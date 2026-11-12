-- Unit: 연관관계와 N+1 (Unit ID: 118)
-- Chapter: Spring (Chapter ID: 10)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (544, 118, '즉시 로딩 기본값과 컬렉션 페이징'),
       (702, 118, '일반 조인과 페치 조인, 지연 로딩 예외'),
       (860, 118, '연관관계 주인과 다중 컬렉션 페치 조인');

-- =====================================================
-- Lesson 544: 즉시 로딩 기본값과 컬렉션 페이징
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3443, 544, '아래 엔티티 매핑과 실행 코드에서 일어나는 동작으로 옳은 것은?', '```java
@Entity
public class Order {
    @Id @GeneratedValue
    private Long id;

    @ManyToOne
    @JoinColumn(name = "member_id")
    private Member member;

    @OneToMany(mappedBy = "order")
    private List<OrderItem> orderItems = new ArrayList<>();
}
```

OrderItem 쪽에는 `@ManyToOne @JoinColumn(name = "order_id") private Order order;` 필드가 있다.

```java
Order order = em.find(Order.class, 1L);

OrderItem item = new OrderItem();
order.getOrderItems().add(item);   // item.setOrder(order)는 호출하지 않았다
em.persist(item);

tx.commit();
```', 'OBJECTIVE'),
       (3444, 544, '아래 설정을 추가한 뒤 같은 코드를 다시 실행할 때 나가는 SELECT의 총 횟수는?', '주문 200건을 목록으로 조회한 뒤, 반복문에서 각 주문의 `orderItems`(지연 로딩)에 접근한다.

설정 전 쿼리 로그:

```
select ... from orders                            -- 1회
select ... from order_item where order_id = ?     -- 200회 (주문마다 1회)
```

`application.yml`에 아래 설정을 추가했다.

```yaml
spring:
  jpa:
    properties:
      hibernate:
        default_batch_fetch_size: 50
```', 'OBJECTIVE'),
       (3445, 544, '아래 비교표를 바탕으로 두 방식을 설명한 것으로 옳지 않은 것은?', '| 항목 | fetch join (JPQL) | @EntityGraph |
|---|---|---|
| 조인 종류 | 기본 INNER JOIN (`left join fetch`로 바꿀 수 있음) | LEFT OUTER JOIN |
| 선언 위치 | JPQL 문자열 안 | 애노테이션 (메서드 이름 쿼리와 조합 가능) |
| 조건 표현 | where·서브쿼리 등 자유롭게 작성 | 함께 로딩할 속성 선언만 가능 |
| List 컬렉션 2개 동시 로딩 | MultipleBagFetchException | MultipleBagFetchException |', 'OBJECTIVE'),
       (3446, 544, '아래 페이징 조회를 실행했을 때의 결과로 옳은 것은?', E'```java\npublic interface OrderRepository extends JpaRepository<Order, Long> {\n\n    @Query(value = "select o from Order o join fetch o.orderItems",\n           countQuery = "select count(o) from Order o")\n    Page<Order> findPage(Pageable pageable);\n}\n```\n\n- 호출: `findPage(PageRequest.of(0, 20))`\n- 데이터: orders 5,000건, 주문 하나당 order_item 평균 4건\n- Hibernate 6 기준\n\n실행된 SQL(발췌):\n\n```sql\nselect o.*, oi.* from orders o inner join order_item oi on oi.order_id = o.id\n-- limit 절이 붙지 않았다\n```', 'OBJECTIVE'),
       (3447, 544, '아래 로그에서 드러난 조회 성능 문제를 가리키는 이름은?', '주문 목록 API의 응답이 2.3초까지 느려져 쿼리 로그를 세어 봤다. 주문 100건을 돌려주는 요청 한 번에 SELECT가 모두 101번 실행됐고, 그중 100번은 회원 한 명씩만 가져오는 같은 모양의 쿼리였다.

```
select ... from orders
select ... from member where member_id = 1
select ... from member where member_id = 2
...
select ... from member where member_id = 100
```

목록 크기를 200건으로 늘리자 SELECT는 201번으로 늘었다.', 'SUBJECTIVE'),
       (3448, 544, '아래에서 member 필드에 들어 있던 객체를 무엇이라고 하는가?', '```java
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "member_id")
private Member member;
```

```java
Order order = em.find(Order.class, 1L);
Member m = order.getMember();

System.out.println(m.getClass().getName());
// com.shop.Member_$$_jvst8b_3   ← Member가 아닌 이름이 찍힌다

System.out.println(m.getId());
// 7   ← SQL 로그에 아무 쿼리도 남지 않는다

