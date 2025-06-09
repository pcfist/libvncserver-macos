#!/bin/zsh

set -ex

LIBPNG_VER=1.6.48
WORKDING_DIR="$(dirname "$0")/libpng"

# Check if already built.
if [ -d "$WORKDING_DIR" -a -f "output/lib/libpng.a" ]; then
    return
fi

# check if working dir is all right
if [ ! -d "$WORKDING_DIR" ]; then
    mkdir -p "$WORKDING_DIR"
fi

cd "$WORKDING_DIR"
WORKDING_DIR=$(pwd)

export CFLAGS="-Wall"

cmake -G Xcode -B build \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0 \
    -DCMAKE_MACOSX_BUNDLE=${WORKDING_DIR}/../output \
    -DCMAKE_INSTALL_PREFIX=${WORKDING_DIR}/../output \
    -DPNG_ARM_NEON=on

xcodebuild build \
    -project build/libpng.xcodeproj \
    -scheme ALL_BUILD \
    -configuration Release \
    -destination 'generic/platform=macos' \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    STRIP_INSTALLED_PRODUCT=NO COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO \
    | xcpretty

cd build
cmake -P cmake_install.cmake
