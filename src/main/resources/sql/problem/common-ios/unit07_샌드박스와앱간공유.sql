-- Unit: 샌드박스와 앱 간 공유 (Unit ID: 108)
-- Chapter: iOS (Chapter ID: 9)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (534, 108, '컨테이너 경로 변경과 유니버설 링크'),
       (692, 108, '파일 보호 등급과 키체인·Team ID'),
       (850, 108, '번들 읽기 전용과 스킴 가로채기');

-- =====================================================
-- Lesson 534: 컨테이너 경로 변경과 유니버설 링크
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3383, 534, '아래 코드에서 업데이트 이후 data가 nil이 되는 원인으로 옳은 것은?', '```swift
// 최초 실행 시
let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let fileURL = docs.appendingPathComponent("notes.json")
try Data(text.utf8).write(to: fileURL, options: [.atomic, .completeFileProtection])
UserDefaults.standard.set(fileURL.path, forKey: "notePath")

// 앱 업데이트 후 다음 실행 (기기는 잠금 해제 상태, notePath 값은 그대로 남아 있음)
let saved = UserDefaults.standard.string(forKey: "notePath") ?? ""
let data = FileManager.default.contents(atPath: saved)   // nil
```', 'OBJECTIVE'),
       (3384, 534, '아래 데이터 공유 방식에 대한 설명으로 옳은 것은?', '메인 앱과 위젯 익스텐션은 서로 다른 프로세스로 실행되며 각자의 데이터 컨테이너를 갖는다. 두 타깃에 `group.com.example.myapp` 같은 동일한 식별자를 entitlement로 부여하면 시스템이 별도의 공유 컨테이너 디렉터리를 마련해 주고, 양쪽이 그 디렉터리의 파일과 `UserDefaults(suiteName:)`를 함께 읽고 쓸 수 있다.', 'OBJECTIVE'),
       (3385, 534, '아래 표의 두 전달 수단 A·B에 대한 설명으로 옳지 않은 것은?', '| 구분 | A | B |
|---|---|---|
| 전달 형태 | 앱 고유 스킴 주소로 앱 실행 + 짧은 파라미터 | 일반 웹 주소(https)로 앱 실행 + 경로·쿼리 |
| 사전 조건 | Info.plist에 스킴 등록 | 서버에 검증용 JSON 파일 게시 + Associated Domains entitlement |
| 등록 주체 | 제한 없음 (누구나 같은 스킴을 선언할 수 있음) | 해당 도메인의 소유자만 |', 'OBJECTIVE'),
       (3386, 534, '아래 코드와 증상을 볼 때, 종료 상태에서만 화면 이동이 되지 않는 원인은?', '```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    router.handle(url)
}

func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard let url = userActivity.webpageURL else { return }
    router.handle(url)
}

