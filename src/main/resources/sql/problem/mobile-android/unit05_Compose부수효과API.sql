-- Unit: Compose 부수효과 API (Unit ID: 171)
-- Chapter: Android (Chapter ID: 16)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (597, 171, '키 재시작과 snapshotFlow 변환'),
       (755, 171, 'SideEffect와 코루틴 스코프 수명'),
       (913, 171, '키 비교와 정리 시점으로 가려 쓰는 Compose 부수효과 API');

-- =====================================================
-- Lesson 597: 키 재시작과 snapshotFlow 변환
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3761, 597, '아래 화면에서 userId가 A에서 B로 바뀐 직후 일어나는 일로 옳은 것은?', '```kotlin
@Composable
fun UserScreen(userId: String) {
    var profile by remember { mutableStateOf<Profile?>(null) }
    LaunchedEffect(userId) {
        profile = api.fetchProfile(userId)   // 응답까지 약 2초 걸린다
    }
    ProfileView(profile)
}
```

UserScreen은 화면에 계속 떠 있는 상태이고, userId가 A로 그려진 지 0.5초 뒤 상위 화면에서 userId로 B가 전달되었다.', 'OBJECTIVE'),
       (3762, 597, '아래 비교표에서 이끌어낼 수 있는 설명으로 옳지 않은 것은?', '| API | 실행 시점 | 정리 시점 | suspend 함수 호출 |
| --- | --- | --- | --- |
| LaunchedEffect(key) | 컴포지션 진입 시, key 변경 시 | 이탈 시·key 변경 시 코루틴 취소 | 가능 |
| DisposableEffect(key) | 컴포지션 진입 시, key 변경 시 | 이탈 시·key 변경 시 onDispose 실행 | 불가 |
| SideEffect | 매 성공적 재구성 후 | 없음 | 불가 |', 'OBJECTIVE'),
       (3763, 597, '아래에서 설명하는 Compose 상태 변환 API에 대한 설명으로 옳은 것은?', 'snapshotFlow는 LaunchedEffect처럼 코루틴이 도는 자리에서 호출하며, 블록 안에서 읽은 Compose 상태를 코루틴 쪽의 Flow로 옮겨 준다. 목록 화면에서는 주로 LazyListState의 스크롤 위치를 다룰 때 쓴다.', 'OBJECTIVE'),
       (3764, 597, '아래 컴포저블이 화면에 나타났다 사라지기까지 tracker의 메서드가 호출된 횟수는?', '```kotlin
