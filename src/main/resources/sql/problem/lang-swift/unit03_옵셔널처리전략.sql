-- Unit: 옵셔널 처리 전략 (Unit ID: 222)
-- Chapter: Swift (Chapter ID: 22)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (648, 222, '강제 언래핑 기준과 암시적 언래핑'),
       (806, 222, '열거형 정체와 nil 병합 평가 순서'),
       (964, 222, 'Swift 옵셔널 — 중첩 옵셔널·약한 캡처와 안전한 언래핑 설계');

-- =====================================================
-- Lesson 648: 강제 언래핑 기준과 암시적 언래핑
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4067, 648, '아래 코드를 실행했을 때 출력되는 값은?', '```swift
let raw: [String?] = ["12", nil, "3.5", "8"]
var total = 0
var failed = 0

for s in raw {
    switch s.flatMap({ Int($0) }) {
    case .some(let n): total += n
    case .none:        failed += 1
    }
}
print("\(total) \(failed)")
```', 'OBJECTIVE'),
       (4068, 648, '아래에서 설명하는 옵셔널 선언 방식에 대한 설명으로 옳은 것은?', '프로퍼티 타입 뒤에 물음표 대신 느낌표를 붙여 `var label: UILabel!`처럼 선언하는 방식이다. 선언 자체는 값이 비어 있는 상태로 시작하지만, 값을 꺼내 쓸 때마다 컴파일러가 언래핑을 자동으로 붙여 준다. 스토리보드가 뷰를 연결해 주는 `@IBOutlet` 프로퍼티처럼, 초기화 직후에는 비어 있어도 사용 시점에는 프레임워크가 값을 채워 준다고 보장되는 자리에 쓴다.', 'OBJECTIVE'),
       (4069, 648, '아래 함수가 컴파일되지 않는 이유로 옳은 것은?', '```swift
func makeUpperID(_ raw: String?) -> String {
    guard let raw else {
        print("입력이 비어 있습니다")
    }
    return raw.uppercased()
}
```', 'OBJECTIVE'),
       (4070, 648, '아래 표를 바탕으로 강제 언래핑 사용에 대한 판단으로 옳지 않은 것은?', '| 값의 출처 | 판단 | 근거 |
|---|---|---|
| 코드에 적힌 리터럴로만 만들어지는 값 (`URL(string: "https://example.com")!`) | 허용 | 값이 잘못됐다면 개발 중 첫 실행에서 바로 드러남 |
| `@IBOutlet` 등 프레임워크가 주입을 보장하는 값 | 허용 | 관례로 굳은 자리. 단, 주입 전에 접근하지 않도록 주의 |
| 직전 줄에서 nil 검사를 마친 값 | 지양 | 검사와 사용이 떨어져 있으면 이후 수정에서 쉽게 깨짐 |
| 네트워크 응답·파일·사용자 입력에서 온 값 | 금지 | 형식이 언제든 달라질 수 있음 |', 'OBJECTIVE'),
       (4071, 648, '아래 로그와 수정 내역에서, 느낌표 세 개를 대신해 넣은 Swift 문법의 이름은?', '[크래시 로그]
Fatal error: Unexpectedly found nil while unwrapping an Optional value

```swift
// 크래시가 난 줄 — 주소를 등록하지 않은 계정에서만 재현된다
let n = user!.address!.city!.count      // n: Int

// 수정한 줄 — 느낌표 세 개를 모두 같은 한 가지 기호로 바꿨다
let n = user▢.address▢.city▢.count      // n: Int?
```

수정 뒤 같은 계정에서 크래시가 사라졌고 n에는 nil이 담겼다. 타입은 Int???가 아니라 Int? 한 겹이었다.', 'SUBJECTIVE'),
       (4072, 648, '아래 코드의 ▢ 자리에 들어간 Swift 연산자의 이름은?', '프로필 화면에서 닉네임을 등록하지 않은 계정만 이름 칸이 빈 채로 렌더링된다는 제보가 들어왔다. nickname은 서버 응답에서 온 String?이다.

```swift
// 고치기 전 — nickname이 nil인 계정에서 이름 칸이 빈 채로 남는다
label.text = nickname

