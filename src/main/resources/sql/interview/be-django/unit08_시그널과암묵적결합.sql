-- Unit: 시그널과 암묵적 결합 (Unit ID: 139)
-- Chapter: Django (Chapter ID: 12)
-- Topic: DJANGO
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-django-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(691, 'DJANGO', 139, 'HARD', true,
 '주문이 생성되면 post_save 수신자에서 재고를 차감하고 푸시 알림 태스크를 발행하도록 설계했습니다. 이 설계에서 생길 수 있는 문제와 개선 방법을 설명해 주시겠어요?',
 '먼저 시그널은 모델 변경의 완전한 훅이 아닙니다. 누군가 QuerySet.update()나 bulk_create()·bulk_update(), 혹은 원시 SQL로 주문을 변경하면 post_save가 발생하지 않기 때문에 재고 차감이 조용히 누락되어 데이터 정합성이 깨집니다. 둘째, post_save는 ''커밋됨''이 아니라 ''INSERT 문이 실행됨''을 뜻합니다. atomic 블록 안이라면 아직 커밋 전이고 이후 롤백될 수 있으므로, 여기서 푸시 태스크를 큐에 넣으면 존재하지 않는 유령 주문에 대한 알림이 나갈 수 있습니다. 또한 수신자는 발신자와 같은 스레드에서 save()가 반환되기 전에 동기적으로 실행되므로 수신자의 비용이 그대로 응답 시간에 더해지고, 호출부에는 재고·알림 로직이 드러나지 않아 추적도 어렵습니다. 개선 방법은 place_order 같은 서비스 함수를 만들어 transaction.atomic 안에서 select_for_update로 재고를 조회·차감하고 주문을 생성하는 흐름을 위에서 아래로 명시적으로 호출하는 것입니다. 그리고 푸시 발송은 transaction.on_commit()에 등록해 커밋이 확정된 이후에만 실행되도록 합니다.',
 'interview-question/691.mp3'),
(692, 'DJANGO', 139, 'NORMAL', true,
 '유스케이스의 사이드이펙트를 시그널 수신자로 처리하는 방식과 서비스 함수에서 직접 호출하는 방식은 어떤 차이가 있나요?',
 '시그널 방식은 호출부에 흐름이 드러나지 않는다는 점이 가장 큰 차이입니다. 예를 들어 뷰에서 Order.objects.create()만 보면 주문을 저장하는 것뿐이지만, 실제로는 등록된 post_save 수신자 수만큼 재고·알림·통계 같은 보이지 않는 작업이 일어나고, 이를 알려면 코드베이스 전체에서 수신자를 grep 해야 합니다. 또 수신자는 등록(임포트) 순서대로 실행되고 그 순서는 INSTALLED_APPS와 임포트 경로에 좌우되므로 실행 순서가 보장되지 않아, 수신자 간 의존이 생기면 미묘한 순서 버그가 됩니다. 테스트에서도 Order를 만들 때마다 수신자가 딸려 와서 disconnect하거나 mock을 걸어야 합니다. 반면 서비스 함수 방식은 한 유스케이스에서 일어나는 일을 한 함수 안에서 위에서 아래로 읽히게 명시적으로 호출하므로 흐름과 순서가 코드에 그대로 보입니다. 시그널이 앱 간 결합을 줄인다고 하지만 실제로는 의존 방향만 바뀌었을 뿐 결합 자체는 그대로이고, 그 사실이 보이지 않게 될 뿐입니다.',
 'interview-question/692.mp3'),
