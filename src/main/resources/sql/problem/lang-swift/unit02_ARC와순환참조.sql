-- Unit: ARC와 순환 참조 (Unit ID: 221)
-- Chapter: Swift (Chapter ID: 22)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (647, 221, 'ARC와 GC 비교, 클로저 순환 참조'),
       (805, 221, 'unowned 크래시와 캡처 목록 판단'),
       (963, 221, '클로저 캡처와 참조 수명 따라가기');

-- =====================================================
-- Lesson 647: ARC와 GC 비교, 클로저 순환 참조
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4061, 647, '아래 Swift 코드를 실행했을 때 콘솔에 찍히는 출력 순서로 옳은 것은?', '```swift
final class Session {
    let id: Int
    init(id: Int) { self.id = id }
    deinit { print("deinit \(id)") }
}

var a: Session? = Session(id: 1)
var b: Session? = Session(id: 2)
b = a
print("mark")
a = nil
b = nil
```', 'OBJECTIVE'),
       (4062, 647, '아래 두 메모리 관리 방식 비교표에서 따라 나오는 설명으로 옳지 않은 것은?', '| 항목 | 방식 A | 방식 B |
| --- | --- | --- |
| 카운트 증감 코드 | 컴파일 시점에 컴파일러가 삽입 | 해당 없음 |
| 해제 시점 | 참조 수가 0이 되는 즉시 | 수집기가 도달 가능성을 검사할 때 |
| 서로를 가리키는 두 객체 | 외부 참조를 모두 끊어도 남음 | 도달 불가능으로 판정돼 회수됨 |
| 실행 중 일시 정지 | 없음 | 힙 스캔 도중 발생 가능 |', 'OBJECTIVE'),
       (4063, 647, '아래 코드를 마지막 줄까지 실행해도 해제 로그가 찍히지 않는 이유로 옳은 것은?', '```swift
final class Downloader {
    var onComplete: (() -> Void)?
    var progress = 0

    func start() {
        onComplete = {
            self.progress = 100
        }
    }
    deinit { print("Downloader 해제") }
}

var d: Downloader? = Downloader()
d?.start()
d = nil
```', 'OBJECTIVE'),
       (4064, 647, '아래에서 설명하는 참조 선언 방식에 대한 설명으로 옳은 것은?', '이 방식으로 선언한 참조는 가리키는 대상의 참조 카운트를 올리지 않는다. 선언할 때는 반드시 옵셔널 var로 써야 하며, 런타임이 별도의 사이드 테이블로 이 참조를 추적한다.', 'OBJECTIVE'),
       (4065, 647, '아래 진단 결과가 가리키는 메모리 문제를 부르는 용어는?', '채팅 화면을 열고 닫기를 30번 반복한 뒤 Memory Graph Debugger를 열자 ChatRoomViewController 인스턴스가 30개 그대로 남아 있었다. deinit에 넣어 둔 로그는 한 번도 찍히지 않았다. 화면이 만들어 프로퍼티로 들고 있는 MessageStore는 owner 프로퍼티로 다시 그 화면을 가리키고 있었고, owner를 weak var로 바꾸자 화면을 닫을 때마다 로그가 찍히고 남아 있는 인스턴스도 사라졌다.', 'SUBJECTIVE'),
       (4066, 647, '아래 컴파일 오류를 없애려면 프로토콜 선언에 상속시켜야 하는 것은?', '```swift
protocol DataLoaderDelegate {
    func didLoad(_ data: [String])
}

