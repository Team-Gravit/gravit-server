-- Unit: 프로토콜 지향 프로그래밍 (Unit ID: 223)
-- Chapter: Swift (Chapter ID: 22)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (649, 223, '확장 디스패치와 실존 컨테이너, 타입 소거'),
       (807, 223, '메시지 디스패치와 위트니스 테이블'),
       (965, 223, '프로토콜 설계의 함정과 existential 다루기');

-- =====================================================
-- Lesson 649: 확장 디스패치와 실존 컨테이너, 타입 소거
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4073, 649, '아래 코드를 실행했을 때 출력되는 두 줄을 순서대로 나열한 것은?', '```swift
protocol Vehicle {
    func move() -> String
}

extension Vehicle {
    func move() -> String { "기본 이동" }
    func stop() -> String { "기본 정지" }
}

struct Car: Vehicle {
    func move() -> String { "자동차 주행" }
    func stop() -> String { "자동차 정지" }
}

let v: Vehicle = Car()
print(v.move())
print(v.stop())
```', 'OBJECTIVE'),
       (4074, 649, '아래 비교표를 바탕으로 판단할 때 옳지 않은 것은?', '| 기준 | 클래스 상속 | 프로토콜 + 확장 |
|---|---|---|
| 적용 타입 | 클래스만 | struct·enum·class 모두 |
| 다중 조합 | 불가 (단일 상속) | 여러 프로토콜 동시 채택 |
| 저장 프로퍼티 공유 | 가능 | 불가 — 확장은 계산 프로퍼티만 추가 |
| 동작 재정의 | override (vtable) | 요구사항만 재정의 가능 (위트니스 테이블) |
| 테스트 대역 만들기 | 서브클래스 필요, final이면 불가 | 프로토콜 채택만으로 가능 |', 'OBJECTIVE'),
       (4075, 649, '아래 값 보관 방식에 대한 설명으로 옳은 것은?', '프로토콜을 값의 타입으로 선언하면(예: `let g: Greeter = Korean()`) 컴파일러는 그 자리에 어떤 구체 타입이 올지 알 수 없다. 그래서 값을 3워드 크기의 값 버퍼와 타입 메타데이터, 위트니스 테이블 포인터로 이루어진 컨테이너에 담아 다룬다.', 'OBJECTIVE'),
       (4076, 649, '아래 코드에 이어 붙였을 때 컴파일 오류 없이 실행되는 호출은?', '```swift
protocol Container {
    associatedtype Item
    var items: [Item] { get }
    func summary() -> String
}

extension Container {
    func summary() -> String { "항목 \(items.count)개" }
}

extension Container where Item: Numeric {
    func total() -> Item { items.reduce(0, +) }
}

struct Cart: Container { let items: [Int] }
struct Tags: Container { let items: [String] }
```', 'OBJECTIVE'),
       (4077, 649, '아래에서 두 저장소를 한 배열에 담기 위해 쓴 기법의 이름은?', '```swift
protocol Storage {
    associatedtype Item
    func save(_ item: Item)
}

struct MemoryStorage: Storage { func save(_ item: String) { print("메모리:", item) } }
struct DiskStorage: Storage   { func save(_ item: String) { print("디스크:", item) } }
```

`let list: [Storage] = [MemoryStorage(), DiskStorage()]`로 두 저장소를 함께 담으려 하자 **Protocol ''Storage'' can only be used as a generic constraint** 오류가 났다. 아래 래퍼를 하나 만들어 담자 오류 없이 컴파일됐고, forEach로 두 구현을 똑같이 호출할 수 있었다. 표준 라이브러리의 AnyHashable·AnySequence, Combine의 AnyPublisher도 같은 방식으로 만들어진 타입이다.

```swift
struct AnyStorage<Item>: Storage {
    private let _save: (Item) -> Void
    init<S: Storage>(_ base: S) where S.Item == Item { _save = base.save }
    func save(_ item: Item) { _save(item) }
}

