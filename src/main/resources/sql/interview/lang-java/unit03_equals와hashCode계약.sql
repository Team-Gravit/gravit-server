-- Unit: equals와 hashCode 계약 (Unit ID: 188)
-- Chapter: Java (Chapter ID: 18)
-- Topic: JAVA
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-java-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(936, 'JAVA', 188, 'HARD', true,
 'hashCode에 쓰이는 필드를 가진 가변 객체를 HashSet에 넣은 뒤 그 필드 값을 변경하면 어떤 문제가 생기는지, 그리고 이를 막으려면 키 클래스를 어떻게 설계해야 하는지 설명해 주세요.',
 'HashSet은 원소를 넣을 때 hashCode로 버킷 위치를 정하고, 조회할 때도 hashCode로 버킷을 찾은 뒤 equals로 같은 원소인지 확인합니다. 그런데 hashCode에 쓰이는 필드가 컬렉션에 넣은 뒤 변경되면, 객체는 예전 해시로 계산된 버킷에 그대로 남아 있지만 contains를 호출하면 새 해시 값으로 다른 버킷을 찾게 되어 false가 반환됩니다. remove도 같은 이유로 해당 객체를 찾지 못해 제거되지 않으므로 사실상 누수가 됩니다. 그래서 Map의 키나 Set의 원소로 쓰는 클래스는 불변으로 설계해야 하며, String, 래퍼 타입, record가 키로 안전한 이유도 불변이기 때문입니다. 어쩔 수 없이 가변 객체를 써야 한다면 hashCode에는 변하지 않는 식별자 필드만 사용해야 합니다. JPA 엔티티는 DB 식별자가 영속화 이전에 null이므로 비즈니스 키를 쓰거나 id가 있을 때만 비교하는 등 별도 전략이 필요합니다.',
 'interview-question/936.mp3'),
(937, 'JAVA', 188, 'NORMAL', true,
 'Java에서 == 연산자와 equals() 메서드의 차이는 무엇인가요?',
 '==는 동일성 비교로, 두 변수가 같은 객체, 즉 같은 참조를 가리키는지를 봅니다. 반면 equals()는 동치성 비교로, 두 객체가 논리적으로 같은 값인지를 봅니다. 예를 들어 new String("java")로 만든 두 문자열은 서로 다른 객체이므로 ==는 false지만 내용이 같으므로 equals()는 true입니다. 다만 Object의 기본 equals()는 this == obj로 구현되어 있어서 재정의하지 않으면 동일성 비교와 같으므로, 값 객체나 DTO처럼 값을 표현하는 클래스는 equals()를 재정의해야 합니다. 참고로 Integer를 ==로 비교하면 Integer 캐시 때문에 -128~127 범위에서는 true, 그 밖에서는 false가 나오므로 오토박싱된 래퍼 타입은 항상 equals()로 비교해야 합니다.',
 'interview-question/937.mp3'),
(938, 'JAVA', 188, 'NORMAL', true,
 'equals()만 재정의하고 hashCode()는 재정의하지 않은 클래스를 HashSet에 사용하면 어떤 문제가 생기는지, 두 메서드를 반드시 함께 재정의해야 하는 이유와 함께 설명해 주세요.',
 'hashCode 규약에는 x.equals(y)가 true면 반드시 x.hashCode()와 y.hashCode()가 같아야 한다는 조건이 있습니다. HashMap이나 HashSet 같은 해시 컬렉션은 먼저 hashCode로 버킷 인덱스를 계산해 어느 칸을 볼지 정하고, 그 버킷 안의 엔트리를 순회하며 equals로 진짜 같은 키인지 확정하기 때문입니다. equals만 재정의하고 hashCode를 재정의하지 않으면 Object의 주소 기반 해시가 사용되어, 논리적으로 같은 두 객체가 서로 다른 해시 코드를 내고 다른 버킷에 들어갑니다. 그러면 equals는 호출조차 되지 않아서 같은 값의 Coord(1, 2)를 두 번 add하면 size가 2가 되고, 새 Coord(1, 2)로 contains를 호출해도 false가 나옵니다. 이 코드는 컴파일도 되고 예외도 없이 조용히 틀린 결과를 내므로 두 메서드는 항상 함께 재정의해야 합니다. 반대로 hashCode가 같아도 equals는 다를 수 있는데, 해시 충돌은 규약상 허용되기 때문입니다.',
 'interview-question/938.mp3'),
(939, 'JAVA', 188, 'EASY', true,
 'equals()를 재정의할 때 지켜야 하는 규약에는 어떤 것들이 있는지 설명해 주세요.',
 'Object.equals()의 Javadoc은 null이 아닌 모든 참조 x, y, z에 대해 다섯 가지 규약을 요구합니다. 반사성은 x.equals(x)가 true여야 한다는 것이고, 대칭성은 x.equals(y)가 true면 y.equals(x)도 true여야 한다는 것입니다. 추이성은 x.equals(y)와 y.equals(z)가 true면 x.equals(z)도 true여야 한다는 것이고, 일관성은 비교에 쓰이는 정보가 바뀌지 않는 한 결과가 항상 같아야 한다는 것입니다. 마지막으로 x.equals(null)은 예외를 던지지 않고 false를 반환해야 합니다. 추이성은 상속 계층에서 흔히 깨지는데, Point를 상속한 ColorPoint가 색 필드를 추가하고 equals를 재정의하면 둘을 섞어 비교할 때 추이성이 깨집니다. 구체 클래스를 상속해 값 필드를 추가하면서 규약을 완벽히 지킬 방법은 없으므로 상속 대신 컴포지션을 쓰거나 값 클래스를 final로 만듭니다.',
 'interview-question/939.mp3'),
