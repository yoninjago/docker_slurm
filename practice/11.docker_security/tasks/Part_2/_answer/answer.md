## Запустим привычный нам nginx более безопасно

### Запустим контейнер nginx без лишних capabilities

Начнём с
```
docker run --cap-drop=ALL --name nginx --rm -p 80:80 nginx:1.21.3
```
Видим ошибку
```
nginx: [emerg] chown("/var/cache/nginx/client_temp", 101) failed (1: Operation not permitted)
```
Процессу не хватает прав сделать chown.  
Chown нужен, т.к. по умолчанию nginx запускает своих workers под отдельным пользователем nginx.  
По этой же причине нужно добавить setgid и setuid.

добавим эту capability:
```
docker run --cap-drop=ALL --cap-add=chown --cap-add=setgid --cap-add=setuid --name nginx  --rm -p 80:80 nginx:1.21.3
```
Видим ошибку 
```
nginx: [emerg] bind() to 0.0.0.0:80 failed (13: Permission denied)
```
Для использования портов с номером меньше, чем 1024 нужна capability net_bind_service
```
docker run -d --cap-drop=all --cap-add=chown --cap-add=setgid --cap-add=setuid --cap-add=net_bind_service --name nginx-uncap  --rm -p 80:80 nginx:1.21.3
```
Видим, что nginx запустился и отлично работает.

### Пересоберем контейнер с NGINX так, чтобы процессы запускались не из-под пользователя root

Пользователь nginx уже есть в стандартном контейнере nginx. От него запускаются воркеры.  
Чтобы запустить основной процесс из под этого пользователя, нужно добавить права на некоторые системные файлы.   Для этого добавим  в Dockerfile следующие строки:
```
RUN     chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx/conf.d
RUN     touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid
```
Т.к. мы запускаем контейнер из-под пользователя, не имеющего прав root, то запустить nginx на стандартном порту 80 не получится.  
Поэтому в конфигурационном файле default.conf изменим порт, на котором запускается nginx на 8080 и добавим его в Dockerfile строку:
```
COPY ./default.conf /etc/nginx/conf.d/default.conf
```
Наконец, сменим пользователя. Для этого добавим в Dockerfile строку
```
USER nginx
```
Соберём получившийся контейнер
```
docker build . -t nginx-rootless
```
Запустим получившийся контейнер:
```
docker run -d --name nginx-rootless -p 8080:8080 nginx-rootless
```
### Теперь запустим rootless контейнер без лишних capabilities

Т.к. мы еще на этапе сборки дали пользователю nginx все необходимые права, то capabilities  chown, setgid и setuid нам не понадобятся.  
Так же мы запускаем процесс на порту с номером больше, чем 1024, поэтому нам не понадобится и net_bind_service.

Таким образом, мы можем запустить nginx вообще без capabilities:
```
docker run --cap-drop=all -d --name nginx-rootless-uncap -p 8081:8080 nginx-rootless
```
