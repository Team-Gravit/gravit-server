-- Unit: Flow (Unit ID: 199)
-- Chapter: Kotlin (Chapter ID: 19)
-- Topic: KOTLIN
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-kotlin-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(991, 'KOTLIN', 199, 'HARD', true,
 '하나의 네트워크 조회 결과를 여러 화면 구성 요소가 동시에 collect하고, 화면 회전처럼 구독이 잠깐 끊겼다 다시 이어지는 일이 잦은 상황입니다. cold Flow를 그대로 쓰면 어떤 문제가 생기고, 어떻게 바꾸며, 업스트림 시작·중지 전략을 선택할 때의 대가는 무엇인가요?',
 '일반 Flow는 cold 스트림이라 collect할 때마다 처음부터 새로 실행되고, 수집자마다 독립적으로 실행됩니다. 그래서 같은 cold Flow를 여러 곳에서 collect하면 네트워크 요청이 수집자 수만큼 반복됩니다. 하나의 결과를 여러 구독자가 공유하려면 shareIn이나 stateIn으로 hot 스트림으로 변환해야 합니다. 이 연산자들은 업스트림 cold Flow를 주어진 scope에서 한 번만 실행하고 그 방출을 여러 수집자에게 공유합니다. 이때 started 파라미터가 업스트림을 언제 시작하고 언제 멈출지 결정합니다. 화면 상태라면 SharingStarted.WhileSubscribed(timeout)이 적합한데, 첫 수집자가 등장할 때 시작하고 마지막 수집자가 떠난 뒤 timeout이 경과하면 업스트림을 중지합니다. 예를 들어 WhileSubscribed(5000)이면 5초 내에 재구독할 경우 업스트림이 유지되어 화면 회전 시 재요청을 막을 수 있습니다. 반면 Eagerly는 즉시 시작하고, Lazily는 첫 수집자 등장 시 시작하지만 둘 다 scope가 취소될 때까지 업스트림을 멈추지 않으므로, 항상 최신이어야 하는 전역 상태나 계속 유지해도 되는 경우에 맞습니다. 또한 stateIn은 StateFlow를 돌려주므로 새 수집자는 즉시 현재 값을 받습니다.'),
(992, 'KOTLIN', 199, 'NORMAL', true,
 'StateFlow와 SharedFlow는 어떻게 다르며, 각각 어떤 경우에 선택하나요?',
 '둘 다 hot 스트림이지만 설계 목적이 다릅니다. StateFlow는 MutableStateFlow(initial)로 만들며 항상 현재 값을 하나 보유하고 value로 동기 접근할 수 있습니다. 새 수집자는 즉시 현재 값을 받고 이후 변경을 계속 받습니다. 또 conflated라서 소비자가 느리면 최신 값만 전달하고, equals 기준으로 같은 값을 다시 설정하면 방출하지 않습니다. 반면 SharedFlow는 replay, extraBufferCapacity, onBufferOverflow 세 파라미터로 동작이 결정되는 이벤트 브로드캐스트용 스트림이고, replay 기본값이 0이라 수집자가 없을 때 emit된 값은 그냥 사라집니다. 사실 StateFlow는 SharedFlow(replay = 1, onBufferOverflow = DROP_OLDEST)에 중복 제거를 더한 특수형이라고 볼 수 있습니다. 그래서 현재 값을 보유해야 하는 UI 상태는 StateFlow로, 토스트나 화면 이동 같은 일회성 이벤트는 SharedFlow로 다루는 것이 기본 선택 기준입니다.'),
