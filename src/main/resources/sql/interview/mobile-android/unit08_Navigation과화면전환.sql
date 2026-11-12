-- Unit: Navigation과 화면 전환 (Unit ID: 174)
-- Chapter: Android (Chapter ID: 16)
-- Topic: COMPOSE
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-android-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(866, 'COMPOSE', 174, 'HARD', true,
 '회원가입이 3단계 화면으로 나뉘어 있고 단계 간 입력값을 공유해야 하며, 가입 완료 후 뒤로 가기를 눌러도 가입 화면으로 돌아가면 안 됩니다. Navigation을 어떻게 구성하시겠으며, 이때 주의할 점은 무엇인가요?',
 '관련된 가입 1·2·3단계 화면을 navigation<SignUpGraph>로 하나의 중첩 그래프로 묶겠습니다. 이렇게 하면 외부에서는 그래프 하나로 진입하고, 그래프 단위로 popUpTo를 할 수 있습니다. 단계 간 입력값 공유는 각 단계에서 navController.getBackStackEntry<SignUpGraph>()로 그래프의 NavBackStackEntry를 얻고, 이를 소유자로 hiltViewModel(parentEntry)를 호출해 여러 단계가 하나의 그래프 스코프 ViewModel을 공유하게 합니다. 이 ViewModel은 그래프를 벗어나면 함께 폐기됩니다. 가입이 완료되면 navigate로 다음 화면으로 이동하면서 popUpTo로 가입 그래프를 지정하고 inclusive = true를 주어 가입 그래프 자신까지 백스택에서 제거합니다. 그러면 뒤로 가기를 눌러도 가입 화면으로 돌아갈 수 없습니다. 주의할 점은 getBackStackEntry<SignUpGraph>()가 해당 그래프가 현재 백스택에 없으면 IllegalArgumentException을 던진다는 것입니다. 따라서 그래프 밖의 화면에서 그래프 스코프 ViewModel을 얻으려 하면 안 되고, 그래프 안에서도 remember(entry)로 감싸 재구성마다 재조회하지 않도록 해야 합니다.',
 'interview-question/866.mp3'),
(867, 'COMPOSE', 174, 'NORMAL', true,
 'Navigation에서 navigate 옵션인 popUpTo와 launchSingleTop은 각각 어떤 동작을 하며, 어떤 상황에서 사용하나요?',
 'popUpTo는 navigate 시 지정한 목적지까지 백스택을 걷어낸 뒤 새 목적지를 쌓는 옵션입니다. inclusive = true를 주면 popUpTo 대상 자신까지 제거됩니다. 그래서 로그인이나 온보딩 완료, 결제 같은 플로우 종료 후 뒤로 가기로 이전 화면에 돌아가면 안 될 때 사용합니다. 예를 들어 로그인 성공 시 navigate(Home) { popUpTo<Login> { inclusive = true } }로 로그인 화면을 스택에서 제거합니다. launchSingleTop은 현재 맨 위 목적지와 같은 목적지로 이동할 때 새 항목을 쌓지 않고 기존 항목을 재사용하는 옵션입니다. 버튼 연타로 같은 화면이 여러 장 쌓이거나 하단 탭을 반복 터치할 때 스택이 늘어나는 문제를 막을 때 사용합니다. 하단 탭 이동에서는 popUpTo(시작 목적지) { saveState = true }, launchSingleTop = true, restoreState = true를 함께 쓰는 것이 관용구입니다.',
 'interview-question/867.mp3'),
