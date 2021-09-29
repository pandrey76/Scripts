function build_and_install_debug_shared_openssl() {
    local PATH_TO_ARCHIVE_FILE
    local PATH_TO_OUTPUT

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
                echo "Archive file with openssl source files doesn't exist."
                exit 0
            fi
        fi
   fi
   if [ -z "$2" ]
      then
        echo "No path to openssl install folder supplied"
        exit 0
   else
        echo "Command prompt arguments: $2"
        if [[ -d "$2" ]]
          then
            PATH_TO_OUTPUT="$2"
        else
            echo "The output folder doesn't exist. Try create it."
            mkdir "$2"
            PATH_TO_OUTPUT="$2"
        fi
   fi

   echo "Path to archive file: ${PATH_TO_ARCHIVE_FILE}"
   echo "Path to unpacking openssl folder: ${PATH_TO_OUTPUT}"

   if [[ -d "${PATH_TO_OUTPUT}" ]]
      then
         echo "Removing output folder: ${PATH_TO_OUTPUT}"
         rm -r -f "${PATH_TO_OUTPUT}"
   fi
   if [[ -d "${PATH_TO_OUTPUT}" ]]
      then
         echo "Error! The folder ${PATH_TO_OUTPUT} doesn't removing."
         exit 0
   fi
   mkdir "${PATH_TO_OUTPUT}"
   if [[ -d "${PATH_TO_OUTPUT}" ]]
      then
         echo "The folder ${PATH_TO_OUTPUT} is correctly creating."
   fi
   echo "Unpacking openssl archive"
   tar xvf "${PATH_TO_ARCHIVE_FILE}" -C "${PATH_TO_OUTPUT}"
   cd "${PATH_TO_OUTPUT}"
   echo "Current folder: $(pwd)"
   OPENSSL_SOURCE_FOLDER_PATH="$(find $(pwd) -type d -name openssl*)"
   echo "Full path to openssl folder: ${OPENSSL_SOURCE_FOLDER_PATH}"
   cd "${OPENSSL_SOURCE_FOLDER_PATH}"
   sed -i -e 's/\r$//' ./config
   ./config shared -d --prefix=${PATH_TO_OUTPUT}/Install/
   make
   make test
   make install
}

build_and_install_debug_shared_openssl "/home/admin1/acvp/OpenSSL/OpenSSL_v.1.0.2s/openssl-1.0.2s.tar.gz" "/home/admin1/acvp/Stend/"
