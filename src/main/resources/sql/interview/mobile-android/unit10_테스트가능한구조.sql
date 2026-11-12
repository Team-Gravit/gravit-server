-- Unit: 테스트 가능한 구조 (Unit ID: 176)
-- Chapter: Android (Chapter ID: 16)
-- Topic: COMPOSE
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-android-unit10 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(876, 'COMPOSE', 176, 'HARD', true,
 'Context를 생성자로 받고, RetrofitClient 싱글턴을 직접 참조하며, Dispatchers.IO를 하드코딩한 ViewModel이 있습니다. 이 ViewModel을 JVM 단위 테스트가 가능한 구조로 바꾸려면 어떻게 리팩터링해야 하고, 각 변경이 테스트에서 어떤 이점을 주는지 설명해 주시겠어요?',
 '이 ViewModel은 프레임워크·구현체·디스패처에 직접 결합되어 있어 JVM에서 실행할 수도, 의존성을 대체할 수도 없습니다. 먼저 RetrofitClient 싱글턴을 직접 참조하는 대신 ViewModel이 OrderRepository 같은 인터페이스에 의존하게 하고, 네트워크·DB 구현체는 Hilt 같은 DI로 주입받도록 바꿉니다. 그러면 테스트에서는 그 인터페이스 자리에 인메모리 맵으로 동작하는 Fake 구현을 넣어 성공·실패 시나리오를 제어할 수 있습니다. 다음으로 ViewModel에서 Context 같은 안드로이드 프레임워크 의존을 제거합니다. ViewModel·UseCase에 Context·Activity·View가 없어야 JVM에서 실행할 수 있고, 문자열 리소스가 필요하면 ID로 넘기고 UI에서 해석합니다. 또 Dispatchers.IO를 하드코딩하면 테스트에서 제어할 수 없으므로 생성자로 CoroutineDispatcher를 주입받고, 테스트에서는 테스트 디스패처를 넘깁니다. 같은 이유로 System.currentTimeMillis() 대신 Clock을 주입하면 결정적인 테스트를 만들 수 있습니다. 마지막으로 입력은 이벤트 함수 호출, 출력은 StateFlow 값으로 단방향 데이터 흐름을 명확히 하면, 테스트가 ''호출하고 상태를 확인''하는 형태로 단순해집니다.',
 'interview-question/876.mp3'),
(877, 'COMPOSE', 176, 'NORMAL', true,
 '안드로이드 테스트에서 의존성을 대체할 때 쓰는 Fake와 Mock은 어떻게 다르고, 각각 어떤 대상에 쓰는 것이 적합한가요?',
 'Fake는 인터페이스를 실제로 동작하는 단순 구현으로 작성한 가짜 구현입니다. 예를 들어 인메모리 맵으로 동작하는 FakeOrderRepository를 만들고 shouldFail 같은 플래그로 실패 시나리오도 제어합니다. Mock은 MockK·Mockito 같은 라이브러리로 호출별 반환값·행동을 지정하는 모의 객체입니다. 검증 방식도 다른데, Fake는 호출 후 결과 상태를 확인하는 상태 기반 검증이고, Mock은 특정 메서드가 호출되었는지와 인자를 확인하는 행위 기반 검증입니다. Fake는 여러 테스트에서 공유할 수 있고 리팩터링에 강한 반면, Mock은 테스트마다 설정해야 하고 구현 세부에 결합되기 쉽습니다. 그래서 적합한 대상도 다릅니다. Fake는 Repository나 데이터 소스 같은 핵심 협력 객체에 적합하고, Mock은 분석 SDK나 알림처럼 부수효과가 일어났는지 확인하는 것이 목적인 경우에 적합합니다. 공식 가이드도 Fake를 우선하고 Mock은 보조적으로 쓰기를 권장하는데, Mock으로 verify(repository).getOrder(1L)처럼 내부 호출을 검증하면 리팩터링 때마다 테스트가 깨지기 때문입니다.',
 'interview-question/877.mp3'),
