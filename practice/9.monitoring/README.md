# Практическая работа

Переходим в каталог `docker_course/practice/9.monitoring`

## Включаем метрики Docker

Нужно добавить

```json
    "experimental": true,
    "metrics-addr":"0.0.0.0:9100",
```

в daemon.json

Итоговый фаил должен выглядеть примерно вот так:

```json
{
    "experimental": true,
    "metrics-addr":"0.0.0.0:9100",
    "bip": "10.5.0.1/16",
    "default-address-pools":[
      {
        "base":"192.168.0.0/16",
        "size":28
      }
    ],
    "registry-mirrors": ["http://172.20.100.52:5000"]
}
```

Посмотреть метрики можно вот так:
```curl localhost:9100/metrics```

## Смотрим потребление ресурсов контейнером

```docker stats```

Более детальные метрики доступны вот тут:

```bash
/sys/fs/cgroup/memory/docker/<longid>/memory.stat
/sys/fs/cgroup/cpu/docker/<longid>/cpuacct.stat
```

Так же можно воспользоваться утилитой ctop

## Смотрим логи контейнера

Нам понадобится 2 окна с ssh!

В первом окне запускаем
```docker run --name logs -it --rm nginx bash```

Во втором окне выполняем
```docker logs --follow logs```

Возвращаемся в первое окно, выполняем
```echo 123```
и видим в логах 123

Теперь в первом окне выходим из контейнера и выполняем

```docker run --name logs_nginx -d --rm nginx```

А во втором снова
```docker logs --follow logs_nginx```

В первом окне выполняем
```docker exec -it logs_nginx bash```
и снова выполняем
```echo 123```

Но в docker logs ничего нет.

Теперь выполним
```echo 123 > /proc/1/fd/1```
и видим 123 в логах

Во втором окне выходим и смотрим логи с хостовой системы вот тут:
```cat /var/lib/docker/containers/```

## Docker inspect может показать причину падения контейнера

```docker inspect 5476 |jq '.[0] | {State}'```

### Самостоятельная работа

Понять, почему не запускается контейнер
```docker run --name broken_nginx -d -v $(pwd)/conf.d:/etc/nginx/conf.d/ nginx```

Решение:
```docker logs broken_nginx```

Исправить конфигурационный файл

Снова запустить контейнер.
