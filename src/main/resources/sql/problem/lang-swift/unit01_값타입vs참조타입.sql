-- Unit: 값 타입 vs 참조 타입 (Unit ID: 220)
-- Chapter: Swift (Chapter ID: 22)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (646, 220, '쓰기 시 복사와 참조 필드 비용'),
       (804, 220, 'let 불변성과 힙 할당, 고유 참조 검사'),
       (962, 220, 'Swift 값 타입과 참조 타입 — 반복문·프로퍼티 감시자·클로저 캡처로 보는 복사와 공유');

-- =====================================================
-- Lesson 646: 쓰기 시 복사와 참조 필드 비용
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4055, 646, '아래 Swift 코드를 실행했을 때 마지막 print가 출력하는 값은?', '```swift
struct Box { var n: Int }

final class Bag {
    var n: Int
    init(n: Int) { self.n = n }
}

var b1 = Box(n: 1)
var b2 = b1
b2.n = 9

let g1 = Bag(n: 1)
let g2 = g1
g2.n = 9

print(b1.n, g1.n)
```', 'OBJECTIVE'),
       (4056, 646, '아래 실행 로그에 나타난 Swift 배열의 복사 동작에 대한 설명으로 옳은 것은?', '```swift
var a = Array(repeating: 0, count: 1_000_000)
var b = a
b[0] = 1
b[1] = 2
```

각 줄을 실행하면서 두 변수가 쓰는 내부 버퍼의 주소와 그 줄의 소요 시간을 찍은 로그다.

```
[var b = a]  a.buffer=0x1f00  b.buffer=0x1f00  소요 0.000001초
[b[0] = 1]   a.buffer=0x1f00  b.buffer=0x9a40  소요 0.0021초
[b[1] = 2]   a.buffer=0x1f00  b.buffer=0x9a40  소요 0.0000004초
```', 'OBJECTIVE'),
       (4057, 646, '아래 비교표를 바탕으로 판단할 때 옳지 않은 것은?', '같은 데이터를 담는 타입을 struct로 만들 때와 class로 만들 때의 차이를 정리한 표다.

| 기준 | struct | class |
|---|---|---|
| 대입·전달 | 값이 복사되어 서로 독립 | 참조가 복사되어 인스턴스 공유 |
| 상속 | 불가 (프로토콜로 확장) | 가능 (단일 상속) |
| 정체성 비교 | 없음 (=== 사용 불가) | 있음 (===로 같은 인스턴스 판별) |
| 소멸 시점 훅 | 없음 | deinit 사용 가능 |
| 메모리 관리 | 참조 카운팅 없음 (내부 참조 제외) | ARC가 참조 카운트 관리 |', 'OBJECTIVE'),
       (4058, 646, '아래 측정에서 A의 복사 비용이 늘어난 이유로 옳은 것은?', '같은 필드를 가진 두 타입 A(struct)와 B(class)를 각각 100만 번 만들고 버리며 시간을 쟀다. 필드가 Int 두 개뿐일 때는 A가 B보다 눈에 띄게 빨랐다.

그다음 A와 B에 이미지 캐시 객체(class)를 가리키는 프로퍼티를 하나씩 추가하고 같은 측정을 다시 했다. 이번에는 A와 B의 격차가 크게 줄었고, 프로파일러에는 앞선 측정에 없던 런타임 호출 swift_retain이 A의 복사 구간에 새로 잡혔다.', 'OBJECTIVE'),
       (4059, 646, '아래 컴파일 오류를 없애려고 메서드 선언 앞에 덧붙인 키워드는?', '```swift
struct Counter {
    var value = 0

    func increase() {
        value += 1
        // error: cannot assign to property: ''self'' is immutable
    }
}
```

키워드 하나를 func 앞에 덧붙이자 컴파일이 통과했다. 대신 `let cart = Counter()`처럼 상수로 만든 값에서는 `cart.increase()` 호출이 막혔다.', 'SUBJECTIVE'),
       (4060, 646, '아래 코드에서 두 배열을 서로 영향 없게 떼어 놓으려면 필요한 복사 방식의 이름은?', '```swift
final class Tag {
    var name: String
    init(name: String) { self.name = name }
}

var original = [Tag(name: "a"), Tag(name: "b")]
var copied = original
copied[0].name = "z"

