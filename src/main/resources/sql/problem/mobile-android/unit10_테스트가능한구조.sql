-- Unit: 테스트 가능한 구조 (Unit ID: 176)
-- Chapter: Android (Chapter ID: 16)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (602, 176, '생성자 주입과 runTest 가상 시간'),
       (760, 176, '테스트 모듈 교체와 디스패처 제어'),
       (918, 176, '안드로이드 테스트 설계: 프레임워크 분리부터 상태 흐름 검증까지');

-- =====================================================
-- Lesson 602: 생성자 주입과 runTest 가상 시간
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3791, 602, '아래 안드로이드 테스트 종류 비교표를 바탕으로 옳지 않은 것은?', '| 종류 | 실행 환경 | 스위트 1회 실행 시간 | 주 검증 대상 | 권장 비중 |
| --- | --- | --- | --- | --- |
| 로컬 단위 테스트 | JVM (src/test) | 수 초 | ViewModel, UseCase, 순수 로직 | 대부분 |
| 로컬 UI 테스트 | JVM (src/test) | 수십 초 | 컴포저블 렌더링, 상호작용 | 일부 |
| 계측 테스트 | 에뮬레이터, 실기기 (src/androidTest) | 수 분 | 실제 기기 동작, 화면 흐름 | 핵심 경로만 |', 'OBJECTIVE'),
       (3792, 602, '아래 ViewModel을 JVM 로컬 단위 테스트로 검증하려 할 때 생기는 문제로 옳은 것은?', '```kotlin
class OrderViewModel(private val context: Context) : ViewModel() {

    private val api = RetrofitClient.orderApi

    fun load(orderId: Long) = viewModelScope.launch(Dispatchers.IO) {
        val order = api.getOrder(orderId)
        // 이하 상태 갱신
    }
}
```', 'OBJECTIVE'),
       (3793, 602, '아래 테스트에서 uiState 값이 Loading에 머물러 실패하는 원인으로 옳은 것은?', '```kotlin
class SearchViewModel(repo: SearchRepository) : ViewModel() {
    val uiState: StateFlow<SearchUiState> = repo.results()
        .map { SearchUiState.Success(it) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), SearchUiState.Loading)
}

class SearchViewModelTest {
    @get:Rule val mainDispatcherRule = MainDispatcherRule()   // Dispatchers.setMain 적용됨
    private val repo = FakeSearchRepository()
    private val viewModel = SearchViewModel(repo)

