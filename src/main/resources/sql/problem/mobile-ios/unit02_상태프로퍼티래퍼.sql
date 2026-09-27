-- Unit: 상태 프로퍼티 래퍼 (Unit ID: 178)
-- Chapter: iOS (Chapter ID: 17)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (604, 178, '저장소 소유권과 바인딩, 환경 주입'),
       (762, 178, '갱신 누락 원인과 전달받은 뷰모델'),
       (920, 178, 'SwiftUI 상태 래퍼 응용: 정체성·데이터 흐름·환경값으로 결과 추적하기');

-- =====================================================
-- Lesson 604: 저장소 소유권과 바인딩, 환경 주입
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3803, 604, '아래 코드를 실행했을 때 나타난 증상의 원인으로 옳은 것은?', '장바구니 화면에서 검색창에 한 글자를 입력할 때마다 담은 상품 개수가 0으로 돌아간다.

```swift
final class CartViewModel: ObservableObject {
    @Published var items: [Item] = []
}

struct CartScreen: View {
    @ObservedObject var vm = CartViewModel()
    @State private var query = ""

    var body: some View {
        VStack {
            TextField("검색", text: $query)
            Text("담은 상품 \(vm.items.count)개")
        }
    }
}
```', 'OBJECTIVE'),
       (3804, 604, '아래 비교표에서 따라 나오는 설명으로 옳지 않은 것은?', '| 래퍼 | 저장소 소유자 | 다루는 값 | 선언 시 초기값 |
|---|---|---|---|
| @State | 이 뷰 | 값 타입 | 직접 지정 |
| @Binding | 다른 뷰 | 값 타입 | 지정하지 않음 |
| @StateObject | 이 뷰 | 참조 타입 | 직접 지정 |
| @ObservedObject | 외부 | 참조 타입 | 전달받아 사용 |', 'OBJECTIVE'),
       (3805, 604, '아래 상태 공유 방식에 대한 설명으로 옳은 것은?', '상위 뷰에서 .environmentObject(_:)로 참조 객체를 주입하면, 그 아래 뷰 트리에 있는 뷰는 중간 단계를 거치지 않고 타입을 지정해 같은 인스턴스를 꺼내 쓸 수 있다.', 'OBJECTIVE'),
       (3806, 604, '아래 코드에서 +1 버튼을 세 번 눌렀을 때 화면에 보이는 두 줄로 옳은 것은?', '```swift
struct ParentView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("합계 \(count)")
            StepperRow(value: $count)
            SummaryLabel(value: count)
        }
    }
}

struct StepperRow: View {
    @Binding var value: Int
    var body: some View { Button("+1") { value += 1 } }
}

