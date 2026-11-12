-- Unit: JPA 쓰기와 식별자 전략 (Unit ID: 119)
-- Chapter: Spring (Chapter ID: 10)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (545, 119, '벌크 연산과 IDENTITY 채번'),
       (703, 119, '신규 엔티티 판단과 시퀀스 할당 크기'),
       (861, 119, '공유 엔티티 삭제 전이와 TABLE 전략');

-- =====================================================
-- Lesson 545: 벌크 연산과 IDENTITY 채번
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3449, 545, '위 코드를 실행한 뒤 a와 b의 값은?', '시작 상태: member 테이블에 id=1, age=20인 행이 한 건 있다. 아래는 모두 하나의 트랜잭션 안에서 실행된다.

```java
public interface MemberRepository extends JpaRepository<Member, Long> {
    @Modifying   // flushAutomatically, clearAutomatically 를 지정하지 않았다
    @Query("update Member m set m.age = m.age + 1 where m.id = 1")
    int plusOne();
}
```

```java
Member m = memberRepository.findById(1L).get();
memberRepository.plusOne();       // 이 시점에 DB의 age는 21이 된다
int a = m.getAge();
int b = memberRepository.findById(1L).get().getAge();
```', 'OBJECTIVE'),
       (3450, 545, '아래 식별자 생성 전략에 대한 설명으로 옳은 것은?', '이 식별자 생성 전략은 기본 키 채번을 DB의 AUTO_INCREMENT 컬럼에 맡긴다. 애플리케이션은 저장 전에 키 값을 알 수 없고, 행이 테이블에 실제로 들어간 뒤에야 DB가 매긴 값을 돌려받는다. MySQL 환경에서 가장 흔하게 쓰인다.', 'OBJECTIVE'),
       (3451, 545, '위 표의 삭제 메서드에 대한 설명으로 옳지 않은 것은?', 'Spring Data JPA 리포지토리가 제공하는 삭제 메서드의 내부 동작이다.

| 메서드 | 내부 동작 |
|---|---|
| deleteById(id) | findById로 조회한 뒤, 있으면 remove() 호출 |
| deleteAll() | 전체를 조회해 엔티티마다 remove() 호출 |
| deleteAllInBatch() | JPQL delete 문 한 번을 DB에 바로 실행 |', 'OBJECTIVE'),
       (3452, 545, '아래 코드에서 INSERT 앞에 SELECT가 한 번 더 나간 이유로 옳은 것은?', '```java
@Entity
public class Coupon {
    @Id
    private String code;
    private int discount;
}
```

```java
// 트랜잭션 안. coupon 테이블은 비어 있다.
couponRepository.save(new Coupon("WELCOME10", 10));
```

실행된 SQL 로그:

```
select c1_0.code, c1_0.discount from coupon c1_0 where c1_0.code=?
insert into coupon (discount, code) values (?, ?)
```', 'OBJECTIVE'),
       (3453, 545, '아래 상황에서 켠 연관관계 매핑 옵션의 이름은?', '주문 화면에서 주문상품 한 줄을 빼는 기능을 만들었다. 트랜잭션 안에서 order.getOrderItems().remove(item)을 호출하고 커밋했더니, 화면에서는 줄이 사라졌는데 order_item 테이블에는 그 행이 그대로 남아 부모 주문과 끊긴 데이터가 매달 수천 건씩 쌓였다. 부모가 삭제될 때만 자식이 지워지는 옵션은 이미 켜져 있었다. 여기에 옵션 하나를 더 true로 바꾸자, 코드를 그대로 둔 채 커밋 시점에 delete from order_item where id=?가 한 번 실행되며 남던 행이 함께 정리됐다.', 'SUBJECTIVE'),
       (3454, 545, '아래 상황에서 JDBC URL에 추가한 MySQL 드라이버 옵션의 이름은?', '회원 1,000건을 저장하는 배치 작업이 4.2초 걸려 아래 설정을 넣었다.

```yaml
spring:
  jpa:
    properties:
      hibernate:
        jdbc.batch_size: 100
        order_inserts: true
```

그래도 MySQL 쿼리 로그에는 insert into member ... 가 1,000줄 그대로 찍혔다. JDBC URL 끝에 옵션 하나를 붙이자 같은 코드에서 로그가 insert into member ... values (...),(...),... 형태 10줄로 줄고 소요 시간이 0.5초가 됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3449
(9371, 3449, 'a = 21, b = 21', '벌크 연산이 1차 캐시까지 함께 갱신한다고 본 오개념. JPQL update는 영속성 컨텍스트를 거치지 않고 DB에만 실행되므로 이미 영속 상태인 m의 값은 바뀌지 않는다.', false),
(9372, 3449, 'a = 20, b = 20', '벌크 연산은 DB의 age만 21로 바꾸고 1차 캐시의 m은 20인 채로 남는다. 같은 트랜잭션의 findById는 1차 캐시에 있는 그 엔티티를 그대로 돌려주므로 다시 조회해도 20이다.', true),
(9373, 3449, 'a = 20, b = 21', '조회해 둔 참조는 낡아도 재조회하면 DB를 새로 읽는다고 본 오개념. 같은 영속성 컨텍스트에 이미 있는 엔티티는 SELECT 없이 반환되므로 clearAutomatically로 컨텍스트를 비우기 전에는 새 값을 볼 수 없다.', false),
(9374, 3449, 'a = 21, b = 20', '벌크 연산이 이미 조회한 엔티티에 먼저 반영되고 재조회가 옛 값을 준다고 본 뒤집힌 오해. 벌크 연산은 자바 객체를 건드리지 않고 DB만 갱신한다.', false),

-- 문제 3450
(9375, 3450, '채번한 키를 미리 확보해 두므로 flush 전까지 INSERT를 모아 둘 수 있다.', 'SEQUENCE 전략의 동작을 갖다 붙인 오개념. 시퀀스는 행을 넣지 않고도 다음 값을 먼저 받아올 수 있지만, DB의 AUTO_INCREMENT는 행이 들어가야 값이 정해진다.', false),
(9376, 3450, 'allocationSize를 키우면 키 채번을 위한 DB 왕복 횟수가 줄어든다.', 'allocationSize는 시퀀스에서 ID 범위를 한 번에 받아 메모리에서 나눠 쓰기 위한 설정이다. 채번을 DB 컬럼에 맡기는 이 전략에는 적용할 자리가 없다.', false),
(9377, 3450, '키 전용 테이블의 행을 잠그고 다음 값을 읽으므로 동시성 경합이 생긴다.', 'TABLE 전략의 동작이다. 키 테이블로 시퀀스를 흉내 내 어떤 DB에서도 쓸 수 있지만 락 경합으로 느리다는 점이 이 전략과 갈린다.', false),
(9378, 3450, '여러 건을 저장해도 INSERT가 한 건씩 나가 JDBC 배치로 묶이지 않는다.', '영속성 컨텍스트는 식별자를 키로 엔티티를 관리하므로 persist 시점에 ID가 있어야 한다. 값을 DB에서 받아와야 하니 INSERT를 flush까지 미룰 수 없고, 쓰기 지연이 깨져 배치로 묶을 대상이 남지 않는다.', true),

-- 문제 3451
(9379, 3451, 'deleteById(id)는 한 건을 지우는 데 SELECT와 DELETE가 각각 나가 쿼리가 2회 실행된다.', '표대로 findById로 먼저 조회한 뒤 remove()를 부르므로 참이다. 조회 없이 바로 지우려면 JPQL delete를 직접 선언해 쓴다.', false),
(9380, 3451, 'deleteAll()로 1,000건을 지우면 DELETE가 1,000번 나가 deleteAllInBatch()보다 느리다.', '엔티티마다 remove()를 호출하므로 참이다. 대신 건별 remove라 엔티티 생명주기 콜백과 Cascade가 정상 동작한다는 이점이 있다.', false),
(9381, 3451, 'deleteAllInBatch()는 CascadeType.REMOVE 설정을 따라 자식 엔티티까지 함께 지운다.', '거짓이라 정답이다. JPQL delete는 영속성 컨텍스트를 거치지 않고 DB에 바로 나가므로 Cascade도 고아 객체 제거도 동작하지 않는다. 자식 테이블 정리는 직접 책임져야 한다.', true),
(9382, 3451, 'deleteAllInBatch()를 실행한 뒤에도 1차 캐시에는 지워진 엔티티가 남아 있을 수 있다.', '벌크 삭제는 컨텍스트를 우회하므로 참이다. 이미 조회해 둔 엔티티가 그대로 남아 재조회 때 없는 행을 그대로 돌려받으므로 실행 후 컨텍스트를 비워야 한다.', false),

-- 문제 3452
(9383, 3452, '@Id 값이 이미 채워져 있어 save()가 기존 엔티티로 판단하고 merge()를 호출했다.', 'save()는 isNew로 갈린다. @Id가 null도 0도 아니면 준영속 엔티티로 보고 merge()를 부르며, merge는 병합할 대상을 찾으려 SELECT를 먼저 던진다. Persistable을 구현해 isNew를 직접 정하면 persist로 돌릴 수 있다.', true),
(9384, 3452, '@GeneratedValue가 없어 다음 키를 정하려고 저장 전에 최댓값을 조회한다.', '직접 할당한 키에 대해 최댓값을 조회하는 동작은 없다. 자동 채번이 없으면 준 값을 그대로 쓴다. SELECT는 채번이 아니라 merge 경로를 탔기 때문에 나간 것이다.', false),
(9385, 3452, '쓰기 지연 저장소가 INSERT를 모으기 전에 중복 키를 미리 확인한다.', '쓰기 지연 저장소는 SQL을 모아 두었다가 flush에 내보낼 뿐 중복 검사를 하지 않는다. 키 중복은 INSERT가 실제로 나갈 때 DB 제약이 잡는다.', false),
(9386, 3452, '문자열 타입 @Id는 1차 캐시의 키로 쓸 수 없어 조회 때마다 DB를 확인한다.', '1차 캐시는 식별자 타입을 가리지 않으므로 String 키도 그대로 캐시 키가 된다. SELECT가 나간 이유는 키 타입이 아니라 isNew 판단 결과다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1106, 3453, 'orphanRemoval,orphanRemoval=true,orphan removal,고아 객체 제거,고아객체 제거', '부모 컬렉션에서 빠져 참조가 끊긴 자식을 flush 시점에 DELETE하는 옵션이 orphanRemoval이다. 이미 켜져 있던 CascadeType.REMOVE는 부모가 삭제될 때 자식을 따라 지우는 것이라, 부모가 살아 있고 자식만 컬렉션에서 빠진 이 상황에서는 아무 일도 하지 않는다. 둘의 차이는 삭제를 부르는 계기가 부모의 삭제인지, 참조가 끊기는 것인지에 있다. 다만 이 옵션은 부모가 자식 생명주기를 온전히 소유한다는 전제가 있어야 하므로, 자식이 다른 엔티티에서도 참조된다면 쓰지 않는다.'),
       (1107, 3454, 'rewriteBatchedStatements,rewriteBatchedStatements=true,rewrite batched statements', 'JDBC 배치로 INSERT를 묶어도 MySQL 드라이버는 기본값에서 이를 한 건씩 나눠 전송하므로 로그가 1,000줄로 남는다. rewriteBatchedStatements=true를 켜야 드라이버가 여러 INSERT를 다중 VALUES 한 문장으로 재작성해 실제 왕복이 줄어든다. jdbc.batch_size는 몇 건씩 묶을지를, order_inserts는 같은 테이블끼리 모으는 순서를 정할 뿐 전송 방식까지 바꾸지는 않는다. 또 식별자 생성 전략이 IDENTITY면 INSERT가 persist마다 즉시 나가 묶일 대상 자체가 없으므로, 이 옵션을 켜도 효과가 없다.');

-- =====================================================
-- Lesson 703: 신규 엔티티 판단과 시퀀스 할당 크기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4397, 703, '아래 코드를 실행했을 때 DB로 나가는 SQL을 순서대로 나타낸 것은?', 'product 테이블은 비어 있고, 아래 코드는 모두 하나의 트랜잭션 안에서 실행된다.

```java
@Entity
public class Product {
    @Id
    private String sku;          // 생성자에서 직접 넣는다

    @Version
    private Long version;

    private int price;

    protected Product() {}

    public Product(String sku, int price) {
        this.sku = sku;
        this.price = price;
    }
}
```

```java
// productRepository는 JpaRepository<Product, String>을 상속한 Spring Data JPA 리포지토리
productRepository.save(new Product("P-100", 5000));
```', 'OBJECTIVE'),
       (4398, 703, '아래 메서드가 정상 커밋된 뒤 account 테이블의 id=1 행 값으로 옳은 것은?', '시작 상태의 account 테이블:

| id | balance | version | updated_at |
|---|---|---|---|
| 1 | 300 | 3 | 2026-09-01 10:00 |

```java
@Entity
public class Account {
    @Id @GeneratedValue
    private Long id;

    private int balance;

    @Version
    private Long version;

    private LocalDateTime updatedAt;

    @PreUpdate
    void touch() {
        this.updatedAt = LocalDateTime.now();
    }
}

public interface AccountRepository extends JpaRepository<Account, Long> {
    @Modifying(clearAutomatically = true)
    @Query("update Account a set a.balance = a.balance + 200 where a.id = 1")
    int deposit();
}
```

```java
@Transactional   // 2026-09-13 15:00에 실행됐다
public void run() {
    accountRepository.deposit();
}
```', 'OBJECTIVE'),
       (4399, 703, '아래 코드를 실행했을 때 변수 a와 b에 담기는 값은?', 'tag 테이블은 비어 있고, 아래 코드는 모두 하나의 트랜잭션 안에서 실행된다.

```java
@Entity
public class Tag {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    protected Tag() {}

    public Tag(String name) {
        this.name = name;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Tag other)) return false;
        return Objects.equals(id, other.id);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(id);
    }
}
```

```java
Set<Tag> tags = new HashSet<>();
Tag jpa = new Tag("jpa");
Tag spring = new Tag("spring");
tags.add(jpa);
tags.add(spring);
int a = tags.size();

