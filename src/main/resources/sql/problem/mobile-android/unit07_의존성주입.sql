-- Unit: 의존성 주입 (Unit ID: 173)
-- Chapter: Android (Chapter ID: 16)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (599, 173, '컴포넌트 스코프와 @EntryPoint'),
       (757, 173, '바인딩 방식과 @Qualifier 구분'),
       (915, 173, 'Hilt 컴포넌트 경계와 인스턴스 수명 추적하기');

-- =====================================================
-- Lesson 599: 컴포넌트 스코프와 @EntryPoint
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3773, 599, '아래 모듈이 제공하는 객체가 세 저장소에 주입될 때의 동작으로 옳은 것은?', '```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    fun provideOkHttpClient(): OkHttpClient =
        OkHttpClient.Builder().build()
}
```

UserRepository, FeedRepository, SearchRepository가 각각 생성자 주입으로 OkHttpClient를 받는다.', 'OBJECTIVE'),
       (3774, 599, '아래 스코프 비교표를 바탕으로 옳지 않은 것은?', '| 스코프 애너테이션 | 생성 시점 | 소멸 시점 |
| --- | --- | --- |
| @Singleton | Application#onCreate | 프로세스 종료 |
| @ActivityRetainedScoped | Activity 최초 생성 | Activity 완전 종료 |
| @ActivityScoped | Activity#onCreate | Activity#onDestroy |
| @FragmentScoped | Fragment#onAttach | Fragment#onDestroy |

참고: 화면 회전은 Activity를 완전히 종료하지 않고 인스턴스만 다시 만든다.', 'OBJECTIVE'),
       (3775, 599, '아래 모듈이 컴파일되지 않는 원인으로 옳은 것은?', '```kotlin
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindUserRepository(
        impl: DefaultUserRepository,
        logger: EventLogger,
    ): UserRepository
}
```

DefaultUserRepository는 @Inject 생성자를 가지며 UserRepository를 구현한다. EventLogger도 @Inject 생성자를 가진다.', 'OBJECTIVE'),
       (3776, 599, '아래 코드에서 화면이 ViewModel을 얻지 못하는 원인으로 옳은 것은?', '```kotlin
@HiltViewModel
class UserViewModel @Inject constructor(
    private val repository: UserRepository,
) : ViewModel()

class UserActivity : AppCompatActivity() {

