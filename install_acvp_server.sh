#!bin/bash

PATH_TO_BASE_INSTALLATION_FOLDER=""
if [ $# -eq 0 ]
  then
    echo "Error! No any command prompt arguments supplied."
    exit 1
else
    if [ -z "$1" ]
      then
        echo "Error! No first command prompt argument supplied."
        exit 1
    else
        echo "First command line argument: $1"
        if [[ -z $(realpath "${1}") ]]
          then
            echo "The command line argument cannot have path to folder structure."
            exit 1
        fi
        PATH_TO_BASE_INSTALLATION_FOLDER=$(realpath "${1}")
        echo "Real path to base installation folder: ${PATH_TO_BASE_INSTALLATION_FOLDER}"
        if [[ ! -d ${PATH_TO_BASE_INSTALLATION_FOLDER} ]]
          then
            echo "Path to base installation folder doesn't exist!"
            exit 1
        fi
    fi
fi

echo "Path to base installation folder: ${PATH_TO_BASE_INSTALLATION_FOLDER}"

PATH_TO_GIT_PROJECT_REPOSITORY=""
if [ -z "$2" ]
  then
    echo "Error! No second command prompt argument supplied."
    exit 1
else
    echo "The second command prompt argument: $2"
    PATH_TO_GIT_PROJECT_REPOSITORY="$2"
fi

if [ -z "${PATH_TO_GIT_PROJECT_REPOSITORY}" ]
  then
    echo "Error! Don't enter the path to git repository project."
    exit 1
fi

CURRENT_SCRIPT_FOLDER=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
echo "Current script folder: ${CURRENT_SCRIPT_FOLDER}"

# CURRENT_REPOSITORY_NAME="CryptographyVerificationServer"
CURRENT_REPOSITORY_NAME=$(basename  ${PATH_TO_GIT_PROJECT_REPOSITORY})
echo "Current git repository name: ${CURRENT_REPOSITORY_NAME}"

CURRENT_REPOSITORY_NAME=$(echo "${CURRENT_REPOSITORY_NAME}" | sed -r 's|^(.*)[.]git$|\1|')
echo "Current git repository name without '.git' extension: ${CURRENT_REPOSITORY_NAME}"

CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER="${PATH_TO_BASE_INSTALLATION_FOLDER}/${CURRENT_REPOSITORY_NAME}"
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

echo "Clone from reprs: ${PATH_TO_GIT_PROJECT_REPOSITORY}"
git clone "${PATH_TO_GIT_PROJECT_REPOSITORY}"

if [ -d "${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER}" ]
    then
        echo "The project ${CURRENT_REPOSITORY_NAME} is correctly cloning from git repository."
        echo "Path to project ${CURRENT_REPOSITORY_NAME} folder: ${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER}"
else
        echo "Error! The project ${CURRENT_REPOSITORY_NAME} is not cloning from git repository!"
        exit 0
fi


# echo "Change end line symbols in all *.sh files: find ${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER} -type f | grep -P '.*\.sh' |  xargs dos2unix"
# find ${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER} -type f | grep -P '.*\.sh' |  xargs dos2unix

echo "Change end line symbols in all *.sh files: find ${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER} -type f | grep -P '.*\.sh' |  xargs sed -i -e 's/\r$//'"
find ${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER} -type f | grep -P '.*\.sh' |  xargs sed -i -e 's/\r$//'


PATH_TO_ACVP_INTERNAL_CLIENT_RUN_SCRIPT="${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER}/acvp-client/run-acvp-client.sh"
echo "Path to script file that run etalone client realization: ${PATH_TO_ACVP_INTERNAL_CLIENT_RUN_SCRIPT}"
# echo "Change end line symbols in file: dos2unix ${PATH_TO_ACVP_INTERNAL_CLIENT_RUN_SCRIPT}"
# cat "${PATH_TO_ACVP_INTERNAL_CLIENT_RUN_SCRIPT}"
# dos2unix "${PATH_TO_INSTALLATION_SCRIPT}"


INSTALLATION_SCRIPT_FILE_NAME="installation.sh"
PATH_TO_INSTALLATION_SCRIPT="${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER}/${INSTALLATION_SCRIPT_FILE_NAME}"
echo "Path to file installation.sh path: ${PATH_TO_INSTALLATION_SCRIPT}"

# echo "Change end line symbols in file: dos2unix ${PATH_TO_INSTALLATION_SCRIPT}"
# dos2unix "${PATH_TO_INSTALLATION_SCRIPT}"

echo "Make file executable: chmod a+x ${PATH_TO_INSTALLATION_SCRIPT}"
chmod a+x "${PATH_TO_INSTALLATION_SCRIPT}"

PATH_TO_PYTHON=""

if [ -z "$3" ]
  then
    PATH_TO_PYTHON="python3"
else
    PATH_TO_PYTHON="$3"
fi
echo "Full path to python interpretater: ${PATH_TO_PYTHON}"

PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION=""
if [ -z "$4" ]
  then
    PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION="/home/admin1/acvp/ACVP_PROJECT/INSTALLATION/libacvp_install/bin/acvp_app"
else
    PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION="$4"
fi
echo "Full path to internal client realization: ${PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION}"

echo "Run script with params: bash ${PATH_TO_INSTALLATION_SCRIPT} ${PATH_TO_PYTHON} ${PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION}"
bash "${PATH_TO_INSTALLATION_SCRIPT}" "${PATH_TO_PYTHON}" "${PATH_TO_ACVP_INTERNAL_CLIENT_REALIZATION}"

# Running script command prompt:
# admin1@ubuntu18:~/acvp/Scripts$ bash install_acvp_server.sh . /home/admin1/VM_SharedFolder/local_git_reprs/CryptographyVerificationServer python3 /home/admin1/acvp/ACVP-CLIENT/ACVP_PROJECT/INSTALLATION/libacvp_install/bin/acvp_app
# admin1@ubuntu18:~/acvp/Scripts$ bash install_acvp_server.sh /home/admin1/acvp/bin/ /home/admin1/VM_SharedFolder/local_git_reprs/CryptographyVerificationServer python3 /home/admin1/acvp/ACVP-CLIENT/ACVP_PROJECT/INSTALLATION/libacvp_install/bin/acvp_app
