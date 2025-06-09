#!/bin/zsh

set -ex

WORKDING_DIR="$(dirname "$0")/libjpeg"

# Check if already built.
if [ -d "$WORKDING_DIR" -a -f "output/lib/libturbojpeg.a" ]; then
    echo "libturbojpeg: Already up to date"
    return
fi

# check if working dir is all right
if [ ! -d "$WORKDING_DIR" ]; then
    mkdir -p "$WORKDING_DIR"
fi

cd "$WORKDING_DIR"
WORKDING_DIR=$(pwd)

git clean -fdx

export CFLAGS="-Wall -arch arm64 -miphoneos-version-min=13.0 -funwind-tables"

cat <<EOF >toolchain.cmake
set(BUILD_SHARED_LIBS OFF)
set(CMAKE_OSX_DEPLOYMENT_TARGET 13.0)
set(CMAKE_C_COMPILER /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang)
EOF

cmake -G Xcode -B build \
    -DENABLE_SHARED=0 \
    -DWITH_JPEG8=1 \
    -DCMAKE_INSTALL_PREFIX=${WORKDING_DIR}/../output \
    -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake

xcodebuild build \
    -project build/libjpeg-turbo.xcodeproj \
    -scheme ALL_BUILD \
    -configuration Release \
    -destination 'generic/platform=macos' \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    STRIP_INSTALLED_PRODUCT=NO COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO \
    | xcpretty

cd build
ln -s Release-macos Release
cmake -P cmake_install.cmake