    private val viewModel: UserViewModel by viewModels()
}
```

UserRepository는 @Binds로 SingletonComponent에 바인딩돼 있고, Application 클래스에는 @HiltAndroidApp이 붙어 있다.', 'OBJECTIVE'),
       (3777, 599, '아래 상황에서 ExampleContentProvider가 AnalyticsTracker를 사용하려면 추가로 필요한 Hilt 애너테이션은?', 'ExampleContentProvider가 query() 안에서 AnalyticsTracker로 조회 로그를 남겨야 한다. AnalyticsTracker는 @Singleton으로 SingletonComponent에 바인딩돼 있고, @AndroidEntryPoint를 붙인 UserActivity에서는 @Inject lateinit var로 문제없이 들어온다.

- ExampleContentProvider에도 @AndroidEntryPoint를 붙였더니 지원하지 않는 대상이라는 빌드 오류가 났다.
- 애너테이션을 떼고 @Inject lateinit var tracker만 남기자 빌드는 통과했지만, query() 첫 호출에서 tracker가 초기화되지 않아 NullPointerException이 났다.
- 급한 대로 AnalyticsTracker()를 직접 생성했더니 @Singleton 인스턴스와 별개여서 같은 사용자의 세션 집계가 두 벌로 쪼개졌다.', 'SUBJECTIVE'),
       (3778, 599, '아래 요구를 모두 만족하려면 FilterState 바인딩에 붙여야 하는 스코프 애너테이션은?', 'UserViewModel이 주입받는 UseCase 두 개가 같은 FilterState를 봐야 한다.

- 스코프를 붙이지 않았더니 UseCase마다 서로 다른 FilterState가 생겨 한쪽에서 바꾼 필터가 다른 쪽에 반영되지 않았다.
- @Singleton으로 바꿨더니 이번에는 다른 화면의 ViewModel까지 같은 FilterState를 써서 필터가 섞였다.
- 화면을 회전해도 값은 남아야 하고, UserViewModel이 onCleared로 정리될 때 FilterState도 함께 버려져야 한다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3773
(10235, 3773, '세 저장소가 하나의 인스턴스를 공유하며 프로세스가 끝날 때까지 유지된다.', '@InstallIn은 바인딩을 어느 컴포넌트에 설치할지만 정한다. 인스턴스를 하나로 묶는 일은 @Singleton 같은 스코프 애너테이션의 몫인데, 설치 위치를 공유 범위로 오해한 선지다.', false),
(10236, 3773, '스코프 애너테이션이 없어 그래프를 만드는 단계에서 빌드 오류가 난다.', '스코프 없는 바인딩은 오류가 아니라 Hilt의 기본 동작이다. 빌드가 막히는 쪽은 바인딩 자체가 없거나, 부모 컴포넌트에서 자식 컴포넌트의 바인딩을 요구해 의존 방향을 어긴 경우다.', false),
(10237, 3773, '저장소마다 별개의 인스턴스가 만들어져 커넥션 풀과 캐시가 따로 유지된다.', '스코프가 없으면 주입 지점마다 provideOkHttpClient가 다시 호출된다. OkHttpClient는 커넥션 풀과 응답 캐시를 인스턴스별로 들고 있어, 세 벌이 생기면 재사용 이득이 사라진다.', true),
(10238, 3773, '가장 먼저 주입받은 저장소가 소멸할 때까지만 인스턴스가 살아 있다가 이후 새로 만들어진다.', '스코프 없는 바인딩은 컨테이너가 인스턴스를 보관하지 않으므로 수명을 추적하지도 않는다. @ActivityScoped처럼 특정 컴포넌트 수명에 묶인 동작을 기본값으로 오해한 선지다.', false),

-- 문제 3774
(10239, 3774, '@ActivityScoped 객체는 화면을 회전하면 들고 있던 값을 잃고 새로 만들어진다.', 'onDestroy에서 소멸하는데 회전은 Activity 인스턴스를 없앴다 다시 만든다. 그래서 회전을 견디지 못하고 새 인스턴스로 바뀐다 — 표에서 그대로 따라 나오는 참인 진술이다.', false),
(10240, 3774, '@ActivityRetainedScoped 객체는 화면을 회전할 때마다 버려지고 새 인스턴스로 교체된다.', '소멸 시점이 Activity 완전 종료인데 회전은 완전 종료가 아니다. 회전을 넘어 같은 인스턴스를 유지하는 것이 이 스코프의 존재 이유이므로 거짓이며, 골라야 할 선지다.', true),
(10241, 3774, '같은 Activity 안에서 Fragment만 교체하면 @FragmentScoped 객체는 새로 만들어지고 @ActivityScoped 객체는 그대로 쓰인다.', 'Fragment 소멸은 Fragment#onDestroy에서 끝나고 Activity는 살아 있으므로 두 스코프의 수명이 갈린다. 표의 두 행을 겹쳐 읽으면 나오는 참인 진술이다.', false),
(10242, 3774, '@Singleton 객체가 Activity를 필드로 붙들고 있으면 그 Activity는 프로세스가 끝날 때까지 회수되지 않는다.', '@Singleton은 프로세스 종료까지 살아 있어 참조된 Activity도 함께 남는다. 이 누수를 피하려고 긴 수명 객체에는 Activity 대신 @ApplicationContext를 넣는다. 참인 진술이다.', false),

-- 문제 3775
(10243, 3775, '@Binds 메서드에는 @Singleton 같은 스코프 애너테이션을 함께 붙일 수 없다.', '@Binds에도 스코프를 붙여 인터페이스 바인딩을 컴포넌트 안에서 공유할 수 있다. 스코프를 @Provides 전용 기능으로 오해한 선지다.', false),
(10244, 3775, '@InstallIn은 object 모듈에만 쓸 수 있어 abstract class 모듈에는 붙일 수 없다.', '@Binds는 본문 없는 추상 함수라 abstract class나 interface 모듈이 오히려 정상 형태다. 모듈의 형태와 @InstallIn 사용 가능 여부를 묶어 생각한 오해다.', false),
(10245, 3775, '반환 타입이 인터페이스이므로 @Binds가 아니라 @Provides로 바꿔야 한다.', '인터페이스와 구현체를 잇는 것이 @Binds의 본래 쓰임이라 방향이 거꾸로다. @Provides는 빌더나 서드파티 객체처럼 생성 로직을 직접 써야 할 때 고른다.', false),
(10246, 3775, '@Binds 메서드는 구현체 하나만 매개변수로 받아야 하는데 두 개를 선언했다.', '@Binds는 매개변수 1개를 반환 타입으로 갈아 끼우는 선언일 뿐이라 추가 의존성을 받을 수 없다. EventLogger까지 쓰려면 본문이 있는 @Provides 함수로 옮겨 직접 생성해야 한다.', true),

-- 문제 3776
(10247, 3776, 'UserActivity에 @AndroidEntryPoint가 없어 Hilt가 이 화면을 주입 지점으로 보지 않는다.', '@HiltViewModel은 팩토리를 만들어 둘 뿐이고, 그 팩토리를 화면에 연결해 주는 것이 @AndroidEntryPoint다. 애너테이션을 붙이면 by viewModels()가 Hilt 팩토리를 쓴다.', true),
(10248, 3776, '@HiltViewModel을 붙인 ViewModel은 by viewModels()로 얻을 수 없고 hiltViewModel()로만 얻어야 한다.', 'hiltViewModel()은 Composable에서 가장 가까운 ViewModelStoreOwner를 찾아 주는 함수일 뿐이다. Activity와 Fragment에서는 by viewModels()를 그대로 쓴다.', false),
(10249, 3776, '생성자에 SavedStateHandle을 선언하지 않아 Hilt가 ViewModel 팩토리를 만들지 못한다.', 'SavedStateHandle은 ViewModelComponent의 기본 바인딩이라 필요할 때 선언하면 되는 선택 사항이다. 없다고 해서 팩토리 생성이 막히지는 않는다.', false),
(10250, 3776, 'UserRepository가 인터페이스이므로 @Binds가 아니라 @Provides로 제공해야 한다.', '인터페이스와 구현체 연결은 @Binds가 맡는 몫이라 바인딩 방식 자체에는 문제가 없다. 원인을 화면이 아니라 의존성 그래프 쪽으로 잘못 돌린 선지다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1214, 3777, '@EntryPoint,EntryPoint,entry point,엔트리 포인트,엔트리포인트', '@AndroidEntryPoint를 붙일 수 없는 클래스에서 컴포넌트에 이미 들어 있는 바인딩을 직접 꺼내 오는 접근 창구가 @EntryPoint다. AnalyticsTracker를 반환하는 메서드 하나짜리 인터페이스를 선언하고 @EntryPoint와 @InstallIn(SingletonComponent::class)을 함께 붙인 뒤, EntryPointAccessors.fromApplication·fromActivity·fromFragment 같은 접근자로 구현을 얻어 호출한다. 본문에서 직접 만든 인스턴스가 @Singleton 인스턴스와 갈라진 것도 컴포넌트 밖에서 객체를 생성했기 때문이다.

이름이 비슷한 @AndroidEntryPoint와 역할이 반대라는 점이 경계다. @AndroidEntryPoint는 Hilt가 필드에 값을 넣어 주는 쪽이고, @EntryPoint는 내가 컴포넌트에서 꺼내 오는 쪽이다. 후자는 서비스 로케이터처럼 동작해 의존성이 코드 안에 숨으므로, 주입이 정말 불가능한 경계에서만 쓴다. WorkManager가 만드는 Worker는 @HiltWorker와 HiltWorkerFactory로 푸는 길이 따로 있다.'),
       (1215, 3778, '@ViewModelScoped,ViewModelScoped,ViewModel Scoped,viewmodel scoped', 'ViewModelComponent에 묶여 ViewModel 인스턴스 하나 안에서만 객체를 공유하는 스코프가 @ViewModelScoped다. 그래서 같은 ViewModel이 주입받는 UseCase 두 개는 같은 FilterState를 보고, 다른 화면의 ViewModel은 각자 다른 FilterState를 갖는다.

스코프를 붙이지 않으면 주입할 때마다 새 인스턴스라 UseCase 사이 공유가 깨지고, @Singleton은 앱 전역 공유라 화면끼리 상태가 섞인다. 회전을 견딘다는 점만 보면 @ActivityRetainedScoped도 후보지만, 그것은 한 Activity에 딸린 모든 ViewModel이 함께 쓰므로 화면 단위로 분리돼야 한다는 조건에 걸린다. ViewModelComponent는 ViewModel이 만들어질 때 생기고 onCleared에서 사라지며, SavedStateHandle을 기본 바인딩으로 갖는다.');

-- =====================================================
-- Lesson 757: 바인딩 방식과 @Qualifier 구분
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4721, 757, '아래 설치 위치를 보고 각 바인딩을 어디서 주입받을 수 있는지 옳게 설명한 것은?', '컴포넌트 계층

```
SingletonComponent
   └─ ActivityRetainedComponent
          ├─ ViewModelComponent
          └─ ActivityComponent
                 └─ FragmentComponent
