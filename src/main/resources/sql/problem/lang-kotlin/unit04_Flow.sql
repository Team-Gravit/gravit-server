-- Unit: Flow (Unit ID: 199)
-- Chapter: Kotlin (Chapter ID: 19)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (625, 199, 'cold·hot 스트림과 버퍼링 전략'),
       (783, 199, 'flowOn 컨텍스트와 catch 범위'),
       (941, 199, 'Flow — 버퍼·공유 전략과 예외 재시도');

-- =====================================================
-- Lesson 625: cold·hot 스트림과 버퍼링 전략
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3929, 625, '아래 코드를 실행했을 때 콘솔에 찍히는 순서로 옳은 것은?', '```kotlin
fun nums(): Flow<Int> = flow {
    println("빌더 진입")
    for (i in 1..3) {
        emit(i)
    }
}

suspend fun main() {
    val f = nums().map {
        println("map $it")
        it * 10
    }
    println("준비 완료")
    f.collect {
        println("수집 $it")
    }
}
```', 'OBJECTIVE'),
       (3930, 625, '아래 코드를 실행했을 때 "GET /user" 로그가 출력되는 총 횟수는?', '```kotlin
val user: Flow<User> = flow {
    println("GET /user")
    emit(api.getUser())
}

val shared: SharedFlow<User> =
    user.shareIn(scope, SharingStarted.Eagerly, replay = 1)

scope.launch { user.collect   { header.render(it) } }
scope.launch { shared.collect { profile.render(it) } }
scope.launch { shared.collect { footer.render(it) } }
```

세 코루틴 모두 정상적으로 시작돼 값을 한 번씩 받는다고 가정한다.', 'OBJECTIVE'),
       (3931, 625, '아래 비교표를 근거로 판단할 때 옳지 않은 것은?', '| 항목 | StateFlow | SharedFlow (replay = 0) |
| --- | --- | --- |
| 초기값 | 생성할 때 반드시 지정 | 없음 |
| 새 수집자가 받는 값 | 구독하는 순간 현재 값 1개 | 구독 이후 방출된 값만 |
| 같은 값을 다시 대입 | 방출하지 않음 | 그대로 방출 |
| 수집자가 느릴 때 | 중간 값을 건너뛰고 최신 값만 전달 | 기본 설정에서는 방출이 대기 |', 'OBJECTIVE'),
       (3932, 625, '아래 코드를 실행했을 때 출력되는 줄과 순서로 옳은 것은?', '```kotlin
flow {
    for (i in 1..3) {
        delay(100)      // 100ms마다 한 개씩 방출
        emit(i)
    }
}
    .conflate()
    .collect { v ->
        delay(300)      // 값 하나를 처리하는 데 300ms
        println("처리 $v")
    }
