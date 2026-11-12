-- Unit: Combine과 데이터 바인딩 (Unit ID: 185)
-- Chapter: iOS (Chapter ID: 17)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (611, 185, '구독 수명과 스케줄러, debounce'),
       (769, 185, '발행 시점과 완료, 스트림 전환·결합'),
       (927, 185, 'Combine 구독 동작과 async/await 비교');

-- =====================================================
-- Lesson 611: 구독 수명과 스케줄러, debounce
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3845, 611, '아래 코드에서 bind() 호출 이후 count를 바꿔도 출력이 나오지 않는 이유로 옳은 것은?', '```swift
final class CounterViewModel {
    @Published var count = 0

    func bind() {
        let cancellable = $count
            .map { value in "현재 \(value)회" }
            .sink { text in print(text) }
        _ = cancellable
    }
}

let vm = CounterViewModel()
vm.bind()        // 출력: 현재 0회
vm.count = 1     // 출력 없음
vm.count = 2     // 출력 없음
```', 'OBJECTIVE'),
       (3846, 611, '아래 파이프라인에서 각 단계가 실행되는 큐에 대한 설명으로 옳은 것은?', '```swift
URLSession.shared.dataTaskPublisher(for: url)              // ①
    .subscribe(on: DispatchQueue.global(qos: .utility))    // ②
    .map { output in decode(output.data) }                 // ③
    .receive(on: DispatchQueue.main)                       // ④
    .map { item in item.title.uppercased() }               // ⑤
    .sink { title in titleLabel.text = title }             // ⑥
    .store(in: &cancellables)
```', 'OBJECTIVE'),
       (3847, 611, '아래 로그를 만든 Subject 타입에 대한 설명으로 옳은 것은?', '하나의 subject에 구독자 A·B를 시차를 두고 붙였을 때의 실행 로그다.

```
t=0   subject.send(10)
t=1   subject.send(20)
t=2   구독자 A 연결          → A 수신: 20
t=3   subject.send(30)       → A 수신: 30
t=4   구독자 B 연결          → B 수신: 30
t=5   subject.send(40)       → A 수신: 40 / B 수신: 40
```', 'OBJECTIVE'),
       (3848, 611, '아래 비교표를 근거로 두 비동기 모델을 설명한 내용으로 옳지 않은 것은?', '| 항목 | Combine | async/await |
|---|---|---|
| 값의 개수 | 시간에 따라 여러 값이 흐르는 스트림 | 호출 한 번에 값 하나 |
| 에러 처리 | Failure 타입, catch·retry 연산자 | throws, do/catch |
| 취소 | AnyCancellable.cancel() | Task.cancel() 뒤 작업이 취소 지점을 직접 확인 |
| 실행 위치 제어 | Scheduler — subscribe(on:)·receive(on:) | actor·@MainActor 격리 |
| 시간·결합 연산 | debounce·throttle·combineLatest 내장 | 표준 라이브러리에 없어 별도 패키지 필요 |
| 최소 지원 버전 | iOS 13+ | iOS 15+ |', 'OBJECTIVE'),
       (3849, 611, '아래 코드에서 deinit이 호출되지 않게 만든 참조 관계를 가리키는 용어는?', '```swift
final class ProfileViewModel {
    @Published var name = ""
    private var cancellables = Set<AnyCancellable>()

    init(namePublisher: AnyPublisher<String, Never>) {
        namePublisher
            .assign(to: \.name, on: self)
            .store(in: &cancellables)
    }

    deinit { print("deinit ProfileViewModel") }
}
```

화면을 열고 닫으며 뷰모델을 가리키던 참조를 모두 지웠는데도 "deinit ProfileViewModel"이 한 번도 출력되지 않고, 화면을 여닫을수록 인스턴스가 하나씩 메모리에 쌓인다.', 'SUBJECTIVE'),
       (3850, 611, '아래처럼 요청 로그가 바뀌도록 파이프라인에 추가한 Combine 연산자의 이름은?', '검색창에 "스위프트"를 한 글자씩 입력했을 때 나간 요청 로그다.

```
[변경 전]
12:00:01.020  GET /search?q=스
12:00:01.190  GET /search?q=스위
12:00:01.340  GET /search?q=스위프
12:00:01.500  GET /search?q=스위프트    ← 마지막 타이핑

[연산자 하나(인자 300ms)를 추가한 뒤 — 같은 속도로 같은 입력]
12:04:07.800  GET /search?q=스위프트    ← 마지막 타이핑은 12:04:07.500, 요청은 이 한 건뿐
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3845
(10427, 3845, 'map 연산자가 첫 값만 변환한 뒤 업스트림 구독을 끊어 두 번째 값부터는 흐르지 않는다.', 'map은 값이 올 때마다 변환해 그대로 흘려보낼 뿐 스트림을 끝내지 않는다. 흐름이 멈춘 원인은 연산자가 아니라 구독을 쥔 객체의 수명에 있다.', false),
(10428, 3845, 'sink가 돌려준 AnyCancellable이 지역 변수라 bind()가 끝날 때 해제되고, 해제 시 자동 cancel()로 구독이 사라진다.', 'Combine 구독의 수명은 AnyCancellable이 쥔다. store(in: &cancellables)처럼 뷰모델이 보관해야 이후 값도 계속 받는다. 첫 출력은 구독 직후 현재 값이 한 번 전달된 것이다.', true),
(10429, 3845, '@Published는 willSet 시점에 발행하므로 대입이 끝난 값은 구독자에게 전달되지 않는다.', 'willSet 시점 발행은 맞지만 새 값은 클로저 인자로 전달된다. 이 성질은 sink 안에서 self의 프로퍼티를 읽을 때 이전 값이 보이는 문제로 나타날 뿐 발행 자체를 막지 않는다.', false),
(10430, 3845, '구독이 메인 큐 밖에서 시작돼 receive(on: DispatchQueue.main)을 붙이지 않으면 값이 버려진다.', '스케줄러를 지정하지 않으면 값은 발행된 곳에서 그대로 전달된다. receive(on:)은 실행 위치를 옮길 뿐 값의 전달 여부를 결정하지 않는다.', false),

