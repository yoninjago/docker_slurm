## Делаем первые шаги в запуске своего приложения в Docker

Важно! Если вы раньше не скачали себе репозиторий - самое время это сделать:
```
git clone git@gitlab.slurm.io:edu/docker_course.git
```

1. Переходим в каталог `docker_course/practice/2.basics/3.start_your_app`

2. Далее переходим в папку `hello/`. Внутри видим два скрипта. Попробуем выполнить `hello.py`:

```
cd hello/
python hello.py
```

3. Теперь попробуем запустить его в Docker. Сперва нам нужно собрать образ, поэтому выполняем команду:

```
docker build .
```

4. Поругалось на отсутствие dockerfile, это правильно. Ведь Docker пока не знает по какой инструкции собрать образ. Копируем dockerfile из папки выше:

```
cp ../Dockerfiles/Dockerfile ./
```

5. Запускаем снова сборку образа и видим, что сборка пошла:

```
docker build .
```

6. Смотрим на образы и видим странное имя. Мы не поставили тег, исправляемся. Пересобираем образ, удалив прошлый:

```
docker images
docker rmi <image ID>
docker build . -t work
```

7. Теперь образ собрался как надо, можем запускать наше приложение:

```
docker run --name hello -d work
```

8. Смотрим в список работающих контейнеров и не видим там наше приложение. Почему?

9. В папке есть второй скрипт, `long.py`. Давайте соберем образ с ним, предварительно скопировав новый dockerfile и заменив им прошлый:

```
cp ../Dockerfiles/Dockerfile_long ./Dockerfile
docker build -t long .
```

10. Обратите внимание, сборка прошла быстрее, а в строчках вывода сборки появились сообщения `Using cache`.

11. Запустим наше приложение и теперь можем увидеть, что с ним все ОК и в списке контейнеров оно работает:

```
docker run --name test_long -d long
docker container ls
```

12. Подчищаем за собой:

```
docker stop test_long && docker rm $(docker ps -a -q) && docker rmi $(docker images -q)
```

## Запустим свой web-сервер в Docker

1. Переходим в каталог `nginx` и смотрим dockerfile:

```
cd ../nginx/
vim Dockerfile
```

2. Правим `custom.conf`, подставив в плейсхолдер свой номер логина:

```
server {
    listen       80;
    server_name  docker.s<ваш номер логина>.edu.slurm.io; <-- Подправить!
```

3. Собираем и запускаем Nginx в Docker. При запуске добавляем ключик `--rm`, чтобы контейнер после остановки удалился сам:

```
docker build -t nginx .
docker run --rm --name nginx -p 80:80 -d nginx
```

4. Пробуем обращаться curl'ом или заходить через браузер в режиме "Инкогнито" на свой сайт

```
curl http://docker.s000099.edu.slurm.io
curl http://docker.s000099.edu.slurm.io/test
```

5. Теперь давайте войдем внутри контейнера и посмотрим что там:

```
docker exec -it nginx /bin/bash
```

6. Установим `vim` и внесем произвольные изменения в `index.html`:

```
apt-get update -y && apt-get install -y vim
vim /usr/share/nginx/html/index.html
```

7. Теперь выйдем из контейнера, остановим его и затем запустим заново:

```
exit
docker stop nginx
docker run --rm --name nginx -p 80:80 -d nginx
```

8. Зайдем снова внутрь контейнера и убедимся что все наши правки и `vim` пропали. Выйдем из контейнера:

```
docker exec -it nginx /bin/bash
vim
exit
```

9. В dockerfile из которого был запущен контейнер, были обозначены переменные окружения. Проверим что они там есть:

```
docker exec nginx env
```

10. Попробуем добавить еще одну переменную окружения при запуске контейнера, сперва остановив текущий:

```
docker stop nginx
docker run --rm --name nginx -p 80:80 -e abc=xyz -d nginx
docker exec nginx env
```

11. Подчищаем за собой:

```
docker stop nginx && docker rmi $(docker images -q)
```

## Best Practices

1. Переходим в каталог `best_practices/`

```
cd ../best_practices
```

2. Видим уже знакомые нам dockerfile, конфиг `Nginx`, а также папку с нашим кодом `app`. Пробуем собрать образ

```
docker build -t test_size .
```

3. Замерим размер получившегося образа:

```
docker images
```

4. Размер получился достаточно большой для запуска простого Nginx'а. Оптимизируем dockerfile. Изменим строку установки на:

```
RUN apt-get update && apt-get install -y \
    nginx \
 && rm -rf /var/lib/apt/lists/*
```
тем самым сократив количество слоев и добавив очистку кеша `apt-get`.

5. Пробуем собрать еще раз образ и замерим размер:

```
docker build -t test_size_2 .
docker images
```

6. Стало лучше, но давайте продолжим. У нас в папке лежит PDF-файл, который точно не нужен для работы нашего Nginx. Исключаем его из сборки через добавление `.dockerignore`, добавив туда также наш `Dockerfile` и `.git`:

```
touch .dockerignore
echo ".git" > .dockerignore
echo "Dockerfile" >> .dockerignore
echo "*.pdf" >> .dockerignore
```

7. Собираем еще раз и смотрим как теперь:

```
docker build -t test_size_3 .
docker images
```

8. Сделаем еще лучше. Изменим базовый образ на `alpine`. Для этого меняем первые три строчки нашего dockerfile на это:

```
FROM alpine

COPY . /opt/

RUN apk add --no-cache nginx && mkdir -p /run/nginx
```

9. Собираем еще раз и смотрим как теперь:

```
docker build -t test_size_4 .
docker images
```

10. С размером теперь стало гораздо лучше. Осталось еще немного причесать dockerfile.

- Опускаем оба COPY из Dockerfile'а ниже уровня EXPOSE
- Раздаем базовому образу и приложению конкретные версии

```
alpine:3.14.3
...
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/main nginx=1.20.2-r1 \
 && mkdir -p /run/nginx
```
или

```
alpine:3.14.3
...
ENV NGINX_VERSION 1.20.2-r1

RUN apk add --no-cache nginx=${NGINX_VERSION} && mkdir -p /run/nginx
```

Итоговый dockerfile выглядит теперь вот так:

```
FROM alpine:3.14.3

ENV NGINX_VERSION 1.20.2-r1

RUN apk add --no-cache nginx=${NGINX_VERSION} && mkdir -p /run/nginx

EXPOSE 80

COPY . /opt/
COPY custom.conf /etc/nginx/conf.d/

CMD ["nginx", "-g", "daemon off;"]
```

**САМОСТОЯТЕЛЬНАЯ РАБОТА:**
- Исправить dockerfile согласно best practices:

```
FROM ubuntu:latest
COPY ./ /app
WORKDIR /app
RUN apt-get update
RUN apt-get upgrade
RUN apt-get -y install libpq-dev imagemagick gsfonts ruby-full ssh supervisor
RUN gem install bundler
RUN curl -sL https://deb.nodesource.com/setup_9.x | sudo bash -
RUN apt-get install -y nodejs

RUN bundle install --without development test --path vendor/bundle
RUN rm -rf /usr/local/bundle/cache/*.gem 
RUN apt-get clean 
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD [“/app/init.sh”]
```

Правильный ответ: https://habr.com/ru/company/southbridge/blog/452108/
