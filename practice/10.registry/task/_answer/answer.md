## Ответ на самостоятельную работу для темы 11

### Создадим новую группу в Harbor

На первой же странице после логина (Projects) - нужно создать новый проект (кнопка New project) c вашим логином студента, например s000001

### Пробуем авторизоваться в Harbor

```
docker login http://harbor.s000001.edu.slurm.io/
```

Видим, что подключение по http невозможно.

Чтобы это исправить, нужно внести изменения в конфигурацию docker daemon:

`vim /etc/docker/daemon.json`

```json
{
"insecure-registries": ["harbor.s000001.edu.slurm.io"],
...
}
```

И перезапустить службу: `systemctl restart docker`

### Перезапуск Harbor

Вполне возможно, что после внезапного перезапуска демона наш registry не запустится нормально.

Нужно его перезапустить:

```bash
cd ~/harbor
docker-compose down
docker-compose up -d
```

Теперь пробуем `docker login` ещё разок, всё должно получиться.

### Проставляем тэги и пушим

Присваиваем тэги при сборке образа:

`cd ~/docker/practice/11.registry/`
`docker build -t harbor.s000001.edu.slurm.io/s000001/myapp:v1.2.3 -t harbor.s000001.edu.slurm.io/s000001/myapp:latest .`

И теперь загружаем в registry образ с двумя нужными тэгами:
`docker push harbor.s000001.edu.slurm.io/s000001/myapp:v1.2.3`
`docker push harbor.s000001.edu.slurm.io/s000001/myapp:latest`

### Готово!
