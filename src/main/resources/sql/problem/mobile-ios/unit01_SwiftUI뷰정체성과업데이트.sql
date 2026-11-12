-- Unit: SwiftUI 뷰 정체성과 업데이트 (Unit ID: 177)
-- Chapter: iOS (Chapter ID: 17)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (603, 177, '구조적·명시적 정체성과 상태 초기화'),
       (761, 177, 'body 재평가 비용과 State 초기값'),
       (919, 177, 'SwiftUI 뷰 갱신 추적과 정체성 유지');

-- =====================================================
-- Lesson 603: 구조적·명시적 정체성과 상태 초기화
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3797, 603, '아래 두 코드에서 isExpanded 값이 바뀔 때 나타나는 동작 차이로 옳은 것은?', 'CardView는 내부에 `@State private var draft = ""`를 두고 사용자가 입력하던 임시 메모를 보관한다.

```swift
// A
if isExpanded {
    CardView().frame(height: 200)
} else {
    CardView().frame(height: 80)
}

// B
CardView().frame(height: isExpanded ? 200 : 80)
```', 'OBJECTIVE'),
       (3798, 603, '아래 화면에서 검색어를 한 글자 입력했을 때 일어나는 일로 옳은 것은?', '```swift
struct RootView: View {
    @State private var query = ""
    @State private var isOn = false

    var body: some View {
        VStack {
            TextField("검색", text: $query)
            Toggle("설정", isOn: $isOn)
            HeavyChart(points: samplePoints)
        }
    }
}
```

samplePoints는 앱이 실행되는 내내 바뀌지 않는 상수 배열이다. HeavyChart는 points만 프로퍼티로 갖는 일반 구조체 뷰이며, Equatable을 채택하거나 .equatable()을 붙이지는 않았다.', 'OBJECTIVE'),
       (3799, 603, '아래 목록에서 첫 번째 항목을 지웠을 때 나타난 증상의 원인으로 옳은 것은?', '```swift
struct RowView: View {
    let item: Item
    @State private var isChecked = false   // 행마다 따로 보관하는 체크 표시
    var body: some View { ... }
}

ForEach(items.indices, id: \.self) { i in
    RowView(item: items[i])
}
```

증상: 항목 다섯 개 가운데 세 번째 행만 체크해 둔 상태에서 첫 번째 항목을 삭제했다. 삭제 뒤에도 체크 표시는 여전히 위에서 세 번째 행에 남아 있었는데, 그 자리에는 원래 네 번째였던 항목이 올라와 있었다.', 'OBJECTIVE'),
       (3800, 603, '아래 비교표에서 따라 나오는 설명으로 옳지 않은 것은?', '| 항목 | UIKit의 UIView (클래스) | SwiftUI의 View (구조체) |
| --- | --- | --- |
| 정체 | 화면에 존재하는 객체 | 화면을 기술한 값 |
| 수명 | 개발자가 생성·제거를 관리 | 프레임워크가 필요할 때마다 새로 생성 |
| 상태 보관 | 인스턴스 프로퍼티에 직접 저장 | 뷰 밖 프레임워크 저장소에 두고 래퍼로 참조 |
| 갱신 방식 | 프로퍼티를 직접 바꿈 | 상태가 바뀌면 body를 다시 계산 |', 'OBJECTIVE'),
       (3801, 603, '아래 상황에서 댓글 초안이 사라지고 onAppear가 다시 호출된 원인을 가리키는 SwiftUI 개념의 이름은?', '목록 화면은 상세 화면을 아래처럼 띄운다.

```swift
DetailView(post: post).id(refreshToken)
```

당겨서 새로고침할 때마다 refreshToken에 새 UUID를 넣도록 했다. 그 뒤로 상세 화면에서 댓글을 절반쯤 쓰다가 목록을 새로고침하면 쓰던 초안이 매번 빈칸으로 돌아갔고, onAppear에 넣어 둔 조회 기록도 새로고침마다 한 번씩 다시 남았다.', 'SUBJECTIVE'),
       (3802, 603, '아래 로그가 찍히던 화면에서 증상을 없애려고 바꿔 붙인 프로퍼티 래퍼의 이름은?', '주문 상세 화면은 ObservableObject를 채택한 OrderViewModel을 화면 안에서 직접 만들어 프로퍼티로 갖고 있다. 조회가 끝나면 뷰모델이 알리는 변화에 맞춰 목록이 화면에 나타나야 한다. 이 화면을 띄운 부모 화면에는 결제 마감까지 남은 시간이 1초마다 갱신되는 표시가 있다.

앱을 열어 둔 채 지켜보자 콘솔에 아래 로그가 1초 간격으로 계속 쌓였다.

```
[OrderViewModel] init
[OrderViewModel] fetchOrder 요청 전송
[OrderViewModel] init
[OrderViewModel] fetchOrder 요청 전송
```

뷰모델에 담아 둔 배송 메모 입력값도 1초마다 빈칸으로 되돌아갔다. 화면이 갱신되는 동작은 그대로 둔 채 뷰모델 프로퍼티 앞의 래퍼만 바꾸자, fetchOrder 요청은 화면을 열 때 한 번으로 줄었고 메모도 그대로 남았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3797
(10299, 3797, 'A와 B 모두 CardView가 그대로 이어지므로 withAnimation을 걸면 높이가 똑같이 부드럽게 변한다.', 'A는 분기가 뒤바뀌는 순간 이전 뷰가 제거되고 새 뷰가 생기므로 높이 값이 이어지지 않는다. 높이가 연속으로 변하는 애니메이션은 같은 뷰의 속성만 바뀌는 B에서 나온다.', false),
(10300, 3797, 'A에서는 분기가 뒤바뀔 때 CardView가 제거되고 새로 생겨 draft가 빈 문자열로 돌아간다.', 'if의 두 분기는 뷰 트리에서 서로 다른 자리라 정체성이 다르다. 정체성이 바뀌면 그 뷰에 매달려 있던 @State 저장소도 함께 버려져 초기값부터 다시 시작한다.', true),
(10301, 3797, 'B에서는 frame에 넘긴 값이 달라질 때마다 CardView가 새 정체성을 얻어 draft가 초기화된다.', '모디파이어 인자가 달라진 것은 같은 뷰의 속성이 바뀐 것일 뿐이다. 타입과 뷰 트리에서의 자리가 그대로라 정체성이 유지되고 @State도 남는다.', false),
(10302, 3797, 'A는 두 분기가 화면상 같은 위치에 그려지므로 SwiftUI가 하나의 CardView로 합쳐 재사용한다.', '정체성은 화면 좌표가 아니라 뷰 트리에서의 경로로 정해진다. if와 else는 서로 다른 경로여서 겉보기 위치가 같아도 한 뷰로 합쳐지지 않는다.', false),

-- 문제 3798
(10303, 3798, 'query를 읽는 TextField만 무효화되고 RootView의 body는 다시 계산되지 않는다.', '무효화 단위는 화면 요소가 아니라 그 상태를 body에서 읽은 뷰다. query를 실제로 읽은 쪽은 RootView이므로 타이핑마다 RootView의 body가 다시 계산된다.', false),
(10304, 3798, 'HeavyChart는 값이 새로 만들어지지 않고 앞서 화면에 올라간 인스턴스가 그대로 재사용된다.', '뷰를 화면에 남아 있는 객체로 본 오해다. 뷰는 구조체 값이라 부모 body가 다시 계산되면 자식 뷰 값도 그때마다 새로 만들어진다.', false),
(10305, 3798, 'HeavyChart 값은 새로 만들어지지만 points가 이전과 같으므로 body 호출은 자동으로 건너뛰어진다.', '입력이 같으면 프레임워크가 알아서 생략해 준다고 본 오해다. 값 비교로 body를 막으려면 뷰가 Equatable을 채택하고 사용처에 .equatable()을 붙여야 하는데, 본문의 HeavyChart는 그 조건을 갖추지 않았다.', false),
(10306, 3798, 'RootView의 body가 다시 계산되면서 HeavyChart 값이 새로 만들어지고 그 body까지 다시 호출된다.', 'query를 읽은 뷰가 RootView라 타이핑마다 RootView가 무효화된다. 자식 뷰 값은 부모 body에서 매번 새로 만들어지고, Equatable을 채택하지 않은 HeavyChart는 points가 같아도 body 호출이 건너뛰어지지 않는다.', true),

-- 문제 3799
(10307, 3799, '행의 정체성이 배열 인덱스에 묶여 있어, 삭제로 번호가 당겨지면서 체크 상태가 다른 항목에 붙었다.', '인덱스를 id로 쓰면 정체성이 항목이 아니라 자리에 붙는다. 앞이 하나 빠져 항목이 한 칸씩 당겨져도 세 번째 자리의 정체성은 그대로 살아 있어, 그 자리에 새로 올라온 항목이 앞서 저장된 @State를 물려받는다.', true),
(10308, 3799, 'RowView가 구조체라서 삭제 과정에서 뷰 값이 복사될 때 isChecked까지 이웃 행으로 복사됐다.', '@State 값은 뷰 값 안이 아니라 프레임워크 저장소에 있고 정체성으로 찾아 쓴다. 뷰 값이 복사된다고 해서 상태가 함께 옮겨 가지는 않는다.', false),
(10309, 3799, 'items가 Identifiable을 채택하지 않아 ForEach가 모든 행을 새로 만들면서 상태가 섞였다.', '모든 행이 새로 만들어졌다면 남은 행의 체크 표시가 전부 사라졌어야 한다. 체크가 같은 자리에 남아 엉뚱한 항목에 붙은 것은 정체성이 항목이 아니라 인덱스에 매여 있다는 신호다. id를 직접 준 이상 Identifiable 채택 여부는 문제가 아니다.', false),
(10310, 3799, '삭제로 배열이 줄어드는 동안 ForEach가 이전 항목 수만큼 뷰를 남겨 화면이 한 칸 밀려 보인 것이다.', 'ForEach는 갱신된 배열을 기준으로 항목 집합을 다시 만들어 개수는 곧바로 줄어든다. 어긋난 것은 항목 수가 아니라 상태가 매달려 있는 정체성이다.', false),

-- 문제 3800
(10311, 3800, '화면이 그대로 떠 있는 동안에도 같은 SwiftUI 뷰의 초기화 구문이 여러 번 실행될 수 있다.', '참이다. 뷰 값은 프레임워크가 갱신할 때마다 새로 만드는 것이라 init이 반복 호출된다. 그래서 init 안에서 무거운 객체를 만들면 갱신마다 다시 만들어진다.', false),
(10312, 3800, 'SwiftUI에서 뷰 값 생성은 자주 일어나므로 값 자체가 가볍게 복사될 수 있어야 한다.', '참이다. 필요할 때마다 새로 만든다는 수명 특성에서 곧바로 따라 나온다. 구조체 값 복사가 저렴하기 때문에 잦은 재생성을 감당할 수 있다.', false),
(10313, 3800, 'SwiftUI에서도 만들어 둔 뷰 값을 붙잡아 두었다가 그 프로퍼티를 직접 바꿔 화면을 갱신할 수 있다.', '거짓이다. 표의 갱신 방식대로 SwiftUI는 상태가 바뀌면 body를 다시 계산해 화면을 바꾼다. 붙잡아 둔 뷰 값은 다음 갱신에서 버려지므로 프로퍼티를 바꿔도 화면에 닿지 않는다.', true),
(10314, 3800, 'SwiftUI에서 화면이 갱신된 뒤에도 남아야 하는 입력값은 뷰의 저장 프로퍼티가 아니라 상태 래퍼에 맡겨야 한다.', '참이다. 상태 보관 행에서 따라 나온다. 뷰 값이 매번 새로 만들어지므로 저장 프로퍼티에 담아 둔 값은 갱신과 함께 초기값으로 되돌아간다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1222, 3801, '정체성,뷰 정체성,identity,view identity,아이덴티티,명시적 정체성,explicit identity', 'SwiftUI는 이전 갱신의 뷰와 지금의 뷰가 같은 뷰인지를 정체성으로 판단한다. .id()에 넘긴 값이 달라지면 타입과 자리가 같아도 다른 뷰로 보아 이전 뷰를 버리고 새로 만들기 때문에, 그 뷰에 매달려 있던 @State가 초기값으로 돌아가고 onAppear도 처음처럼 다시 호출된다. body 재평가와 구분해야 한다. 재평가는 정체성을 유지한 채 body만 다시 계산하는 일이라 @State가 살아남지만, 정체성이 바뀌면 상태의 수명 자체가 끊긴다.'),
       (1223, 3802, '@StateObject,StateObject,스테이트오브젝트,스테이트 오브젝트', '부모 화면이 1초마다 다시 계산되면 자식 뷰 값도 그때마다 새로 만들어지고, 프로퍼티 초기식에 적어 둔 OrderViewModel()도 함께 다시 실행된다. @ObservedObject는 객체를 붙들어 두지 않고 넘겨받은 객체를 구독만 하므로, 뷰 안에서 직접 만든 객체는 갱신마다 새것으로 갈린다. 그래서 init과 조회가 반복되고 객체에 담아 둔 입력값도 함께 사라진다. @StateObject로 선언하면 초기식이 그 뷰 정체성에서 한 번만 평가되고 프레임워크 저장소가 객체를 붙들고 있어, 이후 갱신에서는 앞서 만든 객체가 그대로 다시 연결된다. 구독은 그대로 이뤄지므로 조회가 끝났을 때 화면이 갱신되는 동작은 유지된다. 뷰가 객체를 소유하면 @StateObject, 바깥에서 받아 관찰만 하면 @ObservedObject로 나눠 쓴다. 값 타입 상태를 뷰에 매어 두는 @State와도 구분한다. 다만 @StateObject가 붙든 객체도 수명은 뷰 정체성에 묶여 있어, .id()가 바뀌는 등으로 정체성이 끊기면 객체 역시 버려지고 새로 만들어진다.');

-- =====================================================
-- Lesson 761: body 재평가 비용과 State 초기값
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4745, 761, '아래 화면에서 저장 버튼을 한 번 눌렀을 때 일어나는 일로 옳은 것은?', '```swift
struct ProfileView: View {
    @State private var nickname = "이수민"
    @State private var lastSavedAt: Date? = nil

    var body: some View {
        VStack {
            Text("닉네임: \(nickname)")
            Button("저장") { lastSavedAt = .now }
        }
    }
}
```

lastSavedAt은 화면을 닫을 때 서버로 함께 보내려고 들고 있는 값이다. 저장 버튼을 한 번 눌러 이 값만 nil에서 현재 시각으로 바뀌었고, nickname은 건드리지 않았다.', 'OBJECTIVE'),
       (4746, 761, '아래 화면에서 검색어를 한 글자 칠 때마다 화면이 멈추는 원인으로 옳은 것은?', '```swift
struct ReportView: View {
    let rows: [Row]
    @State private var keyword = ""

    var body: some View {
        let ranked = rows.sorted { $0.amount > $1.amount }
        VStack {
            TextField("검색", text: $keyword)
            List(ranked.filter { $0.title.contains(keyword) }) { row in
                Text(row.title)
            }
        }
    }
}
```

rows는 50,000건이고 화면이 떠 있는 동안 바뀌지 않는다. 계측해 보니 정렬 한 번에 0.38초가 걸렸고, 검색어를 한 글자 입력할 때마다 화면이 0.4초씩 멈췄다.', 'OBJECTIVE'),
       (4747, 761, '아래 화면에서 기본 수량을 바꿔도 수량 표시가 따라 바뀌지 않는 이유로 옳은 것은?', '```swift
struct QuantityBox: View {
    @State private var value: Int

    init(initial: Int) {
        _value = State(initialValue: initial)
    }

    var body: some View {
        Stepper("수량 \(value)", value: $value, in: 1...99)
    }
}

struct OrderView: View {
    @State private var preset = 1

    var body: some View {
        VStack {
            Picker("기본 수량", selection: $preset) {
                Text("1개").tag(1)
                Text("5개").tag(5)
                Text("10개").tag(10)
            }
            QuantityBox(initial: preset)
        }
    }
}
```

화면을 처음 열면 수량이 1로 보인다. Picker에서 5개를 고르면 QuantityBox(initial: 5)가 실행되는데도 수량 표시는 계속 1에 머물렀다.', 'OBJECTIVE'),
       (4748, 761, '아래 표에서 따라 나오는 설명으로 옳지 않은 것은?', '| 정체성 종류 | 무엇으로 정해지나 | 달라졌을 때 |
| --- | --- | --- |
| 구조적 정체성 | 뷰의 타입과 뷰 트리에서의 자리 | 이전 뷰를 제거하고 새 뷰를 만든다 |
| 명시적 정체성 | ForEach에 준 id, .id()에 넘긴 값 | 자리가 같아도 서로 다른 뷰로 본다 |', 'OBJECTIVE'),
       (4749, 761, '아래 상황에서 차트 뷰에 채택한 프로토콜의 이름은?', '지출 화면은 위쪽에 금액 입력 칸을 두고 아래쪽에 한 달 치 지출을 그리는 SpendingChart를 둔다. SpendingChart가 받는 지출 배열은 입력 칸과 아무 관련이 없어 화면이 떠 있는 동안 늘 같은 값이었는데도, 금액을 한 글자 칠 때마다 SpendingChart의 body 진입 로그가 그대로 찍혔다.

차트 뷰에 프로토콜 하나를 채택하고 사용처에는 짝이 되는 모디파이어를 붙였다. 그러자 지출 배열이 그대로인 동안에는 body 진입 로그가 더 이상 찍히지 않았고, 금액 입력이 화면에 반영되기까지 걸리는 시간도 300ms에서 16ms로 줄었다.', 'SUBJECTIVE'),
       (4750, 761, '아래 상황에서 조회 수 요청을 옮겨 붙인 뷰 모디파이어의 이름은?', '강의 상세 화면은 열릴 때 조회 수 올리기 요청을 한 번만 보내야 한다. 처음에는 요청하는 줄을 body 안에 그냥 두었더니, 화면에서 좋아요를 누르거나 글자 크기를 바꾸기만 해도 조회 수가 계속 올라갔다. 요청 함수는 완료 핸들러를 받는 동기 함수라 async 컨텍스트가 필요하지는 않았다.

이 줄을 뷰에 붙인 어떤 모디파이어의 클로저 안으로 옮기자 조회 수는 화면을 띄울 때 한 번만 올라갔고, 목록으로 나갔다가 같은 강의를 다시 열면 그때 한 번 더 올라갔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4745
(12827, 4745, '뷰가 가진 @State 가운데 하나가 바뀌었으므로 ProfileView의 body가 처음부터 다시 계산된다.', '무효화는 뷰가 어떤 상태를 가졌는지가 아니라 body를 계산하는 동안 무엇을 읽었는지로 정해진다. lastSavedAt은 body 어디에서도 읽히지 않아 의존성 목록에 올라가지 않는다.', false),
(12828, 4745, 'lastSavedAt은 body를 계산하는 동안 읽히지 않으므로 ProfileView는 무효화되지 않고 body도 다시 계산되지 않는다.', '의존성은 body가 평가되는 동안 실제로 읽은 상태로만 만들어진다. 이 값을 읽는 뷰가 하나도 없으니 값이 바뀌어도 화면을 다시 계산할 이유가 없다. 저장 시각을 화면에 표시하도록 고치는 순간 의존성이 생겨 재평가가 시작된다.', true),
(12829, 4745, 'body가 다시 계산되면서 Text가 새로 만들어져 nickname이 선언할 때 적어 둔 값으로 되돌아간다.', '재평가를 상태 초기화로 오해한 것이다. 재평가는 뷰 값을 다시 만드는 일일 뿐이고, @State 저장소는 정체성이 유지되는 동안 살아남아 최근 값을 계속 내어 준다.', false),
(12830, 4745, 'lastSavedAt을 읽는 곳이 없으므로 대입 자체가 무시되어 값은 계속 nil로 남는다.', '의존성이 없다는 것과 값이 저장되지 않는다는 것은 다르다. 대입은 프레임워크 저장소에 정상적으로 반영되며, 다만 그 값을 읽는 뷰가 없어 화면 갱신만 일어나지 않는다.', false),

-- 문제 4746
(12831, 4746, 'rows가 상수라 값은 그대로인데도 List가 갱신마다 50,000개 행 뷰를 모두 만들어 올리기 때문이다.', '멈춤의 원인을 뷰 값 생성 비용으로 본 오해다. List는 화면에 보이는 범위의 행만 만들고 구조체 뷰 값 생성은 매우 저렴하다. 계측에서 0.38초를 쓴 쪽은 행 생성이 아니라 정렬이다.', false),
(12832, 4746, 'keyword가 바뀔 때마다 ReportView의 정체성이 새로 생겨 화면이 처음부터 다시 만들어지기 때문이다.', '상태 변경을 정체성 변경으로 본 오해다. 타입과 뷰 트리에서의 자리가 그대로면 정체성은 이어진다. 정체성이 끊겼다면 keyword까지 빈 문자열로 돌아가 검색어를 이어 칠 수 없었을 것이다.', false),
(12833, 4746, 'TextField가 keyword를 바꾸면 무효화가 뷰 트리 위쪽으로 번져 앱 화면 전체의 body가 다시 계산되기 때문이다.', '무효화가 조상 쪽으로 거슬러 올라간다고 본 오해다. 무효화는 그 상태를 읽은 뷰에서 시작해 아래로 내려간다. 게다가 여기서 시간을 잡아먹는 것은 재평가 범위가 아니라 body 안의 정렬이다.', false),
(12834, 4746, 'keyword를 읽는 ReportView의 body가 글자마다 다시 계산되고, 그때마다 50,000건 정렬이 처음부터 다시 실행되기 때문이다.', 'TextField가 keyword를 바꾸면 그 값을 읽은 ReportView가 무효화돼 body가 다시 계산된다. 정렬은 body 첫 줄에 있어 재평가마다 되풀이되고, 0.38초짜리 작업이 글자마다 얹혀 0.4초 멈춤으로 나타난다. 정렬 결과는 body 밖에 두고 캐시해야 한다.', true),

-- 문제 4747
(12835, 4747, 'QuantityBox의 정체성이 그대로 이어져 먼저 만들어진 @State 저장소가 살아 있고, 다시 실행된 init의 초기값은 쓰이지 않기 때문이다.', '@State의 수명은 뷰 값이 아니라 정체성에 묶인다. 타입과 뷰 트리에서의 자리가 그대로라 정체성이 이어지고, 저장소는 처음 담은 1을 계속 내어 준다. init에 적은 초기값은 저장소가 아직 없을 때만 쓰인다. 부모 값을 따라가려면 @Binding으로 받아야 한다.', true),
(12836, 4747, '뷰가 구조체라서 새 초기값이 복사본에만 들어가고 화면에 올라가 있는 원래 인스턴스는 그대로 남기 때문이다.', '화면에 뷰 인스턴스가 상주한다고 본 오해다. 뷰 값은 갱신마다 새로 만들어지고 화면에 남는 것은 프레임워크가 관리하는 렌더 트리다. 값 복사가 아니라 상태 저장소의 수명이 갈림길이다.', false),
(12837, 4747, 'preset이 바뀌어도 OrderView의 body는 다시 계산되지 않아 QuantityBox 값이 새로 만들어지지 않기 때문이다.', 'OrderView의 body가 $preset으로 그 값을 읽고 있으므로 선택이 바뀌면 무효화가 일어나 body는 다시 계산된다. QuantityBox(initial: 5)도 실제로 실행되며, 문제는 그 초기값이 이미 있는 저장소를 덮지 못한다는 점이다.', false),
(12838, 4747, 'preset이 바뀔 때마다 QuantityBox의 정체성이 새로 생겨 @State가 처음 값인 1로 되돌아가기 때문이다.', '정체성이 새로 생겼다면 그때 실행된 init의 초기값 5가 화면에 보였을 것이다. 1이 그대로인 것은 오히려 정체성이 이어져 예전 저장소가 살아 있다는 신호다. 일부러 초기화하려면 .id(preset)처럼 정체성을 갈아야 한다.', false),

-- 문제 4748
(12839, 4748, '뷰 값이 갱신마다 새로 만들어져도 정체성이 이어지는 동안에는 앞서 담아 둔 @State 값을 그대로 쓴다.', '참이다. 표는 정체성이 달라졌을 때만 이전 뷰를 제거한다고 말한다. 뒤집으면 정체성이 이어지는 동안에는 그 뷰에 매달린 상태 저장소도 함께 살아남는다는 뜻이 된다.', false),
(12840, 4748, '같은 타입의 뷰라도 if 분기와 else 분기에 하나씩 적어 두면 서로 다른 뷰로 취급된다.', '참이다. 구조적 정체성은 타입만이 아니라 뷰 트리에서의 자리까지 함께 보므로 두 분기는 서로 다른 뷰가 된다. 분기가 뒤바뀌면 이전 뷰가 제거되어 그 안에 있던 상태도 함께 사라진다.', false),
(12841, 4748, '.id()에 넘긴 값이 달라져도 뷰 트리에서의 자리가 그대로라면 같은 뷰로 이어져 @State가 유지된다.', '거짓이다. 명시적 정체성은 자리가 같아도 서로 다른 뷰로 보게 만든다. .id() 값이 바뀌는 순간 이전 뷰가 제거되고 새 뷰가 생겨 @State는 초기값으로 돌아간다. 화면을 일부러 비울 때 쓰는 성질이다.', true),
(12842, 4748, '목록에서 항목 순서만 뒤바뀌고 각 항목의 id가 그대로면 행 뷰를 새로 만들지 않고 자리만 옮긴다.', '참이다. id를 준 뒤에는 자리가 아니라 그 값이 같은 뷰인지를 정하므로, id가 유지되는 행은 위치가 바뀌어도 같은 뷰로 이어진다. 그래서 행에 담긴 상태와 이동 애니메이션이 항목을 따라간다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1538, 4749, 'Equatable,이퀘이터블,이퀘터블,Equatable 프로토콜', '부모 뷰의 body가 다시 계산되면 자식 뷰 값은 그때마다 새로 만들어지고, 입력이 이전과 같아 보여도 프레임워크가 알아서 body 호출을 건너뛰어 주지는 않는다. 뷰가 Equatable을 채택해 두 뷰 값을 어떻게 견줄지 알려 주고 사용처에 .equatable()을 붙이면, 같다고 판정된 갱신에서는 body 호출 자체가 생략된다. 그래서 지출 배열이 그대로인 동안 차트를 다시 그리는 비용이 사라지고 입력 반응이 빨라진다. 다만 비교 비용이 body보다 클 수 있어 정말 무거운 뷰에만 쓴다. 상태를 실제로 쓰는 하위 뷰로 내려보내는 방법과 구분해야 한다. 그쪽은 재평가가 시작되는 범위 자체를 좁히는 것이고, Equatable은 이미 시작된 갱신에서 자식의 body 호출을 막는 수단이다. 비교 규칙을 느슨하게 짜서 달라진 값을 같다고 판정하면 화면이 갱신되지 않는 버그가 되니 주의한다.'),
       (1539, 4750, 'onAppear,.onAppear,onAppear(perform:),온어피어', 'body는 상태가 바뀔 때마다 여러 번 다시 계산되므로 요청 전송 같은 부수 효과를 body 안에 두면 갱신 횟수만큼 반복된다. onAppear에 넘긴 클로저는 뷰의 정체성이 처음 생겨 화면에 나타날 때 실행되므로, 같은 화면이 여러 번 재평가돼도 다시 불리지 않는다. 목록으로 나갔다가 다시 들어오면 정체성이 새로 생기기 때문에 그때 한 번 더 실행된다. 즉 실행 횟수는 재평가 횟수가 아니라 정체성의 수명에 맞춰진다. 화면에서 사라질 때 정리 작업을 맡는 onDisappear와 짝이고, async 작업을 다루며 뷰가 사라지거나 id가 바뀌면 자동으로 취소되는 task와는 구분한다. 본문의 요청은 완료 핸들러를 받는 동기 함수라 task가 필요하지 않다.');

-- =====================================================
-- Lesson 919: SwiftUI 뷰 갱신 추적과 정체성 유지
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5693, 919, '아래 화면에서 버튼을 두 번 누르는 동안 일어난 일로 옳은 것은?', '```swift
struct NoticeBadge: View {
    @State private var unread = 3

    var body: some View {
        VStack {
            Text(unread > 0 ? "새 알림 있음" : "알림 없음")
            Button("하나 읽음") { unread -= 1 }
        }
    }
}
```

화면을 연 뒤 "하나 읽음" 버튼을 두 번 눌러 unread가 3에서 2로, 다시 1로 줄었다.', 'OBJECTIVE'),
       (5694, 919, '아래 로그에서 두 차트 가운데 DetailChart의 body만 글자마다 다시 계산된 원인으로 옳은 것은?', '```swift
struct ExpenseView: View {
    @State private var memo = ""
    let points: [Double]   // 화면이 떠 있는 동안 바뀌지 않는다

    var body: some View {
        let _ = print("ExpenseView body")
        VStack {
            TextField("메모", text: $memo)
            Text("\(memo.count)/100자")
            SummaryChart(points: points)
            DetailChart(points: points, onSelect: { index in
                print("선택한 막대: \(index)")
            })
        }
    }
}
```

SummaryChart와 DetailChart는 둘 다 Equatable을 채택하지 않은 구조체 뷰이고, 각자 body 첫 줄에서 ExpenseView처럼 자기 이름과 body를 출력한다. 메모 칸에 세 글자를 입력하는 동안 콘솔에는 아래 로그만 찍혔다.

```
ExpenseView body
DetailChart body
ExpenseView body
DetailChart body
ExpenseView body
DetailChart body
```', 'OBJECTIVE'),
       (5695, 919, '아래 네 목록에서 이름을 고친 뒤 두 번째 행만 접히고 첫 번째 행은 펼친 채 남는 목록은?', 'Tag는 서버가 준 고유 번호 id와 이름 name을 가진 구조체로 Identifiable을 채택했다. tags는 부모 화면의 @State 배열이고, TagRow는 `@State private var isExpanded = false`로 행마다 펼침 여부를 따로 보관한다. 같은 tags를 아래 네 가지 코드로 각각 그렸다.

| 목록 | 행을 만드는 코드 |
| --- | --- |
| 가 | `ForEach(tags.indices, id: \.self) { i in TagRow(tag: tags[i]) }` |
| 나 | `ForEach(tags, id: \.name) { tag in TagRow(tag: tag) }` |
| 다 | `ForEach(tags) { tag in TagRow(tag: tag) }` |
| 라 | `ForEach(tags) { tag in TagRow(tag: tag).id(UUID()) }` |

네 목록 모두 첫 번째 행(swift)과 두 번째 행(ios)을 펼쳐 둔 뒤, 두 번째 태그의 name을 ios에서 iOS로 고쳤다.', 'OBJECTIVE'),
       (5696, 919, '아래 두 방식에서 필터 패널을 감췄다가 다시 보이게 했을 때의 동작으로 옳은 것은?', '```swift
struct FilterPanel: View {
    @State private var minPrice = 0

    var body: some View {
        Stepper("최소 가격 \(minPrice)원", value: $minPrice, step: 10000)
            .onAppear { print("FilterPanel 등장") }
    }
}

// A
if showFilter {
    FilterPanel()
}

// B
FilterPanel()
    .opacity(showFilter ? 1 : 0)
```

A와 B 각각에서 패널이 보이는 상태로 최소 가격을 30,000원까지 올렸다. 그런 다음 showFilter를 false로 바꿔 패널을 감췄다가 다시 true로 바꿔 보이게 했다.', 'OBJECTIVE'),
       (5697, 919, '아래 상황에서 ChatModel 클래스 선언 바로 앞에 붙인 것의 이름은?', '채팅 화면의 ChatModel은 ObservableObject를 채택한 클래스로, `@Published var roomName`과 `@Published var unreadCount`를 갖는다. 화면 위쪽의 TitleBar는 이 모델을 `@ObservedObject`로 받아 roomName만 표시하고, unreadCount는 body에서 읽지 않는다. 그런데 새 메시지가 들어와 unreadCount가 1 늘 때마다 TitleBar의 body 진입 로그도 함께 찍혀, 메시지가 몰린 1분 동안 로그가 240번 쌓였다.

최소 지원 버전을 iOS 17로 올리면서 ObservableObject 채택과 @Published를 모두 지우고, ChatModel 클래스 선언 바로 앞에 한 줄을 붙였다. TitleBar에서는 @ObservedObject만 지우고 모델을 일반 프로퍼티로 받았다. 같은 조건으로 1분을 다시 재 보니 TitleBar 로그는 방 이름을 바꾼 순간에 한 번만 찍혔다.', 'SUBJECTIVE'),
       (5698, 919, '아래 상황에서 OrderView의 body 첫 줄에 넣은 메서드의 이름은?', '주문 화면 OrderView는 `@State private var memo`와 `@State private var quantity`를 갖고, body에서 메모 입력 칸과 함께 `Text("\(memo.count)/200자")`로 글자 수를 보여 준다. 메모를 입력할 때마다 화면이 버벅여서, body 첫 줄에 `let _ = ` 형태로 디버그 전용 호출을 한 줄 넣고 앱을 실행했다.

화면을 처음 열자 콘솔에 아래 첫 줄이 찍혔고, 메모 칸에 한 글자를 칠 때마다 둘째 줄이 한 번씩 더 찍혔다.

```
OrderView: @self, @identity, _memo, _quantity changed.
OrderView: _memo changed.
```

로그를 보고 memo와 글자 수 표시를 MemoField라는 하위 뷰로 옮기자, 메모를 입력해도 OrderView 줄은 더 이상 찍히지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5693
(15355, 5693, '표시할 문구가 그대로이므로 SwiftUI가 이를 미리 알아채고 body를 다시 계산하지 않는다.', '결과를 보고 다시 계산할지 정한다고 본 오해다. 의존성은 body가 평가되는 동안 읽은 상태로 정해지고, 삼항 연산자 조건에서 unread를 읽었으므로 값이 바뀔 때마다 body가 다시 계산된다. 문구가 같은지는 계산한 뒤에야 알 수 있다.', false),
(15356, 5693, 'body가 다시 계산될 때마다 Text가 화면에서 제거되고 새로 만들어져 문구가 한 번씩 깜빡인다.', 'body를 다시 계산하는 것을 화면을 다시 그리는 것으로 본 오해다. Text는 타입과 자리가 그대로라 정체성이 이어지고, 새 뷰 값을 이전 값과 비교해 달라진 부분만 렌더 트리에 반영하므로 제거·생성이 일어나지 않는다.', false),
(15357, 5693, 'body는 두 번 다시 계산되지만, 새로 만든 Text가 이전과 같아 화면에 반영되는 변경은 없다.', 'body에서 unread를 읽었으므로 값이 바뀔 때마다 body가 다시 계산된다. 하지만 2와 1 모두 0보다 커서 새 Text가 이전과 똑같고, 프레임워크는 이전 뷰 값과 비교해 달라진 부분만 반영하므로 렌더 트리는 그대로다.', true),
(15358, 5693, 'body가 다시 계산될 때마다 unread가 선언에 적어 둔 초기값 3으로 다시 설정된다.', '다시 계산을 상태 초기화로 본 오해다. @State 값은 뷰 값이 아니라 프레임워크 저장소에 있고 정체성이 이어지는 동안 유지된다. 선언에 적은 초기값은 저장소가 처음 만들어질 때만 쓰인다.', false),

-- 문제 5694
(15359, 5694, 'DetailChart에 넘기는 클로저가 부모 body가 계산될 때마다 새로 만들어져 입력이 같다고 판정되지 않기 때문이다.', '부모 body가 다시 계산되면 두 차트 값이 모두 새로 만들어지고, 입력이 이전과 같다고 판단된 자식은 body가 건너뛰어진다. points는 그대로지만 클로저는 매번 새로 만들어지고 서로 비교할 수도 없어 달라진 입력으로 취급된다.', true),
(15360, 5694, 'SummaryChart는 이전 뷰 값이 그대로 재사용되고, DetailChart만 뷰 값이 새로 만들어지기 때문이다.', '뷰 값을 재사용한다고 본 오해다. 부모 body가 다시 계산되면 두 차트 값 모두 새로 만들어진다. 갈린 것은 값 생성이 아니라 입력 비교 뒤 body를 건너뛰었는지이며, points만 받는 SummaryChart는 입력이 같아 건너뛰어졌다.', false),
(15361, 5694, 'DetailChart가 부모에게서 클로저를 받으면서 ExpenseView의 memo를 읽는 뷰로 함께 등록되기 때문이다.', '클로저를 받는 것을 상태를 읽는 것으로 본 오해다. 의존성은 body가 평가되는 동안 실제로 읽은 상태로만 생기는데, DetailChart의 body도 넘겨받은 클로저도 memo를 읽지 않는다. 다시 계산된 이유는 의존성이 아니라 달라진 입력이다.', false),
(15362, 5694, 'DetailChart의 정체성이 글자마다 새로 생겨, 이전 뷰가 제거되고 새 뷰로 다시 만들어지기 때문이다.', '다시 계산을 정체성 교체로 본 오해다. DetailChart는 타입과 뷰 트리의 자리가 그대로라 정체성이 이어진다. 정체성은 유지된 채 body만 다시 계산된 것이며, 정체성이 바뀌었다면 내부 @State도 초기값으로 돌아갔을 것이다.', false),

-- 문제 5695
(15363, 5695, '가', '행의 id가 내용과 함께 바뀐다고 본 오해다. 인덱스를 id로 쓰면 이름을 고쳐도 두 행의 id는 0과 1 그대로라 둘 다 정체성이 이어져 펼친 채 남는다. 인덱스 id의 약점은 삭제·삽입으로 자리가 밀릴 때 드러난다.', false),
(15364, 5695, '나', '이름을 id로 쓰면 ios를 iOS로 고치는 순간 두 번째 행의 id가 달라져 다른 뷰로 취급된다. 이전 행이 제거되고 새 행이 만들어져 isExpanded가 false로 돌아가고, id가 swift 그대로인 첫 번째 행은 펼친 채 남는다.', true),
(15365, 5695, '다', 'Identifiable을 채택하면 내용이 바뀔 때 id도 바뀐다고 본 오해다. 서버가 준 고유 번호는 이름을 고쳐도 그대로라 두 행 모두 같은 뷰로 이어져 펼친 채 남는다. 편집되는 값이 아니라 변하지 않는 값을 id로 써야 하는 이유다.', false),
(15366, 5695, '라', '고친 행만 영향을 받는다고 본 오해다. UUID()는 부를 때마다 새 값을 만든다. 이름을 고쳐 부모 body와 ForEach가 다시 계산되면 모든 행이 새 id를 받아, 이름을 고치지 않은 첫 번째 행까지 함께 접힌다.', false),

-- 문제 5696
(15367, 5696, 'A와 B 모두 FilterPanel의 타입과 자리가 같아, 다시 보여도 최소 가격 30,000원이 남는다.', '타입만 같으면 같은 뷰로 이어진다고 본 오해다. A의 if는 조건이 false가 되면 FilterPanel을 뷰 트리에서 빼내 수명을 끝낸다. 다시 true가 되면 새 정체성으로 만들어져 @State도 초기값 0부터 시작한다.', false),
(15368, 5696, 'A에서는 최소 가격이 0원으로 돌아가지만, "FilterPanel 등장" 로그는 처음 한 번만 찍힌다.', '상태와 onAppear의 수명을 따로 본 오해다. 둘 다 정체성에 묶여 있다. A에서 패널이 다시 보일 때 새 정체성이 생기므로 @State가 0으로 돌아가는 것과 함께 onAppear도 다시 호출돼 로그가 한 번 더 찍힌다.', false),
(15369, 5696, 'B에서는 감추는 순간 FilterPanel이 뷰 트리에서 빠져, 다시 보이면 최소 가격이 0원으로 돌아간다.', '투명하게 만드는 것을 뷰 제거로 본 오해다. B의 FilterPanel은 조건과 상관없이 늘 같은 자리에 있고 opacity 값만 바뀐다. 정체성이 이어지므로 minPrice의 30,000원이 그대로 남는다.', false),
(15370, 5696, 'B에서는 최소 가격 30,000원이 남고, 다시 보여도 "FilterPanel 등장" 로그가 더 찍히지 않는다.', 'B는 opacity 값만 바뀔 뿐 FilterPanel이 뷰 트리에서 빠지지 않아 정체성이 계속 이어진다. 그래서 @State 저장소가 30,000원을 유지하고, 정체성이 처음 생길 때 한 번 불리는 onAppear도 다시 호출되지 않는다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1854, 5697, '@Observable,Observable,@Observable 매크로,Observable 매크로,옵저버블,Observation,옵저베이션', 'ObservableObject는 @Published 프로퍼티 가운데 무엇이 바뀌든 객체 단위로 한 가지 변경 신호를 보낸다. 그래서 그 객체를 구독하는 뷰는 어떤 프로퍼티를 읽었는지와 상관없이 모두 무효화되고, roomName만 읽는 TitleBar도 unreadCount가 늘 때마다 body가 다시 계산됐다. iOS 17부터 쓸 수 있는 @Observable 매크로를 붙이면 Observation 프레임워크가 body 평가 중 실제로 읽은 프로퍼티만 의존성으로 기록하므로, TitleBar는 roomName이 바뀔 때만 무효화된다. 객체를 누가 소유하고 얼마나 붙들지를 정하는 @StateObject·@ObservedObject와 구분해야 한다. 그쪽은 객체의 수명 문제이고, @Observable은 어떤 변화가 어떤 뷰를 다시 계산하게 하는지의 범위를 좁힌다. 이미 시작된 갱신에서 값 비교로 자식 body 호출을 막는 Equatable과도 다르다.'),
       (1855, 5698, '_printChanges,_printChanges(),Self._printChanges(),Self._printChanges,printChanges,printChanges(),Self.printChanges()', 'Self._printChanges()는 body가 평가될 때 이번 평가를 일으킨 원인을 콘솔에 적어 주는 디버그용 메서드다. @identity는 정체성이 새로 생겼다는 뜻이라 화면을 처음 열 때만 보이고, @self는 부모가 넘긴 뷰 값 자체가 이전과 달라졌다는 뜻이며, _memo처럼 밑줄이 붙은 이름은 그 @State 값이 바뀌었다는 뜻이다. 글자마다 _memo만 찍힌 것을 보면 memo를 읽는 OrderView 전체가 무효화되고 있음을 알 수 있고, memo를 실제로 쓰는 하위 뷰로 내리자 무효화 범위가 MemoField로 좁혀져 OrderView 줄이 사라졌다. body 안에 print를 넣는 방법과 구분해야 한다. print는 body가 실행됐다는 사실만 알려 줄 뿐 무엇이 바뀌어서인지는 알려 주지 않는다. 이름이 밑줄로 시작하는 비공식 API라 디버깅할 때만 쓰고 출시 코드에는 남기지 않는다.');
