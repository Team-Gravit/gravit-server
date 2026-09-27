-- Unit: 에러 핸들링과 프로세스 안정성 (Unit ID: 130)
-- Chapter: Node.js (Chapter ID: 11)
-- Topic: NODE_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-nodejs-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(646, 'NODE_JS', 130, 'HARD', true,
 'Express 4로 만든 Node.js 서버가 async 핸들러의 미처리 거부 때문에 간헐적으로 종료됩니다. 팀원이 uncaughtException과 unhandledRejection에 로그만 남기는 리스너를 달아 프로세스를 계속 살려 두자고 제안한다면, 이 방식의 문제점과 대안을 어떻게 설명하시겠어요?',
 '로그만 남기고 계속 실행하는 방식은 위험합니다. 예외가 어디서 났는지 모르기 때문에 프로세스 상태를 신뢰할 수 없고, 버그가 발생한 뒤의 오염된 상태, 예를 들어 반쯤 쓰인 파일이나 잠긴 커넥션, 어긋난 카운터를 가진 채 계속 서비스하게 되며 메모리·커넥션 누수도 누적됩니다. 공식 문서도 uncaughtException 리스너에서는 동기적으로 정리 작업만 하고 종료하라고 명시합니다. 대안은 리스너에서 계속 실행하지 않고 우아한 종료를 거쳐 프로세스를 종료하는 것입니다. unhandledRejection 리스너에서 reason을 다시 throw해 uncaughtException 경로로 통일하고, uncaughtException 리스너에서 에러를 기록한 뒤 우아한 종료를 시도하며, 정리가 끝나지 않으면 타임아웃 후 강제 종료합니다. 프로세스를 죽이면 서비스가 끊긴다는 우려가 있지만, 죽이지 않으면 더 큰 장애가 옵니다. 재시작은 PM2·Kubernetes 같은 프로세스 매니저에 맡기면 되고, 이들이 새 프로세스를 즉시 띄우는 동안 나머지 프로세스가 트래픽을 받습니다. 종료 없이 관찰만 필요하다면 기본 종료 동작을 바꾸지 않는 uncaughtExceptionMonitor 이벤트를 쓸 수 있습니다. 또 Express 4는 async 핸들러에서 던진 예외를 잡지 못하므로, 이를 처리해 주는 Express 5·NestJS·Fastify를 쓰는 것도 원인 쪽의 대안입니다.'),
(647, 'NODE_JS', 130, 'NORMAL', true,
 'Node.js 에러 처리에서 운영 오류(Operational Error)와 프로그래머 오류(Programmer Error)는 어떻게 다르고, 각각 어떻게 대응해야 하나요?',
 '운영 오류는 정상 프로그램이 런타임에 만나는 예상 가능한 실패로, DB 연결 실패, 타임아웃, 잘못된 입력, 파일 없음, 404 같은 것들입니다. 프로그래머 오류는 undefined.foo 접근, 타입 오류, 잘못된 인자 전달 같은 코드의 버그입니다. 운영 오류는 프로세스를 종료하지 않고 요청 단위에서 처리하며, 재시도하거나 대체 응답을 주거나 사용자에게 4xx/5xx를 반환하는 식으로 대응합니다. 반면 프로그래머 오류는 즉시 실패시키고 프로세스를 종료한 뒤 재시작해야 합니다. 버그가 발생한 뒤에는 상태를 신뢰할 수 없기 때문입니다. 실무에서는 AppError 같은 도메인 에러 클래스를 정의하고 isOperational 같은 플래그로 운영 오류와 버그를 나눠 처리합니다.'),
