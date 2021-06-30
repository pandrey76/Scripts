#!bin/bash

CURRENT_USER=""
if [ $# -eq 0 ]
  then
    echo "Error! No any command prompt arguments supplied."
    exit 0
else
    if [ -z "$1" ]
      then
        echo "Error! No first command prompt argument supplied."
        exit 0
    else
        echo "The current user: $1"
        CURRENT_USER="$1"
    fi
fi

if [ -z "${CURRENT_USER}" ]
  then
    echo "Error! Don't entered the current user."
    exit 0
fi

# echo "Go to home folder"
# cd ~
#
# echo "Go to ~./acvp folder"
# cd acvp

CURRENT_REPOSITORY_NAME="CryptographyVerificationServer"
echo "Current git repository name: ${CURRENT_REPOSITORY_NAME}"

CURRENT_SCRIPT_FOLDER=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
echo "Current script folder: ${CURRENT_SCRIPT_FOLDER}"

CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER="${CURRENT_SCRIPT_FOLDER}/${CURRENT_REPOSITORY_NAME}"
echo "Full path to project ${CURRENT_REPOSITORY_NAME} folder: ${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER}"

echo "Remove folder: ${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER}"
rm -r -f "${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER}"

if [ -d "${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER}" ]
    then
        echo "Error! The folder ${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER} is still exists!"
        exit 0
else
        echo "The folder ${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER} is correctly removed."
fi        

echo "Clone from reprs: /media/${CURRENT_USER}/9269-8EE1/local_git_reprs/${CURRENT_REPOSITORY_NAME}"
git clone "/media/${CURRENT_USER}/9269-8EE1/local_git_reprs/${CURRENT_REPOSITORY_NAME}"

if [ -d "${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER}" ]
    then
        echo "The project ${CURRENT_REPOSITORY_NAME} is correctly cloning from git repository."
else
        echo "Error! The project ${CURRENT_REPOSITORY_NAME} is not cloning from git repository!"
        exit 0
fi

INSTALLATION_SCRIPT="installation.sh"
PATH_TO_INSTALLATION_SCRIPT= "${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER}/${INSTALLATION_SCRIPT}"
echo "Path to installation.sh path: ${PATH_TO_INSTALLATION_SCRIPT}"

echo "Make file executable: chmod a+x ${PATH_TO_INSTALLATION_SCRIPT}"
chmod a+x "${PATH_TO_INSTALLATION_SCRIPT}"

echo "Change end line symbols in file: dos2unix ${PATH_TO_INSTALLATION_SCRIPT}./CryptographyVerificationServer/installation.sh"
dos2unix "${PATH_TO_INSTALLATION_SCRIPT}"

# if [ -z "$2" ]
#   then
#     PATH_TO_INSTALLATION_SCRIPT="./CryptographyVerificationServer/installation.sh"
# else
#     PATH_TO_INSTALLATION_SCRIPT="$2"
# fi

PATH_TO_PYTHON=""
if [ -z "$2" ]
  then
    PATH_TO_PYTHON="python3"
else
    PATH_TO_PYTHON="$2"
fi
echo "Full path to python interpretater: ${PATH_TO_PYTHON}"

PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION=""
if [ -z "$3" ]
  then
    PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION="/home/admin1/acvp/ACVP_PROJECT/INSTALLATION/libacvp_install/bin/acvp_app"
else
    PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION="$3"
fi
echo "Full path to internal client realization: ${PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION}"

echo "Run script with params: bash ${PATH_TO_INSTALLATION_SCRIPT} ${PATH_TO_PYTHON} ${PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION}"
CURRENT_USER=""
bash "${PATH_TO_INSTALLATION_SCRIPT}" "${PATH_TO_PYTHON}" "${PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION}"
