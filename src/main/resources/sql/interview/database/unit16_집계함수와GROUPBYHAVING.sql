-- Unit: 집계 함수와 GROUP BY, HAVING (Unit ID: 245)
-- Chapter: 데이터베이스 (Chapter ID: 4)
-- Topic: DATABASE
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-database-unit16 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1404, 'DATABASE', 245, 'HARD', true,
 '값이 없는 행을 NULL로 둔 컬럼의 평균을 구했더니 전체 행 기준 기대값보다 높게 나왔습니다. 원인과 해결 방법은 무엇인가요?',
 '원인은 AVG가 NULL을 제외하고 계산하기 때문입니다. AVG는 합계를 전체 행 수가 아니라 NULL이 아닌 행 수로 나누므로, NULL인 행이 분모에서 빠져 전체 행 기준으로 기대한 값보다 평균이 높게 나옵니다. 집계 함수는 COUNT(*)를 제외하면 모두 NULL을 제외하고 계산합니다. NULL을 0으로 간주해 전체 평균을 구하려면 COALESCE로 NULL을 0으로 바꾼 뒤 평균을 내거나, SUM을 COUNT(*)로 나누면 됩니다. COUNT(*)는 NULL 여부와 무관하게 행 자체의 개수를 세기 때문입니다.',
 'interview-question/1404.mp3'),
(1405, 'DATABASE', 245, 'NORMAL', true,
 'WHERE와 HAVING은 둘 다 조건 필터인데, 어떤 차이가 있나요?',
 'WHERE와 HAVING은 둘 다 조건 필터지만 적용 대상과 실행 시점이 다릅니다. 실행 순서는 FROM, WHERE, GROUP BY, HAVING, SELECT 순입니다. WHERE는 GROUP BY 이전에 실행되어 그룹화 전의 개별 행을 걸러내고, HAVING은 GROUP BY 이후에 실행되어 집계 결과로 그룹을 걸러냅니다. 그래서 HAVING에서는 집계 함수를 사용할 수 있지만 WHERE에서는 사용할 수 없습니다. HAVING으로도 걸 수 있는 일반 조건은 WHERE에 두는 것이 좋은데, WHERE가 먼저 실행되어 그룹화 대상 행 수를 줄이므로 성능상 유리하기 때문입니다.',
 'interview-question/1405.mp3'),
(1406, 'DATABASE', 245, 'NORMAL', true,
 '집계 함수만 쓸 때와 GROUP BY와 함께 쓸 때 결과는 어떻게 달라지나요?',
 '집계 함수는 여러 행의 값을 입력받아 단 하나의 값을 반환하는 함수라서, GROUP BY 없이 집계 함수만 쓰면 여러 행이 하나의 값으로 요약됩니다. 반면 GROUP BY와 함께 쓰면 지정한 컬럼의 값이 같은 행끼리 그룹으로 분할한 뒤, 각 그룹마다 집계 함수를 한 번씩 적용해 그룹당 한 행을 반환합니다. 예를 들어 부서 컬럼으로 묶어 평균 급여를 구하면 부서마다 한 행씩 평균이 나옵니다.',
 'interview-question/1406.mp3'),
(1407, 'DATABASE', 245, 'EASY', true,
 'GROUP BY의 ROLLUP은 무엇이고 언제 쓰나요?',
 'ROLLUP은 GROUP BY의 확장 기능으로, 그룹별 집계 결과에 소계와 총계 행을 추가로 생성합니다. 예를 들어 ROLLUP(A, B)는 (A, B) 조합별 집계에 더해 A별 소계와 전체 총계를 계층적으로 만들어 줍니다. 이때 소계·총계 행에서 그룹화되지 않은 컬럼은 NULL로 표시됩니다. 그래서 부서별·직급별 합계와 함께 부서별 소계, 전체 총계가 필요한 보고서성 집계에 사용합니다. 참고로 CUBE는 여기서 더 나아가 가능한 모든 조합의 집계를 생성합니다.',
 'interview-question/1407.mp3'),