let list: [AnyStorage<String>] = [AnyStorage(MemoryStorage()), AnyStorage(DiskStorage())]
list.forEach { $0.save("data") }
```', 'SUBJECTIVE'),
       (4078, 649, '아래 벤치마크에서 실행 시간이 31ms로 줄어든 쪽의 draw() 호출에 적용된 메서드 디스패치 방식의 이름은?', '같은 모듈 안에서 한 번도 재정의된 적이 없는 draw()를 1,000만 번 호출한 벤치마크다. 선언만 바꾸고 나머지 코드는 그대로 두었다.

| 선언 | 실행 시간 | 생성된 기계어에서 관찰된 것 |
|---|---|---|
| `class Renderer { func draw() { ... } }` | 82ms | 객체가 가리키는 표를 한 번 읽어 주소를 얻은 뒤 호출 |
| `final class Renderer { func draw() { ... } }` | 31ms | 호출 명령 자체가 사라지고 draw()의 본문이 그 자리에 펼쳐짐 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4073
(11035, 4073, '기본 이동 / 기본 정지', '프로토콜 타입 변수로 부르면 무조건 확장의 구현이 실행된다고 본 오개념. move()는 프로토콜 본문에 선언된 요구사항이라 위트니스 테이블을 거쳐 Car가 직접 쓴 구현이 실행된다.', false),
(11036, 4073, '자동차 주행 / 자동차 정지', '두 메서드 모두 채택 타입의 구현으로 덮인다고 본 오개념. stop()은 프로토콜 본문에 없는 확장 전용 메서드라, 변수의 정적 타입인 Vehicle의 구현으로 컴파일 시점에 고정된다.', false),
(11037, 4073, '자동차 주행 / 기본 정지', 'move()는 요구사항이라 위트니스 테이블에서 실제 타입 Car의 구현이 선택되고, stop()은 요구사항이 아니어서 테이블에 항목이 없으므로 Vehicle 확장의 구현이 그대로 불린다.', true),
(11038, 4073, '기본 이동 / 자동차 정지', '요구사항과 확장 전용 메서드의 동작을 정반대로 본 오개념. 채택 타입의 재정의가 반영되는 쪽은 프로토콜 본문에 선언된 move()이고, 고정되는 쪽이 stop()이다.', false),

-- 문제 4074
(11039, 4074, 'struct로 만든 타입도 부모를 하나 골라 상속하면 공통 저장 프로퍼티를 물려받을 수 있다.', '거짓이라 정답. 적용 타입 행대로 상속은 클래스만 되는 장치여서 struct는 부모를 고르는 일 자체가 불가능하고, 그래서 저장 프로퍼티를 물려받을 길도 없다.', true),
(11040, 4074, '한 타입에 나는 능력과 헤엄치는 능력을 함께 부여해야 한다면 상속 계층보다 프로토콜 채택이 맞다.', '참인 진술. 단일 상속은 부모를 하나만 고를 수 있어 능력이 늘수록 계층이 꼬이지만, 프로토콜은 여러 개를 동시에 채택해 필요한 능력만 골라 붙일 수 있다.', false),
(11041, 4074, '여러 타입이 같은 상태를 나눠 가져야 한다면 프로토콜 확장만으로는 안 되고 공통 구조체를 프로퍼티로 두는 식의 조합이 필요하다.', '참인 진술. 확장은 계산 프로퍼티만 추가할 수 있어 값을 들고 있을 자리를 만들지 못하므로, 상태 공유는 공통 구조체를 품는 컴포지션으로 푼다.', false),
(11042, 4074, 'final로 선언된 네트워크 클라이언트라도 프로토콜로 추상화해 두면 테스트에서 가짜 구현으로 갈아끼울 수 있다.', '참인 진술. final 클래스는 서브클래싱이 막혀 대역을 못 만들지만, 같은 프로토콜을 채택한 별도 타입을 만들면 주입 지점의 구현만 바꿔 끼울 수 있다.', false),

-- 문제 4075
(11043, 4075, '서로 다른 구체 타입의 값을 하나의 배열에 섞어 담을 수 없다.', '이 방식의 가장 큰 이점이 오히려 이질적인 타입을 [Greeter]처럼 한 배열에 담아 균일하게 호출하는 것이다. 섞어 담지 못하는 쪽은 타입이 하나로 고정되는 제네릭 제약이다.', false),
(11044, 4075, '값 버퍼보다 큰 값을 넣어도 힙 할당 없이 버퍼 안에 그대로 들어간다.', '버퍼 크기가 3워드로 고정이라 그보다 큰 값은 힙에 따로 할당하고 포인터만 버퍼에 넣는 박싱이 일어난다. 이 박싱이 비용의 한 축이다.', false),
(11045, 4075, '담긴 값의 실제 타입은 런타임에도 확인할 수 없다.', '타입 메타데이터를 함께 들고 있어 실제 타입을 런타임에 알 수 있고, 그래서 as? 캐스팅이 동작한다. 컴파일러가 미리 모른다는 것과 런타임에 모른다는 것은 다른 이야기다.', false),
(11046, 4075, '구체 타입이 고정되지 않아 특수화 최적화를 받지 못하고 호출이 간접 호출로 남는다.', '제네릭 제약으로 쓰면 컴파일러가 타입별로 코드를 따로 찍어내 직접 호출로 바꿀 수 있지만, 이 방식은 호출 대상을 테이블로 찾아가야 해 그 최적화를 적용할 수 없다.', true),

-- 문제 4076
(11047, 4076, 'Tags(items: ["swift", "pop"]).total()', 'Tags의 Item은 String이라 where Item: Numeric 조건을 만족하지 못한다. 조건부 확장의 기능은 조건을 만족하는 채택 타입에만 붙으므로 total()은 아예 제공되지 않는다.', false),
(11048, 4076, 'Cart(items: [10, 20]).total()', 'Cart의 Item이 Int라 Numeric 조건을 만족해 조건부 확장의 total()이 그대로 제공된다. reduce로 더해 30이 나온다.', true),
(11049, 4076, 'Cart(items: [10, 20]).items.total()', 'total()은 Container를 채택한 타입에 붙은 기능이지 [Int] 배열 자체에 붙은 것이 아니다. 확장이 누구를 대상으로 선언됐는지 혼동한 경우다.', false),
(11050, 4076, 'Container(items: [10, 20]).summary()', '프로토콜은 요구사항 목록일 뿐이라 그 자체로 인스턴스를 만들 수 없다. 게다가 Container는 associatedtype을 가져 구체 타입이 정해져야 의미가 생긴다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1314, 4077, '타입 소거,타입소거,타입 이레이저,타입이레이저,type erasure,type-erasure,typeerasure', 'AnyStorage는 초기화 때 받은 구체 타입 S를 클로저 안에 가둬 두고 밖으로는 Item만 드러낸다. 이렇게 구체 타입 정보를 버리고 하나의 구체 래퍼 타입으로 통일하는 기법이 타입 소거이며, associatedtype이나 Self를 쓰는 프로토콜을 값의 타입처럼 다뤄야 할 때 등장한다. 옆 개념과 경계를 그어 두자. 제네릭 제약(<S: Storage>)은 구체 타입을 그대로 유지한 채 컴파일 시점에 특수화하므로 성능은 유리하지만 서로 다른 타입을 한 배열에 담지 못한다. Swift 5.7의 기본 연관 타입을 선언하면 any Storage<String>으로 래퍼 없이 같은 일을 할 수 있어, 지금은 API에서 구체 타입을 감추거나 구버전을 지원할 때 주로 쓴다.'),
       (1315, 4078, '정적 디스패치,정적디스패치,스태틱 디스패치,static dispatch,직접 디스패치,다이렉트 디스패치,direct dispatch', 'final을 붙이면 재정의될 가능성이 사라져 컴파일러가 호출 대상을 컴파일 시점에 확정할 수 있고, 그 결과 인라이닝까지 이뤄져 호출 명령 자체가 없어진다. 이것이 정적(직접) 디스패치다. final이 없던 쪽에서 표를 한 번 읽던 동작은 vtable을 조회하는 테이블 디스패치이고, @objc dynamic을 붙였을 때 셀렉터로 메서드를 찾아가는 방식은 메시지 디스패치다. 값 타입의 메서드와 프로토콜 확장 전용 메서드도 정적 디스패치 대상이며, Whole Module Optimization이 켜져 있으면 컴파일러가 모듈 안에서 재정의가 없는 클래스를 final처럼 취급해 같은 최적화를 적용하기도 한다.');

-- =====================================================
-- Lesson 807: 메시지 디스패치와 위트니스 테이블
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5021, 807, '아래 메서드 디스패치 방식에 대한 설명으로 옳은 것은?', 'Swift 메서드 선언에 `@objc dynamic`을 붙이면 그 메서드의 호출은 Objective-C 런타임으로 넘어간다. 호출 주소가 컴파일 시점에 정해지지 않고, 실행 시점에 메서드 이름인 셀렉터로 구현을 찾아 들어간다.', 'OBJECTIVE'),
       (5022, 807, '아래 코드의 반복문이 출력하는 두 줄을 순서대로 나열한 것은?', '```swift