(648, 'NODE_JS', 130, 'NORMAL', true,
 'Node.js에서 콜백 방식과 Promise(async/await) 방식은 비동기 에러가 전파되고 잡히는 방식이 어떻게 다른가요?',
 '콜백 방식에서는 콜백이 나중에 다른 스택에서 실행되기 때문에, 비동기 호출을 try/catch로 감싸도 콜백 안에서 throw한 예외는 잡히지 않고 uncaughtException이 됩니다. 그래서 콜백 스타일은 에러 우선 콜백 규약에 따라 첫 인자에 에러를 넘기고, 콜백 안에서는 throw하지 않고 err를 확인해 처리합니다. Promise 방식에서는 거부가 체인을 따라 전파되며, .catch()나 await에 try/catch를 걸어 잡을 수 있습니다. 필요하면 catch에서 새 에러를 cause 옵션과 함께 던져 원인을 보존합니다. 어디에서도 잡지 않은 거부는 unhandledRejection이 됩니다. 특히 async 함수를 forEach나 이벤트 핸들러에 넘기면 반환된 Promise를 아무도 기다리지 않아 거부가 조용히 unhandledRejection이 되므로 주의해야 합니다.'),
(649, 'NODE_JS', 130, 'EASY', true,
 'Node.js 서버에서 우아한 종료(Graceful Shutdown)란 무엇이고, SIGTERM을 받았을 때 어떤 순서로 진행되는지 설명해 주시겠어요?',
 '우아한 종료는 배포나 오토스케일링 때 오케스트레이터가 SIGTERM을 보낸 뒤 SIGKILL로 강제 종료하기 전까지, 진행 중인 요청을 끝내고 자원을 정리한 뒤 종료하는 것입니다. Kubernetes는 기본 30초 후 SIGKILL을 보냅니다. 순서는 먼저 server.close로 새 연결 수락을 중단하고 헬스체크가 실패를 반환하게 해 로드밸런서가 트래픽을 제외하도록 합니다. 다음으로 closeIdleConnections로 유휴 keep-alive 연결을 끊는데, 이것을 하지 않으면 server.close의 콜백이 호출되지 않아 종료가 SIGKILL까지 지연됩니다. 그 뒤 진행 중인 요청이 완료되기를 기다리고, DB 풀·메시지 큐·캐시 연결을 종료하고 로그를 플러시한 다음 process.exit(0)으로 종료합니다. 정리가 끝나지 않는 경우에 대비해 예를 들어 10초 타임아웃을 두고, 미완료라도 강제 종료합니다.'),
