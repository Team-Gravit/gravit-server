-- Unit: 위임과 프로퍼티 (Unit ID: 202)
-- Chapter: Kotlin (Chapter ID: 19)
-- Topic: KOTLIN
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-kotlin-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1006, 'KOTLIN', 202, 'HARD', true,
 '비용이 큰 외부 리소스 초기화를 lazy로 지연하려고 합니다. 여러 스레드가 동시에 접근할 수 있는 환경에서 스레드 안전 모드를 어떻게 선택하고, 초기화 호출이 실패할 수 있다면 어떤 문제가 생기나요?',
 'lazy는 최초 접근 시 람다를 한 번 실행해 값을 계산하고 이후에는 캐시된 값을 돌려주므로, 비용 큰 초기화를 실제로 필요할 때까지 지연하는 데 적합합니다. 여러 스레드가 동시에 첫 접근할 수 있다면 기본값인 SYNCHRONIZED 모드를 그대로 쓰는 것이 안전합니다. 이 모드는 락(이중 검사)으로 보호해 한 스레드만 계산하고 나머지는 대기 후 같은 값을 사용하므로, 초기화가 정확히 한 번이어야 할 때 선택합니다. 초기화에 부수 효과가 없고 락 비용을 피하고 싶다면 PUBLICATION 모드를 고려할 수 있는데, 락 없이 결과 저장만 원자적으로 처리해 여러 스레드가 각자 계산할 수는 있지만 첫 결과만 채택됩니다. NONE 모드는 동기화가 없어 여러 번 계산되거나 불일치가 생길 수 있으므로 단일 스레드임이 확실할 때만 씁니다. 한편 lazy 람다가 예외를 던지면 값이 저장되지 않아 다음 접근 때 람다가 다시 실행됩니다. 따라서 실패할 수 있는 외부 호출을 lazy 안에 두면 실패가 매 접근마다 반복되고 원인 파악이 어려워질 수 있습니다.',
 'interview-question/1006.mp3'),
(1007, 'KOTLIN', 202, 'NORMAL', true,
 '기존 컬렉션에 기능을 덧붙일 때 상속으로 확장하는 방식과 Kotlin의 클래스 위임(by)을 쓰는 방식은 어떤 차이가 있나요?',
 '상속으로 기능을 추가하면, 예를 들어 HashSet을 상속해 추가 횟수를 세는 경우 HashSet.addAll이 내부적으로 add를 호출하는지 같은 부모 구현 세부에 종속되어 이중 계산 같은 문제가 생길 수 있습니다. 반면 클래스 위임은 class A(b: B) : I by b 형태로 인터페이스의 모든 멤버 호출을 다른 객체에 전달하는 합성 방식입니다. 관심 있는 메서드만 오버라이드하면 되고, 나머지는 컴파일러가 생성한 전달 메서드가 내부 객체를 호출하므로 위임 메서드를 일일이 작성할 필요가 없습니다. 또 위임 객체는 래퍼의 존재를 모르기 때문에 위임 객체 내부에서 자기 메서드를 호출해도 래퍼의 오버라이드를 거치지 않습니다. 그래서 inner의 addAll이 inner.add를 불러도 래퍼의 add는 호출되지 않아 이중 계산이 생기지 않고, 상속의 취약한 기반 클래스 문제가 사라집니다. 다만 같은 이유로 자기 호출을 가로채고 싶다면 위임은 답이 아닙니다.',
 'interview-question/1007.mp3'),
(1008, 'KOTLIN', 202, 'NORMAL', true,
 '프로퍼티 초기화를 미룰 때 lateinit과 lazy 중 무엇을 쓸지 어떤 기준으로 선택하나요?',
 '가장 큰 기준은 프로퍼티의 가변성과 초기화 주체입니다. lazy는 val 전용이고, lateinit은 var에 사용합니다. 또 lazy는 초기화 로직을 프로퍼티가 스스로 가지고 있어 최초 접근 시 람다를 한 번만 실행해 계산하고 이후에는 캐시된 값을 돌려주는 반면, lateinit은 외부에서 값을 초기화해 주는 방식입니다. 따라서 값이 한 번 정해지면 바뀌지 않고 초기화 방법을 선언부에 담을 수 있으면 lazy를, 외부에서 나중에 주입되는 var라면 lateinit을 선택합니다. 참고로 lateinit은 기본 타입에 쓸 수 없으므로 Int 같은 타입에 늦은 초기화가 필요하면 초기화 전 접근 시 예외를 던지는 Delegates.notNull()을 사용할 수 있습니다.',
 'interview-question/1008.mp3'),
(1009, 'KOTLIN', 202, 'EASY', true,
 'val x: Int by Delegate()처럼 선언한 위임 프로퍼티는 컴파일 후 어떻게 동작하나요?',
 '컴파일러는 위임 객체를 x$delegate 같은 숨겨진 필드에 저장하고, 프로퍼티의 접근자가 그 객체에 호출을 전달하도록 코드를 생성합니다. 즉 x를 읽으면 x$delegate.getValue(this, this::x)가, 쓸 수 있는 var라면 setValue가 호출됩니다. 이때 thisRef는 프로퍼티를 가진 객체이고, property는 KProperty<*>로 프로퍼티 이름·타입 같은 메타데이터를 제공합니다. getValue/setValue는 operator 함수이므로 시그니처만 맞으면 어떤 클래스든 위임 객체가 될 수 있습니다. lazy도 특별한 문법이 아니라 getValue를 제공하는 Lazy 객체로서 이 규약을 따르는 것일 뿐입니다.',
 'interview-question/1009.mp3'),
