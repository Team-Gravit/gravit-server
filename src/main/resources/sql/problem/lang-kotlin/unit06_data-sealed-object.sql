-- Unit: data·sealed·object (Unit ID: 201)
-- Chapter: Kotlin (Chapter ID: 19)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (627, 201, 'enum·sealed 비교와 얕은 복사'),
       (785, 201, '배열 동등성과 가변 키, 구조 분해'),
       (943, 201, 'Kotlin data class 제약과 sealed·object로 상태 설계하기');

-- =====================================================
-- Lesson 627: enum·sealed 비교와 얕은 복사
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3941, 627, '아래 Kotlin 코드를 실행했을 때 출력되는 값은?', '```kotlin
data class User(val id: Long) {
    var nickname: String = ""
}

fun main() {
    val u1 = User(1).apply { nickname = "kim" }
    val u2 = User(1).apply { nickname = "lee" }
    val u3 = u1.copy()

    println("${u1 == u2} ${u3.nickname == u1.nickname}")
}
```', 'OBJECTIVE'),
       (3942, 627, '아래 비교표를 바탕으로 두 방식에 대한 설명으로 옳지 않은 것은?', '| 구분 | enum class | sealed class / interface |
| --- | --- | --- |
| 인스턴스 | 각 상수가 단일 인스턴스 | 하위 타입마다 여러 인스턴스 생성 가능 |
| 상태(데이터) | 모든 상수가 같은 프로퍼티 집합 | 하위 타입마다 서로 다른 프로퍼티 보유 가능 |
| 상속 | 불가 (인터페이스 구현만) | sealed interface는 다중 구현 가능 |
| when 완전성 | 지원 | 지원 |', 'OBJECTIVE'),
       (3943, 627, '아래 계층에 새 하위 타입을 추가한 뒤 벌어지는 일로 옳은 것은?', '```kotlin
sealed interface UiState {
    data object Loading : UiState
    data class Success(val items: List<String>) : UiState
    data class Error(val cause: Throwable) : UiState
}

fun render(state: UiState) = when (state) {
    is UiState.Success -> showList(state.items)
    else -> showSpinner()
}
```

이후 팀이 UiState 안에 `data object Empty : UiState`를 추가했고, render 함수는 한 줄도 고치지 않은 채 빌드했다.', 'OBJECTIVE'),
       (3944, 627, '아래 Kotlin 코드를 실행했을 때 출력 순서로 옳은 것은?', '```kotlin
object Registry {
    init { println("R") }
    fun ping() = "pong"
}

class Service {
    companion object {
        init { println("C") }
    }
    fun run() = Registry.ping()
}

fun main() {
    println("start")
    val s = Service()
    println("mid")
    s.run()
    println("end")
}
```', 'OBJECTIVE'),
       (3945, 627, '아래 상황에서 backup이 원본을 지켜 주지 못한 원인이 된 복사 방식의 이름은?', '주문 화면에서 되돌리기 기능을 만들려고 원본을 그대로 남겨 둘 backup을 따로 떠 두었다. 그런데 backup에만 항목을 넣었더니 원본 목록에도 같은 항목이 함께 늘어 있었다.

```kotlin
data class Cart(val id: Long, val items: MutableList<String>)

val origin = Cart(1, mutableListOf("책"))
val backup = origin.copy()

println(origin === backup)   // false
backup.items.add("펜")
println(origin.items)        // [책, 펜]
```', 'SUBJECTIVE'),
       (3946, 627, '아래 상황에서 Loading 선언에 적용한 Kotlin 1.9의 선언 형태를 무엇이라고 하는가?', '```kotlin
