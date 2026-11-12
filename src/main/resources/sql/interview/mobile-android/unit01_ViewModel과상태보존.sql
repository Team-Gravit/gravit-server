-- Unit: ViewModel과 상태 보존 (Unit ID: 167)
-- Chapter: Android (Chapter ID: 16)
-- Topic: COMPOSE
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-android-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(831, 'COMPOSE', 167, 'HARD', true,
 'ViewModel에서 Context가 필요하다는 이유로 Activity를 필드로 보관했다면 어떤 문제가 생기고, Context 사용과 비동기 작업은 어떻게 안전하게 처리해야 하나요?',
 'ViewModel은 화면보다 오래 살아남는 컴포넌트라서 Activity·View·Context를 필드로 잡으면 안 됩니다. 화면 회전 같은 구성 변경에서 Activity는 새로 만들어지지만 ViewModel은 유지되기 때문에, 필드에 담아 둔 옛 Activity를 계속 붙들게 되어 메모리 누수가 생깁니다. 앱 전역 Context가 꼭 필요하다면 AndroidViewModel을 쓰거나 Hilt의 @ApplicationContext를 주입받아 사용합니다. 비동기 작업은 viewModelScope에서 시작하는 것이 안전합니다. viewModelScope는 ViewModel이 폐기되는 onCleared() 시점에 자동으로 취소되는 코루틴 스코프이므로, 죽은 화면을 갱신하려는 작업이 남지 않습니다. 참고로 생성자 인자가 있는 ViewModel은 ViewModelProvider.Factory가 필요하고 실무에서는 @HiltViewModel로 이를 대체합니다. 또한 ViewModel은 UI 상태의 보관소이지 영속 저장소가 아니므로, 앱을 껐다 켜도 남아야 하는 데이터는 Room·DataStore 같은 영속 계층에 둡니다.',
 'interview-question/831.mp3'),
(832, 'COMPOSE', 167, 'NORMAL', true,
 '화면 회전과 백그라운드 프로세스 종료 상황에서 ViewModel과 SavedStateHandle의 상태 보존은 각각 어떻게 다른가요?',
 '화면 회전 같은 구성 변경에서는 Activity가 재생성되지만 ViewModel은 그대로 유지되므로 ViewModel만으로 충분합니다. 반면 앱이 백그라운드에 있을 때 시스템이 메모리 확보를 위해 프로세스를 종료하면 ViewModel도 메모리와 함께 사라지고, 사용자가 돌아왔을 때 ViewModel은 초기 상태로 새로 생성됩니다. 이 경우를 대비하는 것이 SavedStateHandle입니다. SavedStateHandle은 onSaveInstanceState() 메커니즘을 ViewModel에서 쓸 수 있게 감싼 것으로, 프로세스 종료 후 복원 시 Bundle에서 값이 복원됩니다. 다만 Bundle은 전송 한도를 넘으면 TransactionTooLargeException이 발생하므로 목록 전체가 아니라 검색어·스크롤 위치 같은 소량의 복원 키만 저장하고 데이터는 다시 불러오는 것이 원칙입니다. 회전 테스트만으로는 이 누락을 잡을 수 없으니 개발자 옵션의 ''액티비티 유지 안 함''을 켜서 프로세스 종료 후 복원 시나리오를 재현해 확인합니다.',
 'interview-question/832.mp3'),
(833, 'COMPOSE', 167, 'NORMAL', true,
 'Fragment에서 viewModels()와 activityViewModels()로 ViewModel을 얻을 때 어떤 차이가 있나요?',
 '둘의 차이는 ViewModel의 소유자, 즉 수명 범위입니다. Fragment에서 viewModels()를 쓰면 Fragment 단위로 ViewModel이 만들어지고, Fragment가 백스택에서 제거될 때 함께 폐기됩니다. activityViewModels()를 쓰면 Activity 수명에 맞춰 ViewModel이 유지되고, 같은 Activity에 속한 여러 Fragment가 하나의 ViewModel을 공유합니다. 그래서 두 Fragment가 데이터를 공유해야 하는데 각자 viewModels()를 쓰면 서로 다른 인스턴스를 받게 되어 공유가 되지 않는 함정이 생깁니다.',
 'interview-question/833.mp3'),
(834, 'COMPOSE', 167, 'EASY', true,
 '안드로이드에서 ViewModel이 필요한 이유를 화면 회전 상황을 예로 들어 설명해 주세요.',
 'Activity는 화면 회전·언어 변경·다크 모드 전환 같은 구성 변경이 일어나면 파괴된 뒤 재생성됩니다. Activity 인스턴스가 새로 만들어지기 때문에 멤버 변수에 담아 둔 목록·입력값·네트워크 결과는 재생성과 함께 모두 사라집니다. 이를 매번 다시 요청하면 네트워크 낭비와 깜빡임이 생기고, 진행 중이던 비동기 작업은 이미 죽은 Activity를 참조해 메모리 누수나 크래시로 이어질 수 있습니다. 그래서 Activity 인스턴스와 무관한 보관소가 필요하고, 그것이 ViewModel입니다. ViewModel은 화면보다 오래 살아남아 UI 상태를 보관하므로 구성 변경으로 Activity가 재생성된 뒤에도 ViewModel이 유지되어 UI 상태가 그대로 남습니다. 즉 ViewModel은 UI 컨트롤러와 데이터 보관·비즈니스 로직을 분리해 이 문제를 구조적으로 해결합니다.',
 'interview-question/834.mp3'),
