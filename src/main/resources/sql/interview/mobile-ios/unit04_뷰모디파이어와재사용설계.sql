-- Unit: 뷰 모디파이어와 재사용 설계 (Unit ID: 180)
-- Chapter: iOS (Chapter ID: 17)
-- Topic: SWIFTUI
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-ios-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(896, 'SWIFTUI', 180, 'HARD', true,
 '검색 TextField와 무거운 ChartView가 한 body에 있어서 타이핑할 때마다 화면 전체가 재평가되는 대시보드 화면이 있습니다. 이 화면을 어떻게 분리하시겠어요? 계산 프로퍼티로 나누는 방법으로는 왜 해결되지 않는지도 함께 설명해 주세요.',
 '먼저 검색어 query 상태를 DashboardView가 들고 있지 않게, 그 상태를 사용하는 SearchField라는 별도 struct 뷰로 내려보내 내부에서 소유하게 하겠습니다. 그러면 타이핑으로 query가 바뀌어도 DashboardView의 body는 건드리지 않습니다. ChartView도 별도 struct로 두면, 별도 struct 뷰는 자신이 읽는 상태에만 의존하므로 입력인 data가 같을 때 body 재평가를 건너뜁니다. 반면 header 같은 계산 프로퍼티나 @ViewBuilder 메서드로 나누는 것은 코드 정리일 뿐 렌더 단위를 나누지 않습니다. 계산 프로퍼티는 부모의 일부로 정체성을 공유하기 때문에 부모와 함께 항상 재평가되므로 재평가 범위가 줄지 않습니다. 이렇게 분리할지는 특정 상태 변경 시 무거운 하위 뷰가 함께 재평가되는 것이 프로파일링에서 확인될 때 판단하고, 상태를 가진 단위와 무거운 단위를 struct로 분리해 무효화 범위를 좁히는 것이 원칙입니다.'),
(897, 'SWIFTUI', 180, 'NORMAL', true,
 'SwiftUI에서 Text에 .padding().background(.yellow)를 적용한 경우와 .background(.yellow).padding()을 적용한 경우 결과가 어떻게 다르고, 왜 그런 차이가 생기나요?',
 '.padding().background(.yellow)는 배경이 여백을 포함한 영역을 채워서 노란 상자 안에 여백 있는 텍스트가 되고, 버튼·태그 형태의 칩 UI에 자주 씁니다. 반대로 .background(.yellow).padding()은 배경이 텍스트 크기만큼의 콘텐츠만 채우고 그 바깥 여백은 투명하게 남아서, 다른 뷰와의 간격 확보 용도로 씁니다. 이런 차이가 생기는 이유는 모디파이어가 뷰를 수정하는 게 아니라 기존 뷰를 감싼 새로운 뷰를 반환하기 때문입니다. 그래서 체인에서 나중에 쓴 모디파이어일수록 바깥쪽에 위치하고, 순서가 곧 중첩 구조이자 레이아웃 결과가 됩니다. 탭 영역도 마찬가지로 .onTapGesture{}.padding()은 패딩 영역이 탭에 반응하지 않고, .padding().onTapGesture{}는 여백까지 탭됩니다.'),
(898, 'SWIFTUI', 180, 'NORMAL', true,
 '자주 쓰는 스타일 조합을 재사용하려고 할 때, ViewModifier 프로토콜을 구현하는 방법과 단순히 View extension으로 메서드를 추가하는 방법 중 각각 언제 어떤 것을 선택하나요?',
 '같은 모디파이어 조합이 세 곳 이상 반복되면 추출을 고려합니다. ViewModifier 프로토콜을 구현하면 body(content:)에서 content로 원본 뷰를 받아 padding, background, clipShape, shadow 같은 조합을 적용하고, extension View에 cardStyle() 같은 메서드를 만들어 modifier(CardStyle())를 호출하게 합니다. ViewModifier는 @State나 @Environment를 가질 수 있기 때문에 다크 모드별 그림자처럼 환경값에 반응하는 스타일을 캡슐화할 때 적합합니다. 반면 상태가 없는 단순 조합이라면 extension View에서 self.padding()처럼 모디파이어를 이어 붙이는 확장만으로도 충분합니다. 다만 버튼 계열은 ButtonStyle 같은 스타일 프로토콜이 뷰 구조는 두고 외형만 바꾸는 공식 확장 지점이므로 커스텀 모디파이어보다 ButtonStyle을 우선합니다.'),
(899, 'SWIFTUI', 180, 'EASY', true,
 'SwiftUI에서 .padding() 같은 뷰 모디파이어를 호출하면 내부적으로 어떤 일이 일어나는지 설명해 주세요.',
 '.padding()이나 .background() 같은 모디파이어는 View 프로토콜의 메서드인데, 이름과 달리 뷰를 수정하는 것이 아니라 기존 뷰를 감싼 새로운 뷰를 반환합니다. 반환 타입은 ModifiedContent<원본, 모디파이어> 형태이고, 원본 뷰는 바뀌지 않습니다. 예를 들어 Text에 padding과 background를 이어 붙이면 background(padding(Text)) 형태로 중첩되어, 나중에 쓴 모디파이어일수록 바깥쪽에 위치합니다. 레이아웃은 바깥에서 안쪽으로 크기를 제안하고 안쪽에서 바깥으로 크기를 보고하므로, 모디파이어 적용 순서가 곧 레이아웃 결과가 됩니다.'),
