-- Unit: 제네릭과 associatedtype (Unit ID: 224)
-- Chapter: Swift (Chapter ID: 22)
-- Topic: SWIFT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-swift-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1116, 'SWIFT', 224, 'HARD', true,
 '의존성 주입을 위해 런타임에 다른 구현으로 교체할 수 있는 repository 프로퍼티를 설계할 때, some과 any 중 무엇을 쓰시겠습니까? 그 선택의 대가는 무엇이며, any로 보관한 값을 실제 처리 함수에서는 어떻게 다루는 것이 실무 관용구인지 설명해 주세요.',
 'repository처럼 런타임에 다른 구현으로 교체해 저장해야 하는 프로퍼티에는 some이 아니라 any를 써야 합니다. some은 구체 타입이 하나로 고정되기 때문에 실행 중 여러 타입이 올 수 있는 저장 위치에는 맞지 않고, 그래서 `let repository: any UserRepository`처럼 선언합니다. 그 대가는 성능입니다. any는 값을 컨테이너에 박싱하고 위트니스 테이블을 통한 간접 호출을 하므로 박싱·간접 호출 비용이 들고, 정적 디스패치와 특수화·인라이닝이 가능한 some보다 느리며 타입 정체성도 사라집니다. any로 보관한 값을 다룰 때는 Swift 5.7의 암묵적 existential 열기(SE-0352) 덕분에 any 값을 some 매개변수를 받는 함수에 그대로 넘길 수 있습니다. 그래서 any로 보관하다가 처리 함수에서는 some으로 받는 조합이 실무 관용구입니다. 원칙적으로 기본값은 some 또는 명시적 제네릭이고, any는 이질적 타입을 한 컬렉션에 담거나 프로퍼티에 런타임에 다른 구현을 교체해 저장할 때만 씁니다. 또 any 값끼리는 Equatable의 Self 요구사항이 성립하지 않아 ==로 비교할 수 없으므로, 비교가 필요하면 제네릭(some)으로 받거나 AnyHashable 같은 타입 소거 래퍼를 씁니다.',
 'interview-question/1116.mp3'),
(1117, 'SWIFT', 224, 'NORMAL', true,
 'Swift의 some(불투명 타입)과 any(existential 타입)는 어떤 차이가 있나요?',
 'some은 불투명 타입으로, 구체 타입이 하나로 고정되어 있고 컴파일러는 그 타입을 알지만 호출자에게는 숨깁니다. 타입 정체성이 유지되어 Self나 연관 타입 관계를 계속 추적할 수 있습니다. 반면 any는 existential 타입으로, 실행 중 여러 구체 타입이 올 수 있도록 값을 컨테이너에 박싱하며 타입 정체성은 사라집니다. 디스패치 방식도 다릅니다. some은 정적 디스패치라 특수화와 인라이닝이 가능해 빠르고, any는 위트니스 테이블을 통한 간접 호출이라 박싱·간접 호출 비용이 듭니다. 그래서 [any P]에는 서로 다른 타입을 섞어 담을 수 있지만, [some P]의 요소는 모두 같은 타입이어야 합니다. 대표 사례로 SwiftUI의 var body: some View는 수십 줄짜리 구체 타입을 숨기면서도 항상 같은 하나의 타입임을 보장하기 위해 some을 씁니다.',
 'interview-question/1117.mp3'),
(1118, 'SWIFT', 224, 'NORMAL', true,
 'Any 타입으로 값을 받는 함수 대신 제네릭 함수를 쓰면 어떤 점이 더 나은가요?',
 'Any로 받으면 어떤 타입이든 넣을 수 있지만 타입 안전성을 버리게 되고, 값을 꺼내 쓸 때 호출부에서 매번 캐스팅을 해야 합니다. 제네릭은 타입을 매개변수화해 같은 로직으로 어떤 타입이든 처리하면서도 컴파일 타임 타입 검사를 유지하므로 캐스팅이 필요 없습니다. 예를 들어 swapValues<T>(_ a: inout T, _ b: inout T)를 호출하면 타입 매개변수 T가 호출부 인자로부터 Int로 추론됩니다. 성능 면에서도 유리한데, 컴파일러가 실제 사용된 타입별로 코드를 생성하는 특수화를 수행할 수 있어 Any나 existential보다 빠릅니다. Array<Element>, Dictionary<Key, Value>, Optional<Wrapped> 같은 표준 라이브러리 컬렉션도 모두 제네릭 타입입니다.',
 'interview-question/1118.mp3'),
(1119, 'SWIFT', 224, 'EASY', true,
 'Swift 프로토콜의 associatedtype은 무엇이며, 채택하는 타입에서는 이를 어떻게 확정하나요?',
 'associatedtype은 프로토콜의 제네릭입니다. 프로토콜은 <T> 문법을 쓰지 않고, 대신 associatedtype으로 채택 타입이 나중에 정할 타입 자리를 선언합니다. 예를 들어 Container 프로토콜에 associatedtype Item을 두면 append(_ item: Item) 같은 요구사항에서 그 자리를 쓸 수 있고, 연관 타입에도 Equatable 같은 제약을 걸 수 있습니다. 채택 타입은 typealias Item = Int처럼 직접 적거나, append(_ item: Int) 같은 요구사항 구현의 시그니처로부터 컴파일러가 추론하게 해서 연관 타입을 확정합니다. 표준 라이브러리의 IteratorProtocol.Element나 Collection.Index가 대표적인 연관 타입입니다.',
 'interview-question/1119.mp3'),