final class DataLoader {
    weak var delegate: DataLoaderDelegate?
    func load() { delegate?.didLoad(["a", "b"]) }
}
```

컴파일 오류: ''weak'' must not be applied to non-class-bound protocol', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4061
(11003, 4061, 'mark → deinit 2 → deinit 1', '참조가 끊긴 인스턴스를 실행 흐름 끝에 몰아서 정리한다고 본 오해. 카운트가 0이 되는 순간 바로 해제되므로 b = a 시점에 deinit 2가 mark보다 먼저 찍힌다.', false),
(11004, 4061, 'deinit 2 → mark → deinit 1', 'b = a로 Session(id: 2)를 가리키던 마지막 참조가 사라져 카운트가 0이 되면서 곧바로 deinit 2가 찍힌다. Session(id: 1)은 a와 b가 함께 가리키므로 a = nil로는 남고 b = nil에서 deinit 1이 찍힌다.', true),
(11005, 4061, 'deinit 1 → mark → deinit 2', 'b = a를 a에 b를 넣는 것으로 뒤집어 읽은 것. 대입은 오른쪽 값을 왼쪽 변수에 넣으므로 참조를 잃는 쪽은 Session(id: 1)이 아니라 Session(id: 2)다.', false),
(11006, 4061, 'mark → deinit 1 → deinit 2', '해제가 변수 선언 순서대로 마지막에 일어난다고 본 오해. 해제 순서를 정하는 것은 선언 순서가 아니라 각 인스턴스의 카운트가 0이 되는 시점이다.', false),

-- 문제 4062
(11007, 4062, '방식 A는 인스턴스가 사라지는 시점을 코드만 보고 예측할 수 있어, 파일 핸들이나 소켓 반납을 해제 시점 코드에 맡기기 좋다.', '참인 진술. 카운트가 0이 되는 즉시 해제되므로 해제 지점이 코드 흐름에 고정된다. 자원 반납을 그 지점에 묶어도 실제 시점이 어긋나지 않는다.', false),
(11008, 4062, '방식 B는 응답 지연이 중요한 구간에서 힙 스캔에 따른 순간적인 멈춤을 미리 설계에 반영해야 한다.', '참인 진술. 수집이 언제 일어날지 정해져 있지 않고 스캔 도중 멈춤이 생길 수 있어, 지연이 튀는 구간을 감수하거나 피하도록 설계해야 한다.', false),
(11009, 4062, '방식 A는 참조를 대입하고 버릴 때마다 증감 비용이 붙어, 대입이 잦은 코드에서는 그 비용이 쌓인다.', '참인 진술. 컴파일러가 넣어 둔 증감 코드가 대입마다 실행되므로 비용이 횟수에 비례한다. 대신 따로 도는 수집 스레드는 없다.', false),
(11010, 4062, '방식 A는 서로를 가리키는 두 객체도 수집기가 나중에 훑어 회수하므로, 개발자가 참조 방향을 설계하지 않아도 된다.', '거짓이라 정답. 표에서 방식 A는 그런 객체가 외부 참조를 끊어도 남는다고 적혀 있다. 훑어 줄 수집기가 없으니 한쪽 방향을 카운트가 오르지 않는 참조로 두는 설계가 필요하다.', true),

-- 문제 4063
(11011, 4063, '프로퍼티에 저장된 클로저가 self를 강하게 캡처해, 인스턴스와 클로저가 서로를 붙잡은 채 카운트가 0으로 내려가지 않는다.', '클로저는 참조 타입이라 self를 캡처하면 카운트를 올린다. 인스턴스는 onComplete로 클로저를, 클로저는 self로 인스턴스를 잡고 있어 d = nil로 바깥 참조를 끊어도 둘 다 살아남는다.', true),
(11012, 4063, 'start()에서 만든 클로저가 한 번도 실행되지 않아, 캡처해 둔 참조가 아직 반납되지 않았다.', '캡처는 클로저를 만드는 순간 일어나고 실행 여부와는 무관하다. 클로저를 실행해도 프로퍼티가 그 클로저를 들고 있는 한 캡처한 참조는 그대로 남는다.', false),
(11013, 4063, '클로저 안에서 self.progress에 값을 쓰는 동안 인스턴스의 카운트가 하나 더 올라간 채로 유지된다.', '프로퍼티에 값을 쓰는 동작 자체는 카운트를 바꾸지 않는다. 카운트를 올리는 것은 대입이나 캡처로 만들어진 강한 참조이지, 프로퍼티 접근이 아니다.', false),
(11014, 4063, '클로저가 함수 안에서 만들어져 스택에 남아 있고, 그 스택이 정리되기 전까지 인스턴스를 붙잡는다.', 'Swift의 클로저는 참조 타입이라 캡처한 값과 함께 힙에 놓이고 함수가 끝나도 사라지지 않는다. 문제는 스택 수명이 아니라 프로퍼티가 클로저를 계속 소유한다는 점이다.', false),

-- 문제 4064
(11015, 4064, '대상이 해제된 뒤 접근하면 이미 해제된 객체를 읽었다는 오류로 프로그램이 즉시 중단된다.', '안전장치가 없는 다른 선언 방식의 동작을 갖다 붙인 오개념. 그쪽은 추적 비용도 없는 대신 댕글링 참조를 그대로 읽는다. 사이드 테이블로 추적한다는 본문 설명이 둘을 가르는 지점이다.', false),
(11016, 4064, '구조체나 열거형 인스턴스에도 붙일 수 있어, 값 타입의 수명까지 늘리지 않고 가리킬 수 있다.', '참조 카운트로 수명이 관리되는 것은 힙에 놓이는 클래스 인스턴스뿐이라 값 타입에는 붙일 수 없다. 값 타입은 대입할 때 복사되므로 애초에 카운트를 셀 대상이 아니다.', false),
(11017, 4064, '대상이 해제되는 순간 이 참조는 자동으로 nil이 되므로, 해제된 뒤에 접근해도 프로그램이 중단되지 않는다.', '대상이 사라질 때 런타임이 추적해 둔 참조를 nil로 되돌려 놓아 댕글링 참조가 생기지 않는다. 대신 쓸 때마다 옵셔널 바인딩으로 풀어야 하고 추적에 약간의 비용이 든다.', true),
(11018, 4064, '부모가 자식을 소유하는 방향에 써서, 자식이 부모보다 먼저 해제되지 않도록 붙잡아 준다.', '붙잡아 주는 것은 기본값인 강한 참조의 역할이다. 카운트를 올리지 않는 참조는 오히려 자식에서 부모로 향하는 역방향에 두어 고리를 끊는 데 쓴다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1310, 4065, '순환 참조,순환참조,강한 순환 참조,강한 참조 순환,참조 순환,retain cycle,리테인 사이클,strong reference cycle,reference cycle', '두 인스턴스가 서로를 강한 참조로 붙잡으면 바깥 참조를 모두 끊어도 카운트가 0이 되지 않아 deinit이 호출되지 않는다. 화면을 닫아도 인스턴스가 계속 쌓이고 로그가 찍히지 않는 것이 전형적인 증상이며, owner를 weak var로 바꿔 한쪽 방향의 카운트 증가를 없애면 고리가 끊어진다. 결과로 나타나는 메모리 누수와는 원인과 현상의 관계이고, 임계 구역이나 댕글링 참조와는 다른 문제다. 추적 방식 수집기라면 도달 불가능으로 판정해 회수하지만 ARC는 이 고리를 스스로 찾지 못한다.'),
       (1311, 4066, 'AnyObject,anyobject,AnyObject 프로토콜,: AnyObject,class', 'weak는 참조 카운트로 수명이 관리되는 클래스 인스턴스에만 붙일 수 있는데, 프로토콜 타입은 구조체도 채택할 수 있어 그대로 두면 클래스 전용이 아니다. 선언을 protocol DataLoaderDelegate: AnyObject로 바꾸면 클래스만 채택할 수 있게 되어 weak를 쓸 수 있다. 예전 문법인 : class도 같은 뜻이지만 지금은 AnyObject 표기를 쓴다. 제네릭 제약에 쓰는 Any나 값 타입까지 포함하는 Equatable 같은 일반 프로토콜과 혼동하지 말 것. delegate를 weak로 두는 이유는 부모가 자식을 강하게 소유하는 구조에서 자식이 부모를 다시 강하게 잡으면 고리가 생기기 때문이다.');

-- =====================================================
-- Lesson 805: unowned 크래시와 캡처 목록 판단
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5009, 805, '아래 코드를 끝까지 실행했을 때 콘솔에 찍히는 순서로 옳은 것은?', '```swift
final class Team {
    let name: String
    var leader: Member?
    init(name: String) { self.name = name }
    deinit { print("Team 해제") }
}

