1. Правим драйвер логирования в настройках демона

`vim /etc/docker/daemon.json`

```
{
    "bip": "10.5.0.1/16",
    "default-address-pools":[
      {
        "base":"192.168.0.0/16",
        "size":28
      }
    ],                        <-- Здесь ставим запятую
    "log-driver": "journald"  <-- Вставляем строку
}
```

2. Перезапускаем docker:

```
systemctl restart docker.service
```

3. Запускаем контейнер `hello`:

```
docker run --name hello -d hello-world
```

4. Смотрим его лог:

```
journalctl CONTAINER_NAME=hello
```

5. Возвращаем обратно настройки демона - убираем драйвер логирования и запятую
