-- Unit: 동기와 비동기 혼용 (Unit ID: 140)
-- Chapter: Django (Chapter ID: 12)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (566, 140, 'ASGI 경계와 어댑터 규칙'),
       (724, 140, '동시 실행과 스레드 경계, GIL'),
       (882, 140, 'Django 동기·비동기 혼용: 실행 위치와 흔한 함정');

-- =====================================================
-- Lesson 566: ASGI 경계와 어댑터 규칙
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3575, 566, '아래 비교표를 바탕으로 두 인터페이스 규격에 대한 설명 중 옳지 않은 것은?', '파이썬 웹 서버와 애플리케이션을 잇는 두 인터페이스 규격을 정리한 표다.

| 항목 | 인터페이스 A | 인터페이스 B |
| --- | --- | --- |
| 처리 모델 | 요청 1개 = 워커 스레드/프로세스 1개, 동기 실행 | 이벤트 루프 위에서 코루틴으로 다수 요청을 동시에 처리 |
| 대표 서버 | gunicorn, uWSGI | uvicorn, daphne, hypercorn |
| 지원 프로토콜 | HTTP 요청·응답만 | HTTP + WebSocket 등 장기 연결 |
| 동기 뷰 실행 | 네이티브 실행 | 스레드 풀로 넘겨 실행 |
| 비동기 뷰 실행 | 요청마다 이벤트 루프를 새로 만들어 실행 | 네이티브 실행 |', 'OBJECTIVE'),
       (3576, 566, '아래 비동기 뷰를 uvicorn 워커 1개로 서비스할 때, 동시에 도착한 요청 10개의 처리 양상으로 옳은 것은?', 'ASGI 서버(uvicorn 워커 1개)에 아래 뷰를 배포했고, 요청 10개가 동시에 도착했다.

```python
import time
import requests
from django.http import JsonResponse


async def report(request):
    res = requests.get("https://api.example.com/stats", timeout=5)  # 응답까지 약 0.5초
    time.sleep(0.5)                                                 # 리포트 정리 대기
    return JsonResponse(res.json())
```

요청 하나만 단독으로 처리하면 약 1초가 걸린다.', 'OBJECTIVE'),
       (3577, 566, '아래 뷰를 ASGI 서버에 배포한 뒤, 재고 차감이 실패한 요청에도 주문 행이 남는다. 그 원인으로 옳은 것은?', '주문 엔드포인트에서 재고 차감이 예외로 끝난 요청을 조사했더니, 재고 수량은 그대로인데 해당 주문 행은 테이블에 남아 있었다.

```python
from asgiref.sync import sync_to_async
from django.db import transaction
from django.db.models import F
from django.http import JsonResponse


@sync_to_async
def create_order(user, product_id, qty):
    with transaction.atomic():
        return Order.objects.create(user=user, product_id=product_id, qty=qty)


@sync_to_async
def decrease_stock(product_id, qty):
    with transaction.atomic():
        Stock.objects.filter(product_id=product_id).update(remaining=F("remaining") - qty)


async def place_order_view(request):
    order = await create_order(request.user, product_id=1, qty=2)
    await decrease_stock(product_id=1, qty=2)
    return JsonResponse({"id": order.id})
```', 'OBJECTIVE'),
       (3578, 566, '아래 배포 구성에 대한 설명으로 옳은 것은?', 'ASGI 서버(uvicorn)에 올린 Django 프로젝트의 구성이다.

- 미들웨어 스택은 5개이고, 그중 세 번째 클래스에만 `async_capable = False`가 붙어 있다.
- 주문 엔드포인트는 순수 Django의 `async def` 뷰다.
- 통계 엔드포인트는 DRF의 `APIView`를 상속해 만들었고, 핸들러는 `def get`이다.', 'OBJECTIVE'),
       (3579, 566, '아래 두 장면에서 함께 쓰인 asgiref 어댑터 함수의 이름은?', '**장면 1.** Celery 태스크는 일반 `def` 함수다. 그 안에서 `httpx.AsyncClient`로 만든 `fetch_all(urls)`를 그대로 불렀더니 네트워크 요청이 하나도 나가지 않고 `RuntimeWarning: coroutine ''fetch_all'' was never awaited` 경고만 남았다. asgiref의 어댑터 하나로 감싸 부르자 결과가 정상적으로 돌아왔다.

**장면 2.** 같은 어댑터를 비동기 뷰가 호출하는 동기 헬퍼 함수 안에 넣었더니 `RuntimeError: You cannot use ... from within an async context` 가 떴다.', 'SUBJECTIVE'),
       (3580, 566, '아래 서버 로그에서 가려진 예외 클래스의 이름은?', 'ASGI(uvicorn)로 배포한 뒤 이 엔드포인트만 500을 낸다.

```python
async def post_list(request):
    posts = list(Post.objects.all())
    return JsonResponse({"n": len(posts)})
```

서버 로그:

```
django.core.exceptions.[가려짐]: You cannot call this from an async context - use a thread or sync_to_async.
```

뷰 선언을 `def`로 되돌리거나, 조회 부분을 `sync_to_async`로 감싼 함수로 옮기면 정상 동작한다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3575
(9707, 3575, 'A는 동시에 처리하는 요청 수가 기동한 워커 수를 넘지 못해, 워커가 모두 I/O 응답을 기다리는 동안 새 요청은 대기열에 쌓인다.', '표의 처리 모델대로 요청 하나가 워커 하나를 통째로 점유한다. 워커가 전부 I/O 대기에 묶이면 남은 요청은 처리되지 못하고 큐에 쌓이므로 참인 진술이다.', false),
(9708, 3575, 'A에 `async def` 뷰를 올리면 요청마다 루프를 새로 만드는 비용이 붙고, 서로 다른 요청이 한 루프에서 번갈아 처리되지도 않는다.', '표에서 A는 요청 단위로 루프를 띄웠다 버린다. 루프가 요청마다 격리되므로 요청 사이의 겹침이 생기지 않는다. 참인 진술이다.', false),
(9709, 3575, 'B에서는 동기 뷰도 이벤트 루프 위에서 직접 실행되므로, 동기 뷰 하나가 3초를 쓰면 같은 워커의 다른 요청도 3초 동안 함께 멈춘다.', '표에서 B의 동기 뷰는 스레드 풀로 넘겨 실행한다. 그동안 루프는 비어 있어 다른 요청을 계속 처리하므로 거짓이다. 루프를 멈추는 것은 비동기 뷰 안의 블로킹 호출이다.', true),
(9710, 3575, '채팅처럼 연결을 오래 유지해야 하는 기능은 A 진입점으로는 다룰 수 없고 B 진입점이 필요하다.', '표의 지원 프로토콜대로 A는 HTTP 요청·응답만 처리한다. WebSocket 같은 장기 연결은 B에서만 다룰 수 있으므로 참인 진술이다.', false),

-- 문제 3576
(9711, 3576, 'Django가 뷰 안의 블로킹 호출을 감지해 스레드 풀로 넘기므로, 10개 요청이 서로 겹쳐 약 1초 만에 모두 끝난다.', '동기·비동기 자동 전환은 뷰와 미들웨어의 경계에서만 일어난다. 코루틴 본문 안에서 부른 requests.get·time.sleep은 루프 스레드에서 그대로 실행되며 스레드 풀로 넘어가지 않는다.', false),
(9712, 3576, '두 호출이 이벤트 루프를 붙잡고 있어 요청이 한 번에 하나씩 처리되고, 마지막 요청은 앞선 9개가 끝난 뒤에야 시작돼 약 10초 뒤 응답한다.', 'async def로 선언해도 await가 없는 블로킹 호출은 루프에 제어권을 반납하지 않는다. 요청당 약 1초가 직렬로 쌓여 10번째 요청은 9초를 기다린 뒤에 처리된다.', true),
(9713, 3576, 'time.sleep(0.5)이 도는 동안 루프가 제어권을 넘겨받아 다른 요청을 처리하므로 전체가 약 5초에 끝난다.', '제어권을 넘기는 것은 await asyncio.sleep()이다. time.sleep은 스레드 자체를 재우므로 그 스레드에서 도는 이벤트 루프도 함께 멈춘다.', false),
(9714, 3576, '블로킹은 그 요청을 맡은 실행 단위 하나만 막으므로, 동기 뷰였을 때와 똑같이 10개 요청 모두 약 1초 안에 응답한다.', '동기 뷰의 블로킹은 워커 스레드 하나만 막는다. 반면 비동기 뷰는 여러 요청이 이벤트 루프 하나를 공유하므로 블로킹의 영향이 그 워커의 모든 요청으로 번진다.', false),

-- 문제 3577
(9715, 3577, '`sync_to_async`의 `thread_sensitive` 기본값이 `False`라, 두 호출이 서로 다른 스레드에 떨어져 앞뒤 쿼리가 같은 트랜잭션에 담기지 못한다.', '기본값은 True이고, 같은 요청의 호출은 하나의 스레드에서 순차 실행돼 커넥션이 유지된다. 게다가 두 호출을 같은 스레드에 두더라도 atomic 블록이 호출마다 따로 열리고 닫히므로 결과는 달라지지 않는다.', false),
(9716, 3577, '`with transaction.atomic()` 블록은 비동기 컨텍스트에서 시작된 호출 안에서 무시되므로, 두 쿼리 모두 트랜잭션 밖에서 실행된다.', '`sync_to_async`가 넘긴 스레드 안은 평범한 동기 컨텍스트라 atomic 블록은 정상적으로 열리고 커밋된다. 각 함수는 제 몫의 트랜잭션을 제대로 처리하며, 문제는 블록이 동작하지 않는 것이 아니라 그 범위에 있다.', false),
(9717, 3577, '`update()`에 쓴 `F("remaining")` 식이 파이썬 쪽에서 계산되므로, 실행 스레드가 바뀌면 차감의 기준 값이 어긋난다.', '`F()` 식은 SQL로 번역돼 데이터베이스가 계산하므로 파이썬 값이나 실행 스레드와 무관하다. 오히려 값을 읽고 고쳐 쓰는 사이의 경합을 막아 주는 안전한 갱신 방식이라, 재고가 어긋난 원인이 될 수 없다.', false),
(9718, 3577, '`create_order` 호출이 반환되는 순간 그 안의 atomic 블록이 커밋을 마쳐, 주문 생성과 재고 차감을 함께 묶는 트랜잭션이 존재하지 않는다.', '트랜잭션은 커넥션에 묶여 동기 함수가 도는 구간에서만 열려 있다. 원자적이어야 하는 쿼리 묶음은 하나의 동기 함수 안 atomic 블록에 넣고 `sync_to_async`로 한 번만 호출해야, 뒤 단계가 실패했을 때 앞 단계까지 함께 되돌아간다.', true),

-- 문제 3578
(9719, 3578, '동기 전용 미들웨어를 지나는 지점에서 요청·응답 단계마다 실행이 스레드로 옮겨져, 주문 엔드포인트가 비동기로 얻으려던 이점이 대부분 사라진다.', 'Django는 체인에서 동기·비동기 경계가 바뀔 때마다 자동으로 적응시킨다. 전환은 요청·응답 각 단계에서 한 번씩 일어나고, 그 지점부터 요청이 스레드로 넘어가 동시성 이득이 줄어든다.', true),
(9720, 3578, '동기 미들웨어와 비동기 뷰가 섞이면 서버 기동 시 `ImproperlyConfigured`가 발생하므로, 스택 전체를 비동기로 바꿔야만 뜬다.', '경계가 바뀌면 Django가 자동으로 적응시키므로 섞여 있어도 서버는 정상 기동하고 동작한다. 문제는 기동 실패가 아니라 전환마다 붙는 비용이다.', false),
(9721, 3578, '통계 엔드포인트의 핸들러를 `async def get`으로 바꾸면 DRF가 코루틴으로 인식해 비동기로 실행한다.', 'DRF의 `APIView`·`ViewSet`은 동기 전제로 설계돼 인증·권한·스로틀도 동기로 돈다. 비동기가 필요하면 순수 Django 뷰로 빼거나 `adrf` 같은 서드파티를 쓴다.', false),
(9722, 3578, '비동기 뷰는 ASGI 핸들러가 직접 부르므로 미들웨어 스택을 건너뛰며, 세 번째 미들웨어의 설정은 주문 엔드포인트에 영향을 주지 않는다.', '비동기 뷰도 미들웨어 체인을 그대로 통과한다. 체인을 건너뛰는 경로는 없으므로 스택 안의 동기 전용 미들웨어는 모든 엔드포인트에 영향을 준다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1148, 3579, 'async_to_sync,asgiref.sync.async_to_sync', '동기 코드에서 코루틴 함수를 실행하려면 새 이벤트 루프(또는 별도 스레드의 루프)를 띄워 돌리고 결과를 돌려주는 async_to_sync가 필요하다. 장면 1의 경고는 코루틴 객체를 만들기만 하고 실행하지 않았다는 뜻이라 어댑터로 감싸야 실제 요청이 나간다. 장면 2는 이미 루프가 도는 스레드에서 다시 루프를 돌리려 해 생기는 오류이므로, 비동기 뷰 안쪽에서 이 어댑터를 중첩해 부르면 안 된다. 반대 방향, 즉 비동기 코드에서 동기 함수를 스레드에 넘겨 부르는 sync_to_async와 혼동하지 않도록 구분해 둔다.'),
       (1149, 3580, 'SynchronousOnlyOperation,django.core.exceptions.SynchronousOnlyOperation', '이벤트 루프가 도는 스레드에서 동기 ORM 쿼리가 실행되는 것을 Django가 감지하면 던지는 예외다. 커넥션이 스레드에 묶여 있고 동기 드라이버가 루프를 막기 때문에 미리 차단한다. 쿼리셋은 지연 평가라 Post.objects.all() 자체로는 쿼리가 나가지 않지만, list()로 평가되는 순간 동기 쿼리가 실행돼 예외가 난다. 해결책은 async for·aget()·acount() 같은 비동기 인터페이스를 쓰거나, 조회를 동기 함수로 묶어 스레드에 넘기는 것이다. 설정이 잘못됐을 때 나는 ImproperlyConfigured, DB 연결·쿼리 실패의 OperationalError와는 원인이 다르다.');

-- =====================================================
-- Lesson 724: 동시 실행과 스레드 경계, GIL
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4523, 724, '아래 비동기 뷰에 요청 1개가 들어왔을 때, 응답이 나가기까지 걸리는 시간은?', 'ASGI 서버(uvicorn)에 배포한 Django 5.1 뷰다. 주석의 시간은 각 호출이 끝나기까지 걸리는 시간이며, 그 밖의 처리 시간과 네트워크 경합은 무시한다.

```python
import asyncio
import httpx
from asgiref.sync import sync_to_async
from django.http import JsonResponse


async def dashboard(request):
    async with httpx.AsyncClient(timeout=3) as client:
        weather, news = await asyncio.gather(
            client.get("https://api.example.com/weather"),  # 약 0.6초
            client.get("https://api.example.com/news"),     # 약 0.9초
        )
        rate = await client.get("https://api.example.com/rate")  # 약 0.4초

    await sync_to_async(save_access_log)(request.user)  # 동기 함수, 약 0.2초
    return JsonResponse({
        "weather": weather.json(),
        "news": news.json(),
        "rate": rate.json(),
    })
```', 'OBJECTIVE'),
       (4524, 724, '아래 비동기 뷰에 요청이 들어왔을 때 일어나는 일로 옳은 것은?', 'ASGI 서버(uvicorn)에 배포한 Django 5.1 프로젝트다. 설정은 모두 기본값이고, 환경 변수 `DJANGO_ALLOW_ASYNC_UNSAFE`는 설정하지 않았다.

```python
# models.py
class Comment(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE)
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    body = models.TextField()


# views.py
async def comment_feed(request, post_id):
    comments = [c async for c in Comment.objects.filter(post_id=post_id)[:20]]
    total = await Comment.objects.filter(post_id=post_id).acount()
    names = [c.author.username for c in comments]
    return JsonResponse({"total": total, "names": names})
```', 'OBJECTIVE'),
       (4525, 724, '아래 부하 테스트 결과를 해석한 것으로 옳은 것은?', 'Django 5.1 프로젝트의 두 엔드포인트를 같은 사양의 서버에서 배포 방식만 바꿔 띄우고, 동시 사용자 200명으로 1분간 부하를 걸었다. 설정은 모두 기본값이고 DB 커넥션 수는 충분하며, 외부 API는 호출마다 약 0.3초 뒤에 응답한다.

| 엔드포인트 | 배포 방식 | 뷰 구현 | 처리량 |
| --- | --- | --- | --- |
| 게시글 상세 | WSGI (gunicorn 동기 워커 4개) | `def` 뷰, `Post.objects.get()` 1회 | 410 req/s |
| 게시글 상세 | ASGI (uvicorn 워커 4개) | `async def` 뷰, `await Post.objects.aget()` 1회 | 400 req/s |
| 여행 견적 | WSGI (gunicorn 동기 워커 4개) | `def` 뷰, `requests`로 외부 API 3곳을 차례로 호출 | 4 req/s |
| 여행 견적 | ASGI (uvicorn 워커 4개) | `async def` 뷰, `httpx.AsyncClient`와 `asyncio.gather`로 3곳을 동시에 호출 | 590 req/s |', 'OBJECTIVE'),
       (4526, 724, '아래 클래스 기반 뷰를 URLconf에 등록해 배포했을 때 일어나는 일로 옳은 것은?', 'ASGI 서버(uvicorn)에 배포한 Django 5.1 프로젝트다.

```python
# views.py
from django.http import JsonResponse
from django.views import View


class CouponView(View):
    async def get(self, request, code):
        coupon = await Coupon.objects.aget(code=code)
        return JsonResponse({"code": coupon.code, "rate": coupon.rate})

    def post(self, request, code):
        coupon = Coupon.objects.get(code=code)
        coupon.used_count += 1
        coupon.save()
        return JsonResponse({"used": coupon.used_count})


# urls.py
urlpatterns = [
    path("coupons/<str:code>/", CouponView.as_view()),
]
```', 'OBJECTIVE'),
       (4527, 724, '아래 상황에서 `False`로 지정한 인자의 이름은?', 'ASGI 서버(uvicorn)에 배포한 Django 5.1 주문 조회 뷰가 동기 전용 외부 SDK 세 개를 호출한다. 세 호출은 서로 독립적이고, 각각 네트워크 응답을 기다리느라 약 0.5초씩 걸린다.

```python
async def order_status(request, order_id):
    pay, ship, point = await asyncio.gather(
        sync_to_async(pay_sdk.fetch)(order_id),
        sync_to_async(ship_sdk.fetch)(order_id),
        sync_to_async(point_sdk.fetch)(order_id),
    )
    return JsonResponse({"pay": pay, "ship": ship, "point": point})
```

`asyncio.gather`로 묶었는데도 응답까지 약 1.5초가 걸렸다. 세 `sync_to_async` 호출에 인자 하나를 `False`로 지정해 넘기자, 코드의 다른 부분은 그대로인데 응답이 약 0.5초로 줄었다.', 'SUBJECTIVE'),
       (4528, 724, '아래 측정에서 스레드 4개로 나눠 돌려도 계산 시간이 줄지 않게 만든 CPython 인터프리터의 장치를 가리키는 용어는?', 'CPython 3.12로 돌리는 Django 서버에, 순수 파이썬 반복문으로 작성한 추천 점수 계산 함수 `score_batch(users)`가 있다. 파일·네트워크 I/O 없이 계산만 하며, 서버 CPU는 8코어다. 사용자 20만 명분을 세 가지 방식으로 계산해 시간을 쟀다.

| 실행 방식 | 소요 시간 |
| --- | --- |
| 20만 명을 단일 스레드에서 한 번에 계산 | 약 8.0초 |
| 5만 명씩 4묶음으로 나눠 `ThreadPoolExecutor(max_workers=4)`로 동시에 계산 | 약 8.3초 |
| 같은 4묶음을 `ProcessPoolExecutor(max_workers=4)`로 동시에 계산 | 약 2.3초 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4523
(12235, 4523, '약 0.9초', '`await`가 붙은 호출은 모두 동시에 실행된다고 본 오개념. `asyncio.gather`로 묶은 두 호출만 겹치고, 그 뒤의 `await`는 앞 줄이 끝나야 시작하므로 가장 긴 0.9초 하나로 끝나지 않는다.', false),
(12236, 4523, '약 1.3초', '`sync_to_async`로 감싼 함수는 별도 스레드에서 알아서 돌고 뷰는 기다리지 않는다고 본 오개념. 스레드에서 실행되더라도 `await`로 끝날 때까지 기다리므로 로그 저장 0.2초가 응답 시간에 더해진다.', false),
(12237, 4523, '약 1.5초', '`gather`로 묶은 두 호출은 겹쳐 실행돼 더 긴 0.9초에 끝나고, 이어서 환율 호출 0.4초와 `await`로 기다리는 로그 저장 0.2초가 차례로 붙는다. 0.9 + 0.4 + 0.2 = 1.5초.', true),
(12238, 4523, '약 2.1초', '`asyncio.gather`도 인자를 하나씩 차례로 기다린다고 본 오개념. `gather`는 넘겨받은 코루틴을 함께 스케줄해 I/O 대기를 겹치므로, 0.6초와 0.9초를 더하지 않고 긴 쪽 0.9초만 든다.', false),

-- 문제 4524
(12239, 4524, '첫 줄의 `async for`가 댓글을 한 건씩 따로 조회해, 이 줄에서만 쿼리가 20번 나간다.', '비동기 순회를 행마다 쿼리를 보내는 방식으로 오해. `async for`도 동기 `for`와 같은 지연 평가 규칙을 따라 쿼리셋을 한 번 평가한 뒤 결과를 돌므로, 첫 줄의 쿼리는 1번이다.', false),
(12240, 4524, '세 번째 줄의 `c.author` 접근이 동기 쿼리를 일으켜 `SynchronousOnlyOperation`이 발생한다.', '미리 불러오지 않은 FK에 접근하면 지연 로딩 쿼리가 나간다. 이 쿼리는 비동기 버전이 없어 이벤트 루프 스레드에서 동기로 실행되려 하므로 Django가 막는다. 첫 줄에서 `select_related("author")`로 함께 로드해야 한다.', true),
(12241, 4524, '세 번째 줄의 `c.author` 접근은 Django가 스레드 풀로 넘겨 실행해, 예외 없이 쿼리가 20번 더 나간다.', '미들웨어 경계의 자동 적응이 뷰 내부 코드에도 일어난다고 본 오개념. 코루틴 본문 안의 동기 ORM 호출은 스레드로 옮겨지지 않고 루프 스레드에서 실행되려다 예외로 차단된다.', false),
(12242, 4524, '작성자 정보는 `async for`로 댓글을 가져올 때 함께 로드돼, 예외 없이 쿼리 2번으로 끝난다.', '비동기 순회가 관계 객체까지 미리 채운다고 본 오개념. `async for`는 쿼리셋에 적힌 대로 댓글 행만 가져오며, 작성자를 함께 가져오려면 `select_related("author")`를 명시해야 한다.', false),

-- 문제 4525
(12243, 4525, '여행 견적의 ASGI 처리량이 높은 것은 이벤트 루프가 세 외부 호출을 CPU 코어 여러 개에 나눠 동시에 실행하기 때문이다.', '이벤트 루프를 멀티코어 병렬 실행으로 오해. 루프는 워커마다 스레드 하나에서 돌며, 외부 응답을 기다리는 동안 제어권을 넘겨 다른 요청을 처리하는 방식으로 대기 시간을 겹칠 뿐이다.', false),
(12244, 4525, '여행 견적의 `async def` 뷰를 WSGI 동기 워커 4개에 그대로 올려도 `asyncio.gather` 덕분에 처리량이 590 req/s에 가깝게 나온다.', 'WSGI는 요청마다 이벤트 루프를 새로 만들어 뷰를 돌리고, 응답이 끝날 때까지 워커를 붙잡는다. 요청당 시간이 0.3초로 줄어도 동시에 처리하는 요청이 워커 수 4개에 묶여 590 req/s에 한참 못 미친다.', false),
(12245, 4525, '게시글 상세의 ASGI 뷰에서 `aget()` 대신 `Post.objects.get()`을 쓰면 스레드 전환이 사라져 처리량이 WSGI보다 높아진다.', '비동기 뷰 안에서 동기 ORM을 부르면 스레드 전환이 사라지는 것이 아니라, 이벤트 루프 스레드에서 쿼리를 실행하려다 `SynchronousOnlyOperation`으로 막힌다. 처리량이 오르기는커녕 요청이 실패한다.', false),
(12246, 4525, '게시글 상세에서 두 방식의 처리량이 비슷한 것은 `aget()`도 결국 쿼리를 스레드로 넘겨 동기 드라이버로 실행하기 때문이다.', 'Django 5.x의 `a` 접두어 ORM 메서드는 동기 쿼리를 `sync_to_async`로 스레드에서 돌리는 얇은 래퍼다. 요청이 쿼리 하나로 끝나면 실제 일은 여전히 스레드의 동기 실행이라, 서버만 ASGI로 바꿔서는 처리량이 오르지 않는다.', true),

-- 문제 4526
(12247, 4526, '핸들러의 `def`와 `async def`가 섞여 `ImproperlyConfigured`가 발생하고, GET·POST 어느 요청도 정상 처리되지 않는다.', 'Django의 `View`는 HTTP 핸들러가 모두 동기이거나 모두 비동기여야 뷰 전체를 한쪽으로 표시할 수 있다. 섞여 있으면 뷰를 만드는 `as_view()` 단계에서 예외가 나므로 요청 메서드와 상관없이 이 뷰를 쓸 수 없다. 핸들러를 한쪽으로 통일해야 한다.', true),
(12248, 4526, 'Django가 메서드마다 따로 적응시켜, GET은 이벤트 루프에서, POST는 스레드 풀에서 각각 정상 처리된다.', '미들웨어 체인의 자동 적응이 뷰 클래스 안의 메서드마다 일어난다고 본 오개념. 클래스 기반 뷰는 뷰 전체의 동기·비동기 여부를 하나로 정하므로 메서드별 적응은 없다.', false),
(12249, 4526, '먼저 정의된 `get`을 따라 뷰 전체가 비동기로 취급돼, POST 요청에서만 `SynchronousOnlyOperation`이 발생한다.', '첫 핸들러가 뷰의 성격을 정한다고 본 오개념. Django는 나머지 핸들러도 같은 성격인지 검사해 다르면 곧바로 설정 오류를 내므로, POST가 비동기 컨텍스트에서 실행되는 단계까지 가지 않는다.', false),
(12250, 4526, '동기 핸들러가 하나라도 있으면 뷰 전체가 동기로 취급돼, `get`의 `aget()`도 스레드에서 실행되며 정상 처리된다.', '동기 쪽이 우선한다고 본 오개념. 뷰가 동기로 취급된다면 `async def get`을 불렀을 때 응답 대신 코루틴 객체가 돌아와 정상 응답이 될 수 없다. 실제로는 그 전에 핸들러 혼용 검사에서 예외가 난다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1464, 4527, 'thread_sensitive,thread-sensitive,thread sensitive,threadsensitive,thread_sensitive=False,스레드 민감,스레드 민감성', 'sync_to_async는 thread_sensitive의 기본값이 True라서, 같은 요청 안에서 감싼 동기 함수들을 하나의 스레드에서 차례로 실행한다. 그래서 asyncio.gather로 묶어도 세 SDK 호출이 한 스레드 앞에 줄을 서 0.5초 × 3 = 약 1.5초가 걸렸다. False로 넘기면 스레드 풀의 아무 스레드에서나 실행돼 세 호출이 동시에 응답을 기다리므로 약 0.5초로 줄어든다. 기본값이 True인 이유는 ORM 커넥션·트랜잭션처럼 스레드에 묶인 상태를 안전하게 쓰기 위해서이므로, 쿼리를 담은 함수에는 기본값을 유지하고 스레드 상태와 무관한 함수에만 False를 쓴다. 실행할 스레드 풀을 직접 지정하는 executor 인자나, 반대 방향으로 동기 코드에서 코루틴을 실행하는 async_to_sync와는 구분한다.'),
       (1465, 4528, 'GIL,Global Interpreter Lock,GlobalInterpreterLock,전역 인터프리터 락,전역 인터프리터 잠금,글로벌 인터프리터 락,글로벌 인터프리터 잠금', 'CPython은 GIL 때문에 한 프로세스 안에서 한 번에 한 스레드만 파이썬 바이트코드를 실행한다. 계산만 하는 코드는 스레드를 4개로 나눠도 GIL을 번갈아 잡으며 실행될 뿐이라 시간이 줄지 않고, 전환 비용 때문에 오히려 조금 늘었다(약 8.0초 → 약 8.3초). 프로세스는 저마다 인터프리터와 GIL을 따로 가지므로 네 코어에서 실제로 동시에 계산해 약 2.3초로 줄었다. 같은 이유로 CPU 위주 작업은 비동기 뷰로 바꿔도 빨라지지 않는다. 이벤트 루프도 스레드 하나에서 돌기 때문이며, 이런 작업은 워커 프로세스를 늘리거나 태스크 큐로 분리해야 한다. 네트워크·파일 응답을 기다리는 동안에는 GIL이 풀려 스레드가 효과를 보는 I/O 작업과 구분하고, 요청을 번갈아 처리하는 이벤트 루프 자체와도 혼동하지 않는다.');

-- =====================================================
-- Lesson 882: Django 동기·비동기 혼용: 실행 위치와 흔한 함정
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5471, 882, '아래 조건에서 마지막 요청의 응답이 나가는 시점은 요청 도착 후 약 몇 초인가?', 'Django 5.1 프로젝트를 gunicorn으로 배포했다. 진입점은 `wsgi.py`이고, 워커는 동기(`sync`) 워커 2개이며 각 워커는 요청을 한 번에 하나씩 처리한다.

```python
import asyncio
import httpx
from django.http import JsonResponse


async def price_compare(request, item_id):
    async with httpx.AsyncClient(timeout=3) as client:
        shop_a, shop_b = await asyncio.gather(
            client.get(f"https://a.example.com/items/{item_id}"),  # 약 0.8초
            client.get(f"https://b.example.com/items/{item_id}"),  # 약 0.5초
        )
    return JsonResponse({"a": shop_a.json(), "b": shop_b.json()})
```

이 엔드포인트에 요청 4개가 동시에 도착했다. 주석의 시간은 각 호출이 끝나기까지 걸리는 시간이며, 그 밖의 처리 시간과 네트워크 경합은 무시한다.', 'OBJECTIVE'),
       (5472, 882, '아래 조치 이후 이 엔드포인트가 동작하는 방식으로 옳은 것은?', 'ASGI 서버(uvicorn 워커 1개)에 배포한 Django 5.1 뷰에서 500 에러가 났다.

```python
async def check_coupon(request, code):
    valid = Coupon.objects.filter(code=code, used=False).exists()  # 쿼리 약 0.3초
    return JsonResponse({"valid": valid})
```

서버 로그:

```
django.core.exceptions.SynchronousOnlyOperation: You cannot call this from an async context - use a thread or sync_to_async.
```

담당자는 코드를 고치지 않고, 서버 환경 변수에 `DJANGO_ALLOW_ASYNC_UNSAFE=true`를 추가해 재배포했다. 그 뒤로 500 에러는 더 나지 않았다.', 'OBJECTIVE'),
       (5473, 882, '아래 실험 결과를 해석한 것으로 옳은 것은?', 'ASGI 서버(uvicorn)에 배포한 Django 5.1 프로젝트에서, 접속 기록을 남기는 동기 함수 `save_log()`(INSERT 1회, 약 0.2초)를 `async def` 뷰 안에서 세 가지 방식으로 불렀다. 뷰는 이 호출 뒤 곧바로 응답을 반환하며 다른 일은 하지 않는다. 로그 행 수는 요청을 보내고 10초 뒤에 확인했다.

| 실험 | 뷰 안의 호출 코드 | 응답 | 응답 시간 | 10초 뒤 로그 행 수 |
| --- | --- | --- | --- | --- |
| 1 | `save_log()` | 500 (`SynchronousOnlyOperation`) | - | 0 |
| 2 | `await sync_to_async(save_log)()` | 200 | 약 0.2초 | 1 |
| 3 | `sync_to_async(save_log)()` | 200 | 0.01초 미만 | 0 |', 'OBJECTIVE'),
       (5474, 882, '아래 뷰에 요청이 들어왔을 때 일어나는 일로 옳은 것은?', 'ASGI 서버(uvicorn)에 배포한 Django 5.1 계좌 이체 뷰다. 설정과 환경 변수는 모두 기본값이다.

```python
from django.db import transaction
from django.db.models import F
from django.http import JsonResponse


async def transfer(request):
    with transaction.atomic():
        await Account.objects.filter(pk=1).aupdate(balance=F("balance") - 10000)
        await Account.objects.filter(pk=2).aupdate(balance=F("balance") + 10000)
    return JsonResponse({"ok": True})
```', 'OBJECTIVE'),
       (5475, 882, '아래 상황에서 서버와 Django 사이의 인터페이스로 새로 채택한 규격의 이름은?', 'Django 5.1 서비스를 gunicorn 동기 워커 4개로 운영하다가, 실시간 알림을 붙이려고 브라우저에서 WebSocket 연결을 요청했더니 서버가 연결을 받아들이지 못하고 끊었다.

팀은 프로젝트의 진입점을 기존 모듈에서 다른 규격의 애플리케이션 객체로 바꾸고, 서버를 uvicorn으로 교체했다. 그 뒤로 WebSocket 연결이 유지됐고, 뷰마다 실행 스레드 이름을 찍은 로그는 다음과 같았다.

```
[def 뷰]        order_list   thread=ThreadPoolExecutor-3_0
[async def 뷰]  dashboard    thread=MainThread
```', 'SUBJECTIVE'),
       (5476, 882, '아래 상황에서 가려진 클래스 속성의 이름은?', 'ASGI 서버(uvicorn)에 배포한 Django 5.1 프로젝트다. `MIDDLEWARE` 설정의 맨 앞에는 사내에서 만든 `TenantMiddleware`가 있고, 나머지는 Django 기본 미들웨어다.

```python
class TenantMiddleware:
    [가려짐] = False

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        request.tenant = request.get_host().split(".")[0]
        return self.get_response(request)
```

`async def` 뷰 `order_summary`에 요청을 보내고 단계마다 실행 스레드 이름을 찍었다.

```
TenantMiddleware          thread=ThreadPoolExecutor-3_0
SecurityMiddleware        thread=MainThread
SessionMiddleware         thread=MainThread
AuthenticationMiddleware  thread=MainThread
order_summary (뷰)        thread=MainThread
```

`[가려짐]`의 값을 `True`로 바꾸고, 공식 문서의 비동기 미들웨어 예시대로 `__call__`이 `await self.get_response(request)`로 다음 단계를 부르는 코루틴이 되도록 고치자 다섯 줄 모두 `thread=MainThread`로 찍혔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5471
(14763, 5471, '약 0.8초', 'WSGI 워커도 이벤트 루프 하나로 여러 요청을 번갈아 처리한다고 본 오개념. WSGI에서 비동기 뷰는 요청마다 새로 만든 루프에서 돌고, 워커는 그 요청이 끝나야 다음 요청을 받으므로 한 번에 2개만 처리된다.', false),
(14764, 5471, '약 1.6초', '요청 하나 안에서는 gather가 두 호출의 대기를 겹쳐 긴 쪽 0.8초에 끝난다. 하지만 WSGI 워커는 요청이 끝날 때까지 붙잡혀 있어, 워커 2개가 요청을 2개씩 두 차례 처리한다. 0.8 × 2 = 1.6초.', true),
(14765, 5471, '약 2.6초', 'WSGI에서는 비동기 뷰가 동기로 바뀌어 gather 안의 호출도 차례로 실행된다고 본 오개념(1.3초 × 2차례). 요청마다 새로 만든 루프도 이벤트 루프이므로, 요청 안의 두 호출은 겹쳐 실행된다.', false),
(14766, 5471, '약 3.2초', '비동기 뷰 요청은 워커 수와 상관없이 서버 전체에서 한 줄로 처리된다고 본 오개념(0.8초 × 4). 동기 워커는 각자 독립된 프로세스라, 두 워커가 동시에 요청을 하나씩 맡는다.', false),

-- 문제 5472
(14767, 5472, '쿼리가 자동으로 스레드 풀에 넘겨져, 뷰 안의 호출을 `sync_to_async`로 감쌌을 때와 똑같이 안전하게 동작한다.', '환경 변수를 자동 스레드 전환 스위치로 본 오개념. 이 변수는 Django의 검사를 끌 뿐 실행 위치를 바꾸지 않는다. 쿼리는 여전히 이벤트 루프 스레드에서 동기로 실행된다.', false),
(14768, 5472, 'ORM이 비동기 드라이버로 바뀌어, 쿼리를 기다리는 약 0.3초 동안 이벤트 루프가 다른 요청을 처리한다.', '검사 해제를 비동기 드라이버 전환으로 본 오개념. Django 5.x ORM의 쿼리는 여전히 동기 드라이버로 실행되며 이 변수는 드라이버를 바꾸지 않는다. 쿼리가 도는 동안 루프는 제어권을 돌려받지 못한다.', false),
(14769, 5472, '쿼리가 이벤트 루프 스레드에서 그대로 실행돼, 약 0.3초 동안 이 워커가 맡은 다른 요청도 함께 멈춘다.', '이 변수는 SynchronousOnlyOperation 검사만 끈다. 동기 쿼리가 루프 스레드를 붙잡아 그동안 다른 코루틴이 돌지 못한다. 스레드에 묶인 커넥션을 여러 요청이 나눠 쓰게 돼 데이터가 조용히 꼬일 위험도 생긴다.', true),
(14770, 5472, '뷰 전체가 동기 뷰로 취급돼 스레드 풀에서 실행되므로, 루프는 막히지 않고 비동기의 이점만 사라진다.', '검사를 끄면 뷰가 동기 뷰로 바뀐다고 본 오개념. async def 뷰는 여전히 루프에서 코루틴으로 실행되고, 그 안의 동기 쿼리가 루프를 막는다. 서버 코드에서는 이 변수 대신 비동기 ORM API나 sync_to_async를 써야 한다.', false),

-- 문제 5473
(14771, 5473, '실험 3에서는 `save_log`가 응답과 별개로 다른 스레드에서 돌고 있어, 확인을 더 늦추면 로그 행이 1로 늘어난다.', 'await 없이 부르면 백그라운드 스레드에서 알아서 실행된다고 본 오개념. 0.2초짜리 INSERT인데 10초 뒤에도 0행이라는 결과가 이를 반박한다. 실행이 시작조차 되지 않았다.', false),
(14772, 5473, '실험 1의 `save_log()` 앞에 `await`만 붙이면, 실험 2처럼 스레드에서 실행돼 정상 처리된다.', 'await가 동기 함수를 스레드로 옮긴다고 본 오개념. await save_log()는 save_log()를 루프 스레드에서 먼저 실행한 뒤 반환값을 기다리려 하므로 같은 예외가 그대로 난다. 스레드로 넘기는 일은 sync_to_async가 한다.', false),
(14773, 5473, '실험 2의 약 0.2초 동안 INSERT가 이벤트 루프 스레드에서 실행돼, 같은 워커의 다른 요청도 그동안 멈춘다.', 'sync_to_async로 감싼 함수도 루프에서 돈다고 본 오개념. 감싼 함수는 별도 스레드에서 실행되고, 뷰는 await로 기다리는 동안 루프에 제어권을 넘긴다. 이 요청만 0.2초 기다릴 뿐 다른 요청은 계속 처리된다.', false),
(14774, 5473, '실험 3의 호출은 코루틴 객체를 만들기만 하고 끝나, `save_log`의 본문이 한 번도 실행되지 않았다.', 'sync_to_async(save_log)는 함수를 스레드에서 돌리는 코루틴 함수를 돌려준다. 이를 호출하면 코루틴 객체만 생기고, await해야 비로소 스레드에서 실행된다. 그래서 응답은 곧바로 나가지만 INSERT는 일어나지 않는다.', true),

-- 문제 5474
(14775, 5474, '`atomic` 블록에 들어가는 시점에 `SynchronousOnlyOperation`이 발생해, 두 계좌 모두 갱신되지 않는다.', 'atomic에는 비동기 버전이 없다. 블록에 들어갈 때 커넥션 상태를 확인하는 동기 DB 작업이 루프 스레드에서 실행되려 해 Django가 막는다. 원자적으로 묶을 쿼리는 atomic을 담은 동기 함수로 만들어 sync_to_async로 한 번 불러야 한다.', true),
(14776, 5474, '두 `aupdate`가 하나의 트랜잭션으로 묶여, 두 번째 갱신이 실패하면 첫 번째 갱신도 함께 되돌아간다.', '동기 트랜잭션 블록이 await 너머의 비동기 쿼리까지 감싼다고 본 오개념. 트랜잭션은 커넥션·스레드에 묶이는데 aupdate는 다른 스레드에서 실행된다. 게다가 기본 설정에서는 블록에 들어가는 단계부터 예외가 난다.', false),
(14777, 5474, '`atomic`이 비동기 컨텍스트를 감지해 블록 전체를 스레드로 옮겨 실행하므로, 두 갱신이 한 트랜잭션 안에서 처리된다.', 'Django가 async 코드 안의 동기 블록을 알아서 스레드로 옮긴다고 본 오개념. 자동 전환은 미들웨어·뷰의 경계에서만 일어나며, 뷰 본문 안의 with 블록은 루프 스레드에서 그대로 실행되다 막힌다.', false),
(14778, 5474, '예외 없이 두 갱신이 각각 따로 커밋되고, `atomic` 블록은 아무 효과 없이 지나간다.', '블록이 조용히 무시된다고 본 오개념. 기본 설정에서는 루프 스레드에서 실행되려는 동기 DB 작업을 Django가 예외로 막으므로, 블록에 들어가는 단계에서 멈춰 갱신까지 가지 못한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1780, 5475, 'ASGI,Asynchronous Server Gateway Interface,비동기 서버 게이트웨이 인터페이스,에이에스지아이', 'ASGI는 서버와 파이썬 웹 애플리케이션이 이벤트 루프 위에서 코루틴으로 요청을 주고받는 규격이다. 한 워커가 여러 요청과 장기 연결을 동시에 다룰 수 있어, HTTP 요청·응답만 다루는 WSGI(교체 전 gunicorn 동기 워커가 따르던 규격)로는 안 되던 WebSocket 연결이 유지됐다. 로그처럼 async def 뷰는 루프가 도는 메인 스레드에서 바로 실행되고, def 뷰는 루프를 막지 않도록 Django가 스레드 풀로 넘겨 실행한다. uvicorn·daphne는 이 규격을 구현한 서버의 이름이지 규격 이름이 아니라는 점을 구분한다. 또 규격만 바꾼다고 모든 요청이 빨라지지는 않으며, 이점은 WebSocket이나 외부 I/O 대기가 긴 요청에서 나타난다.'),
       (1781, 5476, 'async_capable,async capable,asynccapable,async_capable=True,async_capable = True', 'async_capable은 미들웨어가 비동기 요청 흐름을 직접 처리할 수 있는지 Django에 알리는 속성으로, 따로 적지 않은 클래스는 False(동기 전용)로 취급된다. ASGI에서 동기 전용 미들웨어를 만나면 Django는 그 지점에서 요청을 스레드로 넘기고, 다음 단계로 갈 때 다시 이벤트 루프로 돌아오는 전환을 자동으로 끼워 넣는다. 로그에서 TenantMiddleware만 스레드 풀에서 돈 것이 그 흔적이며, 요청·응답 단계마다 전환 비용이 붙어 비동기 뷰의 이점이 줄어든다. 동기 요청을 처리할 수 있는지 나타내는 짝 속성 sync_capable(기본값 True)과 구분하고, sync_to_async에 넘기는 thread_sensitive 인자와도 혼동하지 않는다. Django 기본 미들웨어는 MiddlewareMixin을 상속해 두 속성이 모두 True라 처음부터 루프에서 바로 실행됐다.');