sealed interface UiState {
    object Loading : UiState                        // 바꾸기 전
    data class Success(val body: String) : UiState
}
```

현재 상태를 로그로 찍으면 `UiState$Loading@6d06d69c`처럼 알아보기 힘든 문자열이 남았고, 화면 상태를 저장했다가 직렬화된 값을 되살리면 새 인스턴스가 만들어져 `state == UiState.Loading` 비교가 false로 떨어졌다. Loading 선언 앞에 변경자 하나를 덧붙이자 로그에는 `Loading`이 찍히고, 되살린 뒤의 비교도 true가 되었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3941
(10683, 3941, 'true true', 'copy()가 본문에 선언한 nickname까지 옮겨 준다고 본 오해. copy()는 주 생성자 프로퍼티만 넘겨 새 인스턴스를 만들므로 u3.nickname은 초기값인 빈 문자열로 남는다.', false),
(10684, 3941, 'true false', '자동 생성된 equals는 주 생성자의 id만 비교해 nickname이 달라도 true다. copy()도 주 생성자만 넘기므로 u3.nickname은 빈 문자열이라 kim과 같지 않아 false가 된다.', true),
(10685, 3941, 'false false', 'nickname이 다르니 두 객체도 다르다고 본 오해. 주 생성자 밖에 선언한 프로퍼티는 자동 생성 대상에서 빠져 값 비교에 쓰이지 않는다.', false),
(10686, 3941, 'false true', '본문 프로퍼티가 비교에 쓰이고 copy()는 객체를 통째로 복제한다고 본 오해. 둘 다 주 생성자 프로퍼티를 기준으로 만들어진다는 원칙에 어긋난다.', false),

-- 문제 3942
(10687, 3942, '같은 상수를 어디서 참조하든 같은 객체이므로, 값 비교와 참조 비교의 결과가 갈리지 않는다.', 'enum 상수는 인스턴스가 하나뿐이라 값이 같으면 참조도 같다. 두 비교가 어긋날 수 없으므로 참인 진술이다.', false),
(10688, 3942, '결과를 담는 하위 타입은 담긴 값이 서로 다른 객체 두 개로 같은 시점에 존재할 수 있다.', 'sealed 하위 타입은 인스턴스를 여러 개 만들 수 있어 Success(1)과 Success(2)가 동시에 살아 있을 수 있다. 그래서 참이다.', false),
(10689, 3942, '두 방식 모두 분기를 빠뜨리면 컴파일 단계에서 드러나 상태를 늘릴 때 고칠 자리를 찾을 수 있다.', '표에서 when 완전성이 둘 다 지원이다. 검사가 켜져 있으면 누락된 경우가 빌드에서 잡히므로 참인 진술이다.', false),
(10690, 3942, '상태마다 지녀야 할 데이터의 종류가 다르면, 상수별로 프로퍼티를 달리 선언할 수 있는 쪽이 알맞다.', '거짓이라 정답이다. 표에서 enum은 모든 상수가 같은 프로퍼티 집합을 갖는다. 하위 타입별로 다른 데이터를 담는 일은 sealed 계층의 몫이다.', true),

-- 문제 3943
(10691, 3943, 'render는 그대로 컴파일되고, 새로 넣은 Empty가 Error와 함께 스피너 화면으로 처리된다.', 'else 분기가 있으면 완전성 검사가 꺼져 하위 타입이 늘어도 컴파일러가 알려 주지 않는다. 새 상태는 조용히 else로 흘러 스피너가 뜬다.', true),
(10692, 3943, 'when이 모든 하위 타입을 덮지 못해 render를 고치라는 컴파일 에러가 난다.', 'sealed면 언제나 컴파일러가 누락을 잡아 준다고 본 오해. else를 두는 순간 완전성 검사가 꺼져 빌드는 조용히 성공한다.', false),
(10693, 3943, 'Empty가 어느 분기와도 맞지 않아 실행 중에 분기 없음 예외가 발생한다.', 'else가 없을 때 표현식 when이 던지는 예외를 이 상황에 갖다 붙인 오해. 여기서는 else가 나머지를 모두 받아 예외가 나지 않는다.', false),
(10694, 3943, 'Success 분기의 스마트 캐스트가 풀려 state.items 접근이 컴파일 에러가 된다.', '하위 타입이 늘면 is 검사의 캐스트가 흔들린다고 본 오해. is로 좁힌 타입은 다른 하위 타입이 추가돼도 그대로 유지된다.', false),

-- 문제 3944
(10695, 3944, 'start → R → C → mid → end', '프로그램이 시작될 때 모든 object가 한꺼번에 만들어진다고 본 오해. object 선언은 처음 접근하는 순간에야 초기화된다.', false),
(10696, 3944, 'start → C → R → mid → end', 'Service 인스턴스를 만들 때 그 안에서 쓰는 Registry까지 함께 준비된다고 본 오해. Registry는 ping()을 부르는 시점에 초기화된다.', false),
(10697, 3944, 'start → C → mid → R → end', 'companion object는 바깥 클래스가 초기화될 때 함께 초기화되므로 Service()를 만드는 순간 C가 찍히고, Registry는 처음 접근하는 s.run()에서 R이 찍힌다.', true),
(10698, 3944, 'start → mid → R → end', 'companion object 안의 멤버를 직접 부를 때만 초기화된다고 본 오해. 인스턴스를 만들면서 클래스가 초기화돼 C가 먼저 찍힌다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1270, 3945, '얕은 복사,얕은복사,shallow copy,shallowcopy,shallow-copy,shallow', 'copy()는 주 생성자 프로퍼티에 들어 있던 참조를 그대로 넘겨 새 인스턴스를 만든다. 그래서 겉의 Cart는 새 객체(참조 비교가 false)지만 안쪽 MutableList는 원본과 같은 객체를 가리켜, 한쪽에서 넣은 항목이 양쪽에서 보인다. 이렇게 껍데기만 새로 만드는 것이 얕은 복사다. 내부 객체까지 새로 만들어 원본과 완전히 끊어 내는 깊은 복사(deep copy)와 구분해야 한다. 실무에서는 data class의 프로퍼티를 읽기 전용 List 같은 불변 타입으로 두어 이런 사고를 예방한다.'),
       (1271, 3946, 'data object,dataobject,data 오브젝트,데이터 오브젝트,데이터 object', 'Kotlin 1.9에서 정식이 된 data object다. 일반 object는 toString()이 클래스 이름과 해시 문자열을 함께 내보내고 equals()가 인스턴스 동일성으로 동작해, 직렬화 뒤 되살리면서 인스턴스가 복제되면 같은 상태인데도 비교가 false가 된다. data object는 toString()이 선언 이름만 돌려주고 equals()가 타입 기준이라 두 증상이 함께 사라진다. 값을 담는 하위 타입에 쓰는 data class, 그리고 상태 비교 보장이 없는 맨 object 선언과 구분해서 기억하면 된다.');

-- =====================================================
-- Lesson 785: 배열 동등성과 가변 키, 구조 분해
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4889, 785, '아래 Kotlin 코드를 실행했을 때 출력되는 값은?', '```kotlin
data class Packet(val payload: IntArray)
data class Frame(val payload: List<Int>)

