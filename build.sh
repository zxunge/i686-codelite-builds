#!/usr/bin/bash

set -eux

BUILD_DATE=20240702
NAME=CodeLite-build${BUILD_DATE}
HOME_PATH=$(cygpath -m ~)

echo 'export PATH=/clang32/bin:$PATH' >> ~/.$(basename $SHELL)rc
. ~/.$(basename $SHELL)rc

cp -rf /clang32/* /clang64/*

git clone https://github.com/wxWidgets/wxWidgets
pushd wxWidgets
git submodule update --init

mkdir build-release
cd build-release
cmake .. -G"MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release                 \
         -DwxBUILD_DEBUG_LEVEL=0                                        \
         -DwxBUILD_MONOLITHIC=1 -DwxBUILD_SAMPLES=SOME -DwxUSE_STL=1    \
         -DCMAKE_INSTALL_PREFIX=$HOME/root                              \
         -DCMAKE_CXX_FLAGS=-Wno-unused-command-line-argument
mingw32-make -j$(nproc)
popd

pushd $HOME/root/
ls
popd

git clone https://github.com/eranif/wx-config-msys2.git
pushd wx-config-msys2
mkdir build-release
cd $_
cmake .. -DCMAKE_BUILD_TYPE=Release -G"MinGW Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/root"
mingw32-make -j$(nproc) install
popd

export PATH=$HOME/root/bin/:$PATH
export MSYS2_BASE=/D/msys64

git clone https://github.com/eranif/codelite.git
pushd codelite
git submodule update --init --recursive
mkdir build-release
cd $_
cmake .. -DCMAKE_BUILD_TYPE=Release -G"MinGW Makefiles" -DWXWIN="$HOME/root" -DCMAKE_INSTALL_PREFIX=~/codelite -Wno-dev
mingw32-make -j$(nproc) install
popd

7zr a -mx9 -mqs=on -mmt=on ~/${NAME}.7z ~/codelite

if [[ -v GITHUB_WORKFLOW ]]; then
  echo "OUTPUT_BINARY=${HOME_PATH}/${NAME}.7z" >> $GITHUB_OUTPUT
  echo "RELEASE_NAME=${NAME}" >> $GITHUB_OUTPUT
  echo "BUILD_DATE=${BUILD_DATE}" >> $GITHUB_OUTPUT
  echo "OUTPUT_NAME=${NAME}.7z" >> $GITHUB_OUTPUT
fi

