-- Unit: 백그라운드 작업 (Unit ID: 97)
-- Chapter: AOS (Chapter ID: 8)
-- Topic: AOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-aos-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(481, 'AOS_COMMON', 97, 'HARD', true,
 '주기적으로 서버 데이터를 동기화하는 기능을 dataSync 타입 포그라운드 서비스로 계속 돌리려고 합니다. 최신 안드로이드에서 이 설계의 문제점은 무엇이고, 어떤 대안으로 옮기며 그 대안의 한계는 무엇인가요?',
 '포그라운드 서비스는 사용자가 인지하는 즉시·장기 작업용이지, 미룰 수 있는 동기화용이 아닙니다. 실제로 API 35부터 dataSync·mediaProcessing 타입 포그라운드 서비스는 24시간 중 총 6시간까지만 실행되고 초과하면 onTimeout()이 호출됩니다. 또 API 31부터는 앱이 화면에 없을 때 포그라운드 서비스를 시작하면 ForegroundServiceStartNotAllowedException이 발생하므로 백그라운드에서 다시 띄우기도 어렵습니다. 그래서 이런 동기화는 WorkManager로 옮기는 것이 맞습니다. WorkManager는 작업을 내부 DB에 영속화해 프로세스 종료나 재부팅 후에도 실행을 보장하고, PeriodicWorkRequest로 최소 15분 간격의 주기 작업을 걸 수 있습니다. 다만 한계도 있습니다. WorkManager는 언젠가 반드시 실행되는 것은 보장하지만 실행 시각은 보장하지 않아서, 기기가 Doze 상태이거나 앱 대기 버킷이 낮으면 몇 시간 뒤에 실행될 수 있습니다. 푸시 알림 기반 앱이라면 주기적으로 서버를 확인하는 설계 자체를 서버 푸시로 뒤집을 수 없는지도 먼저 검토합니다. FCM 고우선순위 메시지는 Doze를 일시적으로 깨울 수 있어 폴링이 필요 없어집니다.'),
(482, 'AOS_COMMON', 97, 'NORMAL', true,
 'WorkManager와 포그라운드 서비스는 어떤 차이가 있고, 각각 어떤 작업에 선택하나요?',
 '기준은 사용자 인지 여부와 지연 가능 여부입니다. 동기화, 로그 업로드, 백업처럼 지연돼도 되지만 반드시 완료돼야 하는 작업은 WorkManager를 씁니다. WorkManager는 작업을 내부 DB에 영속화하므로 프로세스가 종료되거나 기기가 재부팅돼도 작업이 남아 있다가 실행됩니다. 또 네트워크·충전·저장 공간 같은 제약 조건을 선언할 수 있고, 시스템이 배터리를 고려해 실행 시점을 지연할 수 있습니다. 반면 음악 재생, 내비게이션, 통화처럼 사용자가 인지하는 상태로 지금 당장 계속 실행돼야 하는 장기 작업은 포그라운드 서비스를 씁니다. 포그라운드 서비스는 즉시 실행되지만 실행 중에만 유효해서 프로세스가 종료되면 소멸하고, 대신 알림으로 실행 사실을 반드시 노출해야 합니다.'),
(483, 'AOS_COMMON', 97, 'NORMAL', true,
 '특정 시각에 울려야 하는 리마인더를 구현할 때 WorkManager 대신 AlarmManager를 쓰는 이유는 무엇이고, 정확한 알람에는 어떤 제약이 있나요?',
 'WorkManager는 언젠가 반드시 실행되는 것은 보장하지만 실행 시각은 보장하지 않습니다. 시스템이 조건과 배터리를 고려해 지연할 수 있고, 주기 작업도 정확한 주기가 아니라 실행 창 안 어딘가에서 실행됩니다. 그래서 알람이나 리마인더처럼 특정 시각에 정확히 실행돼야 하는 작업은 예약 시각에 앱을 깨우는 AlarmManager가 적합합니다. 다만 정확한 알람에는 제약이 있습니다. API 31부터는 SCHEDULE_EXACT_ALARM 특수 권한이 필요하고, API 34부터는 알람·시계 앱이 아니면 기본 거부되어 사용자가 설정에서 켜야 합니다. 캘린더·알람 성격이 아니라면 setWindow() 같은 유연한 알람을 씁니다. 또 setExactAndAllowWhileIdle()은 Doze 중에도 알람을 깨우지만 시스템이 9분에 한 번 수준으로 빈도를 제한합니다.'),
(484, 'AOS_COMMON', 97, 'EASY', true,
 '안드로이드에서 포그라운드 서비스를 실행하려면 어떤 요소들이 필요한가요?',
 '포그라운드 서비스는 시스템이 포그라운드 프로세스 수준의 우선순위를 주는 대신, 사용자에게 알림으로 실행 사실을 노출해야 합니다. 그래서 첫째로 알림이 필수입니다. 둘째로 매니페스트에 FOREGROUND_SERVICE 권한을 선언해야 합니다. 셋째로 API 34부터는 서비스에 foregroundServiceType 타입 선언이 필수이고, mediaPlayback이라면 FOREGROUND_SERVICE_MEDIA_PLAYBACK처럼 타입별 권한도 함께 필요합니다. 또 startForegroundService()를 호출한 뒤 짧은 제한 시간 안에 서비스에서 startForeground()를 호출해야 하며, 호출하지 않으면 ANR이 발생합니다.'),
