-- Unit: 컬렉션 내부 구조 (Unit ID: 189)
-- Chapter: Java (Chapter ID: 18)
-- Topic: JAVA
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-java-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(941, 'JAVA', 189, 'HARD', true,
 'HashMap에 약 10만 건처럼 대량의 엔트리를 저장해야 할 때, 리사이징이 성능에 어떤 영향을 주고 이를 줄이려면 어떻게 해야 하는지 로드 팩터의 트레이드오프와 함께 설명해 주세요.',
 'HashMap은 엔트리 수가 용량 × 로드 팩터(기본 0.75)를 넘으면 버킷 배열을 2배로 늘리고 모든 엔트리를 재배치합니다. 예를 들어 용량 16이면 13번째 엔트리를 넣을 때 32로 확장됩니다. 이 리사이징은 모든 노드를 순회하므로 O(n) 작업이고, 맵이 크면 순간적인 지연이 발생합니다. 기본 용량으로 10만 건을 넣으면 리사이징이 약 13회 일어납니다. 저장할 개수를 미리 알고 있다면 new HashMap<>((int) (100_000 / 0.75f) + 1)처럼 예상 크기를 고려해 초기 용량을 지정하면 리사이징을 피할 수 있고, Java 19 이상에서는 HashMap.newHashMap(expected)도 쓸 수 있습니다. 로드 팩터 자체도 조정할 수 있지만, 높이면 메모리는 아끼는 대신 충돌이 늘고, 낮추면 충돌은 줄지만 메모리를 더 씁니다. 0.75는 시간과 공간의 절충값입니다. 참고로 리사이징할 때 각 노드를 재해싱하지 않고 새로 추가된 비트 하나만 검사해 원래 버킷(lo)과 원래 인덱스+기존 용량 위치의 버킷(hi) 두 그룹으로 나눕니다. 또한 HashMap은 스레드 안전하지 않아 동시 리사이징 시 데이터 유실이 생길 수 있으므로, 동시 접근에는 ConcurrentHashMap을 써야 합니다.',
 'interview-question/941.mp3'),
(942, 'JAVA', 189, 'NORMAL', true,
 'ArrayList와 LinkedList의 차이는 무엇이며, 실무에서는 어느 쪽을 주로 선택하는지 이유와 함께 설명해 주세요.',
 'ArrayList는 동적 배열이고 LinkedList는 이중 연결 리스트입니다. 인덱스 접근 get(i)은 ArrayList가 O(1)인 반면 LinkedList는 앞이나 뒤 중 가까운 쪽에서 순회해야 하므로 O(n)입니다. 중간 삽입·삭제는 ArrayList가 뒤 원소를 전부 이동해야 해서 O(n)이고, LinkedList도 노드 연결 자체는 O(1)이지만 위치를 찾는 순회 비용 때문에 결국 O(n)입니다. 또 ArrayList는 연속 메모리라 캐시 지역성이 매우 좋지만, LinkedList는 노드가 힙에 흩어져 있어 캐시 지역성이 나쁩니다. 메모리 측면에서도 LinkedList는 원소마다 참조 3개를 가진 노드 객체가 필요해 오버헤드가 큽니다. 그래서 실무에서는 거의 항상 ArrayList를 씁니다. LinkedList가 이론상 유리한 중간 삽입·삭제도 실제로는 ArrayList가 빠른 경우가 많습니다. 양 끝 삽입·삭제가 핵심인 큐·스택 용도라면 LinkedList보다 ArrayDeque가 빠르고 메모리 효율도 좋습니다. 참고로 ArrayList는 처음 add 시 용량 10으로 할당되고, 이후 용량을 초과하면 1.5배씩 확장하며 Arrays.copyOf로 배열을 복사합니다.',
 'interview-question/942.mp3'),
