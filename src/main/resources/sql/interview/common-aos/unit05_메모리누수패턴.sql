-- Unit: 메모리 누수 패턴 (Unit ID: 96)
-- Chapter: AOS (Chapter ID: 8)
-- Topic: AOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-aos-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(476, 'AOS_COMMON', 96, 'HARD', true,
 '화면 회전을 반복할수록 앱 메모리가 계속 늘어난다는 리포트를 받았다면, 누수를 어떤 흐름으로 진단하고 어디를 고치겠습니까? WeakReference로 감싸는 방법의 한계도 함께 말씀해 주세요.',
 '회전할 때마다 액티비티가 재생성되므로, 누수가 있으면 회전할 때마다 액티비티 인스턴스가 하나씩 쌓여 메모리가 우상향합니다. 먼저 디버그 빌드에 LeakCanary를 적용해 둡니다. LeakCanary는 파괴된 Activity·Fragment·View·ViewModel을 WeakReference로 추적하다가 GC 후에도 남아 있으면 힙 덤프를 떠서 참조 체인(Leak Trace)을 자동으로 출력해 줍니다. 이어서 Android Studio Memory Profiler로 힙 덤프를 캡처해 클래스별 인스턴스 수와 Retained Size를 봅니다. 파괴됐어야 할 Activity 인스턴스가 2개 이상이면 누수로 확정하고, 파괴된 액티비티의 Retained Size가 수 MB라면 뷰 트리까지 누수된 것입니다. 그다음 ''GC 루트 → … → 누수 객체'' 경로를 역추적해 등록 해제나 null 처리처럼 끊어야 할 참조를 정합니다. 체인의 첫 앱 코드 지점이 수정 대상이고, 대부분 static 필드, 등록 해제 누락, 내부 클래스 중 하나입니다. WeakReference로 감싸면 누수 자체는 막을 수 있지만 참조가 언제 사라질지 예측하기 어렵고 코드가 복잡해지므로, 콜백을 받는 쪽을 직접 고칠 수 없을 때 쓰는 차선책입니다. 근본 해법은 수명이 맞는 스코프에 객체를 두는 것입니다. 수정 후에는 회전과 화면 진입·이탈을 반복하고 강제 GC를 실행해 인스턴스 수가 1로 유지되는지 재검증합니다. 참고로 LeakCanary는 debugImplementation으로만 추가해 릴리스 빌드에는 포함되지 않게 합니다.',
 'interview-question/476.mp3'),
(477, 'AOS_COMMON', 96, 'NORMAL', true,
 'Activity Context와 Application Context는 어떤 차이가 있고, 싱글턴에 Context를 보관해야 할 때는 어느 쪽을 써야 하나요?',
 '두 Context의 핵심 차이는 수명입니다. Application Context는 프로세스 전체와 수명이 같고, Activity Context는 액티비티 생명주기 동안만 유효합니다. Activity는 Context의 구현체이므로 액티비티 Context를 싱글턴이나 정적 필드에 넣으면, 오래 사는 싱글턴이 파괴된 액티비티를 계속 참조해 액티비티 전체와 그 뷰 계층까지 붙잡히는 누수가 생깁니다. 따라서 싱글턴, 라이브러리 초기화, DB·저장소처럼 오래 사는 객체에는 Application Context를 보관해야 하고, 예를 들어 init에서 context.applicationContext를 꺼내 저장하면 프로세스와 수명이 같아 누수가 아닙니다. 반대로 Application Context는 테마가 없어 다이얼로그 표시나 레이아웃 인플레이트에는 쓸 수 없으므로, 뷰 생성·다이얼로그·화면 전환처럼 테마가 필요한 UI 작업에는 Activity Context를 쓰되 오래 사는 객체에 저장하지 않습니다.',
 'interview-question/477.mp3'),
