# Практическая работа

Переходим в каталог `docker_course/practice/10.registry`

## Поднимаем проксирующее зеркало

Запускаем наш собственный registry командой:

```bash
docker run \
  -d \
  -p 5000:5000 \
  --restart=always \
  --name=mirror \
  -e REGISTRY_PROXY_REMOTEURL="https://registry-1.docker.io" \
  registry
```

Далее мы можем смотреть логи контейнера в отдельном окне:

```bash
docker logs mirror -f
```

Попробуем позагружать образы командой:

```bash
docker pull 127.0.0.1:5000/library/centos:latest
```

Если всё сделано правильно, в логе контейнера `mirror` будет видно обращения к зеркалу и процесс проксирования.

## Собираем образ, проставляем тэг и пробуем пушить

Склонируйте репозиторий с практикой на машину с Docker и перейдите в директорию `practice/10.registry`:

```bash
git clone git@gitlab.slurm.io:edu/docker_course.git
cd docker_course/practice/10.registry
```

Собираем образ:

```bash
docker build .
```

Смотрим, что получилось:

```bash
docker image ls
```

Добавим тэг командой:

```bash
docker build -t app:1.1 .
```

И попробуем запушить образ куда-нибудь:

```bash
docker push app:1.1
```

Видим, что по умолчанию Docker хочет использовать Docker Hub.

### Самостоятельная работа

Остановите контейнер mirror и запустите такой же, но с именем registry и без указания переменных. Это будет наш простой локальный registry.

Попробуйте теперь пересобрать образ с тэгом `localhost:5000/app:1.1` и запушить его.

## Логинимся в Gitlab registry и пушим туда

0. Создаем новый пустой проект в Gitlab

https://gitlab.slurm.io/projects/new#blank_project

Обязательно назовите его `app`, чтобы не править команды ниже.

1. Создаем project access токен в Gitlab

Слева меню -> внизу `Settings` -> `Access Tokens`

```url
https://gitlab.slurm.io/<ваш номер студента>/app/-/settings/access_tokens

Name - любое имя (например docker-token)
Scopes - read_registry, write_registry
```

**Токен нужно обязательно сохранить!**

2. Переходим в терминал со стендом и пытаемся залогиниться:

```bash
docker login registry.slurm.io
# вместо логина вводите что угодно, пароль - из токена на предыдущем шаге
```

Теперь мы можем туда что-нибудь отправить на хранение.
Соберём образ:

```bash
docker build -t registry.slurm.io/s000001/app:gitlab .
```

И отправим его пылиться на склад:

```bash
docker push registry.slurm.io/s000001/app
```

Как видим, по умолчанию Docker ищет тэг latest.
Давайте его добавим к образу:

```bash
docker tag registry.slurm.io/s000001/app:gitlab registry.slurm.io/s000001/app:latest
```

И теперь заново запушим.<br>
Можете использовать ключ `--all-tags` для того, чтобы в registry попали все тэги образа.

Если всё сделано правильно, мы сможем убедиться, что он доехал куда нам было нужно - откроем в браузере Gitlab и посмотрим:

```url
https://gitlab.slurm.io/<ваш номер студента>/xpaste/container_registry
```

## Поднимаем полноценный Docker registry (Harbor)

1. Перейдем в домашнюю папку, где уже лежит папка с harbor:

```bash
cd ~/
```

2. Перейдём в каталог:

```bash
cd harbor/
```

3. Скопируем заранее подготовленный конфиг:

```bash
cp ~/docker_course/practice/10.registry/harbor.yml .
```

4. Правим в файле harbor.yml имя вашего хоста, заменяя номер студента

```bash
vim harbor.yml
# ищем hostname: harbor.<ваш номер студента>.edu.slurm.io
```

5. Подготовим всё к запуску:

```bash
cp harbor/prepare .
./prepare
```

6. Запускаем проект:

```bash
docker-compose up -d
```

7. Заходим в наш registry:

http://harbor.s000000.edu.slurm.io <br>
*login: admin <br>*
*password: dockerslurm*
