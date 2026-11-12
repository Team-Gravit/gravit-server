-- Unit: 제네릭과 associatedtype (Unit ID: 224)
-- Chapter: Swift (Chapter ID: 22)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (650, 224, '제약 선택과 some·any 비교, 특수화'),
       (808, 224, '조건부 확장과 existential 열기'),
       (966, 224, 'where 절이 막는 호출, 연관 타입 추론, some과 any의 쓰임새');

-- =====================================================
-- Lesson 650: 제약 선택과 some·any 비교, 특수화
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4079, 650, '아래 코드가 컴파일되지 않는 이유로 옳은 것은?', '```swift
func pickBigger<T: Equatable>(_ a: T, _ b: T) -> T {
    return a > b ? a : b
}

var x = 3, y = 7
print(pickBigger(x, y))
```', 'OBJECTIVE'),
       (4080, 650, '아래 비교표를 바탕으로 옳지 않은 것은?', '프로토콜 P를 값의 타입 자리에서 다루는 두 방식을 정리한 표다.

| 항목 | some P | any P |
|---|---|---|
| 구체 타입 | 하나로 고정, 호출자에게만 숨김 | 실행 중 여러 타입이 올 수 있음 |
| 타입 정체성 | 유지 — 연관 타입 관계를 계속 추적 | 소거 — 값을 박스에 담음 |
| 디스패치 | 정적, 특수화·인라이닝 가능 | 위트니스 테이블을 통한 간접 호출 |
| 이질적 컬렉션 | 불가 — 요소가 모두 같은 타입 | 가능 — 서로 다른 타입을 섞어 담음 |
| 도입 버전 | 반환 위치 Swift 5.1, 매개변수 위치 5.7 | Swift 5.6, 모든 프로토콜에 사용 5.7 |', 'OBJECTIVE'),
       (4081, 650, '아래 프로토콜과 채택 타입에 대한 설명으로 옳은 것은?', '아래 코드는 그대로 컴파일된다.

```swift
protocol Container {
    associatedtype Item: Equatable
    var count: Int { get }
    mutating func append(_ item: Item)
    subscript(i: Int) -> Item { get }
}

struct IntStack: Container {
    private var items: [Int] = []
    var count: Int { items.count }
    mutating func append(_ item: Int) { items.append(item) }
    subscript(i: Int) -> Int { items[i] }
}
```', 'OBJECTIVE'),
       (4082, 650, '아래 코드에서 컴파일 오류가 나는 줄과 그 이유로 옳은 것은?', '오류는 (1)~(3) 중 한 줄에서만 난다. Swift 5.9 기준이다.

```swift
protocol Container<Item> {
    associatedtype Item: Equatable
    mutating func append(_ item: Item)
}

struct IntBox: Container {
    private var items: [Int] = []
    mutating func append(_ item: Int) { items.append(item) }
}

