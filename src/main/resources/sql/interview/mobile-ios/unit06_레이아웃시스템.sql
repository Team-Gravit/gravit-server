-- Unit: 레이아웃 시스템 (Unit ID: 182)
-- Chapter: iOS (Chapter ID: 17)
-- Topic: SWIFTUI
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-ios-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(906, 'SWIFTUI', 182, 'HARD', true,
 'SwiftUI의 HStack에 긴 제목 Text와 날짜 Text를 나란히 두었더니 제목이 "..."으로 잘립니다. 크기 협상과 스택의 공간 분배 규칙으로 원인을 설명하고, 어떻게 해결할지, 그리고 GeometryReader로 해결하려 할 때 어떤 문제가 생기는지 말씀해 주시겠어요?',
 'SwiftUI에는 제약이 없고 부모가 자식에게 공간을 제안하면 자식이 쓸 크기를 결정합니다. HStack은 자식들의 유연성을 조사한 뒤 유연성이 가장 낮은 자식부터 남은 공간을 균등 분할한 크기를 제안하고, 자식이 응답한 크기를 뺀 나머지를 다음 자식에게 제안합니다. 긴 제목 Text는 HStack이 나눠준 공간에 맞춰 줄어들기 때문에 "..."으로 잘리게 됩니다. 해결하려면 제목에 layoutPriority(1)을 주어 공간 분배 순서에서 앞으로 당겨 먼저 필요한 공간을 가져가게 하고, 날짜 Text에는 fixedSize()를 적용해 제안을 무시하고 이상적 크기로 응답하게 해서 줄어들지 않도록 합니다. 원인을 모른 채 frame을 남발하는 것은 안티패턴이고, 불필요한 frame은 제거하는 것이 좋습니다. 한편 크기를 재려고 GeometryReader로 텍스트를 감싸면, GeometryReader는 제안된 공간을 전부 차지하기 때문에 주변 레이아웃 전체가 망가집니다. 크기 측정이 필요하다면 .background(GeometryReader { ... })처럼 배경에 숨겨 쓰거나, iOS 16 이상에서는 Layout 프로토콜, iOS 17 이상에서는 onGeometryChange를 사용하는 것이 대안입니다.',
 'interview-question/906.mp3'),
(907, 'SWIFTUI', 182, 'NORMAL', true,
 'Auto Layout에서 Content Hugging과 Compression Resistance는 각각 무엇이고 어떻게 다른지 설명해 주시겠어요?',
 '둘 다 intrinsicContentSize를 가진 뷰가 늘어남과 줄어듦에 대한 태도를 표현하는 콘텐츠 크기 우선순위입니다. Content Hugging은 콘텐츠보다 커지기 싫은 정도로, 값이 높을수록 늘어나지 않으려 하고 기본값은 250(defaultLow)입니다. Compression Resistance는 콘텐츠보다 작아지기 싫은 정도로, 값이 높을수록 잘리지 않으려 하며 기본값은 750(defaultHigh)입니다. 예를 들어 UIStackView 폭이 300이고 두 레이블의 intrinsic 폭 합이 200이면 남는 100은 허깅이 낮은 레이블이 늘어나 가져가고, 폭이 150이면 부족한 50만큼 압축 저항이 낮은 레이블이 잘립니다. 두 레이블의 허깅이나 압축 저항 우선순위가 같으면 엔진이 어느 쪽을 늘리거나 자를지 결정할 수 없어 모호하다는 경고가 나오며, 한쪽을 1만큼이라도 높이면 해결됩니다.',
 'interview-question/907.mp3'),
(908, 'SWIFTUI', 182, 'NORMAL', true,
 'UIKit의 Auto Layout과 SwiftUI의 크기 협상은 레이아웃을 결정하는 방식에서 어떤 차이가 있나요?',
 'Auto Layout은 제약을 선형 방정식으로 표현하고, Cassowary 알고리즘 기반 엔진이 모든 제약을 동시에 만족하는 프레임을 계산합니다. 반면 SwiftUI에는 제약이 없고, 부모가 자식에게 공간을 제안하면 자식이 크기를 결정해 응답하고 부모가 그 크기로 배치하는 과정이 재귀적으로 이어집니다. 그래서 크기 결정권이 Auto Layout에서는 제약 집합 전체에 전역적으로 있고, SwiftUI에서는 자식에게 지역적·단방향으로 있습니다. 충돌 처리도 달라서 Auto Layout은 우선순위가 낮은 제약이 양보하고 위반 시 경고를 내지만, SwiftUI에는 충돌 개념이 없어 자식이 넘치면 그냥 넘칩니다. 콘텐츠 크기는 Auto Layout이 intrinsicContentSize와 허깅·압축 저항으로, SwiftUI는 이상적 크기와 fixedSize·layoutPriority로 다룹니다. 디버깅은 Auto Layout은 경고 로그나 hasAmbiguousLayout, 뷰 디버거를, SwiftUI는 .border()로 프레임을 확인하거나 Self._printChanges()를 씁니다. 상호운용 시에는 UIKit 쪽 intrinsicContentSize가 SwiftUI의 이상적 크기로, SwiftUI의 응답 크기가 UIKit의 호스팅 뷰 크기로 번역됩니다.',
 'interview-question/908.mp3'),