(940, 'JAVA', 188, 'EASY', true,
 'equals()와 hashCode()를 올바르게 재정의하는 방법을 설명해 주세요.',
 '직접 구현할 때는 먼저 equals의 매개변수 타입을 반드시 Object로 선언해야 합니다. equals(Coord o)처럼 쓰면 오버라이딩이 아니라 오버로딩이 되어 컬렉션에서 호출되지 않으며, @Override를 붙이면 컴파일러가 이 실수를 잡아 줍니다. equals 본문은 동일 참조면 즉시 true를 반환하고, instanceof 패턴 매칭으로 타입 검사와 null 처리를 한 뒤 핵심 필드를 비교하는 순서로 작성합니다. hashCode는 equals에서 비교한 필드와 동일한 필드만 사용해 Objects.hash(x, y)처럼 계산해야 equals가 같으면 hashCode도 같다는 규약이 지켜집니다. 부동소수점 필드는 Double.compare(), 배열 필드는 Arrays.equals()와 Arrays.hashCode()로 비교합니다. 또한 Java 16 이후에는 record를 쓰면 모든 컴포넌트를 기준으로 equals, hashCode, toString을 컴파일러가 자동 생성하므로 규약 위반 위험이 사라져 값 객체에 가장 안전합니다.',
 'interview-question/940.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 936
(5049, 936, '필드 변경 후 새 해시 값으로 다른 버킷을 찾게 되어 contains가 false를 반환함을 설명', 'ESSENTIAL', 1),
(5050, 936, '객체가 예전 해시로 계산된 버킷에 남아 remove로도 제거되지 않음을 언급', 'ESSENTIAL', 2),
(5051, 936, 'Map의 키·Set의 원소로 쓰는 클래스는 불변으로 설계해야 함을 언급', 'ESSENTIAL', 3),
(5052, 936, '가변 객체를 써야 한다면 hashCode에 변하지 않는 식별자 필드만 사용함을 제시', 'SUPPLEMENTARY', 4),
(5053, 936, 'String·래퍼 타입·record가 불변이라 키로 안전함을 언급', 'SUPPLEMENTARY', 5),
(5054, 936, 'JPA 엔티티는 영속화 이전 식별자가 null이라 별도 전략이 필요함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 937
(5055, 937, '==는 두 변수가 같은 객체(같은 참조)를 가리키는지 보는 동일성 판단임을 설명', 'ESSENTIAL', 1),
(5056, 937, 'equals()는 두 객체가 논리적으로 같은지 보는 동치성 판단임을 설명', 'ESSENTIAL', 2),
(5057, 937, 'Object의 기본 equals()가 this == obj로 구현되어 재정의하지 않으면 동일성과 같음을 언급', 'ESSENTIAL', 3),
(5058, 937, 'Integer 캐시 때문에 -128~127 범위에서만 ==가 true가 됨을 언급', 'SUPPLEMENTARY', 4),
(5059, 937, '오토박싱된 래퍼 타입에는 == 대신 equals()를 써야 함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 938
(5060, 938, 'equals가 true인 두 객체는 반드시 hashCode가 같아야 한다는 규약을 명시', 'ESSENTIAL', 1),
(5061, 938, '해시 컬렉션이 hashCode로 버킷을 찾은 뒤 equals로 같은 키를 확정하는 과정을 설명', 'ESSENTIAL', 2),
(5062, 938, '논리적으로 같은 객체가 다른 버킷에 들어가 HashSet에 중복 저장되거나 조회되지 않음을 설명', 'ESSENTIAL', 3),
(5063, 938, 'hashCode 미재정의 시 Object의 주소 기반 해시가 사용됨을 언급', 'SUPPLEMENTARY', 4),
(5064, 938, 'hashCode가 같아도 equals는 다를 수 있음(해시 충돌 허용)을 언급', 'SUPPLEMENTARY', 5),
(5065, 938, '컴파일 오류나 예외 없이 조용히 틀린 결과가 나옴을 언급', 'SUPPLEMENTARY', 6),

-- 질문 939
(5066, 939, '반사성·대칭성·추이성·일관성·null 처리 중 최소 3개를 규약 이름으로 제시', 'ESSENTIAL', 1),
(5067, 939, '대칭성·추이성 중 최소 1개의 조건을 x·y(·z) 간 equals 결과 관계로 설명', 'ESSENTIAL', 2),
(5068, 939, 'x.equals(null)은 예외를 던지지 않고 false를 반환해야 함을 언급', 'SUPPLEMENTARY', 3),
(5069, 939, '구체 클래스를 상속해 값 필드를 추가하면 추이성이 깨짐을 언급', 'SUPPLEMENTARY', 4),
(5070, 939, '상속 대신 컴포지션을 쓰거나 값 클래스를 final로 만드는 대안을 제시', 'SUPPLEMENTARY', 5),

-- 질문 940
(5071, 940, 'equals의 매개변수 타입을 반드시 Object로 선언해야 함을 명시', 'ESSENTIAL', 1),
(5072, 940, 'equals 구현에서 instanceof 검사가 타입 검사와 null 처리를 함께 수행함을 언급', 'ESSENTIAL', 2),
(5073, 940, 'equals에 쓴 필드와 동일한 필드만 hashCode 계산에 사용해야 함을 언급', 'ESSENTIAL', 3),
(5074, 940, 'Object가 아닌 매개변수로 쓰면 오버로딩이 되어 컬렉션에서 호출되지 않음을 언급', 'SUPPLEMENTARY', 4),
(5075, 940, '@Override를 붙이면 컴파일러가 오버로딩 실수를 잡아 줌을 언급', 'SUPPLEMENTARY', 5),
(5076, 940, 'record가 모든 컴포넌트를 기준으로 equals·hashCode를 자동 생성함을 언급', 'SUPPLEMENTARY', 6);
