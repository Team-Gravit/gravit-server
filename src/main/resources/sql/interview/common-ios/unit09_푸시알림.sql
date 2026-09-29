-- Unit: 푸시 알림 (Unit ID: 110)
-- Chapter: iOS (Chapter ID: 9)
-- Topic: IOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-ios-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(546, 'IOS_COMMON', 110, 'HARD', true,
 '앱이 종료된 상태에서 사용자가 주문 알림을 탭했을 때 주문 상세 화면으로 정확히 이동시키려면 어떻게 설계해야 하며, 탭 즉시 뷰 컨트롤러를 만들어 push하는 방식은 왜 실패할 수 있나요?',
 '앱이 종료된 상태에서 알림을 탭하면 앱이 실행된 뒤 userNotificationCenter(_:didReceive:)가 호출됩니다. 이때 UNUserNotificationCenter의 delegate를 didFinishLaunching에서 설정해 두어야 시스템이 곧이어 호출하는 didReceive를 놓치지 않고, 첫 화면의 viewDidLoad처럼 늦게 설정하면 이 호출을 놓칩니다. 탭 즉시 OrderDetailViewController를 만들어 rootViewController의 navigation에 push하는 방식은 안티패턴인데, 앱이 종료 상태였다면 window와 navigation이 아직 없어 nil이거나 로그인 화면일 수 있기 때문입니다. 그래서 didReceive에서는 response.notification.request.content.userInfo에서 route와 id를 추출해 DeepLink 같은 딥링크 모델로 변환하고, 화면 이동은 라우터(Coordinator)에 위임합니다. 라우터는 앱이 이미 실행 중이고 루트 화면이 준비됐다면 즉시 이동하고, 방금 실행돼 화면 구성 전이라면 pending에 딥링크를 보관했다가 루트 화면 준비 후 flushIfNeeded로 처리합니다. 인증이 필요한 화면이면 로그인 완료 후 flushIfNeeded()로 이어서 이동합니다. 또한 URL Scheme·Universal Link 진입과 같은 DeepLink 모델·라우터를 공유하면 진입 경로가 늘어나도 처리 코드는 하나로 유지됩니다.',
 'interview-question/546.mp3'),
(547, 'IOS_COMMON', 110, 'NORMAL', true,
 '로컬 알림과 원격 푸시는 어떤 차이가 있나요?',
 '가장 큰 차이는 발신 주체입니다. 로컬 알림은 앱 자신이 기기 안에서 예약하고, 원격 푸시는 서버가 APNs를 거쳐 기기로 보냅니다. 사전 준비도 다른데, 로컬 알림은 권한 요청만 하면 되지만 원격 푸시는 권한 요청에 더해 디바이스 토큰 등록과 서버·APNs 인증 구성이 필요합니다. 또 로컬 알림은 네트워크가 불필요한 반면 원격 푸시는 네트워크가 필요하며, APNs와의 지속 연결은 OS가 관리합니다. 트리거 면에서 로컬 알림은 시간 간격, 특정 날짜·시각, 위치 진입·이탈로 발생하고 원격 푸시는 서버가 원하는 시점에 보냅니다. 데이터 출처 면에서 로컬 알림은 앱이 이미 알고 있는 정보를, 원격 푸시는 서버의 최신 정보를 전달하므로 알람·리마인더는 로컬 알림, 채팅 메시지·주문 상태 변경은 원격 푸시가 대표 사례입니다. 반면 두 방식 모두 UNUserNotificationCenter로 권한·표시·탭 처리를 통일해서 다루고, 시스템이 배너·사운드·배지를 표시하는 것도 같아서 차이는 누가 언제 만들었는가뿐입니다.',
 'interview-question/547.mp3'),
(548, 'IOS_COMMON', 110, 'NORMAL', true,
 '앱이 포그라운드일 때와 백그라운드일 때 알림이 처리되는 방식은 어떻게 다른가요?',
 '포그라운드(Active) 상태에서는 알림이 도착해도 기본적으로 배너를 표시하지 않습니다. 대신 UNUserNotificationCenterDelegate의 willPresent가 호출되고, 앱이 [.banner, .list, .sound] 같은 표시 옵션을 돌려줘야 배너가 뜹니다. 즉 포그라운드에서는 앱이 표시 여부를 결정합니다. 예를 들어 채팅 화면에서 현재 보고 있는 채팅방과 알림 대상이 같으면 빈 옵션을 반환해 표시를 생략하는 것이 기본 처리입니다. 반면 백그라운드나 Suspended 상태에서는 시스템이 배너·사운드·배지를 표시하고, 사용자가 알림을 탭하면 didReceive가 호출됩니다. 앱이 종료(Not Running) 상태라면 시스템이 배너를 표시하고, 탭하면 앱이 실행된 후 didReceive가 호출되는데, 이를 위해 delegate가 미리 설정돼 있어야 합니다.',
 'interview-question/548.mp3'),