```

방출 시각은 각각 100ms · 200ms · 300ms이고, 소비는 값을 받은 시점부터 300ms가 걸린다.', 'OBJECTIVE'),
       (3933, 625, '아래 상황에서 값을 0에서 1로 바꾼 MutableSharedFlow 생성 파라미터의 이름은?', '주문 화면 뷰모델이 토스트 이벤트를 MutableSharedFlow로 내보낸다. 사용자가 앱을 백그라운드로 내린 5초 동안 이벤트 3건이 방출됐고, 화면이 다시 올라와 수집을 시작했지만 토스트는 한 건도 뜨지 않았다. 생성 인자 하나를 0에서 1로 바꾸자 복귀 직후 마지막 이벤트 1건이 곧바로 화면에 떴다. extraBufferCapacity는 64, onBufferOverflow는 DROP_OLDEST로 그대로 두었다.', 'SUBJECTIVE'),
       (3934, 625, '아래 상황에서 started 인자로 지정한 SharingStarted 전략의 이름은?', '목록 화면 뷰모델이 repository.observeOrders()를 stateIn으로 감싸 화면 상태를 노출한다. 화면을 회전하면 수집자가 0.3초쯤 사라졌다가 곧바로 다시 붙는데, 그때마다 업스트림이 멈췄다 다시 시작돼 서버 호출이 새로 나갔다. started를 Eagerly로 바꾸니 회전 시 재호출은 사라졌지만 사용자가 화면을 떠난 뒤에도 업스트림이 계속 돌아 통신량이 늘었다. 결국 다른 전략에 5,000(밀리초)을 넘겨 두 문제를 한꺼번에 없앴다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3929
(10651, 3929, '빌더 진입 → map 1 → map 2 → map 3 → 준비 완료 → 수집 10 → 수집 20 → 수집 30', '중간 연산자를 붙이는 순간 값이 흐른다고 본 오해. `map`은 연산자 사슬만 만들 뿐, 종단 연산자인 `collect`가 호출되기 전에는 값을 하나도 흘리지 않는다.', false),
(10652, 3929, '빌더 진입 → 준비 완료 → map 1 → 수집 10 → map 2 → 수집 20 → map 3 → 수집 30', 'flow 빌더 블록이 Flow 객체를 만들 때 실행된다고 본 오해. 빌더 블록은 `collect` 시점에 비로소 실행되므로 "준비 완료"가 "빌더 진입"보다 먼저 찍힌다.', false),
(10653, 3929, '준비 완료 → 빌더 진입 → map 1 → 수집 10 → map 2 → 수집 20 → map 3 → 수집 30', '종단 연산자 `collect`가 호출돼야 빌더가 실행되고, 값 하나가 `map`을 거쳐 소비된 뒤에야 다음 값이 방출된다. 지연 실행과 값 단위 순차 실행이 함께 나타난 결과다.', true),
(10654, 3929, '준비 완료 → 빌더 진입 → map 1 → map 2 → map 3 → 수집 10 → 수집 20 → 수집 30', '연산자마다 세 값을 몰아 처리한다고 본 오해. Flow는 단계별 일괄 처리가 아니라 값 하나가 파이프라인 끝까지 간 뒤 다음 값을 방출한다.', false),

-- 문제 3930
(10655, 3930, '1회', '`shareIn`이 이 Flow를 쓰는 모든 수집을 하나로 묶는다고 본 오해. cold 원본을 직접 `collect`한 코루틴은 공유 대상이 아니라 자기 몫의 업스트림을 따로 실행한다.', false),
(10656, 3930, '2회', '`Eagerly`라 `shareIn`이 수집자와 무관하게 업스트림을 한 번 실행하고 두 수집자가 그 방출을 공유한다. 여기에 원본을 직접 collect한 코루틴 몫 한 번이 더해져 2회다.', true),
(10657, 3930, '3회', 'hot으로 바꿔도 수집자 수만큼 업스트림이 돈다고 본 오해. 공유 스트림의 두 수집자는 각자 실행하지 않고 같은 방출을 나눠 받는다.', false),
(10658, 3930, '4회', '`shareIn`의 실행 한 번에 더해 수집자마다 또 실행된다고 본 오해. 공유 스트림에는 수집자별 재실행이 없고, 재실행은 cold 원본을 직접 collect할 때만 일어난다.', false),

-- 문제 3931
(10659, 3931, '같은 내용의 상태 객체를 연달아 두 번 대입하면 StateFlow 수집자의 화면 갱신도 두 번 일어난다.', '표의 "같은 값을 다시 대입 → 방출하지 않음"에 정면으로 어긋나 거짓이다. equals가 같으면 방출이 억제되므로 갱신은 한 번에 그친다. 그래서 상태는 data class로 만들어야 한다.', true),
(10660, 3931, '화면 회전 뒤 다시 구독한 수집자는 StateFlow라면 새 방출이 없어도 마지막 화면 상태를 그릴 수 있다.', '새 수집자가 구독하는 순간 현재 값 1개를 받으므로 참이다. 항상 값 하나를 보유한다는 성질 덕에 화면 복원에 별도 재조회가 필요 없다.', false),
(10661, 3931, '수집자가 붙기 전에 SharedFlow (replay = 0)로 보낸 완료 알림은 나중에 붙은 수집자에게 도착하지 않는다.', '구독 이후 방출된 값만 받으므로 참이다. 화면이 백그라운드에 있는 동안 보낸 일회성 이벤트가 사라지는 흔한 원인이 바로 이 설정이다.', false),
(10662, 3931, '진행률처럼 값이 빠르게 바뀌면 StateFlow 수집자는 중간 단계 값을 일부 보지 못할 수 있다.', '느린 수집자에게는 중간 값을 건너뛰고 최신 값만 전달되므로 참이다. 모든 값을 빠짐없이 받아야 한다면 버퍼를 둔 SharedFlow 쪽을 골라야 한다.', false),

-- 문제 3932
(10663, 3932, '처리 3', '`conflate`가 최신 값만 남긴다는 말을, 처리에 들어간 값까지 버리는 것으로 본 오해. 100ms에 방출된 1은 소비자가 놀고 있던 참이라 곧바로 처리에 들어간다.', false),
(10664, 3932, '처리 1 → 처리 2 → 처리 3', '`conflate`를 값 손실이 없는 `buffer`로 본 오해. `buffer`라면 세 값을 모두 처리하지만 `conflate`는 밀린 값 중 최신 것만 남기고 나머지를 버린다.', false),
(10665, 3932, '처리 1', '밀린 값을 버리면서 스트림도 그대로 끝난다고 본 오해. 버려지는 것은 지나간 중간 값뿐이고, 가장 최근 값은 자리에 남아 소비자가 비는 즉시 처리된다.', false),
(10666, 3932, '처리 1 → 처리 3', '1을 처리하는 300ms 사이에 2와 3이 도착해 최신 값 3만 남고 2는 버려진다. 400ms에 1의 처리가 끝나면 소비자가 3을 받아 이어서 처리한다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1266, 3933, 'replay,리플레이', 'replay는 새 수집자가 구독하는 순간 되돌려 받는 최근 방출 값의 개수다. 0이면 구독 전에 나간 값이 어디에도 남지 않아, 수집자가 없던 동안의 이벤트는 그대로 사라진다. 이름이 비슷해 헷갈리는 extraBufferCapacity는 emit이 대기하지 않도록 여유 자리를 둘 뿐 새 수집자에게 다시 보내 주지는 않고, onBufferOverflow는 버퍼가 찼을 때 무엇을 버릴지 정하는 값이라 구분해야 한다. StateFlow가 구독 즉시 현재 값을 주는 것도 replay = 1에 중복 제거를 더한 구조로 보면 이해하기 쉽다.'),
       (1267, 3934, 'WhileSubscribed,SharingStarted.WhileSubscribed,WhileSubscribed(5000),WhileSubscribed(5_000),SharingStarted.WhileSubscribed(5000),와일서브스크라이브드', 'WhileSubscribed(timeout)은 첫 수집자가 붙을 때 업스트림을 시작하고, 마지막 수집자가 떠난 뒤 timeout이 지나야 멈춘다. 5초를 주면 화면 회전처럼 잠깐 끊겼다 다시 붙는 재구독은 같은 업스트림을 이어 쓰므로 서버 재호출이 없고, 사용자가 화면을 완전히 떠나면 5초 뒤 업스트림이 멈춰 통신도 끊긴다. Eagerly는 수집자와 무관하게 즉시 시작해 scope가 취소될 때까지 계속 돌고, Lazily는 첫 수집자에 시작하되 그 뒤로는 멈추지 않는다는 점에서 갈린다.');

-- =====================================================
-- Lesson 783: flowOn 컨텍스트와 catch 범위
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4877, 783, '아래 코드를 실행했을 때 출력되는 줄과 순서로 옳은 것은?', '```kotlin
flow {
    emit(1)
    emit(2)
    throw IllegalStateException("업스트림 실패")
}
    .onEach { println("onEach $it") }
    .catch { e -> println("catch ${e.message}") }
    .onCompletion { cause -> println("완료 cause=$cause") }
    .collect { println("수집 $it") }
