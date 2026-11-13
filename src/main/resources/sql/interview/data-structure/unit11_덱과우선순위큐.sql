-- Unit: 덱과 우선순위 큐 (Unit ID: 228)
-- Chapter: 자료구조 (Chapter ID: 1)
-- Topic: DATA_STRUCTURE
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-data-structure-unit11 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1319, 'DATA_STRUCTURE', 228, 'HARD', true,
 '고정 크기 구간을 한 칸씩 옮기며 구간 최댓값을 선형 시간에 구하려 합니다. 스택이나 큐가 아니라 덱을 써야 하는 이유는 무엇인가요?',
 '이 문제는 윈도우를 옮기는 동안 Front와 Rear 양 끝 모두에서 제거가 필요합니다. 윈도우를 벗어난 인덱스는 Front에서 제거하고, 현재 값보다 작은 값은 Rear에서 제거한 뒤 현재 인덱스를 Rear에 넣습니다. 이처럼 양 끝에서 삽입과 삭제가 모두 필요하므로 덱이 아니면 구현할 수 없는 대표적인 사례입니다. 덱은 Front와 Rear 양 끝에서의 삽입과 삭제가 모두 O(1)입니다. 덱에는 인덱스를 저장하고 값이 큰 순서를 유지하며, Front가 항상 윈도우 최댓값입니다. 이 방식으로 전체를 O(n)에 해결할 수 있습니다.',
 'interview-question/1319.mp3'),
(1320, 'DATA_STRUCTURE', 228, 'NORMAL', true,
 '우선순위 큐를 배열이나 연결리스트가 아니라 힙으로 구현하는 이유는 무엇인가요?',
 '정렬되지 않은 배열이나 연결리스트로 구현하면 삽입은 O(1)이지만 최우선 원소 삭제가 O(n)이고, 삭제 시 전체 탐색이 필요합니다. 정렬된 배열이나 연결리스트로 구현하면 최우선 원소 삭제는 O(1)이지만 삽입이 O(n)이고, 삽입 시 위치 탐색이 필요합니다. 반면 힙은 삽입과 삭제가 모두 O(log n)으로 균형 잡혀 있어 우선순위 큐의 표준 구현 방식으로 사용됩니다.',
 'interview-question/1320.mp3'),
(1321, 'DATA_STRUCTURE', 228, 'NORMAL', true,
 '덱으로 스택을 대체할 때와 큐를 대체할 때, 사용하는 끝은 어떻게 다른가요?',
 '덱은 사용하는 끝을 제한하는 방식으로 스택과 큐를 모두 대체할 수 있습니다. 스택으로 쓸 때는 한쪽 끝만 사용합니다. 예를 들어 addLast로 Rear에 삽입하고 removeLast로 같은 Rear에서 삭제하며, LIFO로 동작합니다. 큐로 쓸 때는 서로 반대쪽 끝을 사용합니다. 예를 들어 addLast로 Rear에 삽입하고 removeFirst로 Front에서 삭제하며, FIFO로 동작합니다. 참고로 Java 공식 문서는 레거시 Stack 클래스 대신 ArrayDeque를 스택 용도로 사용할 것을 권장합니다.',
 'interview-question/1321.mp3'),
(1322, 'DATA_STRUCTURE', 228, 'EASY', true,
 '덱이란 어떤 자료구조이고, 어떤 연산에 최적화되어 있나요?',
 '덱은 Double-Ended Queue의 줄임말로, 큐의 Front와 Rear 양쪽 끝 모두에서 삽입과 삭제를 허용하는 자료구조입니다. 덱은 양 끝 연산에 최적화되어 있어서 Front나 Rear에 데이터를 삽입하거나 제거하는 연산, 양 끝 데이터를 조회하는 연산이 모두 O(1)입니다. 반면 중간 위치의 원소를 탐색하거나 삭제하는 연산은 O(n)이 걸립니다. 한쪽 끝만 쓰면 스택처럼, 반대쪽 끝을 쓰면 큐처럼 동작하기 때문에 스택과 큐를 일반화한 자료구조라고 할 수 있습니다.',
 'interview-question/1322.mp3'),