// 고친 뒤 — 연산자 하나만 넣었고, 오른쪽 항의 타입이 String이라 결과도 비옵셔널 String이 되었다
label.text = nickname ▢ defaultName()
```

계측 결과: nickname에 값이 있는 계정에서는 defaultName()이 한 번도 호출되지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4067
(11019, 4067, '23 1', 'Int("3.5")가 소수점 앞의 3만 떼어 온다고 본 오해다. Swift의 Int(String)은 정수 형태가 아니면 일부라도 취하지 않고 전체를 nil로 돌려준다.', false),
(11020, 4067, '20 2', 'nil 요소와 "3.5" 둘 다 변환 결과가 nil이라 .none으로 빠진다. 변환에 성공한 12와 8만 더해 total은 20, failed는 2가 된다.', true),
(11021, 4067, '20 1', 'nil은 switch에서 어떤 케이스에도 걸리지 않고 지나간다고 본 오해다. 옵셔널의 nil은 .none 케이스에 정확히 걸려 failed를 올린다.', false),
(11022, 4067, '0 4', 'flatMap을 배열 전용으로 보고 옵셔널에는 못 쓴다고 본 오해다. Optional.flatMap은 값이 있을 때만 변환을 적용하고 결과를 한 겹으로 평탄화한다.', false),

-- 문제 4068
(11023, 4068, 'nil을 대입하려 하면 컴파일 오류가 나므로 값이 비는 상황 자체가 생기지 않는다.', '느낌표 표기도 옵셔널이라 nil 대입이 그대로 허용된다. 컴파일러가 막아 준다고 믿으면 빈 값이 들어오는 경로를 놓치게 된다.', false),
(11024, 4068, 'if let이나 guard let으로는 바인딩할 수 없어 nil 비교 연산으로만 유무를 확인해야 한다.', '옵셔널이므로 바인딩이 그대로 된다. 오히려 값이 주입되기 전 접근이 걱정되는 자리에서는 바인딩으로 한 번 걸러 주는 편이 안전하다.', false),
(11025, 4068, '타입 표기를 생략한 다른 변수에 대입하면 비옵셔널로 추론되어 부재 가능성이 사라진다.', '대입 결과는 옵셔널 타입으로 추론된다. 자동 언래핑은 값을 쓸 때 붙는 편의일 뿐, 타입이 품은 부재 가능성을 지워 주지는 않는다.', false),
(11026, 4068, '값이 비어 있는 상태에서 접근하면 느낌표를 직접 쓰지 않은 줄에서도 런타임에 종료된다.', '자동으로 붙는 언래핑은 강제 언래핑과 같은 동작이다. 그래서 뷰가 올라오기 전 아웃렛을 건드리는 것처럼 값이 아직 없을 때는 그 줄에서 바로 크래시가 난다.', true),

-- 문제 4069
(11027, 4069, 'else 블록이 return이나 throw 같은 탈출 없이 그대로 아래로 흘러 내려가기 때문이다.', 'guard의 else는 반드시 현재 스코프를 벗어나야 한다. 로그만 찍고 끝나면 body must not fall through 오류가 난다. 반환 타입에 맞는 값을 돌려주거나 fatalError로 끝내야 한다.', true),
(11028, 4069, '이름을 생략한 축약형은 허용되지 않아 guard let raw = raw 형태로만 쓸 수 있기 때문이다.', 'Swift 5.7부터 바인딩 이름이 원래 이름과 같으면 축약형이 정식 문법이다. 축약 자체는 오류의 원인이 아니다.', false),
(11029, 4069, 'guard로 꺼낸 raw가 guard 블록 안에서만 살아 있어 return 줄에서는 쓸 수 없기 때문이다.', 'if let의 스코프를 guard에 그대로 옮겨 붙인 오해다. guard로 바인딩한 상수는 guard 문 다음 줄부터 함수 끝까지 유효하다.', false),
(11030, 4069, '옵셔널 String?을 비옵셔널 String으로 반환하려면 마지막 줄에 느낌표가 필요하기 때문이다.', '바인딩을 통과한 raw는 이미 비옵셔널 String이라 느낌표를 붙일 필요가 없다. 붙이면 오히려 불필요한 단언이라는 경고 대상이 된다.', false),

-- 문제 4070
(11031, 4070, '서버 응답에서 꺼낸 문자열은 직전 줄에서 nil 검사를 마쳤더라도 느낌표를 붙일 자리가 아니다.', '출처가 외부라 금지 행에 먼저 걸리고, 검사 직후 사용이라는 점에서 지양 행에도 걸린다. 어느 쪽으로 읽어도 허용에 닿지 않으므로 바인딩으로 꺼내야 한다.', false),
(11032, 4070, '아웃렛 프로퍼티에 느낌표를 쓰더라도 뷰가 올라오기 전에 그 값을 건드리면 크래시를 각오해야 한다.', '허용은 주입이 끝난 뒤를 전제로 한 판단이다. 표가 단서로 달아 둔 대로 주입 시점보다 먼저 접근하면 보장이 성립하지 않아 빈 값을 꺼내게 된다.', false),
(11033, 4070, '직전 줄에서 nil 검사를 마친 값은 허용으로 분류되므로, 검사 뒤에는 바인딩보다 느낌표가 낫다.', '표는 이 경우를 허용이 아니라 지양으로 둔다. 검사와 사용이 떨어져 있으면 나중에 검사 줄만 사라지고 느낌표가 남아 크래시로 이어지기 때문이다.', true),
(11034, 4070, '허용으로 분류된 두 경우는 값이 비었을 때 그 사실이 개발·테스트 단계에서 드러난다는 공통점이 있다.', '리터럴은 첫 실행에서, 아웃렛 연결 누락은 화면을 띄우는 순간 드러난다. 반대로 외부 입력은 사용자 기기에서 처음 깨지기 때문에 금지로 분류된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1312, 4071, '옵셔널 체이닝,옵셔널체이닝,optional chaining,옵셔널 체인,?.,?. 연산자', '물음표를 붙인 점 표기로 접근하면 중간 어느 단계에서 nil이 나오는 순간 식 전체가 nil로 끝나고 뒤따르는 접근은 아예 실행되지 않는다. 그래서 같은 계정에서 크래시 대신 nil이 담겼다. 결과 타입은 늘 옵셔널이지만 체인이 길어도 겹치지 않고 한 겹으로 평탄화되어 Int?가 된다. "여기엔 반드시 값이 있다"고 단언하고 없으면 종료시키는 강제 언래핑, 값을 꺼내 새 이름에 담고 없을 때의 분기를 따로 쓰는 옵셔널 바인딩(if let·guard let)과는 역할이 다르다.'),
       (1313, 4072, 'nil 병합 연산자,nil 병합,널 병합 연산자,??,nil coalescing,nil-coalescing,nil coalescing operator,닐 코얼레싱', '왼쪽 옵셔널에 값이 있으면 그 값을, 없으면 오른쪽 값을 돌려주는 ??다. 오른쪽이 비옵셔널이면 식 전체가 비옵셔널로 확정되므로 결과가 String이 된다. 오른쪽 피연산자는 @autoclosure로 감싸여 왼쪽이 nil일 때만 평가되고, 그래서 값이 있는 계정에서는 defaultName()이 호출되지 않았다. 값이 없을 때 식 전체를 nil로 흘려보내는 옵셔널 체이닝과 달리 여기서 부재가 해소되므로, 경계에서 옵셔널을 끊고 내부는 비옵셔널로 다루는 자리에 어울린다.');

-- =====================================================
-- Lesson 806: 열거형 정체와 nil 병합 평가 순서
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5015, 806, '아래 코드를 실행했을 때 출력되는 내용은?', '```swift
var evaluated: [String] = []