(549, 'IOS_COMMON', 110, 'EASY', true,
 '원격 푸시가 서버에서 사용자 기기까지 전달되는 과정을 설명해 주세요.',
 '먼저 앱이 실행되면 registerForRemoteNotifications()를 호출하고, APNs가 기기·앱 조합에 대한 디바이스 토큰을 발급해 didRegisterForRemoteNotificationsWithDeviceToken으로 전달합니다. 앱은 이 토큰을 자사 서버에 전송해 사용자 ID와 매핑해 저장합니다. 디바이스 토큰은 재설치, 백업 복원, OS 업데이트 등으로 바뀔 수 있으므로 앱 실행 시마다 등록하고 값이 바뀌었으면 서버에 다시 보냅니다. 이후 보낼 일이 생기면 서버가 APNs에 전송 요청(HTTP/2 요청)을 보내는데, 인증은 .p8 키 기반 JWT 토큰이나 인증서를 쓰며 만료 관리가 쉬운 토큰 기반 방식이 권장됩니다. 그러면 APNs가 해당 기기로 알림을 전달하고, 기기가 오프라인이면 일정 기간 보관 후 최신 1건을 전달합니다. 기기에서는 시스템이 배너를 표시하거나 앱이 실행 중이면 delegate로 전달합니다. 다만 APNs는 전달을 최선 노력(best-effort)으로 보장하므로 기기가 오래 오프라인이면 유실될 수 있어, 중요한 상태 변경은 앱 실행 시 서버 조회로 보완해야 합니다.',
 'interview-question/549.mp3'),
