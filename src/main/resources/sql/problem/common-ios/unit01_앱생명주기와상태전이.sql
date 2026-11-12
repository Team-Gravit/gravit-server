-- Unit: 앱 생명주기와 상태 전이 (Unit ID: 102)
-- Chapter: iOS (Chapter ID: 9)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (528, 102, '종료 콜백 누락과 델리게이트 역할 분리'),
       (686, 102, '실행 콜백 순서와 백그라운드 작업 선택'),
       (844, 102, '씬 연결 해제와 백그라운드 시간 한도');

-- =====================================================
-- Lesson 528: 종료 콜백 누락과 델리게이트 역할 분리
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3347, 528, '아래 저장 코드 배치에서 사용자가 겪게 될 문제로 옳은 것은?', '사용자가 글을 작성하던 중 홈으로 나갔고, 앱은 백그라운드에 머물다가 한참 뒤 메모리를 확보하려는 시스템에 의해 정리되었다. 이 앱의 저장 코드는 아래와 같이 배치되어 있다.

```swift
// AppDelegate.swift
func applicationWillTerminate(_ application: UIApplication) {
    DraftStore.shared.save(editor.text)   // 작성 중인 글 저장
}

// SceneDelegate.swift
func sceneWillResignActive(_ scene: UIScene) {
    GameClock.shared.pause()
}

func sceneDidEnterBackground(_ scene: UIScene) {
    Analytics.log("enter_background")     // 저장 호출 없음
}
```', 'OBJECTIVE'),
       (3348, 528, '아래 로그를 남기는 동안 앱이 거친 실행 상태 전이 순서로 옳은 것은?', E'한 씬(Scene)에서 기록된 콜백 호출 로그다. 이 구간에서 앱 프로세스는 한 번도 새로 만들어지지 않았고, `didFinishLaunchingWithOptions` 로그도 다시 찍히지 않았다.\n\n```\n10:02:11.402  sceneWillResignActive\n10:02:11.630  sceneDidEnterBackground\n--- 이후 약 3분간 아무 로그도 기록되지 않음 ---\n10:05:03.117  sceneWillEnterForeground\n10:05:03.240  sceneDidBecomeActive\n```', 'OBJECTIVE'),
       (3349, 528, '아래 비교표를 바탕으로 씬(Scene) 기반 앱에 대한 설명으로 옳지 않은 것은?', '| 항목 | AppDelegate | SceneDelegate |
|---|---|---|
| 담당 단위 | 프로세스 (앱당 1개) | UI 인스턴스인 씬 (여러 개 가능) |
| 시작 콜백 | `didFinishLaunchingWithOptions` | `scene(_:willConnectTo:options:)` |
| 종료·정리 콜백 | `applicationWillTerminate`, `didDiscardSceneSessions` | `sceneDidDisconnect` |', 'OBJECTIVE'),
       (3350, 528, '아래 앱 실행 상태에 대한 설명으로 옳은 것은?', '앱이 메모리에는 그대로 남아 있지만 어떤 코드도 실행되지 않는 상태다. 백그라운드로 내려간 앱은 짧은 유예 시간이 지나면 이 상태가 되며, 오디오 재생·위치 추적처럼 별도의 백그라운드 모드를 선언하지 않은 앱은 대부분 여기에 머문다.', 'OBJECTIVE'),
       (3351, 528, '아래 두 장면에서 앱이 공통으로 놓여 있던 실행 상태의 이름은?', '게임을 하던 중 전화가 걸려 와 통화 화면이 위에 뜨자, 게임 화면은 그대로 보이는데 아무리 두드려도 캐릭터가 반응하지 않았다. 앱 전환기를 열어 앱 카드가 축소된 순간에도 같은 일이 일어났다. 두 경우 모두 로그에는 `sceneWillResignActive`만 찍혔고 `sceneDidEnterBackground`는 찍히지 않았다.', 'SUBJECTIVE'),
       (3352, 528, '아래 상황에서 업로드를 이어 가려고 추가한 `UIApplication` 메서드의 이름은?', '사진 업로드가 80% 지점에 있을 때 사용자가 홈으로 나가자 전송이 4초 만에 끊겼다. 백그라운드 진입 콜백 첫 줄에 `UIApplication` 메서드 호출 한 줄을 추가하자 같은 업로드가 약 30초까지 이어져 대부분 완료되었다. 이 메서드가 돌려주는 `UIBackgroundTaskIdentifier` 값을 보관했다가 작업이 끝난 뒤 `endBackgroundTask(_:)`에 넘겨야 하며, 만료 핸들러에서 이를 빠뜨린 빌드는 시스템에 의해 강제 종료되었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3347
(9099, 3347, '앱이 Background로 내려가는 순간 `applicationWillTerminate`가 함께 호출되므로 글은 저장되지만, 씬이 여러 개면 마지막 씬의 내용만 남는다.', 'Background 진입 시 호출되는 것은 `sceneDidEnterBackground`다. 종료 콜백을 백그라운드 진입 알림으로 오해한 것으로, 이 코드에서는 저장이 아예 일어나지 않는다.', false),
(9100, 3347, '씬을 쓰는 앱에서는 AppDelegate 콜백이 모두 무시되므로, 같은 파일에 둔 SDK 초기화 코드까지 함께 실행되지 않는다.', '씬으로 위임되는 것은 UI 상태 전이 콜백뿐이다. `didFinishLaunchingWithOptions` 같은 프로세스 단위 콜백은 그대로 호출되므로 SDK 초기화는 정상 동작한다.', false),
(9101, 3347, 'Suspended 상태의 앱을 시스템이 정리할 때는 `applicationWillTerminate`가 호출되지 않아, 저장 코드가 한 번도 실행되지 못한 채 작성 중이던 글이 사라진다.', '앱이 살아 있는 동안 마지막으로 확실히 호출되는 콜백은 `sceneDidEnterBackground`다. 시스템이 Suspended 앱을 조용히 정리하면 종료 콜백은 오지 않으므로 저장 호출을 이 콜백으로 옮겨야 한다.', true),
(9102, 3347, '유예 시간이 끝나 Suspended로 넘어가기 직전에 `sceneWillResignActive`가 한 번 더 호출되는데, 그 안에 저장 코드를 넣지 않은 것이 원인이다.', 'Suspended로 넘어가는 시점에는 어떤 콜백도 오지 않는다. `sceneWillResignActive`는 Active에서 Inactive로 갈 때 호출될 뿐이라 마지막 저장 기회로 쓸 수 없다.', false),

-- 문제 3348
(9103, 3348, 'Active → Inactive → Background → Not Running → Background → Inactive → Active', '유예 시간이 지나면 곧바로 종료된다고 본 것. Not Running을 거쳤다면 프로세스가 새로 만들어져 `didFinishLaunchingWithOptions` 로그가 다시 남았어야 한다.', false),
(9104, 3348, 'Active → Inactive → Background → Suspended → Background → Inactive → Active', '`sceneWillResignActive`로 Inactive, `sceneDidEnterBackground`로 Background가 되고, 로그가 끊긴 3분은 코드가 멈춘 Suspended다. 복귀는 Background를 거쳐 `sceneWillEnterForeground`(Inactive) → `sceneDidBecomeActive`(Active) 순이다.', true),
(9105, 3348, 'Active → Background → Inactive → Suspended → Inactive → Background → Active', 'Inactive와 Background의 순서를 뒤집은 것. 화면이 사라지기 전에 이벤트 수신이 먼저 끊기므로 `sceneWillResignActive`가 `sceneDidEnterBackground`보다 앞선다.', false),
(9106, 3348, 'Active → Inactive → Suspended → Background → Inactive → Active', 'Suspended를 Background 앞에 둔 것. 코드가 제한적으로 도는 Background를 거친 뒤 유예 시간이 끝나야 코드가 완전히 멈춘 Suspended가 된다.', false),

-- 문제 3349
(9107, 3349, '아이패드에서 같은 앱의 창을 두 개 띄우면 `scene(_:willConnectTo:options:)`는 창마다 한 번씩 호출되지만 `didFinishLaunchingWithOptions`는 한 번만 호출된다.', '참인 진술이다. 시작 콜백이 프로세스 단위와 씬 단위로 나뉘어 있어, 프로세스는 하나여도 그 위에 씬은 여러 개 만들어질 수 있기 때문이다.', false),
(9108, 3349, '푸시 알림 토큰 등록처럼 창 개수와 무관하게 한 번만 해야 하는 초기화는 AppDelegate 쪽에 두는 것이 맞다.', '참인 진술이다. AppDelegate는 앱당 하나뿐인 프로세스 단위 객체라 창을 여러 개 열어도 중복 실행 걱정 없이 전역 초기화를 맡길 수 있다.', false),
(9109, 3349, '윈도우를 만들고 루트 뷰 컨트롤러를 붙이는 코드는 창마다 필요하므로 `scene(_:willConnectTo:options:)`에 둔다.', '참인 진술이다. 윈도우는 씬마다 하나씩 필요한 UI 자원이라, 씬이 연결되는 시점에 만들어야 창을 여러 개 띄울 수 있다.', false),
(9110, 3349, '사용자가 앱 전환기에서 창 하나를 닫아 `sceneDidDisconnect`가 호출되면 프로세스도 함께 끝나므로, 다시 열 때는 `didFinishLaunchingWithOptions`부터 시작한다.', '거짓이다. `sceneDidDisconnect`는 씬 하나가 해제될 때 오는 UI 단위 콜백이라 프로세스는 그대로 살아 있을 수 있다. 남은 창이 있으면 앱은 계속 실행 중이다.', true),

-- 문제 3350
(9111, 3350, '`UIApplication.State` 열거형에는 이 상태에 해당하는 값이 없어, 앱은 자신이 이 상태에 있다는 것을 스스로 확인할 수 없다.', '코드가 돌지 않는 상태는 앱이 스스로 관찰할 방법이 없다. 그래서 열거형에는 `active`·`inactive`·`background` 세 값만 있고 Not Running과 이 상태는 빠져 있다.', true),
(9112, 3350, '이 상태에 들어간 앱은 앱 전환기 목록에서 사라지므로, 사용자가 최근 앱 화면으로 다시 열 수 없다.', '앱 전환기에 카드가 남는 것은 씬 세션이 유지되기 때문이며 코드 실행 여부와는 무관하다. 카드가 보인다고 실행 중인 것도, 사라졌다고 메모리에서 내려간 것도 아니다.', false),
(9113, 3350, '이 상태로 넘어가기 직전에 `sceneDidDisconnect`가 호출되어 씬 정리 코드를 실행할 수 있다.', '`sceneDidDisconnect`는 사용자가 창을 닫거나 시스템이 씬 자원을 회수할 때 오는 콜백이다. 이 상태로 넘어가는 시점에는 어떤 콜백도 호출되지 않는다.', false),
(9114, 3350, '시스템이 이 상태의 앱을 정리하기 전에 `backgroundTimeRemaining`으로 남은 시간을 알려 주므로 종료 시점을 예측할 수 있다.', '`backgroundTimeRemaining`은 백그라운드 실행 시간이 남아 있을 때 참고하는 값이다. 이 상태의 앱은 아무 통보 없이 정리되므로 종료 시점을 미리 알 수 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1072, 3351, 'Inactive,Inactive 상태,비활성,비활성 상태,인액티브,인액티브 상태', '포그라운드에 남아 화면은 보이지만 이벤트 전달이 멈춘 상태가 Inactive다. 전화 수신·앱 전환기 노출·제어 센터 표시가 대표 장면이며, 이 전이에서 `sceneWillResignActive`가 호출된다. `sceneDidEnterBackground`가 찍히지 않았다는 점이 Background와 갈리는 결정적 단서다. 화면이 사라지고 제한적으로만 코드가 도는 Background, 메모리에만 남고 코드가 완전히 멈춘 Suspended와 구분해 두자.'),
       (1073, 3352, 'beginBackgroundTask,beginBackgroundTask(),beginBackgroundTask(_:),beginBackgroundTask(withName:expirationHandler:),beginBackgroundTask(expirationHandler:),UIApplication.shared.beginBackgroundTask', '`beginBackgroundTask`는 백그라운드로 내려간 앱이 시스템에 실행 시간을 조금 더 요청하는 메서드다. 4초 만에 끊기던 업로드가 30초 가까이 이어진 것이 그 효과이며, 반환된 `UIBackgroundTaskIdentifier`를 `endBackgroundTask(_:)`로 반납하지 않으면 앱이 강제 종료된다. 몇 분 이상 걸리는 전송은 이 메서드가 아니라 `URLSession` 백그라운드 세션이, 주기적 갱신은 `BackgroundTasks` 프레임워크가 맡는다.');

-- =====================================================
-- Lesson 686: 실행 콜백 순서와 백그라운드 작업 선택
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4295, 686, '아래 상황에서 사용자가 아이콘을 탭한 뒤 콘솔에 찍히는 콜백 순서로 옳은 것은?', '씬(Scene) 기반 앱 A는 아래 7개 콜백의 첫 줄에서 자기 이름을 콘솔에 출력한다.

- AppDelegate: `applicationWillTerminate`, `didFinishLaunchingWithOptions`
- SceneDelegate: `sceneDidBecomeActive`, `sceneWillResignActive`, `scene(_:willConnectTo:options:)`, `sceneDidEnterBackground`, `sceneWillEnterForeground`

사용자가 A를 쓰다가 홈으로 나간 뒤 다른 게임을 1시간 동안 했다. 그 사이 메모리가 부족해진 시스템이 Suspended 상태로 멈춰 있던 A를 종료했다. 이후 사용자가 홈 화면에서 A의 아이콘을 탭했다.', 'OBJECTIVE'),
       (4296, 686, '아래 코드가 들어간 앱에서 제어 센터가 열려 있는 동안 일어나는 일로 옳은 것은?', '`Info.plist`에 씬 설정(`UIApplicationSceneManifest`)이 들어 있어 SceneDelegate로 화면을 구성하는 게임 앱이다. 타이머 제어 코드는 AppDelegate에, 진행 상황 저장 코드는 SceneDelegate에 두었다. 게임 도중 사용자가 제어 센터를 열었다.

```swift
// AppDelegate.swift
func applicationWillResignActive(_ application: UIApplication) {
    GameClock.shared.pause()
}

func applicationDidBecomeActive(_ application: UIApplication) {
    GameClock.shared.resume()
}

// SceneDelegate.swift
func sceneDidEnterBackground(_ scene: UIScene) {
    ProgressStore.shared.save()
}
```', 'OBJECTIVE'),
       (4297, 686, '아래 작업 목록을 바탕으로 백그라운드 실행 방식에 대한 설명으로 옳은 것은?', '사용자가 홈으로 나간 뒤에도 마쳐야 하는 작업 세 가지다. 이 앱은 오디오·위치 같은 백그라운드 모드를 선언하지 않았다.

| 작업 | 예상 소요 시간 | 실행 시점 |
|---|---|---|
| A. 작성을 마친 메모 1건을 서버로 전송 | 약 3초 | 홈으로 나간 직후 한 번 |
| B. 1.5GB 강의 영상 내려받기 | 약 20분 | 홈으로 나간 직후 한 번 |
| C. 최신 기사 목록 미리 받아 두기 | 약 5초 | 앱을 열지 않은 동안 하루 여러 번 |', 'OBJECTIVE'),
       (4298, 686, '아래 설명에 해당하는 앱 실행 상태의 특징으로 옳은 것은?', '포그라운드에서 벗어나 화면에는 더 이상 보이지 않지만, 짧은 시간 동안은 앱 코드가 계속 실행되는 상태다. 사용자가 홈 화면으로 나가거나 다른 앱으로 전환하면 앱은 Inactive를 지나 이 상태로 들어온다.', 'OBJECTIVE'),
       (4299, 686, '아래 상황에서 토큰 확인 호출을 옮겨 넣은 콜백의 이름은?', '씬 기반 앱에서 로그인 토큰이 만료됐는지 서버에 확인하는 `SessionRefresher.refreshIfNeeded()`를 처음에는 SceneDelegate의 `sceneDidBecomeActive(_:)`에 넣었다. 그러자 사용자가 제어 센터나 알림 센터를 열었다가 닫을 때마다 확인 요청이 서버로 날아가, 한 사용자에게서만 하루 수백 건의 요청 로그가 쌓였다.

같은 SceneDelegate의 다른 콜백으로 이 호출을 옮기자 제어 센터·알림 센터를 여닫을 때의 요청은 모두 사라졌다. 반면 홈 화면에 나갔다가 몇 분 뒤 앱으로 돌아오는 경우에는 여전히 돌아올 때마다 요청이 한 번씩 남았다.', 'SUBJECTIVE'),
       (4300, 686, '아래 코드의 빈칸에 들어갈 속성 래퍼의 이름은?', 'SwiftUI로 만든 뉴스 앱에 원격 푸시를 붙이는 중이다. 처음에는 아래 AppDelegate 클래스만 만들고 `NewsApp`에는 아무것도 추가하지 않았는데, 기기에서 실행해도 `push token:` 로그가 한 번도 찍히지 않았고 `didFinishLaunchingWithOptions` 안에 둔 중단점에도 걸리지 않았다. `NewsApp` 안에 빈칸이 있는 선언 한 줄을 추가하자 앱을 켜자마자 중단점에 걸렸고 곧이어 토큰 로그가 찍혔다.

```swift
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("push token:", deviceToken.map { String(format: "%02x", $0) }.joined())
    }
}

@main
struct NewsApp: App {
    @________(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4295
(11627, 4295, '`sceneWillEnterForeground` → `sceneDidBecomeActive`', '종료 사실을 놓치고 메모리에 남아 있던 앱이 이어서 깨어난다고 본 것. 시스템이 A를 종료해 프로세스가 사라졌으므로, 새 프로세스를 만드는 `didFinishLaunchingWithOptions`부터 다시 시작한다.', false),
(11628, 4295, '`didFinishLaunchingWithOptions` → `scene(_:willConnectTo:options:)` → `sceneDidBecomeActive`', '포그라운드 진입 콜백은 백그라운드에서 돌아올 때만 온다고 본 것. 새로 실행할 때도 씬이 연결된 뒤 `sceneWillEnterForeground`를 거쳐야 `sceneDidBecomeActive`로 Active가 된다.', false),
(11629, 4295, '`didFinishLaunchingWithOptions` → `scene(_:willConnectTo:options:)` → `sceneWillEnterForeground` → `sceneDidBecomeActive`', 'Suspended 상태에서 종료된 앱은 다음 실행이 처음부터 시작된다. 프로세스 생성 → 씬 연결과 윈도우 구성 → 포그라운드 진입 → Active 순이다. 종료되는 순간에는 콜백이 오지 않아 `applicationWillTerminate`는 찍히지 않는다.', true),
(11630, 4295, '`didFinishLaunchingWithOptions` → `sceneWillEnterForeground` → `scene(_:willConnectTo:options:)` → `sceneDidBecomeActive`', '씬 연결을 포그라운드 진입 뒤로 미룬 것. 윈도우와 루트 뷰 컨트롤러는 `scene(_:willConnectTo:options:)`에서 먼저 구성되어야 하므로, 씬이 연결된 다음에야 포그라운드 진입 콜백이 온다.', false),

-- 문제 4296
(11631, 4296, '제어 센터가 열리는 순간 `applicationWillResignActive`가 호출되어 `GameClock`이 일시 정지된다.', 'AppDelegate가 여전히 화면 상태 전이를 받는다고 본 것. 씬을 쓰는 앱에서는 이 UI 콜백이 호출되지 않고 SceneDelegate의 `sceneWillResignActive`가 대신 호출되는데, 그 콜백이 구현되어 있지 않아 멈춤 코드가 실행되지 않는다.', false),
(11632, 4296, '제어 센터가 화면을 덮고 있는 동안에도 `GameClock`은 멈추지 않고 계속 흘러간다.', '씬 기반 앱에서 Active와 Inactive 사이의 전이는 SceneDelegate의 `sceneWillResignActive`·`sceneDidBecomeActive`로만 전달된다. AppDelegate에 둔 `pause()`는 불리지 않고, Inactive에서도 코드는 실행 중이라 타이머가 계속 돈다.', true),
(11633, 4296, '제어 센터가 열리면 앱이 Background로 전환되어 `sceneDidEnterBackground`의 저장 코드가 실행된다.', '제어 센터를 여는 것을 홈 이동과 같게 본 것. 제어 센터가 화면을 덮어도 앱은 포그라운드에 남은 채 이벤트만 받지 못하는 Inactive일 뿐이라 `sceneDidEnterBackground`는 호출되지 않는다.', false),
(11634, 4296, '제어 센터가 열리면 앱이 Suspended로 넘어가 `GameClock`을 포함한 모든 코드 실행이 멈춘다.', '이벤트를 받지 못하는 것을 코드 정지로 오해한 것. 제어 센터가 열려 있는 동안 앱은 Inactive라 코드가 계속 실행되며, Suspended는 Background에서 유예 시간이 끝난 뒤에야 들어가는 상태다.', false),

-- 문제 4297
(11635, 4297, 'A는 `beginBackgroundTask`로 실행 시간을 더 받아 두면 홈으로 나간 뒤에도 전송을 마칠 수 있다.', '`beginBackgroundTask`는 백그라운드 진입 뒤 대략 30초 안팎의 실행 시간을 더 받는 방식이다. 약 3초면 끝나는 A는 그 안에 충분히 마칠 수 있고, 끝나면 `endBackgroundTask`로 반납하면 된다.', true),
(11636, 4297, 'B는 `beginBackgroundTask`로 실행 시간을 더 받아 두면 20분 동안 끊기지 않고 내려받을 수 있다.', '요청한 시간이 원하는 만큼 늘어난다고 본 것. 이 방식으로 받는 시간은 대략 30초 안팎이라 20분짜리 B는 도중에 끊긴다. 몇 분 이상 걸리는 다운로드는 `URLSession` 백그라운드 세션에 맡겨야 한다.', false),
(11637, 4297, 'C는 `URLSession` 백그라운드 세션을 한 번 만들어 두면 앱을 열지 않아도 하루 여러 번 다시 실행된다.', '전송을 이어 주는 방식을 반복 실행 예약 수단으로 착각한 것. 백그라운드 세션은 이미 시작한 전송을 이어 줄 뿐이며, 앱을 열지 않은 동안의 주기적 갱신은 `BackgroundTasks` 프레임워크로 예약한다.', false),
(11638, 4297, 'A를 `beginBackgroundTask`로 감쌌다면 전송이 끝난 뒤 `endBackgroundTask`를 부르지 않아도 시스템이 알아서 정리한다.', '받은 시간이 끝나면 자동으로 반납된다고 본 것. `endBackgroundTask`를 빠뜨리면 시스템이 앱을 강제 종료할 수 있어, 작업 완료 시점과 만료 핸들러 양쪽에서 반드시 호출해야 한다.', false),

-- 문제 4298
(11639, 4298, '`UIApplication.State`에 대응하는 값이 없어, 앱이 지금 이 상태인지 코드로 확인할 수 없다.', '코드가 전혀 돌지 않는 Suspended와 헷갈린 것. 이 상태에서는 코드가 실행되므로 `applicationState`를 읽으면 `.background`가 나온다. 열거형에 빠진 것은 Not Running과 Suspended뿐이다.', false),
(11640, 4298, '사용자가 앱 전환기에서 다시 열면 `didFinishLaunchingWithOptions`부터 다시 호출된다.', '화면에서 사라지면 프로세스도 끝난다고 본 것. 이 상태의 앱은 프로세스가 살아 있어, 다시 열면 `sceneWillEnterForeground` → `sceneDidBecomeActive` 순으로 이어서 복귀한다.', false),
(11641, 4298, '이 상태에 머물 수 있는 시간은 30초로 고정되어 있어, `backgroundTimeRemaining`으로 확인할 필요가 없다.', '유예 시간을 정해진 값으로 외운 것. 허용 시간은 공식 문서에 고정값으로 명시되어 있지 않고 버전·시스템 상황에 따라 달라지므로, `backgroundTimeRemaining`으로 남은 시간을 확인하는 것이 안전하다.', false),
(11642, 4298, '오디오 백그라운드 모드를 선언하고 음악을 재생 중인 앱은 유예 시간이 지나도 이 상태로 재생을 이어 간다.', 'iOS는 기본적으로 유예 시간이 지나면 앱을 Suspended로 멈추지만, 오디오 재생·위치 추적처럼 백그라운드 모드를 명시적으로 선언한 앱은 예외로 이 상태에 머물며 계속 실행된다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1388, 4299, 'sceneWillEnterForeground,sceneWillEnterForeground(_:),sceneWillEnterForeground(),sceneWillEnterForeground(_ scene: UIScene)', '`sceneWillEnterForeground(_:)`는 씬이 Background에서 포그라운드로 올라오기 직전(또는 새로 연결된 씬이 처음 화면에 나오기 직전)에 호출되므로, 홈에 나갔다 돌아올 때만 한 번씩 요청이 남는다. 제어 센터·알림 센터는 앱을 포그라운드에 둔 채 Inactive로만 바꾸기 때문에 `sceneWillResignActive` → `sceneDidBecomeActive`만 오고 이 콜백은 불리지 않는다. 짧은 인터럽트에도 반응해야 하는 타이머 재개는 `sceneDidBecomeActive`에, 백그라운드에서 돌아온 뒤 한 번만 하면 되는 토큰 확인은 `sceneWillEnterForeground`에 나누어 두자.'),
       (1389, 4300, 'UIApplicationDelegateAdaptor,@UIApplicationDelegateAdaptor,UIApplicationDelegateAdaptor(AppDelegate.self),@UIApplicationDelegateAdaptor(AppDelegate.self)', 'SwiftUI 앱은 `@main`이 붙은 `App` 구조체가 진입점이라, AppDelegate 클래스를 만들어 두기만 해서는 시스템이 그 객체를 만들지도 콜백을 전달하지도 않는다. `@UIApplicationDelegateAdaptor(AppDelegate.self)`로 선언해야 SwiftUI가 AppDelegate 인스턴스를 만들어 `didFinishLaunchingWithOptions`·푸시 토큰 수신 같은 프로세스 단위 콜백을 넘겨준다. 화면 상태 전이(`active`·`inactive`·`background`)를 관찰하는 `@Environment(\.scenePhase)`와 헷갈리지 말자. scenePhase는 UI 단위 전이만 알려 줄 뿐 푸시 토큰 같은 AppDelegate 콜백은 받지 못한다.');

-- =====================================================
-- Lesson 844: 씬 연결 해제와 백그라운드 시간 한도
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5243, 844, '아래 표에 정리된 앱 실행 상태에 대한 설명으로 옳지 않은 것은?', '씬(Scene) 기반 iOS 앱이 가질 수 있는 실행 상태를 정리한 표다.

| 상태 | 코드 실행 | 화면 표시 | 대표 장면 |
|---|---|---|---|
| Not Running | 없음 | 없음 | 아직 실행하지 않았거나 종료된 뒤 |
| Inactive | 실행 중 | 표시됨 | 전화 수신, 앱 전환기 진입, 제어 센터 노출 |
| Active | 실행 중 | 표시됨 | 포그라운드에서 이벤트를 정상 처리 |
| Background | 제한적 실행 (짧은 유예 시간 동안만) | 없음 | 홈으로 나간 직후 |
| Suspended | 없음 | 없음 | 유예 시간이 끝나 메모리에만 남음 |', 'OBJECTIVE'),
       (5244, 844, '아래 SwiftUI 앱을 아이패드에서 창 두 개로 띄웠을 때 일어나는 일로 옳은 것은?', '사용자가 같은 앱의 창 A와 창 B를 나란히 띄워 두고 글을 쓰다가, 창 A만 화면에서 치우고 창 B만 전체 화면으로 남겼다.

```swift
@main
struct MemoApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup { EditorView() }
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .background: DraftStore.shared.saveAll()
                case .active:     SyncEngine.shared.resume()
                default:          break
                }
            }
    }
}
```', 'OBJECTIVE'),
       (5245, 844, '아래 코드와 로그를 볼 때 앱이 종료된 원인으로 옳은 것은?', '사진 업로드 앱을 백그라운드에서 테스트하던 중 앱이 종료되었다.

```swift
var taskID: UIBackgroundTaskIdentifier = .invalid

func sceneDidEnterBackground(_ scene: UIScene) {
    taskID = UIApplication.shared.beginBackgroundTask(withName: "flushUpload") {
        Log.write("expired")          // 만료 핸들러
    }
    Uploader.shared.flush {
        Log.write("flush done")
    }
}
```

```
14:20:05.110  sceneDidEnterBackground
14:20:05.118  backgroundTimeRemaining = 29.5
14:20:13.472  flush done
14:20:34.902  expired
14:20:34.981  프로세스 종료 — 시스템이 강제 종료함
```', 'OBJECTIVE'),
       (5246, 844, '아래 두 사용자의 보고에서 앱이 다시 열리기 직전까지 놓여 있던 상태로 옳은 것은?', '같은 버전의 메모 앱을 쓰는 두 사용자가 앱으로 돌아왔을 때의 화면이 서로 다르다고 알려 왔다. 이 앱은 프로세스가 새로 만들어질 때만 스플래시 화면을 0.5초 보여 주고, `didFinishLaunchingWithOptions`에서 서버 설정을 한 번 내려받는다.

- 사용자 A: 홈으로 나갔다가 2분 뒤 앱 전환기에서 다시 열었다. 쓰던 메모와 커서 위치가 그대로였고 스플래시는 보이지 않았으며, 서버에도 설정 요청이 새로 남지 않았다.
- 사용자 B: 홈으로 나간 뒤 무거운 게임을 한 시간 하고 돌아왔다. 스플래시가 잠깐 보인 뒤 첫 화면부터 시작했고, 같은 시각 서버에 설정 요청이 한 건 새로 찍혔다. 앱을 직접 종료한 적은 없다고 한다.', 'OBJECTIVE'),
       (5247, 844, '아래 상황에서 정리 코드를 옮겨 넣은 SceneDelegate 콜백의 이름은?', '아이패드용 문서 앱에서 사용자가 같은 앱의 창을 여러 개 열었다 닫기를 반복하자, 앱을 종료하지 않았는데도 메모리 사용량이 창을 닫은 뒤에도 내려가지 않고 계단처럼 쌓였다. 계측해 보니 이미 화면에서 사라진 창이 걸어 둔 타이머와 `NotificationCenter` 옵저버가 그대로 살아 있었고, 사라진 화면을 갱신하려는 호출까지 남아 있었다.

SceneDelegate의 어느 콜백에 타이머 무효화와 옵저버 해제를 넣자, 창을 닫을 때마다 메모리 사용량이 원래 수준으로 돌아왔고 남아 있는 다른 창들은 아무 영향 없이 계속 동작했다. 이 콜백은 홈으로 나갔다가 몇 분 뒤 돌아오는 동안에는 한 번도 호출되지 않았다.', 'SUBJECTIVE'),
       (5248, 844, '아래 상황에서 반복문을 빠져나갈 조건으로 참조한 UIApplication 속성의 이름은?', '사진 백업 앱이 홈으로 나간 뒤에도 남은 사진을 이어서 올리도록 만들었다. 처음에는 30초 동안은 안전하다고 보고 목록 전체를 한 번에 도는 반복문을 돌렸다.

테스트해 보니 어떤 기기에서는 29초가량 전송이 이어진 반면, 배터리가 부족하거나 앱을 여러 개 띄워 둔 기기에서는 6초 만에 전송이 끊겨 마지막 사진이 절반만 올라간 채 망가졌다. 사진 한 장을 시작하기 전에 `UIApplication.shared`의 값 하나를 읽어 그 값이 5초 미만이면 남은 목록을 따로 저장하고 반복문을 빠져나오도록 고치자, 기기와 상황이 달라도 파일이 깨지는 일이 사라졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5243
(14155, 5243, 'Not Running에는 사용자가 앱을 아직 열지 않았을 때뿐 아니라, 메모리를 확보하려는 시스템이 Suspended 상태의 앱을 정리했을 때도 도달한다.', '참인 진술이다. 표의 Not Running은 실행 전과 종료 후를 함께 묶은 칸이며, 코드가 멈춘 Suspended 앱은 아무 통보 없이 정리되어 이 칸으로 내려온다.', false),
(14156, 5243, 'Inactive는 Active와 Background 사이를 스쳐 가는 짧은 순간일 수도 있고, 전화 수신처럼 사용자가 한동안 머무는 구간일 수도 있다.', '참인 진술이다. 앱 전환기 진입은 곧 다른 상태로 넘어가는 통과 지점이지만, 통화 화면이 떠 있는 동안에는 표의 화면 표시대로 앱이 보이는 채 이 상태에 머문다.', false),
(14157, 5243, '화면 표시가 똑같이 없음이어도 Background와 Suspended는 코드 실행 칸이 달라, 시스템이 따로 깨우지 않는 한 Suspended에서는 어떤 정리 코드도 돌지 않는다.', '참인 진술이다. 두 상태를 가르는 기준은 화면이 아니라 코드 실행 가능 여부이고, Suspended는 그 칸이 없음이라 앱이 스스로 할 수 있는 일이 남지 않는다.', false),
(14158, 5243, 'Background에서 시작한 업로드는 코드가 제한적으로나마 실행되고 있으므로, 유예 시간이 끝나 Suspended로 넘어간 뒤에도 이어서 완료된다.', '거짓이다. 표의 Background는 짧은 유예 시간 동안만 코드가 돌고 Suspended의 코드 실행 칸은 없음이다. 유예 시간 안에 못 끝낸 전송은 중단되므로 시간을 더 받거나 다른 전송 방식으로 옮겨야 한다.', true),

-- 문제 5244
(14159, 5244, 'scenePhase는 앱 프로세스 하나의 상태를 나타내므로 두 창이 모두 .background로 바뀌고, saveAll()이 연달아 두 번 실행된다.', 'AppDelegate가 맡던 프로세스 단위 관점을 그대로 가져온 오개념이다. scenePhase는 씬마다 따로 전달되는 UI 단위 값이라, 화면에 남은 창에서는 전이 자체가 일어나지 않는다.', false),
(14160, 5244, '창 A 쪽 scenePhase만 .background가 되어 A의 saveAll()이 실행되고, 화면에 남은 창 B는 .active 그대로라 저장이 일어나지 않는다.', '씬은 UI 인스턴스 단위라 창마다 생명주기가 따로 흐른다. 치워진 창만 백그라운드로 내려가 저장 코드가 돌고, 남은 창은 계속 이벤트를 받는 Active 상태로 남는다.', true),
(14161, 5244, '창이 여러 개일 때 scenePhase는 가장 마지막에 연결된 창의 상태만 전달하므로, 창 B가 활성인 동안에는 .background가 오지 않는다.', '여러 씬의 상태를 하나로 합쳐 전달한다고 본 것. 각 WindowGroup 인스턴스는 자기 씬의 전이만 받으므로, 창 A가 내려가면 A 쪽 관찰 코드가 그대로 실행된다.', false),
(14162, 5244, '창 A는 화면에서 사라지는 순간 곧바로 Suspended가 되어, .background가 전달되기 전에 코드 실행이 멈춘다.', 'Background 구간을 건너뛴다고 본 것. 화면에서 내려간 씬은 먼저 Background로 들어가 저장 같은 마무리 코드를 돌리고, 유예 시간이 지나야 Suspended가 된다.', false),

-- 문제 5245
(14163, 5245, '업로드가 끝난 뒤에도 만료 핸들러 안에서도 endBackgroundTask(_:)가 호출되지 않아, 반납되지 않은 작업을 안고 있던 앱을 시스템이 강제 종료했다.', 'beginBackgroundTask로 받은 시간은 돌려받은 식별자를 반납해 끝맺어야 한다. flush done 시점이나 expired 시점에 endBackgroundTask(_:)를 불렀다면 앱은 조용히 Suspended로 내려갔을 것이다.', true),
(14164, 5245, '업로드가 유예 시간 안에 끝나지 못해 종료된 것이므로, 전송 시작을 sceneWillResignActive로 앞당겨야 한다.', '로그를 보면 flush done이 8초 만에 찍혀 전송은 이미 끝났다. 남은 시간이 모자란 것이 아니라, 끝난 작업을 반납하지 않은 채 만료를 맞은 것이 원인이다.', false),
(14165, 5245, 'beginBackgroundTask로 늘릴 수 있는 시간은 30초로 고정되어 있어, 그 시간이 지나면 어떤 앱이든 종료를 피할 수 없다.', '허용 시간을 고정값으로 외운 것. 시간은 버전·시스템 상황에 따라 달라지며 로그의 29.5초도 그때의 값일 뿐이다. 만료 전에 반납하면 종료가 아니라 Suspended로 넘어간다.', false),
(14166, 5245, '유예 시간이 끝나 Suspended로 넘어가는 순간 시스템이 앱을 정리한 것이므로, 코드를 어떻게 짜도 막을 수 없다.', 'Suspended 앱이 정리될 때는 어떤 콜백도 오지 않아 로그가 남지 않는다. 여기서는 만료 핸들러의 expired가 찍혔으므로 백그라운드 작업이 만료되면서 끝난 경우다.', false),

-- 문제 5246
(14167, 5246, 'A는 Background, B는 Not Running이었다. 홈으로 나간 앱은 사용자가 다시 열 때까지 Background에 머무르며 코드를 계속 실행한다.', '유예 시간을 빠뜨린 것. Background는 홈으로 나간 직후의 짧은 구간일 뿐이고, 그 시간이 지나면 코드가 멈춘 Suspended로 내려간다. 2분을 Background로 버티지는 못한다.', false),
(14168, 5246, 'A는 Inactive, B는 Suspended였다. 화면에서 사라져도 앱은 이벤트만 받지 못할 뿐 포그라운드에 남아 있다.', 'Inactive와 Background를 뒤섞은 것. Inactive는 전화 수신처럼 화면이 보이는 채 이벤트만 끊긴 상태라, 홈으로 나가 화면에서 사라진 A는 이미 그 단계를 지났다.', false),
(14169, 5246, 'A는 Suspended, B는 Not Running이었다. 둘 다 코드가 멈춰 있었지만 프로세스가 메모리에 남아 있었는지가 갈렸다.', 'A는 프로세스가 살아 있어 메모와 커서가 그대로 복원되고 설정 요청도 없었다. B는 게임에 밀려 시스템이 앱을 정리해 프로세스가 사라졌고, 그래서 didFinishLaunchingWithOptions부터 다시 시작했다.', true),
(14170, 5246, 'A와 B 모두 Suspended였다. B의 스플래시는 시스템이 화면 스냅샷을 잃어버려 첫 화면을 다시 그린 것이다.', '스플래시만 보고 판단한 것. B는 설정 요청이 새로 남아 didFinishLaunchingWithOptions가 다시 실행됐음을 알 수 있다. Suspended에서 복귀했다면 그 콜백은 호출되지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1704, 5247, 'sceneDidDisconnect,sceneDidDisconnect(_:),sceneDidDisconnect(),sceneDidDisconnect(_ scene: UIScene),UISceneDelegate.sceneDidDisconnect', '`sceneDidDisconnect(_:)`는 씬 하나가 앱과의 연결이 끊길 때, 즉 사용자가 창을 닫거나 시스템이 씬 자원을 회수할 때 호출되어 그 씬만 쓰던 타이머·옵저버·뷰 자원을 정리하는 자리다. 씬 단위 콜백이라 남은 창이 있으면 앱은 그대로 실행되며, 프로세스가 끝날 때 오는 `applicationWillTerminate`와는 범위가 다르다. 홈으로 나갈 때 호출되어 사용자 데이터를 저장하는 `sceneDidEnterBackground`와도 구분해야 한다. 백그라운드로 내려간 창은 연결이 유지되어 이 콜백이 오지 않으므로, 사례처럼 홈에 나갔다 돌아오는 동안에는 한 번도 불리지 않는다.'),
       (1705, 5248, 'backgroundTimeRemaining,UIApplication.shared.backgroundTimeRemaining,application.backgroundTimeRemaining', '`backgroundTimeRemaining`은 백그라운드로 내려간 앱에 시스템이 허용한 실행 시간이 얼마나 남았는지 알려 주는 값이다. iOS 13 이후 대략 30초 안팎으로 알려져 있을 뿐 공식 문서가 고정값을 못 박은 적은 없어서, 기기 상태와 시스템 상황에 따라 사례처럼 6초로 줄기도 한다. 30초를 상수로 박아 두면 전송이 중간에 잘리는 이유가 여기에 있다. 시간을 더 달라고 요청하는 `beginBackgroundTask`와 역할이 다르다. 이쪽은 남은 양을 읽는 조회이고, 저쪽은 시간을 요청해 식별자를 받아 두는 호출이다. 몇 분 이상 걸리는 전송이라면 이 값을 재는 대신 `URLSession` 백그라운드 세션에 맡기고, 앱을 열지 않은 동안의 주기적 갱신은 `BackgroundTasks` 프레임워크로 예약한다.');
