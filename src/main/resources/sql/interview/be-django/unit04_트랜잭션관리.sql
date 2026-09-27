-- Unit: 트랜잭션 관리 (Unit ID: 135)
-- Chapter: Django (Chapter ID: 12)
-- Topic: DJANGO
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-django-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(671, 'DJANGO', 135, 'HARD', true,
 'Django 주문 서비스 함수가 하나의 atomic 블록 안에서 주문 저장, IntegrityError가 날 수 있는 쿠폰 적용, 영수증 메일 Celery 태스크 발행을 모두 수행한다고 해 봅시다. 쿠폰 적용이 실패해도 주문은 유지하고 메일은 확정된 주문에만 보내려면 트랜잭션을 어떻게 설계해야 하며, 잘못 설계하면 어떤 문제가 생기나요?',
 '바깥 transaction.atomic으로 주문 생성을 감싸 실제 트랜잭션을 열고, 실패할 수 있는 쿠폰 적용은 안쪽 atomic으로 한 번 더 감싸 세이브포인트로 격리한 뒤 그 바깥에서 예외를 잡습니다. 이렇게 하면 쿠폰 적용이 실패해도 세이브포인트까지만 롤백되고 주문 자체는 유지됩니다. 만약 안쪽 atomic 없이 atomic 블록 안에서 IntegrityError 같은 DB 예외를 try/except로 잡고 쿼리를 계속 실행하면, 트랜잭션이 이미 실패 상태이고 Django도 롤백 필요 플래그를 세워 두기 때문에 다음 쿼리에서 TransactionManagementError가 발생합니다. 영수증 메일처럼 되돌릴 수 없는 사이드이펙트는 transaction.on_commit(lambda: send_receipt.delay(order.id))처럼 등록해 가장 바깥 트랜잭션이 커밋된 직후에 실행되게 해야 합니다. 블록 안에서 바로 태스크를 발행하면 커밋 전이라 워커가 아직 존재하지 않는 order_id를 조회해 DoesNotExist가 날 수 있고, 롤백되면 유령 주문에 메일이 발송됩니다. on_commit으로 등록한 콜백은 롤백 시 폐기되므로 이런 문제가 없습니다.'),
(672, 'DJANGO', 135, 'NORMAL', true,
 'Django에서 transaction.atomic을 중첩해서 사용하면 바깥 블록과 안쪽 블록은 각각 어떻게 다르게 동작하나요?',
 'atomic은 중첩할 수 있는데, 가장 바깥 블록만 BEGIN/COMMIT/ROLLBACK을 사용하는 실제 트랜잭션을 열고, 안쪽 블록은 SAVEPOINT/RELEASE/ROLLBACK TO를 사용하는 세이브포인트로 변환됩니다. 그래서 바깥 블록에서 예외가 나면 전체가 롤백되지만, 안쪽 블록에서 예외가 나면 세이브포인트까지만 롤백되고 그 예외를 바깥에서 잡으면 바깥 트랜잭션은 계속 유효하게 진행됩니다. 참고로 atomic(savepoint=False)로 세이브포인트를 생략하면 비용은 아낄 수 있지만 안쪽에서 예외가 날 때 바깥 트랜잭션 전체가 롤백 예정 상태가 되어 오염됩니다. 또 durable=True는 해당 블록이 반드시 가장 바깥 트랜잭션이어야 함을 강제하므로, 중첩된 위치에서 사용하면 RuntimeError가 발생합니다.'),
