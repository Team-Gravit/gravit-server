-- Unit: 샌드박스와 앱 간 공유 (Unit ID: 108)
-- Chapter: iOS (Chapter ID: 9)
-- Topic: IOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-ios-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(536, 'IOS_COMMON', 108, 'HARD', true,
 '외부 인증 페이지에서 로그인한 뒤 인증 코드를 앱으로 돌려받는 콜백을 구현해야 합니다. 이 콜백을 URL Scheme으로 받으면 어떤 위험이 있고, 대신 어떤 방식을 선택하며, 그 방식이 안전한 근거와 도입 시 주의할 점은 무엇인가요?',
 'URL Scheme은 전역 등록이 아니어서 누구나 같은 스킴을 선언할 수 있고, 어떤 앱이 열릴지 보장되지 않습니다. 그래서 악성 앱이 은행 앱 스킴을 가로채 로그인 콜백을 탈취하는 사례가 보고된 바 있고, 토큰이나 인증 코드 같은 민감한 값은 URL Scheme으로 전달하면 안 됩니다. OAuth 콜백처럼 보안이 중요한 경우에는 Universal Link나 ASWebAuthenticationSession을 사용합니다. Universal Link가 안전한 이유는 도메인 소유자가 서버의 .well-known 경로에 올린 AASA(apple-app-site-association) 파일과 앱의 Team ID·Bundle ID를 Apple이 교차 검증해 앱과 도메인의 관계를 증명하기 때문입니다. 도입 시에는 AASA 파일이 HTTPS로 제공되지 않거나, 리다이렉트되거나, JSON 형식에 오류가 있거나, Team ID·Bundle ID가 일치하지 않으면 링크를 탭해도 Safari로만 열린다는 점을 확인해야 합니다. 또 AASA는 Apple CDN이 캐시하므로 배포 후 갱신이 반영되기까지 시간이 걸릴 수 있고, Safari에서 같은 도메인 내부로 이동할 때는 의도적으로 앱을 열지 않는다는 점도 주의해야 합니다.'),
(537, 'IOS_COMMON', 108, 'NORMAL', true,
 'URL Scheme과 Universal Link는 설정 방법과 앱이 설치되지 않았을 때의 동작에서 어떤 차이가 있나요?',
 'URL Scheme은 myapp:// 같은 앱 고유 스킴을 Info.plist(CFBundleURLTypes)에 등록해 설정하며, 다른 앱이나 Safari에서 이 URL을 열 때 시스템이 해당 앱을 실행하고 URL을 전달합니다. 반면 Universal Link는 https://example.com/order/123 같은 일반 웹 URL을 쓰며, 도메인 소유자가 서버에 AASA 파일을 올려 앱과 도메인의 관계를 증명해야 하고, 앱 쪽에서도 Signing & Capabilities의 Associated Domains에 applinks:example.com을 추가해 Associated Domains entitlement를 설정해야 합니다. 앱이 설치되지 않았을 때 URL Scheme은 아무 일도 일어나지 않아 스토어 이동 같은 대체 흐름을 만들기 어렵습니다. Universal Link는 앱이 없거나 등록된 경로와 일치하지 않으면 Safari에서 웹 페이지를 표시하므로 자연스럽게 대체됩니다. 두 방식은 경쟁이 아니라 보완 관계라서, 실무에서는 Universal Link를 기본으로 하되 앱 내부·QR 코드·푸시 알림처럼 앱 설치가 전제된 경로에서는 URL Scheme을 함께 지원합니다.'),
