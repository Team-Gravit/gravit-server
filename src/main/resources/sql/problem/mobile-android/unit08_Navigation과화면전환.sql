-- Unit: Navigation과 화면 전환 (Unit ID: 174)
-- Chapter: Android (Chapter ID: 16)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (600, 174, 'popUpTo 백스택과 탭 상태 복원'),
       (758, 174, '인자 전달과 중복 이동 방지'),
       (916, 174, 'Navigation 백스택 운용과 화면 간 데이터 전달');

-- =====================================================
-- Lesson 600: popUpTo 백스택과 탭 상태 복원
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3779, 600, '아래 코드를 순서대로 실행한 뒤 백스택의 상태로 옳은 것은?', '```kotlin
// 현재 백스택 (바닥부터): Home, Search, ProductList
navController.navigate(ProductDetail(42))

navController.navigate(Cart) {
    popUpTo<Search> { inclusive = true }
}

navController.navigate(Cart) {
    launchSingleTop = true
}
```', 'OBJECTIVE'),
       (3780, 600, '아래 탭 이동 코드에서 두 증상이 나타난 원인으로 옳은 것은?', '```kotlin
// 하단 탭 Home / Search / Profile 을 오갈 때 쓰는 이동 함수
fun NavHostController.navigateToTab(route: Any) = navigate(route) {
    launchSingleTop = true
}
```

- 증상 1: Home 탭에서 목록을 한참 내린 뒤 Search 탭에 갔다가 Home으로 돌아오면 목록이 맨 위로 되돌아간다.
- 증상 2: 탭을 15번 오간 뒤 뒤로 가기를 누르자 지나온 탭 화면이 하나씩 다시 나타났다.', 'OBJECTIVE'),
       (3781, 600, '아래 설정으로 브라우저의 링크를 눌러 화면을 여는 방식에 대한 설명으로 옳지 않은 것은?', '```kotlin
composable<ProductDetail>(
    deepLinks = listOf(
        navDeepLink<ProductDetail>(basePath = "https://example.com/product"),
    ),
) { entry -> ProductDetailRoute(productId = entry.toRoute<ProductDetail>().id) }
```

```xml
<activity android:name=".MainActivity" android:exported="true">
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https" android:host="example.com" android:pathPrefix="/product" />
    </intent-filter>
</activity>
```', 'OBJECTIVE'),
       (3782, 600, '아래 코드에서 sharedViewModel 인스턴스가 유지되는 범위로 옳은 것은?', '```kotlin
navigation<SignUpGraph>(startDestination = SignUpStep1) {
    composable<SignUpStep1> { entry ->
        val parentEntry = remember(entry) { navController.getBackStackEntry<SignUpGraph>() }
        val sharedViewModel: SignUpViewModel = hiltViewModel(parentEntry)
        SignUpStep1Route(sharedViewModel)
    }
    composable<SignUpStep2> { /* 위와 같은 방식으로 sharedViewModel 획득 */ }
}

