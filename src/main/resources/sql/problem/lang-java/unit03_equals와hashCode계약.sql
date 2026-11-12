-- Unit: equals와 hashCode 계약 (Unit ID: 188)
-- Chapter: Java (Chapter ID: 18)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (614, 188, '참조 비교와 대칭성·추이성, record'),
       (772, 188, 'equals 오버로딩과 가변 키, 컴포지션'),
       (930, 188, 'equals·hashCode 구현에서 놓치기 쉬운 함정');

-- =====================================================
-- Lesson 614: 참조 비교와 대칭성·추이성, record
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3863, 614, '아래 코드의 출력 결과를 위에서부터 순서대로 나열한 것은?', '```java
Integer a = 127, b = 127;
Integer c = 128, d = 128;

System.out.println(a == b);
System.out.println(c == d);
System.out.println(c.equals(d));
```', 'OBJECTIVE'),
       (3864, 614, '아래 클래스가 어기는 equals 규약과 그로 인해 나타나는 결과로 옳은 것은?', '```java
public final class CaseInsensitiveString {
    private final String s;

    public CaseInsensitiveString(String s) { this.s = s; }

    @Override
    public boolean equals(Object o) {
        if (o instanceof CaseInsensitiveString cis) return s.equalsIgnoreCase(cis.s);
        if (o instanceof String str) return s.equalsIgnoreCase(str);
        return false;
    }
}
```', 'OBJECTIVE'),
       (3865, 614, '아래 절차를 쓰는 자료구조에서 마지막 get 호출이 어떻게 동작하는가?', '```
조회 절차
  get(key)
    ① key.hashCode()로 버킷 번호를 계산해 어느 칸을 볼지 정한다
    ② 그 칸에 담긴 항목을 훑으며 key.equals(항목의 키)가 true인 것을 찾는다
```

키로 넣은 클래스 Key는 필드 x, y를 써서 hashCode()만 재정의했고 equals()는 재정의하지 않았다.

```java
map.put(new Key(1, 2), "A");
map.get(new Key(1, 2));
```', 'OBJECTIVE'),
       (3866, 614, '아래 표의 네 클래스가 보이는 동작으로 옳지 않은 것은?', '| 클래스 | equals 선언 | 비교에 쓰는 필드 | hashCode |
|---|---|---|---|
| A | public boolean equals(Object o) | x, y | 재정의하지 않음 |
| B | public boolean equals(Object o) | x, y | Objects.hash(x, y) |
| C | public boolean equals(Coord o) | x, y | Objects.hash(x, y) |
| D | public boolean equals(Object o) | name (setter로 바꿀 수 있음) | name.hashCode() |', 'OBJECTIVE'),
       (3867, 614, '아래 실행 결과가 어기고 있는 equals 규약의 이름은?', '```java
// ColorPoint는 상대가 Point면 좌표만, ColorPoint면 좌표와 색까지 비교한다.
Point p = new Point(1, 2);
ColorPoint c1 = new ColorPoint(1, 2, RED);
ColorPoint c2 = new ColorPoint(1, 2, BLUE);

