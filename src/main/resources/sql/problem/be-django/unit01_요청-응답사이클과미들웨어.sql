-- Unit: 요청·응답 사이클과 미들웨어 (Unit ID: 132)
-- Chapter: Django (Chapter ID: 12)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (558, 132, '실행 순서와 단락 응답, ASGI'),
       (716, 132, '예외 훅과 템플릿 응답, CSRF 검사'),
       (874, 132, 'Django 미들웨어의 조립 순서와 예외·비동기 요청 처리 흐름');

-- =====================================================
-- Lesson 558: 실행 순서와 단락 응답, ASGI
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3527, 558, '아래 설정으로 index 뷰에 요청 한 건을 처리했을 때 log에 기록되는 순서는?', '```python
# settings.py
MIDDLEWARE = ["app.mw.A", "app.mw.B"]

# app/mw.py
class A:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        log("A-in")
        response = self.get_response(request)
        log("A-out")
        return response


class B:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        log("B-in")
        response = self.get_response(request)
        log("B-out")
        return response

# views.py
def index(request):
    log("view")
    return HttpResponse("ok")
```', 'OBJECTIVE'),
       (3528, 558, '아래 설정으로 서버를 띄우고 요청을 보냈을 때 일어나는 일로 옳은 것은?', '```python
# settings.py
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
]
```

네 미들웨어 모두 Django 기본 구현을 그대로 쓰고, 뷰는 `request.user.is_authenticated` 값으로 화면을 나눈다.', 'OBJECTIVE'),
       (3529, 558, '아래 미들웨어 훅에 대한 설명으로 옳은 것은?', 'URL 라우팅이 끝나 어떤 뷰가 실행될지 정해진 뒤, 그 뷰가 호출되기 직전에 핸들러가 불러 주는 훅이다. 요청 객체와 함께 실행될 뷰 함수 객체, 위치 인자, 키워드 인자를 인자로 전달받는다.', 'OBJECTIVE'),
       (3530, 558, '아래 코드에서 detail 뷰로 요청이 들어왔을 때의 동작으로 옳은 것은?', '```python
# MIDDLEWARE 목록 맨 아래에 등록된 미들웨어이며 process_exception 메서드는 없다.
class GuardMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        try:
            response = self.get_response(request)
        except ValueError:
            return JsonResponse({"detail": "bad value"}, status=400)
        return response


# views.py
def detail(request, pk):
    raise ValueError("pk format error")
```', 'OBJECTIVE'),
       (3531, 558, '아래 로그에서 일어난 처리 방식을 가리키는 용어는?', '```
