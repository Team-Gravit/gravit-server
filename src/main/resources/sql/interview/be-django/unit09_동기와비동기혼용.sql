-- Unit: 동기와 비동기 혼용 (Unit ID: 140)
-- Chapter: Django (Chapter ID: 12)
-- Topic: DJANGO
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-django-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(696, 'DJANGO', 140, 'HARD', true,
 '운영 중인 Django 서비스 전체를 ASGI와 비동기 뷰로 전환해 성능을 높이자는 제안이 나왔습니다. 전환이 실제로 이점을 주는 경우와 이점이 사라지는 경우를 들어, 어떤 구성을 선택하시겠습니까?',
 'ASGI로 바꾼다고 무조건 빨라지지는 않습니다. ASGI는 이벤트 루프 위에서 I/O 대기 중인 요청이 루프에 제어권을 반납하는 구조라서, 외부 API 여러 개를 호출하거나 WebSocket 같은 장기 연결처럼 I/O 대기 시간이 긴 요청에서 이점이 나타납니다. 반면 요청 대부분이 DB 쿼리 몇 개로 끝나는 전형적인 CRUD API라면, Django 5.x의 ORM은 내부적으로 여전히 동기 드라이버를 스레드에서 실행하므로 처리량 차이가 거의 없습니다. 또 미들웨어 체인에서 동기·비동기 경계가 바뀔 때마다 스레드 전환 비용이 들고, 동기 전용 미들웨어가 하나라도 있으면 그 지점에서 요청이 스레드로 넘어가 비동기 뷰의 이점이 대부분 사라집니다. DRF의 APIView·ViewSet도 동기 전제라 async 핸들러를 넣어도 정상 동작하지 않으므로 비동기가 꼭 필요하면 순수 Django 뷰나 adrf 패키지를 써야 하고, CPU 위주 작업은 이벤트 루프를 점유하므로 비동기로 바꾸기보다 워커 프로세스 증설이나 태스크 큐로 분리해야 합니다. 그래서 전체 전환 대신 동기 Django + WSGI를 기본으로 두고, 외부 API 병렬 호출·스트리밍·WebSocket처럼 이점이 분명한 엔드포인트만 ASGI 비동기 뷰로 분리하는 구성을 선택하겠습니다. 전체를 비동기로 바꾸려면 미들웨어 스택 전체를 async_capable로 맞추고 DRF·서드파티까지 검토해야 하는 큰 작업이기 때문입니다.',
 'interview-question/696.mp3'),
(697, 'DJANGO', 140, 'NORMAL', true,
 'WSGI와 ASGI의 처리 모델은 어떻게 다르고, 각각에서 동기 뷰와 비동기 뷰는 어떻게 실행되나요?',
 'WSGI는 요청 1개를 워커 스레드나 프로세스 1개가 동기로 처리하는 모델이라 동시 처리 수가 워커 수로 제한됩니다. ASGI는 이벤트 루프 위에서 코루틴으로 다수 요청을 동시에 처리하고, I/O 대기 중인 요청은 루프에 제어권을 반납합니다. 뷰 실행 방식을 보면, WSGI에서 동기 뷰는 네이티브로 실행되지만 비동기 뷰는 동작은 해도 요청마다 이벤트 루프를 새로 만들기 때문에 이점이 없습니다. ASGI에서는 비동기 뷰가 네이티브로 실행되고, 동기 뷰는 sync_to_async로 자동 변환되어 스레드 풀에서 실행됩니다. 또 WSGI는 HTTP만 다루지만 ASGI는 WebSocket 같은 장기 연결도 지원합니다. 서버로는 WSGI에 gunicorn·uWSGI, ASGI에 uvicorn·daphne·hypercorn 등을 사용합니다.',
 'interview-question/697.mp3'),
