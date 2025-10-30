#!/usr/bin/env bash
set -e
set -x

CXX=${CXX:-clang++}
if ! command -v "${CXX}" >/dev/null 2>&1; then
  if command -v g++ >/dev/null 2>&1; then
    CXX=g++
  elif command -v c++ >/dev/null 2>&1; then
    CXX=c++
  else
    echo "No suitable C++ compiler found" >&2
    exit 1
  fi
fi

PBC_INCLUDE_DIR=${PBC_INCLUDE_DIR:-/usr/local/include}
PBC_LIB_DIR=${PBC_LIB_DIR:-/usr/local/lib/pbc}

if [ ! -f "${PBC_INCLUDE_DIR}/pbc/compress-c.h" ]; then
  echo "Could not find PBC headers under ${PBC_INCLUDE_DIR}." >&2
  echo "Please run ./install_pbc.sh or set PBC_INCLUDE_DIR to a valid include directory." >&2
  exit 1
fi

if [ ! -d "${PBC_LIB_DIR}" ]; then
  echo "Could not find PBC libraries under ${PBC_LIB_DIR}." >&2
  echo "Please run ./install_pbc.sh or set PBC_LIB_DIR to a valid library directory." >&2
  exit 1
fi

PBC_EXAMPLE_HOME="$( cd "$(dirname "${BASH_SOURCE[0]}")/." && pwd )"

mkdir -p "${PBC_EXAMPLE_HOME}/dataset"
cp ../dataset/Apache "${PBC_EXAMPLE_HOME}/dataset/test_data"

"${CXX}" pbc_train_pattern.cc \
  -L"${PBC_LIB_DIR}" -I"${PBC_INCLUDE_DIR}" \
  -lpbc -lpbc_fse -lpbc_fsst -lzstd -lhs -lpthread \
  -o pbc_train_pattern

"${CXX}" pbc_compress.cc \
  -L"${PBC_LIB_DIR}" -I"${PBC_INCLUDE_DIR}" \
  -lpbc -lpbc_fse -lpbc_fsst -lzstd -lhs -lpthread \
  -o pbc_compress

./pbc_train_pattern "${PBC_EXAMPLE_HOME}/dataset/test_data" "${PBC_EXAMPLE_HOME}/dataset/test_data.pat"
./pbc_compress "${PBC_EXAMPLE_HOME}/dataset/test_data" "${PBC_EXAMPLE_HOME}/dataset/test_data.pat"

set +x
set +e
