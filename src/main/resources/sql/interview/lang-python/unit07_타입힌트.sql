-- Unit: 타입 힌트 (Unit ID: 218)
-- Chapter: Python (Chapter ID: 21)
-- Topic: PYTHON
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-python-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1086, 'PYTHON', 218, 'HARD', true,
 '외부 HTTP 요청을 받는 파이썬 서비스에서 함수에 타입 힌트를 달아 두면 잘못된 타입의 입력을 막을 수 있을까요? 정적 검사기와 런타임 검증을 어디에 어떻게 나눠 적용할지 설명해 주세요.',
 '타입 힌트만으로는 막을 수 없습니다. 파이썬 인터프리터는 힌트를 __annotations__에 저장할 뿐 검사하지 않기 때문에, int로 선언한 인자에 문자열이 들어와도 오류 없이 그대로 실행됩니다. 그래서 검증 책임을 나눠야 합니다. HTTP 요청, 파일, 환경 변수 같은 외부 입력 경계에서는 pydantic처럼 힌트를 읽어 입력 데이터를 실제로 검사·변환하는 런타임 검증 도구를 사용합니다. 참고로 pydantic은 기본 lax 모드에서 "42"를 42로 강제 변환하고, strict=True를 주면 정확히 일치하는 타입만 허용합니다. 반면 내부 호출은 mypy나 pyright 같은 정적 검사기에 맡겨 실행 전에 타입 오류를 잡습니다. 정적 검사기는 CI 단계에서 실행해 오류가 있으면 파이프라인을 실패시키는 식으로 운영합니다. 모든 호출에 런타임 검사를 넣으면 성능 비용이 크기 때문에, 경계에서만 런타임 검증을 하고 내부는 정적 검사기에 맡기는 것이 성능과 안전의 균형점입니다.',
 'interview-question/1086.mp3'),
(1087, 'PYTHON', 218, 'NORMAL', true,
 '파이썬에서 인터페이스를 정의할 때 abc.ABC와 typing.Protocol은 어떤 차이가 있고, 각각 어떤 상황에 적합한가요?',
 'abc.ABC는 상속으로 타입을 인정하는 명목적 타이핑이고, Protocol은 상속 없이 필요한 메서드가 있으면 그 타입으로 인정하는 구조적 타이핑입니다. Protocol은 덕 타이핑을 정적 검사기가 이해할 수 있게 만든 것이라고 볼 수 있습니다. abc.ABC는 인스턴스화를 차단하고 isinstance 검사도 가능하며, 내부 클래스 계층에 계약을 강제할 때 적합합니다. Protocol은 런타임 영향이 없고, 예를 들어 close 메서드만 있으면 파일·소켓·DB 커넥션을 모두 받을 수 있습니다. 그래서 외부 라이브러리 객체나 덕 타이핑 인터페이스에 적합합니다. Protocol도 runtime_checkable을 붙이면 isinstance 검사를 할 수 있습니다. 비슷한 구조적 도구로 TypedDict가 있는데, 런타임에는 그냥 dict이지만 JSON이나 API 응답의 키·값 타입을 명세할 때 씁니다.',
 'interview-question/1087.mp3'),
(1088, 'PYTHON', 218, 'NORMAL', true,
 '파이썬의 동적 타이핑과, 타입 힌트를 더한 점진적 타이핑은 타입 확정 시점과 오류 발견 시점 측면에서 어떻게 다른가요?',
 '타입 확정 시점부터 보면, 파이썬의 동적 타이핑에서는 타입이 실행 시에 확정됩니다. 변수가 아니라 객체가 타입을 가지기 때문에 같은 변수에 다른 타입을 얼마든지 담을 수 있습니다. 반면 점진적 타이핑은 타입 힌트를 원하는 곳에만 추가해 정적 검사를 붙이는 방식으로, mypy나 pyright 같은 검사기를 실행할 때 힌트가 있는 부분만 타입이 확정됩니다. 오류 발견 시점을 보면, 동적 타이핑에서는 타입 오류를 실행 중 TypeError로만 발견합니다. 점진적 타이핑에서는 검사기가 실행 전에 타입 오류를 리포트하므로 먼저 발견할 수 있고, 실행 중 TypeError도 여전히 발생할 수 있습니다. 또한 힌트는 강제되지 않기 때문에 힌트가 없는 코드도 정상적으로 실행되며, 필요한 곳만 제약을 걸 수 있습니다.',
 'interview-question/1088.mp3'),
(1089, 'PYTHON', 218, 'EASY', true,
 '파이썬 타입 힌트는 런타임에 강제되지 않는데, 언어가 이렇게 설계된 이유는 무엇인가요?',
 '이렇게 설계된 이유는 크게 세 가지입니다. 첫째, 모든 호출마다 isinstance 검사를 넣으면 성능 비용이 큽니다. 둘째, 덕 타이핑이나 제네릭, Protocol처럼 런타임에 검사할 수 없는 타입이 많습니다. 셋째, 기존 코드와의 하위 호환 때문입니다. 힌트를 추가해도 동작이 바뀌지 않아야 점진적 도입이 가능합니다. 실제로 힌트는 함수·모듈·클래스의 __annotations__ 딕셔너리에 저장될 뿐 호출 경로에는 관여하지 않습니다. 결국 언어 설계 철학상 힌트는 도구를 위한 메타데이터이고, 검증은 mypy·pyright 같은 정적 검사기나 pydantic 같은 라이브러리의 몫으로 분리되어 있습니다.',
 'interview-question/1089.mp3'),
