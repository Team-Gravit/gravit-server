-- Unit: QuerySet 지연 평가 (Unit ID: 133)
-- Chapter: Django (Chapter ID: 12)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (559, 133, '쿼리 횟수와 결과 캐시, exists'),
       (717, 133, '평가 트리거 판별과 prefetch 캐시'),
       (875, 133, 'Django QuerySet 슬라이싱·비동기 평가와 결과 캐시의 함정');

-- =====================================================
-- Lesson 559: 쿼리 횟수와 결과 캐시, exists
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3533, 559, '아래 코드를 위에서 아래로 실행할 때 데이터베이스로 나가는 SELECT는 모두 몇 번인가?', '```python
qs = Article.objects.filter(status="PUBLISHED")
qs = qs.order_by("-created_at")

top = qs[:5]
print(list(top))

for a in qs:
    print(a.title)

print(len(qs))
```

- Article 행은 이미 저장돼 있고, 실행 중 다른 곳에서 데이터베이스를 건드리지 않는다.
- 실행 순서는 위에서 아래로 한 번뿐이다.', 'OBJECTIVE'),
       (3534, 559, '아래 ORM 캐시 동작에 대한 설명으로 옳은 것은?', 'Django의 QuerySet은 한 번 평가되면 가져온 행 전체를 그 객체 내부의 결과 캐시에 리스트로 담아 둔다. 같은 객체를 다시 순회하면 담아 둔 결과 캐시를 그대로 쓰며, 결과 캐시는 QuerySet 객체 단위로 따로 관리된다.', 'OBJECTIVE'),
       (3535, 559, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 항목 | 일반 평가 (`for row in qs`) | `iterator(chunk_size=N)` |
| --- | --- | --- |
| 결과 캐시 | 가져온 행을 `_result_cache`에 전부 보관 | 보관하지 않음 |
| 메모리 | 전체 행 크기에 비례 | 청크 크기에 비례 |
| 재순회 | 캐시로 여러 번 가능 | 쿼리를 다시 실행 |
| `prefetch_related` | 정상 동작 | Django 5.0부터 `chunk_size` 지정 필수 |', 'OBJECTIVE'),
       (3536, 559, '아래 쿼리 로그에서 SELECT가 21회로 늘어난 원인으로 옳은 것은?', '뷰:

```python
posts = Post.objects.order_by("-id")[:20]
return render(request, "post_list.html", {"posts": posts})
```

템플릿:

```
{% for post in posts %}
  {{ post.title }} ({{ post.comments.all|length }})
{% endfor %}
```

쿼리 로그(게시글 20건):

```
SELECT ... FROM post ORDER BY id DESC LIMIT 20      -- 1회
SELECT ... FROM comment WHERE post_id = 41          -- 1회
SELECT ... FROM comment WHERE post_id = 42          -- 1회
... (게시글마다 1회씩)
SELECT ... FROM comment WHERE post_id = 60          -- 1회
총 21회
```', 'OBJECTIVE'),
       (3537, 559, '아래 로그가 드러낸 Django QuerySet의 동작 방식을 가리키는 용어는?', '서비스 함수 get_active_products()가 Product.objects.filter(is_active=True)를 그대로 반환한다. 함수가 값을 돌려준 직후 재고 배치가 상품 12건을 비활성으로 바꿨고, 이어서 템플릿이 목록을 그리자 그 12건이 화면에서 빠져 있었다. APM 구간 로그를 보면 SELECT는 서비스 함수 구간이 아니라 템플릿 렌더링 구간에 찍혀 있었다.', 'SUBJECTIVE'),
       (3538, 559, '아래에서 `if reviews:` 자리에 대신 호출한 QuerySet 메서드의 이름은?', '상품 상세 API는 리뷰가 하나라도 달렸는지만 화면에 표시하고, 리뷰 목록 자체는 이어서 쓰지 않는다. 그런데 `if reviews:`로 검사하는 바람에 리뷰 12만 건이 전부 파이썬 객체로 올라와 응답이 3.4초 걸렸다.

조건문의 검사 방식만 다른 메서드 호출로 바꾸자 쿼리 로그에 아래 한 줄만 찍히고 응답이 9ms로 줄었다.

```sql
SELECT 1 AS "a" FROM review WHERE product_id = 7 LIMIT 1
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3533
(9595, 3533, '1회', 'top과 qs가 같은 조회 결과를 나눠 쓴다고 본 것. 평가 전 슬라이싱은 LIMIT을 붙인 별개의 QuerySet을 만들 뿐이라, top과 qs는 각자 한 번씩 조회한다.', false),
(9596, 3533, '2회', 'list(top)에서 LIMIT 5 조회가 1회, for 순회에서 qs 전체 조회가 1회. 두 번째 조회가 qs의 결과 캐시를 채우므로 뒤따르는 len(qs)는 DB에 가지 않는다.', true),
(9597, 3533, '3회', 'len(qs)가 결과 캐시를 두고도 COUNT 쿼리를 따로 낸다고 본 것. 캐시가 이미 차 있으면 파이썬이 보관된 리스트의 길이만 센다.', false),
(9598, 3533, '4회', 'filter()와 order_by()를 호출할 때마다 쿼리가 나간다고 본 것. 두 메서드는 조건을 덧붙인 새 QuerySet만 만들고 DB에 접근하지 않는다.', false),