print(original[0].name)   // "z"
```

배열 자체는 값 타입이라 `copied`는 `original`과 다른 배열인데도, 원본의 0번 원소까지 함께 바뀌었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4055
(10987, 4055, '1 1', '참조 타입도 대입할 때 인스턴스가 통째로 복사된다고 본 것. g2와 g1은 같은 힙 인스턴스를 가리키므로 g2.n = 9가 g1.n에도 그대로 보인다.', false),
(10988, 4055, '1 9', 'Box는 struct라 var b2 = b1에서 값이 복사돼 b2.n = 9가 b1에 닿지 않고, Bag은 class라 g2와 g1이 같은 인스턴스를 공유해 g1.n이 9가 된다.', true),
(10989, 4055, '9 1', '값 타입과 참조 타입의 동작을 서로 뒤바꿔 본 것. struct 대입은 독립된 복사본을 만들고, class 대입은 같은 인스턴스를 가리키는 참조를 하나 더 만든다.', false),
(10990, 4055, '9 9', 'struct 대입도 참조만 넘긴다고 본 것. b2는 b1과 분리된 복사본이라 b2.n을 9로 바꿔도 b1.n은 1로 남는다.', false),

-- 문제 4056
(10991, 4056, '대입하는 순간 원소 100만 개가 모두 복사되므로, 이 코드에서 가장 비싼 줄은 var b = a이다.', '로그에서 대입은 0.000001초에 끝났고 두 버퍼 주소가 0x1f00으로 같다. 대입은 버퍼를 공유하고 참조 카운트만 올리는 O(1) 연산이다.', false),
(10992, 4056, 'b를 바꿔도 두 변수가 같은 버퍼를 계속 공유하므로 a[0]의 값도 1로 함께 바뀐다.', '참조 타입의 동작을 배열에 갖다 붙인 오개념. 로그의 a.buffer는 0x1f00 그대로라 a는 옛 버퍼를 유지하고, 값 의미론이 지켜져 a[0]은 0으로 남는다.', false),
(10993, 4056, '이 동작은 컴파일러가 모든 struct에 자동으로 넣어 주므로, 직접 만든 struct도 같은 로그를 남긴다.', '언어 기능이 아니라 표준 라이브러리가 isKnownUniquelyReferenced로 구현한 최적화다. 커스텀 struct는 직접 구현하지 않으면 대입하는 순간 전체가 복사된다.', false),
(10994, 4056, '첫 쓰기에서 버퍼를 단독으로 소유하게 되어, 뒤이은 두 번째 쓰기는 복사 없이 제자리에서 끝난다.', '첫 쓰기 때는 버퍼가 공유 중이라 새 버퍼 0x9a40을 만드느라 0.0021초가 들었고, 그 뒤에는 b만 그 버퍼를 참조해 두 번째 쓰기가 0.0000004초로 떨어졌다.', true),

-- 문제 4057
(10995, 4057, '여러 화면이 같은 인스턴스를 함께 들고 상태를 바꿔야 한다면 struct보다 class가 맞다.', '표의 대입·전달 행에서 class는 참조가 복사돼 인스턴스를 공유한다. 한 곳의 변경이 나머지에 곧바로 보여야 하는 요구에 맞으므로 참인 진술이다.', false),
(10996, 4057, '화면이 사라질 때 타이머를 멈추는 정리 코드를 넣어야 하면 class를 골라야 한다.', '표의 소멸 시점 훅 행에 따라 참이다. struct에는 deinit이 없어 인스턴스가 사라지는 순간에 실행할 코드를 걸 자리가 없다.', false),
(10997, 4057, '두 struct 값이 같은 대상을 가리키는지 ===로 확인해 불필요한 복사를 건너뛸 수 있다.', '표의 정체성 비교 행과 어긋나 거짓이다. struct에는 정체성이 없어 ===를 쓸 수 없고, 두 값이 같은지는 ==(Equatable)로만 따진다.', true),
(10998, 4057, '공통 동작을 상위 타입에서 물려받는 계층 구조가 필요하면 struct로는 만들 수 없다.', '표의 상속 행에 따라 참이다. struct는 상속이 불가해 공통 동작은 프로토콜과 그 기본 구현으로 나눠 갖는 방식으로 대신한다.', false),

-- 문제 4058
(10999, 4058, 'A를 복사할 때마다 새로 붙인 프로퍼티가 가리키는 인스턴스의 참조 카운트를 원자적으로 올려야 해서.', '참조 카운팅이 빠지는 것은 값 타입 자신뿐이다. 내부에 참조 타입 프로퍼티를 두면 복사마다 그 참조를 retain해야 해서 값 타입의 비용 이점이 줄어든다.', true),
(11000, 4058, 'A가 복사될 때 그 프로퍼티가 가리키는 인스턴스까지 통째로 새로 만들어 복사해서.', '값 타입 복사는 참조 자체만 옮기는 얕은 복사다. 대상 인스턴스를 새로 만들지 않으므로 복사본끼리 같은 이미지 캐시 객체를 공유한다.', false),
(11001, 4058, 'A의 크기가 3워드를 넘어서면서 대입할 때마다 힙에 박싱되어서.', '3워드 인라인 버퍼 한도는 값을 프로토콜 타입(existential)에 담을 때 적용되는 규칙이다. A를 선언된 타입 그대로 쓰는 한 크기 때문에 박싱되지는 않는다.', false),
(11002, 4058, 'A가 struct라도 참조 타입 프로퍼티를 가지면 A 전체가 class처럼 ARC 관리 대상이 되어서.', 'A 자신은 여전히 값 타입이라 수명이 스코프로 정해지고 참조 카운트를 갖지 않는다. ARC가 세는 것은 프로퍼티가 가리키는 클래스 인스턴스뿐이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1308, 4059, 'mutating,뮤테이팅', '값 타입의 메서드는 기본적으로 self를 불변으로 보기 때문에 프로퍼티에 대입하려면 mutating을 붙여 self를 바꿀 수 있는 상태로 선언해야 한다. 이 키워드가 붙는 순간 그 메서드는 var로 선언한 값에서만 호출할 수 있어, let 상수에서는 호출이 막힌다. class에는 이 키워드가 없다. 참조 타입은 let으로 선언해도 참조만 고정될 뿐 프로퍼티 변경은 자유롭기 때문이다. 프로퍼티 감시자를 뜻하는 willSet·didSet과는 역할이 다르다.'),
       (1309, 4060, '깊은 복사,깊은복사,deep copy,deepcopy,딥 카피,딥카피', '배열 대입은 원소가 들고 있는 참조까지만 복사하는 얕은 복사(shallow copy)라, 원소가 class면 두 배열이 같은 인스턴스를 가리킨다. 원소마다 새 인스턴스를 만들어 값을 옮기는 깊은 복사를 해야 두 배열이 완전히 분리된다. Swift는 깊은 복사를 자동으로 제공하지 않아 NSCopying 채택이나 복제 메서드를 직접 만들어야 한다. Copy-on-Write와 헷갈리기 쉬운데, 그쪽은 배열 버퍼의 복사를 쓰기 시점까지 미루는 최적화일 뿐 원소 인스턴스를 새로 만들어 주지는 않는다.');

-- =====================================================
-- Lesson 804: let 불변성과 힙 할당, 고유 참조 검사
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5003, 804, '아래 Swift 코드에서 마지막 줄의 출력은?', '```swift
struct Theme { var color: String }

