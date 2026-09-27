-- Unit: 의존성 주입 (Unit ID: 173)
-- Chapter: Android (Chapter ID: 16)
-- Topic: COMPOSE
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-android-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(861, 'COMPOSE', 173, 'HARD', true,
 'Hilt에서 어떤 객체에 스코프를 붙일지 결정할 때 무엇을 기준으로 판단하고, 스코프를 잘못 선택하면 어떤 문제가 생기는지 설명해 주세요.',
 'Hilt에서 스코프가 없는 바인딩은 기본적으로 주입할 때마다 새 인스턴스를 만들고, 스코프를 붙이면 해당 컴포넌트 인스턴스 안에서 하나만 만들어 공유합니다. 그래서 스코프는 필요할 때만 붙여야 하고, 판단 기준은 ''이 객체가 상태를 가지며 공유되어야 하는가''입니다. 반대로 무조건 @Singleton을 붙이면 상태가 있는 객체가 앱 전역에서 공유되어 예상치 못한 상태 공유 버그가 생기고, 메모리도 프로세스 종료까지 해제되지 않습니다. 또 Activity Context를 @Singleton 객체에 주입하면 Activity가 종료돼도 싱글턴이 붙들고 있어 누수가 생기므로 @ApplicationContext를 사용해야 합니다. 반면 OkHttpClient나 Room DB 같은 무거운 객체를 스코프 없이 매번 새로 생성하면 커넥션 풀과 캐시가 분리되어 성능이 저하되므로, 이런 객체에는 @Singleton이 적절합니다.'),
(862, 'COMPOSE', 173, 'NORMAL', true,
 'Hilt 모듈에서 @Provides와 @Binds는 어떻게 다르고, 각각 언제 사용하나요?',
 '@Provides는 빌더 패턴이나 서드파티 라이브러리 객체처럼 우리가 생성자를 소유하지 않아 직접 생성 로직이 필요한 객체에 사용합니다. 본문이 있는 일반 함수로 작성하고 필요한 의존성을 매개변수로 여러 개 받을 수 있으며, 보통 object 모듈에 둡니다. @Binds는 @Inject 생성자를 가진 구현체를 인터페이스 타입으로 노출하는, 즉 인터페이스와 구현체를 연결하는 용도입니다. abstract class나 interface 모듈 안에 본문이 없는 abstract 함수로 선언하고, 매개변수는 구현체 정확히 1개, 반환 타입은 인터페이스입니다. @Provides는 팩토리 클래스가 생성되어 약간의 오버헤드가 있는 반면 @Binds는 코드 생성이 최소라 더 효율적입니다. 선택 기준은 생성자에 @Inject를 붙일 수 있으면 모듈 없이 생성자 주입을 최우선으로 하고, 인터페이스 연결은 @Binds, 그 외는 @Provides를 쓰는 것입니다.'),
(863, 'COMPOSE', 173, 'NORMAL', true,
 'Hilt의 @ActivityRetainedScoped와 @ActivityScoped는 어떤 차이가 있나요?',
 '@ActivityRetainedScoped는 ActivityRetainedComponent의 스코프로, 이 컴포넌트는 Activity 최초 생성 시 만들어지고 Activity가 완전히 종료될 때 소멸합니다. 그래서 화면 회전 같은 구성 변경 후에도 같은 인스턴스를 유지합니다. 반면 @ActivityScoped는 ActivityComponent의 스코프로 Activity#onCreate에 생성되어 Activity#onDestroy에 소멸하므로, 화면 회전 시 새로 만들어집니다. 즉 @ActivityRetainedScoped는 ViewModel처럼 회전을 견디고 @ActivityScoped는 회전 시 새로 생성된다는 점이 핵심이며, 두 스코프의 관계는 ViewModel과 Activity의 관계와 동일합니다.'),
(864, 'COMPOSE', 173, 'EASY', true,
 '의존성 주입(DI)이란 무엇이며, 왜 필요한지 설명해 주세요.',
 '의존성 주입은 객체가 필요한 협력 객체를 직접 만들지 않고 외부에서 받는 설계 원칙입니다. 클래스 안에서 Retrofit 빌더로 API 객체를 직접 생성하는 식으로 만들면 생성 방법·수명·교체가 그 클래스에 묶여서, 테스트에서 네트워크를 가짜로 바꿀 수 없고 같은 객체를 여러 곳에서 각각 만들어 메모리와 설정이 중복됩니다. DI는 생성의 책임을 컨테이너로 옮기고 클래스는 인터페이스에만 의존하게 만들어 결합도를 낮춥니다. 안드로이드에서는 Hilt가 이 역할을 하는데, Hilt는 컴파일 타임에 코드를 생성하는 Dagger 위에 안드로이드 전용 규칙을 얹은 것이라 런타임 리플렉션이 없어 빠르고 의존성 누락을 빌드 시점에 잡아냅니다.'),
