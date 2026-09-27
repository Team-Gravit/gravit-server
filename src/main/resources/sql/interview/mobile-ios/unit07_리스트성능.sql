-- Unit: 리스트 성능 (Unit ID: 183)
-- Chapter: iOS (Chapter ID: 17)
-- Topic: SWIFTUI
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-ios-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(911, 'SWIFTUI', 183, 'HARD', true,
 'UITableView 기반 피드에서 셀마다 썸네일 이미지를 불러오는데, 빠르게 스크롤하면 엉뚱한 이미지가 보이고 스크롤도 끊깁니다. 두 문제의 원인과 대응 방법을 각각 설명해 주시겠어요?',
 '엉뚱한 이미지가 보이는 문제는 셀 재사용 때문입니다. 화면 밖으로 나간 셀은 재사용 풀에 들어갔다가 새 행의 데이터로 다시 구성되는데, 셀 A가 이미지를 비동기로 요청한 뒤 재사용되어 셀 B가 됐을 때 뒤늦게 도착한 A의 이미지가 B에 그려지는 것이 원인입니다. 대응으로는 재사용 직전에 호출되는 prepareForReuse에서 진행 중인 이전 행의 다운로드 작업을 취소하고, 이전 이미지를 nil로 비워 잔상을 막습니다. 또는 응답이 도착했을 때 현재 셀의 식별자와 비교해 다르면 결과를 버리는 방법도 있습니다. 스크롤이 끊기는 문제는 셀 구성이 프레임당 예산 안에 끝나지 않아서 생깁니다. 셀 하나를 구성하는 데 16ms 이상 걸리면 프레임이 떨어지는데, 이미지를 동기로 로딩·디코딩하면 메인 스레드가 막혀 끊김이 발생합니다. 따라서 이미지는 백그라운드에서 디코딩하고 캐시를 사용하며, 포매팅이나 정렬 같은 계산은 뷰모델에서 미리 해 두고 cellForRowAt에서는 값을 대입만 하도록 가볍게 유지합니다.'),
(912, 'SWIFTUI', 183, 'NORMAL', true,
 'SwiftUI에서 수천 개 항목을 보여줄 때 VStack, LazyVStack, List는 뷰 생성 방식과 재사용 측면에서 어떤 차이가 있나요?',
 'VStack은 모든 항목 뷰를 즉시 생성하기 때문에 수천 개 항목을 넣으면 첫 렌더가 수 초 걸릴 수 있어, 수십 개 이하의 소규모 목록에만 쓰고 수백 개 이상에는 쓰지 않습니다. LazyVStack은 ScrollView 안에서 항목 뷰를 화면에 가까워질 때 생성하는 지연 생성 방식이지만, UIKit식 재사용 풀은 없고 한 번 생성된 뷰가 화면 밖으로 나가도 해제가 보장되지 않아 수백~수천 개 규모에서는 메모리에 주의해야 합니다. List는 내부적으로 UIKit 컬렉션 뷰(iOS 16 이전은 테이블뷰)를 사용해 지연 생성과 셀 재사용을 모두 제공하므로 수천 개 이상의 목록에 적합하고, 스와이프 액션·구분선·섹션 헤더·편집 모드 같은 목록 기능도 내장되어 있습니다.'),
(913, 'SWIFTUI', 183, 'NORMAL', true,
 'iOS 앱에서 목록 화면을 만들 때 SwiftUI List, ScrollView와 LazyVStack 조합, UICollectionView 중 어떤 상황에서 각각을 선택하시겠어요?',
 'SwiftUI 앱에서 설정·피드·채팅처럼 표준적인 목록이라면 셀 재사용과 스와이프·구분선·섹션 같은 목록 기능을 내장한 List를 씁니다. 카드형 목록, 수평 캐러셀, 격자처럼 List로는 레이아웃 자유도가 부족한 화면이라면 ScrollView 안에 LazyVStack이나 LazyVGrid를 두어 지연 생성으로 구성합니다. 수만 개 항목을 다루거나 정밀한 스크롤 제어, 복잡한 셀 애니메이션이 필요하면 UICollectionView를 선택하고, 이때는 컴포지셔널 레이아웃과 Diffable Data Source를 조합하는 것이 현재 표준입니다. 기존 UIKit 화면을 유지하면서 셀 UI만 현대화하고 싶다면 UITableView나 UICollectionView에 UIHostingConfiguration을 써서 셀 내용을 SwiftUI로 작성합니다.'),