protocol Animal {
    func speak() -> String
}
extension Animal {
    func speak() -> String { "동물 소리" }
}

protocol Pet: Animal { }
extension Pet {
    func speak() -> String { "반려동물 소리" }
}

struct Dog: Pet { }
struct Cat: Pet {
    func speak() -> String { "야옹" }
}

let animals: [Animal] = [Dog(), Cat()]
for a in animals {
    print(a.speak())
}
```', 'OBJECTIVE'),
       (5023, 807, '아래 비교표에서 따라 나오는 결론으로 옳지 않은 것은?', '같은 동작을 프로토콜 Greeter로 추상화해 함수 하나를 두 가지 방식으로 선언해 보고, 컴파일 결과를 정리한 표다.

| 기준 | 제네릭 제약 `func run<T: Greeter>(_ g: T)` | existential `func run(_ g: any Greeter)` |
|---|---|---|
| 구체 타입 확정 | 호출 지점마다 컴파일 시점에 확정 | 값에 담긴 메타데이터로 실행 시점에 확인 |
| 특수화(specialization) | 타입별 코드를 따로 찍어내 적용 | 적용되지 않음 |
| 여러 타입을 한 배열에 | 불가 — T가 하나로 고정 | 가능 |
| 값 보관 | 넘겨받은 타입 그대로 | 3워드 버퍼, 넘치면 힙에 박싱 |', 'OBJECTIVE'),
       (5024, 807, '아래 코드에서 ① 줄이 컴파일되지 않는 이유로 옳은 것은?', '```swift
protocol Trackable {
    var hitCount: Int { get set }
    mutating func hit()
}

extension Trackable {
    var hitCount: Int = 0              // ①
    mutating func hit() { hitCount += 1 }
}

struct Banner: Trackable {
    var hitCount: Int = 0
}
```', 'OBJECTIVE'),
       (5025, 807, '아래 분석에서 draw() 호출 직전에 읽어 들인 표의 이름은?', '프로토콜 Drawable을 채택한 struct 12개를 배열에 담아 순회하며 요구사항 메서드 draw()를 부르는 코드를 릴리스 빌드로 뽑아 기계어를 살펴봤다.

- 배열 원소마다 값 옆에 포인터가 하나씩 더 붙어 다녔다.
- draw() 호출 직전에 그 포인터가 가리키는 곳에서 늘 같은 위치의 8바이트를 읽어, 그 주소로 점프했다.
- 채택하는 struct를 하나 더 만들어 13개가 되자 점프 대상을 모아 둔 자리가 하나 더 생겼고, 호출하는 쪽 기계어는 한 글자도 바뀌지 않았다.
- 같은 이름의 메서드를 `final class`에서 직접 부르는 코드에는 이 읽기 단계가 아예 없었다.', 'SUBJECTIVE'),
       (5026, 807, '아래 상황에서 드러난 문제를 가리키는 용어는?', '사내 공통 SDK v1.0에 아래 두 클래스가 있다. EventUploader는 SDK 소유라 앱 팀이 고칠 수 없고, RetryUploader는 앱 팀이 만들어 쓰는 하위 클래스다.

```swift
// SDK v1.0
class EventUploader {
    private(set) var sent = 0
    func send(_ e: Event) {
        sent += 1
        transport.write(e)
    }
    func sendAll(_ events: [Event]) {
        for e in events { send(e) }
    }
}