[12:00:01] SecurityMiddleware   진입
[12:00:01] RateLimitMiddleware  진입
[12:00:01] RateLimitMiddleware  429 응답 객체 생성
[12:00:01] SecurityMiddleware   응답 헤더 추가
[12:00:01] 응답 전송 status=429
```

MIDDLEWARE 목록은 SecurityMiddleware, RateLimitMiddleware, AuthenticationMiddleware 순이고 뷰 함수에도 진입 로그를 심어 두었지만, 이 요청에서는 뒤의 두 로그가 한 줄도 남지 않았다.', 'SUBJECTIVE'),
       (3532, 558, '아래 상황에서 서버를 바꾼 뒤 Django와 서버 사이에 쓰이게 된 인터페이스 규격의 이름은?', '동기 뷰만 있던 프로젝트를 gunicorn 기본 워커로 운영해 왔다. 실시간 알림을 붙이려고 `async def` 뷰와 WebSocket 처리를 추가했더니 기존 워커에서는 요청이 처리되지 않았다. 서버를 uvicorn으로 바꾸고 `asgi.py`의 애플리케이션 객체를 가리키도록 설정하자 정상 동작했고, 대신 동기 전용으로 선언된 미들웨어가 하나 끼어 있던 구간마다 스레드 전환이 일어나 응답이 조금 느려졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3527
(9579, 3527, 'A-in → B-in → view → A-out → B-out', '응답 단계까지 목록 순서대로 흐른다고 본 오해. get_response 호출이 끝난 뒤의 코드는 안쪽에서 바깥쪽으로 돌아오므로 B-out이 A-out보다 먼저 찍힌다.', false),
(9580, 3527, 'A-in → B-in → view → B-out → A-out', 'A가 B를 감싸는 양파 구조라 요청은 A-in에서 B-in으로 안쪽으로 들어가고, 뷰가 끝난 뒤에는 안쪽 B-out부터 바깥 A-out으로 되돌아 나온다.', true),
(9581, 3527, 'B-in → A-in → view → A-out → B-out', '기동 시 Django가 MIDDLEWARE를 역순으로 순회하며 인스턴스를 조립하는 것을 실행 순서로 혼동한 것. 조립만 역순이고 실행은 목록 순서대로 바깥에서 안쪽으로 간다.', false),
(9582, 3527, 'A-in → A-out → B-in → B-out → view', '미들웨어가 각각 제 코드를 끝낸 뒤에야 다음으로 넘어간다고 본 오해. get_response 호출이 곧 다음 단계로의 위임이라 A의 나머지 코드는 뷰가 끝나야 실행된다.', false),

-- 문제 3528
(9583, 3528, 'CsrfViewMiddleware가 없어도 SecurityMiddleware가 POST 요청의 CSRF 토큰을 대신 검증한다.', '이름만 보고 보안 전반을 맡는다고 본 오해. SecurityMiddleware는 HTTPS 리다이렉트와 보안 헤더만 담당하고, CSRF 토큰 검증은 CsrfViewMiddleware가 process_view에서 한다.', false),
(9584, 3528, '응답 단계도 목록 위에서 아래 순서라 SecurityMiddleware가 응답을 가장 먼저 손본다.', '응답 단계는 아래에서 위로 거슬러 올라간다. 목록 맨 아래인 CommonMiddleware가 응답을 먼저 손대고 SecurityMiddleware가 마지막에 손댄다.', false),
(9585, 3528, '기동 시 Django가 의존 관계를 확인해 순서를 바로잡으므로 어떤 순서로 적어도 결과는 같다.', 'Django는 MIDDLEWARE의 순서를 검사하거나 재배치하지 않는다. 적어 둔 순서가 그대로 실행 순서이자 의존 관계이므로 잘못 적으면 실행 중에 드러난다.', false),
(9586, 3528, 'request.session이 아직 준비되지 않은 상태에서 request.user를 채우려다 요청 처리가 실패한다.', 'request.user를 만드는 미들웨어는 세션을 읽어야 하는데, 세션을 채우는 미들웨어가 목록에서 아래에 있어 요청 단계에서는 아직 실행되지 않았다. 순서가 곧 의존성이다.', true),

-- 문제 3529
(9587, 3529, 'None 대신 응답 객체를 돌려주면 뷰와 안쪽 미들웨어의 같은 훅을 건너뛰고 바로 응답 단계로 넘어간다.', '뷰 앞에서 요청을 끊을 수 있는 지점이라 차단 IP 검사나 권한 검사를 여기에 둔다. 반환값이 None이면 그대로 다음 단계로 진행한다.', true),
(9588, 3529, '뷰가 던진 예외 객체를 인자로 받아 원하는 응답으로 바꿔 돌려줄 수 있다.', '예외 객체를 받는 것은 process_exception이다. 이 훅은 뷰가 실행되기 전에 불리므로 아직 뷰의 예외가 생길 수 없다.', false),
(9589, 3529, '응답 단계에 속하므로 MIDDLEWARE 목록의 아래에서 위 순서로 호출된다.', '뷰 실행 전에 불리는 요청 단계 훅이라 목록 위에서 아래 순서다. 아래에서 위는 응답 단계와 예외 처리 훅의 순서다.', false),
(9590, 3529, '뷰가 돌려준 TemplateResponse의 컨텍스트를 렌더링 전에 고칠 수 있다.', '렌더링 전 컨텍스트를 손대는 것은 process_template_response다. 뷰가 응답을 돌려준 뒤에 불리는 응답 단계 훅이라 호출 시점이 다르다.', false),

-- 문제 3530
(9591, 3530, 'except ValueError가 걸려 상태 코드 400인 JSON 응답이 클라이언트에게 전달된다.', '코드 모양만 보면 그럴듯하지만, 핸들러가 뷰 호출을 감싸며 예외를 먼저 응답으로 바꾼다. except 절에는 아무것도 도달하지 않아 400 응답은 만들어지지 않는다.', false),
(9592, 3530, '예외가 이 미들웨어를 지나 서버까지 그대로 올라가므로 바깥 미들웨어의 응답 단계 코드는 실행되지 않는다.', '예외는 핸들러 선에서 응답으로 바뀌므로 서버까지 올라가지 않는다. 바깥 미들웨어의 응답 단계는 변환된 응답을 받아 평소처럼 실행된다.', false),
(9593, 3530, 'self.get_response(request)가 예외 대신 상태 코드 500인 응답을 돌려주므로 except 블록은 실행되지 않는다.', '핸들러가 뷰 호출을 감싸 예외를 응답으로 변환해 돌려주기 때문이다. 그래서 뷰의 예외를 가로채 응답으로 바꾸려면 try/except가 아니라 process_exception을 써야 한다.', true),
(9594, 3530, '예외가 삼켜져 get_response가 None을 돌려주므로 이어지는 return 줄에서 None이 그대로 나간다.', '핸들러는 예외를 삼키는 대신 반드시 응답 객체를 만들어 돌려준다. get_response가 None을 반환하는 경로는 없어서 응답 단계 코드는 항상 응답 객체를 받는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1132, 3531, '단락,쇼트서킷,쇼트 서킷,숏서킷,숏 서킷,short-circuit,short circuit,shortcircuit', '안쪽 미들웨어와 뷰의 진입 로그가 하나도 없는데 응답은 정상적으로 돌아 나온 것이 단서다. 어떤 미들웨어가 get_response를 호출하지 않고 그 자리에서 응답을 만들어 돌려주면 안쪽 체인과 뷰가 통째로 생략되는데, 이것이 단락(short-circuit)이다. 뷰가 실행된 뒤 예외 때문에 500이 나는 경우와 구분해야 한다. 예외 경로에서는 뷰 로그가 남고 process_exception이 안쪽부터 바깥쪽으로 불린다. process_view가 응답을 반환해 뷰를 건너뛰는 것도 같은 원리의 단락이다.'),
       (1133, 3532, 'ASGI,Asynchronous Server Gateway Interface,비동기 서버 게이트웨이 인터페이스', 'gunicorn 기본 워커는 동기 규격인 WSGI만 다루므로 async 뷰와 WebSocket 같은 지속 연결을 감당하지 못한다. uvicorn과 asgi.py로 바꾼 뒤 쓰이는 규격이 ASGI다. WSGI가 요청 하나를 environ 딕셔너리로 받아 동기로 처리하고 끝나는 반면, ASGI는 scope와 send·receive 콜러블로 비동기 이벤트를 주고받아 요청 하나에 여러 메시지가 오가는 통신도 담는다. 다만 동기 전용으로 선언된 미들웨어가 체인에 끼면 그 지점마다 스레드 전환이 일어나 비동기의 이점이 깎인다.');

-- =====================================================
-- Lesson 716: 예외 훅과 템플릿 응답, CSRF 검사
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4475, 716, '아래 코드에서 X-Api-Key 헤더가 없는 요청 한 건을 처리할 때 log에 남는 순서로 옳은 것은?', '```python
# settings.py
MIDDLEWARE = ["app.mw.ApiKeyMiddleware", "app.mw.TimingMiddleware"]

