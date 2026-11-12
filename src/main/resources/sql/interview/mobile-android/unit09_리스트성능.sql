-- Unit: 리스트 성능 (Unit ID: 175)
-- Chapter: Android (Chapter ID: 16)
-- Topic: COMPOSE
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-android-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(871, 'COMPOSE', 175, 'HARD', true,
 '피드 화면에서 RecyclerView나 LazyColumn을 이미 쓰고 있는데도 스크롤 중 프레임 드랍이 발생한다면, 원인을 어디서부터 찾고 어떻게 최적화하시겠습니까?',
 '화면은 초당 60프레임을 그려야 하므로 프레임당 예산은 약 16ms이고, 이를 초과하면 프레임 드랍(Jank)이 발생합니다. RecyclerView나 LazyColumn이 아무리 잘 재사용해도 스크롤 성능은 항목 하나의 비용 × 화면에 보이는 개수이기 때문에, 항목 하나가 5ms 걸리면 10개가 보이는 순간 예산을 넘깁니다. 그래서 최적화의 첫 대상은 항목 레이아웃·바인딩·컴포저블 자체입니다. 먼저 날짜 포매팅·정렬·필터링 같은 데이터 가공은 onBindViewHolder나 항목 컴포저블 안에서 하지 않고 ViewModel에서 미리 끝내 불변 UI 모델로 내려보냅니다. 이미지는 Coil·Glide 같은 라이브러리에 위임해 크기 조절·캐시·취소를 맡깁니다. 항목 높이를 고정하면 측정이 줄어드는데, RecyclerView는 setHasFixedSize(true), Compose는 Modifier.height()로 고정합니다. 수만 건의 큰 목록은 Paging 라이브러리로 페이지 단위 로딩합니다. 그리고 디버그 빌드, 특히 Compose는 실제보다 훨씬 느리므로 Macrobenchmark와 Baseline Profile을 적용한 릴리스 빌드에서 측정해 판단합니다.',
 'interview-question/871.mp3'),
(872, 'COMPOSE', 175, 'NORMAL', true,
 'RecyclerView에서 목록이 바뀔 때 notifyDataSetChanged() 대신 DiffUtil(ListAdapter)을 쓰는 이유와, areItemsTheSame과 areContentsTheSame의 차이를 설명해 주세요.',
 '목록이 바뀔 때 notifyDataSetChanged()를 부르면 모든 항목을 다시 바인딩하고 애니메이션도 없습니다. DiffUtil은 이전 목록과 새 목록의 차이를 Eugene Myers 차이 알고리즘으로 계산해 삽입·삭제·이동·변경을 알아내고, 필요한 notifyItemXxx()만 호출하므로 바뀐 항목만 갱신되고 애니메이션도 적용됩니다. 실무에서는 DiffUtil 계산을 백그라운드 스레드에서 수행한 뒤 결과를 메인 스레드에 반영하는 ListAdapter를 표준으로 씁니다. ItemCallback의 areItemsTheSame은 두 항목이 같은 항목인지, 즉 정체성(ID)을 비교하고, areContentsTheSame은 같은 항목의 내용이 바뀌었는지를 비교합니다. 둘을 뒤섞으면 이동 감지가 깨지거나 변경이 무시됩니다. 또 submitList에 같은 리스트 인스턴스를 변경해서 다시 넘기면 이전과 참조가 같아 갱신이 무시되므로 항상 새 리스트를 만들어 넘겨야 합니다.',
 'interview-question/872.mp3'),
