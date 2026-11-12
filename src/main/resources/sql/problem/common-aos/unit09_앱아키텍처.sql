-- Unit: 앱 아키텍처 (Unit ID: 100)
-- Chapter: AOS (Chapter ID: 8)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (526, 100, '단일 진실 공급원과 유스케이스 분리'),
       (684, 100, '도메인 모델과 의존성 주입'),
       (842, 100, '단방향 흐름과 리포지터리, 모듈 경계');

-- =====================================================
-- Lesson 526: 단일 진실 공급원과 유스케이스 분리
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3335, 526, '아래 코드로 만든 화면에서 실제로 나타나는 동작으로 옳은 것은?', '```kotlin
class OrderListFragment : Fragment(R.layout.fragment_order_list) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        binding.progress.isVisible = true
        viewLifecycleOwner.lifecycleScope.launch {
            val response = retrofit.create(OrderApi::class.java).getOrders()
            binding.list.adapter = OrderAdapter(response.items)
            binding.progress.isVisible = false
        }
    }
}
```

이 프래그먼트 밖에 주문 목록을 보관하는 클래스는 없다. 구성 변경으로 프래그먼트가 재생성되면 위 onViewCreated가 다시 실행된다.', 'OBJECTIVE'),
       (3336, 526, '아래 레이어 구분표를 바탕으로 옳지 않은 것은?', '| 레이어 | 구성 요소 | 알아도 되는 것 | 몰라야 하는 것 |
|---|---|---|---|
| UI | Activity·Fragment, ViewModel | UiState, 사용자 이벤트 | HTTP 상태 코드, SQL, DTO |
| Domain | UseCase, 도메인 모델 | Repository 인터페이스 | 안드로이드 프레임워크, 구현체 |
| Data | Repository, DataSource, DTO·Entity | Retrofit, Room, DataStore | UiState, 화면 구조 |

의존 방향은 UI → Domain → Data 한 방향이며 역방향 참조는 두지 않는다.', 'OBJECTIVE'),
       (3337, 526, '아래 데이터 흐름 규칙을 적용했을 때 따라오는 결과로 옳은 것은?', '이 앱에서 화면에 필요한 값은 모두 상태 홀더가 만든 객체 하나에 담겨 UI로 내려간다. UI는 그 객체를 받아 그리기만 하고, 버튼이 눌리거나 목록이 아래로 당겨지면 화면을 직접 고치는 대신 그 사실만 상태 홀더로 올린다. 상태를 바꾸는 코드는 상태 홀더 안에만 둔다.', 'OBJECTIVE'),
       (3338, 526, '아래 코드로 만든 화면을 회전했을 때 나타나는 현상과 그 원인으로 옳은 것은?', '```kotlin
data class LoginUiState(
    val isLoading: Boolean = false,
    val toastMessage: String? = null
)

class LoginViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    fun onLoginFailed() {
        _uiState.update { it.copy(isLoading = false, toastMessage = "로그인에 실패했습니다") }
    }
}
```

```kotlin
// LoginFragment.onViewCreated
viewLifecycleOwner.lifecycleScope.launch {
    viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.uiState.collect { state ->
            binding.progress.isVisible = state.isLoading
            state.toastMessage?.let { Toast.makeText(requireContext(), it, Toast.LENGTH_SHORT).show() }
        }
    }
}
```

로그인이 한 번 실패해 토스트가 뜬 직후 사용자가 화면을 회전한다. toastMessage를 다시 null로 되돌리는 코드는 어디에도 없다.', 'OBJECTIVE'),
       (3339, 526, '아래 상황에서 팀이 새로 세운 설계 원칙을 가리키는 용어는?', '같은 주문 정보를 주문 목록·주문 상세·알림 화면이 각각 서버에서 받아 그렸다. 그 결과 한 주문이 목록에서는 배송중, 상세에서는 결제완료로 보인다는 문의가 한 달에 40건 넘게 접수됐다. 팀은 세 화면이 모두 로컬 DB(Room)만 관찰하게 바꾸고, 서버 응답은 화면으로 바로 보내지 않고 DB에 써 넣는 데에만 쓰도록 고쳤다. 그 뒤로는 어느 화면을 열어도 같은 주문이 같은 값으로 보인다.', 'SUBJECTIVE'),
       (3340, 526, '아래 상황에서 팀이 새로 분리해 낸 구성 요소의 이름은?', '장바구니·주문서·마이페이지 세 화면의 ViewModel이 저마다 회원 등급 조회와 보유 쿠폰 조회를 부른 뒤, 두 결과를 합쳐 최종 할인율을 계산하는 코드를 각각 갖고 있었다. 할인 정책이 한 번 바뀌자 세 곳 중 두 곳만 수정돼 화면마다 다른 금액이 표시됐다. 팀은 이 계산을 안드로이드 의존성이 없는 클래스 하나로 옮기고 operator fun invoke() 하나만 노출하게 만든 뒤, 세 ViewModel이 그것을 주입받아 쓰도록 바꿨다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3335
(9067, 3335, '받아 온 목록은 어댑터에 남아 있어 프래그먼트가 다시 만들어져도 서버를 다시 부르지 않는다.', '어댑터는 프래그먼트 뷰와 함께 버려진다. 목록을 담아 둘 상태 홀더가 없으니 재생성 때마다 요청이 처음부터 다시 나간다.', false),
(9068, 3335, '프래그먼트가 다시 만들어질 때마다 같은 목록을 서버에서 새로 받고, 응답이 오기 전까지 목록 자리는 비어 있다.', '받아 온 데이터가 뷰에만 담겨 있어 재생성과 함께 사라진다. ViewModel 같은 상태 홀더에 UiState로 두면 재생성 뒤 최신 상태를 다시 그리기만 하면 된다.', true),
(9069, 3335, '요청이 예외로 끝나면 진행 표시가 자동으로 사라지고 빈 목록만 남는다.', '예외가 나면 isVisible = false 줄까지 가지 못해 진행 표시가 그대로 남는다. 로딩과 실패를 한 상태 객체로 다루지 않을 때 나오는 전형적인 증상이다.', false),
(9070, 3335, '서버 호출이 메인 스레드에서 실행돼 응답이 올 때까지 화면 입력이 멈춘다.', 'suspend 함수로 만든 Retrofit 호출은 내부에서 백그라운드로 넘어가므로 메인 스레드를 막지 않는다. 문제는 멈춤이 아니라 데이터를 둘 자리가 없다는 점이다.', false),

-- 문제 3336
(9071, 3336, '서버 응답 객체를 그대로 ViewModel까지 올려 필드를 꺼내 쓰면 표의 UI 행 규칙을 어긴다.', 'DTO는 Data 레이어 안에서만 쓰고 밖으로는 도메인 모델로 바꿔 내보낸다. 그래야 서버 필드명이 바뀌어도 화면 코드는 그대로다. 참인 진술이라 답이 아니다.', false),
(9072, 3336, 'UseCase를 에뮬레이터 없이 JVM 단위 테스트로 돌리려면 생성자에서 Context를 받지 않아야 한다.', 'Domain 행은 안드로이드 프레임워크를 몰라야 한다. Context를 끌어들이는 순간 순수 코틀린 테스트가 불가능해진다. 참인 진술이라 답이 아니다.', false),
(9073, 3336, 'Repository가 Retrofit 예외를 도메인 오류로 바꿔 돌려주는 것은 표의 Data 행과 어긋나지 않는다.', 'Retrofit·Room을 아는 쪽이 Data 행이고, 오류 변환은 그 지식이 위로 새지 않게 막는 일이다. 경계를 지키는 동작이므로 참인 진술이고 답이 아니다.', false),
(9074, 3336, '화면에 띄울 오류 문구와 진행 표시 여부를 정해 내려보내는 일은 표에서 Data 행의 책임이다.', 'Data 행은 UiState와 화면 구조를 몰라야 한다. 문구 선택과 로딩 표시는 UiState를 만드는 ViewModel의 결정이다. 표에 정면으로 어긋나는 거짓 진술이라 이것이 답이다.', true),

-- 문제 3337
(9075, 3337, '상태 객체가 하나뿐이라 값이 조금만 바뀌어도 화면 전체 뷰를 매번 새로 만들어 붙여야 한다.', '상태를 한 객체로 모으는 것과 뷰를 다시 만드는 것은 별개다. 그리기 함수가 바뀐 값만 뷰에 반영하면 되므로 갱신 비용을 이유로 단일 상태를 피할 근거가 없다.', false),
(9076, 3337, '상태를 바꾸는 곳이 하나이므로 여러 코루틴이 동시에 이벤트를 올려도 잠금 없이 순서가 보장된다.', '변경 지점이 한 곳인 것과 동시 접근이 안전한 것은 다른 이야기다. 갱신 연산 자체가 원자적이어야 하며, 흐름을 한 방향으로 묶었다고 경쟁 상태가 사라지지는 않는다.', false),
(9077, 3337, '화면이 다시 만들어져도 마지막 상태 객체를 한 번 더 그리면 되므로 값을 되살리는 코드가 줄어든다.', '그릴 값이 상태 홀더 쪽에 모여 있어 UI는 최신 객체를 받아 다시 그리기만 하면 된다. 뷰마다 값을 저장하고 복원하던 코드가 사라지는 것이 이 규칙의 실질적 이득이다.', true),
(9078, 3337, 'UI가 값을 직접 고치지 못하므로 입력 반영이 한 단계 늦어져 즉각 반응이 필요한 화면에는 쓸 수 없다.', '이벤트를 올리고 새 상태를 받는 경로는 같은 프레임 안에서 끝날 만큼 짧다. 흐름을 한 방향으로 묶는 것과 응답이 느려지는 것은 관계가 없다.', false),

-- 문제 3338
(9079, 3338, '회전 뒤 수집이 새로 시작되면서 최신 상태를 그대로 받아, 이미 보여 준 토스트가 한 번 더 뜬다.', 'StateFlow는 새로 붙은 수집자에게 현재 값을 먼저 내려 준다. 보여 준 뒤 지우지 않은 toastMessage가 남아 다시 소비되므로, 보여 준 뒤 null로 되돌리는 소비 처리가 필요하다.', true),
(9080, 3338, '회전으로 ViewModel이 새로 만들어져 toastMessage가 null로 돌아가므로 토스트는 다시 뜨지 않는다.', 'ViewModel은 구성 변경을 넘겨 살아남는다. 회전으로 사라지는 것은 프래그먼트의 뷰이며, 상태 객체는 직전 값을 그대로 들고 있다.', false),
(9081, 3338, 'StateFlow는 이전과 같은 값을 다시 내보내지 않으므로 회전 뒤에는 진행 표시조차 갱신되지 않는다.', '같은 값이 연달아 들어오면 거를 뿐, 수집을 새로 시작하면 현재 값을 한 번 내려 준다. 그래서 회전 직후 화면은 최신 상태로 정상적으로 그려진다.', false),
(9082, 3338, '토스트를 메인 스레드가 아닌 곳에서 호출해 회전 시점에 예외가 발생한다.', 'lifecycleScope는 메인 디스패처에서 시작하므로 수집 블록도 메인 스레드다. 원인은 스레드가 아니라 한 번 쓰고 지워야 할 값을 상태에 남겨 둔 데 있다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1068, 3339, '단일 진실 공급원,단일 진실 공급처,단일 신뢰 출처,단일 정보원,SSOT,Single Source of Truth,싱글 소스 오브 트루스', '데이터가 어디서 왔든 화면이 믿을 기준은 한 곳뿐이라는 원칙이 단일 진실 공급원(SSOT)이다. 안드로이드에서는 보통 로컬 DB를 기준으로 두고 네트워크 응답은 그 DB를 갱신하는 수단으로만 쓴다. 화면은 DB만 관찰하면 되므로 화면마다 값이 갈리는 일이 사라진다. 여러 소스를 감춰 주는 Repository는 이 원칙을 구현하는 자리이지 원칙 자체가 아니고, 캐시는 원본이 따로 있는 사본이라는 점에서 기준이 되는 저장소와 구분된다.'),
       (1069, 3340, '유스케이스,유스 케이스,유즈케이스,UseCase,Use Case,use case,인터랙터,Interactor', '여러 조회나 여러 Repository를 조합한 비즈니스 규칙을 여러 화면이 함께 쓸 때, 그 규칙을 안드로이드 의존성 없는 클래스로 뽑아 둔 것이 UseCase다. 하나의 동작만 하도록 operator fun invoke()만 노출하는 관례가 여기서 나온다. 데이터 출처를 감추고 가져오는 일을 맡는 Repository와는 역할이 다르고, 상태를 만들어 화면에 내려 주는 ViewModel과도 자리가 다르다. 반대로 Repository 메서드 하나를 그대로 넘겨주기만 하는 UseCase는 층만 늘리는 군더더기다.');

-- =====================================================
-- Lesson 684: 도메인 모델과 의존성 주입
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4283, 684, '아래 코드에서 ViewModel 쪽 동작에 대한 설명으로 옳은 것은?', '```kotlin
// Domain 레이어에 정의한 오류 타입
sealed class ProfileError : Exception() {
    object Offline : ProfileError()
    class Server(val code: Int) : ProfileError()
}
```

```kotlin
// Data 레이어
class ProfileRepositoryImpl(
    private val api: ProfileApi,   // Retrofit
    private val dao: ProfileDao    // Room
) : ProfileRepository {

    override suspend fun refreshProfile(id: Long): Result<Profile> =
        withContext(Dispatchers.IO) {
            try {
                val dto = api.getProfile(id)
                dao.upsert(dto.toEntity())
                Result.success(dto.toProfile())
            } catch (e: IOException) {
                Result.failure(ProfileError.Offline)
            } catch (e: HttpException) {
                Result.failure(ProfileError.Server(e.code()))
            }
        }
}
```

```kotlin
// UI 레이어
class ProfileViewModel(
    private val repository: ProfileRepository
) : ViewModel() {
    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    fun onRefresh(id: Long) {
        _uiState.update { it.copy(isRefreshing = true) }
        viewModelScope.launch {                     // Dispatchers.Main에서 시작
            val result = repository.refreshProfile(id)
            _uiState.update {
                it.copy(isRefreshing = false, profile = result.getOrNull() ?: it.profile)
            }
        }
    }
}
```', 'OBJECTIVE'),
       (4284, 684, '아래 코드와 상황에서 두 번째 새로고침이 끝난 직후의 화면 모습으로 옳은 것은?', '```kotlin