System.out.println(m.getName());
// 이 줄에서 select ... from member where member_id = 7 이 실행된다
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3443
(9355, 3443, 'member 자리에는 프록시가 들어가 getName()을 호출하는 순간 처음 SELECT가 나간다.', '@ManyToOne의 기본 FetchType은 EAGER다. fetch를 지정하지 않았으므로 프록시가 아니라 실제 회원 엔티티가 채워진다. 모든 연관관계가 지연 로딩으로 시작한다고 착각한 것.', false),
(9356, 3443, 'orderItems는 Order를 조회하는 시점에 함께 조회돼 값이 채워진 상태가 된다.', '@OneToMany의 기본 FetchType은 LAZY다. 컬렉션은 실제로 접근할 때 SELECT가 나간다. ToOne은 즉시, ToMany는 지연이 기본인데 둘을 반대로 안 것.', false),
(9357, 3443, '커밋해도 order_item 행의 order_id에는 주문 식별자가 채워지지 않는다.', '외래 키를 관리하는 연관관계 주인은 FK를 가진 OrderItem.order 쪽이다. mappedBy가 붙은 컬렉션에만 담는 것은 쓰기에 반영되지 않으므로 item.setOrder(order)까지 해 줘야 한다.', true),
(9358, 3443, '컬렉션에서 OrderItem을 빼면 해당 order_item 행이 함께 삭제된다.', '고아 객체 제거는 orphanRemoval = true를 붙여야 동작한다. 매핑에 없으므로 컬렉션에서 빼도 DELETE는 나가지 않는다. cascade도 기본으로 적용되지 않는다.', false),

-- 문제 3444
(9359, 3444, '2회', 'batch size가 fetch join처럼 조인 한 번으로 합쳐 준다고 오해한 값. 조인이 아니라 지연 로딩이 일어나는 시점에 식별자를 IN 절로 묶는 방식이라 컬렉션 조회가 한 번으로 줄지는 않는다.', false),
(9360, 3444, '5회', '컬렉션 로딩이 order_id IN (...) 형태로 50개씩 묶여 200 / 50 = 4회가 되고, 목록 조회 1회를 더해 5회다. 쿼리 수가 N에서 N / batch_size로 줄어든다.', true),
(9361, 3444, '51회', '설정값 50을 추가 쿼리 횟수로 오해한 값. 50은 한 번의 IN 절에 묶는 식별자 개수이지 쿼리 횟수가 아니다.', false),
(9362, 3444, '201회', 'batch size가 즉시 로딩에만 먹힌다고 오해해 설정 전과 같다고 본 값. 오히려 지연 로딩이 일어나는 시점에 묶어 가져오는 방식이라 지연 로딩일 때 효과가 난다.', false),

-- 문제 3445
(9363, 3445, '연관 데이터가 없는 주문까지 결과에 담으려면 fetch join에는 left를 덧붙여야 하지만 @EntityGraph는 그대로 둬도 된다.', '조인 종류 행에서 따라 나오는 참인 진술이다. fetch join은 기본이 INNER JOIN이라 연관이 비어 있는 행이 빠지고, @EntityGraph는 LEFT OUTER JOIN이라 빈 쪽도 남는다.', false),
(9364, 3445, '메서드 이름만으로 만든 조회 메서드에 함께 로딩을 걸어야 한다면 @EntityGraph를 쓴다.', '선언 위치 행에서 따라 나오는 참인 진술이다. fetch join은 JPQL 문자열이 있어야 해서 메서드 이름 쿼리에는 붙일 수 없고, 애노테이션은 그 위에 얹을 수 있다.', false),
(9365, 3445, '여러 조건과 서브쿼리를 조합한 조회에서 연관 엔티티까지 함께 가져와야 하면 fetch join이 알맞다.', '조건 표현 행에서 따라 나오는 참인 진술이다. @EntityGraph는 무엇을 함께 로딩할지 선언할 뿐 조건을 담지 못하므로, 복잡한 where가 필요하면 JPQL을 직접 쓴다.', false),
(9366, 3445, '@EntityGraph는 조인 방식이 달라 List 컬렉션 두 개를 한 번에 로딩해도 예외가 나지 않는다.', '표의 마지막 행에 정면으로 걸리는 거짓이다. 두 방식 모두 MultipleBagFetchException이 난다. 카테시안 곱으로 행이 폭증하는 문제라 조인 종류와 무관하며, 컬렉션은 하나만 함께 로딩하고 나머지는 batch size로 푼다.', true),

