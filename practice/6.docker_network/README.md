## Разбираемся в имеющимися сетями

1. Посмотрим какие сети уже есть в Docker:

```
docker network ls
```

2. По-умолчанию, все контейнеры подключаются к Bridge-сети. Проверим это, установив `brctl`:

```
yum install bridge-utils -y
```

3. Посмотрим состояние текущего bridge и подключенных интерфейсов:

```
brctl show
ip a
```

4. Запустим два контейнера:

```
docker run -dit --name alpine1 alpine ash
docker run -dit --name alpine2 alpine ash
```

5. Посмотрим теперь на состояние нашего bridge и увидим два подключенных интерфейса контейнеров:

```
brctl show
docker network inspect bridge
```
Или же воспользуемся следующим выражением, для короткого отображения IP адресов наших контейнеров
```
docker network inspect bridge -f '{{range .Containers}}{{println .Name}}{{println .IPv4Address}}{{end}}'
```

6. Зайдем внутрь контейнера и посмотрим сетевые интерфейсы:

```
docker attach alpine1
ip a
```

7. Попингуем внешний мир и соседний контейнер по IP-адресу:

```
ping -c 3 ya.ru
ping -c 3 <ip-адрес второго контейнера>
```

8. Но если мы попробуем попинговать второй контейнер по имени, то ничего не выйдет:

```
ping -c 3 alpine2
```

9. Глянем настройки DNS у контейнера и увидим, что он использует такие же настройки, что и хост:

```
cat /etc/resolv.conf
exit
cat /etc/resolv.conf
```

10. Подчистим за собой:

```
docker container stop alpine1 alpine2
docker container rm alpine1 alpine2
```

## Создаем свою сеть в Docker

1. Создадим свою сеть типа bridge:

```
docker network create --driver bridge alpine-net
```

2. Проверим что все ок:

```
docker network ls
brctl show
docker network inspect alpine-net
```

3. Запустим три контейнера, два из них будут подключены к нашей новой сети, а один нет:

```
docker run -dit --name alpine1 --network alpine-net alpine ash
docker run -dit --name alpine2 --network alpine-net alpine ash
docker run -dit --name alpine3 alpine ash
```

4. Проверим выполненные действия:

```
docker network inspect bridge
docker network inspect alpine-net
brctl show
```

5. Подключимся к контейнеру в нашей созданной сети и попингуем соседние:

```
docker container attach alpine1
ping -c 2 alpine2
ping -c 2 alpine3
```

6. Видим, что контейнер в той же сети теперь пингуется по имени, а в другой сети нет. Более того, к контейнеру другой сети нельзя будет подключиться даже по IP-адресу. Посмотрим его настройки DNS:

```
cat /etc/resolv.conf
exit
```

7. Почистим за собой:

```
docker container stop alpine1 alpine2 alpine3
docker container rm alpine1 alpine2 alpine3
docker network rm alpine-net
```

**САМОСТОЯТЕЛЬНАЯ РАБОТА:**
- Запустить контейнер с alpine на хостовой сети
- В списке интерфейсов контейнера должен быть интерфейс хоста
