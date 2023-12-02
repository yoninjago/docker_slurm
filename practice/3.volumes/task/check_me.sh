#!/bin/bash

set -e
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

echo "Проверяем вашу работу"
echo "..."; sleep 2

# check if docker containers are running (redis, postgres, web)
for service in web redis postgres
do
    if [ -z `docker-compose ps -q $service` ] || [ -z `docker ps -q --no-trunc | grep $(docker-compose ps -q $service)` ]; then
        echo "${RED}Контейнер с $service не запущен${NC}"
        exit 1
    else
        echo "${GREEN}Контейнер $service запущен${NC}"
        echo "..."; sleep 1
    fi
done

# check if there is a named volume
if [ -z "$(docker volume ls | grep slurm_data)" ]; then
    echo "${RED}Том для данных не найден${NC}"
    exit 1
else
    echo "${GREEN}Том для данных найден${NC}"
    echo "..."; sleep 1
fi

# check if the volume is mounted in postgres
if ! $(docker inspect -f '{{ (index .Mounts) }}' $(docker-compose ps -q postgres) 2> /dev/null | grep "/var/lib/postgresql/data" &> /dev/null); then
    echo "${RED}Том для данных не смонтирован${NC}"
    exit 1
else
    echo "${GREEN}Том для данных смонтирован по нужному пути${NC}"
    echo "..."; sleep 1
fi

# check if web container listens to port 5000
if ! $(cat < /dev/null > /dev/tcp/127.0.0.1/5000) 2> /dev/null; then
    echo "${RED}Контейнер не слушает порт 5000${NC}"
    exit 1
else
    echo "${GREEN}Контейнер принимает запросы на порт 5000${NC}"
    echo "..."; sleep 1
fi

# check if we can curl and receive correct answer

string="This page has been viewed"
if [[ $(curl -s "http://127.0.0.1:5000") == *"$string"* ]]; then
    echo "${GREEN}Ответ от приложения верный${NC}"
else
    echo "${RED}Ответ от приложения неверный:${NC}"
    echo "$(curl -vs http://127.0.0.1:5000/)"
    exit 1
fi
