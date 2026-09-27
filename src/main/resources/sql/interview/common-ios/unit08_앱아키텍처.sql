-- Unit: 앱 아키텍처 (Unit ID: 109)
-- Chapter: iOS (Chapter ID: 9)
-- Topic: IOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-ios-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(541, 'IOS_COMMON', 109, 'HARD', true,
 '뷰 컨트롤러 하나에 네트워크 호출, 목록 필터링, 상세 화면 push까지 모두 들어 있는 주문 목록 화면을 테스트 가능한 구조로 리팩터링한다면 코드를 어떻게 나누고, 그 대가는 무엇인가요?',
 '지금 구조는 서버 없이는 필터링 규칙조차 테스트할 수 없고, 목록 화면이 OrderDetailViewController를 직접 생성하므로 상세 화면의 존재를 알아야 합니다. 먼저 취소 주문 필터링이나 가격 포맷팅 같은 표현 로직과 로딩·오류 상태를 ViewModel로 옮기고, ViewModel은 UIKit을 import하지 않는 순수 Swift 객체로 만듭니다. 뷰 컨트롤러는 ViewModel의 상태를 관찰해 그리기만 합니다. 네트워크 호출은 OrderService 같은 프로토콜로 추상화하고 ViewModel이 init(service:)로 생성자 주입받게 하면, 테스트에서는 StubOrderService 같은 가짜 구현을 넣어 서버 없이 필터 규칙과 오류 처리를 수 밀리초 만에 검증할 수 있습니다. 상세 화면으로의 push는 Coordinator로 옮겨서 ViewModel은 ''상세로 가고 싶다''는 의도만 알리고 실제 전환은 Coordinator가 수행하게 합니다. 그러면 목록 화면은 다음 화면을 모르게 됩니다. 대가는 보일러플레이트입니다. MVVM은 바인딩 코드가, MVVM-C는 Coordinator 계층이 추가로 필요합니다. 그래서 화면 수가 적은 앱이라면 필요 이상으로 계층을 늘리는 것 자체가 비용이 되므로 팀 규모와 흐름 복잡도를 보고 수준을 정해야 합니다.'),
(542, 'IOS_COMMON', 109, 'NORMAL', true,
 'iOS에서 MVC와 MVVM은 책임 분리 관점에서 어떤 차이가 있나요?',
 'Apple 방식의 MVC에서는 Controller, 즉 UIViewController가 View와 Model 사이를 중재하면서 표현 로직까지 가집니다. 그래서 MVC의 단위 테스트 범위는 거의 없습니다. 대신 보일러플레이트가 최소이고, 프로토타입이나 화면 수가 적은 앱에 적합합니다. MVVM은 화면에 표시할 상태(목록, 로딩 여부, 오류 메시지)와 사용자 액션 처리를 ViewModel로 옮깁니다. ViewModel은 UIKit을 import하지 않기 때문에 순수 Swift 객체로 단위 테스트할 수 있고, 테스트 범위가 ViewModel과 Service까지 넓어집니다. View(ViewController)는 ViewModel의 상태를 바인딩으로 관찰해 그리기만 하고 입력은 ViewModel에 전달합니다. 바인딩 수단은 클로저, Combine의 @Published, Observation 등 프로젝트 선택에 따르며 바인딩 방식이 MVVM의 본질은 아닙니다. 대신 MVVM은 바인딩 코드만큼 보일러플레이트가 중간 수준으로 늘어납니다.'),
