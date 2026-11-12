-- Unit: 이터레이터와 제너레이터 (Unit ID: 215)
-- Chapter: Python (Chapter ID: 21)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (641, 215, '제너레이터 실행 시점과 yield from'),
       (799, 215, '이터레이터 소비와 send, 이터러블 분리'),
       (957, 215, '이터레이션 규약의 빈틈과 제너레이터 흐름 제어');

-- =====================================================
-- Lesson 641: 제너레이터 실행 시점과 yield from
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4025, 641, '아래 코드로 만든 객체 c를 다룰 때 옳은 것은?', '```python
class Countdown:
    def __init__(self, start):
        self.current = start

    def __iter__(self):
        return self

    def __next__(self):
        if self.current <= 0:
            raise StopIteration
        self.current -= 1
        return self.current + 1

c = Countdown(3)
```', 'OBJECTIVE'),
       (4026, 641, '아래 코드가 표준 출력에 찍는 내용을 순서대로 나열한 것은?', '```python
def gen():
    print("A")
    yield 1
    print("B")
    yield 2
    print("C")

g = gen()
print("start")
print(next(g))
```', 'OBJECTIVE'),
       (4027, 641, '아래 측정 결과를 바탕으로 판단할 때 옳지 않은 것은?', '원소 10,000,000개를 다루는 두 방식을 같은 환경에서 측정한 결과다.

| 항목 | 리스트 컴프리헨션 `[x*x for x in range(10**7)]` | 제너레이터 표현식 `(x*x for x in range(10**7))` |
|---|---|---|
| 생성 직후 메모리 | 약 400MB | 약 200바이트 |
| 첫 원소를 얻기까지 걸린 시간 | 0.9초 | 0.000002초 |
| 같은 객체를 두 번째로 순회한 결과 | 원소 10,000,000개 | 빈 결과 |
| len() 호출 결과 | 10,000,000 | TypeError |', 'OBJECTIVE'),
       (4028, 641, '아래 코드의 출력으로 옳은 것은?', '```python
def inner():
    yield 1
    yield 2
    return 99

def outer():
    result = yield from inner()
    yield result
    yield 3

print(list(outer()))
```', 'OBJECTIVE'),
       (4029, 641, '아래 빈칸에 공통으로 들어갈 itertools 함수의 이름은?', '무한 수열을 만드는 count() 위에 짝수만 남기는 제너레이터를 얹고, 앞에서 다섯 개만 확인하려고 list()로 감쌌더니 프로그램이 결과를 내지 못한 채 메모리 사용량만 계속 올라갔다. 아래처럼 함수 하나를 끼워 넣자 곧바로 결과가 찍혔다.

```python
from itertools import count, ____

evens = (n for n in count() if n % 2 == 0)
print(list(____(evens, 5)))   # [0, 2, 4, 6, 8]
```', 'SUBJECTIVE'),
       (4030, 641, '아래 실행 결과에서 마지막 줄이 찍히게 만든 예외의 이름은?', '```python
def reader(path):
    f = open(path, encoding="utf-8")
    try:
        for line in f:
            yield line.rstrip("\n")
    finally:
        f.close()
        print("파일 닫힘")

