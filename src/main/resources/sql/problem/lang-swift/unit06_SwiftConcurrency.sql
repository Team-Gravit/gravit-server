-- Unit: Swift Concurrency (Unit ID: 225)
-- Chapter: Swift (Chapter ID: 22)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (651, 225, 'async let과 협력적 스레드 풀'),
       (809, 225, '중단 지점과 액터 상속, 취소 핸들러'),
       (967, 225, 'Swift Concurrency: 결과 순서·취소·실행 위치');

-- =====================================================
-- Lesson 651: async let과 협력적 스레드 풀
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4085, 651, '아래 코드에서 load()를 호출한 뒤 반환값을 받기까지 걸리는 시간은?', '각 호출의 소요 시간은 fetchUser() 0.4초, fetchNotices() 0.9초, fetchBanner() 0.6초이고 세 호출은 서로의 결과에 의존하지 않는다.

```swift
func load() async throws -> Dashboard {
    async let user    = fetchUser()
    async let notices = fetchNotices()
    async let banner  = fetchBanner()
    return try await Dashboard(user: user, notices: notices, banner: banner)
}
```', 'OBJECTIVE'),
       (4086, 651, '아래 비교표에 나온 두 가지 작업 생성 방식에 대한 설명으로 옳지 않은 것은?', '동기 코드에서 비동기 작업을 만드는 두 방식을 비교한 표다.

| 항목 | 방식 A | 방식 B |
|---|---|---|
| 액터 컨텍스트 상속 | 상속함 | 상속하지 않음 |
| 우선순위·작업 로컬 값 상속 | 상속함 | 상속하지 않음 |
| 만든 쪽 작업의 취소 전파 | 전파되지 않음 | 전파되지 않음 |
| 수명 | 만든 스코프가 끝나도 계속 실행 | 만든 스코프가 끝나도 계속 실행 |', 'OBJECTIVE'),
       (4087, 651, '아래 코드의 실행 결과가 이렇게 나온 이유로 옳은 것은?', '```swift
let task = Task {
    for i in 1...3 {
        heavyCompute()          // 취소 여부를 확인하지 않는 동기 계산, 1회 약 1초
        print("step \(i)")
    }
    print("finished")
}
try await Task.sleep(for: .milliseconds(100))
task.cancel()
print("cancel 호출")
```

실행 결과

```
cancel 호출
step 1
step 2
step 3
finished
```', 'OBJECTIVE'),
       (4088, 651, '아래 실행 모델에 대한 설명으로 옳은 것은?', 'Swift Concurrency의 비동기 함수는 CPU 코어 수만큼의 스레드로 구성된 협력적 스레드 풀 위에서 실행된다. 이 풀은 어떤 작업도 스레드를 오래 붙잡지 않는다는 약속 위에서 스레드를 돌려 쓰며, 세마포어 대기나 동기 sleep처럼 스레드를 붙잡는 호출은 금지에 가깝다.', 'OBJECTIVE'),
       (4089, 651, '아래 상황에서 팀이 도입한 표준 라이브러리의 동시성 도구 이름은?', '이미지 URL 목록을 받아 모두 내려받는 화면이 있다. 처음에는 for 반복문 안에서 URL 개수만큼 Task { }를 만들었는데, 사용자가 화면을 벗어나 상위 작업을 취소해도 다운로드가 끝까지 진행됐고 한 건이 실패해도 그 오류가 호출부로 올라오지 않았다. URL 개수는 서버 응답에 따라 매번 달라져 async let으로 미리 나열할 수도 없었다.

이 부분을 다른 도구로 바꾸자 상위 작업을 취소하면 진행 중이던 다운로드가 함께 멈췄고, 한 건의 실패가 나머지를 취소한 뒤 호출부로 전파됐다. 또 이 도구를 쓴 함수는 반환되는 시점에 모든 다운로드가 끝나 있음이 보장됐다.', 'SUBJECTIVE'),
       (4090, 651, '아래 코드의 밑줄 자리에 들어갈 표준 라이브러리 API의 이름은?', '서버 SDK가 completion 클로저로 결과를 돌려주는 legacyFetch만 제공해, 새로 만드는 화면의 async 함수 안에서는 이 호출에 await를 붙일 수 없었다. 아래처럼 표준 API 하나를 끼워 넣어 문제를 풀었다.

```swift
func fetchData() async throws -> Data {
    try await ______ { continuation in
        legacyFetch { data, error in
            if let error { continuation.resume(throwing: error) }
            else         { continuation.resume(returning: data!) }
        }
    }
}
```

처음 작성한 코드에서는 두 갈래가 모두 실행돼 resume이 두 번 불렸고, 실행 중 "SWIFT TASK CONTINUATION MISUSE ... tried to resume its continuation more than once" 경고가 찍혀 실수를 잡아낼 수 있었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4085
(11067, 4085, '0.4초', '가장 먼저 끝나는 자식만 기다리면 된다고 본 값이다. Dashboard를 조립하려면 세 결과가 모두 필요하므로 마지막 자식까지 기다려야 한다.', false),
(11068, 4085, '0.9초', '세 async let이 선언되는 순간 자식 작업이 동시에 시작되므로, 전체 시간은 가장 오래 걸리는 fetchNotices()의 0.9초가 결정한다.', true),
(11069, 4085, '1.5초', 'await에 도달할 때 비로소 작업이 시작된다고 보아 뒤의 두 호출 0.9초와 0.6초를 순차로 더한 값이다. async let은 선언 시점에 이미 자식을 시작해 둔다.', false),
(11070, 4085, '1.9초', '세 호출을 한 줄씩 try await로 순차 실행한다고 본 값(0.4+0.9+0.6)이다. async let은 시작을 앞당기고 await에서 결과만 모은다.', false),

-- 문제 4086
(11071, 4086, '방식 A를 @MainActor로 격리된 메서드 안에서 만들면 그 본문도 메인 액터에서 실행된다.', '표의 액터 컨텍스트 상속 행에서 그대로 따라 나오는 참인 설명이다. 만든 자리의 액터를 물려받으므로 UI 갱신 코드를 본문에 둘 수 있다.', false),
(11072, 4086, '방식 B로 만든 작업에 높은 우선순위가 필요하면 만들 때 직접 지정해야 한다.', '방식 B는 우선순위와 작업 로컬 값을 물려받지 않으므로 참이다. 아무것도 상속하지 않아 기본 우선순위로 시작하며 필요한 값은 명시해야 한다.', false),
(11073, 4086, '두 방식 모두 핸들을 보관해 두지 않으면 나중에 그 작업을 취소할 방법이 없다.', '수명과 취소 전파 행에서 따라 나오는 참인 설명이다. 스코프와 수명이 묶이지 않으므로 반환된 핸들의 cancel()을 직접 불러 줄 사람이 필요하다.', false),
(11074, 4086, '방식 A는 자신을 만든 작업이 취소되면 함께 취소되므로 별도의 취소 처리가 필요 없다.', '취소 전파 행과 정면으로 어긋나 거짓이다. 방식 A도 비구조적 작업이라 만든 쪽이 취소돼도 멈추지 않는다. 취소가 자동으로 내려가는 것은 async let·TaskGroup의 자식이다.', true),

-- 문제 4087
(11075, 4087, '취소 플래그만 세워졌을 뿐 작업 본문이 그 플래그를 한 번도 확인하지 않아 반복이 끝까지 실행됐다.', '협력적 취소라 cancel()은 강제 종료가 아니라 표시일 뿐이다. 반복문 안에 Task.isCancelled 확인이나 try Task.checkCancellation() 같은 지점을 두어야 스스로 멈춘다.', true),
(11076, 4087, 'Task로 만든 작업은 비구조적이라 취소 요청 자체를 받지 못하고 cancel() 호출이 무시된다.', '비구조적이라는 말은 수명이 만든 스코프와 묶이지 않는다는 뜻이지 취소를 받지 못한다는 뜻이 아니다. 취소 상태는 정상적으로 세워졌고 본문이 읽지 않았을 뿐이다.', false),
(11077, 4087, '취소는 다음 중단 지점에서 한 번만 전달되는데 이 작업에는 await가 없어 전달될 자리가 없었다.', '취소 상태는 한 번 세워지면 사라지지 않고 유지된다. 중단 지점이 없어도 Task.isCancelled로 언제든 읽을 수 있으므로, 전달될 자리가 없어서가 아니라 확인하지 않아서 끝까지 돈 것이다.', false),
(11078, 4087, '자식 작업이 없는 작업에는 취소가 적용되지 않아 부모 쪽 cancel() 호출이 효력을 잃었다.', '취소는 자식이 있어야 성립하는 개념이 아니다. 자식이 없어도 자기 자신의 취소 상태는 세워진다. 전파 대상이 없었던 것이 아니라 확인 지점이 없었던 것이 원인이다.', false),

-- 문제 4088
(11079, 4088, '큐를 만들 때마다 전용 스레드가 배정되므로 한 작업이 스레드를 붙잡아도 다른 작업은 새 스레드에서 진행된다.', 'GCD에서 큐마다 스레드가 늘어나 스레드 폭발로 이어지던 모델을 그대로 옮겨 온 오개념이다. 협력적 풀은 스레드 수를 코어 수에 묶어 두므로 붙잡힌 스레드는 손실이 된다.', false),
(11080, 4088, '중단된 비동기 함수는 결과가 준비될 때까지 자신이 쓰던 스레드를 계속 차지한 채 대기한다.', '중단(suspend)과 블로킹을 혼동한 것이다. 중단되면 지역 변수 같은 상태를 힙의 비동기 프레임에 저장하고 스레드를 반납해 다른 작업이 그 스레드를 쓰게 한다.', false),
(11081, 4088, '중단됐던 함수는 결과가 준비된 뒤 중단 전과 다른 스레드에서 이어서 실행될 수 있다.', '반납했던 스레드로 돌아온다는 보장이 없어 풀에서 비어 있는 스레드가 재개를 맡는다. 그래서 특정 스레드를 전제로 한 코드나 UI 갱신은 @MainActor로 격리해 두어야 한다.', true),
(11082, 4088, '풀의 스레드가 모두 대기에 묶여도 런타임이 스레드를 더 만들어 처리량을 유지해 준다.', '스레드를 더 만들어 주지 않기 때문에 블로킹을 금지하는 것이다. 모든 스레드가 대기에 묶이면 재개할 준비가 된 작업이 있어도 실행할 스레드가 없어 전체가 멈춘다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1318, 4089, 'TaskGroup,태스크 그룹,태스크그룹,task group,withTaskGroup,withThrowingTaskGroup,ThrowingTaskGroup,작업 그룹', '자식 작업 수가 실행 시점에 정해질 때 쓰는 구조적 동시성 도구가 TaskGroup(withTaskGroup·withThrowingTaskGroup)이다. 그룹 스코프를 벗어나는 시점에 모든 자식이 완료·취소되어 있고, 부모의 취소는 자식으로 내려가며 자식의 오류는 형제를 취소한 뒤 부모로 올라온다. 병렬 개수가 컴파일 시점에 고정이면 async let을 쓰고, Task { }는 동기 코드에서 비동기 세계로 들어가는 진입점에만 쓴다. 상황 속 증상(취소가 안 먹고 오류가 사라짐)은 Task { }가 비구조적이라 수명이 스코프와 묶이지 않는 데서 온다.'),
       (1319, 4090, 'withCheckedThrowingContinuation,with checked throwing continuation,checkedThrowingContinuation,체크드 스로잉 컨티뉴에이션', 'try await와 continuation.resume(throwing:)이 함께 쓰였으므로 오류를 던질 수 있는 withCheckedThrowingContinuation이다. 콜백으로만 결과를 주는 기존 API를 async 함수로 잇는 다리이며, continuation은 반드시 정확히 한 번만 resume해야 한다. Checked 계열은 이 규칙을 어기면 SWIFT TASK CONTINUATION MISUSE로 알려 주지만, 검사 비용을 없앤 withUnsafeContinuation 계열은 같은 실수를 알려 주지 않고 미정의 동작으로 이어진다. 오류를 던지지 않는 콜백이라면 withCheckedContinuation을 쓴다.');

-- =====================================================
-- Lesson 809: 중단 지점과 액터 상속, 취소 핸들러
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5033, 809, '아래 코드의 실행 로그와 소요 시간이 이렇게 나온 이유로 옳은 것은?', '```swift
func work(id: Int, seconds: Double) async throws -> Int {
    try await Task.sleep(for: .seconds(seconds))   // 취소되면 오류를 던짐
    if id == 1 { throw WorkError.failed }
    return id
}

func run() async {
    do {
        try await withThrowingTaskGroup(of: Int.self) { group in
            group.addTask { try await work(id: 1, seconds: 0.1) }
            group.addTask { try await work(id: 2, seconds: 5.0) }
            for try await value in group { print("수집 \(value)") }
        }
    } catch {
        print("catch: \(error)")
    }
    print("run 종료")
}
```

실행 로그 (run() 호출부터 끝까지 약 0.1초)

```
catch: failed
run 종료
```', 'OBJECTIVE'),
       (5034, 809, '아래 코드의 출력이 이렇게 갈린 이유로 옳은 것은?', 'Swift 5.7 이후의 기본 동작이며, 실행 위치를 바꾸는 업커밍 기능 플래그는 켜지 않았다.

```swift
@MainActor
final class ProfileScreen {
    let loader = ProfileLoader()

    func tapped() {
        Task {
            print("A", Thread.isMainThread)
            await loader.load()
        }
    }
}

final class ProfileLoader {          // 액터 격리가 없는 일반 클래스
    func load() async {
        print("B", Thread.isMainThread)
        _ = await fetchName()        // 네트워크 호출
        print("C", Thread.isMainThread)
    }
}
```

출력

```
A true
B false
C false
```', 'OBJECTIVE'),
       (5035, 809, '아래 비교표를 바탕으로 옳지 않은 것은?', '같은 앱에서 비동기 작업을 다루는 두 방식을 비교한 표다.

| 항목 | 방식 A | 방식 B |
|---|---|---|
| 비동기 결과 전달 | 완료 클로저(콜백)로 넘김 | 중단·재개 문법으로 순차 코드처럼 씀 |
| 오류 전달 | 콜백 인자에 담아 단계마다 직접 넘김 | 던지기 문법으로 호출부까지 자동 전파 |
| 취소 | 표준 지원이 사실상 없음 | 취소가 작업 트리를 따라 아래로 전파 |
| 스레드 | 큐를 만든 만큼 스레드가 늘어날 수 있음 | 코어 수만큼의 스레드 풀을 돌려 씀 |
| 데이터 경합 검출 | 실행 중에 붙이는 도구에 의존 | 컴파일 단계에서 검사 |', 'OBJECTIVE'),
       (5036, 809, '아래 실행 방식에 대한 설명으로 옳은 것은?', '비동기 함수가 결과를 기다려야 하는 지점에 이르면, 지역 변수를 비롯한 현재 상태를 힙에 마련된 프레임으로 옮겨 두고 쓰던 스레드를 반납한다. 기다리던 결과가 준비되면 풀에서 비어 있는 스레드 하나가 그 프레임을 되살려 다음 줄부터 이어서 실행한다.', 'OBJECTIVE'),
       (5037, 809, '아래 상황에서 팀이 바꿔 쓴 작업 생성 방식의 이름은?', '@MainActor로 격리된 뷰 모델 안에서 `Task { }`로 사진 40장의 축소본을 만들었더니, 작업이 도는 동안 목록 스크롤이 60fps에서 18fps까지 떨어졌다. 클로저 안의 코드는 한 줄도 고치지 않고 작업을 만드는 표현만 바꾸자 스크롤은 60fps를 유지했다. 대신 바꾼 쪽에서는 호출부가 심어 둔 작업 로컬 값(요청 추적 ID)이 비어 있었고, 우선순위도 호출부를 따라가지 않아 만들 때 직접 지정해야 했다.', 'SUBJECTIVE'),
       (5038, 809, '아래 상황에서 팀이 도입한 표준 라이브러리 함수의 이름은?', '업로드를 취소하면 서버에 올리던 임시 청크를 바로 지워야 한다. 처음에는 전송 루프 안에 `Task.isCancelled` 확인만 두었는데, 작업이 서버 응답을 기다리며 중단돼 있는 동안에는 그 확인 지점까지 가지 못해 취소 시각과 임시 청크 삭제 시각의 차이가 평균 24초였다. 표준 라이브러리 함수 하나로 전송 함수를 감싸 정리 코드를 함께 걸어 두자 같은 차이가 20ms 아래로 떨어졌다. 다만 이 정리 코드는 작업이 어느 지점에 있든 취소 즉시, 취소를 요청한 쪽 스레드에서 곧바로 불릴 수 있어 공유 상태를 건드릴 때는 별도 동기화가 필요했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5033
(13595, 5033, 'addTask로 넣은 자식은 for try await로 꺼내는 순간 시작되므로, 두 번째 자식은 시작도 못 한 채 버려졌다.', '자식 작업은 addTask로 추가하는 즉시 시작된다. 두 번째 자식도 이미 실행 중이었고, 형제의 오류로 취소돼 5초를 채우지 못했을 뿐이다.', false),
(13596, 5033, '자식 하나가 던진 오류가 남은 자식을 취소시킨 뒤 그룹 밖으로 올라와, 5초짜리 자식을 기다리지 않고 스코프가 끝났다.', '그룹 안에서 자식이 throw하면 형제 자식이 취소되고 오류는 호출부로 전파된다. Task.sleep이 취소를 감지해 곧바로 오류를 던지므로 5초를 기다리지 않고 0.1초 만에 끝난다.', true),
(13597, 5033, '그룹은 자식의 오류를 삼키고 빈 결과로 채우므로, catch 블록은 자식과 무관하게 for 루프가 끝난 뒤 실행됐다.', '오류를 삼켰다면 catch로 들어갈 일이 없다. 수집 로그가 하나도 없이 catch가 찍혔다는 것 자체가 오류가 for try await를 통해 그룹 밖으로 올라왔다는 증거다.', false),
(13598, 5033, '그룹을 벗어난 뒤에도 5초짜리 자식은 백그라운드에 남아 계속 실행되므로 스코프만 먼저 끝났다.', '자식이 부모 스코프보다 오래 살 수 없는 것이 구조적 동시성의 규칙이다. 그룹 스코프를 벗어나는 시점에 모든 자식은 완료되었거나 취소돼 있어 남아 도는 자식이 없다.', false),

-- 문제 5034
(13599, 5034, 'Task { }가 만들어진 자리의 액터를 물려받지 않아 클로저 본문부터 메인 밖에서 실행되기 때문이다.', 'Task { }는 만들어진 자리의 액터 컨텍스트를 물려받는다. 물려받지 않았다면 A도 false로 찍혔어야 한다. 상속하지 않는 쪽은 Task.detached다.', false),
(13600, 5034, 'await가 붙은 호출은 결과가 올 때까지 호출한 스레드를 붙잡고 있어, 메인 스레드가 잠긴 채로 판정이 뒤집히기 때문이다.', '중단과 블로킹을 혼동한 것이다. await는 상태를 저장하고 스레드를 반납한다. 스레드를 붙잡고 있었다면 오히려 B가 true로 찍혔을 것이다.', false),
(13601, 5034, 'async 함수는 호출될 때마다 전용 스레드를 새로 만들어 쓰므로 메인 스레드에서는 실행될 수 없기 때문이다.', '협력적 스레드 풀은 코어 수만큼의 스레드를 돌려 쓸 뿐 호출마다 스레드를 만들지 않는다. @MainActor로 격리된 async 함수는 메인에서 실행되므로 실행될 수 없다는 말도 성립하지 않는다.', false),
(13602, 5034, 'load()가 어떤 액터에도 격리되지 않은 async 함수라, 호출되는 순간 메인 액터를 벗어나 협력적 스레드 풀에서 실행되기 때문이다.', '액터 격리가 없는 async 함수는 호출자의 액터를 이어받지 않고 전역 협력적 스레드 풀로 넘어간다. 그래서 B와 C가 모두 false다. UI를 만지는 코드는 @MainActor로 격리해 두어야 한다.', true),

-- 문제 5035
(13603, 5035, '방식 B에서도 중간 단계 함수가 오류를 인자에 다시 담아 넘겨 주지 않으면 호출부는 실패 사실을 알 수 없다.', '표의 오류 전달 행과 정면으로 어긋나 거짓이다. 방식 B는 던지기 문법으로 호출부까지 자동 전파되므로 중간 단계가 손수 옮겨 담을 필요가 없다. 인자에 실어 나르는 쪽은 방식 A다.', true),
(13604, 5035, '방식 A로 만든 화면에서 사용자가 중간에 나가도 진행 중인 작업을 멈추려면 직접 플래그나 별도 장치를 만들어야 한다.', '취소 행에서 따라 나오는 참인 설명이다. 표준 취소 경로가 없으니 어디까지 진행했고 멈춰야 하는지를 애플리케이션 코드가 스스로 관리해야 한다.', false),
(13605, 5035, '방식 B에서 한 작업이 스레드를 오래 붙잡으면 남은 작업이 쓸 스레드가 줄어 전체 처리량이 떨어진다.', '스레드 행에서 따라 나오는 참인 설명이다. 풀의 스레드 수가 코어 수에 묶여 있어 한 자리가 막히면 그만큼 실행 여력이 사라진다. 동기 sleep이나 세마포어 대기를 피하는 이유다.', false),
(13606, 5035, '방식 A에서는 경합 버그가 테스트에서 재현되지 않으면 배포한 뒤에야 드러날 수 있다.', '데이터 경합 검출 행에서 따라 나오는 참인 설명이다. 실행 중에 붙이는 도구는 실제로 지나간 경로만 잡아내므로, 재현되지 않은 경합은 컴파일 단계 검사와 달리 놓친다.', false),

-- 문제 5036
(13607, 5036, '중단된 작업마다 스레드 하나가 대기 상태로 예약돼 있어, 동시에 기다리는 작업이 늘면 필요한 스레드 수도 함께 늘어난다.', '중단을 블로킹으로 오해한 것이다. 기다리는 동안 스레드는 반납되므로 대기 중인 작업 수와 스레드 수는 비례하지 않는다. 이 오해가 풀 안에서 세마포어로 기다리는 코드로 이어진다.', false),
(13608, 5036, '상태를 힙으로 옮기는 것은 값 복사라서, 중단 지점을 지난 뒤에는 중단 전에 쓰던 지역 변수를 다시 읽을 수 없다.', '상태를 옮겨 두는 목적이 바로 재개한 뒤에도 그대로 이어 쓰기 위해서다. 중단 전후로 지역 변수 값은 유지된다. 대신 그 사이에 공유 상태가 바뀔 수 있다는 점이 진짜 주의할 부분이다.', false),
(13609, 5036, '중단 앞뒤로 실행 스레드가 바뀔 수 있어, 스레드 지역 저장소나 스레드 단위로 소유권을 따지는 락에 기댄 코드는 중단 지점을 넘어가면 깨질 수 있다.', '재개를 맡는 스레드가 중단 전과 같다는 보장이 없다. 그래서 스레드에 값을 묶어 두거나 같은 스레드가 풀어야 하는 락을 await 너머로 들고 가면 값이 사라지거나 해제에 실패한다.', true),
(13610, 5036, '중단 지점은 컴파일러가 최적화하면서 알아서 넣어 주므로, 개발자는 어디서 멈출지 신경 쓰지 않아도 된다.', '중단 지점은 await로 코드에 드러나는 명시적 표시다. 어디서 멈출 수 있는지 읽어 낼 수 있어야 그 틈에 상태가 바뀔 가능성을 따질 수 있어서 문법으로 강제한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1634, 5037, 'Task.detached,Task detached,detached,detached task,detachedTask,디태치드 태스크,디태치드 태스크 생성,분리된 작업,분리된 태스크', '액터 컨텍스트·우선순위·작업 로컬 값을 하나도 물려받지 않는 작업 생성 방식이 Task.detached다. Task { }는 만들어진 자리의 액터를 물려받으므로 @MainActor 안에서 만들면 본문도 메인에서 돌아 스크롤이 밀린다. 바꾼 뒤 추적 ID가 비고 우선순위를 직접 지정해야 했던 것이 상속을 끊었다는 표시다. 다만 Task.detached도 비구조적이라 수명이 만든 스코프와 묶이지 않고 취소도 전파되지 않으니, 핸들을 보관해 직접 cancel()을 불러야 한다. 병렬 실행 자체가 목적이라면 수명과 취소가 보장되는 async let·TaskGroup을 먼저 고려한다.'),
       (1635, 5038, 'withTaskCancellationHandler,with task cancellation handler,taskCancellationHandler,task cancellation handler,취소 핸들러', '취소가 걸린 즉시 실행될 정리 코드를 작업 본문과 함께 걸어 두는 표준 함수가 withTaskCancellationHandler다. Task.isCancelled나 try Task.checkCancellation()은 작업 코드가 그 지점을 지나가야 취소를 알아차리므로, 응답을 기다리며 중단된 동안에는 반응이 늦는다. 24초가 20ms로 줄어든 차이가 여기서 온다. 경계도 함께 알아 두자. cancel()은 취소 플래그를 세우는 요청일 뿐 강제 종료가 아니고, checkCancellation()은 확인 지점에서 CancellationError를 던지는 쪽이다. 등록한 정리 코드는 취소를 요청한 쪽 스레드에서 곧바로 실행될 수 있으므로 무거운 작업이나 동기화 없는 공유 상태 접근을 넣으면 안 된다.');

-- =====================================================
-- Lesson 967: Swift Concurrency: 결과 순서·취소·실행 위치
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5981, 967, '아래 코드를 실행했을 때 출력되는 배열은?', '각 자식 작업은 전달받은 시간만큼 기다린 뒤 id를 돌려준다. 오류와 취소는 일어나지 않는다.

```swift
func delayedID(_ id: Int, seconds: Double) async -> Int {
    try? await Task.sleep(for: .seconds(seconds))
    return id
}

func collect() async -> [Int] {
    await withTaskGroup(of: Int.self) { group in
        group.addTask { await delayedID(1, seconds: 0.3) }
        group.addTask { await delayedID(2, seconds: 0.1) }
        group.addTask { await delayedID(3, seconds: 0.2) }
        var ids: [Int] = []
        for await id in group { ids.append(id) }
        return ids
    }
}

print(await collect())
```', 'OBJECTIVE'),
       (5982, 967, '아래 코드에서 사용자가 입력을 이어서 바꿨을 때 찍히는 로그로 옳은 것은?', '검색창에 글자를 칠 때마다 search(_:)가 불린다. 사용자가 "s" → "sw" → "swi"를 100ms 간격으로 입력한 뒤 손을 멈췄다. api.search는 불릴 때마다 "검색: {query}" 로그를 남긴다.

```swift
@MainActor
final class SearchViewModel {
    private let api = SearchAPI()
    private var searchTask: Task<Void, Never>?

    func search(_ query: String) {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await api.search(query)
        }
    }
}
```', 'OBJECTIVE'),
       (5983, 967, '아래 실행 위치 규칙에 대한 설명으로 옳은 것은?', 'Swift 6.2에는 빌드 설정에서 켤 수 있는 업커밍 기능이 추가되었다. 이 기능을 켜면 어떤 액터에도 격리되지 않은 async 함수가 전역 스레드 풀로 넘어가지 않고, 자신을 호출한 쪽의 액터에서 그대로 이어서 실행된다. 켜기 전처럼 항상 호출자의 액터를 벗어나 실행되게 하려면 함수에 @concurrent를 붙여 명시한다.', 'OBJECTIVE'),
       (5984, 967, '아래 코드가 앱을 멈추게 한 이유로 옳은 것은?', 'Swift 5 언어 모드로 빌드한 앱이다. 기존 동기 API를 유지하려고 아래 함수를 만들었는데, 6코어 기기에서 TaskGroup의 자식 작업 20개가 동시에 이 함수를 부르자 앱이 크래시 없이 영원히 멈췄다. 자식 작업이 2개일 때는 문제가 없었다.

```swift
func thumbnail(for id: Int) -> UIImage {        // 동기 함수
    let semaphore = DispatchSemaphore(value: 0)
    var image: UIImage?
    Task {
        image = await render(id)                 // 비동기 렌더링
        semaphore.signal()
    }
    semaphore.wait()
    return image!
}
```', 'OBJECTIVE'),
       (5985, 967, '아래 상황에서 컴파일 오류를 없애려고 사용한 작업 생성 방식의 이름은?', '@MainActor로 격리된 화면의 버튼 탭 핸들러 saveTapped()는 동기 함수다. 이 안에 `let result = await uploader.save(draft)`와 `statusLabel.text = result.message` 두 줄을 넣자 "''async'' call in a function that does not support concurrency" 컴파일 오류가 났다. 핸들러의 시그니처는 UIKit에 맞춰 정해져 있어 async로 바꿀 수 없었다.

두 줄을 클로저 하나로 감싸자 오류가 사라졌다. 클로저 안에서 찍은 Thread.isMainThread는 true였고, 우선순위도 핸들러를 따라 userInitiated로 잡혔다. 다만 화면을 닫아도 업로드가 계속돼, 반환된 핸들을 프로퍼티에 보관해 두었다가 화면이 사라질 때 직접 cancel()을 부르도록 고쳤다.', 'SUBJECTIVE'),
       (5986, 967, '아래 상황에서 개발자가 세 줄의 선언에 적용한 문법의 이름은?', '홈 화면은 서로 의존하지 않는 세 요청(프로필 0.5초, 추천 목록 1.1초, 공지 0.3초)의 결과를 모아 그린다. 처음에는 `let profile = try await fetchProfile()`처럼 세 줄을 차례로 기다려 화면이 뜨기까지 약 1.9초가 걸렸다.

세 줄의 선언 앞부분만 바꾸고, 결과를 쓰는 마지막 줄 한 곳에서 한꺼번에 try await를 붙이자 같은 화면이 약 1.1초 만에 떴다. 추천 목록 요청이 실패한 날에는 오류가 호출부로 올라왔고, 그때까지 끝나지 않은 요청은 취소됐다. 요청 개수가 늘 3개로 고정돼 있어 반복문이나 그룹 객체는 쓰지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5981
(16123, 5981, '[1, 2, 3]', 'addTask로 넣은 순서대로 결과가 모인다고 본 오개념이다. for await는 자식이 끝나는 순서대로 결과를 꺼내므로, 순서가 필요하면 id를 함께 돌려받아 나중에 정렬해야 한다.', false),
(16124, 5981, '[2, 3, 1]', '세 자식은 addTask 즉시 동시에 시작되고, for await는 먼저 끝난 자식부터 꺼낸다. 0.1초인 2, 0.2초인 3, 0.3초인 1 순으로 끝나므로 배열도 그 순서가 된다.', true),
(16125, 5981, '[]', '그룹이 자식을 백그라운드에 남겨 두고 바로 반환한다고 본 오개념이다. for await는 모든 자식의 결과를 꺼낼 때까지 돌고, 그룹 스코프는 자식이 모두 끝난 뒤에야 빠져나온다.', false),
(16126, 5981, '[3, 2, 1]', '나중에 넣은 자식이 먼저 처리된다고(스택처럼) 본 오개념이다. 결과 순서를 정하는 것은 넣은 순서가 아니라 각 자식이 끝나는 시각이다.', false),

-- 문제 5982
(16127, 5982, '검색: s, 검색: sw, 검색: swi', 'cancel()이 강제 종료가 아니니 세 작업이 모두 끝까지 돈다고 본 것이다. 강제 종료는 아니지만 Task.sleep이 취소를 감지해 일찍 깨고, 이어지는 guard가 취소 상태를 읽어 앞의 두 작업을 끝낸다.', false),
(16128, 5982, '검색: s', '처음 만든 작업이 살아남고 뒤의 작업이 밀려난다고 본 것이다. search가 불릴 때마다 새 작업을 만들기 전에 이전 핸들의 cancel()을 부르므로 취소되는 쪽은 앞선 작업이다.', false),
(16129, 5982, '아무 로그도 찍히지 않는다', '이전 작업의 취소가 새 작업에도 번진다고 본 것이다. Task { }로 만든 작업은 서로 독립된 비구조적 작업이라, 앞 작업을 취소해도 새로 만든 작업의 취소 상태는 그대로다.', false),
(16130, 5982, '검색: swi', '"s"와 "sw" 작업은 300ms를 채우기 전에 다음 입력이 cancel()을 불러 Task.sleep이 일찍 깨고 guard에서 빠져나간다. 마지막 "swi" 작업만 취소되지 않고 300ms를 채워 검색을 부른다.', true),

-- 문제 5983
(16131, 5983, '기능을 켜면 @MainActor 메서드가 부른 격리 없는 async 함수 속 무거운 계산이 화면을 멈추게 할 수 있다.', '호출자가 메인 액터이므로 격리 없는 함수도 메인에서 이어서 실행된다. 켜기 전에는 풀로 넘어가 화면에 영향이 없던 코드가 켠 뒤 버벅일 수 있어, 무거운 계산에는 @concurrent를 붙여 풀로 보내야 한다.', true),
(16132, 5983, '기능을 켜면 격리 없는 async 함수는 누가 호출하든 항상 메인 액터에서 실행된다.', '호출자의 액터를 메인 액터로 넓혀 본 오개념이다. 다른 액터에서 부르면 그 액터에서, 격리 없는 곳에서 부르면 격리 없는 채로 실행된다. 메인에서 도는 것은 호출자가 메인일 때뿐이다.', false),
(16133, 5983, '@concurrent를 붙인 함수는 @MainActor 메서드에서 호출하면 메인 스레드에서 실행된다.', '@concurrent의 뜻을 거꾸로 본 것이다. @concurrent는 호출자의 액터를 벗어나 전역 협력적 스레드 풀에서 실행하라는 표시라, 메인에서 불러도 메인 밖에서 돈다.', false),
(16134, 5983, '기능을 켜면 Task.detached로 만든 작업도 만든 자리의 액터를 물려받게 된다.', '이 기능은 격리 없는 async 함수가 어디서 실행되는지만 바꾼다. Task.detached는 여전히 액터 컨텍스트와 우선순위를 물려받지 않으며, 상속이 필요하면 Task { }를 쓴다.', false),

-- 문제 5984
(16135, 5984, 'Task { }가 호출한 스레드에서 곧바로 끝까지 실행돼, wait()에 이르기 전에 signal()이 이미 지나가 버렸다.', 'Task { }는 본문을 즉시 실행하지 않고 실행기에 예약만 한다. 또 세마포어는 먼저 온 signal()을 세어 두므로, 설령 먼저 불렸어도 wait()는 바로 통과해 멈추지 않는다.', false),
(16136, 5984, '렌더링 작업이 자식 작업의 취소 상태를 물려받아 중간에 멈추는 바람에 signal()이 불리지 않았다.', '본문 어디에도 취소가 없고, Task { }는 비구조적이라 만든 쪽의 취소를 물려받지 않는다. 자식이 2개일 때는 멀쩡했다는 점도 원인이 취소가 아니라 동시 호출 수임을 보여 준다.', false),
(16137, 5984, 'wait()가 풀의 스레드를 모두 붙잡아, signal()을 불러 줄 안쪽 작업이 실행될 스레드를 얻지 못했다.', '협력적 스레드 풀은 코어 수만큼만 스레드를 둔다. 자식 20개가 wait()로 스레드를 모두 막자 안쪽 Task가 돌 스레드가 없어 signal()이 영영 불리지 않았다. 2개일 때는 남는 스레드가 있어 풀렸다.', true),
(16138, 5984, '자식 작업이 늘자 런타임이 스레드를 계속 새로 만들어, 스레드 폭발로 스케줄링이 마비됐다.', '큐마다 스레드가 늘던 GCD 모델을 옮겨 온 오개념이다. 협력적 풀은 스레드를 더 만들지 않기 때문에, 막힌 스레드를 대신할 스레드가 없어 전체가 멈춘 것이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1950, 5985, 'Task,Task { },Task {},Task{},Task 이니셜라이저,Task init,태스크,unstructured task,비구조적 작업,비구조적 태스크', '동기 함수 안에서 비동기 코드로 들어가는 진입점이 Task { }다. 만들어진 자리의 액터 컨텍스트와 우선순위·작업 로컬 값을 물려받으므로, @MainActor 핸들러 안에서 만들면 본문도 메인에서 실행돼 statusLabel을 바로 고칠 수 있다(isMainThread가 true). 반면 Task.detached는 아무것도 물려받지 않아 메인 밖에서 돌고 우선순위도 직접 정해야 하므로 상황과 맞지 않는다. 또 Task { }는 비구조적 작업이라 수명이 핸들러 스코프와 묶이지 않아 화면을 닫아도 계속 돈다. 그래서 핸들을 보관해 직접 cancel()을 불러 줄 책임이 생긴다. async let·TaskGroup은 async 함수 안에서만 쓸 수 있어 동기 핸들러의 진입점이 될 수 없다.'),
       (1951, 5986, 'async let,asynclet,async-let,에이싱크 렛,어싱크 렛,비동기 let', '개수가 고정된 병렬 작업에 쓰는 구조적 동시성 문법이 async let이다. 선언하는 순간 자식 작업이 시작되고 결과를 쓰는 곳의 await에서 모으므로, 전체 시간은 세 요청의 합(1.9초)이 아니라 가장 긴 요청(1.1초)이 정한다. 자식은 선언한 스코프를 벗어나 살 수 없어, 오류가 올라오면 아직 끝나지 않은 요청은 취소된다. 요청 개수가 실행 시점에 달라진다면 TaskGroup을 쓰고, Task { }를 여러 개 만드는 방식은 취소와 오류 전파가 보장되지 않으므로 피한다.');
