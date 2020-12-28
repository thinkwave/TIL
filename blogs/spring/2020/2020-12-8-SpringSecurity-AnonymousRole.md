---
layout: post
title:  "Spring Security에서 Anonymous Role 체크"
date: 2020-12-08 09:54:12 +0900
categories: Spring
tags: [spring boot, spring security]
---

## 이슈
* `Controller`에서 Anonymous Role 확인이 안됨.
* `@AuthenticationPrincipal UserDetails principal` 은 로그인된 사용자 정보만 들어옴


## 해결
*  SecurityContextHolder.getContext().getAuthentication(); 로 체크
```
@ApiIgnore
@RequiredArgsConstructor
@Controller
public class HomeController {

    private final PostService postService;

    @ApiOperation(value =")
    @GetMapping("/")
    public String home(Model model, @AuthenticationPrincipal UserDetails principal) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
```