func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
           options connectionOptions: UIScene.ConnectionOptions) {
    window?.rootViewController = RootViewController()
}
```

증상: 앱이 실행 중일 때 myapp://order/123 이나 https://example.com/order/123 을 탭하면 주문 상세 화면이 열린다. 앱을 완전히 종료한 뒤 같은 링크를 탭하면 앱은 실행되지만 홈 화면만 보인다.', 'OBJECTIVE'),
       (3387, 534, '아래 상황에서 팀이 서버에 올려 문제를 해결한 파일의 이름은?', '이메일에 담긴 https://example.com/order/123 을 탭하면 앱이 설치돼 있는데도 늘 Safari로만 열렸다. 앱의 Associated Domains에는 applinks:example.com이 들어 있었고 링크를 받아 화면을 여는 라우터 코드도 정상이었다. 원인은 서버 쪽이었다. https://example.com/.well-known/ 아래에 있어야 할 파일이 404를 돌려주고 있었다. 그 파일을 확장자 없이 application/json으로 올리고 앱을 다시 설치하자 같은 링크가 앱에서 열렸다.', 'SUBJECTIVE'),
       (3388, 534, '아래 세 가지 결과가 모두 같은 구조에서 비롯된다. 그 구조를 가리키는 용어는?', '- 같은 기기에 설치된 다른 회사 메모 앱이 저장한 파일은 경로를 알아내도 읽기가 거부됐다.
- 사진 라이브러리는 시스템이 띄운 허용 창을 거치기 전에는 목록조차 받아 올 수 없었다.
- 반면 자기 앱이 Documents에 쓴 파일은 아무 권한 창 없이 바로 읽혔다.

결국 다른 앱의 문서는 UIDocumentPickerViewController로 사용자가 직접 고르게 하고, 사진은 권한 API를 거쳐 가져오도록 바꿨다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3383
(9195, 3383, '앱 번들은 코드 서명으로 무결성이 검증되어 런타임에 수정할 수 없으므로 첫 실행의 쓰기 자체가 실패했다.', '쓰기 대상은 읽기 전용인 앱 번들이 아니라 앱마다 따로 주어지는 데이터 컨테이너의 Documents다. 번들의 제약을 데이터 저장 경로에 잘못 갖다 붙인 오개념.', false),
(9196, 3383, '데이터 컨테이너 경로에 들어가는 UUID가 업데이트 과정에서 바뀌어, 저장해 둔 절대 경로가 더는 같은 파일을 가리키지 않는다.', '파일은 그대로 남아 있고 낡은 것은 경로 문자열이다. 그래서 절대 경로를 저장하지 말고 실행할 때마다 FileManager.default.urls(for:in:)로 컨테이너를 다시 구한 뒤 파일명을 붙여야 한다.', true),
(9197, 3383, 'Documents는 저장 공간이 부족할 때 시스템이 먼저 비우는 영역이라 업데이트 도중 파일이 삭제되었다.', '시스템이 임의로 지울 수 있는 곳은 Caches와 tmp다. Documents는 사용자 데이터 영역이라 백업 대상이며 시스템이 마음대로 비우지 않는다. 정리 정책을 뒤바꿔 이해한 오개념.', false),
(9198, 3383, 'completeFileProtection으로 쓴 파일이라 기기를 잠금 해제한 뒤에도 첫 접근은 항상 실패한다.', '이 보호 등급은 기기가 잠긴 동안에만 접근을 막는다. 본문은 잠금 해제 상태를 전제하므로 보호 등급은 nil의 원인이 될 수 없다.', false),

-- 문제 3384
(9199, 3384, '식별자 문자열만 똑같이 맞추면 다른 개발 팀이 배포한 앱과도 같은 저장 공간을 나눠 쓸 수 있다.', '접근 권한을 결정하는 것은 문자열이 아니라 서명에 담긴 Team ID다. 팀이 다르면 같은 식별자를 적어도 entitlement 검증에서 막힌다.', false),
(9200, 3384, '메인 앱이 값을 갱신하면 시스템이 위젯 화면을 곧바로 다시 그려 주므로 별도 요청이 필요 없다.', '저장소를 함께 본다고 화면이 자동으로 갱신되지는 않는다. 메인 앱이 WidgetCenter.shared.reloadAllTimelines() 등으로 타임라인 갱신을 요청해야 새 값이 위젯에 반영된다.', false),
(9201, 3384, '토큰이나 비밀번호도 이 저장 공간에 두면 별도 설정 없이 암호화되어 안전하게 보관된다.', '공유 컨테이너에 놓이는 것은 평문 파일과 plist다. 민감한 값은 Keychain Access Group을 따로 설정해 Keychain으로 공유하는 것이 맞다.', false),
(9202, 3384, '두 프로세스가 같은 파일에 동시에 쓰면 내용이 깨질 수 있어, 원자적 쓰기나 파일 코디네이터로 접근을 조율해야 한다.', '저장 공간이 공유될 뿐 프로세스 간 배타 제어까지 시스템이 대신해 주지는 않는다. .atomic 옵션이나 NSFileCoordinator로 쓰기 시점을 조정하고, 저장소 하나에 쓰기 담당을 한쪽으로 몰아두는 편이 안전하다.', true),

-- 문제 3385
(9203, 3385, 'A로 OAuth 인증 코드를 돌려받으면 같은 스킴을 미리 선언해 둔 다른 앱이 그 값을 가로챌 수 있다.', '참이다. 등록 주체에 제한이 없어 어느 앱이 열릴지 시스템이 보장하지 않는다. 그래서 인증 코드처럼 민감한 값의 콜백은 A로 받으면 안 된다.', false),
(9204, 3385, 'B는 서버에 파일을 게시할 수 있어야 해서, 운영 중인 웹 도메인이 없는 팀은 도입하기 어렵다.', '참이다. 사전 조건에 서버 게시가 들어 있어 앱 프로젝트 설정만으로는 끝나지 않는다. 도메인 소유가 곧 진입 장벽이자 위조를 막는 근거이기도 하다.', false),
(9205, 3385, 'B는 링크를 탭했을 때 앱이 설치돼 있지 않으면 아무 화면도 열리지 않아, 스토어로 보내는 대체 흐름을 따로 만들어야 한다.', '거짓이다. B가 쓰는 주소는 일반 웹 주소라 앱이 없으면 브라우저가 그 페이지를 그대로 연다. 아무 일도 일어나지 않아 대체 흐름을 손수 만들어야 하는 쪽은 A다.', true),
(9206, 3385, 'QR 코드처럼 앱 설치가 이미 전제된 경로라면 서버 설정 없이 A만으로도 화면 이동을 붙일 수 있다.', '참이다. A의 사전 조건은 Info.plist 등록뿐이라 도입 비용이 낮다. 설치가 보장된 내부 경로에서는 여전히 실용적이며, 실무에서는 B와 함께 지원해 한 라우터로 합류시킨다.', false),

-- 문제 3386
(9207, 3386, '실행되지 않은 상태에서 열릴 때는 URL과 사용자 활동이 willConnectTo의 connectionOptions로 전달되는데, 그 자리를 처리하지 않았다.', 'connectionOptions.urlContexts와 connectionOptions.userActivities를 꺼내 같은 라우터로 넘겨야 콜드 스타트 딥링크가 완성된다. 실행 중 경로와 종료 상태 경로를 모두 처리해야 한다.', true),
(9208, 3386, '앱이 종료된 상태에서는 시스템이 URL을 전달하지 않으므로, 사용자가 앱을 먼저 켠 뒤에만 링크가 동작한다.', '종료 상태에서도 URL과 사용자 활동은 앱을 띄우면서 함께 전달된다. 전달 자체가 없는 것이 아니라 전달되는 자리가 다를 뿐이라는 점을 놓친 오개념.', false),
(9209, 3386, 'Associated Domains entitlement가 빠져 있어 콜드 스타트에서만 도메인 검증이 실패한다.', '이 설정이 없으면 실행 중이든 아니든 웹 주소가 앱으로 오지 않고, 커스텀 스킴 링크는 애초에 그 설정과 무관하다. 실행 중에는 두 링크가 모두 동작한다는 증상과 맞지 않는다.', false),
(9210, 3386, 'AASA 파일이 Apple CDN에 캐시되어 있어 종료 상태에서는 예전 경로 목록으로 판정된다.', '캐시는 앱 설치·업데이트 시점의 도메인 검증에 영향을 줄 뿐 앱의 실행 상태와는 무관하다. 캐시가 문제였다면 실행 중에도 웹 링크가 Safari로 빠졌을 것이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1084, 3387, 'apple-app-site-association,apple app site association,AASA,AASA 파일,apple-app-site-association 파일', 'Universal Link는 도메인 소유자가 서버의 /.well-known/ 아래에 올린 apple-app-site-association(AASA) 파일을 Apple이 가져와, 그 안의 앱 식별자(Team ID + Bundle ID)와 허용 경로 목록을 앱과 대조하는 방식으로 앱과 도메인의 관계를 증명한다. 이 검증이 있어서 도메인을 소유하지 않은 앱은 남의 링크를 가로챌 수 없고, 링크 위조가 가능한 URL Scheme과 성격이 갈린다. 파일이 없거나 HTTPS가 아니거나 리다이렉트되면 검증이 실패해 링크가 브라우저로만 열린다. 앱 쪽 Associated Domains 설정, 커스텀 스킴을 등록하는 Info.plist의 CFBundleURLTypes와는 역할이 다르니 혼동하지 말 것.'),
       (1085, 3388, '샌드박스,샌드박싱,앱 샌드박스,sandbox,sandboxing,app sandbox', '앱마다 자기만의 데이터 컨테이너를 주고 그 밖의 자원 접근은 시스템 API와 사용자 동의를 거치게 하는 실행 환경이 샌드박스다. 자기 컨테이너 안은 자유롭게 읽고 쓰지만 다른 앱의 컨테이너는 경로를 알아도 열 수 없고, 사진·연락처처럼 컨테이너 밖 자원은 권한 모델을 통과해야 하며, 다른 앱의 문서는 UIDocumentPickerViewController처럼 시스템이 대신 열어 주는 창구로만 받아 온다. 같은 팀의 앱·익스텐션이 저장 공간을 나눠 쓰는 App Group은 이 벽을 허무는 것이 아니라 서명으로 허가된 공유 컨테이너를 하나 더 열어 주는 예외 통로다. 앱 번들을 런타임에 못 고치게 하는 코드 서명은 무결성을 지키는 별개의 장치이니 구분한다.');

-- =====================================================
-- Lesson 692: 파일 보호 등급과 키체인·Team ID
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4331, 692, '아래 코드와 로그에서 07:00에 draft.json 읽기만 실패한 원인으로 옳은 것은?', '```swift
let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

