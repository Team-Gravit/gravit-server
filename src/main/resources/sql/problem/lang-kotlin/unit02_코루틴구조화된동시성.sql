-- Unit: 코루틴 구조화된 동시성 (Unit ID: 197)
-- Chapter: Kotlin (Chapter ID: 19)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (623, 197, '부모 자식 Job과 협력적 취소, 디스패처'),
       (781, 197, '스레드 차단과 병렬도 제한, 타임아웃'),
       (939, 197, '코루틴 구조화된 동시성 — 컨텍스트 상속, 실패 전파, 디스패처 포화');

-- =====================================================
-- Lesson 623: 부모 자식 Job과 협력적 취소, 디스패처
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3917, 623, '아래 코드의 실행 출력이 그렇게 나온 이유로 옳은 것은?', '```kotlin
val parent = scope.launch {
    launch { delay(500); println("자식 종료") }
    println("부모 본문 종료")
}
delay(100)
println("isActive=${parent.isActive}, isCompleted=${parent.isCompleted}")
```

실행 출력

```
부모 본문 종료
isActive=true, isCompleted=false
자식 종료
```', 'OBJECTIVE'),
       (3918, 623, '아래 코드에서 job.cancel 호출 이후에 벌어지는 일로 옳은 것은?', '```kotlin
val job = scope.launch(Dispatchers.Default) {
    var sum = 0L
    for (i in 1..2_000_000_000) { sum += i }
    println("합계=$sum")
}
delay(50)
job.cancel()
println("취소 요청 완료, isCancelled=${job.isCancelled}")
```

이 코루틴 안에는 delay, yield, ensureActive 같은 호출이 하나도 없다.', 'OBJECTIVE'),
       (3919, 623, '아래 비교표를 바탕으로 한 판단으로 옳지 않은 것은?', '| 디스패처 | 스레드 풀 | 권장 용도 |
|---|---|---|
| Dispatchers.Default | 코어 수만큼(최소 2개) 고정 | 정렬·파싱 등 CPU 집약 계산 |
| Dispatchers.IO | 필요 시 확장(기본 상한 64), Default와 스레드를 공유 | 파일·JDBC 등 블로킹 I/O |
| Dispatchers.Main | 플랫폼이 제공하는 UI 스레드 | 화면 갱신 |
| Dispatchers.IO.limitedParallelism(n) | 기존 풀 위에 씌운 뷰, 새 스레드 없음 | 동시 실행 수 제한 |', 'OBJECTIVE'),
       (3920, 623, '아래 상황에서 만들어진 코루틴에 대한 설명으로 옳은 것은?', '어떤 코루틴을 시작하면서, 스코프의 컨텍스트에 더해 그 자리에서 새로 만든 Job을 컨텍스트 인자로 함께 넘겼다. 그 결과 이 코루틴의 Job은 스코프가 들고 있던 Job의 자식 목록에 등록되지 않고, 인자로 넘어온 Job만을 부모로 삼게 되었다.', 'OBJECTIVE'),
       (3921, 623, '아래 증상을 없애려면 정리 코드를 감싸야 하는 코루틴 컨텍스트 원소의 이름은?', '```kotlin