    @Test
    fun 결과가_오면_Success가_된다() = runTest {
        repo.emit(listOf("kotlin"))
        assertTrue(viewModel.uiState.value is SearchUiState.Success)   // 실패: 값이 Loading
    }
}
```', 'OBJECTIVE'),
       (3794, 602, '아래 상황에서 테스트를 고치는 방향으로 옳은 것은?', '주문 화면 테스트 20개가 OrderRepository를 MockK로 만들어 쓰고, 각 테스트가 verify로 getOrder(1L)의 호출 여부와 호출 횟수까지 확인한다. 이후 ViewModel이 주문을 하나씩 가져오는 대신 getOrders(listOf(1L))로 한 번에 가져오도록 리팩터링하자, 화면에 보이는 결과와 최종 상태는 그대로인데 테스트 20개가 모두 실패했다.', 'OBJECTIVE'),
       (3795, 602, '아래 상황에서 테스트 본문을 감싼 코루틴 테스트 함수의 이름은?', '검색어를 입력하면 300ms 디바운스 뒤에 조회하고, 응답이 5초 안에 오지 않으면 타임아웃 상태로 바꾸는 ViewModel이 있다. 처음에는 테스트마다 Thread.sleep(5500)으로 기다려 30개 스위트가 3분 가까이 걸렸고, CI가 붐비는 날에는 몇 개씩 실패했다. 코루틴 테스트 라이브러리가 제공하는 실행 블록으로 테스트 본문을 감싸고 Thread.sleep을 걷어내자, 같은 30개가 2초 만에 끝났고 간헐적 실패도 사라졌다.', 'SUBJECTIVE'),
       (3796, 602, '아래 상황에서 새로 추가한 테스트 라이브러리의 이름은?', '컴포저블 40개의 표시와 클릭을 확인하는 테스트를 계측 테스트로 두었더니, 에뮬레이터 부팅까지 합쳐 한 번 도는 데 6분이 걸렸고 CI에서 에뮬레이터가 죽어 결과가 들쭉날쭉했다. 테스트 코드는 한 줄도 고치지 않고 파일을 src/androidTest에서 src/test로 옮긴 뒤 의존성 하나를 추가하자, 에뮬레이터를 켜지 않고도 같은 40개가 50초 만에 끝났다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3791
(10283, 3791, '계측 테스트는 src/test에서 돌아가므로 에뮬레이터 없이 수 초 만에 화면 흐름을 반복 검증할 수 있다.', '거짓이라 고를 선지다. 표에서 계측 테스트만 실행 환경이 에뮬레이터, 실기기(src/androidTest)이고 1회 실행이 수 분이다. 화면 흐름 검증이 가장 비싸기 때문에 핵심 경로만 남긴다.', true),
(10284, 3791, '할인 금액 계산 로직을 계측 테스트에서 로컬 단위 테스트로 옮기면 같은 검증에 드는 실행 시간이 줄어든다.', '참이다. 수 분이 드는 환경에서 수 초가 드는 환경으로 내려오는 이동이라, 순수 로직을 아래층으로 내릴수록 피드백이 빨라진다.', false),
(10285, 3791, '로그인부터 결제까지 이어지는 흐름 검증을 늘릴수록 전체 테스트 실행 시간이 가파르게 늘어난다.', '참이다. 화면 흐름은 표에서 계측 테스트 몫이고 1회 실행이 수 분이라, 개수가 늘면 그 비용이 그대로 곱해진다.', false),
(10286, 3791, '컴포저블에 버튼이 표시되는지는 에뮬레이터를 켜지 않고도 JVM에서 확인할 수 있다.', '참이다. 표의 로컬 UI 테스트가 JVM(src/test)에서 컴포저블 렌더링과 상호작용을 맡으므로 기기 없이도 확인된다.', false),

-- 문제 3792
(10287, 3792, '생성자가 Context를 받으므로 테스트에서 android.content.Context 인스턴스를 직접 만들어 넘기면 된다.', 'Context는 안드로이드 프레임워크가 만들어 주는 타입이라 JVM에는 구현 자체가 없다. 무엇을 넘길지가 아니라 ViewModel에서 Context를 걷어내야 JVM에서 실행된다.', false),
(10288, 3792, 'launch에 Dispatchers.IO를 지정했으므로 Dispatchers.setMain 없이도 테스트가 그대로 통과한다.', 'viewModelScope는 컨텍스트에 Dispatchers.Main을 품고 있다. 안에서 어떤 디스패처로 launch하든 메인 디스패처 초기화 실패 예외가 먼저 나서, 교체 규칙이 필요하다.', false),
(10289, 3792, 'api가 싱글턴 구현체를 직접 참조해, 네트워크 실패 응답을 돌려주는 가짜 구현으로 바꿔 끼울 수 없다.', '주입 통로가 없으면 대체할 방법도 없다. 생성자로 저장소 인터페이스를 받게 바꿔야 실패 시나리오를 테스트에서 재현할 수 있다.', true),
(10290, 3792, 'Dispatchers.IO는 스레드 풀에서 도는 만큼 runTest의 가상 시간으로 delay를 건너뛸 수 있다.', '가상 시간은 runTest가 만든 테스트 디스패처 위에서만 동작한다. 하드코딩된 Dispatchers.IO는 실제 시간을 그대로 기다려서 대기가 실행 시간에 더해진다.', false),

-- 문제 3793
(10291, 3793, 'stateIn의 초기값을 Loading으로 준 탓에 이후 방출이 무시된다. 초기값을 Success로 바꿔야 한다.', '초기값은 첫 값을 정할 뿐 이후 방출을 막지 않는다. 애초에 상위 흐름 수집이 시작되지 않아 갱신할 값이 흘러오지 않은 것이다.', false),
(10292, 3793, '구독자가 없어 상위 흐름 수집이 시작되지 않았다. backgroundScope에서 uiState를 먼저 수집해야 값이 갱신된다.', 'WhileSubscribed는 구독자가 생긴 뒤에야 상위 흐름을 수집하고 마지막 구독이 끊기면 멈춘다. value를 읽는 것은 구독으로 치지 않으므로 초기값만 보인다.', true),
(10293, 3793, 'runTest의 가상 시간이 5초를 넘겨 WhileSubscribed 타임아웃이 지나는 바람에 초기값으로 되돌아갔다.', '5초는 마지막 구독이 끊긴 뒤 상위 수집을 유지하는 시간이다. 구독이 한 번도 없었으니 이 타임아웃은 시작조차 하지 않는다.', false),
(10294, 3793, 'StateFlow의 최신 값은 Turbine 같은 라이브러리로만 읽을 수 있어 value는 항상 초기값을 준다.', 'value는 언제나 최신 값을 돌려준다. Turbine은 여러 번 방출되는 값을 순서대로 확인할 때 편한 도구일 뿐 값 읽기의 전제 조건이 아니다.', false),

-- 문제 3794
(10295, 3794, 'verify의 times(1)을 atLeastOnce()로 완화해 호출 횟수 검증을 느슨하게 만든다.', '횟수를 느슨하게 해도 검증 대상이 getOrder 호출 그 자체다. 이름과 인자가 바뀐 지금은 그 호출이 아예 없어 20개가 그대로 실패한다.', false),
(10296, 3794, 'MockK 대신 실제 Retrofit 구현체를 주입해 서버 응답으로 결과를 확인한다.', '결과가 네트워크와 서버 상태에 묶여 더 느리고 불안정해진다. 단위 테스트는 외부 의존을 끊는 방향으로 가야 실행이 빠르고 결과가 일정하다.', false),
(10297, 3794, 'OrderRepository를 인메모리로 구현한 가짜 저장소를 주입하고 최종 상태만 단언하도록 바꾼다.', '결과 상태를 기준으로 삼으면 내부 호출 방식이 바뀌어도 통과한다. 공식 가이드가 핵심 협력 객체는 Mock보다 가짜 구현을 쓰라고 권하는 이유가 이 리팩터링 내성이다.', true),
(10298, 3794, '계측 테스트로 옮겨 실제 기기 화면에 찍힌 금액 텍스트로 결과를 확인한다.', '로직 검증을 화면으로 끌어올리면 실행이 수 분으로 늘고 문구나 배치만 바뀌어도 깨진다. 화면 테스트는 주어진 상태가 올바르게 표시되는지만 맡는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1220, 3795, 'runTest,runTest {},runTest{}', 'runTest는 가상 시간을 쓰는 테스트 스코프에서 본문을 실행한다. 그래서 디바운스 300ms나 타임아웃 5초처럼 시간을 기다리는 코드도 실제 시간을 소모하지 않고 즉시 다음으로 넘어가, 대기 시간이 곧 테스트 실행 시간이 되는 문제가 사라진다. Thread.sleep이나 runBlocking은 실제로 기다리므로 스위트가 길어지고 기기 속도에 따라 결과가 흔들린다. 메인 디스패처를 테스트용으로 갈아 끼우는 Dispatchers.setMain과도 역할이 다르다. setMain은 viewModelScope가 쓸 디스패처를 바꾸는 것이고, runTest는 테스트 본문을 어떤 시간 축 위에서 돌릴지를 정한다.'),
       (1221, 3796, 'Robolectric,로보렉트릭', 'Robolectric은 안드로이드 프레임워크의 동작을 JVM 위에서 대신 제공해, 에뮬레이터 없이 src/test에서 화면과 관련된 코드를 돌리게 해 준다. 계측 테스트를 로컬 UI 테스트로 내려 실행 시간을 크게 줄이고 기기 상태에 따른 불안정도 함께 없애는 수단이 여기서 나온다. 컴포저블을 단독으로 띄워 검증하는 createComposeRule은 테스트를 작성하는 규칙이지 실행 환경을 바꾸는 것이 아니고, Espresso는 실기기와 에뮬레이터에서 도는 계측 UI 테스트 도구라는 점에서 구분된다.');

-- =====================================================
-- Lesson 760: 테스트 모듈 교체와 디스패처 제어
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4739, 760, '아래 코드에서 작성 당시 통과하던 테스트가 지금은 실패하는 이유로 옳은 것은?', '```kotlin
class CouponViewModel(private val repository: CouponRepository) : ViewModel() {