(1090, 'PYTHON', 218, 'EASY', true,
 '정적 검사기의 타입 좁히기(Narrowing)란 무엇이고, str | None을 반환하는 함수의 결과를 안전하게 다루려면 어떻게 해야 하나요?',
 '타입 좁히기는 정적 검사기가 isinstance, is None, assert, match 같은 조건문을 따라가며 분기 안에서 변수의 타입을 더 구체적인 타입으로 좁히는 흐름 분석입니다. 예를 들어 str | None을 반환하는 함수의 결과에 바로 upper()를 호출하면 None에는 upper가 없으므로 검사기가 오류를 냅니다. 대신 if name is not None: 으로 감싸면 그 블록 안에서 name은 str로 좁혀져 검사를 통과합니다. 직접 좁히기 함수를 만들 때는 3.13부터 TypeIs, 3.10부터는 TypeGuard를 반환 타입으로 씁니다. 또 match 문의 마지막 case에서 assert_never를 호출해 두면 Literal에 새 값이 추가됐을 때 분기 누락을 검사기가 잡아냅니다.',
 'interview-question/1090.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1086
(5827, 1086, '인터프리터는 타입 힌트를 검사하지 않아 잘못된 타입이 들어와도 그대로 실행됨을 언급', 'ESSENTIAL', 1),
(5828, 1086, 'HTTP 요청 같은 외부 입력 경계는 pydantic 등 런타임 검증 도구로 검사한다고 제시', 'ESSENTIAL', 2),
(5829, 1086, '내부 호출은 mypy·pyright 같은 정적 검사기로 실행 전에 검사한다고 제시', 'ESSENTIAL', 3),
(5830, 1086, 'pydantic 기본(lax) 모드는 "42"를 42로 강제 변환한다고 언급', 'SUPPLEMENTARY', 4),
(5831, 1086, '정적 검사기를 CI 단계에서 실행해 오류 시 파이프라인을 실패시킨다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1087
(5832, 1087, 'abc.ABC는 상속 기반 명목적 타이핑, Protocol은 메서드 형태 기반 구조적 타이핑이라는 차이를 설명', 'ESSENTIAL', 1),
(5833, 1087, 'abc.ABC는 내부 클래스 계층에 계약을 강제하는 데 적합하다고 제시', 'ESSENTIAL', 2),
(5834, 1087, 'Protocol은 외부 라이브러리 객체나 덕 타이핑 인터페이스에 적합하다고 제시', 'ESSENTIAL', 3),
(5835, 1087, 'abc.ABC는 인스턴스화를 차단한다고 언급', 'SUPPLEMENTARY', 4),
(5836, 1087, 'Protocol은 runtime_checkable을 붙여야 isinstance 검사가 가능하다고 언급', 'SUPPLEMENTARY', 5),
(5837, 1087, 'TypedDict는 JSON·API 응답의 딕셔너리 키·값 타입 명세에 쓴다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1088
(5838, 1088, '동적 타이핑에서는 타입이 실행 시에 확정된다고 설명', 'ESSENTIAL', 1),
(5839, 1088, '점진적 타이핑에서는 검사기 실행 시 힌트 있는 부분만 타입이 확정된다고 설명', 'ESSENTIAL', 2),
(5840, 1088, '동적 타이핑에서는 타입 오류를 실행 중 TypeError로 발견한다고 설명', 'ESSENTIAL', 3),
(5841, 1088, '점진적 타이핑에서는 검사기가 실행 전에 타입 오류를 리포트한다고 설명', 'ESSENTIAL', 4),
(5842, 1088, '동적 타이핑에서는 변수가 아니라 객체가 타입을 가진다고 언급', 'SUPPLEMENTARY', 5),
(5843, 1088, '점진적 타이핑에서 힌트는 강제되지 않아 힌트 없는 코드도 정상 실행된다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1089
(5844, 1089, '모든 호출마다 isinstance 검사를 넣으면 성능 비용이 크다는 점을 이유로 제시', 'ESSENTIAL', 1),
(5845, 1089, '덕 타이핑·제네릭·Protocol처럼 런타임 검사가 불가능한 타입이 많다는 점을 이유로 제시', 'ESSENTIAL', 2),
(5846, 1089, '힌트를 추가해도 동작이 바뀌지 않아야 하는 하위 호환을 이유로 제시', 'ESSENTIAL', 3),
(5847, 1089, '힌트는 __annotations__ 딕셔너리에 저장될 뿐 호출 경로에 관여하지 않는다고 언급', 'SUPPLEMENTARY', 4),
(5848, 1089, '힌트는 도구를 위한 메타데이터이고 검증은 검사기·라이브러리 몫이라고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1090
(5849, 1090, '검사기가 isinstance·is None 같은 조건문을 따라 분기 안에서 타입을 좁힌다고 설명', 'ESSENTIAL', 1),
(5850, 1090, 'str | None 반환값은 is not None 검사 후 그 블록 안에서 str로 좁혀진다고 제시', 'ESSENTIAL', 2),
(5851, 1090, 'assert_never로 Literal 분기 누락을 검사기가 잡아낸다고 언급', 'SUPPLEMENTARY', 3),
(5852, 1090, 'TypeIs나 TypeGuard로 사용자 정의 좁히기 함수를 만들 수 있다고 언급', 'SUPPLEMENTARY', 4);
