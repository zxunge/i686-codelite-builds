[![Build i686 versions of CodeLite](https://github.com/zxunge/i686-codelite-builds/actions/workflows/build-codelite.yml/badge.svg)](https://github.com/zxunge/i686-codelite-builds/actions/workflows/build-codelite.yml)

# CodeLite i686 Builds
Automatic builds of i686 architected CodeLite.

## Some Notes About the Releases
Those binaries are built using GitHub Action (GHA) and MSYS2 clang32 port.
The build-deps directory contains the wxWidgets and wx-config program used in building. So you can build other CodeLite Plugins using them.<br />
The build-deps\lib directory includes a clang_dll directory, which was renamed to clang_x64_dll when building CodeLite to meet the wx-config-msys2 program's search requirements. You should know that all binaries are in 32 bit no matter what they are. You might need to change their names when building other plugins.
