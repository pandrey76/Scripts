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
CURL_INSTALL_FOLDER="${INSTALL_FOLDER_PROJECT}/curl-7.64.1_install"
LIBACVP_INSTALL_FOLDER="${INSTALL_FOLDER_PROJECT}/libacvp_install"

wget https://www.openssl.org/source/openssl-1.1.1b.tar.gz && tar -xf openssl-1.1.1b.tar.gz -C "${SOURCE_FOLDER_PROJECT}"
mv -f openssl-1.1.1b.tar.gz "${ARCHIVE_FOLDER_PROJECT}"
export OPENSSL_INSTALL="${OPENSSL_INSTALL_FOLDER}"
# Adding debug build ( ./config -d )
cd "${SOURCE_FOLDER_PROJECT}/openssl-1.1.1b" && ./config shared -d --prefix="${OPENSSL_INSTALL}" && make clean && make && make install
#
## Install Curl for network transport
export CURL_INSTALL="${CURL_INSTALL_FOLDER}"
wget https://curl.haxx.se/download/curl-7.64.1.tar.gz && tar -xf curl-7.64.1.tar.gz -C "${SOURCE_FOLDER_PROJECT}"
mv -f curl-7.64.1.tar.gz "${ARCHIVE_FOLDER_PROJECT}"
##
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${OPENSSL_INSTALL}/lib"
# Adding debug build ( ./configure --enable-debug )
cd "${SOURCE_FOLDER_PROJECT}/curl-7.64.1" && ./configure --enable-debug --prefix="${CURL_INSTALL}" --with-ssl="${OPENSSL_INSTALL}" && make && make install
##
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CURL_INSTALL/lib}"

##
cd "${SOURCE_FOLDER_PROJECT}"
#
git clone "https://github.com/cisco/libacvp.git"
cd "libacvp"
##
# Adding debug build ( CFLAGS="-O0 -g" ./configure )
CFLAGS="-O0 -g" ./configure --with-ssl-dir="$OPENSSL_INSTALL" --with-libcurl-dir="$CURL_INSTALL" --prefix="${LIBACVP_INSTALL_FOLDER}" && make && make install
#
export ACV_SERVER="demo.acvts.nist.gov"
export ACV_PORT="443"
export ACV_URI_PREFIX="acvp/v1/"
export ACV_API_CONTEXT="acvp/"
#
cd "${LIBACVP_INSTALL_FOLDER}"
#./app/acvp_app --help
#./app/acvp_app --all_algs

./bin/acvp_app --all_algs