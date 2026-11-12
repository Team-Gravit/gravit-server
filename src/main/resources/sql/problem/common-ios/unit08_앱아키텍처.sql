-- Unit: 앱 아키텍처 (Unit ID: 109)
-- Chapter: iOS (Chapter ID: 9)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (535, 109, 'MVC·MVVM 비교와 코디네이터 도입'),
       (693, 109, '의존성 컨테이너와 생성자 주입'),
       (851, 109, '자식 코디네이터 해제와 서비스 로케이터');

-- =====================================================
-- Lesson 535: MVC·MVVM 비교와 코디네이터 도입
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3389, 535, '아래 뷰 컨트롤러 코드에 대한 설명으로 옳은 것은?', '주문 목록 화면의 전체 코드다.

```swift
final class OrderListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var orders: [Order] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        URLSession.shared.dataTask(with: URL(string: "https://api.example.com/orders")!) { data, _, _ in
            guard let data, let list = try? JSONDecoder().decode([Order].self, from: data) else { return }
            self.orders = list.filter { $0.status != .cancelled }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }.resume()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = OrderDetailViewController(order: orders[indexPath.row])
        navigationController?.pushViewController(detail, animated: true)
    }
}
```', 'OBJECTIVE'),
       (3390, 535, '아래 아키텍처에 대한 설명으로 옳은 것은?', '화면에 보여 줄 상태(목록·로딩 여부·오류 문구)와 사용자 액션 처리는 별도 객체가 맡는다. 이 객체는 UIKit을 import하지 않는 순수 Swift 객체이고, 뷰 컨트롤러는 그 객체의 상태를 관찰해 화면을 그리고 입력을 전달하는 일만 한다.', 'OBJECTIVE'),
       (3391, 535, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 항목 | MVC | MVVM | MVVM-C |
|---|---|---|---|
| 표현 로직 위치 | 뷰 컨트롤러 | 뷰모델(UIKit 비의존) | 뷰모델 |
| 화면 전환 위치 | 뷰 컨트롤러 | 뷰 컨트롤러 | 별도 흐름 담당 객체 |
| 단위 테스트 범위 | 거의 불가 | 뷰모델·서비스 | 뷰모델·서비스·화면 흐름 |
| 보일러플레이트 | 최소 | 중간(바인딩 코드) | 많음(흐름 계층 추가) |
| 적합한 규모 | 프로토타입·화면 수가 적은 앱 | 대부분의 상용 앱 | 딥링크·A/B 테스트가 많은 앱 |', 'OBJECTIVE'),
       (3392, 535, '아래처럼 협력자를 넘기는 방식에 대한 설명으로 옳은 것은?', '스토리보드가 인스턴스를 대신 만들어 주는 화면이라 초기화 시점에 협력자를 건넬 수 없었다. 그래서 아래처럼 선언하고, 화면을 띄우는 쪽에서 값을 채워 넣기로 했다.

```swift
protocol OrderService {
    func fetchOrders() async throws -> [Order]
}

final class OrderDetailViewController: UIViewController {
    var service: OrderService!

    override func viewDidLoad() {
        super.viewDidLoad()
        Task { await load() }
    }
}
```', 'OBJECTIVE'),
       (3393, 535, '아래 상황을 해결하려고 새로 도입한 객체의 이름은?', '주문 목록에서 상세로, 상세에서 환불로 넘어가는 흐름을 각 화면이 직접 다음 화면을 만들어 push하도록 짰다. A/B 테스트로 상세를 건너뛰고 목록에서 곧바로 환불로 보내려 하자 목록 화면 코드를 고쳐야 했고, 푸시 알림으로 환불 화면에 바로 진입시키는 경로를 넣자 화면마다 진입 분기가 늘었다. 구조를 바꾼 뒤로 각 화면은 다음 화면의 존재를 몰라도 됐지만, 부모가 자식 객체를 배열에 담아 붙잡았다가 흐름이 끝나면 지워 주어야 했고 이를 빠뜨리자 메모리 누수가 생겼다.', 'SUBJECTIVE'),
       (3394, 535, '아래 상황에서 테스트를 불안정하게 만든 참조를 걷어내려고 적용한 기법의 이름은?', '결제 화면의 단위 테스트가 실행할 때마다 실제 서버로 요청을 보내, 네트워크 상태에 따라 같은 테스트가 성공하기도 실패하기도 했다. 화면과 뷰모델 곳곳에서 PaymentService.shared를 그대로 불러 쓰고 있었던 탓이다. 구조를 고친 뒤로는 같은 테스트가 서버 없이 3ms 만에 끝났고, 실행 순서와 상관없이 매번 같은 결과가 나왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3389
(9211, 3389, 'dataTask 클로저가 self를 강하게 캡처하므로 이 화면은 순환 참조가 생겨 해제되지 않는다.', '클로저를 붙잡고 있는 것은 URLSession의 태스크이고 화면은 그 태스크를 보관하지 않는다. 응답이 오면 클로저가 풀려 캡처도 끝나므로 순환 참조가 아니다. 강한 캡처를 곧 누수로 보는 오개념이다.', false),
(9212, 3389, 'Apple의 MVC는 모델이 뷰를 직접 갱신하는 구조라, 갱신을 컨트롤러가 중계하는 이 코드는 규칙에 어긋난다.', 'Apple의 MVC는 모델과 뷰가 직접 통신하지 않고 컨트롤러가 중재하는 것이 원칙이라 중재 자체는 규칙에 맞다. 이 코드의 문제는 그 중재자에게 네트워크·파싱·필터링·화면 전환까지 몰린 데 있다.', false),
(9213, 3389, '취소된 주문을 걸러내는 규칙이 네트워크 콜백 안에 있어, 서버 응답 없이는 그 규칙만 따로 검증할 수 없다.', 'filter 조건이 dataTask 콜백 안에 갇혀 있어 실행하려면 실제 응답이 필요하다. 표현 로직을 네트워크·UIKit과 떼어 놓아야 단위 테스트가 가능해진다는 점이 뷰 컨트롤러 비대화의 실제 비용이다.', true),
(9214, 3389, '목록 화면이 상세 화면 타입을 직접 만들지 않으므로, 상세 화면을 교체해도 이 파일은 손대지 않아도 된다.', 'didSelectRowAt에서 OrderDetailViewController를 직접 생성해 push한다. 목록이 상세의 존재와 초기화 방법까지 알고 있어, 상세를 교체하면 이 파일도 함께 고쳐야 한다.', false),

-- 문제 3390
(9215, 3390, '상태를 관찰하는 수단으로 Combine의 @Published를 쓰지 않으면 이 구조라고 볼 수 없다.', '바인딩은 클로저, Combine, Observation 등 무엇으로도 구현할 수 있다. 특정 프레임워크를 썼는지가 아니라 표현 로직을 UIKit 바깥으로 분리했는지가 판단 기준이다.', false),
(9216, 3390, '화면 전환을 누가 소유할지는 정해 주지 않아, 전환 코드가 뷰 컨트롤러나 표현 객체 어느 쪽으로도 흘러갈 수 있다.', '이 구조는 표현 로직의 자리만 정하고 내비게이션 책임은 비워 둔다. 표현 객체가 navigationController를 참조하는 순간 UIKit 의존이 되살아나며, 이것이 흐름 전담 객체를 따로 두는 방식이 나온 배경이다.', true),
(9217, 3390, '이미지·색상 객체까지 표현 객체가 만들어 넘겨야 뷰 컨트롤러의 코드가 짧아진다.', 'UIImage·UIColor를 표현 객체가 만들면 UIKit 의존이 생겨 단위 테스트가 다시 어려워진다. 이미지 이름·색상 토큰 같은 값만 넘기고 실제 변환은 뷰 쪽이 맡아야 한다.', false),
(9218, 3390, '뷰 컨트롤러에 있던 코드를 그대로 옮기기만 해도 계층별 코드량이 알아서 균형을 잡는다.', '자리만 옮기면 비대한 표현 객체가 될 뿐 문제는 위치만 바뀐다. 네트워크·저장은 서비스 계층으로, 화면 전환은 흐름 담당 객체로 한 번 더 나눠야 각 조각이 작아진다.', false),

-- 문제 3391
(9219, 3391, 'MVC에서 MVVM으로 옮기면 표현 로직이 이동한 만큼 단위 테스트로 검증할 수 있는 범위가 넓어진다.', '표의 단위 테스트 범위가 거의 불가에서 뷰모델·서비스로 넓어진다. 표현 로직이 UIKit에 의존하지 않는 객체로 빠져나온 것이 그 이유이므로 참인 진술이다.', false),
(9220, 3391, 'MVVM에서 MVVM-C로 옮길 때 표현 로직의 위치는 그대로 두고 화면 전환 담당만 바뀐다.', '표에서 표현 로직 위치는 두 열 모두 뷰모델이고, 화면 전환 위치만 뷰 컨트롤러에서 별도 흐름 담당 객체로 바뀐다. 표와 어긋나는 곳이 없어 참이다.', false),
(9221, 3391, '화면 수가 적고 수명이 짧은 프로토타입이라면 바인딩 코드가 없는 MVC로 시작해도 된다.', '표의 보일러플레이트 최소, 적합한 규모 프로토타입 항목과 그대로 맞는다. 아키텍처는 화면 수·흐름 복잡도·테스트 요구에 맞춰 고르는 것이므로 참이다.', false),
(9222, 3391, 'MVVM-C는 화면 흐름까지 테스트 범위에 들어오는 대신, 작성할 코드량은 셋 중 가장 적다.', '앞부분은 표와 맞지만 뒷부분이 거짓이라 이 선지를 골라야 한다. 표의 보일러플레이트는 MVVM-C가 많음, MVC가 최소다. 흐름 계층이 늘어난 만큼 코드량은 오히려 가장 많다.', true),

-- 문제 3392
(9223, 3392, '값을 채우기 전에 화면이 협력자를 건드리면 컴파일은 통과하지만 실행 중에 크래시한다.', '암시적 추출 옵셔널이라 nil 상태의 접근이 컴파일 시점에 막히지 않는다. 화면을 띄우는 쪽이 주입을 빠뜨리면 viewDidLoad에서 곧바로 터진다. 프로퍼티 주입이 치르는 대표적 비용이다.', true),
(9224, 3392, '주입을 빠뜨린 채로 화면을 띄우면 컴파일 단계에서 오류로 걸러진다.', '누락이 컴파일 오류로 잡히는 쪽은 협력자를 init 인자로 받는 생성자 주입이다. 프로퍼티로 받으면 컴파일러가 주입 여부를 확인할 방법이 없어 실행해 봐야 안다.', false),
(9225, 3392, '한 번 채운 협력자는 불변이 되어 화면이 살아 있는 동안 다른 구현으로 바꿀 수 없다.', 'var 프로퍼티라 언제든 다시 대입할 수 있다. 불변으로 고정되는 쪽은 생성자에서 받아 상수에 담는 생성자 주입이며, 그 특성을 잘못 옮겨 붙인 것이다.', false),
(9226, 3392, '테스트에서 가짜 구현을 끼워 넣으려면 이 선언을 구체 타입으로 바꿔야 한다.', '반대다. OrderService라는 프로토콜 타입으로 선언했기 때문에 스텁을 대입할 수 있다. 구체 타입으로 바꾸면 교체 지점이 사라져 테스트에서 갈아 끼울 수 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1086, 3393, '코디네이터,coordinator,코디네이터 패턴,coordinator 패턴,coordinator pattern', '화면 전환 소유권을 화면 밖으로 옮겨 어떤 화면 다음에 어떤 화면이 오는지를 전담하는 객체가 코디네이터다. 각 화면은 다음으로 가고 싶다는 의도만 알리므로 화면 재사용이 쉬워지고, 딥링크·푸시 알림으로 특정 화면에 바로 들어가는 처리도 한곳으로 모인다. 부모가 childCoordinators 배열로 자식을 붙잡지 않으면 흐름 도중에 조기 해제되고, 흐름이 끝난 뒤 지우지 않으면 누수가 남는다. 상태와 액션 처리를 맡는 뷰모델, 실제 화면 스택을 조작하는 도구인 UINavigationController와는 역할이 다르다.'),
       (1087, 3394, '의존성 주입,의존성주입,dependency injection,DI,디펜던시 인젝션', '협력자를 객체가 스스로 만들거나 싱글턴으로 찾지 않고 바깥에서 건네받게 하는 기법이 의존성 주입이다. 싱글턴이 있다는 사실보다 코드 곳곳에서 shared를 직접 부르는 것이 문제로, 교체 지점이 사라져 숨은 의존성이 된다. 같은 싱글턴이라도 주입 경로로 전달하면 테스트에서 스텁으로 갈아 끼울 수 있어 결과가 결정적으로 바뀐다. 생성자 주입이 기본이며, 의존 방향 규칙을 말하는 의존성 역전 원칙(DIP)이나 가짜 구현물 자체를 가리키는 스텁·목과는 구분한다.');

-- =====================================================
-- Lesson 693: 의존성 컨테이너와 생성자 주입
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4337, 693, '아래 코드로 앱을 실행했을 때 일어나는 일로 옳은 것은?', 'SceneDelegate는 appCoordinator를 프로퍼티로 보관한 뒤 start()를 호출한다. LoginViewController는 전달받은 뷰모델을 프로퍼티로 보관한다.

```swift
final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let navigation: UINavigationController

    init(navigation: UINavigationController) {
        self.navigation = navigation
    }

    func start() {
        let auth = AuthCoordinator(navigation: navigation)
        auth.start()
    }
}

final class AuthCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let navigation: UINavigationController

    init(navigation: UINavigationController) {
        self.navigation = navigation
    }

    func start() {
        let viewModel = LoginViewModel()
        viewModel.onLoginSucceeded = { [weak self] in
            self?.showHome()
        }
        navigation.pushViewController(LoginViewController(viewModel: viewModel), animated: false)
    }

    private func showHome() {
        navigation.setViewControllers([HomeViewController()], animated: true)
    }
}
```', 'OBJECTIVE'),
       (4338, 693, '아래 리팩터링 기록을 바탕으로 옳은 것은?', '주문 상세 화면을 두 단계로 리팩터링하며 남긴 기록이다.

| 항목 | 시작 | 1단계 | 2단계 |
|---|---|---|---|
| 뷰 컨트롤러 줄 수 | 1,400 | 230 | 190 |
| 뷰모델 줄 수 | 없음 | 1,160 | 320 |
| 뷰모델이 import하는 모듈 | 없음 | Foundation, UIKit | Foundation |
| 네트워크·저장 코드 위치 | 뷰 컨트롤러 | 뷰모델 | OrderRepository |
| 화면 전환 코드 위치 | 뷰 컨트롤러 | 뷰모델 | OrderCoordinator |', 'OBJECTIVE'),
       (4339, 693, '아래 뷰모델이 협력자를 얻는 방식에 대한 설명으로 옳은 것은?', '앱이 시작될 때 한 곳에서 DependencyContainer를 만들어 각 화면의 뷰모델에 넘긴다. OrderService·CouponService·AnalyticsTracker·DateProvider는 모두 프로토콜이다.

```swift
final class DependencyContainer {
    let orderService: OrderService
    let couponService: CouponService
    let analytics: AnalyticsTracker
    let dateProvider: DateProvider
    // 그 밖의 서비스 16개

    init(orderService: OrderService, couponService: CouponService,
         analytics: AnalyticsTracker, dateProvider: DateProvider /* , 그 밖의 16개 */) { ... }
}

final class CheckoutViewModel {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func applyCoupon(code: String) async {
        guard let coupon = try? await container.couponService.find(code: code) else { return }
        if coupon.expiresAt > container.dateProvider.now {
            container.analytics.track("coupon_applied")
        }
    }
}
```', 'OBJECTIVE'),
       (4340, 693, '아래 아키텍처에 대한 설명으로 옳은 것은?', '모델과 뷰는 서로를 직접 참조하지 않는다. 사용자 입력은 가운데 객체가 받아 모델에 반영하고, 모델이 바뀌었다는 사실도 가운데 객체가 전달받아 뷰에 반영한다. UIKit 앱에서는 UIViewController가 이 가운데 객체 역할을 맡는다.', 'OBJECTIVE'),
       (4341, 693, '아래 상황에서 뷰모델 클래스 선언 바로 위에 추가한 한 줄은?', '주문 목록 뷰모델과 뷰 컨트롤러를 아래처럼 연결했다.

```swift
final class OrderListViewModel {
    @Published private(set) var rows: [OrderRow] = []
    private let service: OrderService

    init(service: OrderService) {
        self.service = service
    }

    func load() async {
        let orders = (try? await service.fetchOrders()) ?? []
        rows = orders.map { OrderRow(id: $0.id, title: $0.productName) }
    }
}

// OrderListViewController.viewDidLoad()
viewModel.$rows
    .sink { [weak self] _ in self?.tableView.reloadData() }
    .store(in: &cancellables)
Task { await viewModel.load() }
```

실행하자 Xcode에 아래 보라색 경고가 뜨고, 목록이 늦게 그려지거나 가끔 크래시가 났다.

```
Main Thread Checker: UI API called on a background thread: -[UITableView reloadData]
```

뷰 컨트롤러 코드와 load() 본문은 그대로 두고 뷰모델 클래스 선언 바로 위에 한 줄만 추가하자 경고가 사라졌다. 대신 테스트 코드에서 이 뷰모델을 만드는 줄에 컴파일 오류가 새로 났고, 테스트 클래스 선언 위에도 같은 한 줄을 붙이자 해결됐다.', 'SUBJECTIVE'),
       (4342, 693, '아래 상황에서 바꾼 뒤의 방식을 이전 방식과 구별해 부르는 이름은?', '환불 화면 뷰모델은 협력자인 RefundService를 바깥에서 건네받는다. 처음에는 뷰모델을 만든 뒤 한 줄로 대입하도록 짰는데, 테스트 하나에서 그 대입을 빠뜨리자 실행 도중 아래 오류로 크래시가 났다.

```
Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value
```

건네받는 방식을 바꾼 뒤로는 같은 실수를 하면 뷰모델을 만드는 줄에서 아래 오류가 떠 빌드부터 되지 않았다. 뷰모델 안의 RefundService 선언도 var에서 let으로 바꿀 수 있었다.

```
error: Missing argument for parameter ''service'' in call
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4337
(11739, 4337, 'AppCoordinator가 자식을 붙잡은 채 지우지 않아, 로그인이 끝난 뒤에도 AuthCoordinator가 메모리에 남는다.', '자식을 배열에 담아 두고 흐름이 끝나도 지우지 않을 때 생기는 누수와 혼동했다. 이 코드는 auth를 start() 안의 지역 상수로만 두고 childCoordinators에 넣지 않아, 붙잡는 쪽이 없으니 오히려 곧바로 해제된다.', false),
(11740, 4337, 'AuthCoordinator가 해제되면서 push했던 로그인 화면도 함께 사라져, 빈 화면만 보인다.', '코디네이터가 화면을 소유한다고 본 오개념이다. push된 LoginViewController는 UINavigationController의 스택이 강하게 보관하므로, 코디네이터가 해제돼도 로그인 화면은 그대로 떠 있다.', false),
(11741, 4337, '로그인 화면은 정상적으로 뜨지만, 로그인에 성공해도 홈 화면으로 넘어가지 않는다.', 'auth는 어디에도 보관되지 않아 AppCoordinator의 start()가 끝나면 해제된다. 화면은 내비게이션 스택이 붙잡아 남지만 [weak self]로 캡처한 코디네이터는 이미 nil이라 showHome()이 불리지 않는다. 부모가 childCoordinators에 담아 둬야 하는 이유다.', true),
(11742, 4337, '뷰모델의 클로저가 AuthCoordinator를 붙잡고 있어, 로그인에 성공하면 홈 화면으로 정상 이동한다.', '클로저 캡처가 코디네이터를 살려 둔다고 본 오개념이다. [weak self]는 참조 카운트를 올리지 않아 코디네이터를 붙잡지 못한다. 보관하는 쪽이 없는 auth는 start()가 끝나자마자 해제되고 self는 nil이 된다.', false),

-- 문제 4338
(11743, 4338, '1단계에서 뷰 컨트롤러가 1,400줄에서 230줄로 줄었으므로, 이 화면의 코드 비대화는 1단계에서 해결됐다.', '뷰 컨트롤러 줄 수만 보고 판단한 오개념이다. 같은 1단계에서 뷰모델이 1,160줄로 늘어 코드가 자리만 옮겼을 뿐이다. 네트워크·저장 코드와 화면 전환 코드를 떼어 낸 2단계에서야 뷰모델이 320줄로 줄었다.', false),
(11744, 4338, '2단계 뷰모델도 Foundation을 import하므로, 여전히 시뮬레이터에 화면을 띄워야만 단위 테스트할 수 있다.', 'Foundation을 UI 프레임워크로 착각한 오개념이다. Foundation은 날짜·URL·JSON 처리 같은 기본 기능을 담은 모듈이라 화면과 무관하다. 테스트를 막는 것은 UIKit 의존이며, 2단계 뷰모델은 이를 벗어나 순수 Swift 객체로 검증할 수 있다.', false),
(11745, 4338, '2단계에서 네트워크·저장 코드를 옮겼으니, 로딩 여부나 오류 문구 같은 화면 상태도 OrderRepository로 옮겨야 한다.', '데이터 계층과 표현 계층의 역할을 섞은 오개념이다. 저장소는 데이터를 가져오고 저장하는 일만 맡고, 화면에 보여 줄 로딩 여부·오류 문구는 뷰모델이 들고 있어야 뷰가 관찰할 상태가 한곳에 모인다.', false),
(11746, 4338, '1단계 뷰모델은 전환 코드가 navigationController를 참조하므로, 이 코드를 옮기기 전에는 UIKit import를 뺄 수 없다.', '표에서 1단계 뷰모델은 화면 전환 코드를 품고 있다. push하려면 UINavigationController를 참조해야 해 UIKit 의존이 생긴다. 네트워크 코드는 Foundation만으로 충분하므로, 전환을 OrderCoordinator로 넘긴 2단계에서 UIKit이 빠진 것이다.', true),

-- 문제 4339
(11747, 4339, '컨테이너의 프로퍼티가 모두 let이라, 테스트에서 이 뷰모델에 스텁을 넣을 방법이 없다.', 'let을 교체 불가로 오해했다. let은 만든 뒤 다시 대입할 수 없다는 뜻일 뿐이다. 컨테이너의 init이 프로토콜 타입을 받으므로, 테스트용 컨테이너를 만들 때 스텁을 넘기면 된다.', false),
(11748, 4339, '테스트에 어떤 스텁이 필요한지 init 선언만 봐서는 알 수 없고, 메서드 본문을 읽어야 드러난다.', 'init은 컨테이너 하나만 받으므로 실제로 쓰는 couponService·dateProvider·analytics는 본문의 container 접근을 따라가야 보인다. 컨테이너를 서비스 로케이터처럼 넘길 때 생기는 숨은 의존성이며, 필요한 협력자만 init으로 받으면 선언부에 드러난다.', true),
(11749, 4339, '컨테이너 없이 CouponService 스텁 하나만 넘겨도 이 뷰모델의 단위 테스트를 만들 수 있다.', '쓰는 서비스만 넘기면 된다고 본 오개념이다. 이 뷰모델의 init은 DependencyContainer만 받으므로, 쿠폰 적용 하나를 검증하려 해도 서비스 20개를 모두 채운 컨테이너를 만들어야 한다. 컨테이너를 통째로 넘기는 설계의 비용이다.', false),
(11750, 4339, 'dateProvider는 현재 시각만 알려 주는 단순한 값이라, 실제 구현을 그대로 써도 만료 판정 테스트가 흔들리지 않는다.', '시간을 순수 계산으로 본 오개념이다. 현재 시각은 실행할 때마다 바뀌는 외부 세계의 값이라, 실제 구현을 쓰면 만료일 근처에서 같은 테스트의 결과가 날짜에 따라 달라진다. 네트워크·저장소처럼 추상화해 고정값을 주입할 대상이다.', false),

-- 문제 4340
(11751, 4340, '가운데 객체가 뷰의 생명주기 콜백까지 받으므로, 네트워크·포맷팅처럼 갈 곳 없는 코드가 이 클래스로 몰리기 쉽다.', 'UIViewController는 중재자이면서 뷰의 생명주기도 소유해 뷰와 중재자의 경계가 사실상 없다. 따로 둘 계층이 없는 네트워크·파싱·포맷팅·화면 전환 코드가 모두 여기로 쌓여 비대한 뷰 컨트롤러가 되기 쉽다.', true),
(11752, 4340, '모델이 바뀌면 뷰가 모델을 직접 관찰해 다시 그리므로, 가운데 객체는 사용자 입력 전달만 맡는다.', '뷰가 모델을 직접 관찰하는 원래의 MVC 설명이나 바인딩 구조와 혼동했다. 본문 구조에서 모델과 뷰는 서로를 모르므로, 모델 변경을 받아 뷰를 갱신하는 일까지 가운데 객체가 맡는다.', false),
(11753, 4340, '화면 전환은 모델 계층이 맡도록 나뉘어 있어, 목록 화면은 다음에 올 상세 화면의 존재를 몰라도 된다.', '화면 전환 책임이 따로 정해져 있다고 본 오개념이다. 이 구조에는 전환 전담 계층이 없어 보통 뷰 컨트롤러가 다음 화면을 직접 만들어 push한다. 그래서 목록 화면이 상세 화면 타입을 알게 되고, 이를 떼어 내려고 코디네이터를 둔다.', false),
(11754, 4340, '가운데 객체는 뷰를 직접 그리지 않으므로, 이 객체에 둔 표현 로직은 UIKit 없이 단위 테스트할 수 있다.', '중재자를 순수 객체로 본 오개념이다. UIKit 앱에서 가운데 객체는 UIViewController 자신이라 UIKit 없이는 인스턴스를 만들 수 없다. 그 안에 둔 필터·포맷팅 로직도 함께 묶여 따로 떼어 검증하기 어렵다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1402, 4341, '@MainActor,MainActor,@MainActor 속성,메인 액터,메인액터,main actor', '@MainActor는 뷰모델을 메인 액터에 격리한다. 이 표시가 없으면 load() 같은 비격리 async 메서드는 메인 스레드가 아닌 실행기에서 돌 수 있어, @Published인 rows가 백그라운드에서 바뀌고 그 값을 받은 sink 안의 reloadData()도 같은 스레드에서 불린다. 선언 위에 @MainActor를 붙이면 await로 기다린 뒤에도 메인 액터로 돌아와 rows를 갱신하므로 뷰 컨트롤러는 고칠 필요가 없다. 대신 격리 밖에서 뷰모델을 만들거나 부르는 코드(테스트 클래스 등)는 격리를 맞추거나 await를 붙여야 한다. 구독 쪽에서 receive(on: DispatchQueue.main)으로 전달 스레드만 바꾸는 방법과는 고치는 위치가 다르며, 스레드와 무관한 [weak self]·@Published와도 구분해야 한다.'),
       (1403, 4342, '생성자 주입,생성자주입,이니셜라이저 주입,이니셜라이저주입,초기화 주입,init 주입,initializer injection,constructor injection', '협력자를 init의 인자로 받는 생성자 주입이다. 인자를 빠뜨리면 인스턴스를 만드는 줄에서 컴파일 오류가 나므로, 누락이 실행 중 크래시로 드러나는 프로퍼티 주입(var service: RefundService!)보다 일찍 잡힌다. 생성 시점에 한 번 받으니 let으로 두어 불변으로 만들 수 있고, 의존성이 선언부에 드러나 기본 방식으로 권장된다. 대신 생성 지점의 인자가 늘어난다. 스토리보드처럼 시스템이 인스턴스를 만들어 init에 끼어들 수 없는 경우에만 프로퍼티 주입을 쓰며, 바깥에서 받는다는 원리 자체를 가리키는 의존성 주입(DI)과는 층위가 다르다.');

-- =====================================================
-- Lesson 851: 자식 코디네이터 해제와 서비스 로케이터
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5285, 851, '아래 뷰모델 코드에 대한 설명으로 옳은 것은?', '주문 배지의 색과 아이콘을 잔여 수량으로 정하는 뷰모델이다. 화면은 badgeColor·badgeIcon을 받아 그대로 그리기만 한다.

```swift
import UIKit
import Combine

final class BadgeViewModel {
    @Published private(set) var badgeColor: UIColor = .clear
    @Published private(set) var badgeIcon: UIImage?

    func update(remaining: Int) {
        badgeColor = remaining == 0 ? .systemGray : .systemRed
        badgeIcon = UIImage(named: remaining == 0 ? "sold_out" : "hot")
    }
}
```', 'OBJECTIVE'),
       (5286, 851, '아래 측정 기록에 대한 설명으로 옳은 것은?', '로그인 → 홈 → 로그아웃을 10번 반복하며 Xcode 메모리 그래프로 살아 있는 인스턴스 수를 셌다. AppCoordinator는 AuthCoordinator를 만들 때 childCoordinators 배열에 담고, 흐름이 끝나도 배열에서 빼지 않는다. AuthCoordinator는 자신이 띄운 LoginViewController를 프로퍼티로 보관한다. 로그아웃 시 내비게이션 스택은 setViewControllers로 통째로 갈아 끼운다.

| 반복 횟수 | AuthCoordinator | LoginViewController | HomeViewController |
|---|---|---|---|
| 1회 | 1 | 1 | 1 |
| 5회 | 5 | 5 | 1 |
| 10회 | 10 | 10 | 1 |', 'OBJECTIVE'),
       (5287, 851, '아래 코드로 목록 화면을 띄웠을 때 일어나는 일로 옳은 것은?', 'fetchOrders()는 서버 응답을 기다린 뒤 주문 3건을 돌려준다. 이 뷰 컨트롤러가 tableView의 데이터 소스다.

```swift
@MainActor
final class OrderListViewModel {
    private(set) var rows: [OrderRow] = []
    private let service: OrderService

    init(service: OrderService) { self.service = service }

    func load() async {
        let orders = (try? await service.fetchOrders()) ?? []
        rows = orders.map { OrderRow(id: $0.id, title: $0.productName) }
    }
}

final class OrderListViewController: UIViewController {
    private let viewModel: OrderListViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        Task { await viewModel.load() }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rows.count
    }
}
```', 'OBJECTIVE'),
       (5288, 851, '아래 테스트 코드에 대한 설명으로 옳은 것은?', 'OrderListViewModel은 init(service: OrderService)로 협력자를 받는다. OrderService는 fetchOrders() 하나만 가진 프로토콜이고, 실제 구현 OrderAPIClient는 서버로 요청을 보낸다.

```swift
struct StubOrderService: OrderService {
    var result: Result<[Order], Error>
    func fetchOrders() async throws -> [Order] { try result.get() }
}

@MainActor
final class OrderListViewModelTests: XCTestCase {
    func test_불러오기_실패시_오류_문구를_노출한다() async {
        let sut = OrderListViewModel(service: StubOrderService(result: .failure(URLError(.timedOut))))

        await sut.load()

        XCTAssertEqual(sut.errorMessage, "주문을 불러오지 못했습니다.")
        XCTAssertTrue(sut.rows.isEmpty)
    }
}
```', 'OBJECTIVE'),
       (5289, 851, '아래 코드가 협력자를 얻는 방식을 부르는 이름은?', '환불 화면의 뷰모델이다. AppContainer는 앱에 하나뿐인 인스턴스다.

```swift
final class RefundViewModel {
    private let service = AppContainer.shared.resolve(RefundService.self)
    private let analytics = AppContainer.shared.resolve(AnalyticsTracker.self)

    func submit(orderID: Order.ID) async { ... }
}
```

테스트에서 이 뷰모델을 만들기 전에 가짜 구현을 등록하는 줄을 빠뜨리자 실제 서버로 요청이 나갔다. 테스트 실행 순서를 바꾸자 같은 테스트가 통과했다 실패했다 했고, 앞선 테스트가 등록해 둔 구현이 그대로 남아 있던 탓이었다. 뷰모델을 만드는 줄에는 인자가 하나도 없어 무엇이 필요한지 호출부에서는 보이지 않았다.', 'SUBJECTIVE'),
       (5290, 851, '아래 상황에서 뷰모델 클래스 선언에 채택한 프로토콜의 이름은?', '검색 화면을 SwiftUI로 옮기면서 뷰모델을 아래처럼 두고 화면에서 @StateObject로 받으려 하자 빌드가 막혔다.

```swift
final class SearchViewModel {
    @Published private(set) var results: [Item] = []
    private let service: SearchService

    init(service: SearchService) { self.service = service }

    func search(_ keyword: String) async { ... }
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel(service: RemoteSearchService())

    var body: some View {
        List(viewModel.results) { Text($0.title) }
            .task { await viewModel.search("가방") }
    }
}
```

클래스 선언 뒤에 프로토콜 하나를 붙이자 빌드가 통과했다. 그 뒤로는 results가 바뀔 때마다 body가 다시 평가돼 목록이 저절로 갱신됐고, UIKit 화면에서 쓰던 수동 구독 코드는 한 줄도 남지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5285
(14267, 5285, '업데이트가 화면을 직접 그리지 않고 프로퍼티 값만 바꾸므로, 표현 로직은 이미 화면과 분리돼 있다.', '그리기 호출이 없다고 분리된 것은 아니다. 내보내는 상태의 타입이 UIColor·UIImage라 이 객체는 UIKit을 함께 끌고 다니며, 화면 프레임워크를 바꾸면 잔여 수량 판정 규칙까지 따라 고쳐야 한다.', false),
(14268, 5285, '@Published로 상태 변화를 내보내고 있어, UIKit이 없는 환경에서도 이 뷰모델을 그대로 만들 수 있다.', '바인딩 수단과 의존 관계를 섞은 오개념이다. @Published는 값이 바뀌었음을 알리는 장치일 뿐이고, 프로퍼티 타입이 UIColor·UIImage인 이상 UIKit을 불러오지 않으면 컴파일조차 되지 않는다.', false),
(14269, 5285, 'UIImage(named:)는 번들에서 자원을 찾으므로, 그 자원을 담지 않은 테스트 타깃에서는 판정이 맞아도 badgeIcon이 nil로 나온다.', '뷰모델이 이미지 객체까지 만들면 검증 결과가 자원 준비 여부에 묶인다. 이름 문자열·색상 토큰 같은 값만 내보내고 실제 변환은 화면이 맡으면, 잔여 수량에 따른 규칙만 떼어 단언할 수 있다.', true),
(14270, 5285, '색을 UIColor 대신 문자열 토큰으로 내보내면 화면 쪽에서 색을 만들 수 없어 배지를 그리지 못한다.', '값만 넘기는 방식을 오해했다. 토큰 문자열을 실제 색으로 바꾸는 표를 화면 쪽에 두면 그대로 그릴 수 있다. 변환 지점을 화면으로 옮기는 것이 뷰모델을 UIKit에서 떼어 내는 일반적인 방법이다.', false),

-- 문제 5286
(14271, 5286, '로그아웃으로 화면 스택에서 내려간 로그인 화면까지 수가 함께 늘었으므로, 그 화면을 붙잡고 있는 쪽은 내비게이션 스택이 아니라 코디네이터다.', 'setViewControllers로 스택을 갈아 끼웠는데도 로그인 화면이 남았다면 스택 밖에 참조가 있다는 뜻이다. 코디네이터가 화면을 프로퍼티로 들고 있고 그 코디네이터를 부모 배열이 붙잡아, 참조 사슬이 한 줄로 이어져 함께 쌓인다.', true),
(14272, 5286, 'HomeViewController가 1로 유지되니 화면은 새지 않고 코디네이터 객체만 남는 것이라, 늘어난 만큼의 메모리 영향은 무시해도 된다.', '마지막 열만 보고 판단한 오개념이다. 같은 기록에서 LoginViewController도 10개까지 늘어 화면과 그 뷰 계층까지 남는다. 홈 화면 수가 1인 것은 setViewControllers가 이전 스택을 걷어낸 결과일 뿐이다.', false),
(14273, 5286, '자식을 만들 때 클로저에서 [weak self]로 캡처하면 배열에서 빼지 않아도 반복할 때마다 쌓이지 않는다.', '약한 캡처를 만능 해제 장치로 본 오개념이다. [weak self]는 클로저가 거는 참조만 약하게 만들 뿐, 부모가 childCoordinators 배열에 담아 둔 강한 참조는 그대로다. 흐름이 끝나면 배열에서 직접 빼야 한다.', false),
(14274, 5286, 'ARC가 참조 카운트로 수명을 관리하므로 흐름이 끝난 자식은 곧 해제되고, 기록의 증가는 메모리 그래프가 갱신되기 전의 값이다.', 'ARC는 참조가 남아 있으면 해제하지 않는다. 부모 배열이 자식을 계속 가리키는 한 카운트가 0이 되지 않아 반복 횟수만큼 그대로 쌓인다. 측정 도구의 표시 지연이 아니라 설계가 만든 누수다.', false),

-- 문제 5287
(14275, 5287, 'Task 블록이 끝날 때까지 viewDidLoad가 멈춰 기다리므로, 첫 그리기부터 주문 3건이 모두 보인다.', 'Task는 비동기 작업을 떼어 맡기고 곧바로 다음 줄로 넘어간다. viewDidLoad는 await를 쓸 수 없어 기다릴 수도 없다. 이 블록이 동기적으로 실행된다고 보는 것은 흔한 오개념이다.', false),
(14276, 5287, 'rows가 private(set)이라 뷰 컨트롤러에서 값을 읽을 수 없어 numberOfRowsInSection에서 컴파일 오류가 난다.', 'private(set)은 쓰기만 타입 안으로 제한하고 읽기는 그대로 열어 둔다. 외부에서 값을 읽는 코드는 정상이며, 상태를 밖에서 함부로 바꾸지 못하게 하려는 흔한 선언이다.', false),
(14277, 5287, 'fetchOrders()가 실패하면 rows가 nil이 되어 목록을 그리는 순간 크래시한다.', 'try?가 실패를 nil로 바꾸지만 뒤의 ?? []가 곧바로 빈 배열로 메운다. rows는 옵셔널이 아니라 항상 배열이므로 실패해도 빈 목록이 될 뿐이다. 실패와 크래시를 붙여 보는 오개념이다.', false),
(14278, 5287, '응답이 오기 전에 reloadData()가 끝나고 rows 변화를 전달받을 통로도 없어, 3건이 채워져도 화면은 빈 목록 그대로다.', 'Task를 띄운 직후 줄이 이어져 첫 그리기는 rows가 빈 상태에서 일어난다. 이 뷰모델은 값이 바뀌었음을 알릴 수단이 없어 뷰 컨트롤러가 다시 그릴 시점을 모른다. 상태를 관찰해 갱신하는 연결이 빠진 것이다.', true),

-- 문제 5288
(14279, 5288, 'URLError를 만들어 넘기므로 이 테스트는 실제 URLSession으로 요청을 한 번 보낸 뒤 시간 초과를 기다린다.', '오류 값을 만드는 일과 통신을 섞은 오개념이다. URLError는 그냥 값이라 만들어도 아무 요청이 나가지 않는다. 뷰모델이 부르는 쪽은 스텁이므로 네트워크 코드는 한 번도 실행되지 않는다.', false),
(14280, 5288, '.failure를 담은 스텁이 매번 같은 오류를 돌려주므로, 서버를 멈추거나 네트워크를 끊지 않아도 실패 경로가 항상 같은 조건으로 재현된다.', '외부 세계와 닿는 협력자를 프로토콜로 받아 두면 테스트에서 결과를 원하는 대로 고정할 수 있다. 실행 환경·실행 순서에 좌우되지 않아 같은 입력에 늘 같은 결과가 나오는 것이 주입의 실질적인 이득이다.', true),
(14281, 5288, 'init이 OrderService 대신 OrderAPIClient를 받도록 바뀌어도 이 테스트는 그대로 통과한다.', '교체 지점이 어디인지 놓친 오개념이다. 구체 타입을 받도록 바꾸면 StubOrderService를 넘기는 줄이 타입 불일치로 컴파일되지 않는다. 프로토콜로 받았기에 가짜 구현을 끼워 넣을 수 있었다.', false),
(14282, 5288, 'rows가 비었는지까지 단언했으므로 화면의 목록이 실제로 비어 보이는지도 함께 검증된다.', '뷰모델 상태 검증과 화면 검증을 같은 것으로 본 오개념이다. 이 테스트는 뷰모델의 프로퍼티만 읽으며 화면은 뜨지도 않는다. 상태가 화면에 제대로 반영되는지는 별도의 UI 테스트나 스냅숏 테스트가 맡는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1718, 5289, '서비스 로케이터,서비스로케이터,service locator,servicelocator,서비스 로케이터 패턴,service locator pattern', '필요한 협력자를 바깥에서 건네받지 않고, 전역에 하나 있는 저장소에 타입을 물어 스스로 찾아오는 방식이 서비스 로케이터다. 컴파일에는 아무 문제가 없지만 무엇에 의존하는지가 선언부에 드러나지 않아 숨은 의존성이 되고, 등록 상태가 전역으로 공유돼 테스트 실행 순서에 결과가 휘둘린다. 협력자를 init 인자로 받는 의존성 주입과는 방향이 반대다 — 그쪽은 쓰는 객체가 컨테이너의 존재조차 모르고, 컨테이너는 조립 루트에서 객체를 만들어 건네주는 역할만 한다. 인스턴스를 하나로 제한하는 규칙인 싱글턴과는 층위가 다르며, 협력자를 프로토콜로 선언해 두었다는 사실만으로 이 문제가 사라지지도 않는다.'),
       (1719, 5290, 'ObservableObject,observable object,옵저버블 오브젝트,옵저버블오브젝트,Combine.ObservableObject', 'SwiftUI의 @StateObject·@ObservedObject·@EnvironmentObject는 모두 ObservableObject를 채택한 참조 타입만 받는다. 채택하면 objectWillChange 발행자가 기본 구현으로 생기고, @Published 프로퍼티가 바뀌기 직전에 뷰가 그 신호를 받아 body를 다시 평가한다. 즉 @Published만 붙여서는 SwiftUI가 관찰할 통로가 열리지 않는다는 것이 핵심이다. 뷰 안에 상태를 두는 @State, 값 타입 상태를 양방향으로 잇는 Binding, iOS 17부터 매크로로 같은 일을 하는 @Observable과는 구분한다. 표현 로직을 UIKit에 기대지 않는 객체에 모아 두었기에, 화면 프레임워크를 바꾸면서도 이 뷰모델을 그대로 옮겨 쓸 수 있었다.');
