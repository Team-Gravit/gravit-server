-- Unit: Compose 부수효과 API (Unit ID: 171)
-- Chapter: Android (Chapter ID: 16)
-- Topic: COMPOSE
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-android-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(851, 'COMPOSE', 171, 'HARD', true,
 'LaunchedEffect나 DisposableEffect 안에서 파라미터로 받은 람다(예: onTimeout, onResume 콜백)를 호출해야 할 때, 그 람다를 효과의 key에 넣는 경우와 넣지 않는 경우 각각 어떤 문제가 생기고 어떻게 해결하나요?',
 'LaunchedEffect와 DisposableEffect는 key가 바뀌면 진행 중인 효과를 취소하거나 onDispose를 실행한 뒤 다시 시작합니다. 그런데 람다처럼 매번 새로 만들어지는 객체를 key에 넣으면 재구성마다 key가 바뀐 것으로 보여 효과의 취소·재시작이 반복됩니다. 예를 들어 3초 타이머가 재구성될 때마다 처음부터 다시 시작되는 식입니다. 반대로 람다를 key에 넣지 않으면 효과가 시작될 때 캡처한 오래된 람다를 계속 사용하게 되어, 나중에 바뀐 최신 콜백이 호출되지 않는 문제가 생깁니다. 이 딜레마는 rememberUpdatedState로 해결합니다. val currentOnTimeout by rememberUpdatedState(onTimeout)처럼 감싸 두면 LaunchedEffect(Unit) 안의 타이머는 재시작되지 않으면서도 호출 시점에는 최신 람다를 실행합니다. DisposableEffect의 LifecycleEventObserver에서 onResume을 호출할 때도 같은 방식을 씁니다. key 자체는 ''이 값이 바뀌면 작업을 다시 해야 하는가''라는 기준으로 정해야 하며, 예를 들어 lifecycleOwner처럼 실제로 바뀔 수 있고 바뀌면 재등록이 필요한 객체는 key에 넣어야 합니다. 이를 누락하면 옛 객체에 옵저버가 등록된 채 남게 됩니다.'),
(852, 'COMPOSE', 171, 'NORMAL', true,
 'Compose에서 LaunchedEffect와 DisposableEffect는 어떤 차이가 있고, 각각 어떤 작업에 사용하나요?',
 '두 API 모두 컴포지션에 진입할 때와 key가 바뀔 때 실행되고, 컴포저블이 이탈하거나 key가 바뀔 때 정리된다는 점은 같습니다. 가장 큰 차이는 코루틴 여부입니다. LaunchedEffect는 컴포지션에 묶인 코루틴을 시작하므로 내부에서 suspend 함수를 호출할 수 있지만, DisposableEffect는 코루틴 스코프가 아니므로 suspend 함수를 호출할 수 없습니다. 정리 방식도 다릅니다. LaunchedEffect는 이탈 시나 key 변경 시 실행 중인 코루틴이 취소되고, DisposableEffect는 블록 마지막에 반환한 onDispose 블록이 실행되어 정리 작업을 수행합니다. onDispose를 빠뜨리면 컴파일 오류가 나므로 정리 누락을 구조적으로 막아 줍니다. 그래서 LaunchedEffect는 suspend 함수 호출, 스낵바 표시, 특정 값 변경에 반응하는 일회성 작업에 쓰고, DisposableEffect는 LifecycleObserver 등록, 센서 리스너, 뒤로 가기 콜백처럼 리스너·옵저버의 등록과 해제가 짝을 이루는 작업에 사용합니다.'),
(853, 'COMPOSE', 171, 'NORMAL', true,
 'LaunchedEffect와 rememberCoroutineScope는 둘 다 코루틴을 시작할 수 있는데, 각각 어떤 상황에서 사용하나요?',
 'LaunchedEffect는 컴포지션에 진입할 때와 key가 바뀔 때 코루틴을 시작하는 API로, 특정 값의 변경에 반응하는 작업에 적합합니다. 다만 LaunchedEffect는 컴포저블 본문에서만 호출할 수 있어서, 버튼 클릭 같은 콜백 안에서는 사용할 수 없습니다. 이렇게 사용자 이벤트로 시작하는 작업은 rememberCoroutineScope()로 얻은 스코프에서 scope.launch로 코루틴을 시작합니다. 예를 들어 FAB를 누르면 listState.animateScrollToItem(0)을 호출하는 경우입니다. 이 스코프는 컴포저블이 이탈하면 함께 취소되므로 죽은 화면을 갱신하는 문제는 없지만, 반대로 화면이 사라져도 끝까지 완료되어야 하는 저장·업로드·결제 요청은 UI 스코프가 아니라 viewModelScope나 WorkManager에서 실행해야 합니다.'),
(854, 'COMPOSE', 171, 'EASY', true,
 'Compose의 SideEffect는 언제 실행되며, 어떤 용도로 사용하나요?',
 'SideEffect는 컴포지션이 성공적으로 적용된 직후, 매 재구성마다 실행되는 부수효과 API이며 취소나 정리 개념이 없습니다. Compose가 관리하지 않는 외부 객체, 예를 들어 분석 SDK나 시스템 UI 컨트롤러에 현재 컴포지션 상태를 반영할 때 사용합니다. 재구성이 확정될 때마다 analytics.setUserProperty로 최신 사용자 정보를 동기화하는 식입니다. 재구성이 중단(취소)되면 실행되지 않으므로 실제로 화면에 반영된 상태만 외부에 전달된다는 장점이 있습니다. 대신 매번 실행되는 것이 목적이므로 가볍고 멱등한 작업만 넣어야 하고, 네트워크 요청처럼 무겁거나 한 번만 해야 하는 작업은 넣으면 안 됩니다.'),