(873, 'COMPOSE', 175, 'NORMAL', true,
 'Compose LazyColumn에는 DiffUtil이 없는데, RecyclerView와 비교했을 때 항목 재사용과 바뀐 항목만 갱신하는 일을 각각 어떤 방식으로 처리하나요?',
 '두 방식 모두 보이는 것만 생성하고 재사용하며 최소한으로 갱신한다는 같은 원칙을 따릅니다. 재사용 단위를 보면 RecyclerView는 viewType별 ViewHolder 풀을 쓰고, LazyColumn은 스크롤로 벗어난 항목의 컴포지션 노드를 재사용 풀에 넣어 같은 contentType의 새 항목에 재사용합니다. 정체성은 RecyclerView가 DiffUtil의 areItemsTheSame(ID)으로 판단하는 반면, LazyColumn은 items()의 key 람다가 같은 역할을 해 상태 보존·애니메이션·최소 재구성을 가능하게 합니다. 내용 변경 감지는 areContentsTheSame에 해당하는 것이 Compose의 건너뛰기 규칙으로, 안정적 인자 기반 건너뛰기(Skipping) 덕분에 Post가 안정적 타입이고 값이 같으면 PostCard는 재실행되지 않습니다. 그래서 항목 데이터 클래스를 불변으로 설계해야 합니다. 초기 표시 속도는 RecyclerView는 인플레이트 비용이 있고, LazyColumn은 인플레이트가 없는 대신 첫 컴포지션 비용이 있습니다.',
 'interview-question/873.mp3'),
(874, 'COMPOSE', 175, 'EASY', true,
 'ViewHolder 패턴이란 무엇이며, RecyclerView는 이를 이용해 항목을 어떻게 재활용하는지 설명해 주세요.',
 'ViewHolder는 항목 View와 그 안의 TextView·ImageView 같은 자식 View 참조를 미리 찾아 보관하는 객체입니다. 과거 ListView에서는 getView()마다 findViewById()를 반복해 느렸는데, ViewHolder 패턴은 이를 한 번만 수행하도록 고안됐고 RecyclerView는 이 패턴을 강제합니다. RecyclerView는 화면 밖으로 나간 ViewHolder를 재활용 풀(RecycledViewPool)에 넣어 둡니다. 새 항목이 필요하면 풀에 같은 viewType의 ViewHolder가 있는지 보고, 있으면 onBindViewHolder()만 호출해 데이터만 교체하고, 없을 때만 비싼 인플레이트를 하는 onCreateViewHolder()를 호출합니다. ViewHolder는 재사용되므로 바인딩 시 VISIBLE/GONE 같은 모든 상태를 설정해야 이전 항목의 아이콘이 남는 버그를 피할 수 있고, onBindViewHolder는 스크롤 중 매우 자주 호출되므로 가볍게 유지해야 합니다.',
 'interview-question/874.mp3'),
