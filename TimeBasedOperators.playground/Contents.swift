import RxSwift
import RxCocoa
import UIKit
import PlaygroundSupport

let disposeBag = DisposeBag()

// 1. replay
print("----------replay----------")
let greet = PublishSubject<String>()
let 반복하는앵무새 = greet.replay(1)
반복하는앵무새.connect()

greet.onNext("1. hello")
greet.onNext("2. hi")

반복하는앵무새
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

greet.onNext("3. 안녕하세요")


// 2. replayAll
print("----------replayAll----------")
let 닥터스트레인지 = PublishSubject<String>()
let 타임스톤 = 닥터스트레인지.replayAll()
타임스톤.connect()

닥터스트레인지.onNext("도르마무")
닥터스트레인지.onNext("거래를 하러왔다")

타임스톤
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


// 3. buffer
print("----------buffer----------")
// Observable에서 방출되는 요소들을 몇 개씩 묶어서 구독자들에게 전달해주도록 도와주는 연산자
// timeSpan: 요소들을 받을 대기시간을 설정해주는 파라미터, count: 몇 개의 요소들을 묶어서 구독자에게 전달해줄 것인지 결정해주는 파라미터, scheduler: 해당 코드가 실행될 쓰레드를 정해주는 파라미터

let source = PublishSubject<String>()

var count = 0
let timer = DispatchSource.makeTimerSource()

timer.schedule(deadline: .now() + 2, repeating: .seconds(1))
timer.setEventHandler {
    count += 1
    source.onNext("\(count)")
}
timer.resume()

source
    .buffer(
        timeSpan: .seconds(2),
        count: 2,
        scheduler: MainScheduler.instance
    )
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


// 4. window
print("----------window----------")
//  buffer와 같이 여러 요소들을 묶어서 한 번에 구독자에게 전달해주는데 [1, 2, 3] 이렇게 전달해주지 않고, Observable로서 전달해주는 연산자
// 요소들을 묶어서 또다른 Observable로 처리할 일이 있다면 buffer 대신 window를 사용하자!

let 만들어낼최대Observable = 1
let 만들시간 = RxTimeInterval.seconds(2)

let window = PublishSubject<String>()

var windowCount = 0
let windowTimerSource = DispatchSource.makeTimerSource()
windowTimerSource.schedule(deadline: .now() + 2, repeating: .seconds(1))
windowTimerSource.setEventHandler {
    windowCount += 1
    window.onNext("\(windowCount)")
}
windowTimerSource.resume()

window
    .window(
        timeSpan: 만들시간,
        count: 만들어낼최대Observable,
        scheduler: MainScheduler.instance
    )
    .flatMap { windowObservable -> Observable<(index: Int, element: String)> in
        return windowObservable.enumerated()
    }
    .subscribe(onNext: {
        print("\($0.index)번째 Observable의 요소 \($0.element)")
    })
    .disposed(by: disposeBag)


// 5. delaySubscription
print("----------delaySubscription----------")
// 구독 자체를 일정 시간만큼 지연 시켜주는 연산자
// dueTime:  얼마동안 구독을 지연시킬건지를 결정, scheduler:  해당 코드를 어떤 쓰레드에서 작업 시킬것인지를 정해준다.

let delaySource = PublishSubject<String>()

var delayCount = 0
let delayTimeSource = DispatchSource.makeTimerSource()
delayTimeSource.schedule(deadline: .now()+2, repeating: .seconds(1))
delayTimeSource.setEventHandler {
    delayCount += 1
    delaySource.onNext("\(delayCount)")
}
delayTimeSource.resume()

delaySource
    .delaySubscription(.seconds(5), scheduler: MainScheduler.instance)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


// 6. delay
print("----------delay----------")
// Observable에서 방출되는 요소를 원하는 시간만큼 지연시켰다가 방출 시키도록 도와주는 연산자
// 요소 방출을 대기시킨다.
// dueTime:  얼마나 요소 방출을 지연시킬 것인지를 정해준다, scheduler: 실행 코드를 어떤 쓰레드에서 실행 시킬 것인지 정해준다.


let delaySubject = PublishSubject<String>()

var delayCount2 = 0
let delayTimeSource2 = DispatchSource.makeTimerSource()
delayTimeSource2.schedule(deadline: .now(), repeating: .seconds(1))
delayTimeSource2.setEventHandler {
    delayCount2 += 1
    delaySource.onNext("\(delayCount2)")
}
delayTimeSource2.resume()

delaySubject
    .delay(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


// 7. interval
print("----------interval----------")
// 일정 주기마다 요소를 반복 방출 시켜주는 연산자
// period: 몇 초 간격으로 요소를 방출시킬지를 정해주는 파라미터
// 방출되는 값은 index값이 방출되게 된다.
// 앞서 구현했던 타이머를 rx로 구현하게 해준다.
Observable<Int>
    .interval(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


// 8. timer
print("----------timer----------")
// interval 연산자와 같이 일정 주기마다 요소(index값)를 방출시키는 연산자 입니다.
// 일정 시간동안 대기했다가 일정 주기마다 요소를 방출 시키고 싶다면 사용
// timer가 마감되는 시간이 아니라 첫 구독한 이후 첫번쨰 값 사이의 dueTime
Observable<Int>
    .timer(
        .seconds(5),
        period: .seconds(2),
        scheduler: MainScheduler.instance
    )
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


// 9. timeOut
print("----------timeOut----------")
// 내가 설정한 시간동안 아무런 요소가 방출되지 않으면 그대로 Observable 시퀀스를 종료하도록 만드는 연산자
// 가끔 인터넷이 느린 환경에서 무언가를 로딩하려고 했을때 너무 시간이 오래 걸리면 로딩 시간 초과 문구가 뜨는 것을 다들 한 번쯤 경험 해봤을 겁니다. 이런 느낌의 상황을 rx에서 timeout을 이용하면 매우 쉽고 빠르게 구현이 가능합니다.
// dueTime: timeout될 시간 즉 얼마나 요소가 방출되기까지를 기다릴 것인지를 설정해주는 파라미터
let 누르지않으면에러 = UIButton(type: .system)
누르지않으면에러.setTitle("눌러주세요!", for: .normal)
누르지않으면에러.sizeToFit()

PlaygroundPage.current.liveView = 누르지않으면에러

누르지않으면에러.rx.tap
    .do(onNext: {
        print("tap")
    })
    .timeout(.seconds(5), scheduler: MainScheduler.instance)
    .subscribe {
        print($0)
    }
    .disposed(by: disposeBag)
