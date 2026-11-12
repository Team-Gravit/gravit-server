-- Unit: 네트워크 계층 (Unit ID: 99)
-- Chapter: AOS (Chapter ID: 8)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (525, 99, '재시도 정책과 멱등성 키, 취소 예외'),
       (683, 99, '인터셉터 순서와 커넥션 풀, 지터'),
       (841, 99, 'URL 결합과 백오프 대기·오프라인 감지');

-- =====================================================
-- Lesson 525: 재시도 정책과 멱등성 키, 취소 예외
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3329, 525, '아래 인터셉터 등록 방식에 대한 설명으로 옳은 것은?', 'OkHttpClient.Builder에서 addNetworkInterceptor()로 등록한 인터셉터는 재시도·리다이렉트 추적·캐시 판정을 맡는 OkHttp 코어보다 뒤, 즉 소켓으로 바이트를 내보내기 바로 직전 자리에 놓인다.', 'OBJECTIVE'),
       (3330, 525, '아래 코드에서 서버가 두 요청 모두에 404를 응답했을 때의 동작으로 옳은 것은?', '```kotlin
interface UserApi {
    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: Long): UserDto

    @GET("users")
    suspend fun searchUsers(@Query("q") q: String): Response<List<UserDto>>
}

// 호출 측
val a = api.getUser(7)
val b = api.searchUsers("kim")
```', 'OBJECTIVE'),
       (3331, 525, '아래 재시도 정책 표를 바탕으로 옳지 않은 것은?', '| 요청 | 결과 | 앱의 처리 |
|---|---|---|
| GET /products | 소켓 타임아웃 | 500ms → 1초 → 2초 간격으로 최대 3회 재시도 |
| POST /orders | 연결 끊김 | 재시도하지 않고 사용자에게 결과 확인을 요청 |
| GET /products | 429, Retry-After: 3 | 3초 기다린 뒤 1회 재시도 |
| GET /products/9 | 404 | 재시도 없이 오류 화면 표시 |', 'OBJECTIVE'),
       (3332, 525, '아래 로그에서 마지막 12:00:00.210 요청이 다시 401을 받은 원인으로 옳은 것은?', '서버는 리프레시가 성공할 때마다 그 이전에 발급한 액세스 토큰을 즉시 무효화한다.

```
12:00:00.120  GET  /v1/orders   Bearer OLD            → 401
12:00:00.121  GET  /v1/profile  Bearer OLD            → 401
12:00:00.122  GET  /v1/cart     Bearer OLD            → 401
12:00:00.131  POST /v1/auth/refresh  (스레드 A)        → 200  access=T1
12:00:00.134  POST /v1/auth/refresh  (스레드 B)        → 200  access=T2
12:00:00.137  POST /v1/auth/refresh  (스레드 C)        → 200  access=T3
12:00:00.210  GET  /v1/orders   Bearer T1             → 401
```', 'OBJECTIVE'),
       (3333, 525, '아래 상황에서 중복 주문을 막기 위해 서버가 새로 요구한 헤더를 무엇이라 하는가?', '결제 화면에서 POST /orders가 응답 없이 타임아웃 났고, 앱이 같은 요청을 한 번 더 보내자 같은 장바구니로 주문이 2건 만들어졌다. 서버 팀은 주문 생성 요청마다 클라이언트가 만든 고유 값 하나를 헤더에 담아 보내도록 규격을 바꿨다. 이후 타임아웃 뒤 재전송에서는 두 번째 요청이 새 주문을 만들지 않고 첫 번째 주문의 결과를 그대로 돌려주었고, 같은 요청을 100회 재전송한 부하 테스트에서도 주문은 1건만 남았다.', 'SUBJECTIVE'),
       (3334, 525, '아래 코드의 catch가 잡아서는 안 되고 그대로 다시 던져야 하는 예외 타입의 이름은?', '```kotlin
