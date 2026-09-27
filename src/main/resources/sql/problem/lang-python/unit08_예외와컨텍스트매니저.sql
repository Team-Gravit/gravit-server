-- Unit: 예외와 컨텍스트 매니저 (Unit ID: 219)
-- Chapter: Python (Chapter ID: 21)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (645, 219, 'finally 반환과 예외 억제, EAFP'),
       (803, 219, 'except 순서와 예외 연쇄, 예외 그룹'),
       (961, 219, '예외 전파 경로와 컨텍스트 매니저의 정리 동작');

-- =====================================================
-- Lesson 645: finally 반환과 예외 억제, EAFP
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4049, 645, '아래 f()를 호출한 결과로 옳은 것은?', '```python
def f():
    try:
        raise KeyError("k")
    except IndexError:
        return "A"
    else:
        return "B"
    finally:
        return "C"
```', 'OBJECTIVE'),
       (4050, 645, '아래 예외 재전파 방식 비교표를 바탕으로 옳지 않은 것은?', '| 형태 | 트레이스백에 남는 것 |
|---|---|
| `raise` (except 블록 안, 인자 없음) | 원본 트레이스백 그대로 |
| `raise New() from e` | 원본 + "The above exception was the direct cause of..." (`__cause__`) |
| `raise New()` (except 블록 안, from 없음) | 원본 + "During handling..., another exception occurred" (`__context__`) |
| `raise New() from None` | 원본 숨김 |', 'OBJECTIVE'),
       (4051, 645, '아래 코드를 실행했을 때 출력 순서로 옳은 것은?', '```python
class Guard:
    def __enter__(self):
        print("enter")
        return self

    def __exit__(self, exc_type, exc, tb):
        print("exit")
        return exc_type is not None and issubclass(exc_type, ValueError)

with Guard() as g:
    print("body")
    raise ValueError("bad")

