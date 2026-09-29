-- Unit: 조인 (Unit ID: 50)
-- Chapter: 데이터베이스 (Chapter ID: 4)
-- Topic: DATABASE
-- Source: gravit-interview-contents-generator/output/2026-09-23/cs-database-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(246, 'DATABASE', 50, 'HARD', true,
 '사용자·주문·상품 테이블을 LEFT JOIN으로 연결해 조회했더니 결과에 같은 사용자 행이 여러 번 나오고 응답도 느려졌습니다. 중복이 생기는 이유와 성능을 개선하기 위해 무엇을 점검하시겠습니까?',
 '먼저 중복 행은 1:N 관계 조인 때문에 생깁니다. 사용자 한 명에 주문이 여러 건이면 조인 결과에서 같은 사용자 행이 주문 수만큼 반복되고, 여기에 상품 테이블까지 이어 붙으면 중복이 더 늘어납니다. 다중 조인은 table_a와 table_b를 먼저 조인한 뒤 그 결과에 table_c를 결합하는 식으로 순차 실행되기 때문입니다. 중복 제거가 목적이라면 DISTINCT를 쓰거나 GROUP BY로 집계해 행을 하나로 묶습니다. 성능 쪽은 세 가지를 점검하겠습니다. 첫째, 조인 키 컬럼에 인덱스를 생성합니다. 조인 키에 인덱스가 있으면 조인 성능이 크게 향상됩니다. 둘째, 조인 순서를 조정합니다. 조인 순서에 따라 성능이 달라질 수 있으므로 일반적으로 결과 행 수가 적은 테이블을 먼저 조인합니다. 셋째, SELECT *를 쓰지 않고 필요한 컬럼만 명시해 데이터 전송량을 줄입니다. 추가로 LEFT JOIN을 썼으니 오른쪽 테이블이 비어 NULL이 채워지는 행에 대해 COALESCE()나 IFNULL()로 기본값 처리를 해 두는 것도 함께 고려하겠습니다.',
 'interview-question/246.mp3'),
(247, 'DATABASE', 50, 'NORMAL', true,
 'INNER JOIN과 LEFT JOIN은 어떤 차이가 있으며, 같은 데이터에 두 조인을 각각 적용하면 결과가 어떻게 달라지는지 설명해 주세요.',
 'INNER JOIN은 두 테이블에서 조인 조건을 만족하는 행만 반환합니다. 양쪽 테이블 모두에 매칭되는 데이터가 있어야 결과에 포함됩니다. 반면 LEFT JOIN은 왼쪽 테이블의 모든 행을 반환하고 오른쪽 테이블에서 매칭되는 행을 결합하며, 매칭되는 행이 없으면 NULL로 채웁니다. 예를 들어 table_a에 id 1, 2, 3이 있고 table_b에 id 1, 3이 있을 때 id로 INNER JOIN하면 결과는 1과 3 두 행만 남습니다. 같은 데이터로 LEFT JOIN하면 1, 2, 3 세 행이 모두 나오고 매칭이 없는 2번 행의 value 컬럼은 NULL이 됩니다. 즉 INNER JOIN 결과 행 수가 LEFT JOIN보다 적거나 같습니다. 그래서 LEFT JOIN을 쓸 때는 NULL 처리가 필요하고, COALESCE()나 IFNULL() 함수로 기본값을 설정해 두는 것이 좋습니다.',
 'interview-question/247.mp3'),
(248, 'DATABASE', 50, 'NORMAL', true,
 'RIGHT JOIN과 FULL OUTER JOIN의 차이는 무엇이며, MySQL에서 FULL OUTER JOIN이 필요할 때는 어떻게 구현하시겠습니까?',
 'RIGHT JOIN은 오른쪽 테이블의 모든 행을 반환하고 왼쪽 테이블에서 매칭되는 행을 결합하며, 왼쪽에 매칭되는 행이 없으면 NULL로 채웁니다. 즉 기준이 되는 테이블이 오른쪽 한쪽뿐입니다. FULL OUTER JOIN은 양쪽 테이블의 모든 행을 반환하고 매칭되지 않는 행은 NULL로 채우므로, 왼쪽에만 있는 행과 오른쪽에만 있는 행이 모두 결과에 남습니다. 예를 들어 table_a에 id 1, 2가 있고 table_b에 id 1, 3이 있으면 FULL OUTER JOIN 결과는 1, 2, 3 세 행이 되고 2번 행의 value와 3번 행의 name이 각각 NULL이 됩니다. 다만 MySQL은 FULL OUTER JOIN을 직접 지원하지 않습니다. 그래서 같은 조인 조건으로 LEFT JOIN한 결과와 RIGHT JOIN한 결과를 UNION으로 결합해 동일한 결과를 만듭니다.',
 'interview-question/248.mp3'),
(249, 'DATABASE', 50, 'EASY', true,
 'CROSS JOIN은 어떤 조인이며 어떤 결과를 반환하는지 설명해 주세요.',
 'CROSS JOIN은 두 테이블의 모든 행을 조합한 카테시안 곱을 반환하는 조인입니다. 다른 조인과 달리 ON으로 조인 조건을 주지 않고, 조인 조건 없이 모든 경우의 수를 생성합니다. 구문은 SELECT A.column, B.column FROM table_a A CROSS JOIN table_b B 형태입니다. 그래서 결과 행 수는 두 테이블 행 수의 곱이 됩니다. 예를 들어 table_a에 id 1, 2가 있고 table_b에 value 100, 200이 있으면 결과는 (1,100), (1,200), (2,100), (2,200)이 나옵니다. 이렇게 결과가 급격히 늘어날 수 있으므로, 의도하지 않은 카테시안 곱이 생기지 않도록 일반 조인에서는 명확한 조인 조건을 사용하는 것이 중요합니다.',
 'interview-question/249.mp3'),
