-- Unit: ARC와 순환 참조 (Unit ID: 221)
-- Chapter: Swift (Chapter ID: 22)
-- Topic: SWIFT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-swift-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1101, 'SWIFT', 221, 'HARD', true,
 '클래스가 완료 콜백 클로저를 프로퍼티로 저장하고, 그 클로저 안에서 self를 사용하고 있습니다. 이때 어떤 메모리 문제가 생길 수 있고, 캡처 리스트로 해결할 때 weak와 unowned 중 무엇을 선택하며 각각의 대가는 무엇인지 설명해 주세요.',
 '클로저는 참조 타입이고 본문에서 사용하는 외부 변수를 강하게 캡처합니다. 클래스 인스턴스가 클로저를 프로퍼티로 저장하고 그 클로저가 self를 캡처하면 self → 클로저 → self 순환이 생겨, 외부 참조를 모두 끊어도 참조 카운트가 0이 되지 않아 인스턴스가 해제되지 않는 메모리 누수가 발생합니다. 해결은 캡처 리스트로 캡처 방식을 지정하는 것입니다. [weak self]로 캡처하면 참조 카운트가 증가하지 않고, 클로저 안의 self는 옵셔널이 되므로 guard let self로 언래핑해 사용합니다. 클로저 실행 시점에 이미 해제됐다면 조용히 빠져나가므로 안전하지만, weak는 런타임이 사이드 테이블로 추적하므로 약간의 비용이 있습니다. [unowned self]는 언래핑이 필요 없고 그 비용도 없지만 안전장치가 없어서, self가 먼저 해제된 뒤 클로저가 실행되면 크래시합니다. 따라서 unowned는 클로저 수명이 self보다 짧다고 확실할 때만 쓰고, 확신이 없으면 weak를 선택하는 것이 안전합니다. 참고로 DispatchQueue.main.async처럼 클로저를 저장하지 않고 즉시 실행 후 버리는 경우에는 순환이 생기지 않으므로 모든 클로저에 [weak self]를 붙일 필요는 없습니다.',
 'interview-question/1101.mp3'),
(1102, 'SWIFT', 221, 'NORMAL', true,
 'Swift의 ARC와 Java 같은 언어의 추적 GC는 메모리 관리 방식에서 어떤 차이가 있나요?',
 'ARC는 참조 카운팅 기반의 자동 메모리 관리입니다. 추적 GC처럼 런타임이 도달 가능성을 분석하지 않고, 컴파일러가 컴파일 시점에 삽입한 retain/release 코드로 동작합니다. 그래서 해제 시점이 다릅니다. ARC는 참조 카운트가 0이 되는 즉시 해제되어 결정적이고, 추적 GC는 GC가 실행되는 시점에 해제되어 비결정적입니다. 가장 큰 차이는 순환 참조 처리입니다. 추적 GC는 서로 참조하더라도 도달 불가능하면 자동으로 회수하지만, ARC는 순환 참조를 스스로 회수하지 못하므로 개발자가 weak나 unowned로 끊어야 합니다. 비용 측면에서 ARC는 참조 대입마다 원자적 증감 비용이 들고, 추적 GC는 주기적으로 힙을 스캔하며 일시 정지(STW)가 생길 수 있습니다. 메모리 사용량은 ARC가 낮고 안정적인 반면, 추적 GC는 스캔 전까지 쓰레기가 남아 상대적으로 높습니다.',
 'interview-question/1102.mp3'),
(1103, 'SWIFT', 221, 'NORMAL', true,
 'Swift에서 weak 참조와 unowned 참조의 차이는 무엇인가요?',
 'weak와 unowned는 둘 다 참조 카운트를 증가시키지 않아 순환 참조를 끊는 데 쓰입니다. 차이는 대상이 해제됐을 때의 동작입니다. weak는 대상이 해제되면 자동으로 nil이 되지만, unowned는 댕글링 참조가 되어 접근 시 크래시합니다. 이 때문에 선언 타입도 다릅니다. weak는 nil이 될 수 있으므로 반드시 옵셔널 var로 선언해야 하고, unowned는 비옵셔널로 선언할 수 있고 let도 가능합니다. 사용 상황으로 보면 weak는 상대가 먼저 사라질 수 있을 때, 예를 들어 delegate나 자식 → 부모 참조에 씁니다. unowned는 상대의 수명이 나와 같거나 더 길다고 확신할 때, 예를 들어 신용카드 → 고객 관계처럼 카드가 고객 없이 존재할 수 없는 경우에 씁니다. 확신이 없으면 weak를 쓰고 옵셔널 바인딩으로 처리하는 것이 안전합니다.',
 'interview-question/1103.mp3'),
(1104, 'SWIFT', 221, 'EASY', true,
 '순환 참조(Retain Cycle)란 무엇이며, ARC 환경에서 왜 메모리 누수로 이어지는지 설명해 주세요.',
 '순환 참조는 두 인스턴스가 서로를 강한 참조로 붙잡고 있는 상태입니다. 예를 들어 Person이 apartment 프로퍼티로 Apartment를 강하게 참조하고, Apartment가 tenant 프로퍼티로 Person을 강하게 참조하는 경우입니다. ARC는 참조 카운트가 0이 될 때 인스턴스를 해제하는데, 이 상태에서는 외부 변수 p와 apt를 nil로 끊어도 서로가 서로를 붙잡고 있어 각자의 참조 카운트가 1로 남고 0이 되지 않습니다. 그래서 deinit이 호출되지 않고 인스턴스가 영원히 해제되지 않아 메모리 누수가 됩니다. 이것이 Swift에서 메모리 누수의 가장 흔한 원인입니다. 해결하려면 한쪽 참조, 예를 들어 Apartment.tenant를 weak var로 바꾸면 순환이 끊어져 두 deinit이 모두 호출됩니다. 설계 단계에서는 소유자를 하나만 정하고 부모 → 자식은 strong, 자식 → 부모는 weak로 두는 것이 원칙입니다.',
 'interview-question/1104.mp3'),
