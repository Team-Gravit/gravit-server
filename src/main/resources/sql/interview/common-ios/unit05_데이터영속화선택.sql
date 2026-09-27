-- Unit: 데이터 영속화 선택 (Unit ID: 106)
-- Chapter: iOS (Chapter ID: 9)
-- Topic: IOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-ios-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(526, 'IOS_COMMON', 106, 'HARD', true,
 '메모 앱에서 로그인 토큰, 다크 모드 설정, 관계가 있는 수천 건의 메모를 개발 편의상 모두 UserDefaults에 저장했다면 어떤 문제가 생기고, 각 데이터는 어디에 저장해야 하는지 설명해 주시겠어요?',
 '모두 UserDefaults에 넣으면 두 가지 문제가 생깁니다. 첫째, UserDefaults는 암호화되지 않은 plist라서 탈옥 기기나 백업 파일에서 그대로 읽을 수 있어 로그인 토큰이 평문으로 노출됩니다. 둘째, UserDefaults는 앱 실행 시 전체 내용이 메모리에 로드되므로 수천 건의 메모처럼 큰 데이터를 넣으면 실행 시 전체 로드와 매 저장 시 전체 직렬화가 발생해 느려지고, 기동 시간과 디스크 쓰기에 영향을 줍니다. 따라서 로그인 토큰 같은 민감 정보는 하드웨어 기반 암호화를 제공하는 Keychain에 저장하고, 다크 모드처럼 작고 단순한 설정값은 UserDefaults에 그대로 두는 것이 적합합니다. 관계가 있고 검색·정렬이 필요한 대량의 메모 목록은 쿼리 능력이 있는 Core Data나 SwiftData에 저장합니다.'),
(527, 'IOS_COMMON', 106, 'NORMAL', true,
 'Core Data와 SwiftData의 차이는 무엇이고, 어떤 경우에 SwiftData 대신 Core Data를 선택하시겠어요?',
 'SwiftData는 Core Data의 저장 계층을 그대로 쓰면서 Swift 매크로와 타입 안전한 API로 감싼 것입니다. 모델 정의는 Core Data가 .xcdatamodeld 에디터와 NSManagedObject를 쓰는 반면, SwiftData는 @Model 매크로가 붙은 Swift 클래스로 정의합니다. 조회 조건도 Core Data는 문자열 NSPredicate라 오타가 런타임에 발견되지만, SwiftData는 #Predicate 매크로로 컴파일 타임에 검증됩니다. UI 연동은 Core Data가 NSFetchedResultsController를, SwiftData는 SwiftUI의 @Query로 자동 갱신됩니다. 다만 SwiftData는 iOS 17 이상에서만 사용할 수 있고 비교적 새로워 버전에 따라 기능·안정성 차이가 있습니다. 그래서 iOS 16 이하를 지원해야 하거나, UIKit 중심 프로젝트이거나, 복잡한 마이그레이션·동시성 처리가 필요하면 Core Data가 여전히 안전한 선택입니다.'),
(528, 'IOS_COMMON', 106, 'NORMAL', true,
 '앱 샌드박스의 Documents와 Library/Caches 디렉터리는 어떤 차이가 있고, 각각 어떤 데이터를 저장해야 하나요?',
 '두 디렉터리는 백업 여부와 시스템의 자동 정리 여부가 다릅니다. Documents는 iCloud·iTunes 백업에 포함되고 시스템이 자동으로 삭제하지 않는 반면, Library/Caches는 백업에서 제외되고 저장 공간이 부족하면 시스템이 삭제할 수 있습니다. 그래서 재다운로드 가능한 이미지나 응답 캐시는 Caches에, 사용자가 만든 문서처럼 재생성 불가능한 데이터는 Documents에 둡니다. 재생성 가능한 데이터를 Documents에 두면 사용자의 iCloud 용량을 낭비하고 앱 심사에서 지적받을 수 있습니다. 참고로 tmp는 앱 미실행 시 삭제될 수 있어 처리 중 임시 파일에 쓰고, 앱이 만든 DB 파일처럼 사용자에게 보이지 않는 데이터는 Library/Application Support에 둡니다.'),
(529, 'IOS_COMMON', 106, 'EASY', true,
 'Keychain이 무엇이고, 저장된 항목이 어떻게 식별되고 접근이 제어되는지 설명해 주시겠어요?',
 'Keychain은 Security 프레임워크가 제공하는 시스템 수준의 암호화 저장소로, 기기의 Secure Enclave와 연계된 키로 보호되어 토큰·비밀번호·인증서 같은 민감 정보를 저장하는 데 씁니다. 각 항목은 kSecClass(비밀번호·인터넷 비밀번호·인증서·키 등)와 kSecAttrService·kSecAttrAccount 조합으로 식별합니다. 접근 제어는 kSecAttrAccessible로 항목에 접근 가능한 시점을 지정하며, 기본 권장값은 잠금 해제 상태에서만 접근하고 기기 이전 시 포함되지 않는 kSecAttrAccessibleWhenUnlockedThisDeviceOnly입니다. 같은 팀 ID의 앱끼리는 Keychain Access Group으로 항목을 공유할 수 있습니다. 또 Keychain 항목은 앱을 삭제해도 남아 있을 수 있어서, 첫 실행을 감지해 Keychain을 초기화하는 로직을 두기도 합니다.'),
