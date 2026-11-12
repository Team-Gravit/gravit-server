-- Unit: QuerySet 지연 평가 (Unit ID: 133)
-- Chapter: Django (Chapter ID: 12)
-- Topic: DJANGO
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-django-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(661, 'DJANGO', 133, 'HARD', true,
 '수십만 행의 로그를 내보내는 작업에서 `for row in BigLog.objects.all()`처럼 QuerySet을 그대로 순회하면 어떤 문제가 생기고, `iterator()`로 바꾸면 무엇을 얻고 무엇을 포기하게 되나요?',
 'QuerySet은 평가되면 결과를 결과 캐시(_result_cache)에 리스트로 전부 보관하기 때문에, 수십만 행을 그대로 순회하면 전체 행이 메모리에 올라가 메모리 사용량이 전체 행 크기에 비례해 커집니다. iterator(chunk_size=N)를 쓰면 청크 단위로 가져오며 스트리밍하므로 메모리 사용량이 청크 크기에 비례하는 수준으로 줄어듭니다. 대신 iterator()는 결과 캐시를 보관하지 않으므로, 여러 번 순회할 수 있는 일반 평가와 달리 재순회하면 쿼리가 다시 실행됩니다. 또 prefetch_related와 함께 쓸 때는 Django 5.0부터 chunk_size를 반드시 지정해야 하고, PostgreSQL·Oracle은 서버 사이드 커서를 쓰지만 MySQL·SQLite는 드라이버가 전체를 가져온 뒤 파이썬 쪽에서만 청크로 나누므로 DB 드라이버 수준의 메모리 절감 효과는 DB마다 다릅니다.',
 'interview-question/661.mp3'),
(662, 'DJANGO', 133, 'NORMAL', true,
 'QuerySet의 존재 여부를 확인할 때 `if qs:`와 `qs.exists()`는 어떻게 다르며, 각각 언제 사용하는 것이 적절한가요?',
 'if qs:처럼 bool()로 검사하면 첫 행만 필요해도 전체 결과를 조회하고, 그 결과로 결과 캐시가 채워집니다. 반면 exists()는 캐시가 없으면 SELECT ... LIMIT 1 같은 별도 쿼리를 즉시 실행할 뿐 결과 캐시를 만들지 않습니다. 그래서 결과를 어차피 이어서 순회할 거라면 bool()로 평가해 캐시를 공유하는 것이 유리하고, 존재 여부만 필요하다면 exists()만 쓰는 것이 옳습니다. 예를 들어 exists()로 확인한 뒤 같은 QuerySet을 for문으로 순회하면 exists()가 캐시를 만들지 않았으므로 전체 조회가 다시 실행되어 쿼리가 두 번 나갑니다.',
 'interview-question/662.mp3'),
(663, 'DJANGO', 133, 'NORMAL', true,
 'Django 모델 인스턴스에서 `post.author`를 두 번 접근할 때와 `post.comments.all()`을 두 번 호출해 각각 순회할 때 쿼리 발생이 어떻게 다른지 설명해 주세요.',
 'post.author 같은 정참조는 처음 접근할 때 쿼리가 한 번 실행되고, 그 결과가 모델 인스턴스 속성에 캐시되어 두 번째 접근부터는 쿼리가 나가지 않습니다. 반면 post.comments 같은 역참조·다대다 매니저는 all()을 호출할 때마다 새 QuerySet을 만들기 때문에 캐시가 없고, 그 QuerySet을 순회할 때마다 매번 쿼리가 실행됩니다. 그래서 반복문 안에서 post.comments.all()을 호출하면 N+1 문제로 이어집니다. prefetch_related로 미리 가져오면 post.comments.all()이 prefetch 캐시를 사용해 쿼리를 내지 않지만, 그 뒤에 .filter()를 붙이면 캐시를 버리고 새 쿼리를 실행합니다. 즉 QuerySet 결과 캐시와 모델 인스턴스의 관련 객체 캐시는 별개입니다.',
 'interview-question/663.mp3'),
(664, 'DJANGO', 133, 'EASY', true,
 'Django QuerySet의 지연 평가란 무엇이며, `filter()`를 여러 번 체이닝하면 쿼리는 몇 번 실행되나요?',
 'Django ORM의 QuerySet은 만들어지는 순간 SQL을 실행하지 않고, 실제로 데이터가 필요한 시점까지 실행을 미루는 지연 평가를 따릅니다. QuerySet은 어떤 데이터를 가져올지 담은 Query 객체일 뿐 데이터 그 자체가 아니어서, filter()·exclude()·order_by() 같은 메서드는 새 QuerySet을 반환할 뿐 DB에 접근하지 않습니다. 체이닝할 때마다 새 QuerySet 객체가 만들어지고 원본은 변경되지 않습니다. 따라서 filter()를 여러 번 호출해도 조건을 조립하는 비용은 파이썬 객체 생성 비용뿐이고, 순회 같은 평가 시점에 SQL 1회로 합쳐져 DB 왕복이 단 한 번 발생합니다. 덕분에 뷰나 서비스 계층에서 조건을 나눠 붙이거나 조건부로 filter를 추가하는 코드를 자연스럽게 쓸 수 있습니다.',
 'interview-question/664.mp3'),
