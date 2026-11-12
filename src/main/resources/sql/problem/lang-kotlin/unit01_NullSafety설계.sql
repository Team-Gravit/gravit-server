-- Unit: Null Safety 설계 (Unit ID: 196)
-- Chapter: Kotlin (Chapter ID: 19)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (622, 196, '스마트 캐스트와 물음표 위치, 안전 캐스트'),
       (780, 196, '컬렉션 널 처리와 강제 단언 대안'),
       (938, 196, 'Kotlin 널 안전성 — 안전 호출 결과 타입, 자바 널 어노테이션, 널 검증 함수');

-- =====================================================
-- Lesson 622: 스마트 캐스트와 물음표 위치, 안전 캐스트
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3911, 622, '아래 Kotlin 코드를 실행했을 때 출력되는 문자열은?', '```kotlin
data class Address(val city: String?)
data class User(val name: String, val address: Address?)

fun cityOf(user: User?): String = user?.address?.city ?: "UNKNOWN"

fun main() {
    val u1 = User("kim", Address("SEOUL"))
    val u2 = User("lee", Address(null))
    val u3 = User("park", null)
    println(cityOf(u1) + "/" + cityOf(u2) + "/" + cityOf(u3))
}
```', 'OBJECTIVE'),
       (3912, 622, '아래 Kotlin 코드에서 컴파일 에러가 나는 줄은?', 'Repo와 run은 같은 모듈에 있고, 두 프로퍼티에 커스텀 getter는 없다.

```kotlin
class Repo(val id: String?, var cache: String?)

fun run(repo: Repo, input: String?) {
    val snapshot = repo.cache ?: return
    println(snapshot.length)                            // (A)
    if (repo.id != null) println(repo.id.length)        // (B)
    if (repo.cache != null) println(repo.cache.length)  // (C)
    var local: String? = input
    if (local != null) println(local.length)            // (D)
}
```', 'OBJECTIVE'),
       (3913, 622, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 구분 | 널 불가 T | 널 가능 T? | 플랫폼 타입 T! |
| --- | --- | --- | --- |
| 출처 | Kotlin 선언 | Kotlin 선언 | 어노테이션 없는 자바 코드 |
| null 대입 | 컴파일 에러 | 허용 | 허용(검사 없음) |
| 직접 메서드 호출 | 가능 | 불가(안전 호출 필요) | 가능(null이면 런타임 NullPointerException) |', 'OBJECTIVE'),
       (3914, 622, '아래 널 가능성 표기 규칙에 따를 때 옳은 것은?', 'Kotlin에서 물음표를 붙이는 위치는 널 가능성이 원소에 걸리는지 컨테이너 자체에 걸리는지를 가른다. 또 제네릭 타입 파라미터는 상한을 따로 적지 않으면 기본 상한이 Any?다.', 'OBJECTIVE'),
       (3915, 622, '아래 코드에서 (A)의 as를 대신한 Kotlin 연산자는?', '```kotlin
fun describe(value: Any?): String {
    val text = value as String        // (A)
    return "길이 ${text.length}"
}
```

describe(42)를 호출하자 ClassCastException이 나며 프로그램이 멈췄다. (A)의 캐스트 연산자만 다른 것으로 바꾸고 그 뒤에 ?: return "문자열이 아님"을 이어 붙이자, 같은 호출이 예외 없이 "문자열이 아님"을 돌려줬다.', 'SUBJECTIVE'),
       (3916, 622, '아래에서 binding 프로퍼티 선언을 바꿀 때 쓴 Kotlin 키워드는?', '```kotlin