// 앱 팀 코드
final class RetryUploader: EventUploader {
    private(set) var retried = 0
    override func send(_ e: Event) {
        retried += 1
        super.send(e)
    }
}
```

v1.1에서 SDK 팀이 호출 비용을 줄이려고 sendAll의 본문만 아래처럼 바꿨다.

```swift
func sendAll(_ events: [Event]) {
    for e in events {
        sent += 1
        transport.write(e)   // send(_:)를 거치지 않는다
    }
}
```

메서드 이름·시그니처·문서에 적힌 동작은 그대로였고 SDK 자체 테스트도 전부 통과했다. 그런데 SDK 버전만 올리고 자기 코드는 한 줄도 건드리지 않은 앱에서, sendAll을 쓰는 화면만 retried가 계속 0으로 남아 재시도가 한 번도 일어나지 않는다는 제보가 들어왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5021
(13563, 5021, '타입마다 만들어 둔 표에서 정해진 자리의 값을 읽어 곧바로 점프한다.', '테이블 디스패치(vtable·위트니스 테이블)의 동작을 갖다 붙인 오개념. 자리 번호로 바로 읽는 대신, 실행 시점에 셀렉터 이름으로 구현을 찾는 탐색 단계가 들어간다.', false),
(13564, 5021, '호출 지점에 본문이 펼쳐지는 인라이닝 대상이 되어 세 방식 중 가장 빠르다.', '정적 디스패치의 특징을 옮겨 붙인 오개념. 호출 대상이 실행 시점까지 열려 있어 인라이닝을 할 수 없고, 이름을 찾는 단계가 남아 오히려 세 방식 중 가장 느리다.', false),
(13565, 5021, '앱이 실행되는 중에 그 이름에 연결된 구현을 다른 함수로 바꿔치기할 수 있다.', '호출 대상을 실행 시점에 이름으로 찾아가므로, 런타임 API로 그 이름이 가리키는 구현만 갈아끼우면 호출하는 쪽 코드를 한 줄도 고치지 않고 다른 함수가 실행된다. 메서드 스위즐링이 이 방식에서만 가능한 까닭이다.', true),
(13566, 5021, 'struct와 enum으로 만든 값 타입의 메서드에도 기본으로 적용된다.', '값 타입에는 재정의가 없어 정적 디스패치가 기본이다. 이 방식은 Objective-C 런타임이 있어야 하므로 NSObject를 상속한 클래스의 멤버에만 쓸 수 있다.', false),

-- 문제 5022
(13567, 5022, '동물 소리 / 야옹', 'Cat은 맞혔지만 Dog 쪽 판단이 틀렸다. 같은 메서드의 기본 구현이 두 확장에 모두 있으면 더 좁은 범위인 Pet 확장의 구현이 선택되므로, Dog는 반려동물 소리를 출력한다.', false),
(13568, 5022, '반려동물 소리 / 야옹', 'Dog는 직접 구현이 없어 기본 구현 중 더 좁은 Pet 확장 쪽이 쓰이고, Cat은 요구사항인 speak()를 직접 구현했으므로 원소 타입이 Animal이어도 위트니스 테이블을 거쳐 Cat의 구현이 실행된다.', true),
(13569, 5022, '반려동물 소리 / 반려동물 소리', '배열 원소 타입이 Animal이라 호출 대상이 확장 구현으로 고정된다고 본 오개념. speak()는 프로토콜 본문에 선언된 요구사항이라 Cat이 직접 쓴 구현이 기본 구현보다 먼저 선택된다.', false),
(13570, 5022, '동물 소리 / 동물 소리', '프로토콜 타입으로 담으면 늘 맨 위 프로토콜의 확장이 불린다고 본 오개념. 요구사항은 실제 타입의 구현을 따르고, 기본 구현끼리는 더 좁은 확장이 있으면 그쪽이 쓰인다.', false),

-- 문제 5023
(13571, 5023, '서로 다른 struct를 한 배열에 모아 순회해야 한다면 제네릭 제약으로 받는 편이 맞다.', '거짓이라 고를 선지. 제네릭 제약은 호출마다 T가 하나로 고정돼 여러 타입을 한 배열에 섞어 담지 못한다. 이질적인 값을 함께 담는 일은 표의 셋째 행대로 existential 쪽이 맡는다.', true),
(13572, 5023, '값이 3워드를 넘는 큰 struct를 any로 여러 개 담으면 힙 할당이 늘어 부담이 커진다.', '참인 진술. 넷째 행대로 버퍼에 들어가지 못하는 값은 힙에 박싱되므로, 원소 수만큼 할당이 따라붙어 메모리와 할당 비용이 함께 늘어난다.', false),
(13573, 5023, '호출이 잦은 내부 루프에서 오버헤드를 줄여야 한다면 제네릭 제약 쪽이 유리하다.', '참인 진술. 둘째 행대로 제약 쪽은 타입별 코드를 따로 찍어내 호출 대상을 컴파일 시점에 고정할 수 있어, 표를 거치는 간접 호출이 남는 쪽보다 반복 호출에 유리하다.', false),
(13574, 5023, '같은 any Greeter 배열을 순회해도 원소마다 실행되는 구현이 달라질 수 있다.', '참인 진술. 첫째·셋째 행대로 여러 구체 타입을 함께 담을 수 있고 실제 타입은 실행 시점에 확인되므로, 호출 코드가 같아도 원소가 무엇이냐에 따라 실행되는 구현이 갈린다.', false),

-- 문제 5024
(13575, 5024, '확장은 계산 프로퍼티와 메서드만 덧붙일 수 있어 값을 담아 둘 저장 공간을 만들지 못한다.', '확장은 이미 정해진 타입의 메모리 배치를 바꿀 수 없어 저장 프로퍼티를 추가하지 못한다. 여러 타입이 상태를 나눠 가져야 한다면 그 값을 모은 구조체를 각자 프로퍼티로 품는 컴포지션으로 푼다.', true),
(13576, 5024, '프로토콜 요구사항으로 선언한 프로퍼티는 확장에서 기본값을 줄 수 없고 채택 타입만 줄 수 있다.', '요구사항이냐가 아니라 저장이냐가 문제다. 같은 자리를 계산 프로퍼티로 썼다면 요구사항이어도 확장에서 기본 구현을 얼마든지 줄 수 있다.', false),
(13577, 5024, '확장 안에서는 mutating을 붙인 메서드를 선언할 수 없어 블록 전체가 거부된다.', '확장에서도 값 타입의 상태를 바꾸는 mutating 메서드를 선언할 수 있어 hit()는 문제가 없다. 거부되는 것은 블록 전체가 아니라 저장 프로퍼티를 만든 그 줄이다.', false),
(13578, 5024, 'Banner가 같은 이름의 프로퍼티를 이미 선언해 확장의 선언과 충돌한 것이다.', '이름 충돌이 원인이라면 Banner를 지웠을 때 통과해야 하지만, 채택 타입이 하나도 없어도 그 줄은 똑같이 거부된다. 확장에 저장 프로퍼티를 둘 수 없다는 규칙 자체가 원인이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1630, 5025, '프로토콜 위트니스 테이블,프로토콜위트니스테이블,위트니스 테이블,위트니스테이블,프로토콜 witness table,protocol witness table,protocolwitnesstable,witness table,witnesstable,PWT', '프로토콜 요구사항은 채택 타입마다 따로 만들어지는 이 표를 거쳐 호출된다. 값 옆에 포인터가 하나 더 붙어 다니고, 채택 타입이 늘 때마다 표가 하나씩 더 생기는데도 호출하는 쪽 기계어가 그대로인 것이 그 증거다. 덕분에 변수의 선언 타입이 프로토콜이어도 값에 담긴 실제 타입의 구현이 실행된다. 옆 개념과 경계를 그어 두자. 클래스가 override된 메서드를 찾을 때 쓰는 vtable은 프로토콜이 아니라 클래스 계층마다 만들어지고, @objc dynamic 메서드가 셀렉터 이름으로 구현을 찾아가는 메시지 디스패치는 정해진 자리를 읽는 대신 런타임 탐색을 한다. final class에서 읽기 단계가 사라진 것은 재정의 가능성이 없어 호출 대상이 컴파일 시점에 확정되는 정적 디스패치이기 때문이다. 프로토콜 본문에 없고 확장에만 있는 메서드는 이 표에 자리가 없어, 변수의 정적 타입만 보고 호출 대상이 정해진다.'),
       (1631, 5026, '취약한 기반 클래스 문제,취약한 기반 클래스,취약한 베이스 클래스 문제,깨지기 쉬운 기반 클래스 문제,깨지기 쉬운 기반 클래스,깨지기 쉬운 베이스 클래스 문제,프래자일 베이스 클래스 문제,프래자일 베이스 클래스,fragile base class problem,fragile base class,fragilebaseclass,FBC', 'RetryUploader는 한 줄도 바뀌지 않았는데 동작이 멈췄다. 원인은 앱 팀이 볼 수 없는 SDK 쪽 구현 세부, 곧 sendAll이 내부적으로 send를 다시 부르느냐에 하위 클래스가 기대고 있었다는 데 있다. v1.1이 그 내부 호출을 지우자 override한 send가 통과되지 않아 retried가 늘지 않는다. 시그니처도 문서도 그대로인 변경이 하위 클래스를 망가뜨릴 수 있다는 점에서, 상속은 캡슐화를 깨고 하위 클래스를 상위 구현에 묶는다는 말이 나온다. 프로토콜로 시작하라는 원칙의 근거이기도 하다. 프로토콜은 요구사항이라는 계약만 공유하고 내부 호출 순서를 물려주지 않으며, 확장에 기본 구현을 두더라도 채택 타입이 요구사항을 직접 구현하면 위트니스 테이블을 거쳐 그 구현이 선택된다. 재시도처럼 덧붙이는 동작은 업로더를 프로퍼티로 품는 컴포지션으로 감싸면 SDK 내부가 바뀌어도 영향을 받지 않는다. 옆 개념과 경계를 그어 두자. God 클래스(God Object)는 한 클래스가 무관한 책임과 상태를 잔뜩 떠안아 비대해진 경우를 가리키는데, 여기서 문제가 된 EventUploader는 메서드 두 개뿐이라 해당하지 않는다. 단일 상속의 한계는 부모를 하나만 고를 수 있어 여러 능력을 동시에 붙이지 못하는 제약이고, 리스코프 치환 원칙 위반은 하위 타입이 상위 타입 자리를 대신하지 못하는 경우다. 여기서는 손대지도 않은 하위 클래스가 상위 클래스의 구현 변경 때문에 오동작했다는 점이 핵심이다.');

-- =====================================================
-- Lesson 965: 프로토콜 설계의 함정과 existential 다루기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5969, 965, '아래 코드를 실행했을 때 print가 출력하는 두 줄을 순서대로 나열한 것은?', '```swift
protocol Logger {
    func log(_ msg: String) -> String
}

