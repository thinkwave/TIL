---
layout: post
title:  "Spring Cloud 정리"
date: 2020-12-12 12:36:12 +0900
categories: Spring
tags: [spring boot, spring cloud]
---

# Spring Cloud

## Hystrix
* Netflix가 만든 Fault Tolerance Library
* 장애 전파 방지 & Resilience
  
### 주요 기능
1. Circuit Breaker
2. Fallback
3. Thread Isolation
4. Timeout

### 적용하기
1. Hystrix Command 상속
   ```
   public class TestCommand extends HystrixCommand<String> {
       @Override
       protected String run() {
           // Rest API로 서버 호출
       }
   }
   ```
2. Hystrix Annotation 사용
    ```
    @HystrixCommand
    public String callApi() {
        // Rest API로 서버 호출
    }
    ```

### 원리
1. 메소드를 Intercept하여 대신 실행
   - Thread Isolation
2. 메소드 실행 후 성공, 실패, 예외 발생 여부를 기록하여 통계를 작성
   - Circuit Breaker : 통계에 따라서 Circuit Open 여부를 결정
3. 예외가 발생한 경우는 사용자가 제공하여 메소드를 실행
   - Fallback
4. 메소드가 종료되지 않으면 예외를 발생시킴
   - Timeout

### Circuit Breaker를 자세히 알아 보자

1. 설정

```
hystrix.command.CommandKey.metrics.rollingState.timeInMilliseconds=10  # (1)
hystrix.command.CommandKey.circuitBreaker.requestVolumeThreshold=20    # (2)
hystrix.command.CommandKey.circuitBreaker.errorThresholdPercentage=50  # (3)
hystrix.command.CommandKey.circuitBreaker.sleepWindowInMilliseconds=5  # (4)
```
> 10초간 20개 이상의 호출이 발생 한 경우, 50% 이상의 에러가 발생하면 5초간 Circuit Open

2. Circuit Open(호출 차단)
(1)일정 시간 동안 (2) 일정 개수 이상의 호출이 발생한 경우, (3) 일정 비율 이상의 에러가 발생한 경우

3. Circuit Close(호출 허용)
(4)일정 시간 경과 후에 단 한개의 요청에 대해서 호출을 허용함(Half Open) 이 호출이 성공한 경우

4. Circuit Breaker의 단위
CommandKey 단위로 생성 되어 통계를 내고 작동한다.

```
@HystrixCommand(commandKey="ExtDep1")
public String anyMethodWithExternalDependency() {
    // 추천 서버 호출
}
```

### Hystrix - Fallback
Fallback으로 지정된 메소드는 다음의 경우에 원본 메소드 대신 실행한다.

1. Circuit Open
2. Any Exception(HystrixBadRequestException 제외)
  - 예외 발생시 무조건 Fallback은 실행
3. Semaphore / ThreadPool Rejection
4. Timeout

> HystrixBadRequestException을 발생시키면, 이 오류는 Fallback을 실행하지 않으며, Circuit Open을 위한 통계에서도 집계되지 않는다.
> Method Caller의 실수(ex 잘못된 파라미터의 전달)의 경우 HystrixBadRequestException을 Throw하게 작성 필요.

> 만약 Caller의 실수를 다은 Exception으로 던진다면, 
> - Circuit Breaker의 통계에 집계되어 Caller의 잘못으로 Circuit Open
> - Fallback이 실행되어, 개발과정에 오류를 인지하지 못할 수 있음.


```
@HystrixCommand(commandKey="ExtDep1",
    fallbackMethod="recommendFallback")
public String anyMethodIwthExternalDependency() {
    // 추천 서버 호출
}

public String recommendFallback() {
    return "<미리 준비된 상품 목록>";
}
```

### Hystrix - Timeout
Hystrix에서는 Circuit Breaker단위로(CommandKey 단위) Timeout을 설정할 수 있다.

```
hystrix.command.<commandKey>.execution.isolation.thread.timeoutInMilliseconds
```

> Default 1초로 매우 짧으므로 유의 필요

### Hystrix - Isolation
두가지 Isolation 방식을 Circuit Breaker별로 지정 가능
- Semaphore
- Thread(default)

1. Semaphore Isolation
   ![Semaphore Isolation](/spring/2020-12-12/hystrix-semaphore-isolation.png)
   - Circuit Breaker 1개당 1개의 Semaphore 생성
   - Semaphore 별로 최대 동시 요청 개수 지정
   - 최대 개수 초과시 Semaphore Rejection 발생 - FAllback 실행
   - Command를 호출한 Caller Thread에서 메소드 실행
   - Timeout이 제 시간에 발생하지 못함