# app/mw.py
class ApiKeyMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        log("key:before")
        response = self.get_response(request)
        log("key:after")
        return response

    def process_view(self, request, view_func, view_args, view_kwargs):
        log("key:view")
        if "X-Api-Key" not in request.headers:
            return HttpResponseForbidden("no key")
        return None


class TimingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        log("timing:before")
        response = self.get_response(request)
        log("timing:after")
        return response

    def process_view(self, request, view_func, view_args, view_kwargs):
        log("timing:view")
        return None


# views.py
def report(request):
    log("report")
    return HttpResponse("ok")
```

요청 URL은 report 뷰로 라우팅된다.', 'OBJECTIVE'),
       (4476, 716, '아래 설정에서 뷰가 ValueError를 던졌을 때, 클라이언트가 받는 상태 코드와 오류 수집 서버 전송 여부로 옳은 것은?', '```python
MIDDLEWARE = [
    "app.mw.ErrorReportMiddleware",  # ①
    "app.mw.ErrorPageMiddleware",    # ②
    "app.mw.ApiErrorMiddleware",     # ③
]
```

| 미들웨어 | process_exception 동작 |
|---|---|
| ① ErrorReportMiddleware | 예외 정보를 오류 수집 서버로 전송하고 None 반환 |
| ② ErrorPageMiddleware | 예외 종류와 상관없이 상태 코드 500인 HTML 오류 페이지 반환 |
| ③ ApiErrorMiddleware | ValueError면 상태 코드 400인 JSON 응답 반환, 그 외에는 None 반환 |

세 미들웨어의 `__call__`은 `get_response`가 돌려준 응답을 손대지 않고 그대로 반환한다.', 'OBJECTIVE'),
       (4477, 716, '아래 코드로 서버를 띄우고 요청 3건을 차례로 처리했을 때, log의 init 줄 수와 세 번째 응답의 헤더 값으로 옳은 것은?', '```python
# settings.py
MIDDLEWARE = ["app.mw.CounterMiddleware"]

# app/mw.py
class CounterMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        self.count = 0
        log("init")

    def __call__(self, request):
        self.count += 1
        request.seen = getattr(request, "seen", 0) + 1
        response = self.get_response(request)
        response["X-Count"] = str(self.count)
        response["X-Seen"] = str(request.seen)
        return response
```

서버는 프로세스 1개·스레드 1개로 실행되고, 요청 3건 사이에 재기동은 없다. 뷰는 `request.seen`을 건드리지 않는다.', 'OBJECTIVE'),
       (4478, 716, '아래 조건을 지키면서 요청당 쿼리 수를 줄이는 방법으로 옳은 것은?', '멀티 테넌트 서비스에서 `TenantMiddleware`가 모든 요청의 요청 단계에서 `request.tenant`를 채운다.

```python
class TenantMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        request.tenant = Tenant.objects.get(domain=request.get_host())  # 쿼리 1건
        return self.get_response(request)
