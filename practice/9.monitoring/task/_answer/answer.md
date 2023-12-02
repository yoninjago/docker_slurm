## Запускаем Cadvisor
```
VERSION=v0.44.0
sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=80:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:v0.44.0
```
### Запускаем тестовый контейнер с лимитом памяти в 100 мб и именем nginx-cadvisor
```
docker run -d -m 100m --name nginx-cadvisor nginx
```
### Получаем данные контейнера в интерфейсе Cadvisor
В браузере заходим по адресу:
```
http://docker.s<ваш номер логина>.edu.slurm.io/docker/nginx-cadvisor
```
### Получаем метрики контейнера в prometheus формате и сохраняем в нужный файл
```
curl localhost:80/metrics | grep nginx-cadvisor > /opt/nginx-metrics
```
