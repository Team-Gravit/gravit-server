-- Unit: 요청 처리 파이프라인 (Unit ID: 129)
-- Chapter: Node.js (Chapter ID: 11)
-- Topic: NEST_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-nodejs-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(641, 'NEST_JS', 129, 'HARD', true,
 'NestJS에서 모든 에러를 로깅하려고 전역 인터셉터의 catchError에 로깅 로직을 넣었더니 401·403 응답이 로그에서 빠졌습니다. 원인이 무엇이고 어떻게 해결하시겠습니까?',
 '원인은 실행 순서에 있습니다. NestJS 요청 파이프라인은 미들웨어 → 가드 → 인터셉터(전) → 파이프 → 핸들러 순으로 실행되므로 가드가 인터셉터보다 먼저 실행됩니다. 인증에 실패해 가드가 UnauthorizedException(401)을 던지거나 canActivate가 false를 반환해 ForbiddenException(403)이 되면, 그 예외는 인터셉터를 거치지 않고 곧장 예외 필터로 갑니다. 인터셉터의 catchError는 핸들러와 파이프에서 난 예외만 잡기 때문에 401·403이 로그에서 빠진 것입니다. 해결책은 에러 로깅을 예외 필터로 옮기는 것입니다. 예외 필터는 파이프라인 어디서든 던져진 예외를 받아 HTTP 응답으로 바꾸므로 모든 단계의 예외를 한곳에서 처리할 수 있습니다. @Catch()로 모든 예외를 잡는 필터를 만들고, 로거처럼 DI가 필요하면 { provide: APP_FILTER, useClass: ... }로 등록합니다. 다만 필터는 가장 구체적인 것이 우선이라 메서드에 바인딩된 필터가 예외를 잡으면 컨트롤러·전역 필터는 실행되지 않는다는 점도 고려해야 합니다.',
 'interview-question/641.mp3'),
(642, 'NEST_JS', 129, 'NORMAL', true,
 'NestJS에서 미들웨어와 가드는 모두 핸들러 이전에 실행되는데, 두 구성요소의 차이는 무엇이고 역할 기반 인가를 가드에 두는 이유는 무엇인가요?',
 '가장 큰 차이는 ExecutionContext 유무입니다. 미들웨어는 Express 미들웨어와 동일한 (req, res, next) 시그니처로, 라우트 매칭 이전에 실행되기 때문에 어떤 컨트롤러·핸들러가 요청을 처리할지 알 수 없고 req, res에만 접근합니다. 그래서 데코레이터 메타데이터도 읽을 수 없습니다. 반면 가드는 ExecutionContext를 통해 어떤 핸들러가 실행될 예정인지 알 수 있어, Reflector로 @Roles(''admin'') 같은 핸들러·클래스 메타데이터를 조회할 수 있습니다. 이 덕분에 데코레이터 기반의 선언적 인가가 가드에서 가능하므로 역할 기반 인가는 가드에 둡니다. 가드는 canActivate가 true면 통과, false면 ForbiddenException(403)을 발생시킵니다. 관례적으로 인증(누구인가, AuthGuard)과 인가(할 수 있는가, RolesGuard)를 가드 두 개로 분리해 순서대로 배치합니다. 미들웨어는 요청 ID 부여, 원시 바디 파싱, helmet 같은 Express 생태계 통합처럼 라우트와 무관한 일에 적합합니다.',
 'interview-question/642.mp3'),
