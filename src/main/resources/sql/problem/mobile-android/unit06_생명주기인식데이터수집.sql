-- Unit: 생명주기 인식 데이터 수집 (Unit ID: 172)
-- Chapter: Android (Chapter ID: 16)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (598, 172, '상태·이벤트 Flow 차이와 stateIn'),
       (756, 172, '중복 수집과 Channel 일회성 이벤트'),
       (914, 172, '생명주기 인식 수집 응용: 블록 재시작·상위 Flow 공유·이벤트 소비');

-- =====================================================
-- Lesson 598: 상태·이벤트 Flow 차이와 stateIn
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3767, 598, '아래 Fragment 코드를 실행했을 때 나타나는 동작으로 옳은 것은?', '```kotlin
class OrderFragment : Fragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        viewLifecycleOwner.lifecycleScope.launch {
            viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.uiState.collect { render(it) }
                viewModel.events.collect { showSnackbar(it) }
            }
        }
    }
}
```

uiState는 화면이 열려 있는 동안 계속 새 값을 보내는 StateFlow이고, events는 버튼을 누를 때마다 값을 보내는 SharedFlow이다.', 'OBJECTIVE'),
       (3768, 598, '아래 두 Flow 비교표를 바탕으로 옳지 않은 것은?', '| 항목 | StateFlow | SharedFlow (기본 설정) |
|---|---|---|
| 초기값 | 필수 | 없음 |
| 새 구독자가 받는 값 | 최신 값 1개 즉시 | 없음 (replay = 0) |
| 같은 값을 다시 보낼 때 | equals로 같으면 방출 생략 | 그대로 방출 |
| 버퍼 | 최신 값 1개만 유지 | extraBufferCapacity로 조절 |

두 Flow 모두 구독자가 없어도 값을 만들어 내는 핫 스트림이다.', 'OBJECTIVE'),
       (3769, 598, '아래 설정과 로그에서 상위 Flow 수집 동작에 대한 설명으로 옳은 것은?', '```kotlin
val uiState: StateFlow<UiState> = repository.observeProducts()
    .map { UiState.Success(it) as UiState }
    .stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = UiState.Loading,
    )
```

```
10:00:00  화면 진입 — 구독자 1명, 상위 수집 시작
10:00:07  화면 회전 — 구독자 0명이 되었다가 0.2초 뒤 다시 1명
10:00:20  홈 버튼 — 구독자 0명
10:00:25  상위 수집 중단
```', 'OBJECTIVE'),
       (3770, 598, '아래 상황에서 스낵바가 표시되지 않은 원인과 대응으로 옳은 것은?', '장바구니 담기 결과를 MutableSharedFlow(replay = 0)로 내보내고, 화면은 STARTED 이상일 때만 이 Flow를 수집한다.

```
09:12:03  홈 버튼 — 앱이 백그라운드로 내려감
09:12:05  서버 응답 도착 — emit(AddedToCart(77)) 호출됨
09:12:31  앱 복귀 — 수집 다시 시작
09:12:31  스낵바 표시 없음
```', 'OBJECTIVE'),
       (3771, 598, '아래 증상을 없애려면 수집 코루틴이 기준으로 삼아야 할 Fragment의 생명주기 소유자는?', '```kotlin
class UserFragment : Fragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.users.collect { binding.list.submitList(it) }
            }
        }
    }
}
```

```
상세 화면으로 갔다가 뒤로 돌아오면 목록이 두 번 그려지고, 몇 번 반복하면 종료된다.

java.lang.NullPointerException: binding is null
    at UserFragment$onViewCreated$1$1$1.invokeSuspend(UserFragment.kt:24)
```', 'SUBJECTIVE'),
       (3772, 598, '위 측정에서 바꾼 뒤의 코드가 사용한 Compose 수집 함수의 이름은?', '지도 화면이 위치 StateFlow를 구독한다. 홈 버튼으로 앱을 내린 뒤 10분간 측정했다.

```
바꾸기 전:  val loc by viewModel.location.collectAsState()
  백그라운드 10분 동안 위치 갱신 콜백 600회, 배터리 소모 4.1%

바꾼 뒤:    val loc by viewModel.location.???()
  백그라운드 위치 갱신 콜백 0회, 배터리 소모 0.6%
  화면으로 돌아오면 최신 위치가 곧바로 그려짐
