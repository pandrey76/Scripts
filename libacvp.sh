#!/bin/bash

ACVP_PROJECT_FOLDER_NAME="ACVP_PROJECT"
INSTALL_FOLDER_NAME="INSTALLATION"
SOURCE_FOLDER_NAME="SOURCE"
ARCHIVE_FOLDER_NAME="ARCHIVE"

BASE_FOLDER=$(pwd)
mkdir "${ACVP_PROJECT_FOLDER_NAME}"
cd "${ACVP_PROJECT_FOLDER_NAME}"
ACVP_PROJECT_FOLDER="${BASE_FOLDER}/${ACVP_PROJECT_FOLDER_NAME}"

mkdir "${INSTALL_FOLDER_NAME}"
mkdir "${SOURCE_FOLDER_NAME}"
mkdir "${ARCHIVE_FOLDER_NAME}"

INSTALL_FOLDER_PROJECT="${ACVP_PROJECT_FOLDER}/${INSTALL_FOLDER_NAME}"
SOURCE_FOLDER_PROJECT="${ACVP_PROJECT_FOLDER}/${SOURCE_FOLDER_NAME}"
ARCHIVE_FOLDER_PROJECT="${ACVP_PROJECT_FOLDER}/${ARCHIVE_FOLDER_NAME}"

OPENSSL_INSTALL_FOLDER="${INSTALL_FOLDER_PROJECT}/openssl-1.1.1b_install"
export OPENSSL_INSTALL="${OPENSSL_INSTALL_FOLDER}"

CURL_INSTALL_FOLDER="${INSTALL_FOLDER_PROJECT}/curl-7.64.1_install"
export CURL_INSTALL="${CURL_INSTALL_FOLDER}"

LIB_ACVP_NAME="libacvp"
LIBACVP_INSTALL_FOLDER="${INSTALL_FOLDER_PROJECT}/${LIB_ACVP_NAME}_install"

CRITERION_NAME="Criterion"
CRITERION_INSTALL_FOLDER="${INSTALL_FOLDER_PROJECT}/${CRITERION_NAME}_install"

# OpenSSL project
########################################################################

# wget https://www.openssl.org/source/openssl-1.1.1b.tar.gz && tar -xf openssl-1.1.1b.tar.gz -C "${SOURCE_FOLDER_PROJECT}"

# --no-check-certificate
wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1b.tar.gz && tar -xf openssl-1.1.1b.tar.gz -C "${SOURCE_FOLDER_PROJECT}"
mv -f openssl-1.1.1b.tar.gz "${ARCHIVE_FOLDER_PROJECT}"

# Adding debug build ( ./config -d )
cd "${SOURCE_FOLDER_PROJECT}/openssl-1.1.1b" && ./config shared -d --prefix="${OPENSSL_INSTALL}" && make clean && make && make install
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${OPENSSL_INSTALL}/lib"

########################################################################

# Curl project
########################################################################

# wget https://curl.haxx.se/download/curl-7.64.1.tar.gz && tar -xf curl-7.64.1.tar.gz -C "${SOURCE_FOLDER_PROJECT}"

# --no-check-certificate
wget --no-check-certificate https://curl.haxx.se/download/curl-7.64.1.tar.gz && tar -xf curl-7.64.1.tar.gz -C "${SOURCE_FOLDER_PROJECT}"
mv -f curl-7.64.1.tar.gz "${ARCHIVE_FOLDER_PROJECT}"
##

# Adding debug build ( ./configure --enable-debug )
cd "${SOURCE_FOLDER_PROJECT}/curl-7.64.1" && ./configure --enable-debug --prefix="${CURL_INSTALL}" --with-ssl="${OPENSSL_INSTALL}" && make && make install

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CURL_INSTALL}/lib"

########################################################################


# libacvp Project
#######################################################################

cd "${SOURCE_FOLDER_PROJECT}"

# Clone repository libacvp
git clone "https://github.com/cisco/${LIB_ACVP_NAME}.git"

# Archive libacvp source project
tar -czvf ${LIB_ACVP_NAME}.tar.gz "${LIB_ACVP_NAME}"
mv -f ${LIB_ACVP_NAME}.tar.gz "${ARCHIVE_FOLDER_PROJECT}"

cd "${LIB_ACVP_NAME}"

# Convert new-line symbol to Unix format
# find . -type f -print0 | xargs -0 dos2unix

# Make file configure executable.
chmod a+x configure

# Adding debug build ( CFLAGS="-O0 -g" ./configure )
CFLAGS="-O0 -g" ./configure --with-ssl-dir="$OPENSSL_INSTALL" --with-libcurl-dir="$CURL_INSTALL" --prefix="${LIBACVP_INSTALL_FOLDER}" && make && make install

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${LIBACVP_INSTALL_FOLDER}/lib"
########################################################################

# Criterion Project - test framework for libacvp
########################################################################

cd "${SOURCE_FOLDER_PROJECT}"

git clone --recursive "https://github.com/Snaipe/Criterion.git"

tar -czvf ${CRITERION_NAME}.tar.gz "${CRITERION_NAME}"
mv -f ${CRITERION_NAME}.tar.gz "${ARCHIVE_FOLDER_PROJECT}"

mkdir "${CRITERION_INSTALL_FOLDER}"

cd "${CRITERION_NAME}"

# Install "meson" and "ninja" build system.

echo "Criterion folder:  $(pwd)"

VENV="CriterionBuildTool_VirtualEnvironment"

python3 -m venv ${VENV}

. ${VENV}/bin/activate

# Updating pip
#pip3 install -U pip

# python3 -m pip install meson
pip3 install meson

# python3 -m pip install ninja
pip3 install ninja

# Archive all python package from Virtual Environment
# ////////////////////////////////////////////////////////////

tar -czvf ${VENV}.tar.gz "${VENV}"
mv -f ${VENV}.tar.gz "${ARCHIVE_FOLDER_PROJECT}"

# ////////////////////////////////////////////////////////////

meson build -Dprefix=${CRITERION_INSTALL_FOLDER}

# ninja -C build
# With Debug
ninja -d explain -C build

ninja -C build install

# Testing
ninja -C build test

deactivate

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CRITERION_INSTALL_FOLDER}/lib"

# Linax install Criterium from apt

# sudo add-apt-repository ppa:snaipewastaken/ppa
# sudo apt-get update
# sudo apt-get install criterion-dev

########################################################################

# libacvp run test and help
########################################################################

cd "${SOURCE_FOLDER_PROJECT}/${LIB_ACVP_NAME}"
echo "libacvp folder:  $(pwd)"

cd "test"

# Build libasvp Tests with Criterion

make clean

INCLUDES="-I${CRITERION_INSTALL_FOLDER}/include" make

chmod a+x runtest

./runtest --verbose

# Remove all output test files (sandbox-gmon.[0-9]*)
find . -type f | grep -P ".*sandbox-gmon[.][0-9]*" | xargs rm

# Sample for executing

export ACV_SERVER="demo.acvts.nist.gov"
export ACV_PORT="443"
export ACV_URI_PREFIX="acvp/v1/"
export ACV_API_CONTEXT="acvp/"
export ACV_TOTP_SEED="1234567890"

cd "${LIBACVP_INSTALL_FOLDER}"
./bin/acvp_app --help
# ./bin/acvp_app --all_algs
