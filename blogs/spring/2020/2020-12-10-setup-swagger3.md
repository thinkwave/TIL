---
layout: post
title:  "Spring Boot + Swagger 3.0 설정 하기"
date: 2020-12-10 12:36:12 +0900
categories: Spring
tags: [spring boot, gradle, swagger]
---

Spring Boot에 Swagger 3.0 설정 하는 방법을 설명 합니다.

## 의존성 추가
'build.gradle' 파일에 추가 합니다.

```
implementation 'io.springfox:springfox-boot-starter:3.0.0'
compile group: 'io.springfox', name: 'springfox-swagger-ui', version: '3.0.0'
```


## Java Configuration
```
package com.exam.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

import java.util.HashSet;
import java.util.Set;


// @Profile("!prod")
@Configuration
@EnableSwagger2
public class SwaggerConfig {

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("Rest API")
                .description("Covid 19")
                .build();
    }

    private Set<String> getConsumeContentTypes() {
        Set<String> consumes = new HashSet<>();
        consumes.add("application/json;charset=UTF-8");
        consumes.add("application/x-www-form-urlencoded");
        return consumes;
    }

    private Set<String> getProduceContentTypes() {
        Set<String> produces = new HashSet<>();
        produces.add("application/json;charset=UTF-8");
        return produces;
    }

    @Bean
    public Docket apiDocket() {
        return new Docket(DocumentationType.SWAGGER_2)
                 .apiInfo(apiInfo())
                .select()
                .apis(RequestHandlerSelectors.any())
                .paths(PathSelectors.any())
                .build();
    }


}
```

## Swagger URL
브라우저로 접속하여 확인
```
http://localhost:8080/swagger-ui/index.html
```