```

lifecycle-runtime-compose 의존성을 추가했고 나머지 코드는 그대로다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3767
(10219, 3767, '두 Flow가 번갈아 수집되어 uiState와 events의 값이 도착한 순서대로 처리된다.', 'collect는 상위 Flow가 끝날 때까지 반환되지 않는 suspend 함수라 두 줄을 나란히 적어도 병렬 수집이 되지 않는다. 번갈아 처리하려면 각각 launch로 감싸야 한다.', false),
(10220, 3767, '화면이 STARTED 미만으로 내려가도 두 수집이 살아남아 백그라운드에서 계속 값을 처리한다.', 'repeatOnLifecycle은 STARTED 미만이 되면 블록 전체를 취소한다. 백그라운드 수집이 남는 것은 이 블록 없이 launch 안에서 바로 collect한 경우다.', false),
(10221, 3767, 'uiState의 값은 화면에 반영되지만 events로 보낸 스낵바는 한 번도 표시되지 않는다.', '첫 collect가 uiState를 계속 수집하며 반환하지 않아 다음 줄의 events collect에 도달하지 못한다. 두 줄을 각각 launch로 감싸야 둘 다 수집된다.', true),
(10222, 3767, 'View가 파괴된 뒤 값이 도착하면 render가 호출돼 널 참조 크래시가 난다.', 'viewLifecycleOwner를 기준으로 삼았으므로 View 파괴와 함께 코루틴이 취소된다. 이 크래시는 Fragment 자신의 lifecycleScope를 썼을 때 생기는 문제다.', false),

-- 문제 3768
(10223, 3768, '같은 내용의 목록을 연속으로 두 번 대입해도 StateFlow 구독자 쪽 화면은 한 번만 다시 그려진다.', '중복 값 방출을 생략하는 성격에서 따라 나온다. equals로 같다고 판정되면 방출 자체가 없으므로 불필요한 렌더링이 줄어든다.', false),
(10224, 3768, '앱을 다시 열어 SharedFlow를 구독하면 직전에 보낸 값 1개를 즉시 받는다.', '기본 replay가 0이라 새 구독자는 구독 이후 방출분만 받는다. 최신 값 1개를 즉시 건네는 것은 StateFlow 쪽 성격이라 서로 바꿔 붙인 진술이다.', true),
(10225, 3768, '1초에 수십 번 바뀌는 값을 StateFlow로 흘리면 구독자는 중간 값 일부를 보지 못할 수 있다.', '최신 값 1개만 유지하는 성격에서 따라 나온다. 값 하나도 빠뜨리면 안 되는 경우라면 버퍼를 조절할 수 있는 SharedFlow가 맞다.', false),
(10226, 3768, '구독자가 한 명도 붙지 않은 시점에도 StateFlow에는 화면에 그릴 값이 이미 하나 존재한다.', '초기값이 필수인 데다 구독자와 무관하게 값을 유지하는 핫 스트림이라 그렇다. 그래서 첫 구독자도 대기 없이 곧바로 값을 받는다.', false),

-- 문제 3769
(10227, 3769, 'started를 SharingStarted.Eagerly로 바꾸면 10:00:25에도 상위 수집이 멈추지 않는다.', 'Eagerly는 구독자 수와 무관하게 scope가 살아 있는 동안 상위 수집을 유지한다. 로그의 중단은 구독자 0명을 5초 기다린 WhileSubscribed의 결과다.', true),
(10228, 3769, 'started를 SharingStarted.Lazily로 바꾸면 구독이 잠시 끊긴 10:00:07에 상위 수집도 함께 멈춘다.', 'Lazily는 첫 구독 이후 구독자가 사라져도 수집을 유지한다. 구독자 수에 따라 멈췄다 다시 시작하는 것은 WhileSubscribed뿐이다.', false),
(10229, 3769, '10:00:20에 마지막 구독자가 사라지면서 uiState가 들고 있던 값도 초기값 Loading으로 되돌아간다.', '상위 수집을 멈추는 것과 보관 중인 값을 버리는 것은 다른 이야기다. StateFlow는 구독자가 없어도 마지막 값을 그대로 들고 있다.', false),
(10230, 3769, '회전 직후 다시 구독한 화면은 상위 Flow가 새 값을 보낼 때까지 초기값 Loading을 그린다.', 'StateFlow는 새 구독자에게 보관 중인 최신 값을 즉시 건넨다. 그래서 회전 뒤 목록이 로딩 화면을 거치지 않고 곧바로 다시 그려진다.', false),

-- 문제 3770
(10231, 3770, '복귀 후 재구독이 늦어 값이 버퍼에서 만료된 것이다. 수집을 onCreate 시점으로 옮기면 해결된다.', '기본 SharedFlow에는 시간이 지나면 값이 사라지는 버퍼가 없다. 수집 시작 시점을 앞당겨도 백그라운드에 있던 09:12:05의 값은 되살아나지 않는다.', false),
(10232, 3770, 'emit 시점에 구독자가 0명이라 값이 그대로 버려진 것이다. 메시지를 UI 상태에 담고 표시 뒤 비우면 유실을 막는다.', 'replay가 0인 SharedFlow의 emit은 받을 구독자가 없으면 아무 곳에도 남지 않는다. 상태로 모델링하면 복귀 후에도 남아 있고 소비 뒤 비우므로 중복도 없다.', true),
(10233, 3770, 'replay를 1로 늘리면 유실이 사라지고 화면 회전 때 같은 값이 다시 오는 문제도 함께 사라진다.', 'replay를 늘리면 유실은 줄지만 재구독마다 보관된 값을 다시 받아 스낵바가 중복으로 뜬다. 유실과 중복을 한 설정으로 동시에 없애지는 못한다.', false),
(10234, 3770, 'SharedFlow가 콜드 스트림이라 구독자마다 스트림이 새로 만들어진 탓이다. StateFlow로 바꾸면 유실도 중복도 사라진다.', 'SharedFlow는 구독자와 무관하게 값을 내보내는 핫 스트림이다. StateFlow로 바꾸면 값은 남지만 재구독 때마다 그 값을 다시 받아 중복 표시가 생긴다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1212, 3771, 'viewLifecycleOwner,viewLifecycleOwner.lifecycleScope,view lifecycle owner,뷰 라이프사이클 오너,뷰라이프사이클오너', 'Fragment 인스턴스의 생명주기는 View보다 길게 이어져 onDestroyView 뒤에도 lifecycleScope로 띄운 코루틴이 남는다. 뒤로 돌아와 onViewCreated가 다시 불리면 수집이 하나 더 붙어 목록이 두 번 그려지고, 살아남은 옛 코루틴이 이미 해제된 binding을 건드려 널 참조로 죽는다. viewLifecycleOwner는 View와 함께 DESTROYED가 되므로 그 시점에 코루틴이 정리되어 중복 수집과 크래시가 함께 사라진다. this(Fragment)나 requireActivity()의 생명주기를 쓰면 수명이 오히려 더 길어져 증상이 심해지므로 구분해야 한다.'),
       (1213, 3772, 'collectAsStateWithLifecycle,collectAsStateWithLifecycle(),collect as state with lifecycle,컬렉트애즈스테이트위드라이프사이클', '내부에서 repeatOnLifecycle(STARTED)로 수집을 감싸 화면이 보이지 않는 동안 구독을 끊는다. 구독이 끊기면 상위의 stateIn(WhileSubscribed)까지 연쇄로 멈춰 위치 갱신 콜백이 0회가 되고, 배터리 소모가 4.1%에서 0.6%로 줄어든 것이 그 결과다. 복귀하면 다시 구독하면서 StateFlow가 보관하던 최신 값을 즉시 받아 화면이 곧바로 그려진다. 컴포지션에 있는 동안 무조건 수집하는 collectAsState()와, 같은 일을 View 시스템에서 직접 하는 repeatOnLifecycle과 구분한다.');

-- =====================================================
-- Lesson 756: 중복 수집과 Channel 일회성 이벤트
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4715, 756, '아래 코드를 실행하고 얻은 로그에 대한 설명으로 옳은 것은?', '```kotlin
class FeedFragment : Fragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        viewLifecycleOwner.lifecycleScope.launchWhenStarted {
            viewModel.feed.collect { render(it) }
        }
    }
}
```

feed는 서버 푸시를 그대로 내보내는 SharedFlow(extraBufferCapacity = 64)이다.

```
10:00:00           화면 표시 — 값이 도착할 때마다 render 호출
10:00:30           홈 버튼 — 화면이 보이지 않게 됨
10:00:30~10:01:00  서버가 푸시 30건 전송, 이 구간 render 호출 0회
10:01:00           앱 복귀 — 0.2초 사이에 render 30회 연속 호출
```', 'OBJECTIVE'),
       (4716, 756, '아래 코드를 실행했을 때 render가 호출된 총 횟수는?', '```kotlin
