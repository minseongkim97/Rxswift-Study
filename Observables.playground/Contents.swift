import UIKit
import RxSwift

"""
중요한 것은 이 모든 것들이 비동기적(asynchronous)이라는 것.
Observable 들은 일정 기간 동안 계속해서 이벤트를 생성하며, 이러한 과정을 보통 emitting(방출)이라고 표현한다.
각각의 이벤트들은 숫자나 커스텀한 인스턴스 등과 같은 값을 가질 수 있으며, 또는 탭과 같은 제스처를 인식할 수도 있다.
"""

// 도움 메서드
public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

//// RxSwift에서 이벤트들은 enum 케이스로 구현되어있다.
//public enum Event<Element> {
//    /// Next elemet is produced.
//    case next(Element)
//
//    /// Sequence terminated with an error.
//    case error(Swift.Error)
//
//    /// Sequence completed successfully.
//    case completed
//}

// Creating observables
example(of: "just, of, from") {
    let one = 1
    let two = 2
    let three = 3
    
    // just 는 Observable의 타입 메서드. 오직 하나의 요소를 포함하는 Observable을 생성한다.
    let observable = Observable<Int>.just(one)
    
    // of 연산자의 요소들은 타입추론되어서 타입 제한이 생기기 때문에 하나의 타입으로 통일 시켜줘야 합니다.
    // 여러개의 요소들을 순차적으로 방출할 수 있습니다!
    let observable2 = Observable<Int>.of(one, two, three)
    
    // 이렇게 하면 just 연산자를 쓴 것과 같이 [1,2,3] 단일 요소를 가지게 된다.
    let observable3 = Observable.of([one, two, three])
    
    // from 연산자는 배열로 요소를 받은 후에 하나하나 요소로서 방출
    // from 연산자는 오직 array 만 취한다.
    let observable4 = Observable.from([one, two, three])
}

// Subscribing to observables
// Observable은 실제로 sequence 정의일 뿐. Observable은 subscribe 되기 전에는(subscriber를 가지기 전까지) 아무런 이벤트도 보내지 않는다!!
// Observable이 방출하는 각각의 이벤트 타입에 대해서 handler를 추가할 수 있다.
// subscribe는 Disposable을 return 한다.
example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    observable.subscribe { event in
        print(event)
    }
    
    // 대부분의 경우 Observable이 .next 이벤트를 통해 방출하는 element에 관심을 가진다.
    observable.subscribe { event in
        if let element = event.element {
            print(element)
        }
    }
    
    // 아주 자주 쓰이는 패턴이기 때문에 RxSwift에서 축약형을 제공해준다.
    // .onNext 클로저는. .next 이벤트만을 argument로 취한 뒤 핸들링하고 다른 것들은 모두 무시하게 된다.
    observable.subscribe(onNext: { element in
        print(element)
    })
}


example(of: "empty") {
    // empty operator는 빈 Observable을 생성해준다.
    // .completed 이벤트만 방출하게 된다.
    // Observable은 반드시 특정 타입으로 정의되어야 한다.
    // 이 경우 타입추론할 것이 없기 때문에 타입을 명시적으로 정의해줘야한다. -> Void
   
    let observable = Observable<Void>.empty()
    
    observable.subscribe(
        onNext: { element in
            print(element)
    },
        onCompleted: {
            print("Completed")
    })
}
// 그럼 empty operator는 어디에 쓰일까?
    // - 즉시 종료할 수 있는 Observable을 리턴하고 싶을 때
    // - 의도적으로 0개의 값을 가지는 Observable을 리턴하고 싶을 때
// 위의 상황들이 실제 언제 나타날까... 모르겠다...


// never operator <-> empty와는 반대의 개념
// 아무런 이벤트를 방출하지 않고 종료되지 않는다.
example(of: "never") {
    let observable = Observable<Void>.never()
    
    observable.subscribe(
        onNext: { element in
            print(element)
        },
        onCompleted: {
            print("Completed")
        })
}
// 이렇게 하면 Completed 조차 프린트 되지 않는다.
// 그럼 이 코드가 제대로 작동하는지 어떻게 알아?? -> 나중에 Challenges section에서 보재요..



