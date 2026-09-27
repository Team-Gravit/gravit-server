-- Unit: 연관관계와 N+1 (Unit ID: 118)
-- Chapter: Spring (Chapter ID: 10)
-- Topic: SPRING_BOOT
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-spring-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(586, 'SPRING_BOOT', 118, 'HARD', true,
 '주문 목록을 페이징해서 보여 주면서 각 주문의 주문 상품 컬렉션까지 함께 조회해야 합니다. 컬렉션을 fetch join한 쿼리에 그대로 페이징을 적용하면 어떤 문제가 생기고, 어떻게 조회하는 것이 좋을까요?',
 '컬렉션을 fetch join한 JPQL에 Pageable이나 setFirstResult/setMaxResults를 적용하면, Hibernate는 SQL에서 페이징하지 않고 모든 데이터를 메모리로 읽은 뒤 애플리케이션에서 페이징합니다. 1:N 조인 결과로 부모 행이 자식 수만큼 중복되기 때문에 조인된 행 수와 부모 수가 달라, SQL LIMIT으로는 정확한 부모 개수를 자를 수 없기 때문입니다. 이때 HHH90003004 경고가 찍히고, 전체 데이터를 메모리에 올리므로 OOM 위험이 있습니다. 개선 방법은 행 수가 늘지 않는 ToOne 관계(예: member)만 fetch join하고 부모 기준으로 페이징하는 것입니다. 주문 상품 같은 컬렉션은 hibernate.default_batch_fetch_size를 100 정도로 설정해 두고, o.getOrderItems()에 접근해 지연 로딩이 일어날 때 식별자 IN 절로 묶어서 가져오게 합니다. 그리고 hibernate.query.fail_on_pagination_over_collection_fetch=true를 켜 두면 경고 대신 예외가 발생해 배포 전에 이 문제를 발견할 수 있습니다. 정리하면 ''ToOne은 fetch join, 컬렉션은 batch size, 페이징은 부모 기준으로''입니다.'),
(587, 'SPRING_BOOT', 118, 'NORMAL', true,
 'N+1 문제를 해결할 때 JPQL의 fetch join과 @EntityGraph는 어떤 차이가 있나요?',
 '둘 다 연관 엔티티를 한 번의 조인 쿼리로 함께 로딩해 N+1을 막는 방법이지만 몇 가지 차이가 있습니다. 먼저 조인 종류가 다릅니다. fetch join은 기본이 INNER JOIN이고 필요하면 left join fetch로 쓸 수 있는 반면, @EntityGraph는 LEFT OUTER JOIN으로 연관 엔티티를 가져옵니다. 다음으로 선언 위치가 다릅니다. fetch join은 JPQL 문자열 안에 join fetch로 작성하고, @EntityGraph는 attributePaths로 함께 로딩할 속성을 애노테이션으로 선언합니다. 그래서 @EntityGraph는 JPQL을 직접 쓰지 않고 findByStatus 같은 메서드 이름 기반 쿼리에도 붙일 수 있습니다. 반면 복잡한 조건은 JPQL을 쓰는 fetch join이 자유롭고, @EntityGraph는 단순한 로딩 선언에 한정됩니다. 공통점으로, List 컬렉션을 두 개 이상 동시에 로딩하면 두 방식 모두 MultipleBagFetchException이 발생합니다.'),
(588, 'SPRING_BOOT', 118, 'NORMAL', true,
 'JPA의 지연 로딩과 즉시 로딩은 어떻게 다르고, 왜 연관관계를 LAZY로 두는 것을 기본 원칙으로 하나요?',
 '지연 로딩(LAZY)은 연관 엔티티 자리에 프록시 객체를 넣어 두고, 실제 필드에 접근하는 순간 SELECT를 실행해 데이터를 가져옵니다. 즉시 로딩(EAGER)은 엔티티를 조회할 때 연관 엔티티까지 함께 조회합니다. 다만 find()는 조인으로 한 번에 가져오지만 JPQL은 본 엔티티를 먼저 조회한 뒤 연관 엔티티를 개별 SELECT하므로 N+1이 발생할 수 있습니다. LAZY를 기본으로 두는 이유는 예측 가능성 때문입니다. EAGER는 어디서 어떤 쿼리가 나갈지 예측할 수 없다는 점이 가장 큰 문제입니다. 특히 @ManyToOne과 @OneToOne은 기본 FetchType이 EAGER이므로 fetch = FetchType.LAZY로 반드시 바꿔 둡니다. 그래서 모든 연관관계를 LAZY로 두고, 연관 데이터가 필요한 조회 메서드에서만 fetch join으로 가져오는 것이 JPA의 기본 원칙입니다.'),
(589, 'SPRING_BOOT', 118, 'EASY', true,
 'JPA에서 N+1 문제란 무엇이며, 어떤 과정으로 발생하는지 설명해 주세요.',
 'N+1 문제는 목록을 조회하는 쿼리 1회를 실행한 뒤, 결과 N건 각각의 연관 엔티티를 가져오는 쿼리가 N회 추가로 나가는 문제입니다. 예를 들어 select o from Order o로 주문 N건을 조회한 다음 반복문에서 o.getMember().getName()을 호출하면, 주문마다 LAZY 프록시가 초기화되면서 SELECT * FROM member WHERE id = ? 쿼리가 하나씩 실행되어 총 1 + N번의 쿼리가 나갑니다. LAZY는 접근 시점에, EAGER는 JPQL 실행 직후에 N번 나가므로 로딩 전략을 바꾸는 것만으로는 해결되지 않고, fetch join이나 EntityGraph, batch size 같은 조회 방식으로 해결해야 합니다. 참고로 지연 로딩 시점에 영속성 컨텍스트가 이미 닫혀 있으면 N+1 대신 LazyInitializationException이 발생합니다.'),