(868, 'COMPOSE', 174, 'NORMAL', true,
 'Navigation에서 명시적 딥링크와 암시적 딥링크는 어떻게 다른가요?',
 '딥링크는 브라우저·알림·다른 앱 같은 외부에서 URI로 앱의 특정 화면을 직접 여는 기능이고, 목적지에 navDeepLink를 선언하면 NavController가 URI의 경로·쿼리를 인자로 매핑해 줍니다. 명시적 딥링크는 알림 클릭처럼 앱 내부에서 PendingIntent로 만드는 딥링크입니다. 시작 목적지부터 합성된 백스택 위에 목적지를 쌓기 때문에 뒤로 가기가 자연스럽게 동작합니다. 반면 암시적 딥링크는 외부 URI로 열리는 딥링크로, AndroidManifest.xml에 <intent-filter>가 있어야 시스템이 앱을 후보로 띄웁니다. 웹 도메인 소유를 검증한 Android App Links를 쓰면 확인 대화상자 없이 바로 열립니다. 어느 쪽이든 딥링크로 들어온 인자는 사용자가 조작할 수 있는 외부 입력이므로, 권한이 필요한 화면을 검증 없이 그대로 열면 안 되고 인증·인가 확인은 화면이 아니라 데이터 계층에서 수행해야 합니다.',
 'interview-question/868.mp3'),
(869, 'COMPOSE', 174, 'EASY', true,
 'Navigation 컴포넌트를 구성하는 NavHost, NavController, NavBackStackEntry는 각각 어떤 역할을 하나요?',
 'Navigation 컴포넌트는 화면 이동을 그래프와 백스택으로 모델링합니다. NavGraph는 앱의 모든 목적지와 이동 경로의 집합입니다. NavHost는 현재 목적지를 화면에 표시하는 컨테이너로, Compose에서는 NavHost(navController, startDestination) 형태로 씁니다. NavController는 이동 명령을 받고 백스택을 관리하는 중심 객체로, rememberNavController()로 얻습니다. navigate()를 호출하면 목적지가 백스택 위에 쌓이고, 뒤로 가기나 popBackStack()을 하면 맨 위가 제거됩니다. NavBackStackEntry는 백스택의 한 항목으로 인자와 SavedStateHandle, ViewModelStoreOwner를 가집니다. 각 NavBackStackEntry가 자체 ViewModelStore를 가지므로 hiltViewModel()로 얻은 ViewModel은 해당 화면이 백스택에서 제거될 때 폐기됩니다.',
 'interview-question/869.mp3'),
