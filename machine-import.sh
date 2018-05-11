#!/bin/bash


display_help() {
  echo "Usage: $0 [OPTION]"
  echo
  echo "   --host-name=<host-name>            specify machine name(required)"
  echo "   --host-key=<host-key>              specify machine ssh key"
  echo "   --host-user=<host-user>            specify machine ssh user"
  echo "   --import-path=<path>               specify import path - location where zip files are located, default is working directory"
  echo "   --help                             display this help and exit"
  echo
  exit 1
}

for i in "$@"
do
  case $i in
    --host-name=*)
      HOST_NAME="${i#*=}"
      shift
      ;;
    --host-key=*)
      HOST_KEY="${i#*=}"
      shift
      ;;
    --host-user*)
      HOST_USER="${i#*=}"
      shift
      ;;
    --import-path*)
      IMPORT_PATH="${i#*=}"
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



if [ -z $IMPORT_PATH ]
then
  IMPORT_PATH=$(pwd)
fi



if [ ! -f ${IMPORT_PATH}/${HOST_NAME}.zip ]
then
  echo "${IMPORT_PATH}/${HOST_NAME}.zip : No such file" 
  exit 1
fi


mkdir -p /tmp/${HOST_NAME} \
&& unzip ${IMPORT_PATH}/${HOST_NAME}.zip -d /tmp/${HOST_NAME}  \
&& cat /tmp/${HOST_NAME}/machine/config.json \
  | sed -e "s|\"SSHKeyPath\": \".*\"|\"SSHKeyPath\": \"${HOST_KEY}\"|g" \
  | sed -e "s|\"SSHKey\": \".*\"|\"SSHKey\": \"${HOST_KEY}\"|g" \
  | sed -e "s|\"SSHUser\": \".*\"|\"SSHUser\": \"${HOST_USER}\"|g" \
  | sed -e "s|\"SSHUser\": \".*\"|\"SSHUser\": \"${HOST_USER}\"|g" \
  | sed -e "s|{{HOME}}/.docker/machine/certs|{{HOME}}/.docker/machine/machines/${HOST_NAME}|g" \
  | sed -e "s|{{HOME}}|${HOME}|g" \
  > /tmp/${HOST_NAME}/machine/config.json.stub \
&& mv /tmp/${HOST_NAME}/machine/config.json.stub /tmp/${HOST_NAME}/machine/config.json \
&& mkdir -p ${HOME}/.docker/machine/machines/${HOST_NAME} \
&& cp -rv /tmp/${HOST_NAME}/machine/* ${HOME}/.docker/machine/machines/${HOST_NAME}/ \
&& rm -rf /tmp/${HOST_NAME}

