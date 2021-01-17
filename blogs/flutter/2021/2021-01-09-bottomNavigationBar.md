---
layout: post
title:  "버튼을 하단 정중앙에 위치"
date:   2021-01-09 08:11:22 +0900
categories: Flutter
tags: [flutter, bottomNavigationBar]
---

버튼을 Scaffold 하단에 위치시키는 간단한 방법으로 [bottomNavigationBar](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html)를 이용합니다.

## bottomNavigationBar
`bottomNavigationBar`는 주로 Home 화면에서 하단 메뉴를 구성할때 사용하므로, 메뉴로 사용하지 않으면 아래 소스 처름 버턴을 위치시켜 사용할 수 있습니다.

![버튼](/flutter/2021-01-09/button.JPG)


## bottomNavigationBar 저장 버튼
```
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: const Text('추가'),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              '저장',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            onPressed: () => _submit(),
          ),
        ],
      ),
      body: _buildContents(context),
      backgroundColor: Colors.grey[200],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RaisedButton(
          onPressed: () => _submit(),
          child: const Text('저장', style: TextStyle(fontSize: 20)),
          color: Colors.green,
          textColor: Colors.white,
          elevation: 5,
        ),
      ),
    );
  }
```
