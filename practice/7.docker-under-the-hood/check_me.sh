#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "Проверяем..."

# Проверяем остановлен ли демон docker
echo "Проверяем остановлен ли демон docker"
    if docker ps ; then
        echo -e "${RED}Демон НЕ остановлен"
    else
        echo -e "${GREEN}Демон docker остановлен"
    fi


# Проверяем установлен ли nerdctl
echo "Проверяем установлен ли nerdctl"
    if nerdctl --version |grep "nerdctl version 0." ; then
        echo -e "${GREEN}nerdctl установлен"
    else
        echo -e "${RED}nerdctl НЕ установлен"
    fi

# Проверяем установлены ли CNI плагины
echo "Проверяем установлены ли CNI плагины"
    if test $(ls /opt/cni/bin/ |wc -l) -ge 10 ; then
        echo -e "${GREEN}CNI плагины установлены"
    else
        echo -e "${RED}CNI плагины НЕ установлены"
    fi

# Проверяем, запущен ли Wordpress
echo "Проверяем, запущен ли Wordpress"
    if curl -s localhost:80 -L  > /dev/null ; then
      if curl -s localhost:80 -L /dev/null |grep "Error establishing a database connection"; then
        echo -e "${RED}Wordpress запущен, но не может подключиться к базе данных"; else
          if curl -s localhost:80 -L /dev/null |grep Працягнуць > /dev/null; then
            echo -e "${GREEN}Wordpress запущен и работает!"
          fi
      fi
      else echo -e "${RED} Wordpress не запущен, либо не использует 80 порт"
    fi