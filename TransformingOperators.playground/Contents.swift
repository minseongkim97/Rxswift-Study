import RxSwift
import RxCocoa


let disposeBag = DisposeBag()

// 1. toArray
// Observable에서 방출된 요소들을 한 번에 모아서 array로서 전달 받을 수 있도록 도와주는 연산자
// toArray() -> Single<[T]>
// UITableView나 UICollectionView에서 유용하게 사용
//  -> ex) api 호출을 통해서 한번 한번 요소를 전달 받는 것이 있다고 하자. 이럴 때 보통 같으면 요소를 받을 때마다 기존에 선언 되어있는 array 등에 요소를 추가해주고 .reloadData()를 매번 호출 해주게 되겠죠.
// 하지만 toArray를 사용한다면 모든 요소들을 전달 받고난 후에 array에 묶인 상태로 받기 때문에 선언 되어있는 array에 그대로 교체해주고 .reloadData() 를 한번만 호출시켜줘도 되겠죠
// 만약 모든 요소를 방출하고서 onCompleted나 onSuccess가 호출되지 않으면 구독자는 아무런 요소를 전달받지 못하게 됩니다!!

Observable.of("A", "B", "C")
    .toArray()
    .subscribe(onSuccess: {
        print($0)
    })
    .disposed(by: disposeBag)


// 2. map
// 타입 변환 시 유용하게 사용가능

Observable.of(Date())
    .map { date -> String in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


// 3. flatMap
// 한 Observable에서 방출되는 요소를 가지고 새로운 요소들을 방출시키는 Observable을 만든 후 구독자에게 넘겨주는 연산자
// 중첩된 observable에서 사용가능

protocol 선수 {
    var 점수: BehaviorSubject<Int> { get }
}

struct 양궁선수 : 선수 {
    var 점수: BehaviorSubject<Int>
}

let 한국국가대표 = 양궁선수(점수: BehaviorSubject<Int>(value: 10))
let 중국국가대표 = 양궁선수(점수: BehaviorSubject<Int>(value: 5))

let 올림픽경기 = PublishSubject<선수>()

올림픽경기
    .flatMap { 선수 in
        선수.점수
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

올림픽경기.onNext(한국국가대표)
한국국가대표.점수.onNext(10)

올림픽경기.onNext(중국국가대표)
한국국가대표.점수.onNext(10)
중국국가대표.점수.onNext(7)


// 4. flatMapLatest
print("----------flatMapLatest----------")
// 가장 최신의 값만을 확인하고 싶을때 사용
// flatMapLatest는 flatMap과 동일하게 Observable에서 방출된 요소를 가지고서 새로운 Observable을 생성하고 새로운 Observable에서 방출되는 요소를 최종적으로 구독자가 받는것 까지는 같은데, 예를들어 새로운 Observable1, 새로운 Observable2 이렇게 각 만들어졌을 때 Obervable1에서 요소가 방출 되다가 Observable2에서 요소가 방출되기 시작하면 Observable1는 종료되게 되는 겁니다.
// 부산이라는 새로운 sequence가 발생한 이후부터는 서울은 해제된다. 더이상 서울이 점수를 내도 받아들이지 않는다.
// 검색기능에서 사용 가능: s -> sw -> swi

struct 높이뛰기: 선수 {
    var 점수: BehaviorSubject<Int>
}

let 서울 = 높이뛰기(점수: BehaviorSubject<Int>(value: 7))
let 부산 = 높이뛰기(점수: BehaviorSubject<Int>(value: 10))

let 전국체전 = PublishSubject<높이뛰기>()

전국체전
    .flatMapLatest { 선수 in
        선수.점수
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

전국체전.onNext(서울)
서울.점수.onNext(9)

전국체전.onNext(부산)
서울.점수.onNext(8)
부산.점수.onNext(15)


// 5. materialize and dematerialize
print("----------materialize and dematerialize----------")
// 에러처리를 도와주는 연산자들
// materialize: 각 요소들을 이벤트 타입으로 감싸서 넘겨주는 연산자
// dematerialize: 이벤트 타입으로 감싸져 있는 것을 풀어서 넘겨주는 연산자

enum 반칙: Error {
    case 부정출발
}

struct 달리기선수: 선수 {
    var 점수: BehaviorSubject<Int>
}

let 김토끼 = 달리기선수(점수: BehaviorSubject<Int>(value: 0))
let 박치타 = 달리기선수(점수: BehaviorSubject<Int>(value: 1))

let 달리기100M = BehaviorSubject<선수>(value: 김토끼)

달리기100M
    .flatMapLatest { 선수 in
        선수.점수
            .materialize()
    }
    .filter {
        guard let error = $0.error else {
            return true
        }
        print(error)
        return false
    }
    .dematerialize()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

김토끼.점수.onNext(1)
김토끼.점수.onError(반칙.부정출발)
김토끼.점수.onNext(2)

달리기100M.onNext(박치타)