System.out.println(c1.equals(p));    // true
System.out.println(p.equals(c2));    // true
System.out.println(c1.equals(c2));   // false
```', 'SUBJECTIVE'),
       (3868, 614, '아래 상황에서 B가 쓴 클래스 선언 방식의 이름은?', '두 사람이 같은 좌표 값 객체를 만들었다. A는 필드 선언·생성자·접근자에 equals·hashCode·toString까지 60여 줄을 손으로 채웠다. B는 Java 16부터 정식 지원된 문법을 써서 괄호 안에 int x, int y만 적은 한 줄로 끝냈다.

B의 소스에는 equals와 hashCode 코드가 한 줄도 없다. 그런데도 값이 같은 인스턴스 두 개를 HashSet에 넣으면 크기가 1이었고, 괄호 안에 필드를 하나 더 늘리자 동치 판정 기준도 그 필드까지 포함하도록 함께 바뀌었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3863
(10475, 3863, 'true, true, true', '오토박싱된 래퍼는 값만 같으면 ==도 true라고 본 오개념. Integer 캐시는 -128~127 범위만 같은 객체를 재사용하므로 128은 박싱할 때마다 새 객체가 만들어진다.', false),
(10476, 3863, 'false, false, true', '==를 언제나 서로 다른 객체를 가리키는 비교로만 본 경우. 127은 캐시된 같은 객체를 함께 가리키므로 a == b가 true다.', false),
(10477, 3863, 'true, false, true', '127은 Integer 캐시 범위라 a와 b가 같은 객체를 가리켜 ==가 true, 128은 별개 객체라 false다. 셋째 줄의 equals는 참조가 아니라 안에 든 int 값을 비교하므로 true다.', true),
(10478, 3863, 'true, false, false', '래퍼 타입의 equals가 Object의 참조 비교 그대로라고 본 오개념. Integer는 equals를 재정의해 값이 같으면 true를 돌려준다.', false),

-- 문제 3864
(10479, 3864, '반사성이 깨져 자기 자신과 비교해도 false가 나오고, 컬렉션에 넣은 객체를 contains로 찾지 못한다.', 'instanceof 검사를 통과한 뒤 같은 문자열끼리 equalsIgnoreCase를 하므로 자기 자신과의 비교는 true다. 반사성은 지켜진다.', false),
(10480, 3864, '대칭성이 깨져 비교 순서를 뒤집으면 결과가 달라지고, 어느 쪽을 인자로 넘기느냐에 따라 contains 결과가 갈린다.', 'String을 받아 주는 둘째 분기 때문에 이 클래스는 문자열과 같다고 답하지만, String.equals는 상대를 String으로만 보므로 false다. 한쪽만 true라 비교 방향에 따라 컬렉션 탐색 결과가 달라진다.', true),
(10481, 3864, '일관성이 깨져 상태를 바꾸지 않아도 같은 두 객체를 다시 비교할 때마다 결과가 달라진다.', '필드 s가 final이고 비교에 외부 상태나 시간·네트워크를 쓰지 않으므로 몇 번을 호출해도 결과가 같다. 일관성 위반은 가변·외부 의존 정보를 비교에 쓸 때 생긴다.', false),
(10482, 3864, 'null 처리 규약이 깨져 인자로 null을 넘기면 NullPointerException이 발생한다.', 'instanceof는 왼쪽 값이 null이면 예외 없이 false를 내므로 두 분기를 지나 false가 반환된다. 이 규약은 null 검사 없이 상대 필드를 바로 건드릴 때 깨진다.', false),

-- 문제 3865
(10483, 3865, '①에서 두 키가 서로 다른 칸으로 흩어져 ②의 비교가 실행되지도 않고 null이 반환된다.', 'equals만 재정의하고 hashCode를 빠뜨린 반대 상황의 증상이다. 여기서는 x, y로 해시 값을 만들었으므로 값이 같은 두 키는 같은 칸으로 간다.', false),
(10484, 3865, '②의 비교가 값 기준으로 자동 대체돼 저장해 둔 "A"가 반환된다.', '재정의하지 않은 equals가 런타임에 값 비교로 바뀌는 일은 없다. Object가 물려주는 equals는 == 그대로여서 참조가 다르면 false다.', false),
(10485, 3865, '해시 값은 같은데 equals가 false이므로 규약 위반으로 판정돼 put 시점에 예외가 발생한다.', '해시 값이 같아도 equals가 다른 상황은 충돌로 허용되며, 런타임은 규약 위반을 검사하지 않는다. 예외 없이 조용히 틀린 결과가 나오는 것이 이 버그의 특징이다.', false),
(10486, 3865, '①에서 같은 칸에 도착하지만 ②의 equals가 참조 비교라 다른 키로 판정돼 null이 반환된다.', 'hashCode를 재정의해 칸까지는 제대로 찾아가지만, Object의 equals는 같은 객체인지만 보므로 새로 만든 키는 남남으로 취급된다. 두 메서드를 함께 재정의해야 하는 이유다.', true),

-- 문제 3866
(10487, 3866, 'A는 값이 같은 인스턴스끼리 equals가 true이므로 HashSet에 둘을 넣으면 하나로 합쳐진다.', 'A는 hashCode를 재정의하지 않아 인스턴스마다 다른 해시 값이 나온다. 두 객체가 서로 다른 칸으로 가 equals가 호출되지도 않으므로 집합 크기는 2가 된다.', true),
(10488, 3866, 'B는 equals에 쓴 필드로만 해시 값을 만들므로 equals가 true인 두 객체는 언제나 같은 칸을 찾아간다.', 'equals가 같으면 hashCode도 같아야 한다는 규약을 지킨 형태다. 같은 필드를 쓰니 값이 같으면 해시 값도 같아 탐색이 같은 칸에서 시작한다.', false),
(10489, 3866, 'C는 매개변수 타입이 Coord여서 재정의가 아니라 오버로딩이 되고, 컬렉션은 Object를 받는 쪽을 호출한다.', '재정의는 시그니처가 같아야 성립한다. Object 대신 Coord를 받으면 별개 메서드가 되어 컬렉션 내부 호출에는 쓰이지 않는다. @Override를 붙이면 컴파일 단계에서 걸린다.', false),
(10490, 3866, 'D는 HashSet에 넣은 뒤 name을 바꾸면 contains도 remove도 실패해 원소가 그대로 남는다.', '해시 값에 쓰인 필드가 바뀌면 객체는 예전 칸에 남아 있는데 탐색은 새 해시 값의 칸을 본다. 키로 쓰는 클래스를 불변으로 설계해야 하는 이유다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1244, 3867, '추이성,이행성,전이성,추이성 규약,transitive,transitivity', 'c1과 p가 같고 p와 c2가 같다면 c1과 c2도 같아야 하는데 마지막 줄이 false다. 상대 타입에 따라 비교 기준을 바꾼 탓에 추이성이 깨졌다. 순서를 뒤집을 때 결과가 갈리는 대칭성 위반과는 다르며, 여기서는 p.equals(c1)과 c1.equals(p)가 모두 true라 대칭성은 지켜진다. 구체 클래스를 상속해 값 필드를 더하면서 이 규약을 지킬 방법은 없으므로, 상속 대신 컴포지션을 쓰거나 값 클래스를 final로 만든다.'),
       (1245, 3868, 'record,레코드,record 클래스,레코드 클래스,자바 레코드', 'B가 쓴 것은 Java 16에서 정식 도입된 record다. 선언에 적은 필드를 기준으로 equals·hashCode·toString이 함께 만들어지므로 손으로 짤 때 생기는 규약 위반이 사라지고, 필드를 늘리면 비교 기준도 같이 따라온다. 일반 클래스에 Lombok이나 IDE 생성기를 쓰는 방법과 결과는 비슷하지만, 저 방식은 생성 코드를 지우거나 필드 추가 후 다시 만들지 않으면 규약이 어긋날 수 있다는 점이 다르다. JPA 엔티티처럼 식별자만으로 동치성을 정해야 하는 자리에는 맞지 않는다.');

-- =====================================================
-- Lesson 772: equals 오버로딩과 가변 키, 컴포지션
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4811, 772, '아래 코드의 출력 두 줄과 그 원인에 대한 설명으로 옳은 것은?', '```java
class Item {
    private final String code;

