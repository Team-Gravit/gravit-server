-- Unit: 위임과 프로퍼티 (Unit ID: 202)
-- Chapter: Kotlin (Chapter ID: 19)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (628, 202, '클래스 위임과 lazy 모드, 표준 위임'),
       (786, 202, '맵 위임과 위임 생성 규약, 프로퍼티 참조'),
       (944, 202, 'Kotlin 위임 규약과 프로퍼티 접근자');

-- =====================================================
-- Lesson 628: 클래스 위임과 lazy 모드, 표준 위임
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3947, 628, '아래 Kotlin 클래스의 프로퍼티 선언에 대한 설명으로 옳은 것은?', '```kotlin
class Sensor {
    var celsius: Double = 0.0
        private set

    val isFreezing: Boolean
        get() = celsius <= 0.0

    var label: String = ""
        set(value) {
            field = value.trim()
        }

    fun update(v: Double) {
        celsius = v
    }
}
```', 'OBJECTIVE'),
       (3948, 628, '아래 코드를 실행했을 때 출력되는 값은?', '```kotlin
class CountingSet<T>(
    private val inner: MutableSet<T> = HashSet()
) : MutableSet<T> by inner {

    var added = 0

    override fun add(element: T): Boolean {
        added++
        return inner.add(element)
    }
    // addAll은 오버라이드하지 않았다
}

fun main() {
    val s = CountingSet<String>()
    s.add("a")
    s.addAll(listOf("b", "c", "d"))
    println(s.added)
}
```
(HashSet.addAll은 내부에서 자신의 add를 원소마다 호출한다.)', 'OBJECTIVE'),
       (3949, 628, '아래 비교표를 바탕으로 옳지 않은 것은?', 'lazy(mode) { ... }에 넘길 수 있는 LazyThreadSafetyMode 세 가지다.

| 모드 | 동기화 | 여러 스레드가 동시에 처음 접근할 때 |
|---|---|---|
| SYNCHRONIZED (기본값) | 락으로 보호(이중 검사) | 한 스레드만 계산하고 나머지는 대기했다가 같은 값을 받는다 |
| PUBLICATION | 락 없음, 결과 저장만 원자적 | 여러 스레드가 각자 계산할 수 있으나 첫 결과만 채택된다 |
| NONE | 없음 | 정의되지 않은 동작 (여러 번 계산·값 불일치 가능) |', 'OBJECTIVE'),
       (3950, 628, '아래 코드의 출력으로 옳은 것은?', '```kotlin
import kotlin.properties.Delegates

class Form {
    val log = mutableListOf<String>()

    var email: String by Delegates.vetoable("none@x.com") { _, _, new ->
        "@" in new
    }

    var name: String by Delegates.observable("무명") { _, old, new ->
        log += "$old→$new"
    }
}

fun main() {
    val f = Form()
    f.email = "wrong-address"
    f.name = "지수"
    println("${f.email} / ${f.log}")
}
```', 'OBJECTIVE'),
       (3951, 628, '아래 상황에서 프로퍼티 선언을 대신할 Kotlin 표준 라이브러리 위임의 이름은?', '다운로더는 응답 헤더가 도착해야 전체 크기를 알 수 있어, Int 프로퍼티 totalBytes를 일단 0으로 채워 두고 헤더를 받는 시점에 대입했다.

- 헤더보다 진행률 계산이 먼저 실행된 날에는 0으로 나누는 예외가 터졌다.
- 다른 경로에서는 진행률이 조용히 0%로 표시돼 원인을 찾는 데 하루가 걸렸다.

그래서 `lateinit var totalBytes: Int`로 바꿔 봤지만 ``''lateinit'' modifier is not allowed on properties of primitive types`` 오류가 나 쓸 수 없었다.', 'SUBJECTIVE'),
       (3952, 628, '아래 코드가 컴파일되도록 두 함수 선언 앞에 붙여야 하는 키워드는?', '```kotlin
import kotlin.reflect.KProperty

class Cell<T>(private var v: T) {
    fun getValue(thisRef: Any?, property: KProperty<*>): T = v

    fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        v = value
    }
}

