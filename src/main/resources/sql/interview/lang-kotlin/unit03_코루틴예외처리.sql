-- Unit: 코루틴 예외 처리 (Unit ID: 198)
-- Chapter: Kotlin (Chapter ID: 19)
-- Topic: KOTLIN
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-kotlin-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(986, 'KOTLIN', 198, 'HARD', true,
 '서버 컴포넌트처럼 오래 사는 CoroutineScope에서 코루틴 하나가 예외로 실패한 뒤로 새로 launch한 코루틴이 전혀 실행되지 않는 문제가 생겼습니다. 원인과 올바른 스코프 구성을 설명하고, 흔한 수정 시도인 launch의 인자로 SupervisorJob을 넘기는 방식이 왜 효과가 없는지도 말씀해 주세요.',
 '원인은 예외 전파의 기본 규칙입니다. 자식 코루틴에서 잡히지 않은 예외가 발생하면 부모를 취소하고, 부모는 나머지 형제 자식을 모두 취소합니다. 일반 Job으로 만든 스코프는 이렇게 자식 하나의 실패로 스코프 자체가 Cancelled 상태가 되어, 이후 launch는 즉시 취소되고 더는 새 코루틴을 실행할 수 없습니다. 오래 사는 스코프가 이유 없이 죽어 있는 버그의 원인은 대부분 이것입니다. 해결하려면 스코프를 만들 때 컨텍스트에 SupervisorJob을 넣어 CoroutineScope(SupervisorJob() + Dispatchers.Default) 형태로 구성합니다. SupervisorJob은 자식 → 부모 방향의 실패 보고를 차단하므로 한 자식이 실패해도 다른 자식과 스코프는 계속 살아 있습니다. 여기에 CoroutineExceptionHandler를 함께 두면 잡히지 않은 예외가 로깅됩니다. 핸들러가 없는 루트 코루틴에서 예외가 나면 JVM에서는 Thread.uncaughtExceptionHandler로, Android에서는 앱 크래시로 이어집니다. 반면 scope.launch(SupervisorJob())처럼 launch의 인자로 SupervisorJob을 넘기면, 감독 대상은 그 launch의 직접 자식이 아니라 launch 자체가 됩니다. 그래서 그 안에서 시작한 자식의 예외는 여전히 형제를 취소하므로 감독 효과가 없습니다. 오히려 scope와 launch 사이의 부모-자식 관계가 끊어져 구조화된 동시성이 깨집니다. 감독이 필요하면 스코프 생성 시 SupervisorJob을 넣거나 supervisorScope를 사용해야 합니다.'),
(987, 'KOTLIN', 198, 'NORMAL', true,
 '코루틴 빌더 launch와 async는 예외를 드러내는 방식이 어떻게 다른가요? 또 async의 예외는 await()를 try/catch로 감싸기만 하면 안전하게 처리되는지 함께 설명해 주세요.',
 'launch는 예외가 발생하는 즉시 부모로 전파하므로 try/catch를 코루틴 본문 안에 두어야 합니다. async는 예외를 await()를 호출할 때 호출자에게 던지므로 await()를 감싸는 곳에서 잡습니다. 다만 async가 루트 코루틴이면 예외가 await 전까지 Deferred에 보관되어 CoroutineExceptionHandler로 가지 않습니다. 그런데 ''async의 예외는 await에서 잡으면 된다''는 설명은 절반만 맞습니다. async가 일반 Job의 자식이면 예외는 await 전에도 즉시 부모로 전파되어 부모를 취소합니다. 그래서 await를 try/catch로 감싸 예외 자체는 잡히더라도 부모 launch가 이미 취소되어 이후 코드에 도달하지 못합니다. await에서 안전하게 잡으려면 async를 supervisorScope 또는 SupervisorJob 아래에 두어 실패를 격리해야 합니다.'),