(1408, 'DATABASE', 245, 'EASY', true,
 'GROUP BY를 쓸 때 그룹화하지 않은 컬럼을 SELECT 절에 넣을 수 없는 이유는 무엇인가요?',
 'GROUP BY를 사용하면 SELECT 절에는 GROUP BY에 명시한 컬럼과 집계 함수만 올 수 있습니다. GROUP BY는 그룹당 한 행만 출력하는데, 그룹화되지 않은 컬럼은 그룹 안에 여러 값이 존재해서 그중 어떤 값을 보여줄지 정할 수 없기 때문입니다. 표준 SQL에서는 이런 비집계 컬럼을 쓰면 오류가 발생합니다. MySQL은 ONLY_FULL_GROUP_BY 설정을 해제하면 임의의 한 값을 반환해 버리는데, 이것이 버그의 원인이 되므로 주의해야 합니다.',
 'interview-question/1408.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1404
(6510, 1404, 'AVG는 합계를 NULL이 아닌 행 수로 나눈다고 설명', 'ESSENTIAL', 1),
(6511, 1404, 'COALESCE로 NULL을 0으로 바꿔 평균 내기·SUM을 COUNT(*)로 나누기 중 최소 1개를 해결책으로 제시', 'ESSENTIAL', 2),
(6512, 1404, 'AVG는 NULL을 제외하고 계산한다고 언급', 'SUPPLEMENTARY', 3),
(6513, 1404, 'COUNT(*)를 제외한 집계 함수는 모두 NULL을 제외한다고 언급', 'SUPPLEMENTARY', 4),
(6514, 1404, 'COUNT(*)는 NULL 여부와 무관하게 행 자체의 개수를 센다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1405
(6515, 1405, 'WHERE는 개별 행을, HAVING은 그룹을 필터링한다고 구분', 'ESSENTIAL', 1),
(6516, 1405, 'WHERE는 GROUP BY 이전에, HAVING은 GROUP BY 이후에 실행된다고 구분', 'ESSENTIAL', 2),
(6517, 1405, 'HAVING에서는 집계 함수를 사용할 수 있고 WHERE에서는 불가능하다고 구분', 'ESSENTIAL', 3),
(6518, 1405, '일반 조건을 WHERE에 두면 그룹화 대상 행 수가 줄어 성능상 유리하다고 언급', 'SUPPLEMENTARY', 4),
(6519, 1405, 'FROM, WHERE, GROUP BY, HAVING, SELECT 순으로 실행된다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1406
(6520, 1406, 'GROUP BY 없이 집계 함수만 쓰면 여러 행이 하나의 값으로 요약된다고 설명', 'ESSENTIAL', 1),
(6521, 1406, 'GROUP BY와 함께 쓰면 그룹당 한 행을 반환한다고 설명', 'ESSENTIAL', 2),
(6522, 1406, 'GROUP BY는 지정한 컬럼의 값이 같은 행끼리 그룹으로 분할한다고 설명', 'SUPPLEMENTARY', 3),
(6523, 1406, '각 그룹마다 집계 함수를 한 번씩 적용한다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1407
(6524, 1407, '그룹별 집계에 소계·총계 행을 추가로 생성한다고 설명', 'ESSENTIAL', 1),
(6525, 1407, '소계·총계가 필요한 보고서성 집계에 사용한다고 언급', 'ESSENTIAL', 2),
(6526, 1407, 'ROLLUP(A, B)은 A별 소계와 전체 총계를 계층적으로 생성한다고 설명', 'SUPPLEMENTARY', 3),
(6527, 1407, '소계·총계 행에서 그룹화되지 않은 컬럼은 NULL로 표시된다고 언급', 'SUPPLEMENTARY', 4),
(6528, 1407, 'CUBE는 가능한 모든 조합의 집계를 생성한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1408
(6529, 1408, 'GROUP BY를 쓰면 그룹당 한 행만 출력된다고 설명', 'ESSENTIAL', 1),
(6530, 1408, '그룹화되지 않은 컬럼은 그룹 안에 여러 값이 존재한다고 설명', 'ESSENTIAL', 2),
(6531, 1408, 'SELECT 절에는 GROUP BY에 명시한 컬럼과 집계 함수만 올 수 있다고 언급', 'SUPPLEMENTARY', 3),
(6532, 1408, '표준 SQL에서는 비집계 컬럼을 쓰면 오류가 발생한다고 언급', 'SUPPLEMENTARY', 4),
(6533, 1408, 'MySQL은 설정에 따라 임의의 한 값을 반환해 버그의 원인이 된다고 언급', 'SUPPLEMENTARY', 5);