class CounterViewModel : ViewModel() {
    private val _state = MutableStateFlow(0)
    val state: StateFlow<Int> = _state.asStateFlow()

    fun run() {              // 아래 다섯 줄을 1초 간격으로 실행한다
        _state.value = 0
        _state.value = 1
        _state.value = 1
        _state.value = 2
        _state.value = 0
    }
}
```

```kotlin
// 화면은 run() 호출 전에 수집을 시작했고, 끝날 때까지 STARTED 이상을 유지한다
viewLifecycleOwner.lifecycleScope.launch {
    viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.state.collect { render(it) }
    }
}
```

render는 즉시 끝나므로 값이 밀려 처리되는 일은 없다.', 'OBJECTIVE'),
       (4717, 756, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 수집 방식 | 수집이 유지되는 구간 | 주로 쓰는 곳 |
|---|---|---|
| collectAsState() | 컴포지션에 남아 있는 동안 항상 | 안드로이드 생명주기가 없는 멀티플랫폼 공통 코드 |
| collectAsStateWithLifecycle() | STARTED 이상 (기준 상태 변경 가능) | 안드로이드 앱의 Compose 화면 |
| repeatOnLifecycle + collect | 지정한 상태 이상 | Activity·Fragment 등 View 시스템 |

세 방식 모두 ViewModel이 노출한 같은 StateFlow 하나를 수집한다고 하자.', 'OBJECTIVE'),
       (4718, 756, '아래 코드에서 관찰된 증상의 원인과 대응으로 옳은 것은?', '```kotlin
