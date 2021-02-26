---
layout: post
title:  "systemctl 명령어"
date:   2021-02-28 13:51:12 +0900
categories: Others
tags: [systemctl]
---

서버 부팅시 서비스들을 자동으로 시작하도록 설정 할 수 있다. 
자주 사용하는 명령어들을 참고용으로 정리 함.


## 서비스 목록
현재 작동중인 서비스 목록을 확인할 수 있다.
```
systemctl
```

> `systemctl list-unit-files` : 모든 서비스 확인 가능


## 부팅시 활성화 여부
`enable` 파라미터로 부팅시 서비스 재시작 설정

```
systemctl disable 서비스명
systemctl enable 서비스명
```

## 서비스 활영화 여부 확인

```
systemctl is-enabled 서비스명
systemctl is-active 서비스명
```


## 시작 중지 재시작
```
systemctl start 서비스명
systemctl stop 서비스명
systemctl restart 서비스명
systemctl reload 서비스명
systemctl kill 서비스명
```

## 서비스 설정반영
```
systemctl daemon-reload
```

## systemd 서비스 추가

```
$ nano /usr/lib/systemd/system/my-new.service

[Unit]
Description=서비스설명
After=svslog.target
After=network.target

[Service]
Type=forking
User=MyUser
Group=MyGroup
Restart=always
ExecStart=실행할 바이너리,스크립트
ExecStop=중지할 바이너리,스크립트

[Install]
WantedBy=multi-user.target
```

