-- Unit: 셀 재사용과 리스트 성능 (Unit ID: 105)
-- Chapter: iOS (Chapter ID: 9)
-- Topic: IOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-ios-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(521, 'IOS_COMMON', 105, 'HARD', true,
 '목록을 빠르게 스크롤할 때 비동기로 받은 이미지가 엉뚱한 셀에 표시되는 버그가 왜 발생하는지, 그리고 이를 어떻게 해결할 수 있는지 설명해 주세요.',
 '셀은 재사용되기 때문에, 이미지 요청을 보낸 시점의 셀과 응답이 도착한 시점의 셀이 같은 인스턴스이지만 서로 다른 항목을 가리키게 됩니다. 예를 들어 row 3에 배정된 셀이 이미지 A를 요청했는데, 사용자가 빠르게 스크롤해서 같은 셀이 row 9에 재배정되어 이미지 B를 요청할 수 있습니다. 게다가 네트워크 응답 순서는 요청 순서와 무관하기 때문에, 느린 응답 A가 B보다 나중에 도착하면 최신 이미지를 덮어쓰는 경쟁 상태가 발생하고, 결국 전혀 다른 상품의 사진이 보이거나 이미지가 깜빡이며 바뀌는 증상이 나타납니다. 해결 원칙은 세 가지입니다. 첫째, 요청할 때 이미지 URL이나 항목 ID를 저장해 두고, 응답이 도착했을 때 셀이 여전히 같은 URL·ID를 가리키는지 확인한 뒤에만 이미지를 반영합니다. 둘째, prepareForReuse에서 진행 중인 이미지 다운로드 작업을 취소해 불필요한 네트워크와 디코딩을 줄입니다. 셋째, NSCache 같은 메모리 캐시를 앞단에 두어 재방문 시 즉시 표시하고 요청 자체를 줄입니다. 참고로 indexPath를 식별자로 저장해 비교하는 방식은 항목 삽입·삭제로 indexPath가 바뀌면 틀릴 수 있으므로, 항목의 고유 ID나 이미지 URL을 기준으로 비교하는 편이 안전합니다.',
 'interview-question/521.mp3'),
(522, 'IOS_COMMON', 105, 'NORMAL', true,
 'prepareForReuse에서 해야 할 일과 하지 말아야 할 일은 무엇이며, 셀의 초기 상태 설정을 prepareForReuse에만 맡기면 어떤 문제가 생기는지 설명해 주세요.',
 'prepareForReuse는 이전 항목의 흔적을 지우는 곳이지, 새 데이터를 넣는 곳이 아닙니다. 새 항목의 데이터 세팅은 cellForRowAt에서 하는 역할입니다. prepareForReuse에서 할 일은 이미지 뷰를 nil이나 플레이스홀더로 초기화하는 것, 진행 중인 이미지 다운로드 같은 비동기 작업을 취소하는 것, 토글·선택·확장 같은 상태 플래그를 초기화하는 것, onTap 같은 클로저 콜백을 nil로 처리하는 것입니다. 반대로 새 항목의 데이터 세팅, 무거운 뷰 재생성, init에서 1회면 충분한 레이아웃 제약 조건 재설정, 데이터 소스나 네트워크 호출은 하지 말아야 합니다. 또 prepareForReuse는 셀이 재사용될 때만 호출되고 처음 생성된 셀에서는 호출되지 않기 때문에, 초기 상태를 여기서만 설정하면 첫 화면의 셀은 초기화되지 않은 채 표시됩니다. 그래서 초기값은 init이나 awakeFromNib에서, 재사용 정리는 prepareForReuse에서, 항목별 값은 configure에서 설정하도록 역할을 나눕니다.',
 'interview-question/522.mp3'),