fun main() {
    val p1 = Packet(intArrayOf(1, 2))
    val p2 = Packet(intArrayOf(1, 2))
    val f1 = Frame(listOf(1, 2))
    val f2 = Frame(listOf(1, 2))

    println("${p1 == p2} ${f1 == f2}")
}
```', 'OBJECTIVE'),
       (4890, 785, '아래 타입 계층에 대한 설명으로 옳은 것은?', '어떤 라이브러리 모듈이 공개 API로 아래 성격의 타입 계층을 제공한다.

- 이 타입을 상속하는 하위 타입의 집합이 컴파일 시점에 고정된다.
- 하위 타입은 라이브러리와 같은 모듈·같은 패키지 안에서만 선언할 수 있다(Kotlin 1.5부터 파일은 달라도 된다).
- 이 라이브러리를 의존하는 애플리케이션 모듈에서는 새 하위 타입을 만들 수 없다.', 'OBJECTIVE'),
       (4891, 785, '아래 표에 정리한 세 형태를 바탕으로 옳지 않은 것은?', '| 형태 | 문법 | 인스턴스가 만들어지는 시점 | 주요 용도 |
| --- | --- | --- | --- |
| object 선언 | `object Config { ... }` | 최초 접근 시. JVM 클래스 초기화 절차를 타므로 별도 동기화 없이 스레드 안전 | 싱글턴, 상태 없는 유틸리티 |
| companion object | `class A { companion object { ... } }` | 바깥 클래스가 초기화될 때 | 팩토리 메서드, 상수 |
| object 표현식 | `object : Listener { ... }` | 표현식을 평가할 때마다 새로 생성 | 익명 클래스 |', 'OBJECTIVE'),
       (4892, 785, '아래 Kotlin 코드를 실행했을 때 출력되는 값은?', '```kotlin
data class Tag(var name: String)

fun main() {
    val tag = Tag("kotlin")
    val set = hashSetOf(tag)

    tag.name = "java"

    println("${set.contains(tag)} ${set.first() === tag} ${set.size}")
}
```', 'OBJECTIVE'),
       (4893, 785, '아래 상황에서 컴파일러가 해 준 검사를 가리키는 용어는?', '결제 상태 계층에 하위 타입 하나를 새로 추가했더니, 이번에 한 줄도 손대지 않은 다른 파일 세 곳에서 빌드가 멈췄다.

```kotlin
sealed interface PayState {
    data object Ready : PayState
    data class Paid(val txId: String) : PayState
    data class Failed(val reason: String) : PayState
    data class Refunded(val amount: Int) : PayState   // 이번에 추가한 것
}