func fill(_ c: inout some Container<Int>) { c.append(1) }   // (1)
let boxes: [any Container<String>] = []                     // (2)
var raw: Container<Int> = IntBox()                          // (3)
```', 'OBJECTIVE'),
       (4083, 650, '아래에서 AnyView가 수행한 기법을 가리키는 용어는?', 'SwiftUI 화면 코드의 var body: some View 안에서 if isLoggedIn으로 분기해 서로 다른 두 뷰를 돌려주도록 고치자 빌드가 실패했다. 두 분기를 각각 AnyView(...)로 감싸 돌려주니 빌드는 통과했지만, 이후 프레임워크가 뷰의 구체 타입을 구분하지 못해 화면 갱신 때 필요 없는 재생성이 늘었다.', 'SUBJECTIVE'),
       (4084, 650, '아래에서 최적화 빌드가 제네릭 함수에 적용한 컴파일러 최적화의 이름은?', '제네릭 함수 sum<T: Numeric>(_ items: [T]) -> T와, 같은 로직을 [Any]로 받아 요소마다 캐스팅하는 함수를 나란히 두고 요소 1,000,000개를 처리해 비교했다. 디버그 빌드에서는 두 함수가 각각 430ms와 460ms로 비슷했지만, 최적화 빌드에서는 [Any] 버전이 420ms인 반면 제네릭 함수는 38ms로 떨어졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4079
(11051, 4079, '호출부의 정수 값만으로는 T가 추론되지 않아 pickBigger<Int>처럼 타입을 직접 적어야 한다.', 'x와 y가 Int이므로 T는 Int로 정상 추론된다. 타입 추론이 되느냐가 아니라 T가 어떤 능력을 보장받느냐가 걸린 문제다.', false),
(11052, 4079, 'Equatable은 값이 같은지만 보장하므로 대소를 따지려면 Comparable 제약이 필요하다.', '제약은 제한이 아니라 능력 부여다. Equatable이 여는 것은 ==·!=뿐이고 <·>·max()·sorted()는 Comparable 제약을 걸어야 열린다. 선언을 <T: Comparable>로 바꾸면 컴파일된다.', true),
(11053, 4079, '삼항 연산자의 두 분기가 서로 다른 타입을 돌려주어 반환 타입 T로 통일되지 않는다.', '두 분기 값 a와 b는 모두 T라 타입이 같다. 오류는 분기 값이 아니라 조건식의 > 연산에서 난다.', false),
(11054, 4079, '제네릭 함수는 반환 타입 자리에 타입 매개변수를 쓸 수 없어 some Equatable로 적어야 한다.', '반환 타입에 타입 매개변수를 쓰는 것은 정상이며 표준 라이브러리도 그렇게 쓴다. some으로 바꾸면 오히려 호출자가 구체 타입 정보를 잃는다.', false),

-- 문제 4080
(11055, 4080, 'Circle과 Square를 한 배열에 모아 그리려면 [some Shape]에 두 타입을 섞어 담으면 된다.', '표의 이질적 컬렉션 행에 정면으로 걸리는 거짓 진술이다. some은 요소 타입이 하나로 고정되므로 서로 다른 구체 타입을 한 배열에 담으려면 [any Shape]가 필요하다.', true),
(11056, 4080, '매개변수 자리에 some을 쓰는 표기는 반환 자리에 쓰는 표기보다 나중 버전에서 쓸 수 있게 됐다.', '표의 도입 버전 행대로 반환 위치는 Swift 5.1, 매개변수 위치는 5.7이라 참이다. 매개변수 자리의 some은 제네릭 선언을 짧게 쓴 축약 표기다.', false),
(11057, 4080, '실행 중에 다른 구현으로 갈아 끼워 저장해야 하는 프로퍼티라면 any 쪽을 골라야 한다.', '참이다. some은 구체 타입이 하나로 고정돼 교체가 불가능하므로, 의존성 주입처럼 구현을 바꿔 담는 자리에는 여러 타입을 받는 any가 맞는다.', false),
(11058, 4080, 'any로 받은 값은 구체 타입이 가려져 연관 타입 사이의 관계를 이어서 따라갈 수 없다.', '참이다. 표의 타입 정체성 행처럼 any는 값을 박싱하며 정체성을 지운다. 그래서 Self 요구사항이 있는 Equatable 비교가 any 값끼리는 성립하지 않는다.', false),

-- 문제 4081
(11059, 4081, 'Item에 Equatable 제약이 붙어 있으므로 IntStack 자신이 Equatable을 채택해야 요구사항이 채워진다.', 'Equatable 제약은 채택 타입이 아니라 연관 타입 Item에 걸린 것이다. Item이 Int로 정해지고 Int가 이미 Equatable이므로 제약은 그대로 만족된다.', false),
(11060, 4081, 'Item은 프로토콜을 선언할 때 한 구체 타입으로 확정되므로 다른 타입을 담는 채택 타입은 만들 수 없다.', 'associatedtype은 확정된 타입이 아니라 채택 타입이 나중에 채울 자리다. 같은 프로토콜을 StringStack이 채택하면 그쪽의 Item은 String이 된다.', false),
(11061, 4081, 'subscript 요구사항의 반환 타입은 Item인데 IntStack은 Int를 돌려주므로 시그니처가 어긋난다.', 'IntStack에서 Item은 이미 Int로 정해졌으므로 Int를 돌려주는 것이 곧 Item을 돌려주는 것이다. 연관 타입을 구체 타입과 별개의 타입으로 본 오해다.', false),
(11062, 4081, 'typealias Item = Int를 적지 않았지만 append 구현의 매개변수 타입에서 Item이 Int로 정해진다.', '연관 타입은 요구사항 구현의 시그니처에서 거꾸로 추론된다. append가 Int를 받고 subscript가 Int를 돌려주므로 Item은 Int로 확정되며, typealias는 명시해도 되고 생략해도 된다.', true),

-- 문제 4082
(11063, 4082, '(1) — 프로토콜은 타입 매개변수를 가질 수 없으므로 some 뒤에 꺾쇠 표기를 붙일 수 없다.', '프로토콜에 타입 매개변수가 없다는 앞부분은 맞지만, Container<Item> 선언은 기본 연관 타입이라 some 뒤에서 쓸 수 있다. (1)은 where Item == Int를 줄여 쓴 정상 코드다.', false),
(11064, 4082, '(2) — existential에는 꺾쇠 축약을 쓸 수 없어 [any Container]로만 적을 수 있다.', '기본 연관 타입 축약은 some뿐 아니라 any 뒤에서도 쓸 수 있다. [any Container<String>]은 Item이 String인 값만 담는 배열로 정상 선언된다.', false),
(11065, 4082, '(3) — Container<Int>는 타입이 아니라 제약의 축약이라 some이나 any 없이 타입 자리에 쓸 수 없다.', 'Container<Int>는 where Item == Int를 짧게 쓴 제약 표기다. 제약 자체는 타입이 아니므로 변수의 타입 자리에 놓으려면 any Container<Int>처럼 적어야 한다.', true),
(11066, 4082, '(3) — IntBox가 Item을 typealias로 명시하지 않아 Item이 Int로 확정되지 않았기 때문이다.', 'append(_ item: Int) 구현에서 Item이 Int로 추론되므로 IntBox의 채택 자체에는 문제가 없다. (3)의 오류는 대입하는 값이 아니라 타입 자리의 표기에서 난다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1316, 4083, '타입 소거,타입소거,type erasure,type-erasure,typeerasure,타입 이레이저', '구체 타입 정보를 감춰 서로 다른 타입을 하나의 래퍼 타입으로 통일하는 기법이 타입 소거이며, AnyView·AnyHashable이 대표 래퍼다. some View는 타입을 호출자에게만 숨길 뿐 컴파일러는 하나의 구체 타입을 계속 추적한다. 그래서 분기마다 다른 뷰를 돌려주면 하나의 타입 조건이 깨져 빌드가 실패한 것이고, 소거와는 구분해야 한다. any P도 값을 박싱하며 정체성을 지운다는 점에서 같은 계열의 비용을 치른다.'),
       (1317, 4084, '특수화,specialization,제네릭 특수화,generic specialization,스페셜라이제이션,제네릭 스페셜라이제이션', '컴파일러가 실제로 쓰인 구체 타입별로 함수 본문을 따로 만들어 두는 최적화가 특수화다. Int 전용 코드가 생기면 박싱과 간접 호출이 사라지고 인라이닝까지 열려 열 배 넘는 차이가 난다. 디버그 빌드에서 두 함수가 비슷했던 것은 최적화 패스가 꺼져 특수화가 일어나지 않기 때문이다. any P로 받는 existential은 구체 타입이 실행 중에야 정해져 특수화 대상이 되지 못한다는 점에서 구분한다.');

-- =====================================================
-- Lesson 808: 조건부 확장과 existential 열기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5027, 808, '아래 코드의 (1)·(2) 두 줄에 대한 설명으로 옳은 것은?', '아래 코드는 한 파일에 그대로 들어 있다.

```swift
extension Array where Element: Numeric {
    func total() -> Element { reduce(0, +) }
}