class ProfileScreen {
    private var binding: Binding? = null   // 화면 생성 직후 한 번 채워진다
    fun render() { binding!!.title = "프로필" }
    fun clear()  { binding!!.title = "" }
}
```

접근할 때마다 강제 단언이 붙었고, 값이 비어 있을 때 남는 스택 트레이스에는 어느 단계에서 초기화가 빠졌는지가 드러나지 않았다. 선언을 바꾸자 binding의 타입이 널 불가 Binding이 되어 본문의 강제 단언이 모두 사라졌고, 초기화 전에 render를 부르면 UninitializedPropertyAccessException이 발생해 원인이 바로 보였다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3911
(10603, 3911, 'SEOUL/null/null', '엘비스 연산자를 빼놓고 안전 호출의 결과인 null이 그대로 돌아온다고 본 것. cityOf의 반환 타입이 널 불가 String이라 애초에 null을 내보낼 수 없다.', false),
(10604, 3911, 'SEOUL/UNKNOWN/UNKNOWN', 'u1은 체인 끝까지 null이 없어 SEOUL이 그대로 나온다. u2는 city가, u3는 user 자체가 null이라 각각 식 전체가 null이 되고, 좌변이 null이면 엘비스 연산자가 UNKNOWN을 돌려준다.', true),
(10605, 3911, 'UNKNOWN/UNKNOWN/UNKNOWN', '안전 호출 체인이 걸려 있으면 언제나 기본값으로 대체된다고 본 오해. 엘비스 연산자는 좌변이 null일 때만 동작하므로 u1은 SEOUL이 살아남는다.', false),
(10606, 3911, 'SEOUL/UNKNOWN/null', '엘비스가 마지막 고리인 city가 null인 경우에만 걸린다고 본 오해. 중간 고리인 address나 수신 객체 user가 null이어도 식 전체가 null이 되어 똑같이 기본값이 쓰인다.', false),

-- 문제 3912
(10607, 3912, '(A)', '엘비스로 조기 종료한 뒤라 snapshot은 널 불가 String으로 확정된다. 조기 종료 뒤에도 별도 널 검사가 더 필요하다고 본 오해.', false),
(10608, 3912, '(B)', '커스텀 getter가 없는 같은 모듈의 val 프로퍼티는 검사 뒤에 값이 바뀔 수 없어 스마트 캐스트가 허용된다. 프로퍼티면 무조건 안 된다며 var 규칙을 val까지 넓힌 오해.', false),
(10609, 3912, '(C)', 'var 프로퍼티는 검사와 사용 사이에 다른 스레드가 값을 바꿀 수 있어 컴파일러가 널 불가로 확정하지 못한다. 지역 val에 복사해 스냅샷을 잡은 (A) 방식이 해결책이다.', true),
(10610, 3912, '(D)', '지역 변수는 대입 흐름을 컴파일러가 전부 추적할 수 있어 var라도 스마트 캐스트가 적용된다. var라는 키워드만 보고 거부된다고 본 오해.', false),

-- 문제 3913
(10611, 3913, '널 가능 타입 값을 널 불가 타입 변수에 그대로 대입하면 컴파일러가 막으므로, 엘비스 연산자 등으로 null을 먼저 없애야 한다.', '표의 널 불가 열은 null 대입이 컴파일 에러다. 널 가능 값에는 null이 들어 있을 수 있으니 대입 전에 null을 제거해야 통과한다. 참인 진술이라 답이 아니다.', false),
(10612, 3913, '어노테이션이 없는 자바 메서드의 반환값을 널 불가 타입으로 받으면 컴파일은 통과하지만, null이 오는 순간 그 대입 지점에서 NullPointerException이 난다.', '표에서 플랫폼 타입은 null 대입을 검사 없이 허용한다. 검사를 미룬 대가로 실제 null이 들어오는 실행 시점에 예외가 터진다. 참인 진술이라 답이 아니다.', false),
(10613, 3913, '같은 자바 반환값을 널 가능 타입으로 선언해 두면, 이후 호출마다 컴파일러가 안전 호출을 요구해 널 검사를 강제한다.', '표의 널 가능 열은 직접 메서드 호출이 불가다. 플랫폼 타입을 T?로 고정하면 컴파일러의 강제력을 되찾게 된다. 참인 진술이라 답이 아니다.', false),
(10614, 3913, '플랫폼 타입 값은 안전 호출 없이 메서드를 부를 수 없어, 널 가능 타입과 똑같이 컴파일러가 막아 준다.', '표에서 플랫폼 타입은 직접 메서드 호출이 가능하다. 컴파일러가 막아 주지 않기 때문에 값이 null이면 런타임 NullPointerException으로 이어진다는 점이 플랫폼 타입의 위험이다.', true),

-- 문제 3914
(10615, 3914, '제네릭 함수의 타입 파라미터에 T : Any 상한을 두면 null 인자를 넘기는 호출이 컴파일 단계에서 막힌다.', '상한을 적지 않으면 기본 상한이 Any?라 null이 그대로 통과한다. 상한을 Any로 좁히면 T가 널 불가 타입만 받게 되어 null 인자는 타입 검사에서 걸린다.', true),
(10616, 3914, 'List<String?> 타입 변수는 리스트 참조 자체가 null일 수 있어, 크기를 읽을 때도 안전 호출을 거쳐야 한다.', '물음표 위치를 뒤집어 읽은 오해. 물음표가 원소 쪽에 붙었으므로 리스트 참조는 널 불가라 size를 곧바로 읽을 수 있고, 널 검사가 필요한 쪽은 꺼낸 원소다.', false),
(10617, 3914, '상한을 적지 않은 fun <T> f(x: T)에 f(null)을 넘기면 T가 널 불가로 취급돼 컴파일 에러가 난다.', '기본 상한을 Any로 착각한 오해. 상한을 생략하면 Any?가 기본이라 T에 null도 들어갈 수 있어 호출이 통과한다.', false),
(10618, 3914, 'List<String>? 값에 filterNotNull을 부르면 원소뿐 아니라 리스트 자체의 null까지 함께 걸러진다.', 'filterNotNull이 컨테이너의 null까지 처리한다고 본 오해. 물음표가 리스트 쪽에 붙어 수신 객체가 null일 수 있으니, 안전 호출이나 엘비스로 리스트의 null을 먼저 처리해야 호출이 성립한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1260, 3915, 'as?,안전 캐스트,안전한 캐스트,안전 형변환,safe cast,세이프 캐스트', 'as는 캐스트에 실패하면 ClassCastException을 던지지만 as?는 실패 시 null을 돌려준다. 그래서 엘비스 연산자와 이어 붙이면 타입이 맞을 때만 처리하고 아니면 기본값을 쓰는 흐름이 한 줄로 완성된다. is 검사는 조건 블록 안에서 스마트 캐스트를 얻는 방식이라 값을 곧바로 널 가능 결과로 받는 as?와 쓰임이 다르고, 강제 단언은 null일 때 오히려 예외를 던지므로 예외를 없애려는 이 상황과 방향이 반대다.'),
       (1261, 3916, 'lateinit,lateinit var,레이트이닛', '선언 시점에는 값을 줄 수 없지만 생성 직후 반드시 외부에서 채워지는 널 불가 프로퍼티에 쓰는 것이 lateinit var다. 널 가능 타입으로 두고 강제 단언을 반복하는 대신 타입을 널 불가로 유지할 수 있고, 초기화 전에 접근하면 UninitializedPropertyAccessException이 나므로 NullPointerException보다 원인이 분명하다. by lazy는 val에 붙어 최초 접근 시 스스로 초기화하는 방식이라 외부에서 값을 넣어 주는 lateinit과 구분되며, lateinit은 Int나 Boolean 같은 기본 타입과 널 가능 타입에는 쓸 수 없다.');

-- =====================================================
-- Lesson 780: 컬렉션 널 처리와 강제 단언 대안
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4859, 780, '아래 Kotlin 코드가 출력하는 리스트는?', 'takeIf는 조건이 참이면 자기 자신을, 거짓이면 null을 돌려준다.

```kotlin
fun main() {
    val scores: List<Int?> = listOf(90, null, 75, null, 60)
    println(scores.mapNotNull { it?.takeIf { s -> s >= 75 } })
}
```', 'OBJECTIVE'),
       (4860, 780, '아래 프로퍼티 선언표를 바탕으로 옳지 않은 것은?', '주문 화면 OrderScreen이 가진 프로퍼티 네 개의 선언과, 각 값이 채워지는 시점이다.

| 프로퍼티 | 선언 | 값이 채워지는 시점 |
| --- | --- | --- |
| screenId | lateinit var screenId: String | 화면이 만들어진 직후 onCreate에서 한 번 대입된다 |
| priceTable | val priceTable: PriceTable by lazy { loadFromDisk() } | 어느 자리에서든 처음 읽는 순간 loadFromDisk()가 실행된다 |
| couponCode | var couponCode: String? = null | 사용자가 쿠폰을 넣을 때만 대입되고, 끝까지 넣지 않는 주문도 있다 |
| retryLimit | var retryLimit: Int = 3 | 선언과 동시에 채워진다 |', 'OBJECTIVE'),
       (4861, 780, '아래 요구사항을 지키도록 (A)를 고치는 방법으로 옳은 것은?', '```kotlin
