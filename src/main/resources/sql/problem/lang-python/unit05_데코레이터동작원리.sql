-- Unit: 데코레이터 동작 원리 (Unit ID: 216)
-- Chapter: Python (Chapter ID: 21)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (642, 216, '정의 시점 실행과 클로저, 프로퍼티 캐시'),
       (800, 216, '적용 형태별 등가 코드와 lru_cache'),
       (958, 216, '파이썬 데코레이터 실행 흐름과 실무 함정');

-- =====================================================
-- Lesson 642: 정의 시점 실행과 클로저, 프로퍼티 캐시
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4031, 642, '아래 파이썬 모듈을 그대로 실행했을 때 화면에 찍히는 순서로 옳은 것은?', '```python
def trace(func):
    print("준비")

    def wrapper(*args, **kwargs):
        print("실행")
        return func(*args, **kwargs)

    return wrapper


@trace
def work(n):
    return n * 2


work(1)
work(2)
```', 'OBJECTIVE'),
       (4032, 642, '아래 코드의 마지막 줄이 출력하는 문자열은?', '```python
def tag(name):
    def decorator(func):
        def wrapper(*args, **kwargs):
            inner = func(*args, **kwargs)
            return "<" + name + ">" + inner + "</" + name + ">"
        return wrapper
    return decorator


@tag("b")
@tag("i")
def text():
    return "hi"


print(text())
```', 'OBJECTIVE'),
       (4033, 642, '아래 비교표를 바탕으로 데코레이터 작성에 대한 설명으로 옳지 않은 것은?', '같은 래퍼를 두 가지 방식으로 만들었을 때, 데코레이트된 함수에서 읽히는 속성값을 비교한 표다.

| 속성 | functools.wraps 없이 | functools.wraps 적용 후 |
|---|---|---|
| __name__ | wrapper | 원본 함수 이름 |
| __doc__ | None | 원본 docstring |
| __module__ | 데코레이터가 정의된 모듈 | 원본 함수의 모듈 |
| __wrapped__ | 없음 | 원본 함수 참조 |', 'OBJECTIVE'),
       (4034, 642, '아래 코드의 마지막 줄이 출력하는 값은?', '```python
import functools


class CountCalls:
    def __init__(self, func):
        functools.update_wrapper(self, func)
        self.func = func
        self.count = 0

    def __call__(self, *args, **kwargs):
        self.count += 1
        return self.func(*args, **kwargs)


@CountCalls
def ping():
    return "pong"


ping()
ping()
ping()
print(ping.count)
```', 'OBJECTIVE'),
       (4035, 642, '아래 코드의 실행 결과를 만들어 내는 파이썬 함수의 성질을 가리키는 용어는?', '```python
def make_step(n):
    def step(x):
        return x + n
    return step


up3 = make_step(3)
up10 = make_step(10)

print(up3(1), up10(1))     # 4 11
print("n" in globals())    # False
```

make_step 호출은 이미 끝나 그 지역 이름 n은 모듈 어디에서도 찾을 수 없는데, up3와 up10은 각각 3과 10을 더한 값을 돌려준다.', 'SUBJECTIVE'),
       (4036, 642, '아래처럼 동작하도록 links에 붙인 파이썬 표준 라이브러리 데코레이터의 이름은?', '```python
class Page:
    def __init__(self, html):
        self.html = html

    @????                      # 여기에 붙인 데코레이터를 찾는다
    def links(self):
        print("파싱")
        return extract_links(self.html)


p = Page(doc1)
p.links        # "파싱" 출력, 0.9초 걸림
p.links        # 아무것도 출력되지 않고 곧바로 같은 결과 반환
p.__dict__     # {"html": ..., "links": [...]}

