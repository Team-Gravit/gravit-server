-- Unit: 불변 객체와 값 설계 (Unit ID: 195)
-- Chapter: Java (Chapter ID: 18)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (621, 195, '읽기 전용 뷰와 final 필드의 한계'),
       (779, 195, '얕은 복사와 불변 스냅샷, 컴팩트 생성자'),
       (937, 195, '불변 객체와 값 설계 — 새 객체 반환, 확장 차단, 복사의 범위');

-- =====================================================
-- Lesson 621: 읽기 전용 뷰와 final 필드의 한계
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3905, 621, '아래 코드가 출력하는 두 값을 순서대로 나열한 것은?', '```java
List<String> src = new ArrayList<>(List.of("a", "b"));
List<String> view = Collections.unmodifiableList(src);
List<String> copy = List.copyOf(src);

src.add("c");

System.out.println(view.size());
System.out.println(copy.size());
```', 'OBJECTIVE'),
       (3906, 621, '아래 코드에서 컴파일 오류가 나는 줄은?', '```java
public final class Config {
    private final Map<String, String> props = new HashMap<>();
    private final String[] hosts = {"a", "b"};

    public void apply(final int limit) {
        props.put("mode", "fast");                           // (가)
        limit = limit + 1;                                   // (나)
        hosts[0] = "z";                                      // (다)
        for (final String h : hosts) System.out.println(h);  // (라)
    }
}
```', 'OBJECTIVE'),
       (3907, 621, '아래에서 설명하는 자바 문법 요소에 대한 설명으로 옳은 것은?', '자바 16에서 정식 도입된 선언 방식이다. 괄호 안에 컴포넌트 목록만 적어 두면, 컴파일러가 정식 생성자와 컴포넌트 이름을 그대로 쓴 접근자, equals·hashCode·toString을 대신 만들어 준다.', 'OBJECTIVE'),
       (3908, 621, '아래 클래스에 남아 있는 취약점으로 옳은 것은?', '```java
public final class Period {
    private final Date start;
    private final Date end;

    public Period(Date start, Date end) {
        if (start.after(end)) throw new IllegalArgumentException("start > end");
        this.start = new Date(start.getTime());
        this.end = new Date(end.getTime());
    }

