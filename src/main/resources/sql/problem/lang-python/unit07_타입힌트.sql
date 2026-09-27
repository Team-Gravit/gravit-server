-- Unit: 타입 힌트 (Unit ID: 218)
-- Chapter: Python (Chapter ID: 21)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (644, 218, 'Protocol과 불공변, 타입 좁히기'),
       (802, 218, 'Any와 object 차이, 전방 참조'),
       (960, 218, '파이썬 타입 힌트: 검사기가 읽어 내는 힌트의 모양');

-- =====================================================
-- Lesson 644: Protocol과 불공변, 타입 좁히기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4043, 644, '아래 코드를 파이썬 3.12 인터프리터로 실행한 결과로 옳은 것은?', '```python
def repeat(text: str, n: int) -> str:
    return text * n

print(repeat("ab", 3))
print(repeat(5, 3))
print(repeat.__annotations__["n"])
```', 'OBJECTIVE'),
       (4044, 644, '아래 비교표를 바탕으로 한 설명 중 옳지 않은 것은?', '| 도구 | 검사 방식 | 실행 중 영향 |
|---|---|---|
| abc.ABC | 명목적 — 상속 관계로 판단 | 추상 메서드가 남아 있으면 인스턴스화 차단 |
| Protocol | 구조적 — 메서드 형태로 판단 | 없음 (runtime_checkable을 붙이면 isinstance 가능) |
| TypedDict | 구조적 — 키 이름과 값 타입으로 판단 | 없음 (만들어지는 값은 그냥 dict) |', 'OBJECTIVE'),
       (4045, 644, '아래 오류 로그의 원인을 없애는 조치로 옳은 것은?', '```python
# app.py
def head[T](xs: list[T]) -> T:
    return xs[0]
```

```
$ python3.9 app.py
  File "app.py", line 3
    def head[T](xs: list[T]) -> T:
             ^
SyntaxError: invalid syntax
```', 'OBJECTIVE'),
       (4046, 644, '아래 코드를 정적 검사기로 검사했을 때에 대한 설명으로 옳은 것은?', '```python
class Animal: ...
class Dog(Animal): ...

def feed_all(animals: list[Animal]) -> None:
    animals.append(Animal())

dogs: list[Dog] = [Dog()]
feed_all(dogs)   # 검사기가 이 줄을 오류로 보고한다
```', 'OBJECTIVE'),
       (4047, 644, '아래 상황에서 팀이 도입한 라이브러리의 이름은?', '사용자 등록 API가 요청 JSON을 그대로 받아 쓰다가, age 자리에 문자열이 담긴 요청 때문에 며칠 뒤 통계 배치에서 TypeError가 났다. 핸들러 힌트에는 age: int라고 적혀 있었지만 요청을 받는 시점에는 아무 일도 일어나지 않았다.

팀은 라이브러리 하나를 얹고 요청 모델 클래스에 같은 힌트를 그대로 옮겼다. 그 뒤로 {"age": "42"}는 42로 바뀐 채 핸들러에 들어오고, {"age": "abc"}는 핸들러에 닿기도 전에 ValidationError로 걸러져 400 응답이 된다. FastAPI가 요청 검증에 쓰는 것도 이 라이브러리다.', 'SUBJECTIVE'),
       (4048, 644, '아래 검사 결과에서 같은 호출의 성패를 가른 검사기 동작을 가리키는 용어는?', '```python
1  def find_email(user_id: int) -> str | None: ...
2
3  email = find_email(7)
4
5  email.upper()
6  if email is not None:
7      email.upper()
8  if isinstance(email, str):
9      email.strip()
```

```
$ mypy app.py
app.py:5: error: Item "None" of "str | None" has no attribute "upper"
Found 1 error in 1 file (checked 1 source file)
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4043
(10955, 4043, 'ababab가 출력된 뒤 두 번째 호출에서 인자가 힌트와 달라 TypeError가 나고 실행이 멈춘다.', '인터프리터는 힌트를 검사하지 않는다. repeat(5, 3)은 정수 5에 곱셈을 적용해 15를 돌려주므로 오류 없이 지나간다. 힌트가 실행을 막아 준다는 오해다.', false),
(10956, 4043, '힌트와 맞지 않는 호출이 있어 실행이 시작되기 전에 걸러지고 아무것도 출력되지 않는다.', '힌트 대조는 mypy 같은 별도 도구가 소스를 읽어서 하는 일이다. 파이썬은 힌트를 저장만 해 두고 실행 흐름에 개입하지 않아, 검사기를 돌리지 않으면 아무도 지적하지 않는다.', false),
(10957, 4043, 'ababab, 15, <class ''int''>가 차례로 출력된다.', 'repeat(5, 3)은 정수 곱셈이 되어 15가 나온다. 힌트는 __annotations__에 타입 객체로 담기므로 n 키를 꺼내면 문자열이 아니라 <class ''int''>가 찍힌다.', true),
(10958, 4043, 'ababab, 555, <class ''str''>가 차례로 출력된다.', '힌트를 보고 인자 5를 문자열 "5"로 바꿔 준다고 오해한 것. 값을 실제로 바꾸는 일은 힌트를 읽는 별도 검증 라이브러리의 몫이고, n의 힌트도 str이 아니라 int다.', false),

