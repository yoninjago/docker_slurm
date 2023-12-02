#!/bin/bash

set -e
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

echo "Проверяем вашу работу"

echo "..."; sleep 2

# check if docker containers are running (redis, postgres, app)
for service in app redis postgres
do
    if [ -z $(docker ps --format {{.Names}} -q | grep $service) ]; then
        echo "${RED}Контейнер $service не запущен${NC}"
        exit 1
    else
        echo "${GREEN}Контейнер $service запущен${NC}"
        echo "..."; sleep 1
    fi
done

# check if app container listens to port 80 and response code is 200
status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://127.0.0.1:80)
if ! [[ "$status_code" -ne 200 ]] ; then
    echo "${GREEN}Главная страница открывается${NC}"
else
    echo "${RED}Главная страница не открывается:${NC}"
    echo "$(curl -X GET -I http://127.0.0.1:80/ | head)"
    exit 1
fi

echo "..."; sleep 1

# check if the app doesn't respond with 500 if a random paste is requested
status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://127.0.0.1:80/1337)
if [[ "$status_code" -ne 500 ]] ; then
    echo "${GREEN}Ответ от приложения верный${NC}"
else
    echo "${RED}У приложения проблемы с бэкендом:${NC}"
    echo "$(curl -X GET -I http://127.0.0.1:80/1337 | head)"
    exit 1
fi