2. Thread
   ![Thread Isolation](/spring/2020-12-12/hystrix-Thread-Isolation.png)
   - Circuit Breaker 별로 사용할 Thread Pool을 지정(ThreadPooKey)
   - Circut break : Thread Pool = N:1 관계 가능
   - 최대 개수 초과시 Thread Pool Rejection 발생 - Fallback 실행
   - Command를 호출한 Thread가 아닌 Thread Pool에서 메소드 실행

> 실제 메소드의 실행은 다른 Thread에서 실행되므로, Thread Local 사용 시 주의 필요

### Hystrix Isolation in Spring Cloud Zuul
1. Remainder
   - Hystrix Isolation은 Semaphore/Thread 두가지 모드가 있음.
   - Semaphore는 Circuit Break와 1:1
   - ThreadPool은 별도 부여된 ThreadPoolKey 단위로 생성된다
2. Spring cloud Zull에서 Hystrix Isolation은
   - Semaphore Isolation을 기본으로 한다.(Timeout이 없음)
   - Hystrix의 원래 Default는 Thread Isolation

![zuul](/spring/2020-12-12/hystrix-isolation-spring-cloud-zuul.png)

> Spring Cloud Zuul의 기본 설정으로는 Semaphore Isolation
> 특정 API 군의 장애(지연)등이 발생하여도 Zuul 자체의 장애로 이어지지 않음

3. Spring cloud Zull에서 Hystrix Isolation을 thread로 변경
- 서버군(Service ID) 별로 Thread Pool을 분리

![zuul-thread](/spring/2020-12-12/spring-cloud-zuul-thread.png)

```
zuul.threadPool.useSeparateThreadPools=true
zuul.threadPool.threadPoolKeyPrefix=zuulgw
```


## Ribbon
Netflix가 만든 Software Load Balancer를 내장한 RPC(REST) Library

![ribbon](/spring/2020-12-12/ribbon.png)

Client Load Balancer with HTTP Client


### Ribbon in Spring Cloud
Spring Cloud에서는 Ribbon 클러이언트를 사용자가 직접 사용하지 않음.

- Spring Cloud의 HTTP 통신이 필요한 요소에 내장되어 있음
  * Zuul API Gateway
  * RestTemplate(@LoadBalanced)
  * Spring Cloud feign - 선언적 Http Client

### Ribbon이 기존 Load Balancer와 다른 점
Ribbon은 대부분 동작은 Programmable 하며, Spring Cloud에서는 아래와 같은 BeanType으로 개발자가 적용 가능.

1. IRule - 주어진 서버 목록에서 어떤 서버를 선택할 것인가
2. IPing - 각 서버가 살아 있는 가를 검사
3. `ServerList<Server>` - 대상 서버 목록 제공
4. `ServerListFilter<Server>` - 대상 서버들 중 호출할 대상 Filter
5. ServerListUpdater
6. IClientConfig
7. ILoadBalancer



## Eureka
Netflix가 만든 Dynamic Service Discovery

![eureka](/spring/2020-12-12/eureka.png)

- 등록 : 서버가 자신의 서비스 이름(종류)과 IP주소, 포트를 등록
- 조회 : 서비스 이름(종류)을 갖고 서버 목록을 조회

### Eureka in Spring Cloud
Eureka가 enalble된 Spring Cloud Application은

1. Server 시작시 Eureka 서버에 자동으로 자신의 상태 등록(up)
2. 주기적 HeartBeat으로 Eureka Server에 자신이 살아 있음을 알림
3. Server 종료시 Eureka 서버에 자신의 상태 변경(down) 혹은 자신의 목록 삭제
4. Eureka 상에 등록된 이름은 `spring.application.name`

### Eureka + Ribbon in Spring Cloud
하나의 서버에 Eureka Client와 Ribbon Client가 함께 설정되면 Spring Cloud는 다음의 Ribbon Bean을 대체

1. `ServerList<Server>`
   - 기본 : ConfigurationBasedServerList
   - 변경 : DiscoveryEnalbedNIWSServerList
2. IPing
   - 기본 : DummyPing
   - 변경 : NIWSDiscoveryPing

> 서버의 목록을 설정으로 명시하는 대신 Eureka를 통해서 Look Up되도록 변경


## API Gateway
Hystrix + Ribbon + Eureka 를 잘 적용하면 MSA 환경에서 무리 없을거 같다?
MSA 환경에서 API Gateway의 필요성
- Single Endpoint 제공
  * API를 사용할 Client들은 API Gateway 주소만 인지
- API의 공통 로직 구현
  * Logging, Authentication, Authorization
- Traffic Control
  * API Quota, Throttling

### Spring Cloud Zuul
Spring Cloud Zuul은 API Routing은 Hystrix, Ribbon, Eureka를 통해서 구현

![zuul](/spring/2020-12-12/zuul.png)

- Spring Cloud와 가장 잘 Integration 되어 있는 API Gateway

