---
layout: post
title:  "MAC에 Jekyll로 블로그 만들기(설치)"
date:   2020-12-23 23:06:44 +0900
categories: mac
---

github과 jekyll을 이용하여 간단히 블로그를 만들어 보자.

## Jekyll 설치
```
sudo gem install jekyll
```

### 에러 : You have to install development tools first. 

```
'try_do': The compiler failed to generate an executable file. (RuntimeError)
You have to install development tools first.
```
위와 같은 에러 발생시 해결방법은 brew로 ruby를 설치한 경우 아래와 같이 환경 변수를 설정하면 된다.

```
export PATH="/usr/local/opt/ruby/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/ruby/lib"
export CPPFLAGS="-I/usr/local/opt/ruby/include"
export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"
```

## Jekyll로 블로그 만들기

```
jekyll new [github id].github.io
```

## 로컬 서버 실행
블로그를 생성한 디렉토리로 이동한 server를 구동하면 `http://localhost:4000`으로 접속하여 확인 할 수 있다.
```
cd [github id].github.io

jekyll serve
```


## 참고
* [Jekyll을 이용한 .github.io 블로그 만들기1](https://gmlwjd9405.github.io/2017/10/06/Jekyll-github.io-blog-1.html)