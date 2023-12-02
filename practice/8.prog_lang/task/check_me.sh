#!/bin/bash

set -e
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

echo "Проверяем вашу работу"

echo "..."; sleep 2

# check that we have container listening on port 9001
for port in 9001 80
do
    if ! docker container ls | grep "$port->" > /dev/null; then
        echo "${RED}Контейнер с приложением на порту $port не запущен${NC}"
        exit 1
    else
        echo "${GREEN}Контейнер с приложением на порту $port запущен${NC}"
        echo "..."; sleep 1
    fi
done

# check that container 9001 gives 200 on root endpoint
status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://127.0.0.1:9001)
if ! [[ "$status_code" -ne 200 ]] ; then
    echo "${GREEN}Главная страница на порту 9001 открывается${NC}"
    echo "..."; sleep 1
else
    echo "${RED}Главная страница на порту 9001 не открывается:${NC}"
    echo "$(curl -X GET -I http://127.0.0.1:9001/ | head)"
    exit 1
fi

# check that container with port 80 has non-root user
if ! [[ -z "$(docker inspect -f '{{ (index .Config.User) }}' $(docker container ls --format='{{json .}}' | jq -r 'select(.Ports | test("80->")) | .ID'))" ]]; then
    echo "${GREEN}Контейнер на порту 80 запущен не от root${NC}"
    echo "..."; sleep 1
else
    echo "${RED}Контейнер на порту 80 запущен от root${NC}"
    exit 1
fi

# check that container 80 gives 200 on root endpoint
status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://127.0.0.1:80)
if ! [[ "$status_code" -ne 200 ]] ; then
    echo "${GREEN}Главная страница на порту 80 открывается${NC}"
    echo "..."; sleep 1
else
    echo "${RED}Главная страница на порту 80 не открывается:${NC}"
    echo "$(curl -X GET -I http://127.0.0.1:80/ | head)"
    exit 1
fi

echo "Проверка завершена"
