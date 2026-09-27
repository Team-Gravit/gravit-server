-- Unit: 데코레이터 동작 원리 (Unit ID: 216)
-- Chapter: Python (Chapter ID: 21)
-- Topic: PYTHON
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-python-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(1076, 'PYTHON', 216, 'HARD', true,
 '직접 작성한 데코레이터를 씌운 함수를 multiprocessing 프로세스 풀에 넘겼더니 실패하고, help()로 봐도 docstring이 나오지 않습니다. 데코레이터 동작 원리 관점에서 원인과 해결 방법을 설명해 주세요.',
 '@ 문법은 데코레이터 호출 결과를 원래 이름에 다시 할당하기 때문에, 데코레이터를 씌우면 원래 함수 이름이 실제로는 wrapper 함수를 가리키게 됩니다. 그래서 functools.wraps 없이 작성하면 __doc__이 None이 되어 help()에서 docstring이 사라지고, __name__은 wrapper가 되며 __module__도 데코레이터 모듈의 것으로 바뀝니다. multiprocessing은 함수를 pickle로 넘기는데, pickle이 __module__.__qualname__으로 함수를 찾지 못해 실패하게 됩니다. 해결책은 wrapper 정의 위에 @functools.wraps(func)를 붙여 원본 함수의 __name__, __doc__, __module__ 같은 메타데이터를 wrapper에 복사하는 것입니다. wraps를 적용하면 __wrapped__ 속성으로 원본 함수에도 접근할 수 있어 inspect.signature나 테스트에서 활용할 수 있습니다. 데코레이터를 __call__을 정의한 클래스로 구현한 경우에는 클래스 버전의 wraps인 functools.update_wrapper를 사용합니다.'),
(1077, 'PYTHON', 216, 'NORMAL', true,
 '데코레이터 본문과 데코레이터가 반환하는 wrapper 함수는 각각 언제 실행되는지, 그 차이를 설명해 주세요.',
 '데코레이터 본문은 함수 정의 시점, 즉 모듈이 import될 때 한 번만 실행됩니다. 함수를 호출하지 않아도 @ 아래 함수가 정의되는 순간 데코레이터가 호출되어 wrapper를 만들고, 원래 이름에 wrapper를 할당합니다. 이때 원래 함수는 wrapper의 클로저 셀에 보관됩니다. 반면 wrapper는 데코레이트된 함수가 호출될 때마다 매번 실행되며, 전처리를 수행한 뒤 보관해 둔 원래 함수를 실행하고 후처리를 한 다음 결과를 반환합니다. 정리하면 데코레이터 본문은 정의 시 1회, 래퍼는 호출 시 매번 실행된다는 차이가 있습니다.'),
(1078, 'PYTHON', 216, 'NORMAL', true,
 '@log_call처럼 인자 없이 쓰는 데코레이터와 @retry(times=3)처럼 인자를 받는 데코레이터는 구조가 어떻게 다른가요?',
 '인자 없는 데코레이터 @log_call은 func을 받아 내부에 wrapper를 정의하고 그 wrapper를 반환하는 함수이며, add = log_call(add)와 동일합니다. 반면 @retry(times=3)처럼 괄호가 붙으면 retry(times=3)이 먼저 호출되어 진짜 데코레이터를 반환하고, 그 반환값이 함수에 적용됩니다. 즉 @d(x)는 d(x)(f)와 같습니다. 그래서 함수가 한 겹 더 필요해, 설정을 받는 팩토리 → 함수를 받는 데코레이터 → 실제 실행 래퍼의 3중 함수 구조가 됩니다. 참고로 @retry와 @retry()를 모두 허용하려면 첫 인자가 함수인지 검사하는 분기가 필요하므로, 인자가 있는 데코레이터는 항상 괄호를 붙이도록 통일하는 것이 좋습니다.'),
(1079, 'PYTHON', 216, 'EASY', true,
 '파이썬의 데코레이터란 무엇이고, @ 문법은 실제로 어떤 코드와 같은지 설명해 주세요.',
 '데코레이터는 함수를 인자로 받아 새 함수를 반환하는 고차 함수입니다. 파이썬에서 함수는 변수에 담고 인자로 넘기고 반환할 수 있는 일급 객체이기 때문에 이런 방식이 가능합니다. @log_call을 add 함수 위에 붙이는 것은 add를 정의한 뒤 add = log_call(add)를 실행하는 것과 완전히 동일하며, @ 문법은 데코레이터 호출 결과를 원래 이름에 다시 할당하는 문법 설탕입니다. 로깅, 캐싱, 인증, 재시도처럼 여러 함수에 공통으로 붙는 관심사를 본문과 분리해 재사용할 때 사용합니다.'),
