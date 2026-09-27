-- Unit: 옵셔널 처리 전략 (Unit ID: 222)
-- Chapter: Swift (Chapter ID: 22)
-- Topic: SWIFT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-swift-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(1106, 'SWIFT', 222, 'HARD', true,
 '서버 JSON 응답을 파싱해 도메인 모델을 만드는 코드에서 옵셔널을 어떻게 처리하시겠어요? 강제 언래핑을 쓰면 어떤 문제가 생기고, 어떤 대안을 택하실지 설명해 주세요.',
 '서버 응답처럼 네트워크·파일·사용자 입력에서 온 값은 언제든 형식이 깨질 수 있으므로 강제 언래핑을 쓰지 않습니다. `!`는 여기엔 반드시 값이 있다는 단언이라, 실제로 nil이면 ''Unexpectedly found nil while unwrapping an Optional value'' Fatal error로 앱이 즉시 종료되고, 컴파일러가 잡아 주던 안전성을 스스로 포기하게 됩니다. 게다가 스택 트레이스는 언래핑 지점만 가리키고 nil이 만들어진 근본 원인은 다른 곳에 있어 원인 추적이 어렵습니다. 그래서 옵셔널은 경계에서 최대한 빨리 해소합니다. 디코딩·파싱 단계에서 guard let으로 필요한 값을 검증하고 없으면 조기 탈출하면, 이후 계층의 도메인 모델은 비옵셔널로 유지되어 옵셔널을 몰라도 됩니다. 타입 캐스팅도 `as!` 대신 `json["age"] as? Int ?? 0`처럼 조건부 캐스팅과 기본값을 조합합니다. 정말 nil이면 버그인 내부 불변 조건이라 크래시가 나야 한다면, `guard let ... else { preconditionFailure("userId가 nil — 로그인 상태 확인 필요") }`처럼 메시지가 있는 실패로 대체해 의도를 명시합니다.'),
(1107, 'SWIFT', 222, 'NORMAL', true,
 'Swift에서 if let과 guard let은 어떤 차이가 있고, 각각 언제 사용하는 것이 적합한가요?',
 '둘 다 옵셔널 바인딩으로, 값이 있으면 새 상수에 꺼내 담고 없으면 분기합니다. 핵심 차이는 스코프입니다. if let으로 바인딩한 상수는 if 블록 안에서만 쓰이지만, guard let으로 바인딩한 상수는 guard 문 이후 스코프 전체에서 유효합니다. 대신 guard의 else 블록은 return, throw, continue, break, fatalError 등으로 반드시 스코프를 벗어나야 하며, 그렇지 않으면 ''guard body must not fall through'' 컴파일 오류가 납니다. 그래서 if let은 값의 유무에 따라 양쪽 모두 처리 로직이 있을 때 적합하고, guard let은 값이 없으면 더 진행할 수 없는 전제 조건을 함수 초입에서 검사하는 조기 탈출 용도에 적합합니다. guard로 실패 조건을 위에서 걸러내면 if let 중첩으로 생기는 피라미드가 사라지고 정상 흐름이 평탄하게 정렬됩니다. 참고로 Swift 5.7부터는 같은 이름일 때 `if let name`처럼 축약해서 쓸 수 있습니다.'),
(1108, 'SWIFT', 222, 'NORMAL', true,
 '옵셔널 체이닝(?.)과 nil 병합 연산자(??)는 값이 없을 때 각각 어떻게 동작하며, 어떤 상황에 사용하나요?',
 '옵셔널 체이닝은 `?.`로 연결한 식에서 중간에 하나라도 nil이면 식 전체가 nil로 평가되고 이후 호출은 건너뜁니다. 그래서 결과 타입은 항상 옵셔널이며, `user?.address?.city?.count`처럼 체인이 길어도 옵셔널이 중첩되지 않고 `Int?` 한 겹으로 평탄화됩니다. 메서드 호출에도 적용되어 `delegate?.didFinish()`는 delegate가 nil이면 호출 자체가 생략됩니다. 반면 `??` nil 병합 연산자는 왼쪽 값이 없을 때 오른쪽의 기본값을 사용합니다. 오른쪽 피연산자는 @autoclosure라 왼쪽이 nil일 때만 평가됩니다. 따라서 체이닝은 깊은 프로퍼티 접근이나 선택적 delegate 호출처럼 없으면 nil로 계속 흘려보내면 되는 상황에, `??`는 포트 번호 기본값 8080처럼 합리적인 기본값이 존재하는 상황에 사용합니다.'),
(1109, 'SWIFT', 222, 'EASY', true,
 'Swift 옵셔널의 실제 정체는 무엇이며, 옵셔널이 널 참조 오류에 대해 안전한 이유는 무엇인가요?',
 '옵셔널은 표준 라이브러리의 제네릭 열거형 `Optional<Wrapped>`입니다. `Int?`는 `Optional<Int>`의 문법 설탕일 뿐이고, 케이스는 두 개로 값이 없음을 뜻하는 nil은 `.none` 케이스, 값이 있으면 `.some(값)`으로 감싸져 있습니다. 즉 옵셔널 값은 상자에 담긴 상태라 그대로 산술이나 메서드 호출을 할 수 없고 반드시 언래핑을 거쳐야 합니다. 안전한 이유는 값의 부재 가능성을 타입으로 표현하기 때문입니다. 컴파일러가 언래핑을 강제하므로 처리 누락이 컴파일 오류가 되고, 그 결과 널 참조 문제가 런타임 크래시가 아니라 컴파일 시점의 오류로 드러납니다.'),