class Row {
    var name: String by Cell("")   // 여기서 컴파일 오류
}
```

컴파일 오류:
```
type ''Cell<String>'' has no method
''getValue(Row, KProperty<*>)'' and thus it cannot serve as a delegate
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3947
(10699, 3947, 'label에 앞뒤 공백이 붙은 값을 대입하면 setter 안의 대입이 setter를 다시 불러 무한 재귀에 빠진다.', 'field는 프로퍼티 이름이 아니라 backing field를 직접 가리키는 식별자라 접근자를 다시 타지 않는다. setter 안에서 label = value.trim()이라고 썼을 때 무한 재귀가 난다.', false),
(10700, 3947, 'celsius에는 private set이 붙어 있어 같은 클래스의 update()에서도 값을 바꿀 수 없다.', 'private set은 setter의 가시성만 클래스 내부로 좁힌 것이라 외부에서만 쓰기가 막힌다. update()는 같은 클래스 안이므로 celsius = v 대입이 정상 컴파일된다.', false),
(10701, 3947, 'isFreezing에는 값을 담는 저장 공간이 없어, 읽을 때마다 celsius를 다시 비교한 결과를 돌려준다.', 'getter가 field를 한 번도 쓰지 않으면 backing field가 생성되지 않는다. isFreezing은 celsius <= 0.0을 매번 계산하므로 celsius가 바뀌면 결과도 따라 바뀐다.', true),
(10702, 3947, 'isFreezing은 val이므로 처음 읽은 결과가 저장되고, 이후 celsius가 바뀌어도 같은 값을 돌려준다.', 'val은 재대입 금지일 뿐 캐시가 아니다. 최초 계산 결과를 저장해 두고 재사용하려면 by lazy로 위임해야 하며, 커스텀 getter는 접근할 때마다 다시 실행된다.', false),

-- 문제 3948
(10703, 3948, '0', 'MutableSet 구현을 inner에 넘겼으니 add 호출도 전부 inner로 전달된다고 본 것. 명시적으로 오버라이드한 멤버는 컴파일러가 만드는 전달 메서드를 대체하므로 s.add 한 번이 그대로 집계된다.', false),
(10704, 3948, '1', 'addAll은 오버라이드하지 않아 컴파일러가 생성한 전달 메서드가 inner.addAll을 부른다. 위임 객체는 자신을 감싼 래퍼를 모르므로 inner 내부의 add 호출은 CountingSet.add를 거치지 않아, 직접 부른 add 한 번만 집계된다.', true),
(10705, 3948, '3', '직접 부른 add는 위임으로 흘러가고 addAll이 넣은 원소 수만 집계된다고 본 것. 실제 관계는 정반대로, 오버라이드한 add는 잡히고 오버라이드하지 않은 addAll이 위임으로 넘어간다.', false),
(10706, 3948, '4', 'inner.addAll이 내부에서 add를 부를 때 래퍼의 오버라이드가 실행된다고 보고 1+3으로 센 것. 상속이라면 그렇지만 위임에서는 위임 객체의 자기 호출이 래퍼를 거치지 않는다.', false),

-- 문제 3949
(10707, 3949, 'PUBLICATION은 락을 쓰지 않는 대신 초기화 람다가 정확히 한 번만 실행되도록 보장한다.', '표의 PUBLICATION은 여러 스레드가 각자 계산할 수 있고 첫 결과만 채택된다. 원자적인 것은 결과 저장이지 람다 실행 횟수가 아니므로 거짓이다. 실행 한 번을 보장하려면 SYNCHRONIZED가 필요하다.', true),
(10708, 3949, '여러 스레드가 함께 읽는 값이고 초기화가 정확히 한 번이어야 한다면 모드를 지정하지 않아도 된다.', '참. 기본값이 SYNCHRONIZED이고 이 모드는 락으로 보호해 한 스레드만 계산하므로, 인자 없이 lazy { }만 써도 초기화가 한 번이라는 요구가 충족된다.', false),
(10709, 3949, 'NONE으로 선언한 값을 두 백그라운드 스레드가 동시에 처음 읽으면 서로 다른 인스턴스를 받을 수 있다.', '참. NONE은 동기화가 전혀 없어 동시 첫 접근이 정의되지 않은 동작이다. 람다가 여러 번 실행돼 스레드마다 다른 결과를 쥘 수 있으므로 단일 스레드가 확실할 때만 고른다.', false),
(10710, 3949, 'PUBLICATION에서는 계산이 여러 번 일어나도 이후 모든 스레드가 읽는 값은 서로 같다.', '참. 결과 저장이 원자적이라 먼저 저장된 첫 결과만 채택되고 이후 접근은 모두 그 값을 읽는다. 계산 횟수가 여러 번인 것과 최종 값이 하나로 모이는 것은 별개다.', false),

