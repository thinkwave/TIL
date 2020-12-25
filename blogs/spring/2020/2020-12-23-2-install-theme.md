---
layout: post
title:  "MAC에 Jekyll로 블로그 만들기(테마 적용)"
date:   2020-12-23 23:06:44 +0900
categories: mac
tags: [jekyll, mac]
---

[Jekyll Theme](http://jekyllthemes.org/)에서 원하는 테마를 다운로드 받자.

## 테마 다운르도
깔끔해 보이는 [monos](http://jekyllthemes.org/themes/monos) 테마를 다운.
```
sudo gem install jekyll
```


## 테마 복사
압축을 풀고 `Gemfile`, `Gemfile.lock` 파일을 제외한 모든 폴더와 파일을 블로그로 만든 폴더로 복사하여 적용.

```
jekyll new [github id].github.io
```


## 참고
* [Jekyll을 이용한 .github.io 블로그 만들기2](https://gmlwjd9405.github.io/2017/10/06/Jekyll-github.io-blog-2.html)