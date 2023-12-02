## Запускаем приложение в Docker-compose для локальной разработки

Важно! Если вы не скачали себе репозиторий - самое время это сделать:
```
git clone git@gitlab.slurm.io:edu/docker_course.git
```

1. Переходим в каталог с практикой

```
cd docker_course/practice/4.docker-compose
```

2. Проверяем, что docker-compose установлен:

```
docker-compose version
```

3. Смотрим на содержание папки `4.docker-compose`. В ней нужно подправить два файла:

`nginx/custom.conf:`

```
server {
    listen       80;
    server_name  docker.s<ваш номер логина>.edu.slurm.io; <-- подправить!
```

`test/docker-entrypoint.sh:`

```
...
curl -H "Host: docker.s<ваш номер логина>.edu.slurm.io" --silent --show-error --fail -I http://nginx/ <-- подправить!
...
curl -H "Host: docker.s<ваш номер логина>.edu.slurm.io" --silent --show-error --fail -I http://nginx/phpinfo/ <-- подправить!
```

4. Смотрим файл запуска `docker-compose.yml`

```
vim docker-compose.yml
```

5. Запускаем наше приложение:

```
docker-compose up -d
```

6. Проверяем, что всё запустилось:

```
docker container ls
docker-compose ps
```

7. Подключимся к нашему сайту из браузера, используя режим Инкогнито, на адреса `http://docker.s<ваш номер логина>.edu.slurm.io` и `docker.s<ваш номер логина>.edu.slurm.io/phpinfo/`

8. Произвольно подправим файл `www/index.html` и сразу увидим изменения на главной странице нашего сайта.

9. Останавливаем docker-compose:

```
docker-compose down
```

## Запускаем production-окружение через Docker-compose

1. Смотрим на файл `docker-compose.production.yml` и запускаемся:

```
docker-compose -f docker-compose.production.yml up -d
```

2. Проверяем, что всё запустилось:

```
docker container ls
docker-compose ps
```

## Запускаем тестирование через Docker-compose

1. Смотрим на каталог `test/` и на файл `docker-compose.test.yml`

2. С помощью тестирования мы проверим, что наше приложение действительно работает. Для этого запускаем docker-compose таким образом:

```
docker-compose -f docker-compose.production.yml -f docker-compose.test.yml up --abort-on-container-exit --exit-code-from test
```

3. Смотрим на вывод от docker-compose. Если все хорошо, то в выводе тестирования будут строчки:

```
...
 Check start page: HTTP/1.1 200 OK
...
 Check PHP_FPM work: HTTP/1.1 200 OK
...
```

4. Также для лучшего понимания, привожу пример тестирования через docker-compose с реального проекта:

`docker-compose.yml:`

```
version: '2.1'
services:
  db:
    image: postgres:9.6
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: xpaste_test
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 1s
      timeout: 1s
      retries: 60
    logging:
      driver: none

  app:
    image: ${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}:${CI_COMMIT_REF_SLUG}.${CI_PIPELINE_ID}
    environment:
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: postgres
      DB_PASSWORD: postgres
      DB_NAME: xpaste_test
      RAILS_ENV: test
      RAILS_LOG_TO_STDOUT: 1
    command: /bin/sh -c 'bundle exec rake db:migrate && bundle exec rspec spec'
    depends_on:
      db:
        condition: service_healthy
```

`.gitlab-ci.yml`

```
stages:
  - build
  - test
  - cleanup
  ...

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY/$CI_PROJECT_NAMESPACE/$CI_PROJECT_NAME:$CI_COMMIT_REF_SLUG.$CI_PIPELINE_ID .

test:
  stage: test
  image:
    name: docker/compose:1.23.2
    entrypoint: [""]
  script:
    - docker-compose 
        -p "$CI_PROJECT_NAME"_"$CI_PIPELINE_ID"
      up
        --abort-on-container-exit
        --exit-code-from app
        --quiet-pull

cleanup:
  stage: cleanup
  image:
    name: docker/compose:1.23.2
    entrypoint: [""]
  script:
    - docker-compose -p "$CI_PROJECT_NAME"_"$CI_PIPELINE_ID" down
  when: always
...
```

**САМОСТОЯТЕЛЬНАЯ РАБОТА:**   
Перейти в каталог `docker_course/practice/4.docker-compose/work_yourself`.
Проект в папке представляет из себя приложение на Flask, которое подсчитывает количество обращений к нему и записывает подсчет в Redis. Для сохранения результатов используется Docker Volume.

- Запустить это же приложение, но с healthcheck'ом сервиса `redis` через команду `redis-cli ping`
- Старт сервиса `web` сделать зависимым от здоровья сервиса `redis`
- Также ограничить через compose-файл сервису `redis` RAM до 500 МБ и CPU до 0,5
- Проверить что все получилось можно сделав после запуска и получив значения:

```
docker inspect <имя_контейнера_redis> | grep "Memory\|NanoCpus"

            "Memory": 524288000,
            "NanoCpus": 500000000,
```

либо использовав для проверки утилиту cgget.
- В решении этой практической работы поможет документация: https://docs.docker.com/compose/compose-file/compose-file-v2/ 
- Готовый файл для этой самостоятельной работы лежит в этом же репозитории и называется `docker-compose.yml_otvet`. Можно использовать как шпаргалку