(909, 'SWIFTUI', 182, 'EASY', true,
 'SwiftUI에서 뷰의 크기가 정해지는 크기 협상 과정을 단계별로 설명해 주시겠어요?',
 'SwiftUI는 제약 대신 부모와 자식이 크기를 협상하며, 세 단계로 진행됩니다. 먼저 부모가 자식에게 이 정도 공간을 쓰라고 크기를 제안합니다. 다음으로 자식이 자신이 쓸 크기를 결정해 부모에게 응답하는데, 자식이 최종 결정권을 가지므로 제안보다 작게 또는 크게 응답하며 제안을 무시할 수도 있습니다. 마지막으로 부모는 자식이 보고한 크기로 위치를 잡는 배치만 하며, 자식을 강제로 줄일 수는 없습니다. 예를 들어 Text·Image처럼 고유 크기를 가진 뷰는 필요한 만큼만 쓰고, Color·Rectangle·Spacer처럼 유연한 뷰는 제안을 다 씁니다. 모디파이어가 중첩되면 제안은 바깥에서 안쪽으로 전달되고 응답은 안쪽에서 바깥으로 돌아오기 때문에 .frame().background()와 .background().frame()의 결과가 달라집니다. iOS 16의 Layout 프로토콜에서는 sizeThatFits가 응답 단계, placeSubviews가 배치 단계에 대응합니다.',
 'interview-question/909.mp3'),