class ChatActivity : AppCompatActivity() {
    override fun onStart() {
        super.onStart()
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.messages.collect { appendMessage(it) }
            }
        }
    }
}
```

messages는 새 메시지가 도착할 때마다 값을 내보내는 SharedFlow다.

```
앱을 내렸다가 복귀하기를 세 번 반복했다. 복귀 직후에는 대화창에 변화가 없었다.
그 뒤 새 메시지 1건이 도착하자 같은 메시지가 4줄 쌓였다.
```', 'OBJECTIVE'),
       (4719, 756, '아래 코드의 ???에 들어갈 Flow 연산자의 이름은?', '```kotlin
// 바꾸기 전 — 중첩이 깊다는 코드 리뷰 지적을 받았다
viewLifecycleOwner.lifecycleScope.launch {
    viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.uiState.collect { render(it) }
    }
}

// 바꾼 뒤 — 수집하는 Flow는 이 하나뿐이다
viewLifecycleOwner.lifecycleScope.launch {
    viewModel.uiState
        .???(viewLifecycleOwner.lifecycle, Lifecycle.State.STARTED)
        .collect { render(it) }
}
```

```
두 코드 모두 홈 버튼을 누른 구간에서 render 호출 0회,
복귀 직후 최신 값으로 render 1회를 기록했다.
```', 'SUBJECTIVE'),
       (4720, 756, '아래 상황에서 SharedFlow를 대신해 도입한 코루틴 도구의 이름은?', '결제가 끝나면 주문 상세로 이동시키는 신호를 MutableSharedFlow(replay = 0)로 보내고 있었다.

```
[바꾸기 전]
09:40:12  결제 성공 응답 도착 — 신호 1건 전송 (화면은 백그라운드, 수집 중단 상태)
09:40:30  앱 복귀 — 화면 이동 없음

