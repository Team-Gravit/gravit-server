-- Unit: Swift Concurrency (Unit ID: 225)
-- Chapter: Swift (Chapter ID: 22)
-- Topic: SWIFT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-swift-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(1121, 'SWIFT', 225, 'HARD', true,
 '여러 URL을 병렬로 다운로드할 때 반복문에서 Task {}를 여러 개 만드는 대신 TaskGroup을 쓰는 이유는 무엇이고, 사용자가 화면을 떠나 작업을 취소했을 때 실제로 작업이 멈추게 하려면 작업 코드에서 무엇을 해야 하나요?',
 '반복문에서 Task {}를 여러 개 만들면 모두 비구조적 작업이 되어 생성한 스코프와 수명이 묶이지 않습니다. 그래서 부모가 취소되어도 취소가 전파되지 않고, 부모가 죽어도 살아남으며, 오류도 사라집니다. 반면 TaskGroup은 구조적 동시성 도구라서 자식 작업이 부모 스코프를 벗어나 살아남을 수 없고, 그룹 스코프가 끝나는 시점에는 모든 자식 작업이 완료 상태임이 보장됩니다. 부모의 취소는 자식으로 전파되고, 자식 하나가 throw하면 나머지 자식이 취소된 뒤 그룹이 오류를 던집니다. 개별 실패를 허용하고 싶다면 자식 안에서 오류를 잡아 Result로 반환하면 됩니다. 다만 취소가 전파된다고 해서 작업이 곧바로 멈추는 것은 아닙니다. Swift의 취소는 협력적 취소라서 cancel()은 작업을 강제로 멈추지 않고 취소 플래그만 세웁니다. 따라서 작업 코드가 Task.isCancelled를 확인하거나 try Task.checkCancellation()으로 CancellationError를 던져 스스로 멈춰야 합니다. 긴 루프에서는 주기적으로 취소를 확인하고, 취소 시 정리 작업은 withTaskCancellationHandler로 등록합니다. Task.sleep이나 URLSession의 async API 같은 표준 API는 취소를 감지해 오류를 던집니다.'),
(1122, 'SWIFT', 225, 'NORMAL', true,
 'Swift Concurrency에서 Task {}와 Task.detached {}의 차이는 무엇인가요?',
 '가장 큰 차이는 상속 여부입니다. Task {}는 현재 액터 컨텍스트를 상속하기 때문에 @MainActor 안에서 만들면 메인에서 실행되고, 우선순위와 로컬 값도 상속합니다. 반면 Task.detached {}는 액터 컨텍스트, 우선순위, 로컬 값을 모두 상속하지 않아 필요하면 명시해야 합니다. 용도도 달라서 Task {}는 버튼 탭 같은 동기 컨텍스트에서 비동기로 진입할 때 쓰고, Task.detached는 현재 컨텍스트와 무관한 백그라운드 작업에 드물게 씁니다. 공통점은 둘 다 비구조적 작업이라 취소를 직접 관리해야 한다는 것입니다. 생성한 스코프와 수명이 묶이지 않고 부모의 취소도 전파되지 않으므로, Task<Success, Failure> 핸들을 보관했다가 task.cancel()로 직접 취소해야 합니다. 누군가가 반드시 취소를 책임져야 누수와 낭비가 생기지 않습니다.'),
(1123, 'SWIFT', 225, 'NORMAL', true,
 '여러 비동기 작업을 병렬로 실행할 때 async let과 TaskGroup 중 무엇을 쓸지 어떤 기준으로 선택하나요?',
 '둘 다 구조적 동시성 도구이고, 선택 기준은 병렬로 실행할 작업의 개수입니다. 사용자 정보, 공지, 배너처럼 병렬로 실행할 작업의 개수가 컴파일 시점에 정해져 있으면 async let을 씁니다. async let은 선언 시점에 자식 작업이 바로 시작되고 await에서 결과를 모으며, 셋 중 하나가 throw하면 나머지는 자동으로 취소됩니다. 반대로 URL 배열을 다운로드하는 것처럼 자식 작업 수가 런타임에 정해지면 TaskGroup을 씁니다. addTask로 자식 작업을 추가하고 for try await로 결과를 수집하는데, 결과는 완료 순서대로 도착하므로 순서가 필요하면 인덱스나 키를 함께 반환해야 합니다.'),
(1124, 'SWIFT', 225, 'EASY', true,
 'Swift Concurrency에서 await에 도달하면 실행 중이던 스레드에는 어떤 일이 일어나는지 설명해 주세요.',
 'async 함수는 중단 지점을 가질 수 있는 함수이고, await는 여기서 중단될 수 있음을 표시합니다. await에 도달하면 지역 변수 같은 현재 함수의 상태가 힙의 비동기 프레임에 저장되고 스레드는 반납됩니다. 즉 await는 스레드를 블로킹하지 않고, 반납된 스레드는 다른 작업이 사용합니다. 이후 결과가 준비되면 같은 스레드가 아닐 수도 있는 풀의 스레드에서 이어서 실행됩니다. 런타임은 CPU 코어 수만큼의 스레드로 구성된 협력적 스레드 풀을 사용하기 때문에, 그 스레드 안에서 sleep이나 세마포어 대기 같은 블로킹을 하면 안 됩니다.'),