(870, 'COMPOSE', 174, 'EASY', true,
 'Navigation에서 화면 간 인자를 타입 안전하게 전달하는 방법과, 인자로 어떤 값을 넘겨야 하는지 설명해 주세요.',
 'Navigation 2.8.0 이후로는 "product/{id}" 같은 문자열 경로 대신 @Serializable 클래스로 목적지를 정의하는 타입 안전 방식이 권장됩니다. 예를 들어 @Serializable data class ProductDetail(val id: Long)로 목적지를 정의하고 navController.navigate(ProductDetail(id))로 이동합니다. 목적지에서는 backStackEntry.toRoute<ProductDetail>()로 인자를 타입 안전하게 복원하고, 인자는 SavedStateHandle에도 들어오므로 ViewModel이 savedStateHandle.toRoute<ProductDetail>()로 직접 읽을 수 있어 UI가 인자를 다시 넘길 필요가 없습니다. 인자로는 ID 같은 작은 값만 전달해야 합니다. 객체 전체를 넘기면 저장 상태(Bundle) 크기 제한에 걸리고, 원본이 갱신돼도 목적지는 옛 복사본을 보게 됩니다. 그래서 목적지는 전달받은 ID로 저장소에서 다시 조회하는 것이 원칙입니다.',
 'interview-question/870.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 866
(4664, 866, '가입 단계 화면들을 navigation<SignUpGraph> 같은 중첩 그래프로 묶는 구성을 제시', 'ESSENTIAL', 1),
(4665, 866, '그래프의 NavBackStackEntry를 소유자로 hiltViewModel을 얻어 여러 단계가 하나의 ViewModel을 공유함을 설명', 'ESSENTIAL', 2),
(4666, 866, '가입 완료 시 popUpTo로 가입 그래프를 inclusive = true와 함께 백스택에서 제거함을 설명', 'ESSENTIAL', 3),
(4667, 866, '그래프가 현재 백스택에 없으면 getBackStackEntry가 IllegalArgumentException을 던짐을 언급', 'ESSENTIAL', 4),
(4668, 866, '그래프를 벗어나면 그래프 스코프 ViewModel도 함께 폐기됨을 언급', 'SUPPLEMENTARY', 5),
(4669, 866, 'getBackStackEntry 호출을 remember(entry)로 감싸 재구성마다 재조회하지 않도록 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 867
(4670, 867, 'popUpTo는 지정한 목적지까지 백스택을 걷어낸 뒤 새 목적지를 쌓음을 설명', 'ESSENTIAL', 1),
(4671, 867, 'launchSingleTop은 맨 위와 같은 목적지로 이동하면 새 항목 대신 기존 항목을 재사용함을 설명', 'ESSENTIAL', 2),
(4672, 867, 'popUpTo의 사용 상황으로 로그인·온보딩 완료·플로우 종료 중 최소 1개를 제시', 'ESSENTIAL', 3),
(4673, 867, 'launchSingleTop의 사용 상황으로 버튼 연타·탭 반복 터치 중 최소 1개를 제시', 'ESSENTIAL', 4),
(4674, 867, 'inclusive = true면 popUpTo 대상 목적지 자신까지 제거됨을 언급', 'SUPPLEMENTARY', 5),
(4675, 867, '하단 탭 이동 시 popUpTo·launchSingleTop에 saveState/restoreState를 함께 쓰는 관용구를 언급', 'SUPPLEMENTARY', 6),

-- 질문 868
(4676, 868, '암시적 딥링크와 대비되는 쪽은 앱 내부에서 PendingIntent로 만드는 딥링크임을 설명', 'ESSENTIAL', 1),
(4677, 868, 'PendingIntent로 만든 딥링크는 시작 목적지부터 합성된 백스택 위에 목적지를 쌓아 뒤로 가기가 자연스러움을 설명', 'ESSENTIAL', 2),
(4678, 868, '암시적 딥링크는 AndroidManifest.xml의 intent-filter가 필요함을 언급', 'ESSENTIAL', 3),
(4679, 868, '암시적 딥링크에 웹 도메인 소유를 검증한 App Links를 쓰면 확인 대화상자 없이 바로 열림을 언급', 'SUPPLEMENTARY', 4),
(4680, 868, 'navDeepLink를 선언하면 NavController가 URI의 경로·쿼리를 인자로 매핑함을 언급', 'SUPPLEMENTARY', 5),
(4681, 868, '딥링크로 들어온 URI 인자는 사용자가 조작할 수 있는 외부 입력으로 취급해야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 869
(4682, 869, 'NavController가 이동 명령을 받고 백스택을 관리하는 중심 객체임을 설명', 'ESSENTIAL', 1),
(4683, 869, 'NavHost가 현재 목적지를 화면에 표시하는 컨테이너임을 설명', 'ESSENTIAL', 2),
(4684, 869, 'NavBackStackEntry가 인자와 SavedStateHandle을 가진 백스택의 한 항목임을 설명', 'ESSENTIAL', 3),
(4685, 869, 'NavBackStackEntry마다 ViewModelStore가 있어 화면이 백스택에서 제거될 때 ViewModel이 폐기됨을 언급', 'SUPPLEMENTARY', 4),
(4686, 869, 'NavGraph가 앱의 모든 목적지와 이동 경로의 집합임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 870
(4687, 870, '문자열 경로 대신 @Serializable 클래스로 목적지를 정의하는 방식을 제시', 'ESSENTIAL', 1),
(4688, 870, 'toRoute()로 백스택 항목이나 SavedStateHandle에서 인자를 복원함을 언급', 'ESSENTIAL', 2),
(4689, 870, '인자로는 객체 전체가 아니라 ID 같은 작은 값만 전달해야 함을 언급', 'ESSENTIAL', 3),
(4690, 870, '객체 전체 전달 시 Bundle 크기 제한·옛 복사본 참조 문제 중 최소 1개를 제시', 'SUPPLEMENTARY', 4),
(4691, 870, '목적지는 전달받은 ID로 저장소에서 다시 조회함을 언급', 'SUPPLEMENTARY', 5),
(4692, 870, '타입 안전 경로 방식이 Navigation 2.8.0 이후 권장됨을 언급', 'SUPPLEMENTARY', 6);