(1110, 'SWIFT', 222, 'EASY', true,
 '암시적 언래핑 옵셔널(IUO)이란 무엇이며, 어떤 곳에서 사용하나요?',
 '암시적 언래핑 옵셔널은 `Int!`처럼 선언하는 옵셔널로, 접근할 때마다 자동으로 `!`가 붙어 강제 언래핑됩니다. 그래서 값이 nil인 상태에서 접근하면 강제 언래핑과 마찬가지로 크래시가 납니다. 따라서 초기화 직후에는 nil이지만 사용 시점에는 값이 반드시 있다고 보장되는 곳에서만 사용합니다. 대표적인 예가 프레임워크가 주입을 보장하는 `@IBOutlet`이며, 이 경우에도 뷰 로드 전에 접근하지 않도록 주의해야 합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1106
(5931, 1106, '네트워크·파일·사용자 입력 같은 외부 데이터에는 강제 언래핑을 금지해야 함을 명시', 'ESSENTIAL', 1),
(5932, 1106, '강제 언래핑한 값이 nil이면 Fatal error로 앱이 즉시 종료됨을 언급', 'ESSENTIAL', 2),
(5933, 1106, '디코딩·파싱 경계에서 guard let으로 옵셔널을 조기 해소해 내부 모델을 비옵셔널로 유지함을 설명', 'ESSENTIAL', 3),
(5934, 1106, 'as! 대신 as? 조건부 캐스팅과 ?? 기본값을 조합하는 대안을 제시', 'SUPPLEMENTARY', 4),
(5935, 1106, '! 크래시의 스택 트레이스는 언래핑 지점만 가리켜 nil의 근본 원인이 드러나지 않음을 언급', 'SUPPLEMENTARY', 5),
(5936, 1106, 'nil이면 버그인 내부 불변 조건에서는 preconditionFailure처럼 메시지가 있는 실패로 대체함을 제시', 'SUPPLEMENTARY', 6),

-- 질문 1107
(5937, 1107, 'guard let으로 바인딩한 상수는 guard 문 이후 스코프 전체에서 유효함을 설명', 'ESSENTIAL', 1),
(5938, 1107, 'guard의 else 블록은 return·throw 등으로 반드시 스코프를 벗어나야 함을 명시', 'ESSENTIAL', 2),
(5939, 1107, 'if let은 값의 유무에 따라 양쪽 모두 처리 로직이 있을 때 적합함을 언급', 'ESSENTIAL', 3),
(5940, 1107, 'guard let은 없으면 더 진행할 수 없는 전제 조건을 함수 초입에서 검사할 때 적합함을 언급', 'ESSENTIAL', 4),
(5941, 1107, 'guard가 if let 중첩 피라미드를 없애 정상 흐름을 평탄하게 만든다고 설명', 'SUPPLEMENTARY', 5),
(5942, 1107, 'Swift 5.7부터 같은 이름일 때 if let name 형태의 축약이 가능함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1108
(5943, 1108, '옵셔널 체이닝은 중간에 하나라도 nil이면 식 전체가 nil로 평가됨을 설명', 'ESSENTIAL', 1),
(5944, 1108, '?? 연산자는 값이 없을 때 지정한 기본값을 사용함을 설명', 'ESSENTIAL', 2),
(5945, 1108, '체이닝은 깊은 프로퍼티 접근에, ??는 합리적 기본값이 존재할 때 적합함을 구분', 'ESSENTIAL', 3),
(5946, 1108, '체인이 길어도 결과 옵셔널이 중첩되지 않고 한 겹으로 평탄화됨을 언급', 'SUPPLEMENTARY', 4),
(5947, 1108, '??의 오른쪽 피연산자는 @autoclosure라 왼쪽이 nil일 때만 평가됨을 언급', 'SUPPLEMENTARY', 5),
(5948, 1108, 'delegate?.didFinish()처럼 대상이 nil이면 메서드 호출 자체가 생략됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1109
(5949, 1109, '옵셔널이 제네릭 열거형 Optional<Wrapped>임을 언급', 'ESSENTIAL', 1),
(5950, 1109, 'nil은 .none 케이스이고 값이 있으면 .some(값)으로 감싸짐을 설명', 'ESSENTIAL', 2),
(5951, 1109, '값의 부재 가능성을 타입으로 표현해 컴파일러가 언래핑을 강제함을 설명', 'ESSENTIAL', 3),
(5952, 1109, 'Int?는 Optional<Int>의 문법 설탕(syntactic sugar)임을 언급', 'SUPPLEMENTARY', 4),
(5953, 1109, '널 참조가 런타임 크래시가 아니라 컴파일 오류로 드러남을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1110
(5954, 1110, 'IUO는 접근할 때마다 자동으로 !가 붙는 옵셔널임을 설명', 'ESSENTIAL', 1),
(5955, 1110, '초기화 직후엔 nil이지만 사용 시점엔 값이 반드시 있다고 보장되는 곳에서만 쓴다고 언급', 'ESSENTIAL', 2),
(5956, 1110, 'IUO의 대표적 사용처로 @IBOutlet을 제시', 'SUPPLEMENTARY', 3),
(5957, 1110, '뷰 로드 전에 IBOutlet에 접근하지 않도록 주의해야 함을 언급', 'SUPPLEMENTARY', 4);