composable<Home> { entry ->
    val parentEntry = remember(entry) { navController.getBackStackEntry<SignUpGraph>() }   // (A)
    val vm: SignUpViewModel = hiltViewModel(parentEntry)
    HomeRoute(vm)
}
```', 'OBJECTIVE'),
       (3783, 600, '아래 상황에서 false를 돌려준 NavController 함수의 이름은?', '알림의 딥링크로 상품 상세 화면에 곧장 들어온 사용자가 화면 오른쪽 위 닫기 버튼을 눌러도 아무 반응이 없다는 제보가 들어왔다. 로그를 찍어 보니 닫기 버튼이 호출하는 NavController 함수가 false를 돌려주고 있었다. 반면 홈 → 목록 → 상세 순서로 들어온 사용자에게는 같은 버튼이 문제없이 동작했다.', 'SUBJECTIVE'),
       (3784, 600, '아래 상황에서 ViewModel 생성자에 주입한 객체의 이름은?', '상품 상세 화면의 ViewModel이 어떤 상품을 보여줄지 알아야 하는데, 화면 컴포저블이 productId를 받아 ViewModel에 다시 넘겨 주는 구조가 번거로웠다. ViewModel 생성자에 객체 하나를 주입받도록 바꾸자 toRoute<ProductDetail>().id로 경로 인자를 바로 꺼낼 수 있었고, 백그라운드에서 프로세스가 정리됐다가 복귀해도 같은 값이 그대로 남아 있었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3779
(10251, 3779, '바닥부터 Home, Search, ProductList, ProductDetail, Cart', 'popUpTo 블록을 읽지 않고 navigate가 쌓기만 한다고 본 결과. popUpTo<Search>는 Search 위에 쌓인 항목을 먼저 걷어낸다.', false),
(10252, 3779, '바닥부터 Home, Cart', 'popUpTo<Search>가 ProductDetail·ProductList를 걷어내고 inclusive = true라 Search까지 제거해 Home만 남은 뒤 Cart가 쌓인다. 마지막 navigate는 맨 위가 이미 Cart라 launchSingleTop이 그 항목을 재사용한다.', true),
(10253, 3779, '바닥부터 Home, Search, Cart', 'inclusive = true를 popUpTo 대상 자신은 남긴다는 뜻으로 오해한 결과. true면 대상인 Search도 함께 제거된다.', false),
(10254, 3779, '바닥부터 Home, Cart, Cart', 'launchSingleTop을 빠뜨리고 센 결과. 맨 위가 같은 목적지 Cart이므로 새 항목을 쌓지 않고 기존 항목을 다시 쓴다.', false),

-- 문제 3780
(10255, 3780, 'launchSingleTop은 맨 위 항목을 다시 쓸 뿐 아래 스택을 걷어내지 않고, 떠나는 탭의 상태를 저장하고 되돌아올 때 복원하는 설정도 빠져 있다.', 'popUpTo(시작 목적지) { saveState = true }와 restoreState = true가 없어 탭마다 항목이 계속 쌓이고 스크롤 위치도 보존되지 않는다. 두 증상 모두 옵션 누락에서 나온다.', true),
(10256, 3780, 'launchSingleTop이 이전 탭 항목까지 함께 제거해, 되돌아올 때 복원할 상태가 남지 않고 백스택도 비워진다.', 'launchSingleTop은 맨 위가 같은 목적지일 때 새 항목을 쌓지 않을 뿐 다른 항목을 제거하지 않는다. 제거는 popUpTo의 몫이다.', false),
(10257, 3780, '탭 화면 ViewModel의 소유자가 NavBackStackEntry가 아니라 Activity라서, 탭이 바뀔 때마다 상태가 초기화되고 항목이 남는다.', '소유자가 Activity라면 오히려 탭을 오가도 상태가 유지된다. 여기서 스크롤 위치가 풀리는 것은 소유자 문제가 아니라 saveState·restoreState 누락 때문이다.', false),
(10258, 3780, 'NavHost에 startDestination이 지정되지 않아 이동할 때마다 그래프가 새로 만들어지고 이전 항목이 정리되지 않는다.', 'startDestination은 NavHost 생성 시 필수 인자라 빠지면 컴파일되지 않는다. 이동마다 그래프가 새로 만들어지는 일도 없다.', false),

-- 문제 3781
(10259, 3781, 'autoVerify로 도메인 소유가 확인되면 어느 앱으로 열지 묻는 선택 대화상자 없이 곧바로 앱이 열린다.', '참인 설명. 웹 도메인 소유가 검증된 App Links는 시스템이 후보를 묻지 않고 해당 앱을 바로 띄운다.', false),
(10260, 3781, 'BROWSABLE 카테고리를 빼면 브라우저에서 넘어오는 링크로는 이 화면이 열리지 않는다.', '참인 설명. 브라우저가 넘기는 인텐트는 BROWSABLE 카테고리를 달고 오므로, 필터에 그 카테고리가 없으면 후보에서 빠진다.', false),
(10261, 3781, '경로에 실린 id는 시스템이 검증해 넘겨주므로, 서버 확인 없이 타인의 주문 상세도 그대로 열어 주면 된다.', '거짓이라 고를 선지. URI 값은 사용자가 마음대로 고칠 수 있는 외부 입력이고 시스템은 형식만 인자로 매핑한다. 권한 확인은 화면이 아니라 데이터 계층에서 해야 한다.', true),
(10262, 3781, '이 링크로 진입한 뒤 뒤로 가기를 누르면 그래프의 시작 목적지가 아래에 합성돼 앱 안에 머문다.', '참인 설명. NavController는 딥링크 목적지 아래에 시작 목적지부터의 백스택을 합성해, 뒤로 가기가 곧장 앱 밖으로 빠지지 않게 한다.', false),

-- 문제 3782
(10263, 3782, 'SignUpStep1과 SignUpStep2가 각자 자기 항목을 소유자로 삼아, 단계마다 서로 다른 인스턴스를 받는다.', '소유자를 각 화면의 entry로 착각한 것. 두 화면 모두 parentEntry, 즉 SignUpGraph의 항목을 소유자로 넘기므로 인스턴스가 같다.', false),
(10264, 3782, 'Activity가 살아 있는 한 유지되어, 가입을 끝내고 다시 들어와도 앞서 입력한 값이 그대로 남는다.', 'Activity 스코프와 혼동한 것. 소유자가 그래프 항목이라 그래프를 벗어나면 폐기되고, 다시 진입하면 새 인스턴스가 만들어진다.', false),
(10265, 3782, '(A)처럼 그래프 밖 화면에서도 같은 소유자를 얻어 인스턴스를 이어 쓸 수 있다.', 'getBackStackEntry는 그 그래프가 현재 백스택에 있을 때만 항목을 찾는다. Home처럼 그래프 밖에서 부르면 IllegalArgumentException이 난다.', false),
(10266, 3782, '두 단계가 같은 인스턴스를 함께 쓰고, SignUpGraph가 백스택에서 빠질 때 그 인스턴스도 폐기된다.', '소유자가 SignUpGraph의 NavBackStackEntry라 그래프가 스택에 있는 동안 인스턴스가 유지되고, 그래프가 걷히면 ViewModelStore도 함께 정리된다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1216, 3783, 'popBackStack,popBackStack(),navController.popBackStack(),팝백스택,팝 백 스택,pop back stack,popbackstack', 'popBackStack()은 백스택 맨 위 항목을 하나 제거하는 함수로, 제거할 항목이 없으면 아무 일도 하지 않고 false를 돌려준다. 딥링크로 곧장 들어오면 아래에 쌓인 항목이 없어 바로 이 경우가 되므로, 반환값을 확인해 false면 시작 목적지로 이동하거나 Activity를 종료하는 대안을 둬야 한다. 대상 목적지까지 여러 항목을 한꺼번에 걷어내는 navigate + popUpTo와 달리 popBackStack()은 한 장만 제거한다는 점에서 구분한다.'),
       (1217, 3784, 'SavedStateHandle,savedStateHandle,saved state handle,세이브드스테이트핸들,세이브드 스테이트 핸들', '목적지로 전달된 경로 인자는 NavBackStackEntry의 SavedStateHandle에도 담기므로, ViewModel이 생성자로 이를 주입받아 toRoute()로 인자를 복원하면 UI가 값을 다시 넘겨 줄 필요가 없다. 프로세스가 정리됐다 복귀해도 값이 남는 것은 이 핸들이 저장 상태에 실려 복원되기 때문이다. 화면 사이에 결과를 돌려줄 때 쓰는 previousBackStackEntry의 savedStateHandle은 같은 저장소를 결과 전달 용도로 쓰는 것이고, 여기서 묻는 것은 ViewModel이 자기 화면의 인자를 읽는 통로다.');

-- =====================================================
-- Lesson 758: 인자 전달과 중복 이동 방지
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4727, 758, '아래 방식으로 목적지에 값을 넘길 때 생기는 문제로 옳은 것은?', '```kotlin
@Serializable
data class OrderSummary(val itemsJson: String, val couponJson: String)

