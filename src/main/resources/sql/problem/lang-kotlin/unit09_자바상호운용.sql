-- Unit: 자바 상호운용 (Unit ID: 204)
-- Chapter: Kotlin (Chapter ID: 19)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (630, 204, '동반 객체 호출과 SAM 변환, 기본 인자'),
       (788, 204, '검사 예외와 널 어노테이션, 와일드카드'),
       (946, 204, 'Kotlin·자바 상호운용 심화: 배열·가변 인자, object 멤버 노출, 널 파라미터 검사, 와일드카드, suspend 래퍼');

-- =====================================================
-- Lesson 630: 동반 객체 호출과 SAM 변환, 기본 인자
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3959, 630, '아래 Kotlin 선언을 자바 코드에서 호출하는 방법으로 옳은 것은?', '아래는 라이브러리로 배포한 Kotlin 파일이다. 어노테이션은 하나도 붙이지 않았다.

```kotlin
// Report.kt
class Report(val title: String) {
    companion object {
        fun empty(): Report = Report("")
    }

    fun render(width: Int = 80, color: Boolean = false): String = TODO()
}
```', 'OBJECTIVE'),
       (3960, 630, '아래 코드에서 컴파일 에러가 발생하는 줄은?', '아래는 한 Kotlin 파일의 일부다.

```kotlin
fun interface Formatter { fun format(s: String): String }
interface Validator { fun validate(s: String): Boolean }

val executor = Executors.newSingleThreadExecutor()

val a = Formatter { it.trim() }            // ㉠
val b = Validator { it.isNotBlank() }      // ㉡
val c = Runnable { println("실행") }        // ㉢
executor.execute { println("작업") }        // ㉣
```', 'OBJECTIVE'),
       (3961, 630, '아래 자바 클래스를 Kotlin에서 호출한 코드에 대한 설명으로 옳은 것은?', '```java
public class LegacyFile {
    public String getPath() { ... }
    public void setPath(String p) { ... }
    public boolean isOpen() { ... }
    public void write(byte[] data) throws IOException { ... }
}
```

```kotlin
val f = LegacyFile()
f.path = "/tmp/a.txt"          // ㉠
if (f.isOpen) println("열림")   // ㉡
f.write(byteArrayOf(1, 2))     // ㉢ (try/catch 없이 호출)
```', 'OBJECTIVE'),
       (3962, 630, '아래 표를 바탕으로 옳지 않은 것은?', '자바 팀에 공개할 Kotlin 선언과, 어노테이션 없이 컴파일했을 때 자바에서 보이는 형태를 정리한 표다.

| Kotlin 선언 (파일 FeedApi.kt) | 자바에서 보이는 형태 |
|---|---|
| `fun refresh()` — 최상위 함수 | `FeedApiKt.refresh()` |
| `object Cache { fun clear() }` | `Cache.INSTANCE.clear()` |
| `class Feed(val title: String)` | `feed.getTitle()` |
| `suspend fun load(id: Long): Feed` | `Object load(long, Continuation<? super Feed>)` |', 'OBJECTIVE'),
       (3963, 630, '아래에서 라이브러리 쪽 함수 선언에 추가한 어노테이션은?', 'Kotlin으로 만든 사내 라이브러리를 자바 서비스 팀에 배포했다.

```kotlin
class Mailer {
    fun send(to: String, subject: String = "(제목 없음)", html: Boolean = false) { }
}
```

Kotlin 테스트에서는 `mailer.send("a@b.com")`이 그대로 통과했지만, 자바 서비스의 빌드는 아래 오류로 멈췄다.

```
error: method send in class Mailer cannot be applied to given types;
  required: String,String,boolean
  found:    String
```

라이브러리의 `send` 선언에 어노테이션 하나를 추가해 다시 배포하자, 자바에서도 `send("a@b.com")`과 `send("a@b.com", "안내")`가 모두 컴파일됐다.', 'SUBJECTIVE'),
       (3964, 630, '아래에서 findNickname의 반환값이 Kotlin 쪽에서 갖는 타입을 가리키는 용어는?', '널 관련 어노테이션이 전혀 없는 자바 라이브러리를 Kotlin에서 쓰고 있다.

```kotlin
// Java: public String findNickname(long id)
val nick = api.findNickname(42)   // IDE는 이 값의 타입을 String! 으로 표시한다
println(nick.length)              // 컴파일 통과
```

별명을 등록하지 않은 사용자를 조회하자 `nick.length`에서 NullPointerException이 발생했다. 컴파일러는 이 줄에 널 검사도, 안전 호출(`?.`)도 요구하지 않았다. 라이브러리 쪽 `findNickname`에 `@Nullable`을 붙여 다시 빌드하니 같은 줄이 컴파일 에러로 바뀌었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3959
(10731, 3959, 'Report.Companion.empty()', 'companion object 멤버는 @JvmStatic이 없으면 Companion 객체의 인스턴스 메서드로 컴파일된다. 그래서 자바에서는 Report.Companion을 거쳐 호출해야 한다.', true),
(10732, 3959, 'Report.empty()', 'companion 멤버가 자바 static과 같다고 본 오해. 진짜 static 메서드는 empty에 @JvmStatic을 붙였을 때만 생성된다.', false),
(10733, 3959, 'ReportKt.empty()', '파일명 + Kt 클래스는 최상위 선언을 담는 그릇이다. empty는 클래스 안 companion 멤버라 ReportKt에는 들어가지 않는다.', false),
(10734, 3959, 'new Report("월간").render()', '기본 인자는 Kotlin 호출 지점에서만 채워진다. @JvmOverloads가 없으면 자바에는 render(int, boolean) 하나만 노출돼 두 인자를 모두 넘겨야 한다.', false),

-- 문제 3960
(10735, 3960, '㉠ — val a = Formatter { it.trim() }', 'fun interface는 SAM 변환을 허용하려고 붙이는 표시다. 추상 메서드가 하나인 fun interface는 람다로 바로 인스턴스를 만들 수 있다(Kotlin 1.4+).', false),
(10736, 3960, '㉡ — val b = Validator { it.isNotBlank() }', 'Kotlin의 일반 인터페이스는 추상 메서드가 하나여도 SAM 변환 대상이 아니다. object : Validator { ... } 표현식을 쓰거나 선언 앞에 fun을 붙여야 한다.', true),
(10737, 3960, '㉢ — val c = Runnable { println("실행") }', 'Runnable은 자바 SAM 인터페이스다. 변수에 담을 때는 이처럼 SAM 생성자 형태로 변환 대상 타입을 밝혀 주면 된다.', false),
(10738, 3960, '㉣ — executor.execute { println("작업") }', '자바 메서드의 SAM 파라미터 자리에 넘긴 람다는 Runnable 구현체로 자동 변환된다. SAM 변환이 가장 흔하게 쓰이는 형태다.', false),

-- 문제 3961
(10739, 3961, '㉠은 필드에 직접 대입하는 문법이라 setPath가 호출되지 않는다.', '프로퍼티 대입처럼 보이지만 컴파일 결과는 setPath 호출이다. Kotlin은 getX/setX 쌍을 x 프로퍼티로 보여줄 뿐 필드에 직접 접근하지 않는다.', false),
(10740, 3961, '㉡은 getter 이름 규칙상 f.open으로 써야 프로퍼티처럼 접근된다.', 'is로 시작하는 boolean getter는 이름을 그대로 쓴다는 규칙을 놓친 오해. isOpen()은 f.isOpen으로 접근하며 f.open이라는 이름은 존재하지 않는다.', false),
(10741, 3961, '㉢은 write가 IOException을 선언했으므로 try/catch로 감싸지 않으면 컴파일되지 않는다.', 'Kotlin에는 검사 예외 개념이 없어 throws 선언을 강제하지 않는다. try/catch 없이도 컴파일되며, 잡을지 말지는 호출하는 쪽이 정한다.', false),
(10742, 3961, '㉢처럼 자바의 byte[] 파라미터에는 Kotlin의 ByteArray를 그대로 넘길 수 있다.', '자바의 기본형 배열 int[]·byte[]는 Kotlin의 IntArray·ByteArray와 곧바로 대응한다. Array<Byte>는 박싱된 Byte[]에 해당해 이 자리에는 넘길 수 없다.', true),

-- 문제 3962
(10743, 3962, 'refresh를 자바에서 FeedApi.refresh()로 부르려면 파일 맨 위에 @file:JvmName("FeedApi")가 필요하다.', '최상위 함수는 파일명 기반 FeedApiKt에 담긴다. 표의 FeedApiKt.refresh()를 FeedApi.refresh()로 바꾸려면 파일 수준에서 클래스 이름을 지정해야 한다.', false),
(10744, 3962, 'Cache.clear() 형태로 부르려면 clear에 @JvmStatic을 붙여야 한다.', '표처럼 object 멤버 호출은 INSTANCE를 거친다. @JvmStatic을 붙이면 static 메서드가 함께 생성돼 Cache.clear()로 부를 수 있다.', false),
(10745, 3962, 'load는 자바에서 Feed를 그대로 돌려주므로 반환값을 Feed 변수에 바로 담을 수 있다.', '표의 시그니처는 반환 타입이 Object이고 Continuation 파라미터가 붙는다. suspend 함수는 자바에서 Feed를 바로 받지 못해 CompletableFuture 래퍼 등을 따로 제공한다.', true),
(10746, 3962, 'feed.title처럼 필드로 직접 읽으려면 title에 @JvmField를 붙여야 한다.', '표의 getTitle()은 프로퍼티가 getter로 노출된 결과다. @JvmField를 붙이면 getter 없이 public 필드로 노출돼 feed.title로 읽을 수 있다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1276, 3963, '@JvmOverloads,JvmOverloads,@kotlin.jvm.JvmOverloads,kotlin.jvm.JvmOverloads', '기본 인자는 Kotlin 호출 지점에서 채워지므로 자바에는 전체 인자를 받는 오버로드 하나만 노출된다. 오류 로그의 required: String,String,boolean이 그 증거다. @JvmOverloads를 붙이면 기본값이 있는 파라미터를 뒤에서부터 하나씩 뺀 오버로드가 함께 생성돼 자바에서도 인자를 생략할 수 있다. companion·object 멤버를 static으로 노출하는 @JvmStatic, 프로퍼티를 필드로 노출하는 @JvmField와 역할이 다르다.'),
       (1277, 3964, '플랫폼 타입,플랫폼타입,platform type,platformtype,platform types', '널 어노테이션이 없는 자바 타입은 Kotlin이 널 가능·널 불가 어느 쪽으로도 확정하지 않고 판단을 개발자에게 넘긴다(String! 표기). 그래서 컴파일 시점 검사가 없고, 널이 들어오면 사용하는 줄에서 NullPointerException이 난다. @Nullable을 붙이자 String?으로 읽혀 컴파일 에러가 된 것이 바로 그 차이다. 널 가능 타입(String?)은 컴파일러가 안전 호출을 강제한다는 점에서 플랫폼 타입과 구분되고, JSpecify @NullMarked가 붙은 범위는 Kotlin 2.1부터 strict로 처리된다.');

-- =====================================================
-- Lesson 788: 검사 예외와 널 어노테이션, 와일드카드
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4907, 788, '아래 자바 빌드 오류에 대한 설명으로 옳은 것은?', 'Kotlin으로 만든 모듈을 자바 서비스에서 호출하자 자바 쪽 빌드만 실패했다. Kotlin 테스트는 모두 통과한다.

```kotlin
// Archive.kt
class Archive {
    fun extract(path: String) {
        if (path.isEmpty()) throw IOException("경로가 비었다")
    }
}
```

```java
// Java
try {
    new Archive().extract(zipPath);
} catch (IOException e) {
    log.warn(e.getMessage());
}
```

```
error: exception java.io.IOException is never thrown in body of corresponding try statement
```', 'OBJECTIVE'),
       (4908, 788, '아래 표를 바탕으로 옳지 않은 것은?', 'Kotlin 2.1 프로젝트에서 자바 라이브러리 네 개를 함께 쓰고 있다. 각 라이브러리가 붙인 널 어노테이션과, 컴파일러 옵션을 따로 켜지 않고 빌드했을 때의 결과를 정리한 표다.

| 라이브러리 | 널 어노테이션 | 기본 옵션으로 빌드한 결과 |
|---|---|---|
| A | 없음 | 반환값을 널 불가 변수에 그대로 대입해도 경고·에러 없음 |
| B | org.jspecify.annotations의 @NullMarked 범위 + @Nullable | @Nullable 반환값을 널 불가 변수에 대입하면 컴파일 에러 |
| C | javax.annotation(JSR-305)의 @Nonnull | 위반해도 경고만 출력되고 빌드는 계속됨 |
| D | org.jetbrains.annotations의 @NotNull | @NotNull 반환값이 널 불가 타입으로 읽힘 |', 'OBJECTIVE'),
       (4909, 788, '아래 Kotlin 선언이 자바에서 보이는 시그니처는?', 'Item은 Kotlin 클래스이고, Kotlin 표준 라이브러리의 List는 원소 타입이 공변(out)으로 선언돼 있다. 자바 팀이 아래 선언을 디컴파일해 시그니처를 확인하려 한다.

```kotlin
// Board.kt
class Board {
    fun render(items: List<@JvmSuppressWildcards Item>) { }
}
```', 'OBJECTIVE'),
       (4910, 788, '아래 빌드 오류를 없애려고 자바 쪽을 고치는 방법으로 옳은 것은?', 'Kotlin으로 만든 이벤트 모듈을 자바 서비스에서 처음 쓰는 중이다. Kotlin 쪽 호출 bus.subscribe { log.info(it.name) }은 문제없이 돌아간다. 모듈 코드는 고칠 수 없다.

```kotlin
// EventBus.kt
class EventBus {
    fun subscribe(handler: (Event) -> Unit) { }
}
```

```java
// Java — IDE는 subscribe의 파라미터를 Function1<Event, Unit>으로 표시한다
bus.subscribe(event -> {
    log.info(event.getName());
});
```

```
error: incompatible types: bad return type in lambda expression
    missing return value
```', 'OBJECTIVE'),
       (4911, 788, '아래에서 RetryPolicy 선언에 덧붙인 키워드는?', '사내 클라이언트 라이브러리에 아래 인터페이스가 있다. 추상 메서드가 하나뿐인데도 호출부에서 client.configure { it < 3 } 은 컴파일되지 않아, 팀원들이 매번 아래처럼 길게 쓰고 있었다.

```kotlin
interface RetryPolicy { fun shouldRetry(attempt: Int): Boolean }

client.configure(object : RetryPolicy {
    override fun shouldRetry(attempt: Int) = attempt < 3
})
```

선언 앞에 키워드 하나를 덧붙여 다시 컴파일하자 client.configure { it < 3 } 이 그대로 통과했고, 자바 팀이 같은 자리에 넘기던 람다도 그대로 동작했다.', 'SUBJECTIVE'),
       (4912, 788, '아래에서 빌드 오류를 없애려고 함수 선언 위에 붙인 어노테이션은?', '통계 유틸을 Kotlin으로 옮기다 아래 오류로 빌드가 멈췄다.

```kotlin
// Stats.kt
fun List<Int>.total(): Int = sum()
fun List<String>.total(): Int = sumOf { it.length }
```

```
error: platform declaration clash: The following declarations have the same JVM signature (StatsKt.total(Ljava/util/List;)I)
```

두 번째 함수 선언 위에 어노테이션 한 줄을 붙여 다시 빌드하니 오류가 사라졌다. 자바 팀이 본 StatsKt에는 메서드가 두 개 생겼고, Kotlin 호출부는 고치기 전과 똑같이 list.total() 로 쓴다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4907
(13259, 4907, 'Kotlin은 예외를 모두 런타임 예외로 감싸 던지므로 자바에서는 RuntimeException으로 잡아야 한다.', 'Kotlin이 예외를 다시 포장한다고 본 오해. 던져지는 객체는 그대로 java.io.IOException이며, 자바 컴파일러는 객체가 아니라 메서드 시그니처의 throws 정보로 잡을 수 있는지를 판단한다.', false),
(13260, 4907, 'extract의 JVM 시그니처에 throws가 남지 않아 자바 컴파일러가 이 예외는 올 수 없다고 본 것이며, 선언에 @Throws(IOException::class)를 붙이면 해결된다.', 'Kotlin에는 검사 예외 개념이 없어 throws를 바이트코드에 기록하지 않는다. 그래서 자바의 catch 절이 절대 도달할 수 없는 것으로 취급돼 컴파일이 막힌다. @Throws가 그 기록을 되살려 준다.', true),
(13261, 4907, 'Kotlin 쪽 extract 본문을 try/catch로 감싸 IOException을 처리해야 자바 빌드가 통과한다.', 'Kotlin도 검사 예외 처리를 강제한다고 본 오해. Kotlin은 선언·호출 어느 쪽에도 처리를 요구하지 않으며, Kotlin 안에서 잡아 버리면 예외가 사라질 뿐 자바가 보는 시그니처는 그대로다.', false),
(13262, 4907, 'Archive.kt의 멤버는 자바에서 ArchiveKt 클래스로 노출되므로 그 이름으로 호출해야 예외 정보가 함께 보인다.', '파일명 뒤에 Kt를 붙인 클래스는 최상위 선언을 담는 그릇이다. extract는 Archive 클래스의 멤버라 자바에서도 Archive의 인스턴스 메서드이고, 노출 이름은 throws 기록 여부와 상관이 없다.', false),

-- 문제 4908
(13263, 4908, 'A의 반환값은 널 여부가 확정되지 않은 채 들어오고, 실제로 널이 오면 컴파일이 아니라 그 값을 쓰는 지점에서 예외로 드러난다.', '참인 진술. 어노테이션이 없으면 컴파일러가 널 판단을 개발자에게 넘겨 검사도 강제하지 않는다. 그래서 표처럼 빌드가 조용히 지나가고 문제가 실행 시점으로 미뤄진다.', false),
(13264, 4908, 'B에서 @Nullable이 붙지 않은 반환값은 따로 표시하지 않아도 널 불가로 읽힌다.', '참인 진술. @NullMarked는 그 범위 전체의 기본값을 널 불가로 바꾼다. 예외적으로 @Nullable을 붙인 것만 널 가능으로 갈리고, 나머지는 표시가 없어도 널 불가가 된다.', false),
(13265, 4908, 'C의 위반을 빌드 실패로 다루려면 -Xjsr305=strict 같은 컴파일러 옵션을 따로 켜야 한다.', '참인 진술. JSR-305는 기본 처리가 경고라 표처럼 빌드를 멈추지 않는다. 옵션으로 에러 승격을 켜야 경계에서의 널 위반이 빌드 단계에서 걸린다.', false),
(13266, 4908, 'D의 @NotNull은 IDE 표시용 힌트일 뿐이라 Kotlin 컴파일러는 이를 무시하고 A와 똑같이 처리한다.', '거짓이라 정답. JetBrains 어노테이션은 Kotlin이 기본으로 인식해 표처럼 널 불가 타입으로 읽는다. 어노테이션이 없는 A와 달리 널을 넘기면 컴파일 단계에서 걸러진다.', true),

-- 문제 4909
(13267, 4909, 'void render(java.util.List<Item> items)', '@JvmSuppressWildcards가 와일드카드 방출을 꺼서 원소 타입이 그대로 남는다. 자바 호출자는 List<Item>을 그대로 넘길 수 있어 경계에서 다루기 쉬워진다.', true),
(13268, 4909, 'void render(java.util.List<? extends Item> items)', '어노테이션을 붙이지 않았을 때 나오는 기본 형태. 공변으로 선언된 원소 타입은 파라미터 위치에서 와일드카드로 방출되는데, 본문의 어노테이션이 바로 그 변환을 끈다.', false),
(13269, 4909, 'void render(java.util.List<? super Item> items)', '공변(out)을 반공변(in)으로 뒤집어 본 오해. ? super 형태는 List<in T>처럼 반공변으로 선언된 자리에서 나오며, out 선언에서는 나오지 않는다.', false),
(13270, 4909, 'void render(java.util.List items)', '어노테이션이 제네릭 타입 인자까지 지운다고 본 오해. 사라지는 것은 와일드카드뿐이고 원소 타입 Item은 시그니처에 그대로 남는다.', false),

-- 문제 4910
(13271, 4910, '자바 표준 java.util.function.Consumer<Event> 구현을 만들어 subscribe에 넘긴다.', 'Kotlin 함수 타입이 자바 표준 함수형 인터페이스와 호환된다고 본 오해. 파라미터 타입은 kotlin.jvm.functions.Function1이라 Consumer 구현체는 그 자리에 대입되지 않는다.', false),
(13272, 4910, '람다 파라미터에 타입을 명시해 (Event event) -> { ... } 형태로 바꾼다.', '반환 타입 추론이 문제라고 본 오해. 파라미터 타입을 적어도 Function1의 반환 타입은 Unit 그대로라 반환값이 없다는 오류가 똑같이 남는다.', false),
(13273, 4910, '람다 본문 끝에 return Unit.INSTANCE; 를 넣어 kotlin.Unit 값을 반환한다.', '(Event) -> Unit은 자바에서 Function1<Event, Unit>으로 보이고 Unit도 값이 있는 타입이다. 자바에는 반환을 생략하는 축약이 없어 유일한 인스턴스인 Unit.INSTANCE를 직접 돌려줘야 한다.', true),
(13274, 4910, 'new Function1<Event, Unit>() 익명 클래스로 invoke를 구현하고 본문 끝에서 아무 값도 반환하지 않는다.', '람다 문법 탓이라고 본 오해. 익명 클래스로 바꿔도 invoke의 반환 타입은 Unit이라 값을 돌려주지 않으면 같은 오류가 그대로 난다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1592, 4911, 'fun,fun interface,funinterface,fun interface 키워드', 'Kotlin의 일반 인터페이스는 추상 메서드가 하나여도 SAM 변환 대상이 아니다. 함수 타입 (A) -> B가 이미 있으니 굳이 인터페이스를 람다로 만들 이유가 없다는 설계 판단 때문이며, 그래서 본문처럼 object 표현식을 써야 했다. interface 앞에 fun을 붙여 fun interface(Kotlin 1.4+)로 선언하면 람다로 바로 인스턴스를 만들 수 있고, 자바 쪽에서도 함수형 인터페이스로 쓰여 양쪽 사용성이 좋아진다. Runnable 같은 자바 SAM 인터페이스는 처음부터 자동 변환 대상이라 이 키워드가 필요 없고, 함수 타입을 파라미터로 받는 방식은 자바 호출자가 Unit.INSTANCE를 반환해야 한다는 점에서 구분된다.'),
       (1593, 4912, '@JvmName,JvmName,@kotlin.jvm.JvmName,kotlin.jvm.JvmName', '제네릭 타입 인자는 컴파일 과정에서 지워지므로(타입 소거) List<Int>와 List<String>이 모두 List가 되고, 두 확장 함수의 JVM 시그니처가 total(List)로 겹쳐 오류 로그의 platform declaration clash가 난다. @JvmName은 JVM 쪽 메서드 이름만 바꾸므로 시그니처 충돌이 풀리면서도 Kotlin 호출부는 list.total() 그대로 유지된다. 파일 맨 위에 붙여 최상위 선언을 담는 클래스 이름을 바꾸는 @file:JvmName과는 붙는 위치와 대상이 다르고, companion·object 멤버를 static으로 노출하는 @JvmStatic이나 기본 인자마다 오버로드를 만드는 @JvmOverloads와도 역할이 다르다.');

-- =====================================================
-- Lesson 946: Kotlin·자바 상호운용 심화: 배열·가변 인자, object 멤버 노출, 널 파라미터 검사, 와일드카드, suspend 래퍼
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5855, 946, '아래 네 호출 중 컴파일되지 않는 것은?', '자바 유틸리티 클래스를 Kotlin에서 호출하는 코드다.

```java
// Java
public class TextUtils {
    public static String join(String sep, String... parts) { ... }
    public static int sum(int[] values) { ... }
}
```

```kotlin
val parts = arrayOf("가", "나", "다")
val scores = intArrayOf(10, 20)

TextUtils.join("-", *parts)        // ㉠
TextUtils.join("-", parts)         // ㉡
TextUtils.sum(scores)              // ㉢
TextUtils.join("-", "가", "나")     // ㉣
```', 'OBJECTIVE'),
       (5856, 946, '아래 표를 바탕으로 옳은 것은?', '자바 팀에 함께 공개한 설정 객체다.

```kotlin
// Config.kt
object Config {
    const val VERSION = "1.4"
    var retryCount = 3
    val timeoutMs = 3_000L
    @JvmStatic fun reset() { retryCount = 3 }
}
```

자바 IDE가 보여 준 Config의 사용 형태를 정리한 표다.

| Kotlin 선언 | 자바 코드에서의 사용 형태 |
|---|---|
| `const val VERSION` | `Config.VERSION` (public static final String) |
| `var retryCount` | `Config.INSTANCE.getRetryCount()` / `Config.INSTANCE.setRetryCount(5)` |
| `val timeoutMs` | `Config.INSTANCE.getTimeoutMs()` |
| `@JvmStatic fun reset()` | `Config.reset()` |', 'OBJECTIVE'),
       (5857, 946, '아래 예외에 대한 설명으로 옳은 것은?', 'Kotlin으로 만든 모듈을 자바 서비스에서 호출하고 있다. 자바 빌드는 경고 없이 통과했고, 운영 중 일부 요청에서만 아래 예외가 찍혔다.

```kotlin
// Kotlin 모듈
class CouponService(private val repo: CouponRepository) {
    fun issue(userId: String, code: String) {
        repo.save(userId, code.uppercase())
    }
}
```

```java
// Java 서비스 — form.getCode()가 null을 돌려준 요청에서
service.issue(userId, form.getCode());
```

```
java.lang.NullPointerException: Parameter specified as non-null is null: method CouponService.issue, parameter code
	at com.example.CouponService.issue(CouponService.kt)
```', 'OBJECTIVE'),
       (5858, 946, '아래 ㉠·㉡ 시그니처에 대한 설명으로 옳은 것은?', '자바 팀에 공개한 Kotlin 모듈의 선언과, 자바 팀이 디컴파일해 확인한 시그니처다.

```kotlin
// Catalog.kt
interface Item

class Catalog {
    fun items(): List<Item> = TODO()        // ㉠
    fun render(items: List<Item>) { }       // ㉡
}
```

```java
java.util.List<Item> items();                        // ㉠
void render(java.util.List<? extends Item> items);   // ㉡
```', 'OBJECTIVE'),
       (5859, 946, '아래에서 buildAsync의 반환 타입으로 들어갈 자바 표준 타입의 이름은?', '리포트 모듈을 자바 서비스 팀에 공개하려 한다.

```kotlin
class ReportService(private val scope: CoroutineScope) {
    suspend fun build(id: Long): Report = TODO()
}
```

자바 팀이 `build`를 호출하려 했지만 IDE에 뜬 시그니처는 `Object build(long, Continuation<? super Report>)`였고, `Continuation`을 직접 구현할 방법이 없었다. 요청 처리 스레드를 점유하는 호출은 팀 규칙으로 금지돼 있어 결과를 기다렸다가 돌려주는 래퍼도 쓸 수 없었다.

그래서 아래 함수를 하나 더 두자 자바 쪽에서 `service.buildAsync(7).thenAccept(r -> render(r));`로 쓸 수 있었다.

```kotlin
// kotlinx-coroutines-jdk8의 future 빌더 사용
fun buildAsync(id: Long): ??? = scope.future { build(id) }
```', 'SUBJECTIVE'),
       (5860, 946, '아래에서 Kotlin 컴파일러가 람다에 적용한 변환의 이름은?', '자바 모듈에 `interface Task { void run(); }`와 `void submit(Task t)`가 있다. Kotlin에서 아래 한 줄을 썼다.

```kotlin
runner.submit { println("작업 시작") }
```

컴파일한 결과를 디컴파일하자 이렇게 바뀌어 있었다.

```java
runner.submit(new Task() {
    public void run() { System.out.println("작업 시작"); }
});
```

한편 같은 모양의 람다를 Kotlin에서 선언한 `interface Rule { fun check(n: Int): Boolean }` 파라미터 자리에 넘기면 컴파일되지 않는다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5855
(15787, 5855, '㉠ — 배열 앞에 붙인 *는 Kotlin에 없는 문법이라 구문 오류가 난다.', '스프레드 연산자를 낯설어한 오해. *는 배열을 가변 인자 자리에 펼쳐 넘기는 Kotlin 문법으로, 자바 varargs 메서드를 호출할 때 쓰라고 있는 것이다.', false),
(15788, 5855, '㉡ — 배열을 * 없이 그대로 넘겨 String 가변 인자 자리에 타입이 맞지 않는다.', '가변 인자는 값을 하나씩 나열받는 자리라 Array<String> 한 덩어리를 받지 못한다. ㉠처럼 *를 붙여 원소를 펼쳐야 String 인자 세 개로 전달된다.', true),
(15789, 5855, '㉢ — IntArray는 박싱된 Integer[]로 컴파일되므로 int[] 파라미터에 들어가지 못한다.', 'IntArray와 Array<Int>를 뒤바꿔 본 오해. 자바의 int[]에 대응하는 것이 IntArray이고, 박싱된 Integer[]에 대응하는 것이 Array<Int>다.', false),
(15790, 5855, '㉣ — 가변 인자 자리에는 배열만 넘길 수 있어 값을 나열하면 타입이 맞지 않는다.', '값을 나열하는 것이 가변 인자의 기본 사용법이고, 컴파일러가 그 값들을 배열로 묶어 준다. 이미 배열을 들고 있을 때만 ㉠처럼 *가 필요하다.', false),

-- 문제 5856
(15791, 5856, 'reset에서 @JvmStatic을 떼면 자바 호출부는 Config.INSTANCE.reset()으로 고쳐야 하지만, Kotlin 호출부의 Config.reset()은 그대로 둬도 된다.', '@JvmStatic은 자바 쪽에 진짜 static 메서드를 함께 만들어 주는 장치다. Kotlin에서는 object 멤버를 처음부터 Config.reset()으로 부르므로 어노테이션이 있든 없든 호출 형태가 같다.', true),
(15792, 5856, 'VERSION은 static 필드로 노출되므로 자바에서 Config.VERSION = "1.5";로 값을 바꿔 모듈을 다시 배포하지 않고 버전을 교체할 수 있다.', 'static 필드이니 쓰기도 된다고 본 오해. const val은 public static final로 컴파일돼 재대입이 막히고, 상수 값은 자바 사용처에 그대로 인라인되기까지 한다.', false),
(15793, 5856, 'retryCount를 자바에서 setRetryCount(5)로 바꿔도 Config.INSTANCE는 호출할 때마다 새로 만들어지므로 Kotlin이 읽는 Config.retryCount는 3 그대로다.', 'INSTANCE를 임시 래퍼로 본 오해. object는 싱글턴이라 INSTANCE는 클래스 로딩 때 만들어진 객체 하나뿐이고, 자바에서 바꾼 값을 Kotlin도 그대로 읽는다.', false),
(15794, 5856, 'VERSION이 static 필드로 나온 것은 object 안에 선언됐기 때문이므로, 같은 선언을 클래스의 companion object로 옮기면 INSTANCE를 거쳐야 한다.', 'object 멤버는 다 static이 된다고 본 오해. static 필드가 된 이유는 const val이라서이며, companion object에 두어도 const val은 바깥 클래스의 static final 필드로 노출된다. 같은 object의 retryCount가 getter를 거치는 것이 그 증거다.', false),

-- 문제 5857
(15795, 5857, '예외 메시지에 uppercase()가 아니라 파라미터 이름이 찍힌 것은, 널을 만난 uppercase()가 원인을 파라미터로 바꿔 예외를 다시 감싸 던지기 때문이다.', '예외가 본문에서 났다고 본 오해. 메시지의 형식은 컴파일러가 진입부에 넣은 검사가 직접 던진 것이고, 표준 라이브러리 함수는 이런 식으로 예외를 다시 포장하지 않는다.', false),
(15796, 5857, '자바 쪽에는 issue의 파라미터가 널 불가라는 정보가 남지 않으므로, 이런 실수는 실행해 보기 전에는 드러날 방법이 없다.', '널 정보가 경계에서 사라진다고 본 오해. Kotlin은 컴파일한 클래스의 파라미터·반환 타입에 @NotNull/@Nullable(JetBrains)을 기록하므로, 자바 IDE와 정적 분석 도구가 미리 경고할 수 있다.', false),
(15797, 5857, 'code를 String?으로 바꾸면 자바에서 널을 넘기는 호출이 컴파일 에러가 되어 같은 문제를 막을 수 있다.', '널 가능 타입이 호출을 막아 준다고 본 오해. String?은 오히려 널을 정식으로 허용하는 선언이라 진입부 검사가 사라지고, 대신 Kotlin 본문에서 안전 호출이나 널 처리를 해야 한다.', false),
(15798, 5857, 'Kotlin이 널 불가 파라미터마다 함수 진입부에 검사 코드를 넣어 두기 때문에, code.uppercase()와 repo.save가 실행되기 전에 예외가 난다.', '널 불가 선언은 Kotlin 안에서만 지켜지므로, 자바가 널을 넘기는 경우를 대비해 진입부 검사가 생성된다. 잘못된 값이 모듈 안으로 퍼지기 전에 경계에서 바로 드러난다.', true),

-- 문제 5858
(15799, 5858, '㉠에 와일드카드가 없는 것은 반환 타입의 제네릭 정보가 타입 소거로 지워졌기 때문이다.', '타입 소거로 사라지는 것은 실행 시점의 타입 인자이고, ㉠처럼 시그니처에는 List<Item>이 그대로 남는다. 반환 위치에 와일드카드를 붙이지 않는 것이 기본 동작일 뿐이다.', false),
(15800, 5858, '㉡의 와일드카드 때문에 자바 호출자는 List<Item> 변수를 그대로 넘기지 못하고 형변환을 거쳐야 한다.', '? extends를 제약으로만 본 오해. List<? extends Item>은 Item과 그 하위 타입의 리스트를 모두 받는 자리라, List<Item>은 물론 List<Book>도 형변환 없이 넘어간다.', false),
(15801, 5858, '㉡에만 ? extends가 붙은 것은 Kotlin의 List가 원소 타입을 out으로 선언한 읽기 전용 타입이고, 이 변환이 파라미터 위치에서 일어나기 때문이다.', '선언 지점 공변성은 자바에 없어서 사용 지점 와일드카드로 옮겨 적는다. 값을 받아 읽기만 하는 파라미터 자리에서 이 변환이 일어나고, 반환 위치에는 기본적으로 붙지 않는다.', true),
(15802, 5858, '㉡의 items를 MutableList<Item>으로 바꿔도 원소 타입이 같으므로 시그니처의 ? extends는 그대로 남는다.', '읽기 전용 List와 MutableList의 가변성 차이를 놓친 오해. MutableList는 원소 타입이 무공변이라 와일드카드 없이 java.util.List<Item>으로 방출된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1908, 5859, 'CompletableFuture,java.util.concurrent.CompletableFuture,CompletableFuture<Report>,컴플리터블퓨처,컴플리터블 퓨처', 'suspend 함수는 자바에서 마지막 파라미터로 Continuation이 붙고 반환 타입도 Object로 보이므로, 자바 호출자가 그대로 쓰는 것은 사실상 불가능하다. 그래서 코루틴을 대신 시작해 주고 결과만 자바 표준 비동기 타입으로 건네는 래퍼를 따로 둔다. kotlinx-coroutines-jdk8의 future 빌더가 돌려주는 것이 CompletableFuture이고, 자바 쪽은 thenAccept·thenApply로 이어 붙이면 된다. 결과를 기다렸다 돌려주는 runBlocking 래퍼도 자바에 노출하는 한 방법이지만 호출 스레드를 점유해 본문의 팀 규칙에 걸리고, Deferred는 코루틴 전용 타입이라 자바에서 다루기 어렵다는 점에서 구분된다.'),
       (1909, 5860, 'SAM 변환,SAM변환,SAM conversion,sam conversion,단일 추상 메서드 변환,SAM 컨버전', '추상 메서드가 하나뿐인 자바 인터페이스를 받는 자리에 람다를 넘기면, 컴파일러가 그 인터페이스를 구현한 객체로 바꿔 준다. 디컴파일 결과에 new Task() { ... }가 나타난 것이 그 흔적이다. 같은 일이 Kotlin 인터페이스에는 일어나지 않는데, Kotlin에는 함수 타입 (A) -> B가 이미 있어 인터페이스를 람다로 만들 이유가 없다는 설계 판단 때문이다. 그래서 Rule 자리에는 object 표현식을 쓰거나, 선언 앞에 fun을 붙여 fun interface로 바꿔야 한다. 변수에 담을 때 변환 대상 타입을 밝히는 Task { ... } 형태는 SAM 생성자라고 불러 구분한다.');