struct SummaryLabel: View {
    let value: Int
    var body: some View { Text("표시 \(value)") }
}
```', 'OBJECTIVE'),
       (3807, 604, '아래 상황에서 클래스가 채택한 프로토콜의 이름은?', '여러 화면이 함께 쓰는 장바구니 데이터를 클래스로 만들었다. 처음에는 평범한 클래스여서, 목록 화면을 띄워 둔 상태로 items 배열에 항목을 추가해도 화면은 이전 목록 그대로였다. 클래스 선언에 프로토콜 하나를 채택하고 items 앞에 @Published를 붙이자, 항목을 추가하는 즉시 목록 화면이 다시 그려졌다.', 'SUBJECTIVE'),
       (3808, 604, '아래 상황에서 두 값을 읽으려고 프로퍼티 앞에 붙인 프로퍼티 래퍼는?', '상세 화면을 닫으려고 부모에서 시트 표시 여부 불리언을 계층마다 내려주던 코드를, 하위 뷰에서 \.dismiss를 가리키는 dismiss 프로퍼티를 선언하고 버튼에서 dismiss()를 호출하는 방식으로 바꿨다. 같은 화면에서 다크 모드인지 판별할 때 쓰는 \.colorScheme도 똑같은 형태로 선언해 읽는다. 두 프로퍼티에는 같은 래퍼가 붙어 있고, 어느 쪽도 앱 루트에서 객체를 따로 주입하지 않았는데 값이 채워져 있었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3803
(10315, 3803, 'TextField에 연결된 바인딩이 같은 뷰의 다른 프로퍼티까지 함께 초기화한다.', '바인딩은 자신이 가리키는 저장소 한 곳만 읽고 쓴다. query가 바뀌어 body가 다시 평가될 뿐, 바인딩이 뷰모델 프로퍼티를 건드리지는 않는다.', false),
(10316, 3803, '@Published가 붙은 배열은 뷰가 다시 그려지는 시점에 자동으로 비워진다.', '@Published는 값이 바뀔 때 변경 사실을 발행할 뿐 값을 지우지 않는다. 갱신 시점마다 값이 초기화된다고 본 오해다.', false),
(10317, 3803, '뷰 값이 다시 만들어질 때마다 초기값 표현식이 실행돼 뷰모델이 새 인스턴스로 교체된다.', '@ObservedObject는 객체를 소유하지 않아 초기값 표현식을 지연 평가하지 않는다. 한 글자 입력마다 CartViewModel()이 다시 실행돼 items가 빈 배열로 돌아간다. 객체를 처음 만드는 뷰는 @StateObject로 선언해야 한다.', true),
(10318, 3803, '뷰모델이 구조체가 아니라 클래스라서 뷰에 전달될 때 값이 복사돼 변경이 유실된다.', '클래스는 참조 타입이라 전달해도 복사되지 않는다. 값 타입 복사 규칙을 참조 타입에 잘못 적용한 오해다.', false),

-- 문제 3804
(10319, 3804, '@Binding으로 선언한 프로퍼티는 부모가 값을 넘기지 않아도 자체 기본값으로 동작을 시작한다.', '표에서 @Binding은 저장소 소유자가 다른 뷰이고 선언 시 초기값을 지정하지 않는다. 가리킬 저장소를 외부에서 받지 못하면 뷰를 만들 수조차 없으므로 거짓이다.', true),
(10320, 3804, '자식이 부모의 값을 바꿔야 한다면 값을 복사해 넘기지 말고 @Binding으로 넘겨야 원본이 함께 바뀐다.', '참이다. @Binding은 저장소 소유자가 다른 뷰이므로 자식의 쓰기가 부모 원본에 그대로 닿아 진실 공급원이 하나로 유지된다.', false),
(10321, 3804, '@State와 @StateObject는 저장소를 이 뷰가 소유하므로 body가 다시 평가돼도 값이 유지된다.', '참이다. 소유자가 이 뷰인 두 래퍼는 저장소가 뷰 정체성에 묶여 남으므로, 뷰 값이 새로 만들어져도 값이 사라지지 않는다.', false),
(10322, 3804, '이미 만들어진 뷰모델을 하위 뷰에 넘겨 구독만 시킬 때는 하위 뷰에서 @ObservedObject로 받는다.', '참이다. 표의 @ObservedObject는 소유자가 외부이고 인스턴스를 전달받아 쓰는 자리이므로, 객체를 받아 쓰는 하위 뷰에 맞는다.', false),

-- 문제 3805
(10323, 3805, '값 타입 구조체만 담을 수 있어 클래스 인스턴스는 넣을 수 없다.', '주입되는 대상 자체가 참조 객체다. 값 타입만 다루는 @State의 제약을 다른 방식에 잘못 옮겨 붙인 오해다.', false),
(10324, 3805, '하위 뷰가 꺼낸 인스턴스는 복사본이라 값을 바꿔도 상위 뷰에는 반영되지 않는다.', '참조 객체를 꺼내는 것이라 복사본이 아니라 같은 인스턴스다. 하위에서 바꾸면 그 객체를 구독하는 상위 뷰도 함께 갱신된다.', false),
(10325, 3805, '중간 뷰마다 값을 인자로 받아 다시 넘겨야 해서 계층이 깊을수록 초기화 코드가 길어진다.', '계층마다 넘기는 프로퍼티 드릴링을 없애려고 쓰는 방식이다. 일반 프로퍼티 전달의 단점을 그대로 갖다 붙인 오해다.', false),
(10326, 3805, '주입을 빠뜨린 채 화면을 띄우면 컴파일은 통과하지만 실행 중 크래시가 난다.', '조회가 타입만으로 이뤄져 주입 여부를 컴파일러가 검사하지 못한다. 값이 없으면 꺼내는 순간 실행이 중단되므로 앱 루트와 프리뷰 양쪽에 주입해야 한다.', true),

-- 문제 3806
(10327, 3806, '합계 0 / 표시 0', '자식의 쓰기가 부모 저장소까지 닿지 않는다고 본 오해다. 바인딩은 부모의 @State 저장소를 그대로 가리키므로 value += 1이 count를 올린다.', false),
(10328, 3806, '합계 3 / 표시 3', '바인딩을 통해 부모의 count가 3이 되고, 부모 body가 다시 평가되면서 SummaryLabel도 새 인자 3을 받아 다시 만들어진다.', true),
(10329, 3806, '합계 3 / 표시 0', 'let으로 받은 값은 한 번 정해지면 갱신되지 않는다고 본 오해다. 부모가 재평가되면 자식 뷰 값 자체가 새 인자로 다시 만들어진다.', false),
(10330, 3806, '합계 0 / 표시 3', '자식이 자기 사본만 올리고 부모는 그대로라고 본 오해다. 바인딩은 사본을 만들지 않으며, 부모가 안 바뀌면 SummaryLabel도 갱신되지 않아 두 줄이 이렇게 갈릴 수 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1224, 3807, 'ObservableObject,Observable Object,옵저버블 오브젝트,옵저버블오브젝트', '@Published 값이 바뀌면 objectWillChange가 발행되고, 이 발행을 구독한 뷰가 body를 다시 평가한다. 이 발행 통로를 제공하는 프로토콜이 ObservableObject다. 평범한 클래스에 항목을 추가해도 화면이 그대로였던 이유는 바뀌었다는 사실을 뷰에 알릴 통로가 없었기 때문이다. 헷갈리기 쉬운 옆 개념과 경계를 잡아 두자. @StateObject·@ObservedObject·@EnvironmentObject는 이 프로토콜을 채택한 객체를 뷰에 연결하는 래퍼일 뿐 프로토콜이 아니고, @Published는 발행 대상 프로퍼티를 고르는 래퍼다. iOS 17+의 @Observable 매크로는 같은 목적을 매크로로 대신하는 별개 장치이며, ObservableObject는 참조 타입 전용이라 구조체에는 채택할 수 없다.'),
       (1225, 3808, '@Environment,Environment,환경 래퍼,환경값 래퍼', '키 경로로 식별되는 환경값을 뷰 트리에서 읽어 오는 래퍼가 @Environment다. dismiss·colorScheme·dynamicTypeSize처럼 시스템이 미리 채워 두는 값이 대표적이라, 앱 루트에서 따로 주입하지 않아도 값이 들어 있는 것이 본문의 장면이다. 옆 개념과의 경계는 이렇다. @EnvironmentObject는 개발자가 .environmentObject(_:)로 넣어 둔 참조 객체를 타입으로 꺼내므로 주입을 빠뜨리면 실행 중 크래시가 나고, @Environment는 키 경로로 값을 지목한다. 환경값은 상위에서 하위로만 흐르며 .environment(\.키, 값)를 붙이면 그 아래 트리 전체에서 덮어쓸 수 있다.');

-- =====================================================
-- Lesson 762: 갱신 누락 원인과 전달받은 뷰모델
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4751, 762, '아래 코드에서 버튼을 눌러도 화면의 이름이 그대로인 원인으로 옳은 것은?', '버튼을 누른 뒤 디버거로 확인하니 profile.name 값은 이미 지민으로 바뀌어 있었지만, 화면에는 여전히 게스트가 보였다.

```swift
final class Profile {
    var name = "게스트"
}

