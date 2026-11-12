-- Unit: Null Safety 설계 (Unit ID: 196)
-- Chapter: Kotlin (Chapter ID: 19)
-- Topic: KOTLIN
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-kotlin-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(976, 'KOTLIN', 196, 'HARD', true,
 'Kotlin 코드에서 null을 반환할 수 있는 자바 라이브러리 메서드의 결과를 타입 명시 없이 val name = javaRepo.findName(1)처럼 받아 여러 함수에 넘겼더니, 호출 지점이 아니라 한참 뒤에서 NPE가 발생했습니다. 원인이 무엇이고 어떻게 고쳐야 하며, 이 상황을 !!로 해결하면 안 되는 이유는 무엇인가요?',
 '자바 코드에는 널 가능성 정보가 없기 때문에 Kotlin은 자바에서 넘어온 값을 플랫폼 타입 T!로 취급합니다. 플랫폼 타입은 null일 수도, 아닐 수도 있다는 뜻이고 T와 T? 중 어느 쪽으로 받을지는 개발자가 직접 선택해야 합니다. 그런데 val name = javaRepo.findName(1)처럼 타입을 명시하지 않으면 타입 추론 결과가 플랫폼 타입 String! 그대로 남습니다. 플랫폼 타입은 null 대입에 검사가 없고 직접 메서드 호출도 허용되기 때문에, 이 값이 검사 없이 여러 함수로 흘러가다가 실제로 사용되는 지점에서 런타임 NPE가 납니다. 즉 플랫폼 타입을 그대로 흘려보내면 NPE가 호출 지점이 아니라 한참 뒤에서 터져 원인 추적이 어려워집니다. 참고로 널 불가 타입인 String으로 받았다면 컴파일은 통과하지만 null이면 그 자리에서 즉시 NPE가 났을 것입니다. 해결책은 자바 라이브러리를 호출하는 경계에서 반환 타입을 String?처럼 T?로 선언해 받고, 이후에는 ?.이나 ?:로 처리하는 것입니다. 자바 쪽에 @Nullable/@NotNull 어노테이션이 있으면 Kotlin이 이를 읽어 일반 널 가능·널 불가 타입으로 변환해 줍니다. 반면 !!로 해결하면 널 가능성 검증을 런타임으로 미루게 되어 Kotlin이 제공하는 컴파일 시점 안전성을 포기하는 것과 같습니다. 또 리팩터링으로 ''절대 null이 아니다''라는 전제가 깨져도 컴파일러가 알려주지 않기 때문에, !! 대신 T?로 받고 ?:나 requireNotNull() 같은 대안을 쓰는 것이 맞습니다.',
 'interview-question/976.mp3'),
(977, 'KOTLIN', 196, 'NORMAL', true,
 'Kotlin에서 null 검사를 했는데도 지역 val 변수는 스마트 캐스트가 되고, 클래스의 var 프로퍼티는 스마트 캐스트가 되지 않는 이유는 무엇이며 어떻게 해결하나요?',
 '스마트 캐스트는 if (x != null) 같은 검사를 통과하면 그 블록 안에서 컴파일러가 x를 자동으로 널 불가 타입으로 취급하는 기능인데, 값이 중간에 바뀔 수 없다고 컴파일러가 보장할 수 있을 때만 동작합니다. val 지역 변수는 값이 바뀌지 않으므로 컴파일러가 이를 보장할 수 있어 스마트 캐스트가 됩니다. 반면 var 프로퍼티는 검사와 사용 사이에 다른 스레드가 값을 바꿀 수 있으므로 스마트 캐스트가 거부됩니다. 같은 이유로 커스텀 getter가 있는 프로퍼티나 다른 모듈의 open 프로퍼티처럼 값 변경 가능성이 있는 경우에도 스마트 캐스트가 되지 않습니다. 해결책은 프로퍼티를 지역 val에 복사한 뒤 검사하는 것으로, 예를 들어 val cache = repo.cache ?: return처럼 스냅샷을 잡으면 이후 cache는 널 불가 타입으로 스마트 캐스트됩니다. 참고로 Kotlin 2.0의 K2 컴파일러부터는 || 조건이나 인라인 람다 내부 등 스마트 캐스트가 적용되는 범위가 확장되었습니다.',
 'interview-question/977.mp3'),
