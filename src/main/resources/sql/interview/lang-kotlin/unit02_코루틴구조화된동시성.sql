-- Unit: 코루틴 구조화된 동시성 (Unit ID: 197)
-- Chapter: Kotlin (Chapter ID: 19)
-- Topic: KOTLIN
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-kotlin-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(981, 'KOTLIN', 197, 'HARD', true,
 '코루틴 기반 서버에서 JDBC처럼 블로킹되는 DB 접근 코드를 실행해야 합니다. 어떤 디스패처를 선택하고 동시 실행 수는 어떻게 다뤄야 하며, 잘못 선택하면 어떤 문제가 생기는지 설명해 주세요.',
 'JDBC 호출은 블로킹 I/O이므로 Dispatchers.IO에서 실행해야 합니다. Dispatchers.Default는 CPU 코어 수만큼의 스레드(최소 2)로 구성된 CPU 집약 작업용 디스패처라서, 여기에 블로킹 I/O를 넣으면 코어 수만큼의 스레드가 막혀 전체가 멈출 수 있습니다. 반면 Dispatchers.IO는 필요 시 확장되는 풀(기본 상한 64 또는 코어 수 중 큰 값)이고 Default와 스레드를 공유하므로 전환 비용도 낮습니다. 다만 DB 커넥션 수에는 한계가 있으므로 Dispatchers.IO.limitedParallelism(10)처럼 커넥션 풀 크기에 맞춰 병렬도를 제한한 디스패처를 만들고, withContext(dbDispatcher)로 블로킹 호출을 감싸면 다른 코루틴을 막지 않습니다. limitedParallelism은 새 스레드를 만드는 것이 아니라 기존 디스패처 위에 병렬도 상한을 씌운 뷰로, 동시 실행 수만 제한합니다. IO의 스레드 상한은 시스템 프로퍼티로 조정할 수 있지만 무작정 올리기보다 커넥션·파일 핸들 같은 자원의 실제 한계에 맞추는 것이 올바른 접근입니다. 또한 서버 요청 처리 스레드에서 runBlocking을 호출하면 스레드를 점유해 이벤트 루프가 막히므로, runBlocking은 main이나 테스트 같은 진입점에서만 사용해야 합니다.',
 'interview-question/981.mp3'),
(982, 'KOTLIN', 197, 'NORMAL', true,
 '코루틴의 coroutineScope와 withContext는 둘 다 블록을 실행하고 결과를 반환하는데, 각각 어떤 목적으로 쓰이며 어떻게 다른지 설명해 주세요.',
 'coroutineScope는 현재 코루틴 안에 자식 스코프를 만드는 suspend 함수로, 병렬 분해를 위한 용도입니다. 반면 withContext는 주로 디스패처 같은 컨텍스트만 바꿔 블록을 실행하고 결과를 반환하는 함수로, 실행 환경을 전환하는 용도입니다. withContext도 내부적으로 새 스코프를 만들기는 하지만 병렬 분기가 목적이 아니라 실행 환경 전환이 목적이며, 대표적으로 블로킹 파일 읽기를 withContext(Dispatchers.IO)로 격리할 때 씁니다. coroutineScope는 블록 안의 모든 자식이 끝나야 반환되며, 자식 중 하나가 실패하면 나머지를 취소하고 예외를 다시 던집니다. 그래서 병렬 분해는 coroutineScope 안에서 async를 여러 개 띄운 뒤 awaitAll()로 모으는 것이 정석입니다. 예를 들어 프로필과 주문을 각각 async로 가져오면 둘 중 하나가 실패할 때 나머지도 취소됩니다.',
 'interview-question/982.mp3'),
