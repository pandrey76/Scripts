#!/bin/bash

# ************************************************
#       MUST DOING
#
#       1. При загрузки openssl из интернета необходимо проверять CRC (sha256).
#
# ************************************************

PROJECT_FOLDER_NAME="GOST_ENGINE"
INSTALL_FOLDER_NAME="INSTALLATION"
SOURCE_FOLDER_NAME="SOURCE"
ARCHIVE_FOLDER_NAME="ARCHIVE"

echo "Working script ${BASH_SOURCE[0]}"
CURRENT_SCRIPT_FOLDER=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
echo "Current script folder: ${CURRENT_SCRIPT_FOLDER}"

# BASE_FOLDER=$(pwd)

mkdir "./${PROJECT_FOLDER_NAME}"
cd "./${PROJECT_FOLDER_NAME}"

PROJECT_FOLDER="${CURRENT_SCRIPT_FOLDER}/${PROJECT_FOLDER_NAME}"

mkdir "${INSTALL_FOLDER_NAME}"
mkdir "${SOURCE_FOLDER_NAME}"
mkdir "${ARCHIVE_FOLDER_NAME}"

INSTALL_FOLDER_PROJECT="${PROJECT_FOLDER}/${INSTALL_FOLDER_NAME}"
SOURCE_FOLDER_PROJECT="${PROJECT_FOLDER}/${SOURCE_FOLDER_NAME}"
ARCHIVE_FOLDER_PROJECT="${PROJECT_FOLDER}/${ARCHIVE_FOLDER_NAME}"



# OpenSSL project
########################################################################
OPENSSL_VERSION="3.0.3"

OPENSSL_INSTALL_FOLDER="${INSTALL_FOLDER_PROJECT}/openssl-${OPENSSL_VERSION}-install"
export OPENSSL_INSTALL="${OPENSSL_INSTALL_FOLDER}"


wget --no-check-certificate https://www.openssl.org/source/openssl-"${OPENSSL_VERSION}".tar.gz && tar -xf openssl-"${OPENSSL_VERSION}".tar.gz -C "${SOURCE_FOLDER_PROJECT}"
mv -f openssl-"${OPENSSL_VERSION}".tar.gz "${ARCHIVE_FOLDER_PROJECT}"

# Adding debug build ( ./config -d )
cd "${SOURCE_FOLDER_PROJECT}/openssl-${OPENSSL_VERSION}" ./config shared -d --prefix="${OPENSSL_INSTALL}" && make clean && make && make install && make test

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${OPENSSL_INSTALL}/lib"


########################################################################