(590, 'SPRING_BOOT', 118, 'EASY', true,
 'Hibernate의 batch size 설정은 어떻게 동작해서 N+1 문제를 줄이나요?',
 'batch size를 설정하면 지연 로딩이 일어날 때 같은 타입의 프록시나 컬렉션을 식별자 IN 절로 묶어서 한 번에 가져옵니다. 설정 전에는 SELECT * FROM order_item WHERE order_id = 1, = 2 ... 처럼 N번 쿼리가 나가지만, 설정 후에는 WHERE order_id IN (1, 2, 3, ..., 100)처럼 묶여서 쿼리 수가 N에서 N / batch_size로 줄어듭니다. 설정은 hibernate.default_batch_fetch_size로 전역 적용하거나 @BatchSize로 개별 적용할 수 있고, 보통 100~1000 사이에서 DB의 IN 절 한계와 메모리를 고려해 정합니다. 조인이 아니기 때문에 부모 데이터가 중복되거나 페이징이 깨지는 문제가 없어 컬렉션 관계에 적합합니다. 다만 fetch join처럼 즉시 가져오는 것이 아니라 지연 로딩이 발생하는 시점에 묶어 가져오는 방식이므로, 그 시점에 영속성 컨텍스트가 살아 있어야 합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 586
(3155, 586, '컬렉션 fetch join에 페이징을 적용하면 Hibernate가 전체 데이터를 메모리로 읽은 뒤 페이징함을 언급', 'ESSENTIAL', 1),
(3156, 586, '1:N 조인으로 부모 행이 자식 수만큼 중복되어 SQL LIMIT으로 부모 개수를 자를 수 없다는 이유를 설명', 'ESSENTIAL', 2),
(3157, 586, 'ToOne 관계만 fetch join하고 부모 기준으로 페이징하는 방법을 제시', 'ESSENTIAL', 3),
(3158, 586, '컬렉션은 batch size로 IN 절에 묶어 지연 로딩하는 방법을 제시', 'ESSENTIAL', 4),
(3159, 586, '메모리 페이징은 전체 데이터를 올리므로 OOM 위험이 있음을 언급', 'SUPPLEMENTARY', 5),
(3160, 586, 'fail_on_pagination_over_collection_fetch 설정으로 경고 대신 예외를 던지게 할 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 587
(3161, 587, 'fetch join은 기본 INNER JOIN이고 @EntityGraph는 LEFT OUTER JOIN을 사용한다는 차이를 설명', 'ESSENTIAL', 1),
(3162, 587, 'fetch join은 JPQL 문자열 안에, @EntityGraph는 애노테이션으로 로딩할 속성을 선언한다는 차이를 설명', 'ESSENTIAL', 2),
(3163, 587, '@EntityGraph는 메서드 이름 기반 쿼리에도 붙일 수 있음을 언급', 'SUPPLEMENTARY', 3),
(3164, 587, '복잡한 조건은 fetch join이 자유롭고 @EntityGraph는 단순 로딩 선언에 한정됨을 언급', 'SUPPLEMENTARY', 4),
(3165, 587, '두 방식 모두 컬렉션 다중 로딩 시 MultipleBagFetchException이 발생함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 588
(3166, 588, '지연 로딩은 프록시 객체를 넣어 두고 실제 필드에 접근하는 순간 SELECT를 실행함을 설명', 'ESSENTIAL', 1),
(3167, 588, '즉시 로딩은 엔티티를 조회할 때 연관 엔티티까지 함께 조회함을 설명', 'ESSENTIAL', 2),
(3168, 588, 'EAGER는 어디서 어떤 쿼리가 나갈지 예측할 수 없다는 점을 LAZY 기본 원칙의 이유로 제시', 'ESSENTIAL', 3),
(3169, 588, '@ManyToOne·@OneToOne의 기본 FetchType이 EAGER라 LAZY로 변경해야 함을 언급', 'SUPPLEMENTARY', 4),
(3170, 588, '모두 LAZY로 두고 필요한 곳에서만 fetch join으로 가져오는 방식을 언급', 'SUPPLEMENTARY', 5),

-- 질문 589
(3171, 589, '목록 조회 쿼리 1회 후 연관 엔티티 조회 쿼리가 N회 추가로 실행되는 문제임을 설명', 'ESSENTIAL', 1),
(3172, 589, '조회한 엔티티마다 LAZY 프록시가 초기화되며 연관 엔티티 SELECT가 하나씩 나가는 과정을 설명', 'ESSENTIAL', 2),
(3173, 589, '로딩 전략을 EAGER로 바꾸는 것만으로는 N+1이 해결되지 않음을 언급', 'SUPPLEMENTARY', 3),
(3174, 589, '영속성 컨텍스트가 닫힌 뒤 지연 로딩하면 LazyInitializationException이 발생함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 590
(3175, 590, '지연 로딩 시 같은 타입의 프록시·컬렉션을 식별자 IN 절로 묶어 한 번에 조회함을 설명', 'ESSENTIAL', 1),
(3176, 590, '쿼리 수가 N에서 N / batch_size로 줄어듦을 언급', 'ESSENTIAL', 2),
(3177, 590, 'default_batch_fetch_size 전역 설정과 @BatchSize 개별 설정 중 최소 1개를 설정 방법으로 제시', 'SUPPLEMENTARY', 3),
(3178, 590, 'batch size는 조인이 아니므로 부모 데이터 중복·페이징 문제가 없음을 언급', 'SUPPLEMENTARY', 4),
(3179, 590, '지연 로딩 시점에 묶어 가져오므로 영속성 컨텍스트가 살아 있어야 함을 언급', 'SUPPLEMENTARY', 5);