final class Member {
    let name: String
    weak var team: Team?
    init(name: String) { self.name = name }
    deinit { print("Member 해제") }
}

var t: Team? = Team(name: "iOS")
var m: Member? = Member(name: "kim")
t!.leader = m
m!.team = t

t = nil
print("mark")
m = nil
```', 'OBJECTIVE'),
       (5010, 805, '아래 세 가지 참조 선언 방식 비교표에서 따라 나오는 설명으로 옳은 것은?', '| 항목 | 방식 A | 방식 B | 방식 C |
| --- | --- | --- | --- |
| 가리킬 때 참조 카운트 | 1 증가 | 증가 없음 | 증가 없음 |
| 대상이 해제되면 | 해제되지 않도록 막음 | 자동으로 nil이 됨 | 옛 주소가 그대로 남음 |
| 선언 형태 | 제약 없음 | 옵셔널 var만 가능 | 비옵셔널 let도 가능 |
| 런타임 추적 비용 | 없음 | 사이드 테이블 추적 비용 있음 | 없음 |', 'OBJECTIVE'),
       (5011, 805, '아래 코드가 마지막 줄에서 중단된 원인으로 옳은 것은?', '```swift
final class Customer {
    let name: String
    var card: Card?
    init(name: String) { self.name = name }
    deinit { print("Customer 해제") }
}

