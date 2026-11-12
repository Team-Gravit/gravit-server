-- Unit: 가시성과 불변성 (Unit ID: 203)
-- Chapter: Kotlin (Chapter ID: 19)
-- Topic: KOTLIN
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-kotlin-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1011, 'KOTLIN', 203, 'HARD', true,
 '클래스 내부의 가변 리스트를 외부에 List 타입으로 노출하려고 합니다. 내부 MutableList를 그대로 반환하면 어떤 문제가 생기고, 대안으로 어떤 방법을 선택할 수 있으며 각각의 비용은 무엇인가요?',
 'private val _items = mutableListOf<Item>()를 두고 val items: List<Item> get() = _items처럼 같은 객체를 반환하면, List는 변경 메서드가 없는 인터페이스일 뿐 런타임 객체는 같은 가변 리스트이므로 내부 변경이 읽기 전용 참조에도 그대로 관찰되고, 외부에서 MutableList로 다운캐스트해 변경할 수도 있습니다. 첫 번째 대안은 _items.toList()로 방어적 복사를 해 스냅샷을 돌려주는 것입니다. toList()는 항상 새 컬렉션을 생성하므로 원본과의 연결이 끊기지만, 호출마다 O(n) 복사 비용이 듭니다. 두 번째 대안은 var items: List<Item>에 private set을 두고 add 시 items + item으로 새 리스트로 교체해 상태 자체를 불변으로 유지하는 방식입니다. 세 번째로 kotlinx.collections.immutable의 PersistentList를 쓰면 구현체 자체가 불변이고, add·remove는 원본을 두고 구조를 공유하는 새 컬렉션을 돌려주므로 변경 비용이 O(log n) 수준이며 다운캐스트로도 변경할 수 없습니다. 다만 불변 방식은 변경마다 새 인스턴스를 만들어 수만 건을 반복 갱신하는 핫 루프에서는 할당 비용이 눈에 띌 수 있으므로, 그런 구간은 지역 범위에서 MutableList로 작업한 뒤 toList()로 봉인해 내보내는 ''내부는 가변, 경계는 불변'' 전략이 현실적입니다.',
 'interview-question/1011.mp3'),
(1012, 'KOTLIN', 203, 'NORMAL', true,
 'Kotlin의 가시성 변경자는 자바와 비교해 어떤 차이가 있나요?',
 '자바의 기본 가시성은 package-private이지만 Kotlin의 기본 가시성은 public입니다. Kotlin에는 package-private이 없는 대신 같은 모듈 안에서만 접근할 수 있는 internal이 있고, 모듈은 Gradle 소스 세트처럼 함께 컴파일되는 단위입니다. internal 멤버는 JVM 바이트코드상 public이지만 이름이 name$moduleName 형태로 맹글링되어 자바에서의 우발적 호출을 막으므로 접근 제어라기보다 의도 표시에 가깝습니다. protected는 자바와 달리 같은 패키지에서는 접근할 수 없고 자신과 하위 클래스만 접근할 수 있으며, 최상위 선언에는 사용할 수 없습니다. private은 클래스 멤버라면 클래스 안에서만, 최상위 선언이라면 같은 파일 안에서만 접근할 수 있는데, 최상위 private은 자바에 없는 개념입니다. 이렇게 Kotlin은 모듈 경계와 파일 경계로 가시성을 자바보다 세밀하게 표현할 수 있습니다.',
 'interview-question/1012.mp3'),
