#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
BLUE='\033[0;34m'

yum install libcap-ng-utils -y > /dev/null

echo "Проверяем..."

# Проверяем запущен ли контейнер nginx-cap
echo -e "${BLUE}Проверяем запущен ли контейнер nginx-cap"
    if curl -s localhost:80 > /dev/null && docker container ls |grep nginx-cap > /dev/null; then
         echo -e "${GREEN}Контейнер nginx-cap запущен и отвечает."
         # Проверяем capabilities контейнера nginx-cap
         echo -e "${BLUE}Проверяем capabilities контейнера nginx-cap" 
         if pscap |grep $(docker inspect -f '{{.State.Pid}}' nginx-cap) | grep "chown, setgid, setuid, net_bind_service" |grep -v "dac_override\|kill\|net_raw\|setfcap" > /dev/null ; then
            echo -e "${GREEN}Контейнер nginx-cap имеет только нужные capabilities: chown, setgid, setuid, net_bind_service"
         else
            echo -e "${RED}Контейнер nginx-cap имеет избыточные capabilities, либо не запущен"
         fi
    else
        echo -e "${RED}Контейнер nginx-uncap НЕ запущен или НЕ отвечает по порту 80."
    fi

echo "-----------------------------------------------------"
# Проверяем запущен ли контейнер nginx-rootless
echo -e "${BLUE}Проверяем запущен ли контейнер nginx-rootless"
    if curl -s localhost:8080 > /dev/null && docker container ls |grep nginx-rootless > /dev/null; then
        echo -e "${GREEN}Контейнер nginx-rootless запущен и отвечает."
        # Проверяем пользователя в контейнере nginx-rootless
        echo -e "${BLUE}Проверяем пользователя в контейнере nginx-rootless"
        if docker exec nginx-rootless whoami |grep nginx > /dev/null; then
            echo -e "${GREEN}Контейнер nginx-rootless запущен использует пользователя nginx"
        else
            echo -e "${RED}Контейнер nginx-cap использует пользователя, отличного от nginx, либо не запущен"
        fi
    else
        echo -e "${RED}Контейнер nginx-rootless НЕ запущен или НЕ отвечает по порту 8080."
    fi

echo "-----------------------------------------------------"

# Проверяем запущен ли контейнер nginx-rootless-uncap
echo -e "${BLUE}Проверяем запущен ли контейнер nginx-rootless-uncap"
    if curl -s localhost:8081 > /dev/null && docker container ls |grep nginx-rootless-uncap > /dev/null; then
        echo -e "${GREEN}Контейнер nginx-rootless-uncap запущен и отвечает."
        # Проверяем capabilities контейнера nginx-rootless-uncap
        echo -e "${BLUE}Проверяем capabilities контейнера nginx-rootless-uncap"
        if test $(cat /proc/$(docker inspect -f '{{.State.Pid}}' nginx-rootless-uncap)/status  |grep Cap |grep 0000000000000000| wc -l) -eq 5; then
            echo -e "${GREEN}Контейнер nginx-rootless-uncap имеет только нужные capabilities, то есть никаких."
        else
            echo -e "${RED}Контейнер nginx-rootless-uncap имеет избыточные capabilities, либо не запущен"
        fi
    else
        echo -e "${RED}Контейнер nginx-rootless-uncap НЕ запущен или НЕ отвечает по порту 8081."
    fi