```', 'OBJECTIVE'),
       (4878, 783, '아래 코드에서 (가)~(라)가 실제로 실행되는 컨텍스트를 짝지은 것으로 옳은 것은?', '```kotlin
// 아래 수집은 Dispatchers.Main 컨텍스트에서 시작한다.
flow {
    emit(readFile())         // (가)
}
    .map { parse(it) }       // (나)
    .flowOn(Dispatchers.IO)
    .map { toUiModel(it) }   // (다)
    .collect { render(it) }  // (라)
```', 'OBJECTIVE'),
       (4879, 783, '아래 관측 결과에 대한 설명으로 옳은 것은?', '같은 저장소 조회 파이프라인을 세 가지 방식으로 노출한 뒤, 수집자 A는 0초에 수집자 B는 3.5초에 구독을 시작해 각자 받은 값을 기록했다. 값 1~5는 구독 시각을 기준으로 1초·2초·3초·4초·5초에 하나씩 만들어지며, stateIn의 초기값은 표에서 제외했다.

| 노출 방식 | A가 받은 값 | B가 받은 값 | 저장소 조회 로그 |
| --- | --- | --- | --- |
| 일반 Flow | 1, 2, 3, 4, 5 | 1, 2, 3, 4, 5 | 2회 |
| stateIn으로 만든 StateFlow | 1, 2, 3, 4, 5 | 3, 4, 5 | 1회 |
| shareIn(replay = 0)으로 만든 SharedFlow | 1, 2, 3, 4, 5 | 4, 5 | 1회 |', 'OBJECTIVE'),
       (4880, 783, '아래 증상을 없애려면 표시된 갱신 문장을 무엇으로 바꿔야 하는가?', '```kotlin
val state = MutableStateFlow(0)