final class Account {
    var user: String
    init(user: String) { self.user = user }
}

struct Config {
    var theme: Theme
    var account: Account
}

var c1 = Config(theme: Theme(color: "light"), account: Account(user: "kim"))
var c2 = c1

c2.theme.color = "dark"
c2.account.user = "lee"

print(c1.theme.color, c1.account.user)
```', 'OBJECTIVE'),
       (5004, 804, '아래 측정 결과에 대한 설명으로 옳은 것은?', 'Double 프로퍼티 6개를 가진 struct Report를 네 가지 방식으로 담아 10만 번 만들고 버리면서, 인스턴스 하나당 일어난 힙 할당 횟수를 셌다. Double 하나는 8바이트라 Report의 크기는 48바이트이고, Summarizable은 Report가 채택한 프로토콜이다.

이 런타임은 프로토콜 타입 변수에 값을 담을 때, 값이 24바이트 이하이면 변수 안의 인라인 버퍼에 그대로 두고 24바이트를 넘으면 힙에 상자를 따로 만들어 옮겨 담는다.

| 담는 방식 | 선언 | 인스턴스당 힙 할당 |
|---|---|---|
| 1. 변수에 그대로 | var r = Report() | 0회 |
| 2. 프로토콜 타입에 담기 | var p: Summarizable = Report() | 1회 |
| 3. class 프로퍼티로 담기 | final class Holder { var r = Report() } | 1회 |
| 4. 빈 class 만들기 | final class Empty {} | 1회 |', 'OBJECTIVE'),
       (5005, 804, '아래 진단 메시지가 두 번째 클로저에서만 나온 이유로 옳은 것은?', '```swift
