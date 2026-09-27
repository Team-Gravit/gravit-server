-- Unit: 클래스와 MRO (Unit ID: 217)
-- Chapter: Python (Chapter ID: 21)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (643, 217, 'MRO와 super 연쇄, 클래스 속성'),
       (801, 217, '인스턴스 생성과 연산자 메서드, 덕 타이핑'),
       (959, 217, '파이썬 속성 탐색 경로와 매직 메서드 활용');

-- =====================================================
-- Lesson 643: MRO와 super 연쇄, 클래스 속성
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4037, 643, '아래 클래스 정의에서 AllInOne.__mro__에 담기는 클래스 순서로 옳은 것은?', '```python
class Device: pass

class Printer(Device): pass

class Scanner(Device): pass

class Fax(Scanner): pass

class AllInOne(Printer, Fax): pass

print(AllInOne.__mro__)
```', 'OBJECTIVE'),
       (4038, 643, '아래 코드를 실행했을 때 출력되는 문자열은?', '```python
class Report:
    def render(self):
        return "R"

class HeaderMixin(Report):
    def render(self):
        return "H" + super().render()

class FooterMixin(Report):
    def render(self):
        return super().render() + "F"

class Page(HeaderMixin, FooterMixin):
    def render(self):
        return "[" + super().render() + "]"

print(Page().render())
```', 'OBJECTIVE'),
       (4039, 643, '아래 코드의 마지막 print 출력으로 옳은 것은?', '```python
class Cart:
    items = []

    def add(self, code):
        self.items.append(code)

a, b = Cart(), Cart()
a.add(1)
b.add(2)
b.items = [9]
b.add(8)