let scores = [10, 20, 30]
let names = ["kim", "lee"]

print(scores.total())   // (1)
print(names.total())    // (2)
```', 'OBJECTIVE'),
       (5028, 808, '아래 코드가 Swift 5.7 이상에서는 통과하고 5.6에서는 막히는 이유로 옳은 것은?', '아래 코드를 Swift 5.6으로 빌드하면 describe(s) 줄에서만 오류가 나고, 5.7 이상에서는 그대로 통과한다.

```swift
protocol Shape { func area() -> Double }
struct Circle: Shape { func area() -> Double { 3.14 } }
struct Square: Shape { func area() -> Double { 4.0 } }

func describe<S: Shape>(_ s: S) -> String { "면적 \(s.area())" }

let stored: [any Shape] = [Circle(), Square()]
for s in stored {
    print(describe(s))
}
```', 'OBJECTIVE'),
       (5029, 808, '아래 코드를 Swift 5.9로 빌드했을 때 (3)·(4) 두 줄에 대한 설명으로 옳은 것은?', '한 파일에 아래 코드만 들어 있다.

```swift
protocol Tag { var name: String { get } }
struct Genre: Tag { let name: String }
struct Mood: Tag { let name: String }

func joinA(_ a: some Tag, _ b: some Tag) -> String { a.name + "/" + b.name }   // (1)
func joinB<T: Tag>(_ a: T, _ b: T) -> String { a.name + "/" + b.name }         // (2)

let g = Genre(name: "rock")
let m = Mood(name: "calm")