(878, 'COMPOSE', 176, 'NORMAL', true,
 '주문 화면에서 할인 계산 결과가 맞는지를 Compose UI 테스트로 화면의 텍스트를 확인해 검증하려고 합니다. 이 방식의 문제는 무엇이고, ViewModel 단위 테스트와 Compose UI 테스트에 각각 무엇을 검증하도록 나누어야 할까요?',
 '할인 계산이 맞는지를 화면의 텍스트로 확인하는 것은 UI 테스트로 비즈니스 로직을 검증하는 것이라, 느리고 깨지기 쉽습니다. 할인 계산 같은 비즈니스 로직은 UI 없이도 검증할 수 있으므로 ViewModel이나 UseCase 단위 테스트에서 검증하는 것이 훨씬 빠르고, 로딩·에러·성공 상태 전환이나 데이터 가공도 마찬가지로 ViewModel 단위 테스트에 맡깁니다. 반면 Compose UI 테스트는 ''주어진 상태를 올바르게 보여 주는가''만 검증합니다. 예를 들어 에러 상태면 재시도 버튼이 보이는지 같은 상태→화면 표시 매핑이나, 버튼 클릭 시 onRetry 같은 이벤트 콜백이 호출되는지를 확인합니다. 이때 Stateless 컴포저블은 상태를 직접 주입할 수 있어서 createComposeRule()로 ViewModel·내비게이션 없이 단독 렌더링해 테스트할 수 있습니다. 로그인에서 홈, 결제로 이어지는 전체 흐름은 실제 통합 확인이 필요하지만 느리고 불안정하므로 소수의 계측 E2E 테스트로 한정합니다.',
 'interview-question/878.mp3'),
(879, 'COMPOSE', 176, 'EASY', true,
 '안드로이드 테스트의 종류를 실행 환경과 속도 기준으로 나누어 설명하고, 테스트 피라미드에서 각 종류를 어느 정도 비중으로 두는지 말씀해 주시겠어요?',
 '안드로이드 테스트는 크게 세 종류입니다. 로컬 단위 테스트는 src/test에서 JVM으로 실행되어 매우 빠르고, ViewModel·UseCase·Repository 같은 순수 로직을 검증합니다. 로컬 UI 테스트는 JVM에 Robolectric을 붙여 Compose 컴포저블의 렌더링과 상호작용을 비교적 빠르게 검증합니다. 계측 테스트는 src/androidTest에서 에뮬레이터나 실기기로 실행되어 느리며, 실제 기기 동작이나 통합, 화면 흐름을 검증합니다. 테스트 피라미드에서는 빠르고 안정적인 ViewModel·Repository 단위 테스트를 대부분으로 두고, 통합·Compose UI 테스트는 일부, 느리고 불안정한 계측·E2E 화면 흐름 테스트는 핵심 경로만 소수로 둡니다. 핵심은 ''논리는 아래에서, 화면은 위에서 최소한으로''이며, ViewModel에 로직이 모여 있으면 대부분의 시나리오를 JVM 단위 테스트로 수 초 안에 검증할 수 있습니다.',
 'interview-question/879.mp3'),
