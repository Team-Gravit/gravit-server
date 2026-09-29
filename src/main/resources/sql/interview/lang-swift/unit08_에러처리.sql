-- Unit: 에러 처리 (Unit ID: 227)
-- Chapter: Swift (Chapter ID: 22)
-- Topic: SWIFT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-swift-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1131, 'SWIFT', 227, 'HARD', true,
 'URLSession을 쓰는 인프라 계층부터 도메인 계층, UI 계층까지 나뉜 iOS 앱에서 에러를 어느 계층에서 잡고 어떻게 올려야 하는지, try?나 빈 catch로 처리할 때의 문제와 함께 설명해 주세요.',
 '원칙은 잡았으면 처리하고, 처리하지 못하면 올리고, 올릴 때는 도메인 언어로 번역하는 것입니다. 인프라 계층처럼 현재 계층에서 의미 있게 처리할 수 없는 에러는 throws로 그대로 전파합니다. URLSession이나 파일 IO 에러가 여기에 해당합니다. 도메인·서비스 계층 경계에서는 저수준 에러를 도메인 에러로 감싸 변환해서, 상위 계층이 URLSession이나 SQLite 같은 구현 세부를 몰라도 되게 합니다. 이때 원인 에러는 underlying 같은 연관값으로 보존해 디버깅 정보를 잃지 않게 합니다. 에러를 잡는 것은 캐시 폴백, 재시도, 기본값 대체처럼 대안이 있는 곳에서만 하고, 잡았다면 반드시 무언가를 해야 합니다. 최종적으로 UI 계층에서 사용자에게 보여줄 메시지와 로그로 마무리합니다. 반대로 try?로 결과를 nil로 바꾸거나 빈 catch 블록을 두면 실패 원인을 삼키게 되어, 디코딩 실패로 화면이 비어 있는데 로그조차 없는 상황이 생깁니다. 이런 안티패턴 대신 복구를 하더라도 원인을 로그로 남기고, 복구할 수 없는 에러는 위로 전파해야 합니다. 또한 잘못된 인덱스나 위반된 불변식 같은 프로그래머 오류는 throw하지 않고 precondition이나 fatalError로 즉시 실패시켜 원인 지점에서 발견하도록 합니다.',
 'interview-question/1131.mp3'),
(1132, 'SWIFT', 227, 'NORMAL', true,
 'Swift에서 throws를 쓸지 Result를 쓸지는 어떤 기준으로 선택하나요?',
 'throws와 try는 제어 흐름이라 에러가 나면 즉시 처리하거나 전파하는 반면, Result는 성공 또는 실패를 담는 열거형, 즉 값이라서 저장하고 전달했다가 나중에 처리할 수 있습니다. 그래서 기본 선택은 throws이고, Result는 실패를 값으로 보관해야 하는 특수 상황에만 씁니다. 예를 들어 throws를 쓸 수 없는 콜백 기반 API로 실패를 전달할 때, 여러 작업을 실행하면서 하나가 실패해도 흐름을 끊지 않고 [Result<T, E>]로 부분 실패를 모을 때, 결과를 캐싱하거나 재시도 큐에 넣을 때 Result가 적합합니다. async/await 도입 전에는 콜백 때문에 Result가 널리 쓰였지만, 이제는 async throws로 자연스럽게 표현되므로 필요성이 크게 줄었습니다. 두 방식은 서로 변환도 가능해서, Result { try ... }로 throws를 Result로 바꾸고, result.get()으로 다시 throws 제어 흐름으로 되돌릴 수 있습니다.',
 'interview-question/1132.mp3'),
(1133, 'SWIFT', 227, 'NORMAL', true,
 'Swift 6의 타입 지정 throws(throws(E))는 기존 throws와 어떻게 다르고, 공개 API에 사용할 때 어떤 점을 주의해야 하나요?',
 '기존 throws는 던지는 에러 타입이 any Error라서 catch에서 as? 캐스팅을 하고 기본 catch를 반드시 둬야 합니다. Swift 6의 throws(E)는 던질 수 있는 에러 타입을 구체 타입 E 하나로 제한하므로, catch에서 error가 구체 타입으로 잡히고 switch로 완전성 검사를 할 수 있어 캐스팅과 기본 catch가 필요 없어집니다. 또 any Error의 박싱 비용이 없어 임베디드 Swift 같은 환경에서 성능상 유리합니다. 하지만 switch 완전성 때문에 에러 케이스를 하나 추가하면 호출부가 깨지므로 API 진화에 불리하고, 공개 API에서는 소스 호환성을 깨는 변경이 됩니다. 그래서 Apple 공식 가이드도 기본은 타입 미지정 throws를 권장하며, 공개 라이브러리에는 기존 throws를, throws(E)는 모듈 내부나 실패 종류가 닫혀 있는 함수, 제네릭 에러 전달에 씁니다. 참고로 throws(Never)는 throws가 없는 것과 같습니다.',
 'interview-question/1133.mp3'),
(1134, 'SWIFT', 227, 'EASY', true,
 'Swift의 throws와 try를 이용한 에러 처리 방식은 어떤 특징을 가지나요?',
 '실패할 수 있는 함수는 throws로 그 사실을 시그니처에 드러내고, 호출부는 반드시 try를 붙여야 하므로 try를 빼먹으면 컴파일 오류가 됩니다. 즉 실패 가능성을 잊는 것이 컴파일 단계에서 막히고, 실패 경로가 정적으로 추적됩니다. 문법은 예외와 비슷하지만 Java·C++ 예외와 달리 런타임 스택 풀기(unwinding)가 없고, 컴파일러가 에러를 특별한 반환 값처럼 처리하는 값 기반 전파라서 오버헤드가 작고 어디서 던져질 수 있는지가 코드에 드러납니다. 던지는 에러는 Error 프로토콜을 채택한 아무 타입이나 될 수 있고, 관례적으로 열거형으로 정의합니다. 한편 배열 인덱스 초과나 강제 언래핑 실패 같은 프로그래머 오류는 throw되지 않고 즉시 크래시합니다.',
 'interview-question/1134.mp3'),