class NewsViewModel(
    private val repository: NewsRepository
) : ViewModel() {
    val isLoading = MutableStateFlow(false)
    val articles = MutableStateFlow<List<Article>>(emptyList())
    val errorMessage = MutableStateFlow<String?>(null)

    fun onRefresh() {
        isLoading.value = true
        viewModelScope.launch {
            repository.fetchNews()                    // Result<List<Article>> 반환
                .onSuccess { articles.value = it }
                .onFailure { errorMessage.value = "뉴스를 불러오지 못했습니다" }
            isLoading.value = false
        }
    }
}
```

Fragment는 세 값을 각각 따로 수집한다. isLoading이 true면 진행 표시를 보이고, articles는 목록에 그리며, errorMessage가 null이 아니면 목록 위에 오류 문구를 띄운다.

첫 새로고침은 네트워크 오류로 실패했다. 사용자가 이어서 한 번 더 새로고침했고, 두 번째 요청은 기사 12건을 받아 성공했다.', 'OBJECTIVE'),
       (4285, 684, '아래 상황에서 메모리에 벌어지는 일로 옳은 것은?', '주문 내역 화면의 OrderHistoryViewModel은 날짜 문구를 만들 때 쓰려고, 처음 생성될 때 팩토리로 넘겨받은 Activity를 프로퍼티에 담아 둔다. 그 뒤 ViewModel에 Activity를 다시 넘겨주는 코드는 없고, ViewModel 말고는 이전 Activity를 붙잡는 곳도 없다.

사용자는 이 화면을 연 채 기기를 세 번 회전했고, 지금도 같은 화면에 머물러 있다.', 'OBJECTIVE'),
       (4286, 684, '아래 두 앱의 UseCase 구성을 두고 내린 판단으로 옳은 것은?', '| 구분 | 앱 A | 앱 B |
|---|---|---|
| 화면 수 | 3개 | 28개 |
| UseCase 수 | 9개 | 6개 |
| UseCase가 하는 일 | 모두 Repository 메서드 하나를 호출해 결과를 그대로 반환 | 모두 Repository 두 개 이상의 결과를 합쳐 계산 (예: 회원 등급·쿠폰·배송비로 결제 금액 산출) |
| UseCase 하나를 쓰는 ViewModel 수 | 1개 | 2~4개 |', 'OBJECTIVE'),
       (4287, 684, '아래 상황의 Product 클래스처럼 쓰이는 객체를 가리키는 용어는?', '쇼핑 앱 서버가 상품 API 응답의 price 필드 형식을 바꿨다.

```text
변경 전: { "product_id": 31, "name": "무선 이어폰", "price": 12900 }
변경 후: { "product_id": 31, "name": "무선 이어폰", "price": { "amount": 12900, "currency": "KRW" } }
```

반년 전 비슷한 형식 변경 때는 ViewModel과 Fragment가 Retrofit이 파싱한 ProductResponse를 그대로 받아 필드를 꺼내 썼고, 파일 17개를 고쳐야 했다. 그 뒤 팀은 Repository가 ProductResponse를 아래 Product로 바꿔 돌려주도록 구조를 바꿨다.

```kotlin
data class Product(
    val id: Long,
    val name: String,
    val price: Money
)
```

이번 변경에서는 ProductResponse와 변환 함수 toProduct() 두 곳만 고쳤고, ViewModel·Fragment 코드는 한 줄도 바뀌지 않았다.', 'SUBJECTIVE'),
       (4288, 684, '아래 변경 후 CartViewModel이 CartRepository 구현체를 얻는 방식을 가리키는 용어는?', '장바구니 화면의 ViewModel을 아래처럼 바꿨다.

```kotlin
// 변경 전
class CartViewModel : ViewModel() {
    private val repository: CartRepository = CartRepositoryImpl(
        api = RetrofitClient.cartApi,
        dao = AppDatabase.getInstance().cartDao()
    )
    // ...
}
```

```kotlin
// 변경 후
class CartViewModel(
    private val repository: CartRepository
) : ViewModel() {
    // ...
}