    Item(String code) { this.code = code; }

    @Override
    public boolean equals(Object o) {
        return o instanceof Item i && i.code.equals(code);
    }

    @Override
    public int hashCode() { return 1; }
}

Set<Item> set = new HashSet<>();
set.add(new Item("A"));
set.add(new Item("A"));
set.add(new Item("B"));

System.out.println(set.size());
System.out.println(set.contains(new Item("B")));
```', 'OBJECTIVE'),
       (4812, 772, '아래 비교 방식을 쓰는 객체를 HashMap의 키로 두었을 때 생기는 문제로 옳은 것은?', '자바 표준 라이브러리의 URL 클래스는 equals를 이렇게 구현한다. 두 URL의 호스트 이름을 DNS로 조회해 IP 주소를 얻은 뒤, 그 주소가 같으면 같은 URL로 본다.

같은 호스트 이름이라도 조회 시점의 DNS 응답이나 부하 분산 설정에 따라 다른 IP 주소가 돌아올 수 있고, 네트워크가 끊긴 동안에는 주소를 아예 얻지 못한다.', 'OBJECTIVE'),
       (4813, 772, '아래 실행 결과가 나타난 이유로 옳은 것은?', '```java
// Member는 equals와 hashCode를 모두 name 필드 하나로 재정의했다.
Member m = new Member("kim");
Set<Member> set = new HashSet<>();
set.add(m);

System.out.println(set.contains(m));   // true

m.setName("lee");

System.out.println(set.contains(m));   // false
System.out.println(set.remove(m));     // false
System.out.println(set.size());        // 1
```', 'OBJECTIVE'),
       (4814, 772, '아래 표의 네 사례에 대한 설명으로 옳지 않은 것은?', '두 객체 x, y를 비교한 결과를 네 가지 경우로 나눈 표다.

| 사례 | x.equals(y) | x.hashCode() == y.hashCode() |
|---|---|---|
| ① | true | true |
| ② | true | false |
| ③ | false | true |
| ④ | false | false |', 'OBJECTIVE'),
       (4815, 772, '아래 코드에서 Coord의 equals가 재정의로 인정되지 않은 까닭을 가리키는 용어는?', '```java
public final class Coord {
    private final int x;
    private final int y;

    public Coord(int x, int y) { this.x = x; this.y = y; }

    public boolean equals(Coord o) { return x == o.x && y == o.y; }