(673, 'DJANGO', 135, 'NORMAL', true,
 'Django에서 ATOMIC_REQUESTS 설정으로 요청 단위 트랜잭션을 쓰는 방식과 필요한 곳에 transaction.atomic을 직접 지정하는 방식은 각각 어떤 장점과 단점이 있나요?',
 'ATOMIC_REQUESTS를 DATABASES 설정에서 True로 두면 미들웨어 이후 뷰 함수 전체가 하나의 트랜잭션으로 감싸지고, 직접 transaction.atomic을 지정하는 기본 방식은 개발자가 지정한 블록만 트랜잭션이 됩니다. ATOMIC_REQUESTS의 장점은 모든 뷰가 자동으로 감싸지므로 트랜잭션을 빼먹을 일이 없어 단순한 CRUD 앱에 편리하다는 것입니다. 단점은 뷰가 길면 트랜잭션·락 보유 시간이 증가하고, 외부 API 호출까지 트랜잭션 안에 들어간다는 점입니다. 반대로 직접 지정하는 atomic은 트랜잭션 범위를 최소화할 수 있어 성능과 락 경합 제어가 용이하다는 장점이 있지만, 트랜잭션이 필요한 곳마다 매번 지정(명시)해야 한다는 단점이 있습니다. 주의할 점으로, ATOMIC_REQUESTS에서도 뷰 안에서 예외를 잡아 400 같은 정상 응답을 돌려주면 롤백되지 않고 커밋되므로 되돌리려면 transaction.set_rollback(True)를 호출해야 합니다. 또 ATOMIC_REQUESTS는 미들웨어에는 적용되지 않아 미들웨어에서 실행한 쿼리는 별도로 커밋됩니다.'),
(674, 'DJANGO', 135, 'EASY', true,
 'Django의 기본 트랜잭션 동작 방식은 무엇이고, 여러 쿼리를 하나의 작업 단위로 처리하려면 어떻게 해야 하나요?',
 'Django는 DB 연결을 autocommit 모드로 열기 때문에 save()·update()·delete() 같은 쿼리가 실행되는 즉시 각각 커밋됩니다. 그래서 재고 차감 후 주문 생성처럼 두 쿼리를 그냥 나열하면 중간에 예외가 나도 앞의 쿼리는 이미 반영된 상태로 남습니다. 여러 쿼리를 모두 성공하거나 모두 취소되게 하려면 transaction.atomic으로 묶어야 합니다. atomic 블록은 정상 종료되면 커밋되고, 예외가 빠져나가면 롤백되며 예외는 삼키지 않고 그대로 다시 던집니다. atomic은 with 문으로 쓰는 컨텍스트 매니저와 데코레이터 양쪽으로 사용할 수 있습니다. 또 select_for_update()로 비관적 잠금을 걸 때는 락이 트랜잭션이 끝날 때 해제되므로 반드시 atomic 블록 안에서 평가해야 하며, 자동 커밋 모드에서 호출하면 TransactionManagementError가 발생합니다.'),
