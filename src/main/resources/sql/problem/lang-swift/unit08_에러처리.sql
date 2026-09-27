-- Unit: 에러 처리 (Unit ID: 227)
-- Chapter: Swift (Chapter ID: 22)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (653, 227, '계층 간 에러 전파와 Result 수집'),
       (811, 227, 'try? 남용과 타입 지정 throws'),
       (969, 227, 'Swift 에러 처리 — defer 순서·Result 가공·에러 변환');

-- =====================================================
-- Lesson 653: 계층 간 에러 전파와 Result 수집
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4097, 653, '아래 표에 정리된 세 가지 호출 방식에 대한 설명으로 옳은 것은?', '| 호출 방식 | 에러가 발생했을 때의 동작 |
| --- | --- |
| `try` | 현재 스코프의 `catch`로 넘어가고, 잡을 곳이 없으면 함수 밖으로 전파된다 |
| `try?` | 에러를 버리고 `nil`을 돌려준다. 호출 결과는 옵셔널이 된다 |
| `try!` | 프로그램이 그 자리에서 중단된다 |', 'OBJECTIVE'),
       (4098, 653, '아래 코드를 실행했을 때 콘솔에 찍히는 내용을 순서대로 나열한 것은?', '```swift
enum FileError: Error { case notFound, corrupted }

func read(_ name: String) throws -> String {
    print("open")
    defer { print("close") }
    guard name == "a.txt" else { throw FileError.notFound }
    return "data"
}

do {
    let text = try read("b.txt")
    print(text)
} catch FileError.corrupted {
    print("corrupted")
} catch {
    print("failed")
}
```', 'OBJECTIVE'),
       (4099, 653, '아래 비교표를 바탕으로 판단할 때 옳지 않은 것은?', '| 구분 | `throws` | `throws(E)` (Swift 6) |
| --- | --- | --- |
| 던질 수 있는 에러 타입 | `any Error` | 구체 타입 `E` 하나 |
| `catch`에서 케이스 나누기 | `as?` 캐스팅과 기본 `catch`가 필요 | `switch`로 완전성 검사 가능 |
| 에러 값 표현 | 박싱 비용이 있음 | 박싱 없음 |
| 에러 케이스를 새로 추가할 때 | 호출부에 영향 없음 | 호출부의 `switch`가 깨질 수 있음 |', 'OBJECTIVE'),
       (4100, 653, '아래 세 계층 코드의 에러 흐름에 대한 설명으로 옳은 것은?', '```swift
// 인프라 계층
func request(_ url: URL) async throws -> Data {
    try await URLSession.shared.data(from: url).0
}

// 서비스 계층
func loadProfile(id: Int) async throws -> Profile {
    let data = try await request(endpoint(id))
    do {
        return try JSONDecoder().decode(Profile.self, from: data)
    } catch {
        throw ProfileError.decoding(underlying: error)
    }
}

// UI 계층
Task {
    do { profile = try await loadProfile(id: 1) }
    catch { showAlert(error) }
}
```', 'OBJECTIVE'),
       (4101, 653, '아래 상황에서 ⓐ 자리에 들어갈 표준 라이브러리 타입의 이름은?', '결제 내역 200건을 각각 외부 API로 검증하는 야간 배치가 있다. 검증 함수를 `try`로 호출하던 때에는 47번째 건에서 던져진 에러 때문에 배치가 그 자리에서 멈춰 나머지 153건이 처리되지 않았다.

검증 함수의 반환 타입을 `ⓐ<Receipt, VerifyError>`로 바꾸고 각 건의 반환값을 배열에 모으도록 고치자, 200건을 끝까지 돌린 뒤 성공 193건 · 실패 7건과 실패 사유별 집계를 한 번에 리포트로 뽑을 수 있었다.', 'SUBJECTIVE'),
       (4102, 653, '아래 상황에서 ⓑ 자리에 넣은 Swift 키워드는?', '컬렉션의 원소를 하나씩 변환하는 고차 함수를 직접 만들었다.

```swift
func transform<T>(_ body: (Element) throws -> T) ⓑ -> [T]
```

ⓑ에 `throws`를 적었을 때는 이 함수를 쓰는 호출부 40여 곳에 모두 `try`가 붙었고, 그중 대부분은 에러가 날 일이 없는 클로저를 넘기면서도 형식적인 `do-catch`를 달아야 했다. ⓑ만 다른 키워드로 바꾸자 그 형식적인 `do-catch`가 전부 사라졌고, 파일을 읽는 클로저를 넘기는 두 곳에서는 컴파일러가 전과 똑같이 `try`를 요구했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4097
(11099, 4097, '`try!`는 실패해도 `nil`을 돌려주므로 옵셔널 바인딩으로 뒤처리하면 중단을 막을 수 있다.', '`try?`의 동작을 `try!`에 갖다 붙인 오개념이다. `try!`는 실패하는 순간 프로그램이 멈추므로 뒤처리할 기회 자체가 없다. 실패가 곧 프로그래머 오류인 번들 리소스 로드 정도에만 쓴다.', false),
(11100, 4097, '`try`로 호출한 함수가 던진 에러를 그 스코프에서 잡지 않으면, 컴파일은 통과하고 런타임에 무시된다.', '전파는 무시가 아니다. 잡을 곳이 없으면 에러가 호출자로 올라가야 하므로 그 함수 역시 `throws`로 선언돼 있어야 하고, 아니면 컴파일 단계에서 오류가 난다.', false),
(11101, 4097, '`try?`로 호출한 지점은 실패해도 원인이 값으로 남지 않아, 결과가 비었을 때 무엇 때문인지 기록할 수 없다.', '에러를 버리고 `nil`만 돌려주니 실패 원인이 사라진다. 디코딩이 깨져 화면이 비었는데 로그조차 없는 상황이 여기서 나온다. 원인이 필요하면 `do-catch`로 받아 남겨야 한다.', true),
(11102, 4097, '`try?`는 호출 결과의 타입을 그대로 두므로, 성공했을 때의 값을 언래핑 없이 곧바로 쓸 수 있다.', '결과가 옵셔널로 한 겹 감싸이므로 언래핑이 필요하다. 이 승격을 놓치면 바인딩이나 `??` 없이 값을 쓰려다 타입이 맞지 않아 컴파일 오류를 만난다.', false),

-- 문제 4098
(11103, 4098, 'open → failed', '`defer`가 에러 상황에서는 건너뛰어진다고 본 오개념이다. `defer`는 정상 반환이든 `throw`든 스코프를 벗어날 때 반드시 실행되므로 `close`가 빠질 수 없다.', false),
(11104, 4098, 'open → close → failed', '`open` 출력 뒤 `guard`가 실패해 `.notFound`가 던져지고, 스코프를 벗어나며 `defer`의 `close`가 찍힌다. 첫 `catch`는 `.corrupted` 패턴이라 맞지 않고 뒤의 기본 `catch`가 받아 `failed`가 남는다.', true),
(11105, 4098, 'open → close → corrupted → failed', '`catch` 절이 모두 실행된다고 본 오개념이다. `catch`는 위에서 아래로 매칭돼 처음 맞는 한 절만 실행되고, 그 뒤 절은 건너뛴다.', false),
(11106, 4098, 'open → close', '첫 `catch` 패턴이 맞지 않으면 `do-catch`를 그냥 빠져나온다고 본 오개념이다. 값 바인딩 없는 마지막 기본 `catch`가 남은 모든 에러를 받으므로 출력이 하나 더 남는다.', false),

-- 문제 4099
(11107, 4099, '`throws(E)` 함수는 `catch`에서 `E`의 모든 케이스를 `switch`로 적으면 기본 `catch`를 두지 않아도 된다.', '에러 타입이 `E` 하나로 확정돼 컴파일러가 완전성을 검사할 수 있다. 그래서 그 밖의 경우를 받는 절이 없어도 처리 누락이 없음을 보장받는다. 참인 진술이라 답이 아니다.', false),
(11108, 4099, '기존 `throws` 함수의 에러를 종류별로 나눠 처리하려면, 호출부가 후보 타입을 직접 지목해 캐스팅해야 한다.', '타입이 `any Error`라 실제 타입은 런타임에야 드러난다. `catch let e as NetworkError`처럼 호출부가 타입을 먼저 알고 있어야 분기가 되므로 참인 진술이다.', false),
(11109, 4099, '실패 종류가 닫혀 있는 모듈 내부 함수라면 `throws(E)` 쪽이 표현 비용과 분기 처리 양쪽에서 이득이다.', '박싱이 없고 `switch` 완전성 검사도 되므로, 케이스가 늘어날 일이 없는 내부 코드에서는 단점 없이 두 이점만 취할 수 있다. 참인 진술이라 답이 아니다.', false),
(11110, 4099, '실패 원인이 앞으로도 늘어날 공개 라이브러리일수록 `throws(E)`로 좁혀 두는 편이 호환성에 유리하다.', '표의 마지막 행에 정면으로 걸린다. `throws(E)`는 에러 케이스를 하나 추가하는 것만으로 호출부 `switch`를 깨뜨리므로, 실패가 늘어날 공개 API에는 오히려 타입 미지정 `throws`가 안전하다.', true),

-- 문제 4100
(11111, 4100, '`request`가 던진 에러는 `loadProfile`의 `do-catch` 밖에서 발생해, 변환되지 않은 채 UI 계층까지 올라간다.', '`do` 블록이 감싼 것은 디코딩 호출뿐이다. 그 앞줄의 `try await request(...)`가 던지면 `catch`를 거치지 않고 곧장 전파되므로, UI가 URLSession 에러를 그대로 받는다. 변환 지점을 넓히려면 `do` 범위를 옮겨야 한다.', true),
(11112, 4100, '`loadProfile`의 `catch`가 함수 전체를 감싸므로, 통신 실패도 `ProfileError.decoding`으로 바뀌어 전달된다.', '`do` 블록의 범위를 함수 전체로 본 오개념이다. `catch`는 바로 위 `do` 블록 안에서 던져진 에러만 받으며, 블록 밖 호출은 그 대상이 아니다.', false),
(11113, 4100, '`Task` 블록 안에서 던져진 에러는 `catch`가 없어도 바깥 스코프로 전파돼 처리된다.', '비구조적 작업은 호출자와 흐름이 끊겨 있다. 안에서 던진 에러는 누군가 `try await task.value`로 꺼내지 않으면 조용히 사라지므로, 블록 안에서 직접 처리하거나 결과를 받아 내야 한다.', false),
(11114, 4100, '디코딩 실패를 `loadProfile`이 안에서 모두 잡아 처리하므로, 시그니처의 `throws`를 지워도 컴파일된다.', '잡은 뒤 `ProfileError`를 다시 던지고 있고, 앞줄의 `request` 호출도 던질 수 있다. 던질 가능성이 하나라도 남으면 시그니처에 `throws` 표시가 있어야 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1322, 4101, 'Result,result,Result 타입,리절트', '성공 값과 실패 원인 중 하나를 담아 두는 표준 라이브러리 열거형이 `Result`다. `throws`는 던지는 순간 흐름이 끊겨 47번째 건에서 배치가 멈추지만, `Result`는 실패가 값이라 200건을 끝까지 돌린 뒤 배열에 모아 집계할 수 있다. 본문의 성공 193건 · 실패 7건 리포트가 그 차이다. 다시 제어 흐름으로 되돌릴 때는 `try result.get()`을 쓴다. 옆 개념과의 경계도 함께 잡아 두자. 실패를 그 자리에서 처리하거나 위로 올리기만 하면 되는 대부분의 함수는 기본이 여전히 `throws`이고, `Result`는 부분 실패 수집·콜백 기반 레거시 API 감싸기·결과 보관처럼 실패를 값으로 들고 있어야 할 때 고른다. 실패 원인을 통째로 버리는 `try?`와 달리 원인이 `Failure` 타입에 그대로 남는다는 점도 구분 포인트다.'),
       (1323, 4102, 'rethrows,rethrows 키워드,리스로우즈', '인자로 받은 클로저가 던질 때만 자신도 던지는 함수임을 표시하는 키워드가 `rethrows`다. 그래서 던지지 않는 클로저를 넘긴 호출부에서는 `try`가 필요 없어지고, 파일을 읽는 클로저를 넘긴 곳에서만 컴파일러가 `try`를 계속 요구한다. 본문에서 형식적인 `do-catch`만 걷힌 이유가 이것이다. 표준 라이브러리의 `map`·`filter`·`forEach`가 모두 같은 방식으로 선언돼 있다. 경계도 함께 기억하자. 함수가 자기 몸통에서 직접 에러를 던진다면 `rethrows`를 쓸 수 없고 `throws`여야 한다. 또 Swift 6의 타입 지정 throws에서는 클로저의 에러 타입을 그대로 전달하는 `throws(E)` 형태로 같은 뜻을 표현할 수 있다.');

-- =====================================================
-- Lesson 811: try? 남용과 타입 지정 throws
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5045, 811, '아래 두 언어의 실패 전파 방식에 대한 설명으로 옳은 것은?', '두 언어 A·B가 실패를 다루는 방식이 다르다.

A는 함수가 실패할 수 있다는 사실을 시그니처에 적어 두고, 그런 함수를 부르는 쪽에는 표식을 반드시 붙이게 한다. 실패가 생겨도 런타임이 호출 스택을 되감지 않고, 컴파일러가 실패를 특별한 반환 값처럼 만들어 호출자에게 건넨다.

B는 시그니처에 아무 표시가 없어도 실패를 던질 수 있고, 던져진 실패는 받아 줄 자리를 만날 때까지 런타임이 스택 프레임을 풀어 가며 거슬러 올라간다.', 'OBJECTIVE'),
       (5046, 811, '아래 코드를 실행했을 때 출력되는 세 값을 순서대로 나열한 것은?', '```swift
enum ParseError: Error { case empty, invalidFormat }

func parseAge(_ text: String) throws -> Int {
    guard !text.isEmpty else { throw ParseError.empty }
    guard let n = Int(text) else { throw ParseError.invalidFormat }
    return n
}

let a = (try? parseAge("42")) ?? -1
let b = (try? parseAge("")) ?? -1

var c = -1
do {
    c = try parseAge("7w")
} catch ParseError.empty {
    c = 0
} catch {
    c = -2
}

print(a, b, c)
```', 'OBJECTIVE'),
       (5047, 811, '아래 상황에서 드러난 에러 처리 방식의 문제로 옳은 것은?', '설정 화면이 저장해 둔 값 대신 늘 초기 상태로 뜬다는 제보가 이어졌다.

코드를 열어 보니 저장된 설정을 읽는 함수가 디코딩 호출을 `try?`로 감싸고, 결과가 비면 새로 만든 기본 설정을 돌려주도록 돼 있었다. 서버 로그에도 크래시 리포트에도 관련 흔적은 남지 않았고, 실제 원인은 앱 업데이트로 바뀐 저장 형식이었다.', 'OBJECTIVE'),
       (5048, 811, '아래 비교표를 바탕으로 판단할 때 옳은 것은?', '| 기준 | `throws` / `try` | `Result` |
| --- | --- | --- |
| 실패를 다루는 성격 | 던지는 순간 흐름이 끊겨 그 자리에서 처리하거나 위로 올린다 | 성공 값과 실패 원인 중 하나를 담은 값이라 변수에 보관할 수 있다 |
| 실패 타입 표기 | 기본은 `any Error` | `Failure` 자리에 구체 타입을 처음부터 적는다 |
| 여러 건을 잇달아 처리할 때 | 첫 실패에서 반복이 멈춘다 | 건별 결과를 그대로 모아 둘 수 있다 |
| `async`/`await` 도입 이후 | `async throws`가 기본 표현이 됐다 | 콜백 API를 감쌀 때 등으로 쓰임이 줄었다 |', 'OBJECTIVE'),
       (5049, 811, '아래 상황에서 대기 현상을 없앤 Swift 키워드는?', '요청을 처리하는 함수가 잠금을 얻고 임시 파일을 연 뒤, 마지막 두 줄에서 파일을 닫고 잠금을 푼다.

```swift
func handle(_ req: Request) throws -> Response {
    lock.acquire()
    let file = try open(req.path)
    let body = try parse(file)
    file.close()
    lock.release()
    return Response(body)
}
```

배포 뒤 형식이 깨진 요청이 들어오면서 `parse`가 실패하기 시작하자, 그 요청들은 에러를 위로 올렸고 이후 같은 자원을 쓰는 요청이 전부 대기 상태에 멈췄다. 서버를 재시작하기 전까지 풀린 잠금은 하나도 없었다.

해제 두 줄을 자원을 얻은 직후 자리로 옮기면서 키워드 하나로 감싸자, 같은 실패가 나도 대기 현상이 사라졌다.', 'SUBJECTIVE'),
       (5050, 811, '아래 상황에서 파서 함수 시그니처에 적용한 Swift 6 기능의 이름은?', '모듈 안에서만 쓰는 파서 함수가 있다. Swift 6로 올린 뒤 이 함수의 시그니처를 한 군데 고쳤더니 호출부가 이렇게 달라졌다.

```swift
// 고치기 전
do { age = try parseAge(text) }
catch let e as ParseError { show(e) }
catch { assertionFailure("여기 올 일 없음") }   // 형식적으로 남겨 둔 절

// 고친 뒤
do { age = try parseAge(text) }
catch {
    switch error {
    case .empty:         show("빈 입력")
    case .invalidFormat: show("형식 오류")
    }
}
```

캐스팅과 형식적으로 남겨 두던 절이 사라졌고, 두 경우 중 하나라도 빠뜨리면 컴파일러가 잡아 줬다. 던지는 쪽도 `throw ParseError.empty` 대신 `throw .empty`로 줄었다. 대신 나중에 실패 경우를 하나 더 추가하자, 이 함수를 쓰던 호출부가 모두 컴파일 오류로 멈췄다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5045
(13627, 5045, 'A는 실패가 위로 올라가는 동안 런타임이 프레임을 풀어내므로, 전파가 깊어질수록 전달 비용이 B보다 크게 쌓인다.', '스택 풀기 비용을 A에 갖다 붙인 오개념이다. A는 실패를 특별한 반환 값처럼 건네므로 전파 깊이에 따른 런타임 비용이 거의 없고, 오히려 프레임을 푸는 쪽은 B다.', false),
(13628, 5045, 'B는 실패를 잡지도 올리지도 않은 호출을 컴파일 단계에서 걸러 내므로, 처리 누락이 실행 중에 드러나는 일이 없다.', 'A의 성질을 B에 옮겨 붙인 오개념이다. B는 시그니처에 표시가 없어도 던질 수 있으니 컴파일러가 처리 여부를 확인할 근거가 없고, 누락은 실행 중에야 드러난다.', false),
(13629, 5045, 'A에서 배열 범위를 벗어난 접근으로 생긴 중단은 이 통로를 타지 않아, 표식을 붙인 호출을 감싸도 받아 낼 수 없다.', 'A는 복구 가능한 실패만 이 통로로 전달한다. 잘못된 인덱스나 깨진 불변식은 코드 자체의 버그라 그 자리에서 즉시 중단시켜 원인을 드러내며, 잡아서 넘길 대상이 아니다.', true),
(13630, 5045, 'B는 실패 종류가 시그니처에 드러나지 않으므로, 호출부가 실패를 확인하려면 반환 값을 옵셔널로 받아 비었는지 살펴야 한다.', '실패를 nil로 바꿔 받는 방식과 던지기를 뒤섞은 오개념이다. B에서 던져진 실패는 반환 값과 별개의 경로로 올라가므로, 반환 타입이 옵셔널로 바뀌는 일은 없다.', false),

-- 문제 5046
(13631, 5046, '42 -1 -2', 'parseAge("42")는 성공해 42가 남고, 빈 문자열은 `.empty`를 던져 `try?`가 nil이 되므로 `??`가 -1을 채운다. "7w"는 `.invalidFormat`이라 `.empty` 절을 지나쳐 뒤의 기본 `catch`가 받아 c는 -2가 된다.', true),
(13632, 5046, '42 -1 0', '`catch` 절이 위에서 아래로 패턴을 맞춰 본다는 점을 놓치고, 첫 절이 모든 에러를 받는다고 본 오개념이다. `.invalidFormat`은 `.empty` 패턴과 맞지 않아 그 절을 건너뛴다.', false),
(13633, 5046, '42 -1 -1', 'do 블록에서 에러가 던져지면 이후 어떤 대입도 일어나지 않아 c가 초기값으로 남는다고 본 오개념이다. 던져진 에러는 반드시 어느 한 `catch` 절로 들어가고, 그 절의 대입이 실행된다.', false),
(13634, 5046, '-1 -1 -2', '`try?`를 붙이면 성공해도 결과가 비어 `??`가 늘 기본값을 쓴다고 본 오개념이다. `??`는 왼쪽이 nil일 때만 오른쪽을 쓰므로, 성공한 호출에서는 42가 옵셔널에서 그대로 꺼내진다.', false),

-- 문제 5047
(13635, 5047, '복구할 대안이 있는 자리이므로 잡은 것 자체는 맞고, 남은 문제는 기본값 대신 `fatalError`로 즉시 멈추지 않은 것이다.', '복구 가능한 실패와 프로그래머 오류를 뒤바꾼 오개념이다. 저장 형식이 바뀐 데이터를 읽지 못한 것은 앱이 감당해야 할 실패라 즉시 중단시킬 대상이 아니다. 즉시 실패는 코드 논리가 깨진 자리에 쓴다.', false),
(13636, 5047, '복구가 일어났다는 사실이 반환 타입에 드러나지 않아, 호출부는 저장된 설정을 읽어 온 경우와 기본값으로 대체된 경우를 구분할 수 없다.', '실패를 값으로도 신호로도 남기지 않고 삼킨 탓이다. 돌려받은 설정만 보면 정상 경로인지 대체된 결과인지 알 수 없으니 증상과 원인을 이을 단서가 끊긴다. 복구하더라도 원인은 기록하고, 판단이 필요한 실패는 위로 올려야 한다.', true),
(13637, 5047, '`try?`를 `try!`로 바꾸면 실패가 크래시 리포트에 남아 원인이 드러나므로, 사용자 기기에서도 안전한 해결책이다.', '`try!`는 실패하는 순간 앱을 중단시킨다. 저장 형식 변경처럼 사용자 기기에서 실제로 일어나는 실패에 쓰면 원인 기록보다 강제 종료가 먼저 남는다. 실패가 곧 코드의 버그인 경우에만 쓴다.', false),
(13638, 5047, '빈 `catch`로 에러를 버린 것이 아니라 기본값이라는 대안을 돌려주고 있으므로, 에러를 삼킨 경우에는 해당하지 않는다.', '삼키기를 빈 `catch`라는 형태로만 좁게 본 오개념이다. 원인을 남기지 않고 아무 일 없었던 듯 흐름을 이어 가면 형태와 무관하게 같은 문제이며, 여기서는 `try?`와 기본값 조합이 그 역할을 한다.', false),

-- 문제 5048
(13639, 5048, '`Result`로 바꾸면 성공 값을 쓰기 전에 실패 여부를 확인하는 단계가 사라져 호출부가 짧아진다.', '실패가 값 안에 들어 있을 뿐 꺼내는 일은 그대로 남는다. `switch`로 두 경우를 나누거나 `get()`으로 다시 제어 흐름으로 되돌려야 하므로, 확인이 없어지는 게 아니라 원하는 시점으로 미뤄지는 것이다.', false),
(13640, 5048, '`async`/`await` 코드에서는 `Result`를 쓸 수 없어, 콜백 API를 감쌀 때도 반드시 `throws`로 고쳐야 한다.', '쓰임이 줄었다는 표의 서술을 쓸 수 없다로 부풀린 오개념이다. 실패를 값으로 보관하거나 건별 결과를 모아야 하는 자리라면 비동기 코드에서도 여전히 유효한 선택이다.', false),
(13641, 5048, '한 건이라도 실패하면 즉시 멈추고 위로 알려야 하는 함수라면, `Result`로 돌려주는 쪽이 호출부가 실패를 놓칠 위험이 적다.', '실패를 값으로 돌려주면 호출부가 성공 경우만 꺼내 쓰고 실패를 조용히 지나쳐도 컴파일러가 막지 않는다. 곧바로 알려야 하는 실패라면 처리나 전파를 강제하는 `throws` 쪽이 놓칠 위험이 적다.', false),
(13642, 5048, '`throws` 함수로 200건을 도는 반복문에서 실패한 건을 건너뛰고 끝까지 돌리려면, 반복문 안에서 `do-catch`로 한 번 더 감싸야 한다.', '표의 셋째 행에서 따라 나오는 결과다. 던지는 순간 흐름이 끊겨 반복 자체가 멈추므로, 끝까지 돌리려면 건별로 받아 줄 자리를 반복문 안에 만들어야 한다. `Result`는 그 자리가 값 안에 이미 들어 있는 셈이다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1638, 5049, 'defer,defer 키워드,defer 블록,디퍼', '자원을 얻은 직후에 해제 코드를 예약해 두면 스코프를 어떤 경로로 벗어나든 그 코드가 실행된다. 이 예약을 맡는 키워드가 `defer`다. 본문에서 재시작 전까지 잠금이 하나도 풀리지 않은 이유는 해제 두 줄이 함수 마지막에 있어, `parse`가 던지는 순간 그대로 건너뛰어졌기 때문이다. 반환 경로가 하나뿐이면 마지막 줄에 두어도 문제가 없지만, 던질 수 있는 호출이 앞에 끼는 순간 출구가 여러 개가 된다. 옆 개념과의 경계도 함께 잡아 두자. `do-catch`는 에러를 받아 처리할 자리를 만드는 장치라 에러를 그대로 위로 올릴 생각이라면 정리 목적으로는 군더더기가 되고, `guard`는 조건이 어긋났을 때 스코프를 일찍 벗어나게 할 뿐 나갈 때 무언가를 대신 실행해 주지는 않는다. 한 스코프에 여러 개를 예약하면 등록한 역순으로 실행되므로, 자원은 얻은 순서의 반대로 풀린다.'),
       (1639, 5050, '타입 지정 throws,타입이 지정된 throws,타입 명시 throws,typed throws,타입드 throws,throws(E)', '던질 수 있는 에러 타입을 시그니처에 하나로 못 박는 Swift 6의 기능이 타입 지정 throws(typed throws)다. `throws(ParseError)`처럼 적으면 `catch`에서 잡히는 `error`가 `any Error`가 아니라 `ParseError`로 확정되므로 캐스팅이 필요 없고, `switch`가 모든 케이스를 덮었는지 컴파일러가 검사해 주니 그 밖의 경우를 받는 형식적인 절을 둘 이유도 사라진다. 타입이 확정된 덕에 던지는 쪽에서도 `throw .empty`로 줄여 쓸 수 있다. 본문 마지막 장면이 이 기능의 대가다. 실패 경우를 하나 추가하면 완전성 검사에 걸려 호출부의 `switch`가 전부 깨지므로, 실패 종류가 늘어날 수 있는 공개 API에는 여전히 타입을 적지 않는 기본형 `throws`가 권장된다. 경계도 함께 기억하자. `throws(Never)`는 아예 던지지 않는다는 뜻이라 `throws`를 붙이지 않은 것과 같고, 박싱이 사라지는 이점은 임베디드 환경처럼 표현 비용이 중요한 곳에서 특히 의미가 있다.');

-- =====================================================
-- Lesson 969: Swift 에러 처리 — defer 순서·Result 가공·에러 변환
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5993, 969, '아래 코드를 실행했을 때 콘솔에 찍히는 내용을 순서대로 나열한 것은?', '```swift
enum NetworkError: Error {
    case invalidURL
    case httpStatus(Int)
}

func fetch() throws {
    defer { print("A") }
    defer { print("B") }
    throw NetworkError.httpStatus(500)
}

do {
    try fetch()
} catch NetworkError.httpStatus(let code) where code == 404 {
    print("not found")
} catch is NetworkError {
    print("network")
} catch {
    print("unknown")
}
```', 'OBJECTIVE'),
       (5994, 969, '아래 코드를 실행했을 때 출력되는 두 값을 순서대로 나열한 것은?', '```swift
enum ParseError: Error { case empty, invalidFormat }

func parseAge(_ text: String) throws -> Int {
    guard !text.isEmpty else { throw ParseError.empty }
    guard let n = Int(text) else { throw ParseError.invalidFormat }
    return n
}

let inputs = ["30", "", "3a"]
let results = inputs.map { s in
    Result { try parseAge(s) }.map { $0 * 2 }
}

var total = 0
var failures = 0
for r in results {
    switch r {
    case .success(let v): total += v
    case .failure: failures += 1
    }
}
print(total, failures)
```', 'OBJECTIVE'),
       (5995, 969, '아래 코드의 에러 처리 방식에 대한 설명으로 옳은 것은?', '```swift
enum RepositoryError: Error {
    case storage(underlying: Error)
}

// 저장소 계층
func saveOrder(_ order: Order) throws {
    do {
        try sqlite.execute(insertQuery(order))
    } catch {
        throw RepositoryError.storage(underlying: error)
    }
}
```

화면 계층은 `saveOrder`를 `try`로 호출하고, 실패하면 알림 창을 띄운다.', 'OBJECTIVE'),
       (5996, 969, '아래 사례 가운데 `throws`로 호출자에게 알리는 것이 알맞은 것만 모두 고른 것은?', '| 사례 | 상황 |
| --- | --- |
| ㉠ | 회원 가입 화면에서 사용자가 나이 칸에 `"스물"`이라고 입력했다 |
| ㉡ | 빌드 과정에서 반드시 앱 번들에 들어가도록 설정한 기본 설정 JSON 파일을 찾지 못했다 |
| ㉢ | 주문 API를 호출했더니 서버가 점검 중이라며 503을 돌려줬다 |
| ㉣ | 같은 모듈 안에서만 부르는 내부 함수에 "항상 0 이상"이어야 하는 개수 인자로 -1이 들어왔다 |', 'OBJECTIVE'),
       (5997, 969, '아래 상황에서 에러 타입에 추가로 채택한 Foundation 프로토콜의 이름은?', '결제가 실패하면 화면 코드가 `error.localizedDescription`을 알림 창에 그대로 띄운다. 카드 한도 초과로 결제가 실패했을 때 사용자에게 보인 문구는 다음과 같았다.

```
The operation couldn’t be completed. (Shop.PaymentError error 1.)
```

`PaymentError` 열거형에 프로토콜 하나를 추가로 채택하고, 케이스마다 `String?`을 돌려주는 속성 하나를 구현했다. 화면 코드는 한 줄도 고치지 않았는데, 같은 실패에서 알림 문구가 "카드 한도를 초과했습니다"로 바뀌었다.', 'SUBJECTIVE'),
       (5998, 969, '아래 코드의 ⓐ 자리에 들어갈 `Result` 메서드의 이름은?', '```swift
enum AppError: Error {
    case network(underlying: URLError)
}

func loadData() -> Result<Data, URLError> { ... }

let result: Result<Data, AppError> = loadData()
    .ⓐ { AppError.network(underlying: $0) }
```

처음에는 ⓐ 자리에 `map`을 적었는데, 클로저가 `Data`를 받는 것으로 해석돼 타입 오류가 났다. ⓐ만 다른 메서드로 바꾸자 컴파일이 통과했고, `loadData`가 성공했을 때의 `Data`는 전과 똑같이 전달됐다. 이후 화면 계층은 `URLError`를 몰라도 `AppError`만 보고 분기할 수 있게 됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5993
(16155, 5993, 'A → B → network', '`defer`가 적힌 순서대로 실행된다고 본 오개념이다. 한 스코프에 여러 `defer`를 등록하면 나중에 등록한 것부터 역순으로 실행되므로 B가 A보다 먼저 찍힌다.', false),
(16156, 5993, 'B → A → not found', '`where` 절을 무시하고 케이스 이름만 맞으면 첫 `catch`가 받는다고 본 오개념이다. 던져진 코드는 500이라 `code == 404` 조건이 거짓이므로 그 절을 건너뛴다.', false),
(16157, 5993, 'B → A → network', '`throw`로 `fetch`를 벗어나며 `defer`가 등록 역순으로 실행돼 B, A가 찍힌다. 첫 `catch`는 `where` 조건(404)이 맞지 않아 건너뛰고, 타입만 확인하는 `catch is NetworkError`가 받아 network가 남는다.', true),
(16158, 5993, 'network → B → A', '`defer`가 에러를 받아 처리한 뒤에 실행된다고 본 오개념이다. `defer`는 자신이 속한 함수 스코프를 벗어나는 순간 실행되므로, 호출자의 `catch`보다 먼저 찍힌다.', false),

-- 문제 5994
(16159, 5994, '60 2', '"30"은 성공해 `map`이 60으로 바꾼다. 빈 문자열은 `.empty`, "3a"는 `Int` 변환 실패로 `.invalidFormat`이 던져져 각각 `.failure`에 담긴다. `Result`는 실패도 값이라 세 건을 모두 돌며 실패 2건이 집계된다.', true),
(16160, 5994, '60 1', '`throws`처럼 첫 실패에서 흐름이 끊긴다고 본 오개념이다. `Result { }`가 던져진 에러를 값으로 붙잡으므로 `inputs.map`은 멈추지 않고 세 번째 입력까지 처리한다.', false),
(16161, 5994, '66 1', '`Int("3a")`가 앞의 숫자 3만 읽어 낸다고 본 오개념이다. `Int(String)`은 문자열 전체가 정수 형식일 때만 값을 돌려주고, 그렇지 않으면 nil이라 `.invalidFormat`이 던져진다.', false),
(16162, 5994, '30 2', '`Result`의 `map`이 성공 값을 가공하지 않는다고 본 오개념이다. `map`은 `.success`일 때만 클로저를 적용해 값을 바꾸고, `.failure`는 그대로 통과시키므로 30은 60이 된다.', false),

-- 문제 5995
(16163, 5995, '원래 에러를 새 에러로 바꿔 던졌으므로, SQLite가 돌려준 원인 에러의 정보는 이 시점에 사라진다.', '변환을 원인 삭제로 본 오개념이다. 원래 에러를 연관값 `underlying`에 담아 던지므로, 상위에서 꺼내 로그로 남기면 SQLite의 실패 원인을 그대로 확인할 수 있다.', false),
(16164, 5995, '`catch` 안에서 다시 던지면 스택 프레임을 풀어 가며 거슬러 올라가는 비용이 한 번 더 든다.', 'Java식 예외를 Swift에 겹쳐 본 오개념이다. Swift의 에러는 런타임 스택 풀기 없이 특별한 반환 값처럼 전달되므로, 다시 던져도 프레임을 푸는 비용이 쌓이지 않는다.', false),
(16165, 5995, '화면 계층이 알림 문구를 고르려면, 받은 에러를 SQLite 에러 타입으로 캐스팅해 분기해야 한다.', '변환의 목적을 거꾸로 본 오개념이다. 저장소 계층이 경계에서 도메인 에러로 감싸 올리므로, 화면은 `RepositoryError`만 보고 분기하면 되고 SQLite라는 구현 세부를 알 필요가 없다.', false),
(16166, 5995, '저장 엔진을 SQLite에서 다른 것으로 바꿔도 같은 방식으로 감싸 던지면, 화면 계층의 분기는 고칠 일이 없다.', '계층 경계에서 저수준 에러를 도메인 에러로 바꿔 올린 덕분이다. 상위는 저장 방식의 세부를 모르고 `RepositoryError`에만 의존하므로, 엔진 교체의 영향이 저장소 계층 안에 갇힌다.', true),

-- 문제 5996
(16167, 5996, '㉢', '사용자 입력 오류를 코드의 버그로 본 오개념이다. 외부에서 들어오는 입력은 언제든 형식이 어긋날 수 있고, 다시 입력받는 식으로 복구할 수 있으므로 ㉠도 호출자에게 알릴 실패다.', false),
(16168, 5996, '㉠, ㉢', '㉠의 잘못된 입력과 ㉢의 서버 점검은 외부 요인이라 재입력·재시도로 복구할 수 있는 실패다. ㉡은 빌드 설정이 깨진 것이고 ㉣은 불변식 위반이라 모두 코드의 버그이므로, 그 자리에서 즉시 멈춰 원인을 드러낸다.', true),
(16169, 5996, '㉠, ㉡, ㉢', '파일을 못 찾았다는 겉모습만 보고 복구 가능한 입출력 실패로 본 오개념이다. 번들에 반드시 들어가도록 한 파일이 없다면 빌드가 잘못된 것이라, 실행 중에 복구할 방법이 없는 프로그래머 오류다.', false),
(16170, 5996, '㉠, ㉢, ㉣', '잘못된 인자를 호출자가 처리할 실패로 본 오개념이다. 같은 모듈 안의 호출이 "항상 0 이상" 조건을 어겼다면 코드 논리가 깨진 것이라, `throws`보다 `precondition`으로 즉시 실패시켜야 원인 지점이 드러난다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1954, 5997, 'LocalizedError,LocalizedError 프로토콜,로컬라이즈드 에러,로컬라이즈드에러', '에러 타입이 `LocalizedError`를 채택하고 `errorDescription`을 구현하면, `localizedDescription`이 그 문구를 돌려준다. 본문에서 화면 코드를 한 줄도 고치지 않았는데 알림 문구가 바뀐 이유가 이것이다. 채택 전에는 시스템이 타입 이름과 케이스 번호로 만든 기본 문구가 나와 사용자에게 아무 정보도 주지 못했다. 전파 전략에서 이 프로토콜은 마지막 단계인 최종 처리, 곧 UI 계층에서 사용자에게 보여 줄 메시지를 만드는 자리에 쓰인다. 옆 개념과의 경계도 짚어 두자. `Error`는 던질 수 있는 타입이 되기 위한 기본 프로토콜일 뿐 표시 문구를 정하지 않고, `CustomStringConvertible`의 `description`은 `print`나 로그에 찍히는 문자열을 바꿀 뿐 `localizedDescription`에는 반영되지 않는다.'),
       (1955, 5998, 'mapError,mapError(_:),Result.mapError,맵에러', '`mapError`는 `Result`가 실패일 때만 클로저를 적용해 실패 쪽 타입을 바꾸고, 성공 값은 그대로 통과시킨다. 본문에서 `Result<Data, URLError>`가 `Result<Data, AppError>`로 바뀌면서도 `Data`가 전과 똑같이 전달된 이유다. 이는 전파 전략의 변환, 즉 계층 경계에서 저수준 에러를 도메인 에러로 감싸 올리는 일을 `Result` 값 위에서 한 것이며, 원인은 연관값 `underlying`에 보존된다. 헷갈리기 쉬운 옆 메서드와 구분하자. `map`은 반대로 성공 값만 가공하므로 클로저가 `Data`를 받아 타입 오류가 났고, `flatMapError`는 클로저가 `Result`를 돌려줘야 하므로 에러 값을 바로 돌려주는 이 클로저와 맞지 않는다. `get()`은 `Result`를 다시 `throws` 흐름으로 되돌리는 메서드다.');