-- 문제 3846
(10431, 3846, '④는 파이프라인 전체에 적용되므로 ③의 디코딩도 메인 큐에서 실행된다.', 'receive(on:)의 효력은 호출한 지점 아래 구간에만 미친다. ③은 ④보다 위에 있어 업스트림이 값을 내보낸 곳에서 그대로 실행되고, 여기서는 백그라운드다.', false),
(10432, 3846, '②는 자기 아래 구간의 실행 큐를 바꾸므로 ③의 디코딩만 백그라운드로 옮겨진다.', 'subscribe(on:)이 정하는 것은 구독과 발행 시작 작업이 실행될 곳, 즉 위쪽이다. 아래 구간을 옮기는 것은 receive(on:)이며 두 연산자의 방향은 서로 반대다.', false),
(10433, 3846, '⑤는 ④ 아래에 있어 메인 큐에서 실행되고, 이어지는 ⑥의 라벨 갱신도 메인 큐에서 일어난다.', 'receive(on:)은 호출 지점부터 아래 구간의 실행 위치를 바꾼다. 그래서 ⑤의 변환과 ⑥의 UI 갱신이 함께 메인 큐로 넘어와 안전해진다.', true),
(10434, 3846, '⑥은 UI를 다루는 구문이라 Combine이 메인 큐로 자동 전환하므로 ④가 없어도 문제가 없다.', 'Combine에 그런 자동 전환은 없다. dataTaskPublisher는 백그라운드에서 값을 내보내므로 ④를 지우면 백그라운드에서 UI를 만지게 되어 크래시로 이어질 수 있다.', false),

-- 문제 3847
(10435, 3847, '구독하지 않아도 value 프로퍼티로 지금 들고 있는 값을 그 자리에서 읽을 수 있다.', '값을 보관하는 Subject라 동기적으로 현재 상태를 꺼내는 통로가 열려 있다. 이벤트만 흘려보내는 쪽에는 이런 프로퍼티가 없어 값을 알려면 구독해야 한다.', true),
(10436, 3847, '생성할 때 초기값을 줄 수 없어 첫 send 전까지는 어떤 값도 들고 있지 않다.', '초기값 없이 만드는 쪽은 PassthroughSubject다. 로그처럼 구독 직전 값을 넘겨주려면 만들어지는 순간부터 들고 있을 값이 필요하므로 초기값이 필수다.', false),
(10437, 3847, '구독자는 연결한 시점 이후의 값만 받으므로 t=3의 30은 A에게만 전달된다.', '로그에서 B는 t=4에 연결하자마자 30을 받았다. 마지막 값을 보관했다가 새 구독자에게 먼저 건네는 이 동작이 두 Subject를 가르는 지점이다.', false),
(10438, 3847, 'send(completion: .finished)로 끝낸 뒤 다시 send(40)을 호출하면 구독자가 40을 받는다.', '완료 이벤트가 지나가면 스트림은 닫혀 이후 값은 아무에게도 전달되지 않는다. 값을 보관하는 성질과 완료 후 재발행을 뒤섞은 오해다.', false),