print("done")
```', 'OBJECTIVE'),
       (4052, 645, '아래 예외 처리 스타일에 대한 설명으로 옳은 것은?', '키가 캐시에 들어 있는지 in으로 미리 확인하지 않고, 곧바로 cache[key]로 값을 꺼낸다. 그러다 KeyError가 났을 때만 값을 다시 계산해 캐시에 채워 넣는 스타일이다.', 'OBJECTIVE'),
       (4053, 645, '아래 상황에서 bare except가 함께 삼켜 버린 예외들이 공통으로 상속하는 클래스의 이름은?', '요청 워커 루프 전체를 `try: ... except: pass`로 감쌌다. 그 뒤로 배포 스크립트가 보낸 종료 요청도, 터미널에서 누른 Ctrl+C도 통하지 않고 프로세스가 계속 돌았다. 로그에는 아무 흔적도 남지 않아 원인을 찾는 데 반나절이 걸렸다.', 'SUBJECTIVE'),
       (4054, 645, '아래 상황에서 파일 누수를 없앤 표준 라이브러리 객체의 이름은?', '열어야 할 경로 개수가 실행할 때마다 달라 `with` 문에 몇 개를 나열할지 미리 정할 수 없었다. `for` 문 안에서 `f = open(p)`로 하나씩 열다 중간에 예외가 나자 앞서 연 파일들이 닫히지 않아 `Too many open files`가 떴다. `contextlib`의 객체 하나를 `with`에 걸고 경로마다 등록하도록 바꾸자, 몇 개를 열었든 예외가 나든 열린 역순으로 전부 닫혔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4049
(10971, 4049, 'KeyError가 호출자에게 그대로 전파되고 반환값은 없다.', 'finally 블록의 return이 진행 중이던 예외를 덮어써 조용히 없앤다. 그래서 KeyError는 함수 밖으로 나가지 못한다. 정리 작업만 두라는 finally 규칙을 어기면 이렇게 예외가 사라진다.', false),
(10972, 4049, '"A"를 반환하고 KeyError는 사라진다.', 'IndexError와 KeyError는 둘 다 LookupError 하위지만 서로 상위-하위 관계가 아닌 형제다. except IndexError는 KeyError를 잡지 못하므로 그 블록은 실행되지 않는다.', false),
(10973, 4049, '"B"를 반환하고 KeyError는 사라진다.', 'else는 try 본문이 예외 없이 끝났을 때만 실행되는 자리다. 여기서는 try 본문이 예외로 중단됐으므로 else로 갈 일이 없다.', false),
(10974, 4049, '"C"를 반환하고 KeyError는 사라진다.', 'except가 KeyError를 못 잡아 전파가 시작되지만, finally의 return이 그 전파를 중단시키고 값을 돌려준다. 파이썬 3.14부터는 이 패턴에 SyntaxWarning이 붙는다.', true),

-- 문제 4050
(10975, 4050, 'except OSError as e: 안에서 raise e로 다시 던지면 표 첫 줄과 똑같이 원본 트레이스백만 남는다.', 'raise e는 그 raise 문이 있는 줄을 트레이스백에 덧붙여 원래 발생 지점이 흐려진다. 원본이 그대로 유지되는 것은 인자 없는 raise뿐이다.', true),
(10976, 4050, 'open 실패로 생긴 OSError를 설정 도메인 예외로 바꿔 던지면서 원인을 남기려면 from e를 붙인다.', 'from e는 __cause__를 채워 직접적 원인으로 표시하므로, 저수준 예외를 도메인 예외로 번역해도 원인 추적이 끊기지 않는다.', false),
(10977, 4050, '라이브러리 내부 구현을 감추려고 from None을 쓰면 장애 분석에서 원래 원인을 되짚기 어려워진다.', '원본을 트레이스백에서 지우는 대신 디버깅 단서도 함께 사라진다. 노출 축소와 추적 가능성 사이의 맞교환이라 신중히 골라야 한다.', false),
(10978, 4050, 'except 블록 안에서 from을 안 붙이고 새 예외를 던져도 원래 예외가 함께 출력된다.', '파이썬이 __context__에 처리 중이던 예외를 자동으로 담아 During handling 문구와 함께 보여 준다. 의도치 않은 암묵적 연쇄가 여기서 생긴다.', false),

-- 문제 4051
(10979, 4051, 'enter → body → done (exit은 출력되지 않는다)', 'with는 블록을 어떻게 빠져나가든 __exit__를 부른다. 예외로 빠져나갈 때도 exc_type, exc, tb를 채워 호출하므로 정리 코드가 건너뛰어지지 않는다.', false),
(10980, 4051, 'enter → body → exit → done (ValueError는 전파되지 않는다)', '__exit__가 True를 돌려주면 예외가 억제된다. exc_type이 ValueError라 issubclass 검사가 True가 되고, 예외가 그 자리에서 멈춰 with 다음 줄까지 이어진다.', true),
(10981, 4051, 'enter → body → exit 다음 ValueError 전파 (done은 출력되지 않는다)', '__exit__의 반환값을 무시한 오해다. False나 None을 돌려줄 때는 전파가 맞지만, 여기서는 True가 나오므로 예외가 밖으로 나가지 않는다.', false),
(10982, 4051, 'enter → exit → done (body는 출력되지 않는다)', '__enter__는 블록 실행 여부를 결정하지 않는다. as 뒤 변수에 바인딩할 값을 돌려줄 뿐이고 블록은 그대로 실행된다.', false),

-- 문제 4052
(10983, 4052, '미리 검사하는 스타일보다 파이썬답지 않아 표준 라이브러리 안에서는 쓰이지 않는다.', '거꾸로 파이썬이 권장하는 쪽이 이 스타일(EAFP)이다. 이터레이터가 끝을 알릴 때 쓰는 StopIteration처럼 표준 라이브러리 내부도 예외를 흐름에 적극 활용한다.', false),
(10984, 4052, '실제로 예외가 나지 않아도 try 블록에 들어가는 것만으로 상당한 비용이 든다.', 'CPython에서 try 진입 자체는 거의 공짜이고 비용은 예외가 실제로 발생할 때 든다. 그래서 예외가 드문 경로에서 이 스타일이 오히려 빠르다.', false),
(10985, 4052, '여러 스레드가 같은 캐시를 쓸 때, 확인해 둔 키가 사용 직전에 지워져 생기는 오류를 겪지 않는다.', '검사와 사용이 두 단계로 나뉘면 그 틈에 상태가 바뀌는 경쟁 조건이 생긴다. 접근 한 번으로 끝내면 틈 자체가 없다는 것이 EAFP의 안전성 근거다.', true),
(10986, 4052, '키가 없는 경우가 대부분인 작업에서도 미리 검사하는 스타일보다 항상 빠르다.', '예외 발생 빈도가 높으면 매번 예외 객체 생성과 전파 비용을 치른다. 이럴 때는 미리 검사하는 LBYL이 유리하므로 항상이라는 말이 성립하지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1306, 4053, 'BaseException,베이스익셉션,베이스 익셉션', 'Ctrl+C는 KeyboardInterrupt, 배포 스크립트의 종료 요청은 SystemExit으로 올라온다. 이 둘과 GeneratorExit은 Exception 아래가 아니라 BaseException 바로 아래에 있고, bare except:는 BaseException까지 잡아 버려 종료와 인터럽트가 통하지 않는다. 워커 루프처럼 넓게 잡아야 하는 자리라면 이 셋을 통과시키는 except Exception:을 쓰고 logging.exception()으로 원인을 남겨야 한다. 예외를 잡는 범위를 고를 때 Exception과 BaseException의 경계를 구분하는 것이 핵심이다.'),
       (1307, 4054, 'ExitStack,contextlib.ExitStack,exit stack,엑시트스택', '자원 개수가 고정이면 with A() as a, B() as b: 로 충분하지만, 개수가 실행 중에 정해지면 ExitStack에 enter_context()로 하나씩 쌓아야 한다. 블록을 벗어날 때 등록된 역순으로 __exit__이 호출되므로 도중에 예외가 나도 이미 연 자원이 모두 해제된다. close()만 있는 객체를 with에서 쓰게 해 주는 closing(), 특정 예외만 조용히 넘기는 suppress()와는 역할이 다르니 구분해 두자.');

-- =====================================================
-- Lesson 803: except 순서와 예외 연쇄, 예외 그룹
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4997, 803, '아래 코드의 출력으로 옳은 것은?', '```python
def a(d, key):
    try:
        return d[key]
    except LookupError:
        return "LOOKUP"
    except KeyError:
        return "KEY"