final class Card {
    let number: String
    unowned let owner: Customer
    init(number: String, owner: Customer) {
        self.number = number
        self.owner = owner
    }
    deinit { print("Card 해제") }
}

var kim: Customer? = Customer(name: "kim")
let card = Card(number: "1234", owner: kim!)

kim = nil
print(card.owner.name)
```

실행 결과

```
Customer 해제
Fatal error: Attempted to read an unowned reference but the object was already deallocated
```', 'OBJECTIVE'),
       (5012, 805, '아래 코드 리뷰 상황에 대한 설명으로 옳은 것은?', '코드 리뷰에서 한 팀원이 "클로저에는 예외 없이 [weak self]를 붙이자"고 제안했다. 리뷰 대상 화면에는 두 종류의 클로저가 있었다.

- (가) 버튼을 누르면 `UIView.animate(withDuration: 0.3) { self.box.alpha = 0 }`을 호출한다. 이 클로저는 어디에도 저장되지 않고 애니메이션이 끝나면 버려진다.
- (나) 화면이 프로퍼티로 들고 있는 store에 `store.onChange = { self.reload() }`처럼 클로저를 넣어 둔다. 이 클로저는 화면이 닫힐 때까지 store가 계속 들고 있다.', 'OBJECTIVE'),
       (5013, 805, '아래 상황에서 host 선언 앞에 붙인 키워드는?', '타임라인 화면(부모)이 미디어 재생기(자식)를 프로퍼티로 들고 있고, 재생기는 재생이 끝난 사실을 알리려고 `var host: TimelineViewController?`에 부모를 담아 둔다. 화면을 열고 닫기를 20번 반복했더니 부모와 자식 어느 쪽의 deinit 로그도 찍히지 않았고, 두 인스턴스가 20쌍 그대로 메모리에 남아 있었다. host를 옵셔널 var 그대로 둔 채 선언 앞에 키워드 하나만 붙이자 화면을 닫을 때마다 두 로그가 모두 찍혔고, 부모가 이미 사라진 뒤에 재생기가 host를 건드려도 크래시 없이 조용히 넘어갔다.', 'SUBJECTIVE'),
       (5014, 805, '아래 코드에서 check가 찍히는 시점에 Session(id: 7) 인스턴스를 강하게 가리키는 참조는 몇 개인가?', '```swift
final class Session {
    let id: Int
    init(id: Int) { self.id = id }
    deinit { print("deinit \(id)") }
}

func run() {
    var s1: Session? = Session(id: 7)
    let s2 = s1
    weak var s3 = s1
    var pool: [Session] = []
    pool.append(s1!)

    s1 = nil
    print("check: \(s2!.id) \(s3?.id ?? -1) \(pool.count)")
}
run()
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5009
(13531, 5009, 'mark → Team 해제 → Member 해제', 'team이 카운트를 올린다고 본 오해. 카운트를 올리지 않으므로 t = nil만으로 Team의 카운트가 0이 되고, 해제 로그가 mark보다 먼저 찍힌다.', false),
(13532, 5009, 'Team 해제 → mark → Member 해제', 'Team의 카운트를 올리는 것은 t뿐이라 t = nil에서 바로 0이 된다. 해제되며 leader가 잡고 있던 참조도 풀려 Member는 m 하나만 남고, m = nil에서 해제된다.', true),
(13533, 5009, 'Member 해제 → mark → Team 해제', 'weak를 붙인 방향을 거꾸로 읽은 것. 카운트를 올리지 않는 쪽은 Member가 Team을 가리키는 team이므로, t = nil로 먼저 카운트가 0이 되는 것은 Team이다.', false),
(13534, 5009, 'mark만 찍히고 두 해제 로그는 찍히지 않는다', '서로를 가리키니 고리가 남는다고 본 오해. 한 방향이 카운트를 올리지 않으면 고리가 성립하지 않아, 두 인스턴스 모두 제때 해제되고 로그도 찍힌다.', false),