(1105, 'SWIFT', 221, 'EASY', true,
 'Swift의 ARC(Automatic Reference Counting)는 어떻게 동작하나요?',
 'ARC는 Swift가 클래스 같은 참조 타입의 메모리를 관리하는 방식입니다. 클래스 인스턴스가 힙에 생성되면 참조 카운트가 1로 시작하고, 그 인스턴스를 가리키는 강한 참조가 생길 때마다 +1, 참조가 사라질 때마다 −1이 됩니다. 참조 카운트가 0이 되는 순간 즉시 deinit이 호출되고 메모리가 해제됩니다. 이 카운트 증감을 위한 retain/release 코드는 컴파일러가 컴파일 시점에 삽입하므로, 가비지 컬렉터처럼 런타임에 별도의 수집 스레드가 돌지 않습니다. 또한 ARC는 참조 타입만 대상으로 하며 값 타입은 ARC 대상이 아닙니다.',
 'interview-question/1105.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1101
(5904, 1101, 'self → 클로저 → self 순환이 생겨 인스턴스가 해제되지 않음을 설명', 'ESSENTIAL', 1),
(5905, 1101, '[weak self]로 캡처하면 클로저 안의 self가 옵셔널이 됨을 언급', 'ESSENTIAL', 2),
(5906, 1101, '[unowned self]는 self가 먼저 해제된 뒤 클로저가 실행되면 크래시함을 언급', 'ESSENTIAL', 3),
(5907, 1101, 'self의 수명을 확신할 수 없으면 unowned 대신 weak를 선택해야 함을 제시', 'ESSENTIAL', 4),
(5908, 1101, 'weak로 캡처한 self가 클로저 실행 시점에 이미 해제됐으면 조용히 빠져나감을 언급', 'SUPPLEMENTARY', 5),
(5909, 1101, '저장되지 않고 즉시 실행 후 버려지는 클로저는 순환이 생기지 않음을 언급', 'SUPPLEMENTARY', 6),
(5910, 1101, 'weak는 런타임이 사이드 테이블로 추적해 약간의 비용이 있음을 언급', 'SUPPLEMENTARY', 7),

-- 질문 1102
(5911, 1102, 'ARC는 카운트 0이 되는 즉시 해제되고 추적 GC는 GC 실행 시점에 해제되는 차이를 설명', 'ESSENTIAL', 1),
(5912, 1102, 'ARC는 순환 참조를 회수하지 못하지만 추적 GC는 도달 불가능하면 자동 회수하는 차이를 설명', 'ESSENTIAL', 2),
(5913, 1102, 'ARC는 런타임이 도달 가능성을 분석하지 않고 컴파일러가 삽입한 코드로 동작함을 언급', 'ESSENTIAL', 3),
(5914, 1102, '추적 GC는 주기적 힙 스캔으로 일시 정지(STW)가 생길 수 있음을 언급', 'SUPPLEMENTARY', 4),
(5915, 1102, 'ARC는 추적 GC보다 메모리 사용량이 낮고 안정적임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1103
(5916, 1103, 'weak와 unowned 모두 참조 카운트를 증가시키지 않음을 언급', 'ESSENTIAL', 1),
(5917, 1103, 'weak는 대상이 해제되면 자동으로 nil이 되고 unowned는 접근 시 크래시하는 차이를 설명', 'ESSENTIAL', 2),
(5918, 1103, 'weak는 반드시 옵셔널 var로 선언해야 하고 unowned는 비옵셔널도 가능한 차이를 설명', 'ESSENTIAL', 3),
(5919, 1103, 'unowned는 상대의 수명이 나와 같거나 더 길다고 확신할 때 사용함을 제시', 'SUPPLEMENTARY', 4),
(5920, 1103, 'delegate나 자식 → 부모 참조를 weak의 대표 사용 예시로 제시', 'SUPPLEMENTARY', 5),

-- 질문 1104
(5921, 1104, '두 인스턴스가 서로를 강한 참조로 붙잡는 상태를 순환 참조로 설명', 'ESSENTIAL', 1),
(5922, 1104, '외부 참조를 모두 끊어도 서로의 참조 카운트가 0이 되지 않음을 설명', 'ESSENTIAL', 2),
(5923, 1104, '순환 참조된 인스턴스는 영원히 해제되지 않아 메모리 누수가 됨을 언급', 'ESSENTIAL', 3),
(5924, 1104, '한쪽 참조를 weak로 바꾸면 순환이 끊어져 두 인스턴스가 해제됨을 언급', 'SUPPLEMENTARY', 4),
(5925, 1104, '부모 → 자식은 strong, 자식 → 부모는 weak로 두는 소유 원칙을 제시', 'SUPPLEMENTARY', 5),

-- 질문 1105
(5926, 1105, '강한 참조가 생기면 참조 카운트가 +1, 사라지면 −1 됨을 설명', 'ESSENTIAL', 1),
(5927, 1105, '참조 카운트가 0이 되는 순간 즉시 deinit이 호출되고 메모리가 해제됨을 설명', 'ESSENTIAL', 2),
(5928, 1105, 'retain/release 코드를 컴파일러가 컴파일 시점에 삽입함을 언급', 'ESSENTIAL', 3),
(5929, 1105, '런타임에 별도의 수집 스레드가 돌지 않음을 언급', 'SUPPLEMENTARY', 4),
(5930, 1105, '값 타입은 ARC 대상이 아님을 언급', 'SUPPLEMENTARY', 5);