(988, 'KOTLIN', 198, 'NORMAL', true,
 '여러 작업을 async로 병렬 실행할 때 coroutineScope와 supervisorScope 중 무엇을 사용할지 어떤 기준으로 선택하시나요?',
 '여러 병렬 작업 중 하나라도 실패하면 전체가 실패해야 하는 경우에는 coroutineScope와 async를 씁니다. 자식이 실패하면 부모를 취소하고 형제도 모두 취소하는 기본 전파 규칙이 원하는 동작과 그대로 일치하기 때문입니다. 반대로 병렬 작업을 서로 독립적으로 실패시키고 싶으면 supervisorScope와 async를 씁니다. supervisorScope는 coroutineScope의 감독 버전으로, 블록 안에서 시작된 직접 자식끼리 실패를 격리하므로 한 async가 실패해도 다른 async에 영향이 없습니다. 이때 각 async의 await를 개별 try나 runCatching으로 감싸면 실패한 작업은 제외하고 부분 결과를 수집할 수 있습니다. 예를 들어 홈 화면의 배너는 실패해도 null로 두고, 핵심 데이터인 피드는 실패 시 그대로 던지는 식입니다. 참고로 감독은 자식 → 부모 방향의 실패 전파만 차단할 뿐, 부모 → 자식 방향의 취소는 그대로 동작합니다.'),
(989, 'KOTLIN', 198, 'EASY', true,
 '코루틴 안에서 catch (e: Exception)으로 예외를 넓게 잡으면 어떤 문제가 생기며, 어떻게 작성해야 하나요?',
 'catch (e: Exception)은 코루틴 취소에 쓰이는 CancellationException까지 잡아 버립니다. 코루틴 취소는 중단 지점에서 CancellationException을 던지는 방식으로 구현되는데, 이 취소 신호가 삼켜지면 코루틴은 취소된 줄 모르고 계속 실행됩니다. 예를 들어 폴링 루프가 멈추지 않는 식으로 취소가 무력화되고 구조화된 동시성이 깨집니다. 따라서 catch (e: CancellationException) { throw e }처럼 취소 예외는 먼저 잡아 반드시 다시 던지고, 그 뒤에 일반 Exception을 처리해야 합니다. 배경을 덧붙이면, 코루틴 라이브러리는 CancellationException을 실패가 아니라 정상 종료 신호로 취급하므로 부모로 전파되지 않고 형제를 취소하지 않으며 CoroutineExceptionHandler에도 전달되지 않습니다. runCatching도 같은 이유로 CancellationException까지 잡아 버리므로, 결과의 예외가 CancellationException이면 다시 던지는 확장 함수를 만들어 쓰는 것이 안전합니다. withTimeout이 던지는 TimeoutCancellationException도 CancellationException의 하위 타입이라 같은 규칙을 따릅니다.'),