struct ProfileCard: View {
    @State private var profile = Profile()

    var body: some View {
        VStack {
            Text(profile.name)
            Button("이름 바꾸기") { profile.name = "지민" }
        }
    }
}
```', 'OBJECTIVE'),
       (4752, 762, '아래 코드에서 자식 뷰의 토글을 켜도 부모 뷰의 텍스트가 그대로인 원인으로 옳은 것은?', '```swift
struct ParentView: View {
    @State private var isOn = false

    var body: some View {
        VStack {
            Text(isOn ? "켜짐" : "꺼짐")
            ChildToggle(initial: isOn)
        }
    }
}

struct ChildToggle: View {
    @State private var value: Bool

    init(initial: Bool) { _value = State(initialValue: initial) }

    var body: some View {
        Toggle("알림 받기", isOn: $value)
    }
}
```', 'OBJECTIVE'),
       (4753, 762, '아래 비교표에서 따라 나오는 설명으로 옳은 것은?', '| 항목 | 왼쪽: @EnvironmentObject | 오른쪽: @Environment |
|---|---|---|
| 넣는 방법 | .environmentObject(객체) | .environment(\.키, 값) |
| 꺼내는 기준 | 타입 | 키 경로 |
| 다루는 대상 | ObservableObject를 채택한 클래스 | 키로 식별되는 값 |
| 넣지 않았을 때 | 꺼내는 순간 실행이 중단됨 | 시스템이 정한 기본값이 들어 있음 |', 'OBJECTIVE'),
       (4754, 762, '아래에 설명한 뷰의 성질에서 따라 나오는 결론으로 옳은 것은?', 'SwiftUI에서 화면을 구성하는 뷰는 구조체 값이다. 부모가 다시 평가될 때마다 자식 뷰 값은 새로 만들어지고, body가 평가되는 동안 뷰는 자기 프로퍼티를 바꿀 수 없는 자리에 놓인다.', 'OBJECTIVE'),
       (4755, 762, '아래 상황에서 선언 앞에 새로 붙인 프로퍼티 래퍼의 이름은?', '주문 내역 화면은 화면 루트에서 뷰모델을 직접 만들어 들고 있다. 처음에는 탭을 옮겼다 돌아올 때마다 목록이 비어 있었고, 서버 로그에는 같은 조회 요청이 화면에 들어올 때마다 새로 찍혔다. 뷰모델 선언 앞의 래퍼만 다른 것으로 바꾸자, 같은 화면을 여러 번 오가도 조회 요청은 처음 한 번만 남고 목록도 그대로 유지됐다. 뷰모델 클래스와 화면 코드의 나머지 부분은 한 글자도 고치지 않았다.', 'SUBJECTIVE'),
       (4756, 762, '아래 상황을 바로잡으려면 상세 영역이 뷰모델을 받을 때 써야 하는 프로퍼티 래퍼의 이름은?', '한 화면 안에 왼쪽 목록과 오른쪽 상세 영역을 나란히 띄운다. 상세 영역은 목록이 만들어 넘겨 준 뷰모델을 인자로 받아 쓰는데, 선언 앞에 @StateObject를 붙여 두었더니 목록에서 다른 항목을 눌러 새 뷰모델을 넘겨도 상세 영역은 처음 눌렀던 항목 내용을 계속 보여 줬다. 상세 영역은 화면에서 사라지지 않고 같은 자리에 그대로 있다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4751
(12843, 4751, '구조체인 뷰의 body 안에서는 프로퍼티에 값을 대입할 수 없어 대입 자체가 무시된다.', '래퍼를 거친 프로퍼티는 body 안에서도 바꿀 수 있고, 본문에서도 name은 실제로 지민으로 바뀌어 있었다. 구조체의 mutating 제약을 래퍼가 붙은 프로퍼티까지 넓혀 적용한 오해다.', false),
(12844, 4751, '담아 둔 값 자체가 교체될 때만 뷰가 무효화되는데, 참조는 그대로고 객체 안쪽 프로퍼티만 바뀌었다.', '값 타입이면 프로퍼티 하나만 고쳐도 값 전체가 새 값으로 교체돼 무효화 신호가 나가지만, 클래스는 참조가 그대로라 @State가 변화를 알아채지 못한다. 이런 모델은 ObservableObject로 만들어 @StateObject로 들고 있어야 한다.', true),
(12845, 4751, 'private으로 선언하면 저장소가 뷰 바깥에 만들어지지 않아 값 변경이 화면까지 전달되지 않는다.', 'private은 다른 타입에서 프로퍼티를 보지 못하게 하는 접근 제어일 뿐이라 저장소 위치나 무효화 동작과 관계가 없다. @State는 오히려 private 선언이 권장된다.', false),
(12846, 4751, '뷰 값이 다시 만들어질 때마다 Profile()이 다시 실행돼 name이 초기값 게스트로 되돌아간다.', '@State의 초기값 표현식은 지연 평가돼 뷰 정체성이 처음 생길 때 한 번만 실행된다. 게다가 본문에서 확인한 name은 지민이었으므로 값이 되돌아간 상황도 아니다.', false),

-- 문제 4752
(12847, 4752, '부모의 상태가 private으로 선언돼 자식 뷰에 쓰기 권한이 전달되지 않았다.', 'private은 접근 제어일 뿐이고, $isOn을 인자로 넘기면 자식이 부모 저장소에 얼마든지 쓸 수 있다. 값이 닿지 않는 이유는 접근 수준이 아니라 저장소가 둘로 갈라진 데 있다.', false),
(12848, 4752, 'Toggle에 넘긴 $value가 읽기 전용 통로라 사용자가 켠 결과가 어디에도 저장되지 않는다.', '$value는 읽고 쓰는 바인딩이라 토글 결과는 자식의 저장소에 제대로 저장된다. 저장이 안 되는 것이 아니라 저장되는 곳이 부모의 저장소가 아닐 뿐이다.', false),
(12849, 4752, '부모가 다시 평가될 때마다 자식의 init이 실행돼 켜 둔 값이 전달받은 값으로 덮어써진다.', 'State(initialValue:)로 준 값은 뷰 정체성이 처음 생길 때만 쓰이고 이후 재평가에서는 무시된다. 덮어쓰기가 일어나는 것이 아니라 애초에 부모 쪽 값이 바뀌지 않는 것이 문제다.', false),
(12850, 4752, '자식이 전달받은 값으로 자기 저장소를 따로 만들어 써서 토글 결과가 부모 저장소에 닿지 않는다.', '값 타입은 넘기는 순간 복사되므로 두 저장소가 서로 남남이 된다. 자식이 부모 값을 바꿔야 한다면 값을 복사해 State로 다시 담지 말고 $isOn을 @Binding으로 받아야 진실 공급원이 하나로 유지된다.', true),

-- 문제 4753
(12851, 4753, '두 방식 모두 값이 아래에서 위로도 전달돼 하위 뷰가 바꾼 값을 상위 뷰가 읽을 수 있다.', '환경은 상위에서 하위로만 흐른다. 하위에서 .environment로 값을 덮어써도 효과는 자기 아래 트리에만 미치고 상위 뷰는 원래 값을 그대로 읽는다.', false),
(12852, 4753, '오른쪽은 꺼내는 기준이 키 경로여서 시스템이 미리 정해 둔 키만 읽을 수 있다.', '키 경로로 찾는다는 것이 키 종류를 시스템 것으로 제한한다는 뜻은 아니다. EnvironmentKey를 직접 정의해 커스텀 키를 꽂아 넣고 같은 방식으로 읽을 수 있다.', false),
(12853, 4753, '프리뷰로 하위 화면만 띄울 때 왼쪽을 쓴 화면은 넣어 주는 코드가 필요하지만 오른쪽만 쓴 화면은 없어도 된다.', '표의 마지막 행에서 곧장 따라 나온다. 왼쪽은 넣지 않으면 꺼내는 순간 실행이 멈추니 프리뷰에도 주입 코드를 붙여야 하고, 오른쪽은 시스템 기본값이 들어 있어 그대로 띄워도 값이 비지 않는다.', true),
(12854, 4753, '앱 루트에서 넣은 객체는 트리 중간에서 같은 타입으로 다시 넣어도 아래쪽 뷰가 루트의 것을 꺼낸다.', '꺼내는 기준이 타입이므로 뷰는 자기에게서 가장 가까운 값을 찾는다. 중간에서 다시 넣으면 그 아래 트리에서는 중간에서 넣은 인스턴스가 꺼내진다.', false),

-- 문제 4754
(12855, 4754, '사용자가 바꾼 값을 다음 갱신까지 남기려면 값을 뷰 밖 저장소에 두고 뷰는 그곳을 가리키기만 해야 한다.', '뷰 값과 함께 사라지지 않는 곳에 값을 둬야 하고, 뷰가 자기를 못 바꾸니 쓰기도 그 저장소를 거쳐야 한다. 프로퍼티 래퍼가 하는 일이 바로 이 연결이다.', true),
(12856, 4754, '뷰 값이 새로 만들어질 때마다 화면이 통째로 다시 그려지므로 뷰를 잘게 쪼갤수록 갱신 비용이 커진다.', '뷰 값을 만드는 일은 화면을 다시 그리는 일이 아니라 무엇을 그릴지 적어 내는 일이다. 잘게 쪼개면 값이 바뀐 부분만 다시 평가돼 오히려 갱신 범위가 좁아진다.', false),
(12857, 4754, '뷰 값이 매번 새로 만들어지므로 같은 자리에 있는 뷰라도 상태는 갱신 때마다 처음 값으로 돌아간다.', '상태는 뷰 값이 아니라 뷰 정체성에 묶여 보관된다. 정체성이 유지되는 한 값도 남고, 자리나 정체성이 바뀔 때만 초기값으로 돌아간다.', false),
(12858, 4754, 'body에서 프로퍼티를 바꿀 수 없으므로 값을 바꾸려면 뷰를 클래스로 선언해 참조 타입으로 만들어야 한다.', '뷰를 참조 타입으로 바꾸는 것은 해법이 아니다. 필요한 것은 값이 바뀌었음을 프레임워크에 알려 body를 다시 평가시키는 통로이고, 그 통로를 래퍼가 제공한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1540, 4755, '@StateObject,StateObject,스테이트오브젝트,스테이트 오브젝트', '객체를 처음 만드는 뷰가 들고 있어야 하는 래퍼가 @StateObject다. 초기값 표현식을 지연 평가해 뷰 정체성이 생길 때 딱 한 번만 실행하고, 그 뒤 body가 여러 번 재평가돼도 같은 인스턴스를 그대로 돌려준다. 그래서 조회 요청이 처음 한 번만 나가고 목록도 남는다. 옆 개념과 경계를 잡아 두자. @ObservedObject는 객체를 소유하지 않고 구독만 하므로 선언부에서 객체를 만들면 뷰 값이 생길 때마다 새 인스턴스가 만들어진다. 이것이 본문의 처음 증상이다. @State는 값 타입 지역 상태용이라 클래스를 담으면 안쪽 프로퍼티 변경을 알아채지 못하고, @EnvironmentObject는 상위에서 주입해 둔 객체를 꺼내 쓰는 쪽이라 객체를 만드는 자리에는 맞지 않는다.'),
       (1541, 4756, '@ObservedObject,ObservedObject,옵저브드오브젝트,옵저브드 오브젝트', '외부에서 만들어 넘겨 준 객체를 소유하지 않고 구독만 할 때 쓰는 래퍼가 @ObservedObject다. 전달받은 인스턴스를 그대로 쓰기 때문에 부모가 새 뷰모델을 넘기면 그때그때 반영되고, 그 객체의 @Published 값이 바뀌면 상세 영역이 다시 평가된다. 경계는 이렇다. @StateObject는 뷰 정체성이 생길 때 받은 첫 인스턴스를 저장소에 붙들어 두고 이후 넘어오는 인스턴스를 무시하므로, 상세 영역이 같은 자리를 지켜 정체성이 그대로였던 본문 상황에서는 첫 항목이 계속 보인다. 반대로 객체를 처음 만드는 뷰에서 @ObservedObject를 쓰면 재평가마다 새 객체가 생기니, 만드는 쪽은 @StateObject, 받는 쪽은 @ObservedObject로 갈라 쓴다. 여러 계층 아래에서 같은 객체를 공유해야 한다면 @EnvironmentObject가 대안이다.');

-- =====================================================
-- Lesson 920: SwiftUI 상태 래퍼 응용: 정체성·데이터 흐름·환경값으로 결과 추적하기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5699, 920, '아래 코드에서 버튼을 순서대로 눌렀을 때 두 카운터 버튼에 표시되는 값으로 옳은 것은?', '화면이 처음 뜬 뒤 버튼을 위 카운터 2번 → 아래 카운터 2번 → 다음 사용자 1번 → 위 카운터 1번 → 아래 카운터 1번 순서로 눌렀다.

```swift
struct TapCounter: View {
    let title: String
    @State private var taps = 0

