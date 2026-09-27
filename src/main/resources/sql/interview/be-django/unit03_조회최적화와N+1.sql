-- Unit: 조회 최적화와 N+1 (Unit ID: 134)
-- Chapter: Django (Chapter ID: 12)
-- Topic: DJANGO
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-django-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(666, 'DJANGO', 134, 'HARD', true,
 '게시글 목록 API에서 각 게시글의 저자 이름, 태그 목록, 댓글 수와 좋아요 수를 함께 보여줘야 합니다. N+1 없이 조회하려면 각 데이터에 어떤 최적화를 적용하고, 이때 주의할 점은 무엇인가요?',
 '관계 종류와 필요한 데이터에 따라 최적화를 나눠 적용합니다. 저자는 게시글 행 하나에 저자 하나인 FK 정참조 관계이므로 select_related("author")로 SQL JOIN을 걸어 같은 쿼리에서 함께 가져옵니다. 태그는 다대다 관계라 JOIN을 쓸 수 없으므로 prefetch_related("tags")로 WHERE post_id IN (...) 형태의 별도 쿼리 1회로 가져와 파이썬에서 결합합니다. 두 방식은 Post.objects.select_related("author").prefetch_related("tags")처럼 함께 쓸 수 있습니다. 댓글 수와 좋아요 수는 개수만 필요하므로 관련 객체를 가져오거나 게시글마다 count()를 호출하지 않고, annotate(Count(...))로 SQL에서 계산해 컬럼처럼 붙입니다. 주의할 점은 annotate의 Count가 JOIN과 GROUP BY로 변환되기 때문에, 댓글과 좋아요처럼 두 개 이상의 1:N 관계를 동시에 Count하면 조인 결과가 곱해져 값이 부풀어 오른다는 것입니다. 이때는 Count("comments", distinct=True)를 쓰거나 Subquery로 분리합니다. 마지막으로 assertNumQueries로 테스트에서 쿼리 수를 고정해 N+1이 다시 생기는 회귀를 막습니다.'),
(667, 'DJANGO', 134, 'NORMAL', true,
 'Django의 select_related와 prefetch_related는 어떻게 다르며, 각각 어떤 관계에 사용하나요?',
 'select_related는 SQL JOIN을 사용해 관련 객체의 컬럼을 결과 행에 포함시키므로, 관련 객체까지 쿼리 1회로 조회합니다. 반면 prefetch_related는 본 쿼리를 먼저 실행한 뒤 관련 객체를 WHERE id IN (...) 형태의 별도 쿼리로 가져오고, 파이썬 메모리에서 짝을 맞춰 결합합니다. 그래서 쿼리 수는 1 + 관계 수가 됩니다. 적용 관계도 다릅니다. select_related는 ForeignKey·OneToOneField 정참조와 OneToOne 역참조처럼 행 하나에 관련 객체 하나인 관계에만 쓸 수 있습니다. 1:N 관계를 JOIN하면 부모 행이 N배로 복제되기 때문에 Django는 select_related("comments") 같은 사용을 FieldError로 막습니다. 그래서 역참조 FK나 다대다(M2M) 관계에는 prefetch_related를 써야 하며, prefetch_related는 관계 종류에 제한이 없습니다. 또 select_related는 JOIN 조건이 고정이라 추가 조건을 걸 수 없지만, prefetch_related는 Prefetch(queryset=...)로 필터와 정렬을 적용할 수 있습니다. 따라서 1:1·N:1 관계에는 select_related, 1:N·M:N 관계에는 prefetch_related를 쓰며, 두 가지를 함께 쓸 수도 있습니다.'),
(668, 'DJANGO', 134, 'NORMAL', true,
 '목록 조회에서 필요 없는 컬럼을 빼려고 할 때 only·defer와 values()는 각각 언제 쓰며, only()가 오히려 성능을 떨어뜨리는 경우는 언제인가요?',
 'only()와 defer()는 컬럼 단위 최적화로, only()는 지정한 필드만 조회하고 defer()는 지정한 필드를 제외하고 조회합니다. 큰 TextField·JSONField 같은 컬럼을 목록 조회에서 제외할 때 가장 효과가 큽니다. 다만 only()나 defer()로 지연된 필드에 나중에 접근하면 Django가 그 인스턴스만을 위한 쿼리를 자동으로 실행합니다. 예를 들어 only("title")로 조회한 뒤 반복문에서 post.body에 접근하면 인스턴스마다 SELECT body 쿼리가 실행되어 또 다른 N+1이 생기므로 오히려 느려집니다. 그래서 only·defer는 메서드나 프로퍼티 호출처럼 모델 인스턴스가 필요할 때 쓰고, 단순히 값만 필요하다면 values()나 values_list()가 더 가볍고 안전합니다.'),
(669, 'DJANGO', 134, 'EASY', true,
 'ORM에서 말하는 N+1 쿼리 문제란 무엇인가요?',
 'N+1 문제는 목록을 1번의 쿼리로 가져온 뒤, 각 행의 관련 객체에 접근할 때마다 행 수 N만큼 추가 쿼리가 발생하는 현상입니다. 예를 들어 게시글 100개를 조회하고 반복문에서 post.author.name에 접근하면 총 101회의 쿼리가 실행됩니다. 코드에는 반복문 하나뿐이라 눈에 띄지 않지만, 데이터가 늘수록 쿼리 수가 선형으로 증가합니다. 정참조는 인스턴스별로 캐시되지만 인스턴스가 다르면 캐시도 다르므로 같은 관련 객체(예: 같은 저자)도 다시 조회되고, DRF의 중첩 시리얼라이저처럼 뷰 코드에 반복문이 없어도 발생할 수 있습니다. 로컬의 소량 데이터로는 체감되지 않으므로 django-debug-toolbar로 쿼리 수를 확인하거나 테스트에서 assertNumQueries로 쿼리 수를 고정하는 습관이 중요합니다.'),