(523, 'IOS_COMMON', 105, 'NORMAL', true,
 '목록을 갱신할 때 reloadData를 호출하는 방식과 Diffable Data Source를 사용하는 방식은 어떻게 다르며, Diffable을 선택하는 이유는 무엇인가요?',
 'reloadData는 항목 하나만 바뀌어도 목록 전체를 갱신합니다. 반면 iOS 13부터 제공되는 UITableViewDiffableDataSource와 UICollectionViewDiffableDataSource는 스냅샷을 비교해 변경분만 적용합니다. Diffable을 선택하는 이유는 우선 변경분만 애니메이션으로 적용할 수 있고, insertRows·deleteRows를 직접 호출할 때 생기는 인덱스 불일치 크래시를 원천적으로 피할 수 있으며, 상태 관리도 단순해지기 때문입니다. 사용할 때는 스냅샷의 항목이 Hashable이어야 하고, 모델 전체보다 항목 ID만 넣는 편이 갱신 판단이 정확하고 메모리도 적게 듭니다.',
 'interview-question/523.mp3'),
(524, 'IOS_COMMON', 105, 'EASY', true,
 'UITableView의 셀 재사용이란 무엇이며, 왜 필요한지 재사용 큐의 동작 원리와 함께 설명해 주세요.',
 '셀 재사용은 화면 밖으로 나간 셀을 큐에 넣어 두었다가 새로 화면에 들어올 항목에 재활용하는 메커니즘입니다. 항목이 1만 개인 목록에 셀을 1만 개 만들면 메모리와 생성 비용을 감당할 수 없지만, 화면에 동시에 보이는 셀은 많아야 10~20개이므로 재사용하면 셀 개수를 상수로 유지할 수 있습니다. 동작 순서는 먼저 register로 셀 클래스와 식별자를 등록하고, cellForRowAt에서 dequeueReusableCell을 호출하면 큐에 남은 셀이 있으면 그것을, 없으면 새 인스턴스를 돌려줍니다. 이때 큐에서 꺼낸 셀은 이전 항목의 텍스트·이미지·선택 상태 같은 상태를 그대로 가지고 있기 때문에, 재사용 직전에 prepareForReuse가 호출되어 초기화할 기회를 줍니다.',
 'interview-question/524.mp3'),
