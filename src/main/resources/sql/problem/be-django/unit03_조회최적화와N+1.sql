-- Unit: 조회 최적화와 N+1 (Unit ID: 134)
-- Chapter: Django (Chapter ID: 12)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (560, 134, 'N+1 진단과 조인·prefetch 선택'),
       (718, 134, '쿼리 수 계산과 annotate·defer'),
       (876, 134, 'N+1 회귀 막기와 조회 방식 고르기 — prefetch 체이닝·OneToOne 역참조·Subquery 집계·JOIN 전송량·values');

-- =====================================================
-- Lesson 560: N+1 진단과 조인·prefetch 선택
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3539, 560, '아래 QuerySet 메서드에 대한 설명으로 옳은 것은?', '이 메서드는 인자로 받은 관계를 SQL JOIN으로 묶어, 관련 객체의 컬럼까지 한 번의 쿼리 결과 행에 함께 담아 온다. 관계 필드가 null을 허용하면 LEFT OUTER JOIN이, 그렇지 않으면 INNER JOIN이 만들어진다.', 'OBJECTIVE'),
       (3540, 560, '아래 코드를 실행할 때 나가는 데이터베이스 쿼리의 총 횟수는?', 'post 테이블에는 행이 30개 있고, 각 게시글에는 댓글이 여러 개 달려 있다.

```python
posts = Post.objects.prefetch_related("comments")
for post in posts:
    print(post.comments.filter(is_deleted=False).count())
```', 'OBJECTIVE'),
       (3541, 560, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 항목 | select_related | prefetch_related |
| --- | --- | --- |
| 동작 방식 | SQL JOIN, 쿼리 1회 | 관계마다 별도 쿼리 후 파이썬에서 결합 |
| 적용 관계 | FK·OneToOne 정참조, OneToOne 역참조 | 모든 관계(다대다·역참조 FK 포함) |
| 결과 크기 | 행마다 관련 컬럼이 반복돼 행이 넓어짐 | 관계별로 따로 가져와 중복이 적음 |
| 추가 조건 | 불가(JOIN 조건 고정) | Prefetch(queryset=...)로 지정 가능 |', 'OBJECTIVE'),
       (3542, 560, '아래 코드를 실행할 때 나타나는 현상으로 옳은 것은?', 'post 테이블에는 행이 20개 있고, body는 평균 40KB인 TextField다.

```python
posts = Post.objects.only("id", "title")
for post in posts:
    print(post.title)
    print(post.body[:30])
```', 'OBJECTIVE'),
       (3543, 560, '아래 상황에서 집계값을 바로잡으려면 Count에 어떤 인자를 추가해야 하는가?', '게시글 1건에 댓글 4개, 태그 3개가 달려 있다. 목록 QuerySet에 두 관계를 한 번에 집계했더니 화면에는 comment_count가 12, tag_count도 12로 찍혔다.

```python
posts = Post.objects.annotate(
    comment_count=Count("comments"),
    tag_count=Count("tags"),
)
```', 'SUBJECTIVE'),
       (3544, 560, '아래 쿼리 로그에서 드러난 성능 문제를 가리키는 용어는?', '게시글 50건을 내려주는 목록 API의 쿼리 로그다. 뷰 코드에는 반복문이 하나뿐이고, 게시글이 10건이던 시절에는 이 로그가 11줄이었다.

```
[0.8ms] SELECT * FROM post
[0.6ms] SELECT * FROM user WHERE id = 7
[0.5ms] SELECT * FROM user WHERE id = 3
[0.6ms] SELECT * FROM user WHERE id = 7
...
총 51개 쿼리 / 1.42초
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3539
(9611, 3539, '관련 객체의 컬럼까지 함께 가져오므로, 관련 객체가 없는 행은 결과에서 빠진다', 'JOIN이면 무조건 행이 걸러진다고 본 오개념. null을 허용하는 관계에는 LEFT OUTER JOIN이 만들어져 관련 객체가 없어도 원본 행은 그대로 남고 관련 컬럼만 null로 채워진다.', false),
(9612, 3539, '역참조 FK나 다대다 관계를 인자로 주면 FieldError가 발생한다', '1:N을 JOIN하면 부모 행이 자식 수만큼 복제돼 결과가 부풀기 때문에 Django가 아예 막는다. 행 하나에 관련 객체가 하나뿐인 FK·OneToOne 정참조와 OneToOne 역참조에만 쓸 수 있다.', true),
(9613, 3539, '이중 언더스코어로 두 단계 깊이를 지정하면 단계마다 쿼리가 한 번씩 추가된다', '깊이 탐색을 쿼리 추가로 오해한 것. author__profile처럼 단계를 늘려도 JOIN 절이 하나 더 붙을 뿐이라 쿼리는 여전히 1회다. 단계마다 쿼리가 느는 쪽은 prefetch_related다.', false),
(9614, 3539, '관련 객체에 별도 queryset을 넘겨 필터와 정렬을 미리 걸어 둘 수 있다', 'Prefetch 객체의 기능을 갖다 붙인 오개념. JOIN 조건은 관계 정의를 따라 고정되므로 관련 객체 쪽에 조건을 얹을 수 없고, 조건이 필요하면 prefetch_related와 Prefetch를 써야 한다.', false),

-- 문제 3540
(9615, 3540, '2', '미리 가져온 캐시를 그대로 쓴다고 본 것. 관계에 filter를 다시 붙이면 Django는 캐시를 버리고 새 쿼리를 만들기 때문에 반복문 안에서 쿼리가 계속 나간다.', false),
(9616, 3540, '31', '미리 가져오는 쿼리 1회를 빼고 센 것. 캐시를 쓰지 못하게 되더라도 관련 객체를 모아 오는 IN 쿼리는 반복문에 들어가기 전에 이미 실행된 뒤다.', false),
(9617, 3540, '32', '목록 1회 + 댓글을 모아 오는 IN 쿼리 1회 + 행마다 조건을 다시 걸어 세는 30회 = 32회다. 미리 가져온 결과를 쓰지도 못하면서 쿼리만 1회 더 낸 셈이라, 조건은 Prefetch에 미리 걸어야 한다.', true),
(9618, 3540, '62', 'filter와 count가 각각 쿼리를 낸다고 본 것. 두 호출은 하나의 QuerySet으로 이어지고 마지막 count에서 COUNT 쿼리 한 번으로 평가되므로 행마다 늘어나는 쿼리는 1회씩이다.', false),

-- 문제 3541
(9619, 3541, '게시글마다 달린 댓글 목록은 JOIN으로 묶는 쪽이 쿼리 1회로 끝나므로 별도 쿼리를 내는 쪽보다 유리하다', '댓글은 게시글 기준 역참조 FK라 적용 관계 행에 따라 JOIN 쪽은 쓸 수조차 없다. 1:N을 JOIN하면 부모 행이 댓글 수만큼 복제돼 결과가 폭증하므로 이런 관계는 별도 쿼리 쪽이 맞다.', true),
(9620, 3541, '관련 객체 중 삭제되지 않은 것만 가져와야 한다면 별도 쿼리를 내는 쪽을 골라야 한다', '참이다. 추가 조건 행대로 JOIN 쪽은 조인 조건이 고정돼 관련 객체를 걸러낼 수 없고, Prefetch에 queryset을 넘기는 방식만 관련 객체 쪽에 조건을 미리 걸 수 있다.', false),
(9621, 3541, '별도 쿼리를 내는 쪽은 관계를 두 개 지정하면 쿼리가 두 번 늘지만, 그 증가량은 목록의 행 수와 무관하다', '참이다. 동작 방식 행대로 관계마다 쿼리가 1회씩 붙을 뿐이고, 각 쿼리는 목록 전체의 키를 한꺼번에 넣어 관련 객체를 가져오므로 행이 늘어도 쿼리 수는 그대로다.', false),
(9622, 3541, '관련 객체의 컬럼이 많을수록 JOIN으로 묶는 쪽은 같은 값을 여러 행에 반복해 담아 전송량이 커진다', '참이다. 결과 크기 행대로 JOIN은 결과 행에 관련 컬럼을 붙여 내려주므로, 같은 관련 객체를 참조하는 행이 많을수록 동일한 값이 반복돼 넓은 결과가 오간다.', false),

-- 문제 3542
(9623, 3542, '조회 대상에서 빠진 body는 값이 채워지지 않아 None으로 출력된다', '가져오지 않은 필드가 빈 값으로 남는다고 본 오개념. Django는 그 필드에 접근하는 시점에 값을 채워 넣으므로 출력값 자체는 정상이고, 대신 조회 비용이 뒤로 미뤄질 뿐이다.', false),
(9624, 3542, '지정하지 않은 필드를 참조했으므로 FieldError가 발생하며 반복문이 중단된다', 'values()처럼 필드가 아예 사라진다고 본 오개념. 모델 인스턴스는 그대로 돌려주므로 지정하지 않은 필드도 접근할 수 있고, 예외 대신 조용히 추가 조회가 일어나 문제가 늦게 드러난다.', false),
(9625, 3542, '본 쿼리가 끝난 직후 body가 키 목록을 넣은 IN 쿼리 1회로 한꺼번에 채워진다', 'prefetch_related의 묶음 조회를 갖다 붙인 오개념. 지연된 필드에는 미리 모아 채워 주는 장치가 없어 인스턴스별로 따로 조회되고, 그래서 목록이 길수록 손해가 커진다.', false),
(9626, 3542, 'body에 접근할 때마다 그 행만을 위한 쿼리가 나가 총 21회가 실행된다', '목록 1회 + 지연된 body를 채우는 20회다. 큰 컬럼을 빼려고 필드를 좁혔는데 결국 그 컬럼을 읽으면서 N+1이 되살아난 경우로, 값만 필요하면 values()가 안전하다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1136, 3543, 'distinct=True,distinct = True,distinct=true,distinct', '두 개의 1:N 관계를 한 번에 집계하면 JOIN 결과가 댓글 4행 × 태그 3행 = 12행으로 부풀고, COUNT가 그 12행을 그대로 세면서 두 값이 모두 12로 나온다. Count("comments", distinct=True)처럼 인자를 주면 중복 행을 제거한 뒤 세므로 4와 3을 얻는다. 관계가 하나뿐이면 이 현상이 없고, 관계가 셋 이상이거나 조건이 복잡하면 distinct 대신 Subquery로 집계를 분리하는 편이 안전하다. 행마다 컬럼을 붙이는 annotate와 달리 aggregate는 QuerySet 전체에 대해 값 하나만 돌려준다는 점도 함께 구분해 두자.'),
       (1137, 3544, 'N+1 문제,N+1,N+1 쿼리,N+1 쿼리 문제,N+1 query,N+1 query problem,N+1 problem,엔 플러스 원,엔플러스원,N 플러스 1', '목록을 가져오는 쿼리 1회에, 행마다 관련 객체를 읽는 쿼리 N회가 따라붙어 총 1+N회가 되는 현상이다. 로그에서 id=7인 사용자가 두 번 조회되는 대목이 원인을 그대로 보여준다. 관련 객체 캐시는 인스턴스 단위라, 저자가 같아도 게시글 인스턴스가 다르면 캐시를 공유하지 않는다. 쿼리 하나가 오래 걸리는 슬로 쿼리와 달리 개별 쿼리는 1ms 안쪽으로 빠르고 횟수만 행 수에 비례해 늘어나므로, 인덱스나 실행 계획을 손봐도 나아지지 않는다. 정참조는 select_related로, 역참조·다대다는 prefetch_related로 미리 채워 넣어야 해결된다.');

-- =====================================================
-- Lesson 718: 쿼리 수 계산과 annotate·defer
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4487, 718, '아래 코드를 실행하는 동안 데이터베이스로 보내지는 쿼리는 모두 몇 번인가?', 'post 테이블에서 author_id가 7인 게시글은 3개이고, 세 게시글의 저자는 모두 같은 사용자다. 이 밖에 관련 객체를 미리 불러오는 설정은 없다.

```python
posts = list(Post.objects.filter(author_id=7))
for post in posts:
    print(post.author.name)
    print(post.author.email)
```', 'OBJECTIVE'),
       (4488, 718, '아래 설명에 해당하는 조회 최적화 방식의 특징으로 옳은 것은?', '이 QuerySet 메서드는 본 쿼리를 먼저 실행해 목록을 가져온 뒤, 인자로 받은 관계의 객체를 목록의 기본키를 모아 넣은 `WHERE ... IN (...)` 쿼리로 따로 조회한다. 그렇게 가져온 관련 객체는 파이썬 메모리에서 목록의 각 행에 짝지어 붙인다.', 'OBJECTIVE'),
       (4489, 718, '아래 로그의 목록 API를 쿼리 1회로 줄이는 수정으로 옳은 것은?', '게시글 목록 API가 게시글마다 댓글 수와 로그인한 사용자(id=5)의 좋아요 여부를 함께 내려준다. Comment와 PostLike 모델은 각각 post FK로 게시글을 참조하며, 댓글 내용이나 좋아요 기록 자체는 응답에 쓰지 않는다. 게시글 20개를 응답할 때 django-debug-toolbar에 찍힌 쿼리는 아래와 같다.

```
[1회]  SELECT id, title, created_at FROM post LIMIT 20
[20회] SELECT COUNT(*) FROM comment WHERE post_id = ?
[20회] SELECT 1 FROM post_like WHERE post_id = ? AND user_id = 5 LIMIT 1
총 41개 쿼리
```', 'OBJECTIVE'),
       (4490, 718, '아래 목록 API의 쿼리를 2회로 줄이는 get_queryset 반환값은?', '게시글 20개를 페이지네이션 없이 한 번에 응답하는 API다. author는 ForeignKey, tags는 ManyToManyField이며, 뷰 코드에는 반복문이 없는데도 요청 한 번에 쿼리가 41회 실행된다.

```python
class PostSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source="author.name")
    tag_names = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = ["id", "title", "author_name", "tag_names"]

    def get_tag_names(self, obj):
        return [tag.name for tag in obj.tags.all()]


class PostListView(ListAPIView):
    serializer_class = PostSerializer

    def get_queryset(self):
        return Post.objects.all()
```', 'OBJECTIVE'),
       (4491, 718, '아래 코드의 빈칸에 들어갈 QuerySet 메서드 이름은?', E'post 테이블의 컬럼은 id, title, author_id, body, created_at이고, body는 평균 80KB인 TextField다. 목록 화면에서 body를 쓰지 않아 아래처럼 빈칸을 채워 조회를 바꿨더니, 실행된 SQL이 다음과 같이 달라졌다.\n\n```python\nposts = Post.objects.________("body")\n```\n\n```sql\n-- 변경 전\nSELECT post.id, post.title, post.author_id, post.body, post.created_at FROM post\n\n-- 변경 후\nSELECT post.id, post.title, post.author_id, post.created_at FROM post\n```', 'SUBJECTIVE'),
       (4492, 718, '아래 코드를 실행할 때 SQL에서 category 테이블을 post 테이블에 붙이는 조인의 종류는?', 'post 테이블의 게시글 120개 중 15개는 아직 카테고리가 정해지지 않아 category_id가 NULL이다.

```python
class Post(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, null=True, on_delete=models.SET_NULL)


posts = Post.objects.select_related("author", "category")
for post in posts:
    print(post.title, post.author.name, post.category)
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4487
(12139, 4487, '1', 'author_id로 걸러 저자 객체까지 함께 불러왔다고 본 것. 조건에 쓴 author_id는 post 행에 있는 컬럼일 뿐이라 user 행은 가져오지 않고, 저자를 같은 쿼리에 담으려면 select_related가 필요하다.', false),
(12140, 4487, '2', '저자가 같으면 게시글 인스턴스끼리 캐시를 나눠 쓴다고 본 것. 관련 객체 캐시는 인스턴스마다 따로 붙으므로, 같은 사용자라도 게시글 인스턴스가 다르면 user를 다시 조회한다.', false),
(12141, 4487, '4', '목록 1회 + 게시글 인스턴스마다 author에 처음 접근할 때 1회씩 3회 = 4회다. 같은 인스턴스에서 author.email을 읽을 때는 앞서 가져와 그 인스턴스에 캐시된 객체를 쓰므로 쿼리가 나가지 않는다.', true),
(12142, 4487, '7', 'author에 접근할 때마다 쿼리가 나간다고 본 것. 정참조로 한 번 가져온 관련 객체는 해당 인스턴스에 캐시되므로, 같은 게시글에서 name 다음 email을 읽는 두 번째 접근은 추가 쿼리가 없다.', false),

-- 문제 4488
(12143, 4488, '반복문 안에서 관계에 filter()를 붙여도 미리 가져온 결과 안에서 걸러져 쿼리가 늘지 않는다', '미리 채운 결과가 그대로 재사용된다고 본 오개념. 관계에 filter()를 다시 붙이면 캐시를 버리고 새 쿼리를 내 N+1이 되살아나므로, 조건은 Prefetch(queryset=...)로 미리 걸어야 한다.', false),
(12144, 4488, 'comments__writer처럼 두 단계 경로를 넘기면 단계마다 관련 객체 쿼리가 1회씩 늘어난다', '관계를 JOIN으로 묶지 않고 단계마다 IN 쿼리를 따로 내기 때문이다. 댓글을 모으는 쿼리 1회와 그 댓글들의 writer를 모으는 쿼리 1회가 목록 쿼리에 더해져 총 3회가 되고, 이 수는 목록 행 수와 무관하다.', true),
(12145, 4488, '역참조 FK나 다대다 관계를 인자로 넘기면 부모 행이 복제되므로 FieldError가 발생한다', 'select_related의 제약을 갖다 붙인 오개념. 부모 행 복제는 1:N을 JOIN할 때 생기는데, 이 방식은 관련 객체를 별도 쿼리로 가져와 파이썬에서 붙이므로 다대다·역참조 FK에도 쓸 수 있다.', false),
(12146, 4488, '관련 객체 쿼리는 반복문에서 각 행의 관계에 처음 접근하는 순간 그 행마다 실행된다', '지연 로딩과 섞어 본 오개념. 관련 객체 쿼리는 QuerySet이 평가될 때 본 쿼리 직후 한꺼번에 실행되고, 반복문 안의 관계 접근은 이미 채워진 결과를 읽기만 한다.', false),

-- 문제 4489
(12147, 4489, 'select_related로 두 관계를 JOIN해 목록 쿼리 한 번에 함께 가져온다', 'JOIN 한 번이면 끝난다고 본 오개념. 댓글·좋아요는 게시글 쪽에서 보면 역참조 FK라 select_related에 넘기면 FieldError가 나고, 1:N을 JOIN하면 게시글 행이 복제되기도 한다.', false),
(12148, 4489, 'prefetch_related로 두 관계의 행을 미리 가져와 파이썬에서 필요한 값을 계산한다', '행마다 반복되던 쿼리는 사라지지만 목록 1회 + 관계별 IN 쿼리 2회로 3회가 남는다. 게다가 개수와 여부 두 값만 쓰는데 댓글·좋아요 행 전체를 메모리에 올려 낭비가 크다.', false),
(12149, 4489, 'only로 목록 쿼리의 컬럼을 줄여 반복되는 쿼리 하나하나를 가볍게 만든다', '컬럼 수와 쿼리 수를 섞은 오개념. only는 목록 쿼리가 가져오는 컬럼만 줄일 뿐, 게시글마다 나가는 COUNT 조회와 좋아요 조회 40회는 그대로 남아 여전히 41회다.', false),
(12150, 4489, 'annotate로 필요한 값을 SQL에서 계산하게 해 목록 쿼리의 컬럼으로 붙인다', '댓글 수는 Count, 좋아요 여부는 Exists 서브쿼리로 붙이면 목록 쿼리 1회 안에서 DB가 계산해 컬럼으로 돌려준다. 관련 객체는 가져오지 않고, Exists는 조인 없이 행마다 계산돼 GROUP BY 부작용도 없다.', true),

-- 문제 4490
(12151, 4490, 'Post.objects.select_related("author").prefetch_related("tags")', 'FK인 author는 select_related가 목록 쿼리에 JOIN으로 합치고, 다대다인 tags는 prefetch_related가 IN 쿼리 1회로 모아 온다. 목록 1회 + 태그 1회 = 2회이며, 시리얼라이저의 author.name과 tags.all()은 채워진 결과를 읽는다.', true),
(12152, 4490, 'Post.objects.select_related("author", "tags")', 'JOIN 한 번으로 두 관계를 다 가져온다고 본 오개념. tags는 다대다라 JOIN하면 게시글 행이 태그 수만큼 복제되므로 Django가 select_related에서 막고 FieldError를 낸다.', false),
(12153, 4490, 'Post.objects.prefetch_related("author", "tags")', 'prefetch_related를 FK에 쓸 수 있다는 점은 맞지만, author까지 별도 IN 쿼리로 가져와 목록 1회 + author 1회 + tags 1회 = 3회가 된다. FK는 JOIN으로 목록 쿼리에 합쳐야 한 번을 더 아낀다.', false),
(12154, 4490, 'Post.objects.select_related("author").annotate(tag_count=Count("tags"))', '태그 수를 붙이면 태그 조회가 사라진다고 본 오개념. 시리얼라이저는 태그 이름 목록을 얻으려고 여전히 obj.tags.all()을 호출하므로 목록 1회 + 게시글마다 1회씩 20회 = 21회가 된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1452, 4491, 'defer,defer(),.defer,.defer(),QuerySet.defer,defer("body"),디퍼', '변경 후 SQL에서 인자로 준 body만 빠지고 나머지 컬럼은 그대로 조회됐으므로, 지정한 필드를 제외하고 가져오는 defer다. 같은 자리에 only를 넣으면 only("body")는 기본키와 body만 가져와 SELECT post.id, post.body FROM post가 되므로 결과가 정반대다. 두 메서드 모두 모델 인스턴스를 돌려주기 때문에, 뺀 body를 나중에 반복문에서 읽으면 인스턴스마다 추가 쿼리가 나가 또 다른 N+1이 생긴다. 인스턴스 없이 값만 쓴다면 values()·values_list()가 더 가볍고 안전하다. 행을 조건으로 거르는 exclude()는 컬럼이 아니라 행을 다루므로 이 자리에 올 수 없다.'),
       (1453, 4492, 'LEFT OUTER JOIN,LEFT JOIN,LEFT OUTER,왼쪽 외부 조인,왼쪽 외부조인,좌측 외부 조인,좌외부 조인,레프트 조인,레프트 아우터 조인', 'category는 null=True라 짝이 되는 카테고리 행이 없는 게시글이 있을 수 있다. 여기에 INNER JOIN을 쓰면 category_id가 NULL인 게시글 15개가 결과에서 조용히 사라지므로, Django는 null을 허용하는 FK를 select_related할 때 LEFT OUTER JOIN을 만든다. 그 결과 120개가 모두 남고 카테고리 컬럼만 NULL로 채워져 post.category는 None이 된다. 반면 null을 허용하지 않는 author는 짝이 반드시 있으므로 INNER JOIN으로 붙는다. 어느 쪽이든 JOIN으로 합쳐 쿼리는 1회이며, 관련 객체를 별도 IN 쿼리로 가져와 파이썬에서 붙이는 prefetch_related와는 동작 방식이 다르다.');

-- =====================================================
-- Lesson 876: N+1 회귀 막기와 조회 방식 고르기 — prefetch 체이닝·OneToOne 역참조·Subquery 집계·JOIN 전송량·values
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5435, 876, '아래 코드를 실행할 때 데이터베이스로 보내지는 쿼리는 모두 몇 번인가?', 'post 테이블에는 행이 40개 있고, 그중 공개된(is_published=True) 게시글은 25개다. tags는 ManyToManyField이며, 각 게시글에는 태그가 여러 개 연결돼 있다.

```python
qs = Post.objects.prefetch_related("tags")
qs = qs.filter(is_published=True).order_by("-created_at")

for post in qs:
    print(post.title, [t.name for t in post.tags.all()])
```', 'OBJECTIVE'),
       (5436, 876, '아래 모델을 기준으로 User 목록을 조회하는 코드에 대한 설명으로 옳은 것은?', 'User는 30명이고, 사용자마다 프로필이 하나씩 있으며 게시글은 여러 개씩 있다.

```python
class User(models.Model):
    name = models.CharField(max_length=50)


class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    bio = models.TextField()


class Post(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name="posts")
    title = models.CharField(max_length=200)
```', 'OBJECTIVE'),
       (5437, 876, '아래 QuerySet 집계 방식에 대한 설명으로 옳은 것은?', '게시글 목록에 게시글마다 최신 댓글 작성자와 로그인한 사용자의 좋아요 여부를 붙이려고 아래처럼 작성했다. 이 방식은 관련 테이블을 본 쿼리에 JOIN하지 않는다. 대신 바깥 쿼리의 현재 행을 가리키는 OuterRef를 조건으로 삼은 내부 쿼리를 SELECT 절에 넣어, 목록의 행마다 값을 하나씩 계산해 컬럼으로 붙인다.

```python
latest = Comment.objects.filter(post=OuterRef("pk")).order_by("-created_at")
posts = Post.objects.annotate(
    last_writer_id=Subquery(latest.values("writer_id")[:1]),
    liked_by_me=Exists(Like.objects.filter(post=OuterRef("pk"), user_id=user.id)),
)
```', 'OBJECTIVE'),
       (5438, 876, '아래 상황에서 쿼리 수를 주문 건수와 무관하게 유지하면서 전송량을 줄이는 수정으로 옳은 것은?', '월간 주문 리포트가 이번 달 주문 20,000건을 한 번에 조회한다. Order는 product FK로 Product를 참조하는데, 이번 달 주문은 상품 8종에만 몰려 있다. Product에는 평균 50KB인 description 컬럼이 있고, 리포트는 주문마다 상품명과 description의 첫 줄을 출력한다.

```python
orders = Order.objects.select_related("product")
for order in orders:
    report.write(order.id, order.product.name, order.product.description.splitlines()[0])
```

django-debug-toolbar로 측정하니 쿼리는 1회였지만 결과 행은 20,000개, DB에서 받아 온 데이터는 약 1GB였다.', 'OBJECTIVE'),
       (5439, 876, '아래 테스트 코드의 빈칸에 들어갈 메서드 이름은?', '게시글 목록 API에 아래 테스트가 있다. 이후 누군가 PostSerializer에 comment_count = serializers.SerializerMethodField()를 추가하자, 화면은 정상으로 나오는데 CI에서 이 테스트만 아래처럼 실패했다.

```python
class PostListAPITest(TestCase):
    def test_list_query_count(self):
        PostFactory.create_batch(20)
        with self.________(2):
            self.client.get("/api/posts/")
```

```
FAIL: test_list_query_count
AssertionError: 22 != 2 : 22 queries executed, 2 expected
Captured queries were:
1. SELECT ... FROM post ...
2. SELECT ... FROM tag INNER JOIN post_tags ... WHERE post_tags.post_id IN (1, 2, ..., 20)
3. SELECT COUNT(*) FROM comment WHERE comment.post_id = 1
4. SELECT COUNT(*) FROM comment WHERE comment.post_id = 2
...
```', 'SUBJECTIVE'),
       (5440, 876, '아래 개선 후 코드의 빈칸에 들어갈 QuerySet 메서드 이름은?', '게시글 200,000건의 제목과 작성자 이름을 CSV로 내보내는 배치 작업이다. 개선 전 코드는 쿼리 1회로 끝났지만 최고 메모리 사용량이 1.2GB였다. 빈칸을 채운 개선 후 코드도 쿼리는 1회였고, 최고 메모리 사용량은 280MB로 줄었다. 개선 후 반복 변수 row를 하나 출력하면 아래처럼 찍힌다.

```python
# 개선 전
posts = Post.objects.select_related("author").only("title", "author__name")
for post in posts:
    writer.writerow([post.title, post.author.name])

# 개선 후
for row in Post.objects.________("title", "author__name"):
    writer.writerow([row["title"], row["author__name"]])
```

```
{''title'': ''서버 점검 안내'', ''author__name'': ''김하나''}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5435
(14667, 5435, '1', 'prefetch_related도 JOIN으로 본 쿼리에 합쳐진다고 본 것. 다대다 관계는 본 쿼리가 끝난 뒤 공개 게시글 id를 모은 IN 쿼리로 따로 가져오므로 목록 1회에 태그 1회가 더해진다.', false),
(14668, 5435, '2', 'QuerySet은 지연 평가라 for 문에서 처음 평가될 때 filter·order_by가 합쳐진 목록 쿼리 1회가 나가고, 곧이어 태그 IN 쿼리 1회가 실행된다. 본 QuerySet에 조건을 이어 붙여도 prefetch 설정은 그대로 이어지므로 post.tags.all()은 캐시를 읽는다.', true),
(14669, 5435, '3', '메서드를 이어 붙일 때마다 쿼리가 나간다고 본 것. prefetch_related를 붙인 첫 줄에서 40행을 먼저 조회하지 않는다. 평가는 for 문에서 한 번만 일어나 목록 1회 + 태그 1회로 끝난다.', false),
(14670, 5435, '26', 'prefetch 뒤 filter()를 붙이면 캐시가 버려진다는 주의를 본 QuerySet까지 넓힌 오개념. 캐시가 버려지는 것은 post.tags.filter()처럼 관계 쪽에 조건을 걸 때이고, 본 QuerySet의 filter·order_by는 prefetch 설정을 그대로 이어받는다.', false),

-- 문제 5436
(14671, 5436, 'select_related("profile")는 프로필을 JOIN으로 붙여 사용자 목록 쿼리 1회에 함께 담아 온다', 'Profile이 OneToOneField로 User를 참조해 사용자 한 명에 프로필은 많아야 하나다. JOIN해도 사용자 행이 복제되지 않으므로 역참조인데도 select_related가 허용되고 쿼리 1회로 끝난다.', true),
(14672, 5436, 'select_related("posts")는 게시글을 JOIN으로 붙여 사용자 목록 쿼리 1회에 함께 담아 온다', '역참조면 무엇이든 JOIN할 수 있다고 본 오개념. posts는 역참조 FK라 사용자 한 명에 게시글이 여러 개이고, JOIN하면 사용자 행이 게시글 수만큼 복제되므로 Django가 FieldError로 막는다.', false),
(14673, 5436, 'prefetch_related("profile")는 OneToOne 관계에 쓸 수 없어 FieldError가 발생한다', 'prefetch_related의 적용 범위를 좁게 본 오개념. 관계 종류에 제한이 없어 프로필도 목록 1회 + IN 쿼리 1회 = 2회로 가져온다. 다만 OneToOne은 JOIN 한 번으로 끝나는 select_related가 쿼리를 한 번 아낀다.', false),
(14674, 5436, 'prefetch_related("posts")는 반복문에서 user.posts.all()에 접근할 때마다 사용자별 쿼리를 낸다', '미리 가져오기를 지연 로딩과 섞어 본 오개념. 사용자 30명의 id를 모은 IN 쿼리 1회로 게시글을 한꺼번에 가져와 두므로, 반복문의 user.posts.all()은 채워진 결과를 읽기만 해 총 2회로 끝난다.', false),

-- 문제 5437
(14675, 5437, '목록의 행마다 값을 계산하므로 게시글 수만큼 쿼리가 추가로 실행된다', '행마다 계산을 행마다 쿼리로 오해한 것. 내부 쿼리는 본 쿼리의 SELECT 절 안에 들어가 DB가 한 번에 처리하므로, 애플리케이션이 보내는 쿼리는 목록 1회뿐이다.', false),
(14676, 5437, '붙인 값은 파이썬 속성이라 order_by나 filter의 조건으로는 쓸 수 없다', 'annotate 결과를 파이썬에서 덧붙인 속성으로 본 오개념. DB가 계산한 쿼리 결과 컬럼이라 order_by("-liked_by_me")처럼 정렬에 쓸 수 있고, filter(Exists(...))처럼 조건으로 직접 넣을 수도 있다.', false),
(14677, 5437, '내부 쿼리가 돌려준 행을 파이썬 메모리로 가져와 게시글 id 기준으로 짝지어 붙인다', 'prefetch_related의 결합 방식을 갖다 붙인 오개념. 계산은 DB 안에서 끝나고 게시글 행마다 값 하나씩만 붙어 오므로, 댓글이나 좋아요 행은 파이썬으로 넘어오지 않는다.', false),
(14678, 5437, '댓글 수 같은 다른 1:N 값을 같은 방식으로 함께 붙여도 값이 곱해져 부풀지 않는다', '관련 테이블을 JOIN하지 않고 행마다 독립된 내부 쿼리로 계산해 곱집합이 생기지 않는다. 두 1:N 관계를 Count로 함께 붙이면 JOIN 결과가 곱해져 값이 부푸는 것과 달리, 관계별 값이 따로 계산된다.', true),

-- 문제 5438
(14679, 5438, 'select_related를 지워 JOIN을 없애고, 반복문에서 order.product에 접근할 때 상품을 읽게 한다', 'JOIN만 없애면 된다고 본 것. 관련 객체 캐시는 주문 인스턴스마다 따로라, 상품이 8종뿐이어도 주문마다 조회가 나가 쿼리가 20,001회로 늘어나는 N+1이 된다.', false),
(14680, 5438, 'select_related는 그대로 두고, defer("product__description")로 description을 목록 쿼리에서 뺀다', '리포트가 쓰는 컬럼을 뺀 것. 지연된 필드는 접근하는 인스턴스마다 따로 조회되므로 주문마다 description 쿼리가 나가 또 다른 N+1이 생긴다. defer는 화면에서 쓰지 않는 큰 컬럼에 써야 한다.', false),
(14681, 5438, 'select_related를 prefetch_related("product")로 바꿔, 상품을 별도 IN 쿼리로 가져온다', 'prefetch_related는 FK에도 쓸 수 있다. 주문 1회 + 상품 8행을 모아 오는 IN 쿼리 1회 = 2회로 고정되고 description은 8번만 전송된다. 여러 행이 같은 큰 관련 객체를 가리키면 JOIN보다 유리하다.', true),
(14682, 5438, 'select_related는 그대로 두고, distinct()를 붙여 반복되는 상품 컬럼을 걸러 낸다', '중복 행 제거로 오해한 것. 주문 행은 id가 모두 달라 DISTINCT로 줄어드는 행이 없고, 행마다 붙은 상품 컬럼도 그대로라 전송량은 줄지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1768, 5439, 'assertNumQueries,assertNumQueries(),.assertNumQueries,.assertNumQueries(),self.assertNumQueries,self.assertNumQueries(),TestCase.assertNumQueries,assertNumQueries(2)', 'assertNumQueries(n)는 with 블록 안에서 실행된 쿼리 수가 n과 다르면 테스트를 실패시키고, 실패 메시지에 실제로 실행된 쿼리 목록을 함께 보여 준다. 로그를 보면 목록 1회와 태그 IN 쿼리 1회 뒤로 comment_count를 구하는 COUNT 쿼리가 게시글 20개마다 하나씩 붙어 22회가 됐다. 뷰 코드에 반복문이 없어도 시리얼라이저 필드가 관련 객체를 건드리면 N+1이 생기므로, get_queryset에서 annotate(comment_count=Count("comments"))로 목록 쿼리에 개수를 붙이고 시리얼라이저가 그 값을 읽게 하면 다시 2회로 돌아온다. 개발 중 쿼리 수를 눈으로 확인하는 django-debug-toolbar와 달리, 이 메서드는 테스트에 쿼리 수를 고정해 두어 CI에서 회귀를 자동으로 잡아 낸다는 점이 다르다.'),
       (1769, 5440, 'values,values(),.values,.values(),QuerySet.values,Post.objects.values', 'row가 딕셔너리로 찍히고 키로 값을 꺼내므로 values다. 모델 인스턴스를 만들지 않고 지정한 컬럼 값만 딕셔너리로 돌려주며, author__name처럼 관계를 따라가면 JOIN으로 같은 쿼리에 담긴다. 개선 전 only도 쿼리는 1회였지만 행마다 Post와 User 인스턴스를 만들어 메모리를 더 썼고, 지정하지 않은 필드에 접근하면 인스턴스마다 추가 쿼리가 나갈 위험도 있다. 모델의 메서드나 프로퍼티가 필요하면 only·defer를, 값만 필요하면 values를 고르는 것이 기준이다. 같은 자리에 values_list를 쓰면 딕셔너리가 아니라 튜플이 나오므로 row["title"]처럼 키로 꺼낼 수 없다.');