suspend fun loadProfile(): Result<Profile> = try {
    Result.success(api.getProfile())   // 응답까지 평균 800ms
} catch (e: Exception) {
    Result.failure(e)
}
```

프로필 화면을 열고 300ms 만에 뒤로 가면 viewModelScope가 정리되는데, 로그에는 이미 사라진 화면에 오류 스낵바를 띄우려는 시도와 재시도 요청 1회가 남는다. 상위 코루틴은 자식이 정상적으로 끝났다고 보고 다음 작업을 그대로 이어서 실행한다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3329
(9051, 3329, '응답이 캐시에서 그대로 반환되는 요청에서도 intercept()가 한 번은 호출된다.', '캐시로 끝난 요청은 소켓을 열지 않으므로 코어 뒤에 놓인 이 인터셉터까지 내려가지 않는다. 캐시 응답도 지나가며 요청당 정확히 한 번 불리는 쪽은 코어 앞에 등록되는 애플리케이션 인터셉터다.', false),
(9052, 3329, '서버가 301로 한 번 리다이렉트하면 같은 호출에서 intercept()가 두 번 실행된다.', '리다이렉트 추적은 코어가 하고 그때마다 새 요청이 소켓으로 나간다. 코어 뒤에 있으니 네트워크 왕복 횟수만큼 불려 원본 요청과 리다이렉트된 요청을 각각 보게 된다.', true),
(9053, 3329, 'gzip으로 압축돼 도착한 응답 본문은 항상 압축이 풀린 상태로만 관찰된다.', '압축 해제도 코어가 담당하므로 코어 뒤 자리에서는 압축된 원본 바이트가 그대로 보인다. 풀린 본문만 보이는 것은 코어를 지나 되돌아온 뒤의 단계다.', false),
(9054, 3329, '앱 코드가 만든 원본 요청만 보이므로 OkHttp가 자동으로 붙이는 Host·Accept-Encoding 헤더는 나타나지 않는다.', '코어가 헤더를 다 채운 뒤 지나가는 자리라 실제 전송되는 요청이 그대로 보인다. 원본 요청만 보이는 것은 코어 앞에 놓인 애플리케이션 인터셉터의 특징이다.', false),

-- 문제 3330
(9055, 3330, '두 호출 모두 예외를 던지지 않고 반환되며, 실패 여부는 각각 code()로 확인한다.', 'UserDto를 직접 반환하는 getUser는 실패를 담아 돌려줄 자리가 없다. 본문 타입만 받는 시그니처에서는 상태 코드를 값으로 꺼낼 수 없어 Retrofit이 HttpException을 던진다.', false),
(9056, 3330, '두 호출 모두 HttpException을 던지므로 404는 try-catch로만 구분할 수 있다.', 'Response<T>로 감싼 searchUsers는 4xx·5xx도 예외가 아니라 값으로 받는다. isSuccessful이 false인 응답이 그대로 돌아오고 errorBody()로 오류 본문을 읽는다.', false),
(9057, 3330, 'getUser는 null을, searchUsers는 빈 리스트를 반환해 호출 측에서는 빈 값으로 처리된다.', 'Retrofit은 실패를 빈 값으로 바꾸지 않는다. 널이나 빈 리스트는 서버가 그런 본문을 성공 응답으로 보냈을 때 나오는 결과이고, 404는 그와 구분해야 하는 실패다.', false),
(9058, 3330, 'getUser는 HttpException을 던지고, searchUsers는 예외 없이 isSuccessful이 false인 응답을 돌려준다.', '반환 타입이 갈랐다. 본문 타입을 직접 받으면 실패를 던질 수밖에 없고, Response<T>로 감싸면 상태 코드와 errorBody()를 값으로 받아 화면 분기에 쓸 수 있다.', true),

-- 문제 3331
(9059, 3331, '첫 행의 500ms → 1초 → 2초 재시도는 retryOnConnectionFailure 기본값 덕분에 OkHttp가 알아서 해 주는 동작이다.', '거짓이다. OkHttp의 자동 재시도는 요청이 서버에 닿지 않은 것이 확실한 커넥션 실패에 한정된다. 타임아웃 뒤 간격을 늘려 가며 다시 보내는 일은 앱이 직접 짜 넣은 백오프다.', true),
(9060, 3331, '둘째 행에서 POST를 재시도하지 않은 것은 요청이 서버에 닿았을 수 있어 주문이 중복 생성될 위험이 있기 때문이다.', '참이다. 연결이 끊긴 시점에는 서버 도달 여부를 알 수 없다. 멱등하지 않은 생성 요청은 재전송이 곧 중복이라 기본은 재시도 금지다.', false),
(9061, 3331, '셋째 행에서 3초를 기다린 것은 서버가 헤더로 알려 준 대기 시간을 그대로 지킨 것이다.', '참이다. 429는 서버가 일시적으로 과부하임을 밝히는 응답이고 Retry-After는 언제 다시 오라는 안내다. 임의 간격으로 곧장 재시도하면 회복 중인 서버에 부하를 더한다.', false),
(9062, 3331, '넷째 행에서 404를 재시도하지 않는 것은 같은 요청을 다시 보내도 같은 실패가 돌아오기 때문이다.', '참이다. 4xx는 요청 자체가 잘못됐다는 뜻이라 재전송해도 결과가 바뀌지 않는다. 재시도가 값어치를 하는 쪽은 서버 사정이 나아질 수 있는 5xx·429와 네트워크 오류다.', false),

-- 문제 3332
(9063, 3332, 'OkHttp는 401 응답에 대해서는 Authenticator를 호출하지 않아 토큰이 갱신되지 않은 채 재요청됐다.', 'Authenticator는 바로 401을 받았을 때 불리는 훅이다. 로그에도 401 직후 리프레시가 세 번 일어났으니 훅 호출 자체는 정상으로 이뤄졌다.', false),
(9064, 3332, '세 요청이 커넥션 풀의 서로 다른 커넥션을 써서 새로 받은 토큰이 서로 공유되지 않았다.', '토큰은 커넥션이 아니라 요청 헤더에 실려 나간다. 커넥션을 나눠 써도 같은 저장소의 값을 읽으므로 커넥션 개수는 실패 원인이 되지 않는다.', false),
(9065, 3332, '세 스레드가 각자 리프레시를 보내 마지막 갱신이 앞선 토큰을 무효화했고, 재요청은 이미 폐기된 T1을 실어 보냈다.', '갱신을 직렬화하지 않으면 이런 경합이 난다. 락을 잡은 뒤 그사이 다른 스레드가 이미 갱신했는지 다시 확인하고, 새 토큰이 있으면 그것을 재사용해야 세 번의 리프레시가 한 번으로 줄어든다.', true),
(9066, 3332, '재요청이 애플리케이션 인터셉터를 다시 거치지 않아 Authorization 헤더가 비어 있었다.', '마지막 줄에 Bearer T1이 찍혀 있으니 헤더는 채워진 채 나갔다. 값이 이미 낡았을 뿐이어서 헤더 누락은 원인이 될 수 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1066, 3333, '멱등성 키,멱등성키,멱등 키,멱등키,Idempotency-Key,Idempotency Key,IdempotencyKey', '같은 키가 붙은 요청은 서버가 처음 처리한 결과를 그대로 되돌려 주므로, 도달 여부가 불확실한 POST 재전송을 안전하게 만드는 장치가 멱등성 키(Idempotency-Key)다. GET·PUT처럼 본래 멱등한 메서드와 달리 POST는 재전송이 곧 중복 생성이라, 이 키가 없으면 타임아웃 뒤 재시도를 아예 막는 것이 원칙이다. 재시도할 때 클라이언트가 키 값을 그대로 유지해야 효과가 있고, 요청을 새로 만들 때마다 키를 새로 뽑으면 서버는 서로 다른 주문으로 본다. 서버가 알아서 중복을 걸러 주는 것이 아니라 클라이언트와 서버가 함께 지켜야 하는 규약이라는 점에서, 커넥션 실패만 조용히 다시 보내는 OkHttp의 자동 재시도와 구분된다.'),
       (1067, 3334, 'CancellationException,kotlinx.coroutines.CancellationException,kotlin.coroutines.cancellation.CancellationException,취소 예외', '코루틴이 취소될 때 진행 중인 흐름을 끊으려고 던져지는 신호가 CancellationException이다. catch (e: Exception)이 이것까지 함께 삼키면 취소가 평범한 실패로 둔갑해, 이미 사라진 화면에 오류를 전달하려 하고 재시도 로직까지 깨어난다. 상위 코루틴은 자식이 취소된 사실을 모른 채 정상 종료로 처리하므로 구조적 동시성의 취소 전파도 끊긴다. IOException·SocketTimeoutException·HttpException처럼 네트워크·서버 사정으로 생기는 예외는 도메인 오류로 바꿔 UI에 알리는 것이 맞지만, 이 예외만은 잡았더라도 반드시 다시 던져 위로 흘려보내야 한다.');

-- =====================================================
-- Lesson 683: 인터셉터 순서와 커넥션 풀, 지터
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4277, 683, '아래 코드로 만든 api에서 getUser(7)을 한 번 호출할 때, (가)~(라)가 일어나는 순서로 옳은 것은?', '```kotlin
interface UserApi {
    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: Long): UserDto
}