// 변경 후 테스트 코드
val viewModel = CartViewModel(FakeCartRepository(items = listOf(sampleItem)))
```

변경 전에는 CartViewModel 테스트 42개가 에뮬레이터에서 실제 서버와 DB를 거쳐 한 번 도는 데 3분 10초가 걸렸고, 외부망이 막힌 CI에서는 전부 실패했다. 변경 후에는 같은 42개가 에뮬레이터 없이 JVM에서 1.2초 만에 통과한다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4283
(11595, 4283, '서버가 500을 응답하면 HttpException이 ViewModel까지 올라오므로 launch 블록 안에서 따로 잡아야 한다.', 'Repository가 HttpException을 잡아 ProfileError.Server(500)로 바꾼 뒤 Result에 담아 돌려준다. 예외가 위로 새지 않으니 ViewModel은 Retrofit 예외 타입을 몰라도 된다. 오류 변환이 Data 레이어 책임이라는 점을 놓친 오개념이다.', false),
(11596, 4283, 'refreshProfile이 끝난 뒤의 _uiState.update 호출은 IO 스레드 위에서 이뤄진다.', 'withContext는 블록을 마치면 호출한 코루틴의 원래 디스패처로 돌아온다. launch가 Main에서 시작했으므로 이어지는 update도 메인 스레드에서 실행된다. IO 전환이 호출 뒤까지 이어진다고 본 오개념이다.', false),
(11597, 4283, 'ViewModel은 디스패처를 따로 지정하지 않고 메인 스레드에서 그대로 불러도 화면이 멈추지 않는다.', 'Repository가 withContext(Dispatchers.IO)로 네트워크·DB 작업을 스스로 옮기므로 호출하는 쪽은 스레드를 신경 쓰지 않아도 된다(main-safe). 전환 책임이 Data 레이어에 있어 ViewModel마다 전환 코드를 반복하거나 빠뜨릴 일이 없다.', true),
(11598, 4283, 'withContext는 블록을 IO 스레드에 맡기고 곧바로 반환하므로 result에 아직 값이 없을 수 있다.', 'withContext는 블록이 끝날 때까지 코루틴을 일시 중단했다가 결과를 돌려준다. 곧바로 반환하는 것은 launch·async의 동작이다. 중단된 동안 메인 스레드가 풀려 화면이 멈추지 않을 뿐, result에는 늘 완료된 값이 담긴다.', false),

-- 문제 4284
(11599, 4284, '기사 12건 목록 위에 첫 실패 때의 오류 문구가 그대로 떠 있다.', 'onSuccess는 articles만 바꾸고, errorMessage를 null로 되돌리는 코드는 어디에도 없다. 세 값이 따로 갱신되니 성공한 목록과 오류 문구가 함께 보이는 모순된 조합이 생긴다. 상태를 UiState 하나로 묶어 요청 시작 때 copy(isLoading = true, errorMessage = null)로 한꺼번에 바꾸면 막힌다.', true),
(11600, 4284, '오류 문구는 사라지고 새로 받은 기사 12건 목록만 화면에 보인다.', '요청이 성공하면 이전 오류가 저절로 지워진다고 본 오개념이다. errorMessage는 코드가 직접 값을 바꿀 때만 바뀌는데, 이 코드에는 성공 시 null로 되돌리는 줄이 없어 첫 실패 문구가 남는다.', false),
(11601, 4284, '남아 있는 오류 값 때문에 목록은 갱신되지 않고 오류 문구만 보인다.', '세 값이 서로 영향을 준다고 본 오개념이다. errorMessage가 남아 있어도 onSuccess의 articles.value = it은 그대로 실행되고, Fragment는 articles를 목록에 그리므로 12건은 정상 표시된다.', false),
(11602, 4284, '진행 표시가 계속 돌고, 그 아래로 기사 12건 목록이 함께 보인다.', '로딩 값이 끝까지 남는다고 본 오개념이다. isLoading.value = false는 onSuccess·onFailure 뒤에 있어 성공·실패와 무관하게 실행되므로 진행 표시는 꺼진다. 이 코드에서 남는 값은 isLoading이 아니라 errorMessage다.', false),

-- 문제 4285
(11603, 4285, '회전할 때마다 ViewModel도 새로 만들어져 최신 Activity를 받으므로 남는 Activity가 없다.', 'ViewModel이 Activity와 함께 파괴된다고 본 오개념이다. ViewModel은 구성 변경을 넘어 살아남고, 팩토리는 ViewModel이 없을 때만 불리므로 회전 뒤에도 ViewModel은 처음 받은 참조를 그대로 쥐고 있다.', false),
(11604, 4285, '회전으로 파괴된 Activity 세 개가 모두 ViewModel에 붙잡혀 수거되지 못한다.', '회전 횟수만큼 참조가 쌓인다고 본 오개념이다. ViewModel은 한 번만 만들어져 첫 Activity 하나만 가리킨다. 두 번째·세 번째로 파괴된 Activity는 붙잡는 곳이 없어 정상적으로 수거된다.', false),
(11605, 4285, 'Activity의 onDestroy 시점에 프레임워크가 ViewModel의 Activity 참조를 자동으로 끊어 준다.', '프레임워크가 ViewModel 필드를 대신 비워 준다고 본 오개념이다. 정리 콜백인 onCleared()도 화면을 완전히 떠날 때만 불리고 회전 때는 불리지 않으므로, 참조를 끊는 일은 전적으로 코드 몫이다.', false),
(11606, 4285, '처음 넘겨받은 Activity 하나가 파괴된 뒤에도 수거되지 못한 채 남아 있다.', '오래 사는 ViewModel이 이미 파괴된 첫 Activity를 계속 가리켜 가비지 컬렉터가 수거하지 못하는 메모리 누수다. 문구는 리소스 ID로 넘겨 UI가 만들게 하고, Context가 꼭 필요하면 Application만 쓴다. Activity를 쥔 ViewModel은 JVM 단위 테스트도 어렵다.', true),

-- 문제 4286
(11607, 4286, '앱 B처럼 화면이 많은 앱은 조합할 것이 없는 Repository 메서드에도 UseCase를 하나씩 둬야 한다.', '앱이 크면 UseCase가 필수라고 본 오개념이다. UseCase를 둘지는 앱 크기가 아니라 여러 Repository 조합이나 로직 재사용이 있는지로 정한다. 한 줄 위임만 하는 UseCase는 큰 앱에서도 층만 늘리므로 ViewModel이 Repository를 바로 불러도 된다.', false),
(11608, 4286, '앱 A는 UseCase를 걷어내고 ViewModel이 Repository를 바로 불러도 권장 구조에 부합한다.', '앱 A의 UseCase는 조합도 재사용도 없이 Repository 호출을 그대로 넘기기만 한다. Domain 레이어는 선택 사항이라 작은 앱에서 생략해도 의존 방향(UI → Data)은 아래로 유지되고 권장 구조에 어긋나지 않는다.', true),
(11609, 4286, '앱 B의 결제 금액 계산은 Repository 여러 개를 다루므로 그중 한 Repository 안에 넣는 편이 권장된다.', '여러 Repository를 엮는 비즈니스 규칙은 Domain 레이어의 UseCase 몫이다. Repository는 자기 데이터의 단일 진실 공급원·캐시·오류 변환을 맡으며, 한 Repository가 다른 Repository를 끌어와 규칙까지 품으면 책임이 뒤섞인다.', false),
(11610, 4286, '앱 B의 UseCase는 여러 ViewModel이 함께 쓰므로 Context를 받아 화면 문구까지 만들어 주는 편이 좋다.', 'UseCase는 안드로이드 의존성이 없어야 JVM 단위 테스트가 가능하고 여러 화면에서 재사용된다. 문구 같은 표시 형식은 UI 레이어가 정하며, 공유된다는 이유로 Context를 들이면 오히려 재사용성과 테스트 가능성을 잃는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1384, 4287, '도메인 모델,도메인모델,domain model,도메인 객체,도메인객체,domain object,도메인 엔티티,domain entity', 'Repository가 서버 응답 형태(ProductResponse)를 앱이 쓰는 형태(Product)로 바꿔 내보낼 때, 그 앱 쪽 객체를 도메인 모델이라 한다. 서버 JSON 모양은 응답 클래스와 변환 함수 안에 갇히므로 형식이 바뀌어도 수정이 Data 레이어 안에서 끝나고, ViewModel·Fragment는 영향을 받지 않는다. 클린 아키텍처에서 말하는 도메인 엔티티도 같은 자리를 가리킨다. 헷갈리기 쉬운 옆 개념과 구분하면, ProductResponse처럼 네트워크 응답을 그대로 옮긴 객체는 DTO이고, Room 테이블의 한 행을 나타내는 객체는 Entity로, 둘 다 Data 레이어 안에서만 쓴다. 로딩 여부·오류 문구처럼 화면 한 장의 상태를 묶은 UiState는 ViewModel이 도메인 모델을 받아 만드는 UI 레이어 객체다.'),
       (1385, 4288, '의존성 주입,의존관계 주입,의존 주입,의존성주입,DI,Dependency Injection,생성자 주입,생성자주입,constructor injection,디펜던시 인젝션', '객체가 필요로 하는 협력 객체를 스스로 만들지 않고 바깥에서 만들어 넘겨받는 방식이 의존성 주입(DI)이고, 생성자 매개변수로 받는 형태를 생성자 주입이라 한다. 변경 전 CartViewModel은 CartRepositoryImpl·RetrofitClient·AppDatabase를 직접 만들어 실제 서버와 DB에 묶여 있었지만, 변경 후에는 CartRepository 인터페이스만 알기 때문에 테스트에서 가짜(Fake) 구현을 넣어 네트워크·기기 없이 돌릴 수 있다. 헷갈리기 쉬운 옆 개념과 구분하면, 의존성 역전 원칙(DIP)은 구현이 아닌 추상화에 의존하라는 설계 원칙이고 DI는 그 의존 대상을 어떻게 건네받을지를 정하는 기법이다. Hilt는 이 주입 코드를 자동으로 조립해 주는 도구일 뿐 기법 자체가 아니며, FakeCartRepository는 주입 덕분에 끼워 넣을 수 있게 된 테스트용 구현이다.');

-- =====================================================
-- Lesson 842: 단방향 흐름과 리포지터리, 모듈 경계
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5231, 842, '아래 코드에서 필터 적용 직후 응답이 도착했을 때 화면에 나타나는 모습으로 옳은 것은?', '```kotlin
// 한 액티비티 위에 목록 프래그먼트와 필터 프래그먼트가 함께 올라가 있다.
data class ProductListUiState(
    val isLoading: Boolean = false,
    val filter: Filter = Filter.None,
    val items: List<Product> = emptyList()
)