    var body: some View {
        Button("\(title) \(taps)") { taps += 1 }
    }
}

struct ProfileScreen: View {
    @State private var userID = 1

    var body: some View {
        VStack {
            TapCounter(title: "위")
            TapCounter(title: "아래")
                .id(userID)
            Button("다음 사용자") { userID += 1 }
        }
    }
}
```', 'OBJECTIVE'),
       (5700, 920, '아래 표의 (가)~(다) 자리에 붙일 선언으로 옳은 조합은?', '설정 화면 SettingsScreen과 그 자식 뷰 두 개에서 상태를 어떻게 선언할지 정리한 표다.

| 자리 | 선언하는 뷰 | 담는 것 | 값의 출처 | 이 뷰에서 하는 일 |
|---|---|---|---|---|
| (가) | SettingsScreen | SettingsViewModel (ObservableObject를 채택한 클래스) | 이 뷰가 처음 생성 | 화면이 떠 있는 동안 같은 인스턴스를 들고 구독 |
| (나) | NotificationRow | 알림 켜기 여부 (Bool) | 부모 SettingsScreen의 @State | 토글로 값을 바꾸고, 부모 화면에도 곧바로 반영돼야 함 |
| (다) | NameLabel | 사용자 이름 (String) | 부모 SettingsScreen의 @State | 읽어서 표시만 하며, 이 뷰가 값을 바꿀 수 없어야 함 |', 'OBJECTIVE'),
       (5701, 920, '아래 뷰모델 설계에서 나타나는 현상으로 옳은 것은?', '검색 화면의 뷰모델 SearchViewModel은 ObservableObject를 채택한 클래스다. 검색 결과 배열 results 말고도 정렬 메뉴 펼침 여부 isSortMenuOpen, 필터 시트 표시 여부 isFilterShown까지 모두 @Published로 담았다. 화면 루트가 이 뷰모델을 @StateObject로 만들고, 검색창·정렬 버튼·결과 목록(수백 개 행) 세 하위 뷰에 넘겨 각각 @ObservedObject로 구독하게 했다.', 'OBJECTIVE'),
       (5702, 920, '아래 코드를 실행했을 때 세 라벨에 표시되는 내용으로 옳은 것은?', '기기는 라이트 모드로 설정돼 있다.

```swift
struct ModeLabel: View {
    let name: String
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Text("\(name): \(scheme == .dark ? "다크" : "라이트")")
    }
}