def b(d, key):
    try:
        return d[key]
    except KeyError:
        return "KEY"
    except LookupError:
        return "LOOKUP"

print(a({}, "x"), b({}, "x"))
```', 'OBJECTIVE'),
       (4998, 803, '아래 예외 계층 설계에 대한 설명으로 옳은 것은?', '```python
class AppError(Exception):
    """서비스 공통 뿌리 예외."""

class NotFoundError(AppError): ...
class PermissionDeniedError(AppError): ...

def fetch(key):
    ...
    raise NotFoundError(key)

# 호출자
try:
    fetch("u42")
except AppError as e:
    report(e)
```', 'OBJECTIVE'),
       (4999, 803, '아래 표를 바탕으로 옳지 않은 것은?', '| contextlib 도구 | with 블록을 벗어날 때 하는 일 |
|---|---|
| `closing(obj)` | `obj.close()`를 호출한다 |
| `suppress(ValueError)` | 블록에서 난 ValueError를 삼키고 with 다음 문장으로 건너뛴다 |
| `ExitStack` | `enter_context()`로 등록한 컨텍스트를 등록의 역순으로 닫는다 |
| `@contextmanager` | 제너레이터의 `yield` 다음 줄부터 이어서 실행한다 |', 'OBJECTIVE'),
       (5000, 803, '아래 트레이스백을 남긴 코드의 예외 처리 방식으로 옳은 것은?', '```
