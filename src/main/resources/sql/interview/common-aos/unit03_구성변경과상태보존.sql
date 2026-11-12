-- Unit: 구성 변경과 상태 보존 (Unit ID: 94)
-- Chapter: AOS (Chapter ID: 8)
-- Topic: AOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-aos-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(466, 'AOS_COMMON', 94, 'HARD', true,
 '화면 회전 시 데이터가 사라지는 문제를 android:screenOrientation 고정이나 android:configChanges 선언으로 해결하려고 할 때, 이 접근이 실패하는 상황과 근본적인 대안은 무엇인가요?',
 '화면 방향을 portrait로 고정해도 구성 변경은 회전만 있는 것이 아니어서, 다크 모드 전환·언어 변경·폴더블 펼침에서는 똑같이 액티비티가 재생성됩니다. android:configChanges를 선언하면 선언한 변경에 대해서는 재생성 대신 onConfigurationChanged()만 호출되지만, 가로 레이아웃이나 야간 색상 같은 리소스 한정자가 자동 적용되지 않으므로 개발자가 직접 뷰를 갱신해야 하고, 선언하지 않은 구성 변경에서는 여전히 재생성됩니다. 또한 configChanges로는 시스템에 의한 프로세스 종료를 막을 수 없으므로 어차피 그에 대비해야 합니다. 그래서 configChanges는 비디오 플레이어·카메라 프리뷰·WebView처럼 재생성 비용이 매우 큰 특수 화면에서만 제한적으로 쓰고, 근본 해결은 상태를 액티비티 밖에 두는 것입니다. 즉 상태를 수명과 크기에 따라 savedInstanceState, ViewModel(필요 시 SavedStateHandle), 영속 저장소로 계층화해 보존합니다.',
 'interview-question/466.mp3'),
(467, 'AOS_COMMON', 94, 'NORMAL', true,
 'savedInstanceState와 ViewModel은 상태 보존 측면에서 어떤 차이가 있고, 각각 어떤 데이터를 담아야 하나요?',
 '둘 다 구성 변경에서는 상태를 유지하지만, 시스템에 의한 프로세스 종료에서 차이가 납니다. savedInstanceState는 시스템이 Bundle을 대신 들고 있기 때문에 프로세스가 종료된 뒤에도 복원됩니다. 반면 ViewModel은 메모리에만 존재하므로 프로세스가 종료되면 사라집니다. 그래서 담는 데이터도 다릅니다. savedInstanceState에는 스크롤 위치, 입력 중인 텍스트, 선택 ID처럼 재조회의 열쇠가 되는 소량 값만 넣고, ViewModel에는 네트워크 응답, 목록 데이터, 화면 로직 상태를 담습니다. savedInstanceState의 데이터는 직렬화되어 Binder IPC로 시스템 프로세스에 전달되므로 크기가 크면 TransactionTooLargeException이 발생하고, 실무 상한은 수십 KB 수준입니다. 큰 데이터는 저장소에서 다시 읽습니다. ViewModel 상태 중 복원이 꼭 필요한 값은 SavedStateHandle을 쓰면 savedInstanceState 메커니즘을 ViewModel 안으로 끌어와 프로세스 종료 후에도 복원할 수 있습니다.',
 'interview-question/467.mp3'),
(468, 'AOS_COMMON', 94, 'NORMAL', true,
 '시스템이 프로세스를 종료한 경우와 사용자가 직접 앱을 종료한 경우 savedInstanceState 복원은 어떻게 다르며, 앱을 다시 켜도 남아야 하는 데이터는 어디에 저장해야 하나요?',
 '시스템에 의해 프로세스가 종료된 경우에는 시스템이 Bundle을 대신 들고 있기 때문에, 프로세스가 죽었더라도 다시 진입하면 savedInstanceState로 상태가 복원됩니다. 하지만 사용자가 뒤로 가기나 finish()로 직접 종료하거나 최근 앱 화면에서 스와이프해 종료하면 새 시작으로 취급되어 savedInstanceState는 복원되지 않습니다. ViewModel 역시 사용자가 종료하면 유실됩니다. 따라서 사용자 설정, 로그인 토큰, 작성 중인 글의 임시 저장본처럼 앱을 껐다 켜도 필요한 데이터는 DataStore, Room, 파일 같은 영속 저장소에 저장해야 하며, 이 계층은 구성 변경이나 종료 방식과 무관하게 항상 유지됩니다.',
 'interview-question/468.mp3'),