fun label(s: PayState): String = when (s) {
    PayState.Ready     -> "대기"
    is PayState.Paid   -> "완료"
    is PayState.Failed -> "실패"
}   // 여기서 빌드가 멈췄다
```

멈춘 세 곳은 모두 else 분기를 두지 않은 상태였고, 빠진 분기를 채워 넣자 빌드가 통과했다. 반면 else 분기를 둔 네 번째 파일은 아무 경고 없이 예전 그대로 빌드됐다.', 'SUBJECTIVE'),
       (4894, 785, '아래 코드에서 Point에는 쓸 수 있고 Plain에는 컴파일 에러가 난 선언 문법의 이름은?', '```kotlin
data class Point(val x: Int, val y: Int)
class Plain(val a: Int, val b: Int)

fun main() {
    val p = Point(3, 4)
    val (x, y) = p        // x = 3, y = 4
    println(x + y)        // 7

    val q = Plain(3, 4)
    val (a, b) = q        // 컴파일 에러: component1() 함수를 찾을 수 없다
    println(a + b)
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4889
(13211, 4889, 'true true', '자동 생성된 equals가 어떤 프로퍼티든 내용까지 비교해 준다고 본 오해. 배열의 equals는 기본 구현 그대로라 같은 인스턴스일 때만 true여서, 내용이 같아도 p1 == p2는 false다.', false),
(13212, 4889, 'false true', '자동 생성 equals는 주 생성자 프로퍼티마다 그 타입의 equals를 불러 쓴다. IntArray는 참조 비교라 서로 다른 인스턴스인 p1, p2가 false, List는 내용 비교라 f1, f2가 true다.', true),
(13213, 4889, 'false false', '자동 생성 equals가 프로퍼티의 참조만 본다고 본 오해. 실제로는 프로퍼티 타입이 스스로 구현한 equals를 따르므로, 내용을 비교하는 List를 담은 Frame 쪽은 true가 된다.', false),
(13214, 4889, 'true false', '배열은 내용 비교, 컬렉션은 참조 비교라고 거꾸로 외운 경우. 반대이기 때문에 배열 프로퍼티는 List로 바꾸거나 equals와 hashCode를 contentEquals 기반으로 직접 구현해야 한다.', false),

-- 문제 4890
(13215, 4890, '하위 타입마다 인스턴스가 정확히 하나씩만 존재하도록 컴파일러가 보장한다.', '상수마다 인스턴스가 하나인 enum의 성질을 갖다 붙인 오개념. 하위 타입 집합만 고정될 뿐이라, 값이 다른 하위 타입 인스턴스는 얼마든지 여러 개 만들 수 있다.', false),
(13216, 4890, 'when으로 분기할 때 각 분기에서 하위 타입의 프로퍼티를 읽으려면 매번 명시적 형변환을 써야 한다.', 'is 검사와 스마트 캐스트가 함께 동작한다는 점을 놓친 오개념. is로 타입을 좁힌 분기 안에서는 형변환 없이 그 하위 타입의 프로퍼티를 바로 읽을 수 있다.', false),
(13217, 4890, '라이브러리가 하위 타입을 하나 늘리면, else 없이 분기하던 사용자 모듈의 when이 컴파일 에러로 바뀔 수 있다.', '집합이 고정돼 있어 컴파일러가 빠진 분기를 잡아 주는데, 그 혜택이 공개 API에서는 양날이 된다. 하위 타입 추가가 사용자 코드를 깨뜨리는 변경이라 호환성 관점에서 신중해야 한다.', true),
(13218, 4890, '새 하위 타입이 언제든 늘 수 있으므로 표현식 when에는 else 분기를 반드시 적어야 한다.', '외부 모듈이 하위 타입을 마음대로 늘릴 수 있다고 본 오개념. 집합이 고정돼 모든 하위 타입을 적으면 else가 필요 없고, else를 두면 오히려 완전성 검사가 꺼진다.', false),

-- 문제 4891
(13219, 4891, '리스너를 만드는 함수에서 object 표현식을 100번 평가해 받은 값들은 모두 같은 인스턴스라 === 비교가 true다.', '거짓이라 정답이다. 표에서 object 표현식은 평가할 때마다 새로 만들어진다. 평가한 횟수만큼 서로 다른 인스턴스가 생기므로 === 비교는 false다. 싱글턴이 되는 쪽은 object 선언이다.', true),
(13220, 4891, '한 번도 참조되지 않은 object 선언은 프로그램이 끝날 때까지 초기화 블록이 실행되지 않는다.', '참인 진술이다. 표의 생성 시점이 최초 접근 시이므로, 그 경로를 한 번도 타지 않으면 JVM이 해당 클래스를 초기화하지 않아 초기화 비용도 들지 않는다.', false),
(13221, 4891, 'companion object의 팩토리 메서드를 한 번이라도 불렀다면 그 안에 선언한 상수도 이미 준비된 상태다.', '참인 진술이다. companion object는 바깥 클래스가 초기화될 때 함께 초기화되므로, 그 안의 메서드를 부를 수 있는 시점이면 초기화 블록과 상수도 이미 채워져 있다.', false),
(13222, 4891, '여러 스레드가 같은 순간에 object 선언을 처음 참조해도 인스턴스는 하나만 만들어진다.', '참인 진술이다. object 선언은 JVM 클래스 초기화 절차를 타서 만들어지고 그 절차 자체가 동기화돼 있어, 개발자가 잠금을 걸지 않아도 인스턴스가 둘 생기지 않는다.', false),

-- 문제 4892
(13223, 4892, 'true true 1', '같은 인스턴스를 넣었으니 contains도 당연히 찾아낸다고 본 오해. HashSet은 먼저 hashCode로 버킷을 고르는데, name이 바뀌며 hashCode도 달라져 넣을 때와 다른 버킷을 뒤지게 된다.', false),
(13224, 4892, 'false false 1', '컬렉션에 넣는 순간 값이 복사돼 옛 값이 남는다고 본 오해. 저장되는 것은 참조뿐이라 set 안의 객체와 tag는 같은 인스턴스이고, 그래서 === 비교는 true다.', false),
(13225, 4892, 'false true 0', '찾지 못했으니 원소도 빠져나갔다고 본 오해. hashCode가 달라져 조회만 실패했을 뿐 원소는 그대로 남아 있어 size는 1이다.', false),
(13226, 4892, 'false true 1', 'name을 바꾸는 순간 hashCode가 달라져 넣을 때와 다른 버킷을 뒤지므로 contains는 false다. 저장된 것은 같은 참조라 === 는 true이고, 원소가 빠진 것도 아니라 size는 1이다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1586, 4893, '완전성 검사,완전성검사,완전성,완전성 체크,exhaustiveness check,exhaustiveness,exhaustive check,exhaustive,철저성 검사,망라성 검사', 'when의 대상이 sealed 타입·enum·Boolean이면 컴파일러가 모든 경우를 덮었는지 확인해 주는데, 이것이 완전성 검사다. 하위 타입 집합이 컴파일 시점에 고정돼 있어야 가능한 검사라서 아무 클래스에나 되는 것이 아니다. 값을 돌려주는 표현식 when은 처음부터 완전성이 강제되었고, Kotlin 1.7부터는 값을 돌려주지 않는 문장 형태의 when도 대상이 sealed·enum·Boolean이면 분기가 빠진 순간 컴파일 에러가 된다. 본문에서 else를 둔 네 번째 파일만 조용히 빌드된 이유가 여기 있다. else는 남은 경우를 모두 받아 버려 검사를 꺼 놓으므로, 상태가 늘어나도 고쳐야 할 자리를 알려 주지 않는다. 분기 안에서 하위 타입의 프로퍼티를 형변환 없이 읽게 해 주는 스마트 캐스트는 이와 별개의 기능이니 구분하자.'),
       (1587, 4894, '구조 분해 선언,구조분해 선언,구조 분해,구조분해,구조 분해 할당,구조 분해 대입,destructuring declaration,destructuring declarations,destructuring,디스트럭처링', 'data class는 주 생성자 프로퍼티마다 component1(), component2()를 차례로 자동 생성하고, val (x, y) = p 같은 구조 분해 선언은 바로 이 componentN() 연산자 함수를 순서대로 불러 값을 나눠 담는다. Plain처럼 componentN()이 없는 일반 클래스에서는 같은 문법이 컴파일 에러가 되며, operator fun component1()을 직접 선언해 주면 일반 클래스에서도 쓸 수 있다. 즉 data class 전용 문법이 아니라 componentN()이 있느냐의 문제다. 주의할 점은 변수 이름이 아니라 선언 순서로 값을 받는다는 것이다. 주 생성자에서 프로퍼티 순서를 바꾸면 타입이 같은 한 컴파일은 그대로 통과하면서 값만 조용히 뒤바뀐다. 일부 값만 바꿔 새 인스턴스를 만드는 copy()와는 쓰임이 다르니 함께 정리해 두자.');

-- =====================================================
-- Lesson 943: Kotlin data class 제약과 sealed·object로 상태 설계하기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5837, 943, '아래 Kotlin 코드를 실행하면 출력되는 값은?', '```kotlin
data class Filter(val keyword: String, val page: Int = 1, val size: Int = 20)

fun main() {
    val base = Filter("kotlin", size = 50)
    val next = base.copy(page = base.page + 1)
    val back = next.copy(page = 1)

    println("${base == back} ${base === back} ${next.size}")
}
```', 'OBJECTIVE'),
       (5838, 943, '아래 비교표의 두 모델링 방식에 대한 설명으로 옳은 것은?', '한 화면의 상태를 아래 두 가지로 모델링했다.

| 구분 | 방식 A | 방식 B |
| --- | --- | --- |
| 선언 | Boolean 프로퍼티 isLoading, isError, isEmpty 세 개 | sealed interface UiState의 하위 타입 Loading, Error(cause), Empty 세 개 |
| 상태 판별 | if로 플래그를 하나씩 확인 | when으로 하위 타입을 분기(else 분기는 두지 않음) |
| 화면이 실제로 쓰는 상태 | 3가지 | 3가지 |
| 새 상태 추가 | 플래그 프로퍼티를 하나 더 선언 | 하위 타입을 하나 더 선언 |', 'OBJECTIVE'),
       (5839, 943, '아래 네 선언 가운데 컴파일되지 않는 것과 그 까닭으로 옳은 것은?', '```kotlin
data class Cart(var count: Int)                    // ㄱ

data class Session(val id: String) {               // ㄴ
    var lastSeen: Long = 0
}

data class Empty()                                 // ㄷ

open class Base(val tag: String)
data class Child(val id: Long) : Base("c")         // ㄹ
```

네 선언은 모두 같은 파일에 있고, 이 가운데 하나만 빌드가 멈춘다.', 'OBJECTIVE'),
       (5840, 943, '아래 코드의 main을 실행했을 때 출력되는 값은?', '```kotlin
interface Listener {
    fun tag(): String
}

object Global : Listener {
    override fun tag() = "G"
}

class Screen {
    companion object {
        fun newListener(): Listener = object : Listener {
            override fun tag() = "S"
        }
    }
}

fun main() {
    val a: Listener = Global
    val b: Listener = Global
    val c = Screen.newListener()
    val d = Screen.newListener()

    println("${a === b} ${c === d} ${c.tag() == d.tag()}")
}
```', 'OBJECTIVE'),
       (5841, 943, '아래 상황에서 PlainKey로 만든 캐시만 조회에 실패하게 만든 메서드의 이름은?', '회원 캐시를 HashMap에 담아 두고 값이 같은 새 키로 다시 조회하는 코드를 점검했다. 두 키 클래스 모두 == 비교는 true로 나오는데, 캐시 조회 결과는 갈렸다.

```kotlin
class PlainKey(val id: Long) {
    override fun equals(other: Any?) = other is PlainKey && other.id == id
}

data class DataKey(val id: Long)

fun main() {
    val c1 = hashMapOf(PlainKey(1L) to "회원A")
    val c2 = hashMapOf(DataKey(1L) to "회원A")

    println(PlainKey(1L) == PlainKey(1L))   // true
    println(DataKey(1L) == DataKey(1L))     // true

    println(c1[PlainKey(1L)])               // null
    println(c2[DataKey(1L)])                // 회원A
}
```', 'SUBJECTIVE'),
       (5842, 943, '아래 코드에서 lenA는 컴파일되고 lenB는 컴파일되지 않는다. lenA에서만 동작한 컴파일러 기능의 이름은?', '```kotlin
sealed interface Msg {
    data class Text(val body: String) : Msg
    data class Img(val url: String) : Msg
}

class Screen {
    var current: Msg = Msg.Text("hi")

    fun lenA(m: Msg): Int = when (m) {          // 컴파일 통과
        is Msg.Text -> m.body.length
        is Msg.Img -> m.url.length
    }

    fun lenB(): Int = when (current) {          // 컴파일 실패
        is Msg.Text -> current.body.length      // current에서 body를 읽을 수 없다
        is Msg.Img -> current.url.length        // current에서 url을 읽을 수 없다
    }
}
```

lenB의 when 안에서 val 지역 변수에 current를 한 번 받아 두고 그 변수로 분기하자 lenA와 똑같이 컴파일됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5837
(15739, 5837, 'true true 50', 'copy()가 값이 같으면 원래 인스턴스를 그대로 돌려준다고 본 오해. copy()는 주 생성자 값을 넘겨 언제나 새 객체를 만들므로, 값이 같아 ==는 true여도 참조 비교인 ===는 false다.', false),
(15740, 5837, 'true false 50', 'copy()는 인자로 주지 않은 프로퍼티를 호출 대상의 현재 값 그대로 넘기므로 next.size는 base에서 이어받은 50이다. back은 세 값이 base와 같아 equals는 true, 새로 만든 객체라 ===는 false다.', true),
(15741, 5837, 'true false 20', 'copy()가 인자로 주지 않은 프로퍼티를 선언부의 기본값으로 되돌린다고 본 오해. 기본값은 생성자를 직접 부를 때만 쓰이고, copy()는 지금 들어 있는 값을 그대로 옮긴다.', false),
(15742, 5837, 'false false 50', '==도 참조를 비교한다고 본 오해. data class가 자동 생성한 equals는 주 생성자 프로퍼티를 값으로 비교하므로, 서로 다른 객체여도 세 값이 모두 같으면 ==는 true가 된다.', false),

-- 문제 5838
(15743, 5838, '방식 B는 하위 타입을 하나 더 늘려도 이미 써 둔 when 분기는 손댈 필요가 없어, 플래그를 늘리는 방식 A보다 고칠 자리가 적다.', 'else 없이 모든 하위 타입을 적어 둔 when은 하위 타입이 늘어난 순간 컴파일 에러가 난다. 고칠 자리가 없는 것이 아니라, 어디를 고쳐야 하는지 컴파일러가 짚어 주는 것이 이 방식의 이점이다.', false),
(15744, 5838, '방식 A도 컴파일러가 플래그 조합을 검사해 주므로, isLoading과 isError가 함께 true가 되는 코드는 빌드 단계에서 걸러진다.', '플래그 여러 개로 상태를 나타내면 컴파일러는 그 변수들 사이의 관계를 알 수 없다. 각 Boolean은 독립된 변수일 뿐이라 모순된 조합도 그대로 빌드되고, 문제는 실행 중에야 드러난다.', false),
(15745, 5838, '방식 B의 하위 타입은 상태마다 인스턴스가 하나씩만 존재하므로, 원인이 서로 다른 Error를 같은 시점에 둘 이상 만들 수 없다.', '상수마다 인스턴스가 하나인 enum의 성질을 sealed에 갖다 붙인 오개념. sealed는 하위 타입 집합만 고정될 뿐이라 Error(네트워크)와 Error(타임아웃)를 동시에 만들어 둘 수 있다.', false),
(15746, 5838, '방식 A는 플래그 세 개의 조합이 8가지라 화면이 쓰지 않는 5가지까지 코드로 표현되지만, 방식 B는 하위 타입 셋 가운데 하나만 될 수 있다.', 'Boolean 세 개면 2의 3제곱인 8가지 조합이 생기고, 화면이 정의한 3가지를 뺀 5가지는 의미 없는 상태다. 방식 B는 값이 하위 타입 셋 중 하나로 정해져 그런 조합이 아예 생기지 않는다.', true),

-- 문제 5839
(15747, 5839, 'ㄱ — data class의 주 생성자 프로퍼티는 val로만 선언할 수 있어 var를 쓰면 컴파일 에러다.', 'data class는 val만 쓰라는 권고를 문법 제약으로 오해한 것. 주 생성자 프로퍼티는 val과 var 모두 허용된다. 다만 var 값을 바꾸면 hashCode가 달라져 해시 컬렉션에서 못 찾게 되므로 권장되지 않을 뿐이다.', false),
(15748, 5839, 'ㄴ — data class는 주 생성자 밖 본문에 프로퍼티를 선언할 수 없다.', '본문 프로퍼티가 자동 생성에서 빠지는 것을 선언 금지로 오해한 것. 본문에도 얼마든지 선언할 수 있고, 다만 equals·hashCode·toString·copy가 그 프로퍼티를 다루지 않을 뿐이다.', false),
(15749, 5839, 'ㄷ — data class는 주 생성자에 파라미터가 적어도 하나 있어야 한다.', '자동 생성되는 equals·hashCode·componentN이 모두 주 생성자 프로퍼티를 기준으로 만들어지는데, 기준이 하나도 없으면 생성할 내용이 없다. 그래서 파라미터가 빈 data class는 선언 단계에서 막힌다.', true),
(15750, 5839, 'ㄹ — data class는 다른 클래스를 상속할 수 없다.', 'data class가 abstract·open·sealed·inner가 될 수 없다는 제약을 상속 자체가 막힌 것으로 오해한 것. 자신이 상속의 부모가 되지 못할 뿐, open 클래스를 상속받는 것은 가능하다.', false),

-- 문제 5840
(15751, 5840, 'true false true', 'object 선언은 최초 접근 때 만든 인스턴스 하나를 계속 쓰므로 Global을 몇 번 참조해도 같은 객체다. object 표현식은 평가할 때마다 새 인스턴스를 만들어 c와 d의 참조는 다르지만, 두 인스턴스가 돌려주는 tag() 값은 똑같이 S다.', true),
(15752, 5840, 'true true true', 'object라는 키워드가 붙으면 모두 싱글턴이라고 본 오해. 이름을 붙인 object 선언만 인스턴스가 하나이고, 함수 안에서 쓰는 object 표현식은 호출할 때마다 새 익명 객체를 만든다.', false),
(15753, 5840, 'false false true', 'Global을 참조할 때마다 새로 만들어진다고 본 오해. object 선언은 처음 접근하는 순간 JVM 클래스 초기화로 한 번만 만들어지고, 이후 참조는 모두 그 인스턴스를 가리킨다.', false),
(15754, 5840, 'true false false', '인스턴스가 다르면 메서드 결과도 달라진다고 본 오해. tag()는 어느 인스턴스에서 불러도 같은 문자열 S를 돌려주고, 문자열 ==는 내용을 비교하므로 마지막 값은 true다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1902, 5841, 'hashCode,hashCode(),hashcode,hash code,해시코드,해시 코드,hashCode 메서드', 'HashMap은 키의 hashCode()로 먼저 버킷을 고른 뒤 그 안에서만 equals로 비교한다. PlainKey는 equals만 직접 구현하고 hashCode는 물려받은 기본 구현 그대로라 인스턴스마다 값이 달라진다. 그래서 값이 같은 새 키로 조회하면 애초에 다른 버킷을 뒤지게 되고, equals까지 가 보지도 못한 채 null이 나온다. data class는 주 생성자 프로퍼티를 기준으로 equals와 hashCode를 함께 자동 생성하므로 값이 같으면 hashCode도 같아 DataKey 쪽은 정상으로 찾아진다. equals만 재정의하고 hashCode를 빠뜨리면 == 비교는 멀쩡히 통과하면서 해시 컬렉션에서만 조용히 실패한다는 점을 기억하자. 같은 계약이 반대 방향으로 깨지는 경우도 있다. hashCode에 쓰이는 프로퍼티를 var로 두고 컬렉션에 담은 뒤 값을 바꾸면, 넣어 둔 원소를 같은 인스턴스로도 찾지 못하게 된다.'),
       (1903, 5842, '스마트 캐스트,스마트캐스트,smart cast,smartcast,smart-cast,스마트 캐스팅,스마트캐스팅', 'is로 타입을 확인하고 나면 그 분기 안에서 컴파일러가 값을 해당 하위 타입으로 좁혀 주어, as 같은 명시적 형변환 없이 Text의 body나 Img의 url을 바로 읽을 수 있다. 이것이 스마트 캐스트다. lenB가 막히는 까닭은 current가 클래스의 var 프로퍼티여서, 타입을 확인한 시점과 값을 읽는 시점 사이에 다른 코드나 다른 스레드가 값을 바꿔 놓을 수 있기 때문이다. 컴파일러는 그 사이에 타입이 유지된다고 장담할 수 없어 좁히기를 포기한다. 본문처럼 val 지역 변수에 한 번 받아 두면 값이 바뀔 수 없으므로 lenA와 똑같이 동작한다. 분기를 빠짐없이 적었는지 확인해 주는 완전성 검사와는 다른 기능이다. 완전성 검사는 어떤 경우가 빠졌는지를 보고, 스마트 캐스트는 좁혀진 타입으로 프로퍼티에 접근하게 해 준다.');