-- 문제 3848
(10439, 3848, '화면 진입 시 프로필 한 건만 받아오는 요청은 값이 하나뿐이라 async/await로 쓰면 do/catch 한 곳에서 에러를 정리할 수 있다.', '값의 개수 행과 에러 처리 행에서 곧장 나오는 결론이다. 단발 요청에는 구독 보관과 취소 객체 관리라는 스트림 모델의 장치가 과하다.', false),
(10440, 3848, '검색어가 계속 바뀌는 입력창처럼 값이 여러 번 흐르고 시간 조건까지 붙는 화면은 Combine이 연산자 조합만으로 표현한다.', '값의 개수 행과 시간·결합 연산 행을 함께 읽으면 나오는 결론이다. 여러 값에 시간 조건과 결합이 겹치는 구간이 Combine이 가장 강한 영역이다.', false),
(10441, 3848, '취소 수단은 두 모델 모두 있지만 async/await는 취소를 알린 뒤에도 작업이 스스로 확인해야 실제로 멈춘다.', '취소 행의 협력적 취소를 읽은 것이다. Task.cancel()은 취소 표시를 세울 뿐이라 작업 안에 확인 지점이 없으면 계산은 끝까지 돌아간다.', false),
(10442, 3848, 'async/await는 표준 라이브러리의 debounce로 입력 지연을 걸 수 있어 시간·결합 연산이 필요한 화면에서도 Combine을 대체한다.', '시간·결합 연산 행에 정면으로 걸린다. 해당 연산자는 async/await 표준 라이브러리에 없어 별도 패키지를 붙여야 하므로 거짓이다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1238, 3849, '순환 참조,강한 참조 순환,강한 순환 참조,참조 순환,retain cycle,strong reference cycle,리테인 사이클', 'assign(to:on:)은 대상 객체인 self를 강하게 참조하고, 그 결과로 받은 AnyCancellable을 다시 self가 cancellables에 보관한다. self와 구독이 서로를 붙잡아 참조 수가 0으로 내려가지 못하므로 외부 참조를 모두 지워도 deinit이 실행되지 않는다. sink { [weak self] name in self?.name = name } 로 바꾸거나, 자기 프로퍼티에 꽂는 경우라면 assign(to: &$name)을 쓰면 고리가 끊긴다. 눈에 보이는 메모리 누수는 결과이고 원인은 이 참조 고리라는 점, 그리고 구독을 보관하지 않아 곧바로 취소되는 반대 상황과도 구분해 두자.'),
       (1239, 3850, 'debounce,디바운스,디바운싱,debouncing', '값이 들어올 때마다 타이머를 다시 시작하고 지정한 시간 동안 새 값이 없을 때에만 마지막 값을 아래로 흘려보내는 연산자가 debounce다. 로그에서 타이핑이 이어지는 동안에는 요청이 한 건도 나가지 않다가 입력이 멈춘 뒤 300ms에 마지막 검색어 한 건만 나간 것이 그 동작이다. throttle은 지정한 간격마다 값을 통과시키므로 타이핑 도중에도 중간 요청이 나가고, removeDuplicates는 같은 값이 연달아 올 때만 걸러 시간과는 무관하다. 실무에서는 removeDuplicates·switchToLatest와 함께 묶어 이전 요청까지 취소한다.');

-- =====================================================
-- Lesson 769: 발행 시점과 완료, 스트림 전환·결합
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4793, 769, '아래 코드에서 마지막 줄이 찍는 출력으로 옳은 것은?', '```swift
import Combine

final class ThermostatViewModel {
    @Published var target = 20
    private var bag = Set<AnyCancellable>()

    func bind() {
        $target
            .sink { [weak self] value in
                print("전달값=\(value) 프로퍼티=\(self?.target ?? -1)")
            }
            .store(in: &bag)
    }
}

let vm = ThermostatViewModel()
vm.bind()        // 전달값=20 프로퍼티=20
vm.target = 26   // ?
```', 'OBJECTIVE'),
       (4794, 769, '아래 실행 결과에서 마지막 send가 아무 출력도 남기지 않은 상황에 대한 설명으로 옳은 것은?', '```swift
enum LoadError: Error { case timeout }

let subject = PassthroughSubject<Int, LoadError>()
subject
    .map { $0 * 2 }
    .sink(receiveCompletion: { print("완료: \($0)") },
          receiveValue:      { print("값: \($0)") })
    .store(in: &cancellables)

subject.send(1)                              // 값: 2
subject.send(completion: .failure(.timeout)) // 완료: failure(timeout)
subject.send(3)                              // 출력 없음
```', 'OBJECTIVE'),
       (4795, 769, '아래 화면에서 배지 갱신이 밀리는 원인으로 옳은 것은?', 'UIKit 목록 화면이다. 서버 상태를 3초마다 받아 상단 배지에 표시하며, 파이프라인 마지막 구간의 스케줄러로 RunLoop.main을 지정했다.

- 화면을 가만히 두면 배지가 3초마다 제때 바뀐다.
- 손가락으로 목록을 잡고 스크롤하는 동안에는 배지가 멈춰 있다.
- 스크롤을 멈추고 손을 떼는 순간 밀려 있던 갱신이 한꺼번에 반영된다.
- 스크롤 중에도 응답 수신 로그는 3초 간격으로 계속 찍힌다.
- 다른 코드는 그대로 두고 스케줄러만 DispatchQueue.main으로 바꾸면 스크롤 중에도 배지가 바뀐다.', 'OBJECTIVE'),
       (4796, 769, '아래 구독 진행 기록에 대한 설명으로 옳은 것은?', '직접 구현한 Subscriber를 Publisher에 붙였을 때 오간 호출 기록이다.

```
① subscriber → publisher.subscribe(subscriber)
② publisher  → subscriber.receive(subscription:)    Subscription 전달
③ subscriber → subscription.request(.max(2))
④ publisher  → subscriber.receive(1)                반환값 .none
⑤ publisher  → subscriber.receive(2)                반환값 .none
⑥ 이후 값이 더 오지 않는다. 완료 이벤트는 아직 오지 않았고 cancel()도 부르지 않았다.
```', 'OBJECTIVE'),
       (4797, 769, '아래 로그처럼 화면 동작이 바뀌도록 파이프라인에서 교체한 Combine 연산자의 이름은?', '목록을 빠르게 스크롤해 같은 셀이 세 번 재사용되는 동안 찍힌 이미지 요청 로그다. 셀은 새 항목을 맡을 때마다 이미지 주소를 하나씩 흘려보내고, 그 주소로 만든 네트워크 Publisher를 안쪽 스트림으로 연결한다.

```
[교체 전 — flatMap]
12:00:00.100  요청 시작 item1
12:00:00.260  요청 시작 item2
12:00:00.410  요청 시작 item3
12:00:00.980  응답 도착 item3 → 셀에 item3 그림 표시
12:00:01.240  응답 도착 item1 → 셀에 item1 그림 표시   ← 이 셀이 맡은 항목은 item3

[교체 후 — 연산자 하나만 바꿈]
12:04:31.100  요청 시작 item1
12:04:31.260  요청 시작 item2   (item1 안쪽 구독 취소)
12:04:31.410  요청 시작 item3   (item2 안쪽 구독 취소)
12:04:31.980  응답 도착 item3 → 셀에 item3 그림 표시
```', 'SUBJECTIVE'),
       (4798, 769, '아래 로그처럼 버튼 상태가 정해지도록 두 입력에 적용한 Combine 연산자의 이름은?', 'UIKit 로그인 화면이다. 이메일과 비밀번호 입력을 각각 초기값이 빈 값인 CurrentValueSubject로 흘리고, 연산자 하나를 거쳐 나온 결과로 제출 버튼의 활성 여부를 갱신한다. 활성 조건은 이메일에 @가 있고 비밀번호가 여덟 자 이상인 것이다.

```
구독 직후                 → 버튼 비활성  (이메일: 빈 값 / 비밀번호: 빈 값)
t=1  이메일 a 입력         → 버튼 비활성  (이메일: a / 비밀번호: 빈 값)
t=2  이메일 a@b.com 입력   → 버튼 비활성  (이메일: a@b.com / 비밀번호: 빈 값)
t=3  비밀번호 abcd 입력    → 버튼 비활성  (이메일: a@b.com / 비밀번호: abcd)
t=4  비밀번호 abcdefgh 입력 → 버튼 활성   (이메일: a@b.com / 비밀번호: abcdefgh)
t=5  이메일 ab.com 입력    → 버튼 비활성  (이메일: ab.com / 비밀번호: abcdefgh)
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4793
(12955, 4793, '전달값=26 프로퍼티=26', '@Published가 대입이 끝난 뒤에 발행한다고 본 오해다. 프로젝션은 값이 바뀌기 직전에 발행하므로 클로저가 도는 순간 저장 프로퍼티는 아직 갱신되지 않았다.', false),
(12956, 4793, '전달값=26 프로퍼티=20', '@Published의 프로젝션은 willSet 시점에 발행한다. 새 값 26은 클로저 인자로 넘어오지만 저장 프로퍼티에는 아직 반영 전이라 20이 읽힌다. 클로저 안에서 self의 프로퍼티를 읽지 말고 인자를 써야 하는 이유다.', true),
(12957, 4793, '전달값=20 프로퍼티=26', '프로젝션이 이전 값을 인자로 준다고 방향을 뒤집어 본 오해다. 인자로 오는 것은 언제나 새로 대입될 값이고, 이전 값이 남아 있는 쪽은 저장 프로퍼티다.', false),
(12958, 4793, '전달값=20 프로퍼티=20', '구독 시점의 값만 계속 전달된다고 본 오해다. 프로젝션은 대입이 있을 때마다 발행하므로 vm.target = 26에서 새 값이 한 번 더 흐른다.', false),

-- 문제 4794
(12959, 4794, '실패 대신 finished로 끝냈다면 스트림이 유지되어 마지막 send(3)에서 값: 6이 찍힌다.', '완료 이벤트가 종류와 상관없이 스트림을 끝낸다는 점을 놓친 오해다. finished도 failure와 똑같이 종결 신호이며, 그 뒤로는 어떤 값도 아래 구간으로 전달되지 않는다.', false),
(12960, 4794, 'subject에 구독자를 하나 더 붙이면 그 구독자는 마지막 send(3)의 값을 정상으로 받는다.', 'Subject가 종료 상태를 기억한다는 점을 놓친 오해다. 이미 완료를 내보낸 Subject에 새로 구독하면 값 대신 완료 이벤트를 곧바로 받고 끝나므로 이후 send는 누구에게도 가지 않는다.', false),
(12961, 4794, '구독을 쥔 AnyCancellable이 살아 있으므로 스트림도 살아 있고, 출력이 없는 것은 receive(on:)이 없어 값이 메인 큐에 닿지 못했기 때문이다.', '스케줄러 누락으로 본 오해다. receive(on:)은 실행 위치만 옮길 뿐 값의 전달 여부를 정하지 않으며, 지정하지 않으면 값은 발행된 자리에서 그대로 전달된다.', false),
(12962, 4794, '실패 완료가 지나가며 파이프라인이 닫힌 것이라, 이 스트림을 살려 두려면 실패를 flatMap 안쪽 Publisher에서 값으로 바꿔 바깥까지 번지지 않게 해야 한다.', '에러는 파이프라인 전체를 종결시킨다. catch나 replaceError를 바깥에 붙이면 대체 값 하나를 내보낸 뒤 finished로 닫히므로, 계속 살아 있어야 하는 UI 스트림은 에러를 안쪽 Publisher에서 처리해 바깥으로 새어 나가지 않게 막는다.', true),

-- 문제 4795
(12963, 4795, '스크롤하는 동안 메인 런루프가 트래킹 모드로 바뀌는데, 이 스케줄러는 기본 모드에 예약된 블록만 실행하므로 전달이 스크롤이 끝날 때까지 미뤄진다.', 'RunLoop 기반 스케줄러는 런루프의 실행 모드를 탄다. UI 트래킹 중에는 기본 모드 블록이 돌지 않아 값이 쌓였다가 모드가 돌아올 때 몰려서 전달된다. UI 바인딩에 DispatchQueue.main을 권하는 이유가 이것이다.', true),
(12964, 4795, '값이 백그라운드 스레드에서 발행되어 메인 스레드로 올라오지 못한 것이므로, 파이프라인 끝에 receive(on:)을 한 번 더 붙여야 한다.', '스레드 전환 누락으로 본 오해다. 이미 메인 런루프 스케줄러를 지정했으니 전달 위치는 메인이며, 문제는 어느 스레드인가가 아니라 언제 실행되는가에 있다.', false),
(12965, 4795, '스크롤 중에는 UIKit이 타이머와 네트워크 작업을 멈추므로 3초 주기의 발행 자체가 끊긴 것이다.', '본문은 스크롤 중에도 응답 수신 로그가 3초 간격으로 찍힌다고 밝히고 있으므로 발행은 계속되고 있다. 멈춘 것은 발행이 아니라 아래 구간으로의 전달이다.', false),
(12966, 4795, 'sink가 요청한 수요가 스크롤 중 바닥나 값이 백프레셔에 막혔다가, 수요가 회복되면서 한꺼번에 흐른 것이다.', '수요 문제로 본 오해다. sink는 .unlimited를 요청하므로 수요가 바닥나지 않으며, 스크롤 여부에 따라 수요가 줄었다 늘었다 하지도 않는다.', false),

-- 문제 4796
(12967, 4796, '④와 ⑤의 반환값은 참고용이라 Publisher가 보내고 싶은 만큼 밀어내며, ⑥은 Publisher에 더 만들 값이 남지 않았다는 뜻이다.', '값이 일방적으로 밀려온다고 본 오해다. Combine은 Subscriber가 요청한 만큼만 보내는 풀 기반이라 receive의 반환값이 곧 추가 수요이고, Publisher가 마음대로 더 보낼 수 없다.', false),
(12968, 4796, '요청한 2개를 모두 받은 시점에 Subscription이 자동으로 취소되므로, 값을 더 받으려면 구독부터 새로 맺어야 한다.', '수요 소진을 구독 종료로 본 오해다. 수요가 0이어도 Subscription은 그대로 살아 있어 언제든 다시 요청을 받을 수 있고, 구독을 끊는 것은 cancel() 호출이나 완료 이벤트다.', false),
(12969, 4796, '남은 수요가 0이 되어 멈춘 것이므로, ②에서 받아 둔 Subscription으로 request(.max(1))를 한 번 더 부르면 값이 하나 더 흐른다.', '수요는 쌓였다가 값이 전달될 때마다 하나씩 줄고, receive가 돌려준 Demand만큼 다시 더해진다. .none만 돌려주면 남은 수요가 0에서 멈춘다. sink는 .unlimited를 요청하기 때문에 이 협상이 겉으로 드러나지 않을 뿐이다.', true),
(12970, 4796, '.max(2)는 받을 값의 개수가 아니라 버퍼 크기 지정이라, 넘치는 값은 버려지고 가장 최근 2개만 남는다.', '수요를 버퍼 용량으로 본 오해다. Demand는 앞으로 받겠다고 약속한 값의 개수를 뜻하며, 넘치는 값을 버리거나 덮어쓰는 동작은 buffer 연산자를 따로 붙여야 생긴다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1554, 4797, 'switchToLatest,.switchToLatest(),switchToLatest(),스위치투레이티스트,스위치 투 레이티스트', '안쪽 Publisher가 새로 도착하면 직전 안쪽 구독을 끊고 최신 것 하나만 살려 두는 연산자가 switchToLatest다. flatMap은 안쪽 스트림을 모두 유지하므로 늦게 도착한 옛 응답이 나중에 화면을 덮어쓰고, 교체 전 로그에서 item1 그림이 item3 그림을 밀어낸 것이 그 결과다. 교체 후 로그의 안쪽 구독 취소 표시가 최신 것만 남기는 동작을 그대로 보여 준다. 헷갈리는 옆 연산자와 구분해 두자. merge는 취소 없이 여러 흐름을 그대로 합치고, combineLatest는 서로 다른 스트림의 최신 값을 짝지을 뿐이며, debounce는 요청이 나가는 시점을 늦출 뿐 이미 나간 요청을 취소하지 못한다. 실무에서는 map으로 안쪽 Publisher를 만든 뒤 switchToLatest를 붙이고, 검색처럼 입력이 잦은 곳에서는 debounce와 함께 쓴다.'),
       (1555, 4798, 'combineLatest,Publishers.CombineLatest,컴바인래티스트,컴바인 래티스트,콤바인래티스트', '한쪽 스트림에 새 값이 오면 다른 쪽의 가장 최근 값과 짝지어 곧바로 결과를 내보내는 연산자가 combineLatest다. 로그에서 t=1과 t=2처럼 이메일만 연달아 바뀌어도 그때마다 비밀번호의 최신 값과 함께 판정이 다시 나온 것이 그 동작이다. zip과 구분해야 한다. zip은 양쪽에서 아직 짝을 만나지 못한 값이 하나씩 모여야 내보내므로 이메일만 두 번 바뀌는 구간에서는 결과가 나오지 않는다. merge는 같은 타입의 값들을 도착 순서대로 섞어 흘릴 뿐 짝을 만들지 않는다. 구독 직후 첫 결과가 나온 것은 두 입력이 CurrentValueSubject라 시작부터 값을 하나씩 들고 있었기 때문이며, PassthroughSubject였다면 양쪽이 한 번씩 값을 낼 때까지 아무 결과도 나오지 않는다.');

-- =====================================================
-- Lesson 927: Combine 구독 동작과 async/await 비교
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5741, 927, '아래 코드에서 표시한 줄이 컴파일되지 않는 이유로 옳은 것은?', '```swift
final class WeatherViewModel: ObservableObject {
    @Published private(set) var temperature = "-"

    init(api: WeatherAPI) {
        // api.fetchTemperature(city:)의 반환 타입: AnyPublisher<Double, URLError>
        api.fetchTemperature(city: "서울")
            .map { "\(Int($0))도" }
            .receive(on: DispatchQueue.main)
            .assign(to: &$temperature)      // ← 컴파일 오류
    }
}
```', 'OBJECTIVE'),
       (5742, 927, '아래 코드를 실행했을 때 서버 로그에 GET /profile 요청이 찍히는 시각을 모두 나열한 것은?', '프로필 화면에서 아래 세 부분을 주석에 적힌 시각에 차례로 실행했다. first와 second는 화면이 닫힐 때까지 보관한다. 서버는 모든 응답에 Cache-Control: no-store를 붙여 기기 쪽 캐시는 쓰이지 않으며, 각 요청은 1초 안에 응답을 받는다.

```swift
// 10:00:00
let request = URLSession.shared.dataTaskPublisher(for: profileURL)
    .map(\.data)

// 10:00:05
let first = request.sink(receiveCompletion: { _ in },
                         receiveValue: { print("A: \($0.count)바이트") })

// 10:00:09
let second = request.sink(receiveCompletion: { _ in },
                          receiveValue: { print("B: \($0.count)바이트") })
```', 'OBJECTIVE'),
       (5743, 927, '아래 상황에서 판정 로그가 늦게 찍히기 시작한 원인으로 옳은 것은?', 'UIKit 로그인 화면이다. 뷰 컨트롤러는 텍스트 필드 내용이 바뀔 때마다 그 값을 해당 입력에 send로 보낸다.

```swift
final class LoginViewModel {
    let emailInput = PassthroughSubject<String, Never>()
    let passwordInput = PassthroughSubject<String, Never>()
    @Published private(set) var isSubmitEnabled = false

    init() {
        Publishers.CombineLatest(emailInput, passwordInput)
            .map { email, pw -> Bool in
                print("판정: \(email) / \(pw.count)자")
                return email.contains("@") && pw.count >= 8
            }
            .assign(to: &$isSubmitEnabled)
    }
}
```

- 이메일 칸에 a@b.com을 한 글자씩 입력하는 동안(값 7번 전달) 판정 로그가 한 줄도 찍히지 않는다.
- 비밀번호 칸에 첫 글자를 치자 "판정: a@b.com / 1자" 한 줄이 처음으로 찍힌다.
- 그 뒤로는 이메일 칸에 글자를 하나 더 칠 때마다 곧바로 판정 로그가 한 줄씩 찍힌다.', 'OBJECTIVE'),
       (5744, 927, '아래 두 구현을 비교한 설명으로 옳은 것은?', '프로필을 한 번 불러오는 같은 기능을 두 방식으로 구현했다. 두 코드 모두 뷰모델 안에 있고, (나)는 화면에서 Task { await viewModel.loadProfile() }로 호출한다.

```swift
// (가) Combine
func loadProfile() {
    api.profilePublisher()                      // AnyPublisher<Profile, Error>
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
                  if case .failure(let e) = completion { self?.error = e }
              },
              receiveValue: { [weak self] p in self?.profile = p })
        .store(in: &cancellables)
}