(530, 'IOS_COMMON', 106, 'EASY', true,
 'Core Data는 데이터베이스인가요? Core Data가 무엇인지 주요 구성 요소와 함께 설명해 주세요.',
 'Core Data는 데이터베이스가 아니라 객체 그래프 관리 프레임워크입니다. SQLite는 Core Data의 기본 저장 방식일 뿐이고, 개발자는 SQL이 아니라 NSManagedObject라는 관리 객체를 다룹니다. 주요 구성 요소는 NSPersistentContainer 아래에 있는 세 가지입니다. NSManagedObjectModel은 .xcdatamodeld에서 엔티티·속성·관계를 정의하고, NSPersistentStoreCoordinator는 SQLite 파일 같은 저장소와의 연결을 담당합니다. NSManagedObjectContext는 작업 공간으로, 여기서 fetch·insert·delete를 한 뒤 save()로 반영합니다. 컨텍스트는 스레드에 묶여 있어서 viewContext는 메인 스레드 전용이고, 대량 삽입·갱신은 performBackgroundTask로 백그라운드 컨텍스트에서 수행한 뒤 병합합니다. 또한 관계 객체는 실제 접근 시점까지 로드하지 않는 지연 로딩(faulting)으로 메모리를 아낍니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 526
(2820, 526, 'UserDefaults는 암호화되지 않아 저장한 토큰이 평문으로 노출됨을 설명', 'ESSENTIAL', 1),
(2821, 526, 'UserDefaults에 큰 데이터를 넣으면 실행 시 전체 로드·매 저장 시 전체 직렬화 중 최소 1개로 느려짐을 설명', 'ESSENTIAL', 2),
(2822, 526, '로그인 토큰 같은 민감 정보는 Keychain에 저장해야 함을 언급', 'ESSENTIAL', 3),
(2823, 526, '관계가 있는 대량의 메모 목록은 Core Data나 SwiftData에 저장함을 언급', 'ESSENTIAL', 4),
(2824, 526, '다크 모드 같은 작고 단순한 설정값은 UserDefaults에 두는 것이 적합함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 527
(2825, 527, 'Core Data는 .xcdatamodeld 에디터로, SwiftData는 @Model 매크로가 붙은 Swift 클래스로 모델을 정의함을 설명', 'ESSENTIAL', 1),
(2826, 527, 'NSPredicate는 오타가 런타임에 발견되고 #Predicate는 컴파일 타임에 검증됨을 설명', 'ESSENTIAL', 2),
(2827, 527, 'SwiftData는 iOS 17 이상에서만 사용할 수 있음을 언급', 'ESSENTIAL', 3),
(2828, 527, '복잡한 마이그레이션 요구나 UIKit 중심 프로젝트에서는 Core Data가 안전한 선택임을 언급', 'ESSENTIAL', 4),
(2829, 527, 'SwiftData가 Core Data의 저장 계층을 그대로 사용함을 언급', 'SUPPLEMENTARY', 5),
(2830, 527, 'SwiftData는 SwiftUI의 @Query로 UI가 자동 갱신됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 528
(2831, 528, 'Documents는 iCloud 백업에 포함되고 Caches는 백업에서 제외됨을 설명', 'ESSENTIAL', 1),
(2832, 528, 'Caches는 저장 공간이 부족하면 시스템이 자동 삭제할 수 있음을 언급', 'ESSENTIAL', 2),
(2833, 528, '재다운로드 가능한 캐시는 Caches에, 재생성 불가능한 사용자 문서는 Documents에 둠을 설명', 'ESSENTIAL', 3),
(2834, 528, '재생성 가능한 데이터를 Documents에 두면 사용자의 iCloud 용량을 낭비함을 언급', 'SUPPLEMENTARY', 4),
(2835, 528, 'tmp는 앱 미실행 시 삭제될 수 있어 처리 중 임시 파일에 쓴다는 점을 언급', 'SUPPLEMENTARY', 5),
(2836, 528, '앱이 만든 DB 파일은 Library/Application Support에 둠을 언급', 'SUPPLEMENTARY', 6),

-- 질문 529
(2837, 529, 'Keychain이 시스템 수준의 암호화 저장소임을 설명', 'ESSENTIAL', 1),
(2838, 529, 'kSecAttrService·kSecAttrAccount 조합으로 Keychain 항목을 식별함을 설명', 'ESSENTIAL', 2),
(2839, 529, 'kSecAttrAccessible로 항목에 접근 가능한 시점을 지정함을 언급', 'ESSENTIAL', 3),
(2840, 529, 'Keychain이 Secure Enclave와 연계된 키로 보호됨을 언급', 'SUPPLEMENTARY', 4),
(2841, 529, '같은 팀 ID의 앱끼리 Keychain Access Group으로 항목을 공유할 수 있음을 언급', 'SUPPLEMENTARY', 5),
(2842, 529, 'Keychain 항목은 앱을 삭제해도 남아 있을 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 530
(2843, 530, 'Core Data는 데이터베이스가 아니라 객체 그래프 관리 프레임워크임을 설명', 'ESSENTIAL', 1),
(2844, 530, 'SQLite는 Core Data의 기본 저장 방식일 뿐임을 언급', 'ESSENTIAL', 2),
(2845, 530, '데이터 모델 정의, 저장소와의 연결, 객체를 다루는 작업 공간 중 최소 2개를 Core Data 구성 요소의 역할로 제시', 'ESSENTIAL', 3),
(2846, 530, 'viewContext는 메인 스레드 전용임을 언급', 'SUPPLEMENTARY', 4),
(2847, 530, '관계 객체를 실제 접근 시점까지 로드하지 않는 지연 로딩(faulting)을 언급', 'SUPPLEMENTARY', 5);