struct ThemeDemo: View {
    var body: some View {
        VStack {
            ModeLabel(name: "A")
            VStack {
                ModeLabel(name: "B")
                ModeLabel(name: "C")
                    .environment(\.colorScheme, .light)
            }
            .environment(\.colorScheme, .dark)
        }
    }
}
```', 'OBJECTIVE'),
       (5703, 920, '아래 상황에서 isFavorite 선언 앞에 붙여 문제를 해결한 프로퍼티 래퍼의 이름은?', '상품 상세 화면의 뷰모델 ProductViewModel은 ObservableObject를 채택한 클래스이고, 화면 루트가 @StateObject로 들고 있다. 뷰모델의 리뷰 목록 reviews는 불러오는 즉시 화면에 반영됐다. 그런데 하트 버튼을 눌러 vm.isFavorite.toggle()을 호출하면 하트 아이콘이 빈 모양 그대로였다. 중단점을 걸어 보니 isFavorite는 이미 true였고, 리뷰 목록을 새로고침하자 그제야 하트가 채워진 모양으로 바뀌었다. isFavorite 선언 앞에 래퍼 하나를 붙이자 누르는 즉시 하트가 바뀌었다.', 'SUBJECTIVE'),
       (5704, 920, '아래 상황에서 ProfileBadge가 세션 객체를 받으려고 붙인 프로퍼티 래퍼의 이름은?', '로그인 세션 UserSession은 ObservableObject를 채택한 클래스로, 앱 루트에서 @StateObject로 만든다. 처음에는 이 객체를 HomeView → FeedView → PostRow → ProfileBadge 순으로 이니셜라이저 인자로 넘겼는데, 중간의 세 뷰는 세션을 쓰지도 않으면서 인자를 받아 다음 뷰에 넘기기만 했다. 리팩터링하면서 중간 세 뷰의 세션 인자를 모두 지우고, 세션을 실제로 쓰는 ProfileBadge만 선언 앞의 래퍼를 바꿨다. 앱을 실행하면 정상 동작했지만, ProfileBadge 하나만 띄운 프리뷰는 아래 오류를 내고 멈췄다.

```
Fatal error: No ObservableObject of type UserSession found.
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5699
(15371, 5699, '위 3 / 아래 3', '.id를 이름표일 뿐 상태와 무관하다고 본 오해다. id 값이 1에서 2로 바뀌면 SwiftUI는 아래 카운터를 다른 뷰로 보고 기존 저장소를 버린 뒤 taps = 0인 새 저장소를 만든다.', false),
(15372, 5699, '위 1 / 아래 1', '부모가 다시 평가돼 뷰 값이 새로 만들어지면 @State도 초기화된다고 본 오해다. 상태는 뷰 값이 아니라 정체성에 묶여 있어, 자리가 그대로인 위 카운터는 taps 2를 유지한다.', false),
(15373, 5699, '위 3 / 아래 1', '위 카운터는 정체성이 그대로라 2에 1을 더해 3이 된다. 아래 카운터는 userID가 바뀌며 .id 값이 달라져 새 뷰로 취급되고, taps가 0부터 다시 시작해 한 번 눌러 1이 된다.', true),
(15374, 5699, '위 1 / 아래 3', '.id를 붙인 뷰만 정체성이 고정되고 나머지는 매번 새로 만들어진다고 거꾸로 본 오해다. id가 없는 뷰도 구조상 자리로 정체성이 유지되고, id를 붙인 뷰는 그 값이 바뀌는 순간 새 뷰가 된다.', false),