(675, 'DJANGO', 135, 'EASY', true,
 'Django의 TestCase에서 on_commit 콜백이 실행되지 않는 이유는 무엇이고, 이를 테스트하려면 어떻게 해야 하나요?',
 'on_commit 콜백은 트랜잭션이 실제로 커밋된 직후에만 실행되는데, TestCase는 각 테스트를 트랜잭션으로 감싸고 테스트가 끝나면 롤백하기 때문에 커밋이 일어나지 않아 on_commit 콜백이 실행되지 않습니다. 이를 테스트하려면 Django 3.2+의 self.captureOnCommitCallbacks(execute=True)를 사용해 블록 안에서 등록된 콜백을 수집하고 즉시 실행할 수 있으며, 수집된 callbacks의 개수로 콜백 등록 여부를 검증할 수 있습니다. 실제 커밋이 필요한 시나리오라면 TransactionTestCase를 사용하지만 느리므로 최소화하는 것이 좋습니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 671
(3622, 671, 'atomic 안에서 IntegrityError를 잡고 쿼리를 계속하면 TransactionManagementError가 발생함을 언급', 'ESSENTIAL', 1),
(3623, 671, '실패 가능한 쿠폰 적용 구간을 안쪽 atomic(세이브포인트)으로 감싸 격리함을 설명', 'ESSENTIAL', 2),
(3624, 671, '메일 발송 태스크를 transaction.on_commit으로 등록해 커밋 이후에 실행함을 설명', 'ESSENTIAL', 3),
(3625, 671, '커밋 전에 태스크를 발행하면 워커가 아직 존재하지 않는 order_id를 조회하는 문제를 언급', 'SUPPLEMENTARY', 4),
(3626, 671, '트랜잭션이 롤백되면 on_commit에 등록된 콜백은 폐기됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 672
(3627, 672, '가장 바깥 atomic 블록만 BEGIN/COMMIT으로 실제 트랜잭션을 연다는 점을 언급', 'ESSENTIAL', 1),
(3628, 672, '안쪽 atomic 블록은 세이브포인트(SAVEPOINT)로 변환됨을 언급', 'ESSENTIAL', 2),
(3629, 672, '안쪽 블록에서 예외가 나면 세이브포인트까지만 롤백되고 바깥은 계속 진행됨을 설명', 'ESSENTIAL', 3),
(3630, 672, 'savepoint=False면 안쪽 예외가 바깥 트랜잭션 전체를 롤백 예정 상태로 만듦을 언급', 'SUPPLEMENTARY', 4),
(3631, 672, 'durable=True를 중첩된 위치에서 사용하면 RuntimeError가 발생함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 673
(3632, 673, 'ATOMIC_REQUESTS는 트랜잭션을 빼먹을 일이 없다는 장점을 언급', 'ESSENTIAL', 1),
(3633, 673, 'ATOMIC_REQUESTS는 뷰가 길면 트랜잭션·락 보유 시간이 증가한다는 단점을 언급', 'ESSENTIAL', 2),
(3634, 673, '직접 지정한 atomic은 트랜잭션 범위를 최소화할 수 있다는 장점을 언급', 'ESSENTIAL', 3),
(3635, 673, '직접 지정한 atomic은 트랜잭션이 필요한 곳마다 매번 지정해야 한다는 단점을 언급', 'ESSENTIAL', 4),
(3636, 673, 'ATOMIC_REQUESTS는 뷰 함수 전체를, 직접 지정한 atomic은 해당 블록만 감싼다는 적용 범위 차이를 설명', 'SUPPLEMENTARY', 5),
(3637, 673, '뷰에서 예외를 잡아 정상 응답을 반환하면 롤백되지 않고 커밋됨을 언급', 'SUPPLEMENTARY', 6),
(3638, 673, 'ATOMIC_REQUESTS는 미들웨어에는 적용되지 않음을 언급', 'SUPPLEMENTARY', 7),

-- 질문 674
(3639, 674, 'Django의 기본 동작이 쿼리마다 즉시 커밋하는 autocommit 모드임을 언급', 'ESSENTIAL', 1),
(3640, 674, '여러 쿼리를 모두 성공 또는 모두 취소되게 하려면 transaction.atomic으로 묶어야 함을 설명', 'ESSENTIAL', 2),
(3641, 674, 'atomic 블록이 정상 종료되면 커밋되고 예외가 빠져나가면 롤백됨을 설명', 'ESSENTIAL', 3),
(3642, 674, 'atomic을 컨텍스트 매니저와 데코레이터 양쪽으로 사용할 수 있음을 언급', 'SUPPLEMENTARY', 4),
(3643, 674, 'select_for_update()는 atomic 블록 안에서 평가해야 한다는 점을 언급', 'SUPPLEMENTARY', 5),

-- 질문 675
(3644, 675, 'TestCase는 각 테스트를 트랜잭션으로 감싸고 롤백하므로 커밋이 일어나지 않음을 설명', 'ESSENTIAL', 1),
(3645, 675, 'captureOnCommitCallbacks(execute=True)로 콜백을 수집해 실행할 수 있음을 언급', 'ESSENTIAL', 2),
(3646, 675, '실제 커밋이 필요한 시나리오는 TransactionTestCase를 사용함을 언급', 'SUPPLEMENTARY', 3);