Traceback (most recent call last):
  File "config.py", line 12, in load_config
    with open(path) as f:
FileNotFoundError: [Errno 2] No such file or directory: ''app.yml''

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "main.py", line 5, in <module>
    load_config("app.yml")
AppError: 설정 로드 실패: app.yml
```', 'OBJECTIVE'),
       (5001, 803, '아래 상황에서 except TimeoutError가 아무것도 잡지 못하게 만든, 파이썬 3.11에 추가된 예외 클래스의 이름은?', 'asyncio.TaskGroup으로 외부 API 다섯 곳을 동시에 호출했다. 그중 둘은 TimeoutError로, 하나는 ValueError로 끝났고 나머지 둘은 정상 응답을 받았다. 호출부를 try/except TimeoutError로 감쌌는데도 아무것도 잡히지 않고 그대로 터졌다. 트레이스백 맨 위에는 낯선 클래스 이름이 찍혔고, 그 아래로 실패한 예외 셋이 1, 2, 3번 가지로 나뉘어 함께 출력됐다.', 'SUBJECTIVE'),
       (5002, 803, '아래 상황에서 고쳐야 할 던더 메서드의 이름은?', '걸린 시간을 재려고 만든 Timer 클래스를 with Timer() as t: 형태로 썼다. 블록은 예외 없이 끝났는데 바로 다음 줄 print(t.elapsed)에서 AttributeError: ''NoneType'' object has no attribute ''elapsed''가 났다. 같은 코드에서 mgr = Timer()로 인스턴스를 따로 잡아 두고 살펴보니 elapsed 값은 제대로 채워져 있었다. 클래스에는 진입용·종료용 던더 메서드가 둘 다 정의돼 있고, 둘 중 하나만 고치면 오류가 사라진다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4997
(13499, 4997, 'KEY KEY', '파이썬이 후보 중 가장 구체적인 except 절을 알아서 골라 준다고 본 오해. 실제로는 절을 위에서 아래로 훑다 처음 일치하는 곳에서 멈추므로, a()에서는 위에 있는 LookupError 절이 KeyError를 먼저 가로챈다.', false),
(13500, 4997, 'LOOKUP KEY', 'KeyError는 LookupError의 하위 클래스다. a()는 상위 절이 위에 있어 KeyError가 거기서 잡혀 LOOKUP을, b()는 하위 절이 위에 있어 KEY를 돌려준다. 같은 예외라도 절 순서가 결과를 바꾼다.', true),
(13501, 4997, 'LOOKUP LOOKUP', '더 넓은 예외를 적은 절이 순서와 무관하게 우선한다고 본 오해. b()는 except KeyError가 먼저 일치해 그 자리에서 탐색이 끝나므로 아래의 LookupError 절까지 내려가지 않는다.', false),
(13502, 4997, 'KEY LOOKUP', 'except 절을 아래에서 위로 훑는다고 본 오해. 탐색은 소스에 적힌 위에서 아래 순서로만 이뤄지므로 두 함수의 결과가 정반대로 뒤집힌다.', false),

-- 문제 4998
(13503, 4998, '호출자의 except를 NotFoundError로 바꿔도 같은 뿌리를 공유하는 PermissionDeniedError까지 함께 잡힌다.', '두 예외는 상하 관계가 아니라 AppError를 나란히 상속한 형제다. except 절은 적힌 클래스와 그 하위만 잡으므로 형제 예외는 걸리지 않고 그대로 전파된다.', false),
(13504, 4998, 'AppError를 Exception 대신 BaseException에서 상속하면 잡히는 범위가 넓어져 더 안전해진다.', 'BaseException 바로 아래는 SystemExit·KeyboardInterrupt처럼 프로그램 제어용 예외의 자리다. 거기로 올리면 도메인 오류가 except Exception 그물에 걸리지 않아 상위 핸들러가 놓치게 된다.', false),
(13505, 4998, '다음 릴리스에서 RateLimitError(AppError)가 추가돼도 위 호출자의 except 절은 고치지 않아도 된다.', '뿌리 예외 하나로 잡아 두면 그 아래 계층이 늘어나도 호출자는 그대로 동작한다. 라이브러리 내부 변경이 호출자 코드를 깨지 않게 하는 것이 뿌리 예외를 두는 이유다.', true),
(13506, 4998, 'fetch가 내부에서 만난 OSError를 NotFoundError로 바꿔 던지는 순간 원래 원인은 남길 방법이 없다.', 'raise NotFoundError(key) from e 로 던지면 __cause__에 원본이 담겨 트레이스백에 함께 출력된다. 도메인 예외로 번역하면서도 원인 추적은 유지할 수 있다.', false),

-- 문제 4999
(13507, 4999, 'suppress(ValueError)를 걸어 두면 블록 중간에서 ValueError가 나도 블록에 남아 있던 문장들이 이어서 실행된다.', '표의 suppress 행은 예외를 삼킨 뒤 with 다음 문장으로 건너뛴다고 적혀 있다. 예외가 난 지점 뒤의 블록 코드는 건너뛰므로 남은 문장이 계속 실행된다는 말은 거짓이다.', true),
(13508, 4999, 'ExitStack에 파일 세 개를 차례로 등록했다면 세 번째로 등록한 파일이 가장 먼저 닫힌다.', '표의 ExitStack 행이 등록의 역순 해제를 명시한다. 나중에 연 자원이 앞서 연 자원에 기대고 있을 수 있어 해제 순서를 뒤집는 것이 안전하다.', false),
(13509, 4999, 'close() 메서드만 있고 던더 메서드가 없는 객체도 closing()으로 감싸면 with에 쓸 수 있다.', 'closing()이 컨텍스트 매니저 역할을 대신 맡아 블록을 벗어날 때 obj.close()를 불러 준다. 덕분에 with를 지원하지 않는 옛 라이브러리 객체도 빠짐없이 닫을 수 있다.', false),
(13510, 4999, '@contextmanager 함수에서 yield를 try/finally로 감싸지 않으면 블록에서 예외가 났을 때 yield 다음 줄이 실행되지 않는다.', '블록에서 난 예외는 yield 지점에서 다시 발생한다. 그 예외를 잡거나 finally로 받아 두지 않으면 제너레이터가 거기서 끝나 정리 코드까지 내려가지 못한다.', false),

-- 문제 5000
(13511, 5000, 'except 블록 안에서 from을 붙이지 않은 채 AppError를 새로 던졌다.', '그 경우 __context__가 채워져 During handling of the above exception, another exception occurred 문구가 찍힌다. 로그의 direct cause 문구는 암묵적 연쇄가 아니라 명시적 연쇄를 뜻한다.', false),
(13512, 5000, '인자 없는 raise로 원본 FileNotFoundError를 그대로 재전파했다.', '원본을 그대로 재전파하면 예외가 하나뿐이라 트레이스백도 한 덩어리로만 나온다. 로그에는 서로 다른 두 예외가 이어 붙어 있으므로 새 예외를 만들어 던진 것이다.', false),
(13513, 5000, 'raise AppError(...) from None으로 내부 구현을 감춘 뒤 던졌다.', 'from None은 원인을 지워 AppError 트레이스백만 출력되게 한다. FileNotFoundError가 위에 그대로 남아 있는 이 로그와는 맞지 않는다.', false),
(13514, 5000, 'except OSError as e 블록에서 raise AppError(...) from e 로 던졌다.', 'from e는 __cause__를 채우고 트레이스백에 direct cause 문구를 넣는다. FileNotFoundError는 OSError의 하위라 이 절에 잡히며, 저수준 오류를 도메인 예외로 번역하면서 원인을 남긴 형태다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1622, 5001, 'ExceptionGroup,예외 그룹,예외그룹,익셉션 그룹,익셉션그룹,exception group', 'TaskGroup은 자식 태스크에서 난 예외를 모아 ExceptionGroup 하나로 올린다. except TimeoutError는 올라온 객체의 타입만 보고 판단하는데, 그 객체는 ExceptionGroup이지 TimeoutError가 아니므로 안에 TimeoutError가 들어 있어도 잡히지 않는다. 트레이스백에 1, 2, 3번 가지가 나뉘어 찍히는 것이 이 클래스의 표시 방식이다. 안의 예외를 타입별로 갈라 잡으려면 except*를 써야 하고, 이때 잡히는 것은 해당 타입만 추려낸 부분 그룹이다. 클래스인 ExceptionGroup과 문법인 except*를 구분하고, 예외에 설명을 덧붙이는 add_note()와도 헷갈리지 말자.'),
       (1623, 5002, '__enter__,__enter__(),enter,Timer.__enter__', 'with 문은 __enter__()가 돌려준 값을 as 뒤 변수에 묶는다. 이 Timer의 __enter__는 시작 시각만 기록하고 아무것도 반환하지 않아 암묵적으로 None이 t에 들어갔고, 그래서 t.elapsed에서 NoneType 오류가 났다. 마지막 줄에 return self를 넣으면 인스턴스가 t에 묶인다. 인스턴스 자체에 elapsed가 제대로 채워져 있었다는 점이 __exit__은 멀쩡히 호출됐다는 증거다. __exit__의 반환값은 as 변수와 무관하며, True면 블록에서 난 예외를 억제할지 정하는 데만 쓰인다.');

-- =====================================================
-- Lesson 961: 예외 전파 경로와 컨텍스트 매니저의 정리 동작
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5945, 961, '아래 코드를 실행했을 때 출력되는 세 줄로 옳은 것은?', '```python
def parse(s):
    try:
        n = int(s)
    except ValueError:
        return "bad"
    else:
        if n < 0:
            raise ValueError("neg")
        return n
    finally:
        print("F", end=" ")