(1120, 'SWIFT', 224, 'EASY', true,
 '제네릭의 제약 조건은 왜 필요하며, where 절은 어떤 경우에 사용하나요?',
 '아무 제약이 없는 T로는 비교·해싱·연산을 할 수 없고, 할 수 있는 일은 저장·전달뿐입니다. 그래서 제약은 제한이라기보다 능력 부여로 보는 편이 정확합니다. 예를 들어 <T: Comparable>로 제약을 걸어야 <, max(), sorted() 같은 기능을 쓸 수 있습니다. 필요한 최소 제약만 거는 것이 재사용성을 높입니다. where 절은 <T: P>로 표현할 수 없는 더 복잡한 관계, 예를 들어 where A.Element == B.Element처럼 두 연관 타입이 같아야 한다거나 연관 타입이 특정 프로토콜을 채택해야 한다는 조건을 표현할 때 씁니다. 조건부 확장에도 쓰여서, extension Array where Element: Numeric으로 요소가 숫자일 때만 sum()을 제공할 수 있습니다.',
 'interview-question/1120.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1116
(5983, 1116, '런타임에 다른 구현을 교체해 저장하는 프로퍼티에는 any가 필요함을 설명', 'ESSENTIAL', 1),
(5984, 1116, '박싱·위트니스 테이블 간접 호출 중 최소 1개를 any의 성능 비용으로 언급', 'ESSENTIAL', 2),
(5985, 1116, '암묵적 existential 열기로 any 값을 some 매개변수 함수에 그대로 넘길 수 있음을 설명', 'ESSENTIAL', 3),
(5986, 1116, '기본값은 some이고 any는 이질성이 필요할 때만 쓴다는 선택 기준을 제시', 'SUPPLEMENTARY', 4),
(5987, 1116, 'any 값끼리는 Equatable의 Self 요구사항 때문에 ==를 쓸 수 없음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1117
(5988, 1117, 'some은 구체 타입이 하나로 고정됨을 설명', 'ESSENTIAL', 1),
(5989, 1117, 'any는 실행 중 여러 구체 타입이 올 수 있도록 값을 담는 박스임을 설명', 'ESSENTIAL', 2),
(5990, 1117, 'some의 정적 디스패치와 any의 위트니스 테이블 간접 호출을 구분', 'ESSENTIAL', 3),
(5991, 1117, 'some의 구체 타입은 컴파일러는 알지만 호출자에게는 숨겨짐을 언급', 'SUPPLEMENTARY', 4),
(5992, 1117, '[any P]에는 서로 다른 타입을 섞을 수 있지만 [some P]는 모두 같은 타입이어야 함을 언급', 'SUPPLEMENTARY', 5),
(5993, 1117, 'SwiftUI의 var body: some View를 some의 대표 사례로 제시', 'SUPPLEMENTARY', 6),

-- 질문 1118
(5994, 1118, '제네릭은 컴파일 타임 타입 검사를 유지해 타입 안전성을 지킨다고 설명', 'ESSENTIAL', 1),
(5995, 1118, 'Any로 받으면 호출부에서 캐스팅이 필요하지만 제네릭은 캐스팅이 불필요함을 언급', 'ESSENTIAL', 2),
(5996, 1118, '컴파일러가 사용된 타입별로 코드를 생성하는 특수화로 Any보다 빠르다고 설명', 'ESSENTIAL', 3),
(5997, 1118, '타입 매개변수 T가 호출부의 인자로부터 추론됨을 언급', 'SUPPLEMENTARY', 4),
(5998, 1118, 'Array·Dictionary·Optional 중 최소 1개를 표준 라이브러리 제네릭 타입 예로 제시', 'SUPPLEMENTARY', 5),

-- 질문 1119
(5999, 1119, 'associatedtype은 채택 타입이 나중에 정할 타입 자리를 프로토콜에 선언하는 것임을 설명', 'ESSENTIAL', 1),
(6000, 1119, 'typealias·시그니처 기반 추론 중 최소 1개를 채택 타입의 연관 타입 확정 방법으로 제시', 'ESSENTIAL', 2),
(6001, 1119, '프로토콜은 <T> 문법 대신 associatedtype으로 제네릭을 표현함을 언급', 'SUPPLEMENTARY', 3),
(6002, 1119, 'IteratorProtocol.Element·Collection.Index 중 최소 1개를 연관 타입 예로 제시', 'SUPPLEMENTARY', 4),
(6003, 1119, '연관 타입에도 Equatable 같은 제약을 걸 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1120
(6004, 1120, 'Comparable 같은 제약을 걸어야 <·max() 등 그 능력을 쓸 수 있다고 설명', 'ESSENTIAL', 1),
(6005, 1120, 'where 절은 연관 타입 간 동일성처럼 <T: P>로 표현 못 하는 관계에 쓴다고 설명', 'ESSENTIAL', 2),
(6006, 1120, '제약이 없는 T로 할 수 있는 일은 저장·전달뿐임을 언급', 'SUPPLEMENTARY', 3),
(6007, 1120, '요소가 Numeric일 때만 sum을 제공하는 조건부 확장을 where 절 예로 제시', 'SUPPLEMENTARY', 4),
(6008, 1120, '필요한 최소 제약만 거는 것이 재사용성을 높인다고 언급', 'SUPPLEMENTARY', 5);
