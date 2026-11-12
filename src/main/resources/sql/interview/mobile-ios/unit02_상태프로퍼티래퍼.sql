-- Unit: 상태 프로퍼티 래퍼 (Unit ID: 178)
-- Chapter: iOS (Chapter ID: 17)
-- Topic: SWIFTUI
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-ios-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(886, 'SWIFTUI', 178, 'HARD', true,
 '화면 루트 뷰에서 뷰모델을 `@ObservedObject var vm = CartViewModel()`로 선언했더니 탭을 바꿨다 돌아오면 목록이 사라지는 문제가 생겼습니다. 원인이 무엇이고, 루트 뷰와 하위 뷰에서 각각 어떻게 선언해야 하는지 설명해 주시겠어요?',
 'SwiftUI 뷰는 구조체 값이라 갱신마다 새로 생성되고, 부모가 재평가되면 자식 뷰 값도 다시 만들어집니다. 그런데 `@ObservedObject var vm = CartViewModel()`처럼 선언하면 뷰 값이 만들어질 때마다 `CartViewModel()`이 다시 실행되어 새 객체가 생기므로, 기존 items가 사라지는 것입니다. 해결하려면 객체를 처음 만드는 화면 루트 뷰에서는 `@StateObject private var vm = CartViewModel()`로 선언합니다. `@StateObject`는 SwiftUI가 생성·보관하며 초기값 표현식이 지연 평가돼 뷰 정체성이 처음 생길 때 한 번만 실행되므로, 정체성 수명 동안 같은 인스턴스가 유지됩니다. 그 객체를 전달받는 하위 뷰(CartList 등)는 `@ObservedObject var vm: CartViewModel`로 선언해 소유하지 않고 넘겨받은 인스턴스를 구독만 합니다. 타이핑할 때마다 네트워크 요청이 다시 나가는 증상도 같은 원인에서 나오는 대표 증상입니다.',
 'interview-question/886.mp3'),
(887, 'SWIFTUI', 178, 'NORMAL', true,
 'SwiftUI에서 `@State`와 `@Binding`은 어떤 차이가 있고, 부모와 자식 뷰 사이에서 각각 어떻게 쓰이나요?',
 '`@State`는 토글 여부나 입력 텍스트처럼 뷰 자신만 사용하는 단순 값을 뷰가 소유하는 지역 상태로, 뷰의 정체성에 묶여 보존되며 외부 접근이 필요 없어 관례적으로 private으로 선언합니다. 반면 `@Binding`은 부모의 `@State`를 소유하지 않고 읽고 쓰는 통로로, 초기값 없이 선언합니다. 부모는 `$isAgreed`처럼 `$` 접두사로 `Binding<T>`를 얻어 자식에게 넘기고, 자식이 그 값을 바꾸면 부모의 원본이 바뀌며 부모가 재평가되면서 자식도 갱신됩니다. 즉 단일 진실 공급원이 유지됩니다. 자식이 값을 읽기만 한다면 바인딩이 아니라 일반 let 프로퍼티로 넘기는 것이 단방향 데이터 흐름을 읽기 쉽게 만듭니다.',
 'interview-question/887.mp3'),
(888, 'SWIFTUI', 178, 'NORMAL', true,
 '`@EnvironmentObject`와 `@Environment`는 모두 뷰 트리를 통해 값을 전달받는데, 무엇을 어떤 방식으로 조회하는지에 어떤 차이가 있나요?',
 '`@EnvironmentObject`는 여러 계층 아래의 뷰가 같은 객체를 써야 할 때 사용합니다. 상위에서 `.environmentObject(_:)`로 객체를 주입하면 하위 뷰에서 `@EnvironmentObject var session: UserSession`처럼 타입으로 조회해 꺼내므로, 매 단계 인자로 넘기는 프로퍼티 드릴링을 제거할 수 있습니다. 다만 주입되지 않은 타입을 꺼내면 런타임 크래시가 나므로 앱 루트나 프리뷰에서 반드시 주입해야 합니다. 반면 `@Environment`가 읽는 대상은 객체가 아니라 시스템·커스텀 환경값이며, 이를 키 경로(KeyPath)로 식별해 뷰 트리에서 조회합니다. 다크 모드(colorScheme), dismiss 같은 시스템 값이 대표적이고 커스텀 키도 정의할 수 있으며, 환경값은 상위에서 하위로만 흐르고 `.environment(\.key, value)`로 하위 트리 전체에 덮어쓸 수 있습니다. 정리하면 `@EnvironmentObject`는 타입으로, `@Environment`는 키 경로로 조회합니다.',
 'interview-question/888.mp3'),
(889, 'SWIFTUI', 178, 'EASY', true,
 'SwiftUI 뷰에서 상태를 일반 저장 프로퍼티가 아니라 프로퍼티 래퍼로 관리해야 하는 이유는 무엇인가요?',
 'SwiftUI 뷰는 구조체라서 body 안에서 자기 프로퍼티를 수정할 수 없고(mutating 불가), 뷰 값은 렌더마다 다시 만들어지므로 일반 저장 프로퍼티에 담은 값은 유지되지 않습니다. 그래서 프로퍼티 래퍼가 실제 값을 뷰 밖의 SwiftUI 관리 저장소에 두고 뷰는 이를 참조만 합니다. 또한 래퍼는 값이 바뀌면 뷰를 무효화해 body를 재평가하도록 연결해 주므로, 상태 변경이 화면 갱신으로 이어집니다.',
 'interview-question/889.mp3'),