print(Cart.items, b.items)
```', 'OBJECTIVE'),
       (4040, 643, '아래 표를 바탕으로 옳지 않은 것은?', '| 매직 메서드 | 정의했을 때 | 정의하지 않았을 때 |
|---|---|---|
| `__repr__` | `repr()`과 리스트·딕셔너리 안의 원소를 출력할 때 쓰인다 | 클래스 이름과 주소가 담긴 기본 표현이 쓰인다 |
| `__str__` | `print()`와 `str()`에 쓰인다 | `__repr__`이 만든 표현이 대신 쓰인다 |
| `__bool__` | `if obj` 판정에 쓰인다 | `__len__`의 결과를 대신 보고, `__len__`마저 없으면 참으로 본다 |
| `__eq__` | `==` 비교에 쓰인다 | 값과 무관하게 같은 객체인지로만 비교한다 |', 'OBJECTIVE'),
       (4041, 643, '아래에서 부모 클래스의 메서드에 붙인 데코레이터의 이름은?', '결제 연동 클래스는 모두 Payment를 상속해 approve와 cancel을 구현하기로 팀에서 정했다. 새로 들어온 TossPayment가 cancel 구현을 빠뜨린 채 배포됐고, 실제 취소 요청이 들어온 뒤에야 AttributeError가 나서 장애로 이어졌다. 다음 스프린트에서 Payment가 abc 모듈의 ABC를 상속하도록 바꾸고 approve·cancel에 데코레이터를 한 줄씩 붙이자, 두 메서드를 모두 구현하지 않은 클래스는 인스턴스를 만드는 순간 TypeError로 막혀 배포 전에 걸러졌다.', 'SUBJECTIVE'),
       (4042, 643, '아래 상황에서 클래스 맨 위에 추가한 속성의 이름은?', '좌표 객체 1,000만 개를 만들어 리스트에 담자 파이썬 프로세스 메모리가 약 1.1GB까지 올라갔다. 클래스 맨 위에 한 줄을 추가하고 같은 코드를 돌리니 메모리가 약 0.5GB로 줄었다. 대신 x·y 말고 p.z = 3처럼 선언하지 않은 이름에 값을 대입하던 코드가 모두 AttributeError로 막혔고, 인스턴스의 __dict__를 찍어 보던 디버깅 코드도 더는 동작하지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4037
(10939, 4037, 'AllInOne, Printer, Device, Fax, Scanner, object', '왼쪽 부모를 끝까지 파고드는 파이썬 2식 깊이 우선 탐색의 결과다. C3는 공통 조상 Device를 그 자손인 Fax·Scanner보다 앞에 둘 수 없다.', false),
(10940, 4037, 'AllInOne, Fax, Scanner, Printer, Device, object', '상속 계층이 더 깊은 부모를 먼저 본다는 오해다. C3는 부모 목록에 적은 순서를 보존하므로 AllInOne(Printer, Fax)에서는 Printer 쪽이 Fax보다 앞에 온다.', false),
(10941, 4037, 'AllInOne, Printer, Fax, Scanner, Device, object', '부모 목록 순서대로 Printer가 먼저 오고, 그다음 Fax와 그 부모 Scanner가 이어진다. 공통 조상 Device는 자손인 Printer·Fax·Scanner를 모두 지난 뒤에야 놓인다.', true),
(10942, 4037, 'AllInOne, Printer, Scanner, Fax, Device, object', 'Scanner가 Fax의 부모라서 먼저 나온다고 본 것. C3의 첫 규칙은 자식이 부모보다 앞이므로 Fax가 Scanner보다 앞에 온다.', false),

-- 문제 4038
(10943, 4038, '[HRF]', 'Page의 super()는 MRO 다음인 HeaderMixin이고, HeaderMixin의 super()는 자기 부모 Report가 아니라 MRO에서 다음인 FooterMixin이다. 그래서 H 뒤에 FooterMixin이 만든 RF가 붙는다.', true),
(10944, 4038, '[HR]', 'HeaderMixin의 super()가 자기 부모 Report를 곧바로 가리킨다고 본 결과다. super()는 부모가 아니라 인스턴스 MRO에서 자기 다음 클래스에 위임하므로 FooterMixin이 건너뛰어지지 않는다.', false),
(10945, 4038, '[HFR]', 'FooterMixin이 super() 호출보다 먼저 F를 붙인다고 본 것. FooterMixin은 super().render()가 돌려준 결과 뒤에 F를 이어 붙이므로 R이 F보다 앞에 온다.', false),
(10946, 4038, '[RFH]', 'MRO 맨 뒤 클래스부터 실행돼 자식으로 거슬러 온다고 본 오해다. 호출은 MRO 앞쪽인 Page에서 시작해 뒤쪽으로 위임되고, 문자열은 되돌아오면서 바깥쪽 클래스가 조립한다.', false),

-- 문제 4039
(10947, 4039, '[1, 2, 8] [9]', 'b.items = [9] 뒤에도 append가 클래스 리스트로 간다고 본 것. 대입은 b의 인스턴스 __dict__에 새 리스트를 만들고, 이후 self.items 탐색은 인스턴스 쪽을 먼저 찾는다.', false),
(10948, 4039, '[] [9, 8]', '인스턴스 메서드의 append가 클래스 속성을 건드리지 못한다고 본 오해다. 인스턴스에 items가 없으면 self.items는 클래스 속성을 찾아오므로 a.add(1)과 b.add(2)가 같은 리스트에 쌓인다.', false),
(10949, 4039, '[1, 2, 8] [9, 8]', '대입 뒤에도 클래스 속성과 인스턴스 속성이 같은 리스트를 계속 공유한다고 본 것. 대입은 이름을 인스턴스 쪽에 새로 묶는 일이라 두 리스트는 서로 다른 객체가 된다.', false),
(10950, 4039, '[1, 2] [9, 8]', '대입 전의 두 append는 공유된 클래스 리스트에 쌓여 [1, 2]가 되고, b.items = [9] 이후의 append는 b만 가진 리스트에 쌓여 [9, 8]이 된다.', true),

-- 문제 4040
(10951, 4040, '`__str__`을 정의한 객체라도 리스트에 담아 출력하면 `__repr__`이 만든 표현이 찍힌다.', '표 첫 행대로 컨테이너 안의 원소는 __repr__ 표현으로 출력된다. print(obj)와 print([obj])의 결과가 달라 보이는 이유이므로 참인 진술이다.', false),
(10952, 4040, '`__len__`이 0을 반환하는 객체도 `__bool__`이 없으면 `if obj`가 참으로 판정한다.', '표 셋째 행에 정면으로 걸린다. __bool__이 없으면 __len__ 결과를 대신 보므로 길이 0은 거짓이다. 무조건 참이 되는 것은 __len__마저 없을 때뿐이다.', true),
(10953, 4040, '`__repr__`만 정의한 클래스의 인스턴스를 print()에 넘기면 `__repr__`이 만든 문자열이 출력된다.', '표 둘째 행대로 __str__이 없으면 __repr__이 대신 쓰인다. __repr__ 하나만 제대로 정의해도 출력과 로그가 읽을 만해지는 근거라 참이다.', false),
(10954, 4040, '필드 값이 모두 같은 두 인스턴스라도 `__eq__`를 정의하지 않았다면 == 비교 결과가 거짓이다.', '표 넷째 행대로 기본 비교는 값이 아니라 같은 객체인지를 본다. 값으로 비교하려면 __eq__를 정의해야 하고, 이때 __hash__도 함께 챙겨야 하므로 참이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1302, 4041, 'abstractmethod,@abstractmethod,abc.abstractmethod,abstract method,추상 메서드', 'abc 모듈의 @abstractmethod를 붙인 메서드가 구현되지 않은 채 남아 있으면 그 클래스는 인스턴스를 만드는 순간 TypeError가 난다. 그래서 누락이 배포 후 호출 시점이 아니라 객체 생성 시점에 드러난다. ABC를 상속만 하고 데코레이터를 붙이지 않으면 아무것도 강제되지 않는다는 점, 그리고 상속 없이 구조만 보는 typing.Protocol이나 __iter__ 같은 메서드 존재만 따지는 덕 타이핑은 강제 시점이 다르다는 점을 함께 구분해 두자.'),
       (1303, 4042, '__slots__,slots,슬롯', '인스턴스마다 만들어지던 __dict__ 대신 미리 정해진 고정 슬롯에 속성을 저장하게 하는 것이 __slots__다. 인스턴스 수가 많을수록 메모리 절감이 크고 선언에 없는 이름에 대입하면 즉시 AttributeError로 걸리지만, 동적 속성 추가와 cached_property를 쓸 수 없고 상속 계층 전체가 선언해야 효과가 난다. 인스턴스 생성 자체를 가로채는 __new__나, 모든 인스턴스가 값을 공유하는 클래스 속성과는 다른 층위의 장치다.');

-- =====================================================
-- Lesson 801: 인스턴스 생성과 연산자 메서드, 덕 타이핑
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4985, 801, '아래 코드의 실행 결과로 옳은 것은?', '```python
class Tag:
    def __init__(self, name):
        self.name = name

    def __eq__(self, other):
        if not isinstance(other, Tag):
            return NotImplemented
        return self.name == other.name