```

모듈 설치 위치

| 바인딩 | @InstallIn 컴포넌트 |
| --- | --- |
| ImageLoader | SingletonComponent |
| SessionCache | ActivityRetainedComponent |
| ToolbarPainter | ActivityComponent |', 'OBJECTIVE'),
       (4722, 757, '아래 두 모듈의 작성 방식에 대한 설명으로 옳은 것은?', '```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideUserApi(client: OkHttpClient): UserApi =
        Retrofit.Builder().baseUrl(BASE_URL).client(client).build().create(UserApi::class.java)
}

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindUserRepository(impl: DefaultUserRepository): UserRepository
}
```

DefaultUserRepository는 UserRepository를 구현하며 @Inject 생성자로 UserApi를 받는다. OkHttpClient 바인딩은 다른 모듈에 이미 있다.', 'OBJECTIVE'),
       (4723, 757, '아래 두 UserRepository 구현의 차이에서 따라 나오는 결과로 옳은 것은?', '```kotlin
// A안
class UserRepository {

    private val api = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .build()
        .create(UserApi::class.java)
}

// B안
class UserRepository @Inject constructor(private val api: UserApi)
```

두 안 모두 ViewModel과 다른 저장소 등 여러 곳에서 쓰인다. B안이 받는 UserApi는 Hilt 모듈이 @Provides로 제공한다.', 'OBJECTIVE'),
       (4724, 757, '아래 누수 보고에서 UserActivity가 회수되지 않는 원인으로 옳은 것은?', '```kotlin
@Singleton
class SessionManager @Inject constructor(
    @ApplicationContext private val appContext: Context,
) {
    private var listener: ((String) -> Unit)? = null

    fun register(onEvent: (String) -> Unit) {
        listener = onEvent
    }
}

@AndroidEntryPoint
class UserActivity : AppCompatActivity() {

    @Inject lateinit var sessionManager: SessionManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        sessionManager.register { message -> showBanner(message) }
    }
}
```

누수 감지 도구가 남긴 참조 사슬

```
GC Root
 └─ SessionManager (SingletonComponent가 보관)
      └─ listener
           └─ UserActivity (onDestroy 이후에도 회수되지 않음)