(1135, 'SWIFT', 227, 'EASY', true,
 'Swift에서 try, try?, try!는 에러가 발생했을 때 각각 어떻게 동작하나요?',
 'try는 기본 형태로, 에러가 발생하면 현재 스코프의 catch로 넘어가거나 함수 밖으로 전파됩니다. 처리하거나 위로 올릴 때 사용합니다. try?는 에러를 버리고 nil을 반환하므로 결과가 옵셔널이 되며, 실패 이유가 중요하지 않고 없으면 말고가 자연스러울 때 적합합니다. try!는 에러가 발생하면 크래시하므로 번들 리소스 로드처럼 실패가 곧 프로그래머 오류인 경우에만 쓰고, 외부 입력 처리에는 사용하면 안 됩니다. 덧붙여 defer 블록은 에러가 던져져도 스코프를 벗어날 때 반드시 실행되므로 파일 닫기나 락 해제 같은 정리 작업에 사용합니다.',
 'interview-question/1135.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1131
(6063, 1131, '현재 계층에서 의미 있게 처리할 수 없는 에러는 throws로 그대로 전파함을 설명', 'ESSENTIAL', 1),
(6064, 1131, '계층 경계에서 저수준 에러를 도메인 에러로 감싸 변환함을 설명', 'ESSENTIAL', 2),
(6065, 1131, '캐시 폴백·재시도·기본값 대체처럼 대안이 있는 곳에서만 에러를 잡아 복구함을 설명', 'ESSENTIAL', 3),
(6066, 1131, 'try?나 빈 catch가 실패 원인을 삼키는 안티패턴임을 언급', 'ESSENTIAL', 4),
(6067, 1131, '변환 시 원인 에러를 연관값(underlying)으로 보존해 디버깅 정보를 유지함을 언급', 'SUPPLEMENTARY', 5),
(6068, 1131, 'UI 계층에서 사용자 메시지·로그로 에러를 최종 처리함을 언급', 'SUPPLEMENTARY', 6),
(6069, 1131, '프로그래머 오류는 throw하지 않고 precondition·fatalError로 즉시 실패시킴을 언급', 'SUPPLEMENTARY', 7),

-- 질문 1132
(6070, 1132, 'throws는 제어 흐름이고 Result는 실패를 값으로 보관하는 장치라는 차이를 설명', 'ESSENTIAL', 1),
(6071, 1132, '기본 선택은 throws이고 Result는 특수 상황에만 쓴다고 언급', 'ESSENTIAL', 2),
(6072, 1132, '콜백 API·부분 실패 수집·결과 캐싱 중 최소 1개를 Result가 적합한 상황으로 제시', 'ESSENTIAL', 3),
(6073, 1132, 'async/await 도입 이후 Result의 필요성이 크게 감소했음을 언급', 'SUPPLEMENTARY', 4),
(6074, 1132, 'Result의 get()으로 다시 throws 제어 흐름으로 되돌릴 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1133
(6075, 1133, 'throws(E)는 던질 수 있는 에러 타입을 구체 타입 하나로 제한함을 설명', 'ESSENTIAL', 1),
(6076, 1133, 'catch에서 switch로 완전성 검사가 가능해 as? 캐스팅이 필요 없어짐을 언급', 'ESSENTIAL', 2),
(6077, 1133, '에러 케이스를 추가하면 호출부가 깨져 API 진화에 불리함을 언급', 'ESSENTIAL', 3),
(6078, 1133, '공개 API에는 기존 타입 미지정 throws가 권장됨을 언급', 'ESSENTIAL', 4),
(6079, 1133, '타입 지정 throws는 박싱 비용이 없어 성능상 유리함을 언급', 'SUPPLEMENTARY', 5),
(6080, 1133, 'throws(Never)는 throws가 없는 것과 같음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1134
(6081, 1134, 'throws가 실패 가능성을 함수 시그니처에 드러낸다고 언급', 'ESSENTIAL', 1),
(6082, 1134, 'throws 함수 호출부에 try를 붙이지 않으면 컴파일 오류가 됨을 언급', 'ESSENTIAL', 2),
(6083, 1134, 'Swift 에러 전파에는 Java·C++ 예외와 달리 스택 풀기(unwinding)가 없음을 언급', 'ESSENTIAL', 3),
(6084, 1134, '컴파일러가 에러를 특별한 반환 값처럼 처리해 오버헤드가 작음을 언급', 'SUPPLEMENTARY', 4),
(6085, 1134, '배열 인덱스 초과 같은 프로그래머 오류는 throw되지 않고 즉시 크래시함을 언급', 'SUPPLEMENTARY', 5),
(6086, 1134, 'Swift 에러는 Error 프로토콜을 채택한 타입임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1135
(6087, 1135, 'try는 에러를 현재 스코프의 catch로 넘기거나 함수 밖으로 전파함을 설명', 'ESSENTIAL', 1),
(6088, 1135, 'try?는 에러를 버리고 nil을 반환함을 언급', 'ESSENTIAL', 2),
(6089, 1135, 'try!는 에러가 발생하면 크래시함을 언급', 'ESSENTIAL', 3),
(6090, 1135, 'try!는 외부 입력 처리에는 사용하면 안 됨을 언급', 'SUPPLEMENTARY', 4),
(6091, 1135, 'defer 블록은 에러가 던져져도 스코프를 벗어날 때 반드시 실행됨을 언급', 'SUPPLEMENTARY', 5);
