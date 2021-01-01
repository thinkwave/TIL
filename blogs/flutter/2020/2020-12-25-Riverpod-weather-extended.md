---
layout: post
title:  "Weather riverpod extended"
date:   2020-12-24 09:56:52 +0900
categories: Flutter
tags: [flutter, riverpod]
---

[weather_riverpod_extended](https://github.com/lightlitebug/weather_riverpod_extended) 는 `헤비프렌`님의 강의를 정리한 내용입니다.

> provider는 기본적으로 싱글톤


## 프로세스
1. ** home ** 에서 ** 검색 ** 버튼을 클릭하면 `SearchPage`로 이동
2. `SearchPage`에서 도시를 입력 후 버튼을 클릭하면 도시명을 ** home ** 화면으로 리턴
3. ** home ** 화면에서 도시명을 받고 `cityProvider.state`에 도시명을 저장
4. `currentWeatherProvider`로 외부 날짜 api 호출
5. `ProviderListener`로 weather의 변경이 감지되고 에러면 AlertDialog를 보여주고 아니면 `Consumer`로 날씨를 보여 줌



## cityProvider

입력 받은 도시의 상태 관리를 위한 StateProvider 생성

```
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cityProvider = StateProvider<String>((ref) {
  return '';
});
```

> 초기값은 ''

## weather api provider

1. `WeatherApiClient`는 도시이름으로 http로 날찌 정보를 가져옴
2. `WeatherRepository`는 `cityProvider`로 도시를 가져오고 `weatherApiClientProvider`로 날짜를 조회 하여 리턴

### weatherApiClientProvider
```
final weatherApiClientProvider = Provider<WeatherApiClient>((ref) {
  print('>>> In weatherApiClientProvider');
  return WeatherApiClient(httpClient: http.Client());
});
```

### WeatherRepository
`Reader`를 파라미터로 받아서, provider를 사용함
```
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather.dart';
import '../providers/providers.dart';

class WeatherRepository {
  final Reader read;

  WeatherRepository({this.read});

  Future<Weather> getWeather() async {
    final String city = read(cityProvider).state;

    try {
      final int locationId =
          await read(weatherApiClientProvider).getLocationId(city);

      return await read(weatherApiClientProvider).fetchWeather(locationId);
    } catch (e) {
      throw e.toString();
    }
  }
}
```

### weatherRepositoryProvider
```
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  print('>>> In weatherRepositoryProvider');
  return WeatherRepository(read: ref.read);
});
```

## weatherStateProvider
최종적으로 날씨 state를 리턴해주는 provider


### WeatherState
날씨를 가져오는 상태를 관리. 로딩중인지, 날씨가 있는지, 에러가 발생하지 않았는지..
UI에서 로딩중이면 로딩바, 날씨가 있으면 날씨를 보여주고, 에러가 있으면 다이어로그로 표시 해 줌
```
class WeatherState {
  final bool loading;
  final Weather weather;
  final String error;

  WeatherState({
    this.loading,
    this.weather,
    this.error,
  });

  WeatherState copyWith({
    bool loading,
    Weather weather,
    String error,
  }) {
    return WeatherState(
      loading: loading ?? this.loading,
      weather: weather ?? this.weather,
      error: error ?? this.error,
    );
  }
}
```

### currentWeatherProvider

`weatherRepositoryProvider`로 날씨를 가져오고 `CurrentWeather`의 상태를 새로 만듬

```
final currentWeatherProvider = StateNotifierProvider<CurrentWeather>((ref) {
  print('>>> In currentWeatherProvicer');
  return CurrentWeather(ref.read);
});

class CurrentWeather extends StateNotifier<WeatherState> {
  final Reader read;

  static WeatherState initialWeatherState = WeatherState();

  CurrentWeather(this.read) : super(initialWeatherState);

  Future<void> fetchWeather() async {
    state = state.copyWith(loading: true, error: '');
    final String city = read(cityProvider).state;

    try {
      final Weather weather =
          await read(weatherRepositoryProvider).getWeather();
      state = state.copyWith(
        loading: false,
        weather: weather,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Can not fetch the weather of $city',
      );
    }
  }
}
```

### weatherStateProvider

```
final weatherStateProvider = Provider<WeatherState>((ref) {
  print('>>> In weatherStateProvider');
  final WeatherState weather = ref.watch(currentWeatherProvider.state);

  return weather;
});
```



## 참고

[Riverpod [1] - New wave of state management in flutter](https://www.youtube.com/watch?v=AjcpfvoyV-Y&list=PLGJ958IePUyBVpGmJA1hSwB8_j1gU0kWq)

[Riverpod [2] - Real-life example - Simplified Weather App](https://www.youtube.com/watch?v=vGG-fjURbRI&list=PLGJ958IePUyBVpGmJA1hSwB8_j1gU0kWq&index=2)

[Riverpod [3-1] - initState, Authentication, Flavor, Pull To Refresh](https://www.youtube.com/watch?v=glFBu3_ax_Q&list=PLGJ958IePUyBVpGmJA1hSwB8_j1gU0kWq&index=3)

[Riverpod [3-2] - initState, Authentication, Flavor, Pull To Refresh](https://www.youtube.com/watch?v=MMdr80t-2U4&list=PLGJ958IePUyBVpGmJA1hSwB8_j1gU0kWq&index=4)

[Riverpod [3-3] - initState, Authentication, Flavor, Pull To Refresh](https://www.youtube.com/watch?v=n3pEMZAiGD8&list=PLGJ958IePUyBVpGmJA1hSwB8_j1gU0kWq&index=5)