// 장바구니 화면 - 항목 수십 개를 JSON 문자열로 만들어 통째로 넘긴다
navController.navigate(
    OrderSummary(itemsJson = cart.toJson(), couponJson = cart.coupon.toJson())
)

composable<OrderSummary> { entry ->
    val route = entry.toRoute<OrderSummary>()
    OrderSummaryRoute(items = route.itemsJson.parseItems())
}
```', 'OBJECTIVE'),
       (4728, 758, '아래 코드의 (A)로 인해 나타나는 동작으로 옳은 것은?', '```kotlin
// state.paid는 결제가 끝난 뒤 true로 유지되고,
// 화면 아래 남은 시간 표시가 1초마다 갱신된다.
@Composable
fun CheckoutRoute(navController: NavHostController, viewModel: CheckoutViewModel) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()

    if (state.paid) {
        navController.navigate(Receipt(state.orderId))   // (A)
    }

    CheckoutScreen(
        state = state,
        onPay = viewModel::pay,
    )
}
```', 'OBJECTIVE'),
       (4729, 758, '아래 표에 정리된 구성 요소의 역할을 바탕으로 한 설명 중 옳지 않은 것은?', '| 구성 요소 | 역할 | Compose에서의 형태 |
| --- | --- | --- |
| NavGraph | 목적지와 이동 경로의 집합 | NavHost { composable<Route> { } } |
| NavHost | 현재 목적지를 화면에 그리는 컨테이너 | NavHost(navController, startDestination) |
| NavController | 이동 명령을 받고 백스택을 관리하는 객체 | rememberNavController() |
| NavBackStackEntry | 백스택의 한 항목. 인자·SavedStateHandle·ViewModelStoreOwner를 가짐 | composable 람다의 매개변수 |', 'OBJECTIVE'),
       (4730, 758, '아래 설정에서 주어진 주소로 앱이 열렸을 때 목적지가 받는 인자 값으로 옳은 것은?', '```kotlin