-- 문제 3446
(9367, 3446, '조인 결과 20,000행을 모두 읽어 들인 뒤 애플리케이션이 주문 20건을 잘라내므로 데이터가 늘수록 메모리 사용량이 커진다.', '컬렉션을 fetch join하면 주문 한 건이 order_item 수만큼 늘어나 SQL의 limit으로는 주문 20건을 정확히 자를 수 없다. 그래서 Hibernate가 전체를 읽어 메모리에서 페이징한다.', true),
(9368, 3446, 'SQL에 limit 20이 그대로 붙어 조인 결과 20행만 읽고 그만큼의 주문을 반환한다.', 'limit이 붙지 않은 이유가 핵심이다. 조인 결과 20행에는 주문이 5건 남짓만 들어 있어 요청한 페이지 크기와 어긋나므로, Hibernate는 아예 limit을 걸지 않는다.', false),
(9369, 3446, '주문 행이 order_item 수만큼 중복돼 한 페이지에 서로 다른 주문이 5건만 담긴다.', '중복된 행이 그대로 페이지에 들어간다는 오해다. Hibernate 6는 컬렉션 fetch join의 부모 중복을 자동으로 제거하므로 요청한 20건이 서로 다른 주문으로 채워진다.', false),
(9370, 3446, '컬렉션 fetch join에 페이징을 걸면 곧바로 예외가 발생해 조회가 실패한다.', '기본 설정에서는 경고 로그만 남기고 조회 자체는 성공한다. 배포 전에 잡고 싶다면 hibernate.query.fail_on_pagination_over_collection_fetch를 켜서 예외로 바꿔야 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1104, 3447, 'N+1,N+1 문제,N + 1,N + 1 문제,N+1 problem,엔플러스원,엔 플러스 원', '목록 조회 1회에 연관 엔티티를 하나씩 가져오는 조회 N회가 따라붙어 총 N+1번의 쿼리가 나가는 상황이다. 로그에서 목록 100건일 때 101번, 200건일 때 201번으로 늘어난 것이 그 모양을 그대로 보여 준다. 즉시 로딩은 JPQL 실행 직후에, 지연 로딩은 연관 필드에 접근하는 순간에 N번이 나가므로 로딩 전략을 바꾸는 것만으로는 사라지지 않는다. fetch join·@EntityGraph·batch size 같은 조회 방식으로 해결한다. 영속성 컨텍스트가 닫힌 뒤 지연 로딩을 건드려 터지는 LazyInitializationException은 쿼리가 아예 나가지 못해 생기는 예외라서 구분해야 한다.'),
       (1105, 3448, '프록시,프록시 객체,proxy,proxy object,하이버네이트 프록시,hibernate proxy', '지연 로딩으로 매핑한 연관 필드에는 원본 엔티티를 상속한 가짜 객체가 먼저 들어간다. 클래스 이름이 Member가 아니라는 점, 식별자를 이미 갖고 있어 getId()에서는 쿼리가 나가지 않는다는 점, 다른 값을 읽는 순간 초기화되며 SELECT가 나간다는 점이 모두 그 증거다. 즉시 로딩이면 처음부터 실제 엔티티가 들어가 이런 장면이 나오지 않는다. 초기화 전에 영속성 컨텍스트가 닫히면 LazyInitializationException이 발생하는데, 이는 이 객체를 채우지 못해 생기는 예외이지 객체의 이름이 아니다.');

-- =====================================================
-- Lesson 702: 일반 조인과 페치 조인, 지연 로딩 예외
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4391, 702, '아래 (가)와 (나)를 실행했을 때 나가는 SQL을 설명한 것으로 옳은 것은?', '```java
@Entity
public class Order {
    @Id @GeneratedValue
    private Long id;

    @ManyToOne
    @JoinColumn(name = "member_id")
    private Member member;
}
```

```java
// (가)
Order order = em.find(Order.class, 1L);

// (나)
List<Order> orders = em.createQuery("select o from Order o", Order.class)
        .getResultList();
```

- orders 테이블에는 주문 3건이 있고, 세 주문의 회원은 모두 다르다.
- (가)와 (나)는 각각 비어 있는 영속성 컨텍스트에서 따로 실행하며, 어느 쪽도 member 필드에 접근하지 않는다.', 'OBJECTIVE'),
       (4392, 702, '아래 (가)와 (나)로 각각 조회한 뒤 반복문까지 실행했을 때 나가는 SELECT의 총 횟수로 옳은 것은?', 'Order 엔티티의 member 필드는 아래처럼 매핑돼 있다.

```java
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "member_id")
private Member member;
```

- (가) JPQL: `select o from Order o join o.member m`
- (나) JPQL: `select o from Order o join fetch o.member`

(가)와 (나) 모두 JPQL만 바꿔 넣고 아래 코드를 그대로 실행한다.

```java
List<Order> orders = em.createQuery(jpql, Order.class).getResultList();

for (Order o : orders) {
    System.out.println(o.getMember().getName());
}
```

- 조회되는 주문은 40건이고, 모두 회원이 있으며 40건의 회원은 서로 다르다.
- (가)와 (나)는 각각 비어 있는 영속성 컨텍스트에서 따로 실행하고, batch size 설정은 없다.', 'OBJECTIVE'),
       (4393, 702, '아래 코드를 실행했을 때 출력되는 orders.size() 값은?', '```java
List<Order> orders = em.createQuery(
        "select o from Order o join fetch o.orderItems", Order.class)
    .getResultList();