-- 문제 3950
(10711, 3950, 'none@x.com / []', 'observable 콜백이 프로퍼티 초기화 때만 불린다고 본 것. observable은 대입이 일어난 뒤 매번 콜백을 호출하므로 name 대입이 log에 남는다.', false),
(10712, 3950, 'wrong-address / [무명→지수]', 'vetoable 콜백이 false를 돌려줘도 대입은 성사되고 알림만 막힌다고 본 것. vetoable은 false면 변경 자체를 거부해 email이 초기값 none@x.com으로 남는다.', false),
(10713, 3950, 'none@x.com / [지수→무명]', '콜백의 두 번째·세 번째 인자를 뒤집어 읽은 것. 인자 순서는 (property, old, new)라 old가 무명, new가 지수이므로 기록도 무명→지수 방향이다.', false),
(10714, 3950, 'none@x.com / [무명→지수]', 'vetoable은 @가 없는 wrong-address를 거부해 email이 초기값 그대로다. observable은 값이 바뀐 뒤 (old, new)로 콜백하므로 log에 무명→지수 한 건만 쌓인다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1272, 3951, 'Delegates.notNull(),Delegates.notNull,notNull(),notNull,Delegates.notNull<Int>()', 'Delegates.notNull()은 값이 채워지기 전에 읽으면 예외를 던지는 var 위임이라, 0 같은 가짜 초기값을 두지 않고도 늦은 초기화를 표현한다. 가짜 초기값이 만든 0으로 나누기 예외와 조용한 0% 표시가 곧바로 원인 지점에서 드러난다. lateinit은 Int·Long 같은 기본 타입에 쓸 수 없어 이 자리를 대신하지 못하고, lazy는 val 전용이며 값을 스스로 계산하므로 외부에서 나중에 대입하는 이 상황과 맞지 않다.'),
       (1273, 3952, 'operator,operator 키워드,operator 변경자,operator modifier', '위임 프로퍼티의 getValue/setValue는 이름으로 직접 호출되는 것이 아니라 관례(convention)로 호출되므로, operator 변경자가 붙어야 컴파일러가 위임 규약으로 인정하고 접근자 코드를 생성한다. ReadOnlyProperty·ReadWriteProperty를 구현하는 방식에서는 인터페이스 멤버가 이미 operator라 따로 붙일 필요가 없다. override는 상위 선언이 있을 때만 쓰고, infix는 인자 하나짜리 중위 호출용이라 이 자리와 무관하다.');

-- =====================================================
-- Lesson 786: 맵 위임과 위임 생성 규약, 프로퍼티 참조
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4895, 786, '아래 코드를 실행한 뒤 출력되는 한 줄은?', '```kotlin
class Profile(private val map: MutableMap<String, Any?>) {
    var nickname: String by map
    var level: Int by map
}

fun main() {
    val m = mutableMapOf<String, Any?>("nickname" to "곰", "level" to 3)
    val p = Profile(m)

    p.nickname = "여우"
    m["level"] = 7

    println(m["nickname"].toString() + " / " + p.level)
}
```', 'OBJECTIVE'),
       (4896, 786, '아래 코드에서 쓰인 위임 생성 규약에 대한 설명으로 옳은 것은?', '```kotlin
class Config(private val source: Map<String, String>) {
    val dbUrl: String by required()
    val port: String by required()

    private fun required() = PropertyDelegateProvider { _: Config, prop ->
        val v = source[prop.name] ?: error("설정 키 없음: " + prop.name)
        ReadOnlyProperty<Config, String> { _, _ -> v }
    }
}

// source에는 dbUrl 키만 있고 port 키는 없다
val config = Config(mapOf("dbUrl" to "jdbc:postgresql://db:5432/app"))
```', 'OBJECTIVE'),
       (4897, 786, '아래 여섯 번의 호출 동안 auth.issueToken()이 실행된 횟수는?', '```kotlin
class ApiClient(private val auth: AuthApi) {
    // 발급에 실패하면 issueToken()이 던진 예외가 그대로 전파된다
    private val token: String by lazy { auth.issueToken() }

    fun call(path: String) {
        // token을 읽어 Authorization 헤더에 넣고 요청한다
    }
}
```

ApiClient 인스턴스 하나를 단일 스레드에서 공유하며 call()을 여섯 번 호출한 로그다. 인증 서버는 10:02:30에 복구됐다.

```
10:02:11  call(/a)  실패 - connection refused
10:02:19  call(/b)  실패 - connection refused
10:02:26  call(/c)  실패 - connection refused
10:02:34  call(/d)  성공
10:02:41  call(/e)  성공
10:02:48  call(/f)  성공
```', 'OBJECTIVE'),
       (4898, 786, '아래 코드의 마지막 줄이 출력하는 값은?', '```kotlin
class User {
    var displayName: String = "guest"

    @Deprecated("displayName을 쓰세요")
    var nickname: String by this::displayName
}

fun main() {
    val u = User()

    u.nickname = "하늘"
    u.displayName = "바다"

    println(u.nickname + " / " + u.displayName)
}
```', 'OBJECTIVE'),
       (4899, 786, '아래 코드의 빈칸에 들어갈 Kotlin 키워드는?', '```kotlin
interface UserRepository {
    fun findById(id: Long): String
    fun save(name: String)
    fun deleteAll()
}

class LoggingRepository(
    private val inner: UserRepository
) : UserRepository ____ inner {

    override fun save(name: String) {
        println("save: " + name)
        inner.save(name)
    }
    // findById와 deleteAll은 직접 구현하지 않는다
}
```

빈칸을 비운 채 컴파일하면 아래 오류가 난다.

```
Class ''LoggingRepository'' is not abstract and does not implement
abstract member public abstract fun findById(id: Long): String
defined in UserRepository
```', 'SUBJECTIVE'),
       (4900, 786, '아래 사고를 막기 위해 point 선언에 덧붙여야 하는 한 줄은?', '```kotlin
class Wallet {
    var point: Int = 0

    fun earn(amount: Int) {
        point += amount
    }

    fun use(amount: Int) {
        require(amount <= point) { "포인트 부족" }
        point -= amount
    }
}
```

사고 보고

- 결제 모듈이 `wallet.point = -5000`처럼 직접 대입해 잔액이 음수인 계정이 37건 나왔다. use()의 require는 한 번도 걸리지 않았다.
- 대시보드 모듈의 `println(wallet.point)`는 앞으로도 그대로 컴파일돼야 한다.
- earn()·use() 안의 대입은 한 글자도 고치지 않는다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4895
(13227, 4895, '곰 / 3', '위임 객체가 생성 시점에 맵 값을 복사해 따로 보관한다고 본 것. by map은 값을 복사하지 않고 읽기와 쓰기를 모두 맵으로 전달하므로 양쪽 변경이 서로 보인다.', false),
(13228, 4895, '여우 / 3', '쓰기는 맵에 반영되지만 읽기는 처음 읽은 값을 캐시한다고 본 것. 값을 캐시하는 것은 by lazy이고, 맵 위임의 getValue는 접근할 때마다 프로퍼티 이름을 키로 맵을 다시 조회한다.', false),
(13229, 4895, '곰 / 7', '읽기만 맵을 보고 쓰기는 프로퍼티 자신의 저장 공간에 한다고 본 것. var를 MutableMap에 위임하면 setValue가 맵에 프로퍼티 이름을 키로 값을 넣으므로 맵 자체가 바뀐다.', false),
(13230, 4895, '여우 / 7', '프로퍼티 이름이 곧 맵의 키다. p.nickname 대입이 맵의 nickname 항목을 여우로 바꾸고, 맵에 직접 넣은 level 값 7은 p.level을 읽는 순간 그대로 조회돼 나온다.', true),

-- 문제 4896
(13231, 4896, 'port를 한 번도 읽지 않는 실행 경로에서는 키 검증이 일어나지 않아 예외 없이 끝난다.', '검증은 값을 읽을 때가 아니라 위임 객체를 만드는 순간 일어난다. dbUrl과 port 모두 Config 생성자에서 초기화되므로, port를 끝내 읽지 않아도 설정 키 없음 예외를 피할 수 없다.', false),
(13232, 4896, '없는 설정 키는 그 값을 처음 읽는 코드가 아니라 Config 인스턴스를 만드는 지점에서 예외로 드러난다.', 'provideDelegate는 프로퍼티가 초기화될 때 한 번 불려 위임 객체를 만들어 준다. 그 안에서 키를 확인하므로 source에 port가 없으면 Config 생성 자체가 실패해 오류가 사용처보다 앞에서 잡힌다.', true),
(13233, 4896, 'provideDelegate는 프로퍼티를 읽을 때마다 호출되므로 dbUrl을 조회할 때마다 키 검증이 되풀이된다.', '읽을 때마다 불리는 것은 위임 객체의 getValue다. provideDelegate는 위임을 만들 때 한 번만 호출되므로 검증 비용이 조회마다 얹히지 않는다.', false),
(13234, 4896, 'required()가 돌려준 PropertyDelegateProvider가 그대로 위임 객체가 되어 dbUrl 읽기에서 그 객체의 getValue가 불린다.', 'provideDelegate가 정의돼 있으면 그 반환값이 위임 객체 자리를 대신한다. 여기서는 ReadOnlyProperty가 위임이 되고 읽기는 그쪽 getValue로 간다.', false),

-- 문제 4897
(13235, 4897, '1', 'lazy가 첫 접근에서 딱 한 번 실행되고 그 결과를 무조건 저장한다고 본 것. 람다가 예외로 끝나면 저장할 값이 없어 초기화가 끝나지 않은 상태로 남는다.', false),
(13236, 4897, '3', '예외로 끝난 세 번만 센 것. 값을 실제로 만들어 낸 /d 호출에서도 람다가 실행됐고, 그때 성공한 값이 저장돼 뒤의 호출이 재사용한다.', false),
(13237, 4897, '4', '/a·/b·/c는 람다가 예외로 끝나 값이 저장되지 않았고, 그래서 접근할 때마다 다시 실행됐다. 서버가 복구된 뒤 /d에서 네 번째로 실행돼 성공했고 그 값이 저장되므로 /e·/f는 람다를 돌리지 않는다.', true),
(13238, 4897, '6', 'lazy를 접근할 때마다 다시 계산하는 커스텀 getter처럼 본 것. 초기화가 한 번 성공하면 값이 캐시되므로 /e·/f에서는 람다가 실행되지 않는다.', false),

-- 문제 4898
(13239, 4898, '바다 / 바다', '다른 프로퍼티로 위임하면 nickname에는 저장 공간이 따로 생기지 않고 읽기와 쓰기가 모두 displayName으로 전달된다. 두 대입이 같은 자리를 건드리므로 나중에 실행된 바다가 최종 값이다.', true),
(13240, 4898, '하늘 / 바다', 'nickname이 자기 backing field를 갖는다고 본 것. by로 위임한 프로퍼티는 backing field 없이 접근자만 만들어지므로, nickname을 읽으면 displayName의 현재 값이 나온다.', false),
(13241, 4898, 'guest / 바다', '위임이 선언 시점의 값을 한 번 복사해 둔다고 본 것. 다른 프로퍼티를 가리키는 위임은 값 복사가 아니라 접근 전달이라, 원본이 바뀌면 읽는 값도 따라 바뀐다.', false),
(13242, 4898, '하늘 / 하늘', '대입 순서를 뒤집어 읽어 nickname 대입을 마지막 상태로 본 것. 하늘을 넣은 뒤 바다를 넣었고 두 프로퍼티가 같은 저장 공간을 쓰므로 최종 값은 바다다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1588, 4899, 'by,by 키워드,by 예약어,by inner', '인터페이스 이름 뒤에 by와 위임 객체를 적으면, 오버라이드하지 않은 멤버마다 inner로 넘기는 전달 메서드를 컴파일러가 만들어 준다. 그래서 findById·deleteAll을 직접 쓰지 않아도 구현 누락 오류가 사라지고, save만 가로채 로그를 남길 수 있다. 상속(: UserRepository 구현체 확장)은 기반 클래스 구현 세부에 묶이고, 전달 메서드를 손으로 쓰는 방법은 인터페이스에 멤버가 늘 때마다 보일러플레이트가 늘어난다. 같은 by 키워드가 프로퍼티 위임(val x: T by lazy { })에도 쓰이지만, 클래스 위임은 인터페이스 구현 전체를 넘기는 쪽이다.'),
       (1589, 4900, 'private set,private set 접근자,private setter,setter를 private로,set을 private로', 'var 선언 다음 줄에 private set을 두면 setter의 가시성만 클래스 내부로 좁혀진다. earn()·use()의 대입은 같은 클래스 안이라 그대로 컴파일되고, 대시보드의 읽기는 getter가 public이라 살아 있으며, 결제 모듈의 직접 대입만 컴파일 단계에서 막힌다. val로 바꾸면 클래스 안의 대입까지 막혀 earn()·use()가 깨지고, 프로퍼티 자체를 private으로 감추면 대시보드 조회가 컴파일되지 않는다. 가시성만 바꾸는 장치라 재대입 자체를 금지하는 val과는 성격이 다르다.');

-- =====================================================
-- Lesson 944: Kotlin 위임 규약과 프로퍼티 접근자
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5843, 944, '아래 코드를 실행하면 마지막 println이 출력하는 log의 내용은?', '```kotlin
import kotlin.properties.ReadWriteProperty
import kotlin.reflect.KProperty

class Audited<T>(
    private var value: T,
    private val log: MutableList<String>
) : ReadWriteProperty<Any?, T> {

    override fun getValue(thisRef: Any?, property: KProperty<*>): T = value

    override fun setValue(thisRef: Any?, property: KProperty<*>, newValue: T) {
        if (value != newValue) {
            log += "${property.name}: $value -> $newValue"
            value = newValue
        }
    }
}

class Profile(log: MutableList<String>) {
    var email: String by Audited("a@x.com", log)
    var age: Int by Audited(20, log)
}

fun main() {
    val log = mutableListOf<String>()
    val p = Profile(log)

    p.email = "b@x.com"
    p.age = 20
    p.age = 31

    println(log)
}
```', 'OBJECTIVE'),
       (5844, 944, '아래 비교표에서 도출되는 설명으로 옳지 않은 것은?', '같은 래퍼 기능을 상속으로 만들 때와 클래스 위임(`by`)으로 만들 때를 비교한 표다.

| 항목 | 상속 (부모 클래스 확장) | 클래스 위임 (`class W(inner: I) : I by inner`) |
|---|---|---|
| 직접 구현하지 않은 멤버 | 부모 구현이 그대로 쓰인다 | 컴파일러가 inner로 넘기는 전달 메서드를 만든다 |
| 기반 객체의 자기 호출 | 부모 메서드가 내부에서 부르는 멤버도 자식의 오버라이드를 거친다 | inner는 래퍼의 존재를 모르므로 래퍼의 오버라이드를 거치지 않는다 |
| 쓸 수 있는 대상 | 부모 클래스가 open이어야 한다 | 인터페이스에만 쓸 수 있고, 위임 객체의 클래스는 final이어도 된다 |
| 대상 교체 | 확장한 부모 타입이 컴파일 시점에 고정된다 | 같은 인터페이스를 구현한 다른 객체를 생성자로 넣어 바꿀 수 있다 |', 'OBJECTIVE'),
       (5845, 944, '아래 코드를 실행하면 마지막 줄에 출력되는 값은?', '```kotlin
class Dashboard {
    var visitors: Int = 10

    val byGetter: Int
        get() = visitors * 2

    val byLazy: Int by lazy { visitors * 2 }
}

fun main() {
    val d = Dashboard()
    println(d.byLazy)

    d.visitors = 50
    println("${d.byGetter} / ${d.byLazy}")
}
```', 'OBJECTIVE'),
       (5846, 944, '아래 코드를 실행하면 출력되는 한 줄은?', '```kotlin
import kotlin.reflect.KProperty

class Tracer(private val v: String) {
    operator fun getValue(thisRef: Any?, property: KProperty<*>): String {
        println("${thisRef?.javaClass?.simpleName} / ${property.name}")
        return v
    }
}

// Main.kt 파일의 최상위 프로퍼티
val appName: String by Tracer("gravit")

fun main() {
    val name = appName
}
```', 'OBJECTIVE'),
       (5847, 944, '아래처럼 동작이 바뀌도록 프로퍼티 선언에 적용한 Kotlin 표준 라이브러리 위임은?', '결제 서버 기동 시간이 12.4초까지 늘어 배포할 때마다 헬스 체크가 실패했다. 프로파일러를 보니 생성자에서 곧바로 만드는 환율 테이블 파서가 3.4초를 차지했는데, 환율 화면을 여는 요청은 전체의 2%뿐이었다.

파서를 담는 val 프로퍼티의 선언부만 고치자 아래처럼 바뀌었다.

- 기동 시간: 12.4초 → 8.9초
- 환율 화면을 처음 연 요청 1건에만 3.4초가 얹혔고, 같은 인스턴스의 다음 요청부터는 12ms
- 환율 화면을 아무도 열지 않은 날에는 파서 객체가 하나도 만들어지지 않았다', 'SUBJECTIVE'),
       (5848, 944, '아래 실행 결과를 없애려면 표시한 줄의 title 자리에 써야 하는 Kotlin 식별자는?', '```kotlin
class Article {
    var title: String = "무제"
        set(value) {
            require(value.isNotBlank()) { "제목은 비어 있을 수 없다" }
            title = value.trim()          // 이 줄
        }
}

fun main() {
    Article().title = "  Kotlin 위임  "
}
```

실행 결과
```
Exception in thread "main" java.lang.StackOverflowError
    at Article.setTitle(Article.kt:5)
    at Article.setTitle(Article.kt:5)
    at Article.setTitle(Article.kt:5)
    ...
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5843
(15755, 5843, '[email: a@x.com -> b@x.com, age: 20 -> 20, age: 20 -> 31]', '대입이 일어나면 setValue 본문이 언제나 끝까지 실행된다고 본 것. setValue는 호출되지만 value != newValue가 거짓이라 age = 20 대입은 기록도 저장도 남기지 않고 끝난다.', false),
(15756, 5843, '[email: a@x.com -> b@x.com, age: 20 -> 31]', '위임한 프로퍼티에 대입하면 setValue(수신 객체, 프로퍼티, 새 값)가 불린다. 앞의 이름은 property.name에서 오고, 같은 값을 넣은 age = 20은 if 조건에 걸려 걸러지므로 기록은 두 건만 남는다.', true),
(15757, 5843, '[email: a@x.com -> b@x.com]', 'Int 같은 기본 타입에는 by 위임을 걸 수 없다고 본 것. 그 제약은 lateinit의 것이고 위임 프로퍼티는 타입을 가리지 않는다. Int에 쓰는 Delegates.notNull()이 대표 예다.', false),
(15758, 5843, '[email: b@x.com -> a@x.com, age: 31 -> 20]', 'setValue의 세 번째 인자를 바뀌기 전 값으로 읽어 방향을 뒤집은 것. 세 번째 인자는 새로 대입된 값이고 위임 객체가 들고 있던 value가 이전 값이라, 기록은 이전 값 -> 새 값 순이다.', false),

-- 문제 5844
(15759, 5844, '인터페이스에 멤버가 새로 추가돼도 위임으로 만든 래퍼는 코드를 더 쓰지 않고 그대로 컴파일된다.', '참. 직접 구현하지 않은 멤버마다 inner를 호출하는 전달 메서드가 컴파일 시점에 만들어지므로 늘어난 멤버도 자동으로 넘어간다. 전달 코드를 손으로 쓰는 방식과 달리 유지 비용이 늘지 않는다.', false),
(15760, 5844, '테스트에서 속을 가짜 구현으로 갈아 끼우려면 상속보다 위임 쪽이 고칠 코드가 적다.', '참. 위임은 같은 인터페이스를 구현한 다른 객체를 생성자 인자로 넣으면 그만이지만, 상속은 확장한 부모 타입이 컴파일 시점에 고정돼 다른 구현을 쓰려면 클래스를 새로 만들어야 한다.', false),
(15761, 5844, '상속으로 추가 횟수를 세는 래퍼를 만들면 원소 하나가 두 번 세어질 수 있다.', '참. 부모의 한 메서드가 내부에서 다른 멤버를 부르면 그 호출도 자식의 오버라이드를 지나므로, 바깥 메서드와 안쪽 호출이 모두 집계돼 중복이 생긴다. 위임에는 이 경로가 없다.', false),
(15762, 5844, 'final로 선언된 클래스의 기능을 감싸려면 위임도 쓸 수 없어 원본을 open으로 고쳐야 한다.', '거짓. open 여부는 상속 쪽 조건이다. 위임은 인터페이스에만 걸면 되고 위임 객체의 클래스가 final이어도 상관없으므로, 그 인터페이스를 구현한 final 클래스는 손대지 않고 감쌀 수 있다.', true),

-- 문제 5845
(15763, 5845, '100 / 20', '커스텀 getter는 읽을 때마다 visitors * 2를 다시 계산해 100이 된다. byLazy는 첫 println에서 이미 20을 만들어 보관했으므로 visitors가 바뀌어도 보관된 20을 그대로 돌려준다.', true),
(15764, 5845, '100 / 100', 'lazy도 접근할 때마다 람다를 다시 돌린다고 본 것. 람다는 값이 아직 없을 때만 실행되고 한 번 성공해 값이 저장된 뒤에는 저장값만 반환되므로, 계산에 쓰인 원본이 바뀌어도 따라가지 않는다.', false),
(15765, 5845, '20 / 20', 'val이면 처음 읽은 값이 캐시된다고 본 것. val은 재대입 금지일 뿐이고, 저장 공간 없이 get()만 둔 프로퍼티는 접근할 때마다 그 본문이 다시 실행된다.', false),
(15766, 5845, '20 / 100', '두 프로퍼티의 성질을 서로 바꿔 읽은 것. 값을 붙잡아 두는 쪽이 by lazy이고, 매번 다시 계산하는 쪽이 커스텀 getter다.', false),

-- 문제 5846
(15767, 5846, 'Tracer / appName', 'getValue의 첫 인자가 위임 객체 자신이라고 본 것. 위임 객체는 이미 호출을 받는 수신자이고, 첫 인자는 그 프로퍼티를 가진 바깥 객체를 가리킨다.', false),
(15768, 5846, 'MainKt / appName', '최상위 프로퍼티도 컴파일 뒤에는 파일 클래스에 담기니 그 클래스가 넘어온다고 본 것. 규약은 소유 객체가 없는 자리에 null을 넘기므로 클래스 이름은 나오지 않는다.', false),
(15769, 5846, 'null / appName', '첫 인자는 프로퍼티를 가진 객체인데 최상위 프로퍼티에는 그런 객체가 없어 null이 넘어온다. 두 번째 인자 KProperty는 선언된 프로퍼티의 메타데이터라 name이 appName이다.', true),
(15770, 5846, 'null / getAppName', 'KProperty.name이 JVM에서 만들어지는 접근자 메서드 이름을 준다고 본 것. name은 Kotlin 소스에 선언된 프로퍼티 이름 그대로이며, 그 덕분에 이름 기반 저장소 위임을 만들 수 있다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1904, 5847, 'lazy,by lazy,lazy {},lazy { },kotlin.lazy,lazy 위임', 'lazy는 최초 접근 때 람다를 한 번 실행해 값을 만들고 그 값을 보관하는 val 전용 위임이라, 생성 비용이 기동 시점에서 첫 사용 시점으로 옮겨진다. 환율 화면을 처음 연 요청 1건만 3.4초를 부담하고 다음 요청이 12ms로 끝나는 것, 아무도 열지 않은 날에 객체가 아예 만들어지지 않는 것이 모두 그 결과다. lateinit은 var에 외부에서 값을 넣어 주는 방식이라 "쓸 때 스스로 만든다"를 보장하지 못하고 기본 타입에도 못 쓰며, Delegates.notNull()은 값을 넣기 전 접근을 예외로 막을 뿐 초기화 로직을 스스로 갖지 않는다. 여러 스레드가 동시에 처음 읽어도 초기화를 한 번으로 묶고 싶다면 기본 모드인 SYNCHRONIZED를 그대로 두면 된다.'),
       (1905, 5848, 'field,field 식별자,field 키워드,backing field', 'setter 안에서 title에 대입하면 그 대입이 setter를 다시 불러 호출이 무한히 쌓이고, 그래서 StackOverflowError가 난다. 접근자 안에서만 쓸 수 있는 field는 프로퍼티가 값을 담아 두는 backing field를 직접 가리키므로 접근자를 다시 타지 않고 값만 바꾼다. value는 setter가 받은 인자일 뿐이라 거기에 대입해도 저장되지 않고, this.title도 결국 같은 setter를 거쳐 재귀가 그대로 남는다. 반대로 getter에서 field를 한 번도 쓰지 않으면 backing field 자체가 만들어지지 않아 읽을 때마다 계산하는 프로퍼티가 된다.');