(693, 'DJANGO', 139, 'NORMAL', true,
 '시그널 사용이 적절한 경우와 서비스 함수 같은 다른 방법을 써야 하는 경우는 어떤 기준으로 나누나요?',
 '기준은 반응해야 할 이벤트를 발생시키는 코드를 내가 소유하고 있는가입니다. 자신이 소유하지 않은 코드, 즉 프레임워크나 서드파티 앱이 발생시키는 이벤트에 반응해야 할 때는 시그널이 사실상 유일한 훅이므로 적절합니다. 예를 들어 user_logged_in에 반응해 마지막 로그인 IP를 기록하거나, 감사 로그·캐시 무효화처럼 재사용 가능한 라이브러리가 사용자 프로젝트의 모델 저장에 끼어들어야 하는 경우, post_migrate로 초기 데이터와 권한을 생성하는 경우가 있습니다. 반대로 재고·주문·알림처럼 내가 소유한 유스케이스 흐름은 서비스 함수에서 명시적으로 순서대로 호출하고, 모델 자체의 불변식은 save() 오버라이드나 clean()으로, 커밋 이후 사이드이펙트는 transaction.on_commit()으로 처리합니다. 시그널을 쓰기로 했다면 dispatch_uid를 항상 지정하고 수신자는 signals.py에 모아 ready()에서 등록하며, 수신자 안에서는 DB 쓰기·외부 호출을 하지 않되 하더라도 on_commit 안에서 하고, raw 인자를 확인해 fixture 로딩 시 건너뛰도록 합니다.',
 'interview-question/693.mp3'),
(694, 'DJANGO', 139, 'EASY', true,
 'Django 시그널이 무엇이고, 시그널이 발신될 때 수신자가 어떻게 실행되는지 설명해 주시겠어요?',
 'Django 시그널은 발신자(sender)가 ''어떤 일이 일어났다''를 알리면 미리 등록된 수신자(receiver) 함수가 실행되는 옵저버 패턴 구현체입니다. 예를 들어 Order.save()를 호출하면 pre_save가 발신되고 INSERT/UPDATE가 실행된 뒤 post_save가 발신되며, 등록된 수신자들이 등록된 순서대로 호출됩니다. 중요한 점은 수신자가 발신자와 같은 스레드에서 동기적으로 실행되고, 모든 수신자가 끝난 뒤에야 save()가 반환된다는 것입니다. Signal.send()는 수신자 리스트를 순회하며 함수를 차례로 호출할 뿐이라 메시지 큐처럼 별도 프로세스에서 나중에 처리되는 비동기 이벤트가 아니고, 사실상 숨겨진 함수 호출입니다. 그래서 수신자에서 예외가 나면 send()가 그대로 전파해 save() 자체가 실패하며, send_robust()를 쓰면 예외를 잡아 반환값으로 돌려받을 수 있습니다. 수신자는 보통 @receiver 데코레이터로 정의하고 AppConfig.ready()에서 signals 모듈을 임포트해 등록합니다.',
 'interview-question/694.mp3'),