-- 문제 5700
(15375, 5700, '(가) @StateObject, (나) @Binding, (다) 일반 let 프로퍼티', '객체를 처음 만드는 뷰는 @StateObject로 정체성 수명 동안 한 번만 생성해 보관한다. 부모 값을 바꿔야 하는 자식은 @Binding으로 원본 저장소를 가리키고, 읽기만 하는 자식은 let으로 받아 쓰기 통로를 열지 않는다.', true),
(15376, 5700, '(가) @ObservedObject, (나) @Binding, (다) 일반 let 프로퍼티', '(가)를 @ObservedObject로 두면 객체를 소유하지 않아 초기값 표현식이 뷰 값이 만들어질 때마다 실행되고 뷰모델이 새 인스턴스로 바뀐다. 객체를 처음 만드는 자리와 전달받는 자리를 혼동한 오해다.', false),
(15377, 5700, '(가) @StateObject, (나) @State, (다) @Binding', '(나)를 @State로 받으면 부모 값을 복사한 별도 저장소가 생겨 토글 결과가 부모에 닿지 않는다. (다)를 @Binding으로 받으면 쓰기 통로가 열려 값을 바꿀 수 없어야 한다는 조건을 어긴다. 쓰기와 읽기 역할을 뒤바꾼 오해다.', false),
(15378, 5700, '(가) @ObservedObject, (나) @State, (다) 일반 let 프로퍼티', '(가)는 객체를 처음 만드는 자리인데 구독 전용 래퍼를 써서 인스턴스가 계속 교체되고, (나)는 값을 복사해 자기 저장소에 담으니 부모 화면에 반영되지 않는다. 소유와 참조를 모두 거꾸로 고른 조합이다.', false),

