#!/bin/bash

display_help() {
    echo "Usage: $0 [OPTION]"
    echo
    echo "   --host-name=<host-name>            specify machine name(required)"
    echo "   --export-path=<export-path>        specify export path - location where zip files will be saved"
    echo "   --help                             display this help and exit"
    exit 1
}

for i in "$@"
do
    case $i in
        --host-name=*)
            HOST_NAME="${i#*=}"
            shift
        ;;
        --export-path=*)
            EXPORT_PATH="${i#*=}"
            shift
        ;;
        --help)
            display_help
            shift            
    esac
done


if [ -z $HOST_NAME ]
then
    echo "Usage: machine-import --host-name=<machine-name>"
    exit 1
fi

if [[ $HOST_NAME =~ .*\/.* ]] || [ $HOST_NAME == '..' ] || [ $HOST_NAME == '.' ]
then
    echo "invalid host '$HOST_NAME'"
    exit 1
fi

if [ -z $EXPORT_PATH ]
then
    EXPORT_PATH=$(pwd)
fi

if [ ! -w $EXPORT_PATH ]
then
    echo "${EXPORT_PATH} not writable"
    exit 1
fi



certs=(CaCertPath CaPrivateKeyPath ClientKeyPath ClientCertPath)

files=(ServerCertPath ServerKeyPath CaCertPath ClientKeyPath ClientCertPath)

mkdir  -p ${EXPORT_PATH} \
&& rm -rf /tmp/${HOST_NAME} \
&& mkdir -p /tmp/${HOST_NAME}/machine \
&& cp -rv ${HOME}/.docker/machine/machines/${HOST_NAME}/config.json /tmp/${HOST_NAME}/machine/  \
&& cat /tmp/${HOST_NAME}/machine/config.json \
  | sed -e 's|"SSHKeyPath": ".*"|"SSHKeyPath": ""|g' \
  | sed -e 's|"SSHKey": ".*"|"SSHKey": ""|g' \
  | sed -e 's|"SSHUser": ".*"|"SSHUser": ""|g' \
  > /tmp/${HOST_NAME}/machine/config.json.stub \
&& mv /tmp/${HOST_NAME}/machine/config.json.stub /tmp/${HOST_NAME}/machine/config.json 


for file in ${certs[@]}; do
    FILENAME=$(cat /tmp/${HOST_NAME}/machine/config.json| grep ${file} | sed "s|\"${file}\":||" | tr -d '",'| tr -d [:space:])    
    [ -s ${FILENAME} ] && cp -rv ${VERBOSE} ${FILENAME} /tmp/${HOST_NAME}/machine
    
done


for file in ${files[@]}; do
    FILENAME=$(cat /tmp/${HOST_NAME}/machine/config.json| grep ${file} | sed "s|\"${file}\":||" | tr -d '",'| tr -d [:space:])    
    [ -s ${FILENAME} ] && cp -rv ${VERBOSE} ${FILENAME} /tmp/${HOST_NAME}/machine
done

cat /tmp/${HOST_NAME}/machine/config.json | sed -e "s:${HOME}:{{HOME}}:g" > /tmp/${HOST_NAME}/machine/config.json.stub \
&& mv /tmp/${HOST_NAME}/machine/config.json.stub /tmp/${HOST_NAME}/machine/config.json \
&& cd /tmp/${HOST_NAME} \
&& zip -r --quiet ${VERBOSE} ${ENCRYPT} ${HOST_NAME}.zip . \
&& cd ${CURDIR} \
&& cp -v /tmp/${HOST_NAME}/${HOST_NAME}.zip ${EXPORT_PATH} \
&& rm -rf /tmp/${HOST_NAME}


echo "${EXPORT_PATH}/${HOST_NAME}.zip"