(670, 'DJANGO', 134, 'EASY', true,
 'prefetch_related로 가져온 관계에 .filter()를 다시 붙이면 어떤 문제가 생기며, 관련 객체에 조건이 필요할 때는 어떻게 해야 하나요?',
 'prefetch_related로 가져온 관계에 .filter()·.exclude()·.order_by()를 다시 붙이면 prefetch 캐시를 버리고 새 쿼리를 실행하기 때문에, 반복문 안에서 게시글마다 쿼리가 나가 N+1이 되살아납니다. 관련 객체에 조건이 필요하면 Prefetch 객체를 사용해 Prefetch("comments", queryset=Comment.objects.filter(is_deleted=False))처럼 조건을 미리 걸어 둡니다. 이 queryset에는 select_related("writer")나 order_by 같은 추가 최적화도 적용할 수 있습니다. 또 to_attr="visible_comments"를 지정하면 결과가 리스트 속성으로 저장되므로, post.comments.all() 대신 post.visible_comments를 순회하면 되고 파이썬에서 조건 분기가 필요할 때도 이 리스트를 순회합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 666
(3597, 666, '저자 같은 FK 정참조 관계에는 JOIN 기반 select_related를 적용한다고 제시', 'ESSENTIAL', 1),
(3598, 666, '태그 같은 다대다(M2M) 관계에는 prefetch_related를 적용한다고 제시', 'ESSENTIAL', 2),
(3599, 666, '댓글 수·좋아요 수는 객체를 가져오지 않고 annotate(Count)로 DB에서 집계한다고 제시', 'ESSENTIAL', 3),
(3600, 666, '두 개 이상의 1:N 관계를 동시에 Count하면 조인 결과가 곱해져 값이 부풀어 오른다고 설명', 'ESSENTIAL', 4),
(3601, 666, '값 부풀림 대응책으로 Count의 distinct=True 또는 Subquery 분리 중 최소 1개를 제시', 'SUPPLEMENTARY', 5),
(3602, 666, 'assertNumQueries로 테스트에 쿼리 수를 고정해 회귀를 막는다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 667
(3603, 667, 'select_related는 SQL JOIN으로 관련 객체를 쿼리 1회에 함께 조회한다고 설명', 'ESSENTIAL', 1),
(3604, 667, 'prefetch_related는 IN 조건의 별도 쿼리로 가져온 뒤 파이썬에서 결합한다고 설명', 'ESSENTIAL', 2),
(3605, 667, 'select_related는 FK·OneToOne처럼 행 하나에 관련 객체 하나인 관계에만 쓸 수 있다고 설명', 'ESSENTIAL', 3),
(3606, 667, '역참조 FK·다대다(M2M) 관계에는 prefetch_related를 써야 한다고 설명', 'ESSENTIAL', 4),
(3607, 667, '1:N 관계를 JOIN하면 부모 행이 N배로 복제되어 select_related에 허용되지 않는다고 언급', 'SUPPLEMENTARY', 5),
(3608, 667, 'Prefetch(queryset=...)로 prefetch_related에만 추가 조건을 걸 수 있다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 668
(3609, 668, 'only는 지정한 필드만, defer는 지정한 필드를 제외하고 조회한다고 설명', 'ESSENTIAL', 1),
(3610, 668, '지연된 필드에 접근하면 인스턴스마다 추가 쿼리가 실행되어 N+1이 생긴다고 설명', 'ESSENTIAL', 2),
(3611, 668, '모델 인스턴스가 필요 없고 값만 필요하면 values()·values_list()가 더 가볍다고 제시', 'ESSENTIAL', 3),
(3612, 668, '큰 TextField·JSONField 컬럼을 목록 조회에서 제외하는 것이 대표 사용 사례라고 언급', 'SUPPLEMENTARY', 4),

-- 질문 669
(3613, 669, '목록 조회 1회 후 행마다 관련 객체 조회가 N회 추가로 발생하는 현상이라고 설명', 'ESSENTIAL', 1),
(3614, 669, '데이터가 늘수록 쿼리 수가 행 수에 비례해 선형으로 증가한다고 언급', 'ESSENTIAL', 2),
(3615, 669, '인스턴스가 다르면 캐시도 달라 같은 관련 객체도 반복 조회된다고 언급', 'SUPPLEMENTARY', 3),
(3616, 669, 'DRF 중첩 시리얼라이저에서는 뷰에 반복문이 없어도 N+1이 발생한다고 언급', 'SUPPLEMENTARY', 4),
(3617, 669, 'django-debug-toolbar·assertNumQueries 중 최소 1개를 쿼리 수 확인 수단으로 제시', 'SUPPLEMENTARY', 5),

-- 질문 670
(3618, 670, 'prefetch한 관계에 .filter()를 붙이면 캐시를 버리고 새 쿼리를 실행해 N+1이 되살아난다고 설명', 'ESSENTIAL', 1),
(3619, 670, '조건은 Prefetch(queryset=...)로 미리 걸어야 한다고 제시', 'ESSENTIAL', 2),
(3620, 670, 'to_attr로 결과를 리스트 속성에 저장해 순회한다고 언급', 'SUPPLEMENTARY', 3),
(3621, 670, 'Prefetch의 queryset에 select_related 같은 추가 최적화도 적용할 수 있다고 언급', 'SUPPLEMENTARY', 4);