(643, 'NEST_JS', 129, 'NORMAL', true,
 'NestJS의 인터셉터와 파이프는 둘 다 핸들러 실행 전에 동작하는데, 두 구성요소의 역할은 어떻게 다른가요?',
 '파이프는 핸들러의 파라미터 단위로 동작하며 두 가지 일을 합니다. 문자열 "42"를 숫자 42로 바꾸는 변환과, 조건 미달이면 BadRequestException을 던지는 검증입니다. 예를 들어 ParseIntPipe나 ValidationPipe가 여기에 해당하고, 변환된 값이 핸들러에 전달됩니다. 파이프는 가드보다 뒤에 실행되므로 인증되지 않은 요청의 바디를 검증하느라 CPU를 쓰지 않습니다. 반면 인터셉터는 핸들러 실행 전과 후 모두에 개입합니다. 파이프라인에서 전후 모두 개입하는 구성요소는 인터셉터뿐입니다. intercept에서 next.handle()을 호출하면 RxJS Observable이 반환되고, 여기에 map, timeout 같은 연산자를 붙여 응답을 가공합니다. 그래서 응답 포맷 통일, 실행 시간 로깅, 캐시, 타임아웃 같은 전후 처리에 적합합니다. 정리하면 파이프는 파라미터 입력의 변환·검증, 인터셉터는 핸들러 전후의 가공을 책임집니다.',
 'interview-question/643.mp3'),
(644, 'NEST_JS', 129, 'EASY', true,
 'NestJS에서 HTTP 요청이 들어와 응답이 나가기까지 거치는 요청 처리 파이프라인의 실행 순서를 설명해 주세요.',
 '요청이 들어오면 미들웨어 → 가드 → 인터셉터(전) → 파이프 → 핸들러 순으로 실행됩니다. 미들웨어가 요청 전처리를 하고, 가드가 인가 여부를 판단하고, 인터셉터가 핸들러 전 로직을 수행한 뒤, 파이프가 입력을 변환·검증하고, 핸들러가 비즈니스 로직을 호출합니다. 핸들러가 실행된 뒤에는 응답이 인터셉터(후)를 거쳐 나가는데, 이 후처리는 메서드 → 컨트롤러 → 전역의 역순으로 진행됩니다. 그리고 파이프라인 어느 단계에서든 예외가 나면 예외 필터가 받아 HTTP 에러 응답으로 변환합니다. 가드가 인터셉터보다 먼저라는 순서가 중요한데, 가드에서 거부된 요청은 인터셉터와 파이프가 실행되지 않으므로 거부할 요청에는 비용을 쓰지 않는 구조입니다.',
 'interview-question/644.mp3'),