print(joinA(g, m))   // (3)
print(joinB(g, m))   // (4)
```', 'OBJECTIVE'),
       (5030, 808, '아래에서 설명하는 프로토콜 요구사항 선언 방식에 대한 설명으로 옳은 것은?', '어떤 프로토콜은 요구사항에 쓸 타입을 이름만 정해 둔 채 비워 둔다. 채택하는 타입이 typealias로 그 자리를 채우거나, 요구사항 구현의 시그니처에서 그 자리가 채워지게 한다. 표준 라이브러리의 IteratorProtocol과 Collection이 이렇게 선언돼 있다.', 'OBJECTIVE'),
       (5031, 808, '아래 (1)과 (2)가 같은 제약을 뜻하도록 만들어 준 Swift 5.7 기능의 이름은?', 'Swift 5.6에서는 (1)처럼만 적을 수 있었다. 5.7로 올린 뒤 프로토콜 선언 첫 줄을 protocol Queue<Element>로 고치자 (2)가 (1)과 같은 뜻이 됐고, [any Queue<String>] 같은 선언도 함께 가능해졌다.

```swift
protocol Queue {
    associatedtype Element: Equatable
    mutating func push(_ e: Element)
}

func fillA<Q: Queue>(_ q: inout Q) where Q.Element == Int { q.push(1) }   // (1)
func fillB(_ q: inout some Queue<Int>) { q.push(1) }                     // (2)
```', 'SUBJECTIVE'),
       (5032, 808, '아래 비교에서 210ms 쪽 호출이 매번 읽어 간 자료 구조의 이름은?', '도형 값 100,000개를 순회하며 area()를 부르는 루프를 두 가지로 만들어 최적화 빌드에서 비교했다.

| 구현 | 값을 다루는 방식 | 소요 시간 | 인라이닝 |
|---|---|---|---|
| A | [any Shape] 배열을 그대로 순회 | 210ms | 0건 |
| B | 같은 값을 some Shape 매개변수로 넘겨 처리 | 24ms | 전부 적용 |

A의 디스어셈블에는 호출마다 값에 딸려 다니는 포인터 목록에서 area() 자리를 읽고 그 주소로 뛰는 두 단계가 찍혔고, B에는 그 두 단계가 아예 없었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5027
(13579, 5027, 'names에도 total()이 붙되 더할 요소가 없어 (2)는 0을 출력한다.', '조건부 확장은 조건을 만족하는 타입에만 메서드를 붙인다. String은 Numeric을 채택하지 않으므로 names에는 total() 자체가 없고, 대신 기본값을 돌려주는 구현이 생기지도 않는다.', false),
(13580, 5027, '(1)은 60을 출력하지만 (2)는 String이 Numeric을 채택하지 않아 컴파일 단계에서 막힌다.', 'where Element: Numeric은 요소가 Numeric일 때만 total()을 여는 조건부 확장이다. Int는 Numeric이라 10+20+30이 계산되고, String 배열에서는 호출 자격이 없어 빌드가 실패한다.', true),
(13581, 5027, 'where 절이 Array 타입 자체를 좁히므로 names 배열을 선언하는 줄에서 먼저 오류가 난다.', '조건부 확장은 원래 타입이 담을 수 있는 요소를 줄이지 않는다. Array는 여전히 어떤 요소 타입이든 담으므로 names 선언은 정상이고, 문제는 그 배열에 없는 메서드를 부른 쪽에서 생긴다.', false),
(13582, 5027, 'reduce(0, +)의 0이 Element로 받아들여지지 않아 (1)도 함께 컴파일되지 않는다.', 'Numeric은 정수 리터럴로 값을 만들 수 있다는 요구사항을 포함하므로 0은 Element로 해석된다. 제약이 곧 능력을 여는 예이며, 제약 없는 T였다면 이 줄이 오히려 막힌다.', false),

-- 문제 5028
(13583, 5028, 'any Shape는 some Shape를 길게 쓴 표기일 뿐이라 제네릭 매개변수 자리에 그대로 들어가기 때문이다.', '두 표기는 다르다. some은 컴파일러가 아는 구체 타입 하나를 호출자에게만 숨긴 것이고, any는 실행 중 여러 타입이 올 수 있는 박스다. 같은 표기였다면 5.6에서도 막히지 않았다.', false),
(13584, 5028, '컴파일러가 호출마다 값을 AnyShape 같은 래퍼로 다시 감싸 S에 넘기기 때문이다.', '래퍼로 감싸는 것은 개발자가 직접 만드는 타입 소거이고 컴파일러가 몰래 해 주지 않는다. 여기서는 감싸는 것이 아니라 이미 감싸져 있는 값을 열어 안의 타입을 꺼내 쓴다.', false),
(13585, 5028, 'Shape에 연관 타입이 없어 any Shape 값 자체가 Shape를 채택한 것으로 취급되기 때문이다.', '연관 타입이 없어도 박스에 담긴 값은 원칙적으로 그 프로토콜을 채택한 것으로 보지 않는다. 채택으로 인정된 것이 아니라 값을 열어 안의 구체 타입을 꺼내는 길이 5.7에서 열린 것이다.', false),
(13586, 5028, '반복 변수에 담긴 박스가 호출 시점에 열려 그 안의 구체 타입 하나가 S로 넘어가기 때문이다.', 'Swift 5.7의 암묵적 existential 열기다. 한 번의 호출 안에서는 값의 구체 타입이 하나로 정해지므로 Circle이면 S=Circle, Square면 S=Square로 각각 특수화된다. any로 보관하다 처리 함수에서 제네릭으로 받는 관용구가 여기서 나온다.', true),

-- 문제 5029
(13587, 5029, '(3)은 타입 검사를 통과하지만 (4)는 두 인자가 같은 타입 T여야 해서 막힌다.', '매개변수 자리의 some은 적힌 자리마다 이름 없는 타입 매개변수를 하나씩 새로 만든다. joinA는 <T1: Tag, T2: Tag>와 같아 서로 다른 타입을 섞어 넘길 수 있고, joinB는 이름 붙인 T 하나를 두 자리에 함께 써서 첫 인자로 T가 Genre로 정해지면 Mood를 받지 못한다.', true),
(13588, 5029, '(3)·(4) 모두 통과한다. 매개변수 자리의 some Tag는 <T: Tag> 선언을 그대로 줄여 쓴 표기라 두 선언이 같은 함수이기 때문이다.', '축약인 것은 맞지만 무엇으로 줄었는지가 다르다. some이 두 번 적히면 타입 매개변수도 두 개가 생기므로 joinA는 자리마다 타입이 따로 정해진다. 두 자리를 한 타입으로 묶고 싶을 때만 joinB처럼 이름 붙인 T를 쓴다.', false),
(13589, 5029, '(3)만 막힌다. some은 반환 타입 자리에만 쓸 수 있어 매개변수 자리에 적은 joinA의 선언부터 성립하지 않기 때문이다.', 'some은 반환 위치가 Swift 5.1, 매개변수 위치가 5.7에 열렸다. 5.9 빌드라 joinA 선언은 정상이며, 막히는 쪽은 선언이 아니라 한 타입 매개변수에 두 타입을 넘긴 (4)의 호출부다.', false),
(13590, 5029, '(3)·(4) 모두 막힌다. some Tag든 T든 구체 타입이 하나로 정해져야 하는데 호출부가 서로 다른 두 타입을 넘겼기 때문이다.', '하나로 정해져야 하는 범위는 함수 전체가 아니라 타입 매개변수 하나하나다. joinA는 자리마다 타입 매개변수가 따로 있어 (3)에서 T1은 Genre, T2는 Mood로 각각 고정된다. 어긋나는 것은 T 하나를 두 자리에 쓴 joinB뿐이다.', false),

-- 문제 5030
(13591, 5030, '채택 타입이 typealias를 적지 않으면 컴파일러가 그 자리를 Any로 채워 넣는다.', '비어 있는 자리는 Any로 대체되는 것이 아니라 요구사항 구현의 시그니처에서 거꾸로 추론된다. 추론할 단서가 전혀 없으면 Any가 채워지는 것이 아니라 채택 선언 자체가 오류가 된다.', false),
(13592, 5030, '이 자리에는 프로토콜 준수 제약을 걸 수 없어, 요구사항 안에서 ==를 쓰려면 구체 타입을 적어야 한다.', '자리 이름 뒤에 콜론을 붙여 Equatable 같은 제약을 걸 수 있고, 그러면 그 자리의 값에 ==를 쓸 수 있다. 제약은 여기서도 제한이 아니라 능력을 여는 장치다.', false),
(13593, 5030, '이렇게 선언한 프로토콜은 Swift 5.7 전까지 변수의 타입 자리에 쓸 수 없어, 값으로 담으려면 타입을 감추는 래퍼를 따로 만들어야 했다.', '빈 자리가 채택 타입마다 달라져 값의 실제 모양이 정해지지 않으므로 오랫동안 제네릭 제약 자리에서만 쓸 수 있었다. 그래서 AnyIterator 같은 래퍼가 필요했고, 5.7부터 any 표기로 값 자리에 놓을 수 있게 됐다.', true),
(13594, 5030, '한 프로토콜에 이런 자리를 둘 이상 둘 수 없어, 두 개가 필요하면 프로토콜을 나눠야 한다.', '개수 제한은 없다. Collection만 해도 Element·Index·SubSequence처럼 여러 자리를 한꺼번에 선언하고, 서로 다른 자리 사이의 관계는 where 절로 묶는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1632, 5031, '기본 연관 타입,기본연관타입,주 연관 타입,주연관타입,primary associated type,primary associatedtype,primaryassociatedtype,프라이머리 연관 타입', '프로토콜 이름 뒤 꺾쇠에 연관 타입 하나를 올려 두면 some Queue<Int>·[any Queue<String>]처럼 where 절 없이 그 자리를 특정할 수 있다. Swift 5.7에 들어온 기본 연관 타입이다. 경계를 둘 짚어야 한다. 첫째, Queue<Int>는 제네릭 타입을 인스턴스화한 것이 아니라 where Element == Int를 줄여 쓴 제약이므로 반드시 some이나 any 뒤에서만 쓸 수 있다. 둘째, 프로토콜이 타입 매개변수를 갖게 된 것도 아니다. 자리를 선언하는 associatedtype은 그대로 남아 있고, 꺾쇠는 그중 대표 자리를 밖에서 부르는 통로일 뿐이다.'),
       (1633, 5032, '위트니스 테이블,프로토콜 위트니스 테이블,위트니스테이블,프로토콜위트니스테이블,witness table,protocol witness table,witnesstable,pwt', 'any로 감싼 값은 값 버퍼·타입 메타데이터와 함께, 그 타입이 프로토콜 요구사항을 어떤 함수로 구현했는지 적어 둔 포인터 표를 들고 다닌다. 이것이 프로토콜 위트니스 테이블이고, 호출은 표를 한 번 읽은 뒤 그 주소로 뛰는 간접 호출이 되어 인라이닝이 막힌다. B가 빠른 것은 some으로 받은 매개변수의 구체 타입이 하나로 고정돼 컴파일러가 타입별 코드를 만들고 호출을 직접 호출로 바꾸기 때문이다. 클래스 상속에서 쓰는 vtable과 구분한다. vtable은 클래스 계층 하나에 붙지만, 위트니스 테이블은 타입과 프로토콜의 짝마다 따로 만들어진다.');

-- =====================================================
-- Lesson 966: where 절이 막는 호출, 연관 타입 추론, some과 any의 쓰임새
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5975, 966, '아래 (1)~(4) 호출 중 컴파일 오류가 나는 것만 모두 고른 것은?', '아래 코드는 한 파일에 그대로 들어 있다.

```swift
struct Point { let x: Int; let y: Int }