(914, 'SWIFTUI', 183, 'EASY', true,
 'UITableView의 셀 재사용은 어떤 과정으로 동작하나요?',
 '먼저 register(_:forCellReuseIdentifier:)로 셀 타입을 등록하고, cellForRowAt에서 dequeueReusableCell(withIdentifier:for:)로 셀을 꺼내 씁니다. 스크롤로 화면 밖으로 나간 셀은 재사용 풀(reuse queue)에 들어가고, 새 행이 필요해지면 풀에서 셀을 꺼내 새 인덱스의 데이터만 갈아끼워 다시 구성합니다. 풀이 비어 있을 때만 새 셀을 생성합니다. 셀은 재사용 직전에 prepareForReuse()를 호출받아 이전 이미지나 선택 상태, 진행 중 작업 같은 흔적을 지웁니다. 그래서 데이터가 1만 개여도 실제 뷰 객체는 화면에 보이는 개수와 약간의 여유분만 존재하고 나머지는 데이터로만 존재합니다.'),
(915, 'SWIFTUI', 183, 'EASY', true,
 'SwiftUI 목록에서 스크롤 성능을 떨어뜨리는 대표적인 실수에는 어떤 것들이 있나요?',
 '첫째, 불안정한 id입니다. ForEach(items.indices, id: \.self)를 쓰거나 body 안에서 UUID()를 생성하면 스크롤마다 새 뷰로 인식되어 재사용이 무의미해집니다. 둘째, 무거운 행 뷰입니다. 행 안에서 날짜 포매팅·정렬을 하거나 AnyView를 쓰면 그 작업이 스크롤마다 반복되므로, 표시용 문자열은 모델에서 미리 만들어 둡니다. 셋째, 상위 상태 변경입니다. 검색어 @State가 목록과 같은 뷰에 있으면 타이핑할 때마다 List 전체가 재평가되므로 행을 별도 struct로 분리하고 상태를 내려보냅니다. 또 ObservableObject 하나를 모든 행이 구독하면 한 행의 변경이 전체 행을 갱신하는데, iOS 17+의 @Observable로 바꾸면 읽은 프로퍼티만 추적됩니다. 행 안의 @State는 행이 재사용·재생성될 때 초기화될 수 있으므로 확장/접힘 같은 행별 UI 상태는 부모가 모델이나 Set<ID> 형태로 보관하고 행은 바인딩으로 받는 것이 안전합니다. 이미지는 AsyncImage의 기본 캐시가 제한적이라 대량 목록에서는 자체 캐시 로더를 씁니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 911
(4901, 911, '재사용된 셀에 이전 행의 이미지 응답이 뒤늦게 도착해 그려지는 것이 원인임을 설명', 'ESSENTIAL', 1),
(4902, 911, 'prepareForReuse에서 작업 취소·현재 셀 식별자와 다른 응답 버리기 중 최소 1개를 대응으로 제시', 'ESSENTIAL', 2),
(4903, 911, '이미지 동기 디코딩 등 무거운 셀 구성이 메인 스레드를 막아 끊김이 생김을 설명', 'ESSENTIAL', 3),
(4904, 911, '백그라운드 디코딩·캐시 중 최소 1개를 끊김 대응으로 제시', 'ESSENTIAL', 4),
(4905, 911, 'prepareForReuse에서 이전 이미지를 nil로 비워 잔상을 방지함을 언급', 'SUPPLEMENTARY', 5),
(4906, 911, '포매팅 같은 계산은 뷰모델에서 미리 하고 셀은 대입만 하도록 유지함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 912
(4907, 912, 'VStack은 모든 항목을 즉시 생성해 수백 개 이상 목록에 부적합함을 설명', 'ESSENTIAL', 1),
(4908, 912, 'LazyVStack은 항목 뷰를 화면에 가까워질 때 생성함을 언급', 'ESSENTIAL', 2),
(4909, 912, 'LazyVStack에는 UIKit식 재사용 풀이 없음을 언급', 'ESSENTIAL', 3),
(4910, 912, 'List는 VStack·LazyVStack과 달리 셀 재사용을 제공함을 언급', 'ESSENTIAL', 4),
(4911, 912, 'List가 내부적으로 UIKit 컬렉션 뷰를 사용함을 언급', 'SUPPLEMENTARY', 5),
(4912, 912, 'LazyVStack에서 화면 밖으로 나간 뷰의 해제가 보장되지 않음을 언급', 'SUPPLEMENTARY', 6),
(4913, 912, 'List에는 스와이프 액션·섹션 헤더·편집 모드 등 목록 기능이 내장되어 있음을 언급', 'SUPPLEMENTARY', 7),

-- 질문 913
(4914, 913, '설정·피드·채팅 같은 표준적인 목록에는 List를 권장함을 언급', 'ESSENTIAL', 1),
(4915, 913, '카드형·수평 캐러셀·격자 같은 자유로운 레이아웃에는 LazyVStack/LazyVGrid를 권장함을 언급', 'ESSENTIAL', 2),
(4916, 913, '수만 개 항목·정밀한 스크롤 제어·복잡한 셀 애니메이션 중 최소 1개를 UICollectionView 선택 근거로 제시', 'ESSENTIAL', 3),
(4917, 913, '기존 UIKit 화면에서 셀 UI만 현대화할 때 UIHostingConfiguration을 쓴다고 언급', 'SUPPLEMENTARY', 4),
(4918, 913, 'UICollectionView는 컴포지셔널 레이아웃과 Diffable Data Source 조합이 현재 표준임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 914
(4919, 914, '화면 밖으로 나간 셀이 재사용 풀(reuse queue)에 들어감을 언급', 'ESSENTIAL', 1),
(4920, 914, '새 행이 필요하면 풀에서 셀을 꺼내 데이터만 갈아끼우는 과정을 설명', 'ESSENTIAL', 2),
(4921, 914, '재사용 풀이 비어 있을 때만 새 셀을 생성함을 언급', 'ESSENTIAL', 3),
(4922, 914, 'dequeueReusableCell로 재사용 셀을 꺼내는 API를 제시', 'SUPPLEMENTARY', 4),
(4923, 914, '재사용 직전 prepareForReuse가 호출되어 이전 데이터의 흔적을 지움을 언급', 'SUPPLEMENTARY', 5),
(4924, 914, '실제 뷰 객체는 보이는 개수와 여유분만큼만 존재함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 915
(4925, 915, 'ForEach의 id가 불안정하면 스크롤마다 새 뷰로 인식되는 문제를 설명', 'ESSENTIAL', 1),
(4926, 915, '행 뷰 안의 날짜 포매팅·정렬 같은 작업이 스크롤마다 반복되는 문제를 설명', 'ESSENTIAL', 2),
(4927, 915, '목록과 같은 뷰의 @State 변경으로 List 전체가 재평가되는 문제를 설명', 'ESSENTIAL', 3),
(4928, 915, 'ObservableObject 하나를 모든 행이 구독하면 한 행 변경이 전체 행을 갱신함을 언급', 'SUPPLEMENTARY', 4),
(4929, 915, '행별 UI 상태는 부모가 Set<ID> 형태 등으로 보관하고 행은 바인딩으로 받음을 언급', 'SUPPLEMENTARY', 5),
(4930, 915, 'AsyncImage는 기본 캐시가 제한적이라 대량 목록에서 자체 캐시 로더를 쓴다고 언급', 'SUPPLEMENTARY', 6);