extension Logger {
    func log(_ msg: String) -> String { "[기본] \(msg)" }
    func warn(_ msg: String) -> String { "[기본 경고] \(msg)" }
}

struct FileLogger: Logger {
    func log(_ msg: String) -> String { "[파일] \(msg)" }
    func warn(_ msg: String) -> String { "[파일 경고] \(msg)" }
}

func report<T: Logger>(_ logger: T) -> String {
    logger.log("A") + " " + logger.warn("B")
}

let f = FileLogger()
print(f.warn("C"))
print(report(f))
```', 'OBJECTIVE'),
       (5970, 965, '아래 상황의 조건을 모두 만족하는 수정으로 옳은 것은?', '주문 화면의 OrderViewModel은 외부 SDK가 제공하는 PaymentClient를 프로퍼티로 직접 만들어 쓰고 있다. 단위 테스트에서는 실제 결제 서버를 부르지 않도록 가짜 응답을 돌려주는 타입으로 바꿔 끼워야 한다. PaymentClient의 소스는 SDK 소유라 수정할 수 없다.

```swift
// SDK 제공 코드 (수정 불가)
final class PaymentClient {
    func pay(_ amount: Int) -> Bool { ... }
}

// 앱 코드
final class OrderViewModel {
    let client = PaymentClient()
    func order(_ amount: Int) -> Bool { client.pay(amount) }
}
```', 'OBJECTIVE'),
       (5971, 965, '아래 컴파일 오류를 래퍼 타입을 새로 만들지 않고 해결하는 수정으로 옳은 것은?', 'Swift 5.9 환경에서 작성한 코드다. 마지막 줄에서 컴파일 오류가 난다.

```swift
protocol Cache {
    associatedtype Value
    func load(_ key: String) -> Value?
}

