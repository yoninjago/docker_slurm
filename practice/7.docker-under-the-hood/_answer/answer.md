## Запустим приложение Wordpress с базой данных используя containerd

Установим nerdctl 
```
wget https://github.com/containerd/nerdctl/releases/download/v0.11.1/nerdctl-full-0.11.1-linux-amd64.tar.gz
mkdir nerdctl
tar -xzf nerdctl-full-0.11.1-linux-amd64.tar.gz -C ./nerdctl
cp ./nerdctl/bin/nerdctl /usr/bin/
chmod +x /usr/bin/nerdctl
```
При попытке запустить контейнер получим ошибку похожую на вот такую:
```
FATA[0000] needs CNI plugin "bridge" to be installed in CNI_PATH ("/opt/cni/bin"), see https://github.com/containernetworking/plugins/releases: exec: "/opt/cni/bin/bridge": stat /opt/cni/bin/bridge: no such file or directory
```
Установим CNI плагины
```
wget https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-amd64-v1.0.0.tgz
mkdir ./CNI
tar xzf cni-plugins-linux-amd64-v1.0.0.tgz -C ./CNI
mkdir -p /opt/cni/bin/
mv ./CNI/* /opt/cni/bin/
```

Теперь запустим базу данных
```
nerdctl run -d --name db -v db1:/var/lib/mysql -e MYSQL_DATABASE=exampledb -e MYSQL_USER=exampleuser -e MYSQL_PASSWORD=examplepass -e MYSQL_RANDOM_ROOT_PASSWORD='1' mariadb:10.5
```
И wordpress
```
nerdctl run -d -p 80:80 --name wp -v wordpress1:/var/www/html -e WORDPRESS_DB_HOST=db -e WORDPRESS_DB_USER=exampleuser -e WORDPRESS_DB_PASSWORD=examplepass -e WORDPRESS_DB_NAME=exampledb wordpress:5.7
```
Теперь можно перейти на http://docker.s011541.edu.slurm.io:80 и увидеть приложение wordpress


## Nerdctl так же совместим с docker compose, поэтому можно использовать файл ./_answer/docker-compose.yaml
Просто выполните nerdctl compose up находясь в директории ./_answer