func load(_ tag: String) -> String? {
    evaluated.append(tag)
    return tag == "cache" ? nil : tag
}

let memory: String? = nil
let name = memory ?? load("cache") ?? load("disk") ?? "guest"

print(name, evaluated)
```', 'OBJECTIVE'),
       (5016, 806, '아래 실행 결과로 알 수 있는 옵셔널 값의 성질로 옳은 것은?', '```swift
let a: Int? = 5
let b: Int? = nil

print(String(describing: a))   // Optional(5)
print(type(of: a))             // Optional<Int>
print(a == .some(5))           // true
print(b == .none)              // true
```', 'OBJECTIVE'),
       (5017, 806, '아래 코드를 실행했을 때 출력되는 내용은?', '```swift
protocol Tracker: AnyObject {
    func log(_ event: String)
}

final class ConsoleTracker: Tracker {
    var count = 0
    func log(_ event: String) { count += 1 }
}

func report(to tracker: Tracker?, event: String) -> String {
    if tracker?.log(event) != nil {
        return "sent"
    }
    return "skipped"
}

let t = ConsoleTracker()
let first = report(to: t, event: "open")
let second = report(to: nil, event: "open")

print(first, second, t.count)
```', 'OBJECTIVE'),
       (5018, 806, '아래 표를 바탕으로 옵셔널 처리 도구에 대한 설명으로 옳지 않은 것은?', '| 도구 | 값이 없을 때 동작 | 꺼낸 값·결과 타입 |
|---|---|---|
| `if let` | else 분기를 실행한다 | 꺼낸 상수는 if 블록 안에서만 유효 |
| `guard let` | else 블록에서 현재 스코프를 벗어난다 | 꺼낸 상수는 guard 문 다음 줄부터 스코프 끝까지 유효 |
| `?.` | 식 전체가 nil이 되고 뒤쪽 접근을 건너뛴다 | 결과 타입은 항상 옵셔널 |
| `??` | 오른쪽 피연산자를 평가해 그 값을 쓴다 | 오른쪽이 비옵셔널이면 결과도 비옵셔널 |
| `map` | 변환을 적용하지 않고 nil을 유지한다 | 결과 타입은 항상 옵셔널 |', 'OBJECTIVE'),
       (5019, 806, '아래 리팩터링에서 ▢ 자리에 들어간 Swift 키워드는?', '코드 리뷰에서 "중첩이 세 겹이라 정상 흐름이 어디인지 안 보인다"는 지적을 받고 아래처럼 고쳤다.

```swift
// 고치기 전
func parse(_ raw: String?) -> Int? {
    if let raw = raw {
        if let n = Int(raw) {
            if n > 0 { return n * 2 }
        }
    }
    return nil
}