@Composable
fun Badge(count: Int, tracker: Tracker) {
    SideEffect { tracker.report(count) }
    DisposableEffect(Unit) {
        tracker.open()
        onDispose { tracker.close() }
    }
    Text(count.toString())
}
```

Badge가 count = 0으로 처음 그려진 뒤 count가 1, 2로 한 번씩 바뀌어 그때마다 재구성이 정상적으로 끝났고, 이어서 Badge가 화면에서 사라졌다.', 'OBJECTIVE'),
       (3765, 597, '아래 상황을 해결하는 데 필요한 Compose API의 이름은?', '긴 목록 화면 오른쪽 아래에 맨 위로 버튼을 달았다. onClick 람다 안에서 listState.animateScrollToItem(0)을 부르자 suspend 함수는 코루틴 안에서만 호출할 수 있다는 컴파일 오류가 났다. 그래서 컴포저블 본문에 LaunchedEffect(Unit)을 두고 그 안에서 스크롤을 시켰더니, 이번에는 버튼을 누르지도 않았는데 화면에 들어오자마자 목록이 맨 위로 튀었다.', 'SUBJECTIVE'),
       (3766, 597, '아래 딜레마를 푸는 데 쓰는 Compose API의 이름은?', '스플래시 화면에서 LaunchedEffect 안에 delay(3000)을 두고 3초 뒤 onTimeout()을 불러 다음 화면으로 넘긴다. 그런데 상위 컴포저블이 재구성될 때마다 onTimeout 람다가 새 객체로 만들어져 내려온다. 이 람다를 효과의 키에 넣었더니 재구성이 일어날 때마다 3초 타이머가 처음부터 다시 시작돼 화면이 영영 넘어가지 않았고, 키에서 뺐더니 이번에는 3초 전에 캡처해 둔 옛 람다가 호출됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3761
(10203, 3761, 'A와 B의 요청 코루틴이 모두 끝까지 실행돼 나중에 도착한 응답이 화면에 반영된다.', '키가 바뀔 때마다 코루틴이 하나씩 쌓인다고 본 오해. 새 키로 다시 시작할 때 이전 코루틴은 취소되므로 두 응답이 서로 경쟁하는 상황 자체가 생기지 않는다.', false),
(10204, 3761, 'A의 코루틴만 계속 실행되고 B에 대한 요청은 화면을 나갔다 다시 들어와야 시작된다.', '재시작 조건을 컴포지션 이탈·재진입으로만 본 오해. 화면이 유지돼도 키로 준 값이 달라지면 그 자체가 재시작 조건이다.', false),
(10205, 3761, '진행 중이던 A의 요청 코루틴이 취소되고 B로 새 코루틴이 시작돼 B의 프로필만 반영된다.', 'LaunchedEffect는 키가 바뀌면 실행 중이던 코루틴을 취소하고 새 키로 다시 시작한다. 0.5초 시점의 A 요청은 응답 전에 취소되므로 profile에는 B의 응답만 담긴다.', true),
(10206, 3761, 'remember가 값을 붙잡고 있어 효과 블록은 다시 실행되지 않고 A의 프로필이 그대로 남는다.', 'remember의 값 보존과 효과의 키를 혼동한 것. profile 변수는 컴포지션에 남아 있어도 키가 달라지면 효과 블록은 새로 실행된다.', false),

-- 문제 3762
(10207, 3762, 'DisposableEffect는 정리 시점이 보장되므로 블록 안에서 서버 응답을 기다리는 suspend 함수를 그대로 호출할 수 있다.', 'suspend 함수 호출 열에 불가로 적힌 것과 정면으로 어긋난다. 이 블록은 코루틴 스코프가 아니어서, 대기가 필요한 작업은 LaunchedEffect로 옮겨야 한다.', true),
(10208, 3762, '재구성이 중간에 취소되면 SideEffect 블록은 실행되지 않으므로, 화면에 반영되지 않은 값이 외부 SDK로 새어 나가지 않는다.', '실행 시점이 매 성공적 재구성 후이므로 적용되지 못한 재구성의 값은 전달될 기회가 없다. 외부 객체 동기화를 이 API에 맡기는 이유다.', false),
(10209, 3762, '화면을 벗어나면 LaunchedEffect가 시작한 작업은 취소되므로, 끝까지 완료돼야 하는 업로드를 여기서 시작하면 안 된다.', '정리 시점이 이탈 시 코루틴 취소라, 화면보다 오래 살아야 하는 작업에는 맞지 않는다. 그런 작업은 viewModelScope나 WorkManager에서 시작한다.', false),
(10210, 3762, '브로드캐스트 수신기처럼 등록과 해제가 짝을 이루는 작업은 정리 시점이 없는 API보다 DisposableEffect에 두는 편이 안전하다.', 'SideEffect는 정리 시점 자체가 없어 해제 코드를 둘 자리가 없다. DisposableEffect는 onDispose 반환을 강제해 해제 누락을 구조적으로 막는다.', false),

-- 문제 3763
(10211, 3763, '컴포저블 본문에서 바로 호출해 그 반환값을 화면에 그리면 상태가 바뀔 때마다 자동으로 다시 그려진다.', '반환값이 State가 아니라 Flow라 그대로 그릴 수 없다. 코루틴 안에서 collect해 상태에 담아야 화면에 반영된다.', false),
(10212, 3763, '콜백 기반 외부 데이터 소스를 State로 바꿔 주므로 produceState와 하는 일이 사실상 같다.', '변환 방향을 뒤집은 오해. 외부 소스를 State로 바꾸는 쪽이 produceState이고, 이 API는 반대로 State를 Flow로 내보낸다.', false),
(10213, 3763, '값이 흘러나올 때마다 컴포저블을 강제로 다시 그려 최신 값을 화면에 반영해 준다.', '재구성은 상태를 읽는 쪽이 바뀔 때 일어나지 방출이 직접 일으키는 것이 아니다. 수집한 값을 상태에 담아야 화면이 갱신된다.', false),
(10214, 3763, '읽은 값이 직전과 같으면 새로 내보내지 않아, 재구성이 잦아도 같은 값이 거듭 소비되지 않는다.', '스냅숏이 바뀔 때마다 블록을 다시 계산하되 결과가 이전과 같으면 방출을 건너뛴다. 그래서 스크롤 중 재구성이 초당 수십 번 일어나도 실제 처리 횟수는 값이 달라진 만큼만 늘어난다.', true),

-- 문제 3764
(10215, 3764, 'open() 3번, report() 3번, close() 3번', 'DisposableEffect가 재구성마다 해제 후 다시 등록된다고 본 오해. 키가 Unit이라 값이 바뀔 일이 없어 재등록도 일어나지 않는다.', false),
(10216, 3764, 'open() 1번, report() 3번, close() 1번', 'SideEffect는 매 성공적 재구성 후 실행돼 첫 구성과 두 번의 재구성까지 3번 돈다. DisposableEffect는 키가 Unit이라 진입 시 open()이 1번, 이탈 시 onDispose로 close()가 1번이다.', true),
(10217, 3764, 'open() 1번, report() 1번, close() 1번', 'SideEffect를 진입 시 한 번만 도는 초기화 블록으로 본 오해. 정리 개념이 없는 대신 재구성이 성공할 때마다 매번 실행된다.', false),
(10218, 3764, 'open() 1번, report() 3번, close() 0번', 'onDispose를 키가 바뀔 때만 도는 블록으로 본 오해. 키가 그대로여도 컴포저블이 컴포지션에서 빠지는 순간 반드시 실행된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1210, 3765, 'rememberCoroutineScope,rememberCoroutineScope(),remember coroutine scope,리멤버코루틴스코프,리멤버 코루틴 스코프', '클릭 같은 사용자 이벤트에서 코루틴을 시작할 때 쓰는 API다. 컴포저블 본문에서 rememberCoroutineScope()로 스코프를 미리 얻어 두면 onClick 안에서 scope.launch로 suspend 함수를 부를 수 있고, 컴포저블이 이탈하면 스코프가 함께 취소돼 사라진 화면을 갱신하는 문제가 없다. LaunchedEffect는 컴포저블 본문에서만 호출할 수 있어 콜백 안에서는 쓸 수 없고, 본문에 두면 클릭과 무관하게 진입 시점에 실행된다는 점에서 구분된다. 다만 화면이 사라져도 끝까지 완료돼야 하는 업로드·결제 요청은 UI 스코프가 아니라 viewModelScope나 WorkManager에서 실행해야 한다.'),
       (1211, 3766, 'rememberUpdatedState,rememberUpdatedState(),remember updated state,리멤버업데이티드스테이트,리멤버 업데이티드 스테이트', '오래 실행되는 효과를 재시작하지 않으면서 최신 값을 참조해야 할 때 쓰는 API다. val currentOnTimeout by rememberUpdatedState(onTimeout)처럼 감싸 두면 재구성 때마다 참조만 최신으로 갱신되고 효과의 키는 그대로여서, 3초 타이머는 유지된 채 호출 시점의 가장 최근 람다가 실행된다. 값을 처음 한 번만 붙잡아 이후 갱신되지 않는 remember와 다르고, 람다를 키에 넣어 재시작을 유발하는 LaunchedEffect(key) 방식과도 구분해야 한다.');

-- =====================================================
-- Lesson 755: SideEffect와 코루틴 스코프 수명
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4709, 755, '아래 컴포저블에서 enabled가 true에서 false로 바뀐 재구성에서 일어나는 일로 옳은 것은?', '```kotlin
@Composable
fun BackGuard(enabled: Boolean, dispatcher: OnBackPressedDispatcher) {
    DisposableEffect(enabled) {
        val callback = BackCallback(enabled)
        dispatcher.addCallback(callback)
        onDispose { callback.remove() }
    }
    Content()
}
```

BackGuard는 화면에 계속 떠 있는 상태이고, enabled가 true인 채로 이미 한 번 그려진 뒤 상위에서 false가 내려왔다.', 'OBJECTIVE'),
       (4710, 755, '아래 상황에서 fetchProfile이 호출된 총 횟수는?', '```kotlin