em.persist(jpa);
boolean b = tags.contains(jpa);
```', 'OBJECTIVE'),
       (4400, 703, '아래 연관관계 매핑에 대한 설명으로 옳은 것은?', '게시글(Post)과 첨부파일(Attachment)은 1:N 관계다. 외래 키 post_id는 attachment 테이블에 있어 Attachment.post가 연관관계의 주인이고, Post.attachments는 mappedBy로 매핑했다. Post.attachments에는 cascade = CascadeType.ALL과 orphanRemoval = true를 함께 걸었고, Attachment.post에는 Cascade 옵션을 걸지 않았다.', 'OBJECTIVE'),
       (4401, 703, '아래 상황에서 값을 바꾼 속성의 이름은?', 'PostgreSQL에서 SEQUENCE 전략으로 식별자를 받는 주문(Order) 엔티티를 10,000건 저장하는 배치 작업이 있다. 처음에는 로그에 `select nextval(''orders_seq'')`가 INSERT와 똑같이 10,000번 찍혔다.

@SequenceGenerator에 1로 적혀 있던 속성 하나를 50으로 바꾸고, DB 쪽도 `ALTER SEQUENCE orders_seq INCREMENT BY 50`으로 맞췄다. 같은 작업을 다시 돌리자 INSERT는 그대로 10,000번 나갔지만 `select nextval(''orders_seq'')`는 약 200번만 찍혔다.', 'SUBJECTIVE'),
       (4402, 703, '아래 상황에서 표시한 자리에 추가한 EntityManager 메서드의 이름은?', '회원 500,000건을 한 트랜잭션에서 저장하는 이관 코드다. 식별자 전략은 SEQUENCE이고 hibernate.jdbc.batch_size는 100이다.

```java
Member admin = em.find(Member.class, 1L);   // 루프 전에 미리 조회해 둔 관리자 회원