```', 'OBJECTIVE'),
       (4725, 757, '아래 빌드 오류를 없애면서 두 클라이언트를 모두 OkHttpClient 타입으로 두려면 도입해야 하는 애너테이션은?', 'API 호출용과 이미지 로딩용으로 OkHttpClient가 두 벌 필요하다. 앞쪽에는 인증 헤더를 붙이는 인터셉터를, 뒤쪽에는 디스크 캐시를 달아야 한다.

- 같은 모듈에 provideAuthClient()와 provideImageClient()를 나란히 두고 빌드했더니 OkHttpClient is bound multiple times로 멈췄다.
- 주입받는 쪽 매개변수 이름을 authClient로 맞춰 보았지만 결과는 같았다.
- AuthHttpClient, ImageHttpClient 같은 래퍼 클래스로 타입을 갈라 보았더니 꺼내 쓰는 코드가 호출부마다 늘어 되돌렸다.', 'SUBJECTIVE'),
       (4726, 757, '아래 요구를 한 번에 풀려면 UserViewModel 생성자에 선언해야 하는 객체는?', '목록 화면에서 상세 화면으로 이동하며 userId를 넘긴다. UserViewModel에는 @HiltViewModel과 @Inject 생성자가 붙어 있다.

- 생성자에 userId: Long을 그대로 선언했더니 Long 바인딩이 없다며 빌드가 멈췄다.
- 화면에서 얻은 뒤 viewModel.userId = id로 넣었더니 회전 뒤 다시 그릴 때 값이 비어 목록으로 튕겼다.
- 시스템이 메모리를 확보하려고 프로세스를 정리한 뒤 사용자가 돌아와도 같은 사용자의 상세가 열려야 한다.
- Hilt가 ViewModelComponent에 기본 바인딩으로 넣어 두므로 모듈을 새로 만들 필요는 없다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4721
(12763, 4721, 'ToolbarPainter는 @Singleton이 붙은 CrashReporter의 생성자에서 그대로 주입받을 수 있다.', 'SingletonComponent는 ActivityComponent의 부모라 자식 컨테이너에만 설치된 바인딩을 볼 수 없다. 설치 위치가 아래로 내려갈수록 쓸 수 있는 범위가 좁아지는데 방향을 거꾸로 본 선지다.', false),
(12764, 4721, 'SessionCache는 ViewModelComponent에 설치된 바인딩을 생성자 매개변수로 받아 쓸 수 있다.', 'ActivityRetainedComponent는 ViewModelComponent의 부모다. 부모는 자식이 들고 있는 바인딩에 접근하지 못하므로 방향이 반대이며, ViewModel 쪽에서 SessionCache를 받는 것이 정상 흐름이다.', false),
(12765, 4721, 'ImageLoader는 FragmentComponent가 주입하는 Fragment에서도 모듈을 더 만들지 않고 받을 수 있다.', 'FragmentComponent는 위로 올라가면 SingletonComponent까지 부모로 두어 그 바인딩을 물려받는다. 그래서 계층의 가장 위에 설치한 바인딩은 아래쪽 어느 주입 지점에서나 그대로 쓸 수 있다.', true),
(12766, 4721, 'ImageLoader는 SingletonComponent에 있어 Activity에서만 받을 수 있고 ViewModel 생성자에서는 받을 수 없다.', 'ViewModelComponent 역시 ActivityRetainedComponent를 거쳐 SingletonComponent를 부모로 둔다. 상속 경로가 Activity 쪽으로만 이어진다고 오해해 ViewModel을 계층 밖으로 밀어낸 선지다.', false),

-- 문제 4722
(12767, 4722, 'provideUserApi의 매개변수는 그래프에서 찾아 넣어 주는 의존성이고, bindUserRepository의 매개변수는 인터페이스에 이어 붙일 구현체를 가리킨다.', '앞쪽은 본문에서 객체를 만들 때 쓸 재료라 그래프가 채워 준다. 뒤쪽은 만드는 일 없이 DefaultUserRepository 바인딩을 UserRepository 타입으로 노출하라는 선언이라 매개변수가 하나뿐이다.', true),
(12768, 4722, 'RepositoryModule을 object로 바꾸면 생성되는 코드가 줄어 @Binds가 더 효율적으로 동작한다.', '@Binds 함수는 본문 없는 abstract 선언이라 object 안에 담을 수 없고, 바꾸는 순간 컴파일이 막힌다. 코드 생성이 적다는 장점을 모듈 형태까지 자유롭다는 뜻으로 넓혀 읽은 선지다.', false),
(12769, 4722, 'bindUserRepository는 호출되는 시점에 리플렉션으로 DefaultUserRepository 생성자를 찾아 인스턴스를 만든다.', 'Hilt는 Dagger 위에 얹혀 컴파일 시점에 코드를 만들어 두므로 런타임 리플렉션이 없다. 생성은 DefaultUserRepository의 @Inject 생성자를 보고 미리 생성해 둔 팩토리 코드가 맡는다.', false),
(12770, 4722, '두 함수의 @Singleton은 SingletonComponent에 설치한다는 뜻이라 @InstallIn과 겹치므로 하나를 지워야 한다.', '@InstallIn은 바인딩을 어느 컨테이너에 설치할지, @Singleton은 그 안에서 인스턴스를 하나만 쓸지를 정한다. 역할이 달라 둘 다 필요하고, 스코프를 지우면 주입할 때마다 새 객체가 만들어진다.', false),

-- 문제 4723
(12771, 4723, 'A안은 Retrofit 인스턴스를 클래스가 직접 들고 있어 UserRepository를 쓰는 곳마다 같은 커넥션 풀을 나눠 쓴다.', '생성 코드가 클래스 안에 있으면 UserRepository가 만들어질 때마다 Retrofit과 그 아래 클라이언트가 새로 생긴다. 커넥션 풀과 캐시도 그만큼 쪼개져 재사용 이득이 사라진다.', false),
(12772, 4723, 'B안은 생성자 매개변수가 늘어 UserRepository를 만드는 쪽이 UserApi 구현 클래스를 직접 알아야 한다.', '생성자 주입에서는 객체를 만드는 일을 컨테이너가 맡아 호출부는 구현 클래스를 모른 채 인터페이스만 본다. 매개변수가 늘면 쓰는 쪽 부담도 는다는 인상만으로 고르기 쉬운 선지다.', false),
(12773, 4723, 'B안은 UserApi 바인딩이 빠져 있어도 빌드는 통과하고 그 화면에 처음 들어갈 때 실패한다.', 'Hilt는 컴파일 시점에 그래프를 검사해 빠진 바인딩을 빌드 오류로 알린다. 필요할 때 객체를 찾아 오다가 런타임에 터지는 서비스 로케이터 방식과 헷갈린 선지다.', false),
(12774, 4723, 'B안은 UserApi 자리에 가짜 구현을 넣어 시험해 볼 수 있지만, A안은 같은 일을 하려면 UserRepository 코드를 고쳐야 한다.', '의존 객체를 밖에서 받으면 무엇을 넣을지 호출하는 쪽이 정한다. A안은 생성 방법이 클래스 안에 박혀 있어 네트워크를 가짜로 바꿔 끼울 틈이 없다.', true),

-- 문제 4724
(12775, 4724, 'UserActivity에 @AndroidEntryPoint가 붙어 Hilt가 화면 인스턴스를 컴포넌트에 계속 보관한다.', '@AndroidEntryPoint가 만드는 ActivityComponent는 onDestroy와 함께 버려지므로 화면을 붙들지 않는다. 주입을 받게 해 주는 애너테이션 자체를 누수 원인으로 오해한 선지다.', false),
(12776, 4724, '프로세스가 끝날 때까지 사는 SessionManager가 화면을 캡처한 람다를 필드로 붙들어 참조가 끊기지 않는다.', 'register에 넘긴 람다는 showBanner를 부르려고 UserActivity를 잡고 있고, 그 람다를 @Singleton 객체가 listener에 담아 둔다. 화면이 끝날 때 등록을 해제해야 사슬이 끊긴다.', true),
(12777, 4724, '@ApplicationContext로 받은 appContext가 화면을 띄운 Activity를 가리켜 함께 남는다.', '@ApplicationContext는 앱과 수명이 같은 Context라 화면을 가리키지 않는다. 오히려 긴 수명 객체에 Activity Context 대신 넣어 이런 누수를 막는 쪽이라 원인으로 지목할 수 없다.', false),
(12778, 4724, 'SessionManager에 스코프가 없어 주입할 때마다 새 인스턴스가 만들어져 메모리에 쌓인다.', '클래스에 @Singleton이 붙어 컨테이너가 인스턴스를 하나만 만들어 공유한다. 스코프 없는 바인딩이 만드는 중복 생성 문제와 참조 사슬이 끊기지 않는 문제를 뒤섞은 선지다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1530, 4725, '@Qualifier,Qualifier,퀄리파이어,한정자,@Named,Named,named', '같은 타입 바인딩이 둘 이상이면 Hilt는 어느 것을 넣을지 정할 수 없어 빌드를 멈춘다. 그래프가 바인딩을 찾을 때 쓰는 열쇠는 타입이지 매개변수 이름이 아니라서, 주입 지점의 이름을 authClient로 맞춰도 달라지지 않는다. @Qualifier를 붙인 애너테이션(@AuthClient, @ImageClient)을 직접 만들어 두 @Provides 함수와 주입 지점에 같은 표식을 달면, 타입은 OkHttpClient로 그대로 두고 바인딩만 갈린다. 애너테이션을 새로 만들기 번거로우면 미리 마련된 @Named("auth")를 써도 된다.

@ApplicationContext와 @ActivityContext도 Hilt가 준비해 둔 한정자다. 둘 다 같은 Context 타입을 구분하는 표식이라는 점에서 쓰임이 같다. 스코프 애너테이션과 헷갈리지 말 것 — @Singleton은 인스턴스를 몇 개 둘지를 정하고, 한정자는 같은 타입 바인딩 중 어느 것인지를 정한다. 래퍼 클래스로 타입을 나누는 방법도 오류 자체는 없애지만 호출부 코드가 늘어난다.'),
       (1531, 4726, 'SavedStateHandle,savedstatehandle,saved state handle,세이브드스테이트핸들', 'Navigation이 넘긴 화면 인자는 ViewModel이 만들어질 때 SavedStateHandle에 담겨 들어온다. 생성자에 SavedStateHandle을 선언하고 handle.get<Long>("userId")로 꺼내면 Long 바인딩을 찾지 못해 나던 빌드 오류가 사라진다. 값이 저장된 상태에 얹히므로 회전은 물론 시스템이 프로세스를 정리한 뒤 돌아와도 남아 있고, ViewModelComponent의 기본 바인딩이라 모듈을 따로 만들지 않아도 된다.

@ViewModelScoped 같은 스코프와 구분하는 것이 경계다. 스코프는 인스턴스를 어느 범위에서 공유할지를 정할 뿐 값을 보관해 주지 않는다. Activity의 onSaveInstanceState 번들은 화면이 직접 읽고 써야 하고 ViewModel까지 옮기는 일은 남는다. 화면 인자가 아니라 실행 중에 정해지는 임의의 값을 생성자로 넘겨야 하면 @AssistedInject 지원을 확인한다.');

-- =====================================================
-- Lesson 915: Hilt 컴포넌트 경계와 인스턴스 수명 추적하기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5669, 915, '아래 빌드 오류를 없애면서 본문의 요구도 지키는 수정으로 옳은 것은?', '```kotlin
@Module
@InstallIn(ActivityComponent::class)
object StorageModule {

