#!/bin/bash

function is_correct_sha256() {
    local PATH_TO_SOURCE_FILE=$1
    local PATH_TO_SHA256_FILE=$2
    if [[ ! -f "${PATH_TO_SOURCE_FILE}" ]];
     then
        echo "The checking file path: ${PATH_TO_SOURCE_FILE} doesn't exist."
        return 1
    fi
    if [[ ! -f "${PATH_TO_SHA256_FILE}" ]];
     then
        echo "The file path that containing crc: ${PATH_TO_SHA256_FILE} doesn't exist."
        return 1
    fi
    local CHECKING_FILE_NAME=${PATH_TO_SOURCE_FILE##*/}
    echo "The calculating fle name is ${CHECKING_FILE_NAME}"
    local CURRENT_CRC_LINE=$(sha256sum "${PATH_TO_SOURCE_FILE}")
    echo "Output from sha256sum work: ${CURRENT_CRC_LINE}"
    
    IFS=' ' read -r CURRENT_CRC CURRENT_FILE <<< ${CURRENT_CRC_LINE}
    printf 'Current CRC: %s    Current file: %s\n' "${CURRENT_CRC}" "${CURRENT_FILE}"

    # echo "Current CRC: ${CURRENT_CRC}"
    # echo "Calculating file name: ${CURRENT_FILE}"

    while IFS=' ' read -r CRC FILE_NAME
      do
        # printf 'CRC: %s, FILE: %s\n' "${CRC}" "${FILE_NAME}"
        if [[ "${PATH_TO_SOURCE_FILE##*/}" == "${FILE_NAME}" ]];
         then
           printf 'CRC: %s, FILE: %s\n' "${CRC}" "${FILE_NAME}"
           if [[ ${CURRENT_CRC} == ${CRC} ]];
             then
               printf 'CRC of file: %s is correct!\n' "${FILE_NAME}"
               return 0
           else
               printf 'CRC of file: %s dont compare to etalone!\n' "${FILE_NAME}"
               return 1
           fi   
        fi
      done <"$PATH_TO_SHA256_FILE"
      printf "Error comparing file name of calculating crc file with file name containing in crc file."
      return 1
}

# ************************************************
#       MUST DOING

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
#OPENSSL_VERSION="3.0.3"
#
#OPENSSL_INSTALL_FOLDER="${INSTALL_FOLDER_PROJECT}/openssl-${OPENSSL_VERSION}"
#export OPENSSL_INSTALL="${OPENSSL_INSTALL_FOLDER}"
#
#
#wget --no-check-certificate https://www.openssl.org/source/openssl-"${OPENSSL_VERSION}".tar.gz && tar -xf openssl-"${OPENSSL_VERSION}".tar.gz -C "${SOURCE_FOLDER_PROJECT}"
#mv -f openssl-"${OPENSSL_VERSION}".tar.gz "${ARCHIVE_FOLDER_PROJECT}"
#
## Adding debug build ( ./config -d )
#cd "${SOURCE_FOLDER_PROJECT}/openssl-${OPENSSL_VERSION}" ./config shared -d --prefix="${OPENSSL_INSTALL}" && make clean && make && make install && make test
#
#export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${OPENSSL_INSTALL}/lib"
#

########################################################################

# cmake project
########################################################################

CMAKE_LATEST_RELEASE_URL="https://cmake.org/files/LatestRelease/"
CMAKE_LATEST_RELEASE_HTML=$(curl -s ${CMAKE_LATEST_RELEASE_URL})
[[ ${CMAKE_LATEST_RELEASE_HTML} =~ .*cmake-([0-9][.][0-9][0-9][.][0-9])-SHA-256[.]txt.* ]] && CMAKE_LATEST_RELEASE_VERSION="${BASH_REMATCH[1]}"

if [[ -z ${CMAKE_LATEST_RELEASE_HTML} ]]
then
    echo "Can't check for latest version of cmake"
else
    echo "Last stable release of cmake is ${CMAKE_LATEST_RELEASE_VERSION}"
fi
CMAKE_LATEST_RELEASE_NAME="cmake-${CMAKE_LATEST_RELEASE_VERSION}"

CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME="${CMAKE_LATEST_RELEASE_NAME}.tar.gz"
CMAKE_LATEST_RELEASE_TARGZ_FILE_URL="${CMAKE_LATEST_RELEASE_URL}${CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME}"
# wget --no-check-certificate "${CMAKE_LATEST_RELEASE_TARGZ_FILE_URL}"

CMAKE_LATEST_RELEASE_SHA256_FILE_NAME="${CMAKE_LATEST_RELEASE_NAME}-SHA-256.txt"
CMAKE_LATEST_RELEASE_SHA256_FILE_URL="${CMAKE_LATEST_RELEASE_URL}${CMAKE_LATEST_RELEASE_SHA256_FILE_NAME}"
# wget --no-check-certificate "${CMAKE_LATEST_RELEASE_SHA256_FILE_URL}"

is_correct_sha256 "./${CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME}" "./${CMAKE_LATEST_RELEASE_SHA256_FILE_NAME}"
if [[ $? -eq 1 ]]
  then
   echo "The file '${CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME}' don't match to CRC."
fi

tar -xf "./${CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME}" -C "${SOURCE_FOLDER_PROJECT}"
mv -f "./${CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME}" "${ARCHIVE_FOLDER_PROJECT}"
mv -f "./${CMAKE_LATEST_RELEASE_SHA256_FILE_NAME}" "${ARCHIVE_FOLDER_PROJECT}"

# Building cmake project
# **********************************************************************

CMAKE_LATEST_RELEASE_INSTALLATION_FOLDER="${INSTALL_FOLDER_PROJECT}/${CMAKE_LATEST_RELEASE_NAME}"
printf 'Full path to cmake installation folder: %s' "${CMAKE_LATEST_RELEASE_INSTALLATION_FOLDER}"

CMAKE_LATEST_RELEASE_SOURCE_FOLDER="${SOURCE_FOLDER_PROJECT}/${CMAKE_LATEST_RELEASE_NAME}"
printf 'Full path to cmake source folder: %s' "${CMAKE_LATEST_RELEASE_SOURCE_FOLDER}"
cd "${CMAKE_LATEST_RELEASE_SOURCE_FOLDER}"

./bootstrap --prefix="${CMAKE_LATEST_RELEASE_INSTALLATION_FOLDER}/"
make
make install

# **********************************************************************
# echo ${CMAKE_LATEST_RELEASE_HTML}
# echo ${CMAKE_LATEST_RELEASE_VERSION}
########################################################################

#
########################################################################
########################################################################