for (int i = 0; i < rows.size(); i++) {
    em.persist(new Member(rows.get(i)));
    if ((i + 1) % 100 == 0) {
        em.flush();
        // ← 표시한 자리
    }
}

admin.changeGrade("VIP");
```

처음에는 INSERT가 100건씩 묶여 잘 나갔는데도 힙 사용량이 300MB에서 멈추지 않고 올라, 약 310,000건째에 OutOfMemoryError로 중단됐다. 표시한 자리에 EntityManager 메서드 호출 한 줄을 넣자 힙이 350MB 안팎에서 오르내리며 500,000건이 모두 저장됐다. 대신 그 뒤로는 커밋해도 admin의 등급을 바꾸는 UPDATE가 나가지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4397
(11899, 4397, 'SELECT 1회 → INSERT 1회', '식별자를 직접 넣으면 save()가 무조건 merge()로 간다고 본 오개념. Spring Data JPA는 래퍼 타입 @Version 필드가 있으면 식별자보다 버전 값을 먼저 보고, version이 null인 이 엔티티를 새 것으로 판단해 persist()를 호출한다.', false),
(11900, 4397, 'SELECT 1회 → UPDATE 1회', 'merge()가 늘 기존 행을 고친다는 오해까지 겹친 경우. 이 코드는 merge()로 가지 않으며, 설령 merge()였더라도 SELECT로 행을 찾지 못하면 UPDATE가 아니라 INSERT가 나간다.', false),
(11901, 4397, 'INSERT 1회', 'save()는 isNew 판단으로 persist와 merge를 가르는데, 래퍼 타입 @Version 필드가 있으면 그 값이 null인지를 기준으로 삼는다. version이 null이라 persist()가 호출되고, 병합 대상을 찾는 SELECT 없이 INSERT만 나간다.', true),
(11902, 4397, 'INSERT 1회 → UPDATE 1회', '버전 값을 채우려고 INSERT 뒤에 UPDATE를 한 번 더 보낸다고 본 오개념. 새 엔티티의 버전 초기값은 INSERT에 함께 담겨 저장되고, 버전 증가는 이후 변경 감지로 UPDATE가 나갈 때 일어난다.', false),

-- 문제 4398
(11903, 4398, 'balance = 500, version = 4, updated_at = 2026-09-13 15:00', '벌크 연산도 엔티티를 거쳐 갱신된다고 본 오개념. JPQL update는 영속성 컨텍스트를 우회해 SQL 한 문장으로 DB에 바로 실행되므로, 엔티티 단위로 동작하는 @PreUpdate 콜백도 @Version 증가도 일어나지 않는다.', false),
(11904, 4398, 'balance = 500, version = 3, updated_at = 2026-09-01 10:00', '벌크 연산은 엔티티 객체를 거치지 않고 SET에 적은 컬럼만 DB에서 고친다. 그래서 balance만 500이 되고, 엔티티 단위로 동작하는 @Version 증가와 @PreUpdate 콜백은 적용되지 않는다. 이런 부가 동작이 필요하면 엔티티를 조회해 변경 감지로 고쳐야 한다.', true),
(11905, 4398, 'balance = 500, version = 4, updated_at = 2026-09-01 10:00', '버전은 UPDATE가 나가면 DB가 알아서 올린다고 본 오개념. @Version 증가는 JPA 구현체가 변경 감지로 만든 UPDATE에 직접 넣는 값이라, 버전 갱신을 SET에 적지 않은 이 벌크 연산에서는 3 그대로 남는다.', false),
(11906, 4398, 'balance = 300, version = 3, updated_at = 2026-09-01 10:00', 'clearAutomatically가 벌크 결과까지 되돌린다고 본 오개념. clear는 영속성 컨텍스트만 비울 뿐 이미 DB에 실행된 UPDATE를 취소하지 않으므로, 트랜잭션이 커밋되면 balance는 500으로 남는다.', false),

-- 문제 4399
(11907, 4399, 'a = 2, b = true', 'id 기반 equals·hashCode가 저장 전후 모두 문제없다고 본 오개념. 저장 전에는 두 태그의 id가 모두 null이라 Objects.equals(null, null)이 true가 되고, 저장 뒤에는 id가 채워져 해시값이 달라진다.', false),
(11908, 4399, 'a = 2, b = false', '저장 뒤 해시값이 바뀌는 문제만 보고 저장 전 문제를 놓친 경우. 두 태그 모두 id가 null이면 hashCode가 같고 equals도 true라, HashSet은 spring을 이미 있는 원소로 보고 넣지 않는다.', false),
(11909, 4399, 'a = 1, b = true', '식별자가 커밋할 때 채워진다고 본 오개념. IDENTITY 전략은 persist() 시점에 INSERT를 바로 실행해 식별자를 받아오므로 jpa의 hashCode가 곧바로 바뀌고, HashSet은 바뀐 해시값으로 찾아 옛 해시값 자리에 있는 원소를 찾지 못한다.', false),
(11910, 4399, 'a = 1, b = false', '저장 전에는 id가 둘 다 null이라 hashCode와 equals 결과가 같아 spring이 중복으로 버려진다(a = 1). persist() 뒤 IDENTITY 전략이 id를 채우면 jpa의 해시값이 바뀌어 옛 자리의 원소를 못 찾는다(b = false). 비즈니스 키를 쓰거나 id가 null일 때의 처리를 정해야 한다.', true),

-- 문제 4400
(11911, 4400, 'postRepository.delete(post)로 첨부파일 30개가 달린 게시글을 지우면 첨부파일 DELETE 문이 30개 나간다.', 'CascadeType.ALL에 포함된 REMOVE는 DB의 ON DELETE CASCADE처럼 한 문장으로 지우지 않는다. JPA가 컬렉션의 자식 엔티티를 불러와 하나씩 remove()하므로 자식 수만큼 DELETE 문이 생기고, 자식이 많으면 대량 삭제 성능에 주의해야 한다.', true),
(11912, 4400, '새 게시글을 참조하는 새 첨부파일을 attachmentRepository.save()로 저장하면 게시글도 함께 INSERT된다.', 'Cascade가 연관관계 양쪽에 모두 적용된다고 본 오개념. 전이는 옵션을 건 Post.attachments에서 자식 방향으로만 일어난다. Attachment.post에는 옵션이 없어 게시글은 저장되지 않고, 저장되지 않은 객체를 참조한 채 flush하면 예외가 난다.', false),
(11913, 4400, '컬렉션 쪽은 연관관계의 주인이 아니어서, 새 게시글을 save()해도 컬렉션에 담은 첨부파일은 INSERT되지 않는다.', 'Cascade를 연관관계의 주인과 묶어 생각한 오개념. 주인은 외래 키를 누가 관리하느냐의 문제이고, Cascade는 이와 무관하게 mappedBy 쪽에서도 동작한다. 단, 첨부파일의 post를 세팅하지 않으면 외래 키가 채워지지 않는다.', false),
(11914, 4400, 'post.getAttachments().remove(file)만 호출하면 file 행은 남고 post_id를 NULL로 바꾸는 UPDATE가 나간다.', '참조가 끊기면 외래 키만 비워진다고 본 오개념. orphanRemoval이 켜져 있으면 컬렉션에서 빠진 첨부파일은 flush 시 DELETE된다. 또 mappedBy 쪽 컬렉션을 바꾸는 것만으로는 외래 키를 고치는 UPDATE가 나가지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1422, 4401, 'allocationSize,allocationSize=50,allocationSize = 50,allocation size,allocation_size', 'allocationSize는 시퀀스에서 식별자를 한 번에 몇 개씩 확보할지 정하는 속성이다. 1이면 엔티티마다 nextval을 호출해야 하지만, 50이면 한 번 호출로 50개 범위를 받아 메모리에서 나눠 쓰므로 10,000건에 호출이 약 200번으로 준다. 이 값은 DB 시퀀스의 INCREMENT BY와 같아야 하며, 다르면 식별자가 겹치거나 큰 공백이 생긴다. 시퀀스의 시작 값을 정하는 initialValue와 헷갈리기 쉬운데, initialValue를 바꿔도 nextval 호출 횟수는 줄지 않는다. 또 allocationSize는 식별자를 받아오는 왕복을 줄일 뿐, INSERT를 묶어 보내는 JDBC 배치 크기(hibernate.jdbc.batch_size)와는 별개의 설정이다.'),
       (1423, 4402, 'clear,clear(),em.clear(),em.clear,entityManager.clear(),entityManager.clear,클리어', 'flush()는 쓰기 지연 저장소에 쌓인 SQL을 DB로 내보낼 뿐, 영속성 컨텍스트에 올라온 엔티티와 변경 감지용 스냅샷은 그대로 둔다. 그래서 flush만 반복하면 저장한 엔티티가 1차 캐시에 계속 쌓여 메모리가 바닥난다. clear()는 영속성 컨텍스트를 통째로 비워 메모리 사용량을 일정하게 유지하지만, 그 전에 조회해 둔 admin도 함께 준영속이 되므로 값을 바꿔도 변경 감지가 일어나지 않는다. 엔티티 하나만 떼어 내는 detach()와 달리 전체를 비운다는 점, 그리고 flush 없이 clear만 하면 아직 DB로 나가지 않은 변경이 버려진다는 점도 함께 기억해야 한다.');

-- =====================================================
-- Lesson 861: 공유 엔티티 삭제 전이와 TABLE 전략
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5345, 861, '아래 코드를 실행하고 트랜잭션이 커밋된 뒤, same의 값과 DB에 저장된 balance 값은?', 'gift_card 테이블은 비어 있고, 아래 코드는 모두 하나의 트랜잭션 안에서 실행된다.

```java
@Entity
public class GiftCard {
    @Id
    private String cardNo;       // 생성자에서 직접 넣는다