System.out.println(orders.size());
```

- Hibernate 6 기준이다.
- `Order.orderItems`는 `@OneToMany(mappedBy = "order")`로 매핑한 `List<OrderItem>`이다.
- 테이블에 저장된 데이터는 아래와 같다.

| 주문 id | 해당 주문의 order_item 행 수 |
|---|---|
| 1 | 3 |
| 2 | 0 |
| 3 | 2 |
| 4 | 1 |', 'OBJECTIVE'),
       (4394, 702, '아래 연관 데이터 조회 방식에 대한 설명으로 옳은 것은?', 'batch size(`hibernate.default_batch_fetch_size`·`@BatchSize`)는 지연 로딩이 일어나는 순간, 영속성 컨텍스트에 아직 초기화되지 않은 같은 타입의 프록시나 컬렉션을 모아 그 식별자들을 `WHERE ... IN (...)` 쿼리 한 번으로 묶어 가져오는 방식이다. 한 번에 묶는 식별자 개수는 설정값으로 정한다.', 'OBJECTIVE'),
       (4395, 702, '아래 상황에서 조회 메서드 선언 바로 위에 추가한 것의 이름은?', '주문 검색 API는 메서드 이름만으로 쿼리를 만드는 아래 조회 메서드를 쓴다.

```java
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByStatus(OrderStatus status);
}
```

조회된 주문 100건마다 회원 이름을 출력하느라 SELECT가 101번 나가자, `findByStatus` 선언 바로 위에 한 줄을 추가했다. 메서드 이름·파라미터·반환 타입은 그대로이고, JPQL이든 SQL이든 쿼리 문자열은 한 글자도 쓰지 않았다. 엔티티 매핑도 건드리지 않았다.

추가 후 쿼리 로그:

```
select o.*, m.* from orders o left outer join member m on m.id = o.member_id where o.status = ?
```

SELECT는 1번으로 줄었고, 회원이 없는 비회원 주문 8건도 추가 전과 똑같이 결과에 들어 있었다.', 'SUBJECTIVE'),
       (4396, 702, '아래 코드에서 컨트롤러의 getName() 호출 줄에서 발생하는 예외의 이름은?', '```yaml
spring:
  jpa:
    open-in-view: false
```

```java
@Service
public class OrderService {
    @Transactional(readOnly = true)
    public Order getOrder(Long id) {
        return orderRepository.findById(id).orElseThrow();
    }
}