(978, 'KOTLIN', 196, 'NORMAL', true,
 'Kotlin에서 List<String?>와 List<String>?는 어떻게 다르며, 리스트 원소에 섞인 null을 걸러 내려면 어떻게 하나요?',
 '두 타입은 널 가능성이 붙는 위치가 달라 전혀 다른 타입입니다. List<String?>는 리스트 자체는 null이 아니지만 원소가 null일 수 있는 타입이고, List<String>?는 원소는 null이 아니지만 리스트 자체가 null일 수 있는 타입입니다. 원소에 섞인 null을 걸러 낼 때는 filterNotNull()을 쓰면 List<T?>가 List<T>로 바뀌어 이후에는 널 불가 원소만 다룰 수 있습니다. 변환과 null 제거를 함께 해야 한다면 mapNotNull { }으로 한 번에 처리할 수 있습니다. 또 제네릭 타입 파라미터 T는 상한이 지정되지 않으면 Any?가 기본이어서 null을 허용하므로, null을 막으려면 T : Any로 상한을 지정해야 합니다.',
 'interview-question/978.mp3'),
(979, 'KOTLIN', 196, 'EASY', true,
 'Kotlin의 널 가능 타입과 널 불가 타입은 무엇이고, 이 구분이 NullPointerException을 어떻게 줄여 주나요?',
 'Kotlin은 널 가능성을 타입 시스템에 포함시킨 언어입니다. 모든 타입은 기본적으로 널 불가 타입이고, null을 담으려면 String?처럼 타입 뒤에 ?를 붙여 널 가능 타입으로 선언해야 합니다. String과 String?은 서로 다른 타입이며 String?에는 String의 메서드를 직접 호출할 수 없고 ?.나 !!. 호출만 허용됩니다. 컴파일러가 널 검사 여부를 추적하기 때문에, 자바에서 런타임에 터지던 NPE의 대부분이 컴파일 에러로 바뀌어 미리 걸러집니다. 다만 NPE가 완전히 없어지는 것은 아니고, !!를 쓰거나 플랫폼 타입, lateinit 미초기화, 자바 상호운용에서는 여전히 발생할 수 있습니다.',
 'interview-question/979.mp3'),