t1, t2 = Tag("py"), Tag("py")
print(t1 == t2)
print(len({t1, t2}))
```', 'OBJECTIVE'),
       (4986, 801, '아래 코드의 출력으로 옳은 것은?', '```python
class Config:
    _instance = None

    def __new__(cls, name):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self, name):
        print("init", name)
        self.name = name

a = Config("A")
b = Config("B")
print(a is b, a.name)
```', 'OBJECTIVE'),
       (4987, 801, '아래 비교표를 바탕으로 파이썬의 메서드 정의 형태에 대한 설명으로 옳은 것은?', '| 정의 형태 | 클래스 `__dict__`에 담기는 객체 | 접근할 때 자동으로 채워지는 첫 인자 | 접근 문법 |
|---|---|---|---|
| 일반 메서드 | 함수 | 접근에 쓰인 인스턴스 | `obj.m()` |
| `@classmethod` | classmethod 객체 | 접근에 쓰인 클래스 | `obj.m()`, `Cls.m()` |
| `@staticmethod` | staticmethod 객체 | 없음 | `obj.m()`, `Cls.m()` |
| `@property` | property 객체 | 접근에 쓰인 인스턴스 | `obj.m` — 괄호 없이 즉시 실행 |', 'OBJECTIVE'),
       (4988, 801, '아래 코드를 실행했을 때의 결과로 옳은 것은?', '```python