@RestController
public class OrderController {
    @GetMapping("/orders/{id}")
    public String detail(@PathVariable Long id) {
        Order order = orderService.getOrder(id);
        return order.getMember().getName();
    }
}
```

- `Order.member`는 `@ManyToOne(fetch = FetchType.LAZY)`로 매핑돼 있다.
- 요청 한 번에 SQL 로그에는 orders 조회 한 줄만 남았고, member를 조회하는 SQL은 끝내 나가지 않은 채 500 응답이 반환됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4391
(11883, 4391, '두 코드 모두 member에 접근하지 않으므로 주문 조회 SQL만 나가고 회원 SELECT는 나가지 않는다.', '@ManyToOne의 기본 FetchType을 LAZY로 착각한 것. fetch를 지정하지 않았으니 EAGER라서 필드에 접근하지 않아도 조회할 때 회원까지 가져온다. 접근하는 순간 SELECT가 나가는 것은 LAZY로 바꿨을 때의 동작이다.', false),
(11884, 4391, '두 코드 모두 즉시 로딩이 적용돼 주문과 회원을 조인한 SQL 한 번으로 끝난다.', '즉시 로딩이면 언제나 조인으로 가져온다고 오해한 것. 조인으로 한 번에 가져오는 것은 find()일 때뿐이다. JPQL은 작성한 문장대로 주문만 조회한 뒤, 즉시 로딩을 지키려고 회원을 따로 SELECT한다.', false),
(11885, 4391, '(가)는 조인 SQL 한 번으로 끝나지만, (나)는 주문 조회 뒤 회원 SELECT가 3회 더 나간다.', 'find()는 EAGER 연관을 조인해 한 번에 가져온다. 반면 JPQL은 작성한 대로 orders만 조회하고, 즉시 로딩을 지키려고 주문 3건의 회원을 하나씩 SELECT한다. 연관 필드에 접근하지 않아도 N+1이 생기는 이유다.', true),
(11886, 4391, '(가)는 주문 조회 뒤 회원 SELECT가 1회 더 나가고, (나)는 조인 SQL 한 번으로 끝난다.', 'find()와 JPQL의 동작을 뒤바꿔 안 것. JPQL은 작성한 문장을 SQL로 옮기므로 조인을 쓰지 않았다면 조인하지 않고 연관 엔티티는 따로 조회한다. 조인으로 한 번에 가져오는 쪽은 find()다.', false),

-- 문제 4392
(11887, 4392, '(가) 1회 / (나) 1회', '일반 join도 연관 엔티티를 로딩한다고 오해한 값. 일반 join은 조인 조건으로 주문을 거르는 데만 쓰이고 회원을 채우지 않는다. member 자리에 프록시가 남아 반복문에서 회원마다 SELECT가 나간다.', false),
(11888, 4392, '(가) 41회 / (나) 1회', '(가)는 조인했어도 회원을 로딩하지 않아 목록 1회 뒤 getName()마다 프록시가 초기화되며 40회가 더 나간다. (나)는 fetch join이 조인 한 번으로 회원까지 영속 상태로 채워 반복문에서 SELECT가 없다.', true),
(11889, 4392, '(가) 41회 / (나) 41회', '매핑의 LAZY 설정이 fetch join보다 우선한다고 오해한 값. LAZY는 따로 지정하지 않았을 때의 기본 동작일 뿐이고, fetch join을 쓴 조회는 회원을 조인으로 함께 가져와 반복문에서 추가 SELECT가 없다.', false),
(11890, 4392, '(가) 1회 / (나) 41회', '두 조인의 역할을 뒤바꿔 안 값. fetch는 나중에 가져오라는 표시가 아니라 이번 조회에서 연관 엔티티까지 함께 채우라는 뜻이다. 반대로 일반 join은 거르기만 해 반복문에서 SELECT가 이어진다.', false),

-- 문제 4393
(11891, 4393, '3', 'fetch join은 기본이 INNER JOIN이라 상품이 없는 주문 2는 빠지고 조인 결과는 6행이다. Hibernate 6은 컬렉션 fetch join으로 중복된 부모를 자동으로 걸러 주문 1·3·4의 3건만 남긴다.', true),
(11892, 4393, '4', 'fetch join을 LEFT OUTER JOIN으로 착각해 상품이 없는 주문 2까지 담긴다고 본 값. 기본은 INNER JOIN이라 연관 행이 없는 주문은 빠진다. 모두 담으려면 left join fetch로 써야 한다.', false),
(11893, 4393, '6', '조인 결과 행이 그대로 목록에 담긴다고 본 값. Hibernate 5까지는 distinct 없이 쓰면 부모가 자식 수만큼 중복됐지만, Hibernate 6부터는 중복된 부모 엔티티를 자동으로 제거한다.', false),
(11894, 4393, '7', 'LEFT OUTER JOIN으로 착각해 주문 2의 빈 행까지 더하고, 부모 중복도 그대로 남는다고 본 값. 기본 INNER JOIN이라 주문 2는 빠지고, Hibernate 6은 중복된 부모도 걸러 낸다.', false),

-- 문제 4394
(11895, 4394, '지연 로딩이 일어날 때 묶어서 가져오므로, 영속성 컨텍스트가 닫힌 뒤에 접근해도 IN 쿼리로 값이 채워진다.', '묶어서 가져오더라도 지연 로딩이 일어나는 시점에 쿼리를 보내므로 그 순간 영속성 컨텍스트가 살아 있어야 한다. 닫힌 뒤 접근하면 IN 쿼리를 보내지 못하고 예외가 난다.', false),
(11896, 4394, '목록을 조회하는 쿼리 한 번에 연관 데이터까지 담아 오므로, 연관 데이터를 위한 추가 쿼리가 나가지 않는다.', '조인으로 한 번에 가져오는 fetch join의 특징을 갖다 붙인 것. batch size는 목록 조회 뒤 IN 쿼리가 따로 나가며, 쿼리 수가 N회에서 N / batch size 회로 줄 뿐 없어지지는 않는다.', false),
(11897, 4394, 'List 타입 컬렉션 두 개에 함께 적용하면 행이 곱절로 불어나 MultipleBagFetchException이 발생한다.', 'List 컬렉션 두 개를 동시에 fetch join할 때의 문제를 갖다 붙인 것. batch size는 조인하지 않고 컬렉션마다 IN 쿼리를 따로 보내 카테시안 곱이 생기지 않으므로, 오히려 그 문제를 피하는 데 쓴다.', false),
(11898, 4394, '조인으로 가져오지 않으므로 컬렉션에 적용해도 부모 행이 늘지 않아 페이징 조회와 함께 쓸 수 있다.', '식별자 IN 절로 자식만 따로 가져오니 부모 조회 결과의 행 수가 그대로다. 그래서 SQL LIMIT으로 부모 개수를 정확히 자를 수 있어, 컬렉션이 필요한 페이징 조회에서 fetch join 대신 쓴다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1420, 4395, '@EntityGraph,EntityGraph,Entity Graph,엔티티 그래프,엔티티그래프,@EntityGraph(attributePaths = "member"),@EntityGraph(attributePaths = {"member"})', '메서드 이름으로 만든 쿼리 위에 애노테이션을 얹어 함께 로딩할 연관 속성을 선언하는 @EntityGraph를 붙인 상황이다(예: attributePaths = "member"). 쿼리 문자열 없이 선언 위에 한 줄만 더했다는 점, 로그의 조인이 LEFT OUTER JOIN이라 회원이 없는 주문도 빠지지 않았다는 점이 그 근거다. fetch join은 JPQL 문자열 안에 써야 하고 기본이 INNER JOIN이라 비회원 주문이 결과에서 빠진다. batch size는 조인이 아니라 목록 조회 뒤 IN 절 쿼리를 따로 보내므로 SELECT가 한 번으로 줄지 않는다.'),
       (1421, 4396, 'LazyInitializationException,org.hibernate.LazyInitializationException,Lazy Initialization Exception,LazyInitialization Exception,지연 초기화 예외,지연 로딩 예외,레이지 이니셜라이제이션 익셉션', '지연 로딩으로 매핑한 member 자리에는 프록시가 들어 있고, 프록시는 실제 값을 읽는 순간 영속성 컨텍스트를 거쳐 SELECT를 실행해 자신을 채운다. 그런데 트랜잭션은 서비스 메서드가 끝날 때 함께 끝났고 open-in-view도 꺼져 있어, 컨트롤러에서 getName()을 부를 때는 영속성 컨텍스트가 이미 닫혀 있다. 그래서 SQL을 보내지 못하고 초기화에 실패해 LazyInitializationException이 난다. member 조회 SQL이 끝내 나가지 않았다는 로그가 그 근거로, 컨텍스트가 살아 있었다면 이 줄에서 SELECT가 한 번 나가고 정상 응답했을 것이다. member가 null이라 나는 NullPointerException과는 다르다. member 자리는 null이 아니라 아직 채워지지 않은 프록시다. 해결하려면 서비스 안에서 fetch join 등으로 필요한 연관을 미리 채우거나, 필요한 값만 DTO로 옮겨 반환한다.');

-- =====================================================
-- Lesson 860: 연관관계 주인과 다중 컬렉션 페치 조인
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5339, 860, '아래 코드를 실행했을 때 나가는 SELECT의 총 횟수는?', '```java
@Entity
public class Member {
    @Id @GeneratedValue
    private Long id;

