-- Unit: 생명주기 인식 데이터 수집 (Unit ID: 172)
-- Chapter: Android (Chapter ID: 16)
-- Topic: COMPOSE
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-android-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(856, 'COMPOSE', 172, 'HARD', true,
 '스낵바 표시나 화면 이동 같은 일회성 이벤트를 ViewModel에서 UI로 전달할 때 SharedFlow, Channel, UI 상태 모델링 방식은 각각 어떤 트레이드오프가 있고, 어떤 방식을 선택하시겠어요?',
 'SharedFlow는 기본 설정(replay = 0)에서 구독자가 없으면 emit한 값을 버리기 때문에, 화면이 백그라운드에 있을 때 발생한 이벤트는 사용자가 돌아와도 받지 못해 유실될 수 있습니다. 이를 막으려고 replay를 늘리면 이번에는 재구독할 때 이미 처리한 이벤트를 다시 받아 중복 처리됩니다. Channel은 구독자가 없어도 버퍼에 보관하므로 유실은 줄지만, 여러 구독자에게 방송할 수 없고 receiveAsFlow()를 쓰면 취소 시점에 값이 사라질 수 있습니다. 그래서 현재 권장 방식은 이벤트를 UI 상태의 일부로 모델링하는 것입니다. 예를 들어 UiState에 userMessage: String? 같은 필드를 두고, UI가 스낵바를 표시한 뒤 ViewModel에 소비했다고 알리면 ViewModel이 해당 값을 null로 비웁니다. 상태에 남아 있으므로 유실되지 않고, 소비 후 비우므로 중복되지 않으며 프로세스 종료에도 대응할 수 있어 저는 이 방식을 선택하겠습니다. 다만 어떤 방식이든 트레이드오프가 있으므로 상황에 맞게 설명할 수 있어야 합니다.'),
(857, 'COMPOSE', 172, 'NORMAL', true,
 'StateFlow와 SharedFlow의 차이는 무엇이고, 각각 어떤 용도에 적합한가요?',
 'StateFlow는 상태를 보관하는 Flow로 초기값이 필수이고 항상 현재 값을 가지고 있습니다. 새 구독자는 최신 값 1개를 즉시 받고, equals로 같은 값이면 방출을 생략하며 중간 값은 건너뛰고 최신 값만 유지합니다. 반면 SharedFlow는 이벤트를 방송하는 Flow로 초기값이 없고 값을 보관하지 않을 수 있습니다. 새 구독자는 replay 개수만큼만 받는데 기본값이 0이라 아무것도 받지 못하고, 중복 값도 모두 방출하며 버퍼는 extraBufferCapacity와 onBufferOverflow로 조절합니다. 그래서 StateFlow는 화면 UI 상태, 로딩·에러 플래그, 목록 같은 상태에 적합하고, SharedFlow는 구독자 여러 명에게 같은 이벤트를 방송할 때 적합합니다. StateFlow는 SharedFlow(replay = 1)에 중복 제거와 초기값이 더해진 특수형으로 볼 수 있습니다.'),
(858, 'COMPOSE', 172, 'NORMAL', true,
 'View 시스템에서 Flow를 수집할 때 launchWhenStarted 대신 repeatOnLifecycle을 사용해야 하는 이유는 무엇인가요?',
 'repeatOnLifecycle(Lifecycle.State.STARTED)은 생명주기가 STARTED 이상이 될 때마다 블록을 새로 시작하고, STARTED 미만으로 떨어지면 블록을 취소합니다. 블록 안의 코루틴이 취소되므로 상위 Flow 수집도 함께 멈추고, WhileSubscribed와 결합하면 데이터 소스까지 정리됩니다. 반면 launchWhenStarted는 STARTED 미만에서 코루틴을 취소하는 것이 아니라 일시 중단만 합니다. 그래서 일시 중단 중에도 상위 Flow는 계속 값을 만들어 버퍼에 쌓이고, 리소스도 해제되지 않습니다. 이런 이유로 launchWhenStarted는 현재 지원 중단(deprecated) 상태이며 repeatOnLifecycle로 대체해야 합니다.'),
(859, 'COMPOSE', 172, 'EASY', true,
 'Activity나 Fragment에서 lifecycleScope.launch 안에서 Flow를 그대로 collect하면 어떤 문제가 생기는지 설명해 주세요.',
 'lifecycleScope.launch { flow.collect { } }로 수집을 시작하면 그 코루틴은 Activity가 파괴될 때까지 살아 있습니다. 그래서 홈 버튼으로 앱을 백그라운드에 보내 onStop이 호출되어도 수집이 계속되고, 화면에 보이지도 않는 UI를 갱신하며 위치나 DB 관찰 같은 상위 데이터 소스도 계속 동작해 배터리를 낭비합니다. Fragment의 경우 onDestroyView로 View가 파괴된 뒤 값이 도착하면 이미 사라진 View에 접근해 크래시가 날 수 있습니다. 따라서 수집 범위는 컴포넌트가 살아 있는 동안이 아니라 화면이 실제로 보이는 동안으로 좁혀야 합니다.'),
