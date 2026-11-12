-- Unit: 요청·응답 사이클과 미들웨어 (Unit ID: 132)
-- Chapter: Django (Chapter ID: 12)
-- Topic: DJANGO
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-django-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(656, 'DJANGO', 132, 'HARD', true,
 '뷰에서 발생한 PermissionDenied 예외를 JSON 형식의 403 응답으로 바꾸는 커스텀 미들웨어를 만들려고 합니다. __call__ 안에서 get_response 호출을 try/except로 감싸는 방식이 왜 기대대로 동작하지 않는지, 대신 어떤 방법을 써야 하며 예외가 미들웨어 체인을 어떤 순서로 흐르는지 설명해 주세요.',
 '__call__ 안에서 self.get_response(request)를 try/except로 감싸도 뷰에서 던진 예외를 직접 잡을 수 없습니다. 핸들러가 뷰의 예외를 먼저 받아 process_exception 훅을 거친 뒤 예외를 응답으로 변환해 돌려주기 때문에, __call__ 입장에서는 예외가 아니라 이미 만들어진 응답 객체를 받게 됩니다. 따라서 예외를 응답으로 바꾸려면 미들웨어에 process_exception(request, exception) 메서드를 정의하고, isinstance(exception, PermissionDenied)일 때 JsonResponse({"detail": "권한 없음"}, status=403) 같은 HttpResponse를 반환해야 합니다. 처리하지 않을 예외에는 None을 반환하면 예외가 다음 미들웨어로 전파됩니다. 흐름을 보면 뷰에서 예외가 발생하면 가장 안쪽 미들웨어의 process_exception부터 바깥쪽으로 차례로 호출되고, 누군가 HttpResponse를 반환하면 그 응답으로 응답 단계가 진행됩니다. 아무도 처리하지 않으면 핸들러가 예외를 잡아 500 응답을 만들며, Http404는 404, PermissionDenied는 403으로 변환됩니다. 어느 경우든 바깥쪽 미들웨어의 응답 단계는 정상 실행됩니다.',
 'interview-question/656.mp3'),
(657, 'DJANGO', 132, 'NORMAL', true,
 'Django 미들웨어에서 __call__로 처리하는 것과 process_view 훅으로 처리하는 것은 어떤 차이가 있나요?',
 '__call__은 요청마다 실행되며 get_response 호출 전후로 요청 단계와 응답 단계를 처리하지만, 이 시점에는 아직 어떤 뷰가 실행될지 알 수 없습니다. 반면 process_view는 URL 라우팅이 끝난 뒤 뷰 실행 직전에 호출되는 훅으로, (request, view_func, view_args, view_kwargs)를 인자로 받기 때문에 뷰 함수 객체를 보고 어떤 뷰가 실행될지 알 수 있습니다. process_view가 None을 반환하면 계속 진행하고, HttpResponse를 반환하면 이후의 process_view와 뷰는 실행되지 않고 응답 단계로 바로 넘어갑니다. process_view는 요청 단계이므로 MIDDLEWARE의 위에서 아래 순서로 호출됩니다. 대표적인 예가 CSRF 미들웨어로, process_view 안에서 view_func의 속성을 확인해 @csrf_exempt가 붙은 뷰는 검증을 건너뜁니다.',
 'interview-question/657.mp3'),
(658, 'DJANGO', 132, 'NORMAL', true,
 'settings.MIDDLEWARE에 등록된 미들웨어들이 요청 단계와 응답 단계에서 각각 어떤 순서로 실행되는지 설명하고, 이 순서가 왜 중요한지 예를 들어 설명해 주세요.',
 '미들웨어는 서로를 감싸는 양파 구조로 조립됩니다. Django는 기동 시 MIDDLEWARE 리스트를 역순으로 순회하며 인스턴스를 만들기 때문에, 실행 시에는 요청 단계에서 리스트의 위에서 아래 순서로 바깥에서 안쪽으로 들어가고, 뷰가 반환한 응답은 응답 단계에서 아래에서 위 순서로 거슬러 올라갑니다. 이 순서가 중요한 이유는 순서가 곧 의존성이기 때문입니다. 위쪽 미들웨어가 request에 붙여 준 것을 아래쪽 미들웨어가 사용합니다. 예를 들어 AuthenticationMiddleware는 request.session이 필요하므로 반드시 SessionMiddleware 아래에 있어야 하고, 순서를 바꾸면 AssertionError나 AttributeError가 발생합니다. 또 SecurityMiddleware는 다른 처리 전에 리다이렉트로 단락시켜야 하므로 가장 위에 두고, LoginRequiredMiddleware는 AuthenticationMiddleware 아래에 두어야 합니다.',
 'interview-question/658.mp3'),
(659, 'DJANGO', 132, 'EASY', true,
 'Django 미들웨어에서 단락(short-circuit)이란 무엇인지 설명해 주세요.',
 '단락은 요청 단계에서 어떤 미들웨어가 self.get_response(request)를 호출하지 않고 바로 응답을 반환하는 것입니다. 이 경우 그 미들웨어보다 안쪽에 있는 미들웨어와 뷰는 실행되지 않습니다. 예를 들어 M1, M2, M3 순서에서 M2가 401 응답을 바로 반환하면 M3와 뷰는 실행되지 않고, 응답은 M2에서 M1으로 바깥쪽 미들웨어의 응답 단계를 거쳐 돌아갑니다. SecurityMiddleware가 가장 위에 위치해 다른 처리 전에 HTTPS 리다이렉트로 단락시키는 것도 같은 예입니다.',
 'interview-question/659.mp3'),