class Base:
    def ping(self):
        return "Base"

class Left(Base):
    def ping(self):
        return "Left"

class Right(Base, Left):
    pass

print(Right().ping())
```', 'OBJECTIVE'),
       (4989, 801, '아래 상황에서 Money 클래스에 새로 정의한 매직 메서드의 이름은?', '정산 스크립트에서 Money(1000) + Money(2000)은 잘 동작했는데, 같은 객체들을 리스트에 담아 sum(moneys)를 부르자 TypeError: unsupported operand type(s) for +: ''int'' and ''Money''가 났다. sum()이 시작값 0에서 출발해 0 + Money(1000)부터 계산한다는 점을 확인한 뒤 Money에 매직 메서드를 하나 더 정의하자, 호출부는 한 줄도 바꾸지 않았는데 sum(moneys)가 총액을 돌려줬다.', 'SUBJECTIVE'),
       (4990, 801, '아래 상황이 보여 주는 파이썬의 타입 처리 방식을 가리키는 용어는?', '로그를 남기는 dump(target) 함수는 안에서 target.write(text)만 호출한다. 여기에 open()으로 연 파일 객체, io.StringIO(), 팀에서 만든 SlackWriter를 차례로 넘겼더니 셋은 공통 부모도 없고 같은 인터페이스를 상속하지도 않았는데 모두 정상 동작했다. 반대로 write 대신 send만 가진 Notifier를 넘긴 순간에야 AttributeError: ''Notifier'' object has no attribute ''write''가 났다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4985
(13467, 4985, 'True가 찍힌 뒤 1이 출력된다.', '__eq__만 정의하면 집합이 값으로 중복을 걸러 준다고 본 오해다. 집합은 해시로 후보를 먼저 추린 다음 ==를 보는데, __eq__를 정의한 순간 __hash__가 None이 되어 집합에 넣는 것부터 막힌다.', false),
(13468, 4985, 'True가 찍힌 뒤 두 번째 print에서 TypeError가 나며 실행이 멈춘다.', '__eq__를 직접 정의한 클래스는 __hash__가 None으로 덮여 해시 불가가 된다. 그래서 == 비교는 의도대로 동작하지만 집합 원소로 넣는 순간 unhashable type 오류가 난다. 값으로 비교하려면 __hash__도 함께 정의해야 한다.', true),
(13469, 4985, 'False가 찍힌 뒤 2가 출력된다.', 'NotImplemented를 돌려주는 분기 때문에 재정의가 무시된다고 본 것. 두 객체 모두 Tag라 isinstance 검사를 통과하므로 name 비교 결과 True가 나온다. NotImplemented는 타입이 다를 때 반대쪽 __eq__에 기회를 넘기는 신호값이다.', false),
(13470, 4985, 'True가 찍힌 뒤 2가 출력된다.', '기본 __hash__가 그대로 살아 있어 값이 같아도 서로 다른 원소로 담긴다고 본 결과다. 하지만 __eq__를 정의한 시점에 __hash__가 사라지므로 집합을 만드는 단계에서 이미 실패한다.', false),

-- 문제 4986
(13471, 4986, 'init A → init B → True B 순으로 출력된다.', '__new__가 저장해 둔 같은 객체를 돌려줘도 반환값이 cls의 인스턴스이면 파이썬은 이어서 __init__을 부른다. 그래서 두 번째 호출의 init도 찍히고, 같은 객체 위에서 self.name이 B로 덮여 a.name 역시 B가 된다.', true),
(13472, 4986, 'init A → True A 순으로 출력된다.', '이미 만들어진 인스턴스를 돌려주면 초기화를 건너뛴다고 본 오해다. __init__ 실행 여부는 __new__가 돌려준 값의 타입만으로 정해지므로, 두 번째 Config 호출에서도 __init__이 그대로 실행된다.', false),
(13473, 4986, 'init A → init B → False B 순으로 출력된다.', '__new__를 재정의해도 호출할 때마다 새 객체가 만들어진다고 본 것. _instance에 담아 둔 객체를 그대로 반환하므로 a와 b는 같은 객체를 가리키고 is 비교는 True가 된다.', false),
(13474, 4986, 'init A → init B → True A 순으로 출력된다.', '__init__이 두 번 불린 것까지는 맞게 보고 속성 대입 결과를 놓친 경우다. 같은 객체 위에서 self.name = name이 다시 실행되므로 먼저 넣은 A는 B로 덮인다. 초기화를 한 번만 하려면 __init__ 안에서 따로 막아야 한다.', false),

-- 문제 4987
(13475, 4987, '`@staticmethod`로 정의한 메서드는 채워지는 첫 인자가 없으므로 인스턴스로는 부를 수 없고 클래스 이름으로만 호출해야 한다.', '표의 접근 문법 열에 obj.m()도 함께 적혀 있다. 첫 인자를 채우지 않을 뿐 인스턴스에서 꺼내 호출하는 것은 문제가 없다. 인스턴스 상태가 필요 없는 도우미를 클래스 안에 묶어 둘 때 쓰는 형태다.', false),
(13476, 4987, '`@property`를 붙인 메서드는 obj.m()처럼 괄호를 붙여야 계산된 값을 돌려받을 수 있다.', '표대로 property는 괄호 없이 obj.m만으로 실행돼 값을 돌려준다. 괄호를 더 붙이면 이미 돌려받은 값을 다시 호출하는 꼴이라, 그 값이 함수가 아니면 not callable 오류로 이어진다.', false),
(13477, 4987, '일반 메서드를 Cls.m()처럼 클래스에서 꺼내 부르면 첫 인자에 클래스가 자동으로 채워진다.', '표에서 클래스를 첫 인자로 받는 것은 classmethod뿐이다. 클래스에서 꺼낸 일반 메서드는 저장된 함수 그대로라 자동으로 채워지는 인자가 없어, Cls.m(obj)처럼 인스턴스를 직접 넘겨야 한다.', false),
(13478, 4987, '부모에 둔 대체 생성자를 서브클래스 이름으로 호출하면 첫 인자에 그 서브클래스가 들어오므로, 서브클래스 인스턴스를 돌려주는 생성자는 `@classmethod`로 정의해야 한다.', '표에서 접근에 쓰인 클래스를 첫 인자로 받는 것은 classmethod뿐이다. Sub.from_json(...)으로 부르면 cls가 Sub가 되어 cls(...)가 Sub 인스턴스를 만든다. staticmethod로 두면 클래스 정보가 없어 부모 타입이 고정된다.', true),

-- 문제 4988
(13479, 4988, '부모 목록에 적은 순서대로 Base의 구현이 골라져 Base가 출력된다.', '부모 목록에 적은 순서만 지키면 된다고 본 결과다. 자식이 부모보다 앞선다는 규칙도 함께 지켜야 하는데, Left는 Base의 자식이라 Base보다 뒤로 밀릴 수 없어 순서 계산 자체가 성립하지 않는다.', false),
(13480, 4988, '파이썬이 순서를 바로잡아 Left의 구현을 골라 Left가 출력된다.', '두 규칙이 부딪히면 파이썬이 알아서 재배치해 준다고 본 오해다. 부모 목록에 적은 순서도 보존해야 하므로 Base를 제치고 Left를 앞세우는 재배치는 허용되지 않고, 계산은 실패로 끝난다.', false),
(13481, 4988, 'class Right를 정의하는 순간 TypeError가 나고 print는 실행되지 않는다.', 'Left가 Base의 자식이라 자식 우선 규칙은 Left를 앞에, 부모 목록 순서 보존 규칙은 Base를 앞에 두라고 요구한다. 둘을 모두 만족하는 순서가 없어 class 문을 실행하는 순간 일관된 MRO를 만들 수 없다는 TypeError가 난다.', true),
(13482, 4988, 'Right()로 인스턴스를 만들려 할 때 TypeError가 난다.', '탐색 순서 계산이 인스턴스를 만드는 시점으로 미뤄진다고 본 것. __mro__는 class 문이 실행되며 클래스 객체가 만들어질 때 확정되므로, 모순은 인스턴스를 만들기 전인 정의 시점에 드러난다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1618, 4989, '__radd__,radd', '왼쪽 피연산자인 int가 Money와의 덧셈을 처리하지 못하면 파이썬은 자리를 바꿔 오른쪽 피연산자의 __radd__를 부른다. sum()은 0부터 더하기 시작하므로 __add__만 있으면 첫 덧셈에서 막히고, __radd__를 정의해야 통과한다. 이름이 비슷한 __iadd__는 a += b처럼 제자리에서 갱신하는 연산을 맡고, __add__가 돌려주는 NotImplemented는 반대쪽 객체에 기회를 넘기라는 신호값이라는 점까지 함께 구분해 두자.'),
       (1619, 4990, '덕 타이핑,덕타이핑,duck typing,duck-typing,오리 타이핑', '상속 계층이 아니라 필요한 메서드를 실제로 가지고 있는지로 동작이 갈리는 것이 덕 타이핑이다. 그래서 어긋남은 클래스를 정의할 때가 아니라 그 메서드를 부르는 순간에야 드러난다. 계약을 미리 강제하고 싶으면 abc 모듈의 추상 메서드로 상속과 구현을 요구하고, 상속 없이 구조만 검사하려면 typing.Protocol을 쓴다. isinstance(obj, collections.abc.Iterable)처럼 표준 ABC로 검사하는 방식도 결국 __iter__가 있는지를 보는 장치라는 점에서 결이 같다.');

-- =====================================================
-- Lesson 959: 파이썬 속성 탐색 경로와 매직 메서드 활용
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5933, 959, '아래 코드를 실행했을 때 출력으로 옳은 것은?', '```python
class Settings:
    timeout = 30

    def __init__(self):
        self.timeout = 10

    def __getattr__(self, name):
        return "default"