(983, 'KOTLIN', 197, 'NORMAL', true,
 '자식 코루틴이 cancel()로 취소된 경우와 예외로 실패한 경우, 부모와 형제 코루틴에 미치는 영향은 어떻게 다른지 설명해 주세요.',
 '자식이 예외 없이 cancel()로 취소되면 부모는 취소되지 않습니다. 취소 시 던져지는 CancellationException은 정상 종료로 취급되기 때문입니다. 반면 자식이 예외로 실패하면 그 실패가 부모에게 전파되어 부모가 취소되고, 부모의 취소가 다시 형제 코루틴에 전파되어 부모와 형제가 모두 취소됩니다. 예를 들어 Job B 아래에 C와 D가 있을 때 C에서 예외가 나면 B가 취소되고 D도 취소되며 그 위의 A까지 전파됩니다. 이는 일반 Job일 때의 규칙이고, SupervisorJob을 쓰면 이 전파를 끊을 수 있습니다. 참고로 부모가 취소되는 경우에는 아래 방향으로 항상 모든 자식이 취소됩니다.',
 'interview-question/983.mp3'),
(984, 'KOTLIN', 197, 'EASY', true,
 '코틀린 코루틴의 구조화된 동시성(Structured Concurrency)이란 무엇이며, 이 원칙 덕분에 어떤 동작이 보장되는지 설명해 주세요.',
 '구조화된 동시성은 코루틴을 반드시 어떤 스코프, 즉 부모 안에서 시작하게 해서 부모의 생명주기가 자식의 생명주기를 포함하도록 강제하는 원칙입니다. launch나 async로 시작한 코루틴은 스코프의 컨텍스트를 상속하고 새 Job을 만들어 부모 Job의 자식으로 등록됩니다. 그 결과 부모는 자식의 완료를 기다리고, 부모가 취소되면 취소가 자식에게 전파되며, 자식의 실패는 부모에게 보고됩니다. 반대로 GlobalScope처럼 아무 데서나 시작되는 비동기 작업은 소유자와 종료 시점을 추적할 수 없어서 화면이 닫혀도 계속 돌며 누수되거나 예외가 조용히 사라질 수 있습니다. 구조화된 동시성 덕분에 이 함수가 반환되면 그 안에서 시작된 작업은 모두 끝나 있다는 호출 스택과 같은 직관을 비동기 코드에서도 유지할 수 있습니다.',
 'interview-question/984.mp3'),