(695, 'DJANGO', 139, 'EASY', true,
 '모델 데이터를 변경했는데도 pre_save·post_save 시그널이 발생하지 않는 경로에는 어떤 것들이 있나요?',
 'pre_save·post_save는 instance.save()를 호출하면 발생하지만, 다음 경로에서는 발생하지 않습니다. QuerySet.update()는 SQL UPDATE를 직접 실행하므로 save 시그널이 발생하지 않고, bulk_create()·bulk_update()도 대량 처리 최적화 경로라 발생하지 않습니다. 또 배치·마이그레이션·외부 도구에서 원시 SQL로 DB를 직접 수정하면 save 시그널뿐 아니라 delete 시그널도 발생하지 않습니다. 반면 loaddata로 fixture를 로딩할 때는 시그널이 raw=True로 발생하므로 수신자에서 raw를 확인해야 합니다. 따라서 시그널은 모델 변경의 완전한 훅이 아니며, post_save로 재고를 차감하는 식으로 반드시 실행되어야 하는 규칙을 시그널에 두면 누군가 update()를 쓰는 순간 조용히 깨집니다.',
 'interview-question/695.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 691
(3724, 691, 'QuerySet.update()나 bulk_create() 경로에서는 post_save가 발생하지 않아 재고 차감이 누락됨을 언급', 'ESSENTIAL', 1),
(3725, 691, 'post_save는 atomic 안에서 커밋 전에 실행되어 롤백 시 유령 알림이 나갈 수 있음을 언급', 'ESSENTIAL', 2),
(3726, 691, '서비스 함수 안에서 재고 차감과 주문 생성을 순서대로 직접 호출하는 대안을 제시', 'ESSENTIAL', 3),
(3727, 691, '푸시 발송을 transaction.on_commit()으로 커밋 이후에 실행하는 방법을 제시', 'ESSENTIAL', 4),
(3728, 691, '수신자가 같은 스레드에서 동기 실행되어 save()를 호출한 API 응답이 느려질 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 692
(3729, 692, '시그널 방식은 호출부 코드에 수신자 로직이 드러나지 않아 흐름 추적이 어려움을 언급', 'ESSENTIAL', 1),
(3730, 692, '서비스 함수 방식은 한 유스케이스의 흐름이 한 함수 안에서 위에서 아래로 읽힘을 언급', 'ESSENTIAL', 2),
(3731, 692, '시그널 수신자의 실행 순서가 등록(임포트) 순서에 좌우되어 보장되지 않음을 언급', 'ESSENTIAL', 3),
(3732, 692, '시그널은 결합을 없애지 않고 의존 방향만 바꾼다는 점을 설명', 'SUPPLEMENTARY', 4),
(3733, 692, '시그널 방식에서는 테스트마다 수신자를 disconnect하거나 mock해야 함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 693
(3734, 693, '자신이 소유하지 않은 코드(프레임워크·서드파티)의 이벤트에 반응할 때 시그널이 적절함을 언급', 'ESSENTIAL', 1),
(3735, 693, 'user_logged_in 반응·재사용 라이브러리·post_migrate 초기 데이터 중 최소 1개를 적절한 사례로 제시', 'ESSENTIAL', 2),
(3736, 693, '재고·주문·알림 같은 유스케이스 흐름은 시그널 대신 서비스 함수에서 호출해야 함을 언급', 'ESSENTIAL', 3),
(3737, 693, '시그널을 쓸 때는 dispatch_uid를 항상 지정해야 함을 언급', 'SUPPLEMENTARY', 4),
(3738, 693, '수신자 안의 DB 쓰기·외부 호출은 on_commit 안에서 해야 함을 언급', 'SUPPLEMENTARY', 5),
(3739, 693, 'fixture 로딩 시 수신자에서 raw 인자를 확인해 건너뛰어야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 694
(3740, 694, '발신자가 알리면 미리 등록된 수신자 함수가 실행되는 구조를 설명', 'ESSENTIAL', 1),
(3741, 694, '수신자는 발신자와 같은 스레드에서 동기적으로 실행됨을 언급', 'ESSENTIAL', 2),
(3742, 694, '수신자가 모두 끝난 뒤에야 save()가 반환된다는 점을 언급', 'SUPPLEMENTARY', 3),
(3743, 694, '수신자에서 예외가 나면 send()가 전파해 save() 자체가 실패함을 언급', 'SUPPLEMENTARY', 4),
(3744, 694, '수신자 등록은 AppConfig.ready()에서 signals 모듈을 임포트해 이뤄짐을 언급', 'SUPPLEMENTARY', 5),

-- 질문 695
(3745, 695, 'QuerySet.update()에서는 save 시그널이 발생하지 않음을 언급', 'ESSENTIAL', 1),
(3746, 695, 'bulk_create()·bulk_update()에서는 save 시그널이 발생하지 않음을 언급', 'ESSENTIAL', 2),
(3747, 695, '원시 SQL이나 DB 직접 수정 시 시그널이 발생하지 않음을 언급', 'ESSENTIAL', 3),
(3748, 695, '시그널은 모델 변경의 완전한 훅이 아니라 반드시 실행될 규칙을 둘 수 없음을 언급', 'SUPPLEMENTARY', 4),
(3749, 695, 'loaddata(fixture)에서는 raw=True로 save 시그널이 발생함을 언급', 'SUPPLEMENTARY', 5);
