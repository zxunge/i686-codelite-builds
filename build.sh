#!/usr/bin/bash

set -eux

BUILD_DATE=20240721-86326fa-posix-layout
NAME=CodeLite-build${BUILD_DATE}
HOME_PATH=$(cygpath -m ~)

echo 'export PATH=/clang32/bin:$PATH' >> ~/.$(basename $SHELL)rc
. ~/.$(basename $SHELL)rc

cp -rf /clang32/* /clang64/

git clone https://github.com/wxWidgets/wxWidgets
pushd wxWidgets
git submodule update --init

mkdir build-release
cd build-release
cmake .. -G"MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release                 \
         -DwxBUILD_DEBUG_LEVEL=0                                        \
         -DwxBUILD_MONOLITHIC=1 -DwxUSE_STL=1    \
         -DCMAKE_INSTALL_PREFIX=$HOME/root                              \
         -DCMAKE_CXX_FLAGS=-Wno-unused-command-line-argument            \
         -DCMAKE_C_FLAGS=-Wno-unused-command-line-argument
mingw32-make -j$(nproc) install
popd

git clone https://github.com/eranif/wx-config-msys2.git
pushd wx-config-msys2
mkdir build-release
cd $_
cmake .. -DCMAKE_BUILD_TYPE=Release -G"MinGW Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/root"
mingw32-make -j$(nproc) install
popd

export PATH=$HOME/root/bin:$PATH
export MSYS2_BASE=/d/msys64

git clone https://github.com/eranif/codelite.git
cp -f winprocess_impl.cpp codelite/CodeLite/AsyncProcess/
pushd codelite
git submodule update --init --recursive
mkdir build-release
cd $_
cmake .. -DWXCFG="clang_dll/mswu" -DCMAKE_BUILD_TYPE=Release -G"MinGW Makefiles" -DWXWIN="$HOME/root" -DCMAKE_CXX_FLAGS=-Wno-ignored-attributes -DWITH_POSIX_LAYOUT=ON -Wno-dev
mingw32-make -j$(nproc) install
popd

pushd codelite
mkdir -p build-release/install/build-deps
mkdir -p build-release/install/locale
cp -rf $HOME/root/* build-release/install/build-deps/
cp -rf ./translations/* build-release/install/locale/
cd build-release/install/
7zr a -mx9 -mqs=on -mmt=on $HOME/${NAME}.7z ./*
popd

if [[ -v GITHUB_WORKFLOW ]]; then
  echo "OUTPUT_BINARY=${HOME_PATH}/${NAME}.7z" >> $GITHUB_OUTPUT
  echo "RELEASE_NAME=${NAME}" >> $GITHUB_OUTPUT
  echo "BUILD_DATE=${BUILD_DATE}" >> $GITHUB_OUTPUT
  echo "OUTPUT_NAME=${NAME}.7z" >> $GITHUB_OUTPUT
fi