// 지금까지는 특정 element들이나 값을 가지는 observable들을 봤지만
// range operator는 값들의 범위를 가지는 observable을 만들 수 있다.
example(of: "range") {
    // range 연산자를 이용해서 start 부터 count크기 만큼의 값을 갖는 Observable을 생성한다.
    let observable = Observable<Int>.range(start: 1, count: 10)
    observable.subscribe(
        onNext: { i in
            let n = Double(i)
            let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
            
            print(fibonacci)
        })
}



// Disposing and terminating
"""
(한번더, 중요) Observable은 subscription을 받기 전까진 아무 짓도 하지 않음.
즉, subscription이 Observable이 이벤트들을 방출하도록 해줄 방아쇠 역할을 한다는 의미
따라서 (반대로 생각해보면) Observable에 대한 구독을 취소함으로써 Observable을 수동적으로 종료시킬 수 있다. -> dispose operator를 사용해서!
"""
example(of: "dispose") {
    let observable = Observable.of("A", "B", "C")
    
    let subscription = observable.subscribe { event in
        print(event)
    }
    
    // 여기서 구독을 취소하고 싶으면 dispose()를 호출하면 된다. 구독을 취소하거나 dispose 한 뒤에는 이벤트 방출이 정지된다.

    subscription.dispose()
}


// DisposeBag
"""
각각의 구독에 대해서 일일히 관리하는 것은 효율적이지 못하기 때문에, RxSwift에서 제공하는 DisposedBag 타입을 이용할 수 있다.
DisposeBag에는 (보통은 .disposed(by:) method를 통해 추가된) disposables를 가지고 있다.

disposable은 dispose bag이 할당 해제 하려고 할 때마다 dispose()를 호출한다
"""

example(of: "dispoaseBag") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C")
        .subscribe {
            print($0)
        }
        .disposed(by: disposeBag)
}
// 만약 dispose bag을 subscription에 추가하거나 수동적으로 dispose를 호출하는 것을 빼먹는다면, 당연히 메모리 누수가 일어날 것이다.
// 하지만 걱정마. Swift 컴파일러가 disposable을 쓰지 않을 때마다 경고를 날려줄거다.



// create
// Using the create operator is another way to specify all the events an observable will emit to subscribers
// 이벤트들을 내가 원하는 시점에서 방출 시킬 수 있게 도와주는 것이 바로 create연산자 입니다!
enum MyError: Error {
    case anError
}


example(of: "create") {
    let disposeBag = DisposeBag()
    
    // 여기서 AnyObserver란 generic 타입으로 Observable sequence에 값을 쉽게 추가할 수 있다. 추가한 값은 subscriber에 방출된다.
    Observable<String>.create { observer  in
        observer.onNext("1")
        // 2. Error 추가
        observer.onError(MyError.anError)
        
        observer.onCompleted()
        observer.onNext("?")
        
        return Disposables.create()
    }
    // 1. .onCompleted()를 통해서 해당 Observable은 종료되었으므로, 두번째 onNext(_:)는 방출되지 않는다.
    // 2. 에러를 통해 종료된다.
    
    .subscribe(
        onNext: {print($0)},
        onError: {print($0)},
        onCompleted: {print("Completed")},
        onDisposed: {print("Disposed")}
    ).disposed(by: disposeBag)
}


// Creating observable factories
// subscriber를 기다리는 (날 시동시켜줘!) Observable을 만드는 대신, 각 subscriber에게 새롭게 Observable 항목을 제공하는 Obaservable factory를 만드는 방법도 있다.
// Observable이 생성되는 시점을 구독자에 의해서 구독되기 전까지 미뤄주는 역할을 합니다.


example(of: "deferred") {
    let disposeBag = DisposeBag()
    
    var flip = false
    
    let factory: Observable<Int> = Observable.deferred {
        flip = !flip
        
        if flip {
            return Observable.of(1,2,3)
        } else {
            return Observable.of(4,5,6)
        }
    }
    
    for _ in 0...3 {
        factory.subscribe(onNext: {
            print($0, terminator: "")
        })
            .disposed(by: disposeBag)
        
        print()
    }
}
// 왜 deffered operator를 사용할까?
"""
무거운 작업의 Observable을 만들어 사용할 때에는 deferred를 이용해서 구독하는 시점과 동시에 작업을 시작할 수 있도록 해서 쓸데없는 낭비를 막자!

또는 구독과 동시에 최신값이 필요한 경우 Observable을 deferred로 감싸서 사용하도록 하자!
"""