// (나) async/await
@MainActor
func loadProfile() async {
    do { profile = try await api.fetchProfile() }
    catch { self.error = error }
}
```', 'OBJECTIVE'),
       (5745, 927, '아래 표처럼 요청이 바뀌도록 debounce 뒤에 추가한 Combine 연산자의 이름은?', '검색창 파이프라인은 입력이 300ms 멈추면 그때의 검색어로 요청을 보낸다(debounce). 같은 사람이 같은 순서로 입력했을 때, debounce 바로 뒤에 인자 없는 연산자 하나를 추가하기 전과 후의 요청을 비교한 표다.

| 입력이 멈춘 시각 | 그때의 검색어 | 추가 전 요청 | 추가 후 요청 |
|---|---|---|---|
| 12:00:01 | swift | GET /search?q=swift | GET /search?q=swift |
| 12:00:04 | swift | GET /search?q=swift | 없음 |
| 12:00:07 | swifty | GET /search?q=swifty | GET /search?q=swifty |
| 12:00:10 | swift | GET /search?q=swift | GET /search?q=swift |

12:00:04의 swift는 끝의 t를 지웠다가 300ms 안에 다시 친 경우이고, 12:00:10의 swift는 swifty에서 y를 지운 경우다.', 'SUBJECTIVE'),
       (5746, 927, '아래 로그처럼 실행 스레드가 바뀌도록 sink 바로 위에 추가한 Combine 연산자의 이름은?', '앱 첫 화면에서 설정 파일(12MB)을 읽어 파싱하는 Publisher를 구독한다. 이 Publisher는 값 요청이 들어온 스레드에서 곧바로 파일을 읽고, 다 읽으면 같은 스레드에서 값 하나를 내보낸다. 다른 코드는 그대로 두고 파이프라인 맨 끝 sink 바로 위에 연산자 하나(인자 DispatchQueue.global())만 추가한 전후의 로그다.

```
[추가 전]
설정 파일 읽기 시작   thread: main
설정 파일 읽기 끝     thread: main     ← 이 1.2초 동안 첫 화면이 멈춤
sink 값 수신          thread: main

