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

#mkdir "./${PROJECT_FOLDER_NAME}"
#cd "./${PROJECT_FOLDER_NAME}"

PROJECT_FOLDER="${CURRENT_SCRIPT_FOLDER}/${PROJECT_FOLDER_NAME}"
echo "Current project folder: ${PROJECT_FOLDER}"

mkdir -p "${PROJECT_FOLDER}"
cd "${PROJECT_FOLDER}"

mkdir -p "${INSTALL_FOLDER_NAME}"
mkdir -p "${SOURCE_FOLDER_NAME}"
mkdir -p "${ARCHIVE_FOLDER_NAME}"

INSTALL_FOLDER_PROJECT="${PROJECT_FOLDER}/${INSTALL_FOLDER_NAME}"
SOURCE_FOLDER_PROJECT="${PROJECT_FOLDER}/${SOURCE_FOLDER_NAME}"
ARCHIVE_FOLDER_PROJECT="${PROJECT_FOLDER}/${ARCHIVE_FOLDER_NAME}"



# OpenSSL project
########################################################################
OPENSSL_VERSION="3.0.3"
OPENSSL_NAME="openssl-${OPENSSL_VERSION}"
OPENSSL_INSTALL_FOLDER="${INSTALL_FOLDER_PROJECT}/${OPENSSL_NAME}"
export OPENSSL_INSTALL="${OPENSSL_INSTALL_FOLDER}"


wget --no-check-certificate https://www.openssl.org/source/openssl-"${OPENSSL_VERSION}".tar.gz && tar -xf "${OPENSSL_NAME}".tar.gz -C "${SOURCE_FOLDER_PROJECT}"
mv -f openssl-"${OPENSSL_VERSION}".tar.gz "${ARCHIVE_FOLDER_PROJECT}"

# Adding debug build ( ./config -d )
cd "${SOURCE_FOLDER_PROJECT}/${OPENSSL_NAME}"
./config shared -d --prefix="${OPENSSL_INSTALL}"
make clean
make
make install
make test

# export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${OPENSSL_INSTALL}/lib"


########################################################################

# cmake project
########################################################################

CMAKE_LATEST_RELEASE_URL="https://cmake.org/files/LatestRelease/"
CMAKE_LATEST_RELEASE_HTML=$(curl -s ${CMAKE_LATEST_RELEASE_URL})
[[ ${CMAKE_LATEST_RELEASE_HTML} =~ .*cmake-([0-9][.][0-9][0-9][.][0-9])-SHA-256[.]txt.* ]] && CMAKE_LATEST_RELEASE_VERSION="${BASH_REMATCH[1]}"
##
if [[ -z ${CMAKE_LATEST_RELEASE_HTML} ]]
then
    echo "Can't check for latest version of cmake"
else
    echo "Last stable release of cmake is ${CMAKE_LATEST_RELEASE_VERSION}"
fi
CMAKE_LATEST_RELEASE_NAME="cmake-${CMAKE_LATEST_RELEASE_VERSION}"

CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME="${CMAKE_LATEST_RELEASE_NAME}.tar.gz"
CMAKE_LATEST_RELEASE_TARGZ_FILE_URL="${CMAKE_LATEST_RELEASE_URL}${CMAKE_LATEST_RELEASE_TARGZ_FILE_NAME}"
wget --no-check-certificate "${CMAKE_LATEST_RELEASE_TARGZ_FILE_URL}"

CMAKE_LATEST_RELEASE_SHA256_FILE_NAME="${CMAKE_LATEST_RELEASE_NAME}-SHA-256.txt"
CMAKE_LATEST_RELEASE_SHA256_FILE_URL="${CMAKE_LATEST_RELEASE_URL}${CMAKE_LATEST_RELEASE_SHA256_FILE_NAME}"
wget --no-check-certificate "${CMAKE_LATEST_RELEASE_SHA256_FILE_URL}"

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

# Building gost-engine project.
########################################################################

# Downloading last version of gost-engine
# **********************************************************************

cd "${PROJECT_FOLDER}"

# Можно и через git загрузить последнюю версию
# git clone "https://github.com/gost-engine/engine.git"

GITHUB_DOWNLOADING_TARGZ_FILE_NAME="tarball"

GOST_ENGINE_DOWNLOADING_TARGZ_FILE_NAME="tarball"
GOST_ENGINE_TARGZ_FILE_NAME="gost-engine-last-release.tar.gz"

