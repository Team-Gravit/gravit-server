-- Unit: 제네릭과 타입 소거 (Unit ID: 191)
-- Chapter: Java (Chapter ID: 18)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (617, 191, 'raw 타입과 와일드카드, 브리지 메서드'),
       (775, 191, '소거 후 시그니처 충돌과 하한 와일드카드'),
       (933, 191, '제네릭과 타입 소거: 소거가 만든 제약과 우회 방법');

-- =====================================================
-- Lesson 617: raw 타입과 와일드카드, 브리지 메서드
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3881, 617, '아래 코드를 실행할 때 ClassCastException이 발생하는 행은?', '아래 코드는 3행에서 unchecked 경고가 나지만 컴파일은 통과한다.

```java
List<String> names = new ArrayList<>();   // 1
names.add("kim");                         // 2
List raw = names;                         // 3
raw.add(42);                              // 4
for (Object o : raw) { }                  // 5
String s = names.get(1);                  // 6
```', 'OBJECTIVE'),
       (3882, 617, '아래 코드에서 (가)와 (나)의 오류가 드러나는 시점을 바르게 짝지은 것은?', '배열과 리스트에 각각 하위 타입 컨테이너를 대입한 코드다.

```java
// (가)
Number[] nums = new Integer[2];
nums[0] = 3.14;

// (나)
List<Number> list = new ArrayList<Integer>();
```', 'OBJECTIVE'),
       (3883, 617, '아래 표를 바탕으로 와일드카드 사용을 설명한 것 중 옳지 않은 것은?', '와일드카드 세 형태를 읽기와 쓰기 기준으로 정리한 표다.

| 선언 형태 | 원소를 꺼낼 때 | 원소를 넣을 때 |
|---|---|---|
| `List<?>` | Object로만 받음 | null 외에는 불가 |
| `List<? extends Number>` | Number로 받음 | 불가 |
| `List<? super Integer>` | Object로만 받음 | Integer와 그 하위 타입 가능 |', 'OBJECTIVE'),
       (3884, 617, '아래 코드가 컴파일되도록 고치는 방법으로 옳은 것은?', '아래 Repository는 타입 인자로 받은 타입의 인스턴스를 직접 만들려 한다.

```java
class Repository<T> {
    T create() {
        return new T();   // 여기서 컴파일 오류
    }
}

Repository<User> repo = new Repository<>();
User u = repo.create();
```', 'OBJECTIVE'),
       (3885, 617, '아래 상황에서 컴파일러가 소스에 없는데도 자동으로 만들어 넣은 메서드를 부르는 이름은?', '```java
class Box<T> {
    void set(T value) { /* 저장 */ }
}

class StringBox extends Box<String> {
    @Override
    void set(String value) { /* 저장 */ }
}
```

StringBox에는 set을 하나만 적었는데, 리플렉션으로 선언된 메서드를 찍어 보면 두 개가 나온다.

```
for (Method m : StringBox.class.getDeclaredMethods()) {
    System.out.println(m.getName() + " " + m.getParameterTypes()[0].getSimpleName()
                       + " synthetic=" + m.isSynthetic());
}

set String synthetic=false
set Object synthetic=true
```

또한 StringBox를 raw 타입 변수에 담아 set(42)를 호출하면, 소스 어디에도 적지 않은 형변환에서 ClassCastException이 난다.', 'SUBJECTIVE'),
       (3886, 617, '아래 코드에서 실행 중에 벌어진 현상을 가리키는 용어는?', '```java
static void trick(List<String>... lists) {
    Object[] arr = lists;
    arr[0] = List.of(42);
    String s = lists[0].get(0);
}

trick(new ArrayList<String>());
```

컴파일러는 이 메서드 선언에 unchecked 경고를 냈지만 컴파일은 통과한다. 실행하면 마지막 대입에서 ClassCastException이 나고, 디버거로 멈춰 보면 lists[0]에는 문자열이 아니라 정수 42가 담긴 리스트가 들어 있다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3881
(10523, 3881, '3행', 'raw 타입 변수에 List<String>을 대입하는 것은 unchecked 경고 대상일 뿐이다. 소거 후 두 변수의 실제 타입은 똑같은 List라서 대입 자체에는 아무 검사도 끼어들지 않는다.', false),
(10524, 3881, '4행', 'raw 타입으로 호출하면 컴파일러가 타입 검사를 건너뛰고, 리스트 내부는 소거되어 Object를 담으므로 42가 그대로 저장된다. 잘못된 값을 넣는 시점에는 아무 일도 일어나지 않는다.', false),
(10525, 3881, '5행', '원소를 Object로 받으면 컴파일러가 형변환을 삽입할 이유가 없다. 순회는 담긴 값의 실제 타입과 무관하게 통과한다.', false),
(10526, 3881, '6행', 'names는 List<String>이라 컴파일러가 get 결과 앞에 (String) 형변환을 자동으로 넣어 둔다. 실제 값은 Integer 42이므로 이 형변환에서 예외가 터진다. 소거된 제네릭에서는 잘못 넣은 자리가 아니라 꺼내 쓰는 자리에서 문제가 드러난다.', true),

-- 문제 3882
(10527, 3882, '(가)와 (나) 모두 컴파일 단계에서 걸러진다.', '배열은 공변이라 Integer[]를 Number[] 변수에 담는 것도, 그 자리에 Double 값을 넣는 것도 컴파일러가 막지 않는다. (가)가 걸리는 곳은 실행 시점이다.', false),
(10528, 3882, '(가)는 실행 중 ArrayStoreException으로, (나)는 컴파일 오류로 드러난다.', '배열은 공변이라 (가)는 컴파일을 통과하고 저장 시점에 원소 타입을 검사해 예외를 던진다. 제네릭은 불공변이라 (나)는 대입 자체가 막힌다. 소거 후에는 런타임 검사가 불가능하므로 컴파일 타임에 차단하는 것이다.', true),
(10529, 3882, '(가)와 (나) 모두 컴파일은 통과하고 실행 중에 예외가 난다.', '제네릭도 배열처럼 공변이라고 본 오해. List<Integer>는 List<Number>의 하위 타입이 아니므로 (나)는 실행까지 가지 못하고 컴파일에서 막힌다.', false),
(10530, 3882, '(가)는 컴파일 오류이고, (나)는 실행 중 ArrayStoreException이 난다.', '배열과 제네릭의 성질을 서로 뒤바꿔 본 오해. ArrayStoreException은 배열에 원소를 저장할 때만 나는 예외이고, 불공변인 제네릭 대입은 애초에 컴파일을 통과하지 못한다.', false),

-- 문제 3883
(10531, 3883, '값을 꺼내 합계만 구하는 메서드는 매개변수를 List<? extends Number>로 선언하면 List<Integer>와 List<Double>을 모두 받을 수 있다.', '상한이 Number라 원소를 Number로 안전하게 꺼낼 수 있고, 불공변 때문에 막혔던 하위 타입 리스트도 받을 수 있다. 생산자에는 extends를 쓴다는 PECS의 앞부분이다.', false),
(10532, 3883, 'List<? super Integer>를 받은 메서드에서 꺼낸 원소는 Integer 변수에 바로 대입할 수 없다.', '하한만 정해져 있어 실제 원소 타입이 Integer일 수도, Number일 수도, Object일 수도 있다. 모든 경우에 안전한 공통 조상은 Object뿐이라 Object로 받아야 한다.', false),
(10533, 3883, 'List<? extends Number>로 선언한 매개변수에는 상한이 Number이므로 그 하위 타입인 Integer 값을 add로 넣을 수 있다.', '표에서 extends 쪽 넣기가 불가인 것과 정면으로 어긋난다. 실제 인자가 List<Double>일 수도 있어 Integer 삽입이 안전하다는 보장이 없으므로 컴파일러가 null 외의 삽입을 막는다.', true),
(10534, 3883, '한 매개변수로 읽기와 쓰기를 모두 해야 한다면 와일드카드 대신 타입 매개변수 <T>를 쓰는 편이 낫다.', '표의 세 형태는 모두 읽기와 쓰기 중 한쪽만 안전하다. 양쪽을 다 해야 하면 타입이 확정된 <T>로 선언해 컴파일러가 두 방향 모두 검사하게 만든다.', false),

-- 문제 3884
(10535, 3884, '생성자에서 Supplier<T>나 Class<T>를 받아 필드에 두고, create에서 그 값으로 인스턴스를 만든다.', '런타임에는 T가 무엇인지 남아 있지 않아 어떤 생성자를 부를지 정할 수 없다. 그래서 만드는 방법 자체를 밖에서 주입한다. new Repository<>(User::new)처럼 넘기면 실행 시점에도 정보가 살아 있다.', true),
(10536, 3884, '타입 매개변수를 <T extends Object>로 한정해 컴파일러가 T의 기본 생성자를 찾게 한다.', '한정을 붙여도 소거 후 타입은 Object 그대로라 달라지는 것이 없다. 한정은 T에 호출할 수 있는 메서드의 상한을 정할 뿐, 특정 생성자의 존재를 보장하지 못한다.', false),
(10537, 3884, 'create를 static으로 바꾸고 T 타입 필드도 static으로 선언해 인스턴스를 미리 만들어 둔다.', 'static 문맥에서는 타입 매개변수 T를 아예 쓸 수 없다. T는 인스턴스마다 다른데 static 멤버는 클래스당 하나뿐이라 어느 T인지 정할 수 없기 때문이다.', false),
(10538, 3884, '반환 타입을 T[]로 바꾸고 new T[1]을 만들어 첫 칸의 값을 돌려준다.', '제네릭 배열 생성도 같은 이유로 금지된다. 배열은 원소를 저장할 때 타입을 런타임에 검사하는데, 소거된 T로는 검사할 대상 자체가 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1250, 3885, '브리지 메서드,브리지메서드,브릿지 메서드,브릿지메서드,브리지 메소드,브릿지 메소드,bridge method,bridgemethod,bridge', '부모 Box<T>의 set은 소거되어 set(Object)가 되는데 자식은 set(String)으로 재정의했다. 시그니처가 달라 다형성이 끊기므로, 컴파일러가 set(Object) 형태의 메서드를 대신 만들어 인자를 (String)으로 형변환한 뒤 set(String)에 넘긴다. 리플렉션 목록에 synthetic=true로 하나 더 보이는 것이 이 메서드이고, raw 타입으로 set(42)를 호출했을 때 ClassCastException이 터지는 지점도 바로 그 형변환이다. 개발자가 직접 쓴 재정의(오버라이딩)나 오버로딩과 달리 소스에 존재하지 않고 컴파일러가 만들어 넣는다는 점이 구분 기준이다.'),
       (1251, 3886, '힙 오염,힙오염,heap pollution,heappollution,힙 폴루션,힙폴루션', '가변 인자 List<String>...은 내부적으로 배열을 만드는데, 제네릭 배열은 만들 수 없으므로 소거되어 사실상 Object[]가 된다. 배열은 공변이라 Object[]로 받아 다른 타입의 리스트를 끼워 넣어도 런타임 검사에 걸리지 않고, 그 결과 List<String>으로 선언된 자리에 List<Integer>가 들어앉는다. 이렇게 제네릭 선언과 실제로 담긴 객체의 타입이 어긋난 상태를 힙 오염이라 하며, raw 타입 혼용이나 unchecked 형변환에서도 생긴다. 가변 인자 배열에 아무것도 저장하지 않고 밖으로 내보내지도 않아 안전이 확인된 경우에만 @SafeVarargs로 경고를 억제하고, 이 애너테이션은 재정의될 수 없는 메서드(static, final, private, 생성자)에만 붙일 수 있다. 뒤이어 터지는 ClassCastException은 힙 오염의 결과일 뿐이며, 용어가 가리키는 것은 타입 정보가 어긋난 상태 자체다.');

-- =====================================================
-- Lesson 775: 소거 후 시그니처 충돌과 하한 와일드카드
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4829, 775, '아래 클래스에 함께 선언할 수 없는 메서드는?', '아래 Printer 클래스에는 메서드가 하나 선언되어 있다.

```java
class Printer {
    void print(List<String> items) {
        for (String s : items) System.out.println(s);
    }
}
```

여기에 메서드를 하나 더 추가하려 한다.', 'OBJECTIVE'),
       (4830, 775, '아래 실행 결과에서 알 수 있는 사실로 옳은 것은?', '```java
class StringBox extends ArrayList<String> { }

List<String> a = new ArrayList<>();
List<Integer> b = new ArrayList<>();

System.out.println(a.getClass() == b.getClass());
System.out.println(new StringBox().getClass().getGenericSuperclass());
```

출력

```
true
java.util.ArrayList<java.lang.String>
```', 'OBJECTIVE'),
       (4831, 775, '아래 비교표에서 따라 나오는 설명으로 옳지 않은 것은?', '배열과 제네릭 컬렉션의 성질을 정리한 표다.

| 구분 | 배열 | 제네릭 컬렉션 |
|---|---|---|
| 하위 타입 관계 | `Integer[]`는 `Number[]`의 하위 타입이다 | `List<Integer>`는 `List<Number>`의 하위 타입이 아니다 |
| 원소 타입을 검사하는 시점 | 원소를 저장할 때 실행 중에 검사 | 코드를 컴파일할 때 검사 |
| 실행 중 원소 타입 정보 | 그대로 유지된다 | 지워진다 |', 'OBJECTIVE'),
       (4832, 775, '아래 코드의 빈칸에 들어갈 매개변수 선언으로 옳은 것은?', '아래 유틸리티는 dst에 정수를 넣기만 하고 dst에서 값을 꺼내지는 않는다.

```java
static void fillWithIntegers(______ dst) {
    for (int i = 0; i < 3; i++) dst.add(i);
}
```

아래 세 호출이 모두 컴파일되어야 한다.

```java
fillWithIntegers(new ArrayList<Integer>());
fillWithIntegers(new ArrayList<Number>());
fillWithIntegers(new ArrayList<Object>());
```', 'OBJECTIVE'),
       (4833, 775, '아래에서 컴파일러가 제네릭 코드에 적용한 처리 방식을 가리키는 용어는?', '작성한 소스는 아래와 같다.

```java
class Box<T> {
    private T value;
    void set(T v) { this.value = v; }
    T get() { return value; }
}
```

컴파일한 클래스 파일을 열어 보면 이렇게 보인다.

```
$ javap Box.class
class Box {
  void set(java.lang.Object);
  java.lang.Object get();
}
```

또한 Box<String> box를 선언해 String s = box.get();을 쓴 호출부를 역어셈블하면, 소스에는 적지 않은 checkcast java/lang/String 명령이 get 호출 바로 뒤에 들어가 있다.', 'SUBJECTIVE'),
       (4834, 775, '아래 상황에서 listOf 선언부에 붙여야 할 애너테이션의 이름은?', '```java
static <T> List<T> listOf(T... items) {
    return new ArrayList<>(Arrays.asList(items));
}
```

이 메서드는 items 배열에 아무것도 저장하지 않고 배열 자체를 밖으로 돌려주지도 않는다. 그런데 빌드할 때마다 아래 경고가 쌓인다.

```
$ javac App.java
App.java:12: warning: [unchecked] Possible heap pollution from parameterized vararg type T
    static <T> List<T> listOf(T... items) {
                                  ^
```

호출부는 손대지 않고 선언부에 한 줄만 덧붙여 이 경고를 없애려 한다. JDK의 Arrays.asList와 List.of 선언부에도 같은 것이 붙어 있다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4829
(13051, 4829, '<T> void print(T[] items)', '타입 매개변수 T는 한정이 없어 Object로 지워지므로 이 메서드는 print(Object[])가 된다. 배열과 리스트는 애초에 다른 타입이라 기존 print(List)와 형태가 겹치지 않고 함께 선언된다.', false),
(13052, 4829, 'void print(List<Integer> items)', '컴파일 후에는 타입 인자가 지워져 두 메서드가 모두 print(List) 한 형태가 된다. 소스에서는 String과 Integer로 달라 보여도 클래스 파일에는 같은 시그니처를 두 개 둘 수 없어 선언 단계에서 막힌다.', true),
(13053, 4829, 'void print(Collection<String> items)', '지워지는 것은 타입 인자뿐이고 컨테이너 타입 자체는 남는다는 점을 놓친 오해. 소거 후에도 print(Collection)과 print(List)는 서로 다른 시그니처라 오버로딩이 성립한다.', false),
(13054, 4829, 'void print(List<String> items, int count)', '매개변수 개수가 다르면 타입 인자를 지워도 print(List)와 print(List, int)로 구분된다. 소거는 타입 인자만 건드리고 매개변수 목록의 길이는 바꾸지 않는다.', false),

-- 문제 4830
(13055, 4830, '첫 줄이 true이므로 타입 인자는 어디에 적었든 실행 중에 남지 않고, 둘째 줄은 클래스 이름을 문자열로 옮겨 적은 것일 뿐이다.', '소거를 완전한 삭제로 본 오해. 둘째 줄은 클래스 파일에 저장된 제네릭 시그니처를 읽어 온 결과다. 지워지는 것은 인스턴스와 지역 변수의 타입 인자이고, 선언부에 적은 타입 인자는 남는다.', false),
(13056, 4830, 'StringBox는 원소 타입이 실행 중에도 유지되므로, raw 타입 변수에 담아 정수를 add하면 저장하는 순간 예외가 난다.', '배열의 저장 시 검사와 혼동한 오개념. 리스트는 add 시점에 원소 타입을 확인하지 않아 정수가 그대로 들어가고, 문제는 String으로 꺼내는 자리에 컴파일러가 넣어 둔 형변환에서 드러난다.', false),
(13057, 4830, '두 리스트의 Class 객체가 같다는 것은 List<String> 변수에 List<Integer>를 그대로 대입해도 된다는 뜻이다.', '실행 중 타입이 같다는 사실과 컴파일 타임 대입 규칙을 뒤섞은 오해. 제네릭은 불공변이라 컴파일러가 대입을 막는다. 소거 탓에 실행 중 검사가 불가능하니 컴파일 단계에서 차단하는 것이다.', false),
(13058, 4830, 'StringBox처럼 상속 선언에 타입 인자를 고정해 두면, 익명 하위 클래스를 만드는 것만으로 실행 중에 원하는 타입 인자를 꺼내 쓸 수 있다.', '둘째 줄이 String까지 알려 준 것은 상속 선언의 타입 인자가 클래스 파일에 남기 때문이다. Jackson의 TypeReference<List<User>>() {}가 중괄호를 붙여 익명 하위 클래스를 만드는 이유가 바로 이것이다.', true),

-- 문제 4831
(13059, 4831, '제네릭 컬렉션도 원소를 넣는 순간 실제 타입을 확인하므로, 맞지 않는 값을 넣으면 그 자리에서 예외가 난다.', '표의 둘째와 셋째 행에 정면으로 어긋난다. 소거된 리스트는 실행 중 원소 타입을 모르므로 저장할 때 아무 검사도 하지 않고, 잘못 넣은 값은 꺼내 쓰는 자리의 형변환에서야 드러난다.', true),
(13060, 4831, 'Number[] 매개변수는 Integer[] 인자를 그대로 받지만, List<Number> 매개변수가 List<Integer> 인자를 받으려면 와일드카드가 필요하다.', '첫 행의 하위 타입 관계에서 바로 따라 나온다. 공변인 배열은 하위 타입 배열을 그대로 받고, 불공변인 제네릭은 List<? extends Number>처럼 상한을 열어 줘야 하위 타입 리스트를 받을 수 있다.', false),
(13061, 4831, 'new List<String>[3]이 막히는 것은 배열이 저장할 때 확인해야 할 원소 타입을 소거된 제네릭 쪽에서 얻을 수 없기 때문이다.', '둘째와 셋째 행을 합치면 나오는 결과다. 배열은 저장 시 원소 타입 검사를 전제로 동작하는데, List<String>은 실행 중 List로만 남아 검사할 기준 자체가 사라진다.', false),
(13062, 4831, '상위 타입 배열 변수로 접근하면 다른 하위 타입 원소를 넣는 코드도 컴파일을 통과하고, 문제는 실행 중에야 드러난다.', '첫 행과 둘째 행의 결과다. 공변이라 Number[] 변수에 Integer[]를 담을 수 있고 컴파일러는 Double 저장을 막지 못하므로, 저장 시점의 런타임 검사가 ArrayStoreException을 던진다.', false),

-- 문제 4832
(13063, 4832, 'List<Integer>', '제네릭은 불공변이라 List<Number>와 List<Object>는 List<Integer> 자리에 들어갈 수 없다. 본문의 세 호출 중 첫 줄만 통과하므로 조건을 만족하지 못한다.', false),
(13064, 4832, 'List<? extends Integer>', '상한만 정해져 실제 원소 타입이 무엇인지 알 수 없으므로 null 외에는 add가 막혀 본문의 dst.add(i)부터 컴파일되지 않는다. 값을 내주는 자리에 쓰는 형태를 받아들이는 자리에 잘못 가져온 것이다.', false),
(13065, 4832, 'List<? super Integer>', '하한이 Integer라 실제 타입이 무엇이든 Integer는 안전하게 담긴다. Integer, Number, Object 리스트가 모두 이 조건을 만족해 세 호출이 다 통과한다. 데이터를 받아들이는 매개변수에는 super를 쓴다.', true),
(13066, 4832, 'List<?>', '원소 타입을 전혀 모르는 형태라 크기 조회처럼 타입과 무관한 연산만 할 수 있고 null 외에는 add가 막힌다. 세 호출을 받기는 하지만 메서드 본문이 컴파일되지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1566, 4833, '타입 소거,타입소거,타입 이레이저,타입이레이저,type erasure,typeerasure,erasure,이레이저,소거', '컴파일러는 제네릭 코드의 타입을 먼저 검사한 뒤 타입 매개변수를 한정 타입으로 바꾼다. 한정이 없으면 Object, <T extends Comparable<T>>면 Comparable이 되므로 javap에는 set(Object)와 Object get()만 남는다. 대신 값을 꺼내 쓰는 자리마다 컴파일러가 checkcast, 즉 형변환을 끼워 넣어 주기 때문에 소스에서는 형변환이 보이지 않는다. 이렇게 한 까닭은 제네릭 도입 전에 컴파일된 코드와의 이진 호환을 지키기 위해서이고, 그 대가로 new T(), 제네릭 배열 생성, 매개변수화 타입의 instanceof가 막힌다. 타입 인자마다 코드를 새로 찍어 내는 C++ 템플릿의 실체화와는 반대 방식이다. 브리지 메서드나 힙 오염은 이 처리 때문에 생기는 결과이지 처리 방식의 이름이 아니라는 점, 그리고 지워지는 것은 인스턴스와 지역 변수의 타입 인자일 뿐 클래스 선언의 제네릭 시그니처는 클래스 파일에 남는다는 점을 함께 기억해 두면 좋다.'),
       (1567, 4834, '@SafeVarargs,SafeVarargs,세이프바라그스,세이프 바라그스,세이프배러그스', '가변 인자 T...는 내부적으로 배열을 만드는데 제네릭 배열은 만들 수 없어 사실상 Object[]로 소거된다. 그래서 컴파일러는 선언만 보고는 힙 오염 가능성을 배제하지 못하고 경고를 낸다. 배열에 아무것도 저장하지 않고 밖으로 내보내지도 않는다면 실제로는 안전하므로, 작성자가 그 사실을 보증하는 애너테이션을 선언부에 붙여 호출부까지 따라다니던 경고를 한 번에 없앤다. @SuppressWarnings("unchecked")는 붙인 자리에서만 경고를 가릴 뿐 호출부 경고는 그대로 남는다는 점이 다르다. 이 애너테이션은 재정의될 수 없는 메서드, 곧 static, final, private 메서드와 생성자에만 붙일 수 있다. 재정의가 가능하면 하위 클래스가 안전하지 않게 구현할 수 있어 보증이 깨지기 때문이다. 경고 문구에 등장하는 힙 오염은 제네릭 선언과 실제로 담긴 객체의 타입이 어긋난 상태 자체를 가리키는 별개의 용어다.');

-- =====================================================
-- Lesson 933: 제네릭과 타입 소거: 소거가 만든 제약과 우회 방법
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5777, 933, '아래 클래스를 컴파일했을 때 javap에 찍히는 best의 시그니처는?', '아래 Ranker는 원소를 서로 견주어 가장 큰 값을 돌려준다.

```java
class Ranker<T extends Comparable<T>> {
    T best(List<T> items) {
        T max = items.get(0);
        for (T t : items) {
            if (t.compareTo(max) > 0) max = t;
        }
        return max;
    }
}
```

컴파일한 Ranker.class를 javap로 열면 best가 한 줄로 찍힌다.', 'OBJECTIVE'),
       (5778, 933, '아래 호출이 컴파일되도록 copy 선언을 고치는 방법으로 옳은 것은?', 'copy는 src에서 값을 하나씩 읽어 dest의 같은 자리에 덮어쓴다.

```java
static <T> void copy(List<T> dest, List<T> src) {
    for (int i = 0; i < src.size(); i++) {
        dest.set(i, src.get(i));
    }
}

List<Number> dest = new ArrayList<>(List.of(0, 0, 0));
List<Integer> src = List.of(1, 2, 3);
copy(dest, src);
```

컴파일하면 마지막 줄에서 아래 오류가 난다.

```
error: method copy in class App cannot be applied to given types;
  required: List<T>,List<T>
  found:    List<Number>,List<Integer>
  reason: inference variable T has incompatible equality constraints Integer,Number
```', 'OBJECTIVE'),
       (5779, 933, '아래 표에서 따라 나오는 설명으로 옳은 것은?', '제네릭 코드 다섯 개를 각각 컴파일해 본 결과다.

| 코드 | 컴파일 결과 |
|---|---|
| `class Holder<T> { static T cache; }` | 오류 |
| `class Holder<T> { static <U> U wrap(U u) { return u; } }` | 통과 |
| `List<String>[] arr = new List<String>[3];` | 오류 |
| `List<?>[] arr = new List<?>[3];` | 통과 |
| `class MyException<T> extends Exception { }` | 오류 |', 'OBJECTIVE'),
       (5780, 933, '아래 코드의 실행 결과로 옳은 것은?', '```java
class Unsafe {
    @SuppressWarnings("unchecked")
    static <T> T cast(Object o) {
        return (T) o;                    // 4행
    }
}

Object boxed = 42;
Object any = Unsafe.cast(boxed);         // 9행
System.out.println("A");                 // 10행
String s = Unsafe.cast(boxed);           // 11행
System.out.println("B");                 // 12행
```

4행에는 unchecked 경고가 붙지만 @SuppressWarnings로 가려 두었고, 전체는 오류 없이 컴파일된다.', 'OBJECTIVE'),
       (5781, 933, '아래 호출이 막히는 까닭이 되는, 제네릭 타입이 지닌 성질을 가리키는 용어는?', '```java
static double sum(List<Number> nums) {
    double total = 0;
    for (Number n : nums) total += n.doubleValue();
    return total;
}

List<Integer> scores = List.of(90, 80, 70);
double s = sum(scores);
```

```
error: incompatible types: List<Integer> cannot be converted to List<Number>
```

Integer는 Number를 상속하고 sum은 원소를 꺼내 읽기만 하는데도 호출이 막힌다. 매개변수와 인자를 `Number[]`와 `Integer[]`로 바꿔 적으면 같은 모양의 호출이 그대로 컴파일된다.', 'SUBJECTIVE'),
       (5782, 933, '아래 측정 결과의 차이를 낳은, 리스트 쪽에서만 더 일어나는 동작의 이름은?', '같은 1,000만 개의 정수를 배열과 리스트에 각각 채웠다. 리스트도 `List<int>`로 선언하려 했으나 컴파일되지 않아 `List<Integer>`로 바꿨다.

```java
int[] arr = new int[10_000_000];
for (int i = 0; i < arr.length; i++) arr[i] = i;

List<Integer> list = new ArrayList<>(10_000_000);
for (int i = 0; i < 10_000_000; i++) list.add(i);
```

측정 결과

```
int[]          : 소요 12ms,  힙 사용 40MB
List<Integer>  : 소요 320ms, 힙 사용 216MB
```

힙 덤프를 열어 보면 리스트 쪽에만 java.lang.Integer 인스턴스가 1,000만 개 가까이 잡혀 있다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5777
(15579, 5777, 'java.lang.Object best(java.util.List)', '한정이 붙지 않은 타입 매개변수를 지웠을 때의 결과다. Object까지 내려가면 본문에서 부르는 compareTo를 찾을 수 없어 컴파일 자체가 성립하지 않는다.', false),
(15580, 5777, 'java.lang.Comparable best(java.util.List)', '소거는 타입 매개변수를 첫 한정 타입으로 바꾸므로 T 자리가 Comparable이 되고, 매개변수에서는 타입 인자만 지워져 List가 남는다. 한정 덕분에 compareTo를 부를 수 있는 형태로 지워진다.', true),
(15581, 5777, 'java.lang.Comparable best(java.util.List<java.lang.Comparable>)', '한정 타입을 타입 인자 자리에 대신 채워 넣는다고 본 오해. 소거는 컨테이너 타입은 남기고 타입 인자는 통째로 지우므로 매개변수는 List 하나로 남는다.', false),
(15582, 5777, 'T best(java.util.List<T>)', '소스에 적은 모양이 그대로 남는다고 본 오해. 실행 시점에는 T가 무엇인지 알 수 없으므로 타입 매개변수가 살아 있는 시그니처는 만들어지지 않는다.', false),

-- 문제 5778
(15583, 5778, 'static <T> void copy(List<? super T> dest, List<? extends T> src)', '값을 받아들이는 dest에는 super, 값을 내주는 src에는 extends를 붙인다. T가 Integer로 정해지면 List<Number>는 Integer를 담을 수 있는 리스트라는 조건을, List<Integer>는 원소를 Integer로 읽을 수 있다는 조건을 만족하므로 호출과 메서드 본문이 모두 통과한다.', true),
(15584, 5778, 'static <T> void copy(List<? extends T> dest, List<? super T> src)', '값을 주고받는 방향을 뒤바꿔 본 것. extends로 열어 둔 dest는 실제 원소 타입을 알 수 없어 null 외에는 넣을 수 없으므로 dest.set부터 컴파일되지 않는다.', false),
(15585, 5778, 'static void copy(List<Object> dest, List<Object> src)', 'Object가 모든 타입의 상위 타입이니 List<Object>도 모든 리스트를 받는다고 본 오해. 제네릭은 불공변이라 List<Number>도 List<Integer>도 이 자리에 들어가지 못해 오류 문구만 바뀐다.', false),
(15586, 5778, 'static void copy(List<?> dest, List<?> src)', '호출부는 통과하지만 dest의 원소 타입을 전혀 모르는 형태라 넣을 값의 안전을 보증할 수 없다. null 외의 삽입이 막혀 이번에는 메서드 본문이 컴파일되지 않는다.', false),

-- 문제 5779
(15587, 5779, '첫 행이 막히는 것은 소거가 static 영역을 건드리지 않기 때문이고, 둘째 행이 통과하는 것은 U가 소거 대상이 아니기 때문이다.', '소거는 static 여부와 무관하게 적용된다. 첫 행이 막히는 까닭은 T가 인스턴스마다 정해지는데 static 멤버는 클래스당 하나뿐이라 어느 T인지 고를 수 없어서고, 둘째 행의 U는 호출할 때마다 정해지는 메서드 자신의 타입 매개변수라 문제가 없다.', false),
(15588, 5779, '다섯째 행이 막히는 것은 Exception이 이미 제네릭 클래스여서 타입 매개변수를 다시 붙일 수 없기 때문이다.', 'Exception은 제네릭 클래스가 아니다. catch 절은 던져진 객체의 타입을 실행 중에 확인해 잡을 자리를 고르는데, 소거된 MyException<T>는 어느 T인지 구분할 수 없어 선언 단계에서 미리 막는다.', false),
(15589, 5779, '넷째 행이 통과하는 것은 List<?>가 실행 중에도 원소 타입을 지니고 있어 배열이 저장할 값을 검사할 수 있기 때문이다.', '통과하는 까닭은 타입 정보가 남아서가 아니라 확인할 타입 인자가 아예 없어 배열의 원소 타입이 List 하나로 확정되기 때문이다. 배열은 들어오는 값이 List인지까지만 보고 그 안의 타입 인자는 보지 못한다.', false),
(15590, 5779, '셋째 행이 필요하면 넷째 행처럼 만든 다음 List<String>[]로 형변환해야 하고, 그 형변환에는 unchecked 경고가 붙는다.', '배열은 원소를 저장할 때 원소 타입을 실행 중에 확인하는데 List<String>은 List로 지워져 확인할 기준이 없다. 그래서 타입 인자를 적지 않은 넷째 행 형태로만 만들 수 있고, 되돌리는 형변환은 컴파일러가 안전을 보증하지 못해 경고를 남긴다.', true),

-- 문제 5780
(15591, 5780, '4행의 형변환에서 ClassCastException이 나고 A도 출력되지 않는다.', '소스에 적은 (T)는 소거되어 사실상 (Object) 검사만 남으므로 메서드 안에서는 어떤 값을 넣어도 통과한다. 실제로 타입을 확인하는 형변환은 반환값을 받는 호출부에 들어간다.', false),
(15592, 5780, 'A와 B가 모두 출력되고 예외 없이 끝난다.', '@SuppressWarnings가 검사까지 없애 준다고 본 오해. 이 애너테이션은 경고 출력만 가릴 뿐 컴파일러가 끼워 넣는 형변환을 지우지 않으므로 11행의 검사는 그대로 남는다.', false),
(15593, 5780, 'A가 출력된 뒤 11행에서 ClassCastException이 난다.', '반환값을 받는 변수의 타입이 T를 정한다. 9행은 Object로 받아 형변환이 삽입될 이유가 없고, 11행은 T가 String으로 정해져 호출 뒤에 String 검사가 들어간다. 실제 값은 Integer 42라 그 자리에서 터진다.', true),
(15594, 5780, '9행에서 ClassCastException이 나고 A와 B 모두 출력되지 않는다.', '제네릭 메서드가 호출될 때마다 무조건 검사가 붙는다고 본 오해. 9행은 결과를 Object 변수에 담아 T가 Object로 정해지므로 확인할 것이 없어 그대로 지나간다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1882, 5781, '불공변,불공변성,무공변,무공변성,비공변,비공변성,invariant,invariance', 'Integer가 Number의 하위 타입이어도 List<Integer>는 List<Number>의 하위 타입이 아니다. 원소 타입 사이의 상하 관계가 컨테이너 타입 사이로 이어지지 않는 이 성질이 불공변이다. 배열은 반대로 공변이라 Integer[]를 Number[] 자리에 넘길 수 있고, 대신 엉뚱한 값을 저장하는 순간 실행 중 검사에 걸려 ArrayStoreException이 난다. 제네릭이 불공변을 택한 까닭은 소거 때문에 실행 중에는 원소 타입을 확인할 방법이 없어 잘못된 삽입을 컴파일 단계에서 아예 차단해야 하기 때문이다. 읽기만 하는 이번 sum처럼 안전한 경우까지 막히는 것이 불편해 와일드카드가 필요해지며, List<? extends Number>로 선언하면 같은 호출이 통과한다. 와일드카드는 불공변을 없애는 장치가 아니라 읽기나 쓰기 중 한 방향으로만 열어 주는 장치라는 점, 그리고 공변인 배열은 검사 시점이 실행 중이라 오류가 늦게 드러난다는 점을 함께 기억해 두면 좋다.'),
       (1883, 5782, '오토박싱,오토 박싱,자동 박싱,자동박싱,박싱,autoboxing,auto boxing,auto-boxing,boxing', '타입 인자 자리에는 기본 타입을 적을 수 없다. 소거 후 타입 매개변수는 Object 같은 참조 타입으로 바뀌어야 하는데 int는 Object의 하위 타입이 아니기 때문이다. 그래서 List<Integer>로 선언하게 되고, list.add(i)마다 int 값이 Integer 객체로 감싸진다. 이때 자동으로 일어나는 이 감싸기가 오토박싱이다. 값 하나가 객체 헤더를 가진 인스턴스가 되고 리스트 내부 배열은 그 객체를 가리키는 참조를 담으므로 메모리가 몇 배로 늘고, 객체를 1,000만 개 만들고 회수하는 비용이 시간 차이로 나타난다. -128부터 127까지는 미리 만들어 둔 인스턴스를 재사용하므로 작은 값만 다루면 차이가 잘 드러나지 않는다. 반대로 꺼낸 값을 int 변수에 담을 때 Integer를 int로 되돌리는 것은 언박싱이고, 이때 값이 null이면 NullPointerException이 난다. 컴파일러가 꺼내는 자리에 넣어 주는 형변환(타입 소거의 결과)이나 선언과 실제 타입이 어긋나는 힙 오염과는 다른, 값 표현을 바꾸는 별개의 동작이다.');
