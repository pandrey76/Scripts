#!/bin/bash

CURRENT_USER=""
if [ $# -eq 0 ]
  then
    echo "Error! No any command prompt arguments supplied."
    exit 0
else
    if [ -z "$1" ]
      then
        echo "Error! Please, enter current logging user name.(No first command prompt argument supplied.)"
        exit 0
    else
        echo "The current user: $1"
        CURRENT_USER="$1"
    fi

    PYTHON3_INTERPRETER=""
       if [ -z "$2" ]
          then
            echo "Error! Please, enter path to python3 interpreter or enter 'python3' for system interpreter (No second command prompt argument supplied.)"
        else
            echo "The python3 interpreter: $2"
            PYTHON3_INTERPRETER="$2"
        fi
fi

echo "Working script ${BASH_SOURCE[0]}"
CURRENT_SCRIPT_FOLDER=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
echo "Current script folder: ${CURRENT_SCRIPT_FOLDER}"

INSTALL_ACVP_SERVER_SCRIPT_NAME="install_acvp_server"
INSTALL_ACVP_SERVER_SCRIPT_NAME_WITH_EXT="${INSTALL_ACVP_SERVER_SCRIPT_NAME}.sh"

PATH_TO_INSTALL_ACVP_SERVER_SCRIPT="${CURRENT_SCRIPT_FOLDER}/${INSTALL_ACVP_SERVER_SCRIPT_NAME_WITH_EXT}"
echo "Full path to script ${INSTALL_ACVP_SERVER_SCRIPT_NAME_WITH_EXT} folder: ${PATH_TO_INSTALL_ACVP_SERVER_SCRIPT}"

PATH_TO_CLIENT_CVP_ETALONE_REALIZATION="${CURRENT_SCRIPT_FOLDER}/ACVP_PROJECT/INSTALLATION/libacvp_install/bin/acvp_app"

echo "Change end line symbols in es: find ${CRYPTOGRAPHY_VERIFICATION_SERVER_FOLDER} -type f | grep -P '.*\.sh' |  xargs sed -i -e 's/\r$//'"
sed -i -e 's/\r$//' "${PATH_TO_INSTALL_ACVP_SERVER_SCRIPT}"

FULL_RUNNING_STRING_FOR_INSTALL_ACVP_SERVER_SCRIPT="${PATH_TO_INSTALL_ACVP_SERVER_SCRIPT} ${CURRENT_USER} ${PYTHON3_INTERPRETER} ${PATH_TO_CLIENT_CVP_ETALONE_REALIZATION}"
echo "Full running string for install_acvp_server.sh script executing: ${FULL_RUNNING_STRING_FOR_INSTALL_ACVP_SERVER_SCRIPT}"
bash "${PATH_TO_INSTALL_ACVP_SERVER_SCRIPT}" "${CURRENT_USER}" "${PYTHON3_INTERPRETER}" "${PATH_TO_CLIENT_CVP_ETALONE_REALIZATION}"

IP="192.168.15.1"
PORT="8000"
PATH_TO_RUNNING_CVP_SERVER_SCRIPT="${CURRENT_SCRIPT_FOLDER}/CryptographyVerificationServer/scripts/run_cvp_server.sh"
echo "Running start server script: ${PATH_TO_RUNNING_CVP_SERVER_SCRIPT} ${IP} ${PORT}"


bash "${PATH_TO_RUNNING_CVP_SERVER_SCRIPT}" "${IP}" "${PORT}"
