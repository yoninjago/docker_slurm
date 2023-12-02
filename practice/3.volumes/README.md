# Практическая работа:

Переходим в каталог `docker_course/practice/3.volumes`

Создадим тестовый том:

```bash
docker volume create slurm-storage
```

Вот он появился в списке:
```bash
docker volume ls
```

А команда inspect выдаст примерно такой список информации в json:

```bash
docker inspect slurm-storage
[
    {
        "CreatedAt": "2023-02-09T22:38:10Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/slurm-storage/_data",
        "Name": "slurm-storage",
        "Options": null,
        "Scope": "local"
    }
]
```

В какой-то момент в Docker была введена команда `--mount` на замену `-–volume`, но старый синтаксис (и даже местами старое поведение) оставили для совместимости.
Попробуем как-то использовать созданный том, запустим с ним контейнер:

```bash
docker run --rm --mount src=slurm-storage,dst=/data -it ubuntu:22.04 /bin/bash
echo $RANDOM > /data/file
cat /data/file
exit
```

А после самоуничтожения контейнера запустим абсолютно другой и подключим к нему тот же том. Проверяем, что в нашем файле:

```bash
docker run --rm --mount src=slurm-storage,dst=/data -it centos:8 /bin/bash -c "cat /data/file"
```

Вы должны увидеть то же самое значение.

А теперь примонтируем каталог с хоста:

```bash
docker run --mount src=/srv,dst=/host/srv,type=bind --name slurm --rm -it ubuntu:22.04 /bin/bash
```

Помните, что docker не любит относительные пути, лучше указывайте абсолютный!

Теперь попробуем совместить оба типа томов сразу:

```bash
docker run --mount src=/srv,dst=/host/srv,type=bind --mount src=slurm-storage,dst=/data --name slurm -it ubuntu:22.04 /bin/bash
```

Отлично, а если нам нужно передать ровно те же тома другому контейнеру?

```bash
docker run --volumes-from slurm --name backup --rm -it centos:8 /bin/bash
```

Вы можете заметить некий лаг в обновлении данных между контейнерами, это зависит от используемого Docker драйвера файловой системы.

Создавать том заранее необязательно, всё сработает в момент запуска docker run:

```bash
docker run --mount src=newslurm,dst=/newdata --name slurmdocker --rm -it ubuntu:22.04 /bin/bash
```

Посмотрим теперь на список томов:

```bash
docker volume ls
```

Ответ будет примерно таким:

```bash
DRIVER    VOLUME NAME
local     slurm-storage
local     newslurm
```

Ещё немного усложним нашу команду запуска, создадим анонимный том:

```bash
docker run -v /anonymous --name slurmanon --rm -it ubuntu:22.04 /bin/bash
```

Помните, что такой том самоуничтожится после выхода из нашего контейнера, так как мы указали ключ `-–rm`

Если этого не сделать, давайте проверим что будет:

```bash
docker run -v /anonymous --name slurmanon -it ubuntu:22.04 /bin/bash
```

И увидим что-то такое:

```bash
docker volume ls
DRIVER    VOLUME NAME
local     04c490b16184bf71015f7714b423a517ce9599e9360af07421ceb54ab96bd333
local     newslurm
local     slurm-storage
```

**САМОСТОЯТЕЛЬНАЯ РАБОТА:**

Запустите из образа контейнер с вашей любимой БД (для примера это может быть образ `postgres:15`) и в качестве хранилища (у postgres это будет `/var/lib/postgresql/data`) задайте контейнеру `tmpfs`.<br>
Обратите внимание, что для нормального старта Postgres необходимо передать переменную окружения `POSTGRES_PASSWORD`.<br>
Общеизвестно, что базы данных очень любят быстрые операции ввода-вывода. Получившийся у вас контейнер можно использовать для тестирования, например интеграционного, чтобы тесты пробегали быстрее. Ограничить создаваемый RAM-диск в размерах можно опцией `tmpfs-size`.
Если возникли затруднения, пример правильной команды для запуска вы сможете найти в файле `otvet.md`
