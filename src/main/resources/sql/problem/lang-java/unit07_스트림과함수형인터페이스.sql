-- Unit: 스트림과 함수형 인터페이스 (Unit ID: 192)
-- Chapter: Java (Chapter ID: 18)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (618, 192, '지연 평가 순서와 공용 풀, 스트림 재사용'),
       (776, 192, '람다 this 차이와 orElseGet'),
       (934, 192, '연산 순서와 실행 시점으로 읽는 스트림 파이프라인');

-- =====================================================
-- Lesson 618: 지연 평가 순서와 공용 풀, 스트림 재사용
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3887, 618, '아래 코드를 실행했을 때 콘솔에 출력되는 순서로 옳은 것은?', '```java
Stream.of("apple", "fig", "banana", "kiwi")
      .peek(s -> System.out.print("P:" + s + " "))
      .filter(s -> s.length() > 3)
      .map(s -> { System.out.print("M:" + s + " "); return s.toUpperCase(); })
      .anyMatch(s -> s.startsWith("B"));
```

출력 사이의 공백은 무시하고 순서만 비교한다.', 'OBJECTIVE'),
       (3888, 618, '아래 메서드가 컴파일되지 않는 이유로 옳은 것은?', '```java
public Runnable makeLogger() {
    int count = 0;
    Runnable r = () -> {
        count++;
        System.out.println("호출 횟수: " + count);
    };
    return r;
}
```', 'OBJECTIVE'),
       (3889, 618, '아래 표에 정리된 스트림 연산의 분류를 바탕으로 옳지 않은 것은?', '| 연산 | 분류 | 실행 특성 |
|---|---|---|
| `filter` | 중간 연산 | 무상태 — 원소를 하나씩 독립적으로 판정한다 |
| `sorted` | 중간 연산 | 상태 있음 — 소스의 모든 원소를 받아야 결과를 내보낸다 |
| `limit` | 중간 연산 | 상태 있음 — 정해진 개수를 채우면 위쪽 공급을 멈춘다 |
| `count` | 최종 연산 | 파이프라인 실행을 촉발하고 스트림을 소비한다 |', 'OBJECTIVE'),
       (3890, 618, '아래 상황에서 무관한 기능까지 함께 느려진 원인으로 옳은 것은?', '운영 중인 서버에 아래 코드를 배포한 뒤부터, 이 API가 호출되는 동안 병렬 스트림을 전혀 쓰지 않는 다른 API의 응답까지 함께 느려졌다. 장애 시점의 CPU 사용률은 10% 아래였고, 스레드 덤프에는 소켓 응답을 기다리는 워커 스레드가 코어 수만큼 잡혀 있었다. 사용자 1,000명분을 조회하는 요청이었다.

```java
List<Profile> profiles = userIds.parallelStream()
        .map(id -> httpClient.fetchProfile(id))
        .toList();
```', 'OBJECTIVE'),
       (3891, 618, '아래 상황에서 두 코드의 실행 시간을 가른, 원소마다 되풀이된 변환 작업을 가리키는 용어는?', '정수 100만 개가 담긴 리스트를 `Stream<Integer>`로 만들어 `reduce(0, Integer::sum)`으로 합산하니 42ms가 걸렸다. 같은 리스트에 `mapToInt`를 붙여 `IntStream`으로 바꾼 뒤 `sum()`을 호출하자 4ms로 줄었다. 두 코드가 수행한 덧셈 횟수는 똑같았지만, 프로파일러에는 앞쪽 코드에서만 수명이 아주 짧은 `Integer` 객체가 100만 개 넘게 만들어졌다고 기록됐다.', 'SUBJECTIVE'),
       (3892, 618, '아래 코드의 마지막 줄에서 던져지는 예외의 이름은?', '```java
Stream<String> longNames = names.stream().filter(n -> n.length() > 3);
long total = longNames.count();
List<String> collected = longNames.toList();
```

마지막 줄에서 남은 실행 로그:

```
... : stream has already been operated upon or closed
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3887
(10539, 3887, 'P:apple P:fig P:banana P:kiwi M:apple M:banana M:kiwi', '한 연산이 전 원소를 끝낸 뒤 다음 연산으로 넘어간다고 본 오해다. 스트림은 단계별 수평 처리가 아니라 원소 단위 수직 처리이며, anyMatch가 단락한다는 점도 놓쳤다.', false),
(10540, 3887, 'P:banana M:banana', 'anyMatch에 넘긴 조건을 만족하는 원소만 파이프라인을 탄다고 본 오해다. 그 조건은 파이프라인 맨 끝에서 평가되므로 apple과 fig도 앞선 연산을 그대로 거친다.', false),
(10541, 3887, 'P:apple M:apple P:fig P:banana M:banana', 'apple이 peek→filter→map을 통과한 뒤에야 fig가 시작된다. fig는 길이가 3이라 filter에서 걸러져 map을 건너뛰고, banana가 BANANA로 바뀌어 조건을 만족하는 순간 anyMatch가 단락해 kiwi는 아예 소스에서 꺼내지지 않는다.', true),
(10542, 3887, 'P:apple M:apple P:fig P:banana M:banana P:kiwi M:kiwi', '원소 단위 수직 처리까지는 맞게 봤지만, 최종 연산이 언제나 전 원소를 소비한다고 오해했다. anyMatch는 단락 연산이라 참인 원소를 만나는 즉시 true를 반환하고 파이프라인을 끝낸다.', false),