```

성능 모니터링 도구로 하루 요청 120만 건을 살펴보니 그중 80%는 헬스 체크와 공개 설정 API처럼 `request.tenant`를 한 번도 쓰지 않는 요청이었는데, 이 요청들에서도 매번 쿼리가 1건씩 나갔다.

- 조건: `request.tenant`를 쓰는 뷰 코드는 수정하지 않는다.', 'OBJECTIVE'),
       (4479, 716, '아래 상황에서 promo 뷰의 빈칸에 들어갈 응답 클래스의 이름은?', '두 뷰가 같은 템플릿과 같은 컨텍스트를 쓴다.

```python
def home(request):
    return render(request, "landing.html", {"notice": ""})


def promo(request):
    return ________(request, "landing.html", {"notice": ""})
```

모든 페이지에 점검 공지를 띄우려고 미들웨어에 훅을 하나 추가해, 넘겨받은 응답의 `context_data["notice"]`에 공지 문구를 채운 뒤 응답을 그대로 돌려주게 했다. 배포 후 로그를 보니 이 훅은 `promo` 요청에서만 호출됐고 `home` 요청에서는 한 번도 호출되지 않았다. 화면에도 `promo` 페이지에만 공지가 떴다.', 'SUBJECTIVE'),
       (4480, 716, '아래 상황에서 대행사 서버의 POST 요청을 거절한 Django 기본 미들웨어의 이름은?', '결제 대행사가 결제 완료를 알리려고 우리 서버의 `/payments/webhook/`으로 요청을 보낸다. 대행사 서버는 브라우저가 아니어서 우리 사이트의 쿠키 없이 JSON 본문만 담아 보낸다. `MIDDLEWARE`는 `startproject`로 만든 기본 목록 그대로이고, 웹훅 뷰 함수 첫 줄에 로그를 심어 두었다.

| 요청 | 응답 상태 코드 | 뷰 첫 줄 로그 |
|---|---|---|
| 대행사 서버가 보낸 GET | 200 | 남음 |
| 관리자가 우리 사이트의 Django 템플릿 폼으로 보낸 POST | 200 | 남음 |
| 대행사 서버가 보낸 POST | 403 | 남지 않음 |

기본 목록에서 미들웨어 한 줄을 주석 처리하자 대행사 POST도 200이 됐다. 보안상 그 줄은 되살리고, 대신 웹훅 뷰 함수에만 Django가 제공하는 데코레이터 하나를 붙여 같은 결과를 얻었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4475
(12107, 4475, 'key:before → key:view → key:after', 'process_view가 자기 __call__의 요청 단계 코드 바로 뒤에 붙어 실행된다고 본 오해. process_view는 라우팅이 끝난 뒤, 즉 모든 미들웨어의 get_response 호출 전 코드가 실행된 다음에 불린다.', false),
(12108, 4475, 'key:before → timing:before → key:view → key:after', 'process_view의 응답 반환을 __call__ 단락처럼 여겨 안쪽 미들웨어의 응답 단계도 생략된다고 본 오해. TimingMiddleware는 이미 get_response를 호출한 상태라 돌아온 403 응답을 받아 timing:after를 남긴다.', false),
(12109, 4475, 'key:before → timing:before → key:view → timing:after → key:after', 'process_view는 가장 안쪽 get_response(라우팅·뷰 실행) 안에서 불리므로 두 before가 먼저 찍힌다. key:view가 403 응답을 반환하면 timing:view와 뷰는 건너뛰고, 응답은 안쪽 timing:after부터 바깥 key:after로 돌아 나온다.', true),
(12110, 4475, 'key:before → timing:before → key:view → timing:view → timing:after → key:after', '응답을 반환해도 뷰만 건너뛰고 나머지 process_view는 계속 불린다고 본 오해. process_view가 응답을 돌려주면 그 뒤의 process_view와 뷰가 모두 실행되지 않는다.', false),

-- 문제 4476
(12111, 4476, '상태 코드 500, 오류 수집 서버로 전송됨', 'process_exception도 목록 위에서 아래로 불린다고 본 오해. 그 순서라면 ①이 전송한 뒤 ②가 500을 돌려주겠지만, 예외 훅은 응답 단계에 속해 목록 아래에서 위로 불린다.', false),
(12112, 4476, '상태 코드 400, 오류 수집 서버로 전송되지 않음', '예외 훅은 가장 안쪽인 ③부터 바깥쪽으로 불린다. ③이 400 JSON 응답을 돌려주는 순간 호출이 멈추므로 ②·①의 process_exception은 불리지 않고, 그 응답이 그대로 응답 단계를 거쳐 나간다.', true),
(12113, 4476, '상태 코드 400, 오류 수집 서버로 전송됨', '응답이 나온 뒤에도 나머지 process_exception이 기록용으로 계속 불린다고 본 오해. 한 훅이 응답을 반환하면 바깥쪽 훅은 호출되지 않는다. 전송까지 하려면 ①을 ③보다 아래에 둬야 한다.', false),
(12114, 4476, '상태 코드 500, 오류 수집 서버로 전송되지 않음', '뷰에서 예외가 나면 훅이 돌려준 응답과 상관없이 핸들러가 500으로 바꾼다고 본 오해. 핸들러의 500 변환은 어떤 process_exception도 응답을 돌려주지 않았을 때만 일어난다.', false),

-- 문제 4477
(12115, 4477, 'init 3줄, X-Count 1, X-Seen 1', '요청마다 미들웨어 인스턴스가 새로 만들어진다고 본 오해. __init__은 서버 기동 시 한 번만 불리고, 이후 요청은 같은 인스턴스의 __call__만 반복해서 실행한다.', false),
(12116, 4477, 'init 1줄, X-Count 1, X-Seen 1', '인스턴스는 하나지만 self.count가 요청마다 0으로 돌아간다고 본 오해. self에 둔 값은 인스턴스와 함께 살아남아 요청이 올 때마다 누적된다.', false),
(12117, 4477, 'init 1줄, X-Count 3, X-Seen 3', '요청 객체도 요청 사이에 이어서 쓰인다고 본 오해. HttpRequest는 요청 한 건의 사이클 안에서만 공유되고 다음 요청에는 새 객체가 만들어져 seen이 다시 1부터 시작한다.', false),
(12118, 4477, 'init 1줄, X-Count 3, X-Seen 1', '__init__은 기동 시 1회라 init은 한 줄이고, 같은 인스턴스의 self.count는 3까지 쌓인다. 반면 request는 요청마다 새로 만들어져 seen은 매번 1이다. 요청별 상태는 self가 아니라 request나 __call__ 안에 둬야 한다.', true),

-- 문제 4478
(12119, 4478, '조회를 감싼 지연 객체를 request.tenant에 붙여, 뷰가 이 값을 처음 사용할 때에만 쿼리가 나가게 한다.', 'SimpleLazyObject처럼 조회를 미뤄 두면 tenant를 쓰지 않는 요청에서는 쿼리가 0건이 되고, 쓰는 뷰는 코드 수정 없이 같은 이름으로 읽는다. request.user를 지연 로딩하는 AuthenticationMiddleware와 같은 방식이다.', true),
(12120, 4478, '조회 코드를 get_response 호출 뒤로 옮기면, tenant를 쓰지 않는 요청에서는 쿼리가 나가지 않는다.', 'get_response 호출 뒤는 뷰가 끝난 응답 단계라 뷰는 request.tenant를 읽지 못해 오류가 난다. 그 코드도 요청마다 빠짐없이 실행되므로 쿼리 수 역시 줄지 않는다.', false),
(12121, 4478, 'TenantMiddleware를 MIDDLEWARE 목록 맨 아래로 옮기면, tenant를 쓰는 뷰로 가는 요청에서만 실행된다.', '목록 위치는 실행 순서만 정할 뿐 실행 여부를 고르지 않는다. 중간에 단락되지 않은 요청은 맨 아래 미들웨어까지 모두 거치므로 헬스 체크 요청에서도 쿼리가 나간다.', false),
(12122, 4478, '조회를 process_view로 옮기면 라우팅 뒤에 실행되므로, tenant를 쓰지 않는 뷰에서는 쿼리가 나가지 않는다.', 'process_view가 실행될 뷰 함수를 넘겨받는다고 해서 그 뷰가 tenant를 쓰는지까지 가려 주지는 않는다. 라우팅된 모든 요청에서 뷰 직전에 불리므로 쿼리 수는 그대로다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1448, 4479, 'TemplateResponse,django.template.response.TemplateResponse,Template Response,템플릿 리스폰스,템플릿리스폰스,템플릿 응답', '훅이 promo 요청에서만 불렸고, 그 훅이 context_data를 고친 결과가 화면에 반영됐다는 점이 단서다. process_template_response 훅은 뷰가 아직 렌더링되지 않은 응답인 TemplateResponse를 돌려줬을 때만 호출된다. TemplateResponse는 템플릿과 컨텍스트를 들고 있다가 이 훅들이 모두 불린 뒤에 렌더링되므로 미들웨어가 그 사이에 컨텍스트를 바꿀 수 있다. 반면 render()는 그 자리에서 템플릿을 렌더링해 완성된 HttpResponse를 돌려주므로 훅이 불리지 않고 고칠 컨텍스트도 남아 있지 않다. 또 이 훅은 응답 단계에 속해 MIDDLEWARE 목록 아래에서 위 순서로 불린다는 점에서, 위에서 아래 순서인 process_view와 구분해야 한다.'),
       (1449, 4480, 'CsrfViewMiddleware,django.middleware.csrf.CsrfViewMiddleware,CSRF 미들웨어,CSRF미들웨어,CSRF View Middleware,CSRF 뷰 미들웨어', 'GET과 우리 사이트 폼의 POST는 통과하고 쿠키 없이 들어온 외부 POST만 403으로 막혔으며, 뷰 첫 줄 로그조차 남지 않았다는 점이 단서다. CsrfViewMiddleware는 POST처럼 상태를 바꾸는 요청에 사이트가 발급한 CSRF 토큰이 함께 오는지 검사하는데, 이 검사를 라우팅이 끝난 뒤 뷰 직전인 process_view에서 하므로 거절되면 뷰가 실행되지 않는다. 같은 이유로 process_view가 넘겨받은 뷰 함수의 표시를 확인할 수 있어, 뷰에 @csrf_exempt를 붙이면 그 뷰만 검사를 건너뛴다. 기본 목록의 AuthenticationMiddleware는 request.user를 채울 뿐 요청을 거절하지 않고, 로그인을 강제하는 LoginRequiredMiddleware는 기본 목록에 없으며 거절 대신 로그인 페이지로 리다이렉트한다는 점과 구분해야 한다.');

-- =====================================================
-- Lesson 874: Django 미들웨어의 조립 순서와 예외·비동기 요청 처리 흐름
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5423, 874, '아래 코드로 서버를 기동한 직후 요청 한 건을 처리했을 때 log에 남는 순서로 옳은 것은?', '```python
# settings.py
MIDDLEWARE = ["app.mw.AuditMiddleware", "app.mw.TraceMiddleware"]

