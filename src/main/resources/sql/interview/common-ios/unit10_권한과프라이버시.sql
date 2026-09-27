-- Unit: 권한과 프라이버시 (Unit ID: 111)
-- Chapter: iOS (Chapter ID: 9)
-- Topic: IOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-ios-unit10 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(551, 'IOS_COMMON', 111, 'HARD', true,
 '영수증을 촬영해 지출을 기록하는 기능에 카메라 권한이 필요하다면, 권한 요청 흐름을 어떻게 설계하고 사용자가 권한을 허용하지 않은 상태에서는 어떻게 대응하시겠습니까?',
 '사용자가 ''영수증 촬영'' 버튼을 눌러 기능을 직접 실행하려는 순간에 권한을 요청하는 Just-in-Time 방식으로 설계합니다. 앱 첫 실행 시 여러 권한을 일괄 요청하는 것은 승인율을 떨어뜨리는 안티패턴입니다. 시스템 대화상자는 notDetermined 상태일 때만 뜨므로, 먼저 AVCaptureDevice.authorizationStatus로 상태를 조회해 분기합니다. authorized면 바로 카메라를 띄우고, notDetermined면 requestAccess를 호출해 이때만 시스템 대화상자를 보여 줍니다. 한 번 거부된 권한은 앱이 대화상자를 다시 띄울 수 없고 사용자가 설정 앱에서 직접 바꿔야 하므로, denied 상태에서는 openSettingsURLString으로 설정 앱에 이동하는 버튼을 담은 안내를 보여 줍니다. restricted는 사용자가 거부한 것이 아니라 보호자 제한이나 MDM 정책으로 막힌 상태라 설정으로 보내도 사용자가 바꿀 수 없으므로, ''이 기기에서는 사용할 수 없습니다''처럼 다른 안내를 보여 줘야 합니다.'),
(552, 'IOS_COMMON', 111, 'NORMAL', true,
 '위치 권한의 ''사용 중 허용''과 ''항상 허용''은 어떻게 다르며, 앱은 어떤 경우에 ''항상 허용''을 요청해야 하나요?',
 '사용 중 허용(When In Use)은 앱이 포그라운드일 때만 위치를 수신하고, 항상 허용(Always)은 백그라운드에서도 위치를 수신합니다. 항상 허용은 requestWhenInUseAuthorization으로 사용 중 허용을 먼저 받은 뒤 requestAlwaysAuthorization으로 요청합니다. 다만 항상 허용은 요청해도 즉시 부여되지 않고, 시스템이 일정 기간 사용 패턴을 본 뒤 사용자에게 계속 허용할지 재확인합니다. 그래서 내비게이션이나 지오펜스처럼 백그라운드 위치가 실제로 필요한 기능이 아니면 항상 허용은 요청하지 않는 것이 좋고, 위치는 사용 중 허용부터 최소 범위로 요청합니다. 또 iOS 14부터는 사용자가 정확한 위치 대신 대략적 위치를 선택할 수 있으므로, 반경 수 km 수준의 정확도로도 동작하도록 설계하는 것이 우선입니다.'),
(553, 'IOS_COMMON', 111, 'NORMAL', true,
 'iOS 앱에서 액세스 토큰과 카드번호 같은 식별 정보는 저장 방식이 각각 어떻게 달라야 하나요?',
 '액세스 토큰과 리프레시 토큰은 Keychain에 저장하고, 보호 등급은 WhenUnlockedThisDeviceOnly로 지정하며, 로그아웃 시 즉시 삭제합니다. UserDefaults나 plist, 로그에 토큰을 두면 안 되며, 요청·응답 전문을 print로 찍으면 개인정보가 콘솔이나 크래시 리포트에 남기 때문에 os.Logger의 privacy: .private로 식별 정보를 마스킹합니다. 반면 주민번호나 카드번호 같은 식별 정보는 가능하면 아예 기기에 저장하지 않고, 카드번호를 결제 대행사의 토큰으로 바꾸는 식의 서버 토큰화로 대체합니다. 민감 정보를 애초에 기기에 두지 않으면 유출 시 피해 범위가 크게 줄어들고, 불가피하게 저장해야 한다면 Keychain에 최소 기간만 둡니다.'),
(554, 'IOS_COMMON', 111, 'EASY', true,
 'iOS에서 권한을 요청할 때 Info.plist의 UsageDescription 키는 어떤 역할을 하며, 이를 빠뜨리면 어떤 일이 발생하나요?',
 '카메라·마이크·위치처럼 권한이 필요한 자원마다 Info.plist에 사용 목적을 적는 NS...UsageDescription 키가 필수입니다. 예를 들어 카메라는 NSCameraUsageDescription 키가 필요합니다. 이 키가 없으면 권한 요청 시점에 앱이 즉시 종료되는 크래시가 발생하고, 심사에서도 리젝됩니다. 또 이 문구는 심사 항목이자 승인율을 좌우하는 카피이므로, ''카메라 접근이 필요합니다'' 같은 동어 반복 대신 ''영수증을 촬영해 자동으로 지출을 기록하기 위해 카메라를 사용합니다''처럼 사용자가 얻는 이익을 구체적으로 적어야 합니다.'),