(698, 'DJANGO', 140, 'NORMAL', true,
 'asgiref의 sync_to_async와 async_to_sync는 각각 어떤 상황에서 쓰이고 어떻게 동작하는지 차이를 설명해 주세요.',
 '두 함수는 asgiref가 제공하는 동기·비동기 어댑터로 방향이 반대입니다. sync_to_async는 비동기 코드에서 동기 함수를 호출할 때 쓰며, 함수를 스레드에서 실행하고 코루틴으로 감싸서 await할 수 있게 합니다. 예를 들어 비동기 뷰에서 트랜잭션이 포함된 동기 서비스 함수를 호출할 때 사용합니다. async_to_sync는 반대로 Celery 태스크 같은 동기 코드에서 비동기 함수를 호출할 때 쓰며, 새 이벤트 루프나 별도 스레드의 루프에서 실행하고 결과를 반환합니다. 다만 async_to_sync는 이미 이벤트 루프가 실행 중인 스레드에서 호출하면 RuntimeError가 나므로, 비동기 뷰 안에서 동기 함수를 거쳐 다시 async_to_sync를 부르는 중첩 구조는 만들지 않아야 합니다. sync_to_async의 thread_sensitive 인자는 기본값이 True이며, 같은 요청 안의 호출을 하나의 스레드에서 순차 실행해 ORM 커넥션·트랜잭션처럼 스레드에 묶인 상태를 보호합니다. thread_sensitive=False는 스레드 풀의 아무 스레드에서나 실행되므로 스레드 상태와 무관한 순수 계산 함수에만 사용합니다.',
 'interview-question/698.mp3'),
(699, 'DJANGO', 140, 'EASY', true,
 'Django 비동기 뷰 안에서 list(Post.objects.all())처럼 ORM 쿼리를 동기 방식으로 평가하면 어떤 일이 일어나고, 왜 그런가요? 또 어떻게 해결할 수 있나요?',
 '비동기 뷰는 이벤트 루프가 실행 중인 스레드에서 돌기 때문에, 그 안에서 동기 쿼리를 실행하면 Django ORM이 이를 감지해 SynchronousOnlyOperation 예외를 던집니다. ORM 커넥션이 스레드에 묶여 있고, 동기 드라이버로 쿼리를 실행하면 이벤트 루프를 블로킹하기 때문입니다. 해결하려면 Django 4.1부터 제공되는 비동기 ORM 인터페이스, 즉 async for로 쿼리셋을 순회하거나 aget()·afirst()·acount() 같은 a 접두어 메서드를 쓰면 됩니다. 또는 쿼리를 동기 함수로 묶어 sync_to_async로 감싸 스레드에서 실행할 수도 있습니다. 참고로 a 접두어 메서드는 내부적으로 sync_to_async로 동기 쿼리를 스레드에서 실행하는 얇은 래퍼라서 Django 5.x 기준으로 진정한 비동기 드라이버는 아닙니다. 또 FK 지연 로딩은 비동기 버전이 없으므로 필요한 관계는 select_related로 미리 로드해야 합니다. DJANGO_ALLOW_ASYNC_UNSAFE=true로 이 검사를 끌 수도 있지만 서버 코드에서 켜면 예외 대신 조용한 데이터 손상·루프 블로킹으로 바뀔 뿐입니다.',
 'interview-question/699.mp3'),
