-- Unit: 화면 전환과 흐름 제어 (Unit ID: 184)
-- Chapter: iOS (Chapter ID: 17)
-- Topic: SWIFTUI
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-ios-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(916, 'SWIFTUI', 184, 'HARD', true,
 'SwiftUI 앱에서 gravit://orders/42/refund 같은 URL로 주문 상세를 거쳐 환불 화면까지 바로 이동하는 딥링크를 구현해야 한다면, 화면 흐름의 소유권을 어떻게 설계하고 어떤 점을 주의해야 하나요?',
 'NavigationPath를 뷰의 @State에 두면 뷰가 흐름을 소유하게 되므로, 경로를 소유하는 관찰 가능한 Router 객체(예: @Observable OrderRouter)를 만들고 NavigationStack(path: $router.path)에 바인딩한 뒤 .environment(router)로 뷰 트리에 주입합니다. 경로는 OrderRoute 같은 Hashable enum 배열로 표현합니다. 화면은 router.showDetail(order)처럼 Router 메서드만 호출하고 다음 뷰가 무엇인지 모르게 하는데, 이는 UIKit Coordinator와 같은 원칙이며, 한 흐름의 경로는 UIKit Coordinator 또는 SwiftUI Router 중 한 곳만 소유해야 합니다. 딥링크는 경로 조립으로 처리합니다. Router의 handle(deepLink:) 같은 함수가 URL에서 주문 id를 꺼내 path = [.detail(order), .refund(request)]처럼 경로 값 배열을 만들어 대입하면 상세와 환불 화면이 한 번에 쌓이고, .onOpenURL에서 이 함수를 호출합니다. 이 변환 함수는 Router에 두고 앱 시작과 포그라운드 진입 양쪽에서 재사용합니다. 경로가 enum 배열이므로 단위 테스트에서 화면 없이 흐름을 검증할 수도 있습니다. 주의할 점으로, navigationDestination(for:)는 스택 안의 뷰에 붙여야 하고 같은 타입에 여러 번 선언하면 예측 불가능하게 동작하며, LazyVStack이나 List 행 내부처럼 지연 생성되는 곳에 선언하면 등록 시점 문제로 전환이 실패할 수 있으므로 스택 루트 근처에 모아 둡니다.',
 'interview-question/916.mp3'),
(917, 'SWIFTUI', 184, 'NORMAL', true,
 'SwiftUI에서 NavigationView와 NavigationLink(destination:)를 쓰는 방식과 iOS 16의 NavigationStack과 NavigationPath를 쓰는 방식은 어떤 차이가 있나요?',
 'iOS 13~15의 NavigationView와 NavigationLink(destination:)는 링크마다 목적지 뷰를 직접 지정해 박아 넣고, 스택은 뷰 계층 안에 암묵적으로 존재했습니다. 그래서 프로그래밍 방식 전환은 isActive 바인딩에 의존해 다단계 push가 불안정했고 딥링크 구현도 어려웠습니다. 이 방식은 iOS 16에서 deprecated 되었습니다. iOS 16+의 NavigationStack은 경로를 데이터로 표현합니다. 스택이 NavigationPath, 즉 Hashable 값의 배열로 드러나고, 링크는 NavigationLink("상세", value: order)처럼 값만 push하며, 값 타입별 목적지는 navigationDestination(for:)에서 타입별로 한 번만 선언합니다. 프로그래밍 방식 전환은 path.append로 push, path.removeLast로 pop, path = NavigationPath()로 루트 복귀처럼 path를 직접 조작하면 되고, 딥링크는 경로 배열을 조립하면 끝납니다. 또한 NavigationPath의 codable 표현을 저장해 상태 복원도 가능합니다.',
 'interview-question/917.mp3'),
