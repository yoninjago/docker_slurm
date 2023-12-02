# Практическая работа

Переходим в каталог `docker_course/practice/12.alternatives`

## Запускаем контейнер в Podman

```podman run -d nginx```

```podman container ls```

Смотрим процесс контейнера:
```ps axfo pid,ppid,command | grep runc```

Мы видим, что на самом деле запущен conmon. Это приложение мониторит контейнер и предоставляет средства связи контейнера с внешним миром (stdin/out) и тд.
Conmon использует runc в качестве рантайма (ключ -r) и передаёт ему OCI bundle в качестве аргумента (ключ -b)

Выполним
```runc list```
и увидим наш контейнер

## Запускаем контейнер в Kata

Для начала давайте удалим все контейнеры docker

```docker container rm $(docker container ls -aq) --force```

На стендах установлен runtime kata
Сменим runtime для docker на kata:
Для этого в `/etc/docker/daemon.json`
нужно добавить
```json
{
  "default-runtime": "kata-runtime",
  "runtimes": {
    "kata-runtime": {
      "path": "/usr/bin/kata-runtime"
    }
  }
},
```

и перезапускаем докер

```bash
systemctl restart docker
```

Теперь запустим контейнер через docker как обычно
```docker run -d --name kata --rm nginx```

и посмотрим на этот контейнер через
```kata-runtime list```

Выполним `pstree`
и видим `qemu` в процессах

Выполним
```runc --root /run/docker/runtime-runc/moby list```
и не увидим наш контейнер

Теперь выполним
```uname -a``` на хостовой системе
и
```docker exec kata uname -a```

Видим, что версии ядра отличаются!

## Самостоятельная работа

Собираем контейнер через Buildah

Возьмем Dockerfile из части 11, Безопасность Docker.

Используя команду `buildah help`, соберём image в buildah, но запустим его в docker.


<details>
  <summary>Решение:</summary>

  ```bash
  buildah build-using-dockerfile -f Dockerfile -t buildah-demo
  buildah images
  buildah push localhost/buildah-demo docker-daemon:demo:latest
  docker run --name buildah demo buildah-demo
  ```

</details>