[바꾼 뒤]
09:52:04  결제 성공 응답 도착 — 신호 1건 전송 (화면은 백그라운드, 수집 중단 상태)
09:52:19  앱 복귀 — 주문 상세로 이동 1회, 이후 화면을 회전해도 다시 이동하지 않음
```

다만 바꾼 뒤 구조에서 결제 완료를 두 화면이 동시에 받아 각각 갱신하게 만들려 했더니, 신호가 둘 중 한 곳에만 도착했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4715
(12747, 4715, '화면이 가려진 순간 수집 코루틴이 취소되면서 상위 구독도 함께 끊겼다. 복귀 뒤 다시 구독하자 서버가 보관하던 푸시를 재전송한 것이다.', 'launchWhenStarted는 STARTED 미만에서 코루틴을 취소하지 않는다. 구독이 정말 끊겼다면 백그라운드 구간의 푸시는 어디에도 남지 않아 복귀 직후 30건이 한꺼번에 밀려들 수 없다.', false),
(12748, 4715, 'SharedFlow가 콜드 스트림이라 수집이 멈춘 동안에는 값이 만들어지지 않았다. StateFlow로 바꾸면 백그라운드 값까지 빠짐없이 받을 수 있다.', 'SharedFlow는 구독 여부와 무관하게 값을 내보내는 핫 스트림이다. StateFlow로 바꾸면 최신 값 1개만 보관하므로 오히려 밀린 30건 가운데 마지막 하나만 받게 된다.', false),
(12749, 4715, '수집 코루틴이 취소되지 않고 멈춰만 있어 상위 구독과 버퍼가 그대로 살아 있었다. repeatOnLifecycle(STARTED)로 감싸면 구독이 끊겨 값이 쌓이지 않는다.', 'launchWhenStarted는 STARTED 미만에서 코루틴을 일시 중단만 하므로 상위 스트림과 그 뒤의 데이터 소스가 계속 동작해 리소스가 샌다. 복귀 직후 30건이 몰린 것이 버퍼가 살아 있었다는 증거다.', true),
(12750, 4715, 'Fragment 자신의 lifecycleScope를 기준으로 삼은 탓에 View가 사라진 뒤에도 수집이 남은 것이다. viewLifecycleOwner로 바꾸면 밀린 값이 사라진다.', '코드는 이미 viewLifecycleOwner.lifecycleScope를 쓰고 있고, 홈 버튼만으로는 View가 파괴되지도 않는다. 생명주기 소유자 선택은 View 파괴 뒤 남는 코루틴의 문제로 백그라운드 적체와는 다르다.', false),

-- 문제 4716
(12751, 4716, '3', '구독을 시작하는 순간 받는 1회를 빼고 값이 바뀐 세 번만 센 것이다. StateFlow는 새 구독자에게 보관 중인 현재 값을 즉시 건네므로 첫 render가 한 번 더 있다.', false),
(12752, 4716, '4', '구독 시작 시 현재 값 0을 받아 1회, 이후 0에서 1, 1에서 2, 2에서 0으로 바뀔 때 세 번 방출되어 모두 4회다. 같은 값을 다시 대입한 두 번은 equals 비교로 방출이 생략된다.', true),
(12753, 4716, '5', '같은 값을 다시 대입한 두 건 가운데 하나만 걸러진다고 본 것이다. StateFlow는 직전 값과 equals로 같으면 몇 번을 대입하든 방출하지 않는다.', false),
(12754, 4716, '6', '대입 5회에 구독 시작 시 받는 1회를 더한 값으로, 중복 값 방출 생략을 고려하지 않은 결과다. 같은 값을 그대로 다시 흘려보내는 쪽은 SharedFlow다.', false),

-- 문제 4717
(12755, 4717, '홈 버튼으로 앱을 내려도 화면이 백스택에 남아 컴포지션이 유지되면 collectAsState()의 수집은 끊기지 않는다.', '컴포지션에 있는지만 따지고 생명주기 상태는 보지 않기 때문이다. 그래서 화면이 보이지 않는 동안에도 상위 Flow와 그 뒤의 데이터 소스가 계속 동작한다.', false),
(12756, 4717, '멀티플랫폼 공통 모듈에 둔 화면 코드에서는 collectAsStateWithLifecycle() 대신 collectAsState()를 쓰게 된다.', '생명주기 상태를 기준으로 삼는 API는 안드로이드 Lifecycle에 의존해 공통 코드에서는 쓸 수 없다. 대신 그 코드는 화면이 가려져도 수집이 계속된다는 점을 감수해야 한다.', false),
(12757, 4717, 'View 시스템에서 repeatOnLifecycle로 감싼 수집은 앱을 내렸다 복귀하면 다시 구독하면서 최신 값으로 화면을 곧바로 그린다.', '지정 상태 미만에서 취소된 블록이 그 상태로 돌아올 때 다시 시작되고, 재구독한 StateFlow가 보관 중이던 값을 즉시 건네기 때문이다. 그래서 복귀 후 빈 화면을 거치지 않는다.', false),
(12758, 4717, 'collectAsStateWithLifecycle()은 컴포지션에서 벗어나지 않는 한 수집을 유지하므로 앱을 내려도 상위 Flow가 계속 동작한다.', '이 API는 컴포지션 여부와 함께 생명주기 상태를 보므로 STARTED 미만으로 내려가면 수집을 끊는다. 컴포지션에 있는지만 따지는 쪽은 collectAsState()이며, 둘의 차이가 바로 이 구간이다.', true),

-- 문제 4718
(12759, 4718, '복귀할 때마다 onStart가 다시 불려 수집 코루틴이 하나씩 늘어난 것이다. 한 번만 지나가는 onCreate에서 시작하면 수집 지점이 하나로 유지된다.', 'repeatOnLifecycle은 STARTED를 오갈 때 블록을 스스로 취소하고 다시 시작하므로 반복 콜백에서 또 호출할 필요가 없다. onStart가 네 번 불려 수집 지점이 넷이 되었고 메시지 1건이 네 번 처리됐다.', true),
(12760, 4718, 'messages의 replay 버퍼에 남아 있던 값이 재구독 때마다 다시 전달된 것이다. replay를 0으로 낮추면 사라진다.', '보관된 값이 되살아나는 것이라면 복귀하는 순간 줄이 늘었어야 하는데, 복귀 직후에는 변화가 없었고 새 메시지가 도착한 시점에 한꺼번에 늘었다. 과거 값이 아니라 같은 값이 여러 번 처리된 것이다.', false),
(12761, 4718, 'Activity의 lifecycleScope가 백그라운드에서도 취소되지 않아 수집이 남은 것이다. viewLifecycleOwner를 기준으로 바꾸면 해결된다.', 'Activity에는 viewLifecycleOwner가 없고, 백그라운드 수집은 이미 repeatOnLifecycle이 블록을 취소해 막고 있다. 문제는 수집이 끊기지 않는 것이 아니라 수집 지점이 여러 개라는 데 있다.', false),
(12762, 4718, 'repeatOnLifecycle이 블록을 다시 시작할 때 직전에 처리한 값을 되돌려 주어 중복이 생긴 것이다. 기준 상태를 RESUMED로 올리면 줄어든다.', '다시 시작하면 새로 구독할 뿐 이미 처리한 값을 돌려주지 않는다. 기준 상태는 언제 구독을 끊고 다시 붙일지를 정할 뿐이라 수집 지점이 넷이라는 사실을 바꾸지 못한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1528, 4719, 'flowWithLifecycle,flowWithLifecycle(),flow with lifecycle,플로우 위드 라이프사이클,플로우위드라이프사이클', '안쪽에서 repeatOnLifecycle을 그대로 사용해 지정한 상태 미만이면 구독을 끊고 다시 그 상태가 되면 새로 구독한다. 두 코드의 로그가 똑같이 찍힌 이유가 여기에 있고, 복귀 직후 render 1회는 재구독한 StateFlow가 보관하던 최신 값을 즉시 건넸기 때문이다. 다만 수집할 Flow가 여러 개면 Flow마다 이 연산자를 붙여야 하므로, 그때는 repeatOnLifecycle 블록 하나 안에 launch를 여러 개 두는 편이 낫다. 같은 일을 Compose에서 하는 collectAsStateWithLifecycle(), 취소가 아니라 일시 중단만 해 상위 구독이 살아남는 launchWhenStarted와 구분한다.'),
       (1529, 4720, 'Channel,채널,코틀린 Channel,kotlin channel,Channel()', '구독자가 없어도 보낸 값을 버퍼에 담아 두기 때문에 백그라운드에서 발생한 신호가 복귀 후 정확히 한 번 처리된다. 대신 값 하나가 여러 수신자에게 방송되지 않고 먼저 가져간 쪽 하나에만 전달되므로, 두 화면이 같은 신호를 함께 받아야 하는 요구에는 맞지 않는다. 구독자가 없을 때 값을 그냥 버리는 replay = 0의 SharedFlow, replay를 늘렸을 때 재구독마다 같은 값을 다시 받아 중복 처리되는 문제와 구분한다. receiveAsFlow()로 수집하다 취소되면 꺼내던 값이 사라질 수 있다는 한계도 있어, 유실과 중복을 모두 피하려면 신호를 UI 상태의 일부로 모델링하고 처리한 뒤 비우는 방식을 쓴다.');

-- =====================================================
-- Lesson 914: 생명주기 인식 수집 응용: 블록 재시작·상위 Flow 공유·이벤트 소비
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5663, 914, '아래 순서로 앱을 조작하는 동안 Logcat에 찍힌 MAP 태그 로그의 순서로 옳은 것은?', '```kotlin
class MapActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        lifecycleScope.launch {
            Log.d("MAP", "A")
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                Log.d("MAP", "B")
                viewModel.location.collect { draw(it) }
            }
            Log.d("MAP", "C")
        }
    }
}
```

location은 위치가 바뀔 때마다 새 값을 내보내는 StateFlow라 collect가 스스로 끝나지 않는다. draw는 로그를 남기지 않는다.

```
앱 실행 → 홈 버튼으로 내림 → 복귀 → 홈 버튼으로 내림 → 복귀
(이 동안 Activity는 한 번도 파괴되지 않았다)
```', 'OBJECTIVE'),
       (5664, 914, '아래 코드에서 담기 버튼으로 스낵바를 한 번 본 뒤 나타나는 동작으로 옳은 것은?', '```kotlin
