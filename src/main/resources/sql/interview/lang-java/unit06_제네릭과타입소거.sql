-- Unit: 제네릭과 타입 소거 (Unit ID: 191)
-- Chapter: Java (Chapter ID: 18)
-- Topic: JAVA
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-java-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(951, 'JAVA', 191, 'HARD', true,
 '제네릭 클래스 안에서 `new T()`로 객체를 생성하려고 하면 컴파일 오류가 납니다. 그 원인을 Java 제네릭의 구현 방식과 연결해 설명하고, 이 제약을 우회하는 방법과 같은 원인에서 비롯되는 다른 제약도 함께 말씀해 주시겠어요?',
 'Java 제네릭은 하위 호환을 위해 타입 소거 방식으로 구현되어 있습니다. 컴파일러는 타입을 검사한 뒤 바이트코드에서 타입 매개변수를 한정 타입, 한정이 없으면 Object로 바꾸고 필요한 곳에 형변환을 삽입하기 때문에 런타임에는 타입 인자 정보가 사라집니다. 그래서 런타임에 T의 실제 타입을 알 수 없으므로 new T()나 new T[10]처럼 타입 매개변수로 인스턴스를 만들 수 없습니다. 우회하려면 Class<T> 같은 타입 토큰이나 Supplier<T> 팩토리를 생성자로 주입받아 factory.get()으로 생성하면 됩니다. 예를 들어 new Repository<>(User::new)처럼 넘깁니다. 같은 원인으로 obj instanceof List<String>처럼 매개변수화 타입에 instanceof를 쓸 수 없어 List<?>만 가능하고, 배열은 런타임 타입 검사를 하는데 소거로 불가하므로 new List<String>[3] 같은 제네릭 배열도 만들 수 없습니다. 또 소거 후 Object여야 하므로 List<int>처럼 기본 타입을 타입 인자로 쓸 수 없어 List<Integer>를 쓰고 박싱 비용을 감수해야 합니다. 다만 소거는 완전한 삭제가 아니어서 클래스·필드·메서드 선언의 제네릭 시그니처는 클래스 파일의 Signature 속성에 남아 리플렉션으로 읽을 수 있고, Jackson의 TypeReference처럼 익명 하위 클래스를 만들어 부모의 타입 인자를 읽어 내는 슈퍼 타입 토큰 기법이 이 덕분에 동작합니다.'),
(952, 'JAVA', 191, 'NORMAL', true,
 '배열과 제네릭 타입은 원소 타입 간 상속 관계가 있을 때 서로 다르게 동작합니다. 두 방식의 차이와, 제네릭이 그렇게 설계된 이유를 설명해 주세요.',
 'Integer가 Number의 하위 타입일 때 배열은 Integer[]가 Number[]의 하위 타입이 되는 공변이지만, 제네릭은 List<Integer>가 List<Number>의 하위 타입이 아닌 불공변입니다. 그래서 Number[] nums = new Integer[2]는 허용되고 nums[0] = 3.14도 컴파일은 통과하지만, 배열은 런타임에 타입을 검사하기 때문에 실행 중 ArrayStoreException이 발생합니다. 반면 List<Number> list = new ArrayList<Integer>()는 컴파일 오류로 막혀, 제네릭은 잘못된 대입을 컴파일 타임에 차단합니다. 제네릭이 불공변인 이유는 타입 소거 때문에 소거 후에는 배열처럼 런타임 타입 검사를 할 수 없으므로, 잘못된 삽입을 컴파일 타임에 원천 차단해야 하기 때문입니다. 다만 불공변만으로는 Number의 모든 하위 타입 리스트를 받는 메서드를 만들 수 없어서 와일드카드가 필요해집니다.'),
