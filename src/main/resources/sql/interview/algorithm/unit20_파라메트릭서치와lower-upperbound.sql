-- Unit: 파라메트릭 서치와 lower/upper bound (Unit ID: 232)
-- Chapter: 알고리즘 (Chapter ID: 2)
-- Topic: ALGORITHM
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-algorithm-unit20 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1339, 'ALGORITHM', 232, 'HARD', true,
 '정렬된 큰 배열에서 특정 값 범위에 속하는 원소 개수를 여러 번 구해야 합니다. 어떻게 빠르게 구할 수 있나요?',
 '정렬된 배열이므로 lower bound와 upper bound로 구간의 두 경계를 찾고 그 차를 구하면 됩니다. 구간이 a부터 b까지라면 a 이상인 값이 처음 나타나는 위치를 lower bound로, b 초과인 값이 처음 나타나는 위치를 upper bound로 찾고, upper bound(b)에서 lower bound(a)를 뺀 값이 구간에 속하는 원소 개수입니다. lower bound와 upper bound는 정렬된 배열에서 경계를 찾는 이진 탐색의 변형이고, 둘 다 시간 복잡도가 O(log n)입니다. 단순 이진 탐색은 같은 값이 여러 개일 때 그중 임의의 위치를 반환하므로 경계가 필요한 이 문제에는 lower bound와 upper bound를 씁니다. Python에서는 bisect_left와 bisect_right, C++에서는 std::lower_bound와 std::upper_bound를 사용할 수 있습니다.',
 NULL),
(1340, 'ALGORITHM', 232, 'NORMAL', true,
 '일반 이진 탐색과 파라메트릭 서치는 탐색 공간과 판단 기준이 어떻게 다른가요?',
 '일반 이진 탐색은 배열 속의 특정 값을 찾는 방법이라 정렬된 배열의 인덱스를 탐색 공간으로 삼고, 가운데 값이 목표 값과 같은지를 기준으로 범위를 좁힙니다. 결과는 값의 위치이거나, 없으면 실패(-1)입니다. 반면 파라메트릭 서치는 조건을 만족하는 최적의 답을 찾는 방법이라 답이 될 수 있는 값의 범위를 탐색 공간으로 삼고, 가운데 값을 답으로 가정했을 때 결정 함수가 참인지 거짓인지를 기준으로 범위를 좁힙니다. 최종적으로는 조건을 만족하는 경계값을 얻습니다.',
 NULL),
(1341, 'ALGORITHM', 232, 'NORMAL', true,
 '단순 이진 탐색과 lower bound는 찾는 값이 없거나 여러 개일 때 반환 결과가 어떻게 다른가요?',
 '찾는 값이 배열에 없으면 단순 이진 탐색은 실패를 뜻하는 -1을 반환하지만, lower bound는 그 값을 삽입할 수 있는 위치를 반환합니다. 모든 원소가 target보다 작으면 삽입 위치는 배열의 끝, 즉 배열 길이가 됩니다. 같은 값이 여러 개 있을 때 단순 이진 탐색은 그중 임의의 위치를 반환하는 반면, lower bound는 target 이상이 처음 나타나는 가장 왼쪽 경계를 반환합니다. 구현에서도 lower bound는 값을 찾아도 즉시 반환하지 않고 범위가 한 점으로 수렴할 때까지 계속 좁힌다는 점이 다릅니다.',
 NULL),
(1342, 'ALGORITHM', 232, 'EASY', true,
 '파라메트릭 서치란 무엇이고, 어떤 성질이 있어야 적용할 수 있나요?',
 '파라메트릭 서치는 조건을 만족하는 최댓값이나 최솟값을 구하라는 최적화 문제를, 값 x가 조건을 만족하는가라는 예/아니오 결정 문제로 바꾸어 이진 탐색으로 해결하는 기법입니다. 적용하려면 결정 함수의 답이 어느 지점을 기준으로 예에서 아니오로, 또는 아니오에서 예로 한 번만 바뀌는 단조성이 있어야 하고, 이 성질이 있으면 그 경계를 이진 탐색으로 찾을 수 있습니다. 실제로 문제를 볼 때는 답을 고정하면 판정이 쉬워지는가와 판정 결과가 단조적인가 두 가지를 먼저 확인하고, 둘 다 성립하면 답의 범위에 대한 이진 탐색으로 풉니다. 나무 자르기나 랜선 자르기처럼 조건을 만족하는 최대 길이를 구하는 문제가 대표적인 유형입니다.',
 NULL),
