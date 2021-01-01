---
layout: post
title:  "Riverpod - StateProvider"
date:   2020-12-26 11:19:02 +0900
categories: Flutter
tags: [flutter, riverpod, StateProvider]
---

[StateProvider](https://pub.dev/documentation/riverpod/latest/all/StateProvider-class.html)로 외부에서 State를 바꿀수 있음. 

간편하게 사용할 수 있어서 필터나 선택값을 관리할때 편하며 다른 provider와 조합하여 사용하기도 유용함


## Counter 예제
[counter](https://github.com/rrousselGit/river_pod/blob/master/examples/counter/lib/main.dart) 예제 참고

### Provider 생성
기본값인 0인 provider 생성
```
final counterProvider = StateProvider((ref) => 0);
```

### 사용

* Consumer : 위젯에서 provider를 읽어 올 수 있음
* watch로 provider 의 state를 가져옴
* context.read(counterProvider).state++ 로 context.read로 state를 가져오고 상태값을 변결함

> `context.read(counterProvider)`는 변경을 감지하지 않음.


```
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter example')),
      body: Center(
        // Consumer is a widget that allows you reading providers.
        // You could also use the hook "useProvider" if you uses flutter_hooks
        child: Consumer(builder: (context, watch, _) {
          final count = watch(counterProvider).state;
          return Text('$count');
        }),
      ),
      floatingActionButton: FloatingActionButton(
        // The read method is an utility to read a provider without listening to it
        onPressed: () => context.read(counterProvider).state++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```