@Composable
fun ProfileTab(userId: String) {
    var name by remember { mutableStateOf("") }
    LaunchedEffect(Unit) {
        name = api.fetchProfile(userId).name
    }
    Text(name)
}
```

ProfileTab이 userId = u1로 처음 그려졌다. 이어서 상위에서 userId가 u2로 바뀌어 재구성이 일어났고, 잠시 뒤 사용자가 다른 탭으로 옮겨 ProfileTab이 컴포지션에서 빠졌다. 다시 ProfileTab 탭으로 돌아왔을 때 userId는 u2 그대로였다.', 'OBJECTIVE'),
       (4711, 755, '아래에서 설명하는 Compose 부수효과 API에 대한 설명으로 옳은 것은?', '이 API는 재구성이 화면에 성공적으로 적용된 직후에 실행된다. Compose가 소유하지 않은 외부 객체에 컴포지션의 현재 상태를 옮겨 놓을 때 쓰며, 분석 SDK에 사용자 속성을 넘기는 코드가 대표적인 쓰임이다.', 'OBJECTIVE'),
       (4712, 755, '아래 업로드 화면에 남은 로그의 원인과 해결 방향으로 옳은 것은?', '사진 업로드 화면에서 버튼의 onClick 람다 안에 scope.launch { uploader.upload(file) }를 두었다. scope는 컴포저블 본문에서 rememberCoroutineScope()로 얻은 것이다. QA 결과 업로드 중간에 뒤로 가기를 누른 경우에만 서버에 파일이 도착하지 않았고, 클라이언트에는 아래 로그가 남았다.

```
W/Upload: upload(file=IMG_2411.jpg) aborted at 41%
W/Upload: kotlinx.coroutines.JobCancellationException: StandaloneCoroutine was cancelled
```', 'OBJECTIVE'),
       (4713, 755, '아래 상황에서 컴포저블 본문에 직접 두어서는 안 되는 이런 동작을 가리키는 용어는?', '장바구니 화면 컴포저블 본문에 analytics.log("cart_view") 한 줄을 적었다. 사용자는 화면에 한 번 들어가 수량을 두 번 바꾸고 쿠폰을 한 번 적용했을 뿐인데, 분석 대시보드에는 같은 이벤트가 네 번 찍혀 있었다. 화면을 나갔다 다시 들어온 적은 없었다.', 'SUBJECTIVE'),
       (4714, 755, '아래 상황에서 GlobalScope.launch를 대신해 써야 할 Compose API의 이름은?', '채팅방 화면에 들어오면 서버에서 최근 메시지 50건을 한 번 받아 와야 한다. 컴포저블 본문에 api.loadMessages(roomId)를 그대로 적자 suspend 함수는 코루틴 안에서만 호출할 수 있다는 컴파일 오류가 났다. 임시로 GlobalScope.launch로 감싸자 컴파일은 통과했지만, 읽지 않은 배지 숫자가 바뀔 때마다 같은 요청이 서버 로그에 쌓였다. 게다가 방을 나간 뒤 도착한 응답이 이미 사라진 화면의 상태를 갱신하려다 크래시가 났다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4709
(12731, 4709, '키가 달라졌을 뿐 컴포저블은 살아 있으므로 블록은 다시 실행되지 않고 처음 등록한 콜백이 그대로 쓰인다.', '효과가 다시 도는 조건을 컴포지션 이탈로만 본 오해. 화면이 그대로여도 키로 준 값이 달라지면 그 자체가 정리 후 재실행의 조건이다.', false),
(12732, 4709, '블록이 먼저 다시 실행돼 새 콜백이 등록된 뒤 onDispose가 돌아 방금 등록한 콜백이 제거된다.', '정리와 재실행의 순서를 뒤집어 본 것. 이 순서라면 새 콜백이 곧바로 사라져 아무것도 남지 않는데, 실제로는 옛 콜백부터 거둬들인다.', false),
(12733, 4709, 'onDispose가 먼저 실행돼 등록돼 있던 콜백이 제거되고, 이어서 블록이 다시 실행돼 새 콜백이 등록된다.', '키가 바뀌면 이전 효과를 정리한 뒤 새 키로 다시 등록한다. 덕분에 어느 시점에도 살아 있는 콜백은 하나뿐이라 중복 등록이 생기지 않는다.', true),
(12734, 4709, 'onDispose는 컴포저블이 컴포지션에서 빠질 때만 실행되므로 이전 콜백이 남은 채 새 콜백이 하나 더 등록된다.', 'onDispose를 이탈 전용 정리 코드로 본 오해. 이탈할 때뿐 아니라 키가 바뀔 때도 실행되므로 콜백이 쌓이지 않는다.', false),

-- 문제 4710
(12735, 4710, '1번', '컴포지션에서 한 번 실행했으면 끝이라고 본 오해. 컴포지션에서 빠졌다 다시 들어오면 이전 실행 기록이 남지 않아 진입 시 다시 시작된다.', false),
(12736, 4710, '2번', '처음 진입에서 1번, 탭을 떠났다 돌아온 재진입에서 1번이다. 키가 Unit이라 userId가 u2로 바뀐 재구성에서는 다시 시작되지 않는다.', true),
(12737, 4710, '3번', '키에 넣지 않은 값이 바뀌어도 효과가 재시작된다고 본 오해. userId를 키로 주지 않았으므로 그 변경은 블록을 다시 돌리지 못한다.', false),
(12738, 4710, '4번', '재구성이 일어날 때마다 블록이 매번 실행된다고 본 오해. 그렇게 도는 것은 SideEffect이고, 키가 그대로면 이 블록은 실행 중인 코루틴을 이어 간다.', false),

-- 문제 4711
(12739, 4711, '컴포지션에 진입할 때 딱 한 번만 실행되므로 화면당 한 번이면 되는 초기화 코드를 두기 알맞다.', '실행 시점을 진입 한 번으로 본 오해. 재구성이 적용될 때마다 다시 실행되므로 한 번이면 되는 작업을 여기 두면 그만큼 반복된다.', false),
(12740, 4711, '블록 안에서 서버 응답을 기다리는 suspend 함수를 호출해 결과를 받아 둘 수 있다.', '코루틴 스코프를 열어 주는 API로 착각한 것. 이 블록은 코루틴이 아니어서 대기가 필요한 작업은 LaunchedEffect로 옮겨야 한다.', false),
(12741, 4711, '시작한 작업은 컴포저블이 컴포지션에서 빠질 때 자동으로 취소돼 사라진 화면을 건드리지 않는다.', 'LaunchedEffect의 취소 동작을 갖다 붙인 오개념. 이 API에는 취소라는 개념 자체가 없어 한 번 실행된 코드는 되돌아가지 않는다.', false),
(12742, 4711, '컴포저블이 화면에서 사라질 때 되돌릴 코드를 둘 자리가 없어 등록과 해제가 짝을 이루는 작업에는 맞지 않는다.', '이 API는 정리 블록을 반환하지 않아 해제 코드를 둘 곳이 없다. 리스너 등록처럼 해제가 따라야 하는 작업은 onDispose를 강제하는 DisposableEffect로 간다.', true),

-- 문제 4712
(12743, 4712, '그 스코프는 컴포저블이 컴포지션에서 빠질 때 함께 취소되므로, 화면보다 오래 살아야 하는 업로드는 viewModelScope나 WorkManager에서 시작해야 한다.', '로그의 취소 예외는 뒤로 가기로 화면이 컴포지션에서 빠지면서 스코프가 함께 끊긴 흔적이다. UI 수명에 묶인 스코프는 화면이 사라지면 취소되므로, 완료가 보장돼야 하는 작업은 화면 밖 스코프에서 시작한다.', true),
(12744, 4712, 'onClick 같은 콜백 안에서는 코루틴을 시작할 수 없으므로, 업로드 호출을 컴포저블 본문의 LaunchedEffect 블록으로 옮겨야 한다.', '콜백에서 코루틴을 시작하라고 있는 것이 rememberCoroutineScope다. 본문의 LaunchedEffect로 옮기면 버튼을 누르지 않아도 화면에 들어오는 순간 업로드가 시작된다.', false),
(12745, 4712, '업로드가 메인 스레드에서 실행돼 화면 전환 작업에 밀린 것이므로, 디스패처를 Dispatchers.IO로 바꾸면 끝까지 실행된다.', '취소는 스레드가 아니라 스코프의 수명 문제다. 디스패처를 바꿔도 스코프가 취소되면 그 위에서 돌던 작업은 함께 끊긴다.', false),
(12746, 4712, '스코프가 재구성마다 새로 만들어져 이전 작업을 놓친 것이므로, 스코프를 상위 컴포저블로 올려 한 번만 만들어 쓰면 된다.', 'rememberCoroutineScope로 얻은 스코프는 재구성에서 다시 만들어지지 않는다. 상위로 올려도 그 컴포저블이 이탈하는 순간 같은 취소가 일어난다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1526, 4713, '부수효과,부수 효과,사이드 이펙트,사이드이펙트,side effect,sideeffect,부작용', '컴포저블 함수의 범위 밖에서 관찰되는 상태 변화가 부수효과다. 로그 전송, 네트워크 호출, 리스너 등록이 모두 여기 해당한다. 컴포저블은 재구성마다 다시 실행되고 실행 횟수나 순서가 보장되지 않으므로, 본문에 이런 코드를 그대로 두면 첫 구성 1번과 재구성 3번을 합쳐 네 번 전송되는 식으로 의도와 어긋난다. 그래서 Compose는 이런 동작을 컴포지션 생명주기에 묶어 실행하는 LaunchedEffect, DisposableEffect, SideEffect를 따로 둔다. 이름이 비슷한 SideEffect는 그 가운데 하나인 API의 이름이고, 여기서 묻는 것은 특정 API가 아니라 동작 자체를 부르는 용어라는 점에서 구분해야 한다.'),
       (1527, 4714, 'LaunchedEffect,LaunchedEffect(),런치드 이펙트,런치드이펙트,론치드 이펙트,론치드이펙트', 'roomId를 키로 준 LaunchedEffect 블록은 컴포지션에 진입할 때 코루틴을 시작하고 컴포저블이 이탈하면 그 코루틴을 자동으로 취소한다. 그래서 배지 숫자처럼 키와 무관한 상태가 바뀌어 재구성이 일어나도 요청이 다시 나가지 않고, 방을 나간 뒤 도착한 응답이 사라진 화면을 건드리는 일도 없다. GlobalScope는 화면 수명과 아무 관계가 없어 두 문제를 모두 그대로 둔다. rememberCoroutineScope는 버튼 클릭 같은 콜백 안에서 코루틴을 시작할 때 쓰는 것으로, 컴포저블 본문에서 진입 시점에 한 번 실행해야 하는 이 상황과는 쓰임이 다르다.');

-- =====================================================
-- Lesson 913: 키 비교와 정리 시점으로 가려 쓰는 Compose 부수효과 API
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5657, 913, '아래 화면에서 unreadCount가 계속 바뀌는 동안 일어나는 일로 옳은 것은?', '```kotlin
class FeedRequest(val tab: String, val page: Int)   // data class가 아닌 일반 클래스

