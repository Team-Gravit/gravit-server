-- Unit: 뷰 컨트롤러 생명주기 (Unit ID: 103)
-- Chapter: iOS (Chapter ID: 9)
-- Topic: IOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-ios-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(511, 'IOS_COMMON', 103, 'HARD', true,
 '상세 화면에서 목록으로 돌아왔을 때 목록이 갱신되지 않아 데이터 로드와 알림 옵저버 등록을 viewWillAppear로 옮겼더니, 탭을 오갈 때마다 요청이 반복되고 같은 알림에 핸들러가 여러 번 실행됩니다. 각 문제의 원인과 개선 방법을 설명해 주시겠어요?',
 '목록이 갱신되지 않았던 원인은 로드 코드가 viewDidLoad에만 있었기 때문입니다. viewDidLoad는 뷰 컨트롤러 인스턴스당 한 번만 호출되므로 상세 화면에서 돌아와도 다시 실행되지 않습니다. 이를 viewWillAppear로 옮기자 새로 두 문제가 생겼습니다. 첫째, viewWillAppear는 탭 전환, 네비게이션 pop, 모달 dismiss 뒤 복귀 등 화면에 나타날 때마다 호출되기 때문에, 여기에 무거운 요청을 넣으면 탭을 오갈 때마다 요청이 반복됩니다. 개선하려면 최초 1회 로드는 viewDidLoad에 두고, viewWillAppear에서는 마지막 로드 후 일정 시간이 지났을 때만 갱신하도록 나눕니다. 둘째, 핸들러가 여러 번 실행되는 것은 viewWillAppear에서 옵저버를 등록만 하고 해제하지 않아 화면을 오갈 때마다 옵저버가 쌓였기 때문입니다. 개선하려면 등록과 해제를 짝이 맞는 콜백에 대칭으로 배치해야 합니다. viewWillAppear에서 등록했다면 viewDidDisappear에서 해제하고, viewDidLoad에서 등록했다면 deinit에서 해제합니다. 참고로 클로저 기반 addObserver(forName:)를 쓸 때는 반환된 토큰을 보관했다가 해제해야 하며, 토큰을 잃어버리면 옵저버가 영원히 남습니다.',
 'interview-question/511.mp3'),
(512, 'IOS_COMMON', 103, 'NORMAL', true,
 'viewDidLoad와 viewWillAppear의 차이는 무엇이고, 각각 어떤 작업을 배치하는 것이 적절한가요?',
 '가장 큰 차이는 호출 횟수입니다. viewDidLoad는 뷰 컨트롤러 인스턴스당 한 번만 호출되지만, viewWillAppear는 화면에 나타날 때마다 호출됩니다. 탭 전환, 네비게이션 push/pop, 모달 dismiss 뒤 복귀 같은 모든 경우에 viewWillAppear가 다시 호출됩니다. 그래서 viewDidLoad에는 서브뷰 추가, 제약 조건 설정, 델리게이트·데이터소스 연결, 최초 데이터 요청처럼 한 번만 하면 되는 초기 구성을 두고, viewWillAppear에는 화면 복귀 시 데이터 갱신, 네비게이션 바 스타일 설정, 옵저버 등록처럼 화면이 나타날 때마다 필요한 작업을 둡니다. 두 콜백 모두 뷰 크기가 아직 확정되지 않은 시점이라 viewDidLoad에서 프레임 값을 계산하는 것은 부적합하며, viewWillAppear에는 애니메이션 시작이나 무거운 네트워크 요청을 넣지 않는 것이 좋습니다.',
 'interview-question/512.mp3'),