    private val _uiState = MutableStateFlow<CouponUiState>(CouponUiState.Loading)
    val uiState: StateFlow<CouponUiState> = _uiState.asStateFlow()

    fun load(id: Long) = viewModelScope.launch {
        val coupon = repository.get(id)
        _uiState.value = if (coupon.expiresAt < System.currentTimeMillis()) {
            CouponUiState.Expired
        } else {
            CouponUiState.Usable(coupon)
        }
    }
}
```

```kotlin
class CouponViewModelTest {
    @get:Rule val mainDispatcherRule = MainDispatcherRule()   // Dispatchers.setMain 적용됨

    private val repository = FakeCouponRepository()
    private val viewModel = CouponViewModel(repository)

    @Test
    fun 만료_전_쿠폰은_Usable이_된다() = runTest {
        repository.coupons[1L] = Coupon(id = 1L, expiresAt = 1_757_000_000_000)

        viewModel.load(1L)

        assertTrue(viewModel.uiState.value is CouponUiState.Usable)
    }
}
```

ViewModel과 테스트 코드는 한 줄도 바뀌지 않았는데, 작성 당시에는 통과하던 이 테스트가 지금은 실패한다.', 'OBJECTIVE'),
       (4740, 760, '아래 의존성 대체 방식 비교표에서 따라 나오는 설명으로 옳은 것은?', '| 항목 | 가짜 구현(Fake) | 모의 객체(Mock) |
| --- | --- | --- |
| 만드는 법 | 인터페이스를 인메모리로 직접 구현 | 라이브러리로 호출별 반환값과 행동을 지정 |
| 검증의 근거 | 실행 뒤 남은 결과 상태 | 어떤 함수가 어떤 인자로 몇 번 불렸는지 |
| 여러 테스트에서 | 하나를 공유해 재사용 | 테스트마다 다시 설정 |
| 잘 맞는 대상 | 저장소, 데이터 소스 등 핵심 협력 객체 | 분석 SDK, 알림 등 부수효과 확인 |', 'OBJECTIVE'),
       (4741, 760, '아래 계측 테스트 설정에서 두 테스트에만 다른 구현을 넣는 방법으로 옳은 것은?', '```kotlin
@Module
@TestInstallIn(components = [SingletonComponent::class], replaces = [RepositoryModule::class])
abstract class FakeRepositoryModule {

    @Binds @Singleton
    abstract fun bindOrderRepository(impl: FakeOrderRepository): OrderRepository
}
```

계측 테스트 30개가 위 모듈을 함께 쓴다. 그중 결제 실패 화면을 확인하는 2개만 조회할 때마다 IOException을 던지는 구현이 필요하고, 나머지 28개는 지금의 가짜 저장소를 그대로 써야 한다.', 'OBJECTIVE'),
       (4742, 760, '아래 Compose UI 테스트에 대한 설명으로 옳은 것은?', '```kotlin
class CartScreenTest {
    @get:Rule val composeRule = createComposeRule()