(880, 'COMPOSE', 176, 'EASY', true,
 'viewModelScope를 사용하는 ViewModel을 JVM 단위 테스트할 때 Dispatchers.Main을 교체해야 하는 이유와 그 방법을 설명해 주세요.',
 'viewModelScope는 Dispatchers.Main을 사용하는데, JVM 테스트 환경에는 안드로이드 메인 루퍼가 없기 때문에 그대로 실행하면 ''Module with the Main dispatcher had failed to initialize'' 같은 예외가 발생합니다. 그래서 kotlinx-coroutines-test의 Dispatchers.setMain으로 Main 디스패처를 UnconfinedTestDispatcher 같은 테스트 디스패처로 교체하고, 테스트가 끝나면 resetMain으로 되돌립니다. 이 과정을 TestWatcher를 상속한 MainDispatcherRule 같은 JUnit Rule로 만들어 starting에서 setMain, finished에서 resetMain을 호출하게 하고, 테스트 클래스에서 @get:Rule로 재사용하는 것이 관례입니다.',
 'interview-question/880.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 876
(4719, 876, 'ViewModel이 Repository 인터페이스에 의존하고 구현체는 DI로 주입받도록 바꿈을 설명', 'ESSENTIAL', 1),
(4720, 876, 'ViewModel에서 Context 같은 안드로이드 프레임워크 의존을 제거해야 JVM에서 실행 가능함을 설명', 'ESSENTIAL', 2),
(4721, 876, 'Dispatchers.IO 하드코딩 대신 생성자로 CoroutineDispatcher를 주입받아야 함을 설명', 'ESSENTIAL', 3),
(4722, 876, '테스트에서는 Repository 인터페이스 자리에 Fake 구현을 넣어 대체함을 언급', 'ESSENTIAL', 4),
(4723, 876, 'System.currentTimeMillis() 대신 Clock을 주입해 결정적 테스트를 만듦을 언급', 'SUPPLEMENTARY', 5),
(4724, 876, '이벤트 함수 호출 후 StateFlow 값을 확인하는 형태로 테스트가 단순해짐을 언급', 'SUPPLEMENTARY', 6),

-- 질문 877
(4725, 877, 'Fake는 인터페이스를 실제로 동작하는 단순 구현으로 작성한 것임을 언급', 'ESSENTIAL', 1),
(4726, 877, 'Mock은 라이브러리로 호출별 반환값·행동을 지정하는 모의 객체임을 언급', 'ESSENTIAL', 2),
(4727, 877, 'Fake는 상태 기반, Mock은 호출 여부·인자를 보는 행위 기반 검증이라는 차이를 설명', 'ESSENTIAL', 3),
(4728, 877, 'Fake는 Repository 같은 핵심 협력 객체, Mock은 부수효과 확인이 목적인 경우에 적합하다는 대상 차이를 설명', 'ESSENTIAL', 4),
(4729, 877, '공식 가이드가 Fake를 우선하고 Mock은 보조적으로 쓰기를 권장함을 언급', 'SUPPLEMENTARY', 5),
(4730, 877, 'Mock으로 내부 호출을 검증하면 리팩터링 때마다 테스트가 깨짐을 언급', 'SUPPLEMENTARY', 6),

-- 질문 878
(4731, 878, 'UI 테스트로 비즈니스 로직을 검증하면 느리고 깨지기 쉬움을 언급', 'ESSENTIAL', 1),
(4732, 878, '할인 계산 같은 비즈니스 로직은 ViewModel 단위 테스트에서 검증함을 설명', 'ESSENTIAL', 2),
(4733, 878, 'Compose UI 테스트는 주어진 상태를 화면에 올바르게 보여 주는지만 검증함을 설명', 'ESSENTIAL', 3),
(4734, 878, 'Stateless 컴포저블에 상태를 직접 주입해 ViewModel 없이 UI를 테스트함을 언급', 'SUPPLEMENTARY', 4),
(4735, 878, '사용자 입력에 따른 이벤트 콜백 호출도 Compose UI 테스트로 확인함을 언급', 'SUPPLEMENTARY', 5),
(4736, 878, '로그인부터 결제까지의 전체 흐름은 소수의 계측 E2E 테스트로 한정함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 879
(4737, 879, '로컬 단위 테스트는 JVM에서 실행되어 매우 빠름을 언급', 'ESSENTIAL', 1),
(4738, 879, '계측 테스트는 에뮬레이터나 실기기에서 실행되어 느림을 언급', 'ESSENTIAL', 2),
(4739, 879, '단위 테스트를 대부분으로 두고 계측·E2E 테스트는 핵심 경로의 소수로 두는 비중을 설명', 'ESSENTIAL', 3),
(4740, 879, '로컬 UI 테스트는 Robolectric을 붙여 JVM에서 Compose 컴포저블을 검증함을 언급', 'SUPPLEMENTARY', 4),
(4741, 879, '논리는 아래에서, 화면은 위에서 최소한으로 검증한다는 피라미드 원칙을 언급', 'SUPPLEMENTARY', 5),

-- 질문 880
(4742, 880, 'viewModelScope가 Dispatchers.Main을 사용함을 언급', 'ESSENTIAL', 1),
(4743, 880, 'JVM 테스트에는 안드로이드 메인 루퍼가 없어 그대로 실행하면 예외가 발생함을 설명', 'ESSENTIAL', 2),
(4744, 880, 'Dispatchers.setMain으로 Main을 테스트 디스패처로 교체함을 설명', 'ESSENTIAL', 3),
(4745, 880, '테스트가 끝나면 resetMain으로 원래 디스패처로 되돌림을 언급', 'SUPPLEMENTARY', 4),
(4746, 880, '디스패처 교체 로직을 JUnit Rule로 만들어 재사용하는 관례를 언급', 'SUPPLEMENTARY', 5);