# app/mw.py
class AuditMiddleware:
    def __init__(self, get_response):
        log("audit:init")
        self.get_response = get_response

    def __call__(self, request):
        log("audit:call")
        return self.get_response(request)


class TraceMiddleware:
    def __init__(self, get_response):
        log("trace:init")
        self.get_response = get_response

    def __call__(self, request):
        log("trace:call")
        return self.get_response(request)


# views.py
def home(request):
    log("home")
    return HttpResponse("ok")
```

서버는 워커 프로세스 1개로 기동하고, 요청 URL은 home 뷰로 라우팅된다.', 'OBJECTIVE'),
       (5424, 874, '아래 세 요청을 차례로 처리했을 때 AccessLogMiddleware가 남기는 상태 코드를 요청 순서대로 나열한 것은?', '```python
# settings.py
MIDDLEWARE = ["app.mw.AccessLogMiddleware"]

# app/mw.py
class AccessLogMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        log(request.path, response.status_code)
        return response


# views.py
def product(request, pk):
    raise Http404("상품 없음")


def sales_report(request):
    raise PermissionDenied


def search(request):
    page = request.GET["page"]
    return HttpResponse(page)
```

| 순서 | 요청 | 처리하는 뷰 |
|---|---|---|
| 1 | GET /products/7/ | product |
| 2 | GET /reports/sales/ | sales_report |
| 3 | GET /search/ (쿼리 문자열 없음) | search |

MIDDLEWARE에는 위 미들웨어 하나만 등록돼 있다.', 'OBJECTIVE'),
       (5425, 874, '아래 미들웨어를 추가한 뒤 이 서비스의 요청 처리에 대한 설명으로 옳은 것은?', '뷰를 모두 `async def`로 작성한 서비스를 uvicorn(ASGI 서버)으로 운영한다. 기존 `MIDDLEWARE`에는 동기·비동기 요청을 모두 지원하는 Django 기본 미들웨어만 있었는데, 감사 로그를 남기려고 아래 미들웨어를 목록 맨 아래에 추가했다.

```python
class AuditLogMiddleware:
    # sync_capable, async_capable 속성은 따로 선언하지 않았다.
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        write_audit_log(request.path)  # 일반 def 함수
        return self.get_response(request)