(538, 'IOS_COMMON', 108, 'NORMAL', true,
 '같은 팀의 앱 사이에서 데이터를 공유할 때 App Group과 Keychain 공유는 각각 어떤 데이터에 쓰이고, 어떤 공통점과 차이가 있나요?',
 'App Group은 공유 컨테이너 디렉터리의 파일, UserDefaults(suiteName:), 공유 컨테이너에 둔 Core Data/SQLite 저장소 같은 데이터를 같은 팀의 앱과 익스텐션이 함께 읽고 쓰게 해 줍니다. Keychain 공유는 토큰이나 비밀번호 같은 민감 데이터를 같은 팀의 앱 사이에서 공유할 때 씁니다. 그래서 내 앱과 익스텐션이 데이터를 함께 써야 하면 App Group을 쓰고, 민감 정보라면 Keychain Access Group을 함께 씁니다. 공통점은 두 수단 모두 같은 팀의 앱에서만 사용할 수 있고 위조 가능성이 없다는 점이며, App Group은 서명 기반입니다. 사전 조건은 다른데, App Group은 동일 Team ID와 group.으로 시작하는 식별자 entitlement가 필요하고, Keychain 공유는 Keychain Access Group entitlement가 필요합니다.'),
(539, 'IOS_COMMON', 108, 'EASY', true,
 'iOS의 샌드박스란 무엇이며, 앱의 데이터 컨테이너 절대 경로를 저장해 두고 재사용하면 안 되는 이유는 무엇인가요?',
 '샌드박스는 iOS의 모든 앱이 실행되는 자기만의 격리된 저장 공간으로, 앱은 다른 앱의 파일이나 메모리에 직접 접근할 수 없습니다. 앱 번들은 코드 서명으로 무결성이 보장되어 런타임에 수정할 수 없고, 데이터는 Documents, Library, tmp 등으로 구성된 앱별 데이터 컨테이너에 저장됩니다. 샌드박스는 권한 모델의 기반이기도 해서, 사진이나 연락처처럼 샌드박스 밖의 자원은 반드시 시스템 API와 사용자 권한을 거쳐야 합니다. 데이터 컨테이너 경로에는 UUID가 포함되는데, 이 UUID는 재설치나 업데이트 시 바뀔 수 있습니다. 그래서 절대 경로를 저장해 두면 안 되고, 항상 FileManager.default.urls(for:in:)로 매번 조회해야 합니다.'),