    @Override
    public int hashCode() { return Objects.hash(x, y); }
}
```

```java
Coord a = new Coord(1, 2);
Object b = new Coord(1, 2);

System.out.println(a.equals(new Coord(1, 2)));   // true
System.out.println(a.equals(b));                 // false

Set<Coord> set = new HashSet<>();
set.add(a);
set.add(new Coord(1, 2));
System.out.println(set.size());                  // 2
```

컴파일도 실행도 오류 없이 위 결과가 그대로 나온다.', 'SUBJECTIVE'),
       (4816, 772, '아래에서 상속 관계를 걷어내고 그 자리에 적용한 설계 기법의 이름은?', '결제 금액을 담는 값 클래스 Money와, 여기에 할인 코드를 더한 Coupon이 있다. 바꾸기 전에는 Money 하나와 Coupon 둘을 섞어 비교할 때 a와 b가 같고 b와 c가 같은데 a와 c는 다르다고 나와, 컬렉션 조회 결과가 무엇을 먼저 넣었느냐에 따라 달라졌다.

```java
// 바꾸기 전
class Coupon extends Money {
    private final String code;
}

// 바꾼 뒤
final class Coupon {
    private final Money money;
    private final String code;

    public Money asMoney() { return money; }
}
```

바꾼 뒤에는 Coupon이 Money 자리에 들어갈 수 없게 되어 둘을 섞어 비교할 일 자체가 사라졌고, equals는 Coupon끼리만 정의하면 됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4811
(13003, 4811, '1과 true — 해시 값이 모두 같아 세 객체가 하나의 원소로 묶이고, equals는 호출되지 않는다.', '해시 값이 같으면 같은 버킷을 고를 뿐이고, 같은 원소인지는 버킷 안에서 equals가 판정한다. code가 다른 Item("B")는 equals가 false라 별개 원소로 남는다.', false),
(13004, 4811, '3과 true — hashCode를 상수로 두면 equals 결과가 무시돼 add할 때마다 새 원소가 쌓인다.', '버킷을 고른 뒤의 판정은 equals가 맡는다. code가 같은 두 Item("A")는 equals가 true라 두 번째 add가 무시되므로 집합 크기는 3이 아니라 2다.', false),
(13005, 4811, '2와 false — 상수 hashCode는 hashCode 규약 위반이라 넣어 둔 값을 다시 찾지 못한다.', '규약은 equals가 같으면 해시 값도 같아야 한다는 것인데 상수 해시는 이 조건을 늘 만족한다. 규약 위반이 아니라 분산이 나쁜 해시일 뿐이므로 contains는 정상적으로 true를 낸다.', false),
(13006, 4811, '2와 true — 원소가 모두 한 버킷에 쌓여 조회가 버킷 안 순차 비교에 가까워진다.', 'code가 같은 두 Item("A")는 equals로 걸러져 크기는 2, contains는 equals가 찾아내 true다. 다만 해시 값이 하나뿐이라 버킷 분산이 사라져 탐색 비용이 원소 수에 비례한다.', true),

-- 문제 4812
(13007, 4812, '비교에 쓰는 필드를 그대로 두면 결과는 언제나 같으므로, 비교마다 네트워크 왕복이 붙어 느려지는 성능 문제만 남는다.', '느려지는 것은 맞지만 그것만이 아니다. 필드가 그대로여도 돌아오는 IP 주소가 달라지면 같다는 판정 자체가 뒤집히므로 성능이 아니라 정확성 문제로 봐야 한다.', false),
(13008, 4812, '필드 값이 그대로여도 조회 시점에 따라 같다는 판정이 뒤집혀, 방금 넣은 키로 찾아도 값이 안 나오는 일이 생긴다.', 'equals는 비교에 쓰는 정보가 바뀌지 않는 한 몇 번을 호출해도 같은 결과를 내야 한다(일관성). 이 구현은 객체 밖 상태인 DNS 응답에 결과를 맡겨 그 조건을 어긴다.', true),
(13009, 4812, '비교 순서를 뒤집으면 결과가 달라져, 어느 쪽을 인자로 넘기느냐에 따라 조회 성공 여부가 갈린다.', '대칭성이 깨졌다고 본 오개념. 양쪽 호스트 이름을 같은 방식으로 주소로 바꿔 견주므로 같은 시점이라면 순서를 바꿔도 결과는 같다.', false),
(13010, 4812, '자기 자신을 키로 넘겨도 false가 나올 수 있어, 넣은 객체 그대로 조회하는 것부터 실패한다.', '반사성이 깨졌다고 본 오개념. 자기 자신과의 비교는 같은 호스트 이름을 같은 시점에 조회한 결과끼리 견주므로 true다. 문제는 넣을 때와 찾을 때의 시점이 다를 때 드러난다.', false),

-- 문제 4813
(13011, 4813, '원소는 처음 이름으로 계산한 버킷에 남아 있는데, 이후 조회는 바뀐 이름으로 계산한 다른 버킷을 뒤지기 때문이다.', '해시 값에 쓰는 필드를 컬렉션에 넣은 뒤 바꾸면 원소의 위치는 다시 계산되지 않는다. 그래서 찾지도 지우지도 못한 채 원소만 남는다. 키로 쓸 클래스를 불변으로 설계해야 하는 이유다.', true),
(13012, 4813, 'setName이 equals에 쓰는 필드를 바꿔 반사성이 깨졌고, 자기 자신과 비교해도 false가 되기 때문이다.', 'm.equals(m)은 이름이 lee로 같은 값끼리 견주므로 여전히 true다. 어긋난 것은 비교 결과가 아니라 원소가 놓인 버킷과 조회가 찾아가는 버킷이다.', false),
(13013, 4813, 'String이 불변이라 setName이 집합에 담긴 원소의 이름까지 바꾸지는 못해, 저장된 원소가 kim으로 남아 있기 때문이다.', '집합은 객체 참조를 담으므로 필드를 바꾸면 집합에서 꺼낸 원소도 lee로 보인다. 문자열이 불변이라는 것은 기존 문자열 객체의 내용이 바뀌지 않는다는 뜻일 뿐 필드 재할당을 막지 않는다.', false),
(13014, 4813, '필드가 바뀌면 HashSet이 원소를 새 버킷으로 옮기는데, 옮기는 사이 잠깐 원소를 찾지 못하는 상태가 되기 때문이다.', '컬렉션은 담아 둔 객체의 필드가 바뀌었다는 사실을 알 길이 없어 재배치를 하지 않는다. 자동으로 옮겨진다면 오히려 contains와 remove가 성공했을 것이다.', false),

-- 문제 4814
(13015, 4814, '②는 규약을 어긴 사례이며, 논리적으로 같은 두 객체가 다른 버킷으로 흩어져 넣어 둔 값을 못 찾게 된다.', 'equals가 true면 hashCode도 같아야 한다는 조건을 정면으로 어긴다. equals만 재정의하고 hashCode를 빠뜨렸을 때 나타나는 전형적인 모습이라 참인 설명이다.', false),
(13016, 4814, '③은 규약 위반이 아니며, 두 객체가 같은 버킷에 도착해도 그 안에서 equals가 둘을 갈라낸다.', '해시 충돌은 규약이 허용한다. 해시 값은 어느 버킷을 볼지 정하는 데까지만 쓰이고 최종 판정은 equals가 맡으므로 참인 설명이다.', false),
(13017, 4814, '②와 ③은 두 조건 중 한쪽만 어긋난 대칭적인 사례이므로, ②가 규약 위반이면 ③도 같은 이유로 규약 위반이다.', '규약은 equals가 같으면 hashCode도 같아야 한다는 한 방향만 요구한다. 그 역은 요구하지 않으므로 ③처럼 해시 값만 같은 경우는 충돌로 허용된다. 역까지 성립한다고 본 오개념이다.', true),
(13018, 4814, '④에 해당하는 쌍이 많을수록 버킷이 고르게 나뉘어 조회 성능에 유리하다.', '서로 다른 객체가 서로 다른 해시 값을 내는 것은 규약이 강제하지는 않지만 좋은 해시 함수의 조건이다. 한 값에 몰리면 탐색이 선형에 가까워지므로 참인 설명이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1560, 4815, '오버로딩,오버로드,메서드 오버로딩,메소드 오버로딩,overloading,overload,method overloading', '재정의(오버라이딩)는 메서드 이름뿐 아니라 매개변수 타입까지 같아야 성립한다. equals의 매개변수를 Object가 아니라 Coord로 적으면 Object의 equals를 덮어쓰는 것이 아니라 이름만 같은 메서드가 하나 더 생기는 오버로딩이 된다. 그래서 컴파일 시점 타입이 Coord인 첫 호출만 새로 만든 메서드로 가고, Object 타입 변수 b를 넘기거나 HashSet 내부처럼 인자가 Object로 다뤄지는 자리에서는 Object가 물려준 equals(참조 비교)가 불려 값이 같아도 false가 된다. hashCode는 제대로 재정의돼 두 객체가 같은 버킷까지는 찾아가지만, 판정을 맡을 equals가 참조 비교라 별개 원소로 쌓여 집합 크기가 2가 된다. 선언에 @Override를 붙이면 재정의가 아님을 컴파일러가 바로 잡아 준다.'),
       (1561, 4816, '컴포지션,컴포지션 패턴,composition,합성,객체 합성,구성', '구체 클래스를 상속해 값 필드를 추가하면서 equals 규약을 온전히 지킬 방법은 없다. 바꾸기 전 증상은 추이성 위반으로, 상대가 Money면 금액만 보고 Coupon이면 코드까지 보는 식으로 비교 기준이 갈린 탓에 생긴다. 해법은 상속 대신 기존 타입을 필드로 품고 필요할 때 꺼내 주는 컴포지션이다. Coupon이 Money의 하위 타입이 아니게 되면 둘을 섞어 비교할 일이 없어지고, equals는 같은 타입끼리만 정의하면 된다. 하위 타입이 상위 타입 자리를 그대로 대신할 수 있는 관계에만 상속을 쓰라는 원칙과 같은 맥락이며, 값 클래스를 final로 막아 하위 타입 자체를 만들지 못하게 하는 것도 같은 문제의 다른 해법이다.');

-- =====================================================
-- Lesson 930: equals·hashCode 구현에서 놓치기 쉬운 함정
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5759, 930, '아래 코드의 출력 결과와 그 원인으로 옳은 것은?', '```java
record Tag(String name, int[] codes) { }