(513, 'IOS_COMMON', 103, 'NORMAL', true,
 'viewDidLoad에서 view의 frame이나 bounds를 읽어 계산하면 안 되는 이유는 무엇이고, 크기에 의존하는 작업은 어디에 배치해야 하나요?',
 'viewDidLoad 시점에는 뷰 계층은 만들어져 있지만 크기가 아직 확정되지 않았습니다. 레이아웃이 확정되기 전이라 view.bounds나 frame 값이 부정확하고, 스토리보드 기본값이거나 0일 수도 있어 이 값으로 계산하면 잘못된 레이아웃이 나옵니다. 실제 크기는 viewDidLayoutSubviews 이후에야 확정되므로 크기에 의존하는 작업은 viewDidLayoutSubviews에 둡니다. 예를 들어 그라데이션 레이어는 오토 레이아웃 대상이 아니므로 여기서 headerView.bounds에 맞춰 프레임을 직접 갱신하고, cornerRadius 갱신도 여기에 둡니다. 다만 viewDidLayoutSubviews는 회전, 키보드, 스크롤 등으로 여러 번 호출되기 때문에 서브뷰 추가나 네트워크 호출 같은 작업을 넣으면 중복 실행됩니다. 프레임 갱신처럼 여러 번 실행해도 결과가 같은 멱등한 작업만 배치해야 합니다. 반면 오토 레이아웃 제약 조건은 크기와 무관하므로 viewDidLoad에서 설정해도 됩니다.',
 'interview-question/513.mp3'),
(514, 'IOS_COMMON', 103, 'EASY', true,
 'UIViewController가 생성되어 화면에 나타나고 사라질 때까지 호출되는 생명주기 콜백의 순서를 설명해 주세요.',
 '먼저 init(coder:)나 init(nibName:bundle:)로 인스턴스가 생성되고, loadView()에서 view 프로퍼티가 만들어집니다. 이어서 viewDidLoad()가 단 한 번 호출되는데, 이때 뷰 계층은 있지만 크기는 아직 확정되지 않았습니다. 이후 화면에 나타날 때마다 viewWillAppear가 호출되고, iOS 17 이상에서는 트레이트·레이아웃이 결정된 직후 viewIsAppearing이 호출됩니다. 그다음 viewWillLayoutSubviews와 viewDidLayoutSubviews가 호출되며, 이 둘은 회전이나 키보드 등으로 레이아웃이 바뀔 때마다 반복됩니다. 화면 전환 애니메이션이 완료되면 viewDidAppear가 호출됩니다. 화면에서 사라질 때는 viewWillDisappear, viewDidDisappear 순서로 호출되고, 마지막으로 참조가 모두 해제되었을 때만 deinit이 호출됩니다.',
 'interview-question/514.mp3'),