(1125, 'SWIFT', 225, 'EASY', true,
 '기존 콜백 기반 API를 async 함수로 바꾸려면 어떻게 해야 하나요?',
 'withCheckedContinuation 계열 함수로 콜백 API를 async 함수로 감쌀 수 있습니다. 오류가 있는 API라면 withCheckedThrowingContinuation을 쓰고, 콜백 안에서 오류가 오면 continuation.resume(throwing:)으로, 성공 값이 오면 continuation.resume(returning:)으로 결과를 전달합니다. 이때 콜백은 반드시 resume을 정확히 한 번 호출해야 합니다. Checked 버전은 이 규칙을 위반하면 런타임에 경고나 크래시로 알려 줍니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1121
(6009, 1121, '비구조적 Task는 부모가 취소되어도 취소가 전파되지 않음을 언급', 'ESSENTIAL', 1),
(6010, 1121, 'TaskGroup은 스코프 종료 시점에 모든 자식 작업이 완료 상태임이 보장된다고 언급', 'ESSENTIAL', 2),
(6011, 1121, 'cancel()은 작업을 강제로 멈추지 않고 취소 플래그만 세운다고 설명', 'ESSENTIAL', 3),
(6012, 1121, 'Task.isCancelled·Task.checkCancellation 중 최소 1개로 작업이 스스로 취소를 확인해야 함을 언급', 'ESSENTIAL', 4),
(6013, 1121, 'TaskGroup에서 자식 하나가 throw하면 나머지 자식이 취소되고 그룹이 오류를 던짐을 언급', 'SUPPLEMENTARY', 5),
(6014, 1121, '개별 실패를 허용하려면 자식 안에서 오류를 잡아 Result로 반환함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1122
(6015, 1122, 'Task {}는 액터 컨텍스트를 상속하고 Task.detached는 상속하지 않음을 언급', 'ESSENTIAL', 1),
(6016, 1122, 'Task {}는 우선순위를 상속하고 Task.detached는 상속하지 않음을 언급', 'ESSENTIAL', 2),
(6017, 1122, 'Task {}와 Task.detached 모두 취소를 직접 관리해야 함을 언급', 'ESSENTIAL', 3),
(6018, 1122, 'Task {}는 버튼 탭 같은 동기 컨텍스트에서 비동기로 진입할 때 쓴다고 언급', 'SUPPLEMENTARY', 4),
(6019, 1122, '@MainActor 안에서 만든 Task {}는 메인에서 실행됨을 언급', 'SUPPLEMENTARY', 5),
(6020, 1122, '핸들(Task<Success, Failure>)을 보관했다가 task.cancel()로 취소함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1123
(6021, 1123, '병렬 작업 개수가 컴파일 시점에 정해져 있으면 async let을 쓴다고 언급', 'ESSENTIAL', 1),
(6022, 1123, '자식 작업 수가 런타임에 정해지면 TaskGroup을 쓴다고 언급', 'ESSENTIAL', 2),
(6023, 1123, 'async let은 선언 시점에 자식 작업이 바로 시작되고 await에서 결과를 모은다고 설명', 'SUPPLEMENTARY', 3),
(6024, 1123, 'TaskGroup 결과는 완료 순서대로 도착해 순서가 필요하면 인덱스나 키를 함께 반환함을 언급', 'SUPPLEMENTARY', 4),
(6025, 1123, 'async let 중 하나가 throw하면 나머지 자식 작업이 자동 취소됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1124
(6026, 1124, 'await에서 현재 함수의 상태가 저장된다고 언급', 'ESSENTIAL', 1),
(6027, 1124, 'await는 스레드를 블로킹하지 않고 반납해 다른 작업이 쓰게 한다고 언급', 'ESSENTIAL', 2),
(6028, 1124, '재개 시 같은 스레드가 아닐 수도 있는 풀의 스레드에서 이어서 실행됨을 언급', 'ESSENTIAL', 3),
(6029, 1124, 'await 시 함수 상태가 힙의 비동기 프레임에 저장됨을 언급', 'SUPPLEMENTARY', 4),
(6030, 1124, '협력적 스레드 풀이 CPU 코어 수만큼의 스레드로 구성됨을 언급', 'SUPPLEMENTARY', 5),
(6031, 1124, '협력적 스레드 풀에서 sleep·세마포어 대기 같은 블로킹을 하면 안 된다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1125
(6032, 1125, 'withCheckedContinuation 계열로 콜백 API를 async 함수로 감쌀 수 있음을 언급', 'ESSENTIAL', 1),
(6033, 1125, '콜백에서 continuation의 resume을 정확히 한 번 호출해야 함을 언급', 'ESSENTIAL', 2),
(6034, 1125, 'Checked 버전은 resume 규칙 위반을 런타임에 알려 준다고 언급', 'SUPPLEMENTARY', 3),
(6035, 1125, 'resume(throwing:)·resume(returning:) 중 최소 1개로 콜백 결과를 전달한다고 언급', 'SUPPLEMENTARY', 4);