    @OneToOne(mappedBy = "member", fetch = FetchType.LAZY)
    private Locker locker;
}

@Entity
public class Locker {
    @Id @GeneratedValue
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member member;
}
```

```java
List<Member> members = em.createQuery("select m from Member m", Member.class)
        .getResultList();
```

- 회원은 30명이고, 모두 서로 다른 사물함을 하나씩 갖고 있다.
- 비어 있는 영속성 컨텍스트에서 실행하며, 조회 뒤 어떤 필드에도 접근하지 않는다.
- batch size 등 별도 설정은 없다.', 'OBJECTIVE'),
       (5340, 860, '아래 코드를 실행했을 때 일어나는 일로 옳은 것은?', '```java
List<Order> orders = em.createQuery(
        "select o from Order o join fetch o.orderItems oi where oi.price >= 10000",
        Order.class)
    .getResultList();

Order order = em.find(Order.class, 1L);
int count = order.getOrderItems().size();

tx.commit();
```

- Hibernate 6 기준이며, 위 코드는 한 트랜잭션 안에서 이어서 실행한다.
- `Order.orderItems`는 `@OneToMany(mappedBy = "order")`로 매핑한 `List<OrderItem>`이다(cascade·orphanRemoval 없음).
- 주문 1에는 order_item 행이 5건 있고, 그중 price가 10,000 이상인 것은 2건이다.', 'OBJECTIVE'),
       (5341, 860, '아래 예외를 없애면서 두 목록을 모두 적은 쿼리로 가져오는 수정으로 옳은 것은?', '```java
@Entity
public class Order {
    @Id @GeneratedValue
    private Long id;

    @OneToMany(mappedBy = "order")
    private List<OrderItem> orderItems = new ArrayList<>();

    @OneToMany(mappedBy = "order")
    private List<Coupon> coupons = new ArrayList<>();
}
```

```java
public interface OrderRepository extends JpaRepository<Order, Long> {
    @Query("select o from Order o join fetch o.orderItems join fetch o.coupons")
    List<Order> findAllWithDetails();
}
```

주문 목록 화면에는 주문마다 주문 상품 목록과 적용된 쿠폰 목록이 모두 필요하고, 페이징은 쓰지 않는다. 위 조회를 추가하자 아래 예외가 발생했다(발췌).

```
org.hibernate.loader.MultipleBagFetchException: cannot simultaneously fetch multiple bags: [com.shop.Order.orderItems, com.shop.Order.coupons]
```', 'OBJECTIVE'),
       (5342, 860, '아래 조회 방식에 대한 설명으로 옳은 것은?', '```java
public class OrderSummary {
    private Long orderId;
    private String memberName;
    private int totalPrice;

    public OrderSummary(Long orderId, String memberName, int totalPrice) {
        this.orderId = orderId;
        this.memberName = memberName;
        this.totalPrice = totalPrice;
    }
    // getter·setter 생략
}
```

```java
List<OrderSummary> result = em.createQuery(
        "select new com.shop.dto.OrderSummary(o.id, m.name, o.totalPrice) "
      + "from Order o join o.member m", OrderSummary.class)
    .getResultList();
```

- `Order.member`는 `@ManyToOne(fetch = FetchType.LAZY)`로 매핑돼 있다.
- 조회되는 주문은 50건이다.', 'OBJECTIVE'),
       (5343, 860, '아래 두 실험 결과로 볼 때, (실험 2)에서 값을 넣은 쪽 필드가 양방향 매핑에서 맡은 역할을 가리키는 용어는?', 'Member와 Order는 아래처럼 양방향으로 매핑돼 있다.

```java
// Member
@OneToMany(mappedBy = "member")
private List<Order> orders = new ArrayList<>();