[추가 후]
설정 파일 읽기 시작   thread: global
설정 파일 읽기 끝     thread: global   ← 첫 화면 멈춤 없음
sink 값 수신          thread: global
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5741
(15483, 5741, 'map이 Double을 String으로 바꿨지만 스트림의 Output은 처음 Publisher의 Double로 고정되어 String 프로퍼티에 넣을 수 없다.', 'Output이 타입으로 고정되는 것은 맞지만 연산자는 매번 새 Publisher를 돌려준다. map을 지나면 Output이 String이 되고 temperature도 String이라 이 부분은 맞아떨어진다.', false),
(15484, 5741, '이 스트림은 URLError로 실패할 수 있는데, assign은 실패 타입이 Never인 스트림에만 연결할 수 있다.', 'Publisher는 Output과 함께 Failure도 타입으로 고정된다. 값을 프로퍼티에 넣기만 하는 assign에는 에러를 받을 자리가 없어 Failure가 Never여야 한다. assign 앞에 replaceError(with: "-")를 두어 에러를 값으로 바꾸면 컴파일된다.', true),
(15485, 5741, 'receive(on:)이 실행 스레드를 옮기면서 실패 타입을 일반 Error로 넓혀 assign과 타입이 맞지 않게 된다.', 'receive(on:)은 실행 위치만 바꿀 뿐 Output과 Failure를 그대로 넘긴다. 실패 가능성은 receive(on:)보다 앞, fetchTemperature가 돌려준 타입에 이미 URLError로 들어 있었다.', false),
(15486, 5741, 'assign이 돌려준 AnyCancellable을 store(in:)으로 보관하지 않아 구독이 곧바로 해제되므로 컴파일러가 막는다.', '&$프로퍼티를 넘기는 assign(to:)는 AnyCancellable을 돌려주지 않고 구독 수명을 그 @Published 프로퍼티에 묶는다. 보관할 반환값이 없으니 오류 원인이 될 수 없다.', false),