class Profile(val nickname: String?)
class Member(val profile: Profile?)

fun show(member: Member?) {
    val len: Int = member?.profile?.nickname?.length   // (A) 컴파일 에러
    println(len)
}
```

요구사항: len은 널 불가 Int여야 하고, 체인 중간에 null이 있으면 0을 담아야 하며, 어떤 입력에도 예외를 던져서는 안 된다.', 'OBJECTIVE'),
       (4862, 780, '아래 두 함수에 값을 넘길 때의 규칙으로 옳은 것은?', 'Kotlin에서 타입 뒤에 붙는 물음표는 그 타입이 가질 수 있는 값에 null 하나를 더한다는 표시다. 아래 두 함수는 파라미터 타입만 다르다.

```kotlin
fun send(to: String) { }
fun log(to: String?) { }
```', 'OBJECTIVE'),
       (4863, 780, '아래에서 IDE가 String! 으로 보여 준 이 타입을 Kotlin에서 부르는 이름은?', '```kotlin
// 자바 라이브러리의 메서드 — 닉네임을 등록하지 않은 회원에게는 null을 돌려준다.
// public String findNickname(long id) { ... }

val nickname: String = javaRepo.findNickname(1L)   // (A)
println(nickname.length)
```

(A)에서 자바 메서드의 반환값을 널 불가 String으로 그대로 받았는데 컴파일은 오류도 경고도 없이 통과했다. 그러나 배포 뒤 닉네임을 등록하지 않은 회원을 조회하자 (A) 줄에서 NullPointerException이 났다. IDE 툴팁은 findNickname의 반환 타입을 String! 으로 보여 준다.', 'SUBJECTIVE'),
       (4864, 780, '아래에서 (A)의 강제 단언을 대신한 Kotlin 표준 라이브러리 함수는?', '```kotlin
