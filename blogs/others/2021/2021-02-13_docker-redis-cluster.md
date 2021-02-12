---
layout: post
title:  "Docker로 Redis Cluster 구성하기"
date:   2021-02-13 14:12:50 +0900
categories: Others
tags: [redis, docker]
---

[docker-compose](https://github.com/Grokzen/docker-redis-cluster)로 Redis Cluster를 쉽게 구동할 수 있습니다. 간단하게 테스트 해 보실분은 docker-redis-cluster로 하시길 추천합니다.


## Cluster 구성
Node 3대와 Primary Cluster, Secondary Cluster, Third Cluster 로 구성합니다.

|Cluster    | Node #01 | Node #02 | Node #03 |
|-----------|:-------------------:|:-------------------:|:-------------------:|
|Cluster #1 | **redis-c1-master(6379)** | redis-c1-slave1(6379) | redis-c1-slave2(6379) |
|Cluster #2 | redis-c2-slave1(6380) | **redis-c2-master(6380)** | redis-c2-slave2(6380) |
|Cluster #3 | redis-c3-slave1(6381) | redis-c3-slave2(6381) | **redis-c3-master(6381)** |




## Docker로 Redis 설치

### Network 구성
```
docker network create redis-cluster-net
```

### Node #1
```
docker run -d --name redis-c1-master --network redis-cluster-net -v /tmp/redis/c1-master:/data redis:5.0 redis-server --port 6379:6379 --cluster-enabled yes --cluster-config-file node.conf --cluster-node-timeout 5000 --bind 0.0.0.0
docker run -d --name redis-c2-slave1 --network redis-cluster-net -v /tmp/redis/c2-slave1:/data redis:5.0 redis-server --port 6380:6380 --cluster-enabled yes --cluster-config-file node.conf --cluster-node-timeout 5000 --bind 0.0.0.0 --appendonly yes
docker run -d --name redis-c3-slave1 --network redis-cluster-net -v /tmp/redis/c3-slave1:/data redis:5.0 redis-server --port 6381:6381 --cluster-enabled yes --cluster-config-file node.conf --cluster-node-timeout 5000 --bind 0.0.0.0 --appendonly yes
```

### Node #2
```
docker run -d --name redis-c1-slave1 --network redis-cluster-net -v /tmp/redis/c1-slave1:/data redis:5.0 redis-server --port 6379:6379 --cluster-enabled yes --cluster-config-file node.conf --cluster-node-timeout 5000 --bind 0.0.0.0
docker run -d --name redis-c2-master --network redis-cluster-net -v /tmp/redis/c2-master:/data redis:5.0 redis-server --port 6380:6380 --cluster-enabled yes --cluster-config-file node.conf --cluster-node-timeout 5000 --bind 0.0.0.0 --appendonly yes
docker run -d --name redis-c3-slave2 --network redis-cluster-net -v /tmp/redis/c3-slave2:/data redis:5.0 redis-server --port 6381:6381 --cluster-enabled yes --cluster-config-file node.conf --cluster-node-timeout 5000 --bind 0.0.0.0 --appendonly yes
```

### Node #3
```
docker run -d --name redis-c1-slave2 --network redis-cluster-net -v /tmp/redis/c1-slave2:/data redis:5.0 redis-server --port 6379:6379 --cluster-enabled yes --cluster-config-file node.conf --cluster-node-timeout 5000 --bind 0.0.0.0
docker run -d --name redis-c2-slave2 --network redis-cluster-net -v /tmp/redis/c2-slave2:/data redis:5.0 redis-server --port 6380:6380 --cluster-enabled yes --cluster-config-file node.conf --cluster-node-timeout 5000 --bind 0.0.0.0 --appendonly yes
docker run -d --name redis-c3-master --network redis-cluster-net -v /tmp/redis/c3-master:/data redis:5.0 redis-server --port 6381:6381 --cluster-enabled yes --cluster-config-file node.conf --cluster-node-timeout 5000 --bind 0.0.0.0 --appendonly yes
```

> `--appendonly yes`는 Master는 메모리 사용으로 생략, Slave는 Disk 사용


## Redis Cli로 Cluster 구성

### 컨테이너 IP 확인
```
docker network inspect redis-cluster-net
```
172.18.0.2:6379 172.18.0.6:6380 172.18.0.10:6381 
172.18.0.5:6379 172.18.0.8:6379 172.18.0.3:6380 172.18.0.9:6380 172.18.0.4:6381 172.18.0.7:6381


### Redis cli로 Cluster 구성하기

`yes`만 하면 자동으로 Cluster를 구성해 줍니다.

* `--cluster create` Auto Shading 지원

```
docker run -i --rm --network host redis:5.0 redis-cli --cluster create 172.18.0.2:6379 172.18.0.6:6380 172.18.0.10:6381 172.18.0.5:6379 172.18.0.8:6379 172.18.0.3:6380 172.18.0.9:6380 172.18.0.4:6381 172.18.0.7:6381 --cluster-replicas 2

>>> Performing hash slots allocation on 9 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 172.18.0.8:6379 to 172.18.0.2:6379
Adding replica 172.18.0.3:6380 to 172.18.0.2:6379
Adding replica 172.18.0.9:6380 to 172.18.0.6:6380
Adding replica 172.18.0.4:6381 to 172.18.0.6:6380
Adding replica 172.18.0.7:6381 to 172.18.0.10:6381
Adding replica 172.18.0.5:6379 to 172.18.0.10:6381
M: 52f7cfb9188d47844dcf101dbee2de6b9e298dad 172.18.0.2:6379
   slots:[0-5460] (5461 slots) master
M: fa705026b31e5998ee598bcb80cb1595098739ab 172.18.0.6:6380
   slots:[5461-10922] (5462 slots) master
M: b9f65f158db43e5fba99ac5319d697e0be8a240d 172.18.0.10:6381
   slots:[10923-16383] (5461 slots) master
S: 5f57caaea20f90b319a76580f27e6c67efbea864 172.18.0.5:6379
   replicates b9f65f158db43e5fba99ac5319d697e0be8a240d
S: 16610a8c4b57f22f577b66b77c13bc323b11670a 172.18.0.8:6379
   replicates 52f7cfb9188d47844dcf101dbee2de6b9e298dad
S: 8a0a1fd910dbd148ba133cee4140c75f3aca0b14 172.18.0.3:6380
   replicates 52f7cfb9188d47844dcf101dbee2de6b9e298dad
S: d786e629e9b6f94e2cfa2b11c796670c6f4e5d36 172.18.0.9:6380
   replicates fa705026b31e5998ee598bcb80cb1595098739ab
S: 63e7257b2919d9a4c0c30a33e5b25c18dc05d840 172.18.0.4:6381
   replicates fa705026b31e5998ee598bcb80cb1595098739ab
S: 3e9b47448cd3d5f8d3071a59cae5d97dc084bde9 172.18.0.7:6381
   replicates b9f65f158db43e5fba99ac5319d697e0be8a240d
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
.
>>> Performing Cluster Check (using node 172.18.0.2:6379)
M: 52f7cfb9188d47844dcf101dbee2de6b9e298dad 172.18.0.2:6379
   slots:[0-5460] (5461 slots) master
   2 additional replica(s)
S: 63e7257b2919d9a4c0c30a33e5b25c18dc05d840 172.18.0.4:6381
   slots: (0 slots) slave
   replicates fa705026b31e5998ee598bcb80cb1595098739ab
S: 16610a8c4b57f22f577b66b77c13bc323b11670a 172.18.0.8:6379
   slots: (0 slots) slave
   replicates 52f7cfb9188d47844dcf101dbee2de6b9e298dad
S: 3e9b47448cd3d5f8d3071a59cae5d97dc084bde9 172.18.0.7:6381
   slots: (0 slots) slave
   replicates b9f65f158db43e5fba99ac5319d697e0be8a240d
M: b9f65f158db43e5fba99ac5319d697e0be8a240d 172.18.0.10:6381
   slots:[10923-16383] (5461 slots) master
   2 additional replica(s)
S: d786e629e9b6f94e2cfa2b11c796670c6f4e5d36 172.18.0.9:6380
   slots: (0 slots) slave
   replicates fa705026b31e5998ee598bcb80cb1595098739ab
S: 5f57caaea20f90b319a76580f27e6c67efbea864 172.18.0.5:6379
   slots: (0 slots) slave
   replicates b9f65f158db43e5fba99ac5319d697e0be8a240d
S: 8a0a1fd910dbd148ba133cee4140c75f3aca0b14 172.18.0.3:6380
   slots: (0 slots) slave
   replicates 52f7cfb9188d47844dcf101dbee2de6b9e298dad
M: fa705026b31e5998ee598bcb80cb1595098739ab 172.18.0.6:6380
   slots:[5461-10922] (5462 slots) master
   2 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```


### Redis Cli 접속

```
docker run -it --rm --network redis-cluster-net redis:5.0 redis-cli -c -h redis-c1-master -p 6379
```

### Cluster 정보 확인

```
docker run -i --rm --network redis-cluster-net redis:5.0 redis-cli --cluster info 172.18.0.2:6379
```




## 참고

* (docker 기반 redis 구축하기)[https://jaehun2841.github.io/2018/12/01/2018-12-01-docker-6/]
* (Redis Cluster 구축 (redis cluster + predixy))[https://freesunny.tistory.com/56]
* (Redis #.1 소개 및 설치)[https://rastalion.me/redis-1-%ec%86%8c%ea%b0%9c-%eb%b0%8f-%ec%84%a4%ec%b9%98/]