    private int balance;

    protected GiftCard() {}

    public GiftCard(String cardNo, int balance) {
        this.cardNo = cardNo;
        this.balance = balance;
    }

    public void charge(int amount) {
        this.balance += amount;
    }
}
```

```java
// giftCardRepository는 JpaRepository<GiftCard, String>을 상속한 Spring Data JPA 리포지토리
GiftCard card = new GiftCard("GC-7788", 10000);
GiftCard saved = giftCardRepository.save(card);
card.charge(5000);
boolean same = (card == saved);
```', 'OBJECTIVE'),
       (5346, 861, '아래 run()이 커밋된 뒤 member 테이블 id=1 행에 남는 값은?', '시작 상태의 member 테이블:

| id | nickname | point |
|---|---|---|
| 1 | kim | 100 |

```java
public interface MemberRepository extends JpaRepository<Member, Long> {
    @Modifying(clearAutomatically = true)
    @Query("update Member m set m.point = m.point + 50")
    int giveEventPoint();
}
```

```java
@Transactional
public void run() {
    Member m = memberRepository.findById(1L).get();
    memberRepository.giveEventPoint();
    m.changeNickname("lee");   // nickname 필드를 바꾸는 메서드
}
```', 'OBJECTIVE'),
       (5347, 861, '아래 서비스에서 remove(999L)를 호출했을 때 일어나는 일로 옳은 것은?', 'Spring Boot 2.7(Spring Data JPA 2.7)에서 Spring Boot 3.2(Spring Data JPA 3.2)로 올린 뒤, 코드는 그대로 둔 서비스 메서드다. coupon 테이블에는 id = 999인 행이 없다.

```java
@Transactional
public void remove(Long id) {
    try {
        couponRepository.deleteById(id);
    } catch (EmptyResultDataAccessException e) {
        throw new CouponNotFoundException(id);
    }
}
```', 'OBJECTIVE'),
       (5348, 861, '아래 상황에서 주문 A를 삭제하고 커밋할 때 일어나는 일로 옳은 것은?', '회원은 자주 쓰는 배송지(Address)를 저장해 두고, 주문(Order)을 넣을 때마다 그중 하나를 골라 쓴다. 그래서 배송지 한 행을 여러 주문이 함께 가리킨다. 한 개발자가 "주문을 저장할 때 새 배송지도 같이 저장되면 편하다"며 Order.address에 아래처럼 Cascade를 걸었다.

```java
@Entity
@Table(name = "orders")
public class Order {
    @Id @GeneratedValue
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "address_id")
    private Address address;
}
```

Address 엔티티에는 주문을 가리키는 필드가 없다. 현재 배송지 id = 7을 주문 A·B·C가 함께 참조하고, orders.address_id에는 외래 키 제약이 걸려 있다. JPA 구현체는 Hibernate이며, 트랜잭션 안에서 주문 A만 조회해 orderRepository.delete(orderA)를 호출한다.', 'OBJECTIVE'),
       (5349, 861, '아래 로그를 남긴 엔티티의 @GeneratedValue에 지정된 strategy 값은?', 'MySQL을 쓰는 쿠폰 발급 API에 동시 요청이 몰리자 응답이 수 초씩 밀렸다. 쿠폰 엔티티를 저장하는 로그를 보면 INSERT 앞에 아래 SQL이 함께 찍혀 있었고, DB 모니터링에는 hibernate_sequences의 같은 행을 두고 여러 트랜잭션이 잠금을 기다리는 모습이 잡혔다.

```
select tbl.next_val from hibernate_sequences tbl where tbl.sequence_name=? for update
update hibernate_sequences set next_val=? where next_val=? and sequence_name=?
insert into coupon (code, member_id, id) values (?, ?, ?)
```', 'SUBJECTIVE'),
       (5350, 861, '아래 상황에서 true로 바꾼 Hibernate 설정의 이름은?', 'PostgreSQL에서 게시글(Post)과 첨부파일(Attachment)을 한 트랜잭션에서 500쌍 저장하는 작업이다. 두 엔티티 모두 SEQUENCE 전략으로 식별자를 받고, hibernate.jdbc.batch_size는 50이다.

```java
for (int i = 0; i < 500; i++) {
    Post post = new Post("title-" + i);
    em.persist(post);
    em.persist(new Attachment(post, "file-" + i));
}
```

커밋 시점의 SQL 로그에는 insert into post와 insert into attachment가 한 줄씩 번갈아 1,000줄 찍혔고, Hibernate 통계에는 JDBC 배치 실행이 1,000회로 남았다. 설정 하나를 true로 바꾸자 같은 코드에서 JDBC 배치 실행이 20회로 줄었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5345
(14427, 5345, 'same = true, balance = 15,000', 'save()가 인자 객체를 그대로 영속화한다고 본 오개념. cardNo를 직접 채워 isNew가 false라 persist()가 아닌 merge()가 호출되고, merge()는 인자와 다른 영속 객체를 새로 만들어 돌려준다.', false),
(14428, 5345, 'same = false, balance = 10,000', '식별자가 채워져 있어 save()는 merge()를 부른다. merge()는 SELECT로 행이 없음을 확인한 뒤 card의 값을 복사한 새 영속 객체를 반환하고 card 자체는 관리하지 않는다. 그래서 card.charge()는 변경 감지되지 않고 10,000이 INSERT된다.', true),
(14429, 5345, 'same = false, balance = 15,000', '다른 객체가 반환된다는 점은 맞지만 인자 객체의 변경이 영속 객체로 이어진다고 본 오개념. merge()는 호출 시점의 값을 한 번 복사할 뿐이라, 그 뒤 card를 바꿔도 영속 객체와 DB에는 반영되지 않는다.', false),
(14430, 5345, 'same = true, balance = 10,000', 'save() 호출 즉시 INSERT가 끝나 이후 변경은 버려진다고 본 오개념. 인자 객체가 영속 상태였다면 커밋 때 변경 감지로 15,000이 반영됐을 것이다. 변경이 빠진 진짜 이유는 card가 관리 대상이 아니기 때문이다.', false),

-- 문제 5346
(14431, 5346, 'nickname = lee, point = 150', '조회해 둔 m이 벌크 연산 뒤에도 영속 상태로 남는다고 본 오개념. clearAutomatically가 영속성 컨텍스트를 비우면서 m은 준영속이 되므로, 닉네임을 바꿔도 변경 감지 대상이 아니다.', false),
(14432, 5346, 'nickname = lee, point = 100', 'm이 여전히 관리되고 변경 감지 UPDATE가 조회 시점 값 point = 100까지 덮어쓴다고 본 경우. clearAutomatically가 없었다면 실제로 생길 수 있는 결과지만, 여기서는 m이 준영속이라 UPDATE 자체가 나가지 않는다.', false),
(14433, 5346, 'nickname = kim, point = 100', 'clearAutomatically가 벌크 연산 결과까지 되돌린다고 본 오개념. clear는 영속성 컨텍스트만 비울 뿐 이미 DB에 실행된 UPDATE는 취소하지 않으므로, 커밋과 함께 point = 150이 확정된다.', false),
(14434, 5346, 'nickname = kim, point = 150', '벌크 연산은 DB에 바로 실행돼 point가 150이 되고, 직후 clearAutomatically로 영속성 컨텍스트가 비워져 m은 준영속이 된다. 준영속 객체의 변경은 감지되지 않아 닉네임 UPDATE가 나가지 않는다. 바꾸려면 다시 조회한 엔티티를 고쳐야 한다.', true),

-- 문제 5347
(14435, 5347, 'SELECT 없이 DELETE 1회가 바로 나가고, 삭제된 행이 0건이라 CouponNotFoundException이 던져진다.', 'deleteById가 JPQL delete를 바로 실행하고 삭제 건수를 검사한다고 본 오개념. 실제로는 findById로 먼저 조회한 뒤 찾은 엔티티를 remove()하는 구조라 SELECT가 먼저 나가고, 삭제 건수는 확인하지 않는다.', false),
(14436, 5347, 'SELECT 1회 뒤 EmptyResultDataAccessException이 발생해 CouponNotFoundException이 던져진다.', 'Spring Data JPA 2.x의 동작이다. 2.x는 조회 결과가 없으면 이 예외를 던졌지만 3.0부터는 없는 id를 조용히 무시한다. 업그레이드 뒤 이 catch 블록은 실행될 일이 없어진다.', false),
(14437, 5347, 'SELECT 1회만 나가고 예외 없이 끝나, CouponNotFoundException이 던져지지 않는다.', '3.x의 deleteById는 findById로 조회해 엔티티가 있을 때만 delete()를 호출한다. id = 999가 없으니 SELECT 뒤 그대로 끝나고 catch 블록도 실행되지 않는다. 없는 id를 알리려면 existsById 등으로 먼저 직접 확인해야 한다.', true),
(14438, 5347, 'SELECT 1회와 DELETE 1회가 나가고 예외 없이 끝나, CouponNotFoundException이 던져지지 않는다.', '조회 결과와 관계없이 DELETE가 항상 나간다고 본 오개념. deleteById는 찾은 엔티티를 remove()하는 방식이라, 조회 결과가 없으면 지울 대상이 없어 DELETE 문이 만들어지지 않는다.', false),

-- 문제 5348
(14439, 5348, '삭제가 배송지 id = 7까지 전파돼, 주문 B·C가 아직 참조 중이라 외래 키 제약 위반으로 커밋이 실패한다.', 'ALL에 포함된 REMOVE가 주문 A의 삭제를 배송지로 전파해 DELETE address가 나가는데, 주문 B·C가 그 행을 참조하고 있어 제약 위반이 난다. 여러 부모가 공유하는 엔티티에는 Cascade를 걸지 않아야 한다.', true),
(14440, 5348, 'Cascade는 @OneToMany 컬렉션에만 적용되므로 주문 A만 지워지고 배송지는 그대로 남는다.', 'Cascade를 부모→자식 컬렉션 전용으로 본 오개념. Hibernate는 @ManyToOne에 건 cascade도 그대로 따르므로, 옵션을 건 방향인 주문→배송지로 삭제가 전파된다.', false),
(14441, 5348, '배송지 삭제가 그 배송지를 참조하는 주문 B·C로 다시 전파돼 주문 세 건이 함께 지워진다.', '전파가 역방향으로도 이어진다고 본 오개념. Cascade는 옵션을 건 필드를 따라서만 흐르며, Address에는 주문을 가리키는 필드가 없으니 주문 B·C는 삭제 대상이 되지 않는다.', false),
(14442, 5348, '다른 주문이 배송지를 참조 중이면 JPA가 전파를 건너뛰어, 주문 A만 지워지고 배송지는 남는다.', 'JPA가 공유 여부를 따져 준다고 본 오개념. Cascade는 다른 엔티티의 참조가 남았는지 확인하지 않고 그대로 전파한다. 공유되는 엔티티인지는 매핑을 설계하는 개발자가 판단해야 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1738, 5349, 'TABLE,GenerationType.TABLE,strategy = GenerationType.TABLE,strategy=GenerationType.TABLE,TABLE 전략,테이블 전략,테이블,table strategy', 'TABLE 전략은 키 값을 담아 두는 전용 테이블의 행을 select ... for update로 잠가 읽고 update로 값을 올려, DB 시퀀스 없이도 시퀀스처럼 식별자를 나눠 준다. 시퀀스 객체가 없는 DB를 포함해 어디서나 동작하지만, 채번할 때마다 같은 행을 잠그므로 동시 요청이 몰리면 잠금 대기가 생긴다. 테이블 이름에 sequences가 들어 있어도 SEQUENCE 전략과는 다르다. SEQUENCE는 DB 시퀀스 객체에 nextval 같은 호출을 보내 행 잠금 없이 값을 받는다. IDENTITY였다면 INSERT 문에 id 컬럼이 빠지고 DB의 AUTO_INCREMENT가 값을 채웠을 것이고, UUID라면 애플리케이션이 값을 만들어 채번용 SQL 자체가 나가지 않는다.'),
       (1739, 5350, 'order_inserts,hibernate.order_inserts,order_inserts=true,hibernate.order_inserts=true,order_inserts: true,spring.jpa.properties.hibernate.order_inserts,spring.jpa.properties.hibernate.order_inserts=true,order inserts', 'JDBC 배치는 같은 SQL 문이 연달아 올 때만 한 묶음으로 쌓인다. post와 attachment INSERT가 번갈아 나오면 문장이 바뀔 때마다 배치가 끊겨 한 건짜리 배치가 1,000번 실행된다. order_inserts를 켜면 Hibernate가 flush 때 INSERT를 엔티티 종류별로 정렬(외래 키 순서는 지킨 채)해, post 500건은 50건씩 10회, attachment 500건도 10회로 묶여 20회가 된다. jdbc.batch_size는 한 묶음의 최대 크기만 정할 뿐 순서를 바꾸지 않고, rewriteBatchedStatements는 MySQL 드라이버가 이미 묶인 배치를 다중 VALUES 한 문장으로 재작성하는 옵션이라 끊긴 배치를 이어 주지 못한다. UPDATE 쪽에서 같은 역할을 하는 설정은 order_updates다.');
