#!/usr/bin/env bash

docker run -p 6379:6379 -d redis
docker ps