(478, 'AOS_COMMON', 96, 'NORMAL', true,
 '액티비티에서 네트워크 응답을 기다리는 작업을 일반 스레드로 실행할 때와 lifecycleScope·viewModelScope에서 실행할 때, 메모리 누수 관점에서 어떤 차이가 있나요?',
 '일반 스레드로 실행하면, 실행 중인 스레드 자체가 GC 루트이기 때문에 그 스레드가 액티비티를 참조하는 한 액티비티가 이미 파괴됐어도 네트워크 응답이 올 때까지 회수되지 않고 누수됩니다. 반면 lifecycleScope나 viewModelScope는 생명주기에 묶인 스코프라서 액티비티나 ViewModel이 끝나면 그 안의 작업이 자동으로 취소되어 액티비티를 붙잡지 않습니다. 같은 원리로 메인 루퍼 Handler에 지연 메시지를 걸어 두면 메인 루퍼에 매달린 MessageQueue가 메시지 실행 전까지 Runnable과 그 외부 참조를 붙잡으므로, onDestroy에서 removeCallbacksAndMessages로 제거하거나 lifecycleScope와 delay를 쓰는 것이 좋습니다.',
 'interview-question/478.mp3'),
(479, 'AOS_COMMON', 96, 'EASY', true,
 '안드로이드에서 메모리 누수란 무엇이며, 어떤 원리로 발생하나요?',
 '메모리 누수는 더 이상 필요 없는 객체가 어딘가에서 계속 참조되어 가비지 컬렉터가 회수하지 못하는 상태입니다. ART의 GC는 정적 변수, 실행 중인 스레드의 스택, JNI 참조 같은 GC 루트에서 도달 가능한 객체는 살아 있다고 판단합니다. 그래서 파괴된 액티비티가 GC 루트에서 이어지는 참조 체인 위에 놓이면 회수되지 않습니다. 안드로이드에서 누수는 항상 수명이 긴 객체가 수명이 짧은 객체를 참조할 때 생기며, 예를 들어 싱글턴이 액티비티를 참조하는 경우입니다. 액티비티 하나가 누수되면 그 액티비티가 붙잡은 뷰 계층, 어댑터, 비트맵, 리스너까지 전부 남기 때문에, 결국 OOM이나 잦은 GC로 인한 버벅임으로 이어집니다.',
 'interview-question/479.mp3'),