```', 'OBJECTIVE'),
       (5426, 874, '아래 설정에서 report 뷰로 요청 한 건을 처리했을 때 X-Elapsed-Ms 헤더에 기록되는 값은?', '```python
# settings.py
MIDDLEWARE = [
    "app.mw.AuthContextMiddleware",
    "app.mw.TimingMiddleware",
    "app.mw.CompressMiddleware",
]

# app/mw.py
class TimingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start = time.perf_counter()
        response = self.get_response(request)
        elapsed_ms = (time.perf_counter() - start) * 1000
        response["X-Elapsed-Ms"] = f"{elapsed_ms:.0f}ms"
        return response
```

| 구간 | 걸린 시간 |
|---|---|
| AuthContextMiddleware: `get_response` 호출 전 (사용자 권한 조회) | 30ms |
| URL 라우팅 + report 뷰 실행 | 50ms |
| CompressMiddleware: `get_response` 호출 후 (응답 본문 gzip 압축) | 20ms |

표에 없는 구간의 시간은 0ms로 본다.', 'OBJECTIVE'),
       (5427, 874, '아래 상황에서 두 동작을 모두 일으킨 Django 기본 미들웨어의 이름은?', '`startproject`로 만든 기본 `MIDDLEWARE` 목록을 그대로 쓰는 쇼핑몰을 배포하면서 `settings.py`에 설정 두 줄을 추가했다. 목록 맨 아래에는 요청마다 진입 로그를 남기는 커스텀 미들웨어를 하나 더 달아 두었다. 배포 뒤 접속 기록은 아래와 같다.

```
[10:02:11] GET http://shop.example.com/cart/
           → 301  Location: https://shop.example.com/cart/
           (커스텀 미들웨어 진입 로그 없음, cart 뷰 진입 로그 없음)
