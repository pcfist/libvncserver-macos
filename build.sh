#!/bin/zsh

set -ex

# Disable OpenSSL build for now.
OPENSSL_PLATFORM="" # Mac

export XCPRETTY_CMD=tee
if which xcpretty; then
    export XCPRETTY_CMD=xcpretty
fi

# Make sure current working dir matches script location.
# This will allow our script to run correctly even when executed from any directory.
BASE_DIR="$(realpath "$(dirname "$0")")"
cd "${BASE_DIR}"

# Build OpenSSL if required.
if [ ! -z "${OPENSSL_PLATFORM}"  -a  ! -d "Build-OpenSSL-cURL" ]; then
    git clone https://github.com/jasonacox/Build-OpenSSL-cURL.git
    cd Build-OpenSSL-cURL
    ./build.sh -p macos -y
    cd ..
fi

./build_libjpeg.sh
./build_liblzo.sh
./build_libpng.sh
##./build_libsasl.sh

WORKDING_DIR="${BASE_DIR}/libvncserver"
if [ ! -d "$WORKDING_DIR" ]; then
    mkdir -p "$WORKDING_DIR"
fi

cd "$WORKDING_DIR"
WORKDING_DIR=$(pwd)

patch -s -p0 -Vnone < "../libvncserver.patch"
git clean -fdx

cmake -G Xcode -B build \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_INSTALL_PREFIX=${BASE_DIR}/output \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0 \
    -DWITH_EXAMPLES=OFF \
    -DWITH_TESTS=OFF \
    -DLZO_LIBRARIES=$(realpath ../output/lib) \
    -DLZO_INCLUDE_DIR=$(realpath ../output/include) \
    -DJPEG_LIBRARY=$(realpath ../output/lib/libturbojpeg.a) \
    -DJPEG_INCLUDE_DIR=$(realpath ../output/include) \
    -DPNG_LIBRARY=$(realpath ../output/lib/libpng16.a) \
    -DPNG_PNG_INCLUDE_DIR=$(realpath ../output/include) \
    -DWITH_OPENSSL=OFF \
    -DWITH_GCRYPT=OFF \
    -DWITH_GNUTLS=OFF

#    -DOPENSSL_LIBRARIES=$(realpath ../Build-OpenSSL-cURL/openssl/${OPENSSL_PLATFORM}/lib) \
#    -DOPENSSL_CRYPTO_LIBRARY=$(realpath ../Build-OpenSSL-cURL/openssl/${OPENSSL_PLATFORM}/lib/libcrypto.a) \
#    -DOPENSSL_SSL_LIBRARY=$(realpath ../Build-OpenSSL-cURL/openssl/${OPENSSL_PLATFORM}/lib/libssl.a) \
#    -DOPENSSL_INCLUDE_DIR=$(realpath ../Build-OpenSSL-cURL/openssl/${OPENSSL_PLATFORM}/include)

xcodebuild clean build \
    -project build/libvncserver.xcodeproj \
    -scheme ALL_BUILD \
    -configuration Release \
    -destination 'generic/platform=macos' \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    STRIP_INSTALLED_PRODUCT=NO COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO \
    | $XCPRETTY_CMD

cd build
ln -s Release-macos Release
cmake -P cmake_install.cmake

cd "$BASE_DIR"
mkdir -p dist
mkdir -p dist/lib
mkdir -p dist/include
#lipo -thin arm64 Build-OpenSSL-cURL/openssl/${OPENSSL_PLATFORM}/lib/libcrypto.a -output dist/lib/libcrypto.a
#lipo -thin arm64 Build-OpenSSL-cURL/openssl/${OPENSSL_PLATFORM}/lib/libssl.a -output dist/lib/libssl.a
#cp -r Build-OpenSSL-cURL/openssl/${OPENSSL_PLATFORM}/include/* dist/include
cp output/lib/libjpeg.a dist/lib/libjpeg.a
cp output/lib/libturbojpeg.a dist/lib/libturbojpeg.a
cp -r output/include/* dist/include
cp output/lib/liblzo2.a dist/lib/liblzo2.a
cp -r output/include/* dist/include
cp output/lib/libpng16.a dist/lib/libpng16.a
cp output/lib/libpng16.a dist/lib/libpng.a
cp -r output/include/* dist/include
#cp libsasl/output/lib/libsasl2.a dist/lib/libsasl2.a
#cp -r libsasl/output/include/* dist/include
cp output/lib/libvncserver.a dist/lib/libvncserver.a
cp output/lib/libvncclient.a dist/lib/libvncclient.a
cp -r output/include/* dist/include