s = Settings()
print(s.timeout, Settings.timeout, s.color)
```', 'OBJECTIVE'),
       (5934, 959, '아래 코드를 실행했을 때 출력되는 순서로 옳은 것은?', '```python
class A:
    def __init__(self):
        print("A", end=" ")

class B(A):
    def __init__(self):
        print("B", end=" ")
        A.__init__(self)

class C(A):
    def __init__(self):
        print("C", end=" ")
        A.__init__(self)

class D(B, C):
    def __init__(self):
        print("D", end=" ")
        B.__init__(self)
        C.__init__(self)

D()
```', 'OBJECTIVE'),
       (5935, 959, '아래 속성 탐색 과정에 대한 설명으로 옳은 것은?', '`Dog` 클래스는 `__init__`에서 인스턴스 속성 `name`을 만들고, `bark(self)` 메서드를 가진다. 인스턴스 `d`에서 `d.bark`를 평가하면 다음 순서로 진행된다.

1. `d.__dict__`에서 `''bark''`를 찾지만 없다.
2. `Dog.__dict__`에서 함수 `bark`를 찾는다.
3. 클래스에서 찾은 함수이므로 `bark.__get__(d, Dog)`이 호출되고, `d`가 첫 인자로 묶인 새 객체가 만들어져 반환된다. 이 변환은 클래스에서 찾은 함수에만 일어난다.', 'OBJECTIVE'),
       (5936, 959, '위 표의 클래스로 아래 식을 실행할 때 오류 없이 실행되는 것은?', '| 클래스 | `__init__` 외에 정의한 매직 메서드 |
|---|---|
| `Box` | `__len__` |
| `Bag` | `__eq__` |
| `Seq` | `__getitem__` |
| `Money` | `__eq__`, `__hash__` (둘 다 금액 값 기준) |

`Box`·`Bag`·`Seq`는 인자 없이, `Money`는 정수 하나로 생성한다.', 'OBJECTIVE'),
       (5937, 959, '아래 상황에서 두 실행 결과가 달라진 원인인 순서 계산 규칙의 이름은?', '같은 코드를 두 환경에서 돌렸다.

```python
class A:
    def who(self): return "A"