(918, 'SWIFTUI', 184, 'NORMAL', true,
 'UIKit에서 뷰 컨트롤러가 다음 화면을 직접 생성해 push하는 방식과 Coordinator 패턴을 쓰는 방식은 어떤 차이가 있나요?',
 '뷰 컨트롤러가 직접 push하는 방식에서는 예를 들어 OrderListVC가 OrderDetailVC를 직접 생성해 navigationController에 push하므로, 화면이 다음 화면의 존재와 생성 방법, 전환 방식을 모두 알아야 하고 의존성 생성까지 떠안습니다. 그 결과 재사용과 테스트가 어렵고, 흐름을 바꾸려면 화면 코드를 고쳐야 한다는 단점이 있습니다. Coordinator 패턴은 화면에서 흐름 제어 책임을 분리한 객체를 둡니다. 화면은 무슨 일이 일어났는지만 알리고 다음 화면을 생성하지 않으며, 어디로 갈지는 Coordinator가 결정해 다음 화면을 생성하고 push나 present합니다. 이때 화면은 onSelect 같은 클로저나 델리게이트를 이벤트 전달 수단으로 노출합니다. Coordinator는 컨테이너에서 VC를 만들며 필요한 서비스를 주입하는 의존성 주입 지점도 되고, AppCoordinator 아래 AuthCoordinator, MainCoordinator처럼 자식 Coordinator로 흐름을 트리로 나눌 수 있습니다.',
 'interview-question/918.mp3'),
(919, 'SWIFTUI', 184, 'EASY', true,
 'Coordinator 패턴을 사용할 때 흔히 발생하는 메모리 관리 문제는 무엇이고, 이를 어떻게 방지하나요?',
 'Coordinator의 고전적 함정은 메모리 관리입니다. 부모 Coordinator는 자식 Coordinator를 childCoordinators 배열에 보관하고, 흐름이 끝나면 부모가 childCoordinators에서 제거해야 합니다. 그런데 사용자가 시스템 뒤로 가기로 흐름을 빠져나갔는데 부모가 자식 Coordinator를 제거하지 않으면 자식 Coordinator가 누수됩니다. 이를 막으려면 UINavigationControllerDelegate의 didShow에서 pop을 감지하거나, 화면의 deinit 또는 완료 콜백으로 Coordinator 종료를 부모에게 알려 제거하게 합니다. 또한 화면에 넘기는 클로저에서 Coordinator를 캡처할 때는 항상 [weak self]를 사용합니다.',
 'interview-question/919.mp3'),
