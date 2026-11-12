-- Unit: 4대 컴포넌트와 인텐트 (Unit ID: 92)
-- Chapter: AOS (Chapter ID: 8)
-- Topic: AOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-aos-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(456, 'AOS_COMMON', 92, 'HARD', true,
 '앱에서 암시적 인텐트로 다른 앱의 기능을 호출하면서, 동시에 외부 앱이 보내는 공유 인텐트를 받는 액티비티를 공개하려고 합니다. 호출하는 쪽과 받는 쪽 각각에서 어떤 실패·보안 위험이 있고 어떻게 대응해야 하는지 설명해 주시겠어요?',
 '호출하는 쪽에서는 암시적 인텐트가 액션·데이터·카테고리만 지정하고 처리할 앱은 시스템이 결정하기 때문에, 처리할 앱이 없으면 ActivityNotFoundException이 발생할 수 있습니다. 그래서 startActivity 전에 resolveActivity(packageManager)로 처리 가능한 앱이 있는지 사전에 확인해야 합니다. 또 암시적 인텐트는 악의적 앱이 가로챌 수 있어 보안상 주의가 필요합니다. 참고로 Android 11(API 30)부터는 패키지 가시성 제한 때문에 resolveActivity()가 다른 앱을 보지 못할 수 있어, 특정 앱을 조회하려면 매니페스트에 <queries>를 선언해야 하고, 다만 ACTION_VIEW·ACTION_SEND 같은 주요 액션은 예외적으로 허용됩니다. 받는 쪽에서는 android:exported 속성이 다른 앱이 이 컴포넌트를 시작할 수 있는지를 결정하므로, 공유 인텐트를 받으려면 인텐트 필터와 함께 exported="true"로 선언합니다. Android 12(API 31)부터는 인텐트 필터가 있는 컴포넌트에 이 값을 명시하지 않으면 설치가 거부됩니다. 그리고 exported="true"인 컴포넌트가 받는 인텐트는 임의의 앱이 보낼 수 있으므로, 인텐트 엑스트라는 신뢰할 수 없는 입력으로 보고 엑스트라 값으로 파일 경로나 URL을 구성한다면 반드시 검증해야 합니다.',
 'interview-question/456.mp3'),
(457, 'AOS_COMMON', 92, 'NORMAL', true,
 '명시적 인텐트와 암시적 인텐트의 차이는 무엇이고, 각각 어떤 상황에 사용하는지 설명해 주시겠어요?',
 '두 인텐트의 차이는 대상 클래스를 지정하느냐입니다. 명시적 인텐트는 Intent(this, DetailActivity::class.java)처럼 대상 컴포넌트의 클래스 이름을 직접 지정하며, 같은 앱 내부의 화면 전환이나 서비스 시작에 사용합니다. 클래스가 존재하면 성공하므로 실패 가능성이 낮고 안전합니다. 암시적 인텐트는 대상 클래스를 지정하지 않고 액션·데이터·카테고리만 명시하며, 시스템이 매니페스트의 인텐트 필터와 대조해 처리할 수 있는 컴포넌트를 찾습니다. 그래서 수신 측에는 인텐트 필터가 필수이고, 브라우저 열기, 공유하기, 전화 걸기처럼 누가 처리하든 상관없는 타 앱 기능 호출에 씁니다. 인텐트 필터 매칭은 액션·데이터·카테고리 세 가지를 모두 통과해야 하고, 여러 앱이 매칭되면 시스템이 선택 대화상자(Chooser)를 띄우거나 사용자가 지정한 기본 앱으로 보냅니다. 반면 처리 앱이 없으면 예외가 발생할 수 있어 사전 확인이 필요합니다.',
 'interview-question/457.mp3'),