-- 문제 3888
(10543, 3888, '람다가 캡처한 지역 변수는 사실상 final이어야 하는데 count++가 그 값을 바꾼다.', '람다는 스택 프레임이 사라진 뒤에도 실행될 수 있어 지역 변수를 값으로 복사해 간다. 원본이 바뀌면 복사본과 어긋나므로 캡처 대상은 값이 한 번만 대입돼야 하고, count++가 바로 이 제약을 어긴다.', true),
(10544, 3888, 'Runnable은 추상 메서드가 두 개여서 람다식으로는 구현할 수 없다.', 'Runnable은 run() 하나만 가진 함수형 인터페이스라 람다 대상으로 적법하다. 막히는 지점은 인터페이스의 모양이 아니라 본문이 바깥 지역 변수를 다시 대입한다는 사실이다.', false),
(10545, 3888, '람다 본문에서 지역 변수를 읽으려면 선언에 final 키워드를 반드시 붙여야 한다.', 'Java 8부터는 값이 한 번만 대입되면 final 키워드가 없어도 사실상 final로 인정돼 읽을 수 있다. 금지되는 것은 읽기가 아니라 변경이므로 원인을 잘못 짚었다.', false),
(10546, 3888, '메서드가 반환하는 람다는 지역 변수를 참조할 수 없고 인스턴스 필드만 캡처할 수 있다.', '지역 변수도 값이 복사돼 캡처되므로 메서드가 반환된 뒤에 실행돼도 문제없다. 다만 필드에는 사실상 final 제약이 없어, count를 필드로 옮기면 같은 코드가 컴파일된다.', false),

-- 문제 3889
(10547, 3889, 'filter를 sorted 앞에 두면 정렬해야 할 원소 수가 줄어 전체 처리 비용이 낮아진다.', 'filter는 무상태라 위치를 앞으로 당겨도 결과가 같고, sorted는 넘겨받은 원소 전체를 정렬하므로 입력이 줄면 비용도 준다. 그래서 참인 진술이다.', false),
(10548, 3889, '무한 스트림에 sorted()를 걸어도 뒤에 limit(3)이 있으면 앞의 세 원소만 정렬해 곧바로 결과를 낸다.', 'sorted는 소스가 끝나야 첫 원소를 내보내는 배리어다. 무한 스트림에서는 정렬 단계에서 원소를 계속 모으기만 하므로 뒤의 limit이 실행될 기회조차 없어 프로그램이 끝나지 않는다.', true),
(10549, 3889, 'count()를 호출하기 전까지는 앞에 붙인 filter의 람다가 한 번도 실행되지 않는다.', '중간 연산은 무엇을 할지만 실행 계획으로 쌓아 두고, 최종 연산인 count()가 호출돼야 파이프라인이 비로소 돈다. 그래서 참인 진술이다.', false),
(10550, 3889, 'limit(3)은 원소 세 개가 통과하면 소스에 원소가 남아 있어도 더 이상 처리하지 않는다.', 'limit은 상태 있는 연산이지만 필요한 개수를 채우는 순간 단락해 위쪽 원소 공급을 멈춘다. 그래서 참인 진술이다.', false),