GOST_ENGINE_LATEST_RELEASE_URL="https://api.github.com/repos/gost-engine/engine/${GOST_ENGINE_DOWNLOADING_TARGZ_FILE_NAME}"
echo "Url for downloading last release of gost-engine from GitHub: ${GOST_ENGINE_LATEST_RELEASE_URL}"

wget --no-check-certificate "${GOST_ENGINE_LATEST_RELEASE_URL}"

GOST_ENGINE_LATEST_RELEASE_TARGZ_FILE_PATH="${PROJECT_FOLDER}/${GOST_ENGINE_TARGZ_FILE_NAME}"
# echo "Path to renaming gost-engine tar.gz file: ${GOST_ENGINE_LATEST_RELEASE_TARGZ_FILE_PATH}"

mv  "${PROJECT_FOLDER}/${GOST_ENGINE_DOWNLOADING_TARGZ_FILE_NAME}" "${GOST_ENGINE_LATEST_RELEASE_TARGZ_FILE_PATH}"

tar -xf "${GOST_ENGINE_LATEST_RELEASE_TARGZ_FILE_PATH}" -C "${SOURCE_FOLDER_PROJECT}"
mv -f "${GOST_ENGINE_LATEST_RELEASE_TARGZ_FILE_PATH}" "${ARCHIVE_FOLDER_PROJECT}"

cd "${SOURCE_FOLDER_PROJECT}"

GOST_ENGINE_SOURCE_FOLDER_NAME=""

for FOLDER in */
  do
   echo "${FOLDER}"
     [[ ${FOLDER} =~ ^(gost-engine.*)/$ ]] && GOST_ENGINE_SOURCE_FOLDER_NAME="${BASH_REMATCH[1]}"
     if [[ -z "${GOST_ENGINE_SOURCE_FOLDER_NAME}" ]]
       then
        continue
     else
        echo "${GOST_ENGINE_SOURCE_FOLDER_NAME}"
        break
     fi
done

if [[ -z "${GOST_ENGINE_SOURCE_FOLDER_NAME}" ]]
  then
   echo "Can't match gost-engine source folder!"
   exit 1
fi
# echo $(find "${SOURCE_FOLDER_PROJECT}" -type d | grep -P "${GOST_ENGINE_FIND_FILE_PATTERN}")
GOST_ENGINE_SOURCE_FOLDER_PATH="${SOURCE_FOLDER_PROJECT}/${GOST_ENGINE_SOURCE_FOLDER_NAME}"
echo "Full path to gost-engine folder: ${GOST_ENGINE_SOURCE_FOLDER_PATH}"

# Download libprove
# **********************************************************************

cd "${PROJECT_FOLDER}"
LIBPROV_TARGZ_FILE_NAME="libprov-last-release.tar.gz"
# Загружаем в исходники gost-engine проект libprove
# Можно и через git также загрузить последнюю версию libprove
# git clone "https://github.com/provider-corner/libprov.git"
LIBPROV_LATEST_RELEASE_URL="https://api.github.com/repos/provider-corner/libprov/${GITHUB_DOWNLOADING_TARGZ_FILE_NAME}"
echo "Url for downloading last release of libprov from GitHub: ${LIBPROV_LATEST_RELEASE_URL}"

wget --no-check-certificate "${LIBPROV_LATEST_RELEASE_URL}"

LIBPROV_LATEST_RELEASE_TARGZ_FILE_PATH="${ARCHIVE_FOLDER_PROJECT}/${LIBPROV_TARGZ_FILE_NAME}"
# echo "Path to renaming gost-engine tar.gz file: ${GOST_ENGINE_LATEST_RELEASE_TARGZ_FILE_PATH}"

mv  "${PROJECT_FOLDER}/${GITHUB_DOWNLOADING_TARGZ_FILE_NAME}" "${LIBPROV_LATEST_RELEASE_TARGZ_FILE_PATH}"

tar -xf "${LIBPROV_LATEST_RELEASE_TARGZ_FILE_PATH}" -C "${SOURCE_FOLDER_PROJECT}"

cd "${SOURCE_FOLDER_PROJECT}"
LIBPROV_SOURCE_FOLDER_NAME=""