struct CartValue { var items: [String] = [] }
final class CartRef { var items: [String] = [] }

func handOff(_ v: CartValue, _ r: CartRef) {
    Task.detached { print(v.items.count) }   // 경고 없음
    Task.detached { print(r.items.count) }   // 아래 경고
}
```

```
warning: capture of ''r'' with non-sendable type ''CartRef'' in a ''@Sendable'' closure
```', 'OBJECTIVE'),
       (5006, 804, '아래 코드에서 컴파일 오류가 나는 대입을 모두 고른 것은?', '```swift
struct Size { var width = 0 }
final class Canvas { var width = 0 }

let s = Size()
var t = Size()
let c = Canvas()
let list = [Size()]

s.width = 10          // ㄱ
t.width = 10          // ㄴ
c.width = 10          // ㄷ
list[0].width = 10    // ㄹ
```', 'OBJECTIVE'),
       (5007, 804, '아래 빈칸에 들어갈 표준 라이브러리 함수의 이름은?', '```swift
final class Storage { var data: [Int] = [] }

struct Buffer {
    private var storage = Storage()

    mutating func append(_ x: Int) {
        if !____(&storage) {
            let fresh = Storage()
            fresh.data = storage.data
            storage = fresh
        }
        storage.data.append(x)
    }
}
```

빈칸에 함수 하나를 채우자, 원소 100만 개를 담은 Buffer를 `var b = a`로 넘긴 뒤 b에만 append해도 a의 내용은 그대로 남았고 대입 자체는 0.000001초에 끝났다. 반대로 빈칸이 있는 줄을 지우고 append마다 늘 새 Storage를 만들게 바꾸면, 결과는 같지만 append 한 번마다 100만 개가 통째로 복사됐다.', 'SUBJECTIVE'),
       (5008, 804, '아래 빈칸에 들어갈 선언 키워드는?', '화면이 닫힐 때 소켓을 닫아 주려고 만든 타입이다. struct로 두었을 때는 정리 코드를 걸 자리가 없어, 화면을 스무 번 열고 닫자 열린 소켓이 20개로 쌓였다. 타입을 class로 바꾸고 아래 빈칸 자리에 블록을 하나 추가하자 화면을 닫을 때마다 로그에 closed가 한 줄씩 찍혔고, 열린 소켓 수는 1개를 넘지 않았다.

```swift
final class RoomScreen {
    let socket = Socket()