class B(A): pass

class C(A):
    def who(self): return "C"

class D(B, C): pass

print(D().who())
```

파이썬 2의 옛 스타일 클래스에서는 D → B → A → C 순으로 뒤져 A가 찍혔고, C에서 재정의한 who는 무시됐다. 파이썬 3에서는 같은 코드의 `D.__mro__`가 (D, B, C, A, object)로 나오고 C가 찍혔다.', 'SUBJECTIVE'),
       (5938, 959, '아래 상황에서 Money 클래스 위에 붙인 데코레이터의 이름은?', '정산 코드의 Money 클래스에는 `__eq__`와 `__lt__`만 정의돼 있었다. `sorted(moneys)`와 `a < b`는 잘 동작했는데, 한도 검사에 쓴 `a <= limit`에서 `TypeError: ''<='' not supported between instances of ''Money'' and ''Money''`가 났다. `__le__`·`__gt__`·`__ge__`를 하나씩 구현하는 대신 functools 모듈에서 가져온 데코레이터 한 줄을 클래스 위에 붙이자, 메서드를 하나도 추가하지 않았는데 `<=`·`>`·`>=` 비교가 모두 동작했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5933
(15995, 5933, '30 30 default', '클래스 속성이 인스턴스 속성보다 먼저 탐색된다고 본 오해다. 탐색은 인스턴스 __dict__부터 시작하므로 __init__에서 만든 timeout=10이 클래스의 30을 가린다.', false),
(15996, 5933, '10 30 default', 's.timeout은 인스턴스 __dict__의 10, Settings.timeout은 클래스의 30이다. __getattr__은 정상 탐색이 모두 실패한 s.color에서만 불려 default를 돌려준다.', true),
(15997, 5933, '10 10 default', 'self.timeout = 10이 클래스 속성을 고쳐 쓴다고 본 것이다. self에 대입하면 인스턴스 __dict__에 새 이름이 생길 뿐 클래스의 timeout=30은 그대로 남는다.', false),
(15998, 5933, 'default default default', '__getattr__이 모든 속성 접근을 가로챈다고 본 오해다. 모든 접근에 불리는 것은 __getattribute__이고, __getattr__은 인스턴스·클래스·MRO를 다 뒤져도 없을 때만 불린다.', false),

-- 문제 5934
(15999, 5934, 'D B C A', 'super()를 쓸 때처럼 MRO를 따라 각 클래스가 한 번씩만 호출된다고 본 것이다. A.__init__(self)처럼 클래스를 고정해 부르면 MRO와 상관없이 적힌 대로 실행된다.', false),
(16000, 5934, 'D B A', 'B.__init__이 A까지 호출하면 초기화가 끝난다고 보고 D의 C.__init__(self) 호출을 놓친 것이다. D는 B와 C의 초기화를 차례로 직접 부르므로 C 쪽 출력도 이어진다.', false),
(16001, 5934, 'D B A C A', 'D가 B와 C를 직접 부르고, B와 C가 각각 A.__init__(self)를 직접 부른다. 공통 부모 A가 두 번 실행되는 것이 다이아몬드에서 부모를 고정해 호출할 때 생기는 문제다.', true),
(16002, 5934, 'D B A C', '같은 인스턴스에 대해 A.__init__은 한 번만 실행된다고 본 오해다. 파이썬은 초기화 여부를 기억하지 않으므로 C.__init__ 안의 A.__init__(self)도 그대로 다시 실행된다.', false),

-- 문제 5935
(16003, 5935, 'm = d.bark로 꺼내 둔 뒤 다른 곳에서 m()만 호출해도 d의 name이 담긴 결과가 나온다.', '꺼낸 객체에 d가 첫 인자로 이미 묶여 있어 나중에 m()만 불러도 bark(d)와 같이 동작한다. 콜백으로 obj.method를 넘길 수 있는 이유도 이 바운드 메서드 덕분이다.', true),
(16004, 5935, 'd.bark is d.bark를 평가하면 양쪽이 같은 객체를 돌려받아 True가 된다.', '메서드가 인스턴스에 한 번 만들어져 저장된다고 본 오해다. d.bark를 평가할 때마다 __get__이 새 바운드 메서드를 만들므로 is 비교는 False다. == 비교는 True가 된다.', false),
(16005, 5935, 'd.__dict__에 직접 넣은 함수 f를 d.f()로 부르면 d가 첫 인자로 자동으로 채워진다.', '인스턴스에 넣은 함수도 메서드처럼 바뀐다고 본 것이다. 변환은 클래스에서 찾은 함수에만 일어나므로 d.f()는 f를 인자 없이 그대로 부르고, f가 self를 요구하면 TypeError가 난다.', false),
(16006, 5935, 'Dog.bark()처럼 클래스에서 꺼내 인자 없이 부르면 첫 인자에 Dog이 채워진다.', 'classmethod처럼 클래스가 첫 인자로 들어간다고 본 오해다. 클래스에서 꺼낸 일반 함수는 아무것도 묶이지 않아 self 누락으로 TypeError가 나며, Dog.bark(d)처럼 직접 넘겨야 한다.', false),

-- 문제 5936
(16007, 5936, '`len(Seq())`', '인덱스 접근이 되면 길이도 알 수 있다고 본 오해다. len()은 __len__만 찾으므로 __getitem__만 있는 Seq는 has no len() TypeError가 난다.', false),
(16008, 5936, '`Box()[0]`', '길이가 있으면 인덱스로 꺼낼 수도 있다고 본 것이다. obj[i]는 __getitem__을 부르는데 Box에는 __len__만 있어 not subscriptable TypeError가 난다.', false),
(16009, 5936, '`{Bag(): 1}`', '__eq__만 정의해도 딕셔너리 키로 쓸 수 있다고 본 오해다. __eq__를 정의하고 __hash__를 두지 않으면 __hash__가 None이 되어 unhashable type TypeError가 난다.', false),
(16010, 5936, '`Money(1) in {Money(1)}`', 'Money는 __eq__와 __hash__를 같은 금액 기준으로 함께 정의해 집합에 넣을 수 있다. in은 해시로 후보를 찾은 뒤 ==로 확인하므로 서로 다른 객체라도 True가 나온다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1934, 5937, 'C3 선형화,C3선형화,C3 linearization,C3,C3 알고리즘,C3 선형화 알고리즘,C3 linearization algorithm', '파이썬 3는 C3 선형화로 MRO를 계산한다. 자식이 부모보다 먼저 오고, 부모 목록에 적은 순서(D(B, C)면 B가 C보다 먼저)를 지키므로 공통 부모 A는 B와 C를 모두 지난 뒤에 놓인다. 그래서 C의 who가 A의 who보다 먼저 발견된다. 옛 방식인 깊이 우선 왼쪽부터 탐색은 A를 C보다 먼저 봐서 C의 재정의를 가렸다. MRO는 계산된 결과인 탐색 순서 자체를 뜻하고, C3 선형화는 그 순서를 만드는 규칙이라는 점을 구분하자. 두 규칙을 모두 만족하는 순서가 없으면 클래스 정의 시점에 TypeError가 난다.'),
       (1935, 5938, 'total_ordering,@total_ordering,functools.total_ordering,@functools.total_ordering,토탈 오더링', 'functools.total_ordering은 __eq__와 순서 비교 메서드 하나(__lt__ 등)만 정의돼 있으면 나머지 순서 비교 메서드를 채워 준다. 그래서 __le__·__gt__·__ge__를 직접 쓰지 않아도 <=와 >=가 동작한다. sorted()는 < 비교만 쓰기 때문에 데코레이터 없이도 동작했던 것이다. 필드 값으로 비교 메서드 전체를 만들어 주는 @dataclass(order=True)와는 기준이 다르고, 해시가 필요하면 __hash__는 따로 챙겨야 한다는 점도 구분하자.');
