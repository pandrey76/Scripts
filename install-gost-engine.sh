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

# cmake project
########################################################################

CMAKE_LATEST_RELEASE_URL="https://cmake.org/files/LatestRelease/"
CMAKE_LATEST_RELEASE_HTML=$(curl -s ${CMAKE_LATEST_RELEASE_URL})
[[ ${CMAKE_LATEST_RELEASE_HTML} =~ .*cmake-([0-9][.][0-9][0-9][.][0-9])-SHA-256[.]txt.* ]] && CMAKE_LATEST_RELEASE_VERSION="${BASH_REMATCH[1]}"

if [ -z ${CMAKE_LATEST_RELEASE_HTML} ]
then
    echo "Can't check for latest version of cmake"
else
    echo "Last stable release of cmake is ${CMAKE_LATEST_RELEASE_VERSION}"
fi
CMAKE_LATEST_RELEASE_NAME="cmake-${CMAKE_LATEST_RELEASE_VERSION}"

CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME="${CMAKE_LATEST_RELEASE_NAME}.tar.gz"
CMAKE_LATEST_RELEASE_TARGZ_FILE_URL="${CMAKE_LATEST_RELEASE_URL}${CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME}"
wget --no-check-certificate "${CMAKE_LATEST_RELEASE_TARGZ_FILE_URL}"
tar -xf "./${CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME}" -C "${SOURCE_FOLDER_PROJECT}"
mv -f "./${CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME}" "${ARCHIVE_FOLDER_PROJECT}"

CMAKE_LATEST_RELEASE_SHA256_FILE_NAME="${CMAKE_LATEST_RELEASE_NAME}-SHA-256.txt"
CMAKE_LATEST_RELEASE_SHA256_FILE_URL="${CMAKE_LATEST_RELEASE_URL}${CMAKE_LATEST_RELEASE_SHA256_FILE_NAME}"
wget --no-check-certificate "${CMAKE_LATEST_RELEASE_SHA256_FILE_URL}"
mv -f "./${CMAKE_LATEST_RELEASE_SHA256_FILE_NAME}" "${ARCHIVE_FOLDER_PROJECT}"
# echo ${CMAKE_LATEST_RELEASE_HTML}
# echo ${CMAKE_LATEST_RELEASE_VERSION}
########################################################################