q = Page(doc2)
q.links        # "파싱" 다시 출력
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4031
(10923, 4031, '실행 → 실행 → 준비', '데코레이터 본문이 원본 호출을 모두 마친 뒤 마지막에 정리 작업처럼 돈다고 본 오개념. 준비는 def work가 읽히는 순간 이미 찍힌 뒤다.', false),
(10924, 4031, '준비 → 실행 → 실행', 'trace 본문은 @가 붙은 def가 읽힐 때 딱 한 번 돌아 준비를 찍고, 그 자리에서 반환된 wrapper가 이름 work에 묶여 호출될 때마다 실행을 찍는다.', true),
(10925, 4031, '준비 → 실행 → 준비 → 실행', '호출할 때마다 trace가 다시 불린다고 본 오개념. work에는 이미 만들어진 wrapper가 묶여 있어 이후 호출은 trace를 거치지 않는다.', false),
(10926, 4031, '실행 → 실행 (준비는 찍히지 않는다)', '@ 적용이 첫 호출까지 미뤄진다고 본 오개념. 데코레이터는 정의 시점에 즉시 적용되므로 work를 한 번도 부르지 않아도 준비는 찍힌다.', false),

-- 문제 4032
(10927, 4032, '<i><b>hi</b></i>', '위에 적은 데코레이터부터 차례로 적용된다고 본 오개념. 적용은 함수에 가까운 아래쪽부터라 i가 안쪽, b가 바깥쪽 태그가 된다.', false),
(10928, 4032, '<b>hi</b>', '겹쳐 쓴 데코레이터 중 맨 위 하나만 살아남는다고 본 오개념. 두 데코레이터 모두 적용되어 래퍼가 두 겹으로 쌓인다.', false),
(10929, 4032, '<i>hi</i>', '함수에 가장 가까운 하나만 적용된다고 본 오개념. 안쪽 래퍼가 만들어진 뒤 그 결과가 다시 위쪽 데코레이터에 넘어간다.', false),
(10930, 4032, '<b><i>hi</i></b>', 'text = tag("b")(tag("i")(text))로 풀린다. i 래퍼가 먼저 원본을 감싸고 b 래퍼가 그 위를 감싸므로, 호출은 바깥 b부터 시작해 b 태그가 가장 밖에 남는다.', true),

-- 문제 4033
(10931, 4033, 'functools.wraps를 붙이면 래퍼가 사라지고 원본 함수가 그대로 이름에 묶이므로 전처리와 후처리 코드는 실행되지 않는다.', '거짓이라 정답. wraps는 래퍼에 원본의 메타데이터를 복사할 뿐 호출 경로를 바꾸지 않는다. 원본을 __wrapped__로 따로 남긴다는 표 자체가 래퍼가 그대로 남아 있다는 뜻이다.', true),
(10932, 4033, 'wraps 없이 감싼 함수를 multiprocessing에 넘기면 pickle이 원본 정의 위치를 찾지 못해 실패할 수 있다.', '참이라 고르면 안 된다. pickle은 __module__과 이름으로 함수를 다시 찾는데, 둘 다 데코레이터 쪽 모듈의 wrapper로 남아 있어 조회가 어긋난다.', false),
(10933, 4033, 'wraps를 적용하면 __wrapped__로 원본을 꺼내 래퍼를 건너뛴 채 테스트할 수 있다.', '참이라 고르면 안 된다. 원본 참조가 남아 있어 감싸기 전 동작을 직접 검증할 수 있고, inspect.signature도 이 참조를 따라가 원본 시그니처를 보여준다.', false),
(10934, 4033, 'wraps 없이 여러 함수를 같은 데코레이터로 감싸면 트레이스백과 프로파일러에 모두 wrapper로 찍혀 서로 구분되지 않는다.', '참이라 고르면 안 된다. 이름이 전부 wrapper로 덮이므로 어느 함수가 느렸는지, 어디서 예외가 났는지를 이름만으로는 갈라낼 수 없다.', false),

