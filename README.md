# Rxswift-Study

# RxSwift
> a library for composing asynchronous and event-based code by using __observable sequences__ and functional style __operators__, allowing for parameterized execution via __schedulers__.

# Observable

[Observable1](https://github.com/minseongkim97/Rxswift-Study/blob/main/RxSwiftPlayground.playground/Contents.swift)

[Observable2](https://github.com/minseongkim97/Rxswift-Study/blob/main/Observables.playground/Contents.swift)

[Traits](https://github.com/minseongkim97/Rxswift-Study/blob/main/Observables_2.playground/Contents.swift)

Observable(관찰가능한) 객체를 통해 이벤트 흐름을 표현한다. → Every Observable instance is just a sequence(Observable = Observable Sequence = Sequence)

- Rx 코드의 기반
- T 형태의 데이터 snapshot을 ‘전달'할 수 있는 일련의 이벤트를 **비동기적으로** 생성하는 기능 → 다른 클래스에서 만든 값을 시간에 따라서 읽을 수 있다
- Observable들은 일정 기간 동안 계속해서 이벤트를 방출(emit)
- 하나 이상의 observers가 실시간으로 어떤 이벤트에 반응 → 앱 UI를 업데이트하거나 생성하는지를 처리하고 활용할 수 있다.
- 세 가지 유형의 이벤트만 방출(next(Element), error(Swift.Error), completed)
    - Observable은 어떤 구성요소를 가지는 next 이벤트를 계속해서 방출할 수 있다.
    - Observable은 error 이벤트를 방출하여 완전 종료될 수 있다.
    - Observable은 complete 이벤트를 방출하여 완전 종료될 수 있다.

Finite Observable (네트워크: 파일 다운로드)

Infinite Observable(보통 UI 이벤트)

<br>

## Traits

Traits -> Observable을 제한 적인 기능만으로 create하고 싶을 때 사용하는 것

상황에 따라서 제한적인 이벤트만 받을 수 있도록 도와줄 수 있게 만들어 진 것

Trait는 일반적인 Observable 보다 좁은 범위의 Observable로 선택적으로 사용할 수 있다. -> 일반적인 Observable로 모두 커버 가능하다.

Trait를 사용해서 코드 가독성으로 높일 수 있다. -> 내가 짜고 있는 코드의 의도를 명확히 해준다.

주의 사항 : 이벤트 타입이 서로 다르다 보니 막 Observable 스트림에서 Single 스트림으로 이동한다던지의 혼용시 문제가 생기게 됩니다.

< Single, Maybe, Completable >

- Single

    - onNext, onError, onCompleted 대신에 `.success(value)`, `.failure(error)` 이렇게 두 가지 이벤트 밖에 없다.
    - 사용: 성공 또는 실패로 확인될 수 있는 1회성 프로세스 (예. 데이터 다운로드, 디스크에서 데이터 로딩)

- Completable
  - .completed 또는 .error(error) 만을 방출하며, 이 외 어떠한 값도 방출하지 않는다.
  - 성공 여부만 전달해주고 싶을 때에는 Single이 아닌 Completable을 사용하도록 하자!! -> ex) 파일쓰기

- Maybe

  - Single과 Completable을 섞어놓은 것 -> .success(value), .completed, .error를 모두 방출할 수 있다.
  - 사용: 프로세스가 성공, 실패 여부와 더불어 출력된 값도 내뱉을 수 있을 때
 

<br>


# Subject

[Subject](https://github.com/minseongkim97/Rxswift-Study/blob/main/Subjects.playground/Contents.swift)

Observable이자 Observer

보통의 앱 개발에서 필요한건 실시간으로 Observable의 새로운 값을 추가하고 Subscriber에게 방출하는 것

구독 여부에 관계 없이 요소를 방출

구독자가 구독하는 시점 이후의 이벤트들만 전달 받을 수 있도록 도와주는 것

- PublishSubject: 빈 상태로 시작하여 새로운 값만을 subscriber에 방출한다.
- BehaviorSubject: 하나의 초기값을 가진 상태로 시작하여, 새로운 subscriber에게 초기값 또는 최신값을 방출한다.
- ReplaySubject: 버퍼를 두고 초기화하며, 버퍼 사이즈 만큼의 값들을 유지하면서 새로운 subscriber에게 방출한다.

<br>

# Operators