(860, 'COMPOSE', 172, 'EASY', true,
 'ViewModel에서 stateIn으로 StateFlow를 만들 때 SharingStarted.WhileSubscribed(5_000)를 지정하는 이유를 설명해 주세요.',
 'stateIn에 WhileSubscribed(5_000)를 지정하면 구독자가 0명이 된 뒤 바로 멈추지 않고 5초 동안 기다렸다가 상위 Flow 수집을 멈춥니다. 화면 회전처럼 구독이 해제된 뒤 즉시 재구독되는 경우에는 상위 스트림이 그대로 유지되고, 앱이 진짜 백그라운드에 들어가 구독자가 없는 상태가 계속될 때만 수집이 중단됩니다. 반면 Lazily는 첫 구독 후 영원히 유지되고, Eagerly는 즉시 시작해 영원히 유지되므로 화면이 없어도 상위 스트림이 계속 동작합니다. 그래서 대부분의 UI 상태에는 WhileSubscribed가 적합합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 856
(4610, 856, 'SharedFlow는 구독자가 없을 때(백그라운드) 발생한 이벤트가 유실될 수 있음을 언급', 'ESSENTIAL', 1),
(4611, 856, 'SharedFlow의 replay를 늘리면 재구독 시 이벤트가 중복 처리됨을 언급', 'ESSENTIAL', 2),
(4612, 856, 'Channel은 여러 구독자에게 이벤트를 방송할 수 없음을 한계로 언급', 'ESSENTIAL', 3),
(4613, 856, '이벤트를 UI 상태의 일부로 모델링해 UI가 소비한 뒤 비우는 방식을 대안으로 제시', 'ESSENTIAL', 4),
(4614, 856, 'Channel은 구독자가 없어도 버퍼에 보관해 유실이 줄어듦을 언급', 'SUPPLEMENTARY', 5),
(4615, 856, 'Channel을 receiveAsFlow()로 수집하면 취소 시점에 값이 사라질 수 있음을 언급', 'SUPPLEMENTARY', 6),
(4616, 856, '상태 기반 모델링은 프로세스 종료에도 대응 가능함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 857
(4617, 857, 'StateFlow는 초기값이 필수인 반면 SharedFlow는 초기값이 없음을 설명', 'ESSENTIAL', 1),
(4618, 857, '새 구독자가 StateFlow에서는 최신 값 1개를, SharedFlow에서는 replay 개수만큼 받는 차이를 설명', 'ESSENTIAL', 2),
(4619, 857, 'StateFlow는 UI 상태 보관, SharedFlow는 여러 구독자에게 이벤트 방송하는 용도로 구분', 'ESSENTIAL', 3),
(4620, 857, 'StateFlow는 equals로 같은 값이면 방출을 생략함을 언급', 'SUPPLEMENTARY', 4),
(4621, 857, 'StateFlow는 항상 현재 값을 보관하고 있음을 언급', 'SUPPLEMENTARY', 5),
(4622, 857, 'StateFlow를 SharedFlow(replay = 1)에 중복 제거와 초기값이 더해진 특수형으로 설명', 'SUPPLEMENTARY', 6),

-- 질문 858
(4623, 858, 'repeatOnLifecycle은 생명주기가 STARTED 미만으로 떨어지면 블록(코루틴)을 취소함을 언급', 'ESSENTIAL', 1),
(4624, 858, 'launchWhenStarted는 STARTED 미만에서 코루틴을 취소하지 않고 일시 중단만 함을 언급', 'ESSENTIAL', 2),
(4625, 858, 'launchWhenStarted의 일시 중단 중에도 상위 Flow가 계속 값을 만들어 냄을 설명', 'ESSENTIAL', 3),
(4626, 858, 'launchWhenStarted는 일시 중단 중에 리소스가 해제되지 않음을 언급', 'SUPPLEMENTARY', 4),
(4627, 858, 'repeatOnLifecycle은 STARTED 이상이 될 때마다 블록을 새로 시작함을 언급', 'SUPPLEMENTARY', 5),
(4628, 858, 'launchWhenStarted가 현재 지원 중단(deprecated) 상태임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 859
(4629, 859, 'lifecycleScope로 시작한 수집 코루틴은 Activity가 파괴될 때까지 살아 있음을 언급', 'ESSENTIAL', 1),
(4630, 859, '앱이 백그라운드로 가도(onStop) 수집이 계속되어 보이지 않는 UI를 갱신함을 언급', 'ESSENTIAL', 2),
(4631, 859, 'Fragment에서 View 파괴 후 값이 도착하면 사라진 View에 접근해 크래시가 날 수 있음을 언급', 'ESSENTIAL', 3),
(4632, 859, '위치·DB 관찰 같은 상위 데이터 소스도 백그라운드에서 계속 동작함을 언급', 'SUPPLEMENTARY', 4),
(4633, 859, '수집 범위를 화면이 실제로 보이는 동안으로 좁혀야 함을 명시', 'SUPPLEMENTARY', 5),

-- 질문 860
(4634, 860, '구독자가 0명이 된 뒤 5초 동안 기다렸다가 상위 Flow 수집을 멈춤을 설명', 'ESSENTIAL', 1),
(4635, 860, '화면 회전처럼 구독 해제 후 즉시 재구독되는 경우에는 상위 스트림이 유지됨을 언급', 'ESSENTIAL', 2),
(4636, 860, 'Lazily·Eagerly는 한 번 시작하면 상위 스트림이 영원히 유지됨을 언급', 'SUPPLEMENTARY', 3);
