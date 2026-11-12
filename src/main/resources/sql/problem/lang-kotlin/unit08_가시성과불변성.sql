-- Unit: 가시성과 불변성 (Unit ID: 203)
-- Chapter: Kotlin (Chapter ID: 19)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (629, 203, '가시성 범위와 계산 프로퍼티, 가변 캐스트'),
       (787, 203, '읽기 전용 뷰와 스냅샷, const 인라인'),
       (945, 203, 'Kotlin 가시성과 불변성: 상속·모듈 경계와 진짜 불변 컬렉션');

-- =====================================================
-- Lesson 629: 가시성 범위와 계산 프로퍼티, 가변 캐스트
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3953, 629, '아래 Kotlin 코드에서 컴파일 에러가 발생하는 줄은?', '```kotlin
// :core 모듈 / Auth.kt
private fun mask(v: String) = "***"

open class Session {
    protected val token = "abc"
    fun show() = mask(token)               // (가)
}
```

```kotlin
// :core 모듈 / Login.kt  — 같은 모듈, 같은 패키지, 다른 파일
class WebSession : Session() {
    fun peek() = token                     // (나)
}

internal class Audit {
    fun log(s: Session) = s.token          // (다)
}

fun newSession(): Session = WebSession()   // (라)
```', 'OBJECTIVE'),
       (3954, 629, '아래 Kotlin 코드를 실행했을 때 출력 결과는?', '```kotlin
class Cart {
    val items = mutableListOf("사과")
    val summary: String get() = "${items.size}개"
    val label: String = "총 ${items.size}건"
}

fun main() {
    val cart = Cart()
    val first = cart.summary
    cart.items.add("배")
    println("$first / ${cart.summary} / ${cart.label}")
}
```', 'OBJECTIVE'),
       (3955, 629, '아래 비교표를 바탕으로 옳지 않은 것은?', '리스트를 담은 클래스가 그 내용을 바깥에 내보내는 네 가지 방식이다.

| 내보내는 방식 | 넘긴 쪽에서 내용이 바뀔 수 있는가 | 비용 |
|---|---|---|
| 내부 가변 리스트를 List 타입으로 반환 | 같은 객체를 가리키는 가변 참조, 자바 코드, 다운캐스트로 바뀔 수 있다 | 없음 |
| toList()로 복사해 반환 | 복사본은 원본과 끊겨 있어 바뀌지 않는다 | 호출마다 O(n) 복사 |
| PersistentList로 보관해 반환 | 구현체 자체가 불변이라 바뀌지 않는다 | 변경할 때마다 구조 공유로 O(log n) 수준 |
| Collections.unmodifiableList로 감싸 반환 | 변경 메서드는 예외를 던지지만, 원본이 바뀌면 그대로 비친다 | 래핑 비용만 |', 'OBJECTIVE'),
       (3956, 629, '아래 클래스 설계에 대한 설명으로 옳은 것은?', '```kotlin
// Line은 모든 프로퍼티가 val인 불변 타입이다.
class Order private constructor(
    val id: Long,
    val lines: List<Line>
) {
    companion object {
        const val MAX_LINES = 100

        fun create(id: Long, lines: List<Line>): Order {
            require(lines.size <= MAX_LINES)
            return Order(id, lines.toList())
        }
    }

    fun withLine(line: Line) = Order(id, lines + line)
}
```', 'OBJECTIVE'),
       (3957, 629, '아래 빌드 로그와 디컴파일 결과에서 ???에 해당하는 Kotlin 가시성 변경자는?', '```kotlin
// :core 모듈 / Loader.kt — 비어 있던 변경자 자리에 ??? 하나를 적었다
??? class Loader {
    fun load() {}
}
```

```
# :app 모듈(다른 모듈)에서 빌드
e: Loader.kt: Cannot access `Loader`: it is ??? in file Loader.kt

# 같은 :core 모듈의 다른 파일에서 빌드
BUILD SUCCESSFUL

# 자바 쪽에서 이 클래스를 열어 보면
public final class Loader {
    public final void load$core() { ... }
}
```', 'SUBJECTIVE'),
       (3958, 629, '아래 코드를 실행하면 마지막 줄에서 발생하는 예외의 이름은?', '```kotlin