for s in ["7", "x", "-1"]:
    try:
        print(parse(s))
    except ValueError:
        print("outer")
```', 'OBJECTIVE'),
       (5946, 961, '아래 상황의 원인에 대한 설명으로 옳은 것은?', 'CPython으로 운영하던 로그 수집 서버에는 `data = open(path).read()`처럼 파일을 열기만 하고 close()나 with 없이 쓰는 코드가 여러 곳 있었지만, 몇 년 동안 아무 문제가 없었다. 같은 코드를 PyPy로 옮겨 실행하자 몇 시간 뒤부터 `OSError: [Errno 24] Too many open files`가 나기 시작했다. 코드는 한 줄도 바꾸지 않았다.', 'OBJECTIVE'),
       (5947, 961, '아래 코드의 출력으로 옳은 것은?', '```python
try:
    raise ExceptionGroup("batch", [
        ValueError("a"),
        TypeError("b"),
        ValueError("c"),
    ])
except* ValueError as eg:
    print("V", len(eg.exceptions))
except* TypeError as eg:
    print("T", len(eg.exceptions))
```', 'OBJECTIVE'),
       (5948, 961, '아래 코드를 실행한 뒤 출력되는 log로 옳은 것은?', '```python
from contextlib import contextmanager

@contextmanager
def tx(log):
    log.append("begin")
    try:
        yield
        log.append("commit")
    except Exception:
        log.append("rollback")
    finally:
        log.append("close")