    @Provides
    fun provideTokenStore(): TokenStore =
        TokenStore.Builder().fileName("tokens").build()
}

@Singleton
class AuthManager @Inject constructor(
    private val tokenStore: TokenStore,
)
```

빌드 로그(요약)

```
error: [Dagger/MissingBinding] TokenStore cannot be provided without an @Provides-annotated method.
  SingletonComponent
      TokenStore is injected at
          AuthManager(tokenStore)
```

요구: AuthManager는 로그인 상태를 앱 전체에서 하나로 유지해야 하고, @AndroidEntryPoint를 붙인 SyncService에서도 주입받는다. TokenStore는 Activity나 화면 상태에 의존하지 않는다.', 'OBJECTIVE'),
       (5670, 915, '아래 팀 규칙에 따라 세 객체를 그래프에 넣는 방법을 옳게 짝지은 것은?', '| 객체 | 상황 |
| --- | --- |
| DateFormatter | 우리 팀이 작성한 클래스다. 생성자를 고칠 수 있고, 필요한 Clock은 이미 그래프에 있다. |
| AppDatabase | Room이 구현을 만드는 추상 클래스라 Room.databaseBuilder(...).build()로만 얻을 수 있다. |
| CartRepository | 인터페이스다. 구현체 DefaultCartRepository에는 @Inject 생성자가 있다. |

팀 규칙

- 모듈 없이 해결되면 모듈을 만들지 않는다.
- 모듈이 필요하면 생성되는 코드가 적은 방식을 먼저 쓴다.', 'OBJECTIVE'),
       (5671, 915, '아래 코드에서 cart 화면의 개수가 0으로 보이는 원인으로 옳은 것은?', '```kotlin