@Composable
fun FeedScreen(tab: String, unreadCount: Int) {
    var posts by remember { mutableStateOf(emptyList<Post>()) }
    LaunchedEffect(FeedRequest(tab, page = 1)) {
        posts = api.loadFeed(tab, page = 1)   // 응답까지 약 1초 걸린다
    }
    FeedList(posts, unreadCount)
}
```

FeedScreen은 tab = "home"인 채로 화면에 계속 떠 있다. 새 메시지가 이어서 들어와 상위에서 unreadCount가 0.5초마다 1씩 늘어나고, 그때마다 FeedScreen의 재구성이 정상적으로 끝난다.', 'OBJECTIVE'),
       (5658, 913, '아래 영상 화면에서 보고된 버그의 원인과 해결 방향으로 옳은 것은?', '```kotlin
@Composable
fun VideoPane(owner: LifecycleOwner, player: Player) {
    DisposableEffect(Unit) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_STOP) player.pause()
        }
        owner.lifecycle.addObserver(observer)
        onDispose { owner.lifecycle.removeObserver(observer) }
    }
    PlayerView(player)
}
```

VideoPane은 화면에 계속 떠 있는 채로, 상위 화면 구성이 바뀌면서 넘겨받는 owner만 A에서 B로 바뀌었다. 그 뒤 QA에서 다음 내용이 보고됐다.

- owner가 A였을 때는 A가 ON_STOP이 되면 영상이 멈췄다.
- owner가 B로 바뀐 뒤로는 B가 ON_STOP이 돼도 영상이 계속 재생된다.', 'OBJECTIVE'),
       (5659, 913, '아래 두 구현의 동작이 서로 달라지는 경우로 옳은 것은?', '```kotlin
