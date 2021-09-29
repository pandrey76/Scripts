function build_gost_engine()    {
    local PATH_TO_ARCHIVE_FILE
    local PATH_TO_OUTPUT
    local PATH_TO_CMAKE_FOLDER
    local GOST_ENGINE_FOLDER_NAME="engine-master"

    if [ $# -eq 0 ]
      then
        echo "No arguments supplied"
        exit 0
    else
        if [ -z "$1" ]
          then
            echo "No path to openssl archive supplied"
            exit 0
        else
            echo "Command prompt arguments: $1"
            if [[ -f "$1" ]]
              then
                PATH_TO_ARCHIVE_FILE="$1"
            else
                echo "Archive file with engine source files doesn't exist."
                exit 0
            fi
        fi
   fi
   if [ -z "$2" ]
      then
        echo "No path to openssl folder supplied"
        exit 0
   else
        echo "Command prompt arguments: $2"
        if [[ -d "$2" ]]
          then
            PATH_TO_OUTPUT="$2"
        else
            echo "Error. Doesn't receive openssl path to source root folder."
           PATH_TO_OUTPUT="$2"
        fi
   fi
   if [ -z "$3" ]
      then
        echo "No path to cmake folder supplied"
        exit 0
   else
        echo "Command prompt arguments # 3: $3"
        if [[ -d "$3" ]]
          then
            PATH_TO_CMAKE_FOLDER="$3"
        else
            echo "Error. Doesn't receive openssl path to source root folder."
           PATH_TO_CMAKE_FOLDER="$3"
        fi
   fi
    cd "${PATH_TO_OUTPUT}"
   # Checking root openssl  folder
   OPENSSL_SOURCE_FOLDER_PATH="$(find $(pwd) -type d -name openssl* -print -quit)"
   echo "Full path to openssl folder: ${OPENSSL_SOURCE_FOLDER_PATH}"
#    cd "${OPENSSL_SOURCE_FOLDER_PATH}"
#    echo "Current OpenSSL source folder: $(pwd)"
   GOST_ENGINE_SOURCE_FOLDER_PATH="${PATH_TO_OUTPUT}/${GOST_ENGINE_FOLDER_NAME}"
   echo "Full path to gost engine source folder: ${GOST_ENGINE_SOURCE_FOLDER_PATH}"

    if [[ -d "${GOST_ENGINE_SOURCE_FOLDER_PATH}" ]]
        then
            rm -r -f "${GOST_ENGINE_SOURCE_FOLDER_PATH}"
            if [[ -d "${GOST_ENGINE_SOURCE_FOLDER_PATH}" ]]
                then
                    echo "Error. Doesn't removed old source folder of gost engine."
                    exit 0
            fi
    fi

   echo "Unpacking gost engine archive"
   tar xvf "${PATH_TO_ARCHIVE_FILE}" -C "${PATH_TO_OUTPUT}"
   cd "${GOST_ENGINE_SOURCE_FOLDER_PATH}"
   echo "Current folder: $(pwd)"

   mkdir build
   cd build

   "$(${PATH_TO_CMAKE_FOLDER}/bin/cmake -DOPENSSL_ROOT_DIR=${OPENSSL_SOURCE_FOLDER_PATH} -DCMAKE_BUILD_TYPE=Debug ..)"
   "$(${PATH_TO_CMAKE_FOLDER}/bin/cmake --build . --config Debug)"
}

build_gost_engine "$1" "$2" "$3"

# bash ./building_gost_engine.sh "/home/admin1/acvp/OpenSSL/OpenSSL_2021.09.27/gost-engine/TAR/engine-master_27.09.2021.tar.gz" "/home/admin1/acvp/Stend1" "/home/admin1/cmake-3.21.3"