(645, 'NEST_JS', 129, 'EASY', true,
 'NestJS에서 ValidationPipe로 요청 DTO를 검증하는 방식과 주요 옵션을 설명해 주세요.',
 'ValidationPipe는 class-validator와 함께 DTO를 검증하는 파이프로, 보통 app.useGlobalPipes로 전역 등록합니다. CreateUserDto처럼 DTO 클래스의 필드에 @IsEmail(), @Length(8, 64) 같은 데코레이터를 붙여 두면, ValidationPipe가 파라미터의 타입 메타데이터인 DTO 클래스를 보고 요청 데이터를 검증합니다. 조건을 만족하지 못하면 BadRequestException, 즉 400 Bad Request가 발생합니다. 주요 옵션으로 whitelist: true는 DTO에 없는 속성을 제거하고, forbidNonWhitelisted: true는 DTO에 없는 속성이 오면 400을 반환하며, transform: true는 값을 기본 타입이나 DTO 인스턴스로 변환합니다. 주의할 점은 타입 메타데이터를 보고 검증하기 때문에 파라미터 타입을 any나 인터페이스로 선언하면 검증이 동작하지 않는다는 것입니다.',
 'interview-question/645.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 641
(3453, 641, '요청 파이프라인에서 가드가 인터셉터보다 먼저 실행된다는 순서를 언급', 'ESSENTIAL', 1),
(3454, 641, '가드에서 던진 예외는 인터셉터를 거치지 않고 곧장 예외 필터로 전달됨을 언급', 'ESSENTIAL', 2),
(3455, 641, '에러 로깅을 모든 단계의 예외를 한곳에서 처리하는 예외 필터로 옮기는 해결책을 제시', 'ESSENTIAL', 3),
(3456, 641, '인터셉터의 catchError는 핸들러와 파이프에서 난 예외만 잡는다고 명시', 'SUPPLEMENTARY', 4),
(3457, 641, '전역 예외 필터에 DI가 필요하면 APP_FILTER 토큰으로 모듈에 등록함을 언급', 'SUPPLEMENTARY', 5),
(3458, 641, '메서드에 바인딩된 필터가 예외를 잡으면 컨트롤러·전역 필터는 실행되지 않음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 642
(3459, 642, '미들웨어는 라우트 매칭 이전에 실행되어 어떤 핸들러가 처리할지 모름을 언급', 'ESSENTIAL', 1),
(3460, 642, '가드는 ExecutionContext로 실행될 핸들러의 메타데이터에 접근할 수 있음을 언급', 'ESSENTIAL', 2),
(3461, 642, '핸들러 메타데이터를 읽을 수 있어 데코레이터 기반 인가가 가드에서 가능하다는 이유를 제시', 'ESSENTIAL', 3),
(3462, 642, '미들웨어가 Express 미들웨어와 동일한 (req, res, next) 시그니처를 가짐을 언급', 'SUPPLEMENTARY', 4),
(3463, 642, '인증(AuthGuard)과 인가(RolesGuard)를 가드 두 개로 분리해 순서대로 배치하는 관례를 언급', 'SUPPLEMENTARY', 5),
(3464, 642, 'canActivate가 false를 반환하면 ForbiddenException(403)이 발생함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 643
(3465, 643, '파이프는 핸들러 파라미터 단위로 동작함을 언급', 'ESSENTIAL', 1),
(3466, 643, '파이프의 역할이 입력값의 변환과 검증임을 설명', 'ESSENTIAL', 2),
(3467, 643, '인터셉터는 핸들러 실행 전과 후 모두에 개입함을 언급', 'ESSENTIAL', 3),
(3468, 643, '인터셉터가 next.handle()이 반환한 RxJS Observable에 연산자를 붙여 응답을 가공함을 언급', 'SUPPLEMENTARY', 4),
(3469, 643, '응답 포맷 통일·실행 시간 로깅·캐시·타임아웃 중 최소 1개를 인터셉터의 용도로 제시', 'SUPPLEMENTARY', 5),
(3470, 643, '파이프가 가드보다 뒤에 실행되어 인증되지 않은 요청의 검증 비용을 쓰지 않음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 644
(3471, 644, '미들웨어 → 가드 → 인터셉터 → 파이프 → 핸들러 순의 요청 처리 순서를 제시', 'ESSENTIAL', 1),
(3472, 644, '핸들러 실행 후 응답이 인터셉터(후)를 거쳐 나간다고 언급', 'ESSENTIAL', 2),
(3473, 644, '어느 단계에서든 예외가 나면 예외 필터가 받아 에러 응답으로 변환함을 언급', 'ESSENTIAL', 3),
(3474, 644, '인터셉터 후처리는 메서드 → 컨트롤러 → 전역의 역순으로 진행됨을 언급', 'SUPPLEMENTARY', 4),
(3475, 644, '가드 실패 시 인터셉터·파이프가 실행되지 않아 거부할 요청에 비용을 쓰지 않음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 645
(3476, 645, 'ValidationPipe가 class-validator 데코레이터가 붙은 DTO 클래스로 요청 데이터를 검증함을 언급', 'ESSENTIAL', 1),
(3477, 645, '검증 조건을 만족하지 못하면 BadRequestException(400)이 발생함을 언급', 'ESSENTIAL', 2),
(3478, 645, 'whitelist·forbidNonWhitelisted·transform 중 최소 1개 옵션의 효과를 제시', 'ESSENTIAL', 3),
(3479, 645, 'whitelist·forbidNonWhitelisted·transform 세 옵션 중 최소 2개의 효과를 제시', 'SUPPLEMENTARY', 4),
(3480, 645, '파라미터 타입을 any나 인터페이스로 선언하면 ValidationPipe 검증이 동작하지 않음을 언급', 'SUPPLEMENTARY', 5),
(3481, 645, 'ValidationPipe를 app.useGlobalPipes로 전역 등록하는 방식을 언급', 'SUPPLEMENTARY', 6);