g = reader("app.log")
print(next(g))
g.close()
```

실행 결과

```
2026-09-10 INFO start
파일 닫힘
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4025
(10907, 4025, 'len(c)를 호출하면 아직 남아 있는 값의 개수인 3을 얻을 수 있다.', '이터레이터는 다음 값을 어떻게 만들지만 알 뿐 전체 개수를 모른다. len()은 __len__이 있어야 동작하는데 Countdown에는 없어 TypeError가 난다. 개수를 알 수 있다고 본 것은 리스트의 감각을 그대로 옮겨온 오해다.', false),
(10908, 4025, 'c[1]처럼 인덱스로 접근하면 두 번째 값인 2를 얻을 수 있다.', '임의 위치 접근에는 __getitem__이 필요하다. Countdown은 __iter__와 __next__만 가지므로 c[1]은 TypeError다. 이터레이터는 앞에서부터 한 번씩 꺼낼 수만 있고 되돌아가거나 건너뛸 수 없다.', false),
(10909, 4025, '같은 c를 for 문으로 두 번 순회하면 두 번째 반복문의 본문은 실행되지 않는다.', '__iter__가 self를 돌려주므로 c는 이터러블이면서 동시에 이터레이터다. 첫 for 문이 current를 0까지 깎아 놓기 때문에 두 번째 for 문은 같은 객체를 다시 받아 첫 __next__에서 곧장 StopIteration을 만나고, 본문을 한 번도 실행하지 못한다.', true),
(10910, 4025, 'c를 for 문에 다시 넘기면 __init__이 다시 호출되어 current가 3으로 되돌아간다.', 'for 문은 대상 객체에 iter()를 부를 뿐 생성자를 다시 부르지 않는다. c는 이미 만들어진 객체라 __init__이 재실행될 일이 없고, current는 첫 순회가 끝난 0 상태 그대로 남는다.', false),

-- 문제 4026
(10911, 4026, 'A, start, 1', '제너레이터 함수는 호출해도 본문이 실행되지 않고 제너레이터 객체만 돌려준다. gen() 시점에 A가 찍힌다고 본 것은 일반 함수의 감각을 그대로 옮긴 오해다.', false),
(10912, 4026, 'start, A, 1', 'gen()은 객체만 만들고 본문은 첫 next(g)에서야 시작된다. 그래서 start가 먼저 찍히고 이어 A가 찍힌 뒤, yield 1이 값을 내보내 1이 출력된다. 실행은 그 yield 자리에서 프레임을 보존한 채 멈춘다.', true),
(10913, 4026, 'start, A, B, 1', '한 번의 next()는 다음 yield를 만나는 순간 멈춘다. yield 1 다음 줄인 print("B")까지 미리 진행한다고 본 오해이며, B는 두 번째 next()를 불러야 찍힌다.', false),
(10914, 4026, 'start, A, 1, B', '값을 내보낸 뒤에도 함수가 계속 달린다고 본 오해다. yield는 반환이 아니라 정지라서 제어권이 곧바로 호출자에게 넘어가고, 다음 줄은 다음 next()가 올 때까지 실행되지 않는다.', false),

-- 문제 4027
(10915, 4027, '리스트 컴프리헨션은 원소를 모두 만든 뒤에야 첫 원소를 넘기므로 첫 결과가 늦게 나온다.', '참인 진술이다. 대괄호 컴프리헨션은 리스트를 완성한 다음 넘기므로 첫 원소를 쓰려면 1천만 번의 계산이 모두 끝나야 한다. 첫 원소까지 0.9초가 걸린 것이 그 결과다.', false),
(10916, 4027, '제너레이터 표현식의 값을 두 번 써야 한다면 list()로 실체화하거나 표현식을 다시 만들어야 한다.', '참인 진술이다. 이터레이터는 진행 상태를 가지며 소진되면 되돌아가지 못한다. 두 번째 순회가 예외 없이 빈 결과인 이유가 이것이라, 재사용하려면 값을 붙잡아 두거나 표현식을 새로 만들어야 한다.', false),
(10917, 4027, '남은 원소 개수를 len()으로 확인하는 코드는 제너레이터 표현식으로 그대로 바꿀 수 없다.', '참인 진술이다. len()은 전체 개수를 미리 알아야 하는데 제너레이터는 다음 값만 안다. 그래서 TypeError가 나며, 개수를 세려면 전체를 소비해 sum(1 for _ in gen) 식으로 직접 세야 한다.', false),
(10918, 4027, '제너레이터 표현식은 생성 직후 원소 10,000,000개를 이미 메모리에 담고 있어 두 번째 순회도 곧바로 된다.', '거짓이라 골라야 할 선지다. 200바이트는 원소가 아니라 실행 프레임만 들고 있다는 뜻이고, 값은 순회할 때 하나씩 계산된다. 원소를 담아 두지 않으니 두 번째 순회가 빈 결과인 것이며, 곧바로 다시 순회된다는 설명은 표의 두 줄과 어긋난다.', true),