-- 문제 5010
(13535, 5010, '방식 C는 대상이 사라져도 옵셔널 바인딩으로 걸러 낼 수 있어, 상대의 수명을 따지지 않고 써도 된다.', '해제 뒤 nil이 되는 것은 방식 B다. 방식 C는 옛 주소가 남고 비옵셔널로도 선언되므로 걸러 낼 장치가 없다. 상대가 나보다 오래 산다는 보장이 있을 때만 쓴다.', false),
(13536, 5010, '방식 B로 가리키면 카운트가 오르지 않으므로, 다른 강한 참조가 남아 있어도 대상이 먼저 사라질 수 있다.', '카운트를 올리지 않는 것과 대상을 일찍 없애는 것은 다르다. 카운트를 올리는 참조가 하나라도 남아 있으면 0이 아니므로 대상은 그대로 살아 있다.', false),
(13537, 5010, '방식 A로 양쪽을 선언하면 두 인스턴스가 서로를 지켜 주므로 메모리가 더 빨리 반납된다.', '표의 첫 줄대로 방식 A는 양쪽에서 카운트를 1씩 올린다. 바깥 참조를 모두 끊어도 서로가 올려 둔 카운트가 남아, 빨리 반납되기는커녕 영영 반납되지 않는다.', false),
(13538, 5010, '서로를 가리키는 두 인스턴스라도 한 방향만 방식 B나 C로 바꾸면 그 방향의 카운트가 오르지 않아 둘 다 해제된다.', '해제를 막는 것은 카운트를 올리는 참조뿐이다. 한 방향의 증가를 없애면 바깥 참조가 끊길 때 한쪽이 0이 되고, 그 인스턴스가 놓는 참조로 반대쪽도 이어서 0이 된다.', true),

-- 문제 5011
(13539, 5011, 'owner가 카운트를 올리지 않고 가리켜, card가 살아 있는데도 kim = nil만으로 Customer의 카운트가 0이 되어 해제됐다.', 'Customer의 카운트를 올리는 참조는 kim 하나뿐이라 그것만 끊으면 즉시 해제된다. owner에는 사라진 인스턴스의 옛 주소가 남고, 마지막 줄이 그 주소를 읽어 중단된다.', true),
(13540, 5011, '대상이 해제되면 그 참조는 자동으로 nil이 되는데, owner가 비옵셔널이라 nil을 담지 못해 중단됐다.', '해제 시 nil로 바뀌는 것은 런타임이 따로 추적해 주는 쪽의 동작이다. unowned는 추적을 하지 않아 nil로 바뀌는 일이 없고, 남아 있는 옛 주소를 그대로 읽다가 중단된다.', false),
(13541, 5011, 'Customer가 card를, card가 Customer를 서로 붙잡아 고리가 생겼고, 고리가 있는 상태에서 프로퍼티를 읽어 중단됐다.', '고리가 생기면 해제가 미뤄져 메모리에 남을 뿐, 읽기 자체가 중단되지는 않는다. owner는 카운트를 올리지 않아 고리도 만들어지지 않았고, 그래서 Customer 해제가 찍혔다.', false),
(13542, 5011, 'card가 지역 상수라 kim = nil과 함께 정리됐고, 이미 정리된 card의 프로퍼티를 읽어 중단됐다.', 'card는 아직 유효 범위 안이라 살아 있다. 정말 정리됐다면 Card 해제 로그가 먼저 찍혔어야 하는데, 실행 결과에 찍힌 것은 Customer 해제뿐이다.', false),

