#!/bin/sh
docker volume rm -f codewhale-home
docker rmi local/codewhale:v0.8.47-hardened 
docker build -t local/codewhale:v0.8.47-hardened docker