(953, 'JAVA', 191, 'NORMAL', true,
 '`List<? extends T>`와 `List<? super T>`는 어떤 차이가 있고, 메서드 매개변수에 각각 언제 사용하는지 설명해 주세요.',
 'List<? extends T>는 T 또는 T의 하위 타입 리스트를 뜻해서, 꺼낸 요소를 T로 안전하게 읽을 수 있지만 실제 타입을 모르므로 요소를 추가할 수는 없습니다. List<? super T>는 T 또는 T의 상위 타입 리스트라서 T와 그 하위 타입 값을 안전하게 넣을 수 있지만, 꺼낸 값은 Object로만 받을 수 있습니다. 그래서 PECS, 즉 Producer-Extends, Consumer-Super 원칙에 따라 매개변수가 데이터를 내주는 생산자면 extends를, 데이터를 받아들이는 소비자면 super를 씁니다. 예를 들어 합계를 구하는 sum(List<? extends Number>)는 List<Integer>도 받아 Number로 읽을 수 있고, fill(List<? super Integer>)는 ArrayList<Number>나 ArrayList<Object>에 Integer를 넣을 수 있습니다. JDK의 Collections.copy(List<? super T> dest, List<? extends T> src)가 교과서적 예시이고, 읽기와 쓰기를 모두 해야 한다면 와일드카드 대신 타입 매개변수 <T>를 사용합니다.'),
(954, 'JAVA', 191, 'EASY', true,
 'Java 제네릭의 타입 소거란 무엇이며, 컴파일러가 제네릭 코드를 바이트코드로 만들 때 어떤 처리를 하는지 설명해 주세요.',
 '타입 소거는 Java 제네릭의 구현 방식으로, 컴파일러가 제네릭 코드의 타입을 검사한 뒤 바이트코드에서는 타입 정보를 지워 런타임에는 타입 인자 정보가 사라지게 하는 것입니다. 구체적으로 타입 매개변수를 한정 타입으로 바꾸는데, 한정이 없으면 Object로, <T extends Comparable<T>>처럼 한정이 있으면 Comparable로 바뀝니다. 그리고 box.get()처럼 값을 꺼내는 곳에는 (String) 같은 형변환을 컴파일러가 삽입합니다. 이렇게 한 이유는 제네릭 도입 전에 컴파일된 라이브러리와 이진 호환을 유지하기 위해서이고, 타입 인자마다 클래스를 새로 만들지 않아 클래스 수도 늘지 않습니다. 그 결과 List<String>, List<Integer>, List<User>는 런타임에 하나의 List 클래스로 완전히 같은 타입이 됩니다.'),