(458, 'AOS_COMMON', 92, 'NORMAL', true,
 '시작된 서비스(Started Service)와 바인드 서비스(Bound Service)는 시작·종료 방식과 용도에서 어떻게 다른지 설명해 주시겠어요?',
 '시작 방식을 보면, 시작된 서비스는 startService()로 시작하고 바인드 서비스는 bindService()로 시작합니다. 종료 시점도 다른데, 시작된 서비스는 stopSelf() 또는 stopService()로 종료되고, 바인드 서비스는 모든 클라이언트가 unbindService()를 호출하면 종료됩니다. 대표 용도로는 시작된 서비스가 파일 다운로드·업로드에, 바인드 서비스가 음악 재생 제어나 IPC에 쓰입니다. 두 종류 모두 서비스는 별도 스레드가 아니라 메인 스레드에서 실행되므로 무거운 작업은 직접 스레드를 분리해야 합니다. 또 Android 8.0(API 26)부터는 백그라운드 상태의 앱이 startService()로 서비스를 시작할 수 없어서 포그라운드 서비스 또는 WorkManager를 사용해야 합니다.',
 'interview-question/458.mp3'),
(459, 'AOS_COMMON', 92, 'EASY', true,
 '안드로이드의 4대 컴포넌트는 무엇이고, 각각 어떤 역할을 하는지 설명해 주시겠어요?',
 '4대 컴포넌트는 Activity, Service, BroadcastReceiver, ContentProvider입니다. Activity는 사용자와 상호작용하는 하나의 화면을 담당하며, 시스템은 액티비티를 백 스택으로 관리해 뒤로 가기를 누르면 스택 상단의 액티비티가 제거됩니다. Service는 UI 없이 백그라운드에서 오래 걸리는 작업을 수행하는 컴포넌트입니다. BroadcastReceiver는 배터리 부족, 네트워크 변경, 부팅 완료처럼 시스템이나 다른 앱이 보내는 이벤트, 즉 브로드캐스트를 수신합니다. ContentProvider는 연락처나 미디어 저장소처럼 앱의 데이터를 다른 앱에 공개해 공유하는 컴포넌트로, content://authority/path 형태의 URI로 접근하고 query·insert·update·delete 같은 CRUD 메서드를 구현합니다.',
 'interview-question/459.mp3'),