-- 문제 4044
(10959, 4044, 'TypedDict로 만든 값은 실행 중 전용 클래스의 인스턴스가 되어, 명세에 없는 키를 넣으면 그 자리에서 예외가 난다.', '만들어지는 값은 평범한 dict라 실행 중에는 아무 제약이 없다. 명세에 없는 키는 검사기가 소스를 읽을 때 지적할 뿐이므로 이 진술이 거짓이다.', true),
(10960, 4044, 'Protocol에 적은 메서드만 갖추면 그 Protocol을 상속하지 않은 외부 라이브러리 객체도 인자로 받을 수 있다.', '참. 구조적 방식은 상속 계보가 아니라 메서드 형태만 보므로, 소스를 고칠 수 없는 남의 클래스에도 인터페이스를 씌울 수 있다.', false),
(10961, 4044, 'abc.ABC를 상속한 클래스는 추상 메서드를 구현하지 않으면 객체를 만드는 순간 실행이 막힌다.', '참. 명목적 방식은 상속을 통해 계약을 걸어 두고, 구현이 빠진 상태의 인스턴스화를 실행 중에 직접 차단한다.', false),
(10962, 4044, 'Protocol은 표시를 따로 붙여야 isinstance로 판별할 수 있지만 abc.ABC 계층은 그대로 판별된다.', '참. runtime_checkable을 붙이지 않은 Protocol은 검사기 전용이라 isinstance 대상이 아니다. abc 계층은 상속 관계가 남아 있어 바로 판별된다.', false),

-- 문제 4045
(10963, 4045, 'list[T]를 typing.List[T]로 바꾸면 이 버전에서도 문법이 통한다.', '내장 list를 대괄호로 쓰는 표기는 3.9부터 이미 허용된다. 파서가 걸린 지점은 함수 이름 뒤의 대괄호라서 컨테이너 표기를 바꿔도 오류가 그대로 남는다.', false),
(10964, 4045, '파일 맨 위에 from __future__ import annotations를 추가하면 오류가 사라진다.', '이 선언은 힌트를 문자열로 미뤄 두게 할 뿐이다. 걸린 것은 힌트가 아니라 함수 정의 자체의 문법이라, 힌트를 언제 평가하든 파서가 읽는 순간 똑같이 막힌다.', false),
(10965, 4045, '반환 힌트를 "T"처럼 따옴표로 감싸면 이름을 찾지 못하는 문제가 풀린다.', '따옴표는 아직 정의되지 않은 클래스 이름을 미뤄 참조할 때 쓰는 방법이다. 로그가 가리키는 곳은 def 줄의 대괄호이고 NameError도 아니라서 소용이 없다.', false),
(10966, 4045, 'TypeVar로 T를 먼저 선언하고 def head(xs: list[T]) -> T: 형태로 정의를 바꾼다.', '함수 이름 뒤에 타입 변수를 적는 표기는 3.12에서 들어온 문법이다. 3.9에서는 모듈 수준에 TypeVar("T")를 만들어 쓰는 예전 방식이어야 파서를 통과한다.', true),