(665, 'DJANGO', 133, 'EASY', true,
 'QuerySet의 결과 캐시는 무엇이며, 캐시가 재사용되는 경우와 재사용되지 않는 경우를 설명해 주세요.',
 'QuerySet은 평가되면 결과를 QuerySet 객체 내부(_result_cache 속성)에 리스트로 캐시해 둡니다. 그래서 같은 QuerySet 객체를 다시 순회하거나 len()을 호출하면 캐시를 재사용해 DB에 가지 않습니다. 반면 filter()처럼 새 QuerySet을 만들면 새 객체이므로 캐시가 공유되지 않고 처음부터 다시 평가됩니다. 또 qs[0] 같은 인덱스 접근은 LIMIT 1 쿼리를 실행하고 캐시에 저장되지 않아 qs[0], qs[1]을 차례로 쓰면 매번 쿼리가 나갑니다. count()·exists()는 이미 캐시가 있으면 캐시를 이용하지만, 캐시가 없으면 별도 쿼리를 날리고 캐시를 만들지 않습니다. 결국 캐시는 QuerySet 객체 단위로 관리되므로 같은 객체를 재사용하는지가 쿼리 수를 결정합니다.',
 'interview-question/665.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 661
(3570, 661, 'QuerySet을 그대로 순회하면 메모리 사용량이 전체 행 크기에 비례함을 설명', 'ESSENTIAL', 1),
(3571, 661, 'iterator()를 쓰면 메모리 사용량이 청크 크기에 비례함을 설명', 'ESSENTIAL', 2),
(3572, 661, 'iterator()를 쓰면 결과 캐시를 보관하지 않음을 언급', 'ESSENTIAL', 3),
(3573, 661, 'iterator()로 순회한 결과를 다시 순회하면 쿼리가 재실행됨을 언급', 'SUPPLEMENTARY', 4),
(3574, 661, 'prefetch_related와 iterator()를 함께 쓰면 Django 5.0부터 chunk_size가 필수임을 언급', 'SUPPLEMENTARY', 5),
(3575, 661, 'MySQL·SQLite는 드라이버가 전체를 가져와 메모리 절감 효과가 DB마다 다름을 언급', 'SUPPLEMENTARY', 6),

-- 질문 662
(3576, 662, 'if qs:(bool 평가)는 첫 행만 필요해도 전체 결과를 조회함을 언급', 'ESSENTIAL', 1),
(3577, 662, 'if qs:(bool 평가)로 평가하면 결과 캐시가 채워짐을 언급', 'ESSENTIAL', 2),
(3578, 662, 'exists()는 결과 캐시를 만들지 않음을 언급', 'ESSENTIAL', 3),
(3579, 662, '이어서 순회할 거면 bool(), 존재 여부만 필요하면 exists()라는 선택 기준을 제시', 'ESSENTIAL', 4),
(3580, 662, 'exists()는 캐시가 없으면 LIMIT 1 별도 쿼리를 실행함을 언급', 'SUPPLEMENTARY', 5),
(3581, 662, 'exists() 확인 뒤 같은 QuerySet을 순회하면 전체 조회 쿼리가 한 번 더 실행됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 663
(3582, 663, '정참조(post.author)는 한 번 접근하면 인스턴스에 캐시되어 두 번째 접근 때 쿼리가 없음을 설명', 'ESSENTIAL', 1),
(3583, 663, '역참조 매니저의 all()은 호출마다 새 QuerySet이라 순회할 때마다 쿼리가 실행됨을 설명', 'ESSENTIAL', 2),
(3584, 663, '반복문 안에서 역참조 매니저의 all()을 호출하면 N+1 문제로 이어짐을 언급', 'SUPPLEMENTARY', 3),
(3585, 663, 'prefetch_related로 미리 가져오면 all()이 prefetch 캐시를 사용해 쿼리를 내지 않음을 언급', 'SUPPLEMENTARY', 4),
(3586, 663, 'prefetch 이후 .filter()를 붙이면 캐시를 버리고 새 쿼리를 실행함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 664
(3587, 664, 'QuerySet은 만들어지는 순간 SQL을 실행하지 않고 데이터가 필요한 시점까지 실행을 미룸을 설명', 'ESSENTIAL', 1),
(3588, 664, 'filter()·exclude()·order_by() 체이닝은 새 QuerySet만 반환하고 DB에 접근하지 않음을 언급', 'ESSENTIAL', 2),
(3589, 664, '체이닝한 조건은 평가 시점에 SQL 1회로 합쳐져 실행됨을 언급', 'ESSENTIAL', 3),
(3590, 664, '체이닝마다 새 QuerySet 객체가 만들어지고 원본은 변경되지 않음을 언급', 'SUPPLEMENTARY', 4),
(3591, 664, '조건부로 filter를 나눠 붙이는 코드를 자연스럽게 쓸 수 있다는 장점을 제시', 'SUPPLEMENTARY', 5),

-- 질문 665
(3592, 665, '평가된 결과가 QuerySet 객체 내부에 리스트로 캐시됨을 언급', 'ESSENTIAL', 1),
(3593, 665, '같은 QuerySet 객체를 다시 순회하면 캐시를 재사용해 DB에 가지 않음을 설명', 'ESSENTIAL', 2),
(3594, 665, 'filter() 등으로 만든 새 QuerySet은 캐시를 공유하지 않아 처음부터 다시 평가됨을 언급', 'ESSENTIAL', 3),
(3595, 665, '인덱스 접근(qs[0])은 매번 LIMIT 1 쿼리를 실행하고 캐시에 저장되지 않음을 언급', 'SUPPLEMENTARY', 4),
(3596, 665, 'count()·exists()는 이미 캐시가 있으면 캐시를 이용함을 언급', 'SUPPLEMENTARY', 5);