// Order
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "member_id")
private Member member;
```

두 실험은 각각 새 트랜잭션에서 실행했고, 회원 1은 이미 저장돼 있다.

```java
// (실험 1)
Member member = em.find(Member.class, 1L);
Order order = new Order();
member.getOrders().add(order);
em.persist(order);
tx.commit();
```

```java
// (실험 2)
Member member = em.find(Member.class, 1L);
Order order = new Order();
order.setMember(member);
em.persist(order);
tx.commit();
```

두 실험 모두 예외 없이 커밋됐고, orders 테이블에 새로 들어간 행은 아래와 같다.

| 실험 | 새 행의 member_id |
|---|---|
| (실험 1) | null |
| (실험 2) | 1 |', 'SUBJECTIVE'),
       (5344, 860, '아래 측정에서 값을 바꿔 가며 조정한 Hibernate 설정을 가리키는 이름은?', '주문 500건을 목록으로 조회한 뒤, 반복문에서 각 주문의 `orderItems`(지연 로딩)에 접근하는 API가 있다. 코드는 그대로 두고 `application.yml`에서 Hibernate 설정 값 하나만 바꿔 가며 측정했다.

| 설정 값 | 요청 한 번에 실행된 SELECT 수 | 응답 시간 |
|---|---|---|
| 지정 안 함 | 501 | 3.4초 |
| 10 | 51 | 420ms |
| 100 | 6 | 95ms |

설정 값이 100일 때의 쿼리 로그(발췌):

```
select ... from orders
select ... from order_item where order_id in (?, ?, ?, ..., ?)   -- 물음표 100개
select ... from order_item where order_id in (?, ?, ?, ..., ?)   -- 물음표 100개
...
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5339
(14411, 5339, '1회', 'fetch = FetchType.LAZY를 지정했으니 프록시가 들어간다고 본 값. 사물함 외래 키는 locker 테이블에만 있어 회원 행만 보고는 사물함이 있는지(프록시) 없는지(null) 정할 수 없으므로, mappedBy 쪽은 지연 로딩을 지정해도 곧바로 조회된다.', false),
(14412, 5339, '2회', '즉시 로딩되더라도 사물함을 IN 절이나 조인 한 번으로 모아 온다고 본 값. JPQL은 작성한 대로 회원만 조회하고, batch size 설정이 없으므로 사물함은 회원마다 따로 SELECT된다.', false),
(14413, 5339, '31회', '회원 목록 조회 1회 뒤, 외래 키가 없는 mappedBy 쪽이라 프록시로 둘 수 없는 locker를 채우려고 회원마다 사물함을 SELECT해 30회가 더 나간다. 필드에 접근하지 않았는데도 N+1이 생긴다.', true),
(14414, 5339, '61회', '사물함을 가져온 뒤 Locker.member를 채우려고 회원을 다시 조회한다고 본 값. 그 회원들은 이미 영속성 컨텍스트에 있어 추가 SELECT 없이 같은 객체로 연결된다.', false),

-- 문제 5340
(14415, 5340, 'count는 5다. where 조건은 가져올 주문만 고를 뿐, 컬렉션에는 주문 상품이 모두 채워진다.', 'fetch join 대상에 별칭을 붙여 where로 거르면 그 조건이 컬렉션을 채우는 행에도 걸린다. 조건이 부모만 고른다고 본 오개념으로, 주문 1의 컬렉션은 조건을 통과한 2건으로만 초기화된다.', false),
(14416, 5340, 'count는 2다. 조건을 통과한 주문 상품만 담긴 컬렉션이 영속성 컨텍스트의 주문 1에 그대로 남아 있다.', 'fetch join은 조인 결과 행으로 컬렉션을 초기화하는데, where가 price 10,000 미만 행을 걸러 2건만 담겼다. em.find는 영속성 컨텍스트의 같은 주문을 돌려주므로 DB의 5건과 어긋난 컬렉션을 보게 된다. 그래서 fetch join 대상은 where로 거르지 않는다.', true),
(14417, 5340, 'count는 5다. em.find가 DB를 다시 읽어 주문 1의 컬렉션을 주문 상품 5건으로 새로 채운다.', 'em.find는 먼저 영속성 컨텍스트를 확인해 이미 관리 중인 주문 1을 SELECT 없이 돌려준다. 초기화가 끝난 컬렉션도 다시 읽지 않으므로 2건인 채로 남는다. 어긋난 상태가 스스로 바로잡히지 않는 이유다.', false),
(14418, 5340, 'count는 2다. 커밋하면 컬렉션에 담기지 않은 주문 상품 3건의 order_item 행이 삭제된다.', '컬렉션은 처음부터 2건으로 초기화된 것이지 3건을 뺀 것이 아니다. 게다가 mappedBy 쪽 컬렉션은 DB에 쓰지 않고 orphanRemoval도 없어 DELETE는 나가지 않는다. 문제는 행 삭제가 아니라 메모리 상태가 DB와 어긋나는 것이다.', false),

-- 문제 5341
(14419, 5341, '두 join fetch를 모두 left join fetch로 바꿔 쿠폰이 없는 주문도 결과에 남긴다.', '조인 종류를 바꾸면 결과에 남는 주문만 달라질 뿐, List 컬렉션 두 개를 한 조인으로 가져오는 구조는 그대로라 같은 예외가 난다. 원인은 빈 연관이 아니라 두 컬렉션이 곱해져 행이 폭증하는 카테시안 곱이다.', false),
(14420, 5341, '두 컬렉션을 @EntityGraph의 attributePaths로 옮겨 JPQL 없이 함께 로딩한다.', '@EntityGraph도 조인으로 함께 가져오므로 List 컬렉션 두 개를 지정하면 같은 MultipleBagFetchException이 난다. 선언 위치만 JPQL에서 애노테이션으로 바뀔 뿐 카테시안 곱 문제는 그대로다.', false),
(14421, 5341, 'select o를 select distinct o로 바꿔 조인으로 중복된 주문을 결과에서 걸러 낸다.', 'distinct는 조인으로 중복된 부모를 걸러 줄 뿐, 두 컬렉션을 한꺼번에 조인하는 구조는 바뀌지 않아 예외가 그대로 난다. Hibernate 6부터는 부모 중복 제거도 자동이라 distinct를 붙일 이유도 없다.', false),
(14422, 5341, 'orderItems만 join fetch로 남기고, coupons는 batch size를 설정해 IN 절로 묶어 가져온다.', '컬렉션 fetch join을 하나만 두면 두 컬렉션이 곱해지지 않아 예외가 사라진다. coupons는 지연 로딩이 일어날 때 주문 식별자를 IN 절로 묶어 가져오므로 N+1 없이 적은 쿼리로 끝난다. 컬렉션 타입을 Set으로 바꾸는 방법도 있다.', true),