Tag t1 = new Tag("sale", new int[]{1, 2});
Tag t2 = new Tag("sale", new int[]{1, 2});

Set<Tag> set = new HashSet<>();
set.add(t1);
set.add(t2);

System.out.println(t1.equals(t2));
System.out.println(set.size());
```', 'OBJECTIVE'),
       (5760, 930, '아래 코드의 x에서 깨지는 equals 규약과 그 수정 방법으로 옳은 것은?', '```java
public final class Reading {
    private final double value;

    public Reading(double value) { this.value = value; }

    @Override
    public boolean equals(Object o) {
        return o instanceof Reading r && r.value == value;
    }

    @Override
    public int hashCode() { return Double.hashCode(value); }
}

Reading x = new Reading(Double.NaN);   // 센서 측정에 실패한 값
```', 'OBJECTIVE'),
       (5761, 930, '아래 상황에서 같은 회원이 접속자 목록에 두 번 들어간 원인으로 옳은 것은?', '접속자 목록은 HashSet<User>로 관리한다. 회원이 로그인할 때마다 DB에서 정보를 읽어 User 객체를 새로 만들어 목록에 넣는다.

```java
class User {
    private final long id;
    private final String nickname;

    User(long id, String nickname) { this.id = id; this.nickname = nickname; }

