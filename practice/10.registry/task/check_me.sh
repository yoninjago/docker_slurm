#!/bin/bash

set -e
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

echo "Проверяем вашу работу"

echo "..."; sleep 2

# get local student ID
student_id=$(printenv HOSTNAME | awk -F '.' '{print $2}')

# pull the image we want to check
if [ -z "$(docker pull harbor."$student_id".edu.slurm.io/"$student_id"/myapp:v1.2.3)" ]; then
    echo "${RED}Образ контейнера myapp:v1.2.3 не найден в вашем Harbor${NC}"
    exit 1
else
    echo "${GREEN}Образ контейнера myapp:v1.2.3 найден${NC}"
    echo "..."; sleep 1
fi

# and the latest version
if [ -z "$(docker pull harbor."$student_id".edu.slurm.io/"$student_id"/myapp:latest)" ]; then
    echo "${RED}Образ контейнера myapp:latest не найден в вашем Harbor${NC}"
    exit 1
else
    echo "${GREEN}Образ контейнера myapp:latest найден${NC}"
    echo "..."; sleep 1
fi

# and then compare both with sha256
if [ "$(docker inspect --format='{{index .RepoDigests 0}}' harbor."$student_id".edu.slurm.io/"$student_id"/myapp:v1.2.3 | sed 's/.*@sha256://'
)" == "$(docker inspect --format='{{index .RepoDigests 0}}' harbor."$student_id".edu.slurm.io/"$student_id"/myapp:latest | sed 's/.*@sha256://'
)" ]; then
    echo "${GREEN}Образы myapp с тэгами v1.2.3 и latest совпадают${NC}"
else
    echo "${RED}Образы myapp с тэгами v1.2.3 и latest не совпадают${NC}"
fi