repeat(1000) {
    scope.launch(Dispatchers.Default) {
        state.value = state.value + 1   // 바꿔야 할 문장
    }
}

// 1000개 코루틴이 모두 끝난 뒤
println(state.value)   // 997, 1000, 993 ... 실행할 때마다 다르고 1000을 넘지 못한다
```', 'OBJECTIVE'),
       (4881, 783, '아래 로그에서 emit 간격이 벌어진 원인이 되는 스트림 처리 문제의 이름은?', '```
[생산] emit 1        00.000
[소비] 처리 1 시작   00.001
[소비] 처리 1 종료   00.301
[생산] emit 2        00.301
[소비] 처리 2 시작   00.302
[소비] 처리 2 종료   00.602
[생산] emit 3        00.602
```

생산 쪽 루프에는 delay도 sleep도 없고, buffer·conflate 같은 연산자나 별도의 큐도 끼워 넣지 않았다. 소비 블록 하나를 처리하는 데 300ms가 걸린다. 같은 파이프라인을 RxJava로 짤 때는 이 상황에 대비해 별도 전략을 지정해야 했지만, 이 코드에는 그런 설정이 한 줄도 없다.', 'SUBJECTIVE'),
       (4882, 783, '아래 로그 변화가 나타나도록 collect 대신 바꿔 쓴 수집 함수의 이름은?', '검색창에 "코", "코틀", "코틀린"을 200ms 간격으로 입력했다. 입력마다 검색 결과가 흘러오고, 소비 블록이 결과 하나를 그리는 데 500ms가 걸린다. 수집 함수 이름만 바꾸고 나머지 코드는 그대로 두었다.

바꾸기 전
```
렌더 시작 코
렌더 완료 코
렌더 시작 코틀
렌더 완료 코틀
렌더 시작 코틀린
렌더 완료 코틀린
```

바꾼 뒤
```
렌더 시작 코
렌더 시작 코틀
렌더 시작 코틀린
렌더 완료 코틀린
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4877
(13179, 4877, 'onEach 1 → 수집 1 → onEach 2 → 수집 2 → catch 업스트림 실패 → 완료 cause=java.lang.IllegalStateException', 'catch가 예외를 처리한 뒤에도 onCompletion은 원래 예외를 그대로 본다고 여긴 오해. catch 아래에 놓인 onCompletion에는 스트림이 정상 종료된 것으로 전달돼 cause에 null이 들어간다.', false),
(13180, 4877, 'onEach 1 → 수집 1 → onEach 2 → 수집 2 → catch 업스트림 실패 → 완료 cause=null', 'catch는 자기보다 위쪽에서 난 예외만 잡고, 잡은 뒤에는 스트림을 정상 완료로 마무리한다. 그래서 아래쪽 onCompletion의 cause는 null이다. 버퍼 연산자가 없어 값 하나가 onEach와 collect를 차례로 지난 뒤 다음 값이 방출된다.', true),
(13181, 4877, 'onEach 1 → onEach 2 → 수집 1 → 수집 2 → catch 업스트림 실패 → 완료 cause=null', '연산자마다 값을 몰아서 처리한다고 본 오해. buffer 같은 연산자가 없으면 값 하나가 파이프라인 끝까지 도달한 뒤에야 다음 emit이 일어나므로 onEach와 수집이 번갈아 찍힌다.', false),
(13182, 4877, 'onEach 1 → 수집 1 → onEach 2 → 수집 2 → 완료 cause=java.lang.IllegalStateException', 'catch가 collect 쪽 예외만 담당한다고 본 오해. catch는 업스트림 전용이라 flow 빌더가 던진 예외야말로 정확히 catch가 맡는 대상이고, 그래서 catch 줄이 출력된다.', false),

-- 문제 4878
(13183, 4878, '(가) IO · (나) IO · (다) Main · (라) Main', 'flowOn은 자기보다 위쪽에 놓인 연산자의 실행 컨텍스트만 바꾼다. 그래서 flow 블록과 그 위쪽 map은 IO에서, flowOn 아래의 map과 collect 블록은 수집을 시작한 Main에서 실행된다.', true),
(13184, 4878, '(가) IO · (나) IO · (다) IO · (라) IO', 'flowOn을 사슬 전체에 걸리는 설정으로 본 오해. flowOn은 놓인 위치에 따라 영향 범위가 정해지며, 아래쪽 연산자와 collect 블록은 수집을 시작한 컨텍스트를 그대로 쓴다.', false),
(13185, 4878, '(가) Main · (나) Main · (다) IO · (라) IO', 'flowOn을 아래쪽에 적용되는 withContext처럼 본 오해. 방향이 반대로, flowOn은 업스트림에만 작용하고 다운스트림은 건드리지 않는다.', false),
(13186, 4878, '(가) IO · (나) Main · (다) Main · (라) Main', 'flowOn이 값을 만드는 flow 블록 하나에만 걸린다고 본 오해. flowOn 위에 놓인 중간 연산자도 모두 바뀐 컨텍스트에서 실행된다.', false),