(650, 'NODE_JS', 130, 'EASY', true,
 'Node.js에서 uncaughtException과 unhandledRejection 이벤트는 각각 언제 발생하고, 리스너가 없을 때 기본 동작은 어떻게 되나요?',
 'uncaughtException은 동기적으로 throw된 예외가 어디에서도 잡히지 않았을 때 발생하고, unhandledRejection은 Promise 거부가 어디에서도 잡히지 않았을 때 발생합니다. uncaughtException에 리스너가 없으면 스택을 출력하고 종료 코드 1로 프로세스가 종료됩니다. unhandledRejection에 리스너가 없으면 Node 15부터는 기본 모드가 throw라서 uncaughtException으로 승격되어 프로세스가 종료됩니다. Node 15 이전에는 경고만 출력하고 넘어갔습니다. 이 동작은 --unhandled-rejections=warn|strict|none 플래그로 조정할 수 있습니다. 반대로 리스너가 등록돼 있으면 리스너가 실행되고 프로세스는 계속 실행됩니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 646
(3482, 646, '로그만 남기고 계속 실행하면 버그 이후의 오염된 상태로 서비스하게 된다고 설명', 'ESSENTIAL', 1),
(3483, 646, '리스너에서 계속 실행하지 않고 우아한 종료를 거쳐 프로세스를 종료하는 대안을 제시', 'ESSENTIAL', 2),
(3484, 646, '프로세스 재시작은 PM2·Kubernetes 등 프로세스 매니저에 맡긴다고 설명', 'ESSENTIAL', 3),
(3485, 646, '프로세스 하나가 죽어도 나머지 프로세스가 트래픽을 받는다고 언급', 'SUPPLEMENTARY', 4),
(3486, 646, '종료 없이 관찰만 하려면 uncaughtExceptionMonitor 이벤트를 사용한다고 언급', 'SUPPLEMENTARY', 5),
(3487, 646, 'async 핸들러 예외를 처리하는 Express 5·NestJS·Fastify를 근본 대안으로 언급', 'SUPPLEMENTARY', 6),

-- 질문 647
(3488, 647, '운영 오류는 DB 연결 실패·타임아웃처럼 예상 가능한 런타임 실패라고 설명', 'ESSENTIAL', 1),
(3489, 647, '프로그래머 오류는 undefined 접근·타입 오류 같은 코드의 버그라고 설명', 'ESSENTIAL', 2),
(3490, 647, '운영 오류는 프로세스를 종료하지 않고 요청 단위에서 처리한다고 서술', 'ESSENTIAL', 3),
(3491, 647, '프로그래머 오류는 프로세스를 종료한 뒤 재시작해야 한다고 서술', 'ESSENTIAL', 4),
(3492, 647, '재시도·대체 응답·4xx/5xx 반환 중 최소 1개를 운영 오류 대응으로 제시', 'SUPPLEMENTARY', 5),
(3493, 647, '프로그래머 오류가 발생한 뒤에는 프로세스 상태를 신뢰할 수 없다고 언급', 'SUPPLEMENTARY', 6),
(3494, 647, 'isOperational 같은 플래그로 운영 오류와 버그를 나눠 처리하는 방식을 언급', 'SUPPLEMENTARY', 7),

-- 질문 648
(3495, 648, '비동기 호출을 감싼 try/catch로는 콜백 안에서 throw한 예외를 잡을 수 없다고 설명', 'ESSENTIAL', 1),
(3496, 648, '콜백 방식은 에러 우선 콜백 규약으로 첫 인자에 에러를 넘긴다고 설명', 'ESSENTIAL', 2),
(3497, 648, 'Promise 거부는 체인을 따라 전파되어 .catch()나 await와 try/catch로 잡힌다고 설명', 'ESSENTIAL', 3),
(3498, 648, '콜백 안 throw를 못 잡는 이유로 콜백이 나중에 다른 스택에서 실행됨을 언급', 'SUPPLEMENTARY', 4),
(3499, 648, '어디에서도 잡지 않은 Promise 거부가 unhandledRejection이 된다고 언급', 'SUPPLEMENTARY', 5),
(3500, 648, 'async 함수를 forEach에 넘기면 거부를 아무도 기다리지 않는다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 649
(3501, 649, 'SIGTERM 수신 후 진행 중인 요청을 끝내고 자원을 정리한 뒤 종료하는 것이라고 설명', 'ESSENTIAL', 1),
(3502, 649, '첫 단계로 server.close를 호출해 새 연결 수락을 중단한다고 서술', 'ESSENTIAL', 2),
(3503, 649, '정리가 끝나지 않으면 타임아웃 후 강제 종료한다고 언급', 'ESSENTIAL', 3),
(3504, 649, '유휴 keep-alive 연결을 closeIdleConnections로 끊지 않으면 종료가 지연된다고 언급', 'SUPPLEMENTARY', 4),
(3505, 649, '종료 중 헬스체크가 실패를 반환해 로드밸런서가 트래픽을 제외하게 한다고 서술', 'SUPPLEMENTARY', 5),
(3506, 649, 'Kubernetes는 SIGTERM 후 기본 30초가 지나면 SIGKILL로 강제 종료한다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 650
(3507, 650, '잡히지 않은 동기 throw가 uncaughtException 이벤트를 발생시킨다고 설명', 'ESSENTIAL', 1),
(3508, 650, '잡히지 않은 Promise 거부가 unhandledRejection 이벤트를 발생시킨다고 설명', 'ESSENTIAL', 2),
(3509, 650, 'uncaughtException 리스너가 없으면 스택 출력 후 종료 코드 1로 종료된다고 설명', 'ESSENTIAL', 3),
(3510, 650, 'Node 15+에서 미처리 거부가 uncaughtException으로 승격되어 프로세스가 종료된다고 설명', 'ESSENTIAL', 4),
(3511, 650, 'Node 15 이전에는 미처리 거부가 경고만 출력하고 넘어갔다고 언급', 'SUPPLEMENTARY', 5),
(3512, 650, '--unhandled-rejections 플래그로 미처리 거부 동작을 조정할 수 있다고 언급', 'SUPPLEMENTARY', 6);