(543, 'IOS_COMMON', 109, 'NORMAL', true,
 '의존성 주입에서 생성자 주입과 프로퍼티 주입은 어떻게 다르고, 각각 언제 사용하나요?',
 '의존성 주입은 객체가 필요한 협력자를 직접 만들거나 싱글턴으로 찾지 않고 외부에서 받는 기법으로, 테스트에서 실제 네트워크 대신 가짜 구현을 끼워 넣는 것이 핵심 목적입니다. 생성자 주입은 init(service: OrderService)처럼 생성 시점에 받는 방식이라 의존성이 명시적이고 불변이며, 빠뜨리면 컴파일 오류가 납니다. 단점은 생성 지점의 인자가 늘어난다는 것입니다. 프로퍼티 주입은 var service: OrderService!처럼 값을 넣는 방식이라 스토리보드나 시스템이 생성하는 객체에도 적용할 수 있습니다. 하지만 주입 전에 접근하면 크래시가 나기 때문에 선택적 의존에만 사용합니다. 그래서 의존성 주입은 생성자 주입을 기본으로 합니다.'),
(544, 'IOS_COMMON', 109, 'EASY', true,
 'Massive View Controller란 무엇이며, UIKit에서 왜 쉽게 발생하나요?',
 'Massive View Controller는 네트워크, 파싱, 포맷팅, 화면 전환 같은 로직이 전부 뷰 컨트롤러 하나에 쏟아져 비대해진 상태를 말합니다. Apple의 MVC에서는 Controller가 View와 Model 사이를 중재하는데, UIKit에서 Controller는 곧 UIViewController입니다. UIViewController는 뷰 생명주기, 사용자 입력, 데이터 로드, 화면 전환을 모두 받을 수 있어서 모든 코드가 뷰 컨트롤러로 모이기 쉽습니다. 또 뷰 컨트롤러가 뷰의 생명주기까지 소유하므로 View와 Controller의 경계가 사실상 없어지고 남은 로직이 모두 여기로 들어갑니다. 이렇게 비대해진 뷰 컨트롤러는 UIKit 없이는 인스턴스도 만들 수 없어 단위 테스트가 불가능하고, 한 화면을 고치면 다른 기능이 깨지는 회귀도 잦아집니다.'),