(700, 'DJANGO', 140, 'EASY', true,
 'Django 비동기 뷰 안에서 requests.get()이나 time.sleep() 같은 블로킹 호출을 하면 어떤 문제가 생기고, 외부 HTTP 호출은 어떻게 해야 하나요?',
 '비동기 뷰 안에서 requests.get()이나 time.sleep(), 동기 파일 I/O 같은 블로킹 호출을 하면 그 호출이 이벤트 루프를 독점하기 때문에, 그 워커가 처리 중인 모든 요청이 멈춥니다. 동기 뷰에서의 블로킹은 그 스레드 하나만 막는 데 그치지만, 비동기 뷰의 블로킹은 루프 전체를 멈추게 한다는 점이 문제입니다. 그래서 비동기 뷰에서 외부 HTTP를 호출할 때는 requests를 쓰지 말고 httpx.AsyncClient나 aiohttp 같은 비동기 클라이언트를 사용해야 합니다. 이렇게 하면 asyncio.gather로 독립적인 외부 호출을 동시에 실행해 I/O를 병렬화할 수 있는데, 이것이 비동기 뷰의 대표적인 용도입니다.',
 'interview-question/700.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 696
(3750, 696, 'ASGI 전환의 이점은 외부 API 호출처럼 I/O 대기 시간이 긴 요청에서 나타남을 설명', 'ESSENTIAL', 1),
(3751, 696, 'DB 위주 CRUD는 ORM 쿼리가 스레드에서 동기 실행되어 처리량 차이가 거의 없음을 언급', 'ESSENTIAL', 2),
(3752, 696, '동기 미들웨어·DRF의 동기 전제·CPU 위주 작업 중 최소 1개를 비동기 이점이 사라지는 경우로 제시', 'ESSENTIAL', 3),
(3753, 696, '동기 Django + WSGI를 기본으로 두고 이점이 분명한 엔드포인트만 ASGI 비동기 뷰로 분리하는 구성을 제시', 'ESSENTIAL', 4),
(3754, 696, '비동기 경로를 쓰려면 미들웨어 스택 전체를 async_capable로 맞춰야 함을 언급', 'SUPPLEMENTARY', 5),
(3755, 696, 'CPU 위주 작업은 워커 프로세스 증설·태스크 큐로 분리해야 함을 언급', 'SUPPLEMENTARY', 6),
(3756, 696, 'DRF에서 비동기가 필요하면 순수 Django 뷰나 adrf 패키지를 대안으로 제시', 'SUPPLEMENTARY', 7),

-- 질문 697
(3757, 697, 'WSGI는 요청 1개를 워커 스레드/프로세스 1개가 동기로 처리함을 설명', 'ESSENTIAL', 1),
(3758, 697, 'ASGI는 이벤트 루프 위에서 코루틴으로 다수 요청을 동시에 처리함을 설명', 'ESSENTIAL', 2),
(3759, 697, 'ASGI에서 동기 뷰는 스레드 풀에서 실행됨을 언급', 'ESSENTIAL', 3),
(3760, 697, 'WSGI에서 비동기 뷰는 요청마다 이벤트 루프를 새로 만들어 이점이 없음을 언급', 'ESSENTIAL', 4),
(3761, 697, 'WSGI는 HTTP만 지원하고 ASGI는 WebSocket 등 장기 연결도 지원함을 언급', 'SUPPLEMENTARY', 5),
(3762, 697, 'WSGI 서버로 gunicorn·uWSGI, ASGI 서버로 uvicorn·daphne 중 최소 1개씩을 제시', 'SUPPLEMENTARY', 6),

-- 질문 698
(3763, 698, 'sync_to_async는 비동기 코드에서 동기 함수를 스레드에서 실행하고 코루틴으로 감쌈을 설명', 'ESSENTIAL', 1),
(3764, 698, 'async_to_sync는 동기 코드에서 비동기 함수를 이벤트 루프에서 실행하고 결과를 반환함을 설명', 'ESSENTIAL', 2),
(3765, 698, 'async_to_sync를 이벤트 루프가 이미 실행 중인 스레드에서 호출하면 RuntimeError가 남을 언급', 'SUPPLEMENTARY', 3),
(3766, 698, 'thread_sensitive=True(기본값)는 같은 요청의 호출을 하나의 스레드에서 순차 실행함을 설명', 'SUPPLEMENTARY', 4),
(3767, 698, 'thread_sensitive=False는 스레드 상태와 무관한 순수 계산 함수에만 사용해야 함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 699
(3768, 699, '비동기 컨텍스트에서 동기 쿼리를 실행하면 SynchronousOnlyOperation 예외가 발생함을 언급', 'ESSENTIAL', 1),
(3769, 699, '커넥션의 스레드 종속·동기 드라이버의 이벤트 루프 블로킹 중 최소 1개를 원인으로 제시', 'ESSENTIAL', 2),
(3770, 699, 'a 접두어 메서드·async for·sync_to_async로 감싸기 중 최소 1개를 해결책으로 제시', 'ESSENTIAL', 3),
(3771, 699, 'a 접두어 메서드는 내부적으로 sync_to_async로 스레드에서 쿼리를 실행하는 얇은 래퍼임을 언급', 'SUPPLEMENTARY', 4),
(3772, 699, 'FK 지연 로딩은 비동기 버전이 없어 select_related로 미리 로드해야 함을 언급', 'SUPPLEMENTARY', 5),
(3773, 699, 'DJANGO_ALLOW_ASYNC_UNSAFE를 서버에서 켜면 조용한 데이터 손상·루프 블로킹으로 바뀜을 언급', 'SUPPLEMENTARY', 6),

-- 질문 700
(3774, 700, '블로킹 호출이 이벤트 루프를 독점해 그 워커가 처리 중인 모든 요청이 멈춤을 언급', 'ESSENTIAL', 1),
(3775, 700, '외부 HTTP는 requests 대신 httpx.AsyncClient·aiohttp 등 비동기 클라이언트를 써야 함을 언급', 'ESSENTIAL', 2),
(3776, 700, '동기 뷰에서의 블로킹은 그 요청을 처리하는 스레드 하나만 막음을 언급', 'SUPPLEMENTARY', 3),
(3777, 700, 'asyncio.gather로 독립적인 I/O를 병렬화하는 것이 비동기 뷰의 대표적 용도임을 언급', 'SUPPLEMENTARY', 4);