(460, 'AOS_COMMON', 92, 'EASY', true,
 '안드로이드 앱의 진입점은 어디라고 할 수 있나요? 하나의 main() 함수에서 시작하는 일반 프로그램과 비교해 설명해 주시겠어요?',
 '안드로이드 앱은 하나의 main()에서 출발하지 않으며, 단일 진입점이 없습니다. 매니페스트(AndroidManifest.xml)에 등록된 컴포넌트를 시스템이 필요할 때 직접 인스턴스화하는 구조입니다. 흔히 MainActivity를 진입점이라고 하지만, 정확히는 런처 인텐트(MAIN + LAUNCHER)를 받는 액티비티가 진입점일 뿐입니다. 브로드캐스트나 서비스 시작으로도 프로세스가 생성될 수 있고, 컴포넌트는 다른 앱이 카메라 액티비티를 띄우거나 시스템이 부팅 완료 브로드캐스트를 보내는 식으로 앱 밖에서도 실행될 수 있습니다. 그래서 컴포넌트 간 통신은 객체 참조가 아니라 인텐트라는 직렬화 가능한 메시지로 이루어집니다.',
 'interview-question/460.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 456
(2444, 456, '처리할 앱이 없으면 ActivityNotFoundException이 발생하므로 resolveActivity()로 사전 확인함을 설명', 'ESSENTIAL', 1),
(2445, 456, '암시적 인텐트는 악의적 앱이 가로챌 수 있어 보안상 주의가 필요함을 언급', 'ESSENTIAL', 2),
(2446, 456, 'android:exported 속성이 외부 앱의 컴포넌트 시작 허용 여부를 결정함을 설명', 'ESSENTIAL', 3),
(2447, 456, 'exported="true" 컴포넌트가 받은 인텐트 엑스트라는 신뢰할 수 없는 입력이므로 검증해야 함을 설명', 'ESSENTIAL', 4),
(2448, 456, 'Android 12(API 31)부터 인텐트 필터가 있는 컴포넌트에 exported 값이 없으면 설치가 거부됨을 언급', 'SUPPLEMENTARY', 5),
(2449, 456, 'Android 11부터 패키지 가시성 제한으로 resolveActivity()가 다른 앱을 못 볼 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 457
(2450, 457, 'Explicit Intent는 대상 컴포넌트의 클래스 이름을 직접 지정함을 언급', 'ESSENTIAL', 1),
(2451, 457, '암시적 인텐트는 액션·데이터·카테고리만 지정하고 시스템이 인텐트 필터와 대조해 대상을 찾음을 설명', 'ESSENTIAL', 2),
(2452, 457, 'Explicit Intent는 앱 내부 화면 전환, 암시적 인텐트는 타 앱 기능 호출에 쓰임을 구분', 'ESSENTIAL', 3),
(2453, 457, '인텐트 필터 매칭은 액션·데이터·카테고리 세 가지를 모두 통과해야 함을 언급', 'SUPPLEMENTARY', 4),
(2454, 457, '여러 앱이 매칭되면 선택 대화상자(Chooser)를 띄우거나 사용자가 지정한 기본 앱으로 보냄을 언급', 'SUPPLEMENTARY', 5),

-- 질문 458
(2455, 458, '시작된 서비스는 startService(), 바인드 서비스는 bindService()로 시작함을 구분', 'ESSENTIAL', 1),
(2456, 458, '시작된 서비스는 stopSelf()·stopService()로, 바인드 서비스는 모든 클라이언트가 unbindService()하면 종료됨을 구분', 'ESSENTIAL', 2),
(2457, 458, '시작된 서비스는 파일 다운로드·업로드, 바인드 서비스는 음악 재생 제어·IPC 용도로 구분', 'ESSENTIAL', 3),
(2458, 458, '서비스는 별도 스레드가 아니라 메인 스레드에서 실행됨을 언급', 'SUPPLEMENTARY', 4),
(2459, 458, 'Android 8.0부터 백그라운드 앱은 startService()를 쓸 수 없어 포그라운드 서비스나 WorkManager를 써야 함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 459
(2460, 459, 'Activity가 사용자와 상호작용하는 하나의 화면을 담당함을 설명', 'ESSENTIAL', 1),
(2461, 459, 'Service가 UI 없이 백그라운드 작업을 수행함을 설명', 'ESSENTIAL', 2),
(2462, 459, 'BroadcastReceiver가 시스템이나 다른 앱이 보내는 브로드캐스트 이벤트를 수신함을 설명', 'ESSENTIAL', 3),
(2463, 459, 'ContentProvider가 앱의 데이터를 다른 앱에 공개해 공유함을 설명', 'ESSENTIAL', 4),
(2464, 459, '액티비티는 백 스택(Back Stack)으로 관리되어 뒤로 가기 시 스택 상단이 제거됨을 언급', 'SUPPLEMENTARY', 5),
(2465, 459, 'ContentProvider는 content://authority/path 형태의 URI로 접근함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 460
(2466, 460, '안드로이드 앱에는 main() 같은 단일 진입점이 없음을 언급', 'ESSENTIAL', 1),
(2467, 460, '런처 인텐트(MAIN + LAUNCHER)를 받는 액티비티가 진입점 역할을 함을 언급', 'ESSENTIAL', 2),
(2468, 460, '브로드캐스트나 서비스 시작으로도 앱 프로세스가 생성될 수 있음을 언급', 'ESSENTIAL', 3),
(2469, 460, '매니페스트에 등록된 컴포넌트를 시스템이 직접 인스턴스화함을 언급', 'SUPPLEMENTARY', 4),
(2470, 460, '컴포넌트 간 통신은 객체 참조가 아니라 직렬화 가능한 인텐트 메시지로 이루어짐을 설명', 'SUPPLEMENTARY', 5);
