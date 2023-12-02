## Устанавливаем kata containers как дополнительный runtime для docker
```
sudo yum -y install yum-utils
sudo -E yum-config-manager --add-repo http://download.opensuse.org/repositories/home:/katacontainers:/releases:/x86_64:/stable-1.11/CentOS_7/home:katacontainers:releases:x86_64:stable-1.11.repo

yum -y install kata-runtime kata-proxy kata-shim
```
### Добавляем kata как дополнительный runtime
Для этого в /etc/docker/daemon.json нужно добавить блок runtimes:
```
{
  "runtimes": {
    "kata": {
      "path": "/usr/bin/kata-runtime"
    }
  }
}
```
Получившийся фаил должен выглядеть примерно вот так:
```
{
  "runtimes": {
    "kata": {
      "path": "/usr/bin/kata-runtime"
    }
  }
}
{
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
### Перезапускаем Docker
```
sudo systemctl restart docker
```
### Запускаем nginx с использованием kata runtime
```
docker run -d --name nginx-kata --runtime kata nginx
```
### Запускаем nginx с использованием стандартного runtime
```
docker run -d --name nginx-runc nginx 
```
ЛИБО явно указать runc в качестве рантайма:
```
docker run -d --runtime runc --name nginx-runc nginx 
```
