-- Unit: 값 타입 vs 참조 타입 (Unit ID: 220)
-- Chapter: Swift (Chapter ID: 22)
-- Topic: SWIFT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-swift-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1096, 'SWIFT', 220, 'HARD', true,
 '큰 데이터를 담는 값 타입을 대입할 때마다 전체를 복사하면 성능이 무너질 수 있습니다. Swift 표준 라이브러리의 Array는 이 문제를 어떻게 해결하고, 직접 만든 struct에서 같은 효과를 얻으려면 어떻게 해야 하나요?',
 'Array·Dictionary·Set·String 같은 표준 라이브러리 컬렉션은 Copy-on-Write(COW, 쓰기 시 복사)로 이 문제를 해결합니다. 대입할 때는 내부 버퍼의 참조만 공유하고 참조 카운트를 올리기 때문에 O(1)이고, 어느 한쪽이 변경(mutating)하려는 순간 버퍼가 다른 곳과 공유 중이면 그때 처음으로 복사합니다. 그래서 사용자 입장에서는 독립적인 복사본이라는 값 의미론이 유지되면서도 실제 복사는 필요한 순간까지 지연됩니다. 다만 COW는 언어 기능이 아니라 표준 라이브러리가 isKnownUniquelyReferenced(_:)로 구현한 최적화이기 때문에, 직접 만든 struct는 자동으로 COW가 되지 않습니다. 큰 버퍼를 가진 커스텀 값 타입에 COW가 필요하면 데이터를 final class 저장소에 담아 struct의 private 프로퍼티로 두고, mutating 메서드에서 isKnownUniquelyReferenced로 그 저장소를 나 혼자만 참조하는지 확인한 뒤, 아니라면 새 저장소로 복사하고 나서 수정하도록 직접 구현해야 합니다. 참고로 값 타입이라도 내부에 참조 타입 프로퍼티가 있으면 복사할 때 그 참조의 카운트가 증가하므로 복사가 완전히 공짜는 아닙니다.',
 'interview-question/1096.mp3'),
(1097, 'SWIFT', 220, 'NORMAL', true,
 'Swift에서 새 타입을 만들 때 struct와 class 중 무엇을 기본으로 선택하고, 어떤 경우에 class를 선택해야 하나요?',
 '기본 선택은 struct입니다. 데이터를 비교·복사하는 것이 자연스럽고 인스턴스에 고유한 정체성이 없는 타입이라면 struct를 기본으로 선택하며, 이는 Apple 공식 권장 기본값이기도 합니다. 값 타입은 독립적인 복사본을 가지므로 예측 가능성이 높고, 대부분 자동으로 Sendable이 되어 동시성 안전성에도 유리합니다. 반면 여러 곳에서 같은 인스턴스를 공유하며 상태를 변경해야 할 때는 class를 선택합니다. 또 deinit으로 생명주기를 관리해야 하거나, 상속이 필요하거나, NSObject 상속을 통한 Objective-C 연동이 필요할 때도 class가 필요합니다. 뷰 컨트롤러·네트워크 세션·공유 캐시가 대표적인 class 사례이고, 좌표·DTO 모델·설정값은 struct 사례입니다. 값 타입 데이터에 ''한 곳에서 관리''하는 특성이 필요하면 class 안에 struct 모델을 두거나 뷰모델 계층에서 참조 타입으로 감싸는 구조를 씁니다. 그리고 상태가 몇 가지로 정해져 있다면 struct보다 연관값을 가진 enum을 먼저 고려합니다.',
 'interview-question/1097.mp3'),
(1098, 'SWIFT', 220, 'NORMAL', true,
 'let으로 선언한 struct 인스턴스와 let으로 선언한 class 인스턴스는 내부 프로퍼티를 바꿀 수 있는지에서 어떻게 다른가요?',
 'let으로 선언한 값 타입(struct)은 내부 프로퍼티까지 전부 불변이라 어떤 프로퍼티도 바꿀 수 없습니다. 반면 let으로 선언한 참조 타입(class)은 변수에 담긴 참조만 고정될 뿐, 그 참조가 가리키는 인스턴스의 내부 프로퍼티는 여전히 바꿀 수 있습니다. 예를 들어 let r2 = r1처럼 class 인스턴스를 let에 담아도 r2.x = 10은 가능하고, 같은 인스턴스를 공유하는 r1의 x도 함께 바뀝니다. 이 차이는 값 타입은 변수가 값 자체를 담고, 참조 타입은 변수가 인스턴스의 주소만 담기 때문입니다. 관련해서 값 타입의 메서드가 자신의 프로퍼티를 바꾸려면 mutating 키워드가 필요하며, mutating 메서드는 let 상수에는 호출할 수 없습니다.',
 'interview-question/1098.mp3'),