-- 문제 3534
(9599, 3534, '같은 객체를 세 번 연달아 순회하면 순회할 때마다 SELECT가 한 번씩, 모두 세 번 나간다.', '첫 순회가 채운 결과 캐시를 두 번째부터 재사용하므로 SELECT는 한 번뿐이다. 평가 결과가 객체 안에 남는다는 점을 놓친 오개념.', false),
(9600, 3534, '이미 평가된 객체에 filter()를 덧붙여 만든 객체는 앞의 결과를 물려받아 SELECT 없이 순회된다.', 'filter()는 새 QuerySet을 만들고 캐시는 객체 단위로 관리되므로 물려받지 못한다. 조건만 좁혔으니 앞의 결과를 걸러 쓰면 된다고 본 오개념.', false),
(9601, 3534, '캐시가 비어 있을 때 count()를 부르면 COUNT 쿼리가 따로 나가고, 이어 같은 객체를 순회하면 SELECT가 또 나간다.', 'count()는 집계 쿼리만 실행하고 행을 가져오지 않아 캐시를 채우지 못한다. 개수와 목록이 다 필요하면 먼저 순회로 캐시를 채운 뒤 len()을 쓰는 편이 쿼리를 아낀다.', true),
(9602, 3534, '순회를 마친 객체라도 len()을 부르면 행 수를 세려고 DB에 한 번 더 다녀온다.', '캐시가 차 있으면 len()은 보관된 리스트의 길이만 세고 DB에 가지 않는다. 길이 계산을 항상 DB의 일로 본 오개념.', false),

-- 문제 3535
(9603, 3535, 'iterator()로 한 번 훑은 QuerySet을 곧바로 다시 순회하면 남아 있는 캐시 덕분에 추가 쿼리 없이 끝난다.', '표에서 iterator()는 결과를 보관하지 않아 재순회 때 쿼리를 다시 실행한다. 캐시가 남아 여러 번 순회할 수 있는 쪽은 일반 평가다.', true),
(9604, 3535, '420만 행을 내보내다 메모리 초과로 죽는 배치라면 iterator(chunk_size=N)로 바꿔 볼 만하다.', '메모리가 전체 행 크기가 아니라 청크 크기에 비례하므로, 행 수가 늘어도 상주 메모리를 일정하게 눌러 둘 수 있다.', false),
(9605, 3535, '같은 결과를 목록 출력과 합계 계산에 두 번 써야 한다면 일반 평가 쪽이 쿼리를 아낀다.', '일반 평가는 캐시가 남아 두 번째 사용에서 DB에 가지 않는다. iterator()라면 두 번째 사용에서 쿼리를 다시 내야 한다.', false),
(9606, 3535, 'prefetch_related를 붙인 QuerySet을 Django 5.0에서 iterator()로 인자 없이 순회하면 실패한다.', 'Django 5.0부터 prefetch_related와 함께 쓸 때 chunk_size 지정이 필수라 생략하면 오류가 난다. 미리 가져온 관련 객체를 청크 단위로 채워야 하기 때문이다.', false),