class ProductListViewModel(private val repository: ProductRepository) : ViewModel() {

    val uiState = MutableStateFlow(ProductListUiState())   // 바깥에서도 쓸 수 있게 열려 있다

    fun onRefresh() {
        uiState.update { it.copy(isLoading = true) }
        viewModelScope.launch {
            val loaded = repository.loadProducts()          // 필터를 적용하지 않은 전체 목록
            uiState.update { it.copy(isLoading = false, items = loaded) }
        }
    }
}
```

```kotlin
class FilterFragment : Fragment() {
    private val listViewModel: ProductListViewModel by activityViewModels()

    private fun onApplyClicked(filter: Filter) {
        listViewModel.uiState.value =
            listViewModel.uiState.value.copy(filter = filter, items = emptyList())
    }
}
```

목록 프래그먼트는 uiState를 수집해 filter를 칩으로, items를 목록으로 그린다. 사용자가 당겨서 새로고침을 해 onRefresh()의 요청이 아직 진행 중일 때 필터를 적용했고, 그 직후 요청 응답이 도착했다.', 'OBJECTIVE'),
       (5232, 842, '아래처럼 상태 정의를 바꿨을 때 따라오는 결과로 옳은 것은?', '```kotlin
// 변경 전
data class SearchUiState(
    val isLoading: Boolean = false,
    val results: List<Item> = emptyList(),
    val errorMessage: String? = null
)
```

```kotlin
// 변경 후
sealed interface SearchUiState {
    data object Loading : SearchUiState
    data class Success(val results: List<Item>) : SearchUiState
    data class Failure(val message: String) : SearchUiState
}
```

```kotlin
private fun render(state: SearchUiState) = when (state) {
    is SearchUiState.Loading -> showProgress()
    is SearchUiState.Success -> showList(state.results)
    is SearchUiState.Failure -> showError(state.message)
}
```

이 화면은 검색어를 고칠 때마다 목록을 서버에서 다시 받아 온다. 기획에서는 새 결과가 도착하기 전까지 직전 목록을 그대로 두고 그 위에 진행 표시만 겹쳐 달라고 요청했다.', 'OBJECTIVE'),
       (5233, 842, '아래 빌드 결과와 모듈 구성에 대한 설명으로 옳은 것은?', '```text
