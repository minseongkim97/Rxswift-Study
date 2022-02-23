import UIKit
import RxSwift
import RxCocoa

// Observable 생성

let observable = Observable.just(1)

// Observable<Int>
let observable2 = Observable.of(1,2,3)

// Observable<[Int]>
let observable3 = Observable.of([1,2,3])

// Observable<Int>
let observable4 = Observable.from([1,2,3,4,5])

// 현재까지 이들에 대한 구독이 없기 때문에 쓸모가 없는 Observable 이다.

// observable4이 방출하는 값들에 접근할 수 있다.
observable4.subscribe { event in
    print(event)
}
// next(1) next(2) next(3) next(4) next(5) completed

observable4.subscribe { event in
    if let element = event.element {
        print(element)
    }
}
// 1 2 3 4 5



observable3.subscribe { event in
    if let element = event.element {
        print(element)
    }
}
// .of: 하나의 배열이 유일한 요소이다.   [1, 2, 3]
// .from: collection 타입을 전달하면 전체 collection이 아닌 개별 요소에 대한 관찰 가능 항목을 생성한다.


observable4.subscribe(onNext: { element in
    print(element)
})
// 1 2 3 4 5


// Disposing our subscription -> 하지 않으면 메모리 누수가 발생할 수 있다.
let subscription4 = observable4.subscribe(onNext: { element in
    print(element)
})

subscription4.dispose()

// 여러 다른 subscription이 있을 수 있고 우리는 이 모든 subscription의 처분을 잊어버릴 수 있다.
// 다른 dispose 방법 -> disposeBag 활용
let disposeBag = DisposeBag()

Observable.of("A", "B", "C")
    .subscribe {
        print($0)
}.disposed(by: disposeBag)
// 완료되는 시점을 추적 후 적절히 dispose


// create 함수를 활용하여 subscription 만들기
// 모든 항목 지정가능
Observable<String>.create { observer in
    observer.onNext("A")
    observer.onCompleted()
    // completed 후 다음 이벤트는 호출되지 않는다
    observer.onNext("?")
    return Disposables.create()
}.subscribe(
    onNext: {
        print($0)
    },
    onError: {
        print($0)
    },
    onCompleted: {
        print("Completed")
    },
    onDisposed: {
        print("Disposed")
})
.disposed(by: disposeBag)


// Subject = Observable + Observer
// 구독 여부에 관계 없이 요소를 방출
// 구독자가 구독하는 시점 이후의 이벤트들만 전달 받을 수 있도록 도와주는 것



// Publish Subject: 잡지 발행으로 생각해보면 쉬울 거 같다.
// 기본값이 필요하지 않다.
// subscribe 후의 이벤트를 처리한다.
let publishSubject = PublishSubject<String>()

publishSubject.onNext("Issue 1")

publishSubject.subscribe { event in
    print(event)
}

publishSubject.onNext("Issue 2")
publishSubject.onNext("Issue 3")

publishSubject.dispose()

publishSubject.onCompleted()

publishSubject.onNext("Issue 4")

// next(Issue 2) next(Issue 3)


// Behavior Subject: 초기값이 필요하다.
// 제일 처음 구독하는 구독자는 설정해준 초기 값으로 시작을 하게 되고, 그 다음구독자 부터는 구독하기 직전에 방출되었던 값으로 시작을 하게 됩니다.
let behaviorSubject = BehaviorSubject(value: "Initial Value")

behaviorSubject.onNext("Last Issue")

behaviorSubject.subscribe { event in
    print(event)
}

behaviorSubject.onNext("Issue 1")

// next(Last Issue) next(Issue 1)


// Replay Subject: buffer size가 필요하다
// 제일 처음 구독자를 위한 초기값을 설정해줄 필요가 없다.
// 가장 최근에 방출되었던 요소들의 최대 개수를 지정해줄 수 있다.
// 뒤에 추가된 이벤트는 모두 처리
// 다만 주의해야할 점이 하나 있는데요. 이렇게 buffer에 이전 방출된 요소들을 저장하는 행위는 엄연히 메모리를 사용하는 행위이기 때문에 이미지라던지 영상 데이터들을 ReplaySubject로 다룰 때 너무 남발하지 않는 것을 추천드립니다.
let replaySubject = ReplaySubject<String>.create(bufferSize: 2)

replaySubject.onNext("Issue 1")
replaySubject.onNext("Issue 2")
replaySubject.onNext("Issue 3")

replaySubject.subscribe {
    print($0)
}.disposed(by: disposeBag)

// next(Issue 2) next(Issue 3)

replaySubject.onNext("Issue 4")
replaySubject.onNext("Issue 5")
replaySubject.onNext("Issue 6")

print("[Subscription 2]")
replaySubject.subscribe {
    print($0)
}.disposed(by: disposeBag)


"""
next(Issue 2)
next(Issue 3)
next(Issue 4)
next(Issue 5)
next(Issue 6)
[Subscription 2]
next(Issue 5)
next(Issue 6)
"""


// Relay
// 각 PublishRelay와 BehaviorRelay는 이름에서 알 수 있듯이 PublishSubject랑  BehaviorSubject의 wrapper 클래스 입니다!
// Read Only cf) Variable (사라질 것임)
// Relay는 onNext 대신 accept라는 이벤트를 방출합니다. accept가 onNext의 역할을 하는 것
// 다른 onError나 onCompleted 이벤트는 모두 무시
// 오직 accept 이벤트만 방출하고 onError나 onCompleted가 방출되도 무시하기 때문에 시퀀스가 절대 죽지 않는 것이죠.
// Relay의 시퀀스가 절대 죽지 않는다는 특성을 이용하여 UI를 다룰 때 주로 사용


var behaviorRelay = BehaviorRelay<String>(value: "Start with me")

behaviorRelay.subscribe(onNext: { element in
    print(element)
}).disposed(by: disposeBag)

behaviorRelay.accept("hi🙂")

behaviorRelay.subscribe(onNext: { element in
    print(element)
}).disposed(by: disposeBag)

behaviorRelay.accept("bye🙂")