(250, 'DATABASE', 50, 'EASY', true,
 '조인(JOIN)이란 무엇이며, 관계형 데이터베이스에서 조인이 필요한 이유는 무엇인가요?',
 '조인은 두 개 이상의 테이블을 연결하여 데이터를 조회하는 SQL 기법입니다. 관계형 데이터베이스에서는 데이터를 여러 테이블에 나누어 저장하고, 필요할 때 조인으로 결합해 원하는 정보를 추출합니다. 조인이 필요한 첫 번째 이유는 데이터 중복 최소화입니다. 정규화를 통해 데이터를 여러 테이블로 분산 저장하면 중복 데이터가 제거되어 저장 공간을 절약하고 일관성을 유지할 수 있는데, 이렇게 흩어진 데이터를 다시 하나의 결과로 보려면 조인이 필요합니다. 두 번째 이유는 유연한 데이터 조회입니다. 필요한 데이터만 선택적으로 결합할 수 있고 다양한 조건으로 데이터를 검색할 수 있습니다. 예를 들어 사용자, 주문, 상품 정보를 각각 다른 테이블에 저장해 두고 조인으로 연결하면 특정 사용자의 주문 내역과 상품명을 한 번에 조회할 수 있습니다.',
 'interview-question/250.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 246
(1259, 246, '1:N 관계 조인에서 중복 행이 발생할 수 있음을 언급', 'ESSENTIAL', 1),
(1260, 246, 'DISTINCT 또는 GROUP BY로 중복 행을 제거하는 방법을 제시', 'ESSENTIAL', 2),
(1261, 246, '조인 키 컬럼에 인덱스를 생성하면 조인 성능이 향상됨을 언급', 'ESSENTIAL', 3),
(1262, 246, '결과 행 수가 적은 테이블을 먼저 조인하는 순서 전략을 제시', 'ESSENTIAL', 4),
(1263, 246, 'SELECT * 대신 필요한 컬럼만 명시', 'SUPPLEMENTARY', 5),
(1264, 246, '다중 조인이 이전 조인 결과에 다음 테이블을 결합하는 순차 실행임을 서술', 'SUPPLEMENTARY', 6),

-- 질문 247
(1265, 247, 'INNER JOIN이 조인 조건을 만족하는 행만 반환함을 설명', 'ESSENTIAL', 1),
(1266, 247, 'LEFT JOIN이 왼쪽 테이블의 모든 행을 반환함을 설명', 'ESSENTIAL', 2),
(1267, 247, 'LEFT JOIN에서 매칭되는 행이 없으면 NULL로 채워짐을 언급', 'ESSENTIAL', 3),
(1268, 247, '같은 데이터에서 INNER JOIN 결과 행 수가 LEFT JOIN보다 적어짐을 비교', 'SUPPLEMENTARY', 4),
(1269, 247, 'COALESCE() 또는 IFNULL() 함수로 NULL 기본값을 설정하는 방법을 제시', 'SUPPLEMENTARY', 5),

-- 질문 248
(1270, 248, 'RIGHT JOIN이 오른쪽 테이블의 모든 행을 반환함을 설명', 'ESSENTIAL', 1),
(1271, 248, 'FULL OUTER JOIN이 양쪽 테이블의 모든 행을 반환함을 설명', 'ESSENTIAL', 2),
(1272, 248, 'MySQL이 FULL OUTER JOIN을 직접 지원하지 않음을 언급', 'ESSENTIAL', 3),
(1273, 248, 'LEFT JOIN과 RIGHT JOIN 결과를 UNION으로 결합해 대체함을 제시', 'ESSENTIAL', 4),
(1274, 248, '매칭되지 않는 행이 양쪽 모두 NULL로 채워짐을 명시', 'SUPPLEMENTARY', 5),

-- 질문 249
(1275, 249, 'CROSS JOIN이 두 테이블의 모든 행을 조합한 카테시안 곱을 반환함을 설명', 'ESSENTIAL', 1),
(1276, 249, '조인 조건 없이 모든 경우의 수를 생성함을 언급', 'ESSENTIAL', 2),
(1277, 249, 'CROSS JOIN 결과 행 수가 두 테이블 행 수의 곱이 됨을 언급', 'SUPPLEMENTARY', 3),
(1278, 249, '명확한 조인 조건 사용으로 카테시안 곱을 방지할 수 있음을 서술', 'SUPPLEMENTARY', 4),

-- 질문 250
(1279, 250, '조인이 두 개 이상의 테이블을 연결해 데이터를 조회하는 SQL 기법임을 설명', 'ESSENTIAL', 1),
(1280, 250, '정규화로 데이터를 여러 테이블에 분산 저장하기 때문임을 언급', 'ESSENTIAL', 2),
(1281, 250, '중복 데이터 제거의 효과로 저장 공간 절약·일관성 유지 중 최소 1개를 언급', 'ESSENTIAL', 3),
(1282, 250, '필요한 데이터만 선택적으로 결합해 유연한 조회가 가능함을 서술', 'SUPPLEMENTARY', 4);