(920, 'SWIFTUI', 184, 'EASY', true,
 'SwiftUI에서 .sheet(item:)을 사용해 모달을 표시하는 방식에 대해 설명해 주세요.',
 '.sheet(item:)과 .fullScreenCover(item:)은 바인딩된 옵셔널 상태가 nil이 아닐 때 모달을 표시합니다. 예를 들어 @State private var editingOrder: Order?를 두고 버튼에서 editingOrder = order를 대입하면 시트가 뜹니다. 표시 여부가 곧 상태이므로 Bool 대신 Identifiable 값을 쓰면 표시 여부뿐 아니라 무엇을 보여줄지까지 표현할 수 있습니다. 시트 안에서는 @Environment(\.dismiss)로 닫고, 시트 안에 별도의 NavigationStack을 두어 모달 내부를 독립된 흐름으로 만들 수 있습니다.',
 'interview-question/920.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 916
(4931, 916, '경로를 소유하는 관찰 가능한 Router 객체를 만들어 뷰 트리에 환경으로 주입함을 설명', 'ESSENTIAL', 1),
(4932, 916, '딥링크 URL을 경로 값 배열로 변환해 Router의 path에 대입하는 방식을 설명', 'ESSENTIAL', 2),
(4933, 916, '화면은 Router 메서드만 호출하고 다음 뷰를 알지 못한다는 원칙을 언급', 'ESSENTIAL', 3),
(4934, 916, '스택 안의 뷰에 선언·같은 타입 중복 선언 금지·지연 생성 영역 회피 중 최소 1개를 navigationDestination 주의점으로 제시', 'ESSENTIAL', 4),
(4935, 916, '한 흐름의 경로는 UIKit Coordinator·SwiftUI Router 중 한 곳만 소유해야 함을 언급', 'SUPPLEMENTARY', 5),
(4936, 916, '경로가 enum 배열이므로 화면 없이 단위 테스트로 흐름을 검증할 수 있음을 언급', 'SUPPLEMENTARY', 6),
(4937, 916, 'URL을 경로로 바꾸는 함수를 앱 시작·포그라운드 진입 양쪽에서 재사용함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 917
(4938, 917, 'NavigationStack은 스택을 NavigationPath 같은 데이터로 표현한다는 점을 설명', 'ESSENTIAL', 1),
(4939, 917, 'NavigationView 방식은 링크마다 목적지 뷰를 직접 지정함을 언급', 'ESSENTIAL', 2),
(4940, 917, 'NavigationView 방식에서는 프로그래밍 방식 전환·딥링크 중 최소 1개가 어려웠음을 제시', 'ESSENTIAL', 3),
(4941, 917, 'path.append(push)·removeLast(pop) 중 최소 1개를 NavigationStack의 경로 조작 예로 제시', 'SUPPLEMENTARY', 4),
(4942, 917, 'navigationDestination(for:)로 값 타입별 목적지를 한 번 선언함을 언급', 'SUPPLEMENTARY', 5),
(4943, 917, 'NavigationView가 iOS 16에서 deprecated 되었음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 918
(4944, 918, '직접 push 방식은 화면이 다음 화면의 존재·생성 방법·전환 방식을 모두 알아야 함을 언급', 'ESSENTIAL', 1),
(4945, 918, '재사용 어려움·테스트 어려움·흐름 변경 시 화면 코드 수정 중 최소 1개를 직접 push 방식의 단점으로 제시', 'ESSENTIAL', 2),
(4946, 918, 'Coordinator 방식에서 화면은 이벤트만 알리고 이동할 곳은 Coordinator가 결정함을 설명', 'ESSENTIAL', 3),
(4947, 918, '클로저·델리게이트 중 최소 1개를 화면이 Coordinator에 이벤트를 알리는 수단으로 제시', 'SUPPLEMENTARY', 4),
(4948, 918, 'Coordinator가 컨테이너에서 VC를 만들며 의존성을 주입하는 지점이 됨을 언급', 'SUPPLEMENTARY', 5),
(4949, 918, '자식 Coordinator로 흐름을 트리 형태로 나눌 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 919
(4950, 919, '뒤로 가기로 흐름을 빠져나갔는데 부모가 자식 Coordinator를 제거하지 않으면 누수됨을 설명', 'ESSENTIAL', 1),
(4951, 919, 'didShow에서 pop 감지·화면 deinit/완료 콜백 중 최소 1개를 Coordinator 종료 통지 방법으로 제시', 'ESSENTIAL', 2),
(4952, 919, '흐름이 끝나면 부모가 childCoordinators에서 자식을 제거해야 함을 언급', 'SUPPLEMENTARY', 3),
(4953, 919, 'Coordinator의 클로저 캡처에는 항상 [weak self]를 사용함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 920
(4954, 920, '.sheet(item:)은 바인딩된 옵셔널 상태가 nil이 아닐 때 시트가 표시됨을 설명', 'ESSENTIAL', 1),
(4955, 920, 'Bool 대신 Identifiable 값을 쓰면 무엇을 보여줄지까지 표현됨을 언급', 'ESSENTIAL', 2),
(4956, 920, '시트 안에서 @Environment(\.dismiss)로 모달을 닫음을 언급', 'SUPPLEMENTARY', 3),
(4957, 920, '시트 안에 별도 NavigationStack을 두어 독립 흐름을 만들 수 있음을 언급', 'SUPPLEMENTARY', 4);