(1013, 'KOTLIN', 203, 'NORMAL', true,
 'val로 선언한 프로퍼티는 불변이라고 할 수 있나요? val과 진짜 불변 객체의 차이를 설명해 주세요.',
 'val은 불변이 아니라 읽기 전용입니다. val은 자바의 final처럼 재대입이 불가능한 참조일 뿐이어서, ''이 이름으로는 다시 대입할 수 없다''는 뜻이지 값이 절대 변하지 않는다는 뜻이 아닙니다. 예를 들어 val list = mutableListOf(1, 2)에 list.add(3)을 호출하면 참조는 그대로지만 객체 내부는 바뀝니다. 또 커스텀 getter를 가진 val은 get() = System.currentTimeMillis()처럼 접근할 때마다 다른 값을 돌려줄 수도 있습니다. 반면 진짜 불변 객체는 객체 내부 변경이 불가능한 것으로, 참조가 val이고 타입이 불변이며 그 안의 모든 프로퍼티도 재귀적으로 불변일 때만 성립합니다. 그래서 val items: MutableList<Item>은 val이지만 불변과는 거리가 멉니다. 불변 객체는 스레드 간에 안전하게 공유할 수 있지만, val은 객체가 불변일 때만 안전한 공유가 가능합니다.',
 'interview-question/1013.mp3'),
(1014, 'KOTLIN', 203, 'EASY', true,
 'Kotlin의 List는 불변 컬렉션인가요? 그 이유를 설명해 주세요.',
 '아닙니다. Kotlin의 List는 변경 메서드가 없는 읽기 전용 인터페이스이고, MutableList는 이를 상속해 add, remove 같은 변경 메서드를 추가한 인터페이스입니다. 런타임 객체는 대부분 java.util.ArrayList 같은 가변 자바 컬렉션 그대로이며, Kotlin은 그 객체를 어느 인터페이스로 보느냐만 제한합니다. 그래서 같은 객체를 가리키는 MutableList 참조로 add를 하면 List 참조에서도 값이 바뀐 것이 보이고, readOnly as MutableList<Int>로 다운캐스트해 변경할 수도 있으며, 자바 코드는 이를 java.util.List로 보기 때문에 아무 제약 없이 add를 호출할 수 있습니다. listOf(1, 2, 3)이 반환하는 객체도 add를 호출하면 UnsupportedOperationException이 발생하는 ''실패하는 가변 컬렉션''일 뿐 진짜 불변 컬렉션은 아닙니다.',
 'interview-question/1014.mp3'),
