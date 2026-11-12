-- Unit: 데이터 영속화 선택 (Unit ID: 106)
-- Chapter: iOS (Chapter ID: 9)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (532, 106, '저장소 선택 기준과 Core Data 폴팅'),
       (690, 106, '데이터 보호 등급과 경량 마이그레이션'),
       (848, 106, 'Caches 삭제와 컨텍스트 변경 병합');

-- =====================================================
-- Lesson 532: 저장소 선택 기준과 Core Data 폴팅
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3371, 532, '아래 iOS 저장소에 대한 설명으로 옳은 것은?', 'Security 프레임워크가 제공하는 시스템 수준의 암호화 저장소다. 항목은 kSecClass와 kSecAttrService·kSecAttrAccount 조합으로 식별하고, 접근 가능 시점은 kSecAttrAccessible로 지정한다. SecItemAdd·SecItemCopyMatching 같은 C 스타일 API를 쓰기 불편해 실무에서는 얇은 래퍼를 만들어 감싼다.', 'OBJECTIVE'),
       (3372, 532, '아래 앱 샌드박스 디렉터리 정책표를 바탕으로 옳지 않은 것은?', '| 디렉터리 | iCloud·iTunes 백업 | 시스템 자동 삭제 |
| --- | --- | --- |
| Documents | 포함 | 없음 |
| Library/Application Support | 포함 | 없음 |
| Library/Caches | 제외 | 저장 공간 부족 시 삭제 가능 |
| tmp | 제외 | 앱 미실행 시 삭제 가능 |', 'OBJECTIVE'),
       (3373, 532, '아래 코드가 주석으로 표시한 지점에서 크래시하는 원인으로 옳은 것은?', '```swift
// container: NSPersistentContainer, titleLabel: 메인 화면의 라벨
container.performBackgroundTask { context in
    let request: NSFetchRequest<Note> = Note.fetchRequest()
    request.fetchLimit = 50
    let notes = (try? context.fetch(request)) ?? []
    DispatchQueue.main.async {
        self.titleLabel.text = notes.first?.title   // 여기서 크래시
    }
}
```

크래시 로그: `__Multithreading_Violation_AllThatIsLeftToUsIsHonor__`', 'OBJECTIVE'),
       (3374, 532, '아래 회의록의 요구 사항을 모두 만족하는 저장 방식 선택으로 옳은 것은?', '신규 노트 기능 회의 결과

- 지원 최소 버전: iOS 15
- 화면 구현: 전부 UIKit이며 SwiftUI 도입 계획 없음
- 저장할 데이터: 노트와 첨부 파일의 1:N 관계, 수천 건 목록에서 조건 검색·정렬 필요
- 다음 분기에 엔티티 하나를 둘로 쪼개는 스키마 변경 예정', 'OBJECTIVE'),
       (3375, 532, '아래 증상이 나타난, 잘못 쓰인 iOS 저장소의 이름은?', '최근 본 상품 3,000건을 배열로 만들어 한 저장소에 통째로 넣었다. 그러자 앱 기동 시간이 0.4초에서 1.6초로 늘었고, 항목 하나만 바꿔도 매번 전체가 다시 디스크에 기록됐다. 탈옥한 테스트 기기에서 Library/Preferences 아래 번들 ID 이름의 .plist 파일을 열자 저장한 값이 그대로 읽혔다.', 'SUBJECTIVE'),
       (3376, 532, '아래 Core Data 실행 로그에서 드러난 동작을 가리키는 용어는?', '노트 5,000건을 한 번에 fetch했는데 메모리 사용량은 거의 늘지 않았다. 그런데 목록 셀에서 note.attachments.count를 처음 읽는 순간마다 아래 로그가 한 줄씩 더 찍히고 스크롤이 끊긴다. 같은 셀을 다시 읽을 때는 로그가 나오지 않는다.

```
CoreData: sql: SELECT 0, t0.Z_PK, t0.Z_OPT, t0.ZFILENAME FROM ZATTACHMENT t0 WHERE t0.ZNOTE = ?
CoreData: annotation: fetch using NSSQLiteStatement
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3371
(9163, 3371, '앱을 지우면 저장한 항목도 함께 지워져, 재설치한 사용자는 이전 값을 다시 읽을 수 없다.', '일반 앱 데이터 감각을 그대로 옮긴 오개념. 이 저장소의 항목은 앱을 삭제해도 남아 있을 수 있어, 재설치했는데 로그인 상태가 유지된 것처럼 보이는 일이 생긴다. 첫 실행을 감지해 항목을 지우는 로직을 두는 팀이 많은 이유다.', false),
(9164, 3371, '저장한 값 전체가 앱 실행 시 메모리에 캐시돼, 항목 수가 늘어도 읽기 비용이 거의 같다.', 'UserDefaults의 동작을 갖다 붙인 오개념. 실행 시 통째로 메모리에 올려두는 쪽은 plist 기반 저장소이고, 이 저장소는 요청할 때마다 시스템을 거쳐 복호화해 값을 돌려준다.', false),
(9165, 3371, '접근 시점을 잠금 해제 상태·이 기기 전용으로 지정한 항목은 다른 기기로 옮기는 백업에 포함되지 않는다.', '접근 시점 속성에 WhenUnlockedThisDeviceOnly를 주면 기기가 잠금 해제된 동안에만 읽히고, 백업을 통해 다른 기기로 넘어가지도 않는다. 기기를 벗어나면 안 되는 토큰의 기본 권장값이다.', true),
(9166, 3371, '속성에 조건을 걸어 항목을 정렬해 가져오는 쿼리를 지원해 수천 건 목록 저장에 적합하다.', 'Core Data의 쿼리 능력을 갖다 붙인 오개념. 이 저장소는 서비스·계정 같은 키 조합으로 항목 하나를 찾을 뿐 조건 검색이나 정렬을 제공하지 않으며, 대량 목록을 담는 자리도 아니다.', false),

-- 문제 3372
(9167, 3372, '다시 내려받을 수 있는 목록 응답 캐시를 Library/Caches에 두면 백업 용량을 늘리지 않는다.', '참인 진술. 표에서 Caches는 백업 제외이고 저장 공간이 부족하면 시스템이 지울 수 있으므로, 사라져도 다시 만들 수 있는 캐시를 두기에 알맞은 자리다.', false),
(9168, 3372, '사용자가 앱에서 직접 작성한 문서를 tmp에 저장하면 백업에 포함돼 기기를 바꿔도 그대로 복원된다.', '표에서 tmp는 백업 제외이며 앱이 실행 중이 아닐 때 시스템이 지울 수도 있다. 다시 만들 수 없는 사용자 문서는 백업에 포함되고 자동 삭제가 없는 Documents에 둬야 기기 이전 후에도 남는다.', true),
(9169, 3372, '앱이 만든 SQLite 파일은 사용자에게 보일 필요가 없어 Library/Application Support에 두는데, 이 위치도 백업에는 포함된다.', '참인 진술. Application Support는 백업 포함이고 자동 삭제도 없어, 사용자에게 드러낼 필요는 없지만 사라지면 안 되는 앱 생성 데이터에 맞는다.', false),
(9170, 3372, '이미지 변환 중 생기는 중간 파일을 tmp에 두면 앱이 실행 중이 아닐 때 시스템이 정리해 줄 수 있다.', '참인 진술. tmp는 앱 미실행 시 시스템이 삭제할 수 있으므로, 작업이 끝나면 없어져도 되는 임시 파일을 두고 정리 부담을 더는 자리로 쓴다.', false),

-- 문제 3373
(9171, 3373, 'try?로 fetch 실패가 감춰져 notes가 비었고, 첫 원소를 꺼내는 곳에서 nil 참조가 일어났다.', 'notes.first?.title은 옵셔널 체이닝이라 배열이 비어 있으면 nil이 대입될 뿐 크래시하지 않는다. 강제 언래핑과 혼동한 오개념이다.', false),
(9172, 3373, '백그라운드에서 만든 변경을 save()로 저장하지 않아, 컨텍스트가 사라지면서 객체도 함께 없어졌다.', '본문 코드는 fetch만 하고 아무 값도 바꾸지 않아 저장할 변경 자체가 없다. 저장 누락은 데이터가 남지 않는 문제이지 이 지점의 크래시 원인이 아니다.', false),
(9173, 3373, 'performBackgroundTask가 메인 큐를 점유해 UI 갱신이 밀렸고, 워치독이 앱을 종료했다.', 'performBackgroundTask는 별도의 백그라운드 큐에서 비동기로 실행돼 메인 큐를 막지 않는다. 메인 스레드를 오래 붙잡아 생기는 강제 종료와 혼동한 오개념이다.', false),
(9174, 3373, '백그라운드 컨텍스트가 가져온 관리 객체를 메인 큐에서 그대로 읽어, 컨텍스트에 묶인 큐 밖에서 접근했다.', '컨텍스트와 그 컨텍스트가 만든 관리 객체는 자신이 묶인 큐에서만 다뤄야 한다. 큐를 넘길 때는 objectID만 전달하고, 메인에서는 viewContext로 그 ID의 객체를 다시 가져와 읽어야 한다.', true),

-- 문제 3374
(9175, 3374, 'Core Data — 관계와 조건 검색을 지원하고, 매핑 모델을 쓰면 엔티티를 쪼개는 변경도 감당한다.', '네 요구를 모두 만족한다. 오래전 버전부터 지원해 iOS 15에 걸리지 않고, UIKit에서는 NSFetchedResultsController로 목록을 갱신하며, 속성 추가 수준을 넘는 구조 변경은 매핑 모델로 처리한다.', true),
(9176, 3374, 'SwiftData — @Model과 #Predicate로 조회 조건을 컴파일 타임에 검증해 문자열 오타를 줄일 수 있다.', '장점 설명 자체는 맞지만 SwiftData는 iOS 17 이상에서만 쓸 수 있어 최소 버전 iOS 15라는 요구에 걸린다. 기능 비교만 보고 지원 버전 조건을 놓친 선택이다.', false),
(9177, 3374, 'UserDefaults — 노트 배열을 Codable로 인코딩해 넣으면 저장소가 조건 검색과 정렬까지 처리해 준다.', 'Codable로 Data를 넣을 수는 있지만 쿼리 기능이 없어 매번 전체를 읽어 직접 걸러야 한다. 수천 건을 넣으면 기동 시 전체 로드와 값 변경 시 전체 직렬화 비용까지 붙는다.', false),
(9178, 3374, 'Documents의 JSON 파일 — 파일 보호 클래스를 지정하면 조건 검색과 정렬 성능까지 함께 보장된다.', 'FileProtectionType은 기기가 잠긴 동안 파일에 접근할 수 있는지를 정할 뿐 검색 성능과는 무관하다. JSON 스냅샷은 조건이 바뀔 때마다 파일 전체를 읽어 파싱해야 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1080, 3375, 'UserDefaults,유저디폴트,유저 디폴트,유저디폴츠,유저 디폴츠,NSUserDefaults,UserDefaults.standard', 'plist 키-값 저장소라 앱 실행 시 내용 전체가 메모리에 로드되고, 값 하나만 바꿔도 파일 전체가 다시 기록된다. 기동 지연과 잦은 전체 쓰기가 나타난 이유이며, 암호화가 없어 .plist를 열면 값이 평문으로 보인다. 그래서 설정값·플래그처럼 작고 단순한 값에만 맞는다. 토큰·비밀번호처럼 민감한 값은 하드웨어 기반 암호화가 붙는 Keychain에, 수천 건의 관계형 목록은 조건 검색·정렬이 되는 Core Data에 두는 것으로 구분한다.'),
       (1081, 3376, '폴팅,faulting,fault,폴트,폴트 처리,지연 로딩,지연로딩,lazy loading,레이지 로딩', 'Core Data는 관계나 속성을 실제로 접근하는 순간까지 값이 비어 있는 껍데기 객체로 두었다가, 접근하는 그때 저장소에서 값을 채운다. 5,000건을 가져와도 메모리가 거의 늘지 않고 첫 접근마다 SELECT가 한 번씩 나가며 이미 채워진 객체에서는 로그가 없는 것이 이 동작의 흔적이다. 목록에서 이런 추가 조회가 반복되면 relationshipKeyPathsForPrefetching으로 미리 가져와 완화한다. 접근 시점을 미루는 이 동작은, 메모리에 올려둔 값을 재사용하는 캐시나 fetch 결과를 통째로 들고 있는 일괄 로딩과 구분한다.');

-- =====================================================
-- Lesson 690: 데이터 보호 등급과 경량 마이그레이션
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4319, 690, '아래 네 값을 UserDefaults에 저장할 때, 실행 중 예외가 발생해 앱이 종료되는 키는?', '설정 화면에서 아래 네 값을 각각 `UserDefaults.standard.set(값, forKey: 키)`로 저장한다. 이 메서드는 `set(_ value: Any?, forKey defaultName: String)`로 선언돼 있어 네 호출 모두 빌드는 통과한다.

```swift
struct DisplaySettings: Codable {
    var isDarkMode: Bool
    var fontScale: Double
}
```

| 키 | 넘긴 값 | 값의 타입 |
| --- | --- | --- |
| recentKeywords | `["swift", "ios"]` | `[String]` |
| lastSyncedAt | `Date()` | `Date` |
| displaySettings | `DisplaySettings(isDarkMode: true, fontScale: 1.2)` | `DisplaySettings` |
| avatarData | 200KB JPEG 이미지의 바이트 | `Data` |', 'OBJECTIVE'),
       (4320, 690, '아래 코드에서 두 번째 저장 호출이 실패한 원인으로 옳은 것은?', '```swift
import Security

func saveRefreshToken(_ token: String) -> OSStatus {
    let item: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "com.example.auth",
        kSecAttrAccount as String: "refreshToken",
        kSecValueData as String: Data(token.utf8)
    ]
    return SecItemAdd(item as CFDictionary, nil)
}

print(saveRefreshToken("token-A"))   // 로그인 직후
print(saveRefreshToken("token-B"))   // 30분 뒤 토큰 갱신 직후
```

실행 결과 (0은 errSecSuccess)

```
0
-25299
```', 'OBJECTIVE'),
       (4321, 690, '아래 상황에서 새벽의 백그라운드 작업이 파일을 읽지 못한 원인으로 옳은 것은?', '암호가 설정된 실기기에서, 팟캐스트 앱이 구독 목록을 `Library/Application Support/subscriptions.json`에 아래처럼 저장한다.

```swift
try data.write(to: subscriptionsURL, options: [.atomic, .completeFileProtection])
```

사용자가 앱을 쓰는 낮에는 이 파일을 읽고 쓰는 데 문제가 없다. 그런데 기기를 잠가 둔 새벽 4시에 백그라운드 새로 고침이 시작돼 이 파일을 읽으려 하면 아래 오류가 난다. 아침에 잠금을 해제하고 앱을 열면 파일은 전날 내용 그대로 정상적으로 읽힌다.

```
[BGAppRefresh 04:00] subscriptions.json 읽기 실패
Error Domain=NSCocoaErrorDomain Code=257 (NSFileReadNoPermissionError)
```', 'OBJECTIVE'),
       (4322, 690, '아래 두 코드에 있는 같은 오타가 드러나는 시점으로 옳은 것은?', '`Note`에는 `isArchived` 속성만 있는데, 두 프로젝트에서 조회 조건을 쓰다가 똑같이 `isArchieved`로 잘못 적었다.

```swift
// A 프로젝트: Core Data
let request: NSFetchRequest<Note> = Note.fetchRequest()
request.predicate = NSPredicate(format: "isArchieved == NO")
let notesA = try context.fetch(request)

// B 프로젝트: SwiftData
let descriptor = FetchDescriptor<Note>(
    predicate: #Predicate { !$0.isArchieved }
)
let notesB = try modelContext.fetch(descriptor)
```', 'OBJECTIVE'),
       (4323, 690, '아래 배포 기록에서 v1.1 때 일어난 Core Data 동작을, v1.2에 필요했던 방식과 구분해 부르는 용어는?', '메모 앱은 Core Data 모델에 새 모델 버전을 추가하고 현재 버전으로 지정하는 방식으로 두 번 업데이트했다. `NSPersistentContainer`의 저장소 옵션은 두 번 모두 기본값 그대로다.

- **v1.1**: `Note` 엔티티에 선택(optional) 속성 `pinnedAt: Date?`를 추가했다. 모델 버전 외에는 아무 파일도 더하지 않았는데, 업데이트한 사용자의 노트 12,000건이 첫 실행에서 그대로 열렸고 `pinnedAt`은 모두 `nil`이었다.
- **v1.2**: `Note` 엔티티를 `Note`와 `NoteBody` 둘로 쪼개고 본문 텍스트를 `NoteBody`로 옮기게 했다. 같은 방식으로 내부 배포하자 기존 저장소가 `NSCocoaErrorDomain Code=134140` 오류로 열리지 않았고, 옛 모델과 새 모델의 엔티티·속성 대응을 직접 적은 매핑 모델 파일을 추가한 뒤에야 열렸다.', 'SUBJECTIVE'),
       (4324, 690, '아래 QA 결과표에서 저장소 X에 해당하는 iOS 저장소의 이름은?', '로그인 기능 QA에서 같은 테스트 토큰을 UserDefaults와 다른 저장소 X에 하나씩 넣고 아래 결과를 얻었다.

| 테스트 | UserDefaults | 저장소 X |
| --- | --- | --- |
| 앱을 삭제했다가 다시 설치한 뒤 값 읽기 | 값이 없음 | 삭제 전 토큰이 그대로 읽힘 |
| 탈옥 기기에서 앱 샌드박스 폴더의 파일을 모두 열람 | Library/Preferences의 .plist에서 토큰이 평문으로 보임 | 샌드박스 안 어느 파일에서도 토큰 문자열이 보이지 않음 |

QA 뒤 팀은 첫 실행 여부를 UserDefaults 플래그로 판단해, 첫 실행이면 저장소 X의 항목부터 지우도록 로그인 로직을 고쳤다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4319
(11691, 4319, 'recentKeywords', '문자열 배열은 plist가 그대로 담을 수 있는 타입이라 변환 없이 저장된다. 배열·딕셔너리도 Data로 인코딩해야만 들어간다고 착각한 오개념이다.', false),
(11692, 4319, 'lastSyncedAt', 'Date는 plist 호환 타입이라 그대로 저장되고 읽을 때도 Date로 돌아온다. 날짜를 문자열이나 숫자로 바꿔야만 저장된다고 착각한 오개념이다.', false),
(11693, 4319, 'displaySettings', 'Codable은 인코더에 넘길 수 있다는 약속일 뿐 저장할 때 자동으로 변환해 주지 않는다. 구조체는 plist 호환 타입이 아니라 set 호출 순간 예외가 나므로, JSONEncoder로 Data를 만든 뒤 저장해야 한다.', true),
(11694, 4319, 'avatarData', 'Data는 plist 호환 타입이라 200KB도 예외 없이 저장된다. UserDefaults에 명시된 크기 한도는 없고, 큰 값은 실행 시 전체를 메모리에 올리느라 기동이 느려지는 성능 문제로 나타난다.', false),

-- 문제 4320
(11695, 4320, '서비스·계정 조합이 같은 항목이 이미 있어, 새 항목을 추가하는 요청이 중복으로 거부됐다.', 'Keychain 항목은 kSecClass·kSecAttrService·kSecAttrAccount 조합으로 식별돼, 같은 조합으로 SecItemAdd를 다시 부르면 errSecDuplicateItem(-25299)이 돌아온다. 값을 바꾸려면 SecItemUpdate를 쓰거나 SecItemDelete로 지운 뒤 추가한다.', true),
(11696, 4320, '이 저장소는 앱 하나에 항목을 하나만 둘 수 있어, 두 번째 항목을 넣을 자리가 없었다.', '항목 개수를 앱 단위로 제한한다고 본 오개념. 한 앱도 서비스·계정 값을 달리해 여러 항목을 둘 수 있고, 거부 기준은 개수가 아니라 같은 식별 조합의 항목이 이미 있느냐다.', false),
(11697, 4320, '첫 호출의 저장이 끝나기 전에 두 번째 호출이 들어와, 같은 항목에 동시에 쓰다 충돌했다.', 'SecItemAdd는 결과를 돌려준 뒤에야 다음 줄로 넘어가는 동기 호출이다. 본문의 두 호출은 30분 간격으로 차례로 실행돼 겹칠 수 없으니, 동시 접근 충돌과 혼동한 것이다.', false),
(11698, 4320, '토큰을 Data로 바꿔 넣어, 문자열이 아닌 값이 저장 전 형식 검사에서 거부됐다.', 'kSecValueData에는 원래 Data를 넣는다. 첫 호출도 같은 방식으로 Data를 넣어 0(errSecSuccess)을 받았으므로 값의 형식은 두 번째 실패의 원인이 될 수 없다.', false),

-- 문제 4321
(11699, 4321, '백그라운드로 실행되는 작업은 앱 샌드박스 밖으로 취급돼, 보호 옵션과 상관없이 앱 파일에 접근할 수 없다.', '백그라운드로 깨어난 앱도 자기 샌드박스 안에서 실행돼 파일을 읽을 수 있다. 실행 상태를 원인으로 본 오개념으로, 같은 작업도 잠금 중 접근을 허용하는 보호 등급이면 파일을 읽는다.', false),
(11700, 4321, 'Application Support는 저장 공간이 부족하면 시스템이 비울 수 있는 곳이라, 새벽에 파일이 정리돼 읽을 대상이 없었다.', '공간이 부족할 때 시스템이 비울 수 있는 곳은 Library/Caches이고 Application Support에는 자동 삭제가 없다. 오류도 파일 없음이 아니라 읽기 권한 없음이며, 아침에 전날 내용이 그대로 읽혔다.', false),
(11701, 4321, '백업에 포함되는 디렉터리라, 새벽에 iCloud 백업이 도는 동안 백업 과정이 파일을 붙잡아 읽기가 거부됐다.', '백업 포함 여부는 용량과 복원 범위를 정할 뿐, 백업이 앱의 파일 읽기를 막지는 않는다. 백업 정책과 기기 잠금에 따른 파일 접근 권한을 혼동한 오개념이다.', false),
(11702, 4321, '쓰기 옵션으로 지정한 보호 등급이, 기기가 잠기면 파일을 복호화할 키를 쓸 수 없게 하는 수준이었다.', '.completeFileProtection은 FileProtectionType.complete에 해당해 기기가 잠기면 파일 키를 쓸 수 없어 읽기 권한 오류가 난다. 잠금 중 백그라운드에서 읽어야 하면 재부팅 후 첫 잠금 해제 뒤로는 계속 열리는 .completeUntilFirstUserAuthentication을 쓴다.', true),

-- 문제 4322
(11703, 4322, 'A와 B 모두 빌드 단계에서 컴파일 오류로 드러나, 앱을 실행해 볼 수조차 없다.', 'NSPredicate(format:)의 조건은 문자열이라 컴파일러가 그 안의 속성 이름을 검사하지 않는다. A도 빌드에서 막힌다고 본 것은 문자열 조건과 매크로 조건을 같게 본 오개념이다.', false),
(11704, 4322, 'A는 빌드를 통과한 뒤 fetch를 실행하는 순간 예외로 드러나고, B는 빌드 단계에서 컴파일 오류로 드러난다.', 'A의 조건은 문자열이라 빌드는 통과하고, fetch 때 엔티티에 없는 키 경로를 만나 예외가 난다. B의 #Predicate는 매크로가 $0.isArchieved를 Swift 코드로 검사해 Note에 없는 멤버라며 컴파일 오류를 낸다.', true),
(11705, 4322, 'A는 빌드 단계에서 컴파일 오류로 드러나고, B는 빌드를 통과한 뒤 fetch를 실행하는 순간 예외로 드러난다.', '두 방식을 거꾸로 짝지은 오개념. 조건을 컴파일 타임에 검증하는 쪽은 #Predicate 매크로이고, 문자열로 적는 NSPredicate는 실행해 봐야 오타가 드러난다.', false),
(11706, 4322, 'A와 B 모두 빌드와 실행이 오류 없이 끝나고, 조건에 맞는 노트가 없어 빈 배열이 돌아온다.', '틀린 속성 이름이 조용히 아무것도 걸러내지 못할 뿐이라고 본 오개념. 문자열 조건은 fetch 때 없는 키 경로로 예외가 나고, #Predicate는 애초에 빌드가 되지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1396, 4323, '경량 마이그레이션,경량마이그레이션,라이트웨이트 마이그레이션,라이트웨이트마이그레이션,lightweight migration,lightweightmigration,lightweight 마이그레이션,경량 migration,자동 경량 마이그레이션,automatic lightweight migration,추론 마이그레이션,inferred migration', '속성 추가처럼 옛 모델과 새 모델의 차이를 Core Data가 스스로 추론할 수 있는 변경은, 저장소를 열 때 매핑 모델 없이 자동으로 새 스키마에 맞춰진다. 이것이 경량 마이그레이션이며, v1.1의 선택 속성 추가가 여기에 해당해 기존 노트 12,000건이 그대로 열리고 새 속성만 nil로 채워졌다. 반면 v1.2처럼 엔티티를 쪼개고 데이터를 다른 엔티티로 옮기는 구조 변경은 추론할 수 없어 매핑 모델을 찾지 못했다는 오류(Code=134140)가 나고, 개발자가 매핑 모델(필요하면 NSEntityMigrationPolicy를 쓴 사용자 정의 마이그레이션 정책까지)을 직접 만들어 주는 방식이 필요하다. 새 모델 버전만 추가하면 어떤 변경이든 자동으로 처리된다고 보거나, 속성 하나를 더하는 데도 매핑 모델이 필요하다고 보는 오해와 구분한다.'),
       (1397, 4324, 'Keychain,키체인,키 체인,iOS Keychain,iOS 키체인,Keychain Services,키체인 서비스', '재설치 뒤에도 값이 남고 앱 샌드박스 파일 어디에도 평문이 없다는 두 결과가 Keychain을 가리킨다. Keychain 항목은 앱 폴더가 아니라 시스템이 관리하는 암호화 저장소에 들어가므로, 앱을 지워도 남아 재설치한 사용자가 로그인된 채로 시작하는 일이 생길 수 있다. 그래서 앱과 함께 지워지는 UserDefaults로 첫 실행을 판별해 Keychain 항목을 먼저 정리하는 로직을 둔다. 반대로 UserDefaults(plist)·Documents 같은 파일·Core Data 저장소는 모두 앱 샌드박스 안의 파일이라 앱 삭제와 함께 사라지고, 별도로 암호화하지 않으면 탈옥 기기에서 내용이 드러난다는 점에서 구분한다.');

-- =====================================================
-- Lesson 848: Caches 삭제와 컨텍스트 변경 병합
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5267, 848, '아래에서 설명하는 iOS 데이터 영속화 프레임워크에 대한 설명으로 옳은 것은?', 'Core Data의 저장 계층을 그대로 쓰면서, 모델을 Swift 매크로로 선언하게 만든 프레임워크다. 엔티티는 매크로를 붙인 Swift 클래스로 정의하고, 관계에는 삭제 규칙까지 코드에 함께 적는다.

```swift
@Model
final class Note {
    var title: String
    var updatedAt: Date
    @Relationship(deleteRule: .cascade) var attachments: [Attachment] = []

    init(title: String, updatedAt: Date = .now) {
        self.title = title
        self.updatedAt = updatedAt
    }
}
```', 'OBJECTIVE'),
       (5268, 848, '아래 버그 리포트에서 스케치 파일이 사라진 원인으로 옳은 것은?', '드로잉 앱은 사용자가 그린 스케치를 기기 안 아래 경로에 PNG로 저장한다. 서버에 올리는 기능은 아직 없어서 파일이 없어지면 다시 만들 수 없다.

```
Library/Caches/sketches/<uuid>.png
```

접수된 리포트

- 저장한 스케치는 몇 주 동안 목록에서 문제없이 열렸다.
- "저장 공간이 부족합니다" 알림을 본 다음 날 앱을 열자, 목록 썸네일이 모두 물음표로 바뀌고 파일을 찾을 수 없다고 나온다.
- 앱을 지운 적도, 기기를 바꾸거나 백업에서 복원한 적도 없다.
- 저장 공간이 넉넉한 사내 테스트 기기에서는 같은 빌드로 몇 주를 써도 재현되지 않는다.', 'OBJECTIVE'),
       (5269, 848, '아래 코드로 저장한 노트 5,000건이 목록에 바로 보이지 않는 원인으로 옳은 것은?', '```swift
// container: NSPersistentContainer — 저장소 옵션은 모두 기본값
container.performBackgroundTask { context in
    for row in rows {                      // rows: 서버에서 받은 5,000건
        let note = Note(context: context)
        note.title = row.title
    }
    try? context.save()
}

// 목록 화면은 메인 컨텍스트로 다시 읽는다
let notes = try container.viewContext.fetch(Note.fetchRequest())
```

관찰된 동작

- 저장이 끝난 뒤 목록 화면을 다시 그려도 새 노트가 한 건도 보이지 않는다.
- 저장 직후 저장소 파일을 sqlite3로 열어 보면 5,000행이 이미 들어 있다.
- 앱을 껐다 켜면 5,000건이 모두 목록에 나온다.', 'OBJECTIVE'),
       (5270, 848, '아래 위젯 익스텐션이 값을 읽지 못한 원인으로 옳은 것은?', '```swift
// 앱 타깃: 최근 검색어 저장
UserDefaults.standard.set(["swift", "ios"], forKey: "recentKeywords")

// 위젯 익스텐션 타깃: 같은 키로 읽기
let keywords = UserDefaults.standard.stringArray(forKey: "recentKeywords")
print(keywords as Any)      // nil
```

확인한 사실

- 위젯은 앱과 같은 프로젝트의 타깃이고, 앱 번들 안에 함께 담겨 배포된다.
- 앱 타깃에서 같은 두 줄을 실행하면 ["swift", "ios"]가 그대로 나온다.
- 기기에서 앱 샌드박스의 Library/Preferences를 열어 보면 앱 번들 ID 이름의 .plist에 이 키가 들어 있다.', 'OBJECTIVE'),
       (5271, 848, '아래 저장소 파일을 만들어 낸 iOS 프레임워크의 이름은?', '팀은 SQL을 한 줄도 쓰지 않았다. Xcode의 .xcdatamodeld 에디터에서 엔티티 Note와 Attachment, 그리고 둘 사이의 1:N 관계를 만들고 클래스 파일을 생성했을 뿐이다. 앱을 한 번 실행한 뒤 시뮬레이터의 Application Support 폴더에 생긴 .sqlite 파일을 열어 보니 아래와 같았다.

```
$ sqlite3 Model.sqlite ''.tables''
ZATTACHMENT  ZNOTE  Z_METADATA  Z_MODELCACHE  Z_PRIMARYKEY

$ sqlite3 Model.sqlite ''PRAGMA table_info(ZNOTE);''
0|Z_PK|INTEGER|0||1
1|Z_ENT|INTEGER|0||0
2|Z_OPT|INTEGER|0||0
3|ZTITLE|VARCHAR|0||0
4|ZUPDATEDAT|TIMESTAMP|0||0
```', 'SUBJECTIVE'),
       (5272, 848, '아래 상황에서 두 앱의 entitlements에 같은 값으로 추가해야 하는 설정의 이름은?', '한 회사가 메인 앱과 위성 앱을 따로 배포한다. 두 앱은 같은 팀 ID로 서명돼 있고, 한 번 로그인하면 둘 다 로그인 상태가 되도록 만들려 한다.

- 메인 앱은 로그인 직후 SecItemAdd로 리프레시 토큰을 저장한다. 같은 앱에서 SecItemCopyMatching으로 읽으면 0(errSecSuccess)이 돌아온다.
- 두 앱을 같은 기기에 설치하고 기기를 잠금 해제한 상태에서, 위성 앱이 같은 서비스·계정 값으로 SecItemCopyMatching을 부르면 -25300(errSecItemNotFound)이 돌아온다.
- 두 앱의 entitlements 파일에 같은 항목을 추가하고 값으로 "<팀ID>.com.example.shared"를 적어 다시 빌드하자, 위성 앱에서도 같은 토큰이 0과 함께 읽혔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5267
(14219, 5267, '모델을 매크로로 선언하는 만큼 저장 형식도 달라져, Core Data로 만들어 둔 기존 저장소 파일은 이어받을 수 없다.', '선언 방식이 바뀌면 저장 형식도 바뀐다고 본 오개념. 모델을 적는 방법만 매크로로 달라졌을 뿐 아래에 깔린 저장 계층은 Core Data와 같아, 스키마만 맞으면 같은 저장소를 이어서 쓸 수 있다.', false),
(14220, 5267, 'SwiftUI 화면에서 목록을 `@Query`로 선언해 두면, 다른 화면에서 저장한 변경이 갱신 코드를 따로 두지 않아도 목록에 반영된다.', 'SwiftUI와 결합했을 때 가장 강한 이유가 여기 있다. `@Query`가 모델 컨텍스트의 변경을 구독해 뷰를 다시 그리므로, Core Data에서 NSFetchedResultsController로 하던 목록 갱신을 선언 한 줄이 대신한다.', true),
(14221, 5267, '동작에 필요한 런타임 버전 조건이 없어, 최소 지원 버전이 iOS 16인 앱에도 코드를 그대로 넣을 수 있다.', 'iOS 17 이상에서만 동작해 iOS 16 이하를 지원해야 하는 앱에서는 선택지가 아니다. 문법이 Swift 표준 기능처럼 보인다고 버전 조건까지 없다고 본 오개념으로, 채택 여부를 가르는 첫 관문이 바로 최소 지원 버전이다.', false),
(14222, 5267, '마이그레이션과 동시성 처리가 Core Data보다 세밀해, 요구가 복잡한 기존 앱일수록 먼저 옮기는 편이 낫다.', '초기 버전에서는 복잡한 마이그레이션·동시성 제어가 Core Data만큼 세밀하지 않다는 보고가 있다. 새 API가 항상 더 완성도 높다고 본 오개념이며, 요구가 복잡하면 Core Data가 여전히 안전한 선택이다.', false),

-- 문제 5268
(14223, 5268, '백업에서 빠지는 위치라, 마지막 백업을 복원하는 과정에서 스케치 파일만 빠지고 목록 정보만 남았다.', '이 위치가 백업에 포함되지 않는 건 맞지만, 리포트의 사용자는 기기를 바꾸거나 백업에서 복원한 적이 없다. 백업 정책과 시스템이 저장 공간을 되찾는 동작을 섞어 본 오개념이다.', false),
(14224, 5268, '앱을 종료할 때마다 시스템이 이 디렉터리를 tmp와 함께 비우므로, 앱을 껐다 켠 사용자에게서 파일이 사라졌다.', '앱 종료가 삭제를 부르지는 않는다. 종료마다 비운다면 저장 공간이 넉넉한 테스트 기기에서도 진작 사라졌어야 한다. tmp 역시 앱이 실행 중이 아닐 때 지워질 수 있을 뿐 종료마다 비워지지 않는다.', false),
(14225, 5268, '파일 보호 등급 기본값 탓에 기기가 잠긴 동안 쓰기가 막혀, 스케치가 처음부터 디스크에 기록되지 않았다.', '몇 주 동안 목록에서 잘 열렸으니 파일은 분명히 기록돼 있었다. 보호 등급 문제는 잠금 상태에서의 읽기·쓰기 권한 오류로 드러나지, 잘 쓰이던 파일이 뒤늦게 없어지는 증상으로 나타나지 않는다.', false),
(14226, 5268, '저장 공간이 부족하면 시스템이 지울 수 있는 디렉터리에, 다시 만들 수 없는 사용자 생성 파일을 뒀다.', 'Library/Caches는 공간이 모자랄 때 시스템이 회수할 수 있는 자리라 다시 내려받거나 만들 수 있는 데이터에 맞는다. 사용자가 그린 원본처럼 되살릴 수 없는 파일은 자동 삭제가 없고 백업에도 포함되는 Documents에 둬야 한다.', true),

-- 문제 5269
(14227, 5269, '백그라운드 컨텍스트의 저장은 저장소까지 반영되지만, 이미 떠 있는 메인 컨텍스트에는 그 변경이 저절로 합쳐지지 않는다.', '컨텍스트는 각자의 작업 공간이라 다른 컨텍스트가 저장한 내용을 알아서 가져오지 않는다. viewContext의 automaticallyMergesChangesFromParent를 켜거나 저장 알림을 받아 병합해야 한다. 앱을 다시 켜면 새 컨텍스트가 저장소에서 읽어 오므로 그때는 보인다.', true),
(14228, 5269, 'try?가 저장 실패를 감춰 디스크에는 한 건도 기록되지 않았고, 다시 켰을 때 보이는 목록은 메모리에 남아 있던 값이다.', '저장 직후 저장소 파일에 이미 5,000행이 있었으니 저장 자체는 성공했다. 또 메모리에 있던 값이 앱을 껐다 켠 뒤까지 살아남을 수도 없다. try?가 삼킨 오류를 먼저 의심한 오개념이다.', false),
(14229, 5269, '백그라운드에서 만든 관리 객체는 작업이 끝나면 폐기돼, 실제 기록은 앱이 종료될 때 한꺼번에 일어난다.', '저장은 save()가 끝나는 그 시점에 저장소로 내려간다. 쓰기를 종료 시점에 몰아서 한다고 본 오개념이며, 저장 직후 파일에서 5,000행이 확인된 것과도 맞지 않는다.', false),
(14230, 5269, '메인 컨텍스트가 가져온 객체가 폴트 상태라 제목이 비어 있어, 목록에 빈 줄만 그려졌다.', '폴트는 값이 필요한 순간 저장소에서 채워지므로 제목을 읽으면 값이 나온다. 게다가 목록에는 빈 줄조차 없었으니 값이 비는 문제가 아니라 행 자체가 오지 않은 상황이다.', false),

-- 문제 5270
(14231, 5270, '저장한 뒤 synchronize()를 부르지 않아 값이 아직 메모리에만 있고 파일에는 기록되지 않았다.', '지금의 UserDefaults는 적당한 시점에 알아서 파일에 기록해 synchronize()를 부를 필요가 없다. 게다가 확인한 .plist에는 값이 이미 들어 있었으니 기록은 끝난 상태다.', false),
(14232, 5270, '익스텐션은 샌드박스 밖에서 실행돼, 앱이 만든 저장 파일은 어떤 설정으로도 읽을 수 없다.', '익스텐션도 자기 샌드박스 안에서 실행되고, 공유 설정을 갖추면 앱과 같은 저장 영역을 읽을 수 있다. 접근이 원천 차단된다고 본 오개념이다.', false),
(14233, 5270, '익스텐션의 standard는 앱과 다른 번들 ID의 Preferences를 열기 때문에, 같은 키를 써도 서로의 값이 보이지 않는다.', 'standard는 지금 실행 중인 번들의 .plist를 연다. 앱과 익스텐션은 번들 ID가 달라 각자 자기 영역만 본다. 값을 나누려면 App Group을 켜고 양쪽에서 UserDefaults(suiteName:)로 같은 영역을 열어야 한다.', true),
(14234, 5270, '문자열 배열은 plist 호환 타입이 아니라 저장될 때 Data로 바뀌므로, stringArray로 읽으면 언제나 nil이 돌아온다.', '문자열 배열은 plist가 그대로 담는 타입이라 변환 없이 저장되고 stringArray로도 읽힌다. 앱 타깃에서 같은 코드가 값을 돌려준 것이 그 증거다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1712, 5271, 'Core Data,코어 데이터,코어데이터,CoreData,core data,coredata,코어데이타', '만든 것은 엔티티와 관계뿐인데 Z 접두가 붙은 테이블·컬럼과 Z_PRIMARYKEY·Z_METADATA 같은 관리용 테이블까지 생긴 것은, 개발자가 SQL 대신 관리 객체(NSManagedObject)를 다루도록 프레임워크가 SQLite 스키마를 대신 만들어 줬다는 뜻이다. Z_PK는 그 과정에서 붙는 내부 기본키다. 그래서 이것은 데이터베이스 자체가 아니라 객체 그래프를 관리하는 프레임워크이고, SQLite는 기본 저장 방식일 뿐이라고 말한다. 같은 저장 계층을 쓰는 SwiftData는 모델을 .xcdatamodeld 에디터가 아니라 @Model 매크로로 선언한다는 점에서, SQLite 래퍼 라이브러리는 개발자가 SQL이나 쿼리 빌더를 직접 쓴다는 점에서 구분한다.'),
       (1713, 5272, 'Keychain Access Group,키체인 액세스 그룹,키체인 액세스그룹,키체인 접근 그룹,키체인 그룹,keychain-access-groups,keychain access group,keychainaccessgroup,액세스 그룹,access group,kSecAttrAccessGroup', '-25300은 값이 없다는 뜻이 아니라 요청한 앱이 볼 수 있는 범위 안에 그 항목이 없다는 뜻이다. Keychain 항목은 기본적으로 그것을 만든 앱에만 보이므로, 같은 팀 ID로 서명된 앱끼리 나눠 쓰려면 두 앱의 entitlements에 같은 접근 그룹 값을 적어야 한다. 그래야 시스템이 두 앱을 한 그룹으로 보고 같은 항목을 돌려준다. 항목을 찾는 키인 kSecAttrService·kSecAttrAccount는 그룹 안에서 어떤 항목인지를 가리킬 뿐 공유 범위를 넓히지 못하고, 항목을 읽을 수 있는 시점을 정하는 kSecAttrAccessible과도 역할이 다르다. 익스텐션이나 형제 앱과 UserDefaults·파일 컨테이너를 나눌 때 쓰는 App Group은 이름이 비슷하지만 별개의 설정이다.');