@HiltViewModel
class CartViewModel @Inject constructor(
    private val repository: CartRepository,
) : ViewModel() {

    var count by mutableStateOf(0)
        private set

    fun add() { count++ }
}

NavHost(navController, startDestination = "product") {
    composable("product") {
        val vm: CartViewModel = hiltViewModel()
        ProductScreen(
            onAdd = vm::add,
            onOpenCart = { navController.navigate("cart") },
        )
    }
    composable("cart") {
        val vm: CartViewModel = hiltViewModel()
        CartScreen(count = vm.count)
    }
}
```

- product 화면에서 담기 버튼을 세 번 누른 뒤 cart로 이동하면 개수가 0으로 보인다.
- 뒤로 가기로 product에 돌아오면 3이 그대로 남아 있다.
- CartRepository는 @Binds와 @Singleton으로 SingletonComponent에 바인딩돼 있다.', 'OBJECTIVE'),
       (5672, 915, '아래 코드의 동작에 대한 설명으로 옳은 것은?', '```kotlin
@Singleton
class SearchHistory @Inject constructor() {

    private val keywords = mutableListOf<String>()

    fun add(keyword: String) { keywords += keyword }

    fun recent(): List<String> = keywords.takeLast(5)
}

@EntryPoint
@InstallIn(SingletonComponent::class)
interface SearchHistoryEntryPoint {
    fun searchHistory(): SearchHistory
}

class SuggestionProvider : ContentProvider() {

    override fun query(/* ... */): Cursor? {
        val history = EntryPointAccessors.fromApplication(
            context!!.applicationContext, SearchHistoryEntryPoint::class.java,
        ).searchHistory()
        return toCursor(history.recent())
    }
}

@AndroidEntryPoint
class SearchActivity : AppCompatActivity() {

    @Inject lateinit var searchHistory: SearchHistory
    // 검색할 때마다 searchHistory.add(keyword)를 호출한다.
}
```

SuggestionProvider는 앱과 같은 프로세스에서 실행된다.', 'OBJECTIVE'),
       (5673, 915, '아래 코드에서 CheckoutActivity를 처음 연 뒤 화면을 한 번 회전하기까지 만들어진 세 클래스의 인스턴스는 모두 몇 개인가?', '```kotlin
class ClickLogger @Inject constructor()

@ActivityScoped
class ThemeHelper @Inject constructor()

@ActivityRetainedScoped
class CheckoutSession @Inject constructor()

@AndroidEntryPoint
class CheckoutActivity : AppCompatActivity() {

    @Inject lateinit var logger1: ClickLogger
    @Inject lateinit var logger2: ClickLogger

    @Inject lateinit var theme1: ThemeHelper
    @Inject lateinit var theme2: ThemeHelper