(545, 'IOS_COMMON', 109, 'EASY', true,
 'MVVM-C에서 Coordinator는 무엇이며, 어떤 이점이 있나요?',
 'Coordinator는 어떤 화면 다음에 어떤 화면이 오는가라는 내비게이션 흐름을 전담하는 객체입니다. 뷰 컨트롤러와 ViewModel은 ''상세로 가고 싶다''는 의도만 알리고, 실제 push나 present는 Coordinator가 수행합니다. 이렇게 하면 각 화면이 다음 화면의 존재를 모르게 되어 화면 재사용과 A/B 테스트, 딥링크 진입 같은 흐름 변경이 쉬워집니다. 푸시 알림이나 Universal Link로 특정 화면에 진입할 때도 Coordinator에 그 화면으로 가라고 요청하면 됩니다. 또 ViewModel이 navigationController를 참조하지 않아도 되므로 UIKit 의존이 생기지 않습니다. 다만 부모 Coordinator가 자식 Coordinator를 childCoordinators에 보관해 해제되지 않게 하고 흐름이 끝나면 제거해야 하며, 이 관리를 빠뜨리면 메모리 누수나 조기 해제가 발생합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 541
(2901, 541, '필터링·포맷팅 같은 표현 로직을 ViewModel로 옮긴다고 설명', 'ESSENTIAL', 1),
(2902, 541, '네트워크 호출을 OrderService 같은 프로토콜로 추상화한다고 설명', 'ESSENTIAL', 2),
(2903, 541, '상세 화면 push를 Coordinator로 옮긴다고 설명', 'ESSENTIAL', 3),
(2904, 541, '대가로 바인딩 코드나 Coordinator 계층 같은 보일러플레이트가 늘어남을 언급', 'ESSENTIAL', 4),
(2905, 541, '서비스를 ViewModel에 생성자로 주입받게 한다고 언급', 'SUPPLEMENTARY', 5),
(2906, 541, 'Stub 서비스로 서버 없이 필터 규칙을 테스트할 수 있다고 언급', 'SUPPLEMENTARY', 6),
(2907, 541, '화면 수가 적은 앱에서는 과한 계층 자체가 비용이 된다고 언급', 'SUPPLEMENTARY', 7),

-- 질문 542
(2908, 542, '표현 로직이 MVC에서는 ViewController에, MVVM에서는 ViewModel에 위치하는 차이를 설명', 'ESSENTIAL', 1),
(2909, 542, 'MVVM의 ViewModel은 UIKit을 import하지 않는다는 점을 언급', 'ESSENTIAL', 2),
(2910, 542, 'MVVM의 View는 ViewModel의 상태를 바인딩으로 관찰해 그리기만 한다고 설명', 'ESSENTIAL', 3),
(2911, 542, 'MVC와 MVVM의 보일러플레이트 양 차이를 설명', 'SUPPLEMENTARY', 4),
(2912, 542, 'MVVM에서는 단위 테스트 범위가 ViewModel·Service까지 넓어진다고 언급', 'SUPPLEMENTARY', 5),
(2913, 542, '클로저·Combine·Observation 같은 바인딩 방식은 MVVM의 본질이 아님을 언급', 'SUPPLEMENTARY', 6),

-- 질문 543
(2914, 543, '생성자 주입은 의존성 누락 시 컴파일 오류가 난다는 장점을 설명', 'ESSENTIAL', 1),
(2915, 543, '프로퍼티 주입은 주입 전에 접근하면 크래시가 날 수 있다는 단점을 언급', 'ESSENTIAL', 2),
(2916, 543, '프로퍼티 주입이 스토리보드·시스템 생성 객체에 적용 가능하다는 점을 언급', 'ESSENTIAL', 3),
(2917, 543, '생성자 주입을 기본 방식으로 쓴다고 서술', 'SUPPLEMENTARY', 4),
(2918, 543, '프로퍼티 주입은 선택적 의존에만 쓴다고 언급', 'SUPPLEMENTARY', 5),
(2919, 543, '생성자 주입은 생성 지점의 인자가 늘어난다는 단점을 언급', 'SUPPLEMENTARY', 6),

-- 질문 544
(2920, 544, '네트워크·파싱·포맷팅 같은 로직이 뷰 컨트롤러 하나에 몰려 비대해진 상태라고 설명', 'ESSENTIAL', 1),
(2921, 544, 'UIViewController가 뷰 생명주기·입력·데이터 로드·화면 전환 중 최소 2개를 받는다는 점을 원인으로 제시', 'ESSENTIAL', 2),
(2922, 544, 'UIKit MVC에서 View와 Controller의 경계가 사실상 없어짐을 언급', 'ESSENTIAL', 3),
(2923, 544, '비대한 뷰 컨트롤러는 단위 테스트가 불가능함을 언급', 'SUPPLEMENTARY', 4),
(2924, 544, 'Apple의 MVC에서는 Controller가 View와 Model 사이를 중재한다고 언급', 'SUPPLEMENTARY', 5),
(2925, 544, '한 화면을 고치면 다른 기능이 깨지는 회귀가 잦아진다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 545
(2926, 545, 'Coordinator가 어떤 화면 다음에 어떤 화면이 오는지 내비게이션 흐름을 전담한다고 설명', 'ESSENTIAL', 1),
(2927, 545, '화면은 이동 의도만 알리고 실제 push·present는 Coordinator가 수행한다고 설명', 'ESSENTIAL', 2),
(2928, 545, '화면 재사용·흐름 변경 중 최소 1개를 Coordinator의 이점으로 제시', 'ESSENTIAL', 3),
(2929, 545, '푸시 알림·Universal Link 진입 시 Coordinator에 목적 화면 이동을 요청하면 된다고 언급', 'SUPPLEMENTARY', 4),
(2930, 545, '자식 Coordinator를 childCoordinators에 보관·제거하지 않으면 누수나 조기 해제가 생김을 언급', 'SUPPLEMENTARY', 5);