(955, 'JAVA', 191, 'EASY', true,
 '제네릭이 없던 시절의 raw 타입 컬렉션과 비교해, 제네릭을 사용하면 어떤 이점이 있는지 설명해 주세요.',
 'Java 5 이전의 raw 타입 컬렉션은 Object를 담았기 때문에 꺼낼 때마다 형변환이 필요했고, 잘못된 타입을 넣어도 아무 경고 없이 들어가 런타임에야 ClassCastException으로 드러났습니다. 제네릭은 클래스나 메서드가 다룰 타입을 매개변수화해서 컴파일 시점에 타입 안전성을 검사하므로, List<String>에 42를 넣으면 작성 시점에 컴파일 오류가 납니다. 즉 오류 발견 시점을 런타임에서 컴파일 타임으로 앞당기는 것이 본질적인 가치입니다. 또 names.get(0)처럼 값을 꺼낼 때 형변환이 필요 없어집니다. raw 타입은 제네릭 이전 코드와의 호환을 위해 남아 있을 뿐이라 새 코드에서는 쓰면 안 됩니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 951
(5135, 951, '제네릭이 타입 소거 방식으로 구현되어 런타임에 타입 인자 정보가 사라짐을 언급', 'ESSENTIAL', 1),
(5136, 951, '런타임에 T의 실제 타입을 알 수 없어 new T()가 불가하다는 인과를 설명', 'ESSENTIAL', 2),
(5137, 951, 'Class<T> 타입 토큰 또는 Supplier<T> 팩토리를 주입받아 생성하는 우회법을 제시', 'ESSENTIAL', 3),
(5138, 951, 'instanceof List<String>·제네릭 배열·List<int> 등 소거로 인한 다른 제약을 최소 1개 제시', 'ESSENTIAL', 4),
(5139, 951, '기본 타입 대신 List<Integer>를 쓰면 박싱 비용이 발생함을 언급', 'SUPPLEMENTARY', 5),
(5140, 951, '선언부의 제네릭 시그니처는 Signature 속성에 남아 리플렉션으로 읽을 수 있음을 언급', 'SUPPLEMENTARY', 6),
(5141, 951, '익명 하위 클래스로 부모의 타입 인자를 읽는 슈퍼 타입 토큰 기법을 제시', 'SUPPLEMENTARY', 7),

-- 질문 952
(5142, 952, '배열은 공변, 제네릭은 불공변(List<Integer>는 List<Number>의 하위 타입이 아님)임을 설명', 'ESSENTIAL', 1),
(5143, 952, '배열에 잘못된 타입을 넣으면 런타임에 ArrayStoreException이 발생함을 언급', 'ESSENTIAL', 2),
(5144, 952, '제네릭은 잘못된 대입을 컴파일 타임에 오류로 차단함을 언급', 'ESSENTIAL', 3),
(5145, 952, '제네릭이 불공변인 이유가 소거로 런타임 타입 검사가 불가하기 때문임을 설명', 'ESSENTIAL', 4),
(5146, 952, '불공변 때문에 하위 타입 리스트를 받으려면 와일드카드가 필요함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 953
(5147, 953, '? extends T는 T로 안전하게 읽을 수 있지만 요소를 추가할 수는 없음을 언급', 'ESSENTIAL', 1),
(5148, 953, '? super T에는 T 및 그 하위 타입 값을 안전하게 넣을 수 있음을 언급', 'ESSENTIAL', 2),
(5149, 953, '데이터를 내주는 생산자는 extends, 받아들이는 소비자는 super를 쓰는 PECS 원칙을 설명', 'ESSENTIAL', 3),
(5150, 953, '? super T에서 꺼낸 값은 Object로만 받을 수 있음을 언급', 'SUPPLEMENTARY', 4),
(5151, 953, '읽기와 쓰기를 모두 해야 하면 와일드카드 대신 타입 매개변수 <T>를 쓴다고 언급', 'SUPPLEMENTARY', 5),
(5152, 953, 'Collections.copy의 dest·src 시그니처를 PECS의 예시로 제시', 'SUPPLEMENTARY', 6),

-- 질문 954
(5153, 954, '컴파일 후 런타임에는 제네릭 타입 인자 정보가 사라진다는 점을 언급', 'ESSENTIAL', 1),
(5154, 954, '타입 매개변수가 한정 타입으로, 한정이 없으면 Object로 대체됨을 설명', 'ESSENTIAL', 2),
(5155, 954, '값을 꺼내는 곳에 컴파일러가 형변환을 삽입함을 언급', 'ESSENTIAL', 3),
(5156, 954, '소거 방식을 택한 이유가 제네릭 이전 라이브러리와의 하위(이진) 호환임을 언급', 'SUPPLEMENTARY', 4),
(5157, 954, 'List<String>과 List<Integer>가 런타임에 하나의 클래스로 같은 타입임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 955
(5158, 955, '잘못된 타입 오류를 런타임이 아닌 컴파일 시점에 발견하게 해 준다는 점을 언급', 'ESSENTIAL', 1),
(5159, 955, '컬렉션에서 값을 꺼낼 때 형변환이 필요 없어진다는 점을 언급', 'ESSENTIAL', 2),
(5160, 955, 'raw 타입 컬렉션은 Object를 담아 잘못된 타입이 ClassCastException으로 드러남을 언급', 'SUPPLEMENTARY', 3),
(5161, 955, 'raw 타입은 하위 호환용으로만 남아 새 코드에서는 쓰지 않아야 함을 언급', 'SUPPLEMENTARY', 4);