(469, 'AOS_COMMON', 94, 'EASY', true,
 '안드로이드에서 구성 변경이란 무엇이며, 구성 변경이 일어나면 액티비티는 어떻게 되나요?',
 '구성(Configuration)은 화면 방향·크기·밀도, 로케일, 글꼴 크기, 다크 모드, 키보드 상태처럼 리소스 선택에 영향을 주는 기기 환경의 집합이고, 이것이 바뀌는 것을 구성 변경이라고 합니다. 화면 회전, 다크 모드 전환, 언어 변경, 글꼴 크기 변경, 멀티윈도우·폴더블, 키보드 연결 등이 원인입니다. 구성 변경이 일어나면 시스템은 기본적으로 액티비티를 파괴하고 다시 생성합니다. 구성이 바뀌면 values-land, values-ko, values-night처럼 다른 리소스 세트가 적용되어야 하므로, 가장 확실한 방법인 재생성을 택하는 것입니다. 이때 액티비티 인스턴스와 멤버 변수는 모두 사라지지만, android:id가 있는 뷰의 EditText 텍스트나 스크롤 위치 같은 일부 뷰 상태는 시스템이 자동으로 저장·복원합니다.',
 'interview-question/469.mp3'),
(470, 'AOS_COMMON', 94, 'EASY', true,
 'ViewModel이 화면 회전 후에도 데이터를 유지할 수 있는 원리와, ViewModel을 사용할 때 주의할 점을 설명해 주세요.',
 'ViewModel은 액티비티·프래그먼트의 ViewModelStore에 보관되어 있어서, 화면 회전으로 액티비티가 재생성되면 새 액티비티 인스턴스에 다시 연결됩니다. 즉 구성 변경 시 ViewModel은 파괴되지 않고 같은 인스턴스가 재사용되므로 네트워크 응답이나 목록 데이터가 유지됩니다. onCleared()도 회전으로 재생성될 때는 호출되지 않고 액티비티가 finish로 완전히 끝날 때만 호출됩니다. 주의할 점은 ViewModel이 액티비티보다 오래 살기 때문에, ViewModel에 액티비티 Context나 뷰를 넣으면 파괴된 액티비티가 GC되지 못하는 메모리 누수가 된다는 것입니다. Context가 꼭 필요하면 AndroidViewModel의 Application Context를 사용합니다.',
 'interview-question/470.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 466
(2496, 466, '화면 방향을 고정해도 다크 모드·언어 변경·폴더블 펼침 중 최소 1개에서 여전히 재생성됨을 언급', 'ESSENTIAL', 1),
(2497, 466, 'configChanges를 선언해도 시스템에 의한 프로세스 종료는 막을 수 없음을 언급', 'ESSENTIAL', 2),
(2498, 466, 'configChanges 선언 시 리소스 한정자가 자동 적용되지 않아 개발자가 직접 뷰를 갱신해야 함을 설명', 'ESSENTIAL', 3),
(2499, 466, '근본 해결은 상태를 액티비티 밖에 두는 것임을 명시', 'ESSENTIAL', 4),
(2500, 466, '비디오 플레이어·카메라 프리뷰·WebView 중 최소 1개를 configChanges가 적합한 화면으로 제시', 'SUPPLEMENTARY', 5),
(2501, 466, 'savedInstanceState·ViewModel·영속 저장소 중 최소 2개를 상태 보존 계층으로 제시', 'SUPPLEMENTARY', 6),

-- 질문 467
(2502, 467, 'savedInstanceState는 시스템에 의한 프로세스 종료 후에도 복원됨을 언급', 'ESSENTIAL', 1),
(2503, 467, 'ViewModel은 메모리에만 존재해 프로세스 종료 시 유실됨을 언급', 'ESSENTIAL', 2),
(2504, 467, '스크롤 위치·입력 중인 텍스트·선택 ID 중 최소 1개를 savedInstanceState에 담을 데이터로 제시', 'ESSENTIAL', 3),
(2505, 467, '네트워크 응답·목록 데이터·화면 로직 상태 중 최소 1개를 ViewModel에 담을 데이터로 제시', 'ESSENTIAL', 4),
(2506, 467, 'savedInstanceState의 실무 크기 상한이 수십 KB 수준임을 언급', 'SUPPLEMENTARY', 5),
(2507, 467, 'Bundle 크기가 크면 TransactionTooLargeException이 발생함을 언급', 'SUPPLEMENTARY', 6),
(2508, 467, 'SavedStateHandle이 ViewModel 상태를 프로세스 종료 후에도 복원하게 해줌을 설명', 'SUPPLEMENTARY', 7),

-- 질문 468
(2509, 468, '시스템이 프로세스를 종료한 경우 재진입 시 savedInstanceState가 복원됨을 언급', 'ESSENTIAL', 1),
(2510, 468, '사용자가 직접 앱을 종료하면 savedInstanceState가 복원되지 않음을 언급', 'ESSENTIAL', 2),
(2511, 468, '앱 재시작 후에도 필요한 데이터는 DataStore·Room·파일 중 최소 1개에 저장함을 제시', 'ESSENTIAL', 3),
(2512, 468, '시스템이 Bundle을 대신 보관하기 때문에 프로세스가 죽어도 복원된다는 이유를 설명', 'SUPPLEMENTARY', 4),
(2513, 468, '사용자 설정·로그인 토큰·임시 저장 초안 중 최소 1개를 영속 저장소 대상 데이터로 제시', 'SUPPLEMENTARY', 5),
(2514, 468, '사용자가 직접 종료한 경우는 새 시작으로 취급됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 469
(2515, 469, '화면 회전·다크 모드 전환·언어 변경·글꼴 크기 변경 중 최소 2개를 구성 변경 원인으로 제시', 'ESSENTIAL', 1),
(2516, 469, '구성 변경 시 시스템이 액티비티를 파괴하고 다시 생성함을 언급', 'ESSENTIAL', 2),
(2517, 469, '재생성하는 이유가 바뀐 구성에 맞는 다른 리소스 세트를 적용하기 위해서임을 설명', 'ESSENTIAL', 3),
(2518, 469, '재생성되면 액티비티의 멤버 변수가 모두 사라짐을 언급', 'SUPPLEMENTARY', 4),
(2519, 469, 'android:id가 있는 뷰는 시스템이 텍스트·스크롤 위치 등을 자동 저장·복원함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 470
(2520, 470, 'ViewModel이 ViewModelStore에 보관되어 새 액티비티 인스턴스에 재연결됨을 설명', 'ESSENTIAL', 1),
(2521, 470, '회전으로 재생성될 때 ViewModel은 파괴되지 않고 같은 인스턴스가 재사용됨을 언급', 'ESSENTIAL', 2),
(2522, 470, 'ViewModel이 액티비티 Context나 뷰를 참조하면 메모리 누수가 발생함을 언급', 'ESSENTIAL', 3),
(2523, 470, 'onCleared()는 액티비티가 finish로 완전히 끝날 때만 호출됨을 언급', 'SUPPLEMENTARY', 4),
(2524, 470, 'Context가 필요하면 AndroidViewModel의 Application Context를 사용함을 제시', 'SUPPLEMENTARY', 5);