struct MemoryCache: Cache {
    func load(_ key: String) -> String? { "메모리 값" }
}

struct DiskCache: Cache {
    func load(_ key: String) -> String? { "디스크 값" }
}

let caches: [any Cache<String>] = [MemoryCache(), DiskCache()]   // 컴파일 오류
```', 'OBJECTIVE'),
       (5972, 965, '아래 메서드 디스패치 방식에 대한 설명으로 옳은 것은?', '클래스에서 재정의할 수 있는 메서드를 부를 때 쓰이는 방식이다. 클래스마다 메서드 구현 주소를 정해진 순서로 적어 둔 표가 하나씩 만들어지고, 하위 클래스가 override하면 그 자리의 주소만 하위 클래스의 구현으로 바뀐다. 호출할 때는 객체가 가리키는 표에서 해당 자리의 주소를 읽어 그곳으로 점프한다.', 'OBJECTIVE'),
       (5973, 965, '아래 측정에서 any Shape 타입 변수의 크기를 늘 40바이트로 만든 구조를 가리키는 용어는?', '64비트 환경에서 프로토콜 Shape를 채택한 두 struct의 크기를 재고, 같은 값을 `any Shape` 타입 변수에 담았을 때를 비교했다.

```swift
protocol Shape { func area() -> Double }

struct Dot: Shape {
    var x = 0.0
    func area() -> Double { 0 }
}

struct Polygon: Shape {
    var p1 = 0.0, p2 = 0.0, p3 = 0.0, p4 = 0.0, p5 = 0.0
    func area() -> Double { p1 + p2 }
}
```

| 측정 | 결과 |
|---|---|
| `MemoryLayout<Dot>.size` | 8 |
| `MemoryLayout<Polygon>.size` | 40 |
| `MemoryLayout<any Shape>.size` | 40 |
| `let s: any Shape = Dot()` | 힙 할당 0회 |
| `let s: any Shape = Polygon()` | 힙 할당 1회 |', 'SUBJECTIVE'),
       (5974, 965, '아래에서 세 모델이 같은 상태를 갖도록 최종적으로 택한 설계 방식을 가리키는 용어는?', '앱의 세 화면 모델 FeedModel·ProfileModel·SearchModel은 모두 struct이고, 요청 횟수와 마지막 갱신 시각을 똑같이 기록해야 한다. 처음에는 아래처럼 시도했지만 컴파일되지 않았다.

```swift
protocol Trackable { }