@Serializable
data class ProductDetail(val id: Long, val fromSearch: Boolean = false)

composable<ProductDetail>(
    deepLinks = listOf(
        navDeepLink<ProductDetail>(basePath = "https://example.com/product"),
    ),
) { entry ->
    val route = entry.toRoute<ProductDetail>()
    ProductDetailRoute(route = route)
}
```

브라우저에서 누른 주소: `https://example.com/product/42?fromSearch=true`', 'OBJECTIVE'),
       (4731, 758, '아래 상황에서 navigate 블록에 true로 켠 설정의 이름은?', '상품 목록에서 상세로 가는 카드를 빠르게 세 번 누르자 같은 상품 상세 화면이 백스택에 세 장 쌓여, 뒤로 가기를 세 번 눌러야 목록으로 돌아왔다. 하단 탭에서도 같은 탭을 반복해 누를 때마다 항목이 하나씩 늘어나 앱을 빠져나가는 데 필요한 뒤로 가기 횟수가 계속 늘었다. 이동 코드에 설정 하나를 true로 켜자 두 경우 모두 화면이 한 장만 남았고, 뒤로 가기 한 번으로 이전 화면에 도달했다.', 'SUBJECTIVE'),
       (4732, 758, '아래 상황에서 회원가입 세 단계에 적용한 그래프 구조의 이름은?', '회원가입 1·2·3단계를 각각 최상위 목적지로 둔 앱에서 두 가지가 번거로웠다. 가입을 취소하고 홈으로 갈 때 지금 몇 단계인지에 따라 popUpTo 대상이 달라져 이동 코드가 세 갈래로 나뉘었고, 가입 흐름을 여는 바깥 화면들은 첫 단계의 이름을 일일이 알고 있어야 했다. 구조를 한 번 바꾸자 popUpTo 대상이 한 곳으로 통일돼 분기가 사라졌고, 바깥 화면은 흐름 이름 하나만 알면 가입을 시작할 수 있게 됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4727
(12779, 4727, '백스택에 항목이 남아 있는 동안만 값이 유지되고, 프로세스가 정리됐다 복귀하면 저장소에서 최신 값으로 다시 채워진다.', '저장 상태가 복원될 때 저장소를 다시 읽는다고 본 오개념. 복원되는 것은 이동 시점에 실어 둔 값 그대로다. 최신 값을 보려면 목적지가 ID로 저장소에 다시 조회해야 한다.', false),
(12780, 4727, '인자가 저장 상태에 통째로 실려 크기 한도에 걸릴 수 있고, 원본이 갱신돼도 목적지는 이동 시점의 복사본을 계속 보여준다.', '경로 인자는 NavBackStackEntry의 저장 상태(Bundle)에 담겨 보관되므로 JSON이 커질수록 저장·복원에서 한도를 건드린다. 또 값이 복사돼 들어가 장바구니가 바뀌어도 이 화면은 그대로다. ID만 넘기고 목적지에서 다시 조회하는 것이 원칙이다.', true),
(12781, 4727, '인자를 문자열로 만들어 넘기면 toRoute로 되돌릴 수 없어, 목적지는 인자 없이 빈 화면을 그리게 된다.', 'toRoute는 경로에 실린 문자열 인자를 그대로 복원하므로 인자가 사라지지는 않는다. 문제는 복원 여부가 아니라 실어 나르는 양과 사본이 금방 낡는다는 점이다.', false),
(12782, 4727, '같은 목적지로 다시 이동하면 맨 위 항목이 재사용돼, 새로 넘긴 인자가 무시되고 처음 값이 계속 쓰인다.', '맨 위 항목 재사용은 launchSingleTop을 켰을 때의 동작이다. 기본 동작은 새 항목을 쌓는 것이라, 이동할 때마다 그때 넘긴 인자가 담긴 항목이 새로 올라간다.', false),

-- 문제 4728
(12783, 4728, '컴포저블 본문의 이동 요청은 컴포지션이 끝난 뒤 한 번만 처리되므로 Receipt 항목은 한 장만 쌓인다.', '컴포저블 본문이 한 번만 실행된다고 본 오개념. 본문은 상태가 바뀔 때마다 다시 실행되는 자리이고, 그 안의 이동 요청도 실행될 때마다 반복된다.', false),
(12784, 4728, '재구성 도중 이동을 요청하면 Compose가 이를 막고 예외를 던져, 결제 화면에 그대로 머문다.', 'Compose는 본문에서 부른 navigate를 막지도, 예외로 알려 주지도 않는다. 이동이 조용히 실제로 일어나기 때문에 오히려 원인을 찾기 어려운 버그가 된다.', false),
(12785, 4728, '남은 시간 표시로 화면이 다시 그려질 때마다 이동이 되풀이돼 Receipt 항목이 계속 쌓인다.', '컴포저블 본문은 재구성마다 실행되는 자리라 state.paid가 참인 동안 navigate가 반복 호출된다. 이동은 버튼 콜백이나 LaunchedEffect처럼 한 번만 실행되는 자리에서 해야 한다.', true),
(12786, 4728, '이동할 때 현재 항목이 함께 제거되어, Receipt에서 뒤로 가기를 누르면 결제 화면을 건너뛴다.', 'navigate는 새 항목을 위에 쌓을 뿐 현재 항목을 지우지 않는다. 돌아가면 안 되는 화면을 없애려면 popUpTo에 inclusive = true를 함께 줘야 한다.', false),

-- 문제 4729
(12787, 4729, '화면 컴포저블이 NavController 대신 콜백만 받아도, 이동 명령을 받는 쪽이 NavHost에 남아 있어 화면 이동은 그대로 동작한다.', '참인 설명. 이동 명령을 받는 것은 NavController의 몫이므로, 화면은 무엇을 눌렀는지만 알리고 실제 이동은 NavHost 쪽에서 처리하면 된다. 결합이 끊겨 미리보기·테스트도 쉬워진다.', false),
(12788, 4729, '같은 목적지를 백스택에 두 장 쌓으면 항목이 둘이므로, 두 화면이 서로 다른 인자와 SavedStateHandle을 갖는다.', '참인 설명. 인자와 SavedStateHandle은 목적지가 아니라 항목에 붙는다. 같은 목적지라도 항목이 다르면 담기는 값과 저장 상태가 따로 관리된다.', false),
(12789, 4729, '어떤 화면이 그려질지는 NavController가 관리하는 백스택의 맨 위 항목에 따라 정해진다.', '참인 설명. NavController가 이동 명령을 받아 백스택을 갱신하면, NavHost는 맨 위 항목에 해당하는 composable을 찾아 화면에 그린다.', false),
(12790, 4729, 'ViewModelStore는 NavHost가 하나만 두고 모든 항목이 나눠 쓰므로, 화면이 백스택에서 빠져도 그 화면의 ViewModel은 남는다.', '거짓이라 고를 선지. 표대로 ViewModelStoreOwner는 항목마다 따로 있어 ViewModelStore도 항목별이다. 항목이 백스택에서 빠지면 그 항목이 들고 있던 ViewModel도 함께 폐기된다.', true),

-- 문제 4730
(12791, 4730, 'id = 42, fromSearch = true', '기본값이 없는 id는 basePath 뒤 경로 조각으로, 기본값이 있는 fromSearch는 쿼리로 매핑된다. 그래서 /42가 id에, ?fromSearch=true가 fromSearch에 채워진 채 toRoute로 복원된다.', true),
(12792, 4730, 'id = 42, fromSearch = false', '선언한 기본값이 쿼리로 들어온 값을 덮어쓴다고 본 오개념. 기본값은 해당 쿼리가 주소에 없을 때만 쓰이고, 값이 있으면 그 값이 들어간다.', false),
(12793, 4730, 'id = 0, fromSearch = true', 'basePath 뒤 경로 조각은 인자로 매핑되지 않는다고 보고 id를 기본값으로 채운 것. 기본값이 없는 인자는 경로 조각으로 반드시 받아야 하며, 없으면 링크 자체가 맞지 않는다.', false),
(12794, 4730, 'id = 42, fromSearch = 전달되지 않음', '기본값이 있는 인자는 딥링크로 받을 수 없다고 본 오개념. 기본값이 있는 인자는 쿼리 자리를 차지하며, 주소에 값이 실려 오면 그대로 채워진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1532, 4731, 'launchSingleTop,launchsingletop,launch single top,launchSingleTop = true,런치싱글톱,런치 싱글 톱,런치싱글탑,런치 싱글 탑', 'launchSingleTop은 이동하려는 목적지가 이미 백스택 맨 위에 있으면 새 항목을 쌓지 않고 그 항목을 다시 쓰게 하는 설정이다. 그래서 버튼 연타나 같은 탭 반복 터치로 같은 화면이 여러 장 겹치는 일을 막아 준다. 비슷하게 백스택을 정리하는 popUpTo와 구분해야 하는데, popUpTo는 지정한 목적지까지 아래 항목들을 걷어내는 설정이고 launchSingleTop은 맨 위 한 장을 재사용할 뿐 다른 항목은 건드리지 않는다. 하단 탭에서 스크롤 위치까지 지키려면 popUpTo(시작 목적지) { saveState = true }와 restoreState = true를 함께 써야 한다.'),
       (1533, 4732, '중첩 그래프,중첩그래프,중첩 내비게이션 그래프,중첩 네비게이션 그래프,nested graph,nestedgraph,nested navigation graph,네스티드 그래프', '관련된 목적지들을 한 그래프 안에 다시 묶은 것이 중첩 그래프다. navigation<SignUpGraph>(startDestination = SignUpStep1) { ... } 처럼 선언하면 바깥에서는 그래프 하나로 진입하므로 첫 단계 이름을 알 필요가 없고, popUpTo<SignUpGraph>로 그래프를 통째로 걷어낼 수 있어 단계마다 분기할 이유도 사라진다. 화면 하나를 가리키는 목적지(Destination)와는 층이 다르다는 점에서 구분하며, 그래프의 NavBackStackEntry를 소유자로 삼으면 묶인 화면들이 ViewModel 하나를 공유하고 그래프를 벗어날 때 함께 폐기된다는 성질도 함께 따라온다.');

-- =====================================================
-- Lesson 916: Navigation 백스택 운용과 화면 간 데이터 전달
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5675, 916, '아래 순서대로 이동했을 때 로그 "created"가 찍히는 총 횟수는?', '```kotlin
@HiltViewModel
class ProductDetailViewModel @Inject constructor() : ViewModel() {
    init { Log.d("Detail", "created") }
}

composable<ProductDetail> {
    val viewModel: ProductDetailViewModel = hiltViewModel()
    ProductDetailRoute(viewModel)
}
```

```kotlin
// 시작 백스택 (바닥부터): Home, ProductList
// 각 줄은 앞 화면이 완전히 그려진 뒤 사용자의 동작으로 실행된다.
navController.navigate(ProductDetail(42))   // (1)
navController.navigate(Cart)                // (2)
navController.popBackStack()                // (3) Cart 제거
navController.popBackStack()                // (4) ProductDetail(42) 제거
navController.navigate(ProductDetail(42))   // (5)
navController.navigate(ProductDetail(7))    // (6)
```', 'OBJECTIVE'),
       (5676, 916, '아래 요구 사항을 만족하는 이동 코드로 옳은 것은?', '현재 백스택 (바닥부터): Home, Cart, Checkout, Payment

- 결제가 성공하면 Payment 화면에서 주문 완료 화면 OrderComplete로 이동한다.
- OrderComplete에서 뒤로 가기를 한 번 누르면 곧바로 Home이 나타나야 한다.
- Cart·Checkout·Payment 중 어느 화면으로도 되돌아갈 수 없어야 한다.', 'OBJECTIVE'),
       (5677, 916, '아래 코드에서 고른 주소가 Checkout 화면에 전달되지 않는 원인으로 옳은 것은?', '```kotlin
// 백스택 (바닥부터): Home, Checkout, AddressPicker
composable<AddressPicker> {
    AddressPickerRoute(onPick = { address ->
        navController.currentBackStackEntry?.savedStateHandle?.set("address", address)
        navController.popBackStack()
    })
}

composable<Checkout> { entry ->
    val address = entry.savedStateHandle.get<String>("address")
    CheckoutRoute(address = address)
}
```

주소를 고르면 Checkout 화면으로 돌아오지만, address는 계속 null이다.', 'OBJECTIVE'),
       (5678, 916, '아래 코드를 (가)에서 (나)로 바꾼 뒤의 변화로 옳은 것은?', '```kotlin
// (가) 변경 전
@Composable
fun ProductCard(product: Product, navController: NavController) {
    Card(onClick = { navController.navigate(ProductDetail(product.id)) }) {
        Text(product.name)
    }
}

// (나) 변경 후
@Composable
fun ProductCard(product: Product, onClick: (Long) -> Unit) {
    Card(onClick = { onClick(product.id) }) {
        Text(product.name)
    }
}

// (나)를 쓰는 NavHost 쪽 - ProductListRoute는 onProductClick을 각 카드의 onClick으로 넘긴다
composable<ProductList> {
    ProductListRoute(onProductClick = { id -> navController.navigate(ProductDetail(id)) })
}
```', 'OBJECTIVE'),
       (5679, 916, '아래 상황에서 적용한 기능의 이름은?', '메신저로 공유된 https://example.com/product/42 링크를 누르면, 브라우저로 열지 앱으로 열지 묻는 선택 창이 먼저 떴다. 팀은 example.com 서버의 /.well-known/assetlinks.json 파일에 앱의 패키지 이름과 서명 인증서 지문을 올리고, 매니페스트의 인텐트 필터에 android:autoVerify="true"를 추가했다. 앱을 다시 설치하자 같은 링크를 눌렀을 때 선택 창 없이 곧바로 앱의 상품 상세 화면이 열렸다.', 'SUBJECTIVE'),
       (5680, 916, '아래 상황에서 붙인 어노테이션의 이름은?', '문자열 경로를 쓰던 앱에서 상세 화면으로 가는 코드에 navController.navigate("prodcut/42")처럼 오타가 섞였다. 빌드는 문제없이 통과했고, 사용자가 그 버튼을 누른 순간에야 일치하는 목적지를 찾지 못한다는 IllegalArgumentException으로 앱이 종료됐다. 팀은 목적지를 data class ProductDetail(val id: Long)로 바꾸고 선언 위에 어노테이션 하나를 붙인 뒤 composable<ProductDetail>로 등록했다. 그러자 navigate(ProductDetail(42))처럼 클래스로 이동하게 되어, 목적지 이름이나 인자 타입을 잘못 쓰면 컴파일 단계에서 걸러졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5675
(15307, 5675, '1회', 'ViewModel이 Activity 범위에 하나만 있어 모든 상세 화면이 공유한다고 본 오개념. hiltViewModel()은 현재 NavBackStackEntry를 소유자로 삼아 상세 항목마다 따로 만든다.', false),
(15308, 5675, '2회', '(5)가 (1)과 같은 id=42라 인스턴스를 이어 쓴다고 본 오개념. ViewModel은 인자가 아니라 항목에 묶이며, (4)에서 (1)의 항목이 제거될 때 이미 폐기됐다.', false),
(15309, 5675, '3회', '(1)에서 상세 항목이 생기며 1회. (2)로 Cart가 쌓여도 상세 항목은 백스택에 남아 (3)에서 같은 인스턴스를 다시 쓴다. (4)에서 항목과 함께 폐기되고, (5)와 (6)은 각각 새 항목이라 1회씩 더해 총 3회다.', true),
(15310, 5675, '4회', 'Cart로 이동하면 가려진 상세 화면의 ViewModel이 폐기된다고 본 오개념. 항목이 백스택에 남아 있는 한 ViewModel도 유지되므로 (3)에서는 새로 만들지 않는다.', false),

-- 문제 5676
(15311, 5676, 'navController.navigate(OrderComplete) { popUpTo<Home> { inclusive = true } }', 'Home으로 돌아가려면 Home까지 걷어내야 한다고 본 오개념. inclusive = true면 대상인 Home까지 제거돼 OrderComplete만 남고, 뒤로 가기를 누르면 앱 밖으로 나간다.', false),
(15312, 5676, 'navController.navigate(OrderComplete) { popUpTo<Home>() }', 'popUpTo<Home>()은 Home 위의 Cart·Checkout·Payment를 걷어내고 Home은 남긴 채 OrderComplete를 쌓는다. 백스택이 Home, OrderComplete가 되어 뒤로 가기 한 번에 Home이 나타난다.', true),
(15313, 5676, 'navController.navigate(OrderComplete) { popUpTo<Payment> { inclusive = true } }', '지금 화면만 없애면 된다고 본 오개념. Payment만 제거돼 Home, Cart, Checkout, OrderComplete가 되므로 뒤로 가기를 누르면 Checkout으로 돌아간다.', false),
(15314, 5676, 'navController.navigate(OrderComplete) { popUpTo<Cart>() }', 'popUpTo가 대상 자신까지 지운다고 본 오개념. inclusive가 없으면 대상 Cart는 남아 Home, Cart, OrderComplete가 되고, 뒤로 가기를 누르면 Cart가 나타난다.', false),

-- 문제 5677
(15315, 5677, 'popBackStack()이 AddressPicker와 함께 Checkout 항목까지 걷어내, 돌아온 Checkout은 SavedStateHandle이 빈 새 항목이다.', 'popBackStack()이 여러 장을 걷어낸다고 본 오개념. popBackStack()은 맨 위 항목 하나만 제거하므로 Checkout 항목은 그대로이고 새로 만들어지지 않는다.', false),
(15316, 5677, '가려져 있던 Checkout 항목의 SavedStateHandle은 그동안 비워져, 돌아와도 넘겨받을 값이 남아 있지 않다.', '가려진 항목이 상태를 잃는다고 본 오개념. 백스택에 남은 항목은 인자·SavedStateHandle·ViewModel을 그대로 유지하며, 그래서 결과를 그 항목에 넣어 돌려주는 방식이 성립한다.', false),
(15317, 5677, 'SavedStateHandle의 값은 프로세스가 정리됐다 복원될 때만 읽혀, 평소 이동에서는 get으로 꺼낼 수 없다.', 'SavedStateHandle을 프로세스 복원 전용으로 본 오개념. set으로 넣은 값은 곧바로 get으로 읽히고, 프로세스가 복원된 뒤에도 남을 뿐이다.', false),
(15318, 5677, '결과를 곧 제거될 AddressPicker 항목의 SavedStateHandle에 넣어, 그 항목이 빠질 때 값도 함께 사라졌다.', 'onPick 시점의 currentBackStackEntry는 AddressPicker 자신이라, popBackStack()과 함께 그 SavedStateHandle도 폐기된다. 결과는 previousBackStackEntry, 즉 Checkout 항목의 SavedStateHandle에 넣어야 한다.', true),

-- 문제 5678
(15319, 5678, '미리보기나 UI 테스트에서 NavHost 없이 카드를 그리고, 눌렀을 때 넘어오는 id만 확인할 수 있다.', '(나)의 카드는 어떤 id가 눌렸는지만 알리고 실제 이동은 NavHost 쪽이 맡는다. 내비게이션과 결합이 끊겨, 미리보기·테스트에서는 id를 기록하는 람다만 넘기면 카드를 그대로 그릴 수 있다.', true),
(15320, 5678, '카드를 빠르게 여러 번 눌러도 상세 화면이 백스택에 한 장만 쌓인다.', '호출 위치를 옮기면 이동 옵션도 바뀐다고 본 오개념. NavHost 쪽 navigate에 launchSingleTop이 없으므로 누를 때마다 상세 항목이 새로 쌓인다.', false),
(15321, 5678, '(가)에서 재구성될 때마다 이동이 반복되던 문제가 (나)에서 사라진다.', '(가)의 navigate도 onClick 람다 안에 있어 눌렀을 때만 실행되므로 재구성마다 반복되지 않았다. 반복 이동은 navigate를 컴포저블 본문에서 직접 부를 때 생긴다.', false),
(15322, 5678, '카드가 NavController를 갖지 않아, 상세로 갈 때 백스택에 항목이 쌓이지 않고 화면만 바뀐다.', 'NavController를 갖지 않으면 백스택을 거치지 않는다고 본 오개념. 이동 요청 위치가 NavHost 쪽으로 옮겨졌을 뿐 navController.navigate가 그대로 불려 상세 항목이 쌓인다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1848, 5679, 'App Links,AppLinks,App Link,AppLink,Android App Links,Android App Link,앱 링크,앱링크,앱 링크스,앱링크스,안드로이드 앱 링크,안드로이드 앱링크', '선택 창이 사라진 것은 앱이 example.com의 주인이라는 사실이 확인됐기 때문이다. 서버의 assetlinks.json과 autoVerify 설정으로 시스템이 웹 도메인 소유를 검증한 링크가 App Links이며, 검증이 끝나면 시스템은 다른 후보를 묻지 않고 곧바로 앱을 연다. 검증 없이 인텐트 필터만 선언한 일반 암시적 딥링크는 같은 링크를 처리할 수 있는 앱이 여럿일 수 있어 선택 창을 띄우고, 알림처럼 앱이 PendingIntent로 직접 만드는 명시적 딥링크는 인텐트 필터 없이 동작한다는 점에서 구분한다. 또 App Links로 열렸더라도 URI의 id는 사용자가 바꿀 수 있는 외부 입력이므로 권한 확인은 데이터 계층에서 해야 한다.'),
       (1849, 5680, '@Serializable,Serializable,@kotlinx.serialization.Serializable,kotlinx.serialization.Serializable,시리얼라이저블,@시리얼라이저블,세리얼라이저블', 'Navigation 2.8.0부터는 @Serializable을 붙인 클래스·객체를 목적지 경로로 쓸 수 있다. 이 어노테이션이 있어야 Navigation이 클래스의 속성(id 등)을 경로와 인자로 바꿔 담고, 목적지에서는 toRoute<ProductDetail>()로 같은 타입의 객체로 되돌린다. 그래서 목적지와 인자를 문자열이 아니라 타입으로 다루게 되어, 오타나 타입 불일치가 실행 중 예외 대신 컴파일 오류로 드러난다. 인자를 꺼낼 때 쓰는 toRoute()나 인자가 함께 담기는 SavedStateHandle과 헷갈리지 말 것. 이 둘은 경로를 되돌려 읽는 쪽이고, @Serializable은 경로 클래스를 정의하는 쪽에 붙는다.');
