-- Unit: 푸시 알림 (Unit ID: 110)
-- Chapter: iOS (Chapter ID: 9)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (536, 110, '무음 푸시와 알림 탭 처리, 디바이스 토큰'),
       (694, 110, '페이로드 한도와 토큰 인증·알림 묶음'),
       (852, 110, '오프라인 보관과 대상 앱 지정, 액션 버튼');

-- =====================================================
-- Lesson 536: 무음 푸시와 알림 탭 처리, 디바이스 토큰
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3395, 536, '아래 페이로드로 도착한 원격 푸시가 기기에서 처리되는 방식으로 옳은 것은?', '앱은 Background Modes의 Remote notifications를 켜 둔 상태이고, 사용자는 알림 권한을 허용했다. 서버가 아래 페이로드를 APNs로 보냈다.

```json
{
  "aps": {
    "content-available": 1,
    "badge": 5
  },
  "route": "order",
  "id": "7781"
}
```', 'OBJECTIVE'),
       (3396, 536, '위 표에서 비교한 두 알림 방식에 대한 설명으로 옳지 않은 것은?', '아래는 한 앱이 함께 쓰는 두 가지 알림 방식을 정리한 표다.

| 항목 | A 방식 | B 방식 |
| --- | --- | --- |
| 알림을 만드는 주체 | 앱 자신이 기기 안에서 예약 | 서버가 APNs를 거쳐 전달 |
| 네트워크 | 필요 없음 | 필요함 |
| 사전 준비 | 알림 권한 요청 | 알림 권한 요청 + 기기별 등록 값 저장 + 서버·APNs 인증 구성 |
| 알림에 담기는 정보 | 앱이 이미 알고 있는 내용 | 서버가 보내는 시점에 가진 최신 내용 |
| 대표 사례 | 30분 뒤 미완료 작업 재알림 | 주문 상태 변경 안내 |', 'OBJECTIVE'),
       (3397, 536, '아래 코드가 적용된 앱이 포그라운드에서 두 알림을 받았을 때의 동작으로 옳은 것은?', '사용자가 앱을 화면에 띄워 둔 상태에서 route 값이 order인 알림과 chat인 알림을 차례로 받았다. 앱에는 아래 델리게이트 메서드만 구현돼 있다.

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
    let info = notification.request.content.userInfo
    if info["route"] as? String == "chat" {
        return []
    }
    return [.banner, .sound]
}
```', 'OBJECTIVE'),
       (3398, 536, '아래 증상에서 종료 상태일 때만 화면 이동이 실패한 원인으로 옳은 것은?', '증상: 앱을 완전히 종료한 뒤 주문 알림을 탭하면 홈 화면만 열리고 주문 상세로 넘어가지 않는다. 앱이 백그라운드에 있을 때 같은 알림을 탭하면 주문 상세로 잘 이동한다. 페이로드에는 두 경우 모두 route와 id가 들어 있고, 탭을 받아 라우터로 넘기는 코드는 한 곳뿐이다.

```swift
final class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }
}
```', 'OBJECTIVE'),
       (3399, 536, '아래 상황에서 서버가 제때 갱신하지 못해 푸시 전달이 실패한 값의 이름은?', '한 사용자에게만 주문 푸시가 도착하지 않아 서버 로그를 확인했다.

```
push send  user=8842  status=410  reason=Unregistered
```

이 사용자는 최근 기기를 새로 사서 백업을 복원했고, 서버에는 예전 기기에서 저장해 둔 64자리 16진수 문자열이 그대로 남아 있었다. 앱이 실행될 때마다 이 값을 다시 읽어 이전과 다르면 서버로 보내도록 고치자 푸시가 정상 도착했다.', 'SUBJECTIVE'),
       (3400, 536, '아래 상황에서 앱에 새로 추가한 구성 요소의 이름은?', '서버가 푸시 본문을 암호화해 보내기 시작하자 배너에 알아볼 수 없는 문자열이 그대로 노출됐다. 페이로드에 이미지 URL을 넣어도 배너에는 사진이 붙지 않았다.

앱 타깃 옆에 별도 타깃 하나를 추가하고 페이로드에 mutable-content 값 1을 넣자, 같은 알림의 배너에 사람이 읽을 수 있는 문장과 사진 미리보기가 함께 나타났다. 이 타깃은 메모리 한계가 낮은 별도 프로세스로 돌고, 메인 앱과 데이터를 주고받으려면 App Group 설정이 필요했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3395
(9227, 3395, '알림 표시에 필요한 alert 키가 없어 APNs가 요청을 거부하고 전송이 실패한다.', 'alert는 필수 키가 아니다. 배너를 띄우지 않고 앱만 깨우려는 페이로드도 유효한 요청이라 정상 전송된다. 표시할 문구가 없을 뿐이다.', false),
(9228, 3395, '배너를 띄우지 않고 앱을 백그라운드에서 깨워 갱신하게 하며, 깨우는 시점은 시스템이 조절한다.', 'content-available 값 1은 사일런트 푸시다. 배너·소리 없이 백그라운드 수신 콜백으로 전달돼 데이터를 갱신할 기회를 준다. 다만 전달 빈도를 시스템이 조절하므로 실시간성은 기대할 수 없다.', true),
(9229, 3395, '표시 직전에 확장이 페이로드를 가로채 배너 문구와 첨부 이미지를 바꿀 수 있다.', '그 동작은 mutable-content 값이 1일 때만 열린다. 이 페이로드에는 그 키가 없고 띄울 배너도 없어 확장이 끼어들 자리가 없다.', false),
(9230, 3395, '배너와 소리로 먼저 표시되고, 사용자가 탭해야 앱에 페이로드가 전달된다.', 'aps가 있으면 무조건 배너가 뜬다는 오해. 배너·소리는 alert·sound 키가 있을 때의 이야기이고, 이 페이로드는 탭 없이 앱으로 바로 전달된다.', false),

-- 문제 3396
(9231, 3396, 'B 방식은 사용자가 기기를 바꾸거나 백업을 복원하면 서버에 저장된 등록 값이 더 이상 맞지 않을 수 있다.', '참인 진술. B 방식은 기기별 등록 값을 서버가 들고 있다가 전송에 쓰는데, 이 값은 재설치·복원으로 바뀔 수 있어 실행 때마다 확인해 갱신해야 한다.', false),
(9232, 3396, '두 방식 모두 사용자가 알림 권한을 거부하면 배너가 화면에 뜨지 않는다.', '참인 진술. 표의 사전 준비를 보면 권한 요청은 두 방식의 공통 조건이고, 만들어진 뒤의 표시·탭 처리는 같은 알림 센터 API가 담당한다.', false),
(9233, 3396, 'A 방식으로는 서버에서 방금 바뀐 주문 상태를 배너 문구에 담을 수 없다.', '참인 진술. A 방식이 담는 정보는 예약하는 순간 앱이 이미 알고 있던 내용뿐이라, 예약 뒤 서버에서 달라진 값은 반영되지 않는다.', false),
(9234, 3396, 'A 방식은 기기가 비행기 모드면 예약한 시각이 되어도 알림이 뜨지 않는다.', '거짓이라 정답. A 방식은 네트워크가 필요 없고 예약부터 표시까지 기기 안에서 끝나므로, 통신이 끊겨 있어도 예약한 시각에 그대로 표시된다.', true),

-- 문제 3397
(9235, 3397, '두 알림 모두 배너와 소리로 표시된다.', '반환값과 무관하게 알림이 오면 늘 표시된다고 본 오해. 포그라운드 표시 여부는 이 메서드가 돌려주는 옵션이 정하고, 빈 배열이면 표시하지 않는다.', false),
(9236, 3397, '두 알림 모두 배너가 뜨지 않는다. 포그라운드에서는 시스템이 배너를 표시하지 않기 때문이다.', '기본 동작만 본 오해. 이 메서드를 구현하지 않으면 그 말이 맞지만, 코드처럼 표시 옵션을 돌려주면 포그라운드에서도 배너가 뜬다.', false),
(9237, 3397, 'order 알림은 배너와 소리로 표시되고, chat 알림은 표시되지 않는다.', 'route가 chat이면 빈 배열을 돌려 표시를 생략하고, 나머지는 배너·소리 옵션을 돌려주기 때문. 사용자가 이미 보고 있는 화면과 겹치는 알림을 감추는 전형적인 처리다.', true),
(9238, 3397, 'chat 알림은 표시되지 않으므로 앱에 전달되지도 않아 페이로드를 읽을 수 없다.', '표시 생략을 미전달로 본 오해. 이 메서드는 알림이 앱에 전달된 뒤 호출되므로 페이로드는 이미 손에 들어와 있고, 앱이 정한 것은 표시 여부뿐이다.', false),

-- 문제 3398
(9239, 3398, '탭을 알리는 콜백이 앱 실행 직후 호출되는데, 그 시점에는 델리게이트가 아직 지정되지 않아 호출을 놓친다.', '종료 상태에서 탭하면 앱이 실행되자마자 시스템이 탭 콜백을 부른다. 델리게이트 지정을 첫 화면의 viewDidLoad에 두면 이미 늦으므로, 실행 초기인 didFinishLaunching으로 옮겨야 한다.', true),
(9240, 3398, '종료 상태로 받은 알림은 시스템이 커스텀 키를 지우고 배너 문구만 남기므로 route와 id를 읽을 수 없다.', '앱 상태에 따라 페이로드가 잘린다는 오해. 커스텀 키는 상태와 무관하게 그대로 전달되고, 증상에도 두 경우 모두 route와 id가 있다고 적혀 있다.', false),
(9241, 3398, '앱이 종료되면서 알림 권한이 초기화되어 탭 이벤트가 앱까지 전달되지 않는다.', '권한은 앱 종료로 초기화되지 않는다. 권한이 없었다면 배너부터 뜨지 않아 탭할 알림 자체가 없었을 것이다.', false),
(9242, 3398, '종료 상태에서의 탭은 실행 옵션으로만 넘어오므로 알림 센터 델리게이트로는 처리할 수 없다.', '예전 API 시절 기억에서 오는 오해. 델리게이트를 제때 지정해 두면 종료 상태에서 탭한 알림도 같은 콜백으로 전달된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1088, 3399, '디바이스 토큰,디바이스토큰,device token,devicetoken,장치 토큰,단말 토큰,푸시 토큰,push token,APNs 토큰,apns token', 'APNs가 기기와 앱 조합마다 발급하는 값이 디바이스 토큰이고, 서버는 이를 사용자와 짝지어 저장해 두었다가 전송할 때 수신 대상으로 쓴다. 재설치·복원·기기 교체로 값이 바뀌면 예전 값은 무효가 되어 로그의 410 Unregistered 같은 응답이 돌아온다. 그래서 앱은 실행할 때마다 등록하고 값이 달라졌으면 서버로 다시 보내야 한다. 서버가 APNs에 인증할 때 쓰는 .p8 키나, 어느 앱으로 보낼지 가리키는 번들 ID(apns-topic)와는 역할이 다르다.'),
       (1089, 3400, 'Notification Service Extension,notification service extension,노티피케이션 서비스 익스텐션,알림 서비스 익스텐션,알림 서비스 확장,UNNotificationServiceExtension,NSE', 'mutable-content 값이 1인 알림을 배너가 뜨기 직전에 가로채 본문과 첨부를 바꿀 수 있는 확장이 Notification Service Extension이다. 덕분에 서버는 암호문과 이미지 URL만 보내고, 복호화와 이미지 내려받기는 기기에서 처리해 페이로드 4KB 한계도 피한다. 별도 프로세스라 메모리 한계가 낮고 메인 앱과 데이터를 나누려면 App Group이 필요하다. 배너 없이 앱을 깨워 데이터를 갱신하는 사일런트 푸시(content-available 1)와는 목적이 다르고, 펼친 알림 화면을 직접 그리는 Notification Content Extension과도 구분한다.');

-- =====================================================
-- Lesson 694: 페이로드 한도와 토큰 인증·알림 묶음
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4343, 694, '아래 코드를 실행했을 때 사용자에게 표시되는 알림으로 옳은 것은?', '할 일 앱에서 사용자가 작업 42의 제목을 정한 직후 reminder 함수가 호출됐고, 10분 뒤 제목을 고치자 같은 함수가 한 번 더 호출됐다. 두 호출 동안 알림 권한은 허용된 상태였다.

```swift
func reminder(taskID: String, title: String) async throws {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = "아직 완료하지 않은 작업이 있어요."
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
    let request = UNNotificationRequest(identifier: "reminder-\(taskID)",
                                        content: content, trigger: trigger)
    try await UNUserNotificationCenter.current().add(request)
}