-- 문제 5742
(15487, 5742, '10:00:00', 'Publisher를 만드는 순간 요청이 나가고 그 결과를 구독자들이 나눠 받는다고 본 오해다. Publisher는 구독 전까지 아무 일도 하지 않아 만들기만 한 10:00:00에는 요청이 없다.', false),
(15488, 5742, '10:00:05', '첫 구독이 받은 응답을 뒤에 붙은 구독자도 나눠 쓴다고 본 오해다. 구독은 Subscriber마다 따로 맺어지고 그때마다 작업이 처음부터 시작되므로 10:00:09의 sink도 자기 요청을 보낸다.', false),
(15489, 5742, '10:00:00, 10:00:05, 10:00:09', '만들 때 한 번, 구독할 때마다 한 번씩 요청이 나간다고 본 오해다. Publisher를 만드는 코드는 할 일을 정의할 뿐이라 sink가 붙기 전인 10:00:00에는 서버에 아무것도 가지 않는다.', false),
(15490, 5742, '10:00:05, 10:00:09', 'Publisher는 sink가 붙어 구독이 시작될 때 비로소 작업을 한다. 두 sink가 각각 구독을 맺으므로 요청도 붙은 시각마다 한 번씩 나간다. 한 결과를 여러 곳에서 쓸 때 요청이 구독 수만큼 늘어나는 이유다.', true),