log = []
try:
    with tx(log):
        log.append("insert")
        raise ValueError("dup")
except ValueError:
    log.append("caught")
print(log)
```', 'OBJECTIVE'),
       (5949, 961, '아래 상황에서 사용한 contextlib 도구의 이름은?', '배포 스크립트 곳곳에 임시 잠금 파일을 지우는 아래 네 줄이 반복됐다.

```python
try:
    os.remove("deploy.lock")
except FileNotFoundError:
    pass
```

contextlib에서 도구 하나를 가져와 `with 도구(FileNotFoundError):` 한 줄 아래에 `os.remove("deploy.lock")`만 두는 두 줄로 바꿨다. 잠금 파일이 없을 때는 전처럼 아무 일 없이 넘어갔고, 권한이 없어 난 PermissionError는 바꾸기 전처럼 그대로 올라왔다.', 'SUBJECTIVE'),
       (5950, 961, '아래 코드가 따른 예외 처리 스타일을 가리키는 약어는?', '여러 워커 프로세스가 같은 캐시 디렉터리를 공유하고, 오래된 파일은 정리 작업이 수시로 지운다. 한 워커의 코드는 아래와 같다.

```python
if os.path.exists(path):
    with open(path) as f:
        data = f.read()
else:
    data = rebuild(path)