// 0분: 첫 호출
try await reminder(taskID: "42", title: "보고서 초안")
// 10분: 제목 수정 후 두 번째 호출
try await reminder(taskID: "42", title: "보고서 최종본")
```', 'OBJECTIVE'),
       (4344, 694, '아래 조건에서 서버가 보낸 두 푸시의 결과로 옳은 것은?', '사용자가 첫 실행 때 알림 권한 요청 창에서 허용 안 함을 눌렀다. 앱은 Background Modes의 Remote notifications를 켜 두었고, 실행 초기에 아래 코드를 실행한다. 이후 서버는 이 사용자에게 표의 두 푸시를 보냈다.

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()
    return true
}

func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02x", $0) }.joined()
    PushTokenSyncer.sendIfChanged(token)
}
```

| 푸시 | 페이로드의 aps |
| --- | --- |
| (가) | {"alert": {"title": "주문 완료"}, "sound": "default"} |
| (나) | {"content-available": 1} |', 'OBJECTIVE'),
       (4345, 694, '아래 로그의 전송 실패를 해결하는 방법으로 옳은 것은?', '주문 상태가 바뀔 때마다 서버가 APNs로 알림을 보내는데, 주문 항목이 많은 사용자에게만 알림이 가지 않았다. 서버 로그와 보내려던 페이로드는 아래와 같다.

```
push send  user=5120  status=413  reason=PayloadTooLarge  size=5.2KB
push send  user=7731  status=200  size=0.8KB
```

```json
{
  "aps": {
    "alert": { "title": "배송 시작", "body": "주문하신 상품이 출발했습니다." },
    "sound": "default"
  },
  "route": "order",
  "id": "123",
  "items": [
    { "name": "무선 키보드", "image": "https://cdn.example.com/p/1.jpg" },
    { "name": "USB-C 허브", "image": "https://cdn.example.com/p/2.jpg" }
  ]
}
```

(user=5120에게 보낸 items 배열에는 실제로 40여 개 항목이 들어 있었다.)', 'OBJECTIVE'),
       (4346, 694, '아래 흐름이 끝났을 때 사용자가 보게 되는 화면과 그 이유로 옳은 것은?', '앱이 종료된 상태에서 사용자가 route가 order, id가 123인 알림을 탭했다. 주문 상세는 로그인이 필요한 화면이며, 실행 뒤 일어난 일은 순서대로 아래와 같다.

1. didFinishLaunching에서 알림 센터 델리게이트를 지정했다.
2. 탭 콜백이 호출되어 `DeepLinkRouter.shared.handle(.order(id: "123"))`이 실행됐다. 이때 coordinator는 연결돼 있지만 isReady는 false다.
3. 로그인 화면이 표시됐고, 사용자가 로그인을 마치자 `loginDidFinish()`가 실행됐다.

```swift
final class DeepLinkRouter {
    static let shared = DeepLinkRouter()
    private var pending: DeepLink?
    weak var coordinator: AppCoordinator?

    func handle(_ link: DeepLink) {
        guard let coordinator, coordinator.isReady else { pending = link; return }
        coordinator.navigate(to: link)
    }

    func flushIfNeeded() {
        if let link = pending { pending = nil; handle(link) }
    }
}

// 로그인 화면
func loginDidFinish() {
    coordinator.isReady = true
    coordinator.showHome()
}
```', 'OBJECTIVE'),
       (4347, 694, '아래 상황에서 서버 팀이 새로 도입한 방식을 가리키는 용어는?', '한 쇼핑 앱은 해마다 3월 둘째 주에 모든 사용자의 푸시가 한꺼번에 끊겼다. 서버 로그에는 아래 줄이 쌓였고, 담당자가 Apple 개발자 사이트에서 파일을 새로 받아 서버에 다시 배포해야 복구됐다.

```
apns connect failed  error=certificate has expired
```

서버 팀이 이 파일을 걷어 내고 방식을 바꾸자, 서버가 APNs로 보내는 요청 헤더가 아래처럼 달라졌다. 개발자 계정에서 키 파일을 한 번 내려받아 둔 뒤로는 해마다 파일을 교체하는 작업이 사라졌고, 같은 키 하나로 팀의 다른 앱 두 개에도 푸시를 보낼 수 있었다.

```
POST /3/device/7f3a9c...e21b
authorization: bearer eyJhbGciOiJFUzI1NiIsImtpZCI6IjhLMlE3In0.eyJpc3MiOiJUOVg0N0tRMiIsImlhdCI6MTc1Nzc0MDAwMH0.MEUCIQ...
apns-topic: com.example.shop
```', 'SUBJECTIVE'),
       (4348, 694, '아래 상황에서 서버가 페이로드에 추가한 키의 이름은?', '중고 거래 앱 사용자가 퇴근 뒤 잠금 화면을 켜 보니 알림 42건이 도착 순서대로 한 줄씩 늘어서 있었다. 거래 상태 알림 사이사이에 판매자 세 명과의 채팅 메시지가 뒤섞여, 원하는 대화의 알림을 찾으려면 한참 스크롤해야 했다.

서버가 aps에 키 하나를 추가해 배포한 다음 날, 같은 구성의 알림 42건이 알림 센터에 아래처럼 네 묶음으로 쌓였다. 배너 문구·소리·배지 숫자와 알림을 길게 눌렀을 때 나오는 버튼은 전날과 같았다.

| 알림 종류 | 추가한 키의 값 | 묶음 안 건수 |
| --- | --- | --- |
| 거래 상태 변경 | trades | 9 |
| 판매자 A와의 채팅 | chat-room-17 | 21 |
| 판매자 B와의 채팅 | chat-room-3 | 8 |
| 판매자 C와의 채팅 | chat-room-52 | 4 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4343
(11755, 4343, '0분 기준 30분에 "보고서 초안", 40분에 "보고서 최종본" 알림이 각각 한 번씩 뜬다.', '식별자가 같아도 요청이 따로 쌓인다고 본 오해. 대기 중인 요청은 식별자로 구분되므로 같은 식별자로 다시 add해도 예약이 하나 더 생기지 않는다.', false),
(11756, 4343, '0분 기준 30분에 "보고서 최종본" 알림이 한 번만 뜬다.', '내용만 바뀌고 예약 시각은 첫 요청을 따른다고 본 오해. 바뀌는 것은 요청 전체라 트리거도 새로 걸리고, 30분은 두 번째 add 시점부터 다시 센다.', false),
(11757, 4343, '0분 기준 40분에 "보고서 최종본" 알림이 한 번만 뜬다.', '같은 식별자로 add하면 대기 중이던 첫 요청이 새 요청으로 교체된다. 새 30분 트리거는 10분에 걸렸으므로 40분에 수정된 제목으로 1건만 뜬다. 작업마다 고정 식별자를 쓰면 중복 알림이 막히는 이유다.', true),
(11758, 4343, '0분 기준 30분에 "보고서 초안" 알림이 한 번만 뜬다.', '같은 식별자가 이미 있으면 두 번째 add가 오류로 거절되거나 무시된다고 본 오해. 실제로는 오류 없이 기존 예약을 새 요청으로 바꿔 끼운다.', false),

-- 문제 4344
(11759, 4344, '권한이 거부돼 디바이스 토큰이 발급되지 않으므로 (가)와 (나) 모두 기기에 닿지 않는다.', '권한 요청과 원격 푸시 등록을 한 단계로 본 오해. registerForRemoteNotifications는 권한 결과와 따로 동작해, 거부해도 토큰이 발급되고 didRegister 콜백으로 서버에 전달된다.', false),
(11760, 4344, '(가)는 화면에 표시되지 않고, (나)는 앱에 전달되어 데이터를 갱신할 수 있다.', '토큰은 권한과 별개로 발급되므로 서버는 이 기기로 보낼 수 있다. 권한은 사용자에게 보이는 표시를 허락하는 것이라 배너·소리를 쓰는 (가)는 막히고, 표시가 없는 사일런트 푸시 (나)는 권한 없이도 앱을 깨운다.', true),
(11761, 4344, '(가)는 배너와 소리로 표시되고, (나)는 권한이 없어 앱에 전달되지 않는다.', '두 푸시의 결과를 뒤바꾼 오해. 권한이 거부되면 막히는 것은 (가)의 배너·소리 같은 표시이고, 표시할 것이 없는 (나)는 권한과 무관하게 전달된다.', false),
(11762, 4344, '권한은 로컬 알림에만 적용되므로 (가)는 배너로 표시되고 (나)도 앱에 전달된다.', '권한이 원격 푸시와 무관하다고 본 오해. 로컬 알림과 원격 푸시는 같은 알림 센터 권한 아래에서 표시되므로, 거부 상태에서는 (가)의 배너도 뜨지 않는다.', false),

-- 문제 4345
(11763, 4345, 'items 배열을 aps 딕셔너리 안으로 옮겨 시스템이 해석하는 영역에 넣는다.', '커스텀 키에만 크기 한도가 걸린다고 본 오해. 4KB는 aps와 커스텀 키를 합친 페이로드 전체의 한도라 위치를 옮겨도 크기는 그대로다. aps는 시스템이 정한 키를 두는 자리이기도 하다.', false),
(11764, 4345, 'content-available 값 1을 넣어 사일런트 푸시로 바꿔 크기 한도를 피한다.', '표시가 없는 푸시는 한도도 없다고 본 오해. 사일런트 푸시도 같은 4KB 한도를 따르고, 배너까지 사라져 배송 시작을 알린다는 원래 목적도 잃는다.', false),
(11765, 4345, 'mutable-content 값 1을 넣어 확장이 나눠 받은 페이로드를 기기에서 합치게 한다.', '확장이 여러 조각을 이어 붙인다고 본 오해. 이 확장은 도착한 알림 한 건의 내용을 표시 전에 바꿀 뿐이고, 도착하는 페이로드 자체는 4KB 한도 안이어야 한다.', false),
(11766, 4345, 'items를 빼고 주문 id만 보낸 뒤, 앱이 그 id로 서버에서 상세 정보를 조회한다.', '일반 알림 페이로드는 커스텀 키까지 합쳐 4KB가 한도라 5.2KB 요청은 거절된다. 알림에는 화면 이동에 필요한 route·id만 싣고, 큰 목록은 앱이 서버에서 받아오는 것이 표준 설계다.', true),

-- 문제 4346
(11767, 4346, '홈 화면. 링크가 pending에 담긴 채 남아 있고, 로그인 뒤 이를 꺼내 처리하는 호출이 없다.', 'isReady가 false라 handle은 링크를 pending에 보관만 한다. 보관된 링크는 flushIfNeeded를 불러야 다시 handle로 넘어가는데 loginDidFinish에 그 호출이 없어 홈에서 멈춘다. showHome 뒤에 부르면 주문 상세로 이어진다.', true),
(11768, 4346, '주문 상세 화면. isReady가 true로 바뀌는 순간 라우터가 보관한 링크로 자동 이동한다.', '라우터가 isReady 값의 변화를 지켜본다고 본 오해. 코드에는 값 변화를 감지하는 장치가 없어, 보관된 링크는 누군가 flushIfNeeded를 불러 줄 때만 처리된다.', false),
(11769, 4346, '홈 화면. 준비되지 않은 시점에 들어온 링크는 handle이 곧바로 버리기 때문이다.', '화면은 맞지만 이유가 틀렸다. guard의 else 분기는 링크를 버리지 않고 pending에 담아 둔다. 링크는 남아 있으니 꺼내서 처리하는 호출만 더하면 된다.', false),
(11770, 4346, '앱이 강제 종료된다. 준비되지 않은 coordinator에 곧바로 navigate를 호출하기 때문이다.', 'guard가 준비 여부를 먼저 확인한다는 점을 놓친 오해. isReady가 false면 navigate까지 가지 않고 링크를 보관한 뒤 반환하므로 충돌할 일이 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1404, 4347, '토큰 기반 인증,토큰기반 인증,토큰 기반 인증 방식,토큰 인증,token-based authentication,token based authentication,token authentication,JWT 인증,JWT 기반 인증,JWT,p8 키 인증,.p8 키 인증,p8 인증,인증 키 방식', 'APNs로 보내는 요청마다 개발자 계정의 .p8 키로 서명한 JWT를 authorization 헤더(bearer)에 붙여 서버를 증명하는 방식이 토큰 기반 인증이다. 키 파일은 만료되지 않고 서버가 JWT만 한 시간 안쪽으로 새로 만들어 쓰면 되므로, 해마다 인증서를 갱신하다 놓쳐 푸시가 통째로 끊기는 사고가 사라진다. 키 하나로 같은 팀의 여러 앱에 보낼 수 있다는 점도 앱마다 따로 발급하는 인증서 방식과 다르다. 여기서 토큰은 서버가 APNs에 내미는 인증 토큰으로, APNs가 기기·앱 조합마다 발급해 수신 대상을 가리키는 디바이스 토큰(요청 경로 /3/device/ 뒤의 값)과는 전혀 다른 값이다.'),
       (1405, 4348, 'thread-id,threadid,thread_id,thread id,스레드 아이디,스레드 ID,스레드id,스레드 식별자,threadIdentifier,thread identifier', 'aps의 thread-id는 값이 같은 알림끼리 잠금 화면과 알림 센터에서 한 묶음으로 모아 보여 주는 키다. 본문에서 값이 trades, chat-room-17처럼 네 가지로 나뉘자 42건이 네 묶음이 된 이유다. 로컬 알림에서는 같은 역할을 UNMutableNotificationContent의 threadIdentifier로 지정한다. 알림을 길게 눌렀을 때 나오는 액션 버튼 세트를 고르는 category나 아이콘 숫자를 정하는 badge와는 다르며, 보여 주는 모양만 묶을 뿐 알림 건수를 합치거나 지우지는 않는다.');

-- =====================================================
-- Lesson 852: 오프라인 보관과 대상 앱 지정, 액션 버튼
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5291, 852, '아래 상황에서 기기가 다시 연결된 뒤 알림 센터에 남아 있는 이 앱의 알림으로 옳은 것은?', '사용자가 13:00에 비행기를 타면서 휴대폰을 비행기 모드로 바꿨다. 그동안 주문 5521의 상태가 바뀔 때마다 서버가 같은 앱으로 배너 알림을 보냈고, 서버 로그는 아래와 같다.

```
13:10  push send  user=3120  apns-collapse-id=order-5521  title="결제 완료"     status=200
13:40  push send  user=3120  apns-collapse-id=order-5521  title="상품 준비 중"  status=200
14:20  push send  user=3120  apns-collapse-id=order-5521  title="배송 출발"     status=200
```

세 요청 모두 보관 기한(apns-expiration)을 다음 날로 잡아 두었고, 15:00에 비행기 모드를 끄자 기기가 APNs에 다시 연결됐다. 알림 권한은 허용된 상태이며, 비행기 모드로 바꾸기 전 이 앱의 알림은 알림 센터에 하나도 없었다.', 'OBJECTIVE'),
       (5292, 852, '아래 상황에서 판매자 앱으로 가는 푸시를 복구하는 방법으로 옳은 것은?', '한 팀이 같은 개발자 계정으로 두 앱을 운영한다. 서버는 .p8 키 하나로 만든 인증 토큰을 두 앱의 푸시 전송에 함께 쓴다.

| 앱 | 번들 ID |
| --- | --- |
| 쇼핑 앱 | com.example.shop |
| 판매자 앱 | com.example.seller |

판매자 앱을 출시한 뒤로 쇼핑 앱 사용자에게는 푸시가 잘 가는데, 판매자 앱 사용자에게 보낸 푸시만 전부 400으로 실패했다. 경로의 디바이스 토큰은 판매자 앱이 실행될 때 받아 서버에 저장해 둔 값이다. 실패한 요청 하나는 아래와 같다.

```
POST /3/device/9b2e41...c07d
authorization: bearer eyJhbGciOiJFUzI1NiIs...(쇼핑 앱 요청과 같은 토큰)
apns-topic: com.example.shop
apns-push-type: alert

→ 400 Bad Request
```', 'OBJECTIVE'),
       (5293, 852, '아래 코드가 적용된 앱에서 (가)와 (나)의 결과로 옳은 것은?', '채팅 앱은 실행 초기에 아래 코드로 알림 카테고리를 등록한다. 서버는 새 메시지 푸시의 aps에 category 값 CHAT_MESSAGE를, 커스텀 키에 route 값 chat과 id 값 17을 넣어 보낸다. DeepLink는 route·id로 채팅방 링크를 만들고, 라우터는 준비된 상태라 링크를 받으면 곧바로 이동한다.

서로 다른 날, 앱이 백그라운드에 있을 때 채팅방 17의 새 메시지 알림을 받고 사용자가 아래처럼 반응했다.

- (가) 배너를 그냥 탭했다.
- (나) 배너를 길게 눌러 나온 "읽음 처리" 버튼을 눌렀다.

```swift
let markRead = UNNotificationAction(identifier: "MARK_READ", title: "읽음 처리", options: [])
let chat = UNNotificationCategory(identifier: "CHAT_MESSAGE", actions: [markRead],
                                  intentIdentifiers: [], options: [])
UNUserNotificationCenter.current().setNotificationCategories([chat])

func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse) async {
    let info = response.notification.request.content.userInfo
    switch response.actionIdentifier {
    case "MARK_READ":
        await ChatAPI.markRead(roomID: info["id"] as? String ?? "")
    case UNNotificationDefaultActionIdentifier:
        if let link = DeepLink(userInfo: info) { DeepLinkRouter.shared.handle(link) }
    default:
        break
    }
}
```', 'OBJECTIVE'),
       (5294, 852, '아래 상황에서 이 사용자에게 제대로 동작하게 구현할 수 있는 알림 기능은?', '가계부 앱 머니노트는 모든 기록을 기기 안에만 저장한다. 운영하는 서버가 없고, 앱이 외부와 데이터를 주고받는 통신도 전혀 하지 않는다. 한 사용자의 앱 상태는 아래와 같다.

| 항목 | 상태 |
| --- | --- |
| 알림 권한 | 허용 |
| 위치 권한 | 허용 안 함 |
| 입력해 둔 월급날 | 매월 25일 |
| 등록해 둔 장소 | 회사(서울 중구) |

기획팀이 알림 기능 네 가지를 제안했고, 개발팀은 앱 구조와 사용자 설정을 지금 그대로 둔 채 이 사용자에게 제대로 동작하는 것부터 구현하기로 했다.', 'OBJECTIVE'),
       (5295, 852, '아래 상황에서 10:30에 사용자 휴대폰의 앱 아이콘에 표시된 배지 숫자는?', '메신저 앱은 새 메시지가 올 때마다 서버가 그 사용자의 안 읽은 메시지 수를 계산해 aps의 badge 값으로 넣어 푸시를 보낸다. 앱에는 배지를 직접 바꾸는 코드가 없고, 사용자는 이날 오전 휴대폰에서 앱을 한 번도 열지 않았다. 휴대폰은 계속 네트워크에 연결돼 있었다.

| 시각 | 일어난 일 | 서버가 계산한 안 읽은 수 | 보낸 푸시의 badge |
| --- | --- | --- | --- |
| 09:00 | 새 메시지 2건 도착 | 2 | 2 |
| 09:40 | 새 메시지 4건 도착 | 6 | 6 |
| 10:10 | 사용자가 PC 웹에서 메시지 5건을 읽음 | 1 | 푸시를 보내지 않음 |', 'SUBJECTIVE'),
       (5296, 852, '아래 상황에서 개발자가 앱 타깃에 새로 추가한 기능(capability)의 이름은?', '뉴스 앱은 밤사이 속보가 나오면 서버가 배너 없는 푸시를 보내, 사용자가 아침에 앱을 열기 전에 기사 목록을 미리 받아 두게 하려 했다. 서버가 보낸 페이로드는 아래와 같고 APNs 응답은 모두 200이었다.

```json
{ "aps": { "content-available": 1 }, "refresh": "headlines" }
```

그런데 앱이 백그라운드에 있을 때는 기사 목록을 받는 콜백이 한 번도 실행되지 않았다. Push Notifications 기능은 처음부터 추가돼 있어서, 같은 앱에 alert를 넣어 보낸 일반 알림은 배너로 잘 떴다.

개발자가 Xcode의 Signing & Capabilities 탭에서 기능 하나를 더 추가하고 그 안의 여러 항목 중 하나에 체크하자, 다음 날부터 아침마다 기사 목록이 미리 받아져 있었다. 다만 목록을 받은 시각은 서버가 보낸 시각과 조금씩 어긋났다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5291
(14283, 5291, '결제 완료, 상품 준비 중, 배송 출발 알림이 보낸 순서대로 세 건 모두 남아 있다.', 'collapse-id를 무시하고 요청마다 알림이 따로 쌓인다고 본 오해. 같은 apns-collapse-id를 단 알림은 새 알림이 이전 알림을 대체해 사용자에게 한 건으로 보인다. status 200은 APNs가 요청을 받았다는 뜻일 뿐 표시 결과를 정하지 않는다.', false),
(14284, 5291, '처음 보낸 결제 완료 알림 1건만 남고, 나중에 보낸 두 건은 보이지 않는다.', '먼저 온 알림을 지키고 뒤에 온 것을 버린다고 본 오해. 같은 collapse-id끼리는 새 알림이 앞선 알림을 대체하므로, 남는 쪽은 가장 나중에 보낸 14:20 알림이다.', false),
(14285, 5291, '마지막에 보낸 배송 출발 알림 1건만 남고, 앞의 두 건은 보이지 않는다.', '세 요청이 같은 apns-collapse-id를 달고 있어 기기에서는 한 건으로 보이고, 가장 나중에 보낸 알림이 앞선 알림을 대체한다. 결제 완료·상품 준비 중 같은 중간 상태는 사용자가 못 보므로, 앱은 실행 때 서버에서 주문 상태를 다시 조회해 보완해야 한다.', true),
(14286, 5291, '세 알림이 한 묶음으로 모여 "배송 출발 외 2건"처럼 접힌 채 남아 있다.', 'thread-id 묶음 표시와 헷갈린 오해. thread-id는 알림 각각을 그대로 둔 채 모아 보여 줄 뿐이라 펼치면 세 건이 다 있지만, collapse-id는 앞선 알림을 새 알림으로 바꿔 끼워 한 건만 남긴다.', false),

-- 문제 5292
(14287, 5292, 'apns-topic 헤더를 com.example.seller로 바꿔 판매자 앱으로 가는 요청임을 밝힌다.', '디바이스 토큰은 기기·앱 조합마다 발급되고, apns-topic은 요청이 향하는 앱을 번들 ID로 밝히는 헤더다. 판매자 앱 토큰에 쇼핑 앱 번들 ID를 붙여 짝이 어긋났으므로 topic을 판매자 앱 것으로 바꾸면 된다.', true),
(14288, 5292, '판매자 앱 전용 .p8 키를 새로 발급받아, 그 키로 서명한 인증 토큰으로 바꾼다.', '키를 앱마다 따로 발급해야 한다고 본 오해. .p8 키는 개발자 계정 단위라 같은 팀의 여러 앱에 함께 쓸 수 있고, 같은 인증 토큰으로 쇼핑 앱 전송은 이미 성공하고 있다.', false),
(14289, 5292, '경로의 디바이스 토큰을 같은 사용자가 쇼핑 앱에서 받은 토큰으로 바꾼다.', '토큰이 기기마다 하나뿐이라고 본 오해. 디바이스 토큰은 기기·앱 조합마다 따로 발급되므로, 쇼핑 앱 토큰으로 보내면 판매자 앱이 아니라 쇼핑 앱으로 알림이 간다.', false),
(14290, 5292, '판매자 앱이 알림 권한을 다시 요청하도록 고쳐 사용자에게 허용을 받는다.', '권한 거부가 APNs 오류로 돌아온다고 본 오해. 권한은 기기에서 표시 여부만 가를 뿐 APNs 요청 결과와는 무관하고, 판매자 앱 사용자 전원이 똑같이 실패한 것도 권한으로는 설명되지 않는다.', false),

-- 문제 5293
(14291, 5293, '(가) 채팅방 17로 이동하고, (나) 채팅방 17로 이동한 뒤 읽음 처리 API를 부른다.', '버튼을 누르면 배너 탭 처리까지 함께 거친다고 본 오해. 한 번의 응답에는 actionIdentifier가 하나뿐이라 (나)는 MARK_READ 분기만 실행되고 화면 이동 분기는 타지 않는다.', false),
(14292, 5293, '(가) 아무 화면으로도 이동하지 않고, (나) 화면 이동 없이 읽음 처리 API만 부른다.', '배너 탭이 default 분기로 빠진다고 본 오해. 배너 자체를 탭하면 actionIdentifier가 UNNotificationDefaultActionIdentifier로 들어와 라우터를 거쳐 채팅방으로 이동한다.', false),
(14293, 5293, '(가) 채팅방 17로 이동하고, (나) 앱 코드는 불리지 않고 시스템이 알림만 지운다.', '액션 버튼은 시스템이 알아서 처리한다고 본 오해. 버튼을 눌러도 같은 didReceive가 호출되고, 어떤 버튼인지는 앱이 actionIdentifier로 가려 직접 처리해야 한다.', false),
(14294, 5293, '(가) 채팅방 17로 이동하고, (나) 화면 이동 없이 읽음 처리 API만 부른다.', '배너를 탭하면 기본 식별자로, 버튼을 누르면 등록한 액션 식별자 MARK_READ로 같은 didReceive에 들어온다. 그래서 (가)는 라우터로 채팅방에 가고, (나)는 화면 이동 없이 읽음 처리만 한다.', true),

-- 문제 5294
(14295, 5294, '가족이 자기 휴대폰에서 지출을 기록하면 곧바로 내 휴대폰에 뜨는 알림', '다른 기기에서 생긴 일도 로컬 알림으로 알릴 수 있다고 본 오해. 가족 휴대폰의 기록은 통신 없이는 내 휴대폰으로 건너올 길이 없으므로, 서버가 기록을 받아 원격 푸시로 보내야 한다.', false),
(14296, 5294, '사용자가 입력한 월급날 오전 9시마다 이번 달 예산을 정하라고 권하는 알림', '로컬 알림은 특정 날짜·시각을 트리거로 쓸 수 있고, 월급날과 권유 문구는 앱이 이미 아는 정보다. 매월 25일 9시로 반복 예약해 두면 서버·통신 없이 기기가 스스로 띄우며, 표시에 필요한 알림 권한도 허용돼 있다.', true),
(14297, 5294, '사용자가 등록한 회사 반경 200m 안에 들어서면 점심값 기록을 권하는 알림', '위치 진입도 로컬 알림 트리거라 서버는 필요 없지만, 기기가 그 지역에 들어선 것을 감지하려면 위치 권한이 있어야 한다. 이 사용자는 위치 권한을 허용하지 않아 회사 근처에 가도 알림이 뜨지 않는다.', false),
(14298, 5294, '기획팀이 출시 뒤에 정한 날짜에 모든 사용자에게 이벤트를 공지하는 알림', '로컬 알림에도 날짜 트리거가 있으니 된다고 본 오해. 예약할 수 있는 것은 예약하는 순간 앱이 이미 아는 날짜·문구뿐이라, 출시 뒤에 정한 공지는 서버가 원격 푸시로 보내야 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1720, 5295, '6,6개,6건,6 개,6 건,여섯,여섯 개,여섯 건', 'aps의 badge는 지금 숫자에 더하는 값이 아니라 아이콘에 표시할 숫자 자체를 정하는 값이다. 마지막으로 받은 푸시가 09:40의 badge 6이므로, 10:10에 사용자가 웹에서 메시지를 읽어 서버의 안 읽은 수가 1이 됐어도 아이콘은 6에 머문다. 아이콘은 서버 상태를 스스로 따라가지 않으므로, 서버가 badge 1을 담은 푸시를 보내거나 앱이 실행될 때 서버 기준으로 다시 계산해 setBadgeCount로 갱신해야 한다. 받은 값을 모두 더해 8로 보거나, 서버의 안 읽은 수 1이 곧바로 반영된다고 보는 것이 흔한 오해다. badge를 0으로 보내면 숫자가 사라진다.'),
       (1721, 5296, 'Background Modes,background modes,BackgroundModes,Background Mode,background mode,백그라운드 모드,백그라운드모드,백그라운드 모드 기능,UIBackgroundModes', 'content-available 값 1인 사일런트 푸시로 백그라운드의 앱을 깨우려면, 앱 타깃에 Background Modes 기능을 추가하고 그 안의 Remote notifications 항목을 켜야 한다. 이 설정이 없으면 APNs가 요청을 받아들여도(200) 기기가 앱을 깨우지 않아 application(_:didReceiveRemoteNotification:fetchCompletionHandler:) 콜백이 불리지 않는다. 발문이 묻는 것은 새로 추가한 기능 자체의 이름이므로, 그 안에서 체크한 항목 이름인 Remote notifications와 헷갈리지 않아야 한다. 배너를 띄우는 일반 알림은 Push Notifications 기능만으로 충분하므로 둘을 구분해야 한다. 켠 뒤에도 깨우는 빈도와 시점은 시스템이 조절해 보낸 시각과 실행 시각이 어긋날 수 있으므로 실시간 갱신 수단으로 기대하면 안 된다. 같은 기능 안의 Background fetch 항목은 시스템이 정한 주기로 앱을 깨우는 별도 항목이라 푸시와는 관계가 없다.');