(550, 'IOS_COMMON', 110, 'EASY', true,
 'APNs 페이로드는 어떻게 구성되며, 사일런트 푸시란 무엇인가요?',
 'APNs 페이로드는 JSON이며, 시스템이 해석하는 aps 딕셔너리와 앱이 자유롭게 쓰는 커스텀 키로 구성됩니다. aps에는 배너에 표시할 제목·본문인 alert, 앱 아이콘 배지 숫자인 badge, 재생할 sound, 액션 버튼 세트 식별자인 category, 알림 센터 그룹화용 thread-id 등이 들어가고, 탭 시 이동에 쓸 route·id 같은 값은 커스텀 키로 넣습니다. 크기 한계는 일반 알림 4KB라서 큰 데이터는 ID만 보내고 앱이 서버에서 조회합니다. 또 mutable-content가 1이면 Notification Service Extension이 표시 전에 내용을 수정해 이미지 첨부나 본문 복호화 등을 할 수 있습니다. 사일런트 푸시는 aps의 content-available을 1로 보낸 푸시로, 배너 없이 앱을 백그라운드에서 깨워 데이터를 갱신합니다. Background Modes의 Remote notifications를 켜야 하고 application(_:didReceiveRemoteNotification:fetchCompletionHandler:)로 전달되며, 시스템이 전달 빈도를 조절하므로 실시간성이 보장되지 않습니다.',
 'interview-question/550.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 546
(2931, 546, '알림 delegate를 didFinishLaunching에서 설정해야 didReceive 호출을 놓치지 않음을 설명', 'ESSENTIAL', 1),
(2932, 546, '탭 즉시 뷰 컨트롤러를 push하면 종료 상태였던 앱은 window·navigation이 아직 없어 실패할 수 있음을 설명', 'ESSENTIAL', 2),
(2933, 546, 'userInfo의 route·id를 딥링크 모델로 변환해 라우터/Coordinator에 위임하는 흐름을 설명', 'ESSENTIAL', 3),
(2934, 546, '루트 화면이 준비되기 전이면 딥링크를 보관했다가 준비 후 이동시키는 방식을 설명', 'ESSENTIAL', 4),
(2935, 546, '인증이 필요한 화면이면 로그인 완료 후 보관된 딥링크로 이어서 이동함을 언급', 'SUPPLEMENTARY', 5),
(2936, 546, 'URL Scheme·Universal Link 진입과 같은 DeepLink 모델·라우터를 공유함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 547
(2937, 547, '로컬 알림은 앱 자신이, 원격 푸시는 서버가 APNs를 거쳐 발신한다는 차이를 설명', 'ESSENTIAL', 1),
(2938, 547, '원격 푸시는 로컬 알림과 달리 사전 준비로 디바이스 토큰 등록이 필요함을 언급', 'ESSENTIAL', 2),
(2939, 547, '두 방식 모두 UNUserNotificationCenter로 권한·표시·탭 처리를 동일하게 다룬다는 점을 언급', 'ESSENTIAL', 3),
(2940, 547, '로컬 알림은 네트워크가 불필요하고 원격 푸시는 네트워크가 필요하다는 차이를 설명', 'SUPPLEMENTARY', 4),
(2941, 547, '로컬 알림의 트리거로 시간 간격·특정 날짜·위치 진입 중 최소 1개를 제시', 'SUPPLEMENTARY', 5),
(2942, 547, '로컬 알림은 앱이 이미 아는 정보, 원격 푸시는 서버의 최신 정보를 전달한다는 차이를 설명', 'SUPPLEMENTARY', 6),

-- 질문 548
(2943, 548, '포그라운드에서는 기본적으로 시스템이 알림 배너를 표시하지 않는다는 점을 언급', 'ESSENTIAL', 1),
(2944, 548, '포그라운드 수신 시 willPresent에서 앱이 표시 옵션을 반환해 표시 여부를 결정함을 설명', 'ESSENTIAL', 2),
(2945, 548, '백그라운드 상태에서 사용자가 알림을 탭하면 didReceive가 호출됨을 설명', 'ESSENTIAL', 3),
(2946, 548, '백그라운드 상태에서는 시스템이 배너·사운드·배지를 표시함을 언급', 'SUPPLEMENTARY', 4),
(2947, 548, '보고 있는 화면과 알림 대상이 같으면 willPresent에서 표시를 생략하는 처리를 설명', 'SUPPLEMENTARY', 5),
(2948, 548, '종료 상태에서 탭하면 앱 실행 후 didReceive가 호출됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 549
(2949, 549, 'registerForRemoteNotifications 호출 시 APNs가 디바이스 토큰을 발급함을 설명', 'ESSENTIAL', 1),
(2950, 549, '앱이 발급받은 디바이스 토큰을 자사 서버에 보내 사용자 ID와 매핑함을 언급', 'ESSENTIAL', 2),
(2951, 549, '서버가 APNs에 전송 요청을 보내면 APNs가 해당 기기로 알림을 전달함을 설명', 'ESSENTIAL', 3),
(2952, 549, '디바이스 토큰이 재설치·백업 복원·OS 업데이트 중 최소 1개로 바뀔 수 있음을 언급', 'SUPPLEMENTARY', 4),
(2953, 549, '서버와 APNs 간 인증은 .p8 키 기반 토큰 방식이 인증서보다 권장됨을 언급', 'SUPPLEMENTARY', 5),
(2954, 549, '기기가 오래 오프라인이면 유실될 수 있어 앱 실행 시 서버 조회로 보완함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 550
(2955, 550, '페이로드가 시스템이 해석하는 aps 딕셔너리와 앱이 자유롭게 쓰는 커스텀 키로 이루어짐을 설명', 'ESSENTIAL', 1),
(2956, 550, 'content-available이 1이면 배너 없이 앱을 백그라운드에서 깨워 데이터를 갱신하는 사일런트 푸시임을 설명', 'ESSENTIAL', 2),
(2957, 550, '사일런트 푸시는 시스템이 전달 빈도를 조절해 실시간성이 보장되지 않음을 언급', 'ESSENTIAL', 3),
(2958, 550, '일반 알림 페이로드의 크기 한계가 4KB임을 언급', 'SUPPLEMENTARY', 4),
(2959, 550, 'mutable-content가 1이면 Notification Service Extension이 표시 전에 내용을 수정할 수 있음을 언급', 'SUPPLEMENTARY', 5),
(2960, 550, '사일런트 푸시를 받으려면 Background Modes의 Remote notifications를 켜야 함을 언급', 'SUPPLEMENTARY', 6);
