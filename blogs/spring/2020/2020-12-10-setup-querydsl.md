---
layout: post
title:  "Gradle에서 Querydsl 설정 하기"
date: 2020-12-10 12:36:12 +0900
categories: Spring
tags: [spring boot, gradle, querydsl]
---


Gradle에서 Querydsl 설정 하는 방법을 설명 합니다.

## Querydsl 설정 추가
'build.gradle' 파일에 추가 합니다.

1. 플러그인 추가
   ```
   id "com.ewerk.gradle.plugins.querydsl" version "1.0.10"
   ```
2. 의존성 추가
   ```
   implementation 'com.querydsl:querydsl-jpa'
   ```
3. 컴파일 설정 추가
   ```
   def querydslDir = "$buildDir/generated/querydsl" querydsl { jpa = true querydslSourcesDir = querydslDir } sourceSets { main.java.srcDir querydslDir } configurations { querydsl.extendsFrom compileClasspath } compileQuerydsl { options.annotationProcessorPath = configurations.querydsl }
   ```

### 전체 설정
```
plugins {
	id 'org.springframework.boot' version '2.3.7.BUILD-SNAPSHOT'
	id 'io.spring.dependency-management' version '1.0.10.RELEASE'

    // 1. 플러그인 추가
	id 'com.ewerk.gradle.plugins.querydsl' version '1.0.10'

	id 'java'
}

group = 'com.exam'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '11'

configurations {
	compileOnly {
		extendsFrom annotationProcessor
	}
}

repositories {
	mavenCentral()
	maven { url 'https://repo.spring.io/milestone' }
	maven { url 'https://repo.spring.io/snapshot' }
}

ext {
	set('springCloudVersion', "Hoxton.BUILD-SNAPSHOT")
}

dependencies {
	implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
	implementation 'org.springframework.boot:spring-boot-starter-web'
	implementation 'org.springframework.cloud:spring-cloud-starter-openfeign'

	// 2. 의존성 추가
	implementation 'com.querydsl:querydsl-jpa'

	// Swagger
	implementation 'io.springfox:springfox-boot-starter:3.0.0'
	compile group: 'io.springfox', name: 'springfox-swagger-ui', version: '3.0.0'

	compile group: 'org.mariadb.jdbc', name: 'mariadb-java-client', version: '2.7.1'
	compile group: 'org.json', name: 'json', version: '20201115'

	compile('org.springframework.boot:spring-boot-devtools')

	compileOnly 'org.projectlombok:lombok'

	runtimeOnly 'com.h2database:h2'

	annotationProcessor 'org.projectlombok:lombok'

	testImplementation('org.springframework.boot:spring-boot-starter-test') {
		exclude group: 'org.junit.vintage', module: 'junit-vintage-engine'
	}
	testImplementation 'de.flapdoodle.embed:de.flapdoodle.embed.mongo'
	testImplementation("org.springframework.cloud:spring-cloud-starter-contract-stub-runner")

}

dependencyManagement {
	imports {
		mavenBom "org.springframework.cloud:spring-cloud-dependencies:${springCloudVersion}"
	}
}

test {
	useJUnitPlatform()
}

// 3. 컴파일 설정 추가
def querydslDir = "$buildDir/generated/querydsl"
querydsl {
	jpa = true
	querydslSourcesDir = querydslDir
}
sourceSets {
	main.java.srcDir querydslDir
}
configurations {
	querydsl.extendsFrom compileClasspath
}
compileQuerydsl {
	options.annotationProcessorPath = configurations.querydsl
}
```

## Java Configuration

```
package com.exam.config;

import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.sql.DataSource;

@RequiredArgsConstructor
@Configuration
public class QuerydslConfig {

    private final DataSource dataSource;

    @PersistenceContext
    private EntityManager entityManager;

    @Bean
    public JPAQueryFactory queryFactory() {
        return new JPAQueryFactory(entityManager);
    }


    @Bean
    public NamedParameterJdbcTemplate namedParameterJdbcTemplate() {
        return new NamedParameterJdbcTemplate(dataSource);
    }

}
```