    @Test
    fun 쿠폰을_적용하면_할인가가_보인다() {
        composeRule.setContent { CartRoute(viewModel = hiltViewModel()) }

        composeRule.onNodeWithText("쿠폰 적용").performClick()

        composeRule.onNodeWithText("9,000원").assertIsDisplayed()
    }
}
```

장바구니에 담긴 금액은 10,000원이고, 쿠폰 할인율을 적용해 최종 금액을 계산하는 일은 CartViewModel이 맡는다.', 'OBJECTIVE'),
       (4743, 760, '아래 상황에서 Rule이 테스트 시작 전에 호출해야 하는 함수의 이름은?', 'viewModelScope 안에서 상태를 갱신하는 ViewModel 테스트 30개가 JVM에서 한 개도 통과하지 못하고 모두 아래 예외로 끝났다.

```
java.lang.IllegalStateException: Module with the Main dispatcher had failed to initialize
```

TestWatcher를 상속한 Rule을 만들어 starting에서 함수 하나를 호출하고 finished에서 Dispatchers.resetMain()을 부르도록 하자, 테스트 본문은 한 줄도 고치지 않았는데 30개가 모두 통과했다.', 'SUBJECTIVE'),
       (4744, 760, '아래 상황에서 단언 앞에 넣은 테스트 스케줄러 함수의 이름은?', 'Rule이 쓰던 디스패처를 UnconfinedTestDispatcher에서 StandardTestDispatcher로 바꾸자, 검색 화면 테스트 12개가 모두 아래 모양에서 실패했다.

```kotlin
@Test
fun 검색어를_넣으면_결과가_채워진다() = runTest {
    repository.results = listOf("kotlin", "coroutine")

    viewModel.onQueryChanged("kotlin")   // 내부에서 200ms 디바운스 뒤 저장소 조회

    assertEquals(2, viewModel.uiState.value.results.size)   // 실패: 실제 0
}
```

저장소가 돌려주는 값에는 문제가 없었고, 단언 바로 앞에 함수 한 줄을 넣자 12개가 다시 통과했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4739
(12811, 4739, 'runTest의 가상 시간이 만료 시각을 지나칠 만큼 앞당겨졌다. 가상 시간을 쓰지 않는 runBlocking으로 바꾸면 통과한다.', '가상 시간은 테스트 스코프 안의 delay를 건너뛸 때만 쓰인다. System.currentTimeMillis()가 돌려주는 실제 시각을 옮기지 못하고, 이 테스트에는 건너뛸 delay도 없다.', false),
(12812, 4739, '만료 판정의 기준값이 테스트를 돌리는 날마다 달라져 같은 입력에도 결과가 뒤집힌다. 생성자로 시계를 주입해 테스트에서 고정해야 한다.', '고정된 만료 시각과 비교할 상대가 코드 밖 환경에서 정해지면 결과는 결정적일 수 없다. Clock을 주입해 테스트에서 원하는 시각을 넣으면 언제 돌려도 같은 결과가 나온다.', true),
(12813, 4739, '가짜 저장소를 여러 테스트가 공유해 앞선 테스트가 남긴 쿠폰이 조회됐다. @Before에서 저장소를 새로 만들면 통과한다.', '테스트가 조회 직전에 1L 쿠폰을 직접 넣으므로 남은 데이터가 끼어들 자리가 없다. 공유 상태는 실제 함정이지만 여기서 실패를 만든 원인은 아니다.', false),
(12814, 4739, 'viewModelScope가 메인 디스패처를 찾지 못해 초기화에 실패했다. Dispatchers.setMain으로 교체해야 상태가 갱신된다.', 'Rule이 이미 메인 디스패처를 교체해 두었다. 교체가 빠졌다면 단언이 어긋나는 것이 아니라 예외로 끝나므로 실패 양상 자체가 다르다.', false),

-- 문제 4740
(12815, 4740, '핵심 협력 객체의 실패 경로는 예외를 지정할 수 있는 모의 객체로만 재현할 수 있다.', '가짜 구현도 플래그 하나를 두고 예외를 던지게 만들 수 있어 실패 재현은 양쪽 모두 가능하다. 표가 가르는 기준은 무엇을 검증의 근거로 삼느냐다.', false),
(12816, 4740, '호출된 함수와 인자를 단언하는 방식은 실행 뒤 결과 상태까지 함께 확인하므로 내부 구현이 바뀌어도 통과한다.', '표에서 그 방식의 근거는 호출 기록이지 결과 상태가 아니다. 최종 결과가 같아도 호출하는 함수 이름이나 인자가 달라지면 단언이 그대로 깨진다.', false),
(12817, 4740, '가짜 구현은 인터페이스를 직접 구현해야 하므로 테스트마다 새로 작성하게 되어 코드가 가장 많이 늘어난다.', '표는 가짜 구현을 여러 테스트가 하나로 공유한다고 적고 있다. 테스트마다 다시 설정하는 쪽은 반대편이라 작성 비용의 방향이 뒤집혔다.', false),
(12818, 4740, '저장소 인터페이스에 함수가 추가되고 ViewModel이 그 함수를 쓰면, 가짜 구현은 한 곳만 고치면 되지만 반환값을 지정해 둔 테스트는 각각 손봐야 한다.', '공유되는 구현 하나를 고치는 비용과, 테스트마다 흩어진 설정을 모두 고치는 비용의 차이다. 리팩터링에 견디는 힘이 갈리는 지점이 바로 여기다.', true),

-- 문제 4741
(12819, 4741, '@TestInstallIn은 모든 계측 테스트에 일괄 적용되므로, 그 두 클래스에는 @UninstallModules와 클래스 안에 정의한 모듈을 조합해 실패용 구현을 따로 바인딩한다.', '모듈 단위 교체는 범위를 고르지 못한다. 대상 클래스에서 모듈을 빼고 그 클래스 안에서 다시 바인딩해야 28개는 그대로 두고 2개만 다른 구현을 받는다.', true),
(12820, 4741, '같은 RepositoryModule을 replaces에 지정한 @TestInstallIn 모듈을 하나 더 만들면 나중에 선언된 쪽이 그 두 테스트에 적용된다.', 'replaces는 어떤 모듈을 대신할지를 적을 뿐 어느 테스트에 적용할지를 고르는 장치가 아니다. 같은 모듈을 대체하는 선언이 둘이면 범위가 갈리는 대신 바인딩이 충돌한다.', false),
(12821, 4741, '그 두 클래스에서 @HiltAndroidTest를 떼면 테스트용 그래프가 꺼지면서 실패용 구현이 대신 주입된다.', '그 표시가 없으면 주입 자체가 이뤄지지 않아 테스트가 시작도 못 한다. 무엇을 주입할지 고르는 스위치가 아니라 주입을 켜는 표시다.', false),
(12822, 4741, '그 두 클래스를 src/androidTest에서 src/test로 옮기면 클래스마다 그래프가 새로 만들어져 원하는 구현이 주입된다.', '실행 위치를 바꾸는 것과 무엇을 바인딩할지는 별개다. 모듈 구성이 그대로라 어디서 돌리든 같은 가짜 저장소가 주입된다.', false),

-- 문제 4742
(12823, 4742, 'Stateless 컴포저블에 상태를 직접 주입한 테스트라 ViewModel을 바꾸지 않고도 실패 상태를 그대로 재현할 수 있다.', 'setContent가 띄운 것은 ViewModel을 스스로 가져다 쓰는 화면이라 상태를 밖에서 넣을 통로가 없다. 상태를 인자로 받는 컴포저블을 따로 띄워야 이 장점이 생긴다.', false),
(12824, 4742, '노드를 텍스트 대신 testTag로 찾게 바꾸면 할인 계산이 바뀌어도 이 테스트는 깨지지 않는다.', 'testTag는 문구가 바뀌어도 노드를 찾게 해 주는 이름표일 뿐이다. 단언하는 값이 9,000원인 이상 계산이 바뀌면 노드를 찾는 방식과 무관하게 실패한다.', false),
(12825, 4742, '할인 계산이 그대로여도 통화 표기나 문구만 바뀌면 이 테스트가 깨진다. 금액이 맞는지는 상태를 만드는 쪽에서 확인해야 한다.', '화면 문구에 로직 검증을 매달면 표시 형식이 바뀔 때마다 테스트를 고치게 된다. 계산은 ViewModel 단위 테스트로 내리고, 화면은 주어진 상태를 제대로 보여 주는지만 맡는다.', true),
(12826, 4742, '컴포저블만 단독으로 띄우는 방식이라 에뮬레이터를 켜지 않아도 JVM에서 그대로 실행된다.', 'createComposeRule은 기본적으로 계측 환경에서 돌고, 이 테스트는 Hilt 그래프에서 ViewModel까지 가져온다. JVM에서 돌리려면 Robolectric 같은 장치가 따로 필요하다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1536, 4743, 'Dispatchers.setMain,setMain,Dispatchers.setMain(),setMain()', 'JVM 테스트에는 안드로이드 메인 루퍼가 없어 Dispatchers.Main이 초기화되지 못한다. viewModelScope는 컨텍스트에 Dispatchers.Main을 품고 있어서, 그 안에서 어떤 디스패처로 launch하든 예외가 먼저 난다. Dispatchers.setMain(테스트 디스패처)로 메인 디스패처를 테스트용으로 갈아 끼우면 예외가 사라지고, 테스트가 끝나면 resetMain()으로 되돌리는 것이 짝이다. 30개 클래스마다 같은 교체와 복구를 반복하지 않으려고 이 한 쌍을 Rule로 감싼다. 테스트 본문을 가상 시간 위에서 돌리는 runTest와는 역할이 다르다. runTest는 delay를 건너뛰며 본문을 실행하는 블록이고, setMain은 viewModelScope가 쓸 디스패처 자체를 바꾼다. 둘 중 하나만 빠져도 증상이 다르게 나타나므로 함께 기억해 두면 좋다.'),
       (1537, 4744, 'advanceUntilIdle,advanceUntilIdle(),testScheduler.advanceUntilIdle(),testScheduler.advanceUntilIdle', 'StandardTestDispatcher는 코루틴을 곧바로 실행하지 않고 스케줄러에 예약만 해 둔다. 그래서 onQueryChanged를 부른 직후에 상태를 읽으면 조회가 시작도 되지 않아 결과가 비어 있다. advanceUntilIdle()은 예약된 코루틴이 더 없을 때까지 가상 시간을 밀어 주므로, 200ms 디바운스처럼 시간을 기다리는 구간도 실제로 기다리지 않고 지나가 단언 시점에는 조회가 끝나 있다. 당장 실행할 수 있는 것만 처리하는 runCurrent()로는 디바운스 지연을 넘기지 못한다는 점에서 구분된다. 앞서 쓰던 UnconfinedTestDispatcher는 코루틴을 즉시 실행해 이런 호출이 필요 없지만 실제 앱의 실행 순서와 달라질 수 있어, 동시성 순서 자체를 검증할 때는 StandardTestDispatcher와 이 함수를 함께 쓰는 쪽이 맞다.');

-- =====================================================
-- Lesson 918: 안드로이드 테스트 설계: 프레임워크 분리부터 상태 흐름 검증까지
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5687, 918, '아래 ViewModel에서 안드로이드 프레임워크 의존을 없애는 방법으로 옳은 것은?', '```kotlin
class OrderViewModel(
    private val context: Context,
    private val repository: OrderRepository,
) : ViewModel() {

    private val _uiState = MutableStateFlow<OrderUiState>(OrderUiState.Loading)
    val uiState: StateFlow<OrderUiState> = _uiState.asStateFlow()

    fun load(orderId: Long) = viewModelScope.launch {
        _uiState.value = runCatching { repository.getOrder(orderId) }.fold(
            onSuccess = { OrderUiState.Success(it) },
            onFailure = { OrderUiState.Error(context.getString(R.string.order_load_failed)) },
        )
    }
}
```

앱은 한국어와 영어를 지원하고, 오류 문구는 기기의 언어 설정을 따라야 한다. OrderRepository는 이미 인터페이스로 주입받고 있다.', 'OBJECTIVE'),
       (5688, 918, '아래 요구를 테스트로 검증하는 방법으로 옳은 것은?', 'PaymentViewModel은 결제가 성공하면 분석 SDK를 감싼 AnalyticsTracker 인터페이스의 log("purchase_completed", amount)를 부른다. 이 호출은 uiState에도, 화면에도 아무 흔적을 남기지 않는다.

지난 배포에서는 이 이벤트가 결제 한 번에 두 번씩 전송돼 매출 집계가 부풀려졌다. 팀은 같은 버그가 다시 들어오면 PR마다 도는 JVM 단위 테스트에서 잡히게 하려 한다. PaymentRepository는 이미 인메모리 가짜 구현(Fake)으로 대체해 쓰고 있다.', 'OBJECTIVE'),
       (5689, 918, '아래 방식으로 작성한 UI 테스트에 대한 설명으로 옳은 것은?', '주문 화면을 두 겹의 컴포저블로 나눴다. 바깥의 OrderRoute는 ViewModel에서 uiState를 수집해 안쪽으로 넘기기만 한다. 안쪽의 OrderScreen은 ViewModel을 전혀 모르고, 표시할 상태(OrderUiState)와 재시도 버튼을 눌렀을 때 부를 람다(onRetry)를 매개변수로만 받는다. UI 테스트는 createComposeRule()로 OrderScreen 하나만 띄우고, setContent 안에서 상태와 람다를 테스트가 직접 만들어 넘긴다.', 'OBJECTIVE'),
       (5690, 918, '아래 실행 결과가 나온 원인과 고치는 방법으로 옳은 것은?', '```kotlin