for FOLDER in */
  do
   echo "${FOLDER}"
     [[ ${FOLDER} =~ ^(.*libprov.*)/$ ]] && LIBPROV_SOURCE_FOLDER_NAME="${BASH_REMATCH[1]}"
     if [[ -z "${LIBPROV_SOURCE_FOLDER_NAME}" ]]
       then
        continue
     else
        echo "${LIBPROV_SOURCE_FOLDER_NAME}"
        break
     fi
done
##
if [[ -z "${LIBPROV_SOURCE_FOLDER_NAME}" ]]
  then
   echo "Can't match gost-engine source folder!"
   exit 1
fi
# echo $(find "${SOURCE_FOLDER_PROJECT}" -type d | grep -P "${GOST_ENGINE_FIND_FILE_PATTERN}")
LIBPROV_SOURCE_FOLDER_PATH="${SOURCE_FOLDER_PROJECT}/${LIBPROV_SOURCE_FOLDER_NAME}"
echo "Full path to libprov folder: ${LIBPROV_SOURCE_FOLDER_PATH}"

cd "${LIBPROV_SOURCE_FOLDER_PATH}"

# cp -a ./provider-corner-libprov-e7057be/. /home/admin1/acvp/Scripts/GOST_ENGINE/SOURCE/gost-engine-engine-b2b4d62/libprov/
cp -a "${LIBPROV_SOURCE_FOLDER_PATH}/." "${GOST_ENGINE_SOURCE_FOLDER_PATH}/libprov/"
rm -rf "${LIBPROV_SOURCE_FOLDER_PATH}"
# echo $(ls)

# **********************************************************************

# Build gostl-engie
# **********************************************************************

## Еще один скрипт сборки gost-engine находится по пути ./gost-engine-engine-ee1986c/.github/script.sh.
## /home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/cmake-3.23.1/bin/cmake -DOPENSSL_ROOT_DIR=/home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/ ..
## /home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/cmake-3.23.1/bin/cmake --build . --config Debug
## /home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/cmake-3.23.1/bin/cmake --build . --target install
## /home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/cmake-3.23.1/bin/cmake -DOPENSSL_ROOT_DIR=/home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3 -DOPENSSL_ENGINES_DIR=/home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/lib64/engines-3 ..
## make
## make test CTEST_OUTPUT_ON_FAILURE=1
## make tcl_tests

# **********************************************************************

## cp /home/admin1/acvp/Scripts/GOST_ENGINE/SOURCE/gost-engine-engine-ee1986c/build/bin/gost.so /home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/ssl/gost.so
##
## В файл openssl.cnf после инструкции "oid_section = new_oids" добавить следующий код (он в приципе приведен в файле example.cnf):
## ******************************************************

## openssl_conf = openssl_def
## [openssl_def]
## engines = engine_section
##
## [engine_section]
## gost = gost_section
##
## [gost_section]
## engine_id = gost
## dynamic_path = /home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/ssl/gost.so
## default_algorithms = ALL

## ******************************************************
## Тестирование работы openssl с gost-engine
## admin1@ubuntu18:~/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/bin$ LD_LIBRARY_PATH="/home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/lib64" ./openssl engine
## admin1@ubuntu18:~/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/bin$ LD_LIBRARY_PATH="/home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/lib64" ./openssl version -e
## admin1@ubuntu18:~/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/bin$ LD_LIBRARY_PATH="/home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/lib64" ./openssl genpkey -algorithm gost2012_256 -pkeyopt paramset:TCB -out ca.key
## admin1@ubuntu18:~/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/bin$ LD_LIBRARY_PATH="/home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/lib64" ./openssl req -new -x509 -md_gost12_256 -days 365 -key ca.key -out ca.cer -subj "/C=RU/ST=Russia/L=Moscow/O=SuperPlat/OU=SuperPlat CA/CN=SuperPlat CA Root"
## admin1@ubuntu18:~/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/bin$ LD_LIBRARY_PATH="/home/admin1/acvp/Scripts/GOST_ENGINE/INSTALLATION/openssl-3.0.3/lib64" ./openssl x509 -in ca.cer -text -noout


## ******************************************************
##
## Проверка подписи, пример с сайта CryptoPro
## **********************************************************************

## openssl cms -sign -engine gostengy -keyform ENGINE -inkey www.example.com -in "doc.txt" -out "doc.signed.txt" -outform PEM -CAfile /path/to/cert/www.example.com.cer -nodetach -signer /path/to/cert/www.example.com.cer

## **********************************************************************
########################################################################