-- 문제 3890
(10551, 3890, '원소마다 스레드를 새로 만들어 스레드 생성 비용이 CPU를 모두 소모했다.', '병렬 스트림은 스레드를 새로 만들지 않고 미리 만들어 둔 풀의 워커를 재사용한다. 생성 비용이 원인이었다면 CPU 사용률이 10%에 머물 수도 없다.', false),
(10552, 3890, 'toList()가 결과를 모으는 동안 리스트 전체에 락을 걸어 다른 요청이 그 락을 기다렸다.', 'toList()는 워커별 부분 결과를 결합해 새 리스트를 만들 뿐 공유 리스트에 락을 걸지 않는다. 락 경합이라면 스레드 덤프도 소켓 대기가 아니라 모니터 대기를 가리켰을 것이다.', false),
(10553, 3890, 'map에 넘긴 람다가 사실상 final이 아닌 변수를 캡처해 원소마다 동기화가 걸렸다.', '사실상 final이 아닌 변수를 캡처하면 실행 중이 아니라 컴파일 단계에서 막힌다. 코드가 배포돼 돌아가고 있다는 사실만으로 배제되는 선지다.', false),
(10554, 3890, '병렬 스트림이 JVM 전체가 공유하는 풀에서 돌아, 그 풀이 비자 같은 풀을 쓰는 다른 작업까지 밀렸다.', 'parallelStream은 애플리케이션마다 하나뿐인 ForkJoinPool.commonPool에서 실행된다. 워커가 HTTP 응답을 기다리며 묶이면 코어 수만큼뿐인 풀이 고갈돼, 같은 풀에 얹힌 다른 작업이 차례를 기다린다. 병렬 스트림은 CPU 연산 전용이다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1252, 3891, '오토박싱,오토 박싱,autoboxing,auto boxing,박싱,boxing,박싱과 언박싱,boxing and unboxing', 'Stream<Integer>는 원소를 Integer 객체로 감싸 다루므로 덧셈마다 값을 꺼내 계산하고 결과를 다시 객체로 감싼다. 이 감싸기가 오토박싱이며, 100만 번 되풀이되면 수명이 짧은 객체가 대량으로 생겨 시간과 GC 부담을 만든다. mapToInt로 얻은 IntStream은 int를 그대로 다뤄 이 과정을 통째로 없애기 때문에 덧셈 횟수가 같아도 열 배 가까이 빨라졌다. 객체에서 값을 꺼내는 반대 방향은 언박싱이라 부르고, 개발자가 형 변환 연산자로 타입을 바꾸는 캐스팅과는 다른 개념이다.'),
       (1253, 3892, 'IllegalStateException,java.lang.IllegalStateException', 'count()는 최종 연산이라 호출되는 순간 파이프라인이 실행되고 그 스트림은 소비된 것으로 표시된다. 스트림은 일회용이라 같은 인스턴스에 toList()를 다시 걸면 IllegalStateException이 발생한다. 여러 번 순회해야 한다면 names.stream()으로 소스에서 새 스트림을 만들어야 한다. 값이 없는 Optional이나 빈 반복자에서 값을 꺼낼 때 나는 NoSuchElementException, 인자 자체가 잘못됐을 때 나는 IllegalArgumentException과 구분한다. 앞의 filter는 중간 연산이라 여기서는 아무 문제도 일으키지 않는다.');

-- =====================================================
-- Lesson 776: 람다 this 차이와 orElseGet
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4835, 776, '아래 코드에서 anon.get()과 lambda.get()이 돌려주는 값으로 옳은 것은?', '```java
public class Counter {
    private int value = 10;

    Supplier<Integer> anon = new Supplier<Integer>() {
        private int value = 20;
        @Override public Integer get() { return this.value; }
    };

    Supplier<Integer> lambda = () -> this.value;
}
```

new Counter()로 객체를 만든 뒤 anon.get()과 lambda.get()을 차례로 호출한다.', 'OBJECTIVE'),
       (4836, 776, '아래 코드의 실행 결과로 옳은 것은?', '```java
List<Integer> result = Stream.iterate(1, n -> n + 1)
        .filter(n -> n % 3 == 0)
        .limit(4)
        .toList();
System.out.println(result);
```

Stream.iterate(1, n -> n + 1)은 1, 2, 3, ...을 끝없이 만들어 내는 소스다.', 'OBJECTIVE'),
       (4837, 776, '아래 상황에서 캐시에 값이 있는데도 데이터베이스 조회가 실행된 원인으로 옳은 것은?', '설정 값을 메모리에 캐시하는 API를 배포한 뒤, 캐시 적중률이 99%인데도 데이터베이스 조회 로그가 요청마다 남았다. 아래 한 줄만 바꿔 다시 배포하자 조회 로그가 적중률만큼 줄었다. 두 배포 모두 API가 돌려준 값은 캐시에 들어 있던 값과 같았다.

```java
// 변경 전
Config c = cache.find(key).orElse(loadFromDb(key));

// 변경 후
Config c = cache.find(key).orElseGet(() -> loadFromDb(key));
```

변경 전 배포에서, 캐시에 값이 있던 요청 한 건의 로그:

```
[CACHE] hit key=theme
[DB] loadFromDb(key=theme) 실행
```', 'OBJECTIVE'),
       (4838, 776, '아래 측정 결과에 대한 해석으로 옳은 것은?', '8코어 장비에서 소스 자료구조와 원소당 연산만 바꿔 가며, 같은 작업을 순차 스트림과 병렬 스트림으로 각각 측정했다.

| 소스 | 원소 수 | 원소당 연산 | 순차 | 병렬 |
|---|---|---|---|---|
| ArrayList | 2,000만 | 소수 판정 | 8,100ms | 1,400ms |
| LinkedList | 2,000만 | 소수 판정 | 8,400ms | 7,600ms |
| ArrayList | 500 | 문자열 길이 합 | 0.03ms | 0.91ms |', 'OBJECTIVE'),
       (4839, 776, '아래 코드의 (가) 자리에 들어갈 중간 연산의 이름은?', '```java
List<List<String>> tagGroups = List.of(
        List.of("java", "stream"),
        List.of("lambda"),
        List.of("jvm", "stream"));

List<String> tags = tagGroups.stream()
        .(가)(List::stream)
        .distinct()
        .toList();
// tags == [java, stream, lambda, jvm]
```

같은 자리에 map(List::stream)을 넣었을 때는 타입이 Stream<Stream<String>>이 되어 toList()의 결과가 List<Stream<String>>이었다.', 'SUBJECTIVE'),
       (4840, 776, '아래 코드의 (가) 자리에 들어갈 표준 함수형 인터페이스의 이름은?', '```java
List<String> names = List.of("kim", "", "lee", "  ");

(가)<String> blank = s -> s.isBlank();

List<String> valid = names.stream()
        .filter(blank.negate())
        .toList();
// valid == [kim, lee]
```

java.util.function 패키지의 표준 인터페이스 가운데 하나이며, 제네릭 타입 인자를 뺀 이름만 답한다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4835
(13067, 4835, 'anon.get() = 20, lambda.get() = 20', '람다도 익명 클래스처럼 자기만의 스코프를 열어 가장 가까운 value를 본다고 여긴 오해다. 람다는 별도의 타입을 만들지 않고 바깥 인스턴스의 문맥에서 실행되므로, 여기서 볼 수 있는 value는 Counter의 필드 하나뿐이다.', false),
(13068, 4835, 'anon.get() = 20, lambda.get() = 10', '익명 클래스는 자체 타입의 인스턴스라 this가 자기 자신을 가리켜 안쪽에 선언한 value 20을 돌려준다. 람다는 새 타입을 만들지 않아 this가 바깥 Counter 인스턴스를 그대로 가리키므로 10을 돌려준다.', true),
(13069, 4835, 'anon.get() = 10, lambda.get() = 10', '익명 클래스 본문에 선언한 필드를 못 보고 바깥 필드만 보인다고 여긴 오해다. 안쪽에 같은 이름의 필드가 있으면 this.value는 안쪽 필드를 가리키고, 바깥 필드에는 Counter.this.value로만 닿는다.', false),
(13070, 4835, 'anon.get() = 10, lambda.get() = 20', '두 방식의 this가 가리키는 대상을 서로 바꿔 알고 있는 경우다. 자기 자신을 가리키는 쪽이 익명 클래스이고, 바깥 인스턴스를 가리키는 쪽이 람다다.', false),

-- 문제 4836
(13071, 4836, '[3, 6, 9, 12]가 출력된다.', '원소가 하나씩 파이프라인을 끝까지 통과하며 3의 배수만 filter를 지나 limit에 도달한다. 네 번째인 12가 통과하는 순간 limit이 단락해 소스에서 원소를 더 꺼내지 않으므로 리스트가 그대로 확정된다.', true),
(13072, 4836, '[3]이 출력된다.', 'limit(4)이 소스에서 1, 2, 3, 4를 먼저 잘라낸 뒤에 filter가 걸린다고 본 오해다. 연산은 적힌 순서대로 이어지므로 limit이 세는 대상은 소스의 앞 네 개가 아니라 filter를 통과한 원소다.', false),
(13073, 4836, '소스가 무한 스트림이라 filter 단계에서 멈추지 않아 아무 값도 출력되지 않는다.', '무한 스트림이면 무조건 끝나지 않는다고 본 오해다. filter는 원소를 모아 두지 않는 무상태 연산이라 통과한 원소를 곧바로 아래로 넘긴다. sorted처럼 전체를 모아야 하는 연산이었다면 실제로 끝나지 않는다.', false),
(13074, 4836, '빈 리스트 []가 출력된다.', '중간 연산이 지연된다는 성질을 지나치게 넓혀 소스가 원소를 아예 만들지 않는다고 본 오해다. 최종 연산인 toList()가 호출되면 그때 파이프라인이 실행되면서 iterate가 값을 공급한다.', false),

-- 문제 4837
(13075, 4837, 'cache.find가 돌려준 Optional이 값을 담고도 비어 있다고 판정돼 대체 값 경로로 넘어갔다.', '판정이 잘못됐다면 API가 돌려준 값도 조회 결과여야 하는데, 두 배포 모두 반환값은 캐시에 들어 있던 값과 같았다. 비어 있는지 여부는 제대로 가려졌으므로 원인은 그 판정보다 앞선 단계에 있다.', false),
(13076, 4837, 'Optional은 값을 지연 생성하는 그릇이라 orElse를 호출하는 시점에야 원본을 읽어 온다.', 'Optional은 값이 있는지 없는지를 감싸 표현하는 그릇일 뿐, 값을 나중에 만들어 내는 지연 장치가 아니다. 로그에서도 조회보다 hit가 먼저 찍혀 값이 이미 준비돼 있었음을 보여 준다.', false),
(13077, 4837, 'orElseGet은 한 번 만든 값을 내부에 보관해 두 번째 요청부터 조회를 건너뛰는데, 그 보관 기능이 없는 orElse는 매번 조회한다.', 'orElseGet은 결과를 보관하지 않는다. 조회가 줄어든 이유는 값이 있을 때 넘겨받은 람다를 아예 실행하지 않기 때문이며, 캐시가 비는 1%의 요청에서는 변경 후에도 그때마다 조회가 일어난다.', false),
(13078, 4837, 'orElse에 넘긴 인자는 메서드가 호출되기 전에 먼저 계산되므로, 캐시에 값이 있어도 loadFromDb가 실행된다.', '자바는 인자를 먼저 평가해 그 결과 값을 넘긴다. 그래서 hit가 찍힌 요청에서도 orElse에 넣을 값을 만드느라 조회가 실행됐다. orElseGet은 값 대신 람다를 넘겨 비어 있을 때만 본문이 돌아가므로 이 비용이 사라진다.', true),

-- 문제 4838
(13079, 4838, '1행과 2행의 순차 처리 시간이 비슷하므로, 병렬 처리 성능도 소스 자료구조보다 원소 수에 좌우된다.', '1행과 2행은 원소 수와 원소당 연산이 똑같은데 병렬 결과만 5배 넘게 갈렸다. 원소 수가 같은 두 행이 서로 다른 결과를 냈으니, 갈림길을 만든 조건은 원소 수가 아니라 나머지 하나인 소스 쪽이다.', false),
(13080, 4838, '3행에서 병렬이 느린 것은 원소당 연산 시간이 스레드 분배·결합 비용보다 커서 생긴 결과다.', '두 비용의 크기를 반대로 본 오해다. 원소 500개의 길이 합은 순차로 0.03ms에 끝날 만큼 가볍고, 그보다 큰 분배·결합 비용이 더해졌기 때문에 0.91ms로 늘어난 것이다.', false),
(13081, 4838, '1행과 2행의 병렬 결과가 갈린 것은 LinkedList가 중간 지점을 바로 집지 못해 조각으로 나누는 비용이 크기 때문이다.', '병렬 스트림은 소스를 조각으로 나눠 워커에 분배한다. ArrayList는 인덱스로 중간을 곧바로 집지만 LinkedList는 링크를 따라가야 분할 지점을 찾으므로, 원소당 연산이 무거워도 병렬 이득이 분할 비용에 거의 상쇄된다.', true),
(13082, 4838, '1행에서 병렬이 약 5.8배 빨라졌으므로 commonPool이 코어 수의 5.8배만큼 워커 스레드를 만들었음을 알 수 있다.', '속도 향상 배수를 스레드 개수로 읽은 오해다. commonPool의 기본 크기는 코어 수에서 하나를 뺀 값이고 호출 스레드를 더해도 8 남짓이라, 8,100ms에서 1,400ms로 줄어든 폭은 그 안에서 설명된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1568, 4839, 'flatMap,flat map,플랫맵,플랫 맵', '각 원소가 만들어 낸 스트림의 내용물을 꺼내 하나의 스트림으로 이어 붙이는 중간 연산이 flatMap이다. map은 원소 하나를 원소 하나로 바꾸기 때문에 List를 Stream으로 바꾸면 스트림을 담은 스트림이 그대로 남지만, flatMap은 그 한 겹을 펼쳐 Stream<String>을 만든다. 그래서 중첩 컬렉션을 평탄화하거나 Optional이 겹쳐 나오는 자리에 쓴다. 값만 변환하는 map, 조건으로 원소를 걸러 내는 filter와 구분하고, 결과에서 중복이 사라진 것은 flatMap이 아니라 뒤에 붙은 distinct가 한 일이라는 점도 함께 기억해 둔다.'),
       (1569, 4840, 'Predicate,프레디케이트,프리디케이트', '원소 하나를 받아 참·거짓을 돌려주는 판정용 인터페이스가 Predicate<T>이고, 추상 메서드는 test다. filter가 요구하는 타입이 바로 이것이며, 조건을 뒤집는 negate와 조건을 엮는 and·or 같은 기본 메서드도 Predicate에 들어 있다. 같은 람다를 Function<String, Boolean>에 담을 수도 있지만 그쪽에는 negate가 없고 filter에 그대로 넘길 수도 없어 (가) 자리에는 들어가지 못한다. 인자 없이 값을 만들어 내는 Supplier, 값을 받고 아무것도 돌려주지 않는 Consumer와도 구분한다.');

-- =====================================================
-- Lesson 934: 연산 순서와 실행 시점으로 읽는 스트림 파이프라인
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5783, 934, '아래 표에 정리된 함수형 인터페이스를 바탕으로 옳지 않은 것은?', '| 인터페이스 | 시그니처 | 대표 사용처 |
|---|---|---|
| `Supplier<T>` | `() -> T` | `Optional.orElseGet` |
| `Consumer<T>` | `T -> void` | `Iterable.forEach` |
| `UnaryOperator<T>` | `T -> T` | `List.replaceAll` |
| `BiFunction<T, U, R>` | `(T, U) -> R` | `Map.merge` |', 'OBJECTIVE'),
       (5784, 934, '아래 상황에서 변경 후 코드가 빨라진 까닭으로 옳은 것은?', '주문 1,000만 건에서 결제 완료 주문의 금액 상위 10건을 뽑는 API를 아래처럼 연산 순서만 바꿔 배포하자 평균 응답이 4,800ms에서 610ms로 줄었다. 두 코드가 돌려준 리스트는 완전히 같았고, 결제 완료 주문은 전체의 약 3%다.

```java
// 변경 전
List<Order> top = orders.stream()
        .sorted(byAmountDesc)
        .filter(Order::paid)
        .limit(10)
        .toList();

// 변경 후
List<Order> top = orders.stream()
        .filter(Order::paid)
        .sorted(byAmountDesc)
        .limit(10)
        .toList();
```', 'OBJECTIVE'),
       (5785, 934, '아래 코드가 예외 없이 고객별 합계를 만들도록 고치는 방법으로 옳은 것은?', '```java
record Order(String customer, int amount) {}

List<Order> orders = List.of(
        new Order("kim", 3000),
        new Order("lee", 5000),
        new Order("kim", 7000));

Map<String, Integer> totalByCustomer = orders.stream()
        .collect(Collectors.toMap(Order::customer, Order::amount));
```

실행 로그:

```
java.lang.IllegalStateException: Duplicate key kim (attempted merging values 3000 and 7000)
```

목표는 고객별 금액을 더한 `Map`을 얻는 것이다.', 'OBJECTIVE'),
       (5786, 934, '아래 상황에서 결과 리스트의 크기가 실행마다 달라진 원인으로 옳은 것은?', '원소 100만 개짜리 `ArrayList`에서 조건에 맞는 이름만 모으는 배치를 아래 코드로 돌렸다. 조건을 만족하는 원소는 언제나 40만 개인데, 같은 입력으로 다섯 번 실행한 결과는 그 아래와 같았다.

```java
List<String> result = new ArrayList<>();
names.parallelStream()
        .filter(n -> n.startsWith("k"))
        .forEach(result::add);
```

```
1회: result.size() = 400,000
2회: result.size() = 399,981
3회: ArrayIndexOutOfBoundsException
4회: result.size() = 400,000
5회: result.size() = 399,997
```', 'OBJECTIVE'),
       (5787, 934, '아래 코드에서 두 구간의 측정 시간이 크게 갈린 까닭이 되는 스트림의 성질을 가리키는 용어는?', '```java
long t0 = System.nanoTime();
Stream<String> errors = Files.lines(Path.of("access.log"))   // 1,000만 줄
        .filter(line -> line.contains("ERROR"))
        .map(String::trim);
System.out.printf("구간 A: %.2fms%n", (System.nanoTime() - t0) / 1e6);

long t1 = System.nanoTime();
List<String> collected = errors.toList();
System.out.printf("구간 B: %.2fms%n", (System.nanoTime() - t1) / 1e6);
```

출력:

```
구간 A: 0.04ms
구간 B: 3,180.55ms
```

파일에서 줄을 읽어 들이는 디스크 I/O는 구간 B에서만 관찰됐다.', 'SUBJECTIVE'),
       (5788, 934, '아래 두 코드의 실행 시간과 `calls` 값을 가른, `anyMatch`가 가진 성질을 가리키는 용어는?', '문서 2,000만 건이 담긴 리스트에서 점수가 90을 넘는 문서가 하나라도 있는지 확인하는 코드를 두 가지로 구현해 같은 데이터로 측정했다. 조건을 만족하는 첫 문서는 앞에서 열두 번째에 있었고, 두 코드가 돌려준 값은 모두 `true`였다.

```java
AtomicInteger calls = new AtomicInteger();

boolean a = docs.stream()
        .peek(d -> calls.incrementAndGet())
        .anyMatch(d -> d.score() > 90);
// a = true, calls = 12, 0.31ms

calls.set(0);

boolean b = docs.stream()
        .peek(d -> calls.incrementAndGet())
        .filter(d -> d.score() > 90)
        .count() > 0;
// b = true, calls = 20,000,000, 2,410ms
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5783
(15595, 5783, '`Optional.orElseGet`이 값이 아니라 `Supplier`를 받는 덕분에, 값이 들어 있으면 대체 값을 만드는 계산 자체가 일어나지 않는다.', '표의 `Supplier`는 인자 없이 값을 만들어 내므로, 넘긴 람다는 호출되기 전까지 실행되지 않는다. 비어 있을 때만 본문이 돌아 비싼 조회를 건너뛸 수 있으니 참인 진술이다.', false),
(15596, 5783, '`Consumer`는 받은 원소를 가공해 돌려주므로, `map`에 넘겨 원소를 다른 값으로 변환하는 데 쓸 수 있다.', '표의 `Consumer`는 반환 타입이 `void`라 돌려줄 값이 없어 거짓이다. 원소를 다른 값으로 바꾸는 `map` 자리에는 `Function`이 필요하고, `Consumer`는 `forEach`처럼 값을 소비만 하는 자리에 쓴다.', true),
(15597, 5783, '`List.replaceAll`에 `UnaryOperator`를 넘기면 원소를 같은 타입의 값으로 바꿔 리스트를 제자리에서 갱신할 수 있다.', '표의 `UnaryOperator`는 입력과 출력이 모두 `T`라 원소 타입을 바꾸지 않는다. 리스트의 원소 타입을 유지한 채 자리마다 값을 치환하려면 이 제약이 필요하니 참인 진술이다.', false),
(15598, 5783, '`Map.merge`가 `BiFunction`을 받는 것은 기존 값과 새 값 두 개를 함께 넘겨 하나로 합치게 하기 위해서다.', '표의 `BiFunction`은 인자를 두 개 받아 하나를 돌려준다. 키가 이미 있을 때 기존 값과 새 값을 같이 넘겨 합친 결과를 받아야 하므로 인자 두 개짜리가 맞으니 참인 진술이다.', false),

-- 문제 5784
(15599, 5784, '`filter`는 상태 있는 연산이라 앞에 두면 원소를 미리 모아 두고, 뒤에 오는 `sorted`가 그 모인 원소를 넘겨받아 정렬 준비 단계를 건너뛴다.', '`filter`는 원소를 하나씩 독립적으로 판정하는 무상태 연산이라 아무것도 모아 두지 않는다. 원소를 전부 모아야 하는 쪽은 `sorted`이므로 두 연산의 분류를 서로 바꿔 본 오해다.', false),
(15600, 5784, '`sorted`는 뒤에 `limit(10)`이 있으면 상위 열 개를 확정하는 순간 멈추므로, 변경 전이 느렸던 원인은 정렬이 아니라 `filter`가 정렬을 마친 원소를 한 번 더 훑은 데 있다.', '`sorted`는 소스가 끝나야 첫 원소를 내보내는 배리어여서 뒤의 `limit`이 정렬을 중간에 세우지 못한다. `filter`가 훑는 원소 수는 두 코드가 1,000만 건으로 같아 차이의 원인이 될 수 없다.', false),
(15601, 5784, '중간 연산을 하나의 반복문으로 융합하는 최적화가 변경 후 파이프라인에만 걸려, 단계마다 생기던 중간 컬렉션이 사라졌다.', '연산 융합은 순서와 상관없이 두 파이프라인 모두에 일어나고, 스트림은 어느 쪽에서도 단계마다 중간 컬렉션을 만들지 않는다. 차이는 융합 여부가 아니라 `sorted`가 받는 원소 수에 있다.', false),
(15602, 5784, '`sorted`는 넘겨받은 원소를 모두 모아야 첫 결과를 낼 수 있으므로, 앞에서 `filter`가 3%만 남기면 정렬해야 할 원소 자체가 크게 줄어든다.', '변경 전에는 1,000만 건을 통째로 정렬한 뒤 걸렀고, 변경 후에는 약 30만 건만 정렬한다. 무상태 연산을 배리어 앞으로 당겨 처리량을 줄이는 것이 파이프라인 순서 조정의 핵심이다.', true),

-- 문제 5785
(15603, 5785, '`toMap`에 세 번째 인자로 `(a, b) -> a + b`를 넘겨, 같은 키가 다시 나왔을 때 두 값을 어떻게 합칠지 알려 준다.', '인자 두 개짜리 `toMap`은 키가 겹칠 때 무엇을 남길지 모르므로 예외를 던진다. 병합 함수를 주면 같은 고객의 두 금액이 더해져 한 값으로 남는다. `groupingBy`에 `summingInt`를 엮어도 결과는 같다.', true),
(15604, 5785, '`collect` 앞에 `distinct()`를 붙여 같은 고객의 주문이 하나만 남게 만든다.', '`distinct`는 원소 전체의 동등성으로 중복을 지우는데, 두 `kim` 주문은 `amount`가 달라 서로 다른 원소라 하나도 지워지지 않는다. 지워진다 해도 남은 금액 하나만 담겨 합계가 되지 못한다.', false),
(15605, 5785, '`toMap` 대신 `toConcurrentMap`으로 바꿔, 같은 키에 값이 겹쳐도 안전하게 처리되게 한다.', '`toConcurrentMap`이 바꾸는 것은 결과 맵의 동시성 특성뿐이고, 병합 함수를 주지 않으면 키가 겹칠 때 같은 예외를 던진다. 스레드 안전과 키 충돌 처리를 한 문제로 묶어 본 오해다.', false),
(15606, 5785, '`orders.stream()`을 `orders.parallelStream()`으로 바꿔, 키가 겹치는 원소를 서로 다른 워커가 나눠 담게 한다.', '워커를 나눠도 부분 결과를 합치는 단계에서 같은 키가 다시 만나므로 충돌은 그대로 남는다. 순차와 병렬은 실행 방식의 선택일 뿐 키가 겹칠 때의 처리 규칙과는 무관하다.', false),

-- 문제 5786
(15607, 5786, '`parallelStream`이 소스를 조각으로 나눌 때 조각 경계에 걸린 원소를 어느 쪽에도 넣지 못해 실행마다 조금씩 빠뜨렸다.', '소스를 나누는 분할은 원소를 빠뜨리지 않도록 정의돼 있다. 분할이 원인이라면 모자란 개수가 매번 비슷해야 하고, 3회에서 배열 인덱스 예외가 난 것도 설명하지 못한다.', false),
(15608, 5786, '`filter`에 넘긴 람다가 워커마다 따로 만들어져, 스레드에 따라 같은 이름에 대한 조건 판정 결과가 달라졌다.', '이 람다는 바깥 상태를 건드리지 않는 순수한 판정식이라 어느 스레드에서 돌아도 결과가 같다. 판정이 흔들렸다면 조건을 만족하는 원소 수도 변했겠지만 그 수는 언제나 40만 개다.', false),
(15609, 5786, '여러 워커 스레드가 동기화 장치가 없는 `ArrayList`에 동시에 추가해, 크기 증가와 값 쓰기가 서로 덮였다.', '`ArrayList.add`는 배열 칸에 값을 쓰고 크기를 늘리는 두 단계라 동시에 실행되면 한쪽 값이 덮이거나 아직 늘리지 않은 칸에 쓰게 된다. 결과는 `collect`나 `toList`로 모아야 안전하다.', true),
(15610, 5786, '`forEach`는 순서를 보장하지 않는 단락 연산이라, 앞선 워커가 끝나면 남은 원소를 처리하지 않고 파이프라인을 끝냈다.', '`forEach`는 원소를 모두 소비하는 최종 연산이지 단락 연산이 아니다. 순서를 보장하지 않는 것과 원소를 건너뛰는 것은 다른 이야기이며, 단락하는 쪽은 `anyMatch`·`findFirst` 같은 연산이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1884, 5787, '지연 평가,지연평가,지연 연산,지연연산,늦은 평가,게으른 평가,lazy evaluation,lazyevaluation,lazy,laziness,레이지 이밸류에이션', '중간 연산인 `filter`와 `map`은 무엇을 할지 실행 계획으로 쌓아 둘 뿐이라, 구간 A에서는 파일을 한 줄도 읽지 않고 0.04ms 만에 지나간다. 최종 연산인 `toList`가 호출되는 구간 B에서야 파이프라인이 한 번에 실행되면서 디스크 I/O가 일어난다. 이 성질 덕분에 `Stream.iterate`가 만드는 무한 스트림도 `limit`과 엮이면 정상으로 끝난다. 결과가 확정되면 남은 원소를 건너뛰는 단락(short-circuit)과는 구분한다. 단락은 실행이 시작된 뒤 언제 멈추느냐의 이야기이고, 지연 평가는 실행이 언제 시작되느냐의 이야기다. 계산한 값을 보관해 두고 다시 쓰는 캐싱과도 다르다. 스트림은 결과를 보관하지 않아 같은 자료를 다시 훑으려면 소스에서 새 스트림을 만들어야 한다.'),
       (1885, 5788, '단락,단락 평가,단락 연산,단축 평가,쇼트 서킷,쇼트서킷,숏 서킷,숏서킷,short-circuit,short circuit,shortcircuit,short-circuiting', '`anyMatch`는 참인 원소를 하나 만나는 순간 결과가 확정되므로 그 자리에서 파이프라인을 끝내고 소스에서 원소를 더 꺼내지 않는다. 그래서 열두 번째 문서까지만 `peek`가 돌아 `calls`가 12에서 멈췄다. 반면 `count`는 전체 개수를 세야 끝나는 연산이라 2,000만 건을 모두 통과시켜 시간이 수천 배로 벌어졌다. `findFirst`·`findAny`·`allMatch`·`limit`도 같은 성질을 가진다. 최종 연산이 호출되기 전까지 아무것도 실행하지 않는 지연 평가와는 구분한다. 지연 평가가 언제 시작하느냐의 이야기라면 단락은 언제 멈추느냐의 이야기다. 앞에 `sorted`처럼 모든 원소를 모아야 하는 배리어가 끼어 있으면 뒤에 단락 연산이 있어도 소스를 전부 읽게 되어 이 이점이 사라진다.');