(910, 'SWIFTUI', 182, 'EASY', true,
 'Auto Layout에서 제약(Constraint)은 어떤 형태로 표현되며, 레이아웃이 모호하다거나 제약이 충돌한다는 것은 각각 어떤 상태를 뜻하나요?',
 'Auto Layout의 제약은 item1.attribute = multiplier × item2.attribute + constant 형태의 선형 방정식 또는 부등식입니다. 예를 들어 label.leading = 1.0 × superview.leading + 16처럼 표현하고, Cassowary 알고리즘 기반 엔진이 모든 제약을 동시에 만족하는 프레임을 계산합니다. 한 축을 결정하려면 위치와 크기, 또는 양 끝 정보가 충분해야 하는데, 이 정보가 부족하면 모호(ambiguous)한 상태이고, 반대로 제약이 넘쳐 동시에 만족할 수 없으면 충돌(unsatisfiable) 상태입니다. 크기가 명시되지 않은 뷰는 레이블·버튼·이미지뷰처럼 콘텐츠로부터 계산한 intrinsicContentSize로 크기를 제안합니다. 모든 제약은 1~1000의 우선순위를 가지며 1000(required)은 반드시 만족해야 하고 그 이하는 충돌 시 낮은 쪽이 양보합니다. 코드로 제약을 줄 때 translatesAutoresizingMaskIntoConstraints를 false로 두지 않으면 기존 프레임이 자동 제약으로 변환되어 개발자 제약과 충돌하며, "Unable to simultaneously satisfy constraints" 경고 대부분이 이 설정 누락이나 필수 제약 중복에서 나옵니다.',
 'interview-question/910.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 906
(4870, 906, 'HStack이 나눠준 제안 공간에 맞춰 Text가 줄어들어 잘린다고 설명', 'ESSENTIAL', 1),
(4871, 906, 'layoutPriority가 높은 자식이 먼저 필요한 공간을 가져가도록 조정하는 방법을 제시', 'ESSENTIAL', 2),
(4872, 906, 'fixedSize가 제안을 무시하고 이상적 크기로 응답해 텍스트 줄임을 막는다고 설명', 'ESSENTIAL', 3),
(4873, 906, 'GeometryReader가 제안된 공간을 전부 차지해 주변 레이아웃을 깨뜨린다고 언급', 'ESSENTIAL', 4),
(4874, 906, '스택이 유연성이 가장 낮은 자식부터 남은 공간을 균등 분할해 제안한다고 설명', 'SUPPLEMENTARY', 5),
(4875, 906, 'GeometryReader를 background에 숨기거나 Layout 프로토콜을 쓰는 방식을 대안으로 제시', 'SUPPLEMENTARY', 6),

-- 질문 907
(4876, 907, 'Content Hugging은 콘텐츠보다 커지기 싫은 정도, 즉 늘어나지 않으려는 태도라고 설명', 'ESSENTIAL', 1),
(4877, 907, 'Compression Resistance는 콘텐츠보다 작아지기 싫은 정도, 즉 잘리지 않으려는 태도라고 설명', 'ESSENTIAL', 2),
(4878, 907, '남는 공간은 허깅이 더 낮은 뷰가 늘어나 가져간다고 설명', 'ESSENTIAL', 3),
(4879, 907, '공간이 부족하면 압축 저항이 더 낮은 뷰가 잘린다고 설명', 'ESSENTIAL', 4),
(4880, 907, '허깅 기본값 250과 압축 저항 기본값 750을 언급', 'SUPPLEMENTARY', 5),
(4881, 907, '두 뷰의 우선순위가 같으면 엔진이 결정할 수 없어 모호 경고가 난다고 언급', 'SUPPLEMENTARY', 6),
(4882, 907, '두 우선순위가 intrinsicContentSize를 가진 뷰의 태도를 표현한다고 언급', 'SUPPLEMENTARY', 7),

-- 질문 908
(4883, 908, 'Auto Layout은 엔진이 모든 제약 방정식을 동시에 만족하는 프레임을 계산한다고 설명', 'ESSENTIAL', 1),
(4884, 908, 'SwiftUI는 부모 제안과 자식 응답이 재귀적으로 이어지는 협상 방식이라고 설명', 'ESSENTIAL', 2),
(4885, 908, '크기 결정권이 Auto Layout은 제약 집합 전체, SwiftUI는 자식에게 있다고 비교', 'ESSENTIAL', 3),
(4886, 908, '충돌 시 Auto Layout은 우선순위로 양보하고 SwiftUI는 자식이 그냥 넘친다고 비교', 'SUPPLEMENTARY', 4),
(4887, 908, '콘텐츠 크기를 Auto Layout은 intrinsicContentSize, SwiftUI는 이상적 크기로 다룬다고 비교', 'SUPPLEMENTARY', 5),
(4888, 908, '상호운용 시 intrinsicContentSize가 SwiftUI의 이상적 크기로 번역된다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 909
(4889, 909, '첫 단계로 부모가 자식에게 사용할 공간을 제안한다고 설명', 'ESSENTIAL', 1),
(4890, 909, '두 번째 단계로 자식이 자신이 쓸 크기를 결정해 부모에게 응답한다고 설명', 'ESSENTIAL', 2),
(4891, 909, '세 번째 단계로 부모가 자식이 보고한 크기로 위치를 잡는다(배치)고 설명', 'ESSENTIAL', 3),
(4892, 909, '자식이 부모의 제안을 무시하고 제안과 다른 크기로 응답할 수 있음을 언급', 'SUPPLEMENTARY', 4),
(4893, 909, '부모는 자식을 강제로 줄일 수 없음을 언급', 'SUPPLEMENTARY', 5),
(4894, 909, 'Text·Image 같은 고유 크기 뷰와 Color·Spacer 같은 유연한 뷰의 응답 방식을 구분', 'SUPPLEMENTARY', 6),

-- 질문 910
(4895, 910, '제약을 multiplier와 constant를 포함한 선형 방정식 또는 부등식으로 설명', 'ESSENTIAL', 1),
(4896, 910, '한 축의 위치·크기 정보가 부족하면 모호(ambiguous) 상태라고 설명', 'ESSENTIAL', 2),
(4897, 910, '제약이 넘쳐 동시에 만족할 수 없으면 충돌(unsatisfiable) 상태라고 설명', 'ESSENTIAL', 3),
(4898, 910, 'translatesAutoresizingMaskIntoConstraints를 false로 두지 않으면 자동 제약과 충돌한다고 언급', 'SUPPLEMENTARY', 4),
(4899, 910, '크기 제약이 없는 뷰는 intrinsicContentSize로 크기를 제안한다고 언급', 'SUPPLEMENTARY', 5),
(4900, 910, '우선순위 1000 미만의 제약은 충돌 시 양보한다고 언급', 'SUPPLEMENTARY', 6);