[10:02:11] GET https://shop.example.com/cart/
           → 200  Strict-Transport-Security: max-age=31536000
           (커스텀 미들웨어 진입 로그 있음, cart 뷰 진입 로그 있음)
```

기본 목록에서 한 줄을 주석 처리하자, 추가한 설정 두 줄은 그대로인데도 301 리다이렉트와 `Strict-Transport-Security` 헤더가 모두 사라졌다.', 'SUBJECTIVE'),
       (5428, 874, '아래 코드의 빈칸에 들어갈 메서드 이름은?', '오류 수집 서버에 어떤 예외가 났는지 보내려고 미들웨어를 만들었다. 첫 버전은 `__call__`에서 `get_response`가 돌려준 응답의 `status_code`가 500이면 전송하게 했는데, 수집 서버에는 `status=500`만 쌓이고 예외 종류와 메시지는 한 건도 남지 않았다. 그래서 아래처럼 메서드 하나를 추가했다.

```python
class ErrorReportMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        return self.get_response(request)

    def ________(self, request, exc):
        send_to_collector(type(exc).__name__, str(exc), request.path)
        return None
```

배포 뒤 하루 동안 정상 응답 12,000건에서는 이 메서드가 한 번도 불리지 않았고, 500으로 끝난 7건에서만 불렸다. 수집 서버에는 주문 뷰에서 난 `OrderLockedError`와 그 메시지가 쌓였고, 7건의 응답은 그대로 500이었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5423
(14635, 5423, 'audit:init → trace:init → audit:call → trace:call → home', '인스턴스도 MIDDLEWARE 목록 순서대로 만들어진다고 본 오해. 바깥 미들웨어는 안쪽 미들웨어를 get_response로 넘겨받아야 하므로, Django는 목록을 역순으로 돌며 안쪽부터 인스턴스를 만든다.', false),
(14636, 5423, 'trace:init → audit:init → trace:call → audit:call → home', '역순 조립을 실행 순서로까지 넓힌 오해. 역순은 인스턴스를 만드는 순서일 뿐이고, 요청 단계는 목록 위에서 아래로 바깥 audit부터 안쪽 trace로 들어간다.', false),
(14637, 5423, 'trace:init → audit:init → audit:call → trace:call → home', '기동 시 Django는 목록을 역순으로 돌며 뷰를 감싸는 TraceMiddleware를 먼저 만들고, 그 인스턴스를 get_response로 넘겨 AuditMiddleware를 만든다. 요청은 목록 순서대로 바깥 audit에서 안쪽 trace로 들어간다.', true),
(14638, 5423, 'audit:init → audit:call → trace:init → trace:call → home', '요청이 지나갈 때 미들웨어가 차례로 만들어진다고 본 오해. __init__은 요청과 상관없이 서버 기동 시 모든 미들웨어에서 한 번씩 먼저 끝나고, 요청이 오면 __call__만 실행된다.', false),

-- 문제 5424
(14639, 5424, '500, 500, 500', '뷰에서 나온 예외는 종류와 상관없이 500이 된다고 본 오해. 핸들러는 Http404를 404로, PermissionDenied를 403으로 바꾸고, 그 밖의 처리되지 않은 예외만 500으로 바꾼다.', false),
(14640, 5424, '404, 401, 500', '권한 거부를 인증 실패(401)와 혼동한 오해. PermissionDenied는 요청자가 누구든 이 자원에 접근할 수 없다는 뜻이라 핸들러가 403 응답으로 바꾼다.', false),
(14641, 5424, '404, 403, 400', '쿼리 문자열이 빠진 것을 클라이언트 잘못으로 보고 400이 된다고 본 오해. request.GET["page"]가 던지는 KeyError 계열 예외는 핸들러가 따로 구분하지 않아 500이 된다. 400을 원하면 직접 응답을 만들어야 한다.', false),
(14642, 5424, '404, 403, 500', '핸들러가 뷰의 예외를 응답으로 바꿔 돌려주므로 미들웨어의 응답 단계 코드는 세 요청 모두에서 실행된다. Http404는 404, PermissionDenied는 403, KeyError는 500으로 바뀐다. 응답이 왔다고 성공으로 보면 안 되는 이유다.', true),

-- 문제 5425
(14643, 5425, '요청은 정상 처리되지만, 이 미들웨어 때문에 요청마다 스레드 전환이 생겨 비동기 뷰의 이점이 줄어든다.', '두 속성을 선언하지 않은 미들웨어는 동기 전용으로 취급된다. ASGI 요청 흐름에 동기 구간이 끼면 Django가 그 구간을 스레드에서 실행하도록 자동 적응시켜 동작은 하지만, 요청마다 전환 비용이 붙는다.', true),
(14644, 5425, '서버는 뜨지만, 요청이 이 미들웨어에 닿으면 async def가 아니라는 오류가 나 500 응답이 나간다.', '동기 미들웨어를 ASGI에서 쓰면 오류가 난다고 본 오해. 두 속성이 모두 False로 선언된 경우가 아니면 Django가 경로를 맞춰 감싸 주므로 동기 __call__도 오류 없이 실행된다.', false),
(14645, 5425, '요청은 정상 처리되고, Django가 __call__을 코루틴으로 바꿔 이벤트 루프에서 실행해 성능 차이가 없다.', '자동 적응을 코드 변환으로 본 오해. Django는 동기 함수를 코루틴으로 고쳐 쓰지 못하고, 별도 스레드에서 실행한 뒤 결과를 기다리므로 전환 비용이 생긴다.', false),
(14646, 5425, '요청은 정상 처리되지만, 비동기 경로와 맞지 않는 이 미들웨어는 건너뛰어 감사 로그가 남지 않는다.', '경로가 맞지 않는 미들웨어를 빼고 실행한다고 본 오해. MIDDLEWARE에 등록된 미들웨어는 모두 실행되며, 동기 전용이면 스레드로 감싸 실행될 뿐이라 감사 로그는 요청마다 남는다.', false),

-- 문제 5426
(14647, 5426, '50ms', 'get_response 호출이 뷰 실행만 뜻한다고 본 오해. get_response는 다음 미들웨어의 __call__이라, 안쪽 CompressMiddleware가 응답 단계에서 압축하는 20ms도 호출이 돌아오기 전에 끝난다.', false),
(14648, 5426, '70ms', 'TimingMiddleware의 get_response 호출은 안쪽 CompressMiddleware와 라우팅·뷰를 통째로 감싼다. 뷰 50ms에 안쪽 미들웨어의 응답 단계 20ms가 더해지고, 바깥 AuthContextMiddleware의 30ms는 측정 시작 전에 끝나 빠진다.', true),
(14649, 5426, '80ms', '목록 위쪽 미들웨어가 안쪽이라고 양파 구조를 거꾸로 본 오해. 목록 위가 바깥이라 AuthContextMiddleware의 30ms는 측정 시작 전에 끝나고, 아래쪽 CompressMiddleware의 20ms가 측정 구간 안에 든다.', false),
(14650, 5426, '100ms', '위치와 상관없이 요청 전체 시간이 잡힌다고 본 오해. 측정 구간은 자기 get_response 호출 전후뿐이라, 목록에서 자기보다 위에 있는 미들웨어의 처리 시간은 포함되지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1764, 5427, 'SecurityMiddleware,django.middleware.security.SecurityMiddleware,Security Middleware,시큐리티 미들웨어,시큐리티미들웨어,보안 미들웨어,보안미들웨어', 'HTTP 요청을 HTTPS 주소로 301 리다이렉트하고, HTTPS 응답에 Strict-Transport-Security(HSTS) 같은 보안 헤더를 붙이는 것이 SecurityMiddleware의 일이다. 기본 목록 맨 위에 있어서 HTTP 요청을 get_response 호출 없이 곧바로 리다이렉트 응답으로 돌려보내는데(단락), 그래서 첫 요청에서는 아래쪽 커스텀 미들웨어와 cart 뷰가 전혀 실행되지 않았다. 다른 처리보다 먼저 리다이렉트해야 하므로 맨 위에 둔다. APPEND_SLASH처럼 URL을 고쳐 리다이렉트하는 CommonMiddleware와 헷갈리기 쉽지만, CommonMiddleware는 HTTPS 전환이나 HSTS 헤더를 다루지 않는다. 응답에 X-Frame-Options 헤더를 붙여 클릭재킹을 막는 XFrameOptionsMiddleware와도 구분해야 한다.'),
       (1765, 5428, 'process_exception,process_exception(),process exception,processexception', '뷰가 예외를 던졌을 때만 호출되고 예외 객체를 인자로 받는 훅이 process_exception이다. __call__의 응답 단계는 핸들러가 이미 예외를 500 응답으로 바꾼 뒤의 결과만 보므로 어떤 예외였는지 알 수 없었다. 이 훅이 None을 반환하면 예외는 바깥쪽 미들웨어의 같은 훅으로 계속 넘어가고, 끝내 아무도 응답을 돌려주지 않으면 핸들러가 500 응답을 만든다. 그래서 7건은 여전히 500이었다. HttpResponse를 반환했다면 그 응답이 대신 나갔을 것이다. 뷰 실행 직전에 뷰 함수를 넘겨받는 process_view, 렌더링 전 TemplateResponse를 넘겨받는 process_template_response와 호출 시점이 다르다.');