data class CartUiState(
    val items: List<String> = emptyList(),
    val userMessage: String? = null,
)

class CartViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(CartUiState())
    val uiState: StateFlow<CartUiState> = _uiState.asStateFlow()

    fun onAdded(item: String) = _uiState.update {
        it.copy(items = it.items + item, userMessage = "담았습니다")
    }
    fun onRemoved(item: String) = _uiState.update { it.copy(items = it.items - item) }
    fun onMessageShown() = _uiState.update { it.copy(userMessage = null) }
}
```

```kotlin
// CartFragment
viewLifecycleOwner.lifecycleScope.launch {
    viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.uiState.collect { state ->
            render(state.items)
            state.userMessage?.let { showSnackbar(it) }
        }
    }
}
```

onMessageShown()을 호출하는 곳은 없다.', 'OBJECTIVE'),
       (5665, 914, '아래 두 안으로 각각 화면을 1분 동안 띄웠을 때 서버 요청 횟수로 옳은 것은?', 'repository.pollPrices()는 수집이 시작될 때마다 폴링 루프를 새로 만들어 3초마다 서버에 요청하는 Flow다. 루프 하나는 1분에 20회 요청한다.

```kotlin
// A안
val prices: Flow<List<Price>> = repository.pollPrices()

// B안
val prices: StateFlow<List<Price>> = repository.pollPrices()
    .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())
```

화면에서는 가격 목록과 상단 요약 두 곳이 ViewModel의 prices를 각각 수집한다. 화면은 1분 내내 보이는 상태이고, 이 두 곳 말고는 prices를 수집하는 곳이 없다.', 'OBJECTIVE'),
       (5666, 914, '아래 코드와 기록에서 frames 수집에 대한 설명으로 옳은 것은?', '```kotlin
@Composable
fun ScanRoute(viewModel: ScanViewModel = hiltViewModel()) {
    val preview by viewModel.frames.collectAsStateWithLifecycle()
    ScanScreen(preview)
}
```

frames는 카메라 미리보기 프레임을 내보내는 StateFlow다.

```
10:00:00  화면 표시
10:00:10  권한 요청 창(반투명 Activity)이 위를 덮음 — onPause만 호출, onStop은 호출되지 않음
10:00:20  권한 요청 창 닫힘 — onResume 호출
10:00:30  홈 버튼 — onPause, onStop 호출
```', 'OBJECTIVE'),
       (5667, 914, '아래 코드의 ???에 들어갈 인자의 이름은?', '```kotlin
class CartViewModel : ViewModel() {
    private val _messages = MutableSharedFlow<String>(??? = 1)
    val messages: SharedFlow<String> = _messages.asSharedFlow()

