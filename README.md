# Zenbu Docker 

To build the docker image run:

`docker build -t debian-zenbu:3.1 .`

To execute the docker container run:

`docker run -it -p 8082:80 debian-zenbu:3.1`  for interactive

`docker run -d -it -p 8082:80 debian-zenbu:3.1`   for detached in background
