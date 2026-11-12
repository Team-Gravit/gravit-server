-- Unit: 권한과 보안 (Unit ID: 101)
-- Chapter: AOS (Chapter ID: 8)
-- Topic: AOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-aos-unit10 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(501, 'AOS_COMMON', 101, 'HARD', true,
 '앱이 인증 토큰을 기기에 저장하고 APK 안에 API 키를 포함하고 있을 때, Keystore 암호화와 R8 난독화만 적용하면 충분한지 각각의 한계와 보완 설계를 설명해 주세요.',
 '둘 다 필요하지만 그것만으로는 충분하지 않습니다. 먼저 토큰 쪽입니다. 토큰을 Keystore 키로 암호화해 내부 저장소에 두는 것은 기기 분실, 백업 추출, 다른 앱의 접근에 대한 방어입니다. 하지만 앱이 실행 중일 때는 복호화된 토큰이 메모리에 있어서 루팅 기기에서는 훅킹으로 가로챌 수 있습니다. 그래서 근본적으로는 토큰 수명을 짧게 하고, 이상 징후가 보이면 서버에서 폐기하는 설계를 함께 가져가야 합니다. 다음은 API 키 쪽입니다. R8 난독화는 클래스와 멤버 이름을 의미 없는 이름으로 바꿀 뿐, API 키나 서버 URL 같은 문자열 상수와 로직 흐름은 그대로 남깁니다. 그래서 APK에 넣은 API 키는 난독화해도 추출할 수 있고, 난독화는 방어가 아니라 지연 수단입니다. 따라서 API 키는 가능하면 서버 프록시로 옮겨 클라이언트에 비밀을 두지 않는 설계를 우선해야 합니다. 결제나 치트 방지처럼 위조 여부가 중요한 경우에는 Play Integrity API 같은 서버 검증을 추가합니다.',
 'interview-question/501.mp3'),
(502, 'AOS_COMMON', 101, 'NORMAL', true,
 '안드로이드 권한 중 일반(Normal) 권한과 위험(Dangerous) 권한은 사용자 동의 방식이 어떻게 다른지 예시와 함께 설명해 주세요.',
 '일반 권한은 매니페스트에 선언하기만 하면 자동으로 허용됩니다. INTERNET, ACCESS_NETWORK_STATE, VIBRATE가 여기에 해당합니다. 반면 위험 권한은 카메라, 위치, 연락처처럼 사용자 프라이버시와 직결된 자원에 대한 권한입니다. 매니페스트 선언과 별도로, 런타임에 사용자가 명시적으로 허용해야 쓸 수 있습니다. CAMERA, ACCESS_FINE_LOCATION, READ_CONTACTS, POST_NOTIFICATIONS가 예입니다. Android 6.0(API 23)부터는 위험 권한을 설치 시점이 아니라 실제로 사용하는 시점에 요청합니다. 참고로 SYSTEM_ALERT_WINDOW 같은 특수 권한은 사용자가 설정 화면에서 직접 켜야 합니다.',
 'interview-question/502.mp3'),
(503, 'AOS_COMMON', 101, 'NORMAL', true,
 '런타임 권한 요청이 거부됐을 때, 한 번 거부된 경우와 ''다시 묻지 않음''으로 영구 거부된 경우를 어떻게 판별하고 각각 어떻게 대응하는지 설명해 주세요.',
 '권한 요청 결과가 거부로 오면 shouldShowRequestPermissionRationale 값으로 두 경우를 판별합니다. 값이 true이면 사용자가 이전에 거부했지만 다시 요청할 수 있는 상태입니다. 이때는 다음 요청 전에 왜 이 권한이 필요한지 앱 자체 UI로 먼저 설명합니다. 거부 결과 후 값이 false이면 두 번 거부했거나 ''다시 묻지 않음''을 선택한 영구 거부 상태입니다. 이 경우 시스템 대화상자를 다시 띄울 수 없으므로 설정 화면으로 이동하도록 안내합니다. Android 11부터는 같은 권한을 두 번 거부하면 시스템이 자동으로 다시 묻지 않습니다. 또 권한이 거부되어도 앱이 동작할 수 있도록 사진 대신 갤러리 선택, 위치 대신 수동 입력 같은 대체 경로를 제공하는 것이 좋습니다.',
 'interview-question/503.mp3'),
(504, 'AOS_COMMON', 101, 'EASY', true,
 'Android Keystore는 무엇이고, 암호 키를 보관하는 데 왜 안전한지 설명해 주세요.',
 'Android Keystore는 암호 키를 앱 프로세스 밖, 즉 하드웨어 보안 모듈이나 TEE에 보관하는 시스템입니다. 앱은 키 자체를 꺼낼 수 없고, 그 키로 암호화나 복호화 연산만 요청할 수 있습니다. 키가 앱 메모리에 노출되지 않기 때문에 힙 덤프나 루팅으로도 키를 빼내기 어렵습니다. 그래서 토큰 같은 민감 데이터를 Keystore 키로 암호화해 내부 저장소에 저장합니다. 과거에 권장되던 EncryptedSharedPreferences는 폐기되었고, 지금은 Keystore를 직접 사용하는 방식이 권장됩니다.',
 'interview-question/504.mp3'),
