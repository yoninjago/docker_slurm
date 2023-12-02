## Запустим приложение Wordpress с базой данных в containerd, не используя docker


Важно! Если вы не скачали себе репозиторий - самое время это сделать:

```
git clone git@gitlab.slurm.io:edu/docker_course.git
```

Переходим в каталог `docker_course/practice/7.docker-under-the-hood`

### DISCLAIMER: Сначала необходимо остановить демон docker!
Используйте команды
```
systemctl mask docker
systemctl stop docker
```

### Нужно запустить контейнер с wordpress:5.7 используя в качестве базы данных контейнер mariadb:10.5

Обоим контейнерам нужен volume для хранения данных  
Для wordpress нужно монтировать в директорию /var/www/html  
Для mariadb в /var/lib/mysql  

Это не задание про правильный запуск wordpress с базой данных, поэтому рекомендую использовать следующие параметры запуска контейнеров:
```
wordpress:
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: exampleuser
      WORDPRESS_DB_PASSWORD: examplepass
      WORDPRESS_DB_NAME: exampledb
```
```
mariadb:
    environment:
      MYSQL_DATABASE: exampledb
      MYSQL_USER: exampleuser
      MYSQL_PASSWORD: examplepass
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
```
#### DISCLAIMER: Пожалуйста, если зайдете через браузер в wordpress не продолжайте его настройку из мастера. Скрипт проверки ищет именно эту страницу и может быть ложноотрицательным, если вы начали настройку wordpress.

Подсказка 1:  
Вместе с containerd идёт утилита ctr, но её функционал крайне ограничен.  
Отличная альтернатива это утилита nerdctl  

Подсказка 2:   
Так как мы не пользуемся docker, то теряем встроенную в docker магию управления iptables  
Поэтому нужно будет установить Container Network Interface (CNI) плагин.  

#### Если совсем зашли в тупик

Ответ (один из его возможных вариантов) можно найти в этом же каталоге с кодом для задания - в папке `_answer`.
