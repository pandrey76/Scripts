#!/bin/bash

#if [ $# -eq 0 ]
#  then
#    echo "Error! No any command prompt arguments supplied."
#    exit 0
#else
#    if [ -z "$1" ]
#      then
#        echo "Error! Please, enter python version string.
#        exit 0
#    else

#        echo "Error! Please, enter correct python version string .( #.#.#, as example: 3.6.9)
#        echo "The current user: $1"
#        CURRENT_USER="$1"
#    fi
#fi

DOWNLOAD_FOLDER_NAME="Temp-downloads"

cd ~
mkdir ./${DOWNLOAD_FOLDER_NAME}
cd "./${DOWNLOAD_FOLDER_NAME}"


wget --no-check-certificate "https://www.python.org/ftp/python/${DOWNLOADING_PYTHON_VERSION}/Python-3.8.9.tgz"
sudo apt update
sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev
tar xvf Python-${DOWNLOADING_PYTHON_VERSION}.tgz -C .
cd ./Python-${DOWNLOADING_PYTHON_VERSION}
INSTALL_FOLDER=$(pwd)/.python-${DOWNLOADING_PYTHON_VERSION}

# pip is installed
./configure --enable-optimizations --prefix="${INSTALL_FOLDER}"
#./configure --enable-optimizations --with-ensurepip=install --prefix="${INSTALL_FOLDER}"

# Building without unit testing of python modules (-x).
make -xj 8
# make -j 8
sudo make altinstall
