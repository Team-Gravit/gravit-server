-- Unit: 이터레이터와 제너레이터 (Unit ID: 215)
-- Chapter: Python (Chapter ID: 21)
-- Topic: PYTHON
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-python-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1071, 'PYTHON', 215, 'HARD', true,
 '수 GB 크기의 로그 파일에서 ERROR 행만 골라 처리해야 할 때, 리스트 대신 제너레이터 체인을 쓰면 무엇을 얻고 어떤 대가를 치르게 되나요?',
 'f.readlines()처럼 파일 전체를 리스트로 적재하면 모든 원소를 동시에 보유하므로 메모리가 O(n)으로 커집니다. 반면 파일 객체 자체가 이터레이터이므로, 한 줄씩 yield하는 read_lines, 이를 split하는 parse, ERROR 행만 통과시키는 only_errors를 제너레이터로 연결하면 세 단계가 한 줄씩 흘러가 현재 원소 하나와 프레임만 유지하는 O(1), 즉 일정한 메모리로 처리할 수 있습니다. 또 전체 생성을 기다리지 않고 첫 next() 호출 즉시 첫 결과를 얻을 수 있습니다. 대가도 있습니다. 제너레이터는 한 번만 순회되므로 이미 소진된 제너레이터를 다시 list()로 순회하면 예외 없이 빈 결과가 나오고, len()이나 인덱싱을 쓸 수 없습니다. 소비 전까지 값이 없어 디버깅과 추적도 어렵습니다. 여러 번 써야 하면 list()로 실체화하거나 제너레이터를 만드는 함수를 다시 호출해야 하고, sorted()처럼 전체를 알아야 하는 연산은 실체화를 일으키므로 파이프라인의 마지막 단계에서만 사용합니다.',
 'interview-question/1071.mp3'),
(1072, 'PYTHON', 215, 'NORMAL', true,
 '파이썬에서 이터러블(Iterable)과 이터레이터(Iterator)는 어떻게 다른가요?',
 '이터러블은 __iter__()를 호출하면 이터레이터를 반환하는 객체로, list, dict, str, range, 파일 등이 해당합니다. 이터레이터는 __next__()를 가지고 있고 __iter__()가 자기 자신을 반환하는 객체로, iter([1,2])의 결과나 제너레이터 객체, map 객체가 해당합니다. 그래서 리스트는 이터러블이지만 이터레이터가 아니어서 next([1, 2])를 호출하면 TypeError가 발생합니다. 이터레이터는 상태를 가지며 한 번 소진되면 끝이므로, 다시 순회하려면 iter()를 새로 호출해야 합니다. 리스트가 여러 번 순회 가능한 이유는 __iter__가 호출될 때마다 새 이터레이터 객체를 만들어 반환하기 때문이고, 반대로 __iter__가 self를 반환하는 이터레이터는 한 번만 순회할 수 있습니다.',
 'interview-question/1072.mp3'),
(1073, 'PYTHON', 215, 'NORMAL', true,
 'yield from을 쓰는 것은 for 루프로 안쪽 제너레이터의 값을 하나씩 yield하는 것과 무엇이 다른가요?',
 'yield from은 중첩 제너레이터의 값을 그대로 바깥으로 전달하므로, 값을 내보내는 결과만 보면 for x in inner: yield x와 동일합니다. 차이는 통신 위임에 있습니다. yield from은 호출자가 보낸 send와 throw를 안쪽 제너레이터까지 투명하게 전달하고, 안쪽 제너레이터가 return한 값은 yield from 표현식의 결과가 됩니다. 예를 들어 flatten 함수에서 원소가 리스트이면 yield from flatten(item)으로 재귀 위임해 [1, [2, [3, 4]], 5]를 [1, 2, 3, 4, 5]로 평탄화할 수 있습니다. 이런 send·throw·yield from 기능은 코루틴의 기반이며, async def/await도 이 제너레이터의 프레임 일시 정지·재개 메커니즘 위에 만들어졌습니다.',
 'interview-question/1073.mp3'),
(1074, 'PYTHON', 215, 'EASY', true,
 '파이썬의 for 문은 내부적으로 어떤 과정을 거쳐 값을 하나씩 꺼내나요?',
 'for x in obj:를 실행하면 인터프리터는 먼저 iter(obj)로 obj.__iter__()를 호출해 이터레이터를 얻습니다. 그다음 while 루프 안에서 next(it), 즉 it.__next__()를 반복 호출해 다음 값을 꺼내 x에 대입하고 본문을 실행합니다. 더 이상 값이 없어 StopIteration 예외가 발생하면 이를 잡아 반복을 종료합니다. 즉 for 문은 iter()로 이터레이터를 얻고 next()를 StopIteration까지 반복하는 과정을 감싼 문법 설탕입니다.',
 'interview-question/1074.mp3'),