(1343, 'ALGORITHM', 232, 'EASY', true,
 '정렬된 배열에서 lower bound와 upper bound는 각각 어떤 위치를 찾는 연산인가요?',
 'lower bound와 upper bound는 정렬된 배열에서 특정 값의 삽입 위치, 즉 경계를 찾는 이진 탐색의 변형입니다. 목표 값과 같은 값이 여러 개 있을 때 경계가 필요하면 이 두 연산을 사용합니다. lower bound는 target 이상인 값이 처음 나타나는 인덱스를, upper bound는 target 초과인 값이 처음 나타나는 인덱스를 찾습니다. 예를 들어 4가 세 번 연속으로 있으면 lower bound는 첫 번째 4의 위치를, upper bound는 마지막 4 바로 다음 위치를 가리킵니다. 두 함수의 구현 차이는 이상과 초과를 가르는 비교 연산자 하나뿐입니다.',
 NULL);

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1339
(6189, 1339, '구간 시작값 이상이 처음 나오는 위치를 lower bound로 찾는다고 설명', 'ESSENTIAL', 1),
(6190, 1339, '구간 끝값 초과가 처음 나오는 위치를 upper bound로 찾는다고 설명', 'ESSENTIAL', 2),
(6191, 1339, '끝값의 upper bound에서 시작값의 lower bound를 뺀 값이 원소 개수라고 설명', 'ESSENTIAL', 3),
(6192, 1339, '경계를 찾는 연산이 O(log n)에 동작한다고 언급', 'ESSENTIAL', 4),
(6193, 1339, '단순 이진 탐색은 중복 값 중 임의의 위치를 반환한다고 언급', 'SUPPLEMENTARY', 5),
(6194, 1339, 'bisect_left·bisect_right·std::lower_bound·std::upper_bound 중 최소 1개를 언급', 'SUPPLEMENTARY', 6),

-- 질문 1340
(6195, 1340, '이진 탐색은 정렬된 배열의 인덱스를 탐색 공간으로 삼는다고 설명', 'ESSENTIAL', 1),
(6196, 1340, '파라메트릭 서치는 답이 될 수 있는 값의 범위를 탐색 공간으로 삼는다고 설명', 'ESSENTIAL', 2),
(6197, 1340, '이진 탐색은 가운데 값이 목표 값과 같은지로 판단한다고 설명', 'ESSENTIAL', 3),
(6198, 1340, '파라메트릭 서치는 결정 함수의 참/거짓으로 판단한다고 설명', 'ESSENTIAL', 4),
(6199, 1340, '파라메트릭 서치의 종료 결과가 조건을 만족하는 경계값이라고 언급', 'SUPPLEMENTARY', 5),
(6200, 1340, '이진 탐색은 값을 못 찾으면 실패(-1)로 끝난다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1341
(6201, 1341, '값이 없을 때 단순 이진 탐색은 실패(-1)를 반환한다고 설명', 'ESSENTIAL', 1),
(6202, 1341, '값이 없을 때 lower bound는 삽입 가능한 위치를 반환한다고 설명', 'ESSENTIAL', 2),
(6203, 1341, '같은 값이 여러 개일 때 단순 이진 탐색은 그중 임의의 위치를 반환한다고 설명', 'ESSENTIAL', 3),
(6204, 1341, '같은 값이 여러 개일 때 lower bound는 가장 왼쪽 경계를 반환한다고 설명', 'ESSENTIAL', 4),
(6205, 1341, 'lower bound는 값을 찾아도 즉시 반환하지 않고 범위가 한 점으로 수렴할 때까지 좁힌다고 언급', 'SUPPLEMENTARY', 5),
(6206, 1341, '모든 원소가 target보다 작으면 삽입 위치가 배열의 끝이 된다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1342
(6207, 1342, '최적화 문제를 예/아니오의 결정 문제로 바꾸는 기법이라고 설명', 'ESSENTIAL', 1),
(6208, 1342, '결정 함수의 답이 한 번만 바뀌는 단조성이 있어야 한다고 설명', 'ESSENTIAL', 2),
(6209, 1342, '결정 함수의 답이 바뀌는 경계를 이진 탐색으로 찾는다고 설명', 'ESSENTIAL', 3),
(6210, 1342, '답을 고정하면 판정이 쉬워지는지 먼저 확인해야 한다고 언급', 'SUPPLEMENTARY', 4),
(6211, 1342, '나무 자르기·랜선 자르기·공유기 설치·예산 중 최소 1개를 예시로 제시', 'SUPPLEMENTARY', 5),

-- 질문 1343
(6212, 1343, 'lower bound는 target 이상인 값이 처음 나타나는 인덱스를 찾는다고 설명', 'ESSENTIAL', 1),
(6213, 1343, 'upper bound는 target 초과인 값이 처음 나타나는 인덱스를 찾는다고 설명', 'ESSENTIAL', 2),
(6214, 1343, '두 함수의 구현 차이가 비교 연산자 하나뿐이라고 언급', 'SUPPLEMENTARY', 3),
(6215, 1343, '같은 값이 여러 개일 때 경계를 찾는 데 쓰인다고 언급', 'SUPPLEMENTARY', 4);
