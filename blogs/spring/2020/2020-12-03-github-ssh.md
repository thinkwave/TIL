---
layout: post
title:  "Github에 SSH 키 생성 후 등록"
date:   2020-12-03 12:36:12 +0900
categories: etc
tags: [github ssh]
---

SSH 키를 생성 후 github에 등록 하는 방법을 설명 합니다.

## SSH 키 생성
이메일은 변경하여 등록
```
ssh-keygen -t rsa -C "email@email.com"
```

## 생성된 SSH 키 확인
출력된 내용을 복사 한다.
```
cat ~/.ssh/id_rsa.pub
```

## github 등록
* Settings > SSH and GPG keys : New SSH Key