-- 문제 5012
(13543, 5012, '(가)도 클로저가 self를 캡처하는 순간 카운트가 오르므로, 캡처 방식을 지정하지 않으면 애니메이션이 끝나도 화면이 해제되지 않는다.', '캡처로 오른 카운트는 클로저가 사라질 때 함께 내려간다. (가)의 클로저는 저장되지 않아 실행 뒤 버려지므로, 올랐던 카운트도 그 시점에 내려간다.', false),
(13544, 5012, '(나)는 클로저가 실행되는 동안에만 self를 잡으므로, reload()가 끝나면 카운트가 내려가 고리가 저절로 풀린다.', '캡처는 실행이 아니라 클로저를 만드는 순간 일어나고, 그 참조는 클로저가 살아 있는 내내 유지된다. store가 클로저를 들고 있는 한 카운트는 내려가지 않는다.', false),
(13545, 5012, '(가)는 클로저가 곧 버려져 고리가 남지 않지만, (나)는 화면이 store를, store가 클로저를, 클로저가 다시 화면을 붙잡아 화면을 닫아도 해제되지 않는다.', '고리가 되려면 붙잡는 참조가 한 바퀴 이어져야 한다. 화면 → store → 클로저 → 화면으로 이어지는 (나)만 그 조건을 채우므로, 캡처 방식을 지정해야 하는 쪽도 (나)다.', true),
(13546, 5012, '두 경우 모두 고리가 생기므로 제안대로 예외 없이 붙여야 하고, 붙이지 않으면 클로저를 만들 때마다 화면이 하나씩 쌓인다.', '저장되지 않고 실행 뒤 버려지는 클로저는 한 바퀴 이어지는 참조를 남기지 않는다. 모든 클로저에 붙이면 고리가 없는 곳까지 옵셔널 처리만 늘어난다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1626, 5013, 'weak,약한 참조,약한참조,weak var,위크', '자식이 부모를 강하게 붙잡으면 부모 → 자식 → 부모로 참조가 한 바퀴 이어져 카운트가 0이 되지 않고, 그래서 화면을 닫아도 deinit 로그가 찍히지 않고 인스턴스가 쌓인다. host를 weak로 선언하면 자식 → 부모 방향에서 카운트가 오르지 않아 고리가 끊어지고, 부모가 해제되는 순간 런타임이 host를 nil로 바꿔 주므로 뒤늦게 건드려도 크래시 없이 넘어간다. unowned도 카운트를 올리지 않지만 대상이 사라진 뒤 접근하면 옛 주소를 읽어 그대로 크래시하므로 본문의 결과와 맞지 않고, 기본값인 strong으로 두면 애초에 고리가 끊어지지 않는다. weak는 카운트로 수명이 관리되는 클래스 인스턴스에만 붙일 수 있다는 점도 함께 기억하자.'),
       (1627, 5014, '2,2개,두 개,두개,둘', 'check 시점에 이 인스턴스를 강하게 가리키는 것은 s2와 배열 pool의 원소, 모두 2개다. s1은 바로 앞 줄에서 nil이 되어 참조를 놓았고, s3은 weak라 처음부터 카운트를 올리지 않는다. 배열·딕셔너리 같은 컬렉션은 담은 원소를 강하게 붙잡으므로 pool.append로 들어간 참조가 1을 차지한다는 점이 핵심이다. 카운트는 아직 2라 이 시점에 deinit은 호출되지 않고, run()이 끝나 s2와 pool이 함께 사라질 때 0이 되면서 그때 deinit이 실행된다. 참조 개수는 변수의 개수가 아니라 카운트를 올리는 강한 참조의 개수로 센다는 점에서 weak 변수 s3과 구분해야 한다.');

-- =====================================================
-- Lesson 963: 클로저 캡처와 참조 수명 따라가기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5957, 963, '아래 코드를 끝까지 실행했을 때 콘솔에 찍히는 순서로 옳은 것은?', '```swift
final class Loader {
    var name = "L"
    func makeHandler() -> () -> Void {
        return { [weak self] in
            guard let self else { print("gone"); return }
            print("run \(self.name)")
        }
    }
    deinit { print("deinit") }
}

var loader: Loader? = Loader()
let handler = loader!.makeHandler()
handler()
loader = nil
handler()
```', 'OBJECTIVE'),
       (5958, 963, '아래 로그 상황에 대한 해석으로 옳은 것은?', '상품 상세 화면 DetailViewController에서 이미지 다운로드를 요청한 뒤 곧바로 화면을 닫았다. 다운로드 함수는 완료 콜백을 인자로 받아 작업이 끝나면 한 번 호출하고 버린다. 화면은 이 콜백을 어디에도 저장하지 않으며, 콜백 안에서는 캡처 리스트 없이 `self.imageView.image = image`로 화면을 갱신한다.

deinit에 남긴 로그를 보니 "상세 화면 해제"는 화면을 닫은 시점이 아니라 약 4초 뒤 다운로드가 끝난 직후에 찍혔다. 같은 동작을 20번 반복한 뒤 Memory Graph Debugger로 확인하니 남아 있는 DetailViewController 인스턴스는 없었다.', 'OBJECTIVE'),
       (5959, 963, '아래 코드를 끝까지 실행했을 때 콘솔에 찍히는 순서로 옳은 것은?', '```swift
final class Buffer {
    deinit { print("Buffer 해제") }
}

struct Wrapper {
    var buf: Buffer
}

var w1: Wrapper? = Wrapper(buf: Buffer())
var w2 = w1
w1 = nil
print("mark")
w2 = nil
```', 'OBJECTIVE'),
       (5960, 963, '아래 참조 관계에서 화면을 닫을 때 OrderViewController가 해제되도록 하려면, 강한 참조를 약한 참조로 바꿔야 하는 곳을 빠짐없이 그리고 필요한 만큼만 고른 것은?', '주문 화면 OrderViewController의 참조 관계는 다음과 같다. 따로 적지 않은 참조는 모두 기본값(strong)이다.

- OrderViewController는 cartView(CartView)와 payment(PaymentManager)를 프로퍼티로 들고 있다.
- CartView는 수량 변경을 알리려고 `var delegate: CartViewDelegate?`로 OrderViewController를 가리킨다.
- PaymentManager는 결제가 끝나면 부를 `var onFinish: (() -> Void)?`를 저장해 두는데, OrderViewController가 여기에 `{ self.showReceipt() }`를 넣었다.
- PaymentManager는 `let logger = Logger.shared`로 앱 전역 싱글턴을 가리킨다. Logger는 받은 문자열만 기록하고 다른 객체는 가리키지 않는다.

화면을 닫으면 내비게이션 스택이 OrderViewController에 대한 참조를 놓는다.', 'OBJECTIVE'),
       (5961, 963, '아래 상황에서 owner 선언 앞에 붙인 키워드는?', '신용카드 앱에서 고객(Customer)은 `var card: Card?`로 카드를 들고 있고, 카드(Card)는 고객 없이는 만들 수 없어서 `let owner: Customer`를 비옵셔널 상수로 두었다. 이대로는 고객 목록 화면을 닫아도 Customer와 Card의 deinit 로그가 한 번도 찍히지 않았다.

owner를 옵셔널로 바꾸거나 var로 고치지 않고 선언 앞에 키워드 하나만 붙이자, 화면을 닫을 때 두 로그가 모두 찍혔다. 그런데 몇 주 뒤 고객이 먼저 해제된 상태에서 남은 카드가 owner.name을 읽는 경로가 실행되자, nil 검사를 거칠 틈도 없이 앱이 Fatal error로 즉시 종료됐다.', 'SUBJECTIVE'),
       (5962, 963, '아래 코드를 실행했을 때 b()가 출력하는 줄의 숫자는?', '```swift
var count = 1
let a = { print("a: \(count)") }
count = 3
let b = { [count] in print("b: \(count)") }
count = 5
a()
b()
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5957
(16059, 5957, 'run L → run L', '클로저가 self를 강하게 붙잡는다고 본 오해. [weak self]로 캡처하면 카운트가 오르지 않아 loader = nil만으로 Loader가 해제되고, 두 번째 호출 전에 deinit이 찍힌다.', false),
(16060, 5957, 'run L → gone → deinit', '해제가 나중으로 미뤄진다고 본 오해. 카운트가 0이 되는 loader = nil 시점에 곧바로 deinit이 찍히고, 그 뒤의 두 번째 호출에서 gone이 찍힌다.', false),
(16061, 5957, 'run L → deinit → gone', '첫 호출 때는 loader가 살아 있어 run L이 찍힌다. loader = nil로 유일한 강한 참조가 사라져 deinit이 찍히고, 두 번째 호출에서는 self가 nil이라 guard의 else로 빠져 gone이 찍힌다.', true),
(16062, 5957, 'run L → deinit → 크래시로 중단', 'unowned의 동작을 갖다 붙인 오개념. weak로 캡처한 self는 대상이 해제되면 nil이 되므로 guard let에서 걸러져 중단 없이 gone이 찍힌다.', false),

-- 문제 5958
(16063, 5958, '다운로드가 끝날 때까지 콜백이 붙잡은 self가 화면의 수명을 늘렸을 뿐, 참조가 한 바퀴 이어지지 않아 고리는 없다.', '콜백은 다운로드 작업이 들고 있다가 한 번 실행한 뒤 버린다. 화면은 콜백을 저장하지 않으므로 고리가 아니라 수명 연장이고, 콜백이 사라져 카운트가 0이 되는 순간 해제된다.', true),
(16064, 5958, '화면과 콜백이 서로를 붙잡은 순환 참조라서, 캡처 방식을 바꾸지 않으면 이 화면은 끝내 해제되지 않는다.', '저장되지 않는 클로저에도 고리가 생긴다고 본 오해. 화면이 콜백을 프로퍼티로 들고 있지 않아 참조가 한 바퀴 이어지지 않으며, 실제로 4초 뒤 해제 로그가 찍혔다.', false),
(16065, 5958, 'ARC가 수집기처럼 일정 주기로 해제를 몰아서 하므로, 카운트가 0이 된 뒤 다음 주기에 해제됐다.', '추적 GC의 동작을 ARC에 갖다 붙인 오해. ARC에는 따로 도는 수집 주기가 없고 카운트가 0이 되는 즉시 해제한다. 늦어진 이유는 콜백이 끝날 때까지 카운트가 남아 있었기 때문이다.', false),
(16066, 5958, '화면은 닫힌 순간 이미 해제됐고, deinit 로그 출력만 콜백이 끝나는 시점까지 미뤄졌다.', 'deinit은 해제 직전에 호출되는 코드라 해제와 로그가 따로 놀지 않는다. 로그가 4초 뒤에 찍혔다면 그때까지 인스턴스가 실제로 살아 있었던 것이다.', false),

-- 문제 5959
(16067, 5959, 'Buffer 해제 → mark', '구조체를 복사하면 안의 인스턴스와 관계가 끊긴다고 본 오해. w2는 같은 Buffer를 가리키는 참조를 복사해 가지므로 w1 = nil 뒤에도 카운트가 1 남는다.', false),
(16068, 5959, 'mark만 찍히고 Buffer 해제는 찍히지 않는다', '구조체가 ARC 대상이 아니니 안의 인스턴스도 관리되지 않는다고 본 오해. 구조체 자체에는 카운트가 없지만, 안에 든 클래스 참조는 복사되고 사라질 때마다 카운트가 오르내린다.', false),
(16069, 5959, 'Buffer 해제 → mark → Buffer 해제', '구조체를 복사할 때 안의 Buffer 인스턴스까지 새로 만들어진다고 본 오해. 복사되는 것은 참조뿐이라 Buffer는 하나이고 해제 로그도 한 번만 찍힌다.', false),
(16070, 5959, 'mark → Buffer 해제', 'w2 = w1은 구조체를 복사하면서 안의 Buffer 참조도 복사해 카운트가 2가 된다. w1 = nil로 1이 되어 mark가 먼저 찍히고, w2 = nil로 0이 되면서 Buffer 해제가 찍힌다.', true),

-- 문제 5960
(16071, 5960, 'CartView의 delegate 한 곳', '고리를 하나만 본 것. 화면 → payment → onFinish 클로저 → 화면으로 이어지는 두 번째 고리가 남아, delegate만 바꿔서는 화면의 카운트가 0이 되지 않는다.', false),
(16072, 5960, 'CartView의 delegate, onFinish 클로저의 self 캡처 두 곳', '고리는 화면 → cartView → delegate → 화면, 화면 → payment → onFinish → 화면 두 개다. 각 고리의 역방향 한 곳씩을 weak delegate와 캡처 리스트 [weak self]로 끊으면 화면이 해제된다.', true),
(16073, 5960, 'onFinish 클로저의 self 캡처 한 곳', '클로저 고리만 본 것. delegate가 기본값 strong이라 화면 → cartView → delegate → 화면 고리가 남는다. delegate를 관례적으로 weak로 선언하는 이유가 바로 이 고리다.', false),
(16074, 5960, 'CartView의 delegate, onFinish의 self 캡처, PaymentManager의 logger 세 곳', '오래 사는 객체를 강하게 가리키기만 해도 문제라고 본 오해. Logger는 누구도 되가리키지 않아 고리가 생기지 않으므로, logger를 바꿔도 화면 해제와는 관계가 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1942, 5961, 'unowned,unowned let,언오운드,미소유 참조,미소유참조,unowned 참조,unowned(safe)', 'unowned로 선언한 참조는 카운트를 올리지 않으므로 고객 → 카드 → 고객으로 이어지던 고리가 끊어져 두 deinit이 모두 호출된다. weak도 카운트를 올리지 않지만 반드시 옵셔널 var여야 해서 비옵셔널 let 그대로 둘 수 없고, 대상이 해제되면 nil이 되어 크래시 대신 조용히 넘어간다. unowned는 대상이 먼저 사라져도 nil로 바뀌지 않아 그 참조를 읽는 순간 즉시 중단된다. 그래서 상대의 수명이 나와 같거나 더 길다고 확신할 때만 쓰고, 확신이 없으면 weak를 쓰는 편이 안전하다.'),
       (1943, 5962, '3,b: 3,b:3', 'in 앞 대괄호의 [count]는 캡처 리스트로, 클로저를 만드는 순간의 값을 복사해 고정한다. b가 만들어질 때 count는 3이었으므로 뒤에서 5로 바뀌어도 b()는 3을 찍는다. 반면 캡처 리스트 없이 만든 a는 변수 자체를 캡처해 실행 시점의 값인 5를 찍는다. 1은 a가 만들어진 시점의 값과 헷갈린 것이고, 5는 캡처 리스트도 변수 자체를 붙잡는다고 본 오해다. [weak self]도 같은 캡처 리스트 문법으로, 값을 고정하는 대신 캡처 방식을 약한 참조로 지정하는 것이다.');