object FakeCartRepository : CartRepository {
    val items = mutableListOf<CartItem>()
    override suspend fun add(item: CartItem) { items += item }
    override suspend fun getAll(): List<CartItem> = items.toList()
}

class CartViewModelTest {
    @get:Rule val mainDispatcherRule = MainDispatcherRule()

    @Test
    fun 상품을_담으면_개수가_1이_된다() = runTest {
        val viewModel = CartViewModel(FakeCartRepository)
        viewModel.add(CartItem(id = 7L))
        assertEquals(1, viewModel.uiState.value.count)
    }

    @Test
    fun 처음_연_장바구니는_비어_있다() = runTest {
        val viewModel = CartViewModel(FakeCartRepository)
        viewModel.load()
        assertTrue(viewModel.uiState.value.isEmpty)
    }
}
```

| 실행 방법 | 담기 테스트 | 빈 장바구니 테스트 |
| --- | --- | --- |
| 빈 장바구니 테스트만 단독 실행 | - | 통과 |
| 클래스 전체 실행 (담기 → 빈 장바구니 순) | 통과 | 실패 |
| 클래스 전체 실행 (빈 장바구니 → 담기 순) | 통과 | 통과 |', 'OBJECTIVE'),
       (5691, 918, '아래 상황에서 테스트 의존성으로 새로 추가한 라이브러리의 이름은?', '상품 목록 화면에서 로딩 스피너가 한 번도 보이지 않는 버그가 배포됐다. ViewModel이 Loading을 건너뛰고 곧바로 Success를 내보내고 있었는데, 기존 테스트는 load()를 부른 뒤 uiState.value 하나만 읽어 Success인지 확인했기 때문에 그대로 통과했다.

버그를 고친 뒤 팀은 테스트 의존성을 하나 추가하고 테스트를 아래처럼 바꿨다. (가짜 저장소는 응답 전에 delay(100)으로 잠시 멈춘다.)

```kotlin
@Test
fun 불러오는_동안_Loading을_거친다() = runTest {
    viewModel.uiState.test {
        assertEquals(ProductUiState.Idle, awaitItem())
        viewModel.load()
        assertEquals(ProductUiState.Loading, awaitItem())
        assertTrue(awaitItem() is ProductUiState.Success)
    }
}
```

일부러 예전 버그를 되살려 돌려 보자, 이 테스트는 Loading을 기대한 줄에서 실패했다.', 'SUBJECTIVE'),
       (5692, 918, '아래 테스트에서 ① 시점의 uiState 값은?', '```kotlin