fun pay(orderId: String?, amount: Int) {
    val id = orderId!!          // (A)
    gateway.charge(id, amount)
}
```

결제 실패를 조사하려고 로그를 열었더니 (A)에서 난 예외는 NullPointerException 한 줄뿐이라, 어느 값이 비어 들어왔는지 알 수 없었다. (A)를 표준 라이브러리 함수 하나로 바꾸자 같은 입력에서 IllegalArgumentException: 주문 번호가 비어 있습니다 가 남았고, 그 뒤 코드에서 id는 그대로 널 불가 String으로 다뤄졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4859
(13131, 4859, '[90, 75, 60]', 'mapNotNull을 filterNotNull과 같은 것으로 보고 원소가 null이 아니면 모두 남는다고 본 오해. 60은 조건에 걸려 takeIf가 null을 돌려주므로 변환 결과가 null이 되어 빠진다.', false),
(13132, 4859, '[90, 75]', '원소가 null이면 안전 호출이 걸려 람다 결과가 null이 되고, 75 미만인 60도 takeIf가 null을 돌려준다. mapNotNull은 변환 뒤 null이 된 결과를 모두 버리므로 90과 75만 남는다.', true),
(13133, 4859, '[90, 75, null]', '원본에 들어 있던 null만 걸러 내고 람다가 돌려준 null은 그대로 남는다고 본 오해. mapNotNull이 버리는 기준은 변환 뒤의 결과값이라 60에서 나온 null도 남지 않는다.', false),
(13134, 4859, '[75, 60]', '조건 s >= 75를 75 이하만 남기는 것으로 거꾸로 읽은 것. 부등호 방향대로라면 90도 조건을 만족해 살아남고, 조건에서 걸리는 쪽은 60이다.', false),

-- 문제 4860
(13135, 4860, 'screenId를 onCreate가 끝나기 전에 읽으면 널 참조가 아니라 아직 초기화되지 않았음을 알리는 예외가 나서, 어느 단계가 빠졌는지 바로 드러난다.', '초기화를 미뤄 둔 널 불가 프로퍼티는 값이 채워지기 전에 읽히면 UninitializedPropertyAccessException을 던진다. 널 가능 타입으로 두고 강제 단언을 붙였을 때 남는 NullPointerException보다 원인 지점이 분명하다. 참인 진술이라 답이 아니다.', false),
(13136, 4860, 'priceTable은 여러 곳에서 읽어도 loadFromDisk()가 처음 한 번만 실행되고, 쓰는 자리마다 값이 채워졌는지 확인하는 코드를 둘 필요가 없다.', '최초 접근 때 한 번 초기화한 뒤 그 결과를 재사용하는 것이 지연 초기화의 동작이다. 프로퍼티 타입이 널 불가로 유지되므로 읽을 때마다 널 검사를 되풀이하지 않아도 된다. 참인 진술이라 답이 아니다.', false),
(13137, 4860, 'couponCode는 null이 아님을 확인한 직후에도 그 자리에서 널 불가로 취급되지 않아, 지역 변수에 옮겨 담고 검사해야 널 검사 없이 쓸 수 있다.', '검사와 사용 사이에 다른 코드가 값을 바꿀 수 있는 var 프로퍼티에는 컴파일러가 스마트 캐스트를 적용하지 않는다. 지역 val로 스냅샷을 잡거나 엘비스 연산자로 기본값을 정해야 널 불가로 다룰 수 있다. 참인 진술이라 답이 아니다.', false),
(13138, 4860, 'retryLimit도 lateinit var로 선언해 두면 값을 채우기 전에 읽었을 때 원인이 분명한 예외가 나므로, 기본값을 미리 넣어 둔 지금 방식보다 안전하다.', '표에서 retryLimit의 타입은 Int라 lateinit을 붙이면 실행은커녕 컴파일부터 막힌다. lateinit은 기본 타입과 널 가능 타입에는 쓸 수 없고, 생성 뒤 외부에서 반드시 채워지는 참조 타입 프로퍼티에 쓰는 도구다.', true),

-- 문제 4861
(13139, 4861, '체인 끝의 ?.length 뒤에 ?: 0 을 이어 붙인다.', '안전 호출 체인은 중간 고리가 하나라도 null이면 식 전체가 null이 되어 결과 타입이 Int?다. 엘비스 연산자로 null일 때 쓸 값을 주면 결과가 널 불가 Int가 되고 예외도 나지 않는다.', true),
(13140, 4861, '체인 끝을 !!.length로 바꿔 결과 타입을 Int로 맞춘다.', '타입은 Int가 되어 컴파일은 통과하지만, 닉네임이 없는 입력에서는 단언한 자리에서 NullPointerException이 난다. 예외를 던지지 않아야 한다는 요구를 어긴다.', false),
(13141, 4861, '변수 선언을 val len: Int? 로 바꿔 식의 결과 타입과 맞춘다.', '컴파일은 통과하지만 len이 널 가능 타입이 되고, 값이 없을 때 0이 아니라 null이 담긴다. 타입 불일치를 변수 쪽으로 옮겼을 뿐 요구를 지키지 못한다.', false),
(13142, 4861, '안전 호출 ?. 을 모두 일반 호출 . 로 바꾸고 변수 타입은 그대로 둔다.', '널 가능 타입 수신 객체에는 점 호출을 직접 쓸 수 없어 컴파일 에러가 오히려 늘어난다. 안전 호출을 없애는 것은 널 가능성을 다루는 방법이 아니다.', false),

-- 문제 4862
(13143, 4862, 'String? 변수라도 실행 시점에 담긴 값이 null이 아니면 send 호출이 통과한다.', '컴파일러는 실행 시점의 값이 아니라 선언된 타입을 보고 호출을 검사한다. 널 검사를 코드로 적어 컴파일러가 확인할 수 있을 때만 스마트 캐스트로 통과하고, 그냥 넘기면 막힌다.', false),
(13144, 4862, '두 파라미터는 물음표 표기만 다를 뿐 실제로는 같은 타입이라, 어느 함수에든 값을 서로 바꿔 넘길 수 있다.', '값의 범위가 다르므로 둘은 별개의 타입이다. 널 가능성을 타입 밖의 문제로 본 오해로, Kotlin은 이 차이를 타입 검사 단계에서 따진다.', false),
(13145, 4862, 'String 값은 log에 아무 변환 없이 넘어가지만, String? 값을 send에 넘기려면 null을 먼저 없애야 한다.', 'String? 가 가질 수 있는 값은 String의 값에 null을 더한 것이라, 좁은 쪽 값은 넓은 쪽 자리에 그대로 들어간다. 반대로 넓은 쪽 값에는 null이 섞여 있어 엘비스 연산자 등으로 걷어내야 통과한다.', true),
(13146, 4862, 'log가 더 넓은 범위를 받아 주므로, log에 넘길 수 있는 값이면 send에도 그대로 넘길 수 있다.', '포함 관계를 거꾸로 적용한 오해. 넓은 쪽에 넘길 수 있는 값에는 null이 섞여 있어 좁은 쪽 자리에는 들어가지 못한다. 방향이 통하는 쪽은 그 반대다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1576, 4863, '플랫폼 타입,플랫폼타입,platform type,platformtype,platform-type', '자바 코드에는 널 가능성 정보가 없어 Kotlin은 그 값을 널 불가로도 널 가능으로도 확정하지 않은 채 넘겨받는데, 이 상태가 플랫폼 타입이고 IDE와 컴파일러 메시지에는 T! 로 표시된다. 어느 쪽으로 받을지 개발자가 정하는 자리라 컴파일러가 널 검사를 강제하지 않는다. 그래서 널 가능 타입 T?와 달리 안전 호출 없이 바로 점 호출이 되고, 그 대가로 null이 들어오면 대입이나 호출 지점에서 NullPointerException이 난다. 자바 쪽에 @Nullable / @NotNull 같은 어노테이션이 붙어 있으면 평범한 T? / T로 변환되므로 플랫폼 타입이 아니다. T! 는 소스 코드에 직접 적을 수 없는 표기이므로, 자바를 호출하는 경계에서는 반환값을 명시적으로 T?로 선언해 두는 것이 원칙이다.'),
       (1577, 4864, 'requireNotNull,requireNotNull(),require not null,requirenotnull', '인자가 null이 아니어야 한다는 계약을 코드에 드러내고, 어긋나면 직접 적은 메시지와 함께 IllegalArgumentException을 던지면서 널 불가 타입 값을 돌려주는 것이 requireNotNull이다. 강제 단언은 같은 자리에서 메시지 없는 NullPointerException만 남기므로 어느 전제가 깨졌는지 추적하기 어렵다. 이름이 비슷한 checkNotNull은 함수 인자가 아니라 객체의 상태가 올바른지 점검할 때 쓰고 IllegalStateException을 던지므로, 로그에 남은 예외 종류로 둘을 구분할 수 있다. null일 때 쓸 기본값이 있거나 조용히 빠져나가도 되는 자리라면 엘비스 연산자로 충분하고, requireNotNull은 계약 위반을 즉시 드러내야 할 때 쓴다.');

-- =====================================================
-- Lesson 938: Kotlin 널 안전성 — 안전 호출 결과 타입, 자바 널 어노테이션, 널 검증 함수
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5807, 938, '아래 Kotlin 코드를 실행했을 때 출력되는 문자열은?', '```kotlin
fun tag(s: String?): String = s?.let { "[" + it.uppercase() + "]" } ?: "NONE"

