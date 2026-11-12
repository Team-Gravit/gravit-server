-- Unit: 네트워크 계층 (Unit ID: 107)
-- Chapter: iOS (Chapter ID: 9)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (533, 107, '상태 코드 확인과 키 변환, 조건부 요청'),
       (691, 107, '백그라운드 전송과 요청 취소, 지수 백오프'),
       (849, 107, '세션 재사용과 관대한 디코딩, 캐시 정책');

-- =====================================================
-- Lesson 533: 상태 코드 확인과 키 변환, 조건부 요청
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3377, 533, '아래 URLSessionConfiguration으로 만든 세션에 대한 설명으로 옳은 것은?', '쇼핑 앱의 비회원 둘러보기 화면은 아래 성질을 갖는 URLSessionConfiguration을 만들어 세션에 넘긴다.

- 응답 캐시, 쿠키, 자격 증명을 디스크에 파일로 남기지 않고 메모리에만 보관한다.
- 타임아웃, 헤더, 요청 캐시 정책 등 나머지 설정은 기본 구성과 같다.', 'OBJECTIVE'),
       (3378, 533, '아래 코드에서 서버가 HTTP 500과 오류 메시지 JSON을 돌려줄 때 일어나는 일로 옳은 것은?', '서버는 /v1/users 요청에 대해 상태 코드 500과 함께 {"message": "internal error"} 본문을 돌려준다.

```swift
URLSession.shared.dataTask(with: url) { data, response, error in
    guard error == nil else { return self.showError() }
    let users = try! JSONDecoder().decode([User].self, from: data!)
    self.users = users
    self.tableView.reloadData()
}.resume()
```', 'OBJECTIVE'),
       (3379, 533, '아래 설정으로 응답 JSON을 Profile로 디코딩한 결과로 옳은 것은?', '```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase

struct Profile: Decodable {
    let displayName: String
    let avatarURL: URL?

    enum CodingKeys: String, CodingKey {
        case displayName
        case avatarURL = "avatar_url"
    }
}
```

응답 JSON

```json
{"display_name": "hana", "avatar_url": "https://cdn.example.com/a.png"}
```', 'OBJECTIVE'),
       (3380, 533, '아래 표를 바탕으로 판단할 때 옳지 않은 것은?', 'iOS 앱은 평문 HTTP 연결이 기본적으로 차단되며, Info.plist의 NSAppTransportSecurity 아래에 다음 키를 적어 예외를 둔다.

| 키 | 예외가 적용되는 범위 |
| --- | --- |
| NSAllowsArbitraryLoads | 앱이 보내는 모든 도메인의 평문 HTTP |
| NSExceptionDomains | 목록에 적어 둔 도메인에 한정 |
| NSAllowsArbitraryLoadsInWebContent | WKWebView가 불러오는 콘텐츠에 한정 |
| NSAllowsLocalNetworking | 로컬 네트워크 주소에 한정 |', 'OBJECTIVE'),
       (3381, 533, '아래 로그에서 10시 24분에 나간 요청을 부르는 HTTP 캐시 용어는?', '목록 화면을 두 번 열었을 때 URLSession이 남긴 기록이다.

```
[10:00] GET /v1/articles
        응답 200, 본문 84KB
        응답 헤더 Cache-Control: max-age=600, ETag: "a91f"

[10:24] GET /v1/articles
        요청 헤더 If-None-Match: "a91f"
        응답 304, 본문 0KB
        화면에는 10시에 받아 둔 84KB 응답이 그대로 그려짐
```', 'SUBJECTIVE'),
       (3382, 533, '아래 코드가 요청을 내보내지 못한 원인인, 빠뜨린 메서드의 이름은?', '서버 접근 로그에 이 요청이 한 건도 남지 않고, 완료 핸들러 안의 print도 찍히지 않는다. 오류 메시지조차 없다.

```swift
func loadUsers() {
    let task = URLSession.shared.dataTask(with: url) { data, _, _ in
        print("응답 \(data?.count ?? 0) 바이트")
    }
}
```

같은 요청을 `let (data, _) = try await URLSession.shared.data(for: request)`로 바꾸자 곧바로 응답이 돌아왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3377
(9179, 3377, '앱이 종료된 뒤에도 시스템 프로세스가 전송을 이어받아 진행 중이던 다운로드를 끝낸다.', '앱 종료 후에도 전송을 대행하는 것은 background 구성의 성질이다. 저장 위치를 메모리로 제한한 것과는 무관하며, 여기서는 앱 프로세스가 사라지면 전송도 함께 끊긴다.', false),
(9180, 3377, '앱을 껐다 켠 뒤 같은 서버를 호출하면 이전 로그인 쿠키가 남아 있지 않아 다시 인증해야 한다.', '쿠키와 자격 증명이 디스크에 기록되지 않으므로 앱 프로세스가 끝나면 함께 사라진다. 그래서 실행과 실행 사이에 인증 상태가 이어지지 않는다.', true),
(9181, 3377, '델리게이트를 붙일 수 없어 인증 요청이나 진행률을 직접 처리할 수 없다.', '델리게이트를 지정하지 못하는 것은 편의용 싱글턴인 URLSession.shared의 제약이다. 구성 객체를 넘겨 직접 만든 세션이라면 저장 위치와 상관없이 델리게이트를 붙일 수 있다.', false),
(9182, 3377, '응답의 Cache-Control 헤더를 무시하므로 같은 URL 요청도 매번 네트워크를 탄다.', '캐시를 어디에 두느냐만 달라졌을 뿐 HTTP 캐시 규칙은 그대로 적용된다. 헤더를 무시하고 항상 네트워크를 타게 하려면 요청 캐시 정책을 reloadIgnoringLocalCacheData로 바꿔야 한다.', false),

-- 문제 3378
(9183, 3378, 'error에 HTTP 500이 담기므로 guard에서 걸러져 showError()가 호출된다.', '전송 오류와 HTTP 오류를 같은 것으로 본 오해다. 서버가 응답을 돌려준 이상 전송은 성공이라 error는 nil이고, 상태 코드는 HTTPURLResponse.statusCode로 직접 확인해야 한다.', false),
(9184, 3378, '오류 응답에는 본문이 없어 data가 nil이므로 강제 언래핑 지점에서 중단된다.', '4xx, 5xx 응답도 본문을 함께 보낼 수 있다. 여기서는 오류 메시지 JSON이 data에 담겨 오므로 언래핑은 통과하고, 문제는 그다음 디코딩에서 터진다.', false),
(9185, 3378, 'guard를 그대로 통과한 뒤 오류 메시지 JSON을 [User]로 디코딩하려다 실패해 앱이 중단된다.', 'error가 nil이라 상태 코드 검사가 없는 이 코드는 500 응답을 정상 응답처럼 다룬다. 배열이 아닌 객체가 오니 디코딩이 오류를 던지고, try!가 그 오류를 크래시로 바꾼다.', true),
(9186, 3378, '디코딩이 빈 배열로 성공하고 reloadData()가 메인 스레드에서 실행돼 목록만 비워진다.', 'JSONDecoder는 형태가 맞지 않으면 빈 값을 채우지 않고 오류를 던진다. 또한 완료 핸들러는 백그라운드 큐에서 불리므로 UI 갱신은 메인 스레드로 옮겨야 한다.', false),

-- 문제 3379
(9187, 3379, '두 프로퍼티 모두 값이 채워진다. 전략이 처리하지 못한 키를 CodingKeys가 대신 맡기 때문이다.', '전략과 CodingKeys가 역할을 나눠 갖는다고 본 오해다. 전략이 먼저 JSON 키를 모두 바꾼 뒤 CodingKeys의 원시값과 비교하므로, 변환 결과와 원시값이 다르면 그 키는 어긋난다.', false),
(9188, 3379, 'display_name 키를 찾지 못해 keyNotFound 오류가 나고 디코딩 전체가 실패한다.', 'CodingKeys를 선언하면 전략이 꺼진다고 본 오해다. display_name은 전략에 의해 displayName으로 바뀌고, 원시값을 따로 적지 않은 case displayName과 그대로 맞아떨어진다.', false),
(9189, 3379, 'avatar_url 키를 찾지 못해 keyNotFound 오류가 나고 디코딩 전체가 실패한다.', '키가 어긋나는 것까지는 맞지만, 옵셔널 프로퍼티는 키가 없어도 오류 대신 nil이 된다. 선택 필드를 옵셔널로 두는 이유가 바로 이 관대함이다.', false),
(9190, 3379, 'displayName에는 hana가 들어가지만 avatarURL은 키가 어긋나 nil로 남는다.', '전략이 avatar_url을 avatarUrl로 바꾼 뒤 원시값 avatar_url과 비교해 맞지 않는다. 옵셔널이라 nil이 되고, display_name 쪽은 displayName으로 바뀌어 일치한다.', true),

-- 문제 3380
(9191, 3380, 'NSAllowsArbitraryLoadsInWebContent를 켜면 웹뷰뿐 아니라 앱이 직접 호출하는 API도 평문으로 보낼 수 있다.', '표에서 이 키의 범위는 WKWebView가 불러오는 콘텐츠뿐이다. 앱 코드가 URLSession으로 직접 보내는 요청은 그대로 차단되므로 거짓이다.', true),
(9192, 3380, '구형 서버 한 곳만 HTTPS를 지원하지 않는다면 NSExceptionDomains로 그 도메인만 열고 나머지는 보호를 유지할 수 있다.', '참이다. 이 키의 범위는 목록에 적어 둔 도메인뿐이라, 예외를 최소한으로 좁히면서 다른 통신에는 평문 차단을 그대로 적용할 수 있다.', false),
(9193, 3380, '사내 IoT 기기와 평문으로 통신해야 한다면 전체 허용 대신 NSAllowsLocalNetworking으로 범위를 줄일 수 있다.', '참이다. 사내 IoT 기기는 로컬 네트워크 주소로 접근하므로 이 키의 범위 안에 들어간다. 필요한 만큼만 여는 편이 심사에서도 사유를 설명하기 쉽다.', false),
(9194, 3380, 'NSAllowsArbitraryLoads는 네 키 가운데 예외 범위가 가장 넓어 도메인 한 곳 때문에 켜기에는 과하다.', '참이다. 범위가 앱이 보내는 모든 도메인이라, 서버 한 곳을 위해 켜면 나머지 통신까지 평문을 허용하게 된다. 그래서 도메인 단위 예외가 원칙이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1082, 3381, '조건부 요청,조건부요청,조건부 GET,conditional request,conditional GET,재검증 요청,캐시 재검증,revalidation', '저장해 둔 응답을 그대로 써도 되는지 서버에 확인하는 요청이다. max-age 600초가 지나 캐시가 만료됐지만 URLSession은 곧장 버리지 않고, 1차 응답의 ETag 값을 If-None-Match에 실어 보낸다. 서버는 바뀐 것이 없으면 304만 돌려주고 본문 84KB의 전송을 생략하며, 클라이언트는 캐시에 있던 본문을 재사용한다. max-age 안이라 네트워크를 아예 타지 않는 캐시 적중과 다르고, 캐시를 버리고 처음부터 다시 받는 reloadIgnoringLocalCacheData와도 구분한다.'),
       (1083, 3382, 'resume,resume(),task.resume(),task.resume,dataTask.resume()', 'dataTask(with:completionHandler:)는 일시 정지 상태의 URLSessionTask를 만들어 돌려줄 뿐이다. 그래서 요청이 나가지 않고 완료 핸들러도 불리지 않으며, 실패한 것이 아니라 시작조차 안 했으므로 오류도 남지 않는다. task.resume()을 호출해야 전송이 시작된다. async 버전 data(for:)는 호출 즉시 전송을 시작하므로 이 실수 자체가 사라진다. 요청은 나갔는데 응답 처리가 안 되는 경우(상태 코드 미검사, 메인 스레드 미전환)와는 원인이 다르니 구분해서 보라.');

-- =====================================================
-- Lesson 691: 백그라운드 전송과 요청 취소, 지수 백오프
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4325, 691, '아래 상황에서 다운로드가 끝났을 때 일어나는 일로 옳은 것은?', '팟캐스트 앱이 아래 코드로 320MB짜리 에피소드 파일을 받기 시작했다. 사용자가 홈 화면으로 나가 다른 앱을 오래 쓰는 사이, 시스템이 메모리를 확보하려고 이 앱의 프로세스를 종료했다. 그 뒤에 다운로드가 끝났다.

```swift
let config = URLSessionConfiguration.background(withIdentifier: "com.example.podcast.download")
let session = URLSession(configuration: config, delegate: downloader, delegateQueue: nil)
session.downloadTask(with: episodeURL).resume()
```', 'OBJECTIVE'),
       (4326, 691, '아래 코드에서 사용자가 글자를 빠르게 이어 입력했을 때 일어나는 일로 옳은 것은?', '검색창에 글자를 입력할 때마다 `search(_:)`가 메인 스레드에서 호출된다. 검색 응답은 보통 0.8초 뒤에 도착하는데, 사용자가 "s", "sw", "swi"를 0.2초 간격으로 입력했다. `client.fetch`는 내부에서 `session.data(for:)`로 요청을 보내 응답을 디코딩해 돌려주며, 도중에 난 오류는 그대로 다시 던진다.

```swift
final class SearchViewController: UIViewController {
    private var searchTask: Task<Void, Never>?

    func search(_ keyword: String) {
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            do {
                let items = try await client.fetch([Item].self, from: makeRequest(keyword))
                render(items)
            } catch {
                showError(error)
            }
        }
    }
}
```', 'OBJECTIVE'),
       (4327, 691, '아래 로그를 바탕으로 판단한 디코딩 결과로 옳은 것은?', '상품 목록 API를 호출한 뒤 아래 코드의 `catch` 블록이 로그를 한 줄 남겼다.

```swift
struct ProductPage: Decodable {
    let items: [Product]
}

struct Product: Decodable {
    let id: Int
    let name: String
    let price: Int
}

do {
    let page = try decoder.decode(ProductPage.self, from: data)
    render(page.items)
} catch let DecodingError.typeMismatch(type, context) {
    print("타입 불일치: \(type), 경로: \(context.codingPath.map(\.stringValue))")
} catch {
    print("기타 오류: \(error)")
}
```

로그

```
타입 불일치: Int, 경로: ["items", "Index 2", "price"]
```', 'OBJECTIVE'),
       (4328, 691, '아래 점검 결과를 바탕으로 판단할 때, 앱에서 연결에 성공하는 서버는?', '쇼핑 앱이 호출하는 서버 네 곳의 TLS 설정을 점검했다. 앱의 `Info.plist`에는 `NSAppTransportSecurity` 항목이 없고, 네 서버 모두 https 주소로 호출한다. 인증서는 모두 신뢰할 수 있는 인증 기관(CA)이 발급했으며 공개 키는 RSA 2048비트다.

| 서버 | TLS 버전 | 키 교환 방식 | 인증서 서명 해시 |
| --- | --- | --- | --- |
| search.shop.example | TLS 1.1 | ECDHE | SHA-256 |
| review.shop.example | TLS 1.3 | ECDHE | SHA-1 |
| order.shop.example | TLS 1.2 | RSA | SHA-256 |
| catalog.shop.example | TLS 1.2 | ECDHE | SHA-256 |', 'OBJECTIVE'),
       (4329, 691, '아래 기록에서 2차 배포 때 ??? 자리에 들어간 값은?', '보안 점검에서 앱의 디스크 캐시 파일(`Cache.db`)에 회원 주소·전화번호가 담긴 `/v1/me` 응답이 남아 있다는 지적을 받았다. 서버 팀이 응답 헤더를 두 차례 바꾸며 확인한 기록이다. 앱은 기본 캐시 정책(`useProtocolCachePolicy`)으로 요청한다.

```
[1차 배포] 응답 헤더  Cache-Control: private, max-age=300
                      ETag: "u42"
  - 요청 직후 Cache.db의 /v1/me 항목: 있음 (주소·전화번호 포함)
  - 1분 뒤 다시 요청: 네트워크 요청 없이 저장된 응답 사용

[2차 배포] 응답 헤더  Cache-Control: ???
                      ETag: "u42"
  - 요청 직후 Cache.db의 /v1/me 항목: 없음
  - 1분 뒤 다시 요청: If-None-Match 없는 일반 요청이 나가 200과 전체 본문 수신
```', 'SUBJECTIVE'),
       (4330, 691, '아래 로그에서 /v1/feed 요청 사이의 간격이 따르는 방식을 가리키는 용어는?', '지하철 구간을 지나는 동안 피드 화면의 `APIClient`가 남긴 요청 로그다. 실패는 모두 요청을 보낸 직후 곧바로 확인됐다.

```
08:30:00  GET /v1/feed        → 실패 URLError.notConnectedToInternet
08:30:01  GET /v1/feed        → 실패 URLError.networkConnectionLost
08:30:03  GET /v1/feed        → 실패 URLError.notConnectedToInternet
08:30:07  GET /v1/feed        → 실패 URLError.cannotConnectToHost
08:30:15  GET /v1/feed        → 200 OK
08:31:40  GET /v1/coupons/77  → 404 Not Found
          (이후 /v1/coupons/77 요청 없음)
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4325
(11707, 4325, '앱 프로세스와 함께 전송도 끊겨, 사용자가 앱을 다시 열면 처음부터 새로 받는다.', '앱 프로세스가 전송을 직접 맡는 default 구성의 동작을 갖다 붙인 오해다. background 구성은 별도 시스템 프로세스가 전송을 대행하므로 앱이 종료돼도 다운로드가 이어진다.', false),
(11708, 4325, '시스템이 앱을 백그라운드로 다시 실행해, 앱 델리게이트 메서드로 전송 완료 이벤트를 알린다.', '전송을 대행하던 시스템이 앱을 깨워 application(_:handleEventsForBackgroundURLSession:completionHandler:)를 호출한다. 앱은 같은 identifier로 세션을 다시 만들어 델리게이트로 받은 파일을 처리한다.', true),
(11709, 4325, '종료 전 메모리에 있던 downloader 객체가 그대로 복원돼, 곧바로 완료 콜백을 받는다.', '종료된 프로세스의 객체가 복원된다고 본 오해다. 프로세스와 함께 downloader도 사라지므로, 다시 실행된 앱이 같은 identifier로 세션과 델리게이트를 새로 만들어야 완료 이벤트를 받는다.', false),
(11710, 4325, '파일 전송은 끝나 있지만, 사용자가 앱을 직접 열기 전까지 앱 코드는 전혀 실행되지 않는다.', '완료 처리가 다음 실행까지 미뤄진다고 본 오해다. 시스템은 사용자를 기다리지 않고 앱을 백그라운드로 깨우며, 앱은 그때 임시 위치에 받은 파일을 옮기는 후처리를 한다.', false),

-- 문제 4326
(11711, 4326, '앞선 두 요청은 끝까지 전송되고, 늦게 도착한 응답이 최신 검색 결과를 덮어쓸 수 있다.', 'Task 취소가 진행 중인 네트워크 요청과 무관하다고 본 오해다. data(for:)를 기다리던 Task가 취소되면 내부 URLSessionTask도 함께 취소돼 전송이 끊기므로, 옛 응답이 뒤늦게 도착하지 않는다.', false),
(11712, 4326, '앞선 두 Task는 cancel() 호출 즉시 실행이 멈춰, render와 showError 모두 호출되지 않는다.', 'Task 취소를 스레드 강제 종료처럼 본 오해다. Swift의 취소는 신호만 보내는 협력 방식이라 Task는 계속 실행되고, 신호를 확인한 data(for:)가 오류를 던져 흐름이 catch로 넘어간다.', false),
(11713, 4326, '앞선 두 요청은 전송이 끊기고 await 지점에서 오류가 던져져, showError가 두 번 호출된다.', '취소 신호를 받은 data(for:)가 내부 URLSessionTask를 취소하고 취소 오류를 던진다. 이 오류도 catch로 들어가 앞선 두 Task 모두 showError에 닿으므로, 취소 오류는 따로 걸러 조용히 넘겨야 한다.', true),
(11714, 4326, '앞선 두 요청의 응답은 도착하지만, 취소된 Task라서 render가 메인 스레드 밖에서 실행된다.', '취소 여부가 실행 위치를 바꾼다고 본 오해다. @MainActor 클로저는 취소돼도 메인 액터에서 실행되며, 이 코드에서는 요청 자체가 끊겨 앞선 두 응답이 도착하지도 않는다.', false),

-- 문제 4327
(11715, 4327, '세 번째 상품의 price가 숫자가 아닌 값으로 와서, 목록 전체의 디코딩이 실패했다.', 'typeMismatch의 type은 모델이 기대한 타입(Int)이고, 경로의 Index 2는 0부터 센 배열 위치라 세 번째 요소다. 요소 하나만 어긋나도 decode 전체가 오류를 던지므로 render는 호출되지 않는다.', true),
(11716, 4327, '두 번째 상품의 price가 숫자가 아닌 값으로 와서, 목록 전체의 디코딩이 실패했다.', '경로의 Index 2를 1부터 센 위치로 읽은 오해다. codingPath에 찍히는 배열 인덱스는 Swift 배열처럼 0부터 시작하므로 Index 2는 세 번째 상품을 가리킨다.', false),
(11717, 4327, '세 번째 상품에 price 키가 아예 없어서, 목록 전체의 디코딩이 실패했다.', '키 누락과 타입 불일치를 같은 오류로 본 오해다. 키가 없으면 keyNotFound가 던져져 typeMismatch를 잡는 첫 catch에 걸리지 않는다. 이 로그가 찍혔으니 키는 있었고 값의 형태가 달랐다.', false),
(11718, 4327, '세 번째 상품의 price가 숫자가 아닌 값으로 와서, 그 상품만 빠진 목록이 만들어졌다.', '배열에서 실패한 요소만 건너뛴다고 본 오해다. JSONDecoder는 요소 하나가 실패하면 상위 decode 전체를 실패시키므로, 나머지 상품이 멀쩡해도 render까지 가지 못한다.', false),

-- 문제 4328
(11719, 4328, 'search.shop.example', 'https 주소면 ATS를 통과한다고 본 오해다. ATS는 TLS 1.2 이상을 요구하므로, 키 교환과 인증서가 요건을 채워도 TLS 1.1 서버와의 연결은 차단된다.', false),
(11720, 4328, 'review.shop.example', 'TLS 버전이 최신이면 나머지는 상관없다고 본 오해다. ATS는 인증서 서명에 SHA-256 이상을 요구하므로, TLS 1.3이어도 SHA-1로 서명한 인증서를 쓰면 연결이 차단된다.', false),
(11721, 4328, 'order.shop.example', 'TLS 버전만 맞추면 된다고 본 오해다. RSA 키 교환은 서버 개인 키가 유출되면 과거에 녹화된 트래픽까지 풀리는 방식이라 순방향 비밀성이 없어 ATS 요건을 채우지 못한다.', false),
(11722, 4328, 'catalog.shop.example', 'TLS 1.2 이상, 순방향 비밀성을 주는 ECDHE 키 교환, SHA-256 서명 인증서를 모두 갖춰 ATS 기본 요건을 통과한다. 셋 중 하나라도 어긋나면 https 주소여도 연결이 차단된다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1398, 4329, 'no-store,no store,nostore,Cache-Control: no-store,Cache-Control:no-store', 'no-store는 응답을 어떤 캐시에도 저장하지 말라는 지시어다. 그래서 2차 배포 뒤에는 Cache.db에 /v1/me 항목이 생기지 않았고, 꺼내 쓸 저장본이 없으니 다시 요청할 때도 조건부 요청 없이 전체 응답을 새로 받았다. 1차 배포의 private는 CDN·프록시 같은 공유 캐시의 저장만 막을 뿐, 기기 안의 URLCache 같은 개인 캐시 저장은 허용하므로 개인 정보가 디스크에 남았다. no-cache와도 구분해야 한다. no-cache는 저장은 허용하되 쓰기 전에 서버 재검증을 요구하므로, 이 경우 Cache.db에 항목이 남고 다시 요청할 때 ETag를 실은 If-None-Match 조건부 요청이 나간다.'),
       (1399, 4330, '지수 백오프,지수적 백오프,지수 백오프 재시도,지수 후퇴,지수적 후퇴,이진 지수 백오프,exponential backoff,exponential back-off,exponential backoff retry,binary exponential backoff,익스포넨셜 백오프', '실패할 때마다 다음 재시도까지 기다리는 시간을 1초, 2초, 4초, 8초처럼 두 배씩 늘리는 방식이 지수 백오프다. 끊긴 네트워크나 과부하가 걸린 서버에 요청을 연달아 퍼붓지 않고, 회복될 시간을 벌면서 다시 시도한다. 매번 같은 간격으로 반복하는 고정 간격 재시도와 구분하라. 또 재시도는 연결 끊김·타임아웃 같은 네트워크 오류에만 적용하며, 로그의 404처럼 요청 자체가 잘못된 4xx 응답은 다시 보내도 결과가 같으므로 재시도하지 않는다.');

-- =====================================================
-- Lesson 849: 세션 재사용과 관대한 디코딩, 캐시 정책
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5273, 849, '아래 기록에 나타난 동작에 해당하는 요청 캐시 정책은?', '뉴스 앱의 기사 목록 화면에서 URLRequest의 캐시 정책만 바꿔 가며 동작을 기록했다. 서버는 응답에 Cache-Control: max-age=60과 ETag를 함께 내려준다.

- 비행기 모드로 화면에 들어가니 앞서 받아 둔 목록이 곧바로 그려졌다.
- 비행기 모드를 풀고 마지막 수신 5분 뒤에 다시 들어가도 요청이 한 건도 나가지 않았고, 5분 전 목록이 그대로 떴다.
- 한 번도 연 적 없는 기사 상세 URL을 열자 Wi-Fi가 연결돼 있는데도 요청 없이 URLError.resourceUnavailable로 즉시 실패했다.', 'OBJECTIVE'),
       (5274, 849, '아래 코드로 화면 진입과 이탈을 반복할 때 메모리가 계속 늘어나는 원인으로 옳은 것은?', '상세 화면에 들어갈 때마다 ImageLoader를 새로 만들어 아래 load(_:)를 호출한다. 화면을 닫으면 그 ImageLoader를 가리키던 참조는 모두 사라진다. 진입과 이탈을 200번 반복하자 앱 메모리 사용량이 40MB에서 300MB로 계속 올랐고, 같은 호스트로 열린 연결 수도 함께 늘어났다.

```swift
final class ImageLoader: NSObject, URLSessionTaskDelegate {
    func load(_ url: URL) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        session.dataTask(with: url) { data, _, _ in
            // 이미지 처리
        }.resume()
    }
}
```', 'OBJECTIVE'),
       (5275, 849, '아래 모델로 응답을 디코딩한 결과로 옳은 것은?', '서버가 게시글 상태 값에 archived를 새로 추가한 날, 앱의 목록 화면이 통째로 비어 보인다는 제보가 들어왔다. 앱은 그 사이 배포한 적이 없다.

```swift
struct Post: Decodable {
    let id: Int
    let title: String
    let state: State?          // 서버가 값을 안 보낼 때가 있어 옵셔널로 둠

    enum State: String, Decodable {
        case draft, published
    }
}

let posts = try decoder.decode([Post].self, from: data)
```

응답 JSON

```json
[
  {"id": 1, "title": "가", "state": "published"},
  {"id": 2, "title": "나", "state": "archived"},
  {"id": 3, "title": "다"}
]
```', 'OBJECTIVE'),
       (5276, 849, '아래 설정을 넣은 앱에서 차단되지 않고 나가는 요청은?', '앱의 Info.plist에 아래 항목만 넣었고, 다른 ATS 관련 키는 넣지 않았다.

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>legacy.example.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <false/>
        </dict>
    </dict>
</dict>
```', 'OBJECTIVE'),
       (5277, 849, '아래 상황에서 디코딩한 이미지를 담아 둔 Foundation 클래스의 이름은?', '사진 목록 화면을 빠르게 스크롤하면 프레임이 끊긴다. 계측해 보니 이미지 바이트는 이미 URLCache에 들어 있어 네트워크 요청은 한 건도 나가지 않는데, 셀 하나를 그릴 때마다 JPEG를 펼치는 데 평균 11ms가 걸렸다.

펼친 UIImage를 URL 문자열을 키로 삼아 따로 담아 두자 같은 셀을 다시 그릴 때 0.4ms로 줄었다. 담아 둔 항목은 앱이 아무 코드도 실행하지 않았는데 메모리 경고가 뜬 뒤 개수가 줄어 있었고, 이어지는 스크롤에서 다시 채워졌다. 여러 스레드에서 동시에 넣고 꺼내도 따로 잠금을 걸지 않았다.', 'SUBJECTIVE'),
       (5278, 849, '아래 테스트에서 StubLoader가 상속한 Foundation 클래스의 이름은?', '네트워크가 막힌 CI 서버에서 APIClient 단위 테스트 12개가 모두 통과한다. 테스트는 200 정상 응답, 500 오류, 타임아웃, 깨진 JSON까지 골라 가며 재현하는데 서버 접근 로그에는 요청이 한 건도 남지 않는다. APIClient 코드는 테스트를 위해 한 줄도 고치지 않았고, 준비 코드는 아래가 전부다.

```swift
let config = URLSessionConfiguration.ephemeral
config.protocolClasses = [StubLoader.self]
let client = APIClient(session: URLSession(configuration: config))
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5273
(14235, 5273, 'useProtocolCachePolicy', 'HTTP 헤더 규칙을 그대로 따르는 기본값이다. 이 정책이었다면 max-age 60초가 지난 뒤에는 ETag를 실은 조건부 요청이 나갔어야 하고, 저장본이 없는 URL도 일반 요청으로 받아 왔을 것이다.', false),
(14236, 5273, 'reloadIgnoringLocalCacheData', '저장본을 무시하고 늘 네트워크를 타는 정책이라, 연결이 끊긴 비행기 모드에서 첫 기록처럼 목록이 그려질 수 없다. 당겨서 새로고침이나 결제 상태 조회처럼 최신값이 꼭 필요할 때 쓴다.', false),
(14237, 5273, 'returnCacheDataDontLoad', '만료 여부를 따지지 않고 저장본만 쓰며, 저장본이 없으면 네트워크를 타지 않고 곧바로 실패한다. 세 기록이 모두 이 동작이라 오프라인 모드 화면에 쓰인다.', true),
(14238, 5273, 'returnCacheDataElseLoad', '앞의 두 기록까지는 같지만 마지막이 어긋난다. 저장본이 없으면 네트워크로 받아 오는 정책이라, 연결이 살아 있는 상태에서 요청도 없이 실패하지는 않는다.', false),

-- 문제 5274
(14239, 5274, '요청이 끝나도 세션이 델리게이트를 강하게 붙들어, invalidate를 부르기 전까지 세션과 ImageLoader가 함께 남는다.', '세션은 직접 무효화하거나 앱이 끝날 때까지 델리게이트 참조를 놓지 않는다. 호출마다 세션을 새로 만들면 그만큼 쌓이므로, 세션 하나를 만들어 재사용하고 다 쓰면 finishTasksAndInvalidate를 불러 정리해야 한다.', true),
(14240, 5274, 'URLSession.shared로 바꾸면 델리게이트를 그대로 붙인 채 쓸 수 있어 세션이 쌓이지 않는다.', 'shared는 구성도 델리게이트도 지정할 수 없는 편의용 싱글턴이라 이 코드의 델리게이트를 그대로 옮길 수 없다. 델리게이트가 필요하면 세션을 직접 만들어 한 번만 생성하고 재사용하는 쪽이 답이다.', false),
(14241, 5274, '완료 핸들러가 백그라운드 큐에서 불리는 탓에 ImageLoader가 메인 스레드보다 먼저 해제돼 참조가 꼬인다.', '핸들러가 백그라운드 큐에서 불리는 것은 맞지만 그것이 해제 시점을 앞당기지는 않는다. 오히려 클로저가 self를 붙드는 동안에는 해제되지 않으며, 어느 큐에서 불리느냐와 메모리 증가는 별개다.', false),
(14242, 5274, '화면을 닫을 때 세션도 함께 사라져 진행 중이던 요청이 취소되고, 취소된 작업이 회수되지 않는다.', '세션이 화면과 생명주기를 같이한다고 본 오해다. 무효화하지 않은 세션은 화면이 사라진 뒤에도 살아남아 요청을 끝까지 마치므로, 취소가 아니라 누적이 일어난다.', false),

-- 문제 5275
(14243, 5275, 'id 2번의 state만 nil이 되고, 세 건 모두 목록에 그려진다.', '옵셔널이 알 수 없는 값까지 받아 넘긴다고 본 오해다. 옵셔널은 키가 없을 때만 nil을 허용하고, 값이 있는데 어느 케이스와도 맞지 않으면 그대로 오류를 던진다.', false),
(14244, 5275, '알 수 없는 값을 받은 id 2번의 state가 첫 케이스인 draft로 채워진다.', '열거형이 모르는 값을 첫 케이스로 대신한다고 본 오해다. 원시값 열거형은 맞는 케이스가 없으면 조용히 대체하지 않고 dataCorrupted 오류를 던진다.', false),
(14245, 5275, 'state 키가 아예 없는 id 3번에서 keyNotFound 오류가 나 디코딩이 실패한다.', '옵셔널 프로퍼티는 키가 없으면 오류 대신 nil이 된다. 그래서 3번은 그대로 통과하며, 걸리는 쪽은 케이스에 없는 값을 보낸 2번이다.', false),
(14246, 5275, 'id 2번의 state 값이 어느 케이스와도 맞지 않아 오류가 나고, 배열 전체 디코딩이 실패한다.', '옵셔널은 키 누락에만 관대하다. 원시값이 draft도 published도 아니면 dataCorrupted가 던져지고 상위 배열까지 실패해 화면이 빈다. unknown 케이스를 두면 새 값에도 버틴다.', true),

-- 문제 5276
(14247, 5276, 'URLSession으로 보내는 http://api.legacy.example.com/v1/items 요청', 'NSIncludesSubdomains가 false라 예외는 적어 둔 호스트 한 곳에만 적용된다. api.를 붙인 서브도메인은 예외 밖이라 평문 요청이 그대로 차단된다.', false),
(14248, 5276, 'URLSession으로 보내는 http://legacy.example.com/v1/items 요청', '예외 목록에 적힌 바로 그 호스트이고 평문 허용 키가 켜져 있어 http 요청이 나간다. 이렇게 도메인 단위로 최소한만 여는 것이 ATS 예외의 원칙이다.', true),
(14249, 5276, 'WKWebView로 여는 http://blog.example.com 페이지 요청', '웹뷰가 불러오는 콘텐츠도 ATS 적용 대상이다. 웹뷰 안쪽만 열어 주려면 NSAllowsArbitraryLoadsInWebContent가 따로 있어야 하는데 이 설정에는 없다.', false),
(14250, 5276, 'URLSession으로 보내는 http://cdn.example.com/images/a.png 요청', '예외 목록에 없는 도메인이라 기본 정책이 그대로 적용돼 평문이 차단된다. 도메인마다 따로 적어야 예외가 되며, 전체 허용 키로 한 번에 여는 것은 심사에서 사유를 요구받는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1714, 5277, 'NSCache,NSCache 클래스,엔에스캐시', '키와 값을 담되 메모리가 부족하면 시스템이 스스로 항목을 덜어 내고, 여러 스레드에서 동시에 접근해도 안전한 캐시 전용 클래스가 NSCache다. 메모리 경고 뒤 앱 코드 없이 항목이 줄어든 점과 잠금 없이 동시 접근한 점이 모두 이 클래스의 성질이다. Dictionary에 직접 담으면 비우는 시점을 앱이 관리해야 하고 동시 접근도 스스로 막아야 한다. URLCache와는 층이 다르다는 점도 함께 기억하라. URLCache는 서버가 보낸 HTTP 응답 바이트를 저장할 뿐이라 펼친 UIImage는 담지 않는다. 그래서 네트워크를 타지 않는데도 스크롤이 끊기며, 메모리 이미지 캐시와 URLCache 디스크 캐시를 겹쳐 쓰는 2단 구성이 흔하다.'),
       (1715, 5278, 'URLProtocol,NSURLProtocol,URL Protocol,URLProtocol 서브클래스', 'URLSession은 요청을 실제로 보내기 전에 구성의 protocolClasses에 등록된 URLProtocol 서브클래스에 먼저 canInit(with:)를 물어본다. 여기서 요청을 맡으면 startLoading()에서 원하는 상태 코드와 본문, 오류를 직접 돌려줄 수 있어 실제 서버 없이 200, 500, 타임아웃, 깨진 JSON을 모두 재현한다. 세션 구성에만 손대므로 APIClient 코드를 테스트용으로 바꾸지 않아도 되는 점이 핵심이다. URLSession을 감싼 프로토콜을 만들어 가짜 구현을 주입하는 방식과 구분하라. 그쪽은 앱 코드의 타입을 바꿔야 하고, 캐시 정책이나 리다이렉트 처리 같은 URLSession 자체의 동작은 검증하지 못한다.');