    public Date start() { return new Date(start.getTime()); }
    public Date end() { return new Date(end.getTime()); }
}
```', 'OBJECTIVE'),
       (3909, 621, '아래 증상을 없애려면 p의 클래스가 갖춰야 할 성질을 가리키는 용어는?', '좌표 값 두 개를 필드로 갖는 Point 인스턴스 p를 HashSet에 넣었다. 이후 p.setX(99)로 필드 하나를 바꾸고 set.contains(p)를 호출했더니 false가 돌아왔다. 그런데 set을 처음부터 끝까지 순회하면 p는 그대로 들어 있었고, 순회 중 꺼낸 원소와 p를 equals로 비교하면 true였다.', 'SUBJECTIVE'),
       (3910, 621, '아래 상황에서 처리 시간을 줄이는 데 사용한 표준 라이브러리 클래스의 이름은?', '로그 1,200,000줄을 한 문자열로 합치는 배치가 있다. 반복문 안에서 result = result + line 방식으로 이어 붙였을 때는 42초가 걸렸고, GC 로그에는 짧게 살다 사라지는 객체가 폭증했다. 반복문 밖에서 누적용 객체를 하나만 만들어 append로 쌓고 마지막에 toString을 한 번만 호출하도록 바꾸자, 같은 입력이 0.3초에 끝났다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3905
(10587, 3905, '2, 2', 'unmodifiableList가 원본과 분리된 복사본을 만든다고 본 오해. 실제로는 src를 그대로 감싼 읽기 전용 뷰라, 원본에 "c"가 더해지면 뷰의 크기도 함께 3이 된다.', false),
(10588, 3905, '2, 3', '두 메서드의 성질을 서로 바꿔 본 것. 원본과 함께 변하는 쪽은 뷰인 view이고, 만드는 시점의 원소를 복사해 크기가 고정되는 쪽은 copy다.', false),
(10589, 3905, '3, 2', 'unmodifiableList는 src를 감싼 뷰라 src.add 이후 크기가 3으로 따라 늘고, List.copyOf는 호출 시점 원소를 옮겨 담은 불변 리스트라 2에 머문다. 읽기 전용과 원본 분리는 다른 이야기다.', true),
(10590, 3905, '3, 3', 'List.copyOf도 원본을 들여다보는 뷰라고 본 오해. copyOf는 호출 시점에 원소를 새 저장 공간으로 옮기므로 이후 원본이 어떻게 바뀌든 영향을 받지 않는다.', false),

-- 문제 3906
(10591, 3906, '(가)', 'final 필드 props는 다른 Map으로 재대입하는 것만 막힌다. 이미 담긴 내용을 바꾸는 put은 정상 컴파일된다 — final은 참조를 고정할 뿐 내용의 불변을 뜻하지 않는다.', false),
(10592, 3906, '(나)', 'final이 붙은 매개변수는 한 번만 대입할 수 있으므로 limit에 다시 대입하는 순간 컴파일 오류가 난다. final이 실제로 금지하는 것은 재대입 하나뿐이고, 이 줄이 바로 그 하나에 걸린다.', true),
(10593, 3906, '(다)', '배열 원소에 대입하는 것은 hosts라는 참조를 바꾸는 것이 아니라 배열 내용을 바꾸는 것이라 허용된다. 배열은 불변으로 만들 수 없어, final 필드여도 원소는 얼마든지 바뀐다.', false),
(10594, 3906, '(라)', '향상된 for문의 변수는 반복마다 재대입되는 것이 아니라 반복마다 새로 선언되므로, final을 붙여도 정상 컴파일된다. 반복 안에서 h에 다시 대입할 때만 오류가 난다.', false),

-- 문제 3907
(10595, 3907, '다른 클래스를 상속해 공통 필드를 부모에서 물려받을 수 있다.', '암묵적으로 final이며 상속 계층에 낄 수 없다. 공통 필드를 부모에 모으는 설계는 쓸 수 없고, 공통 동작이 필요하면 인터페이스와 조합해야 한다.', false),
(10596, 3907, '선언 본문에 인스턴스 필드를 더 두어 컴포넌트 밖의 상태를 관리할 수 있다.', '인스턴스 필드는 괄호 안에 적은 컴포넌트뿐이며, 본문에 인스턴스 필드를 추가하면 컴파일 오류다. 상수처럼 쓰는 static 필드만 추가할 수 있다.', false),
(10597, 3907, '암묵적으로 final이라 인터페이스도 구현할 수 없다.', '상속이 막히는 것과 인터페이스 구현은 별개다. 오히려 sealed 인터페이스를 구현해 정해진 형태 중 하나를 표현하고 switch 패턴 매칭으로 빠짐없이 처리하는 것이 대표 용법이다.', false),
(10598, 3907, '컴포넌트로 받은 컬렉션이 가변이면 선언만으로는 원소 변경을 막지 못한다.', '컴파일러가 보장하는 것은 컴포넌트 참조를 다시 대입하지 못한다는 데까지다. 얕은 불변이라 컴팩트 생성자에서 List.copyOf로 복사해 넣어야 진짜 불변이 된다.', true),

-- 문제 3908
(10599, 3908, '인자를 먼저 검사한 뒤에 복사하므로, 검사 직후 다른 스레드가 원본을 바꾸면 뒤집힌 기간이 저장된다.', '검사한 값과 실제로 저장하는 값이 서로 다른 객체라 그 틈이 열린다. 인자를 먼저 복사하고 복사본을 검사하면 검사 대상과 저장 대상이 같아져 이 틈이 사라진다.', true),
(10600, 3908, '접근자가 내부 Date 참조를 그대로 돌려주어, 호출자가 반환값을 바꾸면 기간이 함께 바뀐다.', '두 접근자 모두 new Date로 복사본을 만들어 반환하므로 이 결함은 이미 막혀 있다. 나갈 때의 복사를 빠뜨린 코드와 혼동한 것이다.', false),
(10601, 3908, '클래스를 상속할 수 있어, 하위 클래스가 접근자를 재정의하면 내부 Date가 노출된다.', '선언이 final class라 상속 자체가 불가능하다. 확장 차단은 불변 클래스 규칙 가운데 이미 지켜진 항목이다.', false),
(10602, 3908, '복사에 clone을 쓰지 않아, 신뢰할 수 없는 하위 클래스 인스턴스를 걸러내지 못한다.', '오히려 반대다. Date는 final이 아니어서 하위 클래스가 clone을 악의적으로 재정의할 수 있으므로, 외부에서 받은 인자의 복사에는 clone이 아니라 생성자를 써야 안전하다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1258, 3909, '불변성,불변,불변 객체,불변객체,immutable,immutability,immutable object,이뮤터블', 'HashSet은 넣는 시점의 hashCode로 버킷을 정해 원소를 보관한다. 키의 필드가 바뀌면 hashCode도 함께 바뀌어 contains는 엉뚱한 버킷을 뒤지므로 못 찾고, 버킷과 무관하게 전부 훑는 순회에서는 원소가 그대로 보인다. 키가 불변이면 hashCode가 생성 이후 고정되어 이 어긋남이 생길 수 없다. equals·hashCode 규약 위반과는 구분해야 한다 — 규약을 정확히 지켜도 상태가 바뀌면 같은 증상이 난다. 또 필드에 final을 붙인 것만으로는 불변이 되지 않는다. 참조가 고정될 뿐 가리키는 객체가 가변이면 hashCode는 여전히 달라질 수 있다.'),
       (1259, 3910, 'StringBuilder,스트링빌더,스트링 빌더,String Builder,StringBuffer,스트링버퍼,스트링 버퍼', 'String이 불변이라 result = result + line은 반복마다 새 문자열과 새 배열을 만들어 지금까지 쌓인 내용을 통째로 복사한다. 줄 수가 늘수록 복사량이 제곱으로 불어나 42초가 나온 것이고, 곧바로 버려지는 중간 문자열이 GC 로그의 단명 객체 폭증으로 나타난다. 가변 버퍼에 append로 쌓으면 내부 배열을 늘려가며 재사용하므로 이 복사가 사라지고, 마지막 toString에서 한 번만 불변 문자열을 만든다. 불변 타입의 생성 비용이 실제 병목으로 확인된 지점에만 가변 동반 클래스를 쓰는 것이 원칙이다. 여러 스레드가 하나의 버퍼를 공유하는 드문 경우에는 StringBuffer를 쓰지만, 단일 스레드에서는 동기화 비용이 없는 StringBuilder가 표준 선택이다.');

-- =====================================================
-- Lesson 779: 얕은 복사와 불변 스냅샷, 컴팩트 생성자
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4853, 779, '아래 코드를 실행했을 때 출력되는 값은?', '```java
public final class Grid {
    private final int[][] cells;