fun main() {
    println(tag("kt") + tag(null) + tag(""))
}
```', 'OBJECTIVE'),
       (5808, 938, '아래 자바 API를 Kotlin에서 호출할 때의 설명으로 옳은 것은?', 'Kotlin 모듈이 아래 자바 클래스를 그대로 가져다 쓴다. 세 메서드의 반환 타입은 모두 자바 String이다.

```java
public class MemberApi {
    @Nullable public String findNickname(long id) { ... }
    @NotNull  public String requireName(long id) { ... }
    public String findEmail(long id) { ... }   // 어노테이션 없음
}
```', 'OBJECTIVE'),
       (5809, 938, '아래 로그를 남긴 (A) 자리의 코드로 옳은 것은?', '```kotlin
fun pay(session: Session?, amount: Int) {
    val s = /* (A) */
    gateway.charge(s.token, amount)   // 이 줄에서 s는 널 불가 Session으로 다뤄진다
}
```

session이 비어 있는 상태로 pay를 부르자 실행이 (A)에서 멈췄고, 로그에는 아래 한 건만 남았다.

```
Exception in thread "main" java.lang.IllegalStateException: 세션이 만료되었습니다
        at PaymentService.pay(PaymentService.kt:42)
```', 'OBJECTIVE'),
       (5810, 938, '아래 실행 결과표를 바탕으로 옳지 않은 것은?', '널 가능 타입 변수 x 하나만 다루는 네 개의 식과, x에 담긴 값에 따른 실행 결과다.

```kotlin
val x: String?
```

| 식 | x가 null일 때 | x가 "ab"일 때 |
| --- | --- | --- |
| (A) x?.length | null | 2 |
| (B) x?.length ?: -1 | -1 | 2 |
| (C) x!!.length | NullPointerException으로 중단 | 2 |
| (D) x?.let { it.length } | null | 2 |', 'OBJECTIVE'),
       (5811, 938, '아래에서 table 프로퍼티 선언에 새로 쓴 Kotlin 문법의 이름은?', '```kotlin
