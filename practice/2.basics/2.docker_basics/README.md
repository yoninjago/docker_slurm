## Краткая шпаргалка по командам Docker

`docker search <name>` поиск образа в Registry

`docker pull <name>` скачать образ из Registry

`docker build <path/to/dir>` собрать образ

`docker run <name>` запустить контейнер из образа

`docker rm <name>` удалить контейнер

`docker ps` || `docker container ls` вывести список работающих контейнеров

`docker logs <name>` показать логи контейнера

`docker start/stop/restart <name>` действия с контейнером

---

# Практическая работа

1. Давайте запустим контейнер с Nginx. Для этого нам сперва нужно выяснить название образа, из которого можно будет запустить Nginx. Поищем его на Docker Hub:

```
docker search nginx
```

2. Нашли образ, запускаем Nginx:

```
docker run nginx
```

3. Не отдает консоль. Делаем Ctrl+C, смотрим на контейнеры и образы:

```
docker ps
docker ps -a
docker images
```

4. Видим что контейнер остановлен и имеет странное имя. Запускаем снова, но уже с необходимыми ключами, затем смотрим результат:

```
docker run --name my-app -d nginx
docker ps
docker images
```

5. Мы запустили контейнер с Nginx, это веб-сервер, а значит на него можно постучаться. В выводе `docker ps` видим открытый 80-ый порт:

```
[root@docker.s000099.slurm.io /]# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS              PORTS     NAMES
0f2a5c061d37   nginx     "/docker-entrypoint.…"   About a minute ago   Up About a minute   80/tcp    my-app
```

однако в списке открытых портов на сервере его нет:

```
netstat -nlp
```

6. Разберемся с ситуацией. Посмотреть детальную информацию о контейнере нам поможет команда `docker inspect`, выполним ее и посмотрим блок о настройке сети:

```
docker inspect my-app
```

7. Видим что порт не прокинут на наш сервер. Выясним IP-адрес нашего контейнера и обратимся к нему с помощью curl:

```
docker inspect my-app | grep IPAddress
curl <your_ip_address>
```

8. Убедимся, что ответ был действительно от Nginx из контейнера, посмотрим логи:

```
docker logs my-app
```

9. Подчищаем за собой:

```
docker stop my-app && docker rm my-app && docker rmi nginx
```
Убедитесь что нет оставленных контейнеров `docker ps -a`  


**САМОСТОЯТЕЛЬНАЯ РАБОТА:**
- Запустить контейнер с MySQL версии 5.7
- Сделать так, чтобы подключаться к нему можно было напрямую с сервера
- Контейнер должен иметь имя my-database