val job = scope.launch {
    try {
        repeat(100) { delay(100) }
    } finally {
        delay(50)
        connection.close()
    }
}
delay(250)
job.cancel()
```

증상: job.cancel 이후 finally 블록에는 들어가지만, 첫 줄에서 곧바로 CancellationException이 다시 발생해 connection.close가 한 번도 실행되지 않는다. 반납되지 않은 커넥션이 쌓여 풀이 서서히 고갈된다.', 'SUBJECTIVE'),
       (3922, 623, '아래 코드의 빈칸에 들어갈 suspend 스코프 빌더 함수의 이름은?', '두 API를 한 번에 하나씩 호출하던 함수는 평균 1.6초가 걸렸다. 아래처럼 고치자 같은 작업이 평균 0.9초로 줄었고, 한쪽 호출이 예외를 던지면 다른 쪽 호출도 곧바로 취소된 뒤 그 예외가 호출자에게 다시 던져졌다.

```kotlin
suspend fun loadDashboard(): Dashboard = ______ {
    val profile = async { userApi.profile() }
    val orders = async { orderApi.recent() }
    Dashboard(profile.await(), orders.await())
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3917
(10619, 3917, '자식을 join으로 기다리지 않았으므로 부모는 자식을 추적하지 못하며, isActive는 스코프가 닫힐 때까지 계속 true로 남는다.', 'join은 자식을 등록하는 수단이 아니다. launch로 띄운 순간 이미 부모 Job의 자식으로 연결되므로, join을 부르지 않아도 부모는 자식을 기다린다.', false),
(10620, 3917, '부모는 본문 실행이 끝나도 아직 살아 있는 자식이 있으면 완료로 넘어가지 못하고 자식을 기다리는 활성 상태에 머문다.', '본문을 끝낸 부모는 Completing 상태로 가서 isActive=true, isCompleted=false를 유지한다. 500ms 뒤 자식이 끝나야 비로소 Completed가 된다.', true),
(10621, 3917, 'delay(100)이 부모 코루틴을 잠시 멈춰 세운 구간이라 그렇게 찍힌 것이며, 이 구간만 지나면 자식보다 먼저 완료로 표시된다.', 'delay(100)은 상태를 출력하는 바깥 흐름을 멈출 뿐 부모 코루틴을 멈추지 않는다. 자식이 남았는데 부모가 먼저 완료되는 일도 일어나지 않는다.', false),
(10622, 3917, '자식이 부모와 다른 스레드에서 실행되면서 Job 계층이 끊기므로, 부모의 완료 시점은 자식의 진행과 무관하게 정해진다.', '실행 스레드가 달라도 Job 계층은 그대로다. 계층이 끊기려면 컨텍스트로 새 Job을 넘겨야 하는데, 여기서는 부모-자식 연결이 그대로 유지된다.', false),

-- 문제 3918
(10623, 3918, 'cancel이 실행 중인 스레드를 인터럽트하므로 반복문이 그 자리에서 끊기고 합계는 출력되지 않는다.', '코루틴 취소는 스레드 인터럽트가 아니다. 취소 요청 플래그를 세울 뿐이라, 중단 지점이 없는 반복문은 아무 영향도 받지 않고 계속 돈다.', false),
(10624, 3918, 'Dispatchers.Default는 CPU 계산 전용 풀이라 취소 요청이 무시되고 isCancelled도 false로 남는다.', '디스패처 종류는 취소 플래그와 아무 관계가 없다. cancel을 부른 직후 isCancelled는 어떤 디스패처에서든 true가 된다.', false),
(10625, 3918, '반복문이 끝난 직후 println을 호출하는 지점에서 CancellationException이 던져져 합계는 출력되지 않는다.', '취소는 suspend 함수, 즉 중단 지점에서만 확인된다. println은 일반 함수라 취소 여부를 보지 않고 그대로 값을 찍는다.', false),
(10626, 3918, 'isCancelled는 곧바로 true가 되지만 반복문은 끝까지 돌아 합계까지 출력된 뒤에야 코루틴이 종료된다.', '취소는 협력적이라 delay나 yield 같은 중단 지점에 닿아야 CancellationException이 생긴다. 반복문 안에 ensureActive를 넣어야 실제로 멈춘다.', true),

-- 문제 3919
(10627, 3919, 'IO는 Default와 완전히 분리된 전용 풀을 쓰므로, 두 디스패처를 오갈 때마다 새 스레드를 만드는 비용이 붙는다.', '표에 IO가 Default와 스레드를 공유한다고 적혀 있다. 공유 덕분에 전환은 스레드를 새로 만들지 않고 이뤄져 비용이 낮다. 그래서 이 진술이 거짓이다.', true),
(10628, 3919, '커넥션이 10개인 데이터베이스 접근은 IO에 limitedParallelism(10)을 씌워 동시 실행 수를 자원 한계에 맞추는 편이 낫다.', '참. 이 뷰는 스레드를 새로 만들지 않고 동시 실행 수만 묶으므로, 커넥션 개수라는 실제 자원 한계를 코드에 그대로 표현할 수 있다.', false),
(10629, 3919, 'JDBC 호출을 Default에 올리면 코어 수만큼뿐인 스레드가 응답을 기다리며 묶여 다른 계산 작업까지 밀릴 수 있다.', '참. Default 풀은 코어 수만큼으로 고정돼 있어, 블로킹 호출이 그 자리를 차지하면 남은 CPU 작업이 실행할 스레드를 얻지 못한다.', false),
(10630, 3919, 'UI 스레드가 없는 서버 애플리케이션에서는 Main을 지정한 코루틴을 실행할 수 없다.', '참. Main은 플랫폼이 제공하는 UI 스레드에 묶여 있어, 그런 스레드가 아예 없는 서버 환경에서는 디스패처를 얻지 못한다.', false),

-- 문제 3920
(10631, 3920, '새 Job을 넘긴 순간 스코프의 나머지 컨텍스트 원소도 함께 버려져, 이 코루틴은 Dispatchers.Unconfined에서 실행된다.', '컨텍스트 합성은 같은 키를 가진 원소만 덮어쓴다. Job만 교체되고 디스패처나 코루틴 이름 등 나머지 원소는 스코프의 것을 그대로 물려받는다.', false),
(10632, 3920, '스코프가 자식으로 세지는 않지만 완료 대기만은 남아 있어, 스코프는 이 코루틴이 끝날 때까지 완료되지 못한다.', '완료 대기는 자식으로 등록된 Job에만 적용된다. 자식 목록에 없으면 스코프는 이 코루틴을 기다리지 않고 먼저 완료돼, 작업이 붕 뜬 채 남는다.', false),
(10633, 3920, '스코프를 취소해도 이 코루틴은 멈추지 않고 계속 실행되며, 안에서 터진 예외도 스코프 쪽으로 보고되지 않는다.', '취소 전파와 실패 보고는 모두 부모-자식 연결을 타고 흐른다. 연결이 끊기면 생명주기를 소유자와 묶는 구조화된 동시성의 이점이 통째로 사라진다.', true),
(10634, 3920, '자식 목록에서만 빠졌을 뿐 예외 전파 경로는 살아 있어, 이 코루틴이 실패하면 스코프의 형제 코루틴까지 함께 취소된다.', '예외 전파도 Job 계층을 따라간다. 부모가 다른 Job이므로 형제는 아무 영향을 받지 않고, 예외는 처리되지 못한 채 밖으로 새어 나간다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1262, 3921, 'NonCancellable,withContext(NonCancellable),Non-Cancellable,논캔슬러블,넌캔슬러블', '취소된 코루틴의 컨텍스트는 이미 취소 상태라, 그 안에서 suspend 함수를 부르면 그 자리에서 CancellationException이 다시 던져진다. 그래서 finally 첫 줄의 delay(50)에서 걸려 connection.close까지 가지 못한다. 정리 구간을 withContext(NonCancellable)로 감싸면 그 블록 동안만 취소되지 않는 Job으로 바뀌어 남은 suspend 호출을 끝까지 마칠 수 있다. 코루틴이 끝난 뒤 콜백을 받는 invokeOnCompletion이나 시간 제한을 거는 withTimeout과는 역할이 다르고, 이미 요청된 취소를 되돌리는 것도 아니다. 정리 구간만 예외적으로 보호하는 장치이므로 그 안에 오래 걸리는 작업을 넣으면 취소가 그만큼 늦어진다.'),
       (1263, 3922, 'coroutineScope,coroutine scope,코루틴스코프,코루틴 스코프', 'coroutineScope는 지금 실행 중인 코루틴 안에 자식 스코프를 열어, 그 안에서 async로 띄운 두 호출을 자식으로 묶고 모두 끝나야 반환한다. 그래서 두 호출이 겹쳐 실행돼 1.6초가 0.9초로 줄고, 자식 하나가 실패하면 나머지를 취소한 뒤 예외를 호출자에게 다시 던진다. 자식의 실패를 형제에게 옮기지 않는 supervisorScope와는 바로 이 지점에서 갈린다. withContext는 디스패처 같은 컨텍스트를 바꿔 블록을 실행하는 용도라 병렬 분기에 쓰는 함수가 아니고, runBlocking은 suspend 함수가 아니라 스레드를 붙잡고 기다리므로 suspend 함수 안에서 쓰면 안 된다.');

-- =====================================================
-- Lesson 781: 스레드 차단과 병렬도 제한, 타임아웃
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4865, 781, '아래 코드를 실행했을 때 출력되는 줄을 순서대로 이은 것은? (/ 는 줄바꿈)', '```kotlin
val parent = scope.launch {
    val a = launch { delay(300); println("A 완료") }
    launch { delay(300); println("B 완료") }
    delay(100)
    a.cancel()
}
parent.join()
println("done isCancelled=${parent.isCancelled}")
```

scope는 일반 Job을 가진 CoroutineScope이고, 세 코루틴 모두 예외를 던지지 않으며 중단 지점은 delay뿐이다.', 'OBJECTIVE'),
       (4866, 781, '아래 suspend 함수 load()가 반환되기까지 걸리는 시간에 가장 가까운 값은?', '```kotlin
suspend fun load(): Int = coroutineScope {
    val a = withContext(Dispatchers.IO) { delay(400); 1 }
    val b = async(Dispatchers.IO) { delay(600); 2 }
    val c = async(Dispatchers.IO) { delay(300); 3 }
    a + b.await() + c.await()
}
```

스레드·커넥션 경합은 없고, delay 외의 실행 시간은 무시한다.', 'OBJECTIVE'),
       (4867, 781, '아래 Job 상태표를 바탕으로 한 판단으로 옳지 않은 것은?', '| 상태 | isActive | isCompleted | isCancelled |
|---|---|---|---|
| Active | true | false | false |
| Completing | true | false | false |
| Cancelling | false | false | true |
| Completed | false | true | false |
| Cancelled | false | true | true |

Completing은 코루틴 본문을 끝낸 뒤의 상태이고, Cancelling은 취소 요청을 받은 뒤의 상태다.', 'OBJECTIVE'),
       (4868, 781, '아래 서버에서 응답 시간이 늘어난 원인으로 옳은 것은?', '요청 처리 스레드가 8개인 서버가 있다. 각 요청 핸들러는 suspend 함수 userApi.fetch()를 runBlocking { userApi.fetch() } 형태로 호출하며, fetch()는 평균 200ms 걸리는 네트워크 호출이다.

동시 요청이 8건일 때까지는 평균 응답이 210ms였는데, 9건째부터 평균 응답이 400ms를 넘어 계단처럼 뛰었다. 같은 구간에서 CPU 사용률은 5% 안팎에 머물렀다.', 'OBJECTIVE'),
       (4869, 781, '아래 코드의 빈칸에 들어갈 함수의 이름은?', '커넥션이 10개인 풀을 쓰는 JDBC 조회를 withContext(Dispatchers.IO)로 감싸 두었다. 평소에는 멀쩡하다가 요청이 몰리자 IO 디스패처의 스레드 50여 개가 한꺼번에 조회를 시도했고, ''connection is not available, request timed out after 30000ms'' 오류가 쏟아졌다. 아래처럼 디스패처를 한 번 감싸 10을 넘겨 준 뒤로는 오류가 사라졌고, 프로세스의 스레드 수는 전과 같았다.

```kotlin
val dbDispatcher = Dispatchers.IO.______(10)

suspend fun findUser(id: Long): User = withContext(dbDispatcher) {
    jdbcTemplate.queryForObject(...)
}
```', 'SUBJECTIVE'),
       (4870, 781, '아래 코드의 빈칸에 들어갈 함수의 이름은?', '상품 상세 화면은 2초 안에 새 데이터를 받지 못하면 직전에 저장해 둔 캐시를 보여 주기로 했다. 처음에는 withTimeout(2_000) { api.load() }로 감쌌는데, 응답이 늦은 요청마다 TimeoutCancellationException이 호출부까지 올라와 화면이 오류로 바뀌었다. 시간 제한을 2초로 그대로 둔 채 함수만 아래처럼 바꾸자 오류 화면 없이 캐시가 표시됐다.

```kotlin
val fresh: Product? = ______(2_000) { api.load() }
val shown = fresh ?: cache.load()
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4865
(13147, 4865, 'A 완료 / B 완료 / done isCancelled=false', 'delay는 취소를 확인하는 중단 지점이라, 중단 중이던 delay(300)가 취소 요청을 받으면 그 자리에서 CancellationException으로 깨진다. a는 300ms를 채우지 못하고 끝나므로 A 완료는 찍히지 않는다.', false),
(13148, 4865, 'B 완료 / done isCancelled=false', '취소는 Job 계층을 아래로만 타고 내려간다. 취소된 것은 a뿐이라 형제는 300ms를 채워 B 완료를 찍고, 자식의 CancellationException은 정상 종료로 취급돼 부모로 올라가지 않아 부모는 완료 상태로 끝난다.', true),
(13149, 4865, 'done isCancelled=true', '자식 하나를 취소하면 부모가 취소되고 형제까지 끊긴다고 본 오해. 부모와 형제까지 취소되는 것은 자식이 CancellationException이 아닌 다른 예외로 실패했을 때다.', false),
(13150, 4865, 'B 완료 / done isCancelled=true', '부모가 자식의 취소를 자기 취소로 기록한다고 본 오해. isCancelled는 그 Job 자신이 취소나 실패로 끝났을 때만 true이며, 자식 하나를 취소한 것은 부모의 종료 방식을 바꾸지 않는다.', false),

-- 문제 4866
(13151, 4866, '600ms', '세 호출이 모두 같은 시점에 시작해 가장 긴 600ms만 걸린다고 본 것. withContext는 블록이 끝나야 반환하므로 a 구간은 뒤의 두 호출과 겹치지 않는다.', false),
(13152, 4866, '700ms', 'withContext의 400ms 뒤에 async 중 짧은 300ms만 더한 값. await는 두 Deferred를 모두 기다리므로 겹쳐 도는 두 작업 중 긴 600ms가 기준이 된다.', false),
(13153, 4866, '1,000ms', 'withContext는 병렬 분기가 아니라 실행 환경 전환이라 그 자리에서 400ms를 다 쓰고 반환한다. 그 뒤 시작한 async 둘은 겹쳐 돌아 max(600, 300) = 600ms가 걸리므로 합이 약 1,000ms다.', true),
(13154, 4866, '1,300ms', '400+600+300을 모두 순차로 더한 값. async는 await를 부르는 시점이 아니라 호출되는 순간 이미 실행을 시작하므로 b와 c는 서로 겹쳐 돈다.', false),

-- 문제 4867
(13155, 4867, 'isCancelled가 true가 된 순간 isCompleted도 함께 true가 되므로, 취소를 요청한 뒤에는 Job이 이미 끝났다고 보고 자원을 정리해도 된다.', '표의 Cancelling 행은 isCancelled=true인데 isCompleted=false다. 취소 요청 뒤에도 finally 같은 정리 코드가 도는 구간이 남으므로 거짓이다. 끝난 시점을 알려면 isCompleted나 join 반환을 봐야 한다.', true),
(13156, 4867, 'isActive 값만으로는 코루틴이 본문을 실행 중인지 자식을 기다리는 중인지 가릴 수 없다.', '참. Active와 Completing은 세 플래그가 true/false/false로 똑같아 표의 값만으로는 구분되지 않는다. 자식이 남았는지는 children 같은 다른 정보로 확인해야 한다.', false),
(13157, 4867, 'isCompleted가 true인 행이 둘이므로, 완료했다는 사실만으로는 정상 종료인지 취소로 끝난 것인지 구분할 수 없다.', '참. Completed와 Cancelled가 모두 isCompleted=true다. 둘을 가르는 값은 isCancelled이므로, 종료 원인을 알려면 두 플래그를 함께 봐야 한다.', false),
(13158, 4867, 'Cancelling 구간에서는 isActive가 false이므로, 이 구간에 남은 정리 코드에서 isActive를 조건으로 삼은 반복문은 한 번도 돌지 않는다.', '참. 취소 요청이 들어오면 isActive는 곧바로 false로 내려간다. 그래서 정리 구간에 while (isActive) 형태의 루프를 두면 조건이 처음부터 거짓이라 본문이 실행되지 않는다.', false),

-- 문제 4868
(13159, 4868, '네트워크 응답을 기다리는 200ms 동안 CPU가 계속 계산에 쓰이므로, 코어가 모자라 9건째 요청부터 계산 순서를 기다리게 된다.', '응답 대기 구간은 CPU를 쓰지 않는다. 계산 자원이 병목이었다면 사용률이 치솟아야 하는데 5% 안팎에 머물렀으므로 이 설명과 맞지 않는다.', false),
(13160, 4868, 'runBlocking이 호출될 때마다 전용 스레드 풀을 새로 만들어, 요청이 늘수록 스레드 수가 불어나며 문맥 전환 비용이 병목이 된다.', 'runBlocking은 풀을 새로 만들지 않고 자신을 부른 스레드에서 이벤트 루프를 돌린다. 문맥 전환이 병목이었다면 CPU 사용률도 5%에 머물지 않는다.', false),
(13161, 4868, 'suspend 함수는 Dispatchers.Main에서만 재개될 수 있는데 서버에는 UI 스레드가 없어, 모든 재개가 한 줄로 직렬화된다.', '재개 스레드는 컨텍스트의 디스패처가 정하며 Main은 필수가 아니다. 서버에서도 Default나 IO에서 얼마든지 재개되므로 재개가 직렬화될 이유가 없다.', false),
(13162, 4868, 'runBlocking은 블록 안 코루틴이 끝날 때까지 호출한 스레드를 붙잡으므로, 처리 스레드 8개가 모두 응답 대기에 묶여 9건째 요청은 앞 호출이 끝나야 스레드를 얻는다.', '응답을 기다리는 동안 코루틴은 중단되지만 runBlocking을 부른 스레드는 풀려나지 않는다. 그래서 동시 처리 수가 스레드 수 8로 묶이고 그 뒤 요청은 200ms 단위로 밀린다. 진입점 밖에서 runBlocking을 피하는 이유다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1578, 4869, 'limitedParallelism,limited parallelism,리미티드 패럴리즘,리미티드패럴리즘', 'Dispatchers.IO.limitedParallelism(10)은 IO 풀 위에 동시 실행 수 상한 10을 씌운 뷰를 돌려준다. 새 스레드를 만들지 않으므로 프로세스의 스레드 수는 그대로이고, 이 디스패처로 들어온 코루틴이 한 번에 10개까지만 실행돼 커넥션 10개라는 실제 자원 한계를 코드로 표현하게 된다. 나머지 요청은 커넥션을 기다리다 타임아웃 나는 대신 디스패처 차례를 기다린다. 비슷해 보이는 kotlinx.coroutines.io.parallelism 시스템 프로퍼티는 IO 풀 전체의 스레드 상한을 바꾸는 전역 설정이라 다른 I/O 작업까지 영향을 받는다. 스레드를 새로 할당해 격리하는 newFixedThreadPoolContext와도 다르고, withContext는 실행 환경을 바꿀 뿐 동시 실행 수를 묶지 못한다.'),
       (1579, 4870, 'withTimeoutOrNull,with timeout or null,위드타임아웃오어널,위드 타임아웃 오어 널', 'withTimeoutOrNull은 제한 시간이 지나면 블록을 취소한 뒤 예외를 밖으로 던지지 않고 null을 돌려준다. 그래서 반환 타입이 Product?가 되고 엘비스 연산자로 캐시를 쓰는 대체 흐름을 바로 이어 붙일 수 있다. 같은 시간 제한을 걸지만 TimeoutCancellationException을 던지는 withTimeout과 갈리는 지점이 여기다. withTimeout으로 대체 값을 쓰려면 호출부에서 그 예외를 잡아야 하는데, CancellationException의 하위 타입이라 다른 취소와 섞여 처리가 지저분해진다. 두 함수 모두 시간이 지나면 블록 안 코루틴을 취소하며, 이 취소 역시 협력적이라 블록 안에 중단 지점이 없으면 제때 끊기지 않는다. 시간 제한 없이 결과만 기다리는 await나 스레드를 붙잡고 자는 Thread.sleep 기반 타이머와는 역할이 다르다.');

-- =====================================================
-- Lesson 939: 코루틴 구조화된 동시성 — 컨텍스트 상속, 실패 전파, 디스패처 포화
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5813, 939, '아래 코드에서 안쪽 launch로 시작된 코루틴에 대한 설명으로 옳은 것은?', '```kotlin
val scope = CoroutineScope(Dispatchers.Default + CoroutineName("scope"))

val outer = scope.launch(Dispatchers.IO) {
    launch(CoroutineName("inner")) {
        work()
    }
}
```

안쪽 launch에는 디스패처를 따로 지정하지 않았고, 어디에서도 예외는 발생하지 않는다.', 'OBJECTIVE'),
       (5814, 939, '아래 코드를 실행했을 때 벌어지는 일로 옳은 것은?', '```kotlin
val scope = CoroutineScope(Job() + Dispatchers.Default)

val a = scope.launch {
    try {
        delay(1_000)
        println("A 완료")
    } finally {
        println("A 정리")
    }
}
val b = scope.launch {
    delay(100)
    throw IllegalStateException("B 실패")
}
```

scope가 들고 있는 것은 일반 Job이며, 두 코루틴 어디에도 예외를 잡는 코드는 없다.', 'OBJECTIVE'),
       (5815, 939, '아래 배치 작업이 30초 넘게 진행되지 않은 원인으로 옳은 것은?', '코어가 4개인 장비에서 도는 배치 애플리케이션이다. 파일 100개를 읽어 파싱하는 작업을 아래처럼 띄웠다.

```kotlin
files.forEach { f ->
    scope.launch(Dispatchers.Default) {
        val text = f.readText()   // 블로킹 파일 읽기
        parse(text)               // CPU 계산
    }
}
```

진행이 멈춘 구간에서 스레드 덤프를 떴더니 DefaultDispatcher-worker-1부터 4까지 네 개가 모두 아래 모습이었다.

```
"DefaultDispatcher-worker-1" RUNNABLE
    java.io.FileInputStream.readBytes(Native Method)
    ...
"DefaultDispatcher-worker-4" RUNNABLE
    java.io.FileInputStream.readBytes(Native Method)
```

같은 구간에서 CPU 사용률은 3% 안팎이었고, 아직 실행을 시작하지 못한 코루틴이 96개 남아 있었다.', 'OBJECTIVE'),
       (5816, 939, '아래 표를 바탕으로 한 판단으로 옳지 않은 것은?', '| 함수 | 형태 | 호출부가 다음 줄로 넘어가는 시점 | 반환값 |
|---|---|---|---|
| launch | 일반 함수 | 호출 즉시 (블록은 따로 진행) | Job |
| async | 일반 함수 | 호출 즉시 (블록은 따로 진행) | Deferred<T> |
| coroutineScope { } | suspend 함수 | 블록 안 모든 자식이 끝난 뒤 | 블록의 마지막 값 |
| withContext(ctx) { } | suspend 함수 | 블록 실행이 끝난 뒤 | 블록의 마지막 값 |', 'OBJECTIVE'),
       (5817, 939, '아래 코드의 빈칸에 들어갈 스코프 객체의 이름은?', '상세 화면을 열고 닫기를 스무 번 반복한 뒤 로그를 보니, 이미 닫힌 화면을 위한 네트워크 요청 17건이 여전히 진행 중이었다. 그중 하나가 던진 예외는 어느 핸들러에도 잡히지 않고 그대로 사라졌다. 문제가 된 코드는 아래와 같았다.

```kotlin
fun load() {
    ______.launch { repository.fetch() }
}
```

빈칸을 화면 생명주기에 묶인 viewModelScope로 바꾸자 화면을 닫는 순간 남은 요청이 함께 취소됐다. 빈칸에 쓰던 이 이름은 @DelicateCoroutinesApi로 표시되어 있어 쓸 때마다 경고가 떴다.', 'SUBJECTIVE'),
       (5818, 939, '아래 코드의 빈칸에 들어갈 kotlinx.coroutines 함수의 이름은?', '```kotlin
val job = scope.launch(Dispatchers.Default) {
    var i = 0
    var sum = 0L
    while (i < 500_000_000) {
        ______()
        sum += i
        i++
    }
    println("계산 완료 sum=$sum")
}
delay(50)
job.cancel()
```

빈칸이 아예 없던 처음 코드는 job.cancel() 뒤에도 반복을 끝까지 돌아 "계산 완료"를 찍었다. 빈칸에 yield()를 넣자 취소는 곧바로 반영됐지만 같은 계산이 2.4초에서 9.1초로 늘었다. 같은 라이브러리의 다른 함수 하나로 바꾸자 취소는 그대로 곧바로 반영되면서 시간은 2.5초로 돌아왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5813
(15675, 5813, '안쪽 launch에 디스패처를 주지 않았으므로, 스코프를 만들 때 지정한 Dispatchers.Default 위에서 실행된다.', '컨텍스트는 스코프에서 곧바로 오는 것이 아니라 바로 위 부모 코루틴에게서 물려받는다. outer가 Dispatchers.IO로 바꿔 둔 뒤라 안쪽도 IO를 그대로 물려받는다.', false),
(15676, 5813, 'CoroutineName을 새로 넘긴 탓에 나머지 컨텍스트 원소가 모두 비워져, 아무것도 지정되지 않은 기본 상태로 되돌아간다.', '컨텍스트 합성은 같은 키를 가진 원소만 덮어쓰는 맵 연산이다. 이름만 inner로 바뀌고 디스패처처럼 키가 다른 원소는 물려받은 값이 그대로 남는다.', false),
(15677, 5813, '부모인 outer에게서 Dispatchers.IO를 물려받아 실행되고, 이름만 inner로 덮인 채 outer의 자식 Job으로 등록된다.', 'launch는 부모 컨텍스트를 물려받은 뒤 같은 키의 원소만 인자 값으로 덮고, 새 Job을 만들어 부모 Job의 자식으로 잇는다. 그래서 디스패처는 IO, 이름은 inner, 부모는 outer가 된다.', true),
(15678, 5813, '컨텍스트를 인자로 넘겨 시작했으므로 부모와의 연결이 끊겨, outer를 취소해도 안쪽 코루틴은 계속 실행된다.', '연결이 끊기는 것은 Job 원소 자체를 인자로 넘겼을 때다. CoroutineName은 Job과 키가 다르므로 부모 Job 자리는 그대로이고 취소도 정상적으로 전파된다.', false),

-- 문제 5814
(15679, 5814, 'b가 던진 예외는 b 안에서 끝나므로, a는 1,000ms를 채워 "A 완료"와 "A 정리"를 차례로 찍는다.', 'CancellationException만 정상 종료로 취급돼 위로 올라가지 않는다. IllegalStateException 같은 일반 예외는 부모 Job에 실패로 보고돼 계층 전체를 무너뜨린다.', false),
(15680, 5814, 'b의 예외가 부모 Job으로 올라가 스코프가 취소되고, delay 중이던 a도 함께 취소돼 "A 정리"만 찍힌다.', '자식이 일반 예외로 실패하면 부모가 취소되고 그 취소가 형제에게 내려간다. a는 중단 지점인 delay에서 CancellationException을 받아 본문을 멈추고 finally만 지나간다.', true),
(15681, 5814, 'a와 b는 서로 형제일 뿐이라 영향을 주고받지 않으며, 스코프는 a가 끝나는 1,000ms 뒤 정상 완료된다.', '형제끼리 직접 영향을 주지는 않지만 전파 경로가 부모를 거친다. b의 실패가 부모를 취소시키고 그 취소가 a로 내려가므로 스코프는 정상 완료가 아니라 취소로 끝난다.', false),
(15682, 5814, 'b의 실패로 a가 취소되면 finally 블록까지 건너뛰게 되어 "A 정리"도 찍히지 않는다.', '취소는 중단 지점에서 CancellationException을 던지는 방식이라 try의 finally는 평소처럼 실행된다. 다만 그 안에서 다시 suspend 함수를 부르려면 NonCancellable로 감싸야 한다.', false),

-- 문제 5815
(15683, 5815, 'launch를 100번 호출한 만큼 worker 스레드가 늘어나, 실제 작업보다 문맥 전환에 더 많은 시간이 쓰이고 있다.', 'launch는 스레드를 만드는 함수가 아니라 이미 있는 풀에 실행을 맡기는 함수다. 덤프에 잡힌 worker도 네 개뿐이고, 전환이 병목이라면 CPU 사용률이 3%에 머물 수 없다.', false),
(15684, 5815, 'Dispatchers.IO와 스레드를 공유하는 구조라, 다른 곳에서 돌던 I/O 작업이 Default의 스레드를 먼저 차지했다.', '두 디스패처가 스레드를 공유하는 것은 맞지만, 공유는 전환 비용을 낮추는 성질이지 자리를 빼앗기는 구조가 아니다. 덤프의 스레드도 모두 이 코드의 파일 읽기 지점에 서 있다.', false),
(15685, 5815, '파일을 읽는 동안에도 CPU 계산이 이어지므로 코어 네 개가 포화된 것이며, 남은 96개는 계산 차례를 기다리는 줄이다.', '블로킹 읽기는 커널의 응답을 기다릴 뿐 CPU를 쓰지 않는다. 계산이 포화됐다면 사용률이 100%에 가까워야 하는데 3% 안팎에 머물렀으므로 덤프와 지표 어느 쪽과도 맞지 않는다.', false),
(15686, 5815, '코어 수만큼만 있는 Default의 스레드 네 개가 모두 파일 읽기에 묶여, 대기 중인 코루틴이 올라탈 스레드가 남지 않았다.', 'Default는 CPU 계산용이라 스레드 수가 코어 수로 고정된다. 여기에 블로킹 호출을 올리면 계산도 하지 않으면서 자리만 차지해 풀 전체가 멈춘다. 이런 작업은 Dispatchers.IO로 보내야 한다.', true),

-- 문제 5816
(15687, 5816, 'withContext는 suspend 함수이므로, 컨텍스트를 바꾼 블록을 호출한 코루틴과 겹쳐 병렬로 돌릴 수 있다.', '표에서 withContext는 블록 실행이 끝난 뒤에야 호출부가 다음 줄로 넘어간다. 호출한 코루틴은 그동안 아무것도 못 하므로 겹쳐 도는 일이 없다. 병렬로 나누려면 async로 띄워야 한다.', true),
(15688, 5816, 'async로 띄운 두 호출은 서로 겹쳐 돌지만, 같은 일을 withContext로 두 번 감싸면 앞 블록이 끝난 뒤에야 뒤 블록이 시작된다.', '참. async는 호출 즉시 반환해 두 블록이 함께 진행되지만, withContext는 블록이 끝나야 넘어가므로 두 번 쓰면 걸린 시간이 그대로 더해진다.', false),
(15689, 5816, 'coroutineScope 블록을 빠져나온 시점에는 그 안에서 async로 띄운 작업이 모두 끝나 있다.', '참. 표의 조건대로 coroutineScope는 블록 안 모든 자식이 끝난 뒤에 넘어간다. 이 성질 덕에 함수가 반환되면 그 안에서 시작한 작업도 끝나 있다는 보장이 생긴다.', false),
(15690, 5816, 'launch의 반환값만으로는 블록이 계산한 결과를 받을 수 없고, 결과가 필요하면 async의 반환값에 await를 써야 한다.', '참. 표에서 launch가 돌려주는 Job은 완료 여부와 취소 수단만 준다. 계산한 값을 돌려받으려면 Deferred를 반환하는 async를 쓰고 await로 꺼내야 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1894, 5817, 'GlobalScope,global scope,글로벌스코프,글로벌 스코프', 'GlobalScope는 애플리케이션이 살아 있는 내내 유지되는 스코프라, 여기서 띄운 코루틴은 어떤 화면이나 요청에도 소속되지 않는다. 소유자가 없으니 화면을 닫아도 취소를 전파해 줄 부모가 없어 요청 17건이 그대로 남았고, 실패한 코루틴의 예외도 보고할 부모가 없어 조용히 사라진 것이다. 코틀린이 이 이름에 @DelicateCoroutinesApi를 붙여 경고를 띄우는 이유가 여기에 있다. viewModelScope나 lifecycleScope는 생명주기 소유자가 붙어 있어 화면이 사라질 때 스코프째 취소되므로 같은 증상이 나오지 않는다. 애플리케이션 전체 수명과 같이 가야 하는 작업이 정말 필요하다면 CoroutineScope(SupervisorJob() + Dispatchers.Default)처럼 소유자를 직접 만들어 두고 누가 취소할지 정해 두는 편이 낫다. 비슷해 보이는 coroutineScope는 지금 실행 중인 코루틴 안에 자식 스코프를 여는 suspend 함수라 역할이 다르다.'),
       (1895, 5818, 'ensureActive,ensureActive(),ensure active,coroutineContext.ensureActive()', 'ensureActive()는 현재 코루틴이 취소됐는지만 확인해, 취소 상태라면 그 자리에서 CancellationException을 던지고 아니면 아무 일도 하지 않고 돌아온다. 그래서 반복문에 넣어도 계산 시간이 2.4초에서 2.5초로 거의 그대로다. 취소는 협력적이라 중단 지점이 없는 CPU 반복문은 cancel() 요청을 알아채지 못하는데, 이 호출 하나가 그 확인 지점을 만들어 준다. yield()도 취소를 확인하지만 실행 차례를 디스패처에 돌려주는 일까지 하므로, 반복마다 부르면 재스케줄링 비용이 쌓여 9.1초까지 늘어난다. 차례를 넘겨야 할 이유가 없다면 ensureActive()가 맞다. isActive는 불리언 프로퍼티라 예외를 던지지 않으므로 while (isActive && i < n)처럼 조건문에 직접 넣어 써야 하고, delay(1) 같은 중단 함수를 대신 끼워 넣으면 취소는 감지되지만 반복마다 잠드는 시간이 붙어 훨씬 느려진다.');