val nums = listOf(1, 2, 3)              // 런타임 객체는 java.util.Arrays$ArrayList
val forced = nums as MutableList<Int>   // 이 캐스트는 그대로 통과한다
forced.add(4)                           // 여기서 예외가 던져진다
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3953
(10715, 3953, '(가) Session.show()가 같은 파일의 최상위 private 함수 mask를 호출하는 줄', '최상위 private은 선언된 파일 전체에서 보인다. show()가 mask와 같은 Auth.kt 안에 있으므로 호출할 수 있다. 클래스가 경계인 자바의 private과 달리 파일이 경계라는 점이 다르다.', false),
(10716, 3953, '(나) 하위 클래스 WebSession이 상위 클래스에서 물려받은 token을 읽는 줄', 'protected는 자신과 하위 클래스에서 보인다. 파일이 달라도 Session을 상속한 WebSession은 token에 접근할 수 있다. 가시성을 파일 위치로 판단한 오해다.', false),
(10717, 3953, '(다) Audit.log가 매개변수로 받은 Session의 token을 읽는 줄', 'Kotlin의 protected는 자바와 달리 같은 패키지라고 열어 주지 않는다. Audit은 Session의 하위 클래스가 아니라 그저 같은 패키지의 이웃이므로 token에 접근할 수 없다.', true),
(10718, 3953, '(라) 최상위 함수 newSession이 WebSession을 Session 타입으로 돌려주는 줄', 'Session과 WebSession은 변경자를 생략해 기본값 public이다. public 최상위 함수가 public 타입을 노출하는 것이라 가시성 충돌이 없다.', false),

-- 문제 3954
(10719, 3954, '1개 / 1개 / 총 1건', 'val이면 값이 한 번 정해져 고정된다고 본 오해다. summary는 뒷받침 필드가 없어 접근할 때마다 items.size를 다시 읽으므로 두 번째 값은 2개가 된다.', false),
(10720, 3954, '1개 / 2개 / 총 1건', 'first는 add 이전에 계산된 문자열을 이미 담았고, summary는 커스텀 getter라 다시 읽어 2개가 된다. label은 초기화식이 생성 시점에 한 번만 실행돼 총 1건에 머문다.', true),
(10721, 3954, '1개 / 2개 / 총 2건', '초기화식으로 값을 받은 val도 커스텀 getter처럼 매번 다시 계산된다고 본 오해다. label은 생성자 실행 때 계산해 뒷받침 필드에 저장하므로 이후 items 변경과 무관하다.', false),
(10722, 3954, '2개 / 2개 / 총 2건', 'val 프로퍼티는 언제 읽어도 객체의 최신 상태를 보여 준다고 본 오해다. first는 이미 만들어진 String 값을 담은 지역 변수라 나중의 add에 따라 바뀌지 않는다.', false),

-- 문제 3955
(10723, 3955, '화면 상태를 1초에 수십 번 갱신하는 코드라면, 갱신마다 전체를 복사하는 방식보다 구조를 공유하는 방식이 갱신 비용 면에서 유리하다.', 'O(n) 복사는 갱신 횟수만큼 전체 비용이 쌓이지만, 구조 공유는 갱신 한 번당 O(log n) 수준에 그친다. 상태를 자주 바꾸는 화면에서 차이가 벌어진다.', false),
(10724, 3955, '감싸서 내보내면 복사 비용은 거의 없지만, 감싸기 전 원본을 쥐고 있던 코드가 항목을 추가하면 받은 쪽에서도 그 항목이 보인다.', '래핑은 변경 메서드를 막는 읽기 창을 씌울 뿐 값을 복사하지 않는다. 그래서 원본 변경이 그대로 비치고, 스냅샷을 넘긴 것과는 성격이 다르다.', false),
(10725, 3955, '내부 리스트를 List 타입으로 그대로 반환하는 방식은 비용이 들지 않는 대신, 받는 쪽이 다운캐스트하지 않으리라는 신뢰에 기대야 한다.', '반환한 객체가 여전히 가변이라 다운캐스트가 통한다. 타입이 막아 주는 것이 아니라 규약이 막아 주는 셈이라, 규약을 강제할 수 있는 모듈 안에서만 쓸 만하다.', false),
(10726, 3955, '복사해 넘긴 뒤 원본에 항목을 추가하면, 앞서 넘긴 복사본에서도 그 항목이 함께 나타난다.', '복사본은 원본과 끊겨 있다는 표의 두 번째 행에 걸린다. 새 컬렉션을 만들어 넘겼으므로 이후 원본 변경은 스냅샷에 반영되지 않는다. 참조만 넘기는 첫 행과 헷갈린 것이다.', true),