(485, 'AOS_COMMON', 97, 'EASY', true,
 'Doze 모드란 무엇이고, 앱의 백그라운드 작업에 어떤 영향을 주나요?',
 'Doze는 안드로이드 6.0(API 23)에서 도입된 배터리 최적화 모드로, 화면이 꺼지고 기기가 정지 상태로 방치되면 진입합니다. Doze 중에는 네트워크 접근, 작업, 알람이 즉시 실행되지 않고 유지 관리 창(Maintenance Window)에만 일괄 실행되기 때문에 앱의 백그라운드 작업이 지연됩니다. 게다가 시간이 갈수록 유지 관리 창의 간격이 길어집니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 481
(2579, 481, 'API 35부터 dataSync 타입 포그라운드 서비스는 24시간 중 총 6시간으로 실행이 제한됨을 언급', 'ESSENTIAL', 1),
(2580, 481, '미룰 수 있는 동기화 작업은 WorkManager로 옮기는 것이 적합함을 제시', 'ESSENTIAL', 2),
(2581, 481, 'Doze나 낮은 앱 대기 버킷에서는 WorkManager 작업 실행이 지연될 수 있음을 언급', 'ESSENTIAL', 3),
(2582, 481, 'FCM 고우선순위 메시지로 서버 푸시를 받아 주기적 폴링을 대체하는 방안을 제시', 'SUPPLEMENTARY', 4),
(2583, 481, 'API 31부터 백그라운드에서 포그라운드 서비스 시작이 금지됨을 언급', 'SUPPLEMENTARY', 5),
(2584, 481, 'PeriodicWorkRequest의 최소 간격이 15분임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 482
(2585, 482, '지연 가능하고 반드시 완료돼야 하는 작업에는 WorkManager를 선택함을 제시', 'ESSENTIAL', 1),
(2586, 482, '사용자가 보고 있어야 하는 즉시·장기 작업에는 포그라운드 서비스를 선택함을 제시', 'ESSENTIAL', 2),
(2587, 482, '프로세스 종료 시 WorkManager 작업은 보장되고 포그라운드 서비스는 소멸하는 차이를 설명', 'ESSENTIAL', 3),
(2588, 482, '포그라운드 서비스는 실행 중 알림 노출이 필수임을 언급', 'SUPPLEMENTARY', 4),
(2589, 482, '네트워크·충전 같은 제약 조건을 WorkManager 작업에 선언할 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 483
(2590, 483, 'WorkManager는 실행 시각을 보장하지 않고 시스템이 실행을 지연할 수 있음을 언급', 'ESSENTIAL', 1),
(2591, 483, '특정 시각에 정확히 실행돼야 하는 작업에는 AlarmManager가 적합함을 제시', 'ESSENTIAL', 2),
(2592, 483, '정확한 알람에는 API 31부터 SCHEDULE_EXACT_ALARM 권한이 필요함을 언급', 'ESSENTIAL', 3),
(2593, 483, 'API 34부터 알람·시계 앱이 아니면 SCHEDULE_EXACT_ALARM이 기본 거부됨을 언급', 'SUPPLEMENTARY', 4),
(2594, 483, '알람 성격이 아닌 작업은 setWindow() 같은 유연한 알람을 쓰도록 제시', 'SUPPLEMENTARY', 5),
(2595, 483, 'Doze 중 setExactAndAllowWhileIdle() 알람은 시스템이 빈도를 제한함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 484
(2596, 484, '실행 사실을 사용자에게 노출하는 알림이 필수임을 언급', 'ESSENTIAL', 1),
(2597, 484, '매니페스트에 FOREGROUND_SERVICE 권한을 선언해야 함을 언급', 'ESSENTIAL', 2),
(2598, 484, 'API 34부터 foregroundServiceType 타입 선언이 필수임을 언급', 'ESSENTIAL', 3),
(2599, 484, 'FOREGROUND_SERVICE_MEDIA_PLAYBACK 같은 타입별 권한이 추가로 필요함을 언급', 'SUPPLEMENTARY', 4),
(2600, 484, 'startForegroundService() 호출 후 제한 시간 안에 startForeground()를 호출하지 않으면 ANR이 발생함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 485
(2601, 485, '화면이 꺼지고 기기가 정지 상태로 방치되면 Doze에 진입함을 언급', 'ESSENTIAL', 1),
(2602, 485, '네트워크·작업·알람이 유지 관리 창에만 일괄 실행되어 지연된다고 설명', 'ESSENTIAL', 2),
(2603, 485, '시간이 갈수록 유지 관리 창의 간격이 길어짐을 언급', 'SUPPLEMENTARY', 3),
(2604, 485, 'Doze 모드가 안드로이드 6.0(API 23)에서 도입됐음을 언급', 'SUPPLEMENTARY', 4);