(505, 'AOS_COMMON', 101, 'EASY', true,
 '안드로이드 빌드에서 R8이 수행하는 세 가지 기능은 무엇인지 설명해 주세요.',
 'R8은 안드로이드 빌드 도구의 기본 축소기로, 세 가지 일을 합니다. 첫째, 코드 축소(Shrinking)입니다. 도달 불가능한 클래스, 메서드, 필드를 제거해 APK 크기와 공격 표면을 줄입니다. 둘째, 난독화(Obfuscation)입니다. 클래스와 멤버 이름을 a, b, c처럼 의미 없는 이름으로 바꿔 디컴파일 결과를 읽기 어렵게 만듭니다. 셋째, 최적화(Optimization)입니다. 인라인, 죽은 코드 제거, 클래스 병합으로 실행 성능을 높이고 크기를 줄입니다. 릴리스 빌드에서 isMinifyEnabled를 true로 설정하면 켜집니다. 난독화된 스택 트레이스는 그대로 읽을 수 없으므로 빌드마다 생성되는 mapping.txt를 보관해야 합니다. 또 Gson처럼 필드명을 런타임에 읽는 라이브러리를 쓰면 -keep 규칙이 필요합니다.',
 'interview-question/505.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 501
(2686, 501, '앱 실행 중에는 복호화된 토큰이 메모리에 있어 루팅 기기에서 훅킹으로 가로챌 수 있음을 언급', 'ESSENTIAL', 1),
(2687, 501, '토큰 수명 단축·서버에서 이상 징후 시 폐기 중 최소 1개를 토큰 보호의 보완책으로 제시', 'ESSENTIAL', 2),
(2688, 501, '난독화는 이름만 바꿀 뿐 API 키 같은 문자열 상수는 APK에서 추출 가능함을 언급', 'ESSENTIAL', 3),
(2689, 501, 'API 키를 서버 프록시로 옮기는 등 클라이언트에 비밀을 두지 않는 설계를 제시', 'ESSENTIAL', 4),
(2690, 501, '분실·백업·다른 앱 접근 중 최소 1개를 저장소 암호화가 막는 위협으로 제시', 'SUPPLEMENTARY', 5),
(2691, 501, '위조 여부가 중요한 경우 Play Integrity API 같은 서버 검증을 추가함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 502
(2692, 502, '일반 권한은 매니페스트 선언만으로 자동 허용됨을 언급', 'ESSENTIAL', 1),
(2693, 502, '위험 권한은 런타임에 사용자가 직접 허용해야 쓸 수 있음을 언급', 'ESSENTIAL', 2),
(2694, 502, 'INTERNET 등 일반 권한 예시와 CAMERA 등 위험 권한 예시를 각각 1개 이상 제시', 'ESSENTIAL', 3),
(2695, 502, 'Android 6.0(API 23)부터 위험 권한을 설치 시가 아닌 사용 시점에 요청함을 언급', 'SUPPLEMENTARY', 4),
(2696, 502, '특수 권한은 설정 화면에서 사용자가 직접 켜야 함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 503
(2697, 503, '거부 결과 후 shouldShowRequestPermissionRationale이 false면 영구 거부로 판별함을 언급', 'ESSENTIAL', 1),
(2698, 503, 'shouldShowRequestPermissionRationale이 true면 다음 요청 전에 권한의 필요성을 먼저 안내함을 언급', 'ESSENTIAL', 2),
(2699, 503, '영구 거부 상태에서는 사용자를 설정 화면으로 안내함을 언급', 'ESSENTIAL', 3),
(2700, 503, 'Android 11부터 같은 권한을 두 번 거부하면 시스템이 자동으로 다시 묻지 않음을 언급', 'SUPPLEMENTARY', 4),
(2701, 503, '거부되어도 갤러리 선택·수동 입력 같은 대체 경로를 제공함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 504
(2702, 504, 'Keystore가 암호 키를 앱 프로세스 밖(하드웨어 보안 모듈 또는 TEE)에 보관함을 언급', 'ESSENTIAL', 1),
(2703, 504, '앱은 키 자체를 꺼내지 못하고 암호화·복호화 연산만 요청할 수 있음을 언급', 'ESSENTIAL', 2),
(2704, 504, '키가 메모리에 노출되지 않아 힙 덤프나 루팅으로도 빼내기 어려움을 언급', 'SUPPLEMENTARY', 3),
(2705, 504, 'EncryptedSharedPreferences가 폐기되어 Keystore를 직접 사용하는 방식이 권장됨을 언급', 'SUPPLEMENTARY', 4),

-- 질문 505
(2706, 505, '도달 불가능한 클래스·메서드·필드를 제거하는 코드 축소(Shrinking)를 언급', 'ESSENTIAL', 1),
(2707, 505, '클래스·멤버 이름을 a, b처럼 의미 없는 이름으로 바꾸는 난독화를 언급', 'ESSENTIAL', 2),
(2708, 505, '인라인·죽은 코드 제거·클래스 병합 중 최소 1개를 R8 최적화의 동작으로 제시', 'ESSENTIAL', 3),
(2709, 505, '난독화된 스택 트레이스를 해독하려면 빌드별 mapping.txt를 보관해야 함을 언급', 'SUPPLEMENTARY', 4),
(2710, 505, 'Gson처럼 필드명을 런타임에 읽는 라이브러리는 -keep 규칙이 필요함을 언급', 'SUPPLEMENTARY', 5);
