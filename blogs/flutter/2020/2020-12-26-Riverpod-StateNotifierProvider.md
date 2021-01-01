---
layout: post
title:  "Riverpod - StateNotifier"
date:   2020-12-26 11:19:06 +0900
categories: Flutter
tags: [flutter, riverpod, StateNotifier]
---

[StateNotifierProvider](https://pub.dev/documentation/riverpod/latest/all/StateNotifierProvider-class.html)로 가장 큰 장점은 외부에서 State를 바꿀수 있음. 

사용 방법은 `StateNotifier`를 상속 받아 서비스 레벨을 구현하고, `StateNotifierProvider`로 provider를 만들어서 사용


## ToDo 예제
[Riverpod의 공식예제 todo](https://github.com/rrousselGit/river_pod/blob/master/examples/todos/README.md)를 참고해서 `StateNotifierProvider`의 활용 방법을 살펴 보자.

> 공식예제인 Todo는 `StateNotifierProvider` 를 사용하지 않음.

### Todo
모델인 Todo 클래스는 다음과 같다
```
class Todo {
  Todo({
    this.description,
    this.completed = false,
    String id,
  }) : id = id ?? _uuid.v4();

  final String id;
  final String description;
  final bool completed;

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }
}
```

### StateNotifier
`StateNotifier`를 확장하여 todo를 add, remove, toggle 기능을 추가
```
class TodosNotifier extends StateNotifier<List<Todo>> {
  TodosNotifier(): super([]);

  void add(Todo todo) {
    state = [...state, todo];
  }

  void remove(String todoId) {
    state = [
      for (final todo in state)
        if (todo.id != todoId) todo,
    ];
  }

  void toggle(String todoId) {
    state = [
      for (final todo in state)
        if (todo.id == todoId) todo.copyWith(completed: !todo.completed),
    ];
  }
}
```

### StateNotifierProvider
`StateNotifierProvider`로 provider를 생성
```
final todosProvider = StateNotifierProvider((ref) => TodosNotifier());
```

### UI
todosProvider의 state(=`List<Todo>`)를 ui에서 사용

```
Widget build(BuildContext context, ScopedReader watch) {
  // rebuild the widget when the todo list changes
  List<Todo> todos = watch(todosProvider.state);

  return ListView(
    children: [
      for (final todo in todos)
        CheckboxListTile(
           value: todo.completed,
           // When tapping on the todo, change its completed status
           onChanged: (value) => context.read(todosProvider).toggle(todo.id),
           title: Text(todo.description),
        ),
    ],
  );
}
```

> `context.read(todosProvider).toggle(todo.id)`로 ui 효율화