    fun onAdded() {
        viewModelScope.launch { _messages.emit("장바구니에 담았습니다") }
    }
}
```

화면은 repeatOnLifecycle(STARTED) 안에서 messages를 수집해 값이 올 때마다 스낵바를 띄운다.

```
[??? = 1]
09:10:02  담기 버튼 — 스낵바 1회
09:10:15  화면 회전 — 이미 본 스낵바가 한 번 더 뜸
09:10:40  홈 버튼 → 백그라운드에서 담기 완료 → 복귀 — 스낵바 1회

[??? = 0으로 바꾼 뒤]
09:20:02  담기 버튼 — 스낵바 1회
09:20:15  화면 회전 — 스낵바 없음
09:20:40  홈 버튼 → 백그라운드에서 담기 완료 → 복귀 — 스낵바 없음
```', 'SUBJECTIVE'),
       (5668, 914, '아래 측정에서 바꾸기 전 ViewModel이 price를 노출할 때 쓴 타입의 이름은?', '주식 가격 화면을 Flow 기반으로 옮기기 전후를 같은 조건에서 측정했다. 가격은 1초마다 다른 값으로 바뀌고, 홈 버튼으로 앱을 5분 동안 백그라운드에 두었다.

바꾸기 전에는 ViewModel이 price를 Flow가 아닌 다른 Jetpack 타입으로 노출했고, Fragment는 이 값에 관찰자를 등록하면서 viewLifecycleOwner를 함께 넘겼다. 관찰자를 해제하는 코드는 따로 두지 않았다.

```
[바꾸기 전]
  백그라운드 5분 동안 showPrice 호출 0회
  복귀 직후 최신 가격으로 showPrice 1회
  화면을 닫았다 다시 여는 것을 50회 반복해도 메모리 누수 없음

[바꾼 뒤]  price를 StateFlow로 바꾸고 아래처럼 수집
  viewLifecycleOwner.lifecycleScope.launch { viewModel.price.collect { showPrice(it) } }
  백그라운드 5분 동안 showPrice 호출 300회
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5663
(15275, 5663, 'A → B', '블록이 STARTED 미만에서 멈췄다가 그 자리부터 이어 간다고 본 것으로, launchWhenStarted의 동작이다. repeatOnLifecycle은 블록을 취소하고 STARTED로 돌아올 때마다 처음부터 다시 실행하므로 복귀할 때마다 B가 찍힌다.', false),
(15276, 5663, 'A → B → C', '블록이 취소되면 repeatOnLifecycle도 곧바로 반환된다고 본 것이다. 이 함수는 생명주기가 DESTROYED가 될 때까지 반환되지 않는 suspend 함수라, Activity가 살아 있는 동안에는 다음 줄의 C가 실행되지 않는다.', false),
(15277, 5663, 'A → B → B → B', 'A는 launch가 시작될 때 한 번 찍힌다. 블록은 처음 STARTED가 될 때와 두 번의 복귀 때마다 새로 시작되어 B가 세 번 찍힌다. repeatOnLifecycle은 DESTROYED 전에는 반환되지 않으므로 C는 아직 찍히지 않는다.', true),
(15278, 5663, 'A → B → A → B → A → B', 'STARTED가 될 때마다 launch 전체가 다시 실행된다고 본 것이다. 다시 시작되는 범위는 repeatOnLifecycle에 넘긴 블록뿐이고, onCreate에서 한 번 띄운 코루틴은 그대로 이어지므로 A는 한 번만 찍힌다.', false),

-- 문제 5664
(15279, 5664, '담아 둔 상품 하나를 빼기만 해도 "담았습니다" 스낵바가 다시 뜬다.', '상품을 빼면 items가 바뀐 새 상태가 방출되는데, 비우지 않은 userMessage가 그 상태에 그대로 실려 있어 collect가 스낵바를 다시 띄운다. 표시한 뒤 onMessageShown()으로 메시지를 비워야 한 번만 처리된다.', true),
(15280, 5664, '앱을 내린 사이 onAdded가 호출되면 복귀한 뒤에도 그 결과 스낵바는 뜨지 않는다.', '구독자가 없으면 값을 버리는 SharedFlow(replay = 0)의 유실과 혼동한 것이다. 여기서는 메시지가 상태에 남아 있어, 복귀 후 다시 시작된 수집이 현재 상태를 즉시 받아 스낵바를 띄운다.', false),
(15281, 5664, '한 번 표시한 메시지는 StateFlow가 같은 값으로 걸러 내므로 스낵바는 한 번만 뜬다.', '방출 생략은 직전 값과 equals로 같을 때만 일어난다. 상품을 빼면 상태 전체가 달라져 방출되고, 새로 구독한 수집자는 현재 값을 즉시 받으므로 메시지가 남아 있는 한 스낵바가 다시 뜬다.', false),
(15282, 5664, '화면을 회전하면 다시 구독한 화면이 초기값 CartUiState()부터 받아 메시지가 사라진다.', 'ViewModel은 회전 뒤에도 살아남고, StateFlow는 새 구독자에게 초기값이 아니라 보관 중인 최신 값을 건넨다. 그래서 회전하면 메시지가 사라지기는커녕 같은 스낵바가 다시 뜬다.', false),