(993, 'KOTLIN', 199, 'NORMAL', true,
 'Flow에서 생산자와 소비자의 속도가 다를 때 쓰는 buffer, conflate, collectLatest는 각각 어떻게 다르게 동작하나요?',
 '기본 Flow는 생산과 소비가 같은 코루틴에서 순차 실행되기 때문에, 생산에 100ms, 소비에 300ms가 걸리면 값 하나에 400ms가 걸립니다. 버퍼링 연산자는 생산자와 소비자를 별도 코루틴으로 분리해 이 병목을 해소합니다. buffer(n)는 생산자를 분리하고 n개까지(기본 64) 버퍼에 쌓아 두며 값 유실이 없으므로, 모든 값을 처리해야 하지만 속도 차이가 있을 때 씁니다. conflate()는 소비자가 바쁘면 중간 값을 버리고 최신 값만 전달하므로 값 유실이 있고, 진행률이나 좌표처럼 최신 값만 의미 있을 때 적합합니다. collectLatest는 새 값이 오면 진행 중인 소비 블록을 취소하고 새 값으로 다시 시작하므로 역시 유실이 있으며, 검색어 입력 시 이전 검색을 취소하는 경우에 적합합니다. 정리하면 buffer는 전부 처리, conflate는 최신만, collectLatest는 진행 중 작업 취소입니다.'),
(994, 'KOTLIN', 199, 'EASY', true,
 'Kotlin의 Flow란 무엇이고, 값이 생산되어 소비되기까지 어떤 순서로 실행되는지 설명해 주세요.',
 'Flow는 코루틴 위에서 동작하는 비동기 데이터 스트림으로, suspend 함수가 값 하나를 돌려준다면 Flow는 여러 값을 시간에 걸쳐 돌려주는 suspend 스트림입니다. flow { emit(x) } 빌더로 생산자를 정의하고 map, filter 같은 중간 연산자를 연결한 뒤, collect, toList, first 같은 종단 연산자가 호출될 때 비로소 flow 블록이 실행됩니다. 실행은 기본적으로 순차적이어서, 값 하나가 생산되어 모든 연산자를 통과하고 소비된 뒤에야 다음 값이 생산됩니다. 각 단계가 같은 코루틴에서 순차 실행되는 것입니다. 또한 emit은 suspend 함수이므로 소비자가 느리면 생산자가 자동으로 대기하게 되어, 별도의 백프레셔 프로토콜 없이 suspend 자체가 역압 역할을 합니다.'),