-- 문제 5743
(15491, 5743, '두 입력이 값을 보관하지 않는 Subject라, 비밀번호 쪽 첫 값이 오기 전에는 이메일과 짝지을 값이 없어 결합 결과가 나오지 않았다.', 'CombineLatest는 양쪽의 최신 값을 짝지어 내보내므로 양쪽이 한 번 이상 값을 낸 뒤부터 동작한다. 입력을 CurrentValueSubject<String, Never>("")로 두면 구독 직후부터 빈 값과 짝지어 판정이 나온다.', true),
(15492, 5743, 'CombineLatest가 두 입력의 값을 도착 순서대로 하나씩 짝지은 뒤 소비하므로, 이메일 값들이 비밀번호 값을 기다리고 있었다.', '도착 순서대로 짝짓고 소비하는 것은 zip의 동작이다. 그랬다면 첫 판정은 가장 먼저 온 이메일 a와 짝지어졌어야 하고, 그 뒤 이메일만 바뀔 때 곧바로 판정이 찍히지도 않는다.', false),
(15493, 5743, 'PassthroughSubject가 비밀번호 값이 올 때까지 이메일 값을 쌓아 두었다가, 비밀번호 첫 글자가 오자 모아서 내보냈다.', 'PassthroughSubject는 값을 쌓아 두지 않는다. 쌓였다가 몰려 나왔다면 비밀번호 첫 글자 때 이메일 전달 횟수만큼 판정 로그가 여러 줄 찍혔어야 하는데 실제로는 한 줄뿐이다.', false),
(15494, 5743, '구독이 비밀번호 칸을 처음 건드린 순간에 시작되어, 그 전에 보낸 이메일 값은 구독자가 없어 버려졌다.', '구독은 init에서 assign이 붙을 때 이미 시작됐다. 이메일 값이 버려졌다면 첫 판정 로그에 a@b.com이 나올 수 없다. CombineLatest가 이메일의 최신 값을 쥐고 비밀번호 값을 기다린 것이다.', false),