> API 요청 들은 각각 HystrixCommand를 통해서 실행되며, 각 API의 Routing은 Ribbon & Eureka의 조합으로 수행


### Hystrix Circuit Breaker in Spring Cloud Zuul

Reminder
- Hystrix Circuit breaker는 CommandKey 이름 단위로 동작한다.

Spring Cloud Zuul에서 Hystrix CommandKey는
- 각 서버군 이름(Zuul 용어로 Service ID, Eureka에 등록된 서버군 이름)이 사용 됨
- 앞선 그림을 예를 들면 3개의 CommandKey가 사용


## Server to Server 호출 in MSA
- MSA 플랫폼 외부의 호출은 API Gateway를 단일 창구로 사용. 
- 내부의 API Server간의 호출은 직접 호출
- Ribbon + Eureka 조합으로 Peer to Peer 호출
- Spring Cloud에서는 다음의 Ribbon + Eureka 기반의 Http 호출 방법을 제공

1. @LoadBalanced Rest Template
   - @LoadBalanced를 붙이는 경우 RestTemplate이 Ribbon + Eureka 기능을 갖게 됨
   - RestTemplate이 Bean으로 선언된 것만 적용 가능
2. Spring cloud Feign


## Spring Cloud Feign
Declarative Http client
- Java Interface + Spring MVC Annotation 선언으로 Http 호출이 가능한 Spring Bean을 자동 생성
- OpenFeign 기반의 Spring Cloud 확장
- Hystrix + Ribbon + Eureka와 연동 되어 있음

1. Ribbon + Eureka 없이 사용하기
```
@FeignClient(name="product", url="http://localhost:8081")
public interface FeignProductRemoteService {
   @RequestMapping(path="/product/{productId}")
   String getProductInfo(@PathVariable("productId") String productId);
}
```

2. Ribbon + Eureka 연동
```
@FeignClient(name="product")
public interface FeignProductRemoteService {
   @RequestMapping(path="/product/{productId}")
   String getProductInfo(@PathVariable("productId") String productId);
}
```

### Spring Cloud Feign with Hystrix
Hystrix 연동하기
- Hystrix가 Classpath에 존재
- feign.hystrix.enabled=true

## 11st with Spring Cloud
- 모든 MSA Platform 내의 서버는 Eureka Client를 탑재
- API Server들간의 호출도 Spring Cloud Feign을 통해 Hystrix + Ribbon + Eureka 조합으로 호출

![11st](/spring/2020-12-12/11st-spring-cloud.png)


## Spring Cloud Config
- Git 기반의 Config 관리
- 플랫폼 내의 모든 Server들은 Config Client를 탑재
- 서버 시작시 Config 서버가 제공하는 Config들이 PropertSource로 등록됨
- Git REPOSITORY 내의 Config 파일들은 다양하게 구성 가능
  - 전체 서버 공통 Config
  - 서버군의 Config
  - 특정 서버용 Config

![config](/spring/2020-12-12/spring-cloud-config.png)

> Spring Cloud Config에서 가져오는 Config을 가장 우선순위로 가짐(System Config 보다)
> 우선 순위는 조정 가능.


## 모티터링
MSA 운영 환경을 위한 전용 모니터링 도구들
- Zipkin
- Turbine
- Spring Boot Admin

### Spring Cloud Sleuth
- 서버간의 Trace 정보의 전달은 사용 Protocol의 헤더를 통해서 전달 필요
   * ex) Http Header
- Spring Cloud에서 제공하는 Distributed Tracing 솔루션
- 대부분 내외부 호출 구간에서 Trace정보를 생성 및 전달
- Log에 남기거나 수집서버(Zipkin)에 전송하여검색/시각화
- Zuul, Servlet, ResTemplate, Hystrix, Feign, RxJav등을 지원
- Sleuth는 DB 호출 구간은 표현 안되므로 Spring AOP를 사용하여 Sleuth API로 Trace 정보를 직접 생성

![tracing](/spring/2020-12-12/tracing.png)

### Spring Cloud Sleuth with Zipkin
Sleuth로 생성한 trace를 시각화

### Hystrix 모니터링 with Turbine
- 실시간으로 모니터링 가능. 장애 발생시 과거 발생 시점은 볼 수 없음
![hystrix monitoring](/spring/2020-12-12/hystrix-monitoring.png)

- 과거 시점은 InfluxDB에 일주일치의 Hystrix Metrics 보관
  * Grafana를 통해 Dashbaord 구성


### Spring Boot Admin
- Eureka에 등록되어 있는 모든 서버의 정보를 표시/제어
- Spring Boot Acturator를 호출



# 참고
[11번가 Spring Cloud 기반 MSA로의 전환 - 지난 1년간의 이야기](https://www.youtube.com/watch?v=J-VP0WFEQsY)



