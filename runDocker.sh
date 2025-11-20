#!/bin/sh

docker build -t arena .
docker run --detach -p 9010:8080 --name arena arena