-- 문제 3536
(9607, 3536, '게시글 QuerySet의 결과 캐시가 20건을 다 담지 못해 게시글마다 목록 조회가 다시 나갔다.', '로그에서 post 조회는 맨 앞 1회뿐이다. 결과 캐시는 평가된 행을 전부 담으므로 건수 때문에 재조회가 일어나지 않는다.', false),
(9608, 3536, 'comment 테이블에 post_id 인덱스가 없어 옵티마이저가 게시글 단위로 쿼리를 쪼갰다.', '인덱스 유무는 쿼리 한 건의 속도를 바꿀 뿐 실행 횟수를 바꾸지 않는다. 횟수는 애플리케이션이 몇 번 요청했는지로 정해진다.', false),
(9609, 3536, '뷰에서 posts를 list()로 미리 평가해 두면 댓글 SELECT 20회도 함께 사라진다.', 'list()는 게시글 조회 시점을 앞당길 뿐 템플릿의 댓글 매니저 호출은 그대로 남는다. 없애려면 prefetch_related로 댓글을 미리 가져와야 한다.', false),
(9610, 3536, '템플릿이 게시글마다 post.comments.all을 호출해 매번 새 QuerySet이 만들어졌고, 캐시가 없어 조회가 반복됐다.', '역참조 매니저의 all()은 호출할 때마다 새 QuerySet이라 앞 반복의 결과를 재사용하지 못한다. 첫 접근 뒤 인스턴스에 캐시되는 정참조 post.author와 갈리는 지점이다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1134, 3537, '지연 평가,지연평가,lazy evaluation,lazyevaluation,레이지 이밸류에이션,지연 실행,지연실행,늦은 평가', 'QuerySet은 만들어질 때가 아니라 결과가 실제로 필요한 순간에 SQL을 실행한다. 그래서 서비스 함수가 QuerySet을 그대로 반환하면 실행 시점이 템플릿 렌더링까지 밀리고, 그 사이에 바뀐 데이터를 읽어 함수 호출 시점과 결과가 어긋난다. 시점을 고정하려면 경계에서 list()로 평가해 넘긴다. 한 번 평가한 결과를 객체 안에 담아 두는 결과 캐시는 "두 번째부터 다시 실행되는가"를 다루는 별개 주제이고, 반복문 안에서 관련 객체를 건드려 쿼리가 행 수만큼 늘어나는 N+1 문제와도 구분한다.'),
       (1135, 3538, 'exists,exists(),.exists(),reviews.exists(),reviews.exists', 'exists()는 컬럼을 하나도 가져오지 않고 LIMIT 1로 행의 존재 여부만 확인해, 12만 건을 파이썬 객체로 만드는 비용을 통째로 없앤다. 다만 결과 캐시를 만들지 않으므로, 존재 확인 뒤 같은 목록을 순회하면 SELECT가 또 나간다. 목록을 이어서 쓸 거라면 오히려 if qs:가 전체를 한 번 조회해 캐시를 채우니 유리하다. first()도 LIMIT 1을 붙이지만 행의 컬럼을 모두 읽어 오므로 위 로그와 맞지 않는다.');

-- =====================================================
-- Lesson 717: 평가 트리거 판별과 prefetch 캐시
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4481, 717, '아래 코드를 위에서부터 실행할 때 DB로 SELECT가 처음 나가는 줄은?', '```python
qs = Coupon.objects.filter(expired=False)          # ①
codes = qs.values_list("code", flat=True)          # ②
if codes is not None:                              # ③
    cache.set("active_coupon_codes", codes, 300)   # ④
for code in codes:                                 # ⑤
    notify(code)
```

- `cache`는 Redis 백엔드를 쓰는 Django 캐시 객체다.
- 만료되지 않은 쿠폰이 여러 건 저장돼 있고, 실행 중 다른 곳에서 DB를 건드리지 않는다.', 'OBJECTIVE'),
       (4482, 717, '아래 코드를 고쳤을 때 쿼리 로그의 SELECT 횟수를 옳게 예측한 것은?', '```python
ranking = Player.objects.order_by("-score")

podium = [ranking[0], ranking[1], ranking[2]]
for p in podium:
    print("시상대", p.name)

for p in ranking:
    print(p.name, p.score)
```

실행 중 찍힌 쿼리 로그(선수는 3명 이상 저장돼 있다):

```
SELECT ... FROM player ORDER BY score DESC LIMIT 1
SELECT ... FROM player ORDER BY score DESC LIMIT 1 OFFSET 1
SELECT ... FROM player ORDER BY score DESC LIMIT 1 OFFSET 2
SELECT ... FROM player ORDER BY score DESC
총 4회
```', 'OBJECTIVE'),
       (4483, 717, '아래 코드를 끝까지 실행했을 때 DB로 나가는 SELECT의 총 횟수는?', '```python
orders = list(
    Order.objects.order_by("-id").prefetch_related("items")[:10]
)

for order in orders:
    item_count = len(order.items.all())
    refunded = order.items.filter(is_refunded=True)
    print(order.id, item_count, len(refunded))
```

- `items`는 주문 항목(`OrderItem`)이 `Order`를 ForeignKey로 참조할 때의 역참조 이름이다.
- 주문은 10건 이상 저장돼 있고, 가져온 주문 10건에는 모두 주문 항목이 있다.
- 실행 중 다른 곳에서 DB를 건드리지 않는다.', 'OBJECTIVE'),
       (4484, 717, '아래 반환 방식에 대한 설명으로 옳은 것은?', '주문 화면용 서비스 함수는 QuerySet을 그대로 넘기지 않고, 함수 안에서 `list(Product.objects.filter(is_active=True))`로 평가를 마친 뒤 돌려준다. 이렇게 하면 상품 SELECT는 함수 안에서 한 번 실행된다. `Product`는 ForeignKey 필드 `category`로 `Category`를 참조하고, 모든 상품에 카테고리가 지정돼 있다.', 'OBJECTIVE'),
       (4485, 717, '아래 셸 기록의 빈칸에 들어갈 이름은?', '새로 짠 주문 조회 조건이 어떤 SQL이 되는지 보려고 Django 셸에서 같은 QuerySet을 두 가지 방식으로 출력했다.

```python
>>> qs = Order.objects.filter(status="PAID", total__gte=50000).order_by("-id")
>>> print(qs)
<QuerySet [<Order: #9121>, <Order: #9120>, ..., ''...(remaining elements truncated)...'']>
>>> print(qs.____)
SELECT "shop_order"."id", "shop_order"."status", "shop_order"."total" FROM "shop_order" WHERE ("shop_order"."status" = PAID AND "shop_order"."total" >= 50000) ORDER BY "shop_order"."id" DESC
```

- `print(qs)` 줄에서는 `LIMIT 21`이 붙은 SELECT가 DB에서 실행됐다.
- 빈칸 줄의 출력을 그대로 복사해 psql에서 실행하자 `PAID` 앞뒤에 따옴표가 없어 오류가 났다.', 'SUBJECTIVE'),
       (4486, 717, '아래 배치에서 순회 대상 QuerySet 끝에 덧붙인 메서드의 이름은?', '매일 새벽 PostgreSQL의 `access_log` 테이블에서 380만 행을 모두 CSV로 내보내는 배치가 있다. 처음 코드는 `for row in AccessLog.objects.all():`였다.

순회 대상 QuerySet 끝에 메서드 호출 하나를 덧붙이고 인자로 2000을 넘기자 결과가 아래처럼 바뀌었다. 내보낸 행 수는 두 경우 모두 380만 행으로 같다.

| 항목 | 바꾸기 전 | 바꾼 뒤 |
| --- | --- | --- |
| 첫 행이 CSV에 기록되기까지 | 약 3분 | 약 1초 |
| 프로세스 최대 메모리 | 9.6GB | 약 230MB |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4481
(12123, 4481, '②번 줄', 'values_list()는 가져올 컬럼만 바꾼 새 QuerySet을 돌려줄 뿐 DB에 가지 않는다. 값만 뽑는 메서드라 그 자리에서 리스트를 만든다고 본 오개념이다.', false),
(12124, 4481, '③번 줄', 'is not None은 객체가 None인지 신원만 비교할 뿐 QuerySet의 참·거짓 판정(bool)을 부르지 않는다. 전체 조회를 일으키는 if codes:와 혼동한 것이다.', false),
(12125, 4481, '④번 줄', 'Redis 캐시에 넣으려면 값을 pickle로 직렬화해야 하고, QuerySet은 직렬화될 때 결과를 먼저 모두 가져온다. 조회 조건만 저장될 것 같지만 이 줄에서 SELECT가 실행된다.', true),
(12126, 4481, '⑤번 줄', 'for 순회도 평가를 일으키지만 그보다 앞선 ④에서 이미 SELECT가 나갔다. 평가가 순회에서만 일어난다고 좁게 본 오개념으로, 직렬화·len()·bool()도 평가를 일으킨다.', false),

-- 문제 4482
(12127, 4482, 'podium을 만들기 전에 ranking.exists()를 불러 두면, 인덱스 접근과 순회가 확인 때 가져온 결과를 써서 모두 1회가 된다.', 'exists()는 SELECT 1 ... LIMIT 1로 존재만 확인하고 결과 캐시를 채우지 않는다. 확인 쿼리 1회가 오히려 더해져 5회가 된다. 존재 확인이 행을 받아 둔다고 본 오개념이다.', false),
(12128, 4482, 'podium을 list(ranking[:3])로 바꾸면, 세 행을 LIMIT 3 SELECT 한 번으로 가져와 모두 2회가 된다.', '슬라이싱은 LIMIT 3이 붙은 새 QuerySet을 만들고 list()가 이를 평가해 세 행을 한 번에 가져온다. 인덱스 접근 3회가 1회로 줄고, 아래 for가 ranking을 평가하는 1회가 남아 2회다.', true),
(12129, 4482, 'top3 = ranking[:3]을 만든 뒤 podium을 [top3[0], top3[1], top3[2]]로 바꾸면, 세 행을 LIMIT 3 한 번으로 가져와 모두 2회가 된다.', 'top3는 LIMIT 3만 붙은 평가 전 QuerySet이라 top3[0]~[2]가 저마다 LIMIT 1 SELECT를 따로 낸다. 여전히 4회다. 슬라이싱이 곧바로 행을 가져온다고 본 오개념이다.', false),
(12130, 4482, 'ranking을 Player.objects.order_by("-score").all()로 만들면, 행이 미리 준비돼 인덱스 접근과 순회가 그 결과를 써서 모두 1회가 된다.', 'all()도 조건이 같은 새 QuerySet을 돌려줄 뿐 DB에 가지 않는다. 인덱스 접근은 여전히 매번 LIMIT 1 SELECT를 내고 캐시를 채우지 않아 4회 그대로다. all()이 전체를 가져온다고 본 오개념이다.', false),

-- 문제 4483
(12131, 4483, '1회', 'prefetch_related가 주문과 항목을 JOIN 한 문장으로 가져오고 filter()도 그 안에서 걸러 쓴다고 본 것. 항목은 IN 조건의 별도 SELECT로 가져오고, filter()는 주문마다 새 SQL을 낸다.', false),
(12132, 4483, '2회', '주문 조회와 항목 일괄 조회만 센 것. all()은 prefetch 캐시를 그대로 쓰지만, filter()를 붙이면 새 QuerySet이 만들어져 prefetch 캐시를 버리고 주문마다 SQL을 다시 실행한다.', false),
(12133, 4483, '11회', 'prefetch_related를 select_related처럼 JOIN으로 본 것. 역참조 항목은 주문 조회 뒤 IN 조건의 SELECT 1회로 따로 가져오므로, 주문 1회와 filter() 10회에 1회가 더 붙는다.', false),
(12134, 4483, '12회', 'list()에서 주문 LIMIT 10 조회 1회와 항목 IN 조회 1회가 나간다. all()은 prefetch 캐시를 써 쿼리가 없고, filter()는 캐시를 버린 새 QuerySet이라 len()에서 주문마다 1회씩 10회. 합계 12회다.', true),

-- 문제 4484
(12135, 4484, '호출한 쪽이 반복문에서 product.category.name을 읽으면, 상품 수만큼 카테고리 SELECT가 더 나간다.', 'list()는 상품 행만 가져와 평가를 끝낼 뿐 ForeignKey 너머의 카테고리는 가져오지 않는다. 정참조는 인스턴스마다 처음 접근할 때 따로 조회하므로 N+1이 생긴다. 함께 가져오려면 select_related가 필요하다.', true),
(12136, 4484, '함수가 값을 돌려준 뒤 다른 요청이 상품을 비활성으로 바꾸면, 호출한 쪽 반복문에는 바뀐 상태가 반영된다.', '상품 인스턴스는 함수 안 SELECT 시점의 값을 담아 이미 메모리에 있어 이후 DB 변경이 반영되지 않는다. QuerySet을 그대로 넘겨 평가가 뒤로 밀릴 때 생기는 시점 불일치와 혼동한 것이다.', false),
(12137, 4484, '같은 상품의 product.category.name을 두 번째로 읽을 때도 카테고리 SELECT가 다시 나간다.', '정참조는 처음 접근해 가져온 Category 객체를 그 인스턴스에 담아 두므로, 같은 인스턴스에서 다시 읽으면 SELECT가 없다. 호출마다 새 QuerySet을 만드는 역참조 매니저의 all()과 혼동한 오개념이다.', false),
(12138, 4484, '상품이 50만 건이어도 호출한 쪽이 앞 10개만 쓰면, 메모리에는 상품 10개만 올라온다.', 'list()는 조건에 맞는 행을 전부 가져와 모델 인스턴스로 만든다. 앞 10개만 필요하면 함수 안에서 [:10] 슬라이싱으로 LIMIT을 붙여야 한다. 호출한 쪽이 쓰는 만큼만 DB에서 꺼내 온다고 본 오개념이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1450, 4485, 'query,.query,qs.query,query 속성,query속성', 'qs.query는 QuerySet이 품고 있는 쿼리 설명서(Query 객체)다. print()나 str()로 찍으면 QuerySet을 평가하지 않고, 조건을 조립해 만들어질 SQL 문장만 보여 주므로 확인하는 동안 SELECT가 나가지 않는다. 다만 파라미터를 DB 드라이버가 아니라 파이썬 문자열 치환으로 끼워 넣어 PAID 같은 문자열 값에 따옴표가 붙지 않는다. 그래서 디버깅용으로 읽기만 하고 그대로 실행하지 않는다. 같은 셸의 print(qs)는 repr()을 거쳐 앞 21개를 실제로 조회하는 평가 동작이라 구분해야 하고, DB에서 EXPLAIN을 실행해 실행 계획을 돌려주는 explain() 메서드와도 다르다. 실제로 실행된 SQL을 확인하려면 DEBUG 모드의 connection.queries나 django-debug-toolbar를 쓴다.'),
       (1451, 4486, 'iterator,iterator(),.iterator(),iterator(2000),.iterator(2000),iterator(chunk_size=2000),.iterator(chunk_size=2000),이터레이터', 'iterator()는 평가한 결과를 _result_cache에 쌓지 않고, PostgreSQL에서는 서버 사이드 커서로 chunk_size(여기서는 2000)만큼씩 받아 모델 인스턴스로 바꿔 흘려보낸다. 그래서 메모리가 전체 행 수가 아니라 청크 크기에 비례하고, 380만 행을 다 받기 전에 첫 행을 쓸 수 있다. 일반 for 순회는 380만 행을 모두 받아 결과 캐시에 인스턴스로 쌓은 뒤에야 첫 행을 내준다. 대가로 캐시가 없어 같은 결과를 다시 순회하려면 쿼리를 새로 실행해야 한다. MySQL·SQLite는 드라이버가 결과를 먼저 받아 두므로 드라이버 수준의 메모리 절감은 PostgreSQL만 못하다. 필요한 필드만 가져와 인스턴스 생성 비용을 줄이는 values_list()나 LIMIT으로 행 수 자체를 줄이는 슬라이싱과는 구분한다. values_list()는 결과를 여전히 캐시에 모두 담고, 슬라이싱으로는 380만 행을 다 내보낼 수 없다.');

-- =====================================================
-- Lesson 875: Django QuerySet 슬라이싱·비동기 평가와 결과 캐시의 함정
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5429, 875, '아래 코드를 위에서부터 실행할 때 DB로 SELECT를 보내는 줄만 모두 고른 것은?', '```python
qs = Notice.objects.filter(pinned=True).order_by("-id")   # ①
page = qs[5:10]                                           # ②
odd = qs[1::2]                                            # ③
head = qs[0]                                              # ④
for n in page:                                            # ⑤
    print(n.title)
head_again = qs[0]                                        # ⑥
```

- 고정 공지(`pinned=True`)는 20건 저장돼 있다.
- 실행 순서는 위에서 아래로 한 번뿐이고, 실행 중 다른 곳에서 DB를 건드리지 않는다.', 'OBJECTIVE'),
       (5430, 875, '아래 비동기 뷰를 요청했을 때 SynchronousOnlyOperation 예외가 처음 발생하는 줄은?', '```python
async def dashboard(request):
    qs = Order.objects.filter(status="PAID").order_by("-id")  # ①
    total = await qs.acount()                                 # ②
    recent = qs[:10]                                          # ③
    if recent:                                                # ④
        title = "최근 결제 주문"
    else:
        title = "결제 주문 없음"
    return render(request, "dashboard.html",                  # ⑤
                  {"recent": recent, "total": total, "title": title})
```

- Django 4.2 프로젝트를 ASGI 서버로 실행하며, `DJANGO_ALLOW_ASYNC_UNSAFE` 같은 우회 설정은 쓰지 않는다.
- `dashboard.html`은 `{% for o in recent %}`로 주문 목록을 그린다.
- 결제 완료(`PAID`) 주문이 여러 건 저장돼 있다.', 'OBJECTIVE'),
       (5431, 875, '아래 요구 사항을 DB 쿼리 1회로 처리하는 코드 흐름은?', '게시판 목록 화면의 요구 사항은 다음과 같다. 글이 없으면 "글이 없습니다"를 띄우고, 글이 있으면 글 개수와 글 목록을 함께 보여 준다. 한 화면의 글은 최대 30건이라 전부 가져와도 부담이 없고, `qs`는 아직 한 번도 평가하지 않은 QuerySet이다.

| 호출 | `qs`가 평가 전일 때 나가는 SQL | 같은 `qs`가 행 전체를 이미 받아 둔 뒤 |
| --- | --- | --- |
| `for p in qs` | 조건에 맞는 행 전체를 가져오는 SELECT | SQL 없음 |
| `len(qs)` | 조건에 맞는 행 전체를 가져오는 SELECT | SQL 없음 |
| `if qs:` | 조건에 맞는 행 전체를 가져오는 SELECT | SQL 없음 |
| `qs.count()` | `SELECT COUNT(*) ...` | SQL 없음 |
| `qs.exists()` | `SELECT 1 ... LIMIT 1` | SQL 없음 |', 'OBJECTIVE'),
       (5432, 875, '아래 쿼리 로그에 검색 조건이 빠진 원인으로 옳은 것은?', '검색 API 코드:

```python
def search_titles(request):
    qs = Post.objects.filter(is_published=True)
    keyword = request.GET.get("q")
    if keyword:
        qs.filter(title__icontains=keyword)
    qs = qs.order_by("-created_at")
    return JsonResponse({"titles": [p.title for p in qs]})
```

공개 글 120건 가운데 제목에 django가 들어간 글은 8건이다. 그런데 `/search?q=django`로 요청하면 120건이 모두 돌아온다. 이 요청의 쿼리 로그는 다음과 같다.

```
SELECT ... FROM post WHERE is_published = true ORDER BY created_at DESC
총 1회
```', 'OBJECTIVE'),
       (5433, 875, '아래 코드의 빈칸에 들어갈 메서드 이름은?', '마케팅 수신에 동의한 회원 180만 명의 id와 email을 매일 밤 CSV로 내보내는 배치를 아래처럼 고쳤다.

```python
# 고치기 전
for m in Member.objects.filter(marketing_agreed=True):
    writer.writerow([m.id, m.email])

# 고친 뒤
for row in Member.objects.filter(marketing_agreed=True).________("id", "email"):
    writer.writerow(row)
```

- `Member` 모델에는 필드가 23개 있다.
- 고친 뒤 반복문에서 받은 `row` 하나를 찍어 보니 `(17, ''kim@example.com'')` 같은 튜플이었다.
- 쿼리 로그의 SELECT 컬럼은 23개에서 2개로 줄었고, 배치 시간은 14분에서 3분으로, 프로세스 최대 메모리는 5.1GB에서 1.2GB로 줄었다.', 'SUBJECTIVE'),
       (5434, 875, '아래 상황에서 정산 합계에 취소된 주문이 섞이게 만든 QuerySet의 동작을 가리키는 용어는?', '관리자 정산 화면의 한 요청 안에서 아래 코드가 실행된다.

```python
orders = Order.objects.filter(status="PAID")
render_table(orders)                    # 주문 목록 표 그리기
amount = sum(o.total for o in orders)   # 정산 합계 계산
```

- `render_table()` 안에서 `orders`를 for로 순회할 때 SELECT가 1회 찍혔다.
- 표를 다 그린 직후, 다른 프로세스의 결제 취소 웹훅이 주문 #9120을 `CANCELED`로 바꿔 커밋했다.
- 정산 합계 줄에서는 쿼리 로그에 SQL이 한 줄도 찍히지 않았고, 합계에는 #9120의 금액이 그대로 들어갔다.
- 합계 줄의 순회 대상을 `orders.all()`로 바꾸자 SELECT가 1회 더 찍히고 #9120이 합계에서 빠졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5429
(14651, 5429, '④, ⑤, ⑥', '③의 qs[1::2]를 ②처럼 LIMIT만 붙는 지연 슬라이싱으로 본 오개념. step이 있는 슬라이싱은 먼저 조회를 실행해 리스트를 만든 뒤 파이썬에서 한 칸씩 건너뛰므로 그 자리에서 SELECT가 나간다.', false),
(14652, 5429, '③, ④, ⑤, ⑥', '③은 step이 있어 그 자리에서 조회한다. ④·⑥의 인덱스 접근은 매번 LIMIT 1 SELECT를 내고 결과를 캐시에 남기지 않는다. ②의 page는 평가 전 QuerySet이라 ⑤에서 순회할 때 LIMIT 5 OFFSET 5로 조회된다.', true),
(14653, 5429, '③, ④, ⑤', '④의 qs[0]이 qs의 결과 캐시를 채운다고 본 오개념. 인덱스 접근은 LIMIT 1로 한 행만 가져올 뿐 캐시를 남기지 않아, ⑥에서 같은 qs[0]을 부르면 LIMIT 1 SELECT가 다시 나간다.', false),
(14654, 5429, '②, ③, ④, ⑥', '슬라이싱이면 모두 그 자리에서 조회한다고 본 오개념. step 없는 qs[5:10]은 LIMIT 5 OFFSET 5를 붙인 새 QuerySet을 돌려줄 뿐이고, 실제 조회는 ⑤에서 page를 순회할 때 일어난다.', false),

-- 문제 5430
(14655, 5430, '①번 줄', 'filter()·order_by()는 조건을 담은 QuerySet을 만들 뿐 DB에 가지 않으므로 비동기 뷰에서도 그대로 쓸 수 있다. 동기 ORM 메서드는 호출만 해도 막힌다고 본 오개념이다.', false),
(14656, 5430, '③번 줄', 'step 없는 슬라이싱은 LIMIT 10을 붙인 새 QuerySet을 돌려줄 뿐 평가하지 않아 DB 접근이 없다. 슬라이싱하는 순간 행을 가져온다고 본 오개념이다.', false),
(14657, 5430, '④번 줄', 'if recent:는 bool()로 recent를 평가해 행을 동기 방식으로 조회한다. 이벤트 루프 위에서 동기 DB 접근이 일어나 예외가 난다. 비동기 뷰에서는 async for나 await qs.aexists()처럼 비동기 평가를 쓴다.', true),
(14658, 5430, '⑤번 줄', '템플릿의 for 순회도 동기 평가라 여기서도 막히지만, 그보다 앞선 ④에서 이미 예외가 난다. if 검사는 변수에 값이 있는지만 볼 뿐 DB에 가지 않는다고 본 오개념이다.', false),

-- 문제 5431
(14659, 5431, '`if qs.exists():`로 확인하고 `n = qs.count()`로 개수를 구한 뒤 `for p in qs:`로 그린다.', 'SELECT 1과 COUNT(*)는 행을 받아 오지 않아 결과 캐시를 채우지 못한다. 확인·개수·순회가 저마다 SQL을 내 모두 3회다. 목적별 전용 메서드가 언제나 가장 싸다고 본 오개념이다.', false),
(14660, 5431, '`n = qs.count()`로 개수를 구해 `if n:`으로 확인한 뒤 `for p in qs:`로 그린다.', 'COUNT(*)는 개수만 돌려받아 결과 캐시가 빈 채로 남고, 이어진 for가 행 전체를 다시 조회해 모두 2회다. count()가 셀 때 행 목록까지 받아 둔다고 본 오개념이다.', false),
(14661, 5431, '`if qs.exists():`로 확인하고 `n = len(qs)`로 개수를 구한 뒤 `for p in qs:`로 그린다.', 'len(qs)가 결과 캐시를 채워 for는 SQL 없이 돌지만, 앞선 exists()는 캐시를 만들지 않아 SELECT 1 ... LIMIT 1이 따로 나가 모두 2회다. 확인 쿼리가 뒤 호출과 결과를 나눠 쓴다고 본 오개념이다.', false),
(14662, 5431, '`if qs:`로 확인하고 `n = len(qs)`로 개수를 구한 뒤 `for p in qs:`로 그린다.', 'if qs:가 행 전체를 가져오며 결과 캐시를 채우므로, 이어진 len(qs)와 for는 표의 오른쪽 열처럼 SQL이 없어 모두 1회다. 목록을 이어서 쓸 때는 bool 검사가 오히려 쿼리를 아낀다.', true),

-- 문제 5432
(14663, 5432, 'filter()가 검색 조건을 붙인 새 QuerySet을 돌려줬지만, 그 반환값을 qs에 다시 담지 않아 조건이 든 객체가 버려졌다.', 'filter()는 원본을 고치지 않고 조건을 더한 새 QuerySet을 만든다. 반환값을 받지 않으면 qs는 is_published 조건만 가진 채 남는다. qs = qs.filter(...)처럼 다시 담아야 조건이 이어진다.', true),
(14664, 5432, 'filter()가 호출된 자리에서 검색 SQL을 실행했지만, 이어진 order_by()가 새 SELECT를 실행하면서 그 결과를 덮어썼다.', 'filter()는 조건만 조립할 뿐 DB에 가지 않는다. 로그의 SELECT가 1회뿐인 것이 근거로, 실제 실행은 return 줄에서 qs를 순회할 때 한 번 일어났다. 메서드 호출마다 쿼리가 나간다고 본 오개념이다.', false),
(14665, 5432, 'title에 인덱스가 없어 LIKE 검색이 느려질 것을 보고, DB 옵티마이저가 검색 조건을 빼고 is_published 조건만 실행했다.', '옵티마이저는 실행 방법을 고를 뿐 WHERE 조건을 빼지 않는다. 로그는 Django가 보낸 SQL 그대로라, 검색 조건이 없다는 것은 처음부터 SQL에 담기지 않았다는 뜻이다.', false),
(14666, 5432, 'qs가 첫 줄에서 is_published 조건으로 이미 평가돼 행을 받아 두었기 때문에, 뒤에 붙인 검색 조건은 그 결과에 반영되지 않았다.', '첫 줄의 filter()는 평가를 일으키지 않아 그 시점엔 받아 둔 행이 없다. 설령 평가됐더라도 조건을 더하면 캐시를 쓰지 않는 새 QuerySet이 만들어져 새 SQL이 나간다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1766, 5433, 'values_list,values_list(),.values_list(),valueslist,values list,밸류스 리스트', 'values_list()는 모델 인스턴스를 만들지 않고, 인자로 받은 컬럼만 SELECT해 행마다 튜플을 돌려준다. 필드 23개를 채운 Member 객체 180만 개 대신 값 두 개짜리 튜플만 만들어, SELECT 폭과 객체 생성 비용, 메모리가 함께 줄었다. 비슷한 values()는 행마다 딕셔너리를 돌려주므로 결과 모양으로 갈리고, 필드 하나만 필요하면 values_list(..., flat=True)로 튜플 대신 값 자체를 받는다. only()도 SELECT 컬럼을 줄이지만 결과는 여전히 모델 인스턴스라 튜플이 나오지 않고, 빠진 필드에 접근하면 추가 쿼리가 나간다. 또 values_list()로 만든 QuerySet도 평가 결과를 결과 캐시에 모두 담으므로, 메모리를 청크 크기 수준으로 누르려면 iterator()를 함께 쓴다.'),
       (1767, 5434, '결과 캐시,결과캐시,result cache,resultcache,_result_cache,result_cache,쿼리셋 캐시,쿼리셋캐시,QuerySet 캐시,QuerySet캐시,queryset cache,쿼리셋 결과 캐시,QuerySet 결과 캐시,결과 캐싱,쿼리셋 캐싱,QuerySet 캐싱,캐시,캐싱,cache,caching', 'QuerySet은 처음 평가될 때 가져온 행을 객체 안의 결과 캐시(_result_cache)에 리스트로 담아 두고, 같은 객체를 다시 순회하면 DB에 가지 않고 이 캐시를 돌려준다. 그래서 표를 그릴 때 채운 캐시가 합계 계산에 그대로 쓰여 SQL이 없었고, 그사이 커밋된 취소도 보이지 않았다. all()이나 filter()는 캐시가 없는 새 QuerySet을 만들므로 SELECT가 다시 나가 최신 상태를 읽는다. 지연 평가와는 방향이 반대다. 지연 평가는 만든 시점보다 늦게 실행돼 그사이 바뀐 새 데이터를 보게 되는 문제이고, 결과 캐시는 이미 받은 옛 데이터를 다시 쓰는 문제다. 합계 줄에서 SQL이 아예 나가지 않았으므로 DB 트랜잭션 격리 수준 탓도 아니며, 모델 인스턴스에 붙는 정참조 관련 객체 캐시와도 구분한다.');