func haveSameElements<A: Collection, B: Collection>(_ a: A, _ b: B) -> Bool
    where A.Element == B.Element, A.Element: Equatable {
    a.count == b.count && zip(a, b).allSatisfy { $0 == $1 }
}

print(haveSameElements([1, 2, 3], [1, 2, 3]))                     // (1)
print(haveSameElements([1, 2, 3], Set([1, 2, 3])))                // (2)
print(haveSameElements([1, 2], ["1", "2"]))                       // (3)
print(haveSameElements([Point(x: 0, y: 0)], [Point(x: 0, y: 0)])) // (4)
```', 'OBJECTIVE'),
       (5976, 966, '아래 코드를 빌드한 결과에 대한 설명으로 옳은 것은?', '두 구조체 모두 typealias를 적지 않았다.

```swift
protocol Store {
    associatedtype Item
    mutating func put(_ item: Item)
    func get(_ i: Int) -> Item
}

struct NameStore: Store {
    private var names: [String] = []
    mutating func put(_ item: String) { names.append(item) }
    func get(_ i: Int) -> String { names[i] }
}

struct MixedStore: Store {
    private var values: [Int] = []
    mutating func put(_ item: Int) { values.append(item) }
    func get(_ i: Int) -> String { String(values[i]) }
}
```', 'OBJECTIVE'),
       (5977, 966, '아래 코드를 Swift 5.9로 빌드·실행한 결과로 옳은 것은?', '```swift