-- 문제 5342
(14423, 5342, '결과 객체는 영속성 컨텍스트가 관리하지 않아, memberName을 바꾸고 커밋해도 UPDATE가 나가지 않는다.', 'select new로 만든 객체는 엔티티가 아니라 값만 담은 DTO라 영속성 컨텍스트가 스냅샷을 두지 않고 변경 감지도 하지 않는다. 화면 전용 데이터를 가볍게 가져오는 DTO 프로젝션의 성질이며, 데이터를 고치려면 엔티티를 조회해 수정해야 한다.', true),
(14424, 5342, 'join o.member는 일반 join이라 회원을 로딩하지 않으므로, 결과마다 회원 이름을 가져오는 SELECT가 따로 나간다.', '일반 join은 연관 엔티티를 채우지 않는다는 규칙을 여기에 잘못 넓힌 것. 이 조회는 회원 엔티티를 채우는 것이 아니라 m.name 값을 SELECT 절에서 바로 꺼내므로, 조인 한 번에 이름까지 담기고 추가 SELECT가 없다.', false),
(14425, 5342, '회원 이름까지 담으려면 join을 join fetch로 바꿔야 하며, 그대로 두면 memberName이 null로 채워진다.', '연관 데이터를 쓰려면 늘 fetch join이 필요하다고 오해한 것. fetch join은 연관 엔티티를 영속 상태로 채우는 기능이라 엔티티가 아닌 DTO를 만드는 조회와는 맞지 않는다. 조인과 m.name만으로 이름이 채워진다.', false),
(14426, 5342, 'orders 테이블의 모든 컬럼을 먼저 SELECT한 뒤, 그중 생성자 인자에 쓴 값만 골라 객체를 만든다.', 'JPA가 늘 엔티티 전체를 읽는다고 오해한 것. 생성자 표현식에 적은 o.id, m.name, o.totalPrice만 SQL의 SELECT 절에 들어가므로, 필요한 컬럼만 가져와 전송량이 줄어드는 것이 이 방식의 장점이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1736, 5343, '연관관계 주인,연관관계의 주인,연관 관계 주인,연관 관계의 주인,연관관계 주인 쪽,관계의 주인,주인,owner,owning side,owner side', '외래 키 값을 실제로 정하는 쪽이 연관관계 주인이다. 양방향 매핑은 객체 쪽 참조가 Order.member와 Member.orders 두 개인데 테이블의 외래 키는 orders.member_id 하나뿐이라, JPA는 둘 중 한쪽만 그 값을 정하게 한다. @JoinColumn을 둔 Order.member가 주인이고, mappedBy를 붙인 Member.orders는 조회에만 쓰인다. 그래서 (실험 1)처럼 주인이 아닌 컬렉션에만 담으면 member_id가 null로 저장되고, (실험 2)처럼 주인 필드에 값을 넣어야 DB에 반영된다. 다만 (실험 2)만 하면 메모리의 member.getOrders()에는 새 주문이 없어 객체 상태가 어긋나므로, 양쪽을 한 번에 세팅하는 편의 메서드를 두는 것이 좋다. mappedBy는 주인이 누구인지 지정하는 속성 이름일 뿐 역할의 이름이 아니며, 보통 @ManyToOne 쪽이 주인이 되는 것은 외래 키가 N 쪽 테이블에 있기 때문이다.'),
       (1737, 5344, 'batch size,batch fetch size,배치 사이즈,배치사이즈,배치 크기,배치 페치 사이즈,default_batch_fetch_size,hibernate.default_batch_fetch_size,@BatchSize,BatchSize,batchsize', '지연 로딩이 일어날 때 아직 초기화되지 않은 같은 타입의 컬렉션(또는 프록시)을 모아, 식별자를 IN 절로 묶어 한 번에 가져오게 하는 설정이 batch size(전역은 hibernate.default_batch_fetch_size, 개별 지정은 @BatchSize)다. 주문 500건일 때 설정 값이 10이면 500 / 10 = 50회, 100이면 5회로 줄고, 목록 조회 1회가 더해져 51회·6회가 된다. 로그의 물음표 100개가 한 번에 묶은 식별자 수다. fetch join과 달리 조인이 아니라 부모 행이 늘지 않으므로 페이징과 함께 쓸 수 있고, 대신 목록 조회와 별도로 IN 쿼리가 나간다. INSERT를 묶어 보내는 hibernate.jdbc.batch_size(쓰기 배치)와는 이름이 비슷하지만 전혀 다른 설정이다.');