// (가)
@Composable
fun TabHeader(tab: Tab, analytics: Analytics) {
    analytics.setUserProperty("currentTab", tab.name)
    TabTitle(tab)
}

// (나)
@Composable
fun TabHeader(tab: Tab, analytics: Analytics) {
    SideEffect { analytics.setUserProperty("currentTab", tab.name) }
    TabTitle(tab)
}
```

Analytics는 Compose가 관리하지 않는 외부 분석 SDK 객체다.', 'OBJECTIVE'),
       (5660, 913, '아래 요구 사항에 맞게 API를 짝지은 것으로 옳은 것은?', '| 기능 | 요구 사항 |
| --- | --- |
| (가) 검색 결과 | 검색어가 바뀔 때마다 suspend 함수로 서버에서 결과를 다시 받아 온다. |
| (나) 지도 | 화면에 있는 동안만 위치 리스너를 등록해 두고, 화면을 떠나면 반드시 해제한다. |
| (다) 상태 표시줄 | 화면이 다시 그려질 때마다 현재 테마의 어두움 여부를 Compose 밖의 시스템 UI 컨트롤러에 맞춰 둔다. |
| (라) 새로고침 버튼 | 사용자가 버튼을 누르면 suspend 함수로 목록을 다시 받아 온다. |', 'OBJECTIVE'),
       (5661, 913, '아래 코드의 빈칸에 들어갈 Compose API의 이름은?', '날씨 화면에서 콜백 방식의 WeatherClient로부터 현재 기온을 받아 그린다. 처음에는 상태 변수와 효과를 따로 두고 콜백 안에서 상태에 값을 넣었는데, 화면을 나간 뒤에도 콜백이 해제되지 않아 누수 경고가 떴다. 아래처럼 한 번의 호출로 바꾸자 코드가 절반으로 줄고 경고도 사라졌다.

```kotlin
@Composable
fun WeatherBadge(city: String, client: WeatherClient) {
    val temp by ________<Double?>(initialValue = null, city) {
        val listener = TempListener { celsius -> value = celsius }
        client.register(city, listener)
        awaitDispose { client.unregister(listener) }
    }
    Text(temp?.let { "$it°C" } ?: "불러오는 중")
}
```', 'SUBJECTIVE'),
       (5662, 913, '아래 상황에서 마지막에 인덱스 읽기를 감싼 Compose API의 이름은?', '상품 목록에서 사용자가 몇 번째 상품까지 봤는지 분석 서버에 남기려 한다. 이 화면은 스크롤 오프셋에 맞춰 헤더 그림자를 그리느라 스크롤 중 재구성이 매우 잦다.

1. 컴포저블 본문에서 listState.firstVisibleItemIndex를 읽어 바로 전송했다. 한 번 훑어 내리는 동안 인덱스는 0에서 20까지만 바뀌었는데 전송은 212건 쌓였다.
2. 전송 코드를 LaunchedEffect(listState) 안으로 옮겼다. 이번에는 화면에 들어올 때 0 한 건만 보내고, 그 뒤로는 스크롤해도 아무것도 보내지 않았다.
3. LaunchedEffect 안에서 인덱스 읽기를 한 API의 람다로 감싸고, 그 뒤에 distinctUntilChanged()와 debounce(300)를 이어 붙인 다음 collect에서 전송했다. 같은 스크롤에서 전송이 3건으로 줄었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5657
(15259, 5657, 'tab 값이 그대로라 같은 키로 판정되므로 요청은 처음 한 번만 나가고, 약 1초 뒤 피드가 채워진다.', '키를 필드 값으로 비교한다고 본 오해. 키는 equals로 비교하는데, equals를 재정의하지 않은 일반 클래스는 같은 객체일 때만 같다고 본다. 재구성마다 새 객체가 만들어지니 매번 다른 키가 된다.', false),
(15260, 5657, '재구성마다 다른 키로 판정돼 진행 중이던 요청이 취소되고 다시 시작되므로, 피드가 계속 비어 있다.', 'LaunchedEffect는 키가 바뀌면 실행 중이던 코루틴을 취소하고 새로 시작한다. 재구성마다 새로 만든 FeedRequest가 키로 들어가 0.5초마다 재시작되는데 응답은 1초 뒤에 오므로, 어느 요청도 posts에 값을 넣기 전에 취소된다.', true),
(15261, 5657, '재구성마다 요청이 하나씩 더 시작되고 이전 요청도 끝까지 실행돼, 응답이 올 때마다 피드가 덮어써진다.', '키가 바뀌면 코루틴이 쌓인다고 본 오해. 새 키로 다시 시작하기 전에 이전 코루틴을 취소하므로 요청이 동시에 여러 개 살아 있지 않고, 늦게 끝난 응답이 덮어쓸 일도 없다.', false),
(15262, 5657, '재구성마다 posts가 remember의 초기값인 빈 목록으로 돌아가, 요청은 한 번만 나가도 응답이 곧바로 지워진다.', 'remember를 재구성마다 새로 초기화되는 지역 변수로 본 오해. remember한 값은 컴포지션에 남아 있는 동안 재구성을 거쳐도 유지된다. 피드가 비는 까닭은 값이 지워져서가 아니라 요청이 끝나지 못해서다.', false),

-- 문제 5658
(15263, 5658, 'onDispose가 재구성마다 실행돼 옵저버가 붙자마자 떨어지므로, 해제 코드를 SideEffect 블록으로 옮겨야 한다.', 'onDispose를 재구성마다 도는 코드로 본 오해. 이탈하거나 키가 바뀔 때만 실행되는데 키가 Unit이라 재구성으로는 돌지 않는다. SideEffect에는 정리 블록이 없어 해제 코드를 둘 자리도 없다.', false),
(15264, 5658, '옵저버가 처음 전달받은 player를 붙잡고 있는 탓이므로, player를 rememberUpdatedState로 감싸면 된다.', '캡처 문제를 엉뚱한 값에서 찾은 오해. player는 바뀐 적이 없고, 이벤트가 오지 않는 까닭은 옵저버가 붙어 있는 대상이 여전히 A의 lifecycle이라서다. player를 감싸도 B에는 등록되지 않는다.', false),
(15265, 5658, '이 블록은 코루틴이 아니어서 ON_STOP 알림을 기다리지 못하므로, 같은 코드를 LaunchedEffect(Unit)로 옮겨야 한다.', '옵저버는 콜백으로 이벤트를 받으므로 코루틴이 필요 없다. LaunchedEffect(Unit)로 옮겨도 키가 그대로라 owner 변경에 반응하지 않고, 해제 코드를 둘 onDispose마저 사라진다.', false),
(15266, 5658, '키가 Unit이라 owner가 바뀌어도 효과가 다시 돌지 않아 옵저버가 A에 남아 있으므로, owner를 키로 넣어야 한다.', 'owner를 키로 주면 owner가 바뀔 때 onDispose가 A에서 옵저버를 떼고, 블록이 다시 실행돼 B에 새로 붙인다. 키가 Unit이면 처음 붙인 A에 그대로 매달려 있어 B의 ON_STOP을 받지 못한다.', true),

-- 문제 5659
(15267, 5659, '재구성이 도중에 취소돼 화면에 적용되지 못하면, (가)는 그 재구성의 탭 이름을 SDK에 보낼 수 있지만 (나)는 보내지 않는다.', '(나)의 블록은 재구성이 성공적으로 적용된 직후에만 실행된다. (가)는 본문이 실행되는 순간 바로 보내므로, 버려진 재구성에서 읽은 값도 SDK에 새어 나갈 수 있다.', true),
(15268, 5659, 'TabHeader가 화면에서 사라지면 (나)는 SDK에 넘긴 속성을 자동으로 되돌리지만 (가)는 그대로 남긴다.', 'SideEffect에 정리 단계가 있다고 본 오해. 이 API는 정리 블록을 두지 않아 이탈할 때 되돌리는 동작이 없다. 떠날 때 되돌려야 한다면 onDispose가 있는 DisposableEffect를 써야 한다.', false),
(15269, 5659, '재구성이 정상적으로 끝날 때마다 (가)는 속성을 다시 보내지만 (나)는 처음 진입할 때 한 번만 보낸다.', 'SideEffect를 진입 시 한 번 도는 초기화 블록으로 본 오해. 키 없이 매 성공적 재구성 후마다 실행되므로, 정상적으로 끝난 재구성에서는 (가)와 똑같이 매번 보낸다.', false),
(15270, 5659, 'tab이 그대로인 재구성에서는 (나)가 실행을 건너뛰지만 (가)는 재구성될 때마다 속성을 보낸다.', 'SideEffect가 읽은 값이 바뀌었는지 보고 실행 여부를 가린다고 본 오해. 이 API는 키를 받지 않아, 값이 같아도 재구성이 적용될 때마다 실행된다.', false),

-- 문제 5660
(15271, 5660, '(가) LaunchedEffect · (나) DisposableEffect · (다) SideEffect · (라) LaunchedEffect', '(라)가 어긋난다. LaunchedEffect는 컴포저블 본문에서만 부를 수 있어 onClick 안에 둘 수 없고, 본문에 두면 누르지 않아도 진입할 때 실행된다. 클릭에서 시작하는 코루틴은 rememberCoroutineScope로 연다.', false),
(15272, 5660, '(가) SideEffect · (나) DisposableEffect · (다) LaunchedEffect · (라) rememberCoroutineScope', '(가)와 (다)를 뒤바꿨다. SideEffect는 코루틴이 아니라 suspend 함수를 부를 수 없고, LaunchedEffect는 키가 그대로면 재구성마다 다시 돌지 않아 (다)처럼 매번 맞춰 두는 일에 맞지 않는다.', false),
(15273, 5660, '(가) LaunchedEffect · (나) DisposableEffect · (다) SideEffect · (라) rememberCoroutineScope', '(가)는 검색어를 키로 한 코루틴, (나)는 onDispose로 해제가 보장되는 등록, (다)는 매 성공적 재구성 후 외부 객체 동기화, (라)는 콜백에서 코루틴을 여는 스코프다. 실행 시점·정리 필요·suspend 여부가 모두 맞는다.', true),
(15274, 5660, '(가) DisposableEffect · (나) LaunchedEffect · (다) SideEffect · (라) rememberCoroutineScope', '(가)와 (나)를 뒤바꿨다. DisposableEffect 블록은 코루틴 스코프가 아니라 suspend 함수를 부를 수 없다. (나)처럼 등록과 해제가 짝을 이루는 작업은 onDispose 반환이 강제되는 DisposableEffect가 맡는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1842, 5661, 'produceState,produceState(),produce state,프로듀스스테이트,프로듀스 스테이트', 'produceState는 콜백이나 Flow처럼 Compose 밖에서 값이 들어오는 소스를 State로 바꿔 준다. 초기값과 키를 받아 내부에서 remember와 LaunchedEffect를 엮어 두므로, 블록 안에서 value에 대입한 값이 곧 화면이 읽는 상태가 된다. 키로 준 city가 바뀌거나 컴포지션을 떠나면 코루틴이 취소되면서 awaitDispose 블록이 실행돼 콜백 해제가 보장된다. 방향이 반대인 snapshotFlow(Compose 상태 → Flow)나, 이미 있는 Flow에만 붙일 수 있는 collectAsState와 구분해야 한다.'),
       (1843, 5662, 'snapshotFlow,snapshotFlow(),snapshot flow,스냅숏플로,스냅숏 플로,스냅숏플로우,스냅숏 플로우,스냅샷플로,스냅샷 플로,스냅샷플로우,스냅샷 플로우', 'snapshotFlow는 블록 안에서 읽은 Compose 상태를 지켜보다가 결과가 바뀔 때마다 값을 내보내는 Flow를 만든다. 그래서 스크롤 인덱스처럼 자주 바뀌는 상태에 distinctUntilChanged·debounce 같은 Flow 연산자를 붙여 처리 횟수를 줄일 수 있다. 1번처럼 본문에서 바로 보내면 재구성 횟수만큼 반복되고, 2번처럼 코루틴 안에서 상태를 한 번 읽기만 하면 그 순간의 값만 얻고 이후 변화는 따라가지 못한다. 반대 방향인 produceState(외부 소스 → State)나, Flow가 아니라 State를 돌려주는 derivedStateOf와 구분해야 한다.');
