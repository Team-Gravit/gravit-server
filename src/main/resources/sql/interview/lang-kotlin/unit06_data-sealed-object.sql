-- Unit: data·sealed·object (Unit ID: 201)
-- Chapter: Kotlin (Chapter ID: 19)
-- Topic: KOTLIN
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-kotlin-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(1001, 'KOTLIN', 201, 'HARD', true,
 '화면 상태를 isLoading 같은 Boolean 플래그 여러 개 대신 sealed 계층으로 모델링하면 무엇을 얻을 수 있고, when으로 분기하거나 라이브러리의 공개 API로 노출할 때는 각각 무엇을 주의해야 하나요?',
 'Boolean 플래그를 여러 개 두어 상태를 표현하면 isLoading이 true인데 data가 null이 아닌 것처럼 불가능한 조합이 생길 수 있습니다. sealed 계층은 하위 타입의 집합이 컴파일 시점에 고정되므로, Loading·Success(data)·Error(cause)처럼 상태를 sealed 하위 타입 하나로 나타내면 ''상태는 이 중 하나''라는 사실이 타입으로 표현되어 불가능한 상태가 애초에 생길 수 없습니다. 이때 값을 담는 하위 타입은 data class로, 값이 없는 하위 타입은 data object로 통일하면 toString과 equals가 일관됩니다. 또 when의 대상이 sealed 타입이면 컴파일러가 모든 경우가 처리되었는지 검사하고, Kotlin 1.7부터는 문장 형태의 when도 누락 시 컴파일 에러가 됩니다. 각 분기에서는 is 검사와 스마트 캐스트가 결합되어 하위 타입의 프로퍼티에 바로 접근할 수 있습니다. 주의할 점은 첫째, when에 else 분기를 두면 완전성 검사가 꺼져서 나중에 Empty 같은 하위 타입을 추가해도 컴파일러가 알려주지 않고, Error가 스피너로 처리되는 식의 버그가 숨을 수 있으므로 모든 하위 타입을 나열해야 한다는 것입니다. 둘째, 다른 모듈의 사용자가 그 sealed 타입을 when으로 분기하고 있다면 하위 타입 추가는 사용자 코드를 깨뜨리는 변경이 되므로, 공개 API의 sealed 계층 확장은 호환성 관점에서 신중해야 합니다.'),
(1002, 'KOTLIN', 201, 'NORMAL', true,
 'Kotlin에서 enum class와 sealed class의 차이는 무엇이고, 어떤 상황에서 sealed class를 선택하나요?',
 'enum class는 각 상수가 단일 인스턴스이고 모든 상수가 같은 프로퍼티 집합을 가집니다. 반면 sealed class나 sealed interface는 하위 타입의 집합이 컴파일 시점에 고정된 계층으로, 하위 타입마다 여러 인스턴스를 생성할 수 있고 하위 타입마다 서로 다른 프로퍼티를 보유할 수 있습니다. 또 enum은 상속이 불가능하고 인터페이스 구현만 되지만 sealed interface는 다중 구현이 가능합니다. 두 방식 모두 when의 완전성 검사를 지원합니다. 따라서 요일이나 색상처럼 값만 다른 상수 집합에는 enum이 적합하고, Loading, Success(data), Error(cause)처럼 상태마다 담는 데이터의 형태가 다른 경우에는 sealed를 선택합니다.'),
(1003, 'KOTLIN', 201, 'NORMAL', true,
 'Kotlin의 object 선언, companion object, object 표현식은 생성 시점과 용도 면에서 각각 어떻게 다른가요?',
 'object 선언은 object Config처럼 선언하며, 최초 접근 시 JVM 클래스 초기화로 인스턴스가 만들어집니다. 그래서 별도의 동기화 없이도 스레드 안전한 지연 초기화 싱글턴이 되고, 싱글턴 외에도 상태 없는 유틸리티나 sealed의 하위 상태로 쓰입니다. companion object는 클래스 안에 선언하며 바깥 클래스 초기화 시 생성되고, 팩토리 메서드나 상수를 두는 용도, 즉 자바의 static을 대체하는 용도로 씁니다. 예를 들어 생성자를 private으로 숨기고 companion object의 of 같은 이름 있는 팩토리로 생성하게 할 수 있습니다. companion object는 하나만 가질 수 있고 이름을 생략하면 Companion으로 접근합니다. object 표현식은 object : Listener처럼 쓰는 익명 클래스로, 자바의 익명 내부 클래스에 해당하며 표현식이 평가될 때마다 새 인스턴스가 생성됩니다.'),
(1004, 'KOTLIN', 201, 'EASY', true,
 'Kotlin에서 클래스에 data 변경자를 붙이면 컴파일러가 무엇을 자동으로 만들어 주며, 그 결과 두 인스턴스의 == 결과는 어떻게 달라지나요?',
 'data 변경자를 붙이면 컴파일러가 주 생성자의 프로퍼티를 기준으로 equals, hashCode, toString, copy, componentN을 자동 생성합니다. 목적은 동일성(identity)이 아니라 값(value)으로 비교되는 객체를 만드는 것입니다. 그래서 Point(1, 2)를 두 번 만들면 서로 다른 인스턴스지만 == 결과는 true이고, hashCode도 같아서 HashSet이나 HashMap 키로 안전하게 쓸 수 있습니다. 반면 ===는 참조 비교이므로 서로 다른 인스턴스인 경우 false입니다. toString은 Point(x=1, y=2) 형태로 출력되고, componentN 덕분에 구조 분해를 할 수 있으며, copy로 일부 값만 바꾼 새 객체를 만들 수 있습니다. 제약으로는 주 생성자에 파라미터가 최소 1개 있어야 하고 모두 val이나 var여야 하며, abstract·open·sealed·inner가 될 수 없습니다.'),