(990, 'KOTLIN', 198, 'EASY', true,
 'CoroutineExceptionHandler는 어떤 역할을 하며, 어느 위치에 설정해야 실제로 동작하나요?',
 'CoroutineExceptionHandler는 잡히지 않은 예외가 최종적으로 도달하는 곳입니다. 일반 try/catch처럼 예외를 복구하는 용도가 아니라 로깅, 리포팅, 애플리케이션 종료 판단 같은 마지막 처리를 위한 장치입니다. 핸들러가 동작하는 위치는 스코프에서 직접 launch한 루트 코루틴과 SupervisorJob·supervisorScope의 직접 자식입니다. 루트는 더 이상 전파할 부모가 없어 핸들러가 최종 처리자가 되고, 감독 Job은 예외를 부모로 올리지 않고 자식이 스스로 처리하게 하기 때문입니다. 반면 일반 launch의 자식 코루틴에 붙인 핸들러는 예외가 부모로 전파되므로 사용되지 않고, async 루트 코루틴은 예외를 Deferred에 보관해 await()에서 던지므로 무시되며, coroutineScope 내부에서는 coroutineScope가 예외를 다시 던지므로 호출자가 잡아야 합니다. 그래서 오래 사는 스코프에는 SupervisorJob과 핸들러를 함께 두는 것이 기본 구성입니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 986
(5318, 986, '일반 Job 스코프는 자식 하나의 실패로 스코프 자체가 취소되어 새 코루틴을 실행할 수 없음을 설명', 'ESSENTIAL', 1),
(5319, 986, '스코프 생성 시 컨텍스트에 SupervisorJob을 넣는 구성을 해결책으로 제시', 'ESSENTIAL', 2),
(5320, 986, 'launch(SupervisorJob())의 감독 대상은 launch의 직접 자식이 아닌 launch 자체라 감독 효과가 없음을 설명', 'ESSENTIAL', 3),
(5321, 986, '스코프에 CoroutineExceptionHandler를 두어 잡히지 않은 예외를 로깅하는 구성을 언급', 'SUPPLEMENTARY', 4),
(5322, 986, 'launch의 인자로 SupervisorJob을 넘기면 scope와의 부모-자식 관계가 끊겨 구조화된 동시성이 깨짐을 언급', 'SUPPLEMENTARY', 5),
(5323, 986, '핸들러가 없는 루트 코루틴의 예외는 Android에서 앱 크래시로 이어짐을 언급', 'SUPPLEMENTARY', 6),

-- 질문 987
(5324, 987, 'launch는 예외가 발생하는 즉시 부모로 전파함을 언급', 'ESSENTIAL', 1),
(5325, 987, 'async는 await() 호출 시점에 호출자에게 예외를 던짐을 언급', 'ESSENTIAL', 2),
(5326, 987, '일반 Job의 자식인 async는 await 전에도 부모를 취소함을 설명', 'ESSENTIAL', 3),
(5327, 987, 'await에서 안전하게 잡으려면 supervisorScope 또는 SupervisorJob 아래에 두어야 함을 제시', 'ESSENTIAL', 4),
(5328, 987, 'async 루트 코루틴의 예외는 await 전까지 Deferred에 보관되어 핸들러로 가지 않음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 988
(5329, 988, '하나라도 실패하면 전체를 실패시켜야 할 때 coroutineScope를 사용함을 제시', 'ESSENTIAL', 1),
(5330, 988, '병렬 작업을 서로 독립적으로 실패시키고 싶을 때 supervisorScope를 사용함을 제시', 'ESSENTIAL', 2),
(5331, 988, 'supervisorScope는 블록 안에서 시작된 직접 자식끼리 실패를 격리함을 설명', 'ESSENTIAL', 3),
(5332, 988, 'supervisorScope에서 async마다 개별 try로 감싸 부분 결과를 수집할 수 있음을 언급', 'SUPPLEMENTARY', 4),
(5333, 988, '감독은 자식에서 부모로의 실패 전파만 차단하고 부모에서 자식으로의 취소는 유지함을 설명', 'SUPPLEMENTARY', 5),

-- 질문 989
(5334, 989, 'catch (e: Exception)이 CancellationException까지 잡아 취소가 무력화됨을 설명', 'ESSENTIAL', 1),
(5335, 989, 'CancellationException은 잡더라도 반드시 다시 던져야 함을 명시', 'ESSENTIAL', 2),
(5336, 989, '코루틴 라이브러리가 CancellationException을 실패가 아닌 정상 종료 신호로 취급함을 언급', 'SUPPLEMENTARY', 3),
(5337, 989, 'runCatching도 CancellationException까지 잡아 버림을 언급', 'SUPPLEMENTARY', 4),
(5338, 989, 'withTimeout의 TimeoutCancellationException도 CancellationException 하위 타입임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 990
(5339, 990, 'CoroutineExceptionHandler는 잡히지 않은 예외가 최종적으로 도달하는 곳임을 언급', 'ESSENTIAL', 1),
(5340, 990, '핸들러의 용도가 예외 복구가 아닌 로깅·리포팅 같은 마지막 처리임을 명시', 'ESSENTIAL', 2),
(5341, 990, '루트 코루틴·감독 스코프의 직접 자식 중 최소 1개를 핸들러가 동작하는 위치로 제시', 'ESSENTIAL', 3),
(5342, 990, '일반 launch의 자식 코루틴에 붙인 핸들러는 예외가 부모로 전파되어 무시됨을 설명', 'SUPPLEMENTARY', 4),
(5343, 990, 'coroutineScope 내부에서는 예외를 다시 던지므로 핸들러가 무시됨을 언급', 'SUPPLEMENTARY', 5);