// 사용자가 앱 화면에서 저장 버튼을 누를 때 (기기 잠금 해제 상태)
try draft.write(to: docs.appendingPathComponent("draft.json"), options: [.atomic, .completeFileProtection])
try recent.write(to: docs.appendingPathComponent("recent.json"), options: [.atomic])

// 백그라운드 새로고침 때마다 호출
func refresh() {
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let d = try? Data(contentsOf: docs.appendingPathComponent("draft.json"))
    let r = try? Data(contentsOf: docs.appendingPathComponent("recent.json"))
    print("draft: \(d == nil ? "fail" : "ok"), recent: \(r == nil ? "fail" : "ok")")
}
```

```
06:58  사용자가 기기를 잠금 (부팅 후 이미 잠금 해제한 적 있음)
07:00  [백그라운드] draft: fail, recent: ok
07:40  사용자가 잠금 해제하고 메시지 앱을 사용 중
07:41  [백그라운드] draft: ok, recent: ok
```', 'OBJECTIVE'),
       (4332, 692, '아래 코드가 차례로 실행된 뒤 위젯 익스텐션에서 만들어지는 text의 값은?', '```swift
// 메인 앱과 위젯 익스텐션 두 타깃 모두 App Groups에 group.com.example.steps가 등록되어 있다.
// 위젯 익스텐션은 이 기기에서 UserDefaults에 값을 쓴 적이 없다.

// ① 메인 앱
let shared = UserDefaults(suiteName: "group.com.example.steps")!
shared.set(3, forKey: "todayCount")
UserDefaults.standard.set(7, forKey: "todayCount")
shared.set(shared.integer(forKey: "todayCount") + 1, forKey: "todayCount")
WidgetCenter.shared.reloadAllTimelines()

// ② 위젯 익스텐션 (① 이후 타임라인을 다시 만들 때)
let a = UserDefaults.standard.integer(forKey: "todayCount")
let b = UserDefaults(suiteName: "group.com.example.steps")!.integer(forKey: "todayCount")
let text = "\(a)/\(b)"
```', 'OBJECTIVE'),
       (4333, 692, '아래 코드와 증상에서 항상 else 분기로만 빠지는 원인으로 옳은 것은?', '```swift