(555, 'IOS_COMMON', 111, 'EASY', true,
 '앱 추적 투명성(ATT)이란 무엇이며, 어떤 앱이 ATT 허락을 요청해야 하나요?',
 '앱 추적 투명성(ATT)은 iOS 14.5부터 앱이 사용자를 추적하기 전에 ATTrackingManager.requestTrackingAuthorization으로 사용자 허락을 받도록 한 제도입니다. 요청이 필요한 앱은 광고 식별자(IDFA)에 접근하거나 타 앱·웹사이트 간 사용자를 추적하는 앱으로 한정되며, 추적 없이 동작하는 앱은 요청하지 않아도 됩니다. 요청한다면 Info.plist에 NSUserTrackingUsageDescription 사용 목적 설명이 필수입니다. 요청 시점은 앱이 Active 상태여야 하며, 실행 직후 다른 대화상자와 겹치면 표시되지 않을 수 있으므로 첫 화면이 안정된 뒤 trackingAuthorizationStatus가 notDetermined일 때 호출합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 551
(2961, 551, '사용자가 촬영 기능을 직접 실행하려는 순간에 요청하는 Just-in-Time 방식을 제시', 'ESSENTIAL', 1),
(2962, 551, 'notDetermined 상태일 때만 시스템 대화상자가 뜨므로 요청 전에 권한 상태를 먼저 조회함을 설명', 'ESSENTIAL', 2),
(2963, 551, '한 번 거부된 권한은 앱이 다시 대화상자를 띄울 수 없어 설정 앱 이동 경로를 제공함을 언급', 'ESSENTIAL', 3),
(2964, 551, 'restricted는 보호자 제한·MDM 정책 때문에 사용자가 바꿀 수 없어 별도 안내가 필요함을 언급', 'ESSENTIAL', 4),
(2965, 551, '앱 첫 실행 시 권한을 일괄 요청하면 승인율이 떨어지는 안티패턴임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 552
(2966, 552, '사용 중 허용은 포그라운드에서만, 항상 허용은 백그라운드에서도 위치를 수신한다는 차이를 설명', 'ESSENTIAL', 1),
(2967, 552, '내비게이션·지오펜스처럼 백그라운드 위치가 실제로 필요한 기능에만 항상 허용을 요청함을 언급', 'ESSENTIAL', 2),
(2968, 552, '사용 중 허용을 먼저 받은 뒤에야 항상 허용을 요청할 수 있음을 언급', 'SUPPLEMENTARY', 3),
(2969, 552, '항상 허용은 즉시 부여되지 않고 시스템이 나중에 사용자에게 계속 허용할지 재확인함을 언급', 'SUPPLEMENTARY', 4),
(2970, 552, '사용자가 정확한 위치 대신 대략적 위치를 선택할 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 553
(2971, 553, '액세스·리프레시 토큰은 Keychain에 저장함을 언급', 'ESSENTIAL', 1),
(2972, 553, '카드번호 같은 식별 정보는 가능하면 기기에 저장하지 않고 서버 토큰화로 대체함을 설명', 'ESSENTIAL', 2),
(2973, 553, 'UserDefaults·plist·로그 중 최소 1개를 토큰 저장 금지 위치로 제시', 'SUPPLEMENTARY', 3),
(2974, 553, '로그아웃 시 Keychain의 토큰을 즉시 삭제함을 언급', 'SUPPLEMENTARY', 4),
(2975, 553, 'os.Logger의 privacy: .private로 로그의 식별 정보를 마스킹함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 554
(2976, 554, '권한마다 Info.plist에 사용 목적을 적는 NS...UsageDescription 키가 필수임을 언급', 'ESSENTIAL', 1),
(2977, 554, 'UsageDescription 키가 없으면 권한 요청 시점에 앱이 즉시 종료(크래시)됨을 언급', 'ESSENTIAL', 2),
(2978, 554, 'UsageDescription 누락은 앱 심사에서 리젝 사유가 됨을 언급', 'SUPPLEMENTARY', 3),
(2979, 554, '사용 목적 문구에 사용자가 얻는 이익을 구체적으로 적어 승인율을 높임을 언급', 'SUPPLEMENTARY', 4),

-- 질문 555
(2980, 555, 'ATT가 앱의 사용자 추적에 앞서 사용자 허락(동의)을 받도록 하는 제도임을 설명', 'ESSENTIAL', 1),
(2981, 555, 'ATT 요청이 필요한 앱을 IDFA 접근이나 타 앱·웹사이트 간 추적을 하는 앱으로 한정해 제시', 'ESSENTIAL', 2),
(2982, 555, 'ATT를 요청하려면 NSUserTrackingUsageDescription 키가 필수임을 언급', 'SUPPLEMENTARY', 3),
(2983, 555, '앱이 Active 상태이고 첫 화면이 안정된 뒤에 ATT를 요청해야 함을 언급', 'SUPPLEMENTARY', 4),
(2984, 555, 'ATT가 iOS 14.5부터 적용됨을 명시', 'SUPPLEMENTARY', 5);