> Task :domain:compileKotlin FAILED
e: domain/usecase/GetOrderSummaryUseCase.kt:4:12 Unresolved reference: android
e: domain/usecase/GetOrderSummaryUseCase.kt:19:38 Unresolved reference: Context
```

```kotlin
// :domain/build.gradle.kts
plugins {
    id("java-library")
    kotlin("jvm")
}
dependencies { /* 안드로이드 관련 의존성 없음 */ }

// :data/build.gradle.kts
plugins { id("com.android.library") }
dependencies { implementation(project(":domain")) }

// :app/build.gradle.kts
plugins { id("com.android.application") }
dependencies {
    implementation(project(":domain"))
    implementation(project(":data"))
}
```

GetOrderSummaryUseCase는 주문 건수와 합계 금액을 계산한 뒤 "총 3건 · 42,000원" 형태의 문구까지 만들어 돌려주려고, Context에서 문자열 리소스를 읽는 코드를 넣었다.', 'OBJECTIVE'),
       (5234, 842, '아래 표의 구성에서 실제로 나타나는 문제로 옳은 것은?', '프로필 데이터를 쓰는 화면이 셋이다. 세 화면의 ViewModel은 공통 Repository 없이 같은 Retrofit ProfileApi와 같은 Room ProfileDao를 각각 주입받아, 캐시 사용 기준과 오류 처리를 저마다 구현했다.

| 화면 | 캐시 사용 기준 | 서버가 401을 돌려줄 때 | 스레드 전환 |
|---|---|---|---|
| 홈 | DB 값이 5분 이내면 그대로 사용 | 로그인 화면으로 이동 | withContext(Dispatchers.IO) |
| 설정 | 캐시를 쓰지 않고 매번 서버 호출 | 오류 문구 표시 | 지정하지 않음 |
| 알림 | DB 값이 24시간 이내면 그대로 사용 | 무시하고 빈 프로필 사용 | withContext(Dispatchers.IO) |

세 화면은 하단 탭으로 연결돼 있어 사용자가 어느 화면부터 열지는 그때그때 다르다.', 'OBJECTIVE'),
       (5235, 842, '아래처럼 코드를 바꾸면서 팀이 지키기로 한 규칙의 이름은?', '```kotlin
// 변경 전 — 장바구니 화면의 프래그먼트와 커스텀 뷰 여섯 곳에 비슷한 코드가 흩어져 있었다
fun onDeleteClicked(item: Item) {
    adapter.remove(item)
    binding.badge.text = (binding.badge.text.toString().toInt() - 1).toString()
    if (adapter.itemCount == 0) binding.empty.isVisible = true
}
```

```kotlin
// 변경 후
fun onDeleteClicked(item: Item) {
    viewModel.onDelete(item)
}

