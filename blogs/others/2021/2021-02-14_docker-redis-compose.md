---
layout: post
title:  "docker-compose로 Redis Cluster 구성하기"
date:   2021-02-14 11:41:06 +0900
categories: Others
tags: [redis, docker]
---

(docker-redis-cluster)[https://github.com/Grokzen/docker-redis-cluster]로 mac에서 docker-compose로 간편하게 redis cluster 구동하기.


## brew로 redis-cli 설치

```
brew install redis
```


## docker redis cluster

MAC에서 Redis Cluster 실행

### 1. 환경 변수
```
export REDIS_CLUSTER_IP=0.0.0.0
```

### 2. Redis Cluster 실행
```shell
docker run -e "IP=0.0.0.0" -p 7000-7005:7000-7005 grokzen/redis-cluster:latest
```

### 3. redis-cli 실행
docker로 구동중인 redis cluster 접속

```
redis-cli -c -h 127.0.0.1 -p 7000
```

* `-c` 클러스터 모드
* `-h` 호스트
* `-p` 포트

## redis-cli 
자주 사용하는 명령어

### keys *
운영에서는 절대 사용하지 말것
```
keys *
```

### keyslot
key값이 어느 slot으로 저장될지 확인
```
cluster keyslot key-value
```