let a: any Equatable = 3
let b: any Equatable = 3
print(a == b)
```', 'OBJECTIVE'),
       (5978, 966, '아래 요구사항을 만족하는 repository 프로퍼티 선언으로 옳은 것은?', 'UserService는 앱 실행 중 설정 화면의 스위치에 따라 repository를 RemoteRepository에서 MockRepository로 바꿔 끼워야 한다. 바꾼 뒤에도 service.repository.fetchUser(id:)는 캐스팅 없이 바로 호출할 수 있어야 한다.

```swift
protocol UserRepository { func fetchUser(id: Int) -> String }
struct RemoteRepository: UserRepository { func fetchUser(id: Int) -> String { "remote" } }
struct MockRepository: UserRepository { func fetchUser(id: Int) -> String { "mock" } }

final class UserService {
    var repository: /* ? */ = RemoteRepository()
}

// 설정 스위치를 켰을 때
service.repository = MockRepository()
print(service.repository.fetchUser(id: 1))
```', 'OBJECTIVE'),
       (5979, 966, '아래에서 B 버전이 사용한 Swift 언어 기능의 이름은?', '목록의 첫 원소를 꺼내는 헬퍼를 두 버전으로 만들었다.

- A 버전: 인자를 [Any]로 받고 결과도 Any로 돌려준다. 호출부마다 as! Int로 결과를 바꿔 써야 했고, 가격 배열 대신 상품명 배열을 넘긴 호출 한 곳이 배포 뒤 Could not cast value of type ''Swift.String'' to ''Swift.Int'' 로 크래시했다.
- B 버전: 함수 본문 로직은 그대로 두고 선언부만 고쳤다. 호출부의 as! 캐스팅이 모두 사라졌고, 같은 잘못된 호출은 배포 전 빌드 단계에서 타입 불일치 오류로 막혔다. 요소 1,000,000개 처리 시간도 최적화 빌드에서 A의 410ms보다 짧은 35ms였다.', 'SUBJECTIVE'),
       (5980, 966, '아래에서 반환 타입 자리에 적용한 선언 방식을 가리키는 용어는?', '사내 라이브러리의 evenSquares() 함수는 반환 타입을 LazyMapSequence<LazyFilterSequence<[Int]>, Int>로 공개하고 있었다. 내부 구현을 배열 반환으로 바꾸자, 이 긴 타입을 변수 선언에 그대로 적어 둔 앱 코드 세 곳이 빌드에 실패했다.

그래서 반환 타입을 키워드 하나와 Sequence<Int>만 적는 형태로 바꿨다. 이후 내부 구현을 다시 바꿔도 앱 코드는 그대로 빌드됐고, 최적화 빌드의 벤치마크도 바꾸기 전과 같은 1.2ms였다. 그런데 인자에 따라 배열과 lazy 시퀀스를 나눠 돌려주도록 고치자, 두 return 문의 실제 타입이 서로 다르다는 오류로 빌드가 실패했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5975
(16107, 5975, '(3)', '(4)를 놓친 선택이다. Point는 Equatable을 채택하지 않아 A.Element: Equatable 조건을 어긴다. 제약은 능력 부여라서, 조건을 못 채운 타입으로는 ==를 쓰는 함수를 부를 수 없다.', false),
(16108, 5975, '(2), (3)', 'A와 B가 같은 컬렉션 타입이어야 한다고 본 오해다. where 절은 두 컬렉션의 요소 타입이 같을 것만 요구하므로 Array<Int>와 Set<Int>는 Element가 모두 Int라 통과한다.', false),
(16109, 5975, '(3), (4)', '(3)은 요소가 Int와 String으로 달라 A.Element == B.Element를 어기고, (4)는 요소 타입은 같지만 Point가 Equatable이 아니라 두 번째 조건을 어긴다. (2)는 컬렉션 종류만 다르고 요소가 모두 Int라 통과한다.', true),
(16110, 5975, '(2), (3), (4)', '(2)를 오류로 본 것은 A와 B가 결국 한 타입이어야 한다는 오해다. 타입 매개변수를 둘로 나눈 이유가 서로 다른 컬렉션을 받기 위해서이며, 둘 사이의 관계는 요소 타입에만 걸려 있다.', false),

-- 문제 5976
(16111, 5976, 'MixedStore만 오류 — put에서는 Item이 Int로, get에서는 String으로 추론돼 하나로 정해지지 않는다.', '연관 타입은 채택 타입마다 구체 타입 하나로 확정돼야 한다. NameStore는 put·get이 모두 String이라 Item = String으로 추론되지만, MixedStore는 두 구현의 단서가 엇갈려 프로토콜 준수 자체가 실패한다.', true),
(16112, 5976, '둘 다 오류 — typealias Item = ...을 적지 않아 두 구조체 모두 Item이 정해지지 않는다.', 'typealias는 선택 사항이다. 연관 타입은 요구사항 구현의 시그니처에서 거꾸로 추론되므로 NameStore는 명시하지 않아도 Item이 String으로 확정된다.', false),
(16113, 5976, '둘 다 통과 — 단서가 엇갈리는 MixedStore는 컴파일러가 Item을 Any로 대신 채워 넣는다.', '추론이 엇갈릴 때 Any로 채워 주는 규칙은 없다. 단서가 충돌하면 준수 오류가 나며, Any로 채워진다면 타입을 채택 타입마다 확정하려는 연관 타입의 의미가 사라진다.', false),
(16114, 5976, '둘 다 통과 — 연관 타입은 요구사항마다 따로 채워지므로 put과 get이 다른 타입을 써도 된다.', 'Item은 요구사항마다 따로 있는 자리가 아니라 채택 타입 전체에 하나뿐인 자리다. put과 get이 같은 Item을 쓰도록 선언됐으므로 두 구현의 타입도 같아야 한다.', false),

-- 문제 5977
(16115, 5977, 'true를 출력한다 — 두 값 모두 실제로는 Int 3이므로 Int의 ==로 비교된다.', '실행 중에는 둘 다 Int지만 컴파일러가 보는 타입은 any Equatable뿐이다. 박스 안의 구체 타입이 같다는 보장이 없으므로 실행 전에 이미 == 호출이 거부된다.', false),
(16116, 5977, 'print 줄에서 컴파일 오류가 난다 — 두 값이 같은 구체 타입이라는 보장이 없다.', 'Equatable의 ==는 (Self, Self)를 받는 Self 요구사항이다. any Equatable 두 개는 Int와 String처럼 서로 다른 타입을 담을 수도 있어 성립하지 않는다. 비교하려면 제네릭으로 받거나 AnyHashable 같은 래퍼를 쓴다.', true),
(16117, 5977, '실행 중 크래시가 난다 — 박스 속 타입을 맞춰 보다가 쓸 == 구현을 찾지 못한다.', '문제는 실행 시점이 아니라 타입 검사 시점에 드러난다. 컴파일러가 == 호출 자체를 허용하지 않으므로 실행 파일이 만들어지지 않고, 런타임 비교 단계까지 가지 않는다.', false),
(16118, 5977, '선언 줄에서 컴파일 오류가 난다 — Self 요구사항이 있는 프로토콜은 any 뒤에 못 쓴다.', 'Swift 5.6까지의 제한이 지금도 있다고 본 오해다. 5.7부터는 Self·연관 타입 요구사항이 있는 프로토콜도 any로 값의 타입 자리에 쓸 수 있어 두 선언 줄은 통과한다.', false),

-- 문제 5978
(16119, 5978, 'var repository: some UserRepository', 'some은 구체 타입을 호출자에게 숨길 뿐 하나로 고정한다. 초기값으로 RemoteRepository가 정해지면 이후 MockRepository를 대입할 때 타입이 달라 컴파일 오류가 난다.', false),
(16120, 5978, 'var repository: Any', '두 타입을 모두 담을 수는 있지만 Any에는 fetchUser가 없다. 호출할 때마다 as?로 UserRepository로 바꿔야 하므로 캐스팅 없이 호출한다는 요구사항을 어긴다.', false),
(16121, 5978, 'var repository: R (UserService<R: UserRepository>)', 'R은 인스턴스를 만들 때 UserService<RemoteRepository>처럼 한 번 정해지면 바뀌지 않는다. 같은 인스턴스에 MockRepository를 대입할 수 없어 실행 중 교체가 불가능하다.', false),
(16122, 5978, 'var repository: any UserRepository', 'any는 UserRepository를 채택한 어떤 타입이든 박스에 담아 실행 중 교체를 허용하고, fetchUser는 프로토콜 요구사항이라 위트니스 테이블을 거쳐 캐스팅 없이 호출된다. 대신 간접 호출 비용을 치른다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1948, 5979, '제네릭,제너릭,제네릭스,generics,generic,제네릭 함수,generic function', '타입을 매개변수로 받아 호출 시점의 구체 타입으로 채우는 기능이 제네릭이다. func first<T>(_ items: [T]) -> T?처럼 선언하면 호출부의 인자에서 T가 추론돼 캐스팅이 필요 없고, 타입이 어긋난 호출은 컴파일 단계에서 막힌다. 최적화 빌드에서 빨라진 것은 컴파일러가 실제 쓰인 타입별 코드를 만드는 특수화 덕분이다. Any로 받는 방식과 구분해야 한다. Any는 무엇이든 담지만 타입 정보를 버려서 꺼낼 때마다 캐스팅이 필요하고, 잘못된 캐스팅은 실행 중에야 드러난다.'),
       (1949, 5980, '불투명 타입,불투명타입,불투명 반환 타입,불투명 결과 타입,opaque type,opaque return type,opaque result type,오페이크 타입,some,some 키워드', '반환 타입을 some Sequence<Int>처럼 적으면 호출자에게는 Sequence<Int>를 따른다는 사실만 보이고, 컴파일러는 실제 구체 타입 하나를 계속 알고 있다. 이것이 불투명 타입이다. 그래서 내부 구현을 바꿔도 호출부 코드가 깨지지 않고, 박싱 없이 정적 호출·특수화가 유지돼 성능도 그대로다. 대신 구체 타입이 하나로 고정돼야 하므로 분기마다 다른 타입을 돌려주면 빌드가 실패한다. any Sequence<Int>와 구분해야 한다. any였다면 분기마다 다른 타입을 돌려줄 수 있지만, 값을 박스에 담고 간접 호출을 거쳐 비용이 늘었을 것이다.');
