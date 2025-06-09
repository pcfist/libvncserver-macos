#!/bin/zsh

set -ex
WORKDING_DIR="$(dirname "$0")/liblzo"

# Check if already built.
if [ -d "$WORKDING_DIR" -a -f "output/lib/liblzo2.a" ]; then
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
    -DCMAKE_INSTALL_PREFIX=${WORKDING_DIR}/../output \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0

xcodebuild build \
    -project build/lzo.xcodeproj \
    -scheme ALL_BUILD \
    -configuration Release \
    -destination 'generic/platform=macos' \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    STRIP_INSTALLED_PRODUCT=NO COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO \
    | $(XCPRETTY_CMD)

cd build
cmake -P cmake_install.cmake