-- 문제 5701
(15379, 5701, '필터 시트 표시 여부는 뷰모델 안에 있어 바인딩을 꺼낼 수 없으므로 .sheet(isPresented:)에 연결하지 못한다.', '@ObservedObject로 받은 뷰모델은 $vm.isFilterShown처럼 프로퍼티의 바인딩을 꺼내 .sheet에 넘길 수 있다. 바인딩은 뷰의 @State에서만 나온다고 본 오해다.', false),
(15380, 5701, '정렬 메뉴를 펼치기만 해도 results를 읽는 결과 목록 뷰의 body까지 함께 다시 평가된다.', '@Published 값 하나가 바뀌어도 나가는 신호는 객체 전체의 objectWillChange 하나라, 이 객체를 구독하는 뷰는 어떤 프로퍼티를 읽든 모두 다시 평가된다. 그래서 순수 UI 상태는 @State로 뷰에 두고 뷰모델엔 도메인 상태만 담는다.', true),
(15381, 5701, '메뉴 펼침 여부 같은 Bool 값은 클래스 안에 두면 바뀌어도 뷰가 알아채지 못해 메뉴가 열리지 않는다.', '@Published가 붙은 프로퍼티는 값이 바뀔 때 objectWillChange를 발행해 구독 중인 뷰를 갱신한다. 클래스 인스턴스를 @State에 담았을 때 변경을 못 알아채는 문제를 이 설계에 잘못 옮겨 붙인 오해다.', false),
(15382, 5701, '메뉴 펼침 여부가 바뀔 때마다 하위 뷰에 넘어간 뷰모델이 새 인스턴스로 바뀌어 results가 비워진다.', '뷰모델은 화면 루트가 @StateObject로 한 번만 만들어 보관하므로, 하위 뷰가 @ObservedObject로 받아도 같은 인스턴스를 가리킨다. 선언부에서 객체를 직접 만든 @ObservedObject의 재생성 문제와 혼동한 오해다.', false),