extension Trackable {
    var requestCount = 0      // error: extensions must not contain stored properties
    var lastUpdated: Date?
}
```

struct라 공통 부모 클래스를 두는 방법도 쓸 수 없었다. 결국 아래처럼 바꾸자 세 모델 모두 같은 기록 기능을 쓰게 됐고, 기록 규칙을 고칠 때도 UsageStats 한 곳만 수정하면 됐다.

```swift
struct UsageStats {
    var requestCount = 0
    var lastUpdated: Date?
    mutating func record() {
        requestCount += 1
        lastUpdated = Date()
    }
}

struct FeedModel    { var stats = UsageStats() }
struct ProfileModel { var stats = UsageStats() }
struct SearchModel  { var stats = UsageStats() }
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5969
(16091, 5969, '[기본 경고] C / [파일] A [기본 경고] B', '확장 전용 메서드는 어디서 불러도 확장 구현이 실행된다고 본 오개념. f의 정적 타입은 FileLogger라 f.warn은 FileLogger가 직접 쓴 구현으로 정해진다.', false),
(16092, 5969, '[파일 경고] C / [파일] A [기본 경고] B', 'f.warn은 정적 타입이 FileLogger라 그 구현이 불린다. 제네릭 함수 안에서는 T가 Logger라는 것만 알려져, 요구사항인 log는 위트니스 테이블로 FileLogger 구현이, 요구사항이 아닌 warn은 확장 구현이 고정된다.', true),
(16093, 5969, '[파일 경고] C / [파일] A [파일 경고] B', '제네릭 함수에 FileLogger를 넘기면 T가 그 타입으로 바뀌어 호출된다고 본 오개념. 함수 본문은 T: Logger 제약만 보고 해석되므로 요구사항이 아닌 warn은 확장 구현으로 고정된다.', false),
(16094, 5969, '[파일 경고] C / [기본] A [기본 경고] B', '제네릭 함수 안에서는 모든 메서드가 확장 구현으로 고정된다고 본 오개념. log는 프로토콜 본문에 선언된 요구사항이라 위트니스 테이블을 거쳐 FileLogger의 구현이 실행된다.', false),

-- 문제 5970
(16095, 5970, 'PaymentClient를 상속한 MockPaymentClient를 만들어 pay를 override하고, 테스트에서는 이 하위 클래스를 넘긴다.', 'final 클래스는 하위 클래스를 만들 수 없어 이 방법은 컴파일부터 막힌다. 상속으로 테스트 대역을 만드는 방식은 final 앞에서 쓸 수 없다는 점이 상속의 한계다.', false),
(16096, 5970, 'extension PaymentClient 안에 pay를 한 번 더 선언해, 테스트 타깃에서만 가짜 결과를 돌려주도록 덮어쓴다.', '확장은 기능을 덧붙일 뿐 이미 있는 메서드를 바꿔 끼우지 못한다. 같은 시그니처의 pay를 다시 선언하면 중복 선언 오류가 난다.', false),
(16097, 5970, 'pay를 요구사항에 넣지 않고 확장에만 둔 프로토콜을 만들어 PaymentClient에 채택시키고, 뷰 모델에는 그 프로토콜 타입으로 가짜 타입을 주입한다.', '요구사항이 아닌 pay는 위트니스 테이블에 자리가 없어, 프로토콜 타입 프로퍼티로 부르면 컴파일 시점에 확장 구현으로 고정된다. 가짜 타입의 pay도 실제 PaymentClient의 pay도 불리지 않는다.', false),
(16098, 5970, 'pay를 요구사항으로 둔 프로토콜을 만들어 PaymentClient가 확장으로 채택하게 하고, 뷰 모델은 그 프로토콜 타입을 주입받게 바꾼다.', '소스를 고칠 수 없는 타입도 확장으로 프로토콜을 채택시킬 수 있다. 뷰 모델이 프로토콜 타입을 받으면 테스트에서 가짜 타입을 넣을 수 있고, pay가 요구사항이라 주입된 타입의 구현이 실행된다.', true),

-- 문제 5971
(16099, 5971, 'protocol Cache<Value>처럼 선언부 꺾쇠 안에 Value를 적어 기본 연관 타입으로 지정한다.', 'Swift 5.7부터 기본 연관 타입을 선언한 프로토콜만 any Cache<String>처럼 연관 타입을 고정한 existential을 쓸 수 있다. 그러면 AnyCache 같은 수동 타입 소거 래퍼 없이 두 구조체를 한 배열에 담는다.', true),
(16100, 5971, '배열 타입을 [some Cache<String>]으로 바꿔 컴파일러가 원소 타입을 알아서 정하게 한다.', 'some은 숨겨진 구체 타입 하나로 고정되므로 MemoryCache와 DiskCache를 한 배열에 섞을 수 없다. some Cache<String> 표기도 기본 연관 타입이 선언돼 있어야 쓸 수 있다.', false),
(16101, 5971, '두 구조체 안에 typealias Value = String을 적어 연관 타입을 분명하게 밝혀 준다.', 'Value는 load의 반환 타입에서 이미 String으로 추론된다. 문제는 채택 타입 쪽이 아니라 Cache<String>이라는 표기를 프로토콜 선언이 허용하지 않는 데 있다.', false),
(16102, 5971, 'associatedtype Value 선언을 extension Cache로 옮겨 프로토콜 본문에는 load만 남긴다.', '연관 타입은 프로토콜 본문에서만 선언할 수 있고 확장에는 둘 수 없다. 설령 옮길 수 있다 해도 Cache<String>처럼 꺾쇠로 고정할 근거는 생기지 않는다.', false),