(515, 'IOS_COMMON', 103, 'EASY', true,
 '뷰 컨트롤러를 pop했는데 deinit이 호출되지 않는다면 어떤 원인을 의심해야 하고, 어떻게 해결할 수 있나요?',
 'pop된 뒤에도 deinit이 호출되지 않으면 강한 참조 순환을 의심해야 하며, 대표적으로 클로저·타이머·델리게이트가 순환을 만듭니다. 가장 흔한 원인은 클로저가 self를 강하게 붙잡는 경우로, 예를 들어 viewModel.onUpdate 클로저 안에서 self.tableView.reloadData()를 호출하면 viewModel → 클로저 → self → viewModel로 순환이 생깁니다. 이때는 클로저에 [weak self]를 써서 약한 참조로 순환을 차단하고 self?.tableView.reloadData()처럼 호출합니다. 또 Timer.scheduledTimer(target:selector:)는 타겟을 강하게 보유하므로 viewDidDisappear에서 invalidate()하지 않으면 뷰 컨트롤러가 해제되지 않고, 델리게이트 프로퍼티는 weak var delegate로 선언해 부모와 자식이 서로를 강하게 잡지 않도록 해야 합니다. 원인을 찾을 때는 Xcode의 Memory Graph Debugger로 해제되지 않은 인스턴스와 참조 경로를 확인할 수 있고, deinit에 print를 넣어 두면 화면을 닫았는데 로그가 찍히지 않는 것으로 순환 참조를 조기에 발견할 수 있습니다.',
 'interview-question/515.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 511
(2737, 511, 'viewWillAppear는 화면에 나타날 때마다 호출되어 무거운 요청이 반복됨을 설명', 'ESSENTIAL', 1),
(2738, 511, 'viewWillAppear에서 옵저버를 등록만 하고 해제하지 않아 화면을 오갈 때마다 쌓임을 설명', 'ESSENTIAL', 2),
(2739, 511, '옵저버 등록·해제를 viewWillAppear↔viewDidDisappear 또는 viewDidLoad↔deinit으로 대칭 배치함을 제시', 'ESSENTIAL', 3),
(2740, 511, '최초 로드는 viewDidLoad에 두고 viewWillAppear에서는 일정 시간이 지났을 때만 갱신하는 방식을 제시', 'ESSENTIAL', 4),
(2741, 511, '로드 코드가 viewDidLoad에만 있으면 1회만 호출되어 복귀 시 목록이 갱신되지 않음을 설명', 'SUPPLEMENTARY', 5),
(2742, 511, '클로저 기반 addObserver(forName:)는 반환된 토큰을 보관했다가 해제해야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 512
(2743, 512, 'viewDidLoad는 인스턴스당 1회, viewWillAppear는 화면에 나타날 때마다 호출됨을 설명', 'ESSENTIAL', 1),
(2744, 512, '서브뷰 추가·제약 조건 설정·델리게이트 연결·최초 데이터 요청 중 최소 1개를 viewDidLoad 작업으로 제시', 'ESSENTIAL', 2),
(2745, 512, 'viewWillAppear에는 화면 복귀 시 데이터 갱신 작업을 배치함을 설명', 'ESSENTIAL', 3),
(2746, 512, '탭 전환·네비게이션 pop·모달 dismiss 뒤 복귀 중 최소 1개에서 viewWillAppear가 다시 호출됨을 언급', 'SUPPLEMENTARY', 4),
(2747, 512, '두 콜백 모두 뷰 크기가 아직 확정되지 않은 시점임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 513
(2748, 513, 'viewDidLoad 시점에는 뷰 크기가 아직 확정되지 않아 frame 값이 부정확함을 설명', 'ESSENTIAL', 1),
(2749, 513, '실제 크기는 viewDidLayoutSubviews 이후에야 확정됨을 언급', 'ESSENTIAL', 2),
(2750, 513, 'viewDidLayoutSubviews는 여러 번 호출되므로 멱등한 작업만 배치해야 함을 설명', 'SUPPLEMENTARY', 3),
(2751, 513, '오토 레이아웃 제약 조건은 크기와 무관해 viewDidLoad에서 설정해도 됨을 언급', 'SUPPLEMENTARY', 4),
(2752, 513, 'cornerRadius·그라데이션 레이어 프레임 갱신 중 최소 1개를 viewDidLayoutSubviews 작업 예로 제시', 'SUPPLEMENTARY', 5),

-- 질문 514
(2753, 514, 'loadView → viewDidLoad → viewWillAppear → viewDidAppear 순서로 호출됨을 설명', 'ESSENTIAL', 1),
(2754, 514, '화면에서 사라질 때 viewWillDisappear → viewDidDisappear 순서로 호출됨을 설명', 'ESSENTIAL', 2),
(2755, 514, 'deinit은 참조가 모두 해제되었을 때만 호출됨을 언급', 'SUPPLEMENTARY', 3),
(2756, 514, 'viewWillLayoutSubviews·viewDidLayoutSubviews가 레이아웃이 바뀔 때마다 반복 호출됨을 언급', 'SUPPLEMENTARY', 4),
(2757, 514, 'viewDidAppear가 화면 전환 애니메이션 완료 시점에 호출됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 515
(2758, 515, '원인으로 강한 참조 순환을 의심해야 함을 언급', 'ESSENTIAL', 1),
(2759, 515, '클로저·타이머·델리게이트 중 최소 1개를 강한 참조 순환의 원인으로 제시', 'ESSENTIAL', 2),
(2760, 515, '[weak self]·weak var delegate·타이머 invalidate() 중 최소 1개를 해결 방법으로 제시', 'ESSENTIAL', 3),
(2761, 515, '클로저가 self를 강하게 붙잡는 경우가 가장 흔한 원인임을 언급', 'SUPPLEMENTARY', 4),
(2762, 515, 'Memory Graph Debugger로 해제되지 않은 인스턴스와 참조 경로를 확인하는 방법을 제시', 'SUPPLEMENTARY', 5),
(2763, 515, 'deinit에 print를 넣어 로그가 찍히지 않는 것으로 순환 참조를 조기에 발견하는 방법을 제시', 'SUPPLEMENTARY', 6);
