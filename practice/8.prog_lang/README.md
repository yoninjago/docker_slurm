# Самостоятельная работа

I. Склонируйте репозиторий с практикой на машину с Docker и перейдите в директорию `practice/8.prog_lang`

```bash
git clone git@gitlab.slurm.io:edu/docker_course.git
cd docker_course/practice/8.prog_lang
```

II. Самостоятельно напишите `Dockerfile` и `docker-compose.yml` файлы для сборки и запуска приложения в директории. Можете смело использовать все известные вам способы оптимизации, в том числе конкретно для Python. А также все знания, полученные на курсе ранее.

Условия задачи:

1. Должен использоваться начальный образ c Python версии 3.8
2. В `Dockerfile` должны устанавливаться зависимости из файла `requirements.txt`

```bash
pip install -r requirements.txt
```

3. Само приложение должно запускаться командой `python setup.py && flask run --host=0.0.0.0 --port 8000`
В репозитории есть скрипт `docker-entrypoint.sh`, можете в качестве стартовой команды запускать его.
4. Приложение должно быть доступно на `8000` порту
5. Приложение должно работать от имени пользователя `app`
6. Рабочей директорией в контейнере должен быть путь `/app`
7. В `Dockerfile` также необходимо передавать дополнительную переменную для работы приложения - `FLASK_APP=src/app.py`
8. В `docker-compose.yml` файле должно быть два сервиса - `db` (postgres) и `app`.
9. Приложение должно собираться автоматически при выполнении команды `docker-compose up`
10. Приложение должно запускаться из локальных файлов проекта (то есть нужно монтировать директорию с кодом в рабочую директорию контейнера с приложением)
11. Для работы приложения ему нужно передать следующие переменные:

```bash
DB_NAME: slurm
DB_USER: postgres
DB_PASSWORD: pa55w0rd
DB_HOST: db
FLASK_ENV: development
```

Не забудьте согласовать переменные окружения приложения и вашей базы данных.

III. Приложение должно уметь сохранять в БД пользователей с `lastName` и `firstName` и выводить данные пользователя по запросу с `id`.

Примеры запросов:

```bash
curl localhost:8000/api/v1/users -X POST -d '{"firstName":"Docker","lastName":"Slurm"}' --header "Content-Type: application/json"

curl localhost:8000/api/v1/users/1
```

## Домашняя работа (по желанию)

Постарайтесь добиться, чтобы размер вашего контейнера с готовым к работе приложением не превышал 150 мб.