// 결제 버튼을 누르면 파트너 결제 앱을 호출한다
let url = URL(string: "partnerpay://checkout?orderID=123")!
if UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url)
} else {
    showInstallGuide()   // 파트너 결제 앱 설치 안내 화면
}
```

- 파트너 결제 앱이 설치된 기기에서도 매번 설치 안내 화면이 뜬다.
- 같은 기기의 Safari 주소창에 `partnerpay://checkout?orderID=123`을 입력하면 파트너 결제 앱이 바로 열린다.
- 우리 앱 Info.plist의 CFBundleURLTypes에는 `myshop` 스킴만 들어 있다.', 'OBJECTIVE'),
       (4334, 692, '아래 테스트에서 1번 경우에만 앱이 열리지 않은 이유로 옳은 것은?', '앱이 설치된 iPhone에서 주문 링크 `https://shop.example.com/order/123`을 여러 곳에서 탭해 보았다. 앱의 Associated Domains에는 `applinks:shop.example.com`이 들어 있고, 서버의 apple-app-site-association(AASA) 파일은 `/order/*` 경로를 이 앱에 연결한다. 테스트는 표의 순서대로 몇 분 사이에 연달아 진행했다.

| 순서 | 링크를 탭한 곳 | 결과 |
|---|---|---|
| 1 | Safari로 연 `https://shop.example.com/events` 페이지 안의 링크 | 앱이 열리지 않고 Safari에서 주문 상세 웹 페이지로 이동 |
| 2 | 메일 앱 본문 | 앱이 열리고 주문 상세 화면 표시 |
| 3 | 메모 앱 | 앱이 열리고 주문 상세 화면 표시 |
| 4 | Safari로 연 `https://blog.partner.com/review` 페이지 안의 링크 | 앱이 열리고 주문 상세 화면 표시 |', 'OBJECTIVE'),
       (4335, 692, '아래 상황에서 팀이 토큰을 옮겨 저장한 곳을 가리키는 용어는?', '메인 앱과 공유 익스텐션이 같은 로그인 토큰을 써야 해서, 처음에는 공유 컨테이너의 `UserDefaults(suiteName:)`에 토큰을 넣었다. 보안 점검에서 암호화하지 않은 기기 백업을 풀자 공유 컨테이너의 plist 파일 안에 토큰 문자열이 그대로 보인다는 지적을 받았다.

팀은 plist에서 토큰 키를 지우고 저장 코드를 아래처럼 바꾼 뒤, 두 타깃의 entitlement에 같은 접근 그룹을 추가했다.

```swift
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccessGroup as String: "ABCDE12345.com.example.shared",
    kSecAttrAccount as String: "authToken",
    kSecValueData as String: Data(token.utf8)
]
let status = SecItemAdd(query as CFDictionary, nil)   // errSecSuccess
```

재점검에서 같은 방식으로 백업을 풀어도 파일 어디에서도 토큰 문자열이 나오지 않았고, 메인 앱과 공유 익스텐션 모두 로그인 상태를 유지했다.', 'SUBJECTIVE'),
       (4336, 692, '아래 두 문제를 해결하려고 공통으로 새 계정 값에 맞춰야 했던 식별자를 가리키는 용어는?', '회사가 앱 배포를 새 법인 개발자 계정으로 옮기던 날, 테스트 빌드에서 두 가지 문제가 한꺼번에 생겼다.

1. 메인 앱은 새 계정으로, 위젯 익스텐션은 옛 계정 설정이 남은 채로 서명됐다. 두 타깃 모두 `group.com.example.myapp`을 선언했는데도 위젯에서 `containerURL(forSecurityApplicationGroupIdentifier:)`가 nil을 돌려줬다. 위젯도 새 계정으로 다시 서명하자 메인 앱이 저장한 값이 위젯에 보였다.
2. 주문 링크를 탭하면 앱 대신 Safari가 열렸다. 서버 AASA 파일의 appIDs 값 `ABCDE12345.com.example.myapp`에서 Bundle ID 부분은 그대로 두고, 점 앞의 10자리만 새 계정 정보 화면에 표시된 `Q7K2M9X4LP`로 바꾸자 링크가 다시 앱으로 열렸다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4331
(11723, 4331, '보호 등급을 준 파일은 앱이 포그라운드에 있을 때만 열려서 백그라운드 새로고침에서는 읽을 수 없다.', '보호 등급이 막는 기준은 앱의 실행 상태가 아니라 기기의 잠금 여부다. 07:41에도 백그라운드 새로고침이었지만 기기가 잠금 해제된 상태라 draft.json이 읽혔다.', false),
(11724, 4331, '백그라운드로 실행될 때는 데이터 컨테이너의 UUID가 새로 정해져 draft.json의 위치를 찾지 못했다.', 'UUID는 재설치·업데이트 때 바뀔 수 있을 뿐 실행 상태에 따라 바뀌지 않는다. 코드는 매번 FileManager로 경로를 새로 구하고, 같은 폴더의 recent.json은 07:00에도 읽혔다.', false),
(11725, 4331, 'draft.json을 쓸 때 지정한 보호 등급이 기기가 잠긴 동안에는 그 파일의 내용을 읽지 못하게 막는다.', 'completeFileProtection으로 쓴 파일은 잠금 해제 상태에서만 접근할 수 있다. 옵션 없이 쓴 recent.json은 부팅 후 첫 잠금 해제만 지났다면 잠긴 동안에도 읽혀서 두 파일의 결과가 갈렸다.', true),
(11726, 4331, '기기가 잠긴 사이 저장 공간이 부족해지자 시스템이 Documents의 파일 일부를 먼저 지웠다.', '시스템이 임의로 지울 수 있는 곳은 Caches와 tmp이고, Documents는 백업 대상인 사용자 데이터 영역이다. 정말 지워졌다면 07:41에도 draft.json을 읽지 못했어야 한다.', false),

-- 문제 4332
(11727, 4332, '7/4', '위젯의 UserDefaults.standard가 메인 앱의 standard를 함께 본다고 오해한 값. standard는 타깃마다 자기 샌드박스에 따로 있어 위젯에서는 쓴 적 없는 키가 되어 0이 나온다.', false),
(11728, 4332, '0/4', '공유되는 것은 suiteName으로 연 저장소뿐이다. 메인 앱은 suite에 3을 쓰고 standard의 7과 무관하게 3에 1을 더해 4로 갱신했다. 위젯의 standard는 위젯 전용이라 값이 없어 integer(forKey:)가 0을 돌려준다.', true),
(11729, 4332, '8/8', 'App Group을 등록하면 standard도 그룹 저장소로 바뀐다고 오해해 7이 3을 덮어쓴 뒤 1을 더했다고 본 값. 등록 여부와 상관없이 standard는 각 타깃 전용이고, 공유는 suiteName으로 연 저장소에서만 일어난다.', false),
(11730, 4332, '0/0', 'App Group으로 공유되는 것은 containerURL 아래 파일뿐이라고 오해한 값. UserDefaults(suiteName:)도 공유 컨테이너에 저장되므로 위젯이 메인 앱이 쓴 4를 그대로 읽는다.', false),

-- 문제 4333
(11731, 4333, '우리 앱 Info.plist의 LSApplicationQueriesSchemes에 partnerpay를 선언하지 않아 설치 여부 조회가 거부됐다.', '다른 앱의 스킴에 canOpenURL을 쓰려면 그 스킴을 LSApplicationQueriesSchemes에 미리 적어 두어야 한다. 앱이 임의의 스킴을 두드려 사용자가 설치한 앱 목록을 알아내는 추적을 막으려는 제한이다.', true),
(11732, 4333, '우리 앱 Info.plist의 CFBundleURLTypes에 partnerpay를 등록하지 않아 시스템이 스킴을 인식하지 못했다.', 'CFBundleURLTypes는 우리 앱이 받을 스킴을 등록하는 곳이다. Safari에서 partnerpay://가 열리므로 시스템은 이미 이 스킴을 알고 있고, 같은 스킴을 우리 앱에도 등록하면 오히려 어느 앱이 열릴지 보장되지 않는다.', false),
(11733, 4333, '우리 앱 Associated Domains에 파트너사 도메인을 넣지 않아 앱 간 호출 검증에 실패했다.', 'Associated Domains는 https 웹 주소를 앱에 연결하는 Universal Link용 설정이다. 커스텀 스킴으로 앱을 열거나 설치 여부를 조회하는 흐름과는 관계가 없다.', false),
(11734, 4333, '샌드박스가 다른 앱의 설치 여부를 숨기므로 canOpenURL은 다른 앱의 스킴에 대해 늘 false를 돌려준다.', '설치 여부를 전부 숨기는 것이 아니라 미리 선언한 스킴에 한해 조회를 허용한다. 선언해 두면 앱이 설치된 기기에서는 true를 받아 open으로 넘어갈 수 있다.', false),

-- 문제 4334
(11735, 4334, 'Safari 안의 웹 페이지에서 탭한 링크는 앱으로 넘기지 않고 항상 웹 페이지로 이동시킨다.', 'Safari에서 탭했다는 사실만으로 막히지 않는다. 4번처럼 다른 도메인의 페이지에서 탭한 링크는 앱으로 열렸으니, 1번과 4번을 가른 것은 보고 있던 페이지의 도메인이다.', false),
(11736, 4334, 'Apple CDN이 예전 AASA 파일을 캐시하고 있어 /order/* 경로가 기기에 아직 등록되지 않았다.', '경로가 등록되지 않았다면 탭한 곳과 상관없이 모두 웹으로 열렸어야 한다. 몇 분 뒤 이어진 2~4번에서 앱이 열렸으므로 기기 등록은 이미 끝나 있었다.', false),
(11737, 4334, '테스트 전에 사용자가 배너의 Safari에서 열기를 골라 이 도메인 링크가 웹으로 열리게 바뀌어 있었다.', '그 선택은 탭한 곳과 관계없이 이 도메인의 링크 전체에 적용된다. 설정이 바뀌어 있었다면 2~4번도 앱 대신 Safari로 열렸어야 한다.', false),
(11738, 4334, '보고 있던 페이지와 링크의 도메인이 같으면 시스템이 의도적으로 앱을 열지 않는다.', '사용자가 이미 그 사이트를 웹으로 보고 있다면 같은 도메인 안의 이동은 웹에서 계속하려는 의도로 보고 앱으로 넘기지 않는다. 1번은 shop.example.com 페이지에서 같은 도메인 링크를 탭했다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1400, 4335, '키체인,Keychain,키체인 공유,Keychain Sharing,키체인 액세스 그룹,Keychain Access Group,키체인 접근 그룹,키체인 서비스,Keychain Services,iOS 키체인,iOS Keychain', '토큰·비밀번호처럼 민감한 값은 평문 파일로 남는 공유 컨테이너가 아니라 시스템이 암호화해 관리하는 키체인에 둔다. 본문의 SecItemAdd와 kSecClassGenericPassword가 키체인 항목을 다루는 API이고, kSecAttrAccessGroup과 entitlement의 접근 그룹(Keychain Access Group)을 같은 팀의 타깃끼리 맞추면 메인 앱과 익스텐션이 같은 항목을 함께 읽는다. 파일·UserDefaults·Core Data 같은 일반 데이터를 나누는 App Group과는 공유 대상이 다르다. 파일에 거는 보호 등급(completeFileProtection)은 잠긴 동안의 파일 접근을 막는 장치일 뿐, 비밀값을 어디에 보관할지 정하는 수단과는 역할이 다르니 구분한다.'),
       (1401, 4336, 'Team ID,팀 ID,TeamID,팀 아이디,Team Identifier,팀 식별자,개발 팀 ID,App ID Prefix,앱 ID 접두사,App ID 프리픽스', 'Team ID는 Apple 개발자 계정(팀)마다 부여되는 10자리 식별자로, 서명에 담겨 누가 만든 앱인지 증명한다. App Group의 공유 컨테이너는 같은 Team ID로 서명된 타깃에게만 열리므로 group 식별자 문자열이 같아도 팀이 다르면 접근이 거부된다. Universal Link는 AASA의 appIDs에 적힌 Team ID + Bundle ID를 앱의 서명과 대조해 도메인과 앱의 관계를 검증한다. 앱마다 다른 Bundle ID(com.example.myapp), 공유 저장소 이름인 App Group 식별자(group.으로 시작)와 헷갈리지 말 것. 두 사건 모두 Bundle ID와 group 식별자는 그대로였고 바뀐 것은 팀 값뿐이었다.');

-- =====================================================
-- Lesson 850: 번들 읽기 전용과 스킴 가로채기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5279, 850, '아래 코드에서 두 번째 write만 실패하는 원인으로 옳은 것은?', '```swift
// config.json 은 앱 번들에 함께 빌드된 기본 설정 파일이다.
let bundleURL = Bundle.main.url(forResource: "config", withExtension: "json")!
let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

var config = try JSONDecoder().decode(Config.self, from: Data(contentsOf: bundleURL))   // ok
config.theme = "dark"
let updated = try JSONEncoder().encode(config)

try updated.write(to: docs.appendingPathComponent("config.json"), options: .atomic)     // ok
try updated.write(to: bundleURL, options: .atomic)                                      // 오류
```

- 기기는 잠금 해제 상태이고, 앱은 설치 직후 처음 실행한 것이다.
- 시뮬레이터에서는 오류가 나지 않고 실제 기기에서만 재현되며, 재설치해도 같은 줄에서 같은 오류가 난다.', 'OBJECTIVE'),
       (5280, 850, '아래 코드와 증상에서 위젯이 옛 값을 계속 보여 주는 원인으로 옳은 것은?', '```swift
// 메인 앱과 위젯 익스텐션 두 타깃 모두 App Groups 에 group.com.example.habit 이 등록돼 있다.
enum SharedStore {
    static let defaults = UserDefaults(suiteName: "group.com.example.habit")!
}

// 메인 앱: 사용자가 습관을 체크할 때
func check() {
    let now = SharedStore.defaults.integer(forKey: "todayCount")
    SharedStore.defaults.set(now + 1, forKey: "todayCount")
}

// 위젯 익스텐션
struct Provider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let count = SharedStore.defaults.integer(forKey: "todayCount")
        completion(Timeline(entries: [Entry(date: .now, count: count)], policy: .atEnd))
    }
}
```

증상: 앱에서 체크한 직후 홈 화면으로 나가면 위젯은 여전히 이전 숫자를 보여 준다. 그대로 한참 두거나 위젯을 지웠다 다시 추가하면 그때는 올바른 숫자가 나온다.', 'OBJECTIVE'),
       (5281, 850, '아래 사고를 되풀이하지 않기 위한 조치로 옳은 것은?', '[설계] 로그인 서버가 인증을 마치면 shopapp://auth?code=XXXX 로 앱을 열어 인증 코드를 돌려주고, 앱은 그 코드를 우리 서버에 보내 액세스 토큰으로 바꾼다.

[사고 기록]
```
09:12  피해 제보 접수. 로그인 버튼을 누른 뒤 우리 앱이 아니라 무료 배경화면 앱이 전면에 떴다.
09:26  그 앱의 Info.plist 를 확인하니 CFBundleURLTypes 에 shopapp 이 함께 적혀 있었다.
09:41  서버 로그 확인. 같은 계정의 인증 코드가 우리 앱이 아닌 외부 주소에서 토큰으로 교환됐다.
10:05  문의 답변: 특정 스킴 문자열을 우리 앱 앞으로 선점해 두는 절차는 제공되지 않는다.
```', 'OBJECTIVE'),
       (5282, 850, '아래 설정이 적용된 기기에서 메일 앱 본문의 링크를 탭했을 때 앱이 열리는 것은?', '앱은 설치돼 있고 Associated Domains 에 applinks:shop.example.com 이 들어 있다. 서버가 돌려주는 apple-app-site-association 파일은 아래와 같고, 기기 등록은 이미 끝난 상태다. 시스템은 components 를 위에서 아래로 훑어 **마지막으로 들어맞은 항목**의 판정을 따른다.

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["ABCDE12345.com.example.shop"],
        "components": [
          { "/": "/order/*" },
          { "/": "/promo/*", "?": { "campaign": "?*" } },
          { "/": "/order/help", "exclude": true }
        ]
      }
    ]
  }
}
```', 'OBJECTIVE'),
       (5283, 850, '아래 작업에서 메인 앱과 위젯 두 타깃에 함께 켠 프로젝트 설정의 이름은?', '습관 기록 앱에 위젯을 붙인 첫 빌드에서 홈 화면 위젯이 늘 "기록 없음"만 보여 줬다. 같은 순간 메인 앱 화면에는 오늘 기록 12건이 들어 있었고, 위젯 코드는 메인 앱과 똑같은 키 문자열로 값을 읽고 있었다.

두 타깃이 값을 읽어 온 자리를 찍어 보니 아래와 같았다.

```
메인 앱  /var/mobile/Containers/Data/Application/3F0A.../Library/Preferences/
위젯     /var/mobile/Containers/Data/Application/9C71.../Library/Preferences/
```

Xcode 의 Signing & Capabilities 에서 두 타깃에 같은 항목을 켜고 양쪽에 동일한 식별자를 지정한 뒤, 저장을 UserDefaults.standard 대신 UserDefaults(suiteName:) 로 바꾸자 위젯에도 12건이 나왔다.', 'SUBJECTIVE'),
       (5284, 850, '아래 점검에서 원인으로 밝혀진, 앱 A 에만 빠져 있던 설정 항목의 이름은?', '주문 링크 https://shop.example.com/order/842 가 앱이 설치된 기기에서도 늘 브라우저로만 열렸다. 같은 링크를 사내 다른 앱 B 에서 다루면 앱으로 잘 열렸다. 두 앱을 나란히 놓고 점검한 결과는 아래와 같다.

| 점검 항목 | 앱 A (안 열림) | 앱 B (열림) |
|---|---|---|
| 서버 apple-app-site-association 응답 | 200, HTTPS, JSON 형식 정상 | 같은 서버라 동일 |
| AASA 의 appIDs 와 앱의 Team ID·Bundle ID | 일치 | 일치 |
| 링크를 받아 화면을 여는 라우터 코드 | 있음 | 있음 |
| .entitlements 안의 applinks:shop.example.com 배열 | 키 자체가 없음 | 있음 |

앱 A 에 그 키를 채워 넣고 다시 서명해 설치하자 같은 링크가 앱에서 열렸다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5279
(14251, 5279, '앱 번들 경로에 들어 있는 UUID가 실행할 때마다 새로 정해져, write 시점에는 존재하지 않는 경로가 된다.', '경로의 UUID는 재설치·업데이트 때 바뀔 수 있을 뿐 한 번의 실행 도중에 달라지지 않는다. 바로 앞에서 같은 bundleURL로 읽기가 성공했으니 경로가 사라진 것은 아니다.', false),
(14252, 5279, '앱 번들은 코드 서명으로 무결성이 검증되는 읽기 전용 영역이라 실행 중에 내용을 바꿀 수 없다.', '번들을 실행 중에 고칠 수 있으면 서명 검증이 무의미해진다. 그래서 번들의 파일은 초기값을 읽어 오는 용도로만 쓰고, 사용자가 바꾸는 설정은 데이터 컨테이너에 쓴다. 앞 줄의 Documents 쓰기가 성공한 것도 그쪽이 쓰기 가능한 영역이기 때문이다.', true),
(14253, 5279, '.atomic 옵션은 같은 디렉터리에 임시 파일을 만들었다가 바꿔치우는데, 대상 이름의 파일이 이미 있어 충돌한다.', '.atomic은 기존 파일을 안전하게 덮어쓰기 위한 옵션이지 이름 충돌을 일으키지 않는다. 같은 옵션으로 쓴 Documents 쪽은 성공했으므로 옵션이 원인이라면 두 줄이 함께 실패했어야 한다.', false),
(14254, 5279, '번들 안의 파일에는 completeFileProtection이 기본으로 걸려 있어 잠금 해제 상태에서도 쓰기가 막힌다.', '파일 보호 등급은 기기가 잠긴 동안의 접근을 제한하는 장치라 잠금 해제 상태에서는 오히려 접근이 허용된다. 읽기·쓰기를 가르는 설정도 아니어서 이 오류의 원인이 될 수 없다.', false),

-- 문제 5280
(14255, 5280, '메인 앱이 위젯에 타임라인을 다시 만들라고 요청하지 않아, 위젯이 예전에 받아 둔 항목을 그대로 그린다.', '저장소를 함께 본다고 위젯 화면이 자동으로 다시 그려지지는 않는다. 값을 바꾼 쪽에서 WidgetCenter.shared.reloadAllTimelines()로 갱신을 요청해야 getTimeline이 다시 불린다. 요청이 없어도 정책에 따라 언젠가는 갱신되므로 한참 뒤에는 새 숫자가 보인다.', true),
(14256, 5280, 'UserDefaults(suiteName:)에 쓴 값은 synchronize()를 불러 주기 전까지 디스크에 남지 않아 다른 프로세스가 읽지 못한다.', '저장 시점은 시스템이 알아서 관리하며 synchronize()는 이제 호출할 필요가 없는 API다. 정말 저장이 안 됐다면 위젯을 지웠다 다시 추가해도 이전 숫자만 나왔어야 한다.', false),
(14257, 5280, '위젯 익스텐션은 자기 샌드박스 안만 볼 수 있어 다른 타깃이 쓴 저장소의 값은 끝내 읽지 못한다.', '두 타깃에 같은 그룹 식별자를 주면 각자의 컨테이너 바깥에 마련된 저장소를 함께 쓸 수 있다. 위젯을 다시 추가했을 때 올바른 숫자가 나왔다는 것 자체가 값이 건너갔다는 증거다.', false),
(14258, 5280, '두 타깃의 그룹 식별자 문자열은 같아도 서명에 담긴 팀이 달라 위젯이 자기 컨테이너를 보고 있다.', '팀이 다르면 entitlement 검증에서 막혀 공유 저장소 접근 자체가 열리지 않는다. 그랬다면 시간이 지나도, 위젯을 다시 추가해도 새 숫자는 영영 보이지 않았을 것이다.', false),

-- 문제 5281
(14259, 5281, '콜백 스킴을 팀만 아는 긴 무작위 문자열로 바꿔 다른 앱이 같은 스킴을 등록하지 못하게 한다.', '스킴 등록 자체에 제한이 없으므로 문자열을 숨기는 것은 대책이 아니다. 앱 바이너리나 통신 기록에서 스킴이 드러나는 순간 같은 가로채기가 그대로 되풀이된다.', false),
(14260, 5281, 'open 을 부르기 전에 canOpenURL 로 우리 앱이 열릴 스킴인지 확인한 뒤에만 URL을 연다.', 'canOpenURL은 그 스킴을 처리할 앱이 있는지만 알려 줄 뿐 어느 앱이 열릴지는 알려 주지 않는다. 게다가 이 흐름에서 콜백 URL을 여는 쪽은 우리 앱이 아니라 로그인 페이지를 띄운 브라우저다.', false),
(14261, 5281, 'Info.plist 의 LSApplicationQueriesSchemes 에 이 스킴을 적어 다른 앱이 쓰지 못하게 막는다.', '그 키는 우리 앱이 canOpenURL로 조회할 남의 스킴을 미리 선언하는 자리로, 설치 앱 목록 추적을 막으려는 제한이다. 남이 우리 스킴을 등록하는 것을 막는 설정이 아니다.', false),
(14262, 5281, '콜백을 도메인 소유가 검증되는 https 링크나 시스템이 제공하는 인증 세션으로 받도록 바꾼다.', '도메인 소유를 서버 파일로 증명한 앱만 그 주소를 가져갈 수 있어 가로채기가 구조적으로 막힌다. 브라우저 세션을 호출한 앱만 결과를 받는 ASWebAuthenticationSession도 같은 목적의 표준 경로다.', true),

-- 문제 5282
(14263, 5282, 'https://shop.example.com/cart', '/cart 는 components 의 어느 항목에도 들어맞지 않는다. 등록되지 않은 경로는 앱으로 넘어가지 않고 브라우저가 그대로 웹 페이지를 연다.', false),
(14264, 5282, 'https://shop.example.com/promo/spring', '/promo/* 항목에는 campaign 쿼리가 있어야 한다는 조건이 함께 붙어 있다. campaign 값이 없는 이 주소는 조건을 채우지 못해 들어맞지 않는다.', false),
(14265, 5282, 'https://shop.example.com/order/842', '/order/* 에 들어맞고, 뒤따르는 exclude 항목은 /order/help 만 가리키므로 이 주소를 건드리지 않는다. 마지막으로 들어맞은 판정이 허용이라 앱이 열린다.', true),
(14266, 5282, 'https://shop.example.com/order/help', '/order/* 에 한 번 들어맞지만 아래의 /order/help 항목이 exclude 라 마지막 판정이 제외로 뒤집힌다. 넓게 열어 둔 경로에서 일부만 빼는 흔한 설정 방식이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1716, 5283, 'App Group,App Groups,앱 그룹,앱 그룹스,앱그룹,앱그룹스,애플리케이션 그룹', '같은 팀이 서명한 앱·익스텐션·워치 앱이 파일과 UserDefaults, Core Data 저장소를 함께 쓰도록 각자의 컨테이너 바깥에 공용 저장 공간을 열어 주는 설정이 App Group이다. 본문에서 두 타깃의 경로 UUID가 서로 달랐던 것은 위젯이 메인 앱과 별개의 프로세스이자 별개의 샌드박스에서 돌기 때문이고, 같은 그룹 식별자를 양쪽 entitlement에 넣어야 비로소 UserDefaults(suiteName:)과 containerURL(forSecurityApplicationGroupIdentifier:)이 같은 자리를 가리킨다. 식별자 문자열만 맞추면 되는 것이 아니라 서명에 담긴 Team ID가 같아야 하므로, 다른 회사 앱과 데이터를 나누는 수단으로는 쓸 수 없다. 토큰·비밀번호처럼 민감한 값은 평문 plist로 남는 이 저장 공간 대신 Keychain Access Group으로 나눠야 하고, 공유 파일을 두 프로세스가 동시에 쓰면 내용이 깨질 수 있어 .atomic 쓰기나 NSFileCoordinator로 접근을 조율해야 한다는 점도 함께 기억할 것.'),
       (1717, 5284, 'Associated Domains,Associated Domain,연관 도메인,연결된 도메인,어소시에이티드 도메인,com.apple.developer.associated-domains', 'Universal Link는 서버 쪽 선언과 앱 쪽 선언이 맞물려야 동작한다. 서버의 apple-app-site-association 파일이 "이 도메인의 이 경로는 이 앱이 처리한다"를 밝히면, 앱은 Associated Domains 에 applinks:도메인 형태로 "이 도메인과 연결해 달라"를 밝혀야 한다. 한쪽만 있으면 교차 검증이 성립하지 않아 링크는 그냥 웹 페이지로 열린다. 본문에서 서버 응답도, appIDs 대조도, 라우터 코드도 같은데 결과가 갈린 이유가 바로 이 앱 쪽 선언의 유무다. 이 항목은 entitlement라서 추가한 뒤 다시 서명해 설치해야 반영된다. 커스텀 스킴을 우리 앱에 등록하는 Info.plist 의 CFBundleURLTypes, 남의 스킴을 조회하려고 선언하는 LSApplicationQueriesSchemes 와는 역할이 전혀 다르니 구분할 것. 두 선언이 다 맞는데도 배포 직후에만 동작하지 않는다면 Apple CDN 이 AASA 파일을 캐시하고 있어 반영이 늦는 경우를 의심한다.');
