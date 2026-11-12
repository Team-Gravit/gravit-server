-- Unit: 뷰 (Unit ID: 52)
-- Chapter: 데이터베이스 (Chapter ID: 4)
-- Topic: DATABASE
-- Source: gravit-interview-contents-generator/output/2026-09-23/cs-database-unit11 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(256, 'DATABASE', 52, 'HARD', true,
 '여러 테이블을 조인하고 집계 함수까지 사용하는 복잡한 뷰를 만들어 서비스에서 계속 조회한다고 가정해 주세요. 이때 감수해야 하는 성능상의 대가와 데이터 수정 측면의 제약은 각각 무엇인가요?',
 '뷰는 데이터를 물리적으로 저장하지 않고 SELECT 쿼리만 저장하기 때문에, 뷰를 조회할 때마다 기반 쿼리가 다시 실행됩니다. 따라서 조인과 집계가 섞인 복잡한 뷰는 조회할 때마다 그 비용을 그대로 치르게 되어 성능 저하가 발생할 수 있고, 뷰 자체에는 인덱스를 직접 생성할 수 없어서 튜닝 수단도 제한됩니다. 수정 측면에서는 집계 함수나 GROUP BY가 들어간 복잡한 뷰는 INSERT/UPDATE/DELETE가 불가능합니다. 예를 들어 orders를 customer_id로 GROUP BY 해서 주문 건수를 세는 뷰에 INSERT를 시도하면 오류가 발생합니다. 또한 뷰는 기반 테이블에 종속적이라 테이블 구조가 바뀌면 뷰도 영향을 받고, 기반 테이블이 삭제되면 뷰도 사용할 수 없게 됩니다.',
 'interview-question/256.mp3'),
(257, 'DATABASE', 52, 'NORMAL', true,
 '어떤 뷰는 UPDATE가 되는데 어떤 뷰는 수정이 되지 않습니다. 수정 가능한 뷰와 수정 불가능한 뷰의 차이는 무엇인가요?',
 '수정 가능한 뷰는 단순 뷰로, 단일 테이블을 기반으로 하고 집계 함수가 없으며 GROUP BY, DISTINCT, UNION도 사용하지 않은 뷰입니다. 예를 들어 customers에서 status가 ''active''인 행의 id, name, email만 뽑은 simple_customers 뷰는 UPDATE로 email을 바꿀 수 있고, 그 수정은 기반 테이블에 반영됩니다. 반대로 집계 함수나 GROUP BY, DISTINCT가 들어간 복잡한 뷰는 INSERT/UPDATE/DELETE가 불가능합니다. orders를 customer_id로 GROUP BY 해 주문 건수를 집계한 customer_stats 뷰에 INSERT를 시도하면 오류가 발생합니다.',
 'interview-question/257.mp3'),
(258, 'DATABASE', 52, 'NORMAL', true,
 '사용자에게 테이블을 직접 열어 주는 대신 뷰를 제공하면 어떤 이점이 있는지, 보안과 유지보수 관점에서 말씀해 주세요.',
 '먼저 보안성입니다. 뷰는 기반 테이블의 특정 컬럼만 골라 노출할 수 있어서, 예를 들어 employees에서 salary를 뺀 id, name, department, position만 담은 뷰를 제공하면 급여 같은 민감 정보를 감출 수 있고 사용자별로 다른 뷰를 줄 수도 있습니다. 유지보수 측면에서는 독립성이 장점입니다. 기반 테이블의 구조가 바뀌어도 뷰 정의만 고치면 되므로 애플리케이션 코드는 바꾸지 않아도 됩니다. 또 복잡한 조인이나 집계 쿼리를 뷰로 저장해 두면 SELECT * FROM monthly_sales처럼 단순하게 쓸 수 있어 쿼리 재사용성이 올라갑니다. 물리적 테이블 구조와 독립적인 논리적 데이터 구조를 제공해 비즈니스 로직에 맞는 형태로 데이터를 표현할 수 있다는 점도 이점입니다.',
 'interview-question/258.mp3'),
(259, 'DATABASE', 52, 'EASY', true,
 '데이터베이스의 뷰(View)란 무엇이고, 뷰를 조회할 때 내부적으로 어떤 일이 일어나는지 설명해 주세요.',
 '뷰는 하나 이상의 테이블에서 유도된 가상 테이블입니다. 물리적으로 데이터를 저장하지 않고 SELECT 쿼리만 저장해 두었다가, 뷰를 조회할 때마다 저장된 기반 쿼리를 실행합니다. 이렇게 동적으로 실행되기 때문에 뷰는 항상 기반 테이블의 최신 데이터를 반영합니다. 생성은 CREATE VIEW active_customers AS SELECT id, name, email FROM customers WHERE status = ''active''처럼 하고, 이후에는 SELECT * FROM active_customers처럼 일반 테이블과 똑같이 조회할 수 있습니다. 제약은 있지만 INSERT, UPDATE, DELETE도 가능하고, 다른 뷰나 쿼리에서 참조할 수도 있습니다.',
 'interview-question/259.mp3'),