(540, 'IOS_COMMON', 108, 'EASY', true,
 '메인 앱에서 UserDefaults.standard에 저장한 값이 위젯에서 보이지 않는 이유는 무엇이며, App Group으로 이를 어떻게 해결하나요?',
 '위젯, 공유 익스텐션, 워치 앱은 메인 앱과 별도 프로세스이자 별도 샌드박스에서 동작하기 때문에 메인 앱의 Documents나 UserDefaults.standard를 볼 수 없습니다. App Group은 이들이 함께 접근할 수 있는 공유 컨테이너를 제공합니다. Xcode의 Signing & Capabilities에서 App Groups를 추가하고 group.com.example.myapp 형태의 식별자를 메인 앱과 위젯 등 모든 타깃에 동일하게 지정한 뒤, UserDefaults(suiteName:)에 그 식별자를 넣어 값을 저장하고 읽으면 양쪽이 같은 값을 봅니다. 파일은 containerURL(forSecurityApplicationGroupIdentifier:)로 얻은 공유 컨테이너 경로에 둡니다. 다만 두 프로세스가 공유 컨테이너의 파일을 동시에 쓰면 손상될 수 있으므로 .atomic 옵션으로 쓰거나 NSFileCoordinator로 접근을 조정해야 합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 536
(2874, 536, '누구나 같은 스킴을 등록할 수 있어 악성 앱이 콜백을 가로챌 수 있음을 설명', 'ESSENTIAL', 1),
(2875, 536, 'OAuth 콜백에는 Universal Link 또는 ASWebAuthenticationSession을 사용한다고 제시', 'ESSENTIAL', 2),
(2876, 536, 'Universal Link는 AASA 파일과 앱의 Team ID·Bundle ID를 Apple이 교차 검증함을 언급', 'ESSENTIAL', 3),
(2877, 536, 'AASA의 HTTPS 아님·리다이렉트·JSON 형식 오류·ID 불일치 중 최소 1개를 실패 원인으로 제시', 'ESSENTIAL', 4),
(2878, 536, 'AASA는 Apple CDN이 캐시하므로 갱신 반영에 시간이 걸릴 수 있음을 언급', 'SUPPLEMENTARY', 5),
(2879, 536, 'Safari에서 같은 도메인 내부 이동은 앱을 열지 않음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 537
(2880, 537, 'URL Scheme은 Info.plist에 앱 고유 스킴을 등록해 설정함을 언급', 'ESSENTIAL', 1),
(2881, 537, 'Universal Link는 도메인 서버에 AASA 파일을 올려야 함을 언급', 'ESSENTIAL', 2),
(2882, 537, '앱이 없을 때 URL Scheme은 아무 일도 일어나지 않아 대체 흐름을 만들기 어려움을 언급', 'ESSENTIAL', 3),
(2883, 537, '앱이 없을 때 Universal Link는 Safari에서 웹 페이지로 열림을 언급', 'ESSENTIAL', 4),
(2884, 537, 'Universal Link는 앱에 Associated Domains entitlement를 추가해야 함을 언급', 'SUPPLEMENTARY', 5),
(2885, 537, '앱 설치가 전제된 QR 코드·푸시 알림 경로에서는 URL Scheme을 함께 지원한다고 서술', 'SUPPLEMENTARY', 6),

-- 질문 538
(2886, 538, '파일·UserDefaults·Core Data 저장소 중 최소 2개를 App Group의 공유 대상으로 제시', 'ESSENTIAL', 1),
(2887, 538, 'Keychain 공유는 토큰·비밀번호 같은 민감 데이터를 공유할 때 쓴다고 언급', 'ESSENTIAL', 2),
(2888, 538, '두 수단 모두 같은 팀의 앱 사이에서만 데이터를 공유할 수 있음을 언급', 'ESSENTIAL', 3),
(2889, 538, 'App Group의 group. 식별자와 Keychain 공유의 Keychain Access Group을 필요 entitlement로 구분', 'SUPPLEMENTARY', 4),
(2890, 538, 'App Group과 Keychain 공유 모두 위조 가능성이 없음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 539
(2891, 539, '앱마다 격리된 저장 공간에서 실행되어 다른 앱의 파일에 직접 접근할 수 없음을 설명', 'ESSENTIAL', 1),
(2892, 539, '데이터 컨테이너의 UUID가 재설치·업데이트 시 바뀔 수 있음을 언급', 'ESSENTIAL', 2),
(2893, 539, '절대 경로 대신 FileManager로 경로를 매번 조회해야 함을 언급', 'SUPPLEMENTARY', 3),
(2894, 539, '앱 번들은 코드 서명으로 무결성이 보장되어 런타임에 수정할 수 없음을 언급', 'SUPPLEMENTARY', 4),
(2895, 539, '사진·연락처 같은 샌드박스 밖 자원은 시스템 API와 사용자 권한을 거쳐야 함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 540
(2896, 540, '위젯·익스텐션은 별도 프로세스이자 별도 샌드박스라 메인 앱의 UserDefaults를 볼 수 없음을 설명', 'ESSENTIAL', 1),
(2897, 540, 'UserDefaults(suiteName:)에 App Group 식별자를 지정해 값을 공유함을 언급', 'ESSENTIAL', 2),
(2898, 540, 'App Group 식별자를 메인 앱과 위젯 등 모든 타깃에 동일하게 지정해야 함을 언급', 'ESSENTIAL', 3),
(2899, 540, '두 프로세스가 공유 컨테이너 파일을 동시에 쓰면 손상될 수 있음을 언급', 'SUPPLEMENTARY', 4),
(2900, 540, '.atomic 옵션 또는 NSFileCoordinator 중 최소 1개를 동시 쓰기 대응책으로 제시', 'SUPPLEMENTARY', 5);