-- 문제 4879
(13187, 4879, 'StateFlow 행에서 B가 3부터 받은 것은 그때까지 나온 값 3건이 버퍼에 보관돼 있었기 때문이다.', 'StateFlow가 지나간 값을 모아 둔다고 본 오해. 항상 현재 값 한 개만 들고 있어 구독 순간의 값 3만 전달되고, 1과 2는 어디에도 남지 않는다.', false),
(13188, 4879, '일반 Flow 행의 조회가 2회인 것은 구독 시각이 달라서이므로, A와 B가 같은 시각에 구독했다면 조회는 1회로 합쳐진다.', '구독 시각이 겹치면 실행도 공유된다고 본 오해. cold Flow는 구독 시각과 무관하게 수집자마다 업스트림을 새로 실행하므로, 동시에 구독해도 조회 로그는 2회로 남는다.', false),
(13189, 4879, 'SharedFlow 행의 B도 구독 직후 그 시점의 현재 값을 한 번 받은 뒤 이어지는 값을 받았다.', 'StateFlow의 성질을 SharedFlow에 갖다 붙인 오해. replay가 0이면 되돌려 줄 값이 없어 구독한 뒤 방출된 값부터 받는다. 표에서 B의 목록이 4부터 시작하는 이유가 이것이다.', false),
(13190, 4879, '일반 Flow 행에서 B가 받은 1은 A가 받은 1과 다른 실행이 만든 값이므로, 두 수집자가 같은 시각에 같은 값을 본다고 볼 수 없다.', '조회 로그가 2회라는 것은 B의 구독이 업스트림을 따로 돌렸다는 뜻이다. B의 1은 3.5초 뒤에 새로 만들어진 값이라 두 화면에 뜨는 값은 시각이 어긋난다.', true),