(980, 'KOTLIN', 196, 'EASY', true,
 'Kotlin의 안전 호출 연산자 ?.과 엘비스 연산자 ?:가 각각 어떻게 동작하는지 설명해 주세요.',
 '안전 호출 연산자 ?.은 수신 객체가 null이면 호출을 건너뛰고 결과 전체가 null이 되는 연산자입니다. user?.address?.city처럼 체이닝하면 중간에 하나라도 null일 때 전체가 null이 됩니다. 엘비스 연산자 ?:는 좌변이 null일 때 사용할 기본값을 지정하는 연산자로, user?.address?.city ?: "UNKNOWN"처럼 안전 호출과 함께 써서 null 대신 기본값을 돌려줄 수 있습니다. 또 엘비스의 우변에는 return이나 throw를 둘 수 있어서 null이면 바로 함수를 빠져나가는 조기 종료 패턴에 유용하고, 이 경우 이후 코드에서는 값이 널 불가 타입으로 스마트 캐스트됩니다.',
 'interview-question/980.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 976
(5265, 976, '자바에서 넘어온 값은 널 정보가 없는 플랫폼 타입 T!로 취급됨을 설명', 'ESSENTIAL', 1),
(5266, 976, '플랫폼 타입을 그대로 흘려보내면 NPE가 호출 지점이 아닌 한참 뒤에서 발생함을 설명', 'ESSENTIAL', 2),
(5267, 976, '자바 호출 경계에서 반환값을 T? 타입으로 선언해 받아야 한다는 해결책을 제시', 'ESSENTIAL', 3),
(5268, 976, '!!는 널 검증을 런타임으로 미뤄 컴파일 시점 안전성을 포기하는 것임을 설명', 'ESSENTIAL', 4),
(5269, 976, '자바 쪽에 @Nullable·@NotNull 어노테이션이 있으면 일반 널 가능·널 불가 타입으로 변환됨을 언급', 'SUPPLEMENTARY', 5),
(5270, 976, '!!를 쓰면 null이 아니라는 전제가 깨져도 컴파일러가 알려주지 않음을 언급', 'SUPPLEMENTARY', 6),
(5271, 976, '플랫폼 타입 값을 널 불가 String으로 받으면 null일 때 즉시 NPE가 발생함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 977
(5272, 977, '값이 중간에 바뀔 수 없다고 컴파일러가 보장할 수 있을 때만 스마트 캐스트가 동작함을 설명', 'ESSENTIAL', 1),
(5273, 977, 'var 프로퍼티는 검사와 사용 사이에 다른 스레드가 값을 바꿀 수 있어 스마트 캐스트가 거부됨을 설명', 'ESSENTIAL', 2),
(5274, 977, '프로퍼티를 지역 val에 복사한 뒤 검사하는 해결책을 제시', 'ESSENTIAL', 3),
(5275, 977, '스마트 캐스트는 null 검사를 통과한 블록 안에서 값을 널 불가 타입으로 자동 취급하는 기능임을 설명', 'SUPPLEMENTARY', 4),
(5276, 977, '커스텀 getter 프로퍼티·다른 모듈의 open 프로퍼티 중 최소 1개를 스마트 캐스트 불가 사례로 제시', 'SUPPLEMENTARY', 5),
(5277, 977, 'K2 컴파일러부터 스마트 캐스트가 적용되는 범위가 확장됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 978
(5278, 978, 'List<String?>는 원소가 null일 수 있는 타입임을 설명', 'ESSENTIAL', 1),
(5279, 978, 'List<String>?는 리스트 자체가 null일 수 있는 타입임을 설명', 'ESSENTIAL', 2),
(5280, 978, 'filterNotNull()이 List<T?>를 List<T>로 바꿔 준다는 점을 언급', 'ESSENTIAL', 3),
(5281, 978, 'mapNotNull이 변환과 null 제거를 한 번에 처리함을 언급', 'SUPPLEMENTARY', 4),
(5282, 978, '상한 없는 제네릭 T는 Any?가 기본이라 null을 막으려면 T : Any 상한이 필요함을 설명', 'SUPPLEMENTARY', 5),

-- 질문 979
(5283, 979, 'Kotlin의 모든 타입은 기본적으로 널 불가이고 타입 뒤에 ?를 붙여야 null을 담을 수 있음을 설명', 'ESSENTIAL', 1),
(5284, 979, 'String과 String?은 서로 다른 타입이라 String?에는 String 메서드를 직접 호출할 수 없음을 설명', 'ESSENTIAL', 2),
(5285, 979, '컴파일러가 널 검사를 추적해 NPE의 대부분이 컴파일 에러로 바뀜을 설명', 'ESSENTIAL', 3),
(5286, 979, '!!·플랫폼 타입·lateinit 미초기화 중 최소 1개를 NPE가 여전히 발생하는 경우로 제시', 'SUPPLEMENTARY', 4),

-- 질문 980
(5287, 980, '안전 호출 ?.은 수신 객체가 null이면 호출을 건너뛰고 결과가 null이 됨을 설명', 'ESSENTIAL', 1),
(5288, 980, '엘비스 연산자 ?:는 좌변이 null일 때 사용할 기본값을 지정함을 설명', 'ESSENTIAL', 2),
(5289, 980, '엘비스 우변에 return이나 throw를 두어 조기 종료할 수 있음을 언급', 'SUPPLEMENTARY', 3),
(5290, 980, '안전 호출 체이닝에서 중간에 하나라도 null이면 전체가 null이 됨을 언급', 'SUPPLEMENTARY', 4);