    @Override
    public boolean equals(Object o) {
        return o instanceof User u && u.id == id;
    }

    @Override
    public int hashCode() { return Objects.hash(id, nickname); }
}
```

id가 7인 회원이 로그인한 상태에서 닉네임을 kim에서 kimchi로 바꾸고 다른 기기로 다시 로그인하자, 목록에 id가 7인 User가 두 개 들어 있었다.', 'OBJECTIVE'),
       (5762, 930, '아래 두 hashCode 구현에 대한 설명으로 옳은 것은?', '게임 서버의 좌표 클래스 Point3는 int 필드 x, y, z를 가지며, equals는 세 필드를 모두 비교한다. 이 객체는 HashMap의 키로 초당 수백만 번 조회된다.

```java
// 구현 A
@Override
public int hashCode() { return Objects.hash(x, y, z); }

// 구현 B
@Override
public int hashCode() {
    int result = Integer.hashCode(x);
    result = 31 * result + Integer.hashCode(y);
    result = 31 * result + Integer.hashCode(z);
    return result;
}
```', 'OBJECTIVE'),
       (5763, 930, '아래 실행 결과에서 두 키 사이에 벌어진 현상을 가리키는 용어는?', '```java
Map<String, Integer> map = new HashMap<>();
map.put("Aa", 1);
map.put("BB", 2);