(1323, 'DATA_STRUCTURE', 228, 'EASY', true,
 '우선순위 큐란 무엇이고, 어떤 상황에서 쓰이나요?',
 '우선순위 큐는 각 데이터가 우선순위를 가지며, 삭제할 때 들어온 순서가 아니라 우선순위가 가장 높은 데이터가 먼저 나가는 자료구조입니다. 다익스트라 최단 경로, 힙 정렬, 운영체제의 작업 스케줄링처럼 가장 우선순위가 높은 것부터 처리해야 하는 곳에서 핵심 자료구조로 사용됩니다. 표준 구현 방식은 힙입니다.',
 'interview-question/1323.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1319
(6092, 1319, '윈도우를 벗어난 인덱스를 Front에서 제거한다고 설명', 'ESSENTIAL', 1),
(6093, 1319, '현재 값보다 작은 값을 Rear에서 제거한다고 설명', 'ESSENTIAL', 2),
(6094, 1319, '덱은 양 끝에서의 삽입과 삭제가 O(1)이라고 설명', 'ESSENTIAL', 3),
(6095, 1319, '덱에 값이 큰 순서를 유지한다고 언급', 'SUPPLEMENTARY', 4),
(6096, 1319, '덱에 원소의 인덱스를 저장한다고 언급', 'SUPPLEMENTARY', 5),
(6097, 1319, 'Front가 항상 윈도우 최댓값이라고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1320
(6098, 1320, '정렬되지 않은 배열·연결리스트는 최우선 원소 삭제가 O(n)이라고 설명', 'ESSENTIAL', 1),
(6099, 1320, '정렬된 배열·연결리스트는 삽입이 O(n)이라고 설명', 'ESSENTIAL', 2),
(6100, 1320, '힙은 삽입과 삭제가 모두 O(log n)이라고 설명', 'ESSENTIAL', 3),
(6101, 1320, '정렬되지 않은 배열·연결리스트는 삽입이 O(1)이라고 언급', 'SUPPLEMENTARY', 4),
(6102, 1320, '정렬된 배열·연결리스트는 최우선 원소 삭제가 O(1)이라고 언급', 'SUPPLEMENTARY', 5),
(6103, 1320, '삭제 시 전체 탐색·삽입 시 위치 탐색 중 최소 1개를 O(n)의 원인으로 언급', 'SUPPLEMENTARY', 6),

-- 질문 1321
(6104, 1321, '스택 대체 시 한쪽 끝에서만 삽입과 삭제를 한다고 설명', 'ESSENTIAL', 1),
(6105, 1321, '큐 대체 시 한쪽 끝에 삽입하고 반대쪽 끝에서 삭제한다고 설명', 'ESSENTIAL', 2),
(6106, 1321, '스택은 LIFO, 큐는 FIFO로 동작한다고 구분', 'SUPPLEMENTARY', 3),
(6107, 1321, '큐 대체 시 Rear에 삽입하고 Front에서 삭제한다고 언급', 'SUPPLEMENTARY', 4),
(6108, 1321, 'Java 공식 문서가 Stack 대신 ArrayDeque를 스택 용도로 권장한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1322
(6109, 1322, 'Front와 Rear 양쪽 끝에서 삽입과 삭제를 모두 허용한다고 설명', 'ESSENTIAL', 1),
(6110, 1322, '양 끝에서의 삽입과 삭제가 O(1)이라고 설명', 'ESSENTIAL', 2),
(6111, 1322, '중간 위치의 원소를 탐색하거나 삭제하는 연산은 O(n)이 걸린다고 언급', 'SUPPLEMENTARY', 3),
(6112, 1322, '덱을 스택과 큐를 일반화한 자료구조라고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1323
(6113, 1323, '들어온 순서가 아니라 우선순위가 가장 높은 데이터가 먼저 나간다고 설명', 'ESSENTIAL', 1),
(6114, 1323, '다익스트라 최단 경로·힙 정렬·작업 스케줄링 중 최소 1개를 활용처로 제시', 'ESSENTIAL', 2),
(6115, 1323, '각 데이터가 우선순위를 가진다고 언급', 'SUPPLEMENTARY', 3),
(6116, 1323, '힙이 우선순위 큐의 표준 구현 방식이라고 언급', 'SUPPLEMENTARY', 4);