(1075, 'PYTHON', 215, 'EASY', true,
 '함수 본문에 yield가 있는 제너레이터 함수는 일반 함수와 달리 어떻게 동작하나요?',
 '함수 본문에 yield가 있으면 그 함수는 호출해도 본문이 실행되지 않고 제너레이터 객체를 반환합니다. 그래서 countdown(3)을 호출한 시점에는 "시작"도 출력되지 않습니다. 이후 next()가 호출될 때마다 다음 yield까지 실행하고 그 값을 내보낸 뒤, 지역 변수와 실행 위치를 그대로 보존한 채 일시 정지합니다. 다음 next()가 오면 멈췄던 위치에서 재개하고, 함수 본문이 끝나면 StopIteration이 발생합니다. 이렇게 yield로 프레임을 일시 정지·재개하면서 제너레이터는 이터레이터 프로토콜을 자동 구현합니다.',
 'interview-question/1075.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1071
(5752, 1071, '파일을 한 줄씩 yield하는 제너레이터 체인으로 메모리를 일정하게 유지함을 설명', 'ESSENTIAL', 1),
(5753, 1071, '제너레이터는 한 번만 순회되어 소진 후 다시 순회하면 빈 결과가 나옴을 언급', 'ESSENTIAL', 2),
(5754, 1071, 'len()·인덱싱 불가, 디버깅·추적 어려움 중 최소 1개를 추가 대가로 제시', 'SUPPLEMENTARY', 3),
(5755, 1071, '첫 next() 호출 즉시 첫 결과를 얻을 수 있음을 언급', 'SUPPLEMENTARY', 4),
(5756, 1071, 'sorted()처럼 전체를 알아야 하는 연산은 파이프라인 마지막 단계에서만 사용함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1072
(5757, 1072, '이터러블은 __iter__()가 이터레이터를 반환하는 객체임을 설명', 'ESSENTIAL', 1),
(5758, 1072, '이터레이터는 __next__()를 가지고 __iter__()가 자기 자신을 반환함을 설명', 'ESSENTIAL', 2),
(5759, 1072, '이터레이터는 상태를 가지며 소진되면 iter()를 새로 호출해야 다시 순회할 수 있음을 설명', 'ESSENTIAL', 3),
(5760, 1072, '리스트는 이터러블이지만 이터레이터가 아니어서 next()에 넘기면 TypeError가 발생함을 언급', 'SUPPLEMENTARY', 4),
(5761, 1072, '__iter__가 새 이터레이터 객체를 만들어 반환하면 여러 번 순회할 수 있음을 설명', 'SUPPLEMENTARY', 5),

-- 질문 1073
(5762, 1073, 'yield from은 send·throw를 안쪽 제너레이터까지 투명하게 전달함을 설명', 'ESSENTIAL', 1),
(5763, 1073, '안쪽 제너레이터의 return 값이 yield from 표현식의 결과가 됨을 설명', 'ESSENTIAL', 2),
(5764, 1073, 'yield from이 값을 내보내는 결과는 for 루프로 하나씩 yield하는 것과 동일함을 언급', 'SUPPLEMENTARY', 3),
(5765, 1073, 'yield from을 재귀 호출해 중첩 리스트를 평탄화하는 예를 제시', 'SUPPLEMENTARY', 4),
(5766, 1073, 'async/await가 제너레이터의 일시 정지·재개 메커니즘 위에 만들어졌음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1074
(5767, 1074, 'for 문이 iter()로 __iter__()를 호출해 이터레이터를 얻음을 설명', 'ESSENTIAL', 1),
(5768, 1074, 'next()로 __next__()를 반복 호출해 다음 값을 꺼냄을 설명', 'ESSENTIAL', 2),
(5769, 1074, 'StopIteration 예외가 발생하면 반복을 종료함을 설명', 'ESSENTIAL', 3),
(5770, 1074, 'for 문이 iter()와 next() 반복을 감싼 문법 설탕임을 언급', 'SUPPLEMENTARY', 4),

-- 질문 1075
(5771, 1075, '호출 시 본문을 실행하지 않고 제너레이터 객체를 반환함을 설명', 'ESSENTIAL', 1),
(5772, 1075, 'next() 호출마다 다음 yield까지 실행하고 값을 내보냄을 설명', 'ESSENTIAL', 2),
(5773, 1075, 'yield 지점에서 지역 변수와 실행 위치를 보존한 채 일시 정지함을 설명', 'ESSENTIAL', 3),
(5774, 1075, '함수 본문이 끝나면 StopIteration이 발생함을 언급', 'SUPPLEMENTARY', 4),
(5775, 1075, '제너레이터가 이터레이터 프로토콜을 자동 구현함을 언급', 'SUPPLEMENTARY', 5);