class ProfileViewModel(private val repository: ProfileRepository) : ViewModel() {

    private val _uiState = MutableStateFlow<ProfileUiState>(ProfileUiState.Idle)
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    fun refresh() {
        _uiState.value = ProfileUiState.Loading
        viewModelScope.launch {
            _uiState.value = ProfileUiState.Success(repository.get())
        }
    }
}

class ProfileViewModelTest {
    @get:Rule val mainDispatcherRule = MainDispatcherRule(StandardTestDispatcher())

    @Test
    fun refresh_직후의_상태() = runTest {
        val viewModel = ProfileViewModel(FakeProfileRepository())   // get()은 멈추지 않고 곧바로 값을 돌려준다

        viewModel.refresh()
        val state = viewModel.uiState.value   // ①
    }
}
```

MainDispatcherRule은 테스트가 시작될 때 넘겨받은 디스패처로 Dispatchers.setMain을 부르고, 끝나면 Dispatchers.resetMain을 부른다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5687
(15339, 5687, 'ViewModel 대신 AndroidViewModel을 상속하고, getApplication()으로 받은 Application에서 오류 문구를 꺼낸다.', 'Application도 Context를 상속한 프레임워크 타입이다. 문구를 받아 오는 통로만 바뀌었을 뿐, getString을 부르려면 여전히 안드로이드 구현이 있어야 해서 의존이 그대로 남는다.', false),
(15340, 5687, '오류 상태에는 문자열 리소스 ID만 담고, 이를 실제 문구로 바꾸는 일은 화면의 stringResource()에 맡긴다.', '상태에는 어떤 문구인지 가리키는 정수만 남아 ViewModel이 순수 Kotlin이 되고, 테스트는 ID만 비교하면 된다. 기기 언어에 맞는 문구는 화면이 리소스를 읽을 때 골라지므로 다국어 요구도 지켜진다.', true),
(15341, 5687, 'Context를 WeakReference로 감싸 넘겨, ViewModel이 화면보다 오래 살아도 Context를 붙잡지 않게 한다.', '메모리 누수를 막는 것과 프레임워크 의존을 끊는 것은 별개 문제다. 감싼 참조를 꺼내 getString을 부르는 순간 다시 안드로이드 구현이 필요하다.', false),
(15342, 5687, '오류 문구를 ViewModel 안에 한국어 문자열 상수로 직접 적어, 문구를 꺼내는 데 Context가 필요 없게 한다.', 'Context는 사라지지만 문구가 코드에 고정돼 기기 언어가 영어여도 한국어가 나온다. 본문의 다국어 요구를 깨뜨리므로 의존을 없애는 올바른 방법이 아니다.', false),

-- 문제 5688
(15343, 5688, 'AnalyticsTracker도 인메모리 가짜 구현으로 바꾸고, 결제 뒤 uiState가 Success가 됐는지를 단언한다.', '가짜 구현으로 바꿔도 단언이 uiState뿐이면 이벤트가 몇 번 나갔는지는 보지 않는다. 전송이 상태에 흔적을 남기지 않으니 두 번 보내는 버그가 들어와도 그대로 통과한다.', false),
(15344, 5688, '결제 화면을 Compose UI 테스트로 띄워 결제 버튼을 누른 뒤, 완료 문구가 한 번만 보이는지 확인한다.', '이벤트 전송은 화면에 아무것도 그리지 않으므로 완료 문구가 한 번 보이는 것과 전송 횟수는 무관하다. 화면 표시로 로직을 확인하려 하면 느려지기만 하고 버그는 놓친다.', false),
(15345, 5688, 'PaymentRepository를 MockK로 바꾸고, 결제 API가 정확히 한 번 호출됐는지 verify로 확인한다.', '결제 API가 한 번 불려도 로그를 두 군데서 부르면 이벤트는 두 번 나간다. 검증 대상이 엇나갔고, 저장소 같은 핵심 협력 객체를 모의 객체(Mock)로 바꾸면 리팩터링 때마다 쉽게 깨진다.', false),
(15346, 5688, 'AnalyticsTracker를 MockK로 만들고, log가 그 이벤트 이름과 금액으로 정확히 한 번 불렸는지 verify한다.', '분석 SDK처럼 호출 자체가 목적인 부수효과는 결과 상태로 드러나지 않는다. 이런 협력 객체는 모의 객체로 대체해 무엇이 어떤 인자로 몇 번 불렸는지 확인하는 행위 기반 검증이 맞다.', true),

-- 문제 5689
(15347, 5689, '서버 오류나 빈 목록처럼 실제 네트워크로는 만들기 번거로운 화면도, 네트워크 없이 곧바로 띄워 확인할 수 있다.', '상태를 인자로 받는 컴포저블에는 어떤 상태든 테스트가 만들어 넣을 수 있다. 저장소가 예외를 던지게 준비하거나 서버를 흉내 낼 필요 없이 Error 상태 하나로 재시도 버튼 표시를 확인한다.', true),
(15348, 5689, '재시도 버튼을 누르면 ViewModel이 저장소를 다시 불러 상태를 Loading으로 바꾸는지까지 함께 확인된다.', '띄운 것은 OrderScreen뿐이라 ViewModel도 저장소도 없다. 버튼을 눌렀을 때 넘겨준 onRetry가 불렸는지까지가 이 테스트의 범위이고, 그 뒤의 상태 전환은 ViewModel 단위 테스트가 맡는다.', false),
(15349, 5689, '상태를 직접 넘기므로 쿠폰 할인액 같은 계산이 맞는지도 화면 문구를 통해 이 테스트에서 검증하는 편이 낫다.', '상태를 직접 넣으면 계산은 아예 일어나지 않고 넣은 값이 그대로 보일 뿐이다. 계산은 ViewModel·UseCase 단위 테스트에서, 화면은 주어진 상태를 제대로 보여 주는지만 검증한다.', false),
(15350, 5689, 'OrderScreen이 쓰는 의존성은 Hilt가 넣어 주므로, 테스트 클래스에 @HiltAndroidTest와 HiltAndroidRule이 필요하다.', 'OrderScreen은 필요한 것을 모두 매개변수로 받아 주입받을 의존성이 없다. Hilt 설정은 ViewModel을 가져오는 OrderRoute 쪽 사정이고, 이 테스트는 createComposeRule()만으로 충분하다.', false),

-- 문제 5690
(15351, 5690, 'UnconfinedTestDispatcher가 코루틴을 곧바로 실행해 두 테스트의 코루틴 순서가 뒤섞였다. StandardTestDispatcher로 바꾸고 단언 앞에 advanceUntilIdle()을 넣는다.', '각 테스트는 자기 runTest가 끝나야 다음 테스트가 시작되므로 두 테스트의 코루틴이 서로 끼어들 틈이 없다. 디스패처를 바꿔도 object에 쌓인 상품은 그대로라 같은 순서에서 같은 실패가 난다.', false),
(15352, 5690, 'Rule이 클래스 전체에 한 번만 적용돼 두 번째 테스트에서는 메인 디스패처가 원래대로 돌아갔다. 테스트마다 setMain을 직접 부른다.', '@get:Rule은 테스트 메서드마다 starting과 finished를 부른다. 메인 디스패처가 빠졌다면 단언 실패가 아니라 초기화 예외가 나고, 순서를 바꾸면 둘 다 통과하는 결과와도 맞지 않는다.', false),
(15353, 5690, '두 테스트가 싱글턴 가짜 저장소 하나를 나눠 써서 앞에서 담은 상품이 뒤 테스트에 남는다. 테스트마다 새 인스턴스를 만들어 넘긴다.', 'object는 JVM에 하나만 만들어져 담기 테스트가 넣은 상품이 빈 장바구니 테스트까지 남는다. 단독 실행이나 반대 순서에서는 통과하는 것이 그 증거다. class로 바꿔 테스트마다 새로 만들면 순서와 무관해진다.', true),
(15354, 5690, '가짜 구현은 인메모리 상태를 가지므로 어떻게 만들어도 테스트 사이에 상태가 남는다. MockK 모의 객체로 바꿔 getAll의 반환값을 지정한다.', '상태가 남는 원인은 가짜 구현 자체가 아니라 그것을 싱글턴으로 공유한 데 있다. 테스트마다 새로 만들면 충분하고, 모의 객체로 바꾸면 오히려 호출 방식에 결합돼 리팩터링에 약해진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1852, 5691, 'Turbine,터빈,app.cash.turbine,Turbine 라이브러리,터빈 라이브러리', 'Turbine은 Flow에 test { } 블록을 붙여, 방출된 값을 awaitItem()으로 하나씩 순서대로 꺼내 확인하게 해 준다. uiState.value는 읽는 순간의 최신 값 하나만 돌려주므로 중간에 Loading을 거쳤는지 건너뛰었는지 구분하지 못하고, 그래서 최종 상태만 맞으면 스피너가 뜨지 않는 버그도 통과했다. backgroundScope에서 collect만 걸어 두는 방법은 stateIn(WhileSubscribed)처럼 구독자가 있어야 움직이는 흐름을 깨워 value를 갱신시킬 뿐, 어떤 값이 어떤 순서로 나왔는지는 따로 모아 비교해야 한다. MockK의 verify가 협력 객체의 호출을 확인하는 도구라면, Turbine은 상태 흐름 자체를 순서대로 확인하는 도구라는 점에서 구분된다.'),
       (1853, 5692, 'Loading,ProfileUiState.Loading,로딩,Loading 상태,로딩 상태', 'refresh()의 첫 줄 대입은 코루틴 밖에서 곧바로 실행되므로 Loading은 호출 즉시 기록된다. 반면 viewModelScope.launch 블록은 Rule이 메인 디스패처로 넣은 StandardTestDispatcher 위에서 곧바로 돌지 않고 스케줄러에 예약만 된다. 테스트 본문이 advanceUntilIdle()을 부르거나 멈춰 기다리기 전까지 예약된 코루틴은 실행되지 않으므로, ① 시점에는 Success로 바뀌기 전의 Loading이 남아 있다. 초기값 Idle을 떠올렸다면 launch 바깥의 대입까지 미뤄진다고 본 것이고, Success를 떠올렸다면 코루틴이 그 자리에서 끝까지 실행된다고 본 것이다. 후자는 UnconfinedTestDispatcher의 동작으로, Rule에 그 디스패처를 넘겼다면 ①은 Success가 된다.');
