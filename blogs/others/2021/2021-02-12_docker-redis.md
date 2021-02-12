---
layout: post
title:  "Docker로 Redis 구동하기"
date:   2021-01-06 19:52:14 +0900
categories: Others
tags: [redis, docker]
---

Redis 연동 테스트 목적으로 Docker로 구동해 보자

## 설치
1. Redis 이미지를 가져 옵니다.
```
docker pull redis:5.0
```

2. 이미지 확인
```
docker images

REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
redis         5.0       7359b9f8c54e   35 hours ago    98.4MB
hello-world   latest    bf756fb1ae65   13 months ago   13.3kB
```

3. network 생성
redis-cli로 redis 접속 하기 위하여 network bridge 생성

```
docker network create redis-net
```

> `docker inspect redis-net` 생성한 네트워크 상세 정보 확인
> `docker network ls` 네트워크 리스트 확인
> `docker network rm redis-net` 네트워크 삭제


## 실행
1. redis-net 브리지로 redis 실행
redis + redis cli 를 redis-net로 묶어서 실행
```
docker run --name redis-cache -p 6379:6379 --network redis-net -d redis:5.0 redis-server --appendonly yes
```
* `--name` : 컨테이너 이름을 지정합니다.
* `-p` : docker 컨테이너 redis 서버와 로컬 호스트를 6379 포트로 연결 합니다.
* `-d` : 백그라운드로 실행
* `--appendonly yes` 

2. redis-cli로 redis 서버 접속

```
docker run -it --network redis-net --rm redis:5.0 redis-cli -h redis-cache

redis-cache:6379> 
```

* `--rm` 컨테이너 종료시 자동으로 컨테이너 삭제


## redis 간략하게 실행
docker network bridge 없이 기본 network 사용하여 구동 하는 방법
1. redis 컨테이너 구동
```
docker run --name redis-cache -p 6379:6379 -d redis:5.0
```

2. redis-cli 실행

기본 네트워크에서 redis 컨테이너 연결
```
docker run -it --link redis-cache:redis --rm redis:5.0 redis-cli -h redis -p 6379

redis:6379>
```

3.다른 컨테이너에서 Redis 컨테이너 연결

```
docker run --name boot-demo-app --link redis-cache:redis -d boot-demo:latest
```