(1005, 'KOTLIN', 201, 'EASY', true,
 'data class에서 주 생성자가 아니라 클래스 본문에 선언한 프로퍼티는 equals와 copy()에서 어떻게 다뤄지나요?',
 'data class의 equals, hashCode, toString, copy는 주 생성자의 프로퍼티만을 대상으로 자동 생성되기 때문에, 클래스 본문에 선언한 프로퍼티는 이들 모두에서 제외됩니다. 예를 들어 User(val id: Long) 본문에 var nickname을 두고 nickname만 다른 두 객체를 만들면, nickname은 무시되어 == 결과가 true가 됩니다. 또 copy()는 본문 프로퍼티를 복사하지 않으므로 복사본의 nickname은 초기값인 빈 문자열이 됩니다. 따라서 값 비교에 포함할 프로퍼티는 반드시 주 생성자에 두어야 합니다. 반대로 ID처럼 일부 필드만으로 동일성을 정의하고 싶다면 equals를 직접 오버라이드하거나 data class를 쓰지 않는 것이 맞습니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1001
(5400, 1001, 'sealed 하위 타입 하나로 상태를 나타내 불가능한 상태 조합이 생길 수 없다고 언급', 'ESSENTIAL', 1),
(5401, 1001, 'when 대상이 sealed 타입이면 컴파일러가 모든 경우의 처리 여부를 검사함을 언급', 'ESSENTIAL', 2),
(5402, 1001, 'else 분기를 두면 완전성 검사가 꺼져 하위 타입 추가를 컴파일러가 잡지 못함을 언급', 'ESSENTIAL', 3),
(5403, 1001, '공개 API의 sealed 계층에 하위 타입을 추가하면 사용자 코드를 깨뜨리는 변경이 됨을 언급', 'ESSENTIAL', 4),
(5404, 1001, '값을 담는 하위 타입은 data class, 값이 없는 하위 타입은 data object로 제시', 'SUPPLEMENTARY', 5),
(5405, 1001, 'when 분기에서 스마트 캐스트로 하위 타입의 프로퍼티에 바로 접근함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1002
(5406, 1002, 'enum 상수는 단일 인스턴스이고 sealed 하위 타입은 여러 인스턴스를 만들 수 있음을 언급', 'ESSENTIAL', 1),
(5407, 1002, 'enum은 모든 상수가 같은 프로퍼티 집합, sealed는 하위 타입마다 다른 프로퍼티를 가짐을 언급', 'ESSENTIAL', 2),
(5408, 1002, 'Loading/Success/Error처럼 형태가 다른 상태에 sealed가 적합하다고 제시', 'ESSENTIAL', 3),
(5409, 1002, 'enum과 sealed 모두 when 완전성 검사를 지원함을 언급', 'SUPPLEMENTARY', 4),
(5410, 1002, 'sealed interface는 다중 구현이 가능함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1003
(5411, 1003, 'object 선언은 최초 접근 시 인스턴스가 생성됨을 언급', 'ESSENTIAL', 1),
(5412, 1003, 'object 표현식은 표현식이 평가될 때마다 새 인스턴스가 생성됨을 언급', 'ESSENTIAL', 2),
(5413, 1003, '싱글턴·상태 없는 유틸리티·sealed 하위 상태 중 최소 1개를 object 선언 용도로 제시', 'ESSENTIAL', 3),
(5414, 1003, '팩토리 메서드·상수·자바 static 대체 중 최소 1개를 companion object 용도로 제시', 'ESSENTIAL', 4),
(5415, 1003, 'companion object는 바깥 클래스 초기화 시 생성됨을 언급', 'SUPPLEMENTARY', 5),
(5416, 1003, 'object 표현식을 자바의 익명 내부 클래스에 해당하는 익명 클래스 용도로 제시', 'SUPPLEMENTARY', 6),
(5417, 1003, 'object 선언의 인스턴스 생성이 별도 동기화 없이 스레드 안전함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 1004
(5418, 1004, 'equals·hashCode·toString·copy·componentN 중 최소 3개를 자동 생성 대상으로 제시', 'ESSENTIAL', 1),
(5419, 1004, '자동 생성이 주 생성자의 프로퍼티를 기준으로 이뤄진다고 언급', 'ESSENTIAL', 2),
(5420, 1004, '서로 다른 인스턴스라도 프로퍼티 값이 같으면 == 결과가 true임을 언급', 'ESSENTIAL', 3),
(5421, 1004, '===는 참조 기준이라 서로 다른 인스턴스면 false임을 언급', 'SUPPLEMENTARY', 4),
(5422, 1004, '주 생성자에 val/var 파라미터가 최소 1개 있어야 한다는 제약을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1005
(5423, 1005, '본문 프로퍼티는 equals에서 제외되어 그 값이 달라도 ==가 true일 수 있음을 언급', 'ESSENTIAL', 1),
(5424, 1005, 'copy()가 본문 프로퍼티를 복사하지 않음을 언급', 'ESSENTIAL', 2),
(5425, 1005, 'equals에 포함할 프로퍼티는 반드시 주 생성자에 둬야 한다고 제시', 'SUPPLEMENTARY', 3),
(5426, 1005, 'ID 등 일부 필드로만 동일성을 정의하려면 equals를 직접 오버라이드해야 함을 언급', 'SUPPLEMENTARY', 4);