(943, 'JAVA', 189, 'NORMAL', true,
 'HashMap, LinkedHashMap, TreeMap은 내부 구조와 순서 보장 측면에서 어떻게 다르며, 각각 어떤 상황에서 선택하나요?',
 'HashMap은 해시 버킷 배열과 체이닝·트리로 구성되며, 순회 순서를 보장하지 않습니다. 대신 조회·삽입이 평균 O(1)이라 순서가 무의미한 일반적인 키-값 저장에 씁니다. HashMap의 순회 순서는 리사이징 후 바뀔 수 있으므로 순서에 의존하는 코드는 버그입니다. LinkedHashMap은 해시 테이블에 이중 연결 리스트를 더해 삽입 순서(또는 접근 순서)를 유지하고, 조회·삽입은 여전히 평균 O(1)입니다. accessOrder=true로 접근 순서를 쓰고 removeEldestEntry를 활용하면 LRU 캐시를 만들 수 있습니다. TreeMap은 레드-블랙 트리로 구현되어 키 정렬 순서를 유지하며, HashMap의 평균 O(1)과 달리 조회·삽입이 O(log n)입니다. 따라서 subMap이나 ceilingKey 같은 범위 검색, 정렬 순회가 필요할 때 TreeMap을 선택합니다.',
 'interview-question/943.mp3'),
(944, 'JAVA', 189, 'EASY', true,
 'HashMap에서 해시 충돌이 발생하면 어떻게 처리하는지 설명해 주세요.',
 '해시 충돌은 서로 다른 키가 같은 버킷 인덱스를 얻는 것입니다. HashMap은 분리 연결법(Separate Chaining)으로 같은 버킷에 들어온 엔트리들을 연결 리스트로 이어 저장합니다. Java 8부터는 한 버킷의 노드가 8개(TREEIFY_THRESHOLD)를 넘으면 그 버킷의 연결 리스트를 레드-블랙 트리로 변환합니다. 단, 용량이 64(MIN_TREEIFY_CAPACITY) 미만이면 트리화 대신 리사이징을 먼저 수행합니다. 트리화 덕분에 최악의 경우 조회가 O(n)에서 O(log n)으로 개선되며, 해시가 같은 키를 대량 삽입하는 해시 플러딩(Hash DoS) 공격에 대응하려는 목적도 있습니다. 반대로 리사이징으로 노드가 6개(UNTREEIFY_THRESHOLD) 이하로 줄면 다시 연결 리스트로 되돌립니다.',
 'interview-question/944.mp3'),
