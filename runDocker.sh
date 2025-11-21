#!/bin/sh

docker build -t arena .
docker run --detach --rm -p 9010:8080 --name arena arena
