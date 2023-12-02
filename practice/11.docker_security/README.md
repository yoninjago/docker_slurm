# Практическая работа

Переходим в каталог `docker_course/practice/11.docker_security`

## Привилегированные контейнеры

```docker run --privileged --rm -it nginx:1.21.3 bash``` Запускаем привелигированный контейнер  
```mkdir /mnt/hdd & mount /dev/sda1 /mnt/hdd``` Создаем директорию и монтируем хост  
```ls -la /mnt/hdd``` Видим хостовую файловую систему

## Distroless контейнеры

Проверяем наличие утилит в контейнерах

```bash
docker run --rm -it --entrypoint bash gcr.io/distroless/java-debian11 
docker run --rm -it gcr.io/distroless/java-debian11 apt install bash
docker run --rm -it gcr.io/distroless/java-debian11 ping ya.ru
```

## Собираем контейнер from:scratch

Смотрим докерфайл, демонстрирующий сборку from:scratch
```сat Dockerfile```

```ls -lrt```
смотрим размер файла hello

```bash
docker build --tag hello .
docker image ls hello - размер такой же как у бинаря
docker run --rm hello
```