-- 문제 4046
(10967, 4046, 'Dog가 Animal의 하위 타입으로 인정되지 않아서 생긴 오류다.', '상속 관계가 있으니 Dog는 Animal의 하위 타입이 맞다. 막힌 것은 클래스끼리의 관계가 아니라 그 클래스를 원소로 담은 리스트끼리의 관계다.', false),
(10968, 4046, '리스트는 원소 타입이 정확히 같아야 인자로 받아들여져서, 하위 타입을 담은 리스트도 거부된다.', '리스트는 읽기와 쓰기가 모두 되므로 원소 타입을 넓혀 받으면 함수 안에서 Animal()을 넣어 버릴 수 있다. 그래서 검사기는 원소 타입이 어긋나는 전달을 막는다.', true),
(10969, 4046, 'feed_all 본문에서 append 줄을 지우면 dogs를 넘겨도 검사기가 통과시킨다.', '검사기는 함수 본문이 아니라 선언된 매개변수 타입만 보고 호출부를 판단한다. 본문을 비워도 list[Animal] 자리에 list[Dog]를 넣는 것은 그대로 막힌다.', false),
(10970, 4046, '매개변수를 Sequence[Animal]로 바꿔도 같은 이유로 여전히 거부된다.', '읽기만 되는 Sequence는 원소 타입을 넓혀 받아도 안전해서 하위 타입 리스트를 그대로 통과시킨다. 입력은 넓게 받으라는 원칙이 여기서 나온다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1304, 4047, 'pydantic,파이단틱,파이댄틱,피단틱,피댄틱', '힌트를 그대로 검증 규칙으로 삼아 실행 중에 입력을 검사하고 필요하면 값까지 바꿔 주는 라이브러리가 pydantic이다. 기본 모드에서는 "42"를 42로 받아 주고, 바꿀 수 없는 "abc"에는 ValidationError를 낸다. mypy·pyright는 소스만 읽고 실행 중 값에는 손대지 않으니 이 자리를 대신할 수 없고, typeguard·beartype은 호출 인자를 검사해 알려 줄 뿐 값을 변환하지 않는다는 점에서 구분된다. 외부 입력이 들어오는 경계에서만 이런 검증을 두고 내부 호출은 검사기에 맡기는 것이 성능과 안전의 균형점이다.'),
       (1305, 4048, '타입 좁히기,타입좁히기,좁히기,타입 내로잉,내로잉,narrowing,type narrowing', 'is not None·isinstance 같은 조건을 만나면 검사기는 그 분기 안에서 변수가 가질 수 있는 타입 후보를 줄여서 다룬다. 이것이 타입 좁히기(narrowing)다. 5번 줄은 어떤 조건도 거치지 않아 str | None 그대로라 None에 upper를 부르는 경우가 남지만, 6~9번 줄의 분기 안에서는 후보가 str만 남아 같은 호출이 통과한다. 조건 판정 결과를 사용자 함수로 알려 주는 TypeGuard·TypeIs는 이 동작을 넓힌 장치이고, 검사기에게 타입을 우기는 cast나 값을 실제로 바꾸는 형 변환과는 구분해야 한다.');

-- =====================================================
-- Lesson 802: Any와 object 차이, 전방 참조
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4991, 802, '아래 코드에서 (A)와 (B)의 검사 결과가 갈린 이유로 옳은 것은?', '```python
from typing import Any

def total(payload: Any) -> int:
    return payload["count"] * 2       # (A) 정적 검사기가 아무 오류도 보고하지 않는다

def total2(payload: object) -> int:
    return payload["count"] * 2       # (B) 정적 검사기가 오류로 보고한다
```', 'OBJECTIVE'),
       (4992, 802, '아래 코드를 실행한 결과와 그 원인으로 옳은 것은?', '```python
def collect(item: int, bucket: list[int] = []) -> list[int]:
    bucket.append(item)
    return bucket

print(collect(1))
print(collect(2))
```', 'OBJECTIVE'),
       (4993, 802, '아래 비교표를 바탕으로 한 설명 중 옳지 않은 것은?', '| 도구 | 힌트를 읽는 시점 | 값에 하는 일 |
|---|---|---|
| mypy · pyright | 배포 전, 소스 파일을 읽어 대조 | 없음 — 실행되는 코드에 포함되지 않는다 |
| pydantic | 모델 객체를 만드는 순간(실행 중) | 규칙에 맞는지 검사하고, 기본 모드에서는 값 변환까지 한다 |
| typeguard · beartype | 데코레이터를 붙인 함수를 호출할 때(실행 중) | 검사해서 알릴 뿐 값은 그대로 둔다 |', 'OBJECTIVE'),
       (4994, 802, '아래 코드를 파이썬 3.11로 실행한 결과로 옳은 것은?', '```python
class Node:
    def __init__(self, value: int, next: Node | None = None) -> None:
        self.value = value
        self.next = next

head = Node(1)
print(head.value)
```', 'OBJECTIVE'),
       (4995, 802, '아래 상황이 보여 주는 파이썬의 타이핑 방식을 가리키는 용어는?', '3년째 돌아가는 정산 서비스에 검사 도구를 들이기로 했다. 코드 전체에 힌트를 붙이는 데 몇 달이 걸릴 것 같아, 팀은 이번 분기에 새로 쓴 모듈에만 힌트를 달고 CI 검사 대상 폴더를 스프린트마다 하나씩 늘리기로 했다.

힌트를 아직 달지 않은 모듈은 검사에서 빠진 채 예전과 똑같이 배포됐고, 힌트를 단 모듈도 배포물의 동작은 달라지지 않았다. 두 달 뒤 검사 범위는 전체의 절반이 됐지만 그동안 서비스가 멈춘 적은 한 번도 없었다.', 'SUBJECTIVE'),
       (4996, 802, '아래 오류를 없애려면 timeout 매개변수에 적어야 할 힌트 표기는?', '```python
# client.py
def fetch(url: str, timeout: int = None) -> str:
    ...
```

```
$ mypy client.py
client.py:2: error: Incompatible default for argument "timeout" (default has type "None", argument has type "int")
Found 1 error in 1 file (checked 1 source file)
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4991
(13483, 4991, 'object는 모든 값을 담을 수 있는 최상위 타입이라 어떤 연산이든 허용되고, Any는 타입이 아직 정해지지 않아 사용을 막기 때문이다.', '두 이름의 역할을 맞바꾼 오개념이다. object는 값을 넓게 받을 뿐 꺼내 쓸 수 있는 동작은 모든 객체의 공통 동작뿐이고, 어떤 연산이든 통과시키는 쪽은 오히려 Any다.', false),
(13484, 4991, 'Any로 받은 값에는 호출할 때마다 isinstance 검사가 자동으로 붙어서, 검사기가 소스에서 따로 볼 필요가 없기 때문이다.', '힌트는 실행 중 값 검사를 붙이지 않는다. Any는 실행에 아무 흔적도 남기지 않으며, 검사기에게 이 값은 대조하지 말라고 알리는 표시일 뿐이다.', false),
(13485, 4991, 'Any는 어떤 연산과도 호환된다고 보아 검사기가 (A)의 본문 대조를 건너뛰지만, object에는 대괄호 접근이 정의돼 있지 않아 (B)에서 걸리기 때문이다.', 'Any는 검사를 사실상 끄는 탈출구라 실제로 버그가 있어도 지적되지 않는다. 반대로 object는 공통 동작만 가진 최소 타입이라 대괄호 접근에서 바로 걸린다. 타입을 모르면 object로 받고 쓰는 지점에서 좁히라는 권고가 여기서 나온다.', true),
(13486, 4991, '(A)는 반환 힌트가 int로 적혀 있어 검사기가 본문을 보지 않고 넘어갔고, (B)는 반환 힌트가 없어 본문까지 살폈기 때문이다.', '두 함수 모두 반환 힌트가 int로 같다. 반환 힌트는 본문 검사 여부를 정하지 않으며, 검사기는 힌트가 붙은 함수의 본문을 끝까지 살핀다. 결과를 가른 것은 매개변수 쪽 힌트다.', false),

-- 문제 4992
(13487, 4992, '[1]과 [2]가 차례로 출력된다. 힌트 list[int]가 호출마다 비어 있는 새 리스트를 만들어 주기 때문이다.', '힌트는 값을 만들지도 비우지도 않는다. 기본값 자리의 빈 리스트는 def 문을 실행할 때 딱 한 번 만들어져 함수 객체에 매달려 있으며, 힌트를 붙이든 지우든 이 동작은 그대로다.', false),
(13488, 4992, '[1]과 [1, 2]가 차례로 출력된다. 기본값 리스트가 정의 시점에 한 번만 만들어져 호출 사이에 남고, 힌트는 이를 막지 않기 때문이다.', '기본값은 def를 실행할 때 평가돼 함수에 저장되므로 두 호출이 같은 리스트를 공유한다. 힌트는 원소 타입만 말할 뿐 이 공유를 막지 못한다. bucket: list[int] | None = None으로 받고 함수 안에서 새로 만드는 것이 정석이다.', true),
(13489, 4992, '[1]이 출력된 뒤, 두 번째 호출에서 bucket의 상태가 힌트와 어긋나 TypeError가 나고 실행이 멈춘다.', '실행 중에 인자와 힌트를 대조하는 절차 자체가 없어 TypeError가 날 자리도 없다. 두 번째 호출은 이미 1이 담긴 리스트에 2를 덧붙여 조용히 끝난다.', false),
(13490, 4992, '[1]과 [1, 2]가 차례로 출력된다. 같은 리스트를 공유하기 때문인데, mypy --strict를 돌리면 이 기본값을 타입 오류로 잡아 준다.', '출력과 원인은 맞지만 뒷말이 틀렸다. 빈 리스트는 list[int]에 맞는 값이라 검사기가 지적할 근거가 없다. 가변 기본값은 타입이 어긋난 문제가 아니라 수명이 길어 생기는 문제여서 린터 규칙이 맡는 영역이다.', false),

-- 문제 4993
(13491, 4993, 'typeguard를 붙인 함수에 잘못된 타입의 인자가 오면 알림은 받지만 값이 고쳐지지는 않으므로, 호출부나 입력 쪽을 직접 손봐야 한다.', '참. 표의 typeguard 행은 실행 중 검사만 하고 값은 그대로 둔다. 검사는 문제를 드러내 줄 뿐이라 잘못된 값을 바로잡는 일은 여전히 코드를 쓰는 쪽의 몫이다.', false),
(13492, 4993, '외부 요청은 pydantic 모델로 받고 내부 함수 호출은 검사기에 맡기면, 실행 중 검사에 드는 비용을 시스템 경계에서만 치르게 된다.', '참. 실행 중 비용이 드는 쪽은 pydantic과 typeguard뿐이고 mypy·pyright는 실행되는 코드에 남지 않는다. 그래서 검증은 입력이 들어오는 경계에 두고 내부는 정적 검사에 맡기는 배치가 나온다.', false),
(13493, 4993, 'pydantic 모델을 통과한 값은 힌트와 같은 타입이라고 믿어도 되지만, mypy만 통과한 코드에 실행 중 들어오는 값에는 같은 보장이 없다.', '참. pydantic은 실행 중 실제 값을 확인한 뒤 통과시키지만, 정적 검사는 소스에 적힌 힌트끼리 앞뒤가 맞는지만 본다. 밖에서 들어오는 값이 힌트와 다를 가능성은 소스만 읽어서는 닫히지 않는다.', false),
(13494, 4993, 'mypy --strict를 CI에서 통과시켜 두면 배포된 서버가 실행 중에도 힌트와 다른 요청 값을 걸러 낸다.', '거짓이라 이 선지를 고른다. 표의 mypy 행은 배포 전에 소스만 읽고 실행되는 코드에는 포함되지 않는다. CI 통과는 소스의 앞뒤가 맞는다는 뜻일 뿐, 실행 중 들어오는 값을 막아 주지는 못한다.', true),

-- 문제 4994
(13495, 4994, 'class 문을 처리하다가 매개변수 힌트를 평가하는 순간 Node라는 이름이 아직 없어 NameError가 나고, 1은 출력되지 않는다.', '힌트는 검사되지 않을 뿐 평가는 된다. def 줄을 실행하는 시점에는 class 블록이 아직 끝나지 않아 Node라는 이름이 만들어지기 전이다. 힌트를 따옴표로 감싸거나 from __future__ import annotations를 쓰면 평가를 미룰 수 있다.', true),
(13496, 4994, '힌트는 실행에 관여하지 않으므로 1이 정상 출력되고, 이 문제는 검사기를 돌려야만 드러난다.', '검사되지 않는 것과 평가되지 않는 것은 다르다. 힌트 자리에 적은 식은 def를 실행할 때 실제로 계산되므로, 아직 없는 이름을 적으면 검사기를 돌리기 전에 실행이 먼저 멈춘다.', false),
(13497, 4994, 'next의 기본값 None이 힌트와 맞지 않아 Node(1) 호출에서 TypeError가 나고, 1은 출력되지 않는다.', 'Node | None은 None도 허용하는 표기라 기본값과 어긋나지 않는다. 게다가 실행 중에 인자와 힌트를 대조하는 절차가 없으므로 이런 이유의 TypeError는 애초에 나지 않는다.', false),
(13498, 4994, '3.11에서는 모든 힌트가 자동으로 문자열로 저장되어 평가가 미뤄지므로 1이 정상 출력된다.', '힌트 평가를 기본으로 미루는 동작은 3.14부터다. 그 전 버전에서는 파일 맨 위에 from __future__ import annotations를 직접 적어야 같은 효과를 얻는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1620, 4995, '점진적 타이핑,점진적타이핑,그래주얼 타이핑,그레주얼 타이핑,gradual typing,gradualtyping,점진적 타입 검사,점진적 타입 지정', '힌트를 붙인 곳만 검사기가 대조하고 나머지는 그대로 두는 파이썬의 방식이 점진적 타이핑이다. 모든 선언을 컴파일 시점에 요구하는 정적 타이핑도, 힌트를 아예 쓰지 않는 동적 타이핑도 아니라는 점이 핵심이다. 힌트를 더해도 배포물의 동작이 달라지지 않기 때문에 이런 부분 도입이 가능하고, 이것이 힌트를 실행 중에 강제하지 않는 이유이기도 하다. 검사 범위를 넓혀 가는 일은 mypy의 검사 대상 설정이 맡고, 실행 중 값을 실제로 검사하는 pydantic과는 층이 다르다.'),
       (1621, 4996, 'int | None,int|None,int |None,int| None,Optional[int],Optional [int],typing.Optional[int]', '기본값으로 None을 줄 거면 힌트도 None을 허용해야 한다. 3.10부터는 int | None으로 쓰고, 그 이전 버전을 지원해야 하면 typing.Optional[int]로 쓴다. 둘은 같은 뜻이며 Optional은 인자를 생략해도 된다는 뜻이 아니라 값이 None일 수도 있다는 뜻이다. 예전 검사기가 이런 코드를 암묵적으로 봐주던 관행은 사라져서, 지금은 명시하지 않으면 그대로 오류가 된다. 이렇게 고친 뒤에는 timeout을 숫자로 쓰는 자리에서 다시 오류가 나므로, is not None 같은 조건으로 좁혀서 써야 한다.');

-- =====================================================
-- Lesson 960: 파이썬 타입 힌트: 검사기가 읽어 내는 힌트의 모양
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5939, 960, '아래 코드에서 검사기가 오류로 보고한 원인과 고치는 방법으로 옳은 것은?', '```python
from collections.abc import Sequence

def load_tags(path: str) -> Sequence[str]:
    with open(path) as f:
        return [line.strip() for line in f]

tags = load_tags("tags.txt")
tags.append("new")   # mypy가 이 줄을 오류로 보고한다
```', 'OBJECTIVE'),
       (5940, 960, '아래 코드를 파이썬 3.12로 실행했을 때 출력으로 옳은 것은?', '```python
from __future__ import annotations

def scale(x: int, factor: float = 1.5) -> float:
    return x * factor

print(scale.__annotations__)
```', 'OBJECTIVE'),
       (5941, 960, '아래 검사 로그의 오류를 없애면서 requests 호출도 계속 타입 검사를 받으려면 해야 할 조치로 옳은 것은?', '```python
# app.py
import requests

def fetch_status(url: str) -> int:
    return requests.get(url, timeout=3).status_code
```

```
$ pip show requests | head -2
Name: requests
Version: 2.32.3
$ mypy app.py
app.py:2: error: Library stubs not installed for "requests"  [import-untyped]
Found 1 error in 1 file (checked 1 source file)
```', 'OBJECTIVE'),
       (5942, 960, '아래 커밋을 검사기로 검사했을 때에 대한 설명으로 옳은 것은?', '```python
from typing import Literal, assert_never

Mode = Literal["r", "w", "a"]   # 이번 커밋에서 "a"를 추가했다

def mode_label(mode: Mode) -> str:
    match mode:
        case "r":
            return "읽기"
        case "w":
            return "쓰기"
        case _:
            assert_never(mode)
```', 'OBJECTIVE'),
       (5943, 960, '아래 코드에서 (가)에 들어갈 이름은?', '```python
import socket
from typing import (가)

class Closable((가)):
    def close(self) -> None: ...

def shutdown(resource: Closable) -> None:
    resource.close()

shutdown(open("app.log"))    # 내장 파일 객체
shutdown(socket.socket())    # 표준 라이브러리 소켓
shutdown(db_conn)            # 외부 드라이버가 돌려준 커넥션 객체
shutdown(42)
```

처음에는 (가) 자리에 abc 모듈의 ABC를 두었는데, mypy가 네 호출을 모두 오류로 보고했다. 앞의 세 객체는 소스를 고칠 수 없는 클래스라 Closable을 상속하게 만들 수도 없었다. typing 모듈에서 가져온 (가)로 바꾸자 나머지 코드는 그대로인데 마지막 shutdown(42) 호출만 오류로 남았다.', 'SUBJECTIVE'),
       (5944, 960, '아래 검사 결과에서 (가)에 들어갈 이름은?', '```python
1  def is_text(x: object) -> bool:
2      return isinstance(x, str)
3
4  def describe(value: int | str) -> str:
5      if is_text(value):
6          return value.upper()
7      else:
8          return str(value + 1)
```

```
$ mypy app.py        # Python 3.13
app.py:6: error: Item "int" of "int | str" has no attribute "upper"
app.py:8: error: Unsupported operand types for + ("str" and "int")
Found 2 errors in 1 file (checked 1 source file)
```

1번 줄의 반환 힌트 bool을 TypeGuard[str]로 바꾸자 6번 줄 오류만 사라지고 8번 줄 오류는 남았다. 같은 자리를 (가)[str]로 바꾸자 두 오류가 모두 사라졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5939
(16011, 5939, '반환 힌트가 읽기 동작만 약속하는 타입이라 호출부에서 원소 추가가 막힌다. 반환 힌트를 list[str]로 좁혀 적는다.', 'Sequence는 인덱싱·길이·순회만 약속하고 append는 없다. 호출부가 무엇을 할 수 있는지는 반환 힌트가 정하므로, 반환은 실제 구체 타입으로 좁게 적는 것이 원칙이다.', true),
(16012, 5939, 'list[str] 값을 Sequence[str]로 돌려주는 것 자체가 리스트의 불변성에 걸린다. return 줄을 tuple(...)로 감싼다.', '불변성은 list끼리의 원소 타입 문제다. 읽기 전용인 Sequence는 list[str]을 그대로 받아 준다. tuple로 감싸도 append가 없는 것은 같아 오류가 그대로 남는다.', false),
(16013, 5939, '실행하면 tags가 Sequence 객체로 바뀌어 append 호출에서 AttributeError가 난다. 반환값을 list()로 한 번 더 감싼다.', '힌트는 값을 바꾸지 않는다. 실행 중 tags는 그냥 list라 append가 정상 동작하고, 오류는 소스만 읽는 검사기에서만 난다. list()로 감싸도 힌트가 Sequence면 검사 결과는 같다.', false),
(16014, 5939, '반환 힌트가 너무 좁아서 생긴 오류다. 반환 힌트를 Iterable[str]처럼 더 넓은 타입으로 바꾼다.', '넓게 받는 원칙을 반환에 잘못 적용한 오개념이다. Iterable은 순회만 약속해 Sequence보다도 쓸 수 있는 동작이 적다. 반환을 넓힐수록 호출부가 할 수 있는 일은 줄어든다.', false),

-- 문제 5940
(16015, 5940, '{''x'': <class ''int''>, ''factor'': <class ''float''>, ''return'': <class ''float''>}', '__future__ 선언이 없을 때의 결과다. 이 선언(PEP 563)이 있으면 힌트를 평가하지 않고 소스에 적힌 글자 그대로 문자열로 저장하므로 타입 객체가 나오지 않는다.', false),
(16016, 5940, '{''x'': ''int'', ''factor'': ''float'', ''return'': ''float''}', 'from __future__ import annotations는 모든 힌트를 문자열로 저장해 평가를 미룬다. 실제 타입 객체가 필요하면 typing.get_type_hints()로 문자열을 해석해야 한다.', true),
(16017, 5940, '{}', '이 선언이 힌트를 버린다고 오해한 것이다. 힌트는 여전히 __annotations__에 저장되고, 달라지는 것은 타입 객체 대신 문자열로 남는다는 점뿐이다.', false),
(16018, 5940, '{''x'': ''int'', ''factor'': ''float = 1.5'', ''return'': ''float''}', '문자열로 저장되는 것은 힌트 식뿐이다. 기본값 1.5는 힌트가 아니라 함수의 __defaults__에 따로 담기므로 factor 항목은 ''float''만 남는다.', false),

-- 문제 5941
(16019, 5941, 'pip install --upgrade requests로 라이브러리를 최신 버전으로 다시 설치한다.', 'pip show 결과처럼 requests는 이미 설치돼 있다. 이 라이브러리는 자체 타입 정보(py.typed)를 싣지 않으므로 버전을 올려도 검사기가 읽을 힌트가 생기지 않는다.', false),
(16020, 5941, 'app.py 맨 위에 from __future__ import annotations를 추가한다.', '이 선언은 app.py에 적힌 힌트의 평가 시점만 미룬다. 검사기가 찾지 못한 것은 requests 쪽의 타입 정보라서 내 파일의 힌트 처리 방식을 바꿔도 로그는 그대로다.', false),
(16021, 5941, 'pydantic을 설치하고 requests 응답을 모델 클래스에 담아 받는다.', 'pydantic은 실행 중 값을 검증하는 층이다. 응답을 모델에 담아도 import requests 줄에서 검사기가 라이브러리의 함수 시그니처를 모르는 문제는 해결되지 않는다.', false),
(16022, 5941, 'typeshed가 배포하는 types-requests 패키지를 개발 의존성으로 설치한다.', '힌트가 없는 서드파티 라이브러리는 .pyi 파일만 모은 types-* 패키지로 타입 정보를 보충한다. 검사기가 이를 읽어 requests.get의 반환 타입까지 대조하게 된다. 실행 코드에는 영향이 없다.', true),

-- 문제 5942
(16023, 5942, '검사기는 조용히 통과하고, mode_label("a")를 호출하는 순간에야 실행 중 오류로 드러난다.', 'assert_never를 두는 이유가 바로 이 누락을 실행 전에 잡는 것이다. 검사기는 분기마다 남은 후보를 추적하므로 호출이 일어나기 전에 소스만 보고 오류를 낸다.', false),
(16024, 5942, '검사기가 Mode 정의 줄에서 기존 match 문이 처리하지 않는 값을 추가했다고 보고한다.', 'Literal에 값을 더하는 것 자체는 올바른 선언이다. 검사기는 정의 줄이 아니라, 좁히기가 끝난 뒤에도 값이 남는 사용 지점에서 오류를 보고한다.', false),
(16025, 5942, 'case _까지 내려온 mode의 타입이 Literal["a"]로 남아, 검사기가 assert_never 호출 줄을 오류로 보고한다.', '"r"·"w" 분기를 지나며 후보가 줄고 마지막에 "a"가 남는다. assert_never는 더 남은 후보가 없는 Never만 받으므로 이 줄이 오류가 되어 빠진 case를 알려 준다.', true),
(16026, 5942, '모듈을 불러오는 순간 인터프리터가 case가 부족하다며 SyntaxError를 낸다.', '인터프리터는 Literal 값과 case 개수를 대조하지 않는다. 문법상 문제가 없어 모듈은 정상 로드되며, 누락을 찾는 일은 검사기의 흐름 분석이 맡는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1936, 5943, 'Protocol,typing.Protocol,프로토콜', '상속 관계가 아니라 필요한 메서드를 갖췄는지로 타입 호환을 판단하는 것이 typing.Protocol이다. 파일·소켓·커넥션 객체는 모두 close()를 가지고 있어 Closable을 상속하지 않아도 통과하고, close가 없는 int만 걸린다. 덕 타이핑을 검사기가 이해하도록 만든 구조적 타이핑이라 소스를 고칠 수 없는 외부 클래스에도 인터페이스를 씌울 수 있다. 반면 abc.ABC는 상속 계보로 판단하는 명목적 방식이라 처음 시도에서 네 호출이 모두 거부됐다. Protocol은 기본적으로 실행 중 검사를 하지 않으며, isinstance로 판별하려면 runtime_checkable을 따로 붙여야 한다. 키와 값 타입으로 딕셔너리 모양을 적는 TypedDict와도 구분한다.'),
       (1937, 5944, 'TypeIs,typing.TypeIs,typing_extensions.TypeIs', '사용자 함수의 판정 결과를 검사기에게 알려 타입 좁히기에 쓰게 하는 표시 가운데, 참인 분기와 거짓인 분기를 모두 좁히는 것이 3.13에서 들어온 TypeIs(PEP 742)다. TypeIs[str]로 적으면 if 쪽에서 value는 str, else 쪽에서는 str을 뺀 int로 좁혀져 두 오류가 사라진다. TypeGuard는 참인 분기만 좁히고 거짓 분기는 원래 타입 int | str 그대로 두기 때문에 8번 줄 오류가 남았다. 반환 힌트가 그냥 bool이면 검사기는 함수 안의 isinstance를 들여다보지 않으므로 어느 분기도 좁혀지지 않는다.');