(260, 'DATABASE', 52, 'EASY', true,
 '뷰를 만들 때 WITH CHECK OPTION을 붙이면 어떤 동작을 하는지, 붙이지 않은 경우와 함께 설명해 주세요.',
 'WITH CHECK OPTION은 뷰를 통한 데이터 수정 시 뷰의 조건을 벗어나는 수정을 막아 주는 옵션입니다. 예를 들어 customers에서 status = ''active''인 행만 담은 active_customers 뷰가 있을 때, 이 옵션이 없으면 UPDATE active_customers SET status = ''inactive''처럼 뷰의 조건에 맞지 않게 만드는 수정도 그대로 실행됩니다. 뷰 정의 끝에 WITH CHECK OPTION을 붙이면 같은 UPDATE가 조건 위반으로 오류를 내며 실패합니다. 즉 뷰의 WHERE 조건이 수정에도 적용되어, 뷰의 조건을 벗어나는 변경을 차단합니다.',
 'interview-question/260.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 256
(1309, 256, '뷰 조회마다 기반 쿼리가 실행되어 성능 저하가 발생할 수 있음을 언급', 'ESSENTIAL', 1),
(1310, 256, '뷰에는 인덱스를 직접 생성할 수 없다는 제약을 제시', 'ESSENTIAL', 2),
(1311, 256, '집계 함수나 GROUP BY가 쓰인 뷰는 INSERT/UPDATE/DELETE가 불가함을 명시', 'ESSENTIAL', 3),
(1312, 256, '기반 테이블 구조가 변경되면 뷰도 영향받는 종속성을 서술', 'SUPPLEMENTARY', 4),
(1313, 256, '기반 테이블이 삭제되면 뷰도 사용할 수 없게 됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 257
(1314, 257, '수정 가능한 뷰는 단일 테이블을 기반으로 해야 함을 언급', 'ESSENTIAL', 1),
(1315, 257, '집계 함수·GROUP BY·DISTINCT·UNION 중 최소 2개를 수정 불가 조건으로 제시', 'ESSENTIAL', 2),
(1316, 257, '수정 불가능한 뷰에 INSERT를 시도하면 오류가 발생함을 서술', 'SUPPLEMENTARY', 3),
(1317, 257, '단순 뷰에 실행한 UPDATE가 기반 테이블에 반영됨을 명시', 'SUPPLEMENTARY', 4),

-- 질문 258
(1318, 258, '특정 컬럼만 노출해 급여 같은 민감 정보를 보호할 수 있음을 언급', 'ESSENTIAL', 1),
(1319, 258, '테이블 구조가 바뀌어도 뷰만 수정하면 애플리케이션 코드는 그대로 둘 수 있음을 설명', 'ESSENTIAL', 2),
(1320, 258, '복잡한 조인·집계 쿼리를 뷰로 저장해 재사용하는 단순화 효과를 제시', 'ESSENTIAL', 3),
(1321, 258, '사용자별로 서로 다른 뷰를 제공할 수 있음을 명시', 'SUPPLEMENTARY', 4),
(1322, 258, '물리적 테이블 구조와 독립적인 논리적 데이터 구조를 제공함을 서술', 'SUPPLEMENTARY', 5),

-- 질문 259
(1323, 259, '뷰가 하나 이상의 테이블에서 유도된 가상 테이블임을 언급', 'ESSENTIAL', 1),
(1324, 259, '실제 데이터를 저장하지 않고 SELECT 문만 저장함을 명시', 'ESSENTIAL', 2),
(1325, 259, '조회할 때마다 기반 쿼리가 실행되어 항상 최신 데이터가 반영됨을 서술', 'ESSENTIAL', 3),
(1326, 259, 'CREATE VIEW 이름 AS SELECT 구문으로 뷰를 생성함을 제시', 'SUPPLEMENTARY', 4),
(1327, 259, '뷰를 테이블처럼 다른 뷰나 쿼리에서 참조할 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 260
(1328, 260, 'WITH CHECK OPTION이 뷰의 조건을 벗어나는 수정을 방지함을 언급', 'ESSENTIAL', 1),
(1329, 260, '옵션이 없으면 뷰 조건에 맞지 않는 UPDATE도 그대로 수정됨을 서술', 'ESSENTIAL', 2),
(1330, 260, '조건을 위반하는 수정 시도는 오류로 실패함을 명시', 'SUPPLEMENTARY', 3),
(1331, 260, 'status가 active인 행만 담은 뷰를 예로 제시', 'SUPPLEMENTARY', 4);