(875, 'COMPOSE', 175, 'EASY', true,
 'ScrollView 안에 항목 1,000개를 넣으면 왜 느려지며, RecyclerView와 LazyColumn은 어떤 원리로 이 문제를 해결하나요?',
 'ScrollView에 항목 1,000개를 넣으면 모든 항목을 즉시 생성해 메모리에 올리고 측정까지 하기 때문에 느립니다. 화면에는 10개만 보이는데 1,000개를 모두 만드는 것은 메모리와 시간 모두 낭비입니다. RecyclerView와 LazyColumn은 화면에 보이는 항목과 위아래 약간의 여유분만 생성하고, 나머지는 데이터로만 두었다가 지연(Lazy) 생성합니다. 또 스크롤로 화면 밖으로 벗어난 항목의 View나 컴포지션을 새로 나타나는 항목에 재사용합니다. Compose에서도 Column + verticalScroll에 많은 항목을 넣으면 지연 생성이 아니므로 ScrollView와 같은 문제가 생겨 항목이 많으면 LazyColumn을 써야 하고, LazyColumn 안에 LazyColumn을 세로로 중첩하면 안쪽 높이가 무한대로 측정되어 크래시가 나므로 하나의 LazyColumn에 항목 유형을 섞어 넣습니다.',
 'interview-question/875.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 871
(4693, 871, '프레임당 예산이 약 16ms임을 언급', 'ESSENTIAL', 1),
(4694, 871, '스크롤 성능이 항목 하나의 비용 × 화면에 보이는 개수로 결정됨을 설명', 'ESSENTIAL', 2),
(4695, 871, '데이터 미리 가공·이미지 라이브러리 위임·항목 높이 고정·페이징 중 최소 2개를 최적화 방안으로 제시', 'ESSENTIAL', 3),
(4696, 871, '디버그 빌드가 아닌 릴리스 빌드에서 성능을 측정해야 함을 언급', 'SUPPLEMENTARY', 4),
(4697, 871, 'RecyclerView는 setHasFixedSize(true), Compose는 Modifier.height()로 높이를 고정함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 872
(4698, 872, 'notifyDataSetChanged()는 모든 항목을 다시 바인딩함을 언급', 'ESSENTIAL', 1),
(4699, 872, 'DiffUtil이 이전·새 목록의 차이를 계산해 필요한 notifyItemXxx()만 호출함을 설명', 'ESSENTIAL', 2),
(4700, 872, 'areItemsTheSame은 정체성(ID), areContentsTheSame은 내용을 다룬다는 차이를 설명', 'ESSENTIAL', 3),
(4701, 872, 'notifyDataSetChanged()는 애니메이션이 없음을 언급', 'SUPPLEMENTARY', 4),
(4702, 872, 'ListAdapter가 DiffUtil 계산을 백그라운드 스레드에서 수행함을 언급', 'SUPPLEMENTARY', 5),
(4703, 872, 'submitList에 같은 리스트 인스턴스를 변경해 넘기면 갱신이 무시됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 873
(4704, 873, 'RecyclerView는 viewType별, LazyColumn은 contentType별로 재사용 풀을 나눈다는 차이를 설명', 'ESSENTIAL', 1),
(4705, 873, 'LazyColumn에서 key 람다가 DiffUtil의 areItemsTheSame처럼 정체성 역할을 함을 설명', 'ESSENTIAL', 2),
(4706, 873, 'LazyColumn의 변경 감지는 안정적 인자 기반 건너뛰기(Skipping)로 이루어짐을 설명', 'ESSENTIAL', 3),
(4707, 873, '항목 데이터 클래스를 불변으로 설계해야 건너뛰기가 동작함을 언급', 'SUPPLEMENTARY', 4),
(4708, 873, '초기 표시 시 RecyclerView는 인플레이트, LazyColumn은 첫 컴포지션 비용이 든다는 차이를 언급', 'SUPPLEMENTARY', 5),

-- 질문 874
(4709, 874, 'ViewHolder가 자식 View 참조를 미리 찾아 보관해 findViewById() 반복을 없앰을 설명', 'ESSENTIAL', 1),
(4710, 874, '화면 밖으로 나간 ViewHolder를 재활용 풀(RecycledViewPool)에 넣어 재사용함을 설명', 'ESSENTIAL', 2),
(4711, 874, '풀에 같은 viewType의 ViewHolder가 있으면 onBindViewHolder()만 호출해 데이터만 교체함을 설명', 'ESSENTIAL', 3),
(4712, 874, '재사용된 ViewHolder에 이전 항목 상태가 남지 않도록 바인딩 시 모든 상태를 설정해야 함을 언급', 'SUPPLEMENTARY', 4),
(4713, 874, 'onBindViewHolder는 스크롤 중 자주 호출되므로 가볍게 유지해야 함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 875
(4714, 875, 'ScrollView는 모든 항목을 즉시 생성해 메모리에 올리고 측정까지 하기 때문에 느림을 설명', 'ESSENTIAL', 1),
(4715, 875, '보이는 항목과 약간의 여유분만 생성하고 나머지는 지연(Lazy) 생성함을 설명', 'ESSENTIAL', 2),
(4716, 875, '화면 밖으로 벗어난 항목의 View나 컴포지션을 새 항목에 재사용함을 언급', 'ESSENTIAL', 3),
(4717, 875, 'Compose에서 Column + verticalScroll에 많은 항목을 넣어도 같은 문제가 생김을 언급', 'SUPPLEMENTARY', 4),
(4718, 875, 'LazyColumn을 세로로 중첩하면 안쪽 높이가 무한대로 측정되어 크래시가 남을 언급', 'SUPPLEMENTARY', 5);