-- 문제 4028
(10919, 4028, '[1, 2, 99, 3]', 'yield from은 inner()의 값 1과 2를 그대로 흘려보낸 뒤, inner()가 return한 99를 yield from 표현식의 값으로 돌려준다. 그 99가 result에 담겨 yield result로 나오고 마지막에 3이 이어진다.', true),
(10920, 4028, '[1, 2, None, 3]', '제너레이터의 return 값은 늘 버려진다고 본 오해다. 직접 for 문으로 위임했다면 그렇지만, yield from은 안쪽의 return 값을 표현식 값으로 넘겨주므로 result는 None이 아니라 99가 된다.', false),
(10921, 4028, '[[1, 2], 99, 3]', 'yield from이 안쪽 값을 모아 한 덩어리로 내보낸다고 본 오해다. 실제로는 원소를 하나씩 그대로 전달해 평탄하게 흘려보내므로 리스트가 중첩되지 않는다.', false),
(10922, 4028, '[1, 2]', '안쪽 제너레이터가 끝나면 바깥도 함께 끝난다고 본 오해다. return은 위임을 마칠 뿐이며, 제어는 yield from 다음 줄로 돌아와 outer()가 남은 yield를 계속 수행한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1298, 4029, 'islice,itertools.islice,아이슬라이스', '무한하거나 아주 긴 이터레이터를 실체화하지 않고 앞에서 정해진 개수만 잘라 다시 이터레이터로 돌려주는 함수가 islice다. count()는 끝이 없으므로 list()로 바로 감싸면 영원히 값을 모으다 메모리가 터진다. 제너레이터는 시퀀스가 아니라 evens[:5] 같은 슬라이싱이 TypeError이고, 그 자리를 대신하는 것이 islice다. 개수가 아니라 조건이 처음 거짓이 되는 지점까지 자르는 takewhile, 조건이 거짓이 될 때까지 앞을 버리는 dropwhile과 구분한다. islice 자체도 지연 평가라 5개를 다 꺼내기 전까지 count()를 그 이상 돌리지 않는다.'),
       (1299, 4030, 'GeneratorExit,generator exit,제너레이터 엑시트,제너레이터엑시트', '일시 정지한 제너레이터에 close()를 부르면 인터프리터가 멈춰 있던 yield 자리에서 GeneratorExit를 일으킨다. 그 덕분에 try에 붙은 finally가 실행되어 파일이 닫히고 마지막 줄이 찍힌다. 제너레이터를 중간에 버려도 열어 둔 자원을 정리할 수 있는 근거가 이것이다. 값이 다 떨어져 정상적으로 끝날 때 나는 StopIteration과 다르고, 호출자가 원하는 예외를 골라 넣는 throw()와도 다르다. GeneratorExit를 잡아서 다시 yield하면 RuntimeError가 나므로, 이 예외는 정리만 하고 빠져나와야 한다.');

-- =====================================================
-- Lesson 799: 이터레이터 소비와 send, 이터러블 분리
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4973, 799, '아래 코드가 출력하는 두 줄로 옳은 것은?', '```python
gen = (x for x in range(5))
print(2 in gen)
print(list(gen))
```', 'OBJECTIVE'),
       (4974, 799, '아래 코드가 출력하는 세 줄을 순서대로 나열한 것은?', '```python
def accumulator():
    total = 0
    while True:
        value = yield total
        total += value

acc = accumulator()
print(acc.send(None))
print(acc.send(10))
print(acc.send(5))
```', 'OBJECTIVE'),
       (4975, 799, '아래 실행 결과를 바탕으로 판단할 때 옳지 않은 것은?', 'itertools의 함수 네 개를 같은 환경에서 실행한 결과다.

| 실행한 코드 | 결과 |
|---|---|
| `list(chain([1, 2], [3]))` | `[1, 2, 3]` |
| `list(islice(count(10, 2), 3))` | `[10, 12, 14]` |
| `[k for k, g in groupby([1, 1, 2, 1])]` | `[1, 2, 1]` |
| `list(zip([1, 2, 3], [10, 20]))` | `[(1, 10), (2, 20)]` |', 'OBJECTIVE'),
       (4976, 799, '아래 순회 설계를 따르는 객체 obj에 대한 설명으로 옳은 것은?', 'obj는 `__next__()`를 직접 갖고 있지 않다. 대신 `__iter__()`가 불릴 때마다 진행 위치를 맨 앞에서 시작하는 **새 보조 객체**를 만들어 돌려주고, 값을 꺼내는 일은 그 보조 객체의 `__next__()`가 맡는다. 보조 객체의 `__iter__()`는 자기 자신을 돌려준다.', 'OBJECTIVE'),
       (4977, 799, '아래 측정에서 B 방식이 따르는 평가 방식의 이름은?', '20GB 로그 파일에서 오류 줄만 추려 화면에 찍는 같은 작업을 두 방식으로 구현해 같은 장비에서 측정했다.

| 항목 | A 방식 | B 방식 |
|---|---|---|
| 최대 메모리 사용량 | 12.4GB | 41MB |
| 첫 줄이 화면에 찍히기까지 | 3분 12초 | 0.2초 |
| 시작 5초 뒤 강제 종료했을 때 파일에서 읽어 들인 줄 수 | 전체 | 1,204줄 |', 'SUBJECTIVE'),
       (4978, 799, '아래 세션에서 nums와 달리 it만 해당하는 객체 종류의 이름은?', '```
>>> nums = [10, 20, 30]
>>> next(nums)
TypeError
>>> it = iter(nums)
>>> next(it), next(it)
(10, 20)
>>> iter(it) is it
True
>>> list(it)
[30]
>>> list(it)
[]
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4973
(13435, 4973, '첫 줄 True, 둘째 줄 [0, 1, 2, 3, 4]', 'in 연산이 원소를 들여다보기만 한다고 본 오해다. 멤버십 검사도 next()로 값을 하나씩 꺼내 비교하므로 검사에 쓰인 0·1·2는 이미 소비돼 뒤에 남지 않는다.', false),
(13436, 4973, '첫 줄 True, 둘째 줄 [2, 3, 4]', '비교에 쓴 원소는 제자리로 돌려놓는다고 본 오해다. 이터레이터에는 되돌리기가 없어 2도 비교하면서 소비된다. 찾은 값을 남겨 두려면 검사 대신 next()로 직접 받아 써야 한다.', false),
(13437, 4973, '첫 줄 True, 둘째 줄 [3, 4]', '2 in gen은 0·1·2를 차례로 꺼내 비교하다 2에서 참이 확정돼 멈춘다. 제너레이터는 그 진행 위치를 그대로 유지하므로 이어지는 list(gen)에는 아직 꺼내지 않은 3·4만 담긴다.', true),
(13438, 4973, '첫 줄 True, 둘째 줄 []', 'in이 언제나 끝까지 훑는다고 본 오해다. 값을 찾은 순간 검사가 끝나므로 뒤쪽 원소는 건드리지 않는다. 빈 결과가 되는 것은 값을 못 찾아 전부 소비했을 때다.', false),

-- 문제 4974
(13439, 4974, '0, 10, 15', 'send(None)은 next()와 같아 첫 yield total이 내보낸 초기값 0을 돌려준다. 다음 send(10)은 멈춰 있던 yield 자리에 10을 넣어 total을 10으로 만든 뒤 while을 한 바퀴 돌아 10을, send(5)는 같은 방식으로 15를 내보낸다.', true),
(13440, 4974, 'None, 10, 15', '보낸 값이 None이니 돌려받는 것도 None이라고 본 오해다. send가 돌려주는 값은 보낸 값이 아니라 제너레이터가 다음 yield에서 내보낸 값이라, 첫 호출에서는 초기값 0이 나온다.', false),
(13441, 4974, '0, 0, 10', 'yield가 값을 받기 전의 total을 내보낸다고 한 칸 밀려 본 오해다. 재개된 코드는 total += value를 끝낸 뒤 while을 돌아 다시 yield total에 도착하므로 갱신된 값이 나간다.', false),
(13442, 4974, '0, 10, 5', '보낸 값이 그대로 메아리처럼 돌아온다고 본 오해다. 제너레이터 안에서 total에 누적한 결과가 나가므로 세 번째 값은 5가 아니라 10 + 5인 15다.', false),

-- 문제 4975
(13443, 4975, 'chain은 앞 이터러블을 끝까지 내보낸 뒤 다음 이터러블로 넘어가므로 결과 순서가 넘긴 순서 그대로다.', '참인 진술이다. 결과 [1, 2, 3]이 그 순서를 보여 준다. 게다가 chain은 넘겨받은 이터러블을 미리 합쳐 두지 않고 필요할 때 하나씩 당겨 쓰므로, 리스트로 이어 붙이는 메모리 비용 없이 여러 묶음을 한 줄로 순회할 수 있다.', false),
(13444, 4975, '끝이 정해지지 않은 count() 위에 앞의 몇 개만 꺼내는 함수를 얹으면 순회가 끝난다.', '참인 진술이다. count(10, 2)는 10부터 2씩 끝없이 이어지지만 islice가 세 개째에서 순회를 끝내 [10, 12, 14]가 나왔다. islice도 지연 평가라 필요한 개수만큼만 count()를 진행시키므로 무한 수열이 문제가 되지 않는다.', false),
(13445, 4975, 'zip의 결과 개수는 두 입력 중 짧은 쪽 길이에 맞춰진다.', '참인 진술이다. 입력은 셋과 둘인데 결과가 두 쌍이다. zip은 매번 두 입력에서 한 개씩 꺼내다 한쪽이 StopIteration을 내면 그 자리에서 끝내기 때문이다. 긴 쪽을 버리지 않으려면 itertools.zip_longest를 쓴다.', false),
(13446, 4975, 'groupby는 같은 값을 모두 한 묶음으로 모으므로 결과에 같은 키가 두 번 나올 수 없다.', '거짓이라 골라야 할 선지다. 결과 [1, 2, 1]에 키 1이 두 번 나온다. groupby는 이웃한 같은 값만 묶고 흐름을 앞에서 뒤로 한 번만 지나가므로, 흩어진 값을 한 묶음으로 모으려면 같은 키끼리 붙도록 먼저 정렬해야 한다.', true),

-- 문제 4976
(13447, 4976, '값을 꺼내던 도중 그 보조 객체에 iter()를 다시 부르면 진행 위치가 맨 앞으로 되감긴 객체를 받는다.', 'iter()만 부르면 언제든 처음으로 돌아간다고 본 오해다. 보조 객체의 __iter__()는 자기 자신을 돌려주므로 위치가 그대로다. 되감으려면 obj에 iter()를 다시 불러 새 보조 객체를 받아야 한다.', false),
(13448, 4976, '중첩 for 문으로 obj를 동시에 두 번 돌려도 바깥쪽의 진행 위치가 안쪽 순회 때문에 밀리지 않는다.', '안쪽 for 문이 iter(obj)로 자기 몫의 보조 객체를 따로 받기 때문이다. 진행 위치가 obj가 아니라 보조 객체에 있어 두 순회가 서로 간섭하지 않는다. 자기 자신을 돌려주는 제너레이터 객체로는 이렇게 쓸 수 없다.', true),
(13449, 4976, '값이 다 떨어지면 보조 객체의 __next__()가 None을 돌려주어 for 문이 멈춘다.', '끝을 반환값으로 알린다고 본 오해다. 그렇게 하면 None 자체를 담고 있던 순회와 구분할 수 없다. 끝은 StopIteration 예외로 알리고, for 문이 그 예외를 잡아 반복을 끝낸다.', false),
(13450, 4976, 'obj에 next()를 바로 불러도 첫 값을 받을 수 있다.', 'for 문에 넣을 수 있으면 next()도 된다고 본 오해다. next()는 대상에 __next__()가 있어야 동작하는데 obj에는 없어 TypeError가 난다. 먼저 iter(obj)로 보조 객체를 얻어야 값을 꺼낼 수 있다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1614, 4977, '지연 평가,지연평가,lazy evaluation,lazy,느긋한 계산법,게으른 평가,늦은 평가,지연 계산', '필요한 값을 그때그때 하나씩 계산해 넘기면 입력이 20GB든 아니든 한 번에 들고 있는 양이 일정해 메모리가 41MB에 머무르고, 첫 줄이 만들어지자마자 곧바로 화면에 나가 0.2초가 된다. 5초 만에 끊었을 때 1,204줄만 읽은 것도 같은 성질이다 — 뒤쪽은 아직 요구받지 않아 읽지도 않았다. A 방식처럼 전부 만들어 두고 넘기는 즉시 평가와 반대편에 있다. 이 방식을 파이썬에서 구현해 주는 도구가 제너레이터·이터레이터지만, 도구 이름과 평가 방식의 이름은 구분해야 한다. 대가도 분명하다. 값을 쌓아 두지 않으므로 다시 순회하거나 len()으로 개수를 세는 일은 할 수 없다.'),
       (1615, 4978, '이터레이터,iterator,반복자,이터레이터 객체,반복자 객체', 'next()로 다음 값을 바로 꺼낼 수 있고, iter()를 불러도 자기 자신이 나오며, 값을 하나씩 소비해 한 번 다 꺼내고 나면 비는 객체가 이터레이터다. 세션의 네 줄이 정확히 그 세 가지 성질을 보여 준다. nums는 for 문에 넣을 수 있고 iter()도 되지만 next()가 통하지 않으니 이터러블일 뿐이며, 둘의 경계가 여기에 있다. iter(nums)는 부를 때마다 진행 위치가 맨 앞인 새 객체를 주기 때문에 리스트는 몇 번이든 다시 순회되고, 그 결과를 받아 둔 it는 한 번만 순회된다. 제너레이터 객체도 이 성질을 갖지만 그것은 이터레이터의 한 종류이고, 여기서 iter()가 돌려준 것은 리스트 전용 이터레이터다.');

-- =====================================================
-- Lesson 957: 이터레이션 규약의 빈틈과 제너레이터 흐름 제어
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5921, 957, '아래 설계를 따르는 객체 s를 다룰 때의 결과로 옳은 것은?', '클래스 Seq는 `__iter__()`와 `__next__()`를 모두 정의하지 않고 `__getitem__(self, i)` 하나만 정의한다. 이 메서드는 i가 0, 1, 2일 때 각각 `i * 10`을 돌려주고, 그 밖의 i에는 IndexError를 일으킨다. `s = Seq()`로 객체를 만들었다.', 'OBJECTIVE'),
       (5922, 957, '아래 코드가 출력하는 줄을 순서대로 나열한 것은?', '```python
def src():
    for i in range(1, 4):
        print(f"read {i}")
        yield i

def double(xs):
    for x in xs:
        print(f"double {x}")
        yield x * 2

for v in double(src()):
    print(f"got {v}")
    if v >= 4:
        break
```', 'OBJECTIVE'),
       (5923, 957, '아래 코드의 실행 결과로 옳은 것은?', '```python
def worker():
    while True:
        try:
            job = yield
            print("처리", job)
        except ValueError:
            print("건너뜀")

w = worker()
next(w)
w.send("A")
w.throw(ValueError)
w.send("B")
```', 'OBJECTIVE'),
       (5924, 957, '아래 코드를 실행한 결과로 옳은 것은?', '리스트를 받던 통계 함수에 메모리를 아끼려고 호출부만 바꿔 제너레이터 표현식을 넘겼다.

```python
def stats(values):
    total = sum(values)
    peak = max(values)
    return total, peak

squares = (n * n for n in [3, 1, 2])
print(stats(squares))
```', 'OBJECTIVE'),
       (5925, 957, '아래 오류를 없애려고 Countdown 클래스에 추가해야 하는 메서드의 이름은?', '```python
class Countdown:
    def __init__(self, start):
        self.current = start

    def __iter__(self):
        return self

for n in Countdown(3):
    print(n)
```

실행 결과

```
TypeError: iter() returned non-iterator of type ''Countdown''
```', 'SUBJECTIVE'),
       (5926, 957, '아래 두 실행에서 결과를 가른 준비 단계를 가리키는 용어는?', '```python
def running_average():
    total, count = 0, 0
    while True:
        value = yield (total / count if count else None)
        total += value
        count += 1
```

실행 1

```
>>> avg = running_average()
>>> avg.send(10)
TypeError: can''t send non-None value to a just-started generator
```

실행 2

```
>>> avg = running_average()
>>> next(avg)
>>> avg.send(10)
10.0
>>> avg.send(20)
15.0
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5921
(15963, 5921, 'for 문에 s를 넣으면 __iter__()가 없어 반복을 시작하기 전에 TypeError가 난다.', '__iter__()가 있어야만 순회된다고 본 오해다. iter()는 __iter__()가 없으면 __getitem__()을 0부터 차례로 부르는 옛 시퀀스 규약으로 대신 이터레이터를 만들어 준다.', false),
(15964, 5921, 'list(s)를 호출하면 [0, 10, 20]을 얻는다.', 'iter(s)가 __getitem__()을 0, 1, 2 순으로 부르는 이터레이터를 만들고, i가 3일 때 난 IndexError를 끝 신호로 받아 순회를 멈춘다. 그래서 세 값만 담긴 리스트가 나온다.', true),
(15965, 5921, 'next(s)를 바로 호출하면 첫 값인 0을 얻는다.', '순회할 수 있으면 next()도 된다고 본 오해다. next()는 __next__()가 있어야 동작하는데 s에는 없어 TypeError가 난다. s는 이터러블일 뿐이라 iter(s)로 이터레이터를 먼저 얻어야 한다.', false),
(15966, 5921, 'for 문이 i가 3일 때 난 IndexError를 그대로 밖으로 내보내 반복이 오류로 끝난다.', 'IndexError를 일반 오류로만 본 오해다. __getitem__()으로 순회하는 규약에서는 IndexError가 값이 다 떨어졌다는 신호로 해석돼, for 문은 예외 없이 조용히 끝난다.', false),

-- 문제 5922
(15967, 5922, 'read 1, read 2, read 3, double 1, double 2, double 3, got 2, got 4', '단계마다 입력을 모두 받아 처리한 뒤 다음 단계로 넘긴다고 본 즉시 평가식 오해다. 제너레이터 체인에서는 값 하나가 마지막 단계까지 흘러간 뒤에야 다음 값을 읽는다.', false),
(15968, 5922, 'double 1, read 1, got 2, double 2, read 2, got 4', '바깥 제너레이터 본문이 먼저 돌므로 double이 먼저 찍힌다고 본 오해다. double의 print는 for x in xs가 src()에서 값을 받아 온 다음 줄이라 read가 늘 먼저 찍힌다.', false),
(15969, 5922, 'read 1, double 1, got 2, read 2, double 2, got 4, read 3', 'break 뒤에도 다음 값을 미리 당겨 둔다고 본 오해다. for 문은 본문을 끝낸 뒤에야 다음 값을 요구하는데 그 전에 break로 빠져나오므로 src()는 i가 3인 자리까지 진행하지 않는다.', false),
(15970, 5922, 'read 1, double 1, got 2, read 2, double 2, got 4', 'for 문이 값 하나를 요구할 때마다 double이 src()에 하나를 요구해, 한 값이 세 단계를 끝까지 통과한다. v가 4일 때 break하니 read 3은 실행되지 않는다. 지연 평가 파이프라인의 실제 흐름이다.', true),

-- 문제 5923
(15971, 5923, '처리 A, 건너뜀, 처리 B가 차례로 출력되고 정상 종료된다.', 'throw()는 멈춰 있던 yield 자리에서 ValueError를 일으키고, 이를 제너레이터 안의 except가 잡아 건너뜀을 찍는다. while이 계속 돌아 다음 yield에서 다시 멈추므로 send("B")도 처리된다.', true),
(15972, 5923, '처리 A가 출력된 뒤 ValueError가 호출자 쪽에서 발생해 프로그램이 멈춘다.', 'throw()가 호출한 자리에서 예외를 던진다고 본 오해다. 예외는 제너레이터가 멈춰 있던 yield 자리에서 발생하므로, 안에서 잡으면 호출자에게는 전파되지 않는다.', false),
(15973, 5923, '처리 A, 건너뜀이 출력된 뒤 send("B")에서 StopIteration이 발생한다.', '예외를 한 번 받으면 제너레이터가 끝난다고 본 오해다. 안에서 잡아 처리하면 실행이 이어져 다음 yield에서 다시 멈춘다. 잡지 못해 밖으로 새어 나갈 때만 제너레이터가 끝난다.', false),
(15974, 5923, '처리 A, 처리 B가 출력되고 throw() 호출은 아무 출력도 남기지 않는다.', 'throw()를 값 없이 재개하는 호출쯤으로 본 오해다. throw()는 제너레이터 안에 실제 예외를 일으키므로 except ValueError 블록이 실행돼 건너뜀이 찍힌다.', false),

-- 문제 5924
(15975, 5924, '(14, 9)가 출력된다.', '제너레이터를 리스트처럼 여러 번 순회할 수 있다고 본 오해다. sum()이 원소를 모두 꺼내 쓰면서 소진시키므로 max()에는 남은 원소가 하나도 없다.', false),
(15976, 5924, '(14, 0)이 출력된다.', '빈 입력에서 max()가 0을 돌려준다고 본 오해다. max()는 default 인자를 주지 않으면 빈 입력에 값을 지어내지 않고 예외를 낸다.', false),
(15977, 5924, 'max() 호출에서 ValueError가 발생한다.', 'sum()이 9, 1, 4를 모두 꺼내 14를 만들며 제너레이터를 소진한다. max()는 빈 이터레이터를 받아 ValueError를 낸다. list()로 실체화하거나 한 번 순회에서 두 값을 함께 계산해야 한다.', true),
(15978, 5924, 'sum() 호출에서 TypeError가 발생한다.', 'len()·인덱싱이 안 되니 sum()도 안 된다고 본 오해다. sum()은 이터러블에서 값을 하나씩 꺼내 더할 뿐이라 제너레이터도 문제없이 받는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1930, 5925, '__next__,__next__(),__next__ 메서드,next 메서드,__next__(self)', 'for 문은 iter()로 받은 객체에서 next()로 값을 꺼내는데, 그러려면 그 객체에 __next__가 있어야 한다. Countdown의 __iter__는 자기 자신을 돌려주지만 정작 __next__가 없어, 인터프리터가 돌려받은 객체를 이터레이터로 인정하지 않고 TypeError를 낸 것이다. __next__에서 current를 하나씩 줄여 돌려주고, 0 이하가 되면 StopIteration을 일으키면 3, 2, 1이 찍힌다. __iter__는 순회를 시작할 이터레이터를 내주는 쪽이고 __next__는 값을 하나씩 꺼내는 쪽이라 둘은 역할이 다르다. 개수를 알려 주는 __len__이나 인덱스 접근용 __getitem__을 더해도 이 오류는 사라지지 않는다.'),
       (1931, 5926, '프라이밍,priming,제너레이터 프라이밍,코루틴 프라이밍,generator priming,coroutine priming,프라이밍 호출,priming call', '막 만들어진 제너레이터는 본문을 한 줄도 실행하지 않은 상태라, send()로 보낸 값을 받아 줄 yield 자리가 아직 없다. 그래서 실행 1은 TypeError가 났다. 실행 2처럼 next(avg) 또는 send(None)을 한 번 불러 첫 yield까지 미리 진행시켜 두는 것이 프라이밍이고, 그 뒤에야 send(10)의 10이 value에 들어가 평균이 계산된다. 이 단계는 제너레이터를 끝내는 close()나 안에 예외를 넣는 throw()와 다르며, 객체 생성자 __init__의 초기화와도 다르다. 반복해서 쓰는 코루틴이라면 생성 직후 next()를 대신 불러 주는 데코레이터로 이 단계를 자동화하기도 한다.');