val client = OkHttpClient.Builder()
    .addInterceptor(AuthInterceptor(tokenProvider))
    .build()

val api = Retrofit.Builder()
    .baseUrl("https://api.example.com/v1/")
    .client(client)
    .addConverterFactory(MoshiConverterFactory.create())
    .build()
    .create(UserApi::class.java)
```

- (가) 응답으로 받은 JSON 바이트를 UserDto 객체로 바꾼다.
- (나) 요청에 Authorization: Bearer 헤더를 붙인다.
- (다) @GET·@Path 선언을 읽어 https://api.example.com/v1/users/7 요청 객체를 만든다.
- (라) 서버와 소켓 연결을 확보하고 요청 바이트를 내보낸다.', 'OBJECTIVE'),
       (4278, 683, '아래 코드와 로그에서 Logcat에 Authorization 헤더 줄이 찍히지 않은 원인으로 옳은 것은?', E'```kotlin\nclass AuthInterceptor(private val tokenProvider: TokenProvider) : Interceptor {\n    override fun intercept(chain: Interceptor.Chain): Response {\n        val original = chain.request()\n        val token = tokenProvider.accessToken() ?: return chain.proceed(original)\n        val authed = original.newBuilder()\n            .header("Authorization", "Bearer $token")\n            .build()\n        return chain.proceed(authed)\n    }\n}\n\nval client = OkHttpClient.Builder()\n    .addInterceptor(HttpLoggingInterceptor().apply {\n        level = HttpLoggingInterceptor.Level.HEADERS\n    })\n    .addInterceptor(AuthInterceptor(tokenProvider))\n    .build()\n```\n\n앱의 Logcat:\n\n```\n--> GET https://api.example.com/v1/orders\n--> END GET\n<-- 200 OK https://api.example.com/v1/orders (95ms)\nContent-Type: application/json\n<-- END HTTP\n```\n\n같은 시각 서버 접근 로그:\n\n```\nGET /v1/orders  Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...  200\n```', 'OBJECTIVE'),
       (4279, 683, '아래 조건에서 앱이 GET /v1/orders를 한 번 호출했을 때, 호출이 끝날 때까지 서버로 나간 요청 횟수로 옳은 것은?', '서버 설정 오류로 GET /v1/orders는 어떤 토큰을 실어 보내도 401을 돌려준다. `tokenProvider.refreshBlocking()`은 호출될 때마다 POST /v1/auth/refresh를 한 번 보내며, 이 요청은 매번 200과 새 토큰을 받는다. OkHttpClient에는 아래 Authenticator가 등록돼 있다.

```kotlin
class TokenAuthenticator(private val tokenProvider: TokenProvider) : Authenticator {
    override fun authenticate(route: Route?, response: Response): Request? {
        if (responseCount(response) >= 3) return null
        val newToken = tokenProvider.refreshBlocking() ?: return null
        return response.request.newBuilder()
            .header("Authorization", "Bearer $newToken")
            .build()
    }

    private fun responseCount(response: Response): Int =
        generateSequence(response) { it.priorResponse }.count()
}
```

- OkHttp는 Authenticator가 돌려준 요청을 다시 보내고, 그렇게 받은 응답의 priorResponse에 직전 응답을 연결한다. 맨 처음 받은 응답의 priorResponse는 null이다.
- Authenticator가 null을 돌려주면 OkHttp는 더 이상 재요청하지 않고 마지막 응답을 호출 측에 넘긴다.', 'OBJECTIVE'),
       (4280, 683, '아래 코드의 safeApiCall로 표의 네 호출을 감쌌을 때, 처리 결과로 옳은 것은?', '```kotlin
sealed interface NetworkError {
    data object NoConnection : NetworkError
    data object Timeout : NetworkError
    data class Http(val code: Int, val message: String?) : NetworkError
    data class Unknown(val cause: Throwable) : NetworkError
}

suspend fun <T> safeApiCall(call: suspend () -> T): Result<T> = try {
    Result.success(call())
} catch (e: HttpException) {
    Result.failure(ApiException(NetworkError.Http(e.code(), e.message())))
} catch (e: SocketTimeoutException) {
    Result.failure(ApiException(NetworkError.Timeout))
} catch (e: IOException) {
    Result.failure(ApiException(NetworkError.NoConnection))
} catch (e: CancellationException) {
    throw e
}
```

네 호출은 모두 본문 타입(UserDto)을 직접 반환하는 Retrofit suspend 함수를 safeApiCall로 감싸 실행했다.

| 호출 | 발생한 일 | 던져진 예외 | 예외의 상위 타입 |
|---|---|---|---|
| (가) | 지하철에서 신호가 끊겨 호스트 이름을 찾지 못함 | UnknownHostException | IOException |
| (나) | 서버가 30초 넘게 응답하지 않음 | SocketTimeoutException | IOException |
| (다) | 서버가 500을 응답함 | HttpException | RuntimeException |
| (라) | 응답 JSON에 필수 필드 id가 빠져 있음 | JsonDataException | RuntimeException |', 'OBJECTIVE'),
       (4281, 683, '아래 측정 결과에서 공유 클라이언트의 2번째 요청부터 앞의 세 구간이 사라지게 한, OkHttpClient 안의 구성 요소 이름은?', '목록 화면이 같은 서버 api.example.com으로 API를 20번 연달아 호출한다. 처음에는 API 함수 안에서 호출할 때마다 `OkHttpClient.Builder().build()`로 클라이언트를 새로 만들었고, 나중에는 클라이언트 하나를 앱 전체에서 공유하도록 바꿨다. 두 방식에서 요청 한 건이 거친 구간별 시간은 다음과 같았다.

| 구간 | 요청마다 새 클라이언트 (20건 모두) | 공유 클라이언트 (2번째 요청부터) |
|---|---|---|
| DNS 조회 | 25ms | 없음 |
| TCP 핸드셰이크 | 40ms | 없음 |
| TLS 핸드셰이크 | 95ms | 없음 |
| 요청 전송·응답 수신 | 45ms | 45ms |
| 합계 | 205ms | 45ms |

공유 클라이언트에서도 1번째 요청은 새 클라이언트 방식과 같은 205ms가 걸렸다.', 'SUBJECTIVE'),
       (4282, 683, '아래 재현 결과에서 2차 재현 때 재시도 코드에 더해진 기법을 가리키는 용어는?', '결제 서버가 2분간 멈췄다가 복구됐다. 앱이 설치된 기기 약 10만 대는 실패한 요청을 1초 → 2초 → 4초 간격으로 다시 보내도록 짜여 있다. 같은 장애를 두 번 재현했고, 2차 재현 전에는 재시도 코드 한 줄만 고쳤다.

| 항목 | 1차 재현 | 2차 재현 |
|---|---|---|
| 기기 A·B·C가 두 번째 재시도 전에 기다린 시간 | 2.00초 · 2.00초 · 2.00초 | 2.13초 · 2.71초 · 2.38초 |
| 기기 A·B·C가 세 번째 재시도 전에 기다린 시간 | 4.00초 · 4.00초 · 4.00초 | 5.62초 · 4.09초 · 4.87초 |
| 복구 직후 초당 최대 요청 수 | 90,000건 | 14,000건 |
| 서버 상태 | 재시도 시점마다 요청이 한꺼번에 몰려 다시 멈춤 | 멈추지 않고 정상 처리 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4277
(11579, 4277, '(나) → (다) → (라) → (가)', '인터셉터가 요청을 가장 먼저 가로챈다고 본 오개념이다. 인터셉터는 OkHttp 체인 안에서 이미 만들어진 Request를 받아 고치는 자리라, Retrofit이 @GET·@Path 선언을 읽어 요청을 만들기 전에는 헤더를 붙일 대상 자체가 없다.', false),
(11580, 4277, '(라) → (다) → (나) → (가)', 'OkHttpClient를 만들 때 서버 연결을 미리 열어 둔다고 본 오개념이다. 클라이언트는 어느 서버로 갈지 모른 채 만들어지고, 연결은 요청이 체인을 따라 내려가 실제로 보낼 차례가 됐을 때 확보된다.', false),
(11581, 4277, '(다) → (나) → (라) → (가)', 'Retrofit이 인터페이스 선언을 번역해 Request를 만들면, OkHttp가 addInterceptor()로 등록된 AuthInterceptor를 먼저 통과시킨 뒤 연결을 잡아 전송한다. 응답 바이트가 돌아오면 Retrofit에 등록된 Moshi 컨버터가 UserDto로 바꾼다.', true),
(11582, 4277, '(다) → (라) → (나) → (가)', '인증 헤더가 전송 뒤에 붙는다고 본 오개념이다. addInterceptor()로 등록한 인터셉터는 체인 앞쪽에서 연결 확보보다 먼저 실행된다. 전송 직전 자리에 놓이는 addNetworkInterceptor()의 인터셉터라 해도 헤더는 보내기 전에 붙는다.', false),

-- 문제 4278
(11583, 4278, '로깅 인터셉터가 체인에서 AuthInterceptor보다 앞에 있어, 헤더가 붙기 전의 요청을 출력했다.', 'addInterceptor()로 등록한 순서가 곧 체인 순서다. 로깅 인터셉터는 자기 차례에 받은 요청을 먼저 찍고 proceed()로 넘기므로, 뒤에 놓인 AuthInterceptor가 붙인 헤더는 볼 수 없다. 두 줄의 등록 순서를 바꾸면 Authorization 줄이 찍힌다.', true),
(11584, 4278, 'HttpLoggingInterceptor는 기본 설정에서 Authorization 헤더를 로그 출력에서 뺀다.', '헤더 값을 가리는 기능은 redactHeader()로 헤더 이름을 직접 지정해야 켜진다. 지정하더라도 줄은 남고 값만 가려진 채 찍히므로, 줄 자체가 없는 이 로그를 가림 처리로는 설명할 수 없다.', false),
(11585, 4278, '애플리케이션 인터셉터는 OkHttp가 전송 직전에 추가하는 헤더를 볼 수 없어 이 줄이 빠졌다.', 'Authorization은 OkHttp 코어가 아니라 앱의 AuthInterceptor가 붙이는 헤더다. 애플리케이션 인터셉터가 못 보는 것은 Host·Accept-Encoding처럼 코어가 채우는 헤더라서, 두 인터셉터 종류의 차이로는 이 증상이 설명되지 않는다.', false),
(11586, 4278, 'tokenProvider가 null을 돌려줘 AuthInterceptor가 헤더 없이 요청을 보냈다.', '서버 접근 로그에 Bearer 토큰이 도착했고 응답도 200이다. 토큰이 없어 헤더 없이 나갔다면 서버에서도 헤더가 보이지 않아야 하므로, 문제는 전송된 요청이 아니라 로그를 찍은 위치에 있다.', false),

-- 문제 4279
(11587, 4279, '/v1/orders 2회, /v1/auth/refresh 1회', '401이면 토큰 갱신 뒤 딱 1회만 재요청된다고 본 오개념이다. 재요청을 멈추는 시점은 OkHttp가 아니라 Authenticator가 null을 돌려줄 때이며, 이 코드는 responseCount가 3이 될 때까지 갱신과 재요청을 이어 간다.', false),
(11588, 4279, '/v1/orders 3회, /v1/auth/refresh 3회', '갱신이 한도 검사보다 먼저 일어난다고 본 오개념이다. 세 번째 401에서는 responseCount가 이미 3이라 첫 줄에서 곧바로 null을 돌려주므로 refreshBlocking()까지 내려가지 않고, 갱신은 두 번에서 멈춘다.', false),
(11589, 4279, '/v1/orders 4회, /v1/auth/refresh 3회', 'responseCount가 직전 응답들만 센다고 본 오개념이다. generateSequence는 지금 받은 응답을 첫 원소로 포함하므로 첫 401에서 이미 1이다. 1과 2일 때만 갱신·재요청하고 3에서 멈추므로 네 번째 orders 요청은 나가지 않는다.', false),
(11590, 4279, '/v1/orders 3회, /v1/auth/refresh 2회', '첫 401은 count 1, 재요청 뒤 두 번째 401은 count 2라 두 번 갱신하고 다시 보낸다. 세 번째 401에서 count가 3이 돼 null을 돌려주고 호출 측은 그 401을 받는다. 이 검사가 없으면 OkHttp의 후속 요청 한도에 걸릴 때까지 갱신이 되풀이된다.', true),

-- 문제 4280
(11591, 4280, '(가)는 NetworkError.NoConnection이 되고, (나)도 IOException의 하위 타입이라 NoConnection이 된다.', 'catch 블록은 위에서부터 차례로 맞춰 보고 처음 맞는 한 곳만 실행한다. SocketTimeoutException 블록이 IOException 블록보다 위에 있으므로 (나)는 먼저 걸리는 Timeout으로 바뀐다. 상위 타입만 보고 판단한 오개념이다.', false),
(11592, 4280, '(다)는 코드 500을 담은 NetworkError.Http가 되고, (라)는 어느 catch에도 걸리지 않아 호출한 쪽으로 전파된다.', 'HttpException은 첫 블록에 걸려 코드 500을 담은 Http가 된다. JsonDataException은 RuntimeException 계열이라 나열된 catch 타입 어디에도 해당하지 않아 Result로 감싸지지 않고 밖으로 던져지며, 호출 측도 잡지 않으면 앱이 종료될 수 있다.', true),
(11593, 4280, '(나)는 NetworkError.Timeout이 되고, (라)는 정의해 둔 NetworkError.Unknown으로 감싸진 실패가 된다.', 'Unknown은 sealed interface에 정의만 돼 있고 이를 만들어 내는 catch 블록이 없어 (라)는 그대로 전파된다. Unknown을 쓰려면 CancellationException 블록 뒤에 나머지 예외를 받아 Unknown으로 감싸는 블록을 따로 둬야 한다.', false),
(11594, 4280, '(가)는 제한 시간 안에 연결하지 못한 경우라 NetworkError.Timeout이 되고, (다)는 NetworkError.Http가 된다.', 'Timeout으로 바뀌는 것은 SocketTimeoutException뿐이다. UnknownHostException은 호스트 이름 조회 실패로 SocketTimeoutException이 아니므로 IOException 블록에 걸려 NoConnection이 된다. 신호 끊김을 시간 초과로 묶어 생각한 오개념이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1382, 4281, '커넥션 풀,커넥션풀,연결 풀,연결풀,커넥션 풀링,connection pool,ConnectionPool,connection-pool', 'OkHttpClient는 인스턴스마다 커넥션 풀(ConnectionPool)을 하나씩 갖는다. 요청이 끝난 연결을 바로 닫지 않고 풀에 남겨 두었다가 같은 서버로 가는 다음 요청에 다시 내주므로, 공유 클라이언트는 2번째 요청부터 DNS 조회·TCP 핸드셰이크·TLS 핸드셰이크를 건너뛰고 곧바로 요청을 보낸다. 1번째 요청은 풀이 비어 있어 연결을 처음부터 맺었고, 요청마다 클라이언트를 새로 만들면 풀도 매번 빈 상태로 새로 생겨 20건 모두 연결을 처음부터 맺는다. 그래서 OkHttpClient는 앱 전체에서 하나만 만들어 공유한다. 연결을 끊지 않고 이어 쓰자는 HTTP Keep-Alive는 프로토콜 차원의 약속이고, 그 연결을 실제로 보관했다가 다시 배정하는 쪽이 커넥션 풀이다. 비동기 요청을 몇 개까지 동시에 실행할지와 실행 스레드를 관리하는 Dispatcher와도 구분한다.'),
       (1383, 4282, '지터,jitter,랜덤 지터,random jitter,무작위 지터,지터링,jittering,백오프 지터,backoff jitter', '지터(jitter)는 재시도 대기 시간에 기기마다 다른 무작위 값을 더해 재시도 시점을 흩어 놓는 기법이다. 1차 재현도 1초 → 2초 → 4초로 간격을 늘리는 지수 백오프(Exponential Backoff)는 이미 쓰고 있었지만, 모든 기기가 같은 순간에 실패했으니 같은 순간에 다시 몰려 막 복구된 서버를 또 멈춰 세웠다. 2차 재현에서는 같은 두 번째 재시도라도 2.13초·2.71초·2.38초처럼 대기 시간이 기기마다 달라져 초당 최대 요청이 90,000건에서 14,000건으로 줄었다. 지수 백오프는 간격을 점점 늘려 서버에 회복할 시간을 주는 장치이고, 지터는 그 간격 안에서 재시도가 한 시점에 겹치지 않게 나누는 장치라 둘을 함께 쓴다. 서버가 429·503 응답의 Retry-After 헤더로 정해 주는 대기 시간과도 구분한다.');

-- =====================================================
-- Lesson 841: URL 결합과 백오프 대기·오프라인 감지
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5225, 841, '아래 코드에서 두 호출이 실제로 보내는 요청 URL로 옳은 것은?', '```kotlin
interface ApiService {
    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: Long): UserDto

    @GET("/health")
    suspend fun health(): HealthDto
}

val api = Retrofit.Builder()
    .baseUrl("https://api.example.com/v1/")
    .client(okHttpClient)
    .addConverterFactory(MoshiConverterFactory.create())
    .build()
    .create(ApiService::class.java)

// 호출
api.getUser(7)
api.health()
```', 'OBJECTIVE'),
       (5226, 841, '아래 관측 결과에서 규격 변경 후 토큰 자동 갱신이 멈춘 원인으로 옳은 것은?', '서버 팀이 만료된 액세스 토큰에 대한 응답을 401에서 403으로 바꾼 뒤, 앱에서 토큰 자동 갱신이 안 된다는 제보가 들어왔다. 앱의 인터셉터·Authenticator·토큰 저장소 코드는 규격 변경 전후로 한 줄도 바뀌지 않았다.

| 호출 | 서버 응답 | /v1/auth/refresh 요청 | 최종 결과 |
|---|---|---|---|
| 변경 전 GET /v1/orders (만료 토큰) | 401 | 1회 나감 | 재요청 후 200 |
| 변경 후 GET /v1/orders (만료 토큰) | 403 | 나가지 않음 | 오류 화면 |
| 변경 후 GET /v1/legacy/orders (만료 토큰) | 401 | 1회 나감 | 재요청 후 200 |
| 변경 후 GET /v1/orders/9 (없는 주문, 유효 토큰) | 404 | 나가지 않음 | 오류 화면 |', 'OBJECTIVE'),
       (5227, 841, '아래 코드에서 예외가 호출 측으로 전파되기까지 delay()로 기다린 시간의 합은?', '```kotlin
suspend fun <T> retryWithBackoff(
    times: Int = 4,
    initialDelayMs: Long = 400,
    maxDelayMs: Long = 1_000,
    shouldRetry: (Throwable) -> Boolean = { it is IOException },
    block: suspend () -> T
): T {
    var delayMs = initialDelayMs
    repeat(times - 1) {
        try {
            return block()
        } catch (e: Throwable) {
            if (!shouldRetry(e)) throw e
        }
        delay(delayMs)
        delayMs = (delayMs * 2).coerceAtMost(maxDelayMs)
    }
    return block()
}

// 호출
retryWithBackoff { api.getOrders() }
```

- api.getOrders()는 호출될 때마다 SocketTimeoutException(IOException의 하위 타입)을 던진다.
- 인자는 모두 기본값을 쓰고, delay() 밖에서 흐르는 시간은 무시한다.', 'OBJECTIVE'),
       (5228, 841, '아래 로그에 나타난 suspend 호출의 동작에 대한 설명으로 옳은 것은?', 'ViewModel은 viewModelScope.launch { } (기본 디스패처는 Dispatchers.Main) 안에서 withContext 없이 api.getUser(7)을 호출한다. getUser는 UserDto를 반환하는 Retrofit suspend 함수다.

```
12:41:02.100  main               프로필 로딩 시작
12:41:02.104  OkHttp Dispatcher  --> GET /v1/users/7
12:41:02.416  OkHttp Dispatcher  <-- 200 (312ms, body 84KB)
12:41:02.419  main               UserDto 수신, uiState 갱신
```

응답을 기다린 312ms 동안 목록의 스크롤 애니메이션은 멈추지 않았고, Choreographer의 skipped frames 경고도 찍히지 않았다.', 'OBJECTIVE'),
       (5229, 841, '아래 상황에서 응답 대기를 30초 지점에서 끊어 준 OkHttpClient 설정의 이름은?', '특정 조회 API가 응답 본문의 첫 바이트를 45초 뒤에야 보내기 시작한다. 앱은 그동안 스피너만 돌다가 45초 만에 화면을 그렸다. 원인을 찾으려고 connectTimeout을 10초에서 3초로 줄여 봤지만, TCP·TLS 연결 자체는 60ms에 끝나는 서버라 증상이 그대로였다. OkHttpClient.Builder의 다른 설정 하나를 30초로 두자 같은 호출이 30초 지점에서 SocketTimeoutException으로 끊겼고, 5초로 낮추자 5초 지점에서 끊겼다. 같은 값을 Retrofit.Builder에 주려 했더니 그런 메서드가 없었다.', 'SUBJECTIVE'),
       (5230, 841, '아래 상황에서 오프라인 여부를 미리 알아내려고 콜백을 등록한 안드로이드 시스템 서비스의 이름은?', '지하철 구간에서 목록 화면을 열면 빈 화면에 스피너만 30초 돌다가 네트워크 오류 문구가 떴다. 로그에는 요청이 readTimeout까지 버틴 뒤 SocketTimeoutException으로 끝난 기록이 남았고, 그사이 사용자는 새로고침을 평균 4.2회 눌러 같은 요청이 여러 건 더 쌓였다. 다음 릴리스에서는 앱이 어떤 시스템 서비스에서 받아 온 객체에 콜백을 등록해 onAvailable·onLost 이벤트를 구독했고, 연결이 끊긴 순간 요청을 보내기도 전에 오프라인 배너를 띄우며 새로고침 버튼을 비활성화했다. 배너가 뜨기까지 걸린 시간은 30초에서 0.2초로 줄었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5225
(14107, 5225, 'getUser → https://api.example.com/v1/users/7 · health → https://api.example.com/v1/health', '@GET 값 앞의 /를 단순한 구분 기호로 본 오개념이다. 경로가 /로 시작하면 절대 경로로 해석돼 baseUrl에 적힌 /v1이 통째로 떨어져 나간다.', false),
(14108, 5225, 'getUser → https://api.example.com/v1/users/7 · health → https://api.example.com/health', 'users/{id}는 상대 경로라 baseUrl의 /v1/ 뒤에 이어 붙고, /health는 /로 시작해 호스트 바로 아래로 붙는다. 같은 인터페이스 안에서도 앞의 / 하나가 버전 경로를 날려 버리므로, baseUrl은 /로 끝내고 경로는 상대 경로로 적는다.', true),
(14109, 5225, 'getUser → https://api.example.com/users/7 · health → https://api.example.com/health', 'baseUrl의 경로 부분은 어차피 무시되고 호스트만 쓰인다고 본 오개념이다. 상대 경로로 적은 users/{id}는 /v1 뒤에 정상적으로 붙는다.', false),
(14110, 5225, 'getUser → https://api.example.com/v1/users/7 · health → https://api.example.com/v1//health', 'baseUrl과 경로를 문자열로 이어 붙인다고 본 오개념이다. Retrofit은 상대 URL 해석 규칙으로 결합하므로 //가 생기지 않는다.', false),

-- 문제 5226
(14111, 5226, 'Authenticator가 호출되기는 했지만 refreshBlocking()이 null을 돌려줘 재요청이 취소됐다.', '갱신을 시도했다면 /v1/auth/refresh 요청이 한 번은 기록에 남아야 한다. 403 행은 refresh가 아예 나가지 않았으니 갱신 함수까지 내려가지도 못한 것이다.', false),
(14112, 5226, '토큰이 만료돼 tokenProvider가 null을 돌려줬고, AuthInterceptor가 헤더를 붙이지 못해 갱신 경로가 시작되지 않았다.', '헤더가 비어 나갔다면 같은 토큰을 쓰는 legacy 엔드포인트도 갱신을 타지 못했어야 한다. 세 번째 행은 같은 조건에서 401을 받아 갱신이 돌았으니 헤더는 정상적으로 실려 나갔다.', false),
(14113, 5226, 'Authenticator는 401 응답에만 불리는 훅이라 403으로 바뀐 뒤로는 갱신 코드가 실행될 기회 자체가 없다.', '401을 그대로 주는 legacy 엔드포인트에서만 갱신이 도는 것이 근거다. 403도 만료로 다루려면 응답 코드를 보고 갱신을 거는 인터셉터를 따로 두거나 서버 규격을 401로 되돌려야 한다.', true),
(14114, 5226, 'followRedirects 기본값 탓에 403 응답이 리다이렉트로 처리되면서 원래 요청이 소진돼 갱신 훅까지 가지 못했다.', '자동으로 추적되는 것은 3xx이고 403은 리다이렉트가 아니다. 리다이렉트가 일어났다면 같은 호출에서 두 번째 요청이 기록에 남았을 것이다.', false),

-- 문제 5227
(14115, 5227, '1,200ms', '간격이 매번 두 배로 늘어나는 것을 놓치고 400ms씩 세 번 쉰다고 본 계산이다. coerceAtMost는 상한을 씌울 뿐 증가 자체를 막지 않는다.', false),
(14116, 5227, '2,800ms', '400 + 800 + 1,600으로 본 계산이다. 세 번째 대기 직전의 delayMs는 800 × 2에 maxDelayMs 1,000이 씌워져 1,000ms가 된다.', false),
(14117, 5227, '3,200ms', '마지막 return block() 뒤에도 한 번 더 쉰다고 본 계산이다. delay()는 repeat 블록 안에만 있어 3회 실행되고, 네 번째 시도가 던진 예외는 대기 없이 곧바로 전파된다.', false),
(14118, 5227, '2,200ms', 'SocketTimeoutException은 IOException이라 shouldRetry가 참이다. repeat가 세 번 돌며 400ms · 800ms · 1,000ms를 쉬고(세 번째는 상한에 걸림), 네 번째 시도의 예외가 그대로 전파된다.', true),

-- 문제 5228
(14119, 5228, '호출부를 withContext(Dispatchers.IO)로 감싸도 대기 방식은 그대로라 312ms가 줄지 않고 디스패처 전환만 한 번 늘어난다.', '요청을 실제로 내보내고 응답을 기다리는 일은 OkHttp의 자체 스레드가 맡고, 호출 코루틴은 그동안 중단 상태로 스레드를 붙잡지 않는다. 그래서 호출부가 어느 디스패처에 있든 대기 시간은 같고, 감싸면 재개 지점만 한 번 더 옮겨진다.', true),
(14120, 5228, '312ms 동안 main 스레드가 응답을 기다리며 블로킹되고, 프레임 경고가 없는 것은 대기가 짧았기 때문이다.', '중단(suspend)을 블로킹으로 본 오개념이다. 중단된 코루틴은 스레드를 반납했다가 재개될 때 다시 배정받는다. 진짜 블로킹이었다면 312ms는 프레임 18개가 밀리는 시간이라 경고가 남았을 것이다.', false),
(14121, 5228, '84KB 응답을 UserDto로 바꾸는 작업은 재개된 뒤 main에서 일어나므로 본문이 커질수록 프레임이 밀린다.', '컨버터는 응답을 받아 온 OkHttp 스레드에서 돌고 main은 변환이 끝난 객체를 받는다. 로그의 main 줄이 바이트가 아니라 UserDto 수신으로 찍힌 것이 그 자리를 보여 준다.', false),
(14122, 5228, '화면을 떠나 viewModelScope가 취소돼도 이미 나간 GET 요청은 응답이 도착할 때까지 그대로 진행된다.', 'Retrofit의 suspend 어댑터는 코루틴이 취소되면 Call.cancel()을 불러 진행 중인 요청을 끊는다. 취소가 전파되지 않는 경우는 중간에서 CancellationException을 삼켰을 때다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1698, 5229, 'readTimeout,read timeout,read-timeout,읽기 타임아웃,읽기타임아웃,리드 타임아웃,리드타임아웃,읽기 제한 시간', 'readTimeout은 연결이 맺어진 뒤 데이터가 오가는 사이의 공백을 재는 한도라, 연결은 60ms에 끝나고 첫 바이트가 45초 뒤에 오는 이 서버에서는 이 값만 증상을 바꾼다. 연결 수립까지만 재는 connectTimeout, 요청 본문을 밀어 넣는 동안을 재는 writeTimeout, 리다이렉트·재시도를 포함해 호출 전체를 재는 callTimeout과 구분한다. 네 값은 구간마다 따로 적용되므로 connectTimeout을 아무리 줄여도 응답 대기는 끊기지 않는다. 타임아웃·인터셉터·재시도 같은 통신 설정이 전부 OkHttp에 있고 Retrofit.Builder에는 baseUrl·컨버터·호출 어댑터만 있다는 점이, Retrofit.Builder에서 같은 메서드를 찾지 못한 이유다.'),
       (1699, 5230, 'ConnectivityManager,connectivity manager,커넥티비티 매니저,커넥티비티매니저', 'ConnectivityManager는 registerNetworkCallback으로 네트워크가 붙고 끊기는 순간을 앱에 알려 주는 시스템 서비스다. 예외로만 오프라인을 판단하면 readTimeout이 다 흐른 뒤에야 알 수 있어 30초를 버리지만, 콜백을 구독하면 상태가 바뀐 즉시 화면을 바꿀 수 있다. onAvailable·onLost를 받는 NetworkCallback은 이 서비스에 등록하는 콜백 객체이고, 어떤 망을 볼지 거르는 NetworkRequest는 등록할 때 함께 넘기는 조건이라 셋을 구분한다. 콜백이 알려 주는 것은 연결 가능 여부일 뿐 요청 성공 보장이 아니므로(캡티브 포털 등) 예외 처리는 그대로 두고, 인터넷이 실제로 되는지는 NET_CAPABILITY_VALIDATED로 확인한다.');