    public Grid(int[][] cells) {
        this.cells = cells.clone();
    }

    public int at(int r, int c) { return cells[r][c]; }
}
```

```java
int[][] src = { {1, 2}, {3, 4} };
Grid g = new Grid(src);

src[0][1] = 99;
src[1] = new int[] {8, 8};

System.out.println(g.at(0, 1) + g.at(1, 0));
```', 'OBJECTIVE'),
       (4854, 779, '아래 설정 교체 방식에 대한 설명으로 옳은 것은?', '```java
public record RouteConfig(String host, int port, int timeoutMs) { }

public final class ConfigHolder {
    private volatile RouteConfig current =
            new RouteConfig("a.example.com", 443, 3000);

    public RouteConfig get() { return current; }        // 락 없음

    public void reload(String host, int port, int timeoutMs) {
        current = new RouteConfig(host, port, timeoutMs);
    }
}
```

수백 개의 요청 스레드가 get을 호출하는 동안, 관리자 스레드가 reload를 호출해 설정을 바꾼다.', 'OBJECTIVE'),
       (4855, 779, '아래 코드에 대한 설명으로 옳은 것은?', 'Java 21에서 컴파일한다.

```java
public sealed interface PaymentResult permits Approved, Declined { }

public record Approved(String txId, long amount) implements PaymentResult { }
public record Declined(String reason) implements PaymentResult { }

static String describe(PaymentResult r) {
    return switch (r) {
        case Approved a -> "승인 " + a.txId();
        case Declined d -> "거절: " + d.reason();
    };
}
```', 'OBJECTIVE'),
       (4856, 779, '아래 표를 바탕으로 한 필드 설계 판단으로 옳지 않은 것은?', '| 타입 | 인스턴스의 값 변경 | 변경 요청 시 동작 |
|---|---|---|
| String | 불가 | 새 인스턴스를 반환 |
| LocalDateTime | 불가 | plusDays 등이 새 인스턴스를 반환 |
| java.util.Date | 가능 | setTime이 그 인스턴스를 바꿈 |
| int[] | 가능 | 원소 대입이 그 배열을 바꿈 |', 'OBJECTIVE'),
       (4857, 779, '아래 상황에서 생성자와 접근자 양쪽에 빠져 있던 조치를 가리키는 용어는?', '주문 도메인의 Order 클래스는 setter가 하나도 없고 필드가 모두 final인데도 QA가 두 가지 버그를 올렸다.

- new Order(items)로 주문을 만든 뒤 호출 측이 자기 items 리스트에 품목을 하나 더 넣자, 이미 만들어진 주문의 품목 수도 같이 늘었다.
- order.items()로 받은 리스트에 clear를 호출하자 주문의 품목이 전부 사라졌다.', 'SUBJECTIVE'),
       (4858, 779, '아래 record 선언에서 (가)로 표시한 블록을 가리키는 이름은?', '```java
public record Money(long amount, String currency) {

    public Money {                                              // (가)
        if (amount < 0) throw new IllegalArgumentException("금액은 음수일 수 없음");
        currency = currency.toUpperCase();
    }