(480, 'AOS_COMMON', 96, 'EASY', true,
 '리스너나 콜백을 등록한 뒤 해제하지 않으면 왜 메모리 누수가 생기며, 이를 어떻게 막을 수 있나요?',
 '리스너나 콜백을 등록하면 등록을 받은 쪽, 예를 들어 LocationManager 같은 시스템 서비스나 이벤트 버스, 싱글턴이 그 콜백 객체를 보관합니다. 해제하지 않으면 이 오래 사는 객체가 콜백을 통해 액티비티를 계속 참조하게 되어 액티비티가 파괴된 뒤에도 회수되지 않습니다. 특히 콜백이 익명 클래스나 람다라면 외부 클래스인 액티비티에 대한 암묵적 참조가 포함되어 있습니다. 이를 막으려면 등록과 해제를 짝지어, onStart에서 requestLocationUpdates로 등록했다면 onStop에서 removeUpdates로 해제하는 식으로 대칭 콜백에서 반드시 해제해야 합니다. 같은 계열로 registerReceiver 후 unregisterReceiver 누락, SharedPreferences 리스너 unregister 누락, LiveData.observeForever 후 removeObserver 누락이 있고, 프래그먼트에서는 this 대신 viewLifecycleOwner로 옵저버를 등록해야 합니다.',
 'interview-question/480.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 476
(2553, 476, 'LeakCanary가 파괴된 Activity를 추적해 GC 후에도 남으면 참조 체인(Leak Trace)을 출력함을 설명', 'ESSENTIAL', 1),
(2554, 476, 'Memory Profiler 힙 덤프에서 Activity 인스턴스 수나 Retained Size로 누수를 확정하는 방법을 제시', 'ESSENTIAL', 2),
(2555, 476, 'GC 루트에서 누수 객체까지의 참조 체인을 역추적해 끊어야 할 참조를 정한다고 설명', 'ESSENTIAL', 3),
(2556, 476, 'WeakReference는 참조가 언제 사라질지 예측하기 어려워 차선책에 그친다고 언급', 'ESSENTIAL', 4),
(2557, 476, '근본 해법은 수명이 맞는 스코프에 객체를 두는 것임을 언급', 'SUPPLEMENTARY', 5),
(2558, 476, '수정 후 회전 반복과 강제 GC로 Activity 인스턴스 수가 1로 유지되는지 재검증한다고 언급', 'SUPPLEMENTARY', 6),
(2559, 476, 'LeakCanary는 debugImplementation으로만 추가해 릴리스 빌드에서 제외한다고 언급', 'SUPPLEMENTARY', 7),

-- 질문 477
(2560, 477, 'Application Context는 프로세스 전체, Activity Context는 액티비티 생명주기만큼 산다는 수명 차이를 설명', 'ESSENTIAL', 1),
(2561, 477, '싱글턴·정적 필드에는 Application Context를 보관해야 한다고 언급', 'ESSENTIAL', 2),
(2562, 477, '액티비티 Context를 싱글턴에 저장하면 액티비티 전체가 붙잡혀 누수된다고 설명', 'ESSENTIAL', 3),
(2563, 477, 'Application Context는 테마가 없어 다이얼로그·레이아웃 인플레이트에 쓸 수 없음을 언급', 'SUPPLEMENTARY', 4),
(2564, 477, 'context.applicationContext로 꺼내 보관하는 방식을 제시', 'SUPPLEMENTARY', 5),

-- 질문 478
(2565, 478, '실행 중인 스레드는 GC 루트라서 액티비티를 참조하면 응답이 올 때까지 누수된다고 설명', 'ESSENTIAL', 1),
(2566, 478, 'lifecycleScope·viewModelScope는 생명주기에 묶여 있어 작업이 자동 취소된다고 언급', 'ESSENTIAL', 2),
(2567, 478, 'Handler 지연 메시지도 메인 루퍼의 MessageQueue가 Runnable을 붙잡아 누수를 일으킨다고 언급', 'SUPPLEMENTARY', 3),

-- 질문 479
(2568, 479, '더 이상 필요 없는 객체가 계속 참조되어 GC가 회수하지 못하는 상태라고 서술', 'ESSENTIAL', 1),
(2569, 479, 'GC는 GC 루트에서 도달 가능한 객체를 살아 있다고 판단한다고 설명', 'ESSENTIAL', 2),
(2570, 479, '수명이 긴 객체가 수명이 짧은 객체를 참조할 때 누수가 생긴다고 언급', 'ESSENTIAL', 3),
(2571, 479, '정적 변수·실행 중인 스레드의 스택·JNI 참조 중 최소 1개를 GC 루트의 예로 제시', 'SUPPLEMENTARY', 4),
(2572, 479, '누수가 OOM이나 잦은 GC로 인한 버벅임으로 이어진다고 언급', 'SUPPLEMENTARY', 5),
(2573, 479, '액티비티가 누수되면 뷰 계층·비트맵·리스너까지 함께 남는다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 480
(2574, 480, '등록을 받은 시스템 서비스·싱글턴이 콜백을 통해 액티비티를 계속 참조한다고 설명', 'ESSENTIAL', 1),
(2575, 480, '등록한 리스너를 대칭 콜백(onStart–onStop 등)에서 반드시 해제해야 한다고 설명', 'ESSENTIAL', 2),
(2576, 480, '익명 클래스·람다 콜백이 외부 액티비티에 대한 암묵적 참조를 포함한다고 언급', 'SUPPLEMENTARY', 3),
(2577, 480, 'registerReceiver·SharedPreferences 리스너·observeForever 중 최소 1개의 해제 누락 사례를 제시', 'SUPPLEMENTARY', 4),
(2578, 480, '프래그먼트에서는 this 대신 viewLifecycleOwner로 옵저버를 등록해야 한다고 언급', 'SUPPLEMENTARY', 5);