(945, 'JAVA', 189, 'EASY', true,
 'for-each 문으로 ArrayList를 순회하면서 원소를 삭제하면 어떤 일이 발생하고, 그 이유와 안전하게 삭제하는 방법은 무엇인가요?',
 'for-each 순회 중에 컬렉션의 remove를 직접 호출하면 ConcurrentModificationException이 발생합니다. ArrayList나 HashMap의 이터레이터는 fail-fast로 동작하기 때문입니다. 컬렉션은 구조 변경 횟수를 modCount로 기록하고, 이터레이터가 다음 원소를 꺼낼 때 이 값이 바뀌어 있으면 예외를 던집니다. 안전하게 삭제하려면 이터레이터의 remove를 사용하거나, 내부적으로 안전하게 처리해 주는 removeIf를 사용하면 됩니다. 다만 fail-fast는 버그를 빨리 드러내기 위한 장치일 뿐 동시성 보장이 아니어서, 멀티스레드 환경에서는 예외 없이 조용히 깨질 수도 있습니다. 참고로 CopyOnWriteArrayList나 ConcurrentHashMap의 이터레이터는 스냅샷 또는 약한 일관성으로 동작해 예외를 던지지 않습니다.',
 'interview-question/945.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 941
(5077, 941, '엔트리 수가 용량 × 로드 팩터(기본 0.75)를 넘으면 배열을 2배로 늘림을 설명', 'ESSENTIAL', 1),
(5078, 941, '리사이징은 모든 노드를 순회하는 O(n) 작업이라 큰 맵에서 순간적인 지연이 생김을 언급', 'ESSENTIAL', 2),
(5079, 941, '저장할 개수를 미리 알면 초기 용량을 지정해 리사이징을 피할 수 있음을 언급', 'ESSENTIAL', 3),
(5080, 941, '로드 팩터를 높이면 메모리는 아끼지만 충돌이 늘고 낮추면 반대인 트레이드오프를 설명', 'ESSENTIAL', 4),
(5081, 941, '리사이징 시 재해싱 없이 새로 추가된 비트 하나만 검사해 노드를 두 그룹으로 나눔을 설명', 'SUPPLEMENTARY', 5),
(5082, 941, 'HashMap은 스레드 안전하지 않아 동시 접근에는 ConcurrentHashMap을 써야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 942
(5083, 942, '인덱스 접근 get(i)이 ArrayList는 O(1), LinkedList는 O(n)임을 언급', 'ESSENTIAL', 1),
(5084, 942, 'LinkedList의 중간 삽입·삭제도 위치를 찾는 순회 비용 때문에 O(n)임을 설명', 'ESSENTIAL', 2),
(5085, 942, '연속 메모리인 ArrayList와 노드가 힙에 흩어진 LinkedList의 캐시 지역성 차이를 설명', 'ESSENTIAL', 3),
(5086, 942, '실무에서는 거의 항상 ArrayList를 선택함을 언급', 'ESSENTIAL', 4),
(5087, 942, 'LinkedList는 원소당 노드 객체(참조 3개)가 필요해 메모리 오버헤드가 큼을 언급', 'SUPPLEMENTARY', 5),
(5088, 942, '양 끝 삽입·삭제가 핵심인 큐·스택 용도에는 LinkedList 대신 ArrayDeque가 적합함을 언급', 'SUPPLEMENTARY', 6),
(5089, 942, 'ArrayList는 용량 초과 시 약 1.5배로 확장하며 배열을 복사함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 943
(5090, 943, 'HashMap은 순회 순서를 보장하지 않음을 명시', 'ESSENTIAL', 1),
(5091, 943, 'LinkedHashMap은 해시 테이블에 이중 연결 리스트를 더해 삽입 순서를 유지함을 설명', 'ESSENTIAL', 2),
(5092, 943, 'TreeMap이 레드-블랙 트리로 키 정렬 순서를 유지함을 설명', 'ESSENTIAL', 3),
(5093, 943, '범위 검색이나 정렬 순회가 필요할 때 TreeMap을 선택함을 언급', 'ESSENTIAL', 4),
(5094, 943, 'HashMap 평균 O(1)과 TreeMap O(log n)의 조회 복잡도 차이를 비교', 'SUPPLEMENTARY', 5),
(5095, 943, 'LinkedHashMap의 accessOrder=true 설정으로 LRU 캐시를 만들 수 있음을 언급', 'SUPPLEMENTARY', 6),
(5096, 943, 'HashMap의 순회 순서는 리사이징 후 바뀔 수 있어 순서에 의존하면 버그임을 언급', 'SUPPLEMENTARY', 7),

-- 질문 944
(5097, 944, '같은 버킷의 엔트리를 연결 리스트로 잇는 분리 연결법(체이닝)을 사용함을 설명', 'ESSENTIAL', 1),
(5098, 944, 'Java 8부터 한 버킷의 노드가 8개를 넘으면 레드-블랙 트리로 변환함을 언급', 'ESSENTIAL', 2),
(5099, 944, '트리화로 최악의 경우 조회가 O(n)에서 O(log n)으로 개선됨을 언급', 'ESSENTIAL', 3),
(5100, 944, '용량이 64 미만이면 트리화 대신 리사이징을 먼저 수행함을 언급', 'SUPPLEMENTARY', 4),
(5101, 944, '트리화가 해시 플러딩(Hash DoS) 공격 대응 목적이기도 함을 언급', 'SUPPLEMENTARY', 5),
(5102, 944, '리사이징으로 노드가 6개 이하로 줄면 다시 연결 리스트로 되돌림을 언급', 'SUPPLEMENTARY', 6),

-- 질문 945
(5103, 945, 'ConcurrentModificationException이 발생함을 언급', 'ESSENTIAL', 1),
(5104, 945, '구조 변경 횟수(modCount)가 바뀌면 이터레이터가 예외를 던지는 fail-fast 동작을 설명', 'ESSENTIAL', 2),
(5105, 945, '이터레이터의 remove 또는 removeIf 중 최소 1개를 안전한 삭제 방법으로 제시', 'ESSENTIAL', 3),
(5106, 945, 'fail-fast는 버그를 빨리 드러내는 장치일 뿐 동시성 보장이 아님을 언급', 'SUPPLEMENTARY', 4),
(5107, 945, 'CopyOnWriteArrayList·ConcurrentHashMap의 이터레이터는 예외를 던지지 않음을 언급', 'SUPPLEMENTARY', 5);