(855, 'COMPOSE', 171, 'EASY', true,
 '컴포저블 함수 본문에 네트워크 호출이나 리스너 등록 같은 부수효과를 직접 작성하면 안 되는 이유는 무엇인가요?',
 '부수효과는 API 호출, 스낵바 표시, 콜백 등록, 전역 변수 변경처럼 컴포저블 함수의 범위 밖에서 관찰 가능한 상태 변화를 말합니다. 컴포저블은 재구성마다 다시 실행되고 실행 횟수와 순서도 보장되지 않으므로, 본문에 부수효과를 쓰면 재구성 횟수만큼 반복 실행됩니다. 또한 화면 이탈이나 조건부 UI 제거로 컴포지션이 취소·폐기될 수 있는데, 정리 없이 시작한 작업은 누수나 죽은 화면 갱신으로 이어집니다. 그래서 부수효과는 컴포지션에 진입·이탈하는 시점과 특정 키의 변경 시점에 묶어 실행해야 하며, Compose는 이를 위해 LaunchedEffect, DisposableEffect, SideEffect 같은 API를 제공합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 851
(4586, 851, '람다처럼 매번 새로 만들어지는 객체를 key에 넣으면 재구성마다 취소·재시작이 반복됨을 설명', 'ESSENTIAL', 1),
(4587, 851, '람다를 key에 넣지 않으면 효과가 오래된 값을 캡처하게 됨을 언급', 'ESSENTIAL', 2),
(4588, 851, 'rememberUpdatedState로 감싸 효과 재시작 없이 최신 람다를 참조하는 해결책을 제시', 'ESSENTIAL', 3),
(4589, 851, 'key는 ''이 값이 바뀌면 작업을 다시 해야 하는가''를 기준으로 정함을 언급', 'SUPPLEMENTARY', 4),
(4590, 851, 'DisposableEffect에서 lifecycleOwner를 key에서 누락하면 옛 객체에 등록된 채 남음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 852
(4591, 852, 'LaunchedEffect는 내부에서 suspend 함수 호출이 가능하지만 DisposableEffect는 불가능하다는 차이를 설명', 'ESSENTIAL', 1),
(4592, 852, '정리 방식이 LaunchedEffect는 코루틴 취소, DisposableEffect는 onDispose 실행이라는 차이를 설명', 'ESSENTIAL', 2),
(4593, 852, '스낵바 표시·suspend 함수 호출·특정 값 변경에 반응하는 작업 중 최소 1개를 LaunchedEffect 용도로 제시', 'ESSENTIAL', 3),
(4594, 852, 'DisposableEffect의 용도로 리스너·옵저버처럼 등록과 해제가 짝을 이루는 작업을 제시', 'ESSENTIAL', 4),
(4595, 852, 'onDispose를 빠뜨리면 컴파일 오류가 나서 정리 누락을 구조적으로 막아 줌을 언급', 'SUPPLEMENTARY', 5),

-- 질문 853
(4596, 853, 'LaunchedEffect는 컴포저블 본문에서만 호출할 수 있음을 언급', 'ESSENTIAL', 1),
(4597, 853, '버튼 클릭 같은 콜백 안에서 코루틴을 시작할 때 rememberCoroutineScope를 사용함을 설명', 'ESSENTIAL', 2),
(4598, 853, 'LaunchedEffect는 진입 시와 key 변경 시에 코루틴을 시작함을 설명', 'ESSENTIAL', 3),
(4599, 853, 'rememberCoroutineScope의 스코프는 컴포저블 이탈 시 함께 취소됨을 언급', 'SUPPLEMENTARY', 4),
(4600, 853, '화면이 사라져도 완료돼야 하는 저장·업로드는 viewModelScope나 WorkManager에서 실행해야 함을 설명', 'SUPPLEMENTARY', 5),

-- 질문 854
(4601, 854, 'SideEffect는 컴포지션이 성공적으로 적용된 직후 매 재구성마다 실행됨을 설명', 'ESSENTIAL', 1),
(4602, 854, 'Compose가 관리하지 않는 외부 객체에 현재 컴포지션 상태를 반영하는 용도임을 언급', 'ESSENTIAL', 2),
(4603, 854, '재구성이 취소되면 SideEffect가 실행되지 않아 실제 반영된 상태만 전달됨을 언급', 'SUPPLEMENTARY', 3),
(4604, 854, '네트워크 요청처럼 무겁거나 한 번만 해야 하는 작업을 SideEffect에 넣으면 안 됨을 언급', 'SUPPLEMENTARY', 4),

-- 질문 855
(4605, 855, '컴포저블은 재구성마다 다시 실행되어 본문의 부수효과가 재구성 횟수만큼 반복됨을 설명', 'ESSENTIAL', 1),
(4606, 855, '컴포지션이 취소·폐기될 때 정리 없이 시작한 작업이 누수나 죽은 화면 갱신으로 이어짐을 설명', 'ESSENTIAL', 2),
(4607, 855, '부수효과를 컴포저블 함수 범위 밖에서 관찰 가능한 상태 변화로 설명', 'SUPPLEMENTARY', 3),
(4608, 855, '부수효과를 컴포지션 진입·이탈 시점이나 키 변경 시점에 묶어 실행하는 해결책을 제시', 'SUPPLEMENTARY', 4),
(4609, 855, 'LaunchedEffect·DisposableEffect·SideEffect 중 최소 1개를 부수효과 API로 제시', 'SUPPLEMENTARY', 5);