class ReportScreen {
    private val table: PriceTable = loadFromDisk()   // (A)
    fun show() { render(table) }
}
```

(A)는 화면 객체를 만드는 순간 함께 실행돼, 보고서를 한 번도 열지 않는 사용자에게도 화면 진입이 평균 1.2초 걸렸다. 타입을 PriceTable 그대로 두고 val도 유지한 채 선언만 바꾸자 진입 시간은 30ms가 됐다. 디스크 접근 로그는 show를 처음 부른 시점에 한 줄 남았고, show를 열 번 더 불러도 그 줄은 늘어나지 않았다.', 'SUBJECTIVE'),
       (5812, 938, '아래 (A)에 들어갈 Kotlin 표준 라이브러리 함수는?', '센서가 값을 보내지 못한 시점이 null로 남아 있는 관측 데이터다.

```kotlin
val temps: List<Double?> = listOf(21.5, null, 19.0, null, 23.5)

val before = temps.sumOf { it ?: 0.0 } / temps.size   // 12.8
val after  = temps.(A)().average()                    // 21.33
```

before 방식은 빈 자리를 0.0으로 메운 뒤 전체 개수로 나눠, 실제 관측된 세 값의 평균보다 한참 낮은 12.8을 내놨다. (A) 자리에 인자 없는 표준 라이브러리 함수 하나를 부르자 식의 결과 타입이 List<Double>로 좁아져 average()를 곧바로 이어 붙일 수 있었고, 값은 21.33이 됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5807
(15659, 5807, '[KT]NONENONE', '길이 0인 문자열도 값이 없는 것으로 보고 엘비스가 걸린다고 본 오해. 안전 호출이 뒤를 건너뛰는 기준은 수신 객체가 null인지 하나뿐이라, 빈 문자열에도 let 블록은 그대로 실행된다.', false),
(15660, 5807, '[KT]NONE[]', 'kt와 빈 문자열은 null이 아니라 let 블록이 실행돼 각각 [KT]와 []가 되고, 인자가 null인 호출에서만 안전 호출의 결과가 null이 되어 엘비스 우변의 NONE이 쓰인다.', true),
(15661, 5807, 'NONENONENONE', '안전 호출이 붙으면 결과가 늘 null이 된다고 본 오해. 수신 객체가 null이 아니면 let 블록이 돌려준 값이 그대로 식의 값이 되므로 엘비스 우변까지 가지 않는다.', false),
(15662, 5807, '[KT][NULL][]', '수신 객체가 null이어도 블록은 실행되고 it에 null이 담긴다고 본 오해. 안전 호출은 수신 객체가 null이면 블록 자체를 건너뛰므로 it은 널 불가 String만 받는다.', false),

-- 문제 5808
(15663, 5808, 'findNickname의 반환값은 어노테이션과 무관하게 Kotlin 쪽에서 널 가능 여부를 개발자가 직접 골라야 한다.', '자바에 널 어노테이션이 붙어 있으면 Kotlin은 그 정보를 읽어 평범한 널 가능 타입으로 바꿔 받는다. 어느 쪽으로 받을지 개발자에게 선택이 넘어오는 것은 어노테이션이 없는 findEmail이다.', false),
(15664, 5808, 'requireName의 반환값은 안전 호출을 거쳐야만 메서드를 부를 수 있고, 점 호출을 쓰면 컴파일 에러가 난다.', '널이 아님을 밝힌 어노테이션이 붙은 반환값은 널 불가 타입으로 변환되므로 점 호출이 그대로 된다. 안전 호출이 강제되는 쪽은 널 가능 타입으로 변환되는 findNickname이다.', false),
(15665, 5808, 'findEmail의 반환값은 널 불가 String 변수에 그대로 담아도 컴파일이 통과하지만, 실제로 null이 오면 그 대입 지점에서 NullPointerException이 난다.', '널 가능성 정보가 없는 자바 반환값은 컴파일러가 검사를 걸지 않은 채 넘겨받아 어느 타입으로 받든 통과시킨다. 검사를 미룬 대가로 null이 실제로 들어오는 실행 시점에 예외가 터진다.', true),
(15666, 5808, 'findEmail의 반환값은 널 정보가 없으므로 Kotlin이 널 가능 타입으로 확정해, 널 불가 변수에 담으려 하면 컴파일 에러가 난다.', '정보가 없으면 안전한 쪽으로 자동 확정된다고 본 오해. 널 정보가 없는 값은 널 가능·널 불가 어느 쪽으로도 확정되지 않으므로 컴파일러가 이 대입을 막지 않는다.', false),

-- 문제 5809
(15667, 5809, 'session ?: return', '엘비스로 조기 종료하면 예외를 던지지 않고 함수만 빠져나가므로 스택 트레이스가 로그에 남지 않는다. 값이 없을 때 조용히 넘어가는 선택이라 실행이 예외로 멈춘 상황과 맞지 않는다.', false),
(15668, 5809, 'requireNotNull(session) { "세션이 만료되었습니다" }', '메시지는 똑같이 남길 수 있지만 이 함수가 던지는 예외는 IllegalArgumentException이다. 함수에 들어온 인자가 계약을 지켰는지 검증하는 도구라 로그에 적힌 예외 종류와 어긋난다.', false),
(15669, 5809, 'session!!', '강제 단언이 실패하면 개발자가 붙인 메시지 없이 NullPointerException만 남는다. 로그에 적힌 예외 종류도, 만료 사유가 문장으로 남은 것도 설명하지 못한다.', false),
(15670, 5809, 'checkNotNull(session) { "세션이 만료되었습니다" }', '객체나 호출 시점의 상태가 전제를 지키는지 점검하는 함수라, 어긋나면 적어 둔 메시지와 함께 IllegalStateException을 던진다. 통과하면 널 불가 타입 값을 돌려줘 이후 줄에서 s를 그대로 쓸 수 있다.', true),

-- 문제 5810
(15671, 5810, '(C)는 x가 null일 수 있으므로 식의 결과 타입도 널 가능한 Int?이고, 결과를 널 불가 Int 변수에 담으려면 엘비스를 덧붙여야 한다.', '강제 단언은 수신 객체를 널 불가로 확정하고 넘어가므로 식의 결과 타입은 Int다. 널 검사를 더 붙일 필요가 없는 대신, 값이 null이면 표처럼 그 자리에서 예외로 중단된다.', true),
(15672, 5810, '(A)와 (D)는 두 경우 모두 같은 결과를 내지만, (D)는 값이 null이 아닐 때만 실행할 코드를 블록으로 묶어 둘 수 있다.', '표에서 두 식의 결과가 같은 것은 안전 호출이 수신 객체가 null이면 뒤를 통째로 건너뛰기 때문이다. let은 건너뛰는 범위를 한 줄에서 블록으로 넓혀 준다. 참인 진술이라 답이 아니다.', false),
(15673, 5810, '(B)는 x가 null일 때도 -1을 돌려주므로, 결과를 널 불가 Int 변수에 담아도 중단 없이 값이 채워진다.', '엘비스 우변이 null이 들어갈 자리를 메워 주므로 식의 결과 타입이 Int가 되고, 어떤 입력에서도 예외 없이 값이 정해진다. 참인 진술이라 답이 아니다.', false),
(15674, 5810, '(C)는 네 식 가운데 유일하게 값을 돌려주지 못하고 실행을 멈추므로, 널 처리의 실패를 컴파일 시점이 아니라 실행 시점으로 미룬 셈이다.', '나머지 셋은 x가 null이어도 null이나 -1이라는 값으로 흐름이 이어지지만 강제 단언만 그 자리에서 멈춘다. 컴파일러가 해 주던 검사를 개발자가 스스로 해제한 대가다. 참인 진술이라 답이 아니다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1892, 5811, 'by lazy,lazy,by lazy {},lazy {},지연 초기화', '프로퍼티를 선언할 때가 아니라 그 값을 처음 읽는 순간 초기화 블록이 한 번 실행되고, 그 뒤로는 저장해 둔 결과를 그대로 돌려주는 것이 by lazy다. 그래서 보고서를 열지 않는 실행 경로에서는 loadFromDisk()의 비용이 아예 들지 않고, 여러 번 읽어도 디스크 접근은 한 번뿐이라 로그가 늘지 않는다. 널 가능 타입으로 두고 처음 쓸 때 채우는 방법도 같은 지연 효과를 내지만, 타입이 PriceTable?이 되어 읽는 자리마다 안전 호출이나 강제 단언이 따라붙는다. lateinit은 var에 붙여 외부에서 값을 넣어 주는 도구라 val을 유지한 이 상황과 맞지 않고, 스스로 초기화하지 않으므로 처음 읽는 시점에 값이 채워진다는 보장도 없다.'),
       (1893, 5812, 'filterNotNull,filterNotNull(),filter not null,널 제외 필터', '원소가 널 가능한 컬렉션에서 null인 원소를 모두 빼고 타입을 List<Double>로 좁혀 주는 것이 filterNotNull이다. 남은 원소가 널 불가라서 average()처럼 널 불가 값을 요구하는 함수를 바로 이어 붙일 수 있고, 빠진 자리는 개수에서도 제외돼 관측된 세 값만으로 평균이 나온다. 엘비스로 0.0을 채우는 before 방식은 null을 없앤 것이 아니라 값 하나를 끼워 넣은 것이라 나누는 개수가 5로 남아 평균이 낮아진다. mapNotNull은 변환 람다를 받아 변환한 결과가 null인 것을 버리는 함수라 같은 일을 시키려면 { it } 같은 람다를 넘겨야 하므로 인자 없는 호출 자리에는 맞지 않는다. 리스트 참조 자체가 null일 수 있는 List<Double>?에는 이 함수를 곧바로 부를 수 없고 안전 호출이 먼저 필요하다.');
