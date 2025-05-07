#!/bin/zsh

set -ex

git clone https://github.com/cyrusimap/cyrus-sasl.git
WORKDING_DIR="$(dirname "$0")/cyrus-sasl"

# Create `output` and working dirs if they don't exist.
mkdir -p "$WORKDING_DIR"
mkdir -p output

cd "$WORKDING_DIR"
WORKDING_DIR=$(pwd)

git clean -fdx

OUTPUT_PATH=$(realpath ../output)
export CFLAGS="-Wall"
./autogen.sh --prefix="$OUTPUT_PATH" \
    --with-staticsasl
make install DESTDIR=$(realpath ../output)
cd ..

mv output/**/cyrus-sasl/build/* output