-- 문제 4880
(13191, 4880, 'state.emit(state.value + 1)', '방출을 suspend 함수로 하면 갱신이 원자적이 된다고 본 오해. 값을 읽는 시점과 쓰는 시점이 그대로 나뉘어 있어, 두 코루틴이 같은 값을 읽으면 증가 한 번이 덮여 사라진다.', false),
(13192, 4880, 'state.tryEmit(state.value + 1)', '성공 여부를 돌려받으면 유실을 막을 수 있다고 본 오해. StateFlow의 tryEmit은 값 대입과 같은 일을 하고 읽고 더해 쓰는 순서도 같아서 증상이 그대로 남는다.', false),
(13193, 4880, 'state.update { it + 1 }', 'update는 현재 값을 읽어 계산한 뒤 그사이 값이 바뀌지 않았을 때만 반영하고, 바뀌었으면 새 값으로 다시 계산한다. 이 재시도 덕분에 동시 갱신에서도 증가가 사라지지 않는다.', true),
(13194, 4880, 'state.compareAndSet(state.value, state.value + 1)', '비교 후 교체를 한 번만 해도 충분하다고 본 오해. 실패했을 때 다시 시도하는 코드가 없어, 경합에서 밀린 갱신은 false만 돌려주고 조용히 버려진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1582, 4881, 'backpressure,back pressure,백프레셔,백 프레셔,배압,역압', 'Flow의 emit은 suspend 함수라 소비가 끝나야 다음 방출로 넘어간다. 로그에서 emit 2가 처리 1 종료 직후 시각에 찍힌 것이 그 증거로, 느린 소비자가 생산 속도를 되돌려 눌러 주는 backpressure가 suspend 하나로 해결된 셈이다. RxJava는 요청 개수를 주고받는 별도 프로토콜과 전략 설정으로 같은 문제를 다루지만, Flow는 코루틴의 중단·재개가 그 역할을 대신한다. 헷갈리기 쉬운 buffer·conflate는 생산자와 소비자를 다른 코루틴으로 떼어 내 이 자동 대기를 풀어 주는 연산자이지 backpressure 자체가 아니며, 값 하나가 파이프라인 끝까지 간 뒤 다음 값이 나가는 순차 실행은 이 대기가 겉으로 드러난 모습이다.'),
       (1583, 4882, 'collectLatest,collect latest,컬렉트 래티스트,컬렉트래티스트', '새 값이 도착하면 진행 중이던 소비 블록을 취소하고 새 값으로 다시 시작하는 수집 함수가 collectLatest다. 바꾼 뒤 로그에서 렌더 시작은 값마다 찍혔는데 렌더 완료는 마지막 값에서만 찍힌 것이, 소비 블록이 500ms를 채우지 못하고 중간에 취소됐다는 증거다. conflate는 밀린 값을 건너뛸 뿐 이미 시작한 처리는 끝까지 보내므로 렌더 완료가 중간에 사라지지 않고, buffer는 값을 하나도 버리지 않아 모든 렌더 완료가 찍힌다. 값이 아니라 그 값으로 만든 하위 Flow를 취소하는 flatMapLatest와도 구분해 둔다.');

-- =====================================================
-- Lesson 941: Flow — 버퍼·공유 전략과 예외 재시도
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5825, 941, '아래 코드에서 출력되는 총 소요 시간으로 가장 가까운 것은?', '```kotlin
fun main() = runBlocking {
    val ms = measureTimeMillis {
        flow {
            repeat(3) { i ->
                delay(100)        // 값 하나를 만드는 데 100ms
                emit(i)
            }
        }
            .buffer()             // 기본 용량 64
            .collect {
                delay(300)        // 값 하나를 처리하는 데 300ms
            }
    }
    println(ms)
}
```

코루틴 전환 비용 등 그 밖의 오버헤드는 무시한다.', 'OBJECTIVE'),
       (5826, 941, '아래 코드의 실행 결과로 출력되는 줄을 순서대로 모두 나열한 것은?', '```kotlin
class UiState(val count: Int)        // data class가 아니다

suspend fun main() = coroutineScope {
    val state = MutableStateFlow(UiState(0))
    val job = launch {
        state.collect { println("수집 ${it.count}") }
    }
    delay(50)                        // 수집자가 붙을 때까지 기다린다

    state.value = UiState(0)
    delay(50)
    state.value = UiState(1)
    delay(50)
    state.value = UiState(1)
    delay(50)
    state.value = UiState(0)
    delay(50)

    job.cancel()
}
```', 'OBJECTIVE'),
       (5827, 941, '아래 관측표를 바탕으로 판단할 때 옳지 않은 것은?', '같은 cold Flow를 shareIn(scope, started, replay = 0)으로 공유해 화면 하나에 연결했다. 업스트림은 실행이 시작된 뒤 1초마다 값을 하나씩 만든다. 공유 스트림은 0초에 만들었고, 화면은 3초에 구독을 시작해 9초에 떠났다가 12초에 다시 구독했다. started 자리에 세 설정을 하나씩 넣고 업스트림 로그를 기록한 결과가 아래 표다.

| started | 업스트림 시작 | 화면이 9초에 떠난 뒤 | 12초 재구독 직후 업스트림 |
| --- | --- | --- | --- |
| Eagerly | 0초 | 계속 돎 | 돌던 것을 그대로 이어 씀 |
| Lazily | 3초 | 계속 돎 | 돌던 것을 그대로 이어 씀 |
| WhileSubscribed(0) | 3초 | 9초에 중지 | 처음부터 새로 시작 |', 'OBJECTIVE'),
       (5828, 941, '아래 코드를 실행했을 때 콘솔 출력으로 옳은 것은?', '```kotlin
var attempt = 0

flow {
    attempt++
    println("요청 $attempt")
    if (attempt < 3) throw IOException("타임아웃")
    emit("데이터")
}
    .retry(2) { it is IOException }
    .catch { e -> println("catch ${e.message}") }
    .collect { v -> println("수집 $v") }
```', 'OBJECTIVE'),
       (5829, 941, '아래 예외를 없애려고 flow 대신 바꿔 쓴 Flow 빌더 함수의 이름은?', '목록 화면에서 아래 함수를 Dispatchers.Main으로 수집하자 첫 값이 화면에 닿기도 전에 예외가 터졌다.

```kotlin
fun load(ids: List<Int>): Flow<Item> = flow {
    withContext(Dispatchers.IO) {
        for (id in ids) emit(api.get(id))
    }
}
```

```
java.lang.IllegalStateException: Flow invariant is violated:
	Flow was collected in [MainCoroutineDispatcher], but emission happened in [Dispatchers.IO].
	Please refer to flow documentation or use flowOn instead
```

withContext 블록은 그대로 두고 빌더 이름만 바꾼 뒤 emit을 send로 고치자, 예외 없이 값이 모두 전달됐다. 바꾼 빌더는 callbackFlow와 달리 블록 끝에서 awaitClose를 요구하지 않는다.', 'SUBJECTIVE'),
       (5830, 941, '아래처럼 요청 로그가 줄어들도록 검색 파이프라인에 끼워 넣은 중간 연산자의 이름은?', '검색창 입력을 StateFlow로 받아 그대로 서버 검색에 넘기던 화면이다. 연산자 하나에 300(밀리초)을 넘겨 사슬 앞쪽에 끼웠더니 요청 로그가 아래처럼 달라졌다. 끼운 뒤에도 이미 나간 요청이 취소된 기록은 없다.

끼우기 전
```
[입력] 코             00.000
[요청] q=코           00.001
[입력] 코틀           00.120
[요청] q=코틀         00.121
[입력] 코틀린         00.250
[요청] q=코틀린       00.251
```

끼운 뒤
```
[입력] 코             00.000
[입력] 코틀           00.120
[입력] 코틀린         00.250
[요청] q=코틀린       00.550
[입력] 자바           02.000
[입력] 자바스크립트   02.200
[요청] q=자바스크립트 02.500
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5825
(15707, 5825, '약 400ms', '생산자와 소비자가 갈라지면 쌓인 값이 한꺼번에 처리된다고 본 오해. 버퍼는 값을 미리 받아 둘 뿐 소비 자체는 여전히 값 하나에 300ms를 쓰므로, 세 값을 겹쳐 처리할 수는 없다.', false),
(15708, 5825, '약 900ms', '버퍼가 생산 시간을 완전히 가려 준다고 본 오해. 첫 값이 나오는 100ms 동안은 소비자가 받을 값이 없어 그냥 기다리므로, 그 앞머리만큼은 줄어들지 않는다.', false),
(15709, 5825, '약 1,000ms', 'buffer가 생산자를 별도 코루틴으로 떼어 내 값이 100ms·200ms·300ms에 미리 쌓인다. 소비자는 100ms에 첫 값을 받아 300ms씩 쉬지 않고 세 번 처리하므로 100 + 900 = 1,000ms가 된다.', true),
(15710, 5825, '약 1,200ms', 'buffer를 붙여도 값 하나가 소비될 때까지 다음 생산이 멈춰 선다고 본 오해. 그 순차 실행((100+300)×3)을 끊으려고 두는 연산자가 바로 buffer다.', false),

-- 문제 5826
(15711, 5826, '수집 0 → 수집 1 → 수집 0', 'UiState가 data class인 줄 알고 값이 같으면 방출이 걸러진다고 본 오해. 중복 억제는 equals에 기대는데, 일반 클래스의 equals는 같은 객체인지만 보므로 새로 만든 인스턴스는 늘 다른 값 취급이다.', false),
(15712, 5826, '수집 0 → 수집 0 → 수집 1 → 수집 1 → 수집 0', 'data class가 아니라 equals가 객체 동일성만 보므로 네 번의 대입이 모두 새 값으로 방출된다. 여기에 구독하는 순간 받은 초기값 0이 앞에 붙어 다섯 줄이 찍힌다.', true),
(15713, 5826, '수집 0 → 수집 1 → 수집 1 → 수집 0', '새 수집자가 구독 순간 현재 값을 받는다는 점을 빠뜨린 오해. 구독 이후 방출만 받는 것은 replay = 0인 SharedFlow이고, StateFlow는 늘 들고 있던 현재 값 하나를 먼저 건넨다.', false),
(15714, 5826, '수집 0 → 수집 1', '중복 억제가 지금까지 나온 값을 모두 기억한다고 본 오해. StateFlow에 내장된 것은 직전 값하고만 견주는 distinctUntilChanged라, 값이 0에서 1을 거쳐 0으로 돌아오면 마지막 0도 방출된다.', false),

-- 문제 5827
(15715, 5827, 'Eagerly 행에서는 화면이 붙기 전인 1초·2초에 만들어진 값이 아무에게도 닿지 않고 사라졌다.', '0초에 시작해 1초마다 값을 만드는데 화면은 3초에야 붙었고, replay가 0이라 지나간 값을 보관할 자리도 없다. 수집자가 없는 동안의 방출이 그대로 버려진다는 점에서 참이다.', false),
(15716, 5827, 'Lazily 행은 화면이 9초에 떠난 뒤에도 업스트림이 계속 돌아, 아무도 받지 않는 값을 만드는 구간이 생긴다.', '이탈 뒤 중지가 없다고 기록된 행이라 참이다. 첫 수집자에 맞춰 늦게 시작하더라도 한번 시작하면 scope가 취소될 때까지 멈추지 않아, 화면이 없는 동안의 통신 비용이 그대로 남는다.', false),
(15717, 5827, '화면이 3초가 아니라 0초에 구독을 시작했다면, Lazily 행의 업스트림 시작 시각은 Eagerly 행과 같아진다.', 'Lazily의 기준은 시각이 아니라 첫 수집자가 붙는 순간이다. 구독이 0초였다면 3초가 아니라 0초에 시작해 Eagerly와 겹치므로 참이다. 이 표에서 둘이 갈린 것도 구독이 3초였기 때문이다.', false),
(15718, 5827, 'WhileSubscribed(0) 행은 12초에 화면이 돌아왔을 때 9초에 멈춘 업스트림을 그대로 이어 쓰므로, 업스트림이 새로 실행되지는 않는다.', '표의 마지막 열에 처음부터 새로 시작이라고 기록돼 있어 거짓이다. 한번 멈춘 업스트림은 이어 쓸 수 없고 cold Flow가 처음부터 다시 실행된다. 유예를 0으로 두면 짧은 이탈에도 재실행 비용이 드는 이유다.', true),

-- 문제 5828
(15719, 5828, '요청 1 → 요청 2 → 요청 3 → 수집 데이터', 'retry(2)는 실패한 업스트림을 최대 두 번까지 다시 실행한다. 세 번째 실행에서 attempt가 3이 돼 예외 없이 emit에 닿으므로, 아래쪽 catch는 받을 예외가 없어 한 줄도 찍지 않는다.', true),
(15720, 5828, '요청 1 → catch 타임아웃', 'retry의 람다를 재시도를 멈출 조건으로 뒤집어 본 오해. 이 람다는 true를 돌려줄 때 다시 시도하라는 뜻이라, IOException이면 재시도가 일어나 요청이 한 번으로 끝나지 않는다.', false),
(15721, 5828, '요청 1 → 요청 2 → catch 타임아웃', 'retry(2)를 업스트림을 통틀어 두 번 실행한다는 뜻으로 본 오해. 인자는 재시도 횟수라 첫 실행까지 합치면 최대 세 번 실행되고, 이 코드는 세 번째에서 성공한다.', false),
(15722, 5828, '요청 1 → 요청 2 → 요청 3 → 수집 데이터 → catch 타임아웃', 'retry가 삼킨 예외가 나중에 catch로도 전달된다고 본 오해. 재시도로 되살아난 스트림은 정상 스트림이라, 아래쪽으로 흘러갈 예외 자체가 남지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1898, 5829, 'channelFlow,채널플로우,채널 플로우,channel flow', 'flow 빌더는 수집이 시작된 컨텍스트에서만 방출해야 한다는 컨텍스트 보존 규칙을 지키며, 이를 어기면 예외 메시지처럼 Flow invariant is violated가 난다. channelFlow는 안쪽에 채널을 두고 send로 값을 넘기므로 다른 코루틴·다른 컨텍스트에서 보내도 이 규칙을 깨지 않는다. 경계를 함께 정리해 두자. flowOn은 업스트림 전체의 실행 컨텍스트를 바꾸는 연산자라, 빌더 안에서 withContext를 쓸 필요 자체를 없애는 쪽이다. callbackFlow는 channelFlow 위에 세운 특수형으로 콜백을 등록하고 해제해야 해서 블록 끝에 awaitClose가 필요하다. 생산 위치만 IO로 옮기면 될 때는 flowOn 한 줄이 더 싸고, 여러 갈래에서 동시에 값을 보내야 할 때 channelFlow를 고른다.'),
       (1899, 5830, 'debounce,디바운스,debounce(300),디바운스(300)', 'debounce(300)은 값이 들어와도 곧바로 흘려보내지 않고 다음 값이 300ms 안에 오는지 기다린다. 로그에서 요청 시각 00.550과 02.500이 각각 마지막 입력 00.250과 02.200보다 정확히 300ms 뒤인 것이 그 증거이며, 그사이 입력들은 뒤이은 입력에 덮여 서버까지 가지 않는다. 헷갈리는 이웃들과의 경계가 중요하다. sample(300)은 입력 간격과 무관하게 300ms 눈금마다 그때의 최신 값을 내보내므로 두 번째 묶음에서도 02.100·02.400 같은 시각에 요청이 나갔을 것이다. distinctUntilChanged는 값이 다르기만 하면 모두 통과시키니 요청 수가 줄지 않는다. collectLatest·flatMapLatest는 일단 요청을 내보낸 뒤 진행 중이던 작업을 취소하는 방식이라, 취소 기록이 없는 이 로그와는 맞지 않는다.');
