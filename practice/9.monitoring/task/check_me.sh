#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "Проверяем..."

# проверяем запущен ли контейнер с cadvisor
echo "проверяем запущен ли контейнер с cadvisor"
    if docker container ps |grep "gcr.io/cadvisor" ; then
        echo -e "${GREEN}Контейнер с cadvisor запущен!"
    else
        echo -e "${RED}Контейнер с НЕ cadvisor запущен!"
    fi

# Проверяем, запущен ли nginx-cadvisor с лимитом памяти 100 МБ

echo "Проверяем, запущен ли nginx-cadvisor с лимитом памяти 100 МБ."
    if curl http://localhost/docker/nginx-cadvisor |grep 'Limit</span> 100.00 <span class="unit-label">MB' ; then
        echo -e "${GREEN}Контейнер nginx-cadvisor запущен с лимитом памяти 100 МБ"
    else
        echo -e "${RED}Контейнер nginx-cadvisor либо не запущен, либо имеет другое имя, либо имеет неверный лимит памяти"
    fi

# Проверяем, доступен ли эндпоинт с метриками

echo "Проверяем, доступен ли эндпоинт с метриками."
    if curl -s localhost:80/metrics |grep 'cadvisor_version_info' ; then
        echo -e "${GREEN}Эндпоинт с метриками доступен"
    else
        echo -e "${RED}Эндпоинт с метриками НЕ доступен"
    fi

# Проверяем, доступны ли метрики контейнера nginx-cadvisor

echo "Проверяем, доступны ли метрики контейнера nginx-cadvisor"
    if test "$(cat /opt/nginx-metrics | grep nginx-cadvisor |wc -l)" -ge 40 ; then
        echo -e "${GREEN}Метрики контейнера nginx-cadvisor доступны."
    else
        echo -e "${RED}Метрики контейнера НЕ nginx-cadvisor доступны."
    fi