-- 문제 5702
(15383, 5702, 'A: 다크 / B: 다크 / C: 라이트', '안쪽 VStack에 붙인 덮어쓰기가 바깥으로도 퍼져 화면 전체가 바뀐다고 본 오해다. 환경값은 상위에서 하위로만 흐르므로, 수식어를 붙인 VStack 바깥의 A는 기기 설정인 라이트를 그대로 읽는다.', false),
(15384, 5702, 'A: 라이트 / B: 다크 / C: 다크', '바깥에서 정한 값이 안쪽의 덮어쓰기보다 우선한다고 본 오해다. 뷰는 자기에게서 가장 가까운 설정을 읽으므로, C는 자기에게 직접 붙은 .environment(\.colorScheme, .light)의 라이트를 읽는다.', false),
(15385, 5702, 'A: 라이트 / B: 라이트 / C: 라이트', 'colorScheme 같은 시스템 환경값은 기기 설정만 따르고 수식어로는 바꿀 수 없다고 본 오해다. .environment(\.키, 값)은 시스템 키든 커스텀 키든 그 아래 트리 전체의 값을 덮어쓴다.', false),
(15386, 5702, 'A: 라이트 / B: 다크 / C: 라이트', 'A는 덮어쓰기가 없어 기기 설정인 라이트, B는 감싼 VStack의 다크를 물려받는다. C는 다크 안에 있지만 자기에게 붙은 수식어가 더 가까워 라이트로 다시 덮어쓴다. 환경값은 아래로만 흐르고 가까운 설정이 이긴다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1856, 5703, '@Published,Published,퍼블리시드', 'ObservableObject를 채택한 클래스는 @Published가 붙은 프로퍼티가 바뀔 때 objectWillChange를 발행하고, 이 신호를 구독한 뷰가 body를 다시 평가한다. isFavorite에는 래퍼가 없어 값은 바뀌어도 신호가 나가지 않았다. 그러다 @Published가 붙은 reviews가 새로고침으로 바뀌어 신호가 나가자 body가 다시 평가되면서 그제야 최신 isFavorite를 읽어 하트가 바뀐 것이다. 옆 개념과 경계를 잡아 두자. ObservableObject는 발행 통로를 제공하는 프로토콜로 이미 채택돼 있었고, @StateObject·@ObservedObject는 이 객체를 뷰에 연결하는 래퍼라 이미 연결된 상태였다. @State는 뷰가 소유하는 값 타입 지역 상태용이라 클래스의 프로퍼티에 붙이는 해법이 아니다.'),
       (1857, 5704, '@EnvironmentObject,EnvironmentObject,인바이런먼트오브젝트,인바이런먼트 오브젝트,환경 객체', '상위에서 .environmentObject(_:)로 넣어 둔 참조 객체를 하위 뷰가 타입으로 꺼내 쓰게 하는 래퍼가 @EnvironmentObject다. 중간 뷰가 인자를 받아 넘기기만 하던 프로퍼티 드릴링이 사라진 것이 본문의 효과다. 조회가 타입만으로 이뤄져 주입 여부를 컴파일러가 확인하지 못하므로, 앱 루트를 거치지 않는 프리뷰에서는 UserSession 객체를 찾지 못해 실행이 멈춘다. 프리뷰에도 .environmentObject(UserSession())를 붙이면 해결된다. 옆 개념과 경계를 잡아 두자. @ObservedObject는 인자로 직접 넘겨받은 객체를 구독하므로 중간 인자를 지울 수 없고, @Environment는 키 경로로 식별되는 값을 읽는 래퍼다(iOS 17+ @Observable 객체라면 @Environment(Type.self)로 받는다). @StateObject는 객체를 처음 만드는 앱 루트 쪽에 붙는다.');