    @Inject lateinit var session1: CheckoutSession
    @Inject lateinit var session2: CheckoutSession
}
```

- 세 클래스는 CheckoutActivity 밖 어디에서도 주입되지 않는다.
- 화면 회전으로 CheckoutActivity 인스턴스가 한 번 다시 만들어졌고, 사용자는 결제 화면을 떠나지 않았다.', 'SUBJECTIVE'),
       (5674, 915, '아래 상황에서 ImageDiskCache 생성자의 Context 매개변수에 붙여야 하는 애너테이션은?', '@Singleton으로 선언한 ImageDiskCache는 캐시 폴더 경로를 얻으려고 생성자에서 Context를 받아야 한다. 매개변수 타입은 Context 그대로 둔다.

```kotlin
@Singleton
class ImageDiskCache @Inject constructor(
    context: Context,
) {
    private val dir = File(context.cacheDir, "images")
}
```

- 이대로 빌드하자 Context 바인딩을 찾을 수 없다는 오류로 멈췄다.
- 급한 대로 생성자 매개변수를 빼고 MainActivity의 onCreate에서 imageDiskCache.init(this)로 넘기게 바꿨다. 이번에는 사용자가 뒤로 가기로 MainActivity를 닫은 뒤에도 힙 덤프에 그 MainActivity가 회수되지 않고 남아 있었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5669
(15291, 5669, 'AuthManager의 @Singleton을 @ActivityScoped로 바꿔 ActivityComponent에서 만들어지게 한다.', '화면마다 AuthManager가 따로 생겨 앱 전체에서 하나라는 요구가 깨진다. 게다가 SyncService가 속한 ServiceComponent는 ActivityComponent의 바인딩을 볼 수 없어 빌드도 다시 멈춘다. 오류 위치만 옮기면 된다고 본 선지다.', false),
(15292, 5669, 'StorageModule의 @InstallIn 대상을 SingletonComponent로 바꿔 AuthManager와 같은 높이에 설치한다.', '자식 컴포넌트는 부모의 바인딩을 쓸 수 있지만 부모는 자식 것을 보지 못한다. AuthManager는 SingletonComponent에서 만들어지므로 TokenStore도 그 높이에 있어야 하고, 화면에 의존하지 않아 옮겨도 된다. SyncService도 같은 바인딩을 받는다.', true),
(15293, 5669, 'provideTokenStore에 @Singleton을 붙여 TokenStore 바인딩을 앱 전역 수명으로 끌어올린다.', '스코프는 설치된 컴포넌트와 짝이 맞아야 한다. ActivityComponent 모듈에 @Singleton을 붙이면 스코프 불일치로 빌드가 멈추고, 설치 위치도 그대로라 AuthManager는 여전히 바인딩을 못 찾는다. 스코프가 설치 위치를 바꾼다고 오해한 선지다.', false),
(15294, 5669, 'AuthManager가 생성자 대신 @Inject lateinit var 필드로 TokenStore를 받도록 바꾼다.', '주입 방식을 바꿔도 AuthManager는 SingletonComponent에서 만들어지므로 같은 그래프 안에서 TokenStore를 찾는다. 필드 주입이 컴포넌트 경계 검사를 피해 간다고 오해한 선지다.', false),

-- 문제 5670
(15295, 5670, 'DateFormatter는 @Provides, AppDatabase는 @Provides, CartRepository는 @Binds', 'DateFormatter는 생성자를 고칠 수 있어 @Inject 생성자만 붙이면 모듈 없이 그래프에 들어간다. 모든 객체에 모듈이 있어야 주입된다고 오해해 첫 번째 규칙을 어긴 선지다.', false),
(15296, 5670, 'DateFormatter는 @Inject 생성자, AppDatabase는 @Binds, CartRepository는 @Provides', '@Binds는 본문 없는 abstract 함수라 빌더를 호출할 자리가 없어 AppDatabase를 만들 수 없다. 인터페이스 연결은 생성 코드가 적은 @Binds가 규칙에 맞는데, 두 방식의 쓰임을 뒤바꾼 선지다.', false),
(15297, 5670, 'DateFormatter는 @Inject 생성자, AppDatabase는 @Inject 생성자, CartRepository는 @Binds', 'AppDatabase는 Room이 구현을 만드는 추상 클래스라 생성자에 @Inject를 붙여 직접 만들 수 없다. 빌더를 거쳐야 하는 객체는 생성 로직을 담을 본문이 있는 @Provides 함수가 필요하다.', false),
(15298, 5670, 'DateFormatter는 @Inject 생성자, AppDatabase는 @Provides, CartRepository는 @Binds', '생성자를 고칠 수 있으면 모듈 없는 생성자 주입이 먼저다. 빌더로만 얻는 객체는 본문이 있는 @Provides가 맡고, 인터페이스와 구현체 연결은 생성 코드가 가장 적은 @Binds가 두 번째 규칙에 맞다.', true),

-- 문제 5671
(15299, 5671, 'product와 cart가 각자의 백 스택 항목을 기준으로 CartViewModel을 따로 얻는다.', 'hiltViewModel()은 가장 가까운 ViewModelStoreOwner에서 ViewModel을 꺼내는데, composable 목적지마다 NavBackStackEntry가 그 소유자다. 그래서 두 화면이 다른 인스턴스를 쓴다. 공유하려면 상위 그래프의 백 스택 항목을 소유자로 넘겨야 한다.', true),
(15300, 5671, 'CartViewModel에 스코프 애너테이션이 없어 hiltViewModel()을 부를 때마다 새로 만들어진다.', 'ViewModel 인스턴스는 스코프 애너테이션이 아니라 소유자의 ViewModelStore가 보관한다. 같은 소유자 안에서는 재구성으로 몇 번을 불러도 같은 인스턴스가 돌아온다. 일반 바인딩의 스코프 규칙을 ViewModel에 그대로 옮긴 오해다.', false),
(15301, 5671, 'CartRepository가 @Singleton이라 두 화면이 같은 저장소를 쓰면서 개수가 덮어쓰였다.', 'count는 저장소가 아니라 ViewModel 필드에 들어 있다. 저장소를 함께 쓴다면 오히려 값이 이어져 보여야 하므로 0이 되는 원인이 될 수 없다. 공유 범위를 거꾸로 짚은 선지다.', false),
(15302, 5671, 'cart로 이동하는 순간 product의 CartViewModel이 onCleared로 정리돼 값이 사라진다.', 'navigate는 product 항목을 백 스택에 남겨 두므로 그 ViewModel도 살아 있다. 뒤로 가면 3이 그대로인 것이 증거다. onCleared는 항목이 백 스택에서 빠질 때 불린다.', false),

-- 문제 5672
(15303, 5672, 'SearchHistoryEntryPoint를 구현한 클래스를 직접 작성해 모듈에 등록해야 호출이 성공한다.', '인터페이스 구현은 Hilt가 생성한 SingletonComponent가 맡는다. 개발자는 꺼낼 바인딩의 반환 타입만 선언하면 된다. 모듈 등록은 그래프에 없던 객체를 새로 넣을 때 필요한 일이다.', false),
(15304, 5672, '@InstallIn을 지워도 fromApplication이 Application 수명의 컴포넌트를 알아서 찾아 준다.', '@InstallIn이 있어야 어느 컴포넌트가 이 인터페이스를 구현할지 정해진다. 빠지면 Hilt가 빌드 단계에서 오류를 낸다. 접근자 이름이 설치 위치까지 정해 준다고 오해한 선지다.', false),
(15305, 5672, 'SearchActivity에서 add한 검색어가 SuggestionProvider의 recent() 결과에도 나타난다.', '두 곳 모두 SingletonComponent가 보관한 같은 @Singleton 인스턴스를 받는다. 필드로 주입받든 EntryPoint로 꺼내든 출처 컴포넌트가 같으면 인스턴스도 같아서, 한쪽에서 쌓은 검색어가 다른 쪽에 보인다.', true),
(15306, 5672, 'query()가 불릴 때마다 EntryPoint가 SearchHistory를 새로 만들어 이전 검색어는 비어 있다.', 'EntryPoint는 객체를 새로 만드는 창구가 아니라 컴포넌트에 있는 바인딩을 꺼내 오는 창구다. SearchHistory는 @Singleton이라 컴포넌트가 하나만 만들어 두고 매번 같은 것을 돌려준다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1846, 5673, '7,7개,7 개,일곱,일곱 개', '스코프가 없는 ClickLogger는 주입 지점마다 새로 만들어진다. 한 화면 인스턴스에서 두 번 주입되고, 회전 전후로 화면이 두 번 만들어졌으니 4개다. @ActivityScoped인 ThemeHelper는 Activity 인스턴스 하나 안에서만 공유돼 회전 전후 1개씩 2개, @ActivityRetainedScoped인 CheckoutSession은 Activity가 완전히 끝날 때까지 회전을 넘어 유지돼 1개다. 합은 4 + 2 + 1 = 7이다.

헷갈리기 쉬운 경계는 세 가지다. 스코프가 없으면 화면당 하나라고 보면 5, @ActivityScoped도 회전을 견딘다고 보면 6, @ActivityRetainedScoped까지 회전마다 새로 만든다고 보면 8이 나온다. 회전을 견디는 쪽은 ViewModel과 수명이 같은 @ActivityRetainedScoped이고, @ActivityScoped는 Activity#onDestroy와 함께 사라진다.'),
       (1847, 5674, '@ApplicationContext,ApplicationContext,Application Context,애플리케이션 컨텍스트,애플리케이션컨텍스트', 'Hilt는 한정자 없는 Context를 바인딩해 두지 않는다. 대신 앱과 수명이 같은 Context를 @ApplicationContext라는 표식으로 SingletonComponent에 넣어 두므로, 매개변수에 이 애너테이션을 붙이면 타입은 Context 그대로 두고 빌드 오류가 사라진다. 프로세스가 끝날 때까지 사는 @Singleton 객체가 이 Context를 들고 있어도 화면을 붙잡지 않으므로 누수도 생기지 않는다.

경계는 @ActivityContext다. 둘 다 같은 Context 타입을 구분하는 한정자지만, @ActivityContext는 ActivityComponent와 그 아래 컴포넌트에만 있어 부모인 SingletonComponent에서는 찾을 수 없다. 설령 넘길 수 있더라도 본문의 init(this)처럼 종료된 Activity를 붙잡아 누수가 난다. 긴 수명 객체에는 Application Context를, 테마·레이아웃처럼 Activity가 꼭 필요한 짧은 수명 객체에만 Activity Context를 넣는다.');