(835, 'COMPOSE', 167, 'EASY', true,
 '화면 회전 같은 구성 변경이 일어났을 때 ViewModel이 유지되는 동작 원리를 설명해 주세요.',
 'ViewModel은 ViewModelStore라는 맵에 보관되고, 이 저장소를 가진 Activity·Fragment·NavBackStackEntry 같은 객체를 ViewModelStoreOwner라고 부릅니다. 화면을 회전하면 시스템은 Activity를 새로 만들지만, ViewModelStore는 NonConfigurationInstance로 보관했다가 새 Activity 인스턴스에 그대로 넘겨줍니다. 그래서 새 Activity가 by viewModels()로 같은 키로 요청하면 기존 ViewModel을 돌려받고, StateFlow의 현재 값을 바로 수집해 네트워크 재요청 없이 UI를 복원합니다. ViewModel은 소유자가 뒤로 가기나 finish()로 완전히 종료될 때만 onCleared()가 호출되고 폐기됩니다.',
 'interview-question/835.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 831
(4477, 831, 'ViewModel이 Activity보다 오래 살아 회전 뒤에도 옛 Activity를 붙들어 메모리 누수가 생김을 설명', 'ESSENTIAL', 1),
(4478, 831, '앱 전역 Context가 필요하면 AndroidViewModel 또는 @ApplicationContext를 사용함을 언급', 'ESSENTIAL', 2),
(4479, 831, 'viewModelScope의 코루틴이 onCleared() 시점에 자동 취소됨을 언급', 'ESSENTIAL', 3),
(4480, 831, '생성자 인자가 있으면 ViewModelProvider.Factory나 Hilt의 @HiltViewModel이 필요함을 언급', 'SUPPLEMENTARY', 4),
(4481, 831, 'ViewModel은 영속 저장소가 아니라 UI 상태의 보관소임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 832
(4482, 832, '화면 회전 시 ViewModel이 유지되어 ViewModel만으로 상태 보존이 충분함을 언급', 'ESSENTIAL', 1),
(4483, 832, '백그라운드 프로세스 종료 시 ViewModel이 초기 상태로 새로 생성됨을 언급', 'ESSENTIAL', 2),
(4484, 832, '프로세스 종료 후 복원 시 SavedStateHandle 값은 Bundle에서 복원됨을 언급', 'ESSENTIAL', 3),
(4485, 832, 'SavedStateHandle에는 검색어·스크롤 위치 같은 소량의 복원 키만 저장함을 언급', 'SUPPLEMENTARY', 4),
(4486, 832, '큰 데이터를 Bundle에 넣으면 TransactionTooLargeException이 발생함을 언급', 'SUPPLEMENTARY', 5),
(4487, 832, '개발자 옵션 ''액티비티 유지 안 함''으로 프로세스 종료 복원을 재현함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 833
(4488, 833, 'viewModels()로 얻은 ViewModel은 Fragment가 백스택에서 제거될 때 폐기됨을 언급', 'ESSENTIAL', 1),
(4489, 833, 'activityViewModels()로 얻은 ViewModel은 Activity 수명에 맞춰 유지됨을 언급', 'ESSENTIAL', 2),
(4490, 833, 'activityViewModels()를 쓰면 여러 Fragment가 하나의 ViewModel을 공유함을 언급', 'ESSENTIAL', 3),
(4491, 833, '두 Fragment가 각자 viewModels()를 쓰면 서로 다른 인스턴스를 받음을 언급', 'SUPPLEMENTARY', 4),

-- 질문 834
(4492, 834, '화면 회전 같은 구성 변경 시 Activity가 파괴 후 재생성됨을 언급', 'ESSENTIAL', 1),
(4493, 834, 'Activity 멤버 변수에 담아 둔 데이터가 재생성과 함께 사라짐을 언급', 'ESSENTIAL', 2),
(4494, 834, 'ViewModel이 Activity 인스턴스와 무관한 보관소라 재생성 후에도 UI 상태가 유지됨을 언급', 'ESSENTIAL', 3),
(4495, 834, 'ViewModel이 UI 컨트롤러에서 데이터 보관 책임을 분리함을 언급', 'SUPPLEMENTARY', 4),
(4496, 834, '매번 다시 요청하면 네트워크 낭비와 깜빡임이 생김을 언급', 'SUPPLEMENTARY', 5),
(4497, 834, '진행 중인 비동기 작업이 죽은 Activity를 참조해 메모리 누수나 크래시로 이어짐을 언급', 'SUPPLEMENTARY', 6),

-- 질문 835
(4498, 835, 'ViewModel이 ViewModelStoreOwner가 가진 ViewModelStore에 보관됨을 언급', 'ESSENTIAL', 1),
(4499, 835, '구성 변경 시 ViewModelStore가 새 Activity 인스턴스에 그대로 넘겨짐을 언급', 'ESSENTIAL', 2),
(4500, 835, '새 Activity가 같은 키로 요청하면 기존 ViewModel을 돌려받음을 언급', 'ESSENTIAL', 3),
(4501, 835, '소유자가 완전히 종료될 때만 onCleared()가 호출되고 ViewModel이 폐기됨을 언급', 'SUPPLEMENTARY', 4),
(4502, 835, '회전 중 ViewModelStore가 NonConfigurationInstance로 보관됨을 언급', 'SUPPLEMENTARY', 5);