    ____ {
        socket.close()
        print("closed")
    }
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5003
(13515, 5003, 'light kim', 'Config를 복사할 때 account가 가리키는 인스턴스까지 새로 만들어진다고 본 것. 값 타입 복사는 참조를 그대로 옮기는 얕은 복사라 c1.account와 c2.account는 같은 인스턴스다.', false),
(13516, 5003, 'light lee', 'theme은 값 타입이라 c2 쪽 변경이 c1에 닿지 않고, account는 참조가 복사돼 두 Config가 같은 인스턴스를 공유하므로 user 변경이 c1에도 보인다.', true),
(13517, 5003, 'dark kim', '값 타입과 참조 타입의 동작을 서로 뒤바꿔 본 것. 중첩된 struct는 복사본이 독립이고, 참조 프로퍼티는 복사 뒤에도 같은 대상을 가리킨다.', false),
(13518, 5003, 'dark lee', 'var c2 = c1이 참조만 넘겨 Config 전체가 공유된다고 본 것. Config는 struct라 theme은 c2 쪽에서만 dark가 되고 c1은 light로 남는다.', false),

-- 문제 5004
(13519, 5004, 'Report는 struct라 어떤 방식으로 담아도 스택에만 놓이며, 2·3번의 1회는 측정 도구가 끼워 넣은 부가 객체를 센 값이다.', 'struct는 스택이라는 경향을 규칙으로 굳힌 오개념. 2번은 48바이트짜리 값을 옮겨 담으려고 만든 힙 상자이고, 3번은 4번과 같은 이유로 Holder 인스턴스 자체가 힙에 잡힌 것이다.', false),
(13520, 5004, '2번에서 Report가 프로토콜을 채택하는 순간 참조 타입이 되므로, p를 다른 변수에 대입하면 둘이 같은 인스턴스를 공유한다.', '프로토콜 채택은 값 의미론을 바꾸지 않는다. p를 대입하면 담긴 값이 복사돼 서로 독립이고, 대입만으로 같은 인스턴스를 공유하는 것은 class 같은 참조 타입이다.', false),
(13521, 5004, 'Double 프로퍼티를 2개로 줄이면 Report가 인라인 버퍼 안에 들어가므로, 2번과 3번의 힙 할당이 나란히 0회가 된다.', '인라인 버퍼 기준은 본문에서 프로토콜 타입에 담을 때의 규칙으로 못 박혀 있다. 3번의 1회는 프로퍼티가 하나도 없는 4번에서도 똑같이 나오므로 Report 크기가 아니라 Holder 인스턴스를 만드는 비용이다.', false),
(13522, 5004, 'Double 프로퍼티를 2개로 줄이면 2번의 힙 할당은 0회가 되지만, 3번은 1회 그대로다.', 'Double 2개는 16바이트라 24바이트 이하 조건을 채워 상자 없이 인라인 버퍼에 담기므로 2번은 0회가 된다. 3번의 1회는 4번과 마찬가지로 Holder 인스턴스를 힙에 만드는 비용이라 담긴 값의 크기와 무관하다.', true),

-- 문제 5005
(13523, 5005, 'v는 복사본이 넘어가 공유가 없지만, r은 같은 인스턴스를 여러 작업이 동시에 건드릴 수 있어서.', '값 타입은 경계를 넘을 때 복사본이 전달돼 동시 변경이 서로 닿지 않으니 대부분 자동으로 Sendable이 된다. 참조 타입은 같은 인스턴스를 공유해 동기화 장치 없이는 안전하다고 인정받지 못한다.', true),
(13524, 5005, 'CartValue는 프로퍼티가 배열 하나뿐이라 복사 비용이 거의 들지 않아서.', '크기나 복사 비용은 이 진단의 기준이 아니다. 프로퍼티가 많은 struct도 구성 요소가 모두 안전하면 경고가 없고, 프로퍼티가 하나뿐인 class는 그대로 경고가 난다.', false),
(13525, 5005, 'CartRef가 상속 가능한 클래스라 하위 타입 인스턴스가 대신 넘어올 수 있어서.', '코드의 CartRef는 final이라 하위 타입이 있을 수 없다. 상속 가능 여부와 상관없이 가변 프로퍼티를 가진 클래스는 공유 때문에 경고 대상이 된다.', false),
(13526, 5005, 'CartValue는 struct라 컴파일러가 접근할 때마다 자동으로 락을 걸어 주기 때문에.', '컴파일러는 값 타입에 락을 걸지 않는다. 넘어간 쪽이 따로 복사본을 들고 있어 잠글 공유 대상 자체가 없다는 것이 차이다.', false),

-- 문제 5006
(13527, 5006, 'ㄱ', 'ㄱ에서 멈춘 것. 배열도 값 타입이라 let으로 묶인 list는 원소에 값을 넣는 subscript 대입까지 막혀 ㄹ도 오류다.', false),
(13528, 5006, 'ㄱ, ㄷ', 'let으로 선언한 클래스 인스턴스는 프로퍼티까지 잠긴다고 본 것. let은 c가 가리키는 대상만 고정하므로 var 프로퍼티인 width 변경은 통과한다.', false),
(13529, 5006, 'ㄱ, ㄹ', '값 타입은 let으로 묶으면 내부 프로퍼티까지 불변이라 ㄱ이 막히고, 배열 역시 값 타입이라 let list의 원소를 바꾸는 대입도 막힌다. ㄴ은 var 값이라, ㄷ은 참조만 고정된 것이라 통과한다.', true),
(13530, 5006, 'ㄱ, ㄷ, ㄹ', '값 타입이든 참조 타입이든 let이면 내부까지 얼어붙는다고 본 것. ㄷ의 Canvas는 class라 참조가 고정돼도 그 인스턴스의 프로퍼티는 바꿀 수 있다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1624, 5007, 'isKnownUniquelyReferenced,isKnownUniquelyReferenced(_:)', '버퍼를 나 혼자만 참조하고 있는지 런타임에 물어보는 함수가 isKnownUniquelyReferenced(_:)다. 참조가 하나뿐이면 복사를 건너뛰고 제자리에서 고치고, 다른 곳과 공유 중일 때만 새 Storage를 만들어 값 의미론을 지킨다. 그래서 대입은 참조 카운트만 올리는 O(1)로 끝나고 복사 비용은 실제로 쓰는 순간까지 미뤄진다. 이것이 Array·Dictionary·String이 쓰는 Copy-on-Write의 구현 방식인데, 언어가 모든 struct에 자동으로 넣어 주는 기능이 아니라서 직접 만든 값 타입에는 이렇게 손으로 넣어야 한다. 반환값은 참조가 유일한지에 대한 판정뿐이라 참조 카운트 값을 읽어 오는 도구가 아니며, 인자는 반드시 inout(&)으로 넘긴 저장 프로퍼티여야 한다. 참조 카운트를 올리지 않고 대상을 가리키는 weak·unowned와는 역할이 다르다.'),
       (1625, 5008, 'deinit,디이닛,소멸자,deinitializer', '인스턴스를 마지막으로 가리키던 참조가 사라져 ARC가 메모리를 회수하기 직전에 한 번 실행되는 블록이 deinit이다. 소켓·타이머·옵저버처럼 인스턴스 바깥에 남는 자원을 여기서 정리한다. 이 선언은 class에만 있고 struct·enum에는 없다. 값 타입은 정체성이 없어 복사본마다 사라지는 시점이 제각각이라 회수 순간을 붙잡을 자리가 없기 때문이며, 이 점이 struct 대신 class를 고르는 대표적인 이유 가운데 하나다. 인스턴스를 만들 때 실행되는 init과 짝을 이루지만 직접 호출할 수 없고 인자도 받지 않는다. 두 인스턴스가 서로를 강하게 가리키는 순환 참조가 있으면 참조 카운트가 0이 되지 않아 아예 실행되지 않으니, 정리 코드가 돌지 않으면 순환 참조부터 의심해야 한다.');

-- =====================================================
-- Lesson 962: Swift 값 타입과 참조 타입 — 반복문·프로퍼티 감시자·클로저 캡처로 보는 복사와 공유
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5951, 962, '아래 Swift 코드를 실행했을 때 마지막 print가 출력하는 값은?', '```swift
struct Stock { var count: Int }

final class Slot {
    var count: Int
    init(count: Int) { self.count = count }
}

var stocks = [Stock(count: 0), Stock(count: 0)]
let slots = [Slot(count: 0), Slot(count: 0)]

for var s in stocks { s.count += 1 }
for s in slots { s.count += 1 }

print(stocks[0].count, slots[0].count)
```', 'OBJECTIVE'),
       (5952, 962, '아래 코드를 실행했을 때 콘솔에 찍히는 줄을 순서대로 나열한 것은?', '```swift
struct Profile { var name: String; var age: Int }

final class Session { var name = "kim" }

struct AppState {
    var profile = Profile(name: "kim", age: 20) {
        didSet { print("profile") }
    }
    var session = Session() {
        didSet { print("session") }
    }
}

var state = AppState()
state.profile.name = "lee"
state.profile.age = 21
state.session.name = "lee"
```', 'OBJECTIVE'),
       (5953, 962, '아래 코드의 출력과 그 이유로 옳은 것은?', '```swift
func makePair() -> (inc: () -> Void, get: () -> Int) {
    var count = 0          // Int, 값 타입
    return ({ count += 1 }, { count })
}

let pair = makePair()      // 여기서 makePair의 실행은 이미 끝났다
pair.inc()
pair.inc()
print(pair.get())
```', 'OBJECTIVE'),
       (5954, 962, '아래 세 요구 사항에 맞춰 고른 타입 종류의 조합으로 옳은 것은?', '쇼핑 앱에서 새로 만들 타입 세 개의 요구 사항이다.

- (가) 결제 화면 상태: 대기·진행 중·완료(영수증 번호)·실패(에러 메시지) 가운데 언제나 정확히 하나만 가진다. 완료인데 에러 메시지가 함께 들어 있는 조합은 아예 만들어질 수 없어야 한다.
- (나) 로그인 세션: 어느 화면에서 토큰을 갱신하면 다른 모든 화면이 곧바로 새 토큰을 봐야 하고, 세션이 메모리에서 사라질 때 열어 둔 소켓을 닫아야 한다.
- (다) 서버에서 받은 상품 정보: id·이름·가격을 담는다. 여러 화면에 넘겨도 한 화면에서 고친 가격이 다른 화면으로 번지면 안 되고, 필드가 모두 같으면 같은 상품으로 본다.', 'OBJECTIVE'),
       (5955, 962, '아래 코드의 빈칸 두 곳에 공통으로 들어갈 연산자는?', '```swift
final class Player {
    var name: String
    init(name: String) { self.name = name }
}

extension Player: Equatable {
    static func == (l: Player, r: Player) -> Bool { l.name == r.name }
}

let a = Player(name: "kim")
let b = Player(name: "kim")
let c = a

print(a == b, a == c)       // true true
print(a ____ b, a ____ c)   // false true
```

같은 연산자를 `struct Point { var x = 0 }`의 두 값 사이에 쓰자 컴파일 오류가 났다.', 'SUBJECTIVE'),
       (5956, 962, '아래 측정에서 드러난 표준 라이브러리 컬렉션의 최적화 기법 이름은?', '10MB짜리 `[UInt8]` 배열 data를 만든 뒤, 이를 프로퍼티로 담은 struct 값 Packet을 1,000개 만들어 배열 packets에 넣었다.

```swift
for _ in 0..<1_000 { packets.append(Packet(payload: data)) }
packets[7].payload[0] = 0xFF
```

| 시점 | 프로세스 메모리 |
|---|---|
| data 생성 직후 | 약 10MB |
| Packet 1,000개 생성 직후 | 약 10MB |
| packets[7].payload[0] 수정 직후 | 약 20MB |

수정 뒤에도 data와 나머지 999개 Packet의 첫 바이트는 그대로였다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5951
(16043, 5951, '0 0', 'for-in이 꺼낸 원소는 무엇이든 복사본이라고 본 것. Slot은 class라 s에 담긴 것은 참조이고, 그 참조로 바꾼 count는 배열이 가리키는 바로 그 인스턴스에 반영된다.', false),
(16044, 5951, '0 1', 'Stock은 struct라 for var s가 원소의 복사본을 꺼내 s만 바뀌고 stocks는 그대로다. Slot은 class라 s가 원소와 같은 인스턴스를 가리켜 slots[0].count가 1이 된다.', true),
(16045, 5951, '1 0', '값 타입과 참조 타입의 동작을 뒤바꿔 본 것. struct 원소는 꺼내는 순간 복사돼 원본과 떨어지고, class 원소는 참조만 꺼내져 원본 인스턴스를 그대로 바꾼다.', false),
(16046, 5951, '1 1', 'for var s로 꺼내면 원소 자리에 바로 쓴다고 본 것. var는 복사본을 고칠 수 있게 할 뿐이라 원본을 바꾸려면 stocks.indices로 돌며 stocks[i].count를 고쳐야 한다.', false),

-- 문제 5952
(16047, 5952, 'profile, profile, session', '참조 타입 프로퍼티의 내부 변경도 감지된다고 본 것. session.name을 바꿔도 session이 가리키는 참조는 그대로라 session 프로퍼티에는 쓰기가 일어나지 않는다.', false),
(16048, 5952, 'session', '값 타입 내부 필드 변경은 감지되지 않는다고 뒤바꿔 본 것. struct의 필드 하나를 바꾸면 바깥 프로퍼티 전체가 새 값으로 바뀐 것으로 취급돼 didSet이 불린다.', false),
(16049, 5952, 'profile, profile', 'Profile은 값 타입이라 name·age를 바꿀 때마다 profile 전체가 새 값으로 쓰여 didSet이 두 번 불린다. Session은 참조 타입이라 name을 바꿔도 참조는 그대로여서 session의 didSet은 불리지 않는다.', true),
(16050, 5952, 'profile, session', '같은 프로퍼티를 연달아 바꾸면 한 번으로 합쳐진다고 보고, 참조 타입 내부 변경도 감지된다고 본 것. 대입마다 따로 불리므로 profile이 두 번 찍히고 session은 찍히지 않는다.', false),

-- 문제 5953
(16051, 5953, '0 — 두 클로저가 캡처하는 순간의 count를 각자 복사해 따로 들고 있어서', '캡처 리스트 없이 캡처한 변수는 복사되지 않는다. 두 클로저가 같은 변수를 공유하므로 inc가 올린 값을 get도 그대로 읽는다.', false),
(16052, 5953, '2 — count가 스택에 그대로 남아 있고 두 클로저가 그 스택 주소를 가리켜서', 'struct·Int는 스택이라는 경향을 규칙으로 굳힌 오개념. makePair의 스택 프레임은 이미 사라졌으므로 스택 주소를 붙잡고 있을 수 없다.', false),
(16053, 5953, '2 — 캡처되는 순간 count가 참조 타입으로 바뀌어 ARC가 관리해서', 'count의 타입은 끝까지 Int, 즉 값 타입이다. 힙에 옮겨지는 것은 저장 위치일 뿐 타입의 의미론이 참조 타입으로 바뀌는 것이 아니다.', false),
(16054, 5953, '2 — 두 클로저가 힙으로 옮겨진 같은 count 하나를 함께 가리켜서', '클로저가 캡처한 지역 변수는 함수가 끝나도 살아 있어야 하므로 힙의 상자로 옮겨진다. 두 클로저가 그 상자 하나를 공유해 inc 두 번의 결과를 get이 읽는다.', true),

-- 문제 5954
(16055, 5954, '(가) enum, (나) class, (다) struct', '정해진 경우 중 하나만 갖고 경우마다 다른 값이 붙는 (가)는 연관값 enum, 공유와 소멸 시 정리가 필요한 (나)는 class, 독립 복사와 값 비교가 맞는 (다)는 struct다.', true),
(16056, 5954, '(가) enum, (나) struct, (다) class', '(나)·(다)를 뒤바꾼 것. struct는 복사본끼리 독립이고 deinit이 없어 (나)의 공유·소켓 정리를 못 하고, class는 인스턴스를 공유해 (다)에서 가격 변경이 다른 화면으로 번진다.', false),
(16057, 5954, '(가) struct, (나) class, (다) class', '(가)를 옵셔널 필드 여러 개의 struct로 두면 완료+에러 같은 모순 조합을 막을 수 없다. (다)도 class면 같은 인스턴스를 공유해 한 화면의 수정이 다른 화면에 보인다.', false),
(16058, 5954, '(가) class, (나) struct, (다) struct', '(가)를 class로 해도 모순 조합이 막히지 않는다. (나)를 struct로 두면 화면마다 복사본을 들어 갱신된 토큰이 퍼지지 않고, 사라질 때 소켓을 닫을 deinit도 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1940, 5955, '===,항등 연산자,항등연산자,identity operator', '===는 두 참조가 힙의 같은 인스턴스를 가리키는지를 따지는 항등 연산자다. a와 b는 이름이 같아 ==(Equatable)로는 true지만 서로 다른 인스턴스라 false이고, c는 a의 참조를 복사한 것이라 true가 나온다. 이 연산자는 정체성이 있는 참조 타입(class·actor)에만 쓸 수 있다. struct 같은 값 타입은 정체성이 없고 값이 같으면 같은 것으로 보기 때문에 ===가 컴파일 오류를 내고, 같음은 ==로만 따진다. 내용이 같은지를 묻는 ==(동등성)와, 같은 대상인지를 묻는 ===(정체성)를 구분하는 것이 핵심이다.'),
       (1941, 5956, 'Copy-on-Write,copy on write,copyonwrite,COW,쓰기 시 복사,쓰기시 복사,쓰기 시 복제,카피 온 라이트', '표준 라이브러리의 Array·Dictionary·Set·String은 대입할 때 내부 버퍼의 참조만 공유하고 참조 카운트만 올린다. 그래서 Packet 1,000개를 만들어도 메모리가 10MB 그대로였다. 공유 중인 버퍼에 처음 쓰기가 일어나는 순간에만 그 값의 버퍼를 새로 복사하므로 packets[7] 수정 때 10MB가 늘었고, 나머지 값은 원래 버퍼를 계속 보며 값 의미론이 지켜졌다. 이것이 Copy-on-Write다. 언어가 모든 struct에 넣어 주는 기능이 아니라 표준 라이브러리가 isKnownUniquelyReferenced로 구현한 최적화라, 직접 만든 struct는 스스로 구현해야 한다. 원소 인스턴스까지 새로 만드는 깊은 복사와도 다르다.');