(985, 'KOTLIN', 197, 'EASY', true,
 '코루틴에 cancel()을 호출했는데도 코루틴이 멈추지 않는 경우가 있습니다. 그 이유와 해결 방법을 설명해 주세요.',
 '코루틴의 취소는 협력적입니다. job.cancel()은 코루틴을 강제로 죽이는 것이 아니라 취소 요청 플래그를 세울 뿐이고, 코루틴이 다음 중단 지점에 도달했을 때 CancellationException이 던져지면서 종료됩니다. delay(), yield(), withContext() 같은 kotlinx.coroutines의 suspend 함수는 취소를 확인하지만, CPU 집약 루프처럼 중단 지점이 없는 코드는 취소 요청을 감지하지 못해 끝까지 실행됩니다. 해결하려면 루프 안에서 isActive를 검사하거나 ensureActive() 또는 yield()를 주기적으로 호출해야 합니다. ensureActive()는 취소된 상태면 CancellationException을 던집니다. 덧붙여 취소된 코루틴 안에서 다시 suspend 함수를 호출하면 즉시 CancellationException이 발생하므로, finally에서 연결 종료처럼 suspend가 필요한 정리 작업은 withContext(NonCancellable)로 감싸야 합니다.',
 'interview-question/985.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 981
(5291, 981, 'JDBC 같은 블로킹 I/O 호출은 Dispatchers.IO에서 실행해야 함을 언급', 'ESSENTIAL', 1),
(5292, 981, '블로킹 I/O를 Dispatchers.Default에 넣으면 코어 수만큼의 스레드가 막혀 전체가 멈춤을 설명', 'ESSENTIAL', 2),
(5293, 981, 'limitedParallelism으로 DB 커넥션 풀 크기에 맞춰 병렬도를 제한하는 방법을 제시', 'ESSENTIAL', 3),
(5294, 981, 'limitedParallelism은 새 스레드를 만들지 않고 동시 실행 수만 제한함을 언급', 'SUPPLEMENTARY', 4),
(5295, 981, 'IO 스레드 상한을 무작정 올리기보다 자원의 실제 한계에 맞춰야 함을 언급', 'SUPPLEMENTARY', 5),
(5296, 981, '서버 요청 처리 스레드에서 runBlocking을 호출하면 스레드를 점유해 막힘을 언급', 'SUPPLEMENTARY', 6),

-- 질문 982
(5297, 982, 'coroutineScope는 병렬 분해를 위한 자식 스코프를 만드는 용도임을 설명', 'ESSENTIAL', 1),
(5298, 982, 'withContext는 디스패처 같은 컨텍스트를 바꿔 실행 환경을 전환하는 용도임을 설명', 'ESSENTIAL', 2),
(5299, 982, 'coroutineScope는 블록 안의 모든 자식이 끝나야 반환됨을 언급', 'SUPPLEMENTARY', 3),
(5300, 982, 'coroutineScope 안에서 async를 여러 개 띄우고 awaitAll로 모으는 패턴을 제시', 'SUPPLEMENTARY', 4),
(5301, 982, 'coroutineScope에서 자식 하나가 실패하면 나머지를 취소하고 예외를 다시 던짐을 언급', 'SUPPLEMENTARY', 5),

-- 질문 983
(5302, 983, '자식이 cancel()로 취소되어도 부모는 취소되지 않음을 언급', 'ESSENTIAL', 1),
(5303, 983, '자식이 예외로 실패하면 부모와 형제 코루틴이 모두 취소됨을 설명', 'ESSENTIAL', 2),
(5304, 983, 'CancellationException이 정상 종료로 취급됨을 언급', 'SUPPLEMENTARY', 3),
(5305, 983, '실패 전파 규칙은 SupervisorJob이 아닌 일반 Job일 때 적용됨을 명시', 'SUPPLEMENTARY', 4),
(5306, 983, '부모 취소는 아래 방향으로 모든 자식에게 항상 전파됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 984
(5307, 984, '모든 코루틴이 부모 스코프 안에서 시작되어 부모 Job의 자식으로 등록됨을 설명', 'ESSENTIAL', 1),
(5308, 984, '부모 코루틴이 자식 코루틴의 완료를 기다림을 언급', 'ESSENTIAL', 2),
(5309, 984, '부모가 취소되면 그 취소가 자식에게 전파됨을 언급', 'ESSENTIAL', 3),
(5310, 984, '자식의 실패가 부모에게 보고됨을 언급', 'SUPPLEMENTARY', 4),
(5311, 984, 'GlobalScope처럼 소유자 없는 코루틴은 누수되거나 예외가 조용히 사라짐을 언급', 'SUPPLEMENTARY', 5),
(5312, 984, '함수가 반환되면 그 안에서 시작된 작업이 모두 끝나 있다는 직관을 서술', 'SUPPLEMENTARY', 6),

-- 질문 985
(5313, 985, 'cancel()이 코루틴을 강제 종료하지 않고 취소를 요청할 뿐임을 설명', 'ESSENTIAL', 1),
(5314, 985, '중단 지점이 없는 CPU 집약 루프는 취소되지 않음을 언급', 'ESSENTIAL', 2),
(5315, 985, 'ensureActive()·yield()·isActive 검사 중 최소 1개를 루프에 넣는 해결책을 제시', 'ESSENTIAL', 3),
(5316, 985, '코루틴이 다음 중단 지점에 도달할 때 CancellationException이 던져지며 종료됨을 설명', 'SUPPLEMENTARY', 4),
(5317, 985, '취소 중 정리 작업에서 suspend 함수가 필요하면 withContext(NonCancellable)로 감쌈을 언급', 'SUPPLEMENTARY', 5);