(865, 'COMPOSE', 173, 'EASY', true,
 'Hilt의 @EntryPoint는 무엇이며 어떤 상황에서 사용하나요?',
 '@AndroidEntryPoint를 붙일 수 없는 클래스는 필드 주입을 받을 수 없는데, 이때 @EntryPoint 인터페이스를 정의하면 컴포넌트에서 원하는 바인딩을 직접 꺼내는 접근 창구가 됩니다. 대표적인 사용처는 Application보다 먼저 생성되는 ContentProvider, 서드파티 라이브러리가 생성하는 객체, 동적 기능 모듈 등입니다. @InstallIn으로 설치할 컴포넌트를 지정한 인터페이스를 만들고, EntryPointAccessors.fromApplication·fromActivity·fromFragment 등 컴포넌트에 맞는 접근자로 진입점을 얻어 바인딩을 꺼냅니다. 다만 서비스 로케이터처럼 동작하므로 남용하면 의존성이 코드에 숨겨지기 때문에, 정말로 주입이 불가능한 경계 지점에서만 사용해야 합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 861
(4637, 861, '객체가 상태를 가지며 공유되어야 하는가를 스코프 부착의 판단 기준으로 제시', 'ESSENTIAL', 1),
(4638, 861, '무조건 @Singleton을 붙이면 상태가 앱 전역에서 공유되어 상태 공유 버그가 생긴다고 언급', 'ESSENTIAL', 2),
(4639, 861, 'OkHttpClient·Room DB 같은 무거운 객체를 스코프 없이 매번 생성하면 성능이 저하된다고 언급', 'ESSENTIAL', 3),
(4640, 861, '스코프가 없는 바인딩은 주입할 때마다 새 인스턴스를 만든다고 언급', 'SUPPLEMENTARY', 4),
(4641, 861, 'Activity Context를 @Singleton 객체에 주입하면 Activity 종료 후에도 붙들려 누수된다고 언급', 'SUPPLEMENTARY', 5),
(4642, 861, '@Singleton 객체의 메모리는 프로세스 종료까지 해제되지 않는다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 862
(4643, 862, '@Provides는 빌더·외부 라이브러리처럼 직접 생성 로직이 필요한 객체에 쓴다고 언급', 'ESSENTIAL', 1),
(4644, 862, '@Binds는 인터페이스와 구현체를 연결하는 용도라고 언급', 'ESSENTIAL', 2),
(4645, 862, '@Binds 메서드는 본문이 없는 abstract 함수로 선언한다고 언급', 'ESSENTIAL', 3),
(4646, 862, '@Binds는 코드 생성이 최소라 @Provides보다 효율적이라고 언급', 'SUPPLEMENTARY', 4),
(4647, 862, '@Binds 메서드의 매개변수는 구현체 정확히 1개라고 언급', 'SUPPLEMENTARY', 5),
(4648, 862, '생성자에 @Inject를 붙일 수 있으면 모듈 없이 생성자 주입이 최우선이라고 언급', 'SUPPLEMENTARY', 6),

-- 질문 863
(4649, 863, '@ActivityRetainedScoped 인스턴스는 화면 회전 후에도 같은 인스턴스로 유지된다고 언급', 'ESSENTIAL', 1),
(4650, 863, '@ActivityScoped 인스턴스는 화면 회전 시 새로 만들어진다고 언급', 'ESSENTIAL', 2),
(4651, 863, 'ActivityRetainedComponent는 Activity가 완전히 종료될 때 소멸한다고 언급', 'SUPPLEMENTARY', 3),
(4652, 863, 'ActivityComponent는 Activity#onCreate에 생성되어 Activity#onDestroy에 소멸한다고 언급', 'SUPPLEMENTARY', 4),
(4653, 863, '@ActivityRetainedScoped의 수명을 ViewModel에 빗대어 회전을 견딘다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 864
(4654, 864, 'DI는 객체가 필요한 협력 객체를 직접 만들지 않고 외부에서 받는 설계 원칙이라고 언급', 'ESSENTIAL', 1),
(4655, 864, '클래스 안에서 의존 객체를 직접 생성하면 테스트에서 가짜로 바꿀 수 없다고 언급', 'ESSENTIAL', 2),
(4656, 864, 'DI가 생성의 책임을 컨테이너로 옮겨 결합도를 낮춘다고 언급', 'ESSENTIAL', 3),
(4657, 864, '같은 객체를 여러 곳에서 각각 만들면 메모리·설정이 중복된다고 언급', 'SUPPLEMENTARY', 4),
(4658, 864, 'Hilt가 Dagger 기반이라 의존성 누락을 빌드 시점에 잡아낸다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 865
(4659, 865, '@AndroidEntryPoint를 붙일 수 없어 필드 주입을 받지 못하는 클래스에서 쓴다고 언급', 'ESSENTIAL', 1),
(4660, 865, '@EntryPoint 인터페이스가 컴포넌트에서 원하는 바인딩을 직접 꺼내는 접근 창구라고 언급', 'ESSENTIAL', 2),
(4661, 865, 'ContentProvider·서드파티 라이브러리가 생성하는 객체·동적 기능 모듈 중 최소 1개를 사용처로 제시', 'ESSENTIAL', 3),
(4662, 865, 'EntryPointAccessors.fromApplication 같은 접근자로 진입점을 얻는다고 언급', 'SUPPLEMENTARY', 4),
(4663, 865, '서비스 로케이터처럼 동작해 남용하면 의존성이 코드에 숨겨진다고 언급', 'SUPPLEMENTARY', 5);
