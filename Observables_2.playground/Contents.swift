import UIKit
import RxSwift

let disposeBag = DisposeBag()

// 도움 메서드
public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}


// Traits -> Observable을 제한 적인 기능만으로 create하고 싶을 때 사용하는 것
// 상황에 따라서 제한적인 이벤트만 받을 수 있도록 도와줄 수 있게 만들어 진 것

// Trait는 일반적인 Observable 보다 좁은 범위의 Observable로 선택적으로 사용할 수 있다. -> 일반적인 Observable로 모두 커버 가능하다.
// Trait를 사용해서 코드 가독성으로 높일 수 있다. -> 내가 짜고 있는 코드의 의도를 명확히 해준다.

// 주의 사항 : 이벤트 타입이 서로 다르다 보니 막 Observable 스트림에서 Single 스트림으로 이동한다던지의 혼용시 문제가 생기게 됩니다.

// < Single, Maybe, Completable >

// Single
// onNext, onError, onCompleted 대신에 `.success(value)`, `.failure(error)` 이렇게 두 가지 이벤트 밖에 없다.
// 사용: 성공 또는 실패로 확인될 수 있는 1회성 프로세스 (예. 데이터 다운로드, 디스크에서 데이터 로딩)

// 차이점 확인하기
/*
 ex1)
 Single<Int>.just(1)
     .subscribe(
         onSuccess: <#T##((Int) -> Void)?##((Int) -> Void)?##(Int) -> Void#>,
         onFailure: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>,
         onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>
     )
 
 ex2)
 Observable<Int>.just(1)
     .asSingle()
     .subscribe(
         onSuccess: <#T##((Int) -> Void)?##((Int) -> Void)?##(Int) -> Void#>,
         onFailure: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>,
         onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>
     )
 
 ex3)
 Observable<String>
     .create { observer in
         observer.onError(<#T##Error#>)
         return Disposables.create()
     }
     .asSingle()
     .subscribe(
         onSuccess: <#T##((String) -> Void)?##((String) -> Void)?##(String) -> Void#>,
         onFailure: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>,
         onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>
     )
     .disposed(by: disposeBag)
*/

/*
 Observable<Int>.just(1)
    .subscribe(
        onNext: <#T##((Int) -> Void)?##((Int) -> Void)?##(Int) -> Void#>,
        onError: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>,
        onCompleted: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>,
        onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>
    )
*/

// Completable
// .completed 또는 .error(error) 만을 방출하며, 이 외 어떠한 값도 방출하지 않는다.
// 성공 여부만 전달해주고 싶을 때에는 Single이 아닌 Completable을 사용하도록 하자!! -> ex) 파일쓰기


// Maybe
// Single과 Completable을 섞어놓은 것 -> .success(value), .completed, .error를 모두 방출할 수 있다.
// 사용: 프로세스가 성공, 실패 여부와 더불어 출력된 값도 내뱉을 수 있을 때



// 예시 -> single을 이용해서 Resources 폴더 내의 Copyright.txt 파일의 일부 텍스트를 읽어야 한다고 가정해보자.
example(of: "Single") {
    let disposeBag = DisposeBag()

    
    enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
    }
    
    func loadText(from name: String) -> Single<String> {
        return Single.create { single in
            let disposable = Disposables.create()
            
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.failure(FileReadError.fileNotFound))
                return disposable
            }
            
            guard let data = FileManager.default.contents(atPath: path) else {
                single(.failure(FileReadError.unreadable))
                return disposable
            }
            
            guard let contents = String(data: data, encoding: .utf8) else {
                single(.failure(FileReadError.encodingFailed))
                return disposable
            }
            
            single(.success(contents))
            return disposable
        }
    }
    
    loadText(from: "Copyright")
        .subscribe {
            switch $0 {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error)
            }
        }
        .disposed(by: disposeBag)
    
}


// Challenge 1 - never 예제에 do 연산자의 onSubscribe 핸들러를 이용해서 프린트해보기
// do 연산자는 부수작용을 추가하는 것을 허용한다. 다시 말하면 어떤 작업을 추가해도 방출하는 이벤트는 변화시키지 않는 것이다.
// stream을 지나는 동안에 side effect 이벤트가 들어오는 경우 사용.
// do는 이벤트를 다음 연산자로 그냥 통과시켜버린다.
// do는 subscribe는 가지고 있지 않는 onSubscribe 핸들러를 가지고 있다.

example(of: "never") {
    let disposeBag = DisposeBag()
    
    let observable = Observable<Any>.never()
    // 그냥 뚫고 지나간다는 do의 onSubscribe 에다가 구독했음을 표시하는 문구를 프린트하도록 함
    observable.do(
        onSubscribe: {
            print("Subscribed")
        })
        .subscribe(
            onNext: { element in
                print(element)
            },
            onCompleted: {
                print("Completed")
            },
            onDisposed: {
                print("Disposed")
            })
        .disposed(by: disposeBag)
}


// Challenge 2 - 디버그 정보 찍어보기 (debug 연산자)
// debug 연산자는 observable의 모든 이벤트를 프린트 함
// 여러가지 파라미터가 있겠지만 가장 효과적인 것은 특정 문자열을 debug 연산자에 넣어주는 것 (예. debug("어떤 문자"))

example(of: "never") {
    let observable = Observable<Any>.never()
    let disposeBag = DisposeBag()
    
    // debug()의 위치에 따라 출력이 달라진다.. 왜그렇지?
    observable.do(
        onSubscribe: {
            print("do operator onSubscibe")
        })
        .debug("observable")
        .subscribe(
            onNext: { element in
                print(element)
            },
            onCompleted: {
                print("Completed")
            },
            onDisposed: {
                print("Disposed")
            }
        )
        .disposed(by: disposeBag)
}