(660, 'DJANGO', 132, 'EASY', true,
 'Django 미들웨어의 기본 구조를 설명하고, __init__과 __call__이 각각 언제 호출되는지 말씀해 주세요.',
 'Django 미들웨어는 get_response를 인자로 받는 호출 가능 객체(callable)입니다. get_response는 다음 미들웨어의 __call__이고, 마지막 미들웨어라면 URL 라우팅과 뷰 실행을 담당하는 핸들러 내부 함수입니다. __init__은 서버 기동 시 한 번만 호출되어 get_response를 저장하고, __call__은 요청마다 실행됩니다. __call__ 안에서 self.get_response(request)를 호출하기 전의 코드는 요청 단계, 호출한 후의 코드는 응답 단계에 해당합니다. __init__은 기동 시 1회만 호출되므로 요청마다 초기화가 필요한 상태는 __call__ 안에 두어야 합니다. 작성한 미들웨어는 settings.py의 MIDDLEWARE 리스트에 경로 문자열로 등록합니다.',
 'interview-question/660.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 656
(3541, 656, '__call__에서 get_response를 try/except로 감싸도 뷰의 예외를 직접 잡을 수 없음을 언급', 'ESSENTIAL', 1),
(3542, 656, '핸들러가 process_exception을 거친 뒤 예외를 응답으로 변환해 돌려주기 때문이라는 이유를 설명', 'ESSENTIAL', 2),
(3543, 656, 'process_exception 훅에서 HttpResponse를 반환해 예외를 응답으로 바꿔야 함을 명시', 'ESSENTIAL', 3),
(3544, 656, 'process_exception은 가장 안쪽 미들웨어부터 바깥쪽 순서로 호출됨을 언급', 'ESSENTIAL', 4),
(3545, 656, 'process_exception이 None을 반환하면 예외가 다음 미들웨어로 전파됨을 언급', 'SUPPLEMENTARY', 5),
(3546, 656, '아무 미들웨어도 처리하지 않으면 핸들러가 PermissionDenied를 403 응답으로 변환함을 언급', 'SUPPLEMENTARY', 6),
(3547, 656, '예외가 응답으로 바뀐 뒤에도 바깥쪽 미들웨어의 응답 단계는 정상 실행됨을 언급', 'SUPPLEMENTARY', 7),

-- 질문 657
(3548, 657, 'process_view는 URL 라우팅 후 뷰 실행 직전에 호출됨을 언급', 'ESSENTIAL', 1),
(3549, 657, 'process_view는 view_func 인자를 받아 어떤 뷰가 실행될지 알 수 있음을 설명', 'ESSENTIAL', 2),
(3550, 657, 'process_view가 HttpResponse를 반환하면 뷰 실행을 건너뛰고 응답 단계로 넘어감을 언급', 'ESSENTIAL', 3),
(3551, 657, 'CSRF 미들웨어가 process_view에서 view_func 속성을 확인해 @csrf_exempt 뷰를 건너뛰는 예를 제시', 'SUPPLEMENTARY', 4),
(3552, 657, 'process_view는 요청 단계이므로 MIDDLEWARE 위에서 아래 순서로 호출됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 658
(3553, 658, '요청 단계에서는 MIDDLEWARE 리스트의 위에서 아래 순서로 통과함을 언급', 'ESSENTIAL', 1),
(3554, 658, '응답 단계에서는 뷰의 응답이 아래에서 위 순서로 거슬러 올라감을 언급', 'ESSENTIAL', 2),
(3555, 658, '뒤쪽 미들웨어가 앞쪽 미들웨어가 제공한 것에 의존하므로 순서가 곧 의존성임을 언급', 'ESSENTIAL', 3),
(3556, 658, 'Auth가 Session 아래·Security가 가장 위에 있는 이유 등 최소 1개 위치 이유를 예로 제시', 'ESSENTIAL', 4),
(3557, 658, '미들웨어가 서로를 감싸는 양파(onion) 구조로 조립됨을 언급', 'SUPPLEMENTARY', 5),
(3558, 658, '기동 시 MIDDLEWARE 리스트를 역순으로 순회하며 미들웨어 인스턴스를 만듦을 언급', 'SUPPLEMENTARY', 6),
(3559, 658, 'Auth와 Session 순서를 바꾸면 AssertionError나 AttributeError가 발생함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 659
(3560, 659, '미들웨어가 get_response를 호출하지 않고 바로 응답을 반환하는 것임을 설명', 'ESSENTIAL', 1),
(3561, 659, '단락되면 그 안쪽 미들웨어와 뷰는 실행되지 않음을 언급', 'ESSENTIAL', 2),
(3562, 659, '단락된 응답도 바깥쪽 미들웨어의 응답 단계를 거쳐 돌아감을 언급', 'SUPPLEMENTARY', 3),
(3563, 659, '401 응답 즉시 반환·SecurityMiddleware의 리다이렉트 중 최소 1개를 단락의 예로 제시', 'SUPPLEMENTARY', 4),

-- 질문 660
(3564, 660, '미들웨어는 get_response를 인자로 받는 호출 가능 객체(callable)임을 언급', 'ESSENTIAL', 1),
(3565, 660, '__init__은 서버 기동 시 1회만 호출됨을 언급', 'ESSENTIAL', 2),
(3566, 660, '__call__은 요청마다 실행됨을 언급', 'ESSENTIAL', 3),
(3567, 660, 'get_response 호출 전 코드는 요청 단계, 호출 후 코드는 응답 단계로 구분', 'SUPPLEMENTARY', 4),
(3568, 660, '요청마다 초기화가 필요한 상태는 __init__이 아닌 __call__ 안에 두어야 함을 언급', 'SUPPLEMENTARY', 5),
(3569, 660, 'settings.py의 MIDDLEWARE 리스트에 경로 문자열로 등록함을 언급', 'SUPPLEMENTARY', 6);