-- 문제 5744
(15495, 5744, '(나)를 부르는 Task를 변수에 담아 두지 않으면 AnyCancellable처럼 곧바로 해제되어 요청도 취소된다.', 'Combine의 구독 수명 규칙을 Task에 옮겨 붙인 오해다. Task는 핸들을 버려도 끝까지 실행되며, 멈추려면 cancel()을 부르고 작업 안에서도 취소를 확인해야 한다.', false),
(15496, 5744, '(가)에서 store(in: &cancellables)를 지워도 sink가 이미 요청을 시작했으므로 응답은 profile에 끝까지 반영된다.', 'sink가 돌려준 AnyCancellable을 아무도 보관하지 않으면 그 자리에서 해제되고, 해제될 때 cancel()이 자동으로 불려 구독이 끊긴다. 응답이 와도 받을 구독자가 남아 있지 않다.', false),
(15497, 5744, '(나)의 profile 대입은 @MainActor 격리 덕분에 메인 스레드에서 일어나므로 (가)의 receive(on:)에 해당하는 줄이 필요 없다.', 'Combine은 Scheduler로, async/await는 actor 격리로 실행 위치를 정한다. @MainActor 함수는 await에서 돌아온 뒤에도 메인 액터에서 이어 실행되므로 UI 상태를 바로 바꿔도 안전하다.', true),
(15498, 5744, '(나)는 에러가 한 번 나면 Combine 스트림처럼 종료 상태가 남아, loadProfile()을 다시 불러도 요청이 나가지 않는다.', '에러로 끝나는 것은 구독 하나의 스트림일 뿐이다. async 함수는 호출마다 독립적으로 실행되므로 다시 부르면 새 요청이 나간다. (가)도 호출할 때마다 파이프라인을 새로 만들어 다시 동작한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1870, 5745, 'removeDuplicates,removeDuplicates(),.removeDuplicates(),리무브듀플리케이츠,리무브 듀플리케이츠,리무브듀플리케이트', '바로 앞에 흘려보낸 값과 같은 값이 연달아 오면 걸러 내는 연산자가 removeDuplicates다. 표에서 12:00:04의 swift는 직전 값 swift와 같아 요청이 사라졌지만, 12:00:10의 swift는 직전 값이 swifty라 다시 통과했다. 지금까지 나온 모든 값이 아니라 바로 앞 값 하나와만 비교한다는 점이 이 표의 핵심이다. 헷갈리는 옆 연산자와 구분해 두자. debounce는 입력이 멈출 때까지 기다렸다가 마지막 값을 내보낼 뿐 같은 검색어가 다시 나오는 것은 막지 못하므로 둘을 함께 쓴다. filter는 조건 클로저를 인자로 받아 값마다 따로 판단할 뿐 직전 값을 기억하지 않는다. Output이 Equatable이면 인자 없이 쓰고, 그렇지 않으면 removeDuplicates(by:)에 비교 방법을 넘긴다.'),
       (1871, 5746, 'subscribe(on:),subscribe(on: DispatchQueue.global()),subscribe(on:DispatchQueue.global()),subscribe(on: .global()),.subscribe(on:),subscribe(on),subscribeOn,서브스크라이브온,서브스크라이브 온', 'subscribe(on:)은 구독과 수요 요청처럼 발행을 시작하는 작업이 실행될 곳을 정하며, 파이프라인 어디에 두든 위쪽 시작점에 영향을 준다. 이 Publisher는 값 요청이 들어온 스레드에서 파일을 읽으므로, sink 바로 위에 두었는데도 파일 읽기가 백그라운드로 옮겨져 첫 화면 멈춤이 사라졌다. 같은 자리에 receive(on:)을 두었다면 그 아래 구간인 sink만 백그라운드로 옮겨지고 파일 읽기는 여전히 메인 스레드에서 돌아 멈춤이 남는다. 두 연산자는 영향을 주는 방향이 서로 반대라는 점을 구분해 두자. 로그처럼 sink도 백그라운드에서 값을 받으므로, 이 값으로 화면을 바꾸려면 sink 앞에 receive(on: DispatchQueue.main)을 함께 둬야 한다.');