private fun render(state: CartUiState) {   // uiState가 새 값을 내보낼 때마다 호출된다
    adapter.submitList(state.items)
    binding.badge.text = state.items.size.toString()
    binding.empty.isVisible = state.items.isEmpty()
}
```

변경 전에는 "목록은 비었는데 배지는 3으로 남아 있다" 같은 화면 조합 버그가 한 스프린트에 23건 접수됐다. 변경 후 같은 유형은 2건으로 줄었다.', 'SUBJECTIVE'),
       (5236, 842, '아래 변경에서 팀이 새로 만든 구성 요소를 가리키는 용어는?', '상품 데이터를 쓰는 화면이 다섯 개로 늘어나는 동안, 각 ViewModel 안에 Retrofit 호출·Room 조회·DataStore의 마지막 동기화 시각 읽기가 비슷한 모양으로 복사됐다. 서버 주소 체계가 바뀌었을 때 고쳐야 할 파일이 14개였고, 그중 두 곳을 빠뜨려 특정 화면만 빈 목록이 나오는 장애가 났다.

```kotlin
// 변경 후 :data 모듈에 새로 만든 클래스가 바깥에 내놓는 것은 이 둘뿐이다
fun observeProducts(): Flow<List<Product>>
suspend fun refresh(): Result<Unit>
```

다섯 개의 ViewModel은 이 두 메서드만 부르고, 화면 쪽 코드에는 Retrofit·Room·DataStore 타입이 한 번도 등장하지 않는다. 같은 서버 주소 변경이 다시 왔을 때 고친 파일은 2개였다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5231
(14123, 5231, 'activityViewModels로 얻은 것은 프래그먼트마다 별개의 인스턴스라서 필터 프래그먼트가 고친 값은 목록 화면에 닿지 않는다.', 'activityViewModels는 액티비티의 ViewModelStore에서 같은 인스턴스를 찾아 돌려준다. 두 프래그먼트가 한 객체를 공유한다는 점을 놓친 오개념으로, 필터 적용은 목록 화면의 수집자에게 그대로 전달된다.', false),
(14124, 5231, '필터 칩은 적용된 채로 남고, 목록에는 필터가 반영되지 않은 전체 응답이 그려진다.', 'onRefresh의 update는 가장 최근 값을 읽어 items만 갈아 끼우므로 필터 프래그먼트가 넣은 filter는 살아남고 items만 전체 목록으로 덮인다. 상태를 바꾸는 자리가 두 곳으로 갈리면 이렇게 서로 맞지 않는 조합이 만들어진다.', true),
(14125, 5231, 'value에 직접 대입한 값은 update로 만든 값과 달리 수집자에게 전달되지 않는다.', 'value 대입과 update는 모두 같은 자리에 새 값을 내보내며, update는 읽고 고쳐 쓰는 과정을 한 덩어리로 묶어 줄 뿐이다. 두 방식이 전달 여부에서 갈린다고 본 오개념이다.', false),
(14126, 5231, '두 곳에서 같은 상태를 쓰려 하므로 나중 쓰기가 예외로 막히고 필터 적용이 취소된다.', 'MutableStateFlow는 여러 곳에서 쓰는 것을 막지 않는다. 예외 없이 조용히 덮어쓰기 때문에 오히려 문제가 늦게 드러난다. 충돌이 곧바로 오류로 보일 것이라 기대한 오개념이다.', false),

-- 문제 5232
(14127, 5232, '상태를 담는 타입이 셋으로 늘어난 만큼 상태를 만드는 코드 자리도 셋으로 나뉜다.', '타입 개수와 상태를 만드는 자리는 별개다. 어느 쪽 정의를 쓰든 새 상태를 만드는 곳은 상태 홀더 하나이며, 바뀐 것은 상태를 어떤 모양으로 표현하느냐뿐이다.', false),
(14128, 5232, 'when에서 빠뜨린 경우가 생겨도 컴파일은 통과하므로 그 상태에서는 화면이 빈 채로 남는다.', 'sealed로 선언하면 하위 타입이 고정돼 when이 모든 경우를 다루지 않을 때 컴파일 단계에서 막힌다. 새 상태를 추가할 때 빠뜨린 분기를 컴파일러가 짚어 주는 것이 이 방식의 이점이다.', false),
(14129, 5232, '오류 문구가 상태 타입 안으로 들어가므로 문구를 고르는 일이 Data 레이어 책임으로 넘어간다.', 'SearchUiState는 화면 한 장의 상태를 담은 UI 레이어 객체이고 문구를 고르는 일은 여전히 상태 홀더 몫이다. Repository는 도메인 오류만 돌려주며, 상태를 표현하는 모양이 바뀌었다고 책임 경계가 옮겨 가지는 않는다.', false),
(14130, 5232, '직전 목록 위에 진행 표시를 겹쳐 달라는 요청을 맞추려면 Loading이 이전 결과를 들고 있도록 타입을 다시 손봐야 한다.', '한 번에 한 상태만 고르게 만든 대가로 목록과 진행 표시가 함께 있는 조합도 같이 막힌다. 그 화면이 필요하면 Loading에 직전 결과를 담거나 Success에 새로고침 여부를 두는 식으로 타입을 다시 설계해야 한다.', true),

-- 문제 5233
(14131, 5233, '합계 계산만 :domain에 남기고 문구 만들기를 UI 레이어로 옮기면 모듈 구성을 그대로 둔 채 이 오류를 없앨 수 있다.', ':domain은 안드로이드 API를 볼 수 없는 순수 JVM 모듈이라 Context 참조가 컴파일 단계에서 걸렸다. 계산 결과는 값으로 돌려주고 문자열 리소스를 읽는 일은 Context를 가진 UI가 맡으면 경계를 지키면서 빌드가 지나간다.', true),
(14132, 5233, ':data가 :domain에 의존하므로 :domain의 UseCase에서 :data의 Room Entity를 바로 참조할 수 있다.', '의존은 :data에서 :domain으로 향하는 한 방향이라 :domain은 :data의 타입을 아예 볼 수 없다. 화살표가 양쪽으로 통한다고 본 오개념이며, 이 참조가 열리면 Domain이 저장 방식에 묶인다.', false),
(14133, 5233, ':app이 :domain과 :data를 함께 의존하므로 :domain 코드에서도 :app의 문자열 리소스 ID를 읽을 수 있다.', '의존은 :app에서 아래로 향할 뿐 거꾸로 흐르지 않는다. 최종 앱에 함께 담긴다는 사실과 각 모듈이 컴파일 시점에 무엇을 볼 수 있는지는 다른 이야기다.', false),
(14134, 5233, 'UseCase가 안드로이드 API를 쓸 수 없으므로 금액·날짜를 사람이 읽을 문구로 바꾸는 일은 Repository가 맡아야 한다.', 'Repository는 데이터와 오류를 다루고 화면 표현은 모른다. 표시 형식을 Data 레이어로 옮기면 경계가 다른 쪽에서 무너질 뿐이므로, 문구 만들기는 UI 레이어에 둔다.', false),

-- 문제 5234
(14135, 5234, '세 ViewModel이 같은 ProfileDao를 나눠 쓰므로 DB 접근이 한 줄로 밀려 화면 전환이 느려진다.', 'DAO를 함께 쓴다고 호출이 줄을 서지는 않는다. 표가 드러내는 문제는 속도가 아니라 같은 데이터를 다루는 규칙이 화면마다 다르다는 점이다.', false),
(14136, 5234, '캐시 기준이 화면마다 달라도 Room이 마지막 쓰기 시각을 기준으로 유효 기간을 하나로 맞춰 준다.', 'Room은 행을 저장하고 읽을 뿐 값이 낡았는지 판단하지 않는다. 만료 기준은 전적으로 코드가 정하므로 세 화면이 각자 정한 기준이 그대로 남는다.', false),
(14137, 5234, '토큰이 만료된 사용자가 어느 탭을 먼저 열었느냐에 따라 로그인 화면으로 가기도 하고 빈 프로필을 보기도 한다.', '같은 401을 두고 대응이 세 갈래로 갈려 사용자가 겪는 흐름이 진입 경로에 좌우된다. 오류 변환과 재인증 판단을 Repository 한 곳으로 모으면 어느 화면에서 시작하든 같은 결과가 나온다.', true),
(14138, 5234, '세 화면이 같은 ProfileApi를 쓰므로 서버 응답 필드가 바뀌면 세 곳 중 한 곳만 고치면 된다.', '응답 객체를 각 ViewModel이 직접 받아 쓰는 구조라 필드 변경은 세 곳 모두로 번진다. 응답을 도메인 모델로 바꾸는 자리를 하나로 모아야 고칠 곳이 한 군데로 줄어든다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1700, 5235, '단방향 데이터 흐름,단방향 데이터흐름,단방향 데이터 플로우,단방향 흐름,UDF,Unidirectional Data Flow,unidirectional data flow,유니디렉셔널 데이터 플로우', '상태는 상태 홀더에서 UI로 한 방향으로만 내려가고, 사용자 입력은 무슨 일이 있었는지만 알리는 이벤트가 되어 UI에서 상태 홀더로만 올라가는 규칙이 단방향 데이터 흐름(UDF)이다. 변경 후 코드에서 프래그먼트는 삭제 사실만 올리고 화면은 render가 받은 CartUiState 하나로만 그려지므로, 목록은 비었는데 배지는 3으로 남는 조합 자체가 만들어질 수 없다. 조합 버그가 23건에서 2건으로 줄어든 것이 그 결과다. 헷갈리기 쉬운 옆 개념과 구분하면, MVVM·MVI는 이 흐름을 구현하는 패턴의 이름이고 UDF는 그 패턴들이 공유하는 흐름 규칙이다. 단일 진실 공급원은 데이터의 기준 저장소가 하나라는 Data 레이어 원칙이라 상태가 어느 방향으로 흐르는지를 정하는 이 규칙과 층이 다르다. 양방향 데이터 바인딩은 뷰와 데이터가 서로를 고치도록 허용한다는 점에서 정반대편에 있다.'),
       (1701, 5236, '리포지터리,리포지토리,레포지터리,레포지토리,리파지토리,저장소,Repository,리포지터리 패턴,리포지토리 패턴', '여러 데이터 소스를 한 겹 뒤로 감추고 바깥에는 도메인 모델과 결과만 내보내는 Data 레이어 구성 요소가 리포지터리(Repository)다. Retrofit·Room·DataStore를 아는 코드가 이 클래스 한 자리로 모였기 때문에 서버 주소 체계가 바뀌어도 고칠 파일이 14개에서 2개로 줄었고, 화면마다 다른 조합을 쓰다 한두 곳을 빠뜨리던 장애도 사라졌다. observeProducts가 Flow를 내보내고 refresh가 갱신만 맡는 모양은, 로컬 DB를 단일 진실 공급원으로 두고 네트워크는 그 DB를 채우는 수단으로 쓰는 전형적인 구성이다. 헷갈리기 쉬운 옆 개념과 구분하면, 단일 진실 공급원은 이 클래스가 따르는 원칙이지 구성 요소의 이름이 아니다. DataSource는 Retrofit 호출이나 Room 접근 하나하나를 감싼 한 단계 아래 조각이라 이 클래스가 감추는 대상이고, 여러 Repository를 엮어 비즈니스 규칙을 담는 UseCase는 Domain 레이어에 있어 자리가 다르다.');
