#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "Проверяем..."

# Проверяем установлен ли kata-runtime
echo "Проверяем установлен ли kata-runtime"
    if kata-runtime --version |grep "kata-runtime  : 1." ; then
        echo -e "${GREEN}Kata runtime установлен"
    else
        echo -e "${RED}Kata runtime НЕ установлен"
    fi

# Проверяем добавлен ли kata-runtime в docker и имеет ли имя kata
echo "Проверяем добавлен ли kata-runtime в docker и имеет ли имя kata"
    if cat /etc/docker/daemon.json  |grep '"kata":' && cat /etc/docker/daemon.json  |grep kata-runtime ; then
        echo -e "${GREEN}Kata runtime добавлен в docker"
    else
        echo -e "${RED}Kata runtime НЕ добавлен в docker или имеет другое имя"
    fi

# Проверяем использует ли контейнер nginx-kata рантайм kata
echo "Проверяем использует ли контейнер nginx-kata рантайм kata"
    if docker inspect nginx-kata |grep '"Runtime": "kata"' ; then
        echo -e "${GREEN}Контейнер nginx-kata запущен и использует рантайм kata"
    else
        echo -e "${RED}Контейнер nginx-kata не использует рантайм kata, либо не запущен "
    fi

# Проверяем использует ли контейнер nginx-runc рантайм runc
echo "Проверяем использует ли контейнер nginx-runc рантайм runc"
    if docker inspect nginx-kata |grep '"Runtime": "runc"' ; then
        echo -e "${GREEN}Контейнер nginx-runc запущен и использует рантайм runc"
    else
        echo -e "${RED}Контейнер nginx-runc не использует рантайм runc, либо не запущен "
    fi