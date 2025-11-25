# Zenbu Docker 

### To build the docker image run:

`docker build -t debian-zenbu:3.1 .`

### To execute the docker container run:

`docker run -it -p 8082:80 debian-zenbu:3.1`  for interactive

`docker run -d -it -p 8082:80 debian-zenbu:3.1`   for detached in background

access your docker zenbu at http://localhost:8082/zenbu 


## NFS mounting external zenbu data directories

### Setup external NFS server
There are better guides on the internet for setting up and configuring an NFS server, but here is a quick guide for a linux machine.

`1) setup your nfs export server zenbu directory structure (for example /data/zenbu)`

```
   mkdir /data/zenbu/dbs
   mkdir /data/zenbu/cache
   mkdir /data/zenbu/users
   mkdir /data/zenbu/html
```

`2) configure /etc/exports to include /data/zenbu (examples)`
```
   /data/zenbu   192.168.1.1/255.255.255.0(rw,sync,no_root_squash,subtree_check)
   /data/zenbu   *(rw,sync,no_root_squash,subtree_check)
```

`3) start NFS services`
```
   > exportfs -a
   > /etc/init.d/nfs-kernel-server reload
```

### Setup docker to NFS mount
```
   docker volume create --driver local \
      --opt type=nfs \
      --opt o=addr=nfs.host.ip.addr,rw,nfsver=4 \
      --opt device=:/data/zenbu \
      zenbu

   docker volume create --driver local --opt type=nfs --opt o=addr=10.64.132.247,rw --opt device=:/data2/zenbu_vacdb  zenbu_vacdb

   docker run -it -v zenbu_vacdb:/data/zenbu -p 8082:80 debian-zenbu:3.1

```