// 고친 뒤 — 들여쓰기가 한 단계로 줄었다
func parse(_ raw: String?) -> Int? {
    ▢ let raw, let n = Int(raw), n > 0 else { return nil }
    return n * 2
}
```

고친 코드를 처음 쓸 때는 else 블록에 print만 넣었다가 `▢ body must not fall through` 오류를 보고 return을 넣었다.', 'SUBJECTIVE'),
       (5020, 806, '아래 상황에서 개발자가 바꿔 부른 표준 라이브러리 메서드의 이름은?', '사용자가 입력한 문자열을 숫자로 바꾸는 화면에서 아래 줄이 컴파일되지 않았다.

```swift
let text: String? = "42"

let n = text.map { Int($0) }   // n의 타입: Int??
let next = n + 1               // 오류: 여기서 n을 숫자로 쓸 수 없다
```

호출하는 메서드 이름 한 곳만 바꾸자 n의 타입이 Int? 한 겹이 되었고, 물음표를 한 번만 풀어 주니 다음 줄이 통과했다. text가 "hello"처럼 숫자로 바꿀 수 없는 값일 때 최종 결과가 비어 있는 것은 바꾸기 전과 같았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5015
(13547, 5015, 'guest ["cache", "disk"]', '왼쪽이 비어 있으면 연쇄의 맨 끝 기본값으로 곧장 간다고 본 오해다. ??는 왼쪽부터 둘씩 짝지어 풀리므로 중간의 load("disk")가 값을 돌려주는 순간 결과가 확정되고 "guest"는 쓰이지 않는다.', false),
(13548, 5015, 'disk ["cache", "disk"]', 'memory가 비어 있어 load("cache")가 평가되지만 이 호출도 nil을 돌려주어 load("disk")까지 평가된다. 여기서 값이 나와 결과는 disk가 되고, 호출 기록에는 두 태그가 부른 순서대로 쌓인다.', true),
(13549, 5015, 'cache ["cache"]', '오른쪽 항이 호출됐으니 그 반환값이 그대로 결과가 된다고 본 오해다. load("cache")는 nil을 돌려주므로 부재가 해소되지 않고 다음 ??로 넘어간다.', false),
(13550, 5015, 'disk []', '??의 오른쪽은 @autoclosure라 아예 평가되지 않는다고 본 오해다. 지연 평가는 왼쪽에 값이 있을 때 건너뛴다는 뜻이고, 왼쪽이 비어 있으면 그 자리에서 평가된다.', false),

-- 문제 5016
(13551, 5016, '물음표를 붙인 표기는 컴파일 단계에서만 쓰이고 실행 시점에는 사라지므로, a는 비옵셔널 5와 같은 값이다.', '물음표가 문법 설탕이라는 말을 타입이 없어진다는 뜻으로 넓힌 오해다. 실행 중에도 a는 감싸진 상태라 출력이 Optional(5)로, 타입이 Optional<Int>로 찍힌다.', false),
(13552, 5016, 'a를 산술식에 그대로 넣으면 컴파일러가 값을 자동으로 꺼내 계산해 준다.', '느낌표를 붙여 선언하는 암시적 언래핑 옵셔널의 동작을 일반 옵셔널에 옮긴 오해다. 물음표로 선언한 값은 바인딩이나 ?? 같은 언래핑을 거치지 않으면 연산 자리에 놓일 수 없다.', false),
(13553, 5016, 'nil이 담긴 b에 메서드를 호출하면 아무 일도 일어나지 않고 조용히 넘어간다.', 'Objective-C에서 nil에 보낸 메시지가 무시되던 동작을 옮긴 오해다. Swift는 언래핑하지 않은 값에 대한 호출을 컴파일 단계에서 막고, 체이닝으로 쓰더라도 결과 타입이 옵셔널로 남는다.', false),
(13554, 5016, 'nil은 값이 비어 있는 특수 상태가 아니라 열거형 케이스 하나여서, 패턴으로 나눠 받을 수 있다.', 'b가 .none과, a가 .some(5)와 같다고 판정된 것이 근거다. 부재는 .none, 존재는 연관값을 가진 .some으로 표현되므로 switch의 case .some(let n)처럼 케이스로 분기할 수 있다.', true),

-- 문제 5017
(13555, 5017, 'sent skipped 1', 'tracker에 값이 있으면 호출이 일어나 식의 결과가 Void를 담은 옵셔널이 되어 nil이 아니고, tracker가 nil이면 호출 자체가 생략되어 식이 nil이 된다. 그래서 첫 호출에서만 count가 오른다.', true),
(13556, 5017, 'sent skipped 2', 'nil 쪽에서도 호출은 되고 결과만 버려진다고 본 오해다. 체이닝은 앞이 비어 있으면 뒤의 메서드를 실행하지 않으므로 count는 한 번만 오른다.', false),
(13557, 5017, 'sent sent 1', '돌려줄 값이 없는 메서드라 nil 비교가 늘 참이 된다고 본 오해다. tracker가 nil이면 식 전체가 nil이 되어 비교가 거짓이 되고 두 번째 호출은 skipped로 간다.', false),
(13558, 5017, 'skipped skipped 0', 'Void를 돌려주는 메서드에 체이닝하면 결과가 늘 nil이라고 본 오해다. 호출이 성사되면 값을 담은 Void?가 되므로 nil 비교만으로 호출 여부를 가려낼 수 있다.', false),

-- 문제 5018
(13559, 5018, '?.로 이어 붙인 식은 결과가 옵셔널이라, 비옵셔널이 필요한 자리에 쓰려면 ??나 바인딩을 한 번 더 거쳐야 한다.', '표에서 ?.의 결과가 항상 옵셔널이고 ??는 오른쪽이 비옵셔널일 때 결과를 비옵셔널로 확정한다. 두 줄을 이어 읽으면 따라 나오는 참인 판단이다.', false),
(13560, 5018, '값이 없을 때 대신 보여 줄 값이 있으면 ??를, 없는 상태를 그대로 흘려보내며 변환만 할 거면 map을 고른다.', '??는 부재를 오른쪽 값으로 메워 없애고, map은 부재를 유지한 채 값이 있을 때만 변환을 적용한다. 부재를 여기서 끝낼지 이어 갈지에 따라 갈리는 참인 판단이다.', false),
(13561, 5018, 'guard let으로 꺼낸 상수는 guard 문 블록 안에서만 살아 있어, 그다음 줄에서 쓰려면 다시 꺼내야 한다.', '표는 guard로 꺼낸 상수가 다음 줄부터 스코프 끝까지 유효하다고 적는다. 블록 안에서만 유효한 쪽은 if let이므로 두 도구의 유효 범위를 맞바꿔 놓은 거짓 진술이다.', true),
(13562, 5018, '값이 없을 때도 뒤이어 처리할 일이 있다면 guard let보다 if let이 어울린다.', 'guard의 else는 스코프를 벗어나는 자리라 뒤이어 할 일을 담기 어렵고, if let의 else는 분기만 하고 흐름이 그대로 이어진다. 두 동작 차이에서 따라 나오는 참인 판단이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1628, 5019, 'guard,guard let,guard-let,guard 문,guard문,가드,가드 문,가드문', '전제 조건이 깨졌을 때 함수 초입에서 흐름을 끊고 나가는 조기 탈출 구문이 guard다. else 블록은 return·throw·break·continue·fatalError처럼 스코프를 벗어나는 문장으로 끝나야 해서, print만 남기면 fall through 오류가 난다. 또 바인딩한 상수가 그 문장 다음 줄부터 함수 끝까지 유효하기 때문에 return n * 2에서 n을 그대로 쓸 수 있고, 그래서 중첩이 한 단계로 줄었다. 같은 바인딩이어도 if let은 꺼낸 상수가 블록 안에서만 살아 있어 조건이 늘수록 중첩이 깊어지며, 값이 없을 때도 이어서 할 일이 있을 때 고른다.'),
       (1629, 5020, 'flatMap,flat map,flatMap(_:),플랫맵,플랫 맵,옵셔널 flatMap', 'map은 클로저가 돌려준 값을 다시 옵셔널로 한 번 감싼다. 클로저 안의 Int(String) 변환 자체가 Int?를 돌려주므로 감싸기가 한 번 더 일어나 Int??가 된 것이다. flatMap은 클로저가 돌려준 옵셔널을 그대로 이어받아 한 겹으로 평탄화하므로 결과가 Int?가 되고, 그래서 물음표를 한 번만 풀면 된다. 변환에 실패했을 때 최종 결과가 비어 있는 것은 두 메서드가 같고 겹의 수만 다르다. 중간이 비면 뒤를 건너뛰는 옵셔널 체이닝(?.)은 프로퍼티·메서드 접근에 쓰는 문법이라는 점, 시퀀스에서 nil을 걸러 내는 compactMap과는 대상이 다르다는 점과 구분한다.');

-- =====================================================
-- Lesson 964: Swift 옵셔널 — 중첩 옵셔널·약한 캡처와 안전한 언래핑 설계
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5963, 964, '아래 코드를 실행했을 때 출력되는 두 줄을 순서대로 나열한 것은?', '```swift
let scores: [String: Int?] = ["kim": 90, "lee": nil]