(890, 'SWIFTUI', 178, 'EASY', true,
 '`ObservableObject`를 채택한 뷰모델의 데이터가 바뀌었을 때 뷰가 갱신되기까지 어떤 과정을 거치나요?',
 '값 타입으로 표현하기 어려운 모델·뷰모델은 `ObservableObject` 프로토콜을 채택한 클래스로 만들고, 변경을 알릴 프로퍼티에 `@Published`를 붙입니다. `@Published` 프로퍼티가 바뀌면 `objectWillChange`가 발행되고, 이를 구독 중인 뷰가 갱신됩니다. 참고로 이런 클래스 인스턴스를 `@State`에 담으면 프로퍼티 변경이 감지되지 않으므로, 소유하는 뷰에서는 `@StateObject`, 전달받는 뷰에서는 `@ObservedObject`로 연결합니다.',
 'interview-question/890.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 886
(4774, 886, '@ObservedObject의 초기값 표현식은 뷰 값이 만들어질 때마다 실행되어 새 객체가 생성됨을 설명', 'ESSENTIAL', 1),
(4775, 886, '객체를 처음 만드는 뷰에서는 @StateObject로 선언해 정체성 수명 동안 한 번만 생성되게 함을 제시', 'ESSENTIAL', 2),
(4776, 886, '객체를 전달받는 하위 뷰는 @ObservedObject로 선언해 소유하지 않고 구독만 함을 설명', 'ESSENTIAL', 3),
(4777, 886, 'SwiftUI 뷰는 갱신마다 새로 생성되는 값이라 부모 재평가 시 뷰 값도 다시 만들어짐을 언급', 'SUPPLEMENTARY', 4),
(4778, 886, '@StateObject의 초기값 표현식은 지연 평가돼 정체성이 처음 생길 때만 실행됨을 언급', 'SUPPLEMENTARY', 5),
(4779, 886, '타이핑할 때마다 네트워크 요청이 다시 나가는 증상도 같은 원인임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 887
(4780, 887, '@State는 뷰가 소유하는 상태이고 @Binding은 소유 없이 읽고 쓰는 참조임을 구분', 'ESSENTIAL', 1),
(4781, 887, '자식이 @Binding 값을 바꾸면 부모의 원본 상태가 바뀜을 설명', 'ESSENTIAL', 2),
(4782, 887, '$ 접두사로 Binding<T>를 얻어 자식에게 넘김을 언급', 'ESSENTIAL', 3),
(4783, 887, '@State는 외부 접근이 필요 없어 관례적으로 private으로 선언함을 언급', 'SUPPLEMENTARY', 4),
(4784, 887, '값을 읽기만 하는 자식에게는 @Binding 대신 일반 let 프로퍼티로 넘김을 제시', 'SUPPLEMENTARY', 5),

-- 질문 888
(4785, 888, '@EnvironmentObject는 타입으로, @Environment는 키 경로로 조회함을 구분', 'ESSENTIAL', 1),
(4786, 888, '@EnvironmentObject는 상위에서 .environmentObject(_:)로 주입한 객체를 하위에서 꺼냄을 설명', 'ESSENTIAL', 2),
(4787, 888, '@Environment가 읽는 대상은 객체가 아니라 시스템·커스텀 환경값임을 언급', 'ESSENTIAL', 3),
(4788, 888, '@Environment로 읽는 시스템 값으로 다크 모드·dismiss 중 최소 1개를 예로 제시', 'SUPPLEMENTARY', 4),
(4789, 888, '주입되지 않은 타입을 @EnvironmentObject로 꺼내면 런타임 크래시가 남을 언급', 'SUPPLEMENTARY', 5),
(4790, 888, '@EnvironmentObject가 매 단계 인자로 넘기는 프로퍼티 드릴링을 제거함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 889
(4791, 889, '구조체인 뷰는 body 안에서 자기 프로퍼티를 수정할 수 없음을 언급', 'ESSENTIAL', 1),
(4792, 889, '뷰 값은 렌더마다 다시 만들어져 일반 저장 프로퍼티의 값이 유지되지 않음을 설명', 'ESSENTIAL', 2),
(4793, 889, '래퍼는 실제 값을 뷰 밖의 SwiftUI 관리 저장소에 둠을 언급', 'ESSENTIAL', 3),
(4794, 889, '값이 바뀌면 래퍼가 뷰를 무효화해 body를 재평가하도록 연결함을 설명', 'SUPPLEMENTARY', 4),

-- 질문 890
(4795, 890, '@Published 프로퍼티가 바뀌면 objectWillChange가 발행됨을 설명', 'ESSENTIAL', 1),
(4796, 890, 'objectWillChange가 발행되면 구독 중인 뷰가 갱신됨을 설명', 'ESSENTIAL', 2),
(4797, 890, '뷰모델을 소유하는 뷰는 @StateObject, 전달받는 뷰는 @ObservedObject로 연결함을 언급', 'SUPPLEMENTARY', 3),
(4798, 890, '@State에 클래스 인스턴스를 담으면 프로퍼티 변경이 감지되지 않음을 언급', 'SUPPLEMENTARY', 4);