-- 문제 4034
(10935, 4034, '0', 'ping이 여전히 원본 함수라 세는 코드가 끼어들지 않는다고 본 오개념. @CountCalls가 붙는 순간 이름 ping은 클래스 인스턴스를 가리킨다.', false),
(10936, 4034, '1', '호출할 때마다 인스턴스가 새로 만들어져 count가 매번 0에서 시작한다고 본 오개념. __init__은 정의 시 한 번만 돈다.', false),
(10937, 4034, '3', '@CountCalls는 ping = CountCalls(ping)과 같아 인스턴스가 하나 만들어지고, 세 번의 호출이 모두 같은 인스턴스의 __call__을 거치므로 속성 count가 3까지 오른다.', true),
(10938, 4034, '4', '정의 시점에 데코레이터가 한 번 적용되는 것을 호출 한 번으로 더해 센 오개념. 정의 시에는 __init__만 돌고 count는 0에서 출발한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1300, 4035, '클로저,closure,함수 클로저,클로져', '바깥 함수가 반환돼 그 프레임이 사라진 뒤에도 안쪽 함수 step이 자유 변수 n을 셀에 붙들고 있어 up3는 3을, up10은 10을 계속 쓴다. up3.__code__.co_freevars에 n이 잡히는 것이 근거다. 함수를 인자로 넘기고 반환할 수 있다는 일급 객체 성질은 이 구조가 성립하기 위한 전제일 뿐이고, 붙들고 있는 이름에 값을 다시 대입할 때 필요한 nonlocal은 이 구조 위에서 쓰는 키워드라 서로 구분해야 한다. 데코레이터도 원본 함수를 이 셀에 보관해 두는 같은 원리로 동작한다.'),
       (1301, 4036, 'cached_property,functools.cached_property,캐시드 프로퍼티,cached property', '괄호 없이 속성처럼 읽히고, 처음 읽을 때 계산한 값을 인스턴스 __dict__에 같은 이름으로 넣어 두는 것이 functools.cached_property다. 두 번째 접근에서 파싱이 찍히지 않는 것은 인스턴스 __dict__의 값이 같은 이름의 클래스 속성보다 먼저 읽히기 때문이고, q에서 다시 찍히는 것은 저장 자리가 인스턴스마다 따로이기 때문이다. 인자를 키로 캐시를 함수 단위로 공유하는 lru_cache나 cache와 갈리는 지점이 여기다. 저장 자리가 인스턴스 __dict__이므로 __slots__만 정의한 클래스에는 쓸 수 없고, 접근할 때마다 새로 계산해야 하는 값에는 그냥 property를 쓴다.');

-- =====================================================
-- Lesson 800: 적용 형태별 등가 코드와 lru_cache
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4979, 800, '아래 파이썬 모듈을 그대로 실행했을 때 일어나는 일로 옳은 것은?', '```python
import functools


def repeat(times=2):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for _ in range(times):
                func(*args, **kwargs)
        return wrapper
    return decorator


@repeat
def hello():
    print("hi")


hello()
```', 'OBJECTIVE'),
       (4980, 800, '아래 코드의 마지막 줄이 출력하는 값은?', '```python
from functools import lru_cache


@lru_cache(maxsize=None)
def area(w, h):
    return w * h


area(2, 3)
area(2, 3)
area(3, 2)
area(3, 2)

info = area.cache_info()
print(info.hits, info.misses)
```', 'OBJECTIVE'),
       (4981, 800, '아래 표에 정리한 세 가지 적용 방식에 대한 설명으로 옳지 않은 것은?', '함수 f에 데코레이터를 붙이는 세 가지 방식을, @를 쓰지 않은 등가 코드와 나란히 정리한 표다.

| 붙인 코드 | @ 없이 쓴 등가 코드 |
|---|---|
| @log | f = log(f) |
| @retry(times=2) | f = retry(times=2)(f) |
| 위에 @log, 아래에 @retry(times=2)를 쌓기 | f = log(retry(times=2)(f)) |', 'OBJECTIVE'),
       (4982, 800, '아래 데코레이터 구현 방식에 대한 설명으로 옳은 것은?', '함수 대신 __call__ 메서드를 정의한 클래스로도 데코레이터를 만들 수 있다. 이때 @를 붙인 이름에는 함수가 아니라, 그 클래스가 원본 함수를 받아 만들어 낸 인스턴스가 묶인다.', 'OBJECTIVE'),
       (4983, 800, '아래 세 증상을 한꺼번에 없앤 표준 라이브러리 데코레이터의 이름은?', '로깅 데코레이터를 여러 API 함수에 붙인 뒤, 운영과 개발 양쪽에서 아래 증상이 한꺼번에 나타났다.

- 프로파일러 결과에 느린 함수가 모두 wrapper라는 한 이름으로 뭉쳐, 어느 API가 느린지 갈라낼 수 없다.
- help(create_order)를 불러도 설명문이 나오지 않고, 문서 생성 도구가 만든 페이지에도 설명이 비어 있다.
- 같은 함수를 프로세스 풀에 넘기자 pickle이 함수를 찾지 못해 작업이 실패한다.

데코레이터의 동작 코드는 그대로 둔 채 안쪽 래퍼 정의 위에 표준 라이브러리 데코레이터 한 줄을 추가하자, 세 증상이 모두 사라졌다.', 'SUBJECTIVE'),
       (4984, 800, '아래처럼 동작하도록 render에 붙인 표준 라이브러리 데코레이터의 이름은?', '```python
@????                      # 이 자리에 붙인 데코레이터를 묻는다
def render(value):
    return f"<span>{value}</span>"


@render.register
def _(value: int):
    return f"<b>{value:,}</b>"


@render.register
def _(value: list):
    return "<ul>" + "".join(f"<li>{v}</li>" for v in value) + "</ul>"


print(render("hi"))        # <span>hi</span>
print(render(7000))        # <b>7,000</b>
print(render([1, 2]))      # <ul><li>1</li><li>2</li></ul>
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4979
(13451, 4979, 'hi가 두 번 출력된 뒤 정상 종료된다.', '@repeat와 @repeat()를 같은 것으로 본 오개념. repeat는 설정값을 받아 데코레이터를 돌려주는 팩토리라, 괄호를 빼면 times 자리에 기본값 2가 아니라 함수 hello가 들어간다.', false),
(13452, 4979, 'hi가 한 번만 출력된 뒤 정상 종료된다.', '괄호를 빼면 반복 설정만 무시되고 원본은 그대로 돈다고 본 오개념. 이름 hello에는 원본도 wrapper도 아닌 decorator가 묶여 있어 원본 함수는 아예 실행되지 않는다.', false),
(13453, 4979, '아무것도 출력되지 않고 hello() 호출에서 TypeError가 난다.', '@repeat는 hello = repeat(hello)와 같아 이름 hello에 decorator가 묶인다. 이어지는 hello()는 decorator를 인자 없이 부르는 셈이라 func 자리가 비어 TypeError가 난다.', true),
(13454, 4979, 'def hello 줄에서 TypeError가 나 모듈을 import하는 단계부터 실패한다.', '괄호를 빠뜨린 잘못이 적용 시점에 바로 걸린다고 본 오개념. repeat(hello)는 인자를 하나 받은 정상 호출이라 그 자리에서는 예외가 없고, 문제는 호출할 때 드러난다.', false),

-- 문제 4980
(13455, 4980, '2 2', '캐시 키는 인자를 묶은 튜플이라 (2, 3)과 (3, 2)는 서로 다른 키다. 키마다 첫 호출이 미스, 두 번째 호출이 적중이 되어 적중 2회·미스 2회로 기록된다.', true),
(13456, 4980, '3 1', '곱이 같거나 인자 구성이 같으면 한 키로 묶인다고 본 오개념. 키는 값이 아니라 인자 자리까지 포함해 만들어지므로 순서가 바뀐 (3, 2)는 새 키라 미스가 한 번 더 난다.', false),
(13457, 4980, '0 4', 'maxsize=None을 캐시를 두지 않는 설정으로 오해한 것. None은 크기 제한이 없다는 뜻이라 저장된 값이 계속 남고, 같은 키로 다시 부른 두 호출이 적중으로 잡힌다.', false),
(13458, 4980, '2 4', 'misses를 캐시를 뒤져 본 전체 횟수로 센 오개념. 적중한 호출은 misses에 들어가지 않으므로, 두 값을 더해야 비로소 전체 호출 수가 된다.', false),

-- 문제 4981
(13459, 4981, '괄호를 쓴 방식은 등가 코드에 호출이 두 번 나오는 만큼, 괄호 없는 방식보다 함수가 한 겹 더 필요하다.', '참이라 고르면 안 된다. retry(times=2)가 먼저 돌아 설정을 기억한 데코레이터를 돌려주고, 그 데코레이터가 다시 f를 받아 래퍼를 만든다. 팩토리·데코레이터·래퍼의 3중 구조다.', false),
(13460, 4981, '두 개를 쌓은 경우 f를 부르면 log가 만든 래퍼가 먼저 실행되고, 그 안에서 retry가 만든 래퍼가 원본을 부른다.', '참이라 고르면 안 된다. 등가 코드에서 log가 가장 바깥에 감싸므로 호출은 바깥부터 안으로 들어간다. 감싸는 순서는 함수에 가까운 아래쪽부터고, 실행 순서는 그 반대다.', false),
(13461, 4981, '세 방식 모두 이름 f가 def로 정의한 원본이 아닌 다른 객체를 가리키게 되어, 원본은 래퍼 안쪽 참조로만 남는다.', '참이라 고르면 안 된다. 등가 코드가 모두 f에 다시 대입하는 형태다. 원본은 래퍼의 클로저에만 남으므로, 밖에서 꺼내려면 functools.wraps가 붙여 주는 __wrapped__ 같은 통로가 필요하다.', false),
(13462, 4981, '괄호 안의 times는 f를 호출할 때마다 다시 평가되므로, 호출할 때마다 재시도 횟수를 다르게 줄 수 있다.', '거짓이라 정답. 등가 코드에서 retry(times=2)는 f를 정의하는 자리에서 딱 한 번 평가되고, 그때 받은 값이 래퍼의 클로저에 갇힌다. 호출마다 바꾸려면 래퍼가 받는 인자로 넘겨야 한다.', true),

-- 문제 4982
(13463, 4982, '메타데이터를 옮길 때도 함수로 만들 때와 똑같이 __call__ 정의 위에 functools.wraps를 붙이면 된다.', '함수형 래퍼의 습관을 그대로 옮긴 오개념. wraps는 감싸는 함수에 붙여 메타데이터를 복사하는 도구라, 여기서는 __init__ 안에서 functools.update_wrapper(self, func)를 불러야 한다.', false),
(13464, 4982, '호출 횟수처럼 호출 사이에 이어지는 값을 클로저 셀이 아니라 속성에 담아, 바깥에서 곧바로 읽을 수 있다.', '이름에 묶인 것이 객체이므로 상태를 그 객체의 속성에 두면 된다. 클로저로 같은 일을 하려면 nonlocal로 값을 고치고 래퍼에 따로 붙여 내보내야 해서, 상태를 다루는 데는 이 방식이 더 단순하다.', true),
(13465, 4982, '클래스 안의 메서드에 붙이면 인스턴스를 만들 때마다 데코레이터 객체도 새로 생겨 상태가 인스턴스별로 갈린다.', '메서드도 인스턴스마다 새로 만들어진다고 본 오개념. 감싸는 일은 클래스 정의가 읽힐 때 한 번뿐이라 데코레이터 객체는 하나고, 모든 인스턴스의 호출이 그 하나의 상태를 함께 쓴다.', false),
(13466, 4982, '감싸는 일은 함수를 처음 호출할 때 일어나므로, 한 번도 부르지 않으면 인스턴스는 만들어지지 않는다.', '적용이 첫 호출까지 미뤄진다고 본 오개념. @가 붙은 def가 읽히는 순간 클래스가 호출되어 __init__이 돌고, 그 뒤의 호출은 이미 만들어진 인스턴스의 __call__로 들어간다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1616, 4983, 'functools.wraps,wraps,@functools.wraps,@wraps', '래퍼가 원본의 __name__·__doc__·__module__·__qualname__을 덮어써서 한꺼번에 터진 증상이라, 래퍼 정의 위에 @functools.wraps(func) 한 줄을 붙여 원본 메타데이터를 복사하면 셋이 같이 풀린다. 프로파일러와 트레이스백은 __name__을, help()와 문서 도구는 __doc__을 읽고, pickle은 __module__과 __qualname__으로 원본 정의 위치를 다시 찾기 때문이다. 메타데이터만 복사할 뿐 호출 경로는 그대로라 래퍼의 전처리·후처리는 계속 실행되고, 원본은 __wrapped__로 꺼내 쓸 수 있다. 클래스로 만든 데코레이터에서 같은 일을 하려면 데코레이터로 붙이는 이 방식 대신 __init__ 안에서 functools.update_wrapper(self, func)를 부른다.'),
       (1617, 4984, 'singledispatch,functools.singledispatch,@singledispatch,@functools.singledispatch,싱글디스패치', '첫 번째 인자의 타입을 보고 등록된 구현으로 갈라 보내는 것이 functools.singledispatch다. 처음 정의한 render가 기본 구현이 되고, register로 등록한 함수들이 타입별 구현이 된다. 그래서 7000은 int용 구현으로, [1, 2]는 list용 구현으로 가고, 등록된 타입이 없는 문자열은 기본 구현으로 떨어져 span 태그가 나온다. 타입 힌트를 읽어 등록하므로 register 아래 함수 이름은 _로 둬도 된다. 갈림 기준이 첫 인자 하나뿐이라 여러 인자의 타입 조합으로 갈라 주는 다중 디스패치와 다르고, 메서드에 쓸 때는 self가 첫 인자가 되므로 singledispatchmethod를 쓴다. 실행 동작은 그대로 두고 타입 검사기에만 시그니처를 알리는 typing.overload와도 구분해야 한다.');

-- =====================================================
-- Lesson 958: 파이썬 데코레이터 실행 흐름과 실무 함정
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5927, 958, '아래 파이썬 모듈을 그대로 실행했을 때 화면에 찍히는 순서로 옳은 것은?', '```python
def a(func):
    print("a 적용")
    def wrapper():
        print("a 호출")
        return func()
    return wrapper


def b(func):
    print("b 적용")
    def wrapper():
        print("b 호출")
        return func()
    return wrapper


@a
@b
def f():
    print("f 실행")


f()
```', 'OBJECTIVE'),
       (5928, 958, '아래 코드의 마지막 줄을 실행했을 때 일어나는 일로 옳은 것은?', '```python
def log_call(func):
    def wrapper(*args, **kwargs):
        print("호출")
        return func(*args, **kwargs)
    return wrapper


class Temp:
    def __init__(self, c):
        self.c = c

    @log_call
    @property
    def f(self):
        return self.c * 9 / 5 + 32


t = Temp(100)
print(t.f)
```', 'OBJECTIVE'),
       (5929, 958, '아래 파이썬 모듈을 그대로 실행했을 때 일어나는 일로 옳은 것은?', '```python
def count_calls(func):
    count = 0

    def wrapper(*args, **kwargs):
        count += 1
        print(f"{count}번째 호출")
        return func(*args, **kwargs)

    return wrapper


@count_calls
def ping():
    return "pong"


ping()
ping()
```', 'OBJECTIVE'),
       (5930, 958, '아래 상황에서 메모리가 줄지 않은 원인으로 옳은 것은?', '이미지 서버의 Thumbnail 클래스에서 메서드 render(self, size) 위에 @lru_cache(maxsize=None)을 붙였다.

- 요청마다 Thumbnail 인스턴스를 새로 만들고, size에는 정수만 넘긴다.
- 응답을 보낸 뒤에는 그 인스턴스를 가리키는 변수를 모두 지운다.
- 요청 10만 건이 지나자 프로세스 메모리가 300MB에서 2.1GB로 늘었고, gc.collect()를 불러도 줄지 않았다.
- render 위의 데코레이터 한 줄만 지우자 같은 부하에서 메모리가 300MB 근처로 유지됐다.', 'OBJECTIVE'),
       (5931, 958, '아래 기록에서 fib 정의 위에 붙인 표준 라이브러리 데코레이터의 이름은?', '재귀 함수 fib(n)은 n이 2 이상이면 fib(n - 1) + fib(n - 2)를 돌려준다.

| 측정 | 데코레이터 없이 | 데코레이터 한 줄 추가 후 |
|---|---|---|
| fib(35) 한 번에 fib 본문이 실행된 횟수 | 29,860,703회 | 36회 |
| fib(35) 소요 시간 | 약 3.1초 | 1ms 미만 |

같은 데코레이터를 리스트를 받는 함수 total(items)에도 붙였더니, total([1, 2, 3]) 호출에서 TypeError: unhashable type: ''list''가 났다.', 'SUBJECTIVE'),
       (5932, 958, '아래 코드에서 Version 클래스에 붙인 표준 라이브러리 데코레이터의 이름은?', '```python
@????                    # 이 자리에 붙인 데코레이터를 묻는다
class Version:
    def __init__(self, major, minor):
        self.key = (major, minor)

    def __eq__(self, other):
        return self.key == other.key

    def __lt__(self, other):
        return self.key < other.key


a, b = Version(1, 2), Version(1, 10)
print(a < b)     # True
print(a <= b)    # True
print(a >= b)    # False
```

첫 줄의 데코레이터만 지우고 다시 실행하면 print(a <= b) 줄에서 TypeError가 난다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5927
(15979, 5927, 'a 적용 → b 적용 → a 호출 → b 호출 → f 실행', '위에 적은 데코레이터부터 적용된다고 본 오개념. f = a(b(f))라서 b가 먼저 원본을 받아 적용되고, 그 결과가 a에 넘어간다.', false),
(15980, 5927, 'b 적용 → a 적용 → b 호출 → a 호출 → f 실행', '호출 순서도 적용 순서와 같다고 본 오개념. 이름 f에는 가장 바깥인 a의 래퍼가 묶이므로 호출은 a 래퍼부터 들어간다.', false),
(15981, 5927, 'b 적용 → a 적용 → a 호출 → b 호출 → f 실행', '적용은 def에 가까운 b부터 정의 시점에 한 번씩 돈다. 호출하면 가장 바깥 a의 래퍼가 먼저 돌고, 그 안의 func가 b의 래퍼라 b 호출을 거쳐 원본에 닿는다.', true),
(15982, 5927, 'b 적용 → a 적용 → a 호출 → f 실행', '바깥 래퍼가 안쪽 래퍼를 대체한다고 본 오개념. a가 받은 func는 원본이 아니라 b의 래퍼라서, a 래퍼가 func()를 부르면 b 호출도 반드시 찍힌다.', false),

-- 문제 5928
(15983, 5928, '"호출"이 찍힌 뒤 212.0이 출력된다.', '데코레이터 순서가 결과에 영향이 없다고 본 오개념. log_call이 property 객체를 평범한 함수로 감싸 버려, f는 더 이상 속성처럼 값을 계산하지 않는다.', false),
(15984, 5928, '"호출" 없이 212.0만 출력된다.', 'property가 바깥에서 그대로 동작한다고 본 오개념. 가장 바깥에 있는 것은 log_call의 래퍼라 클래스 속성 f는 property가 아니라 일반 함수다.', false),
(15985, 5928, '"property" 객체는 호출할 수 없다는 TypeError가 난다.', 'print(t.f)에서 래퍼를 부르지 않는다는 점을 놓친 오개념. 이 TypeError는 t.f()로 래퍼를 실제로 호출해 func(self)가 property 객체를 부를 때 난다.', false),
(15986, 5928, '"호출" 없이 온도 값 대신 메서드 객체의 표현이 출력된다.', '클래스 속성 f가 래퍼 함수라 t.f는 t에 묶인 메서드 객체일 뿐 호출되지 않는다. property처럼 디스크립터를 만드는 데코레이터는 가장 위(바깥)에 둬야 한다.', true),

-- 문제 5929
(15987, 5929, '"1번째 호출", "2번째 호출"이 차례로 찍힌다.', '클로저 안에서 바깥 변수를 그대로 고칠 수 있다고 본 오개념. count += 1은 대입이라 count가 wrapper의 지역 변수로 취급되므로 nonlocal count가 있어야 이렇게 된다.', false),
(15988, 5929, '첫 번째 ping() 호출에서 UnboundLocalError가 난다.', '래퍼 안에 count 대입이 있어 count는 wrapper의 지역 이름이 되고, 값이 없는 상태에서 읽으려다 실패한다. 적용은 정상이고 래퍼를 처음 실행할 때 드러난다.', true),
(15989, 5929, '"1번째 호출"이 두 번 찍힌다.', '호출마다 바깥 count를 복사해 0에서 새로 센다고 본 오개념. 파이썬은 복사하지 않고 대입이 있으면 지역 이름으로 보므로 첫 호출부터 예외가 난다.', false),
(15990, 5929, '@count_calls가 적용되는 def ping 줄에서 예외가 난다.', '이름 오류가 적용 시점에 걸린다고 본 오개념. count_calls 본문은 wrapper를 정의만 하고 실행하지 않아, 정의 시점에는 아무 문제 없이 wrapper가 반환된다.', false),

-- 문제 5930
(15991, 5930, '캐시 키에 self가 포함돼 캐시가 인스턴스를 계속 참조하므로, 다 쓴 인스턴스도 해제되지 않는다.', 'lru_cache는 함수 하나에 캐시 하나를 두고 인자 전체를 키로 쓴다. 메서드에서는 self도 인자라 키가 인스턴스를 붙들고, 크기 제한이 없어 요청마다 쌓인다.', true),
(15992, 5930, '인스턴스마다 별도 캐시가 생겨 각 인스턴스의 __dict__에 결과가 저장되므로 계속 쌓인다.', 'cached_property와 섞은 오개념. lru_cache의 캐시는 함수에 하나뿐이고, 설령 인스턴스 __dict__에 있었다면 인스턴스와 함께 해제됐을 것이다.', false),
(15993, 5930, '래퍼가 클로저로 원본을 붙들고 있어서, 호출할 때마다 원본 함수 객체가 새로 복제돼 쌓인다.', '클로저가 호출마다 복제본을 만든다고 본 오개념. 원본은 정의 시점에 한 번 클로저 셀에 담길 뿐이고, 호출을 거듭해도 함수 객체가 늘지 않는다.', false),
(15994, 5930, '캐시가 size를 해시할 수 없는 값으로 보고, 결과를 키 없이 매번 새 항목으로 저장해 쌓는다.', '해시 불가 인자의 동작을 잘못 안 오개념. 해시할 수 없는 인자면 저장하지 않고 TypeError가 나며, 본문의 size는 해시 가능한 정수다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1932, 5931, 'lru_cache,functools.lru_cache,@lru_cache,@functools.lru_cache,lru_cache(maxsize=None),@lru_cache(maxsize=None),functools.lru_cache(maxsize=None),@functools.lru_cache(maxsize=None),cache,functools.cache,@cache,@functools.cache', '인자를 키로 반환값을 저장해 두었다가 같은 인자로 다시 부르면 본문을 건너뛰는 메모이제이션 데코레이터가 functools.lru_cache다(크기 제한이 없는 functools.cache도 같은 역할). 캐시가 없으면 fib(35)는 같은 부분 문제를 수없이 다시 풀어 호출이 지수적으로 늘지만, 캐시를 붙이면 fib(0)부터 fib(35)까지 36개 값을 한 번씩만 계산한다. 인자를 딕셔너리 키로 쓰기 때문에 리스트처럼 해시할 수 없는 인자가 오면 TypeError가 난다. 인스턴스 속성에 첫 계산 결과를 저장하는 cached_property와 달리 캐시가 함수 하나에 모이며, 메서드에 쓰면 self까지 키에 잡혀 인스턴스가 해제되지 않는 점도 구분해야 한다.'),
       (1933, 5932, 'total_ordering,functools.total_ordering,@total_ordering,@functools.total_ordering,토탈 오더링,토탈오더링', '__eq__와 비교 메서드 하나(여기서는 __lt__)만 정의하면 나머지 __le__·__gt__·__ge__를 채워 주는 클래스 데코레이터가 functools.total_ordering이다. 데코레이터가 없으면 Version에는 __le__가 없고, 반대쪽의 __ge__도 없어 a <= b가 TypeError로 끝난다. a > b는 반대쪽 __lt__로 뒤집어 풀리므로 없어도 동작한다는 점과 구분된다. 필드 선언을 바탕으로 __init__·__repr__·__eq__ 등을 만들어 주는 dataclass와는 쓰임이 다르며, dataclass(order=True)는 클래스에 이미 __lt__가 있으면 TypeError를 내므로 이 코드에 붙일 수 없다.');