-- 문제 3956
(10727, 3956, 'withLine이 기존 인스턴스를 그대로 두고 새 Order를 만들므로, 한 인스턴스를 여러 스레드가 잠금 없이 함께 읽어도 된다.', '만들어진 뒤 내부가 바뀌지 않는 객체는 읽기끼리 경합할 일이 없다. 변경이 새 객체 생성으로 표현되니 공유해도 동기화가 필요 없고, 캐시 키로 써도 값이 흔들리지 않는다.', true),
(10728, 3956, 'create에 넘긴 리스트를 호출자가 나중에 변경하면, 그 변화가 Order의 lines에도 그대로 반영된다.', '넘겨받은 리스트를 그대로 담았다고 본 오해다. create는 toList()로 새 컬렉션을 만들어 저장하므로 원본과의 연결이 끊겨 나중 변경이 스며들지 않는다.', false),
(10729, 3956, 'MAX_LINES는 const val이므로 companion object가 처음 쓰이는 시점에 계산되어 그때부터 값이 정해진다.', 'const val은 컴파일 타임 상수라 사용하는 자리에 값이 그대로 새겨진다. 초기화 시점을 따지는 것은 런타임에 값이 정해지는 일반 val에 해당하는 이야기다.', false),
(10730, 3956, 'lines가 읽기 전용 List 타입이므로, 이 참조를 MutableList로 다운캐스트하는 코드는 컴파일되지 않는다.', 'List에서 MutableList로의 캐스트는 경고만 낼 뿐 컴파일된다. 읽기 전용은 그 타입으로 볼 때의 제약일 뿐, 런타임 객체까지 불변으로 바꿔 주지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1274, 3957, 'internal,인터널,internal 변경자', '다른 모듈 빌드만 막히고 같은 모듈 빌드는 통과한다는 점, 그리고 자바 쪽에서 load$core처럼 이름 뒤에 모듈 이름이 붙어 보인다는 점이 internal의 표시다. 이 이름 변형을 맹글링이라 하며, 바이트코드에서는 public이라 자바에서 억지로 부를 수는 있다. 그래서 접근을 물리적으로 막는 장치라기보다 라이브러리 내부 구현이니 쓰지 말라는 의도 표시에 가깝다. 파일 바깥이면 막히는 최상위 private, 하위 클래스에만 열리는 protected와 경계가 다르다.'),
       (1275, 3958, 'UnsupportedOperationException,java.lang.UnsupportedOperationException,kotlin.UnsupportedOperationException', 'listOf가 돌려주는 객체는 크기가 고정된 자바 리스트라 add 같은 변경 메서드가 모두 UnsupportedOperationException을 던진다. 다운캐스트 자체는 런타임 타입이 java.util.List라 검사를 통과하므로 ClassCastException이 아니다. 읽기 전용 인터페이스는 그 타입으로 볼 때 변경 메서드를 감출 뿐, 실패하는 가변 컬렉션이지 진짜 불변 컬렉션이 아니다. 진짜 불변이 필요하면 toList()로 복사하거나 PersistentList를 쓴다.');

-- =====================================================
-- Lesson 787: 읽기 전용 뷰와 스냅샷, const 인라인
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4901, 787, '아래 Kotlin 코드를 실행했을 때 출력 결과는?', '```kotlin
class Roster {
    private val _names = mutableListOf("민수")

    val live: List<String> get() = _names
    val snapshot: List<String> get() = _names.toList()

    fun join(name: String) { _names.add(name) }
}

fun main() {
    val roster = Roster()
    val a = roster.live
    val b = roster.snapshot

    roster.join("지연")
    println("${a.size} ${b.size} ${roster.snapshot.size}")
}
```', 'OBJECTIVE'),
       (4902, 787, '아래 비교표를 바탕으로 옳지 않은 것은?', 'Kotlin 가시성 변경자가 보이는 범위를 정리한 표다.

| 변경자 | 클래스 멤버에 붙였을 때 | 최상위 선언에 붙였을 때 |
|---|---|---|
| public | 어디서나 (기본값) | 어디서나 (기본값) |
| internal | 같은 모듈 안에서만 | 같은 모듈 안에서만 |
| protected | 자신과 하위 클래스에서만 | 붙일 수 없음 |
| private | 그 클래스 안에서만 | 같은 파일 안에서만 |', 'OBJECTIVE'),
       (4903, 787, '아래 Kotlin 클래스를 같은 모듈의 자바 코드에서 썼을 때 일어나는 일로 옳은 것은?', '```kotlin
// Feed.kt
class Feed {
    private val _posts = mutableListOf("첫 글")

    val posts: List<String> get() = _posts

    fun size() = _posts.size
}
```

```java
// FeedRunner.java — 같은 모듈
Feed feed = new Feed();
List<String> posts = feed.getPosts();
posts.add("자바가 넣은 글");
System.out.println(feed.size());
```', 'OBJECTIVE'),
       (4904, 787, '아래 코드에서 두 번째 println이 false를 출력하는 이유로 옳은 것은?', '```kotlin
data class Profile(val id: Long, val tags: MutableList<String>)

fun main() {
    val p = Profile(1, mutableListOf("kotlin"))
    val cache = hashSetOf(p)

    println(cache.contains(p))   // true
    p.tags.add("android")
    println(cache.contains(p))   // false
    println(cache.size)          // 1
}
```', 'OBJECTIVE'),
       (4905, 787, '아래 (가) 줄을 고쳐 증상을 없앤 기법의 이름은?', '```kotlin
class Invoice(lines: List<String>) {
    val lines: List<String> = lines        // (가)
}
```

```
> val input = mutableListOf("배송비")
> val invoice = Invoice(input)
> invoice.lines.size
1
> input.add("포장비")      // invoice는 건드리지 않았다
> invoice.lines.size
2

// (가)를 val lines: List<String> = lines.toList() 로 고친 뒤 같은 순서로 실행하면
> invoice.lines.size
1
```', 'SUBJECTIVE'),
       (4906, 787, '아래 빌드 기록에서 ???에 들어갈 Kotlin 선언 키워드는?', '```kotlin
// :core 모듈 / ApiConfig.kt
object ApiConfig {
    ??? val VERSION = "v1"
}
```

```
# :app 모듈은 ApiConfig.VERSION을 화면에 찍는다
$ ./gradlew :app:run
현재 버전: v1

# VERSION만 "v2"로 고치고 :core 모듈만 다시 빌드한 뒤
$ ./gradlew :core:build :app:run
현재 버전: v1      ← 값을 고쳤는데 그대로다

# :app까지 다시 컴파일하면
$ ./gradlew :app:clean :app:run
현재 버전: v2
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4901
(13243, 4901, '1 1 2', 'live도 부를 때마다 목록을 떠 준다고 본 오해다. live는 _names 객체를 그대로 돌려주므로 a는 내부 리스트와 같은 객체를 가리키고, join 이후 크기가 2로 보인다.', false),
(13244, 4901, '2 1 2', 'a가 가리키는 것은 _names 그 자체라 join이 그대로 비쳐 2가 된다. b는 toList()로 새로 만든 컬렉션이라 원본과 끊겨 1에 머물고, 마지막 값은 그 시점에 다시 복사한 목록이라 2다.', true),
(13245, 4901, '2 2 2', 'toList()가 원본에 읽기 전용 창을 씌우는 것이라고 본 오해다. toList()는 새 컬렉션을 만들어 원본과의 연결을 끊으므로 이후의 join은 b에 반영되지 않는다.', false),
(13246, 4901, '1 1 1', '프로퍼티 타입이 List면 내용이 고정된다고 본 오해다. 읽기 전용은 그 참조로 변경 메서드를 못 부른다는 뜻일 뿐, 뒤에 있는 객체가 다른 경로로 바뀌는 것까지 막지는 못한다.', false),

-- 문제 4902
(13247, 4902, '같은 모듈 안의 다른 파일에서 어떤 최상위 함수가 보이지 않았다면, 그 함수에 붙은 변경자는 private이다.', '최상위에 붙일 수 있는 변경자 중 public과 internal은 같은 모듈이라면 파일이 달라도 보인다. 파일을 경계로 삼는 것은 최상위 private뿐이라 후보가 하나로 좁혀진다.', false),
(13248, 4902, '라이브러리 안에서만 쓰려는 클래스에는 internal이면 충분하고, 같은 모듈의 다른 파일에서 계속 쓸 것이라면 private까지 내려서는 안 된다.', 'internal은 모듈 경계까지 열어 두므로 라이브러리 내부끼리 쓰는 데는 지장이 없다. private으로 내리면 선언한 파일 밖에서는 쓸 수 없어 같은 모듈의 다른 파일도 막힌다.', false),
(13249, 4902, '하위 클래스에서는 쓰되 같은 모듈의 상속 관계 없는 클래스에서는 감추고 싶은 멤버라면 internal보다 protected가 알맞다.', 'internal은 같은 모듈이기만 하면 상속과 무관한 클래스에도 열린다. 상속 계층만 골라서 열어 주는 것은 protected라 요구 조건에 맞는다.', false),
(13250, 4902, 'protected는 최상위 함수에도 붙일 수 있어, 같은 파일에 선언된 하위 클래스라면 그 함수를 호출할 수 있다.', '표의 protected 행 오른쪽 칸이 붙일 수 없음이다. 상속 관계를 기준으로 삼는 변경자라 상속할 대상이 없는 최상위 선언에는 쓸 수 없고, 적으면 컴파일 에러가 난다.', true),

-- 문제 4903
(13251, 4903, 'add 호출이 그대로 성공해 내부 리스트에 항목이 늘고, feed.size()는 2를 출력한다.', 'getPosts()가 돌려주는 것은 _posts 객체 자체이고, 자바 쪽에서는 Kotlin의 List가 java.util.List로 보여 변경 메서드가 열려 있다. 그래서 바깥 코드가 내부 상태를 늘릴 수 있다.', true),
(13252, 4903, 'add 호출은 컴파일되지만 실행 시 UnsupportedOperationException이 발생한다.', '읽기 전용 타입이면 변경 시 예외가 난다고 본 오해다. 예외를 던지는 것은 listOf가 만드는 크기 고정 리스트이고, 여기서 실제 객체는 mutableListOf가 만든 ArrayList라 add가 성공한다.', false),
(13253, 4903, 'Kotlin의 List는 자바 쪽에 변경 메서드가 없는 인터페이스로 매핑되므로 add 줄이 컴파일되지 않는다.', '읽기 전용 List는 Kotlin 컴파일러가 보는 타입일 뿐이고 자바에는 java.util.List로 넘어간다. add가 그대로 보이므로 자바 컴파일러는 이 호출을 막지 않는다.', false),
(13254, 4903, 'getPosts()가 호출할 때마다 복사본을 돌려주므로 자바 쪽 리스트만 늘고 feed.size()는 1을 출력한다.', '커스텀 getter는 늘 새 컬렉션을 만든다고 본 오해다. 이 getter는 _posts를 그대로 돌려줄 뿐이고, 복사본을 주려면 toList()처럼 새 컬렉션을 만드는 호출이 있어야 한다.', false),

-- 문제 4904
(13255, 4904, 'id와 tags가 모두 val이라 hashCode 값은 그대로지만, HashSet이 한 번 저장한 뒤에는 equals를 다시 부르지 않기 때문이다.', 'val은 재대입만 막을 뿐 tags가 가리키는 리스트 내부는 얼마든지 바뀐다. data class가 만든 hashCode는 tags 내용까지 쓰므로 항목이 늘면 값 자체가 달라진다.', false),
(13256, 4904, 'data class의 equals는 두 참조가 같은 객체인지를 비교하는데, 내용을 바꾼 p는 저장 당시의 객체와 더 이상 같지 않기 때문이다.', 'data class의 equals는 참조가 아니라 모든 프로퍼티 값을 비교하도록 생성된다. 게다가 p는 같은 객체 그대로이고 안에 든 리스트만 바뀌었으므로 참조가 달라졌다는 설명도 성립하지 않는다.', false),
(13257, 4904, 'tags에 항목이 들어가면서 p의 hashCode가 달라져, 저장할 때 정해진 버킷에서 p를 찾지 못하기 때문이다.', '해시 기반 컬렉션은 넣을 때의 hashCode로 자리를 정한다. data class의 hashCode가 tags 내용까지 반영하므로, 넣은 뒤 내용이 바뀌면 조회는 엉뚱한 자리를 뒤져 실패한다. 가변 객체를 키로 쓰면 위험한 이유다.', true),
(13258, 4904, 'contains가 부르는 equals에서 리스트끼리는 내용이 아니라 참조로 비교되어, 항목을 추가한 뒤에는 서로 다른 리스트로 판정되기 때문이다.', '자바 리스트의 equals는 원소를 차례로 비교하지 참조를 보지 않는다. 비교 대상도 같은 p라 tags 참조까지 동일하다. 어긋난 지점은 equals가 아니라 그보다 앞서 자리를 찾는 hashCode 단계다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1590, 4905, '방어적 복사,방어적복사,방어 복사,defensive copy,defensive copying,디펜시브 카피', '생성자가 받은 리스트를 그대로 필드에 담으면 호출자가 쥐고 있는 원본이 곧 객체의 상태가 되어, 바깥에서 일어난 변경이 안으로 새어 든다. toList()로 새 컬렉션을 떠서 담으면 원본과의 연결이 끊겨 이후 변경이 비치지 않는다. 안에 있는 것을 밖으로 내보낼 때 스냅샷을 돌려주는 것도 같은 기법이다. 읽기 전용 타입으로 선언만 바꾸는 것과는 구분해야 한다. List 타입은 그 참조로 변경 메서드를 못 부르게 할 뿐, 원본을 쥔 쪽의 변경은 막지 못한다. 다만 넘길 때마다 O(n) 복사 비용이 들므로, 큰 컬렉션을 자주 갱신한다면 PersistentList 같은 진짜 불변 컬렉션이 대안이다.'),
       (1591, 4906, 'const,const val,컴파일 타임 상수,컴파일타임 상수,compile-time constant,compile time constant', '이 키워드를 붙인 선언은 값이 쓰이는 자리마다 그대로 새겨져 들어간다. 그래서 값을 고친 모듈만 다시 빌드하면 예전 값이 박힌 :app 쪽 바이트코드가 그대로 쓰여 v1이 계속 나오고, 쓰는 쪽까지 다시 컴파일해야 새 값이 반영된다. 기본 타입과 String에만, 그리고 최상위나 object 안에서만 쓸 수 있다는 제약도 함께 붙는다. 일반 val은 런타임에 게터를 통해 값을 읽으므로 이런 현상이 없고, 재대입을 막는다는 점만 공유한다. 값이 앞으로 바뀔 수 있는 공개 API라면 const를 피하는 편이 안전하다.');

-- =====================================================
-- Lesson 945: Kotlin 가시성과 불변성: 상속·모듈 경계와 진짜 불변 컬렉션
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5849, 945, '아래 가시성 변경자에 대한 설명으로 옳은 것은?', 'Kotlin의 가시성 변경자 가운데 하나다. 클래스 멤버에 붙이면 그 클래스 자신과 그 클래스를 상속한 하위 클래스에서만 보이고, 파일 최상위 선언에는 붙일 수 없다.', 'OBJECTIVE'),
       (5850, 945, '아래 Kotlin 코드의 출력 결과는?', '```kotlin
data class Config(val name: String, val hosts: MutableList<String>)

fun main() {
    val a = Config("prod", mutableListOf("h1"))
    val b = a.copy()

    b.hosts.add("h2")
    println("${a.hosts.size} ${b.hosts.size} ${a == b}")
}
```', 'OBJECTIVE'),
       (5851, 945, '아래 요구를 가시성 변경자로 처리하는 방법으로 옳지 않은 것은?', ':core 모듈과, :core를 의존성으로 쓰는 :app 모듈이 있다. :core 안에는 Parser.kt와 Cache.kt 두 파일이 있다.

- 요구 1: Parser.kt에 있는 최상위 함수 normalize를 Parser.kt 밖에서는 쓰지 못하게 한다.
- 요구 2: Cache 클래스를 :core의 여러 파일에서는 쓰되 :app에서는 import하지 못하게 한다.
- 요구 3: Base 클래스의 seed 프로퍼티를 Base를 상속한 클래스에서만 읽게 한다.', 'OBJECTIVE'),
       (5852, 945, '아래 측정 결과에 대한 설명으로 옳은 것은?', '항목 10만 개를 하나씩 모아 List 타입으로 돌려주는 두 구현을 같은 기기에서 측정했다.

| 구현 | 10만 개를 다 모으는 데 걸린 시간 | 만들어진 리스트 객체 수 |
|---|---|---|
| (가) acc = acc + item 으로 매번 새 리스트를 만들어 교체 | 8,120ms | 100,000 |
| (나) MutableList에 add로 모은 뒤 마지막에 한 번 toList() | 9ms | 2 |', 'OBJECTIVE'),
       (5853, 945, '아래 측정에서 (가) 자리에 쓴 컬렉션 타입의 이름은?', '목록 화면의 상태 리스트를 한 항목씩 5,000번 갱신하는 코드를 고치기 전후로 측정했다. (가)는 kotlinx.collections.immutable에서 가져온 타입이다.

| 구분 | 갱신 코드 | 5,000번 갱신에 걸린 시간 |
|---|---|---|
| 고치기 전 | state = state.toList() + item | 3,912ms |
| 고친 뒤 | state의 타입만 (가)로 바꾸고 state = state.add(item) | 41ms |

고친 뒤에는 갱신 직전에 붙잡아 둔 이전 참조로 크기를 찍어도 갱신 전 값이 그대로 나왔고, 그 참조를 MutableList로 캐스트하려 하자 캐스트 자체가 실패했다.', 'SUBJECTIVE'),
       (5854, 945, '아래 (가) 자리에 쓴 자바 표준 라이브러리 메서드의 이름은?', '```kotlin
val origin = mutableListOf("사과")
val view: List<String> = (가)(origin)
```

```
> (view as MutableList<String>).add("배")
java.lang.UnsupportedOperationException

> origin.add("배")
> view
[사과, 배]

> view === origin
false
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5849
(15771, 5849, '같은 패키지에 있는 Kotlin 클래스라면 상속 관계가 없어도 이 멤버를 읽을 수 있다.', '자바의 같은 이름 변경자가 패키지까지 열어 주는 것과 혼동한 오개념이다. Kotlin은 패키지를 가시성 경계로 쓰지 않아, 상속하지 않은 이웃 클래스는 같은 패키지라도 막힌다.', false),
(15772, 5849, '같은 파일 최상위에 선언한 확장 함수에서는 이 멤버를 읽을 수 없다.', '확장 함수는 클래스 바깥에서 정적 메서드로 컴파일되므로 수신 객체의 내부 멤버에 대한 권한이 없다. 파일이 같아도 상속 계층에 들어간 것이 아니라 접근이 막힌다.', true),
(15773, 5849, '하위 클래스가 이 멤버를 오버라이드하면서 가시성을 public으로 넓히는 것은 컴파일 에러다.', '오버라이드는 가시성을 그대로 두거나 더 넓힐 수 있다. 막히는 쪽은 좁히는 경우라, 하위 클래스에서 public으로 다시 공개하는 코드는 정상으로 컴파일된다.', false),
(15774, 5849, '같은 모듈 안에서는 어디서나 보이고, 다른 모듈에서만 접근이 막힌다.', '모듈을 경계로 삼는 것은 internal이다. 이 변경자의 경계는 모듈이 아니라 상속 계층이므로, 같은 모듈이어도 상속하지 않은 클래스에서는 보이지 않는다.', false),

-- 문제 5850
(15775, 5850, '1 2 false', 'copy()가 안에 든 컬렉션까지 새로 떠 준다고 본 오개념이다. copy()는 프로퍼티 값을 그대로 옮기므로 hosts는 리스트 객체 하나를 두 인스턴스가 함께 가리킨다.', false),
(15776, 5850, '2 2 false', 'a와 b가 서로 다른 인스턴스라 같을 수 없다고 본 오개념이다. data class의 equals는 참조가 아니라 프로퍼티 값을 비교하는데, name이 같고 hosts도 같은 객체라 true가 된다.', false),
(15777, 5850, '1 1 true', 'val이면 안에 든 리스트도 못 바꾼다고 본 오개념이다. val은 hosts에 다른 리스트를 다시 대입하는 것만 막고, MutableList 내부에 항목을 더하는 것은 그대로 허용한다.', false),
(15778, 5850, '2 2 true', 'copy()는 얕은 복사라 a.hosts와 b.hosts가 같은 리스트다. b 쪽에서 더한 항목이 a에도 보여 둘 다 2가 되고, 값을 비교하는 equals도 두 프로퍼티가 모두 같아 true다.', true),

-- 문제 5851
(15779, 5851, '요구 1은 normalize에 private을 붙이면 되고, 그러면 같은 모듈의 Cache.kt에서도 normalize가 보이지 않는다.', '최상위 선언의 private은 클래스가 아니라 파일을 경계로 삼는다. 같은 모듈이라도 다른 파일에서는 보이지 않으므로 요구 1을 그대로 만족한다.', false),
(15780, 5851, '요구 3은 seed에 protected를 붙이면 되고, Base를 상속한 클래스라면 :app 모듈에 있어도 seed를 읽을 수 있다.', 'protected의 경계는 모듈이 아니라 상속 계층이다. Base가 공개돼 있어 상속할 수 있다면 모듈이 달라도 하위 클래스 본문 안에서는 seed에 접근할 수 있다.', false),
(15781, 5851, '요구 2는 Cache에 internal을 붙이면 되고, :app이 자바로 작성돼 있어도 Cache의 메서드를 호출할 길이 완전히 막힌다.', 'internal은 바이트코드에서 public으로 남고 함수 이름 뒤에 모듈 이름이 붙는 맹글링만 일어난다. Kotlin 컴파일러 쪽만 막을 뿐이라 자바에서는 변형된 이름으로 호출할 수 있다.', true),
(15782, 5851, '요구 1을 private 대신 internal로 처리하면 Cache.kt에서도 normalize를 쓸 수 있어 요구 1에 못 미친다.', 'internal의 경계는 모듈이라 같은 :core 안의 다른 파일에는 그대로 열린다. 파일 밖을 막으려면 파일을 경계로 삼는 최상위 private까지 내려야 한다.', false),

-- 문제 5852
(15783, 5852, '(가)는 항목을 더할 때마다 그때까지 모은 전체를 새 리스트로 베끼므로, 항목 수가 늘수록 총 복사량이 제곱에 가깝게 불어난다.', '리스트 객체가 항목 수만큼 만들어졌다는 것은 교체가 10만 번 일어났다는 뜻이고, 교체 한 번마다 그때까지의 원소를 모두 옮긴다. 그래서 총 복사량이 항목 수의 제곱에 비례해 시간 차이가 벌어진다.', true),
(15784, 5852, '(나)가 빠른 것은 toList()가 원본을 그대로 돌려주어 복사가 한 번도 일어나지 않기 때문이다.', 'toList()는 언제나 새 컬렉션을 만든다. 표의 리스트 객체 2개가 모으는 데 쓴 MutableList와 마지막 복사본이며, (나)가 빠른 까닭은 복사가 없어서가 아니라 복사를 마지막 한 번으로 미뤘기 때문이다.', false),
(15785, 5852, '(나)가 돌려준 목록은 내부 MutableList와 같은 객체라, 작업이 끝난 뒤 내부 리스트를 바꾸면 받은 쪽에도 그대로 비친다.', '읽기 전용 타입으로 반환하면 늘 같은 객체가 나간다고 본 오개념이다. toList()가 만든 복사본은 원본과의 연결이 끊겨 있어 이후 원본 변경이 비치지 않는다.', false),
(15786, 5852, '(가)가 느린 것은 리스트를 교체할 때마다 스레드 간 동기화 잠금을 잡기 때문이다.', '불변 값을 새로 만들어 교체하는 데는 잠금이 필요 없다. 공유해도 동기화가 필요 없다는 점이 오히려 불변의 이점이고, 여기서 시간을 잡아먹는 것은 잠금이 아니라 되풀이되는 전체 복사다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1906, 5853, 'PersistentList,persistentListOf,퍼시스턴트 리스트,퍼시스턴트리스트,persistent list,영속 리스트,영속리스트', '갱신을 5,000번 반복해도 한 번당 비용이 거의 늘지 않는다는 점, 갱신 전에 붙잡아 둔 참조가 옛 내용을 그대로 유지한다는 점, MutableList로 캐스트조차 되지 않는다는 점이 함께 가리키는 타입은 PersistentList다. 갱신 요청을 받으면 바뀌지 않은 부분의 구조를 새 컬렉션과 나눠 쓰고 달라진 자리만 새로 만들기 때문에, 전체를 베끼는 toList() 방식이 항목 수에 비례해 느려지는 구간에서도 비용이 완만하게 늘어난다. 같은 라이브러리의 ImmutableList는 변경 메서드 자체가 없어 갱신을 표현하지 못하므로 상태를 계속 바꾸는 이 코드에는 맞지 않는다. 표준 라이브러리의 List는 이름과 달리 읽기 전용 인터페이스일 뿐이어서 같은 객체를 가리키는 다른 참조나 자바 코드, 다운캐스트로 내용이 바뀔 수 있다는 점에서도 구분된다.'),
       (1907, 5854, 'unmodifiableList,Collections.unmodifiableList,java.util.Collections.unmodifiableList', '변경 메서드를 부르면 UnsupportedOperationException이 나는데 원본에 넣은 항목은 그대로 비치고, 원본과 같은 객체도 아니라는 세 가지가 동시에 성립하는 것은 원본을 감싸 읽기 창만 씌우는 Collections.unmodifiableList다. 값을 복사하지 않고 원본을 참조만 하므로 감싸기 전 원본을 쥐고 있던 쪽의 변경은 막지 못한다. toList()로 뜬 복사본은 원본과 연결이 끊겨 이후 변경이 비치지 않고, listOf가 만드는 목록은 크기가 고정된 자바 리스트 자체라 감쌀 원본이 따로 없다는 점에서 다르다. 변경 메서드를 막는 것과 내용이 변하지 않는 것은 다른 이야기이며, 진짜 불변이 필요하면 방어적 복사나 PersistentList를 써야 한다.');