(1015, 'KOTLIN', 203, 'EASY', true,
 'Kotlin에서 불변 객체를 설계할 때 따라야 할 원칙은 무엇인가요?',
 '먼저 모든 프로퍼티를 val로 선언하되, val은 재대입만 막을 뿐 객체 내부 변경은 막지 못하므로 그것에 그치지 않고 타입까지 불변으로 둬야 합니다. 즉 String, Int처럼 불변인 타입을 쓰고, 컬렉션은 List 대신 진짜 불변 컬렉션을 쓰거나 방어적 복사를 거친 값으로 둡니다. 변경이 필요하면 기존 객체를 고치지 않고 새 객체를 만듭니다. data class라면 copy()로 일부만 바꾼 새 객체를 만들고, withLine(line) = Order(id, lines + line)처럼 변경 대신 새 객체를 반환하는 메서드를 둘 수도 있습니다. 또 생성자에서 외부 가변 컬렉션을 받으면 lines.toList()처럼 복사해서 저장해, 호출자가 나중에 원본을 바꿔도 영향을 받지 않게 합니다. 이렇게 만든 불변 객체는 스레드 간 공유 시 동기화가 필요 없어 코루틴·Flow에서 상태를 안전하게 전달할 수 있고, equals/hashCode가 시간이 지나도 변하지 않아 컬렉션 키·캐시 키로 안전하며, 상태 변화가 새 객체 생성으로 명시되어 변경 지점을 추적하기 쉽습니다.',
 'interview-question/1015.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1011
(5449, 1011, '같은 객체를 List로 반환하면 내부 변경이 읽기 전용 참조에도 그대로 관찰됨을 설명', 'ESSENTIAL', 1),
(5450, 1011, 'toList() 방어적 복사는 호출마다 O(n) 복사 비용이 듦을 언급', 'ESSENTIAL', 2),
(5451, 1011, 'PersistentList는 변경 시 원본과 구조를 공유하는 새 컬렉션을 반환함을 설명', 'ESSENTIAL', 3),
(5452, 1011, '변경 시 기존 리스트를 수정하지 않고 items + item처럼 새 리스트로 교체하는 방식을 제시', 'SUPPLEMENTARY', 4),
(5453, 1011, '핫 루프에서는 지역 MutableList로 작업한 뒤 toList()로 봉인하는 ''내부는 가변, 경계는 불변'' 전략을 제시', 'SUPPLEMENTARY', 5),

-- 질문 1012
(5454, 1012, '기본 가시성이 자바는 package-private, Kotlin은 public임을 언급', 'ESSENTIAL', 1),
(5455, 1012, '자바의 package-private 대신 같은 모듈 안에서만 접근 가능한 internal이 있음을 설명', 'ESSENTIAL', 2),
(5456, 1012, 'Kotlin의 protected는 자바와 달리 같은 패키지에서 접근할 수 없음을 언급', 'ESSENTIAL', 3),
(5457, 1012, '최상위 private 선언은 같은 파일 안에서만 접근 가능함을 언급', 'SUPPLEMENTARY', 4),
(5458, 1012, 'internal 멤버가 바이트코드상 public이지만 이름이 맹글링되어 자바의 우발적 호출을 막음을 설명', 'SUPPLEMENTARY', 5),

-- 질문 1013
(5459, 1013, 'val은 재대입만 불가능할 뿐 참조가 가리키는 객체 내부는 변경될 수 있음을 설명', 'ESSENTIAL', 1),
(5460, 1013, '커스텀 getter를 가진 val은 접근할 때마다 다른 값을 돌려줄 수 있음을 언급', 'ESSENTIAL', 2),
(5461, 1013, '진짜 불변은 참조가 val이고 타입과 모든 프로퍼티가 재귀적으로 불변일 때 성립함을 설명', 'ESSENTIAL', 3),
(5462, 1013, 'val이 자바의 final에 해당하는 재대입 불가 참조임을 언급', 'SUPPLEMENTARY', 4),
(5463, 1013, 'val items: MutableList처럼 val이어도 불변이 아닌 예를 제시', 'SUPPLEMENTARY', 5),

-- 질문 1014
(5464, 1014, 'List는 변경 메서드가 없는 읽기 전용 인터페이스일 뿐 불변 컬렉션이 아님을 설명', 'ESSENTIAL', 1),
(5465, 1014, '런타임 객체는 java.util.ArrayList 같은 가변 자바 컬렉션 그대로일 수 있음을 언급', 'ESSENTIAL', 2),
(5466, 1014, '읽기 전용 참조가 바뀌는 경로로 가변 참조·자바 코드·MutableList 다운캐스트 중 최소 1개를 제시', 'ESSENTIAL', 3),
(5467, 1014, 'listOf 결과에 add를 호출하면 UnsupportedOperationException이 발생함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 1015
(5468, 1015, '프로퍼티를 val로 두는 것에 그치지 않고 타입까지 불변(진짜 불변 컬렉션 또는 방어적 복사)으로 둬야 함을 언급', 'ESSENTIAL', 1),
(5469, 1015, '변경이 필요하면 기존 객체를 고치지 않고 copy() 등으로 새 객체를 만든다고 설명', 'ESSENTIAL', 2),
(5470, 1015, '생성자에서 받은 외부 가변 컬렉션을 복사해서 저장함을 언급', 'ESSENTIAL', 3),
(5471, 1015, '불변 객체는 스레드 간 공유 시 동기화가 필요 없다는 이점을 언급', 'SUPPLEMENTARY', 4),
(5472, 1015, 'equals/hashCode가 시간이 지나도 변하지 않아 컬렉션 키·캐시 키로 안전함을 언급', 'SUPPLEMENTARY', 5);