-- 문제 5972
(16103, 5972, 'struct로 만든 타입의 메서드도 같은 방식으로 호출되어, 부를 때마다 표를 한 번 거친다.', '값 타입은 상속과 재정의가 없어 호출 대상이 컴파일 시점에 정해지는 정적 디스패치가 기본이다. 재정의 가능성이 있어야 표를 둘 이유가 생긴다.', false),
(16104, 5972, '실행 중에 표의 자리를 다른 함수로 바꿔 끼우는 메서드 스위즐링을 이 방식으로 할 수 있다.', '스위즐링은 셀렉터 이름으로 구현을 찾는 @objc dynamic 메시지 디스패치에서 가능하다. 이 방식의 표는 컴파일 때 정해져 실행 중에 바꿔 끼우지 않는다.', false),
(16105, 5972, 'Whole Module Optimization을 켜면 모듈 안에서 재정의가 없는 메서드는 이 표를 건너뛰고 호출될 수 있다.', 'WMO는 모듈 전체를 보고 재정의가 없는 클래스를 final처럼 취급한다. 그러면 호출 대상이 컴파일 시점에 확정되는 정적 디스패치로 바뀌어 표 조회가 사라지고 인라이닝도 가능해진다.', true),
(16106, 5972, '호출할 때마다 메서드 이름으로 표를 처음부터 검색하므로 세 방식 가운데 가장 느리다.', '이름으로 구현을 찾는 것은 메시지 디스패치의 동작이다. 이 방식은 자리 번호가 컴파일 때 정해져 있어 포인터를 한 번 따라가면 되므로 메시지 디스패치보다 빠르다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1946, 5973, 'existential 컨테이너,existential container,existentialcontainer,existential컨테이너,이그지스텐셜 컨테이너,이그지스텐셜컨테이너,익지스텐셜 컨테이너,익지스텐셜컨테이너,존재 컨테이너,존재 타입 컨테이너,실존 컨테이너', '프로토콜을 값의 타입으로 쓰면 컴파일러는 어떤 구체 타입이 올지 모르므로, 값을 늘 같은 크기의 existential 컨테이너에 담는다. 64비트 기준으로 값 버퍼 3워드(24바이트)와 타입 메타데이터 포인터(8바이트), 위트니스 테이블 포인터(8바이트)를 합쳐 40바이트다. 그래서 8바이트짜리 Dot을 넣든 40바이트짜리 Polygon을 넣든 any Shape의 크기는 40으로 같다. Dot은 24바이트 버퍼 안에 그대로 들어가 힙 할당이 없지만, Polygon은 버퍼에 들어가지 않아 힙에 따로 박싱되고 버퍼에는 그 주소만 남는다. 옆 개념과 경계를 그어 두자. 박싱은 버퍼에 못 들어간 값을 힙으로 옮기는 현상이지 값을 감싸는 구조의 이름이 아니다. 위트니스 테이블은 컨테이너 안의 포인터가 가리키는 요구사항 구현 목록이다. AnyStorage 같은 타입 소거 래퍼는 개발자가 직접 만드는 구체 타입이다. 제네릭 제약(<T: Shape>)으로 받으면 이런 컨테이너 없이 구체 타입 그대로 다뤄져 특수화 최적화도 받을 수 있다.'),
       (1947, 5974, '컴포지션,합성,객체 합성,객체합성,composition,object composition,objectcomposition,구성', '공통 상태를 UsageStats라는 별도 타입으로 모으고, 각 모델이 그 값을 프로퍼티로 품어 기능을 빌려 쓰는 방식이 컴포지션(합성)이다. 모델과 UsageStats는 is-a가 아니라 has-a 관계이며, 기록 규칙을 바꿀 때 UsageStats만 고치면 된다는 점이 재사용 효과다. 처음 시도가 막힌 이유는 프로토콜 확장이 계산 프로퍼티와 메서드만 덧붙일 수 있고 값을 담아 둘 저장 프로퍼티는 만들 수 없기 때문이다. 옆 개념과 경계를 그어 두자. 상속은 부모 클래스의 상태와 동작을 물려받는 is-a 관계라 클래스에만 쓸 수 있고, struct인 세 모델에는 애초에 쓸 수 없다. 프로토콜 확장의 기본 구현은 동작은 공유하지만 상태는 공유하지 못한다. 의존성 주입은 필요한 객체를 밖에서 넣어 주는 방식을 말하는 것으로, 여기처럼 모델이 스스로 UsageStats를 만들어 품는 경우와는 초점이 다르다.');