(1080, 'PYTHON', 216, 'EASY', true,
 '함수 위에 @a, @b 순서로 데코레이터를 여러 개 쌓으면 어떤 순서로 적용되고, 호출 시에는 어떤 순서로 실행되나요?',
 '@a, @b 순서로 쌓으면 함수에 가까운 아래쪽 데코레이터부터 적용되어 f = a(b(f))가 됩니다. 즉 적용 순서는 b → a입니다. 호출할 때는 가장 바깥에 있는 a의 wrapper가 먼저 실행되어, a 전처리 → b 전처리 → f → b 후처리 → a 후처리 순서로 흐릅니다. 클래스 메서드에 여러 데코레이터를 쓸 때는 @staticmethod, @classmethod, @property가 일반 함수를 디스크립터로 바꾸므로 대부분 가장 위(바깥)에 두고, 그 아래에 로깅이나 캐싱 데코레이터를 둡니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1076
(5776, 1076, '데코레이터 적용 후 원래 함수 이름이 wrapper 함수를 가리키게 됨을 원인으로 설명', 'ESSENTIAL', 1),
(5777, 1076, 'wraps 없이는 __doc__이 None이 되어 help()에서 docstring이 사라짐을 언급', 'ESSENTIAL', 2),
(5778, 1076, 'pickle이 __module__.__qualname__으로 함수를 찾지 못해 multiprocessing이 실패함을 설명', 'ESSENTIAL', 3),
(5779, 1076, 'functools.wraps(func)로 원본 메타데이터를 wrapper에 복사해 해결함을 제시', 'ESSENTIAL', 4),
(5780, 1076, 'wraps 적용 시 __wrapped__ 속성으로 원본 함수에 접근할 수 있음을 언급', 'SUPPLEMENTARY', 5),
(5781, 1076, '클래스로 구현한 데코레이터에서는 functools.update_wrapper를 사용함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1077
(5782, 1077, '데코레이터 본문은 함수 정의 시점(모듈 import 시)에 1회 실행됨을 언급', 'ESSENTIAL', 1),
(5783, 1077, 'wrapper는 데코레이트된 함수가 호출될 때마다 매번 실행됨을 언급', 'ESSENTIAL', 2),
(5784, 1077, '함수를 호출하지 않아도 @ 아래 함수가 정의되는 순간 데코레이터가 실행됨을 명시', 'SUPPLEMENTARY', 3),
(5785, 1077, 'wrapper가 전처리 후 원래 함수를 실행하고 후처리한 뒤 결과를 반환하는 흐름을 설명', 'SUPPLEMENTARY', 4),
(5786, 1077, '원래 함수가 wrapper의 클로저 셀에 보관됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1078
(5787, 1078, '인자 없는 데코레이터는 func을 받아 wrapper를 반환하는 함수임을 언급', 'ESSENTIAL', 1),
(5788, 1078, '인자 있는 데코레이터는 retry(times=3)이 먼저 호출되어 진짜 데코레이터를 반환함을 설명', 'ESSENTIAL', 2),
(5789, 1078, '팩토리 → 데코레이터 → 래퍼의 3중 함수 구조를 제시', 'ESSENTIAL', 3),
(5790, 1078, '@d(x)가 d(x)(f)와 동일함을 명시', 'SUPPLEMENTARY', 4),
(5791, 1078, '@retry와 @retry()를 모두 허용하려면 첫 인자가 함수일 때를 검사하는 분기가 필요함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1079
(5792, 1079, '데코레이터가 함수를 인자로 받아 새 함수를 반환하는 고차 함수임을 설명', 'ESSENTIAL', 1),
(5793, 1079, '@ 문법이 add = log_call(add)처럼 호출 결과를 원래 이름에 다시 할당하는 문법 설탕임을 설명', 'ESSENTIAL', 2),
(5794, 1079, '함수가 인자로 넘기고 반환할 수 있는 일급 객체라서 데코레이터가 가능함을 언급', 'SUPPLEMENTARY', 3),
(5795, 1079, '로깅·캐싱·인증·재시도 중 최소 1개를 데코레이터 활용 예로 제시', 'SUPPLEMENTARY', 4),

-- 질문 1080
(5796, 1080, '함수에 가까운 아래 데코레이터부터 적용되어 f = a(b(f))가 됨을 설명', 'ESSENTIAL', 1),
(5797, 1080, '호출 시 가장 바깥인 a의 wrapper 전처리가 먼저 실행됨을 설명', 'ESSENTIAL', 2),
(5798, 1080, '후처리는 b 후처리 → a 후처리 순으로 안쪽부터 실행됨을 언급', 'SUPPLEMENTARY', 3),
(5799, 1080, '@staticmethod·@classmethod·@property는 디스크립터로 바꾸므로 가장 위에 둬야 함을 설명', 'SUPPLEMENTARY', 4);