(1099, 'SWIFT', 220, 'EASY', true,
 'Swift의 값 타입과 참조 타입이 각각 무엇이고, 변수에 대입할 때 어떻게 동작하는지 설명해 주세요.',
 'Swift의 모든 타입은 값 타입과 참조 타입 중 하나로 동작합니다. 값 타입은 변수에 대입하거나 함수에 전달할 때 값 자체가 복사되어, 복사본을 수정해도 원본은 바뀌지 않고 서로 독립적입니다. struct, enum, 튜플이 값 타입이고, Int·String·Array·Dictionary 등 표준 라이브러리 대부분도 값 타입입니다. 참조 타입은 변수에 인스턴스의 주소(참조)만 담기므로, 대입하면 같은 인스턴스를 여러 변수가 공유합니다. 그래서 한 변수로 프로퍼티를 바꾸면 다른 변수에서도 바뀐 값이 보입니다. class, actor, 클로저가 참조 타입입니다.',
 'interview-question/1099.mp3'),
(1100, 'SWIFT', 220, 'EASY', true,
 'Swift에서 struct 인스턴스는 항상 스택에 저장되나요?',
 '아닙니다. 값 타입 인스턴스는 보통 스택이나 소유자(컨테이너·구조체) 안에 인라인으로 저장되어 할당·해제가 빠르고 참조 카운트 관리가 필요 없지만, 이는 경향일 뿐 보장이 아닙니다. 클로저에 캡처되거나, 프로토콜 타입(existential)에 담겼는데 크기가 인라인 버퍼(3워드)를 넘으면 힙에 박싱되고, 클래스 프로퍼티로 들어간 경우에도 힙에 놓입니다.',
 'interview-question/1100.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1096
(5881, 1096, 'Copy-on-Write로 대입 시 버퍼 참조만 공유하다가 변경 시점에 복사함을 설명', 'ESSENTIAL', 1),
(5882, 1096, '직접 만든 struct는 자동으로 COW가 되지 않음을 명시', 'ESSENTIAL', 2),
(5883, 1096, 'isKnownUniquelyReferenced로 버퍼를 혼자만 참조하는지 확인해 아니면 복사 후 수정함을 설명', 'ESSENTIAL', 3),
(5884, 1096, 'COW는 언어 기능이 아니라 표준 라이브러리가 구현한 최적화임을 언급', 'SUPPLEMENTARY', 4),
(5885, 1096, '값 타입도 내부 참조 타입 프로퍼티가 있으면 복사 시 참조 카운트가 증가함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1097
(5886, 1097, '인스턴스에 고유한 정체성이 없는 타입은 struct를 기본으로 선택함을 설명', 'ESSENTIAL', 1),
(5887, 1097, '여러 곳에서 같은 인스턴스를 공유하며 상태를 변경해야 할 때 class를 선택함을 설명', 'ESSENTIAL', 2),
(5888, 1097, '상속·deinit 생명주기 관리·Objective-C 연동 중 최소 1개를 class 선택 사유로 제시', 'ESSENTIAL', 3),
(5889, 1097, '값 타입의 장점으로 예측 가능성과 동시성 안전성 중 최소 1개를 제시', 'SUPPLEMENTARY', 4),
(5890, 1097, '상태가 몇 가지로 정해져 있다면 struct보다 enum이 먼저임을 언급', 'SUPPLEMENTARY', 5),
(5891, 1097, 'class 안에 struct 모델을 두어 한 곳에서 관리하는 구조를 제시', 'SUPPLEMENTARY', 6),

-- 질문 1098
(5892, 1098, 'let으로 선언한 값 타입은 내부 프로퍼티까지 전부 불변임을 언급', 'ESSENTIAL', 1),
(5893, 1098, 'let으로 선언한 참조 타입은 참조만 고정되어 내부 프로퍼티를 바꿀 수 있음을 설명', 'ESSENTIAL', 2),
(5894, 1098, '값 타입 메서드에서 자신의 프로퍼티를 바꾸려면 mutating 키워드가 필요함을 언급', 'SUPPLEMENTARY', 3),
(5895, 1098, 'mutating 메서드는 let 상수에서 호출할 수 없음을 명시', 'SUPPLEMENTARY', 4),

-- 질문 1099
(5896, 1099, '값 타입은 대입하거나 함수에 전달할 때 값 자체가 복사됨을 설명', 'ESSENTIAL', 1),
(5897, 1099, '참조 타입은 대입 시 같은 인스턴스를 여러 변수가 공유함을 설명', 'ESSENTIAL', 2),
(5898, 1099, '값 타입(struct·enum 등)과 참조 타입(class·actor 등)에 해당하는 타입을 각각 1개 이상 제시', 'ESSENTIAL', 3),
(5899, 1099, 'Int·String·Array 등 표준 라이브러리 대부분이 값 타입임을 언급', 'SUPPLEMENTARY', 4),
(5900, 1099, '참조 타입 변수에는 인스턴스의 주소(참조)만 담김을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1100
(5901, 1100, '값 타입은 보통 스택이나 소유자 안에 인라인으로 저장됨을 언급', 'ESSENTIAL', 1),
(5902, 1100, '클로저 캡처·existential 박싱·클래스 프로퍼티 중 최소 1개를 값 타입이 힙에 놓이는 경우로 제시', 'ESSENTIAL', 2),
(5903, 1100, '프로토콜 타입에 담긴 값이 인라인 버퍼(3워드)를 넘으면 힙에 박싱됨을 언급', 'SUPPLEMENTARY', 3);