System.out.println("Aa".hashCode());     // 2112
System.out.println("BB".hashCode());     // 2112
System.out.println("Aa".equals("BB"));   // false
System.out.println(map.size());          // 2
System.out.println(map.get("BB"));       // 2
```

디버거로 map 내부를 열어 보니 버킷 16개 가운데 0번 버킷 하나에 두 항목이 함께 들어 있고, 나머지 버킷은 비어 있었다.', 'SUBJECTIVE'),
       (5764, 930, '아래 상황에서 작은 id끼리의 비교만 통과한 까닭이 된 자바의 동작을 가리키는 용어는?', '주문 수정 API는 주문 작성자 id와 로그인한 회원 id가 같을 때만 수정을 허용한다. 두 id는 모두 Integer 타입이다.

```java
if (order.getWriterId() == loginUser.getId()) {
    order.update(request);
} else {
    throw new ForbiddenException();
}
```

id가 1~100인 테스트 데이터로는 모든 테스트가 통과했다. 운영에 배포하자 id가 57인 회원은 자기 주문을 정상적으로 수정했지만, id가 128인 회원과 3,021인 회원은 자기 주문인데도 ForbiddenException을 받았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5759
(15531, 5759, 'true, 1 — 자동 생성된 equals가 모든 컴포넌트를 내용 기준으로 비교해 두 배열도 같다고 본다.', 'record가 모든 컴포넌트를 값처럼 비교한다고 본 오개념. 자동 생성된 equals는 참조 타입 컴포넌트를 그 타입의 equals로 비교하는데, 배열은 equals를 재정의하지 않아 참조 비교가 된다.', false),
(15532, 5759, 'true, 2 — equals는 내용 기준으로 true지만 hashCode는 배열 주소로 계산해 두 원소가 다른 버킷으로 간다.', 'record는 같은 컴포넌트로 equals와 hashCode를 함께 만들어 둘이 어긋나지 않는다. 배열은 두 메서드 모두에서 참조 기준으로 다뤄지므로 equals부터 false다.', false),
(15533, 5759, 'false, 2 — 자동 생성된 equals가 배열 컴포넌트는 참조로 비교해, 내용이 같아도 다른 배열이면 다르다고 본다.', 'record의 equals는 컴포넌트마다 그 타입의 equals를 쓰고, 배열의 equals는 Object의 참조 비교 그대로다. 내용으로 비교하려면 equals·hashCode를 직접 재정의해 Arrays.equals·Arrays.hashCode를 써야 한다.', true),
(15534, 5759, 'false, 1 — equals는 false지만 hashCode는 배열 내용으로 계산돼 같은 버킷에 모여 하나로 합쳐진다.', '해시 값이 같아 같은 버킷에 모여도 하나로 합칠지는 equals가 정한다. equals가 false면 별개 원소로 남는다. 게다가 배열의 hashCode는 내용이 아니라 객체마다 따로 정해지는 값이다.', false),

-- 문제 5760
(15535, 5760, '대칭성 — 비교 순서에 따라 결과가 달라지므로, 한쪽 값을 기준으로 비교하도록 순서를 고정한다.', '== 비교는 양쪽을 바꿔도 결과가 같아 대칭성은 지켜진다. NaN끼리는 어느 순서로 비교해도 똑같이 false다. 문제는 순서가 아니라 자기 자신과의 비교에서 생긴다.', false),
(15536, 5760, 'null 처리 — NaN을 비교하다 NullPointerException이 나므로, 비교 전에 value가 null인지 검사한다.', 'double은 기본 타입이라 null이 될 수 없고, NaN도 예외 없이 비교된다. o가 null이면 instanceof가 false를 내므로 null 처리 규약도 지켜진다.', false),
(15537, 5760, '일관성 — NaN과의 비교는 호출할 때마다 결과가 바뀌므로, value를 비교 대상에서 뺀다.', 'NaN == NaN은 몇 번을 호출해도 항상 false라 결과가 바뀌지 않는다. 일관성은 네트워크·시간처럼 객체 밖 상태에 기대어 비교할 때 깨진다.', false),
(15538, 5760, '반사성 — x.equals(x)가 false가 되므로, 비교를 Double.compare(r.value, value) == 0으로 바꾼다.', '==로 비교하면 NaN은 자기 자신과도 같지 않아 x.equals(x)가 false다. Double.compare는 NaN끼리를 같다고 보므로 반사성이 회복된다. 부동소수점 필드를 이 방식으로 비교하는 이유다.', true),

-- 문제 5761
(15539, 5761, 'equals가 nickname을 보지 않아 대칭성이 깨졌고, 비교 순서에 따라 서로 다른 회원으로 판정됐다.', 'id 하나만 견주는 비교는 순서를 바꿔도 결과가 같아 대칭성은 지켜진다. 두 객체는 어느 방향으로 비교해도 equals가 true다.', false),
(15540, 5761, 'equals가 같다고 볼 두 객체가 서로 다른 해시 값을 내, equals 판정까지 가지 못하고 별개로 저장됐다.', 'hashCode에 equals가 보지 않는 nickname이 섞여, equals가 true인 두 객체의 해시 값이 달라졌다. HashSet은 해시 값이 다르면 equals를 부르지 않는다. hashCode에는 equals에 쓴 id만 넣어야 한다.', true),
(15541, 5761, '목록에 있던 객체의 nickname이 바뀌어 원래 버킷에 남은 탓에, 새 해시 값으로는 찾지 못했다.', '넣은 뒤 필드가 바뀐 가변 키 문제로 본 오개념. 필드가 final이고 로그인마다 객체를 새로 만들므로 먼저 들어간 객체는 kim 그대로다. 새 객체의 해시 값이 다를 뿐이다.', false),
(15542, 5761, 'equals는 모든 필드를 비교해야 한다는 규약을 어겨, id만 같은 두 객체를 다른 회원으로 판정했다.', 'equals 규약에 모든 필드를 비교하라는 조건은 없다. id만으로 같음을 정하는 것은 정당한 설계이며, 이 코드에서 두 객체의 equals는 true다. 어긋난 곳은 hashCode다.', false),

-- 문제 5762
(15543, 5762, 'A는 호출마다 가변 인자 배열을 만들고 int를 박싱해, 조회가 잦은 이 서버에서는 B보다 부담이 크다.', 'Objects.hash는 가변 인자라 호출마다 Object 배열이 생기고 int 값이 Integer로 박싱된다. 규약은 둘 다 지키지만, 호출이 잦은 곳에서는 31을 곱해 직접 더하는 B가 유리하다.', true),
(15544, 5762, 'A와 B는 같은 객체에 서로 다른 값을 내므로, 어느 쪽을 쓰든 같은 두 객체가 다른 버킷으로 갈 수 있다.', '두 구현의 결과 값이 서로 다른 것은 맞지만 한 클래스는 하나만 쓴다. 어느 쪽이든 같은 필드로 계산하므로 equals가 같은 두 객체는 늘 같은 해시 값을 낸다.', false),
(15545, 5762, 'B는 31을 곱하다 int 범위를 넘으면 예외가 발생하므로, 값이 큰 좌표에는 쓸 수 없다.', '자바의 int 곱셈은 범위를 넘으면 예외 없이 값이 순환한다. 넘친 값도 같은 입력에는 늘 같으므로 해시 값으로 쓰는 데 문제가 없다.', false),
(15546, 5762, 'A는 인자 순서를 z, y, x로 바꿔도 결과가 같으므로, 필드 나열 순서를 신경 쓸 필요가 없다.', 'Objects.hash는 앞 결과에 31을 곱하고 다음 값을 더하는 식이라 순서가 바뀌면 값도 바뀐다. 순서를 바꿔도 규약은 지켜지지만 결과가 같다는 설명은 틀렸다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1876, 5763, '해시 충돌,충돌,해시 콜리전,해시 값 충돌,hash collision,collision,hash conflict', '서로 다른 두 키가 같은 해시 값을 내는 것이 해시 충돌이다. 문자열 해시는 앞 글자부터 31을 곱해 더해 가는데, A(65)×31 + a(97)과 B(66)×31 + B(66)이 모두 2,112라 두 키가 같은 버킷에 들어갔다. hashCode 규약은 equals가 true면 해시 값도 같아야 한다는 한 방향만 요구하므로, 해시 값은 같고 equals는 false인 이 상황은 허용된다. HashMap은 버킷 안에서 equals로 키를 가려내므로 두 값 모두 정상 조회된다. equals가 true인데 해시 값이 다른 규약 위반과는 다르며, 충돌이 잦아 한 버킷에 항목이 몰리면 탐색이 느려지는 성능 문제로 이어진다. 충돌이 난 항목들을 한 버킷에 이어 담는 처리 방식인 체이닝과도 구분한다.'),
       (1877, 5764, 'Integer 캐시,Integer 캐싱,IntegerCache,Integer cache,정수 캐시,인티저 캐시,래퍼 캐시,래퍼 클래스 캐시,박싱 캐시,캐시,캐싱', 'int를 Integer로 바꾸는 Integer.valueOf는 -128~127 범위의 값에 대해 미리 만들어 둔 객체를 재사용한다. 이것이 Integer 캐시다. id 57은 두 쪽이 같은 캐시 객체를 가리켜 참조를 비교하는 ==가 우연히 true였고, 128 이상은 박싱할 때마다 새 객체가 생겨 값이 같아도 false가 됐다. 테스트 데이터가 모두 캐시 범위 안이라 버그가 드러나지 않았다. 오토박싱 자체는 기본 타입을 래퍼 객체로 바꾸는 변환일 뿐이고, 작은 값에서만 같은 객체가 나온 원인은 캐시다. ==는 같은 객체인지(동일성)를, equals는 값이 같은지(동치성)를 보므로 래퍼 타입은 equals나 Objects.equals로 비교해야 한다.');