(525, 'IOS_COMMON', 105, 'EASY', true,
 'UITableView 목록을 스크롤할 때 끊김이 생긴다면 어떤 원인들이 있고, 각각 어떻게 개선할 수 있나요?',
 '스크롤 중 프레임 드롭의 대부분은 셀 생성이 아니라 셀 구성 단계의 무거운 작업 때문입니다. cellForRowAt에서 동기 디코딩이나 복잡한 문자열 처리를 하면 끊기므로, 이런 작업은 백그라운드에서 미리 계산하거나 다운샘플링하고 셀 구성은 값 대입만 하도록 합니다. 셀이 보일 때 비로소 이미지를 요청하면 네트워크 대기가 생기므로, UITableViewDataSourcePrefetching으로 다음 화면 항목의 이미지를 미리 요청합니다. 또 cornerRadius와 masksToBounds, 그림자, 마스크는 오프스크린 렌더링을 일으키므로 그림자에는 shadowPath를 지정하고 둥근 모서리는 이미지 자체를 가공합니다. 반투명 배경이 겹치면 합성 비용이 들므로 셀과 서브뷰를 불투명하게 만들고, 셀마다 heightForRowAt을 실측하는 대신 estimatedRowHeight와 automaticDimension으로 높이를 지연 계산합니다. 항목 하나만 바뀌는데 reloadData로 전체를 갱신하는 경우에는 Diffable Data Source로 변경분만 적용합니다.',
 'interview-question/525.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 521
(2794, 521, '요청 시점과 응답 시점의 셀이 같은 인스턴스지만 다른 항목을 가리킨다는 점을 원인으로 설명', 'ESSENTIAL', 1),
(2795, 521, '응답 순서가 요청 순서와 무관해 느린 응답이 최신 이미지를 덮어쓰는 경쟁 상태가 생긴다고 설명', 'ESSENTIAL', 2),
(2796, 521, '요청 시 저장한 URL이나 항목 ID가 응답 시점에도 같을 때만 이미지를 반영하는 방법을 제시', 'ESSENTIAL', 3),
(2797, 521, 'prepareForReuse에서 진행 중인 이미지 다운로드 작업을 취소하는 방법을 제시', 'ESSENTIAL', 4),
(2798, 521, 'NSCache 같은 메모리 캐시를 앞단에 두어 재방문 시 즉시 표시하는 방법을 제시', 'SUPPLEMENTARY', 5),
(2799, 521, 'indexPath를 식별자로 저장하는 방식은 항목 삽입·삭제로 indexPath가 바뀌면 틀릴 수 있다는 한계를 언급', 'SUPPLEMENTARY', 6),

-- 질문 522
(2800, 522, 'prepareForReuse는 이전 항목의 흔적을 지우는 곳이고 새 데이터 세팅은 cellForRowAt의 역할이라고 구분', 'ESSENTIAL', 1),
(2801, 522, '이미지 초기화·진행 중 작업 취소·상태 플래그 초기화·콜백 nil 처리 중 최소 2개를 prepareForReuse 작업으로 제시', 'ESSENTIAL', 2),
(2802, 522, 'prepareForReuse는 처음 생성된 셀에서는 호출되지 않아 첫 화면 셀이 초기화되지 않는다고 설명', 'ESSENTIAL', 3),
(2803, 522, '초기값은 init·awakeFromNib에서, 항목별 값은 configure에서 설정한다고 역할 분담을 서술', 'SUPPLEMENTARY', 4),
(2804, 522, '무거운 뷰 재생성이나 레이아웃 제약 조건 재설정은 prepareForReuse에서 하지 않는다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 523
(2805, 523, 'reloadData의 전체 갱신과 Diffable Data Source의 스냅샷 기반 변경분 적용의 차이를 설명', 'ESSENTIAL', 1),
(2806, 523, 'Diffable을 쓰면 insertRows·deleteRows의 인덱스 불일치 크래시를 피할 수 있다고 언급', 'ESSENTIAL', 2),
(2807, 523, 'Diffable을 쓰면 변경분을 애니메이션과 함께 적용할 수 있다는 점을 선택 이유로 언급', 'SUPPLEMENTARY', 3),
(2808, 523, '스냅샷에는 모델 전체보다 항목 ID만 넣는 편이 갱신 판단이 정확하다고 언급', 'SUPPLEMENTARY', 4),
(2809, 523, '스냅샷의 항목이 Hashable이어야 한다는 조건을 명시', 'SUPPLEMENTARY', 5),

-- 질문 524
(2810, 524, '화면 밖으로 나간 셀을 큐에 넣었다가 새로 들어올 항목에 재활용한다고 설명', 'ESSENTIAL', 1),
(2811, 524, '재사용으로 셀 개수를 상수로 유지해 메모리와 생성 비용을 줄인다는 목적을 언급', 'ESSENTIAL', 2),
(2812, 524, 'dequeueReusableCell은 큐에 셀이 있으면 그것을, 없으면 새 인스턴스를 돌려준다고 설명', 'ESSENTIAL', 3),
(2813, 524, '큐에서 꺼낸 셀이 이전 항목의 상태를 그대로 가지고 있다고 언급', 'SUPPLEMENTARY', 4),
(2814, 524, 'register로 셀 클래스와 재사용 식별자를 먼저 등록해야 한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 525
(2815, 525, '동기 디코딩·높이 실측·오프스크린 렌더링·반투명 합성·네트워크 대기·전체 reloadData 중 최소 2개를 원인으로 제시', 'ESSENTIAL', 1),
(2816, 525, '백그라운드 미리 계산·높이 지연 계산·오프스크린 렌더링 제거·불투명 처리·프리페칭·Diffable 중 최소 2개를 개선책으로 제시', 'ESSENTIAL', 2),
(2817, 525, '프레임 드롭의 대부분이 셀 생성이 아니라 셀 구성 단계의 무거운 작업 때문이라고 언급', 'SUPPLEMENTARY', 3),
(2818, 525, '그림자에는 shadowPath를 지정해 오프스크린 렌더링을 피한다고 언급', 'SUPPLEMENTARY', 4),
(2819, 525, 'UITableViewDataSourcePrefetching으로 다음 화면 항목의 이미지를 미리 요청하는 방법을 제시', 'SUPPLEMENTARY', 5);
