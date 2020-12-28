---
layout: post
title:  "Json Text 날짜를 LocalDateTime으로 변환"
date: 2020-12-07 08:21:12 +0900
categories: Spring
tags: [spring boot, gradle, querydsl]
---

## 이슈
외부 통신시 json 문자열로 데이터를 수신한 경우, String 날짜를 `LocalDateTime`으로 변환


## 해결

### 변환
* DTO에 `@JsonFormat` 애노테이션을 추가하고 날짜 형식을 지정
* ex) createDt=2020-12-01T14:11:00.708
```
@JsonProperty("createDt")
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss.SSS") 
private LocalDateTime createDt;
```