for key in ["lee", "park"] {
    if let s = scores[key] {
        print("A", s)
    } else {
        print("B")
    }
}
```', 'OBJECTIVE'),
       (5964, 964, '아래 코드를 실행했을 때 출력되는 내용은?', '```swift
final class Screen {
    let name: String
    init(name: String) { self.name = name }

    func makeRefresh() -> () -> String {
        return { [weak self] in
            guard let self else { return "취소" }
            return "\(self.name) 갱신"
        }
    }
}

var screen: Screen? = Screen(name: "홈")
let refresh = screen?.makeRefresh()

let first = refresh?() ?? "없음"
screen = nil
let second = refresh?() ?? "없음"

print(first, second)
```', 'OBJECTIVE'),
       (5965, 964, '아래 요구 사항을 모두 만족하는 코드는?', '서버 설정에서 포트 번호를 읽어 비옵셔널 Int 상수에 담으려 한다. 환경 변수는 `let env = ProcessInfo.processInfo.environment`로 받았고, `env["PORT"]`의 타입은 `String?`이다.

| 상황 | 기대 결과 |
|---|---|
| PORT = "3000" | 3000 |
| PORT 항목이 아예 없음 | 8080 |
| PORT = "abc" | 8080 |

어떤 경우에도 앱이 종료되면 안 되고, 컴파일도 통과해야 한다.', 'OBJECTIVE'),
       (5966, 964, '아래 장애 분석을 바탕으로 코드 개선 방향에 대한 판단으로 옳은 것은?', '[크래시 로그]
Fatal error: Unexpectedly found nil while unwrapping an Optional value
ProfileViewController.swift:42

```swift
// ProfileViewController.swift 42번째 줄
let id = session.userId!
```

원인을 찾는 데 사흘이 걸렸다. userId를 nil로 만든 곳은 42번째 줄이 아니라, 토큰이 만료되면 세션을 비우는 LogoutService였다. 토큰 만료 직후 사용자가 프로필 화면을 열 때마다 크래시가 재현됐다.', 'OBJECTIVE'),
       (5967, 964, '아래 코드에서 ▢ 자리에 추가한 Swift 속성(attribute)의 이름은?', '옵셔널 기본값 처리를 직접 만든 함수로 감쌌더니, value에 값이 있는 경우에도 느린 함수가 매번 호출된다는 측정 결과가 나왔다.

```swift
func loadFromDisk() -> String {
    print("디스크 읽기")          // 약 120ms 걸림
    return "guest"
}

// 고치기 전
func fallback(_ value: String?, _ other: String) -> String {
    if let value { return value }
    return other
}

// 고친 뒤 — other의 타입을 ▢ () -> String으로 바꿨다
func fallback(_ value: String?, _ other: ▢ () -> String) -> String {
    if let value { return value }
    return other()
}

let name = fallback("kim", loadFromDisk())   // 호출하는 줄은 한 글자도 바꾸지 않았다
```

고친 뒤에는 value에 값이 있을 때 "디스크 읽기"가 한 번도 찍히지 않았고, value가 nil일 때만 찍혔다.', 'SUBJECTIVE'),
       (5968, 964, '아래 수정에서 ▢ 자리에 들어간 Swift 연산자는?', '서버 응답을 딕셔너리로 받는 화면에서, 일부 사용자만 화면에 들어서자마자 앱이 종료됐다.

[크래시 로그]
Could not cast value of type ''Swift.String'' to ''Swift.Int''.

```swift
let json: [String: Any] = ["name": "kim", "age": "20"]   // 이 사용자는 age가 문자열로 내려왔다

// 고치기 전
let age = json["age"] as! Int

// 고친 뒤
let age = json["age"] ▢ Int ?? 0
```

수정 후 같은 사용자는 종료 없이 나이가 0으로 표시됐고, age가 숫자로 내려온 사용자는 이전과 같은 값이 나왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5963
(16075, 5963, 'B, B', '값이 nil이면 키가 없는 것과 같다고 본 오해다. 값 타입이 Int?라 lee에는 nil이 값으로 저장되고, 조회 결과는 바깥 상자가 채워진 Int??라서 바인딩이 성공한다.', false),
(16076, 5963, 'A nil, A nil', '없는 키도 값이 nil인 항목처럼 돌려준다고 본 오해다. park는 키 자체가 없어 조회 결과의 바깥 겹부터 nil이므로 바인딩이 실패하고 else로 간다.', false),
(16077, 5963, 'A nil, B', 'lee 조회 결과는 바깥이 .some이고 안에 nil이 든 Int??다. if let은 바깥 한 겹만 벗기므로 s는 nil인 Int?로 바인딩되어 A가 찍힌다. park는 키가 없어 바깥부터 nil이라 B가 찍힌다.', true),
(16078, 5963, 'A Optional(nil), B', '값이 든 옵셔널이 Optional(5)로 찍히는 것을 보고 비어 있을 때도 감싼 채 찍힌다고 본 오해다. 비어 있는 Int?는 출력하면 nil로만 나온다.', false),

-- 문제 5964
(16079, 5964, '홈 갱신 취소', '[weak self]는 참조 카운트를 올리지 않으므로 screen에 nil을 넣는 순간 인스턴스가 해제된다. 두 번째 호출에서는 약한 참조가 nil이라 guard let self가 실패해 취소를 돌려준다.', true),
(16080, 5964, '홈 갱신 홈 갱신', '클로저가 self를 캡처했으니 인스턴스를 계속 붙잡아 둔다고 본 오해다. 강한 캡처라면 그렇지만, weak 캡처는 수명을 늘리지 않아 screen이 비면 곧바로 해제된다.', false),
(16081, 5964, '홈 갱신 없음', 'screen을 nil로 바꾸면 refresh도 nil이 된다고 본 오해다. refresh는 makeRefresh가 돌려준 클로저를 이미 담아 둔 별개의 값이라 그대로 남고, 호출도 정상적으로 된다.', false),
(16082, 5964, '취소 취소', 'weak로 캡처한 참조는 처음부터 비어 있다고 본 오해다. 약한 참조도 대상이 살아 있는 동안에는 그 인스턴스를 가리키므로 첫 호출에서는 guard가 통과한다.', false),

-- 문제 5965
(16083, 5965, 'let port: Int = Int(env["PORT"]!) ?? 8080', 'PORT 항목이 없으면 env["PORT"]!에서 nil을 강제로 꺼내다 종료된다. 숫자 변환 실패는 뒤의 ??가 막아 주지만, 그 앞 단계의 부재는 막아 주지 못한다.', false),
(16084, 5965, 'let port: Int = Int(env["PORT"] ?? "8080")!', '항목이 없을 때는 "8080"이 들어가 통과하지만, "abc"는 Int 변환 결과가 nil이라 마지막 !에서 종료된다. 부재와 변환 실패라는 두 번의 nil 가능성 중 하나만 처리했다.', false),
(16085, 5965, 'let port: Int = env["PORT"].map { Int($0) } ?? 8080', 'map 안의 Int(String)이 Int?를 돌려주므로 결과는 Int??다. ??는 바깥 한 겹만 벗겨 Int?를 남기므로 비옵셔널 Int 상수에 대입할 수 없어 컴파일되지 않는다.', false),
(16086, 5965, 'let port: Int = Int(env["PORT"] ?? "") ?? 8080', '항목이 없으면 빈 문자열로 메워 변환 단계로 넘기고, 빈 문자열과 "abc"는 변환이 nil이 되어 뒤의 ??가 8080으로 메운다. 두 번의 nil 가능성을 각각 ??로 해소해 결과가 비옵셔널 Int로 확정된다.', true),

-- 문제 5966
(16087, 5966, '크래시가 가리킨 42번째 줄이 nil을 만든 곳이므로, 그 줄 바로 위의 로직만 고치면 재발을 막을 수 있다.', '스택 트레이스는 언래핑한 지점만 보여 줄 뿐 nil이 생긴 곳을 알려 주지 않는다. 본문에서도 nil을 만든 곳은 LogoutService였다.', false),
(16088, 5966, '토큰 만료로 실제로 비는 일이 생기는 값이므로, guard let으로 꺼내고 else에서 로그인 화면으로 돌려보내야 한다.', '만료 후 세션이 비는 것은 버그가 아니라 정상적으로 일어나는 상태다. 없을 수 있는 값은 화면 초입에서 guard let으로 해소하고, 없을 때 할 일을 else에 명시해야 한다.', true),
(16089, 5966, 'userId를 String!로 선언을 바꾸면 느낌표를 쓰는 줄이 사라져 같은 상황에서도 크래시가 나지 않는다.', '암시적 언래핑 옵셔널은 접근할 때마다 강제 언래핑이 자동으로 붙는다. 느낌표가 코드에서 안 보일 뿐, 값이 비어 있으면 똑같이 종료된다.', false),
(16090, 5966, '느낌표 대신 ?? ""로 빈 문자열을 넣으면 토큰 만료 상황도 추가 처리 없이 문제없이 넘어간다.', '크래시는 사라지지만 빈 ID로 프로필 요청이 나가 실패가 다른 곳으로 옮겨 가고 원인은 더 숨는다. 합리적인 기본값이 없는 값에 ??를 쓰면 부재를 덮기만 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1944, 5967, '@autoclosure,autoclosure,@autoclosure 속성,오토클로저,오토 클로저,자동 클로저', '호출 자리에 적힌 식을 자동으로 클로저로 감싸, 함수 안에서 호출할 때까지 평가를 미루는 속성이 @autoclosure다. 그래서 호출하는 줄은 그대로인데 value에 값이 있으면 other()가 불리지 않아 loadFromDisk()가 실행되지 않는다. 표준 라이브러리의 ?? 오른쪽 피연산자도 같은 방식이라 왼쪽이 nil일 때만 평가된다. 호출하는 쪽이 { loadFromDisk() }처럼 중괄호를 직접 써야 하는 일반 클로저 매개변수, 클로저가 함수가 끝난 뒤에도 보관될 수 있음을 표시하는 @escaping과 구분한다.'),
       (1945, 5968, 'as?,as? 연산자,조건부 캐스팅,조건부 타입 캐스팅,조건부 다운캐스팅,조건부 형변환,조건부 타입 변환,옵셔널 캐스팅,conditional cast,conditional casting,conditional downcast,conditional downcasting', 'as?는 캐스팅에 실패하면 종료하는 대신 nil을 돌려주는 조건부 캐스팅이다. 그래서 age가 문자열 "20"으로 온 사용자는 결과가 nil이 되고 뒤의 ?? 0이 기본값을 채웠다. 캐스팅에 성공하면 Int?에 값이 담겨 이전과 같은 값이 나온다. 실패하면 곧바로 런타임 종료가 나는 강제 캐스팅 as!, 항상 성공이 보장된 업캐스팅에 쓰는 as와 구분한다. 문자열 "20"을 숫자로 바꾸는 일은 캐스팅이 아니라 Int(String) 이니셜라이저가 할 일이라는 점도 함께 기억하자.');