    public Money plus(Money other) {
        return new Money(amount + other.amount, currency);
    }
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4853
(13115, 4853, '5', 'clone이 안쪽 배열까지 새로 만드는 깊은 복사라고 본 오해다. 그렇게 보면 생성 시점 값이 그대로 남아 2와 3이 되어 5가 나오지만, 배열의 clone은 바깥 한 겹만 새로 만든다.', false),
(13116, 4853, '10', '실제와 정반대로 안쪽 배열이 새로 복사되고 바깥 배열은 원본과 공유된다고 본 오해다. 그렇게 보면 src[0][1] = 99는 내부에 비치지 않아 2가 남고, src[1] 교체는 그대로 전달되어 8이 되어 2 + 8이 된다. clone이 새로 만드는 것은 바깥 한 겹뿐이다.', false),
(13117, 4853, '102', 'clone은 얕은 복사라 바깥 배열만 새로 만들고 안쪽 배열은 원본과 공유한다. 그래서 src[0][1] = 99는 그대로 비치고, 바깥 배열은 분리되어 있어 src[1] 교체는 전달되지 않아 3이 남는다. 99 + 3이다.', true),
(13118, 4853, '107', 'clone이 아무것도 분리하지 못한다고 본 오해다. 99 + 8은 복사를 아예 생략하고 인자를 그대로 저장했을 때의 값이고, 실제로는 바깥 배열 한 겹이 분리되어 src[1] 교체가 막힌다.', false),

-- 문제 4854
(13119, 4854, 'reload가 세 값을 차례로 덮어쓰는 동안, 읽는 스레드는 host만 새 값이고 port는 옛 값인 조합을 볼 수 있다.', '필드를 제자리에서 고치는 가변 설정 객체를 떠올린 오해다. 여기서는 새 인스턴스를 다 만든 뒤 참조 하나만 바꾸므로, 절반만 갱신된 상태 자체가 만들어지지 않는다.', false),
(13120, 4854, 'get이 돌려준 값은 세 항목이 같은 시점에서 나온 한 벌이라, 읽는 쪽은 락 없이도 어긋나지 않은 조합을 쓴다.', '갱신이 참조 대입 한 번으로 끝나고 대상이 바뀌지 않는 객체라, 읽는 쪽은 교체 전이나 후의 온전한 한 벌만 본다. volatile이 그 참조 변경의 가시성을 맡는다.', true),
(13121, 4854, 'get을 synchronized로 감싸야 다른 스레드가 바꾼 참조를 읽는 쪽이 볼 수 있다.', '참조가 volatile이라 최신 값 가시성은 이미 보장된다. 락은 읽기와 쓰기 여러 번을 하나의 단위로 묶어야 할 때 필요한 것이지, 바뀌지 않는 객체의 참조를 한 번 읽는 데는 필요 없다.', false),
(13122, 4854, 'reload 직전에 get으로 받아 둔 참조를 계속 쓰는 스레드도 교체 이후에는 새 설정 값을 보게 된다.', '이미 받은 참조는 그 시점의 인스턴스를 계속 가리키고 그 인스턴스는 끝까지 그대로다. 갱신을 반영하려면 get을 다시 호출해야 하며, 이것이 스냅샷을 넘기는 방식의 성질이다.', false),

-- 문제 4855
(13123, 4855, 'describe에 default 분기를 추가하면 구현 타입이 늘었을 때 처리 누락을 컴파일러가 더 확실히 잡아 준다.', '거꾸로다. default를 두면 처리하지 않은 타입이 모두 그쪽으로 흘러가 완전성 검사가 무력해진다. 누락을 컴파일 단계에서 잡고 싶다면 default를 두지 않아야 한다.', false),
(13124, 4855, 'Approved와 Declined는 한 봉인 인터페이스에 속하므로 txId와 reason이 같은 문자열이면 equals가 true다.', 'record가 만들어 주는 equals는 타입이 같고 모든 컴포넌트가 같을 때만 true다. 같은 인터페이스를 구현한다는 사실은 동치성과 아무 관계가 없다.', false),
(13125, 4855, 'Approved 인스턴스의 amount를 setAmount로 바꾸면 승인 금액만 고쳐 같은 인스턴스를 재사용할 수 있다.', 'record는 setter를 만들어 주지 않고 컴포넌트는 private final이다. 값을 바꾸려면 바뀐 값으로 새 인스턴스를 만들어야 하며, 이것이 값 캐리어로 쓰는 전제다.', false),
(13126, 4855, 'permits 목록에 구현 타입을 하나 더 추가하면, default 분기가 없는 describe의 switch가 컴파일 오류가 된다.', '봉인 인터페이스는 구현 목록이 고정이라 컴파일러가 switch가 모든 경우를 덮는지 검사한다. 형태가 늘면 처리 누락이 컴파일 단계에서 드러나는 것이 두 문법을 함께 쓰는 이유다.', true),

-- 문제 4856
(13127, 4856, 'Date 필드는 final로 선언해 두면 생성자에서 받은 인스턴스를 그대로 저장해도 값이 바뀌지 않는다.', 'final은 그 필드에 다른 객체를 다시 대입하지 못하게 할 뿐이다. 표대로 Date는 값이 바뀌므로, 인자를 넘긴 쪽이 같은 인스턴스에 setTime을 부르면 내부 값도 함께 바뀐다.', true),
(13128, 4856, 'int[] 필드는 생성자에서 clone으로 복사해 담아야 호출자가 원본 원소를 바꿔도 내부 값이 유지된다.', '배열은 원소 대입으로 값이 바뀌고 배열 자체를 바꿀 수 없게 만들 방법도 없다. 그래서 들어올 때와 나갈 때 모두 복사해 원본과 분리해 두어야 한다.', false),
(13129, 4856, 'LocalDateTime 필드는 접근자에서 그대로 반환해도 호출자가 내부 상태를 바꿀 수 없다.', '값 변경 수단이 없고 변경 요청은 새 인스턴스로 돌아오므로, 참조를 내주어도 필드가 가리키던 값은 그대로다. 복사 없이 노출해도 되는 경우다.', false),
(13130, 4856, 'String을 HashMap 키로 쓰면 담은 뒤에 키의 hashCode가 달라져 값을 잃어버릴 일이 없다.', '해시 값은 키의 상태에서 나오는데 String은 상태가 바뀌지 않으므로, 담을 때 정해진 버킷이 계속 유효하다. 값이 바뀌는 객체를 키로 쓸 때와 갈리는 지점이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1574, 4857, '방어적 복사,방어적복사,방어 복사,방어복사,defensive copy,defensive copying,디펜시브 카피', 'setter가 없고 필드가 모두 final이어도, 외부에서 받은 가변 컬렉션의 참조를 그대로 저장하면 그 참조를 들고 있는 쪽이 내부를 계속 바꿀 수 있다. 접근자가 내부 참조를 그대로 내주면 반대 방향으로도 같은 구멍이 열린다. 그래서 들어올 때와 나갈 때 모두 복사본을 쓴다. List.copyOf는 원본과 분리된, 바뀌지 않는 리스트를 만들어 두 구멍을 한 번에 막는다. 반면 Collections.unmodifiableList는 원본을 감싼 읽기 전용 뷰라 원본이 바뀌면 함께 바뀌므로 첫 번째 버그를 막지 못한다. 복사는 인자 검사보다 먼저 해야 한다. 검사한 뒤 복사하면 그 틈에 다른 스레드가 원본을 바꿔 검사를 통과한 값과 저장된 값이 달라질 수 있다. 또 복사는 얕게 이뤄지므로, 원소 자체가 바뀔 수 있는 타입이면 원소까지 바뀌지 않는 타입이어야 한다. final은 재대입만 막는 표시라 이 구멍과는 무관하다.'),
       (1575, 4858, '컴팩트 생성자,컴팩트생성자,컴팩트 컨스트럭터,compact constructor,compactconstructor,간결 생성자,축약 생성자', 'record는 컴포넌트 목록을 그대로 받는 정식(canonical) 생성자를 컴파일러가 만들어 준다. 매개변수 목록 없이 본문만 적은 이 블록은 그 정식 생성자의 앞부분에 끼워 넣는 코드가 되고, 필드 대입은 블록이 끝난 뒤 컴파일러가 이어서 수행한다. 그래서 여기서는 필드가 아니라 매개변수 이름에 대입해 검증과 정규화를 한다. currency = currency.toUpperCase()는 필드를 고치는 것이 아니라 앞으로 대입될 값을 바꾸는 것이고, this.currency = ... 로 쓰면 컴파일 오류다. 가변 컬렉션을 컴포넌트로 받을 때 List.copyOf로 바꿔 담는 자리도 바로 여기다. 괄호 안에 매개변수를 모두 적고 this로 직접 대입하는 정식 생성자와 구분해야 하고, 본문에 인스턴스 필드를 새로 추가하는 것은 record에서 아예 허용되지 않는다.');

-- =====================================================
-- Lesson 937: 불변 객체와 값 설계 — 새 객체 반환, 확장 차단, 복사의 범위
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5801, 937, '아래 코드의 출력 결과로 옳은 것은?', '```java
public final class Money {
    private final long amount;

    public Money(long amount) { this.amount = amount; }

    public Money plus(Money other) { return new Money(amount + other.amount); }

    public long amount() { return amount; }
}
```

```java
Money wallet = new Money(500);
Money fee = new Money(120);

wallet.plus(fee);
Money total = wallet.plus(fee);

System.out.println(wallet.amount() + ", " + total.amount());
```', 'OBJECTIVE'),
       (5802, 937, '아래 클래스가 불변을 보장하지 못하는 이유로 옳은 것은?', '```java
public class Temperature {
    private final double celsius;

    public Temperature(double celsius) { this.celsius = celsius; }

    public double celsius() { return celsius; }

    public Temperature plus(double delta) { return new Temperature(celsius + delta); }
}
```', 'OBJECTIVE'),
       (5803, 937, '아래 제안에 대한 판단으로 옳은 것은?', '도메인 클래스를 정리하면서 아래 두 타입을 모두 record로 바꾸자는 제안이 나왔다.

- **Member** — 가입 뒤에도 등급과 연락처가 여러 번 바뀐다. 데이터베이스 기본 키 memberId가 같으면 나머지 값이 달라도 같은 회원으로 본다. 알림 발송 모듈은 조회 시점에 만든 Member 인스턴스를 Set에 담아 두고, 나중에 다시 조회한 Member가 그 Set에 있는지로 이미 보낸 회원인지 확인한다.
- **Point** — x, y 두 값만 갖는다. 만든 뒤 값을 바꿀 일이 없고, 두 값이 같으면 같은 좌표로 본다.', 'OBJECTIVE'),
       (5804, 937, '아래 표를 바탕으로 불변 클래스의 컬렉션 필드를 다룬 판단으로 옳지 않은 것은?', '생성자에서 받은 List<Item> src를 필드에 담는 세 가지 방법이다.

| 방법 | 원본 src와의 관계 | 결과 리스트에 add를 호출하면 |
|---|---|---|
| new ArrayList<>(src) | 호출 시점의 원소를 옮겨 담아 분리됨 | 정상 추가됨 |
| Collections.unmodifiableList(src) | src를 그대로 감싼 읽기 전용 뷰 | UnsupportedOperationException |
| List.copyOf(src) | 호출 시점의 원소를 옮겨 담아 분리됨 | UnsupportedOperationException |', 'OBJECTIVE'),
       (5805, 937, '아래에서 세 번째 증상이 함께 나타난 까닭이 되는, Order가 한 복사의 성격을 가리키는 용어는?', '주문 도메인의 Order는 생성자에서 List.copyOf로 품목 목록을 담고, 접근자는 그 목록을 그대로 돌려준다. 그런데 운영에서 아래 세 가지가 함께 관찰됐다.

- 호출 측이 넘겼던 원본 목록에 품목을 더 넣어도 주문의 품목 수는 3개 그대로였다.
- 접근자로 받은 목록에 add를 부르면 UnsupportedOperationException이 났다.
- 호출 측이 넘겼던 원본 목록의 첫 번째 Item 인스턴스에서 quantity를 3에서 30으로 바꾸자, 주문 상세 화면의 첫 품목 수량도 30으로 나왔다.', 'SUBJECTIVE'),
       (5806, 937, '아래 코드에서 (가)로 표시한 메서드를 가리키는 용어는?', '```java
public final class Email {
    private final String value;

    private Email(String value) { this.value = value; }

    public static Email of(String raw) {                        // (가)
        String normalized = raw.trim().toLowerCase();
        if (!normalized.contains("@")) {
            throw new IllegalArgumentException("이메일 형식이 아님: " + raw);
        }
        return new Email(normalized);
    }

    public String value() { return value; }
}
```

이 구조로 바꾼 뒤, 검증을 건너뛴 채 Email을 만들던 호출 경로가 사라졌고, Email을 상속해 value()를 갈아끼우려던 테스트 코드는 컴파일되지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5801
(15643, 5801, '740, 740', 'plus가 자신의 amount를 고친 뒤 자기 자신을 돌려준다고 본 오해다. 그렇게 보면 두 번의 호출이 모두 wallet에 쌓여 740이 되지만, amount는 private final이라 대입 자체가 불가능하다.', false),
(15644, 5801, '500, 620', 'plus는 wallet을 그대로 둔 채 더한 값을 담은 새 인스턴스를 돌려준다. 그래서 반환값을 변수로 받지 않은 첫 호출은 만들어진 객체가 그대로 버려져 흔적을 남기지 않고, wallet은 500, 결과를 받은 total만 620이 된다.', true),
(15645, 5801, '620, 740', '첫 호출의 결과는 wallet에 누적되고 두 번째 호출만 새 인스턴스를 만든다고 본 절충 오해다. 불변 객체에서는 호출 횟수와 상관없이 수신자 쪽 값이 변하지 않으므로 wallet은 끝까지 500이다.', false),
(15646, 5801, '500, 740', '버려진 첫 호출의 결과가 어딘가에 남아 두 번째 계산에 더해진다고 본 오해다. 변수로 받지 않은 새 인스턴스는 곧바로 버려지므로 두 번째 호출도 500 + 120만 계산한다.', false),

-- 문제 5802
(15647, 5802, '접근자 celsius()가 내부 필드를 그대로 내주어, 호출자가 받은 값을 바꾸면 필드도 함께 바뀐다.', 'double은 기본형이라 반환할 때 값이 복사되어 전달되고, 받은 쪽에서 무엇을 하든 필드에 닿지 않는다. 방어적 복사가 필요한 것은 배열·컬렉션·Date처럼 참조를 내주는 가변 객체 쪽이다.', false),
(15648, 5802, '생성자가 인자를 검사하지 않아 절대 영도보다 낮은 값도 그대로 저장된다.', '값 검증이 빠진 것은 사실이지만 그것은 잘못된 값이 들어오는 문제이고, 만들어진 뒤 상태가 달라지는지와는 다른 이야기다. 검증을 추가해도 이 클래스에서 값이 달라 보이게 되는 경로는 그대로 남는다.', false),
(15649, 5802, 'celsius 필드에 volatile이 없어, 생성이 끝나기 전 참조를 받은 다른 스레드가 초기화 전 값을 볼 수 있다.', 'final 필드는 생성자가 끝난 뒤 전달된 참조로 읽으면 초기화된 값이 반드시 보이도록 보장된다(안전한 발행). 불변 객체를 동기화 없이 공유할 수 있는 근거가 이 규칙이라 volatile을 덧붙일 필요가 없다.', false),
(15650, 5802, '클래스와 생성자가 모두 열려 있어, 하위 클래스가 celsius()를 재정의하면 부를 때마다 다른 값을 돌려줄 수 있다.', '필드를 private final로 두어도 타입을 물려받은 쪽이 접근자를 갈아끼우면 쓰는 쪽에서 보이는 값이 달라진다. 그래서 불변 클래스는 final class로 선언하거나 생성자를 외부에서 부르지 못하게 닫아 확장 자체를 차단한다.', true),

-- 문제 5803
(15651, 5803, 'Member를 바꾸면 등급이 달라진 뒤 다시 조회한 인스턴스가 Set에 담아 둔 것과 다른 값으로 취급돼, 이미 보낸 회원에게 알림이 또 나간다.', 'record가 만들어 주는 equals는 모든 컴포넌트가 같아야 true이므로, memberId가 같아도 등급이 달라지면 다른 값이 되어 Set이 찾지 못한다. 식별자로 같음을 판단하고 상태가 변하는 타입에는 값 의미론이 맞지 않는다.', true),
(15652, 5803, 'Point는 컴포넌트가 두 개뿐이라 equals와 hashCode를 직접 재정의해야 해서, 바꿔도 손으로 쓸 코드가 줄지 않는다.', '컴포넌트 개수와 무관하게 컴파일러가 모든 컴포넌트를 비교하는 equals와 그에 맞는 hashCode, toString, 접근자까지 만들어 준다. 두 값이 같으면 같은 좌표로 보는 규칙이 선언만으로 지켜지는 쪽이다.', false),
(15653, 5803, 'Member는 컴팩트 생성자에 등급을 바꾸는 메서드를 두면, 상태 변경까지 바뀐 타입 안에서 처리할 수 있다.', '컴팩트 생성자는 인스턴스를 만들 때 값을 검증하거나 다듬는 자리이지 메서드를 담는 곳이 아니다. 컴포넌트는 private final이라 만들어진 뒤에는 어떤 메서드로도 값을 바꿀 수 없다.', false),
(15654, 5803, 'Point는 값이 바뀌지 않으므로 필드를 public으로 연 일반 클래스로 두어도 두 값이 같으면 같은 좌표로 비교된다.', 'equals를 재정의하지 않은 클래스는 Object의 기본 구현을 써서 같은 인스턴스인지로만 비교한다. x와 y가 같아도 다른 인스턴스면 false가 되어 같은 좌표로 보는 규칙이 깨진다.', false),

-- 문제 5804
(15655, 5804, 'new ArrayList<>(src)로 담으면 들어올 때의 구멍은 막히지만, 접근자가 그 리스트를 그대로 내주면 호출자가 원소를 지울 수 있다.', '표 첫 줄대로 원본과는 분리되지만 결과 리스트 자체는 수정이 열려 있다. 그래서 나갈 때 한 번 더 복사하거나 읽기 전용으로 감싸야 양쪽 구멍이 모두 닫힌다.', false),
(15656, 5804, 'List.copyOf로 담으면 접근자에서 다시 복사하지 않고 그대로 반환해도 호출자가 원소를 넣거나 뺄 수 없다.', '표 셋째 줄에서 결과 리스트는 추가 시도 자체가 예외로 막히고, 원본과도 분리돼 있다. 들어올 때와 나갈 때의 구멍을 한 번에 닫는 선택이라 접근자에서 추가 조치가 필요 없다.', false),
(15657, 5804, '생성자에서 unmodifiableList로 감싸 저장해 두면, 인자를 넘긴 쪽이 자기 리스트에 원소를 추가해도 내부 목록의 크기는 그대로다.', '표 둘째 줄에서 이 방법은 src를 감싼 뷰라 원본과 분리되지 않는다. 넘긴 쪽이 src에 원소를 더하면 내부 목록의 크기도 함께 늘어난다. 수정이 막히는 것과 원본에서 분리되는 것은 다른 이야기다.', true),
(15658, 5804, '내부에는 new ArrayList<>(src)로 담고 접근자에서만 unmodifiableList로 감싸 내주면, 호출자 쪽 수정은 막힌다.', '감싼 결과는 표 둘째 줄대로 add가 예외로 막히고, 감싸는 대상이 이미 원본과 분리된 내부 리스트라 뷰가 원본을 따라 변하는 문제도 생기지 않는다. 뷰가 위험해지는 것은 외부 리스트를 감쌀 때다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1890, 5805, '얕은 복사,얕은복사,얕은 복제,shallow copy,shallowcopy,shallow-copy,shallow copying', 'List.copyOf는 목록이라는 껍데기만 새로 만들고 그 안의 원소 참조는 원본에서 그대로 옮겨 담는다. 그래서 원본에 품목을 더하거나 빼는 일은 주문에 닿지 않고(원본과 분리), 접근자로 받은 목록에 add를 부르면 예외가 나지만(수정 불가), 두 목록이 같은 Item 인스턴스를 가리키고 있으므로 그 Item의 quantity가 바뀌면 주문 쪽에서도 바뀐 값이 보인다. 세 번째 증상만 남은 까닭이 여기에 있다. 원소까지 새로 만들어 원본과 완전히 갈라놓는 깊은 복사와 구분해야 한다. 복사를 한다는 결정(방어적 복사)과 그 복사가 어디까지 미치는가는 층위가 다른 이야기이며, 방어적 복사를 제대로 해도 원소가 가변이면 이 구멍은 남는다. 진짜 불변이 되려면 원소 타입도 값이 바뀌지 않는 타입이어야 하고, Item이 가변이라면 생성자에서 원소를 하나씩 불변 형태로 바꿔 담아야 한다. 배열의 clone, new ArrayList<>(src), Collections.unmodifiableList도 모두 같은 범위까지만 복사한다는 점에서 사정이 같다.'),
       (1891, 5806, '정적 팩토리 메서드,정적팩토리 메서드,정적팩토리메서드,정적 팩터리 메서드,정적팩터리메서드,정적 팩토리,정적 팩터리,static factory method,staticfactorymethod,static factory,스태틱 팩토리 메서드', '생성자를 private으로 닫고 인스턴스를 돌려주는 static 메서드만 열어 둔 형태다. 생성자와 달리 이름을 붙일 수 있어 of·from·valueOf처럼 무엇을 만드는지가 호출부에서 드러나고, 만들기 전에 값을 다듬거나 검증하는 단계를 끼워 넣을 수 있어 검증을 건너뛴 인스턴스가 아예 생기지 않는다. 호출할 때마다 새 인스턴스를 만들어야 한다는 제약도 없어서, 자주 쓰는 값은 미리 만들어 둔 인스턴스를 돌려주는 캐싱이 가능하다(Integer.valueOf가 작은 정수를 재사용하는 방식). 불변 클래스 관점에서 더 중요한 것은 확장 차단이다. 생성자가 private이면 하위 클래스가 상위 생성자를 부를 수 없어 상속이 사실상 막히고, 접근자를 갈아끼워 값이 달라 보이게 만드는 일도 함께 차단된다. 이 코드에서 상속을 시도한 테스트 코드가 컴파일되지 않은 이유가 그것이다. 별도의 클래스가 다른 타입의 인스턴스를 만들어 주는 팩토리 메서드 패턴이나, 값을 단계별로 쌓아 올리는 빌더와는 다르다. 여기서는 클래스 자신이 자기 인스턴스를 내주는 static 메서드다. record가 자동으로 만들어 주는 정식 생성자·컴팩트 생성자와도 구분한다.');