(995, 'KOTLIN', 199, 'EASY', true,
 'Flow의 catch 연산자는 어떤 범위의 예외를 잡으며, 소비 로직에서 발생하는 예외까지 처리하려면 어떻게 구성하나요?',
 'catch 연산자는 업스트림, 즉 자기보다 위쪽에서 발생한 예외만 잡습니다. 그래서 collect 블록 안에서 발생한 예외는 catch가 잡지 못합니다. 소비 로직의 예외까지 처리하려면 소비 로직을 onEach로 올리고 그 아래 마지막에 catch를 두는 패턴을 씁니다. 이렇게 하면 onEach도 catch의 업스트림이 되어 예외가 catch에 도달합니다. 필요하면 retry(n)으로 조건에 맞는 예외가 발생했을 때 업스트림을 재실행할 수 있고, onCompletion은 정상 완료·예외·취소 모두에서 호출되며 cause로 이를 구분합니다. 마지막으로 launchIn(viewModelScope)을 쓰면 collect를 launch로 감싼 단축 표현으로 수집을 시작할 수 있습니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 991
(5344, 991, 'cold Flow는 collect마다 새로 실행되어 네트워크 요청이 수집자 수만큼 반복됨을 언급', 'ESSENTIAL', 1),
(5345, 991, 'stateIn 또는 shareIn으로 cold Flow를 hot으로 변환해 한 번의 실행을 여러 수집자가 공유함을 설명', 'ESSENTIAL', 2),
(5346, 991, 'WhileSubscribed(timeout)은 마지막 수집자가 떠난 뒤 timeout 경과 시 업스트림을 중지함을 설명', 'ESSENTIAL', 3),
(5347, 991, 'timeout 안에 재구독하면 업스트림이 유지되어 화면 회전 시 재요청을 막는다는 점을 언급', 'ESSENTIAL', 4),
(5348, 991, 'Eagerly·Lazily는 scope가 취소될 때까지 업스트림을 중지하지 않음을 언급', 'SUPPLEMENTARY', 5),
(5349, 991, 'stateIn으로 만든 StateFlow는 새 수집자에게 현재 값을 즉시 전달함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 992
(5350, 992, 'StateFlow는 항상 현재 값을 하나 보유함을 언급', 'ESSENTIAL', 1),
(5351, 992, 'SharedFlow에서 replay = 0이고 수집자가 없으면 emit된 값이 사라짐을 언급', 'ESSENTIAL', 2),
(5352, 992, '상태는 StateFlow, 일회성 이벤트는 SharedFlow로 쓰는 선택 기준을 제시', 'ESSENTIAL', 3),
(5353, 992, 'StateFlow는 equals 기준으로 같은 값을 다시 설정하면 방출하지 않음을 언급', 'SUPPLEMENTARY', 4),
(5354, 992, 'StateFlow가 SharedFlow(replay = 1, DROP_OLDEST)에 중복 제거를 더한 특수형임을 언급', 'SUPPLEMENTARY', 5),
(5355, 992, 'SharedFlow의 동작이 replay·extraBufferCapacity·onBufferOverflow 파라미터로 결정됨을 설명', 'SUPPLEMENTARY', 6),

-- 질문 993
(5356, 993, 'buffer는 값을 버퍼에 쌓아 유실 없이 전부 처리함을 설명', 'ESSENTIAL', 1),
(5357, 993, 'conflate는 소비자가 바쁘면 중간 값을 버리고 최신 값만 전달함을 설명', 'ESSENTIAL', 2),
(5358, 993, 'collectLatest는 새 값이 오면 진행 중인 소비 블록을 취소하고 새로 시작함을 설명', 'ESSENTIAL', 3),
(5359, 993, '기본 Flow는 생산과 소비가 같은 코루틴에서 순차 실행되어 소요 시간이 합산됨을 언급', 'SUPPLEMENTARY', 4),
(5360, 993, '검색어 입력 시 이전 검색 취소에 collectLatest가 적합함을 제시', 'SUPPLEMENTARY', 5),
(5361, 993, '버퍼링 연산자가 생산자와 소비자를 별도 코루틴으로 분리함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 994
(5362, 994, 'suspend 함수가 값 하나를 돌려주는 것과 달리 Flow는 여러 값을 시간에 걸쳐 돌려줌을 언급', 'ESSENTIAL', 1),
(5363, 994, 'collect 같은 종단 연산자가 호출될 때 비로소 flow 블록이 실행됨을 설명', 'ESSENTIAL', 2),
(5364, 994, '값 하나가 모든 연산자를 통과해 소비된 뒤에야 다음 값이 생산되는 순차 실행을 설명', 'ESSENTIAL', 3),
(5365, 994, 'emit이 suspend 함수라 소비자가 느리면 생산자가 자동으로 대기함을 언급', 'SUPPLEMENTARY', 4),
(5366, 994, 'map·filter 같은 중간 연산자와 collect·toList 같은 종단 연산자를 구분', 'SUPPLEMENTARY', 5),
(5367, 994, 'Flow가 코루틴 위에서 동작하는 비동기 데이터 스트림임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 995
(5368, 995, 'catch는 업스트림에서 발생한 예외만 잡고 collect 블록 안의 예외는 잡지 못함을 설명', 'ESSENTIAL', 1),
(5369, 995, '소비 로직을 onEach로 올리고 마지막에 catch를 두는 패턴을 제시', 'ESSENTIAL', 2),
(5370, 995, 'retry(n)가 예외 발생 시 업스트림을 재실행함을 언급', 'SUPPLEMENTARY', 3),
(5371, 995, 'onCompletion이 정상 완료·예외·취소 모두에서 호출됨을 언급', 'SUPPLEMENTARY', 4),
(5372, 995, 'launchIn이 collect를 launch로 감싼 단축 표현임을 언급', 'SUPPLEMENTARY', 5);