-- 문제 5665
(15283, 5665, 'A안 20회, B안 20회', 'ViewModel 속성 하나에 담긴 Flow라서 수집자끼리 나눠 쓴다고 본 것이다. pollPrices()는 collect마다 루프를 새로 만드는 콜드 Flow라, A안은 수집 2곳이 루프 2개를 돌려 40회가 된다.', false),
(15284, 5665, 'A안 40회, B안 20회', 'A안은 수집 2곳이 콜드 Flow를 각각 시작해 루프가 2개다(20회×2). B안은 stateIn이 상위를 한 번만 수집해 핫 스트림으로 바꾸고 두 수집자가 같은 값을 공유하므로 루프가 1개다.', true),
(15285, 5665, 'A안 40회, B안 40회', 'stateIn 뒤에도 수집자마다 상위가 따로 시작된다고 본 것이다. stateIn은 viewModelScope에서 상위를 한 번만 수집해 그 값을 모든 구독자에게 나눠 주므로, 구독자가 늘어도 루프는 하나다.', false),
(15286, 5665, 'A안 20회, B안 40회', '콜드와 핫의 성격을 거꾸로 붙인 것이다. 구독자마다 최신 값을 따로 들고 있으려고 상위를 각자 돌린다고 오해했지만, StateFlow는 값 하나를 모든 구독자가 공유하고 콜드 Flow는 collect마다 새로 시작한다.', false),

-- 문제 5666
(15287, 5666, '10:00:10~10:00:20에는 화면 일부가 가려져 있으므로 frames 수집이 멈춘다.', 'onPause만 호출되면 생명주기는 RESUMED에서 STARTED로 한 단계 내려갈 뿐이다. 기본 기준이 STARTED 이상이라 화면이 일부라도 보이는 이 구간에도 수집은 이어진다.', false),
(15288, 5666, '10:00:30 이후에도 ScanRoute가 컴포지션에 남아 있는 동안은 frames 수집이 이어진다.', '컴포지션에 있는지만 보고 수집하는 collectAsState()의 동작을 붙인 것이다. collectAsStateWithLifecycle()은 onStop으로 생명주기가 STARTED 미만이 되는 순간 수집을 끊는다.', false),
(15289, 5666, '10:00:20에 권한 요청 창이 닫히면 수집이 새로 시작되어 preview가 초기값부터 그려진다.', '기본 설정에서는 그 구간에 수집이 끊긴 적이 없어 다시 시작할 일이 없다. 또 수집이 새로 시작되더라도 StateFlow는 보관 중인 최신 값을 즉시 건네므로 초기값으로 돌아가지 않는다.', false),
(15290, 5666, 'minActiveState를 Lifecycle.State.RESUMED로 지정하면 10:00:10~10:00:20에도 수집이 멈춘다.', '수집 기준 상태는 바꿀 수 있다. RESUMED로 올리면 onPause로 STARTED가 된 순간 기준 미만이 되어 수집이 끊긴다. 기본값 STARTED에서는 화면이 일부라도 보이는 이 구간을 계속 수집한다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1844, 5667, 'replay,replay=1,replay = 1,리플레이', 'replay는 새 구독자에게 최근 값을 몇 개까지 다시 건넬지 정한다. 1이면 마지막 메시지가 보관되어, 회전 뒤 다시 구독한 화면이 이미 처리한 값을 또 받아 스낵바가 중복으로 뜨고, 백그라운드에서 보낸 값도 남아 있다가 복귀 후 전달된다. 0이면 아무것도 보관하지 않으므로 중복은 사라지지만 구독자가 없을 때 emit한 값은 그대로 버려진다. 이름이 비슷한 extraBufferCapacity는 구독자가 있지만 처리가 느릴 때 쓰는 추가 버퍼라, 구독자가 없는 동안의 값을 보관하거나 새 구독자에게 다시 건네지 않으므로 회전 중복의 원인이 될 수 없다. 유실과 중복을 함께 피하려면 메시지를 UI 상태에 담고 처리한 뒤 비우는 방식을 쓴다.'),
       (1845, 5668, 'LiveData,MutableLiveData,라이브데이터,라이브 데이터', 'LiveData는 관찰자를 등록할 때 넘긴 생명주기 소유자의 상태를 스스로 확인해 STARTED 미만이면 값을 전달하지 않고, 다시 STARTED가 되면 최신 값 하나만 건넨다. DESTROYED가 되면 관찰자를 스스로 떼어 내므로 해제 코드 없이도 누수가 없다. 반면 StateFlow를 포함한 Flow는 생명주기를 모르기 때문에 lifecycleScope.launch 안에서 collect만 하면 View가 파괴되기 전까지 백그라운드에서도 계속 수집해 300회가 찍혔다. Flow로 옮길 때는 repeatOnLifecycle(STARTED)나 collectAsStateWithLifecycle()로 수집하는 쪽이 범위를 직접 좁혀야 한다. 항상 현재 값을 들고 있다는 점은 StateFlow와 같지만, 생명주기를 스스로 인식하는지가 둘을 가르는 차이다.');