(900, 'SWIFTUI', 180, 'EASY', true,
 '조건에 따라 모디파이어를 적용할지 말지 정하는 .if 같은 조건부 모디파이어 확장이 왜 위험한지, 그리고 어떻게 대신 작성하는지 설명해 주세요.',
 '.if 확장은 @ViewBuilder 안에서 조건이 참이면 transform(self), 거짓이면 self를 반환하기 때문에 조건에 따라 뷰 타입이 갈라집니다. 뷰 타입이 갈라지면 if/else와 똑같이 구조적 정체성이 바뀌어서 상태가 초기화되거나 애니메이션이 끊길 수 있습니다. 그래서 조건부로 뷰를 감쌀지 말지를 정하기보다, 항상 같은 모디파이어를 적용하고 값만 조건부로 바꾸는 것이 SwiftUI의 기본 원칙입니다. 예를 들어 .foregroundStyle(isHighlighted ? .red : .primary)처럼 색상 값만 조건으로 바꾸고, 뷰를 if로 빼는 대신 .opacity(isVisible ? 1 : 0)처럼 투명도 값을 조건으로 바꿉니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 896
(4824, 896, '검색어 상태를 SearchField 같은 하위 struct 뷰가 내부에서 소유하도록 내려보낸다고 설명', 'ESSENTIAL', 1),
(4825, 896, '계산 프로퍼티로 나눈 뷰는 부모와 함께 항상 재평가된다고 설명', 'ESSENTIAL', 2),
(4826, 896, '별도 struct 뷰는 입력이 같으면 body 재평가를 건너뛴다고 설명', 'ESSENTIAL', 3),
(4827, 896, '계산 프로퍼티·메서드 분리는 코드 정리일 뿐 렌더 단위를 나누지 않는다고 언급', 'SUPPLEMENTARY', 4),
(4828, 896, '무거운 하위 뷰의 재평가를 프로파일링으로 확인하는 것을 분리 신호로 언급', 'SUPPLEMENTARY', 5),

-- 질문 897
(4829, 897, 'padding 후 background 순서는 배경이 여백 포함 영역을 채운다고 설명', 'ESSENTIAL', 1),
(4830, 897, 'background 후 padding 순서는 배경이 콘텐츠만 채우고 바깥 여백은 투명하다고 설명', 'ESSENTIAL', 2),
(4831, 897, '모디파이어가 뷰를 감싼 새 뷰를 반환함·나중 모디파이어가 바깥에 위치함 중 최소 1개를 원인으로 제시', 'ESSENTIAL', 3),
(4832, 897, 'padding 후 background 순서가 버튼·태그 형태의 칩 UI에 쓰인다고 언급', 'SUPPLEMENTARY', 4),
(4833, 897, 'onTapGesture 뒤에 padding을 붙이면 패딩 영역이 탭에 반응하지 않는다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 898
(4834, 898, 'ViewModifier는 @State·@Environment를 가질 수 있어 환경값에 반응하는 스타일 캡슐화에 적합하다고 설명', 'ESSENTIAL', 1),
(4835, 898, '상태가 없는 단순 조합이면 View extension만으로 충분하다고 설명', 'ESSENTIAL', 2),
(4836, 898, 'ViewModifier의 body(content:)에서 content가 원본 뷰임을 언급', 'SUPPLEMENTARY', 3),
(4837, 898, '같은 모디파이어 조합이 세 곳 이상 반복되면 추출한다는 기준을 언급', 'SUPPLEMENTARY', 4),
(4838, 898, '버튼 계열은 커스텀 모디파이어보다 ButtonStyle이 우선이라고 언급', 'SUPPLEMENTARY', 5),

-- 질문 899
(4839, 899, '모디파이어가 기존 뷰를 감싼 새로운 뷰를 반환한다고 설명', 'ESSENTIAL', 1),
(4840, 899, '모디파이어를 호출해도 원본 뷰는 바뀌지 않는다고 언급', 'ESSENTIAL', 2),
(4841, 899, '반환되는 새 뷰의 타입이 ModifiedContent임을 언급', 'SUPPLEMENTARY', 3),
(4842, 899, '모디파이어 적용 순서가 곧 레이아웃 결과가 된다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 900
(4843, 900, '조건에 따라 뷰 타입이 갈라져 구조적 정체성이 바뀐다고 설명', 'ESSENTIAL', 1),
(4844, 900, '정체성이 바뀐 결과로 상태 초기화·애니메이션 단절 중 최소 1개를 언급', 'ESSENTIAL', 2),
(4845, 900, '항상 같은 모디파이어를 적용하고 값만 조건부로 바꾸는 대안을 제시', 'ESSENTIAL', 3),
(4846, 900, 'if로 뷰를 빼는 대신 opacity 값을 조건으로 바꾸는 예를 제시', 'SUPPLEMENTARY', 4);