```

하루 수천 번 호출 중 몇 번씩 `FileNotFoundError`가 났다. 로그를 보면 모두 `os.path.exists(path)`가 True를 돌려준 직후 `open(path)` 줄에서 났다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5945
(16027, 5945, 'F 7 / F bad / F bad', 'else에서 난 예외도 같은 try의 except ValueError가 잡는다고 본 오해. except는 try 본문에서 난 예외만 맡고, else에서 난 예외는 finally를 거쳐 바깥으로 전파된다.', false),
(16028, 5945, '7 F / bad F / outer F', 'finally가 반환값이 호출자에게 전달된 뒤에 실행된다고 본 오해. print(parse(s))는 parse가 끝나야 출력하는데, finally는 parse를 빠져나가기 직전에 돌므로 F가 먼저 찍힌다.', false),
(16029, 5945, 'F 7 / F bad / F outer', 'int("x")의 ValueError는 except가 잡아 bad를 돌려준다. else에서 난 ValueError("neg")는 같은 try의 except 대상이 아니어서 finally를 실행한 뒤 바깥 try로 전파돼 outer가 찍힌다.', true),
(16030, 5945, 'F 7 / F bad / outer', '예외가 전파될 때는 finally를 건너뛴다고 본 오해. finally는 return으로 나가든 예외로 나가든 항상 실행되므로 전파 전에 F가 먼저 찍힌다.', false),

-- 문제 5946
(16031, 5946, 'PyPy의 파일 객체에는 __exit__이 없어 with 문으로 감싸도 파일이 자동으로 닫히지 않는다.', 'with로 연 파일은 어느 구현체에서나 블록을 벗어날 때 __exit__이 호출돼 닫힌다. 오히려 with가 구현체와 무관하게 해제를 보장하는 방법이다.', false),
(16032, 5946, 'PyPy는 참조가 사라진 파일 객체를 곧바로 정리하지 않아, 닫히지 않은 파일 디스크립터가 쌓였다.', 'CPython은 참조 수가 0이 되는 즉시 객체를 해제하며 파일을 닫지만, PyPy는 가비지 컬렉터가 돌 때까지 해제를 미룬다. 그 사이 열린 디스크립터가 OS 한도에 닿은 것이다.', true),
(16033, 5946, 'CPython에서는 read()가 끝나는 순간 인터프리터가 파일 객체의 __exit__을 호출해 닫아 주었다.', '__exit__은 with 문이 부를 때만 호출된다. CPython에서 파일이 닫힌 것은 참조 수가 0이 돼 객체가 해제됐기 때문이지 컨텍스트 매니저 규약 덕분이 아니다.', false),
(16034, 5946, 'PyPy는 한 프로세스가 열 수 있는 파일 수를 CPython보다 낮게 제한해 같은 수의 파일도 열지 못한다.', '열 수 있는 파일 디스크립터 수는 인터프리터가 아니라 OS가 프로세스마다 정하는 한도다. 달라진 것은 한도가 아니라 다 쓴 파일이 닫히는 시점이다.', false),

-- 문제 5947
(16035, 5947, 'V 2 (이어서 TypeError가 전파된다)', '일반 except처럼 처음 일치한 절 하나만 실행된다고 본 오해. except*는 그룹을 타입별로 나눠 일치하는 절을 모두 실행하므로 TypeError 부분도 아래 절에서 처리된다.', false),
(16036, 5947, 'V 1 / T 1 / V 1', '그룹 안 예외마다 절을 하나씩 따로 실행한다고 본 오해. except*는 같은 타입을 한데 모은 부분 그룹을 한 번만 넘기므로 ValueError 둘은 한 번의 실행에 함께 담긴다.', false),
(16037, 5947, 'V 3 / T 3', 'eg가 원래 그룹 전체를 가리킨다고 본 오해. 각 절에 묶이는 eg는 그 절의 타입만 추려낸 부분 그룹이라 exceptions 길이가 타입별 개수와 같다.', false),
(16038, 5947, 'V 2 / T 1', 'except*는 ExceptionGroup을 타입별로 갈라 일치하는 절마다 부분 그룹을 넘긴다. ValueError 두 개가 담긴 그룹으로 첫 절이, TypeError 하나가 담긴 그룹으로 둘째 절이 각각 한 번 실행된다.', true),

-- 문제 5948
(16039, 5948, '[''begin'', ''insert'', ''rollback'', ''close'']', '블록의 ValueError는 yield 지점에서 다시 발생해 except가 받는다. except가 raise 없이 끝나 제너레이터가 정상 종료하면 예외가 억제된 것으로 처리돼 바깥 except까지 가지 않는다.', true),
(16040, 5948, '[''begin'', ''insert'', ''rollback'', ''close'', ''caught'']', 'rollback만 기록하면 예외가 알아서 계속 전파된다고 본 오해. 제너레이터가 예외를 잡고 다시 던지지 않으면 with 밖에서는 실패가 보이지 않으므로 raise로 재전파해야 한다.', false),
(16041, 5948, '[''begin'', ''insert'', ''commit'', ''close'']', '블록에서 난 예외가 제너레이터에 전달되지 않고 yield 다음 줄이 그대로 이어진다고 본 오해. 예외가 yield 지점에서 발생하므로 commit 줄은 건너뛴다.', false),
(16042, 5948, '[''begin'', ''insert'', ''caught'']', '블록에서 예외가 나면 제너레이터의 나머지 코드가 실행되지 않는다고 본 오해. 예외가 yield 지점에서 다시 발생해 try가 받으므로 except와 finally가 모두 실행된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1938, 5949, 'suppress,contextlib.suppress,suppress(),contextlib.suppress(),서프레스', 'suppress(*exc)는 지정한 예외 타입만 조용히 무시하는 컨텍스트 매니저로, try/except/pass 네 줄을 두 줄로 줄여 준다. 안에서는 __exit__이 지정한 타입일 때만 True를 돌려 예외를 억제하므로, 지정하지 않은 PermissionError는 그대로 전파된다. close()만 있는 객체를 with에서 쓰게 하는 closing(), 개수가 동적인 자원을 역순으로 닫는 ExitStack과는 역할이 다르다. except Exception: pass처럼 넓게 삼키면 원인 추적이 어려워지니 무시할 예외는 좁게 지정해야 한다.'),
       (1939, 5950, 'LBYL,Look Before You Leap,Look-Before-You-Leap', 'LBYL(Look Before You Leap)은 쓰기 전에 조건을 먼저 검사하는 스타일이다. 검사와 사용이 두 단계로 나뉘어, 그 틈에 정리 작업이 파일을 지우면 이미 True로 판정된 채 open이 실행되는 경쟁 조건이 생긴다. 파이썬이 선호하는 EAFP(Easier to Ask Forgiveness than Permission)는 곧바로 open을 시도하고 FileNotFoundError를 except로 받아 rebuild하므로 이 틈 자체가 없다. 다만 예외가 자주 나는 경로에서는 매번 예외 비용을 치르므로 LBYL이 더 빠를 수 있다.');