(1010, 'KOTLIN', 202, 'EASY', true,
 'Kotlin에서 커스텀 위임 프로퍼티를 만드는 방법을 설명해 주세요.',
 '커스텀 위임 프로퍼티는 두 가지 방법으로 만들 수 있습니다. 첫째, 표준 라이브러리의 ReadOnlyProperty나 ReadWriteProperty 인터페이스를 구현하는 방법입니다. 이 인터페이스들은 getValue/setValue 시그니처를 강제해 주므로 시그니처 실수를 컴파일러가 잡아 줍니다. 람다 하나로 충분한 읽기 전용 위임은 ReadOnlyProperty { thisRef, prop -> ... }처럼 SAM 변환으로 바로 만들 수도 있습니다. 둘째, 임의의 클래스에 getValue(thisRef, property)와 setValue(thisRef, property, value)를 operator 함수로 직접 정의하는 방법입니다. 이때 property.name을 활용하면 이름 기반 저장소를 프로퍼티로 매핑할 수 있습니다. 또한 operator fun provideDelegate를 정의하면 프로퍼티가 초기화될 때 한 번 호출되어, 실제 위임 객체를 만들기 전에 프로퍼티 이름 검증이나 등록 같은 작업을 수행할 수 있습니다.',
 'interview-question/1010.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1006
(5427, 1006, '기본 모드 SYNCHRONIZED는 락으로 보호해 초기화가 정확히 한 번만 실행됨을 설명', 'ESSENTIAL', 1),
(5428, 1006, 'PUBLICATION 모드는 여러 스레드가 각자 계산할 수 있으나 첫 결과만 채택함을 설명', 'ESSENTIAL', 2),
(5429, 1006, 'lazy 람다가 예외를 던지면 값이 저장되지 않아 다음 접근 때 람다가 다시 실행됨을 언급', 'ESSENTIAL', 3),
(5430, 1006, '단일 스레드임이 확실할 때만 NONE 모드로 락 비용을 제거할 수 있음을 언급', 'SUPPLEMENTARY', 4),
(5431, 1006, 'PUBLICATION 모드는 초기화에 부수 효과가 없을 때 선택함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1007
(5432, 1007, '상속으로 확장하면 부모 클래스의 구현 세부에 종속됨을 설명', 'ESSENTIAL', 1),
(5433, 1007, '클래스 위임에서는 오버라이드하지 않은 멤버의 전달 메서드를 컴파일러가 생성함을 언급', 'ESSENTIAL', 2),
(5434, 1007, '위임 객체 내부에서 자기 메서드를 호출해도 래퍼의 오버라이드를 거치지 않음을 설명', 'ESSENTIAL', 3),
(5435, 1007, '자기 호출을 가로채고 싶다면 위임이 적합하지 않다는 한계를 언급', 'SUPPLEMENTARY', 4),
(5436, 1007, '위임을 쓰면 상속의 취약한 기반 클래스 문제가 사라짐을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1008
(5437, 1008, 'lazy는 val 전용이고 lateinit은 var에 쓴다는 차이를 설명', 'ESSENTIAL', 1),
(5438, 1008, 'lazy는 초기화 로직을 프로퍼티가 스스로 가지고 lateinit은 외부에서 초기화한다는 차이를 설명', 'ESSENTIAL', 2),
(5439, 1008, 'lateinit은 기본 타입에 쓸 수 없어 Int 등에는 Delegates.notNull()을 대안으로 제시', 'SUPPLEMENTARY', 3),
(5440, 1008, 'lazy는 최초 접근 시 한 번만 계산하고 이후에는 캐시된 값을 반환함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 1009
(5441, 1009, '컴파일러가 위임 객체를 숨겨진 $delegate 필드에 저장함을 언급', 'ESSENTIAL', 1),
(5442, 1009, '프로퍼티를 읽으면 위임 객체의 getValue, 쓰면 setValue가 호출됨을 설명', 'ESSENTIAL', 2),
(5443, 1009, 'getValue/setValue는 operator 함수라 시그니처만 맞으면 어떤 클래스든 위임 객체가 될 수 있음을 언급', 'SUPPLEMENTARY', 3),
(5444, 1009, 'lazy도 특별한 문법이 아니라 이 규약을 따르는 Lazy 객체임을 언급', 'SUPPLEMENTARY', 4),

-- 질문 1010
(5445, 1010, 'ReadOnlyProperty 또는 ReadWriteProperty 인터페이스를 구현하는 방법을 제시', 'ESSENTIAL', 1),
(5446, 1010, 'getValue/setValue operator 함수를 직접 정의하는 방법을 제시', 'ESSENTIAL', 2),
(5447, 1010, '인터페이스를 구현하면 시그니처 실수를 컴파일러가 잡아 준다는 장점을 언급', 'SUPPLEMENTARY', 3),
(5448, 1010, 'provideDelegate로 위임 객체 생성 전에 프로퍼티 이름 검증 등을 수행할 수 있음을 언급', 'SUPPLEMENTARY', 4);
