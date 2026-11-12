-- Unit: 마이그레이션 (Unit ID: 136)
-- Chapter: Django (Chapter ID: 12)
-- Topic: DJANGO
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-django-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(676, 'DJANGO', 136, 'HARD', true,
 '운영 중인 서비스에서 롤링 배포로 Django 모델의 컬럼 이름을 바꿔야 한다면 어떤 순서로 진행하시겠어요? RenameField를 바로 쓰면 안 되는 이유와 함께 설명해 주세요.',
 '롤링 배포 중에는 구버전 코드와 신버전 코드가 같은 DB를 동시에 사용하기 때문에, 마이그레이션은 양쪽 코드 모두와 호환되는 상태만 만들어야 합니다. RenameField는 SQL 한 줄(ALTER ... RENAME)이라 편해 보이지만, 실행되는 순간 구버전 코드는 옛 이름을, 신버전 코드는 새 이름을 찾기 때문에 어느 쪽이든 반드시 오류가 납니다. 그래서 무중단으로 이름을 바꾸려면 다섯 단계로 나눕니다. 첫째, 새 컬럼을 nullable로 추가하는 마이그레이션을 실행합니다. 둘째, 쓰기 시 구·신 컬럼에 모두 기록하고 읽기는 구 컬럼에서 하는 코드를 배포합니다. 셋째, 기존 데이터를 배치로 백필합니다. 넷째, 읽기를 신 컬럼으로 전환하고 구 컬럼 쓰기를 중단하는 코드를 배포합니다. 다섯째, 구 컬럼을 삭제하는 마이그레이션을 실행합니다. 이렇게 먼저 확장하고 나중에 수축하는 방식을 확장·수축(Expand & Contract) 패턴이라고 합니다. 이때 수백만 행 백필을 마이그레이션 안에서 돌리면 배포 파이프라인이 오래 멈추고 락과 WAL이 폭증하므로, 대형 백필은 관리 명령(management command)으로 분리해 배치·재시도가 가능하게 만듭니다.',
 'interview-question/676.mp3'),
(677, 'DJANGO', 136, 'NORMAL', true,
 '컬럼을 추가할 때와 삭제할 때 마이그레이션과 코드 배포의 순서가 서로 다른데, 각각 어떤 순서로 진행하고 왜 그런지 설명해 주세요.',
 '롤링 배포 중에는 구버전 코드와 신버전 코드가 같은 DB를 동시에 쓰므로, 변경 종류에 따라 순서가 달라집니다. 컬럼을 추가할 때는 마이그레이션을 먼저 실행하고 그 다음 코드를 배포합니다. Django는 컬럼을 명시적으로 나열해 조회하기 때문에 구버전 코드는 모델에 없는 새 컬럼을 SELECT하지 않고, 따라서 컬럼이 먼저 생겨도 구코드는 문제없이 동작합니다. 이때 새 컬럼은 nullable로 추가하거나 db_default를 지정해 구코드와 호환되게 합니다. 반대로 컬럼을 삭제할 때는 코드에서 해당 컬럼 참조를 제거한 버전을 먼저 배포하고, 그 후에 RemoveField 마이그레이션을 실행합니다. 컬럼을 먼저 삭제하면 아직 살아 있는 구버전 코드가 삭제된 컬럼을 계속 SELECT하므로 오류가 나기 때문입니다. 정리하면 추가는 먼저, 삭제는 나중입니다.',
 'interview-question/677.mp3'),
(678, 'DJANGO', 136, 'NORMAL', true,
 'Django 마이그레이션이 중간에 실패했을 때 PostgreSQL과 MySQL에서 결과가 어떻게 다른지, 그리고 이 차이 때문에 마이그레이션 파일을 어떻게 작성하는 것이 안전한지 설명해 주세요.',
 'PostgreSQL과 SQLite는 DDL이 트랜잭션에 포함되므로 마이그레이션 하나가 원자적으로 실행되고, 중간에 실패하면 전체가 롤백됩니다. 반면 MySQL과 Oracle은 DDL이 암묵적 커밋을 유발하기 때문에 트랜잭션 롤백이 불가능해, 중간에 실패하면 절반만 적용된 상태가 남을 수 있습니다. 그래서 특히 MySQL에서는 한 파일에 여러 스키마 변경을 넣지 않고 마이그레이션을 작게 나누는 것이 안전합니다. 참고로 마이그레이션 클래스에 atomic = False를 지정하면 트랜잭션 없이 실행되는데, 이는 PostgreSQL의 CREATE INDEX CONCURRENTLY처럼 트랜잭션 안에서 실행할 수 없는 작업에 필요합니다.',
 'interview-question/678.mp3'),
(679, 'DJANGO', 136, 'EASY', true,
 'Django에서 makemigrations와 migrate는 각각 어떤 역할을 하며, 어떤 마이그레이션이 이미 적용됐는지는 어떻게 추적하나요?',
 'makemigrations는 마이그레이션 파일들을 순서대로 재생해 계산한 모델 상태와 현재 models.py를 비교하고, 그 차이를 operations로 기록한 새 마이그레이션 파일을 생성합니다. migrate는 아직 적용되지 않은 마이그레이션 파일을 dependencies로 정의된 의존성 순서에 따라 실행해 DB 스키마를 변경합니다. 적용 여부는 DB의 django_migrations 테이블로 추적하며, migrate가 실행될 때마다 이 테이블에 행이 추가됩니다. 파일은 있는데 테이블에 기록이 없으면 미적용으로 판단해 그것만 실행합니다. 실무에서는 CI에 makemigrations --check를 넣어 모델은 바꿨는데 마이그레이션을 커밋하지 않은 사고를 감지하고, 배포 전 sqlmigrate로 실제 실행될 SQL을 확인해 테이블 재작성이나 락 여부를 검토합니다.',
 'interview-question/679.mp3'),
(680, 'DJANGO', 136, 'EASY', true,
 'RunPython으로 데이터 마이그레이션을 작성할 때 모델을 직접 import하지 않고 apps.get_model()을 사용해야 하는 이유는 무엇인가요?',
 'RunPython은 스키마가 아니라 백필, 코드값 변환, 기본 행 삽입처럼 데이터 자체를 변환해야 할 때 사용합니다. 이때 apps.get_model()을 쓰면 해당 마이그레이션 시점의 모델 상태, 즉 이력 모델(historical model)을 사용하게 됩니다. 반대로 from accounts.models import User처럼 직접 import하면 현재 코드의 모델이 실행되기 때문에, 나중에 추가된 그 시점에 없는 필드를 참조하다 실패하거나 사용자 정의 메서드·시그널이 예기치 않게 동작할 수 있습니다. 이력 모델에는 사용자 정의 메서드, save() 오버라이드, 시그널이 없어서 순수 필드 조작만 가능합니다. 또 RunPython의 두 번째 인자인 역방향 함수를 주지 않으면 되돌리기가 불가능하므로, 되돌릴 게 없다면 RunPython.noop을 명시합니다. 그리고 스키마 마이그레이션과 데이터 마이그레이션은 파일을 분리해야 실패 시 복구가 쉽습니다.',
 'interview-question/680.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 676
(3647, 676, '롤링 배포 중에는 구버전 코드와 신버전 코드가 같은 DB를 동시에 사용함을 언급', 'ESSENTIAL', 1),
(3648, 676, 'RenameField 실행 순간 구버전 코드는 옛 이름을, 신버전 코드는 새 이름을 찾아 오류가 남을 설명', 'ESSENTIAL', 2),
(3649, 676, '새 컬럼 추가 → 이중 쓰기 → 백필 → 읽기 전환 → 구 컬럼 삭제의 5단계 순서를 제시', 'ESSENTIAL', 3),
(3650, 676, '이 방식을 확장·수축(Expand & Contract) 패턴이라는 이름으로 언급', 'SUPPLEMENTARY', 4),
(3651, 676, '대형 백필은 마이그레이션 대신 관리 명령(management command)으로 분리함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 677
(3652, 677, '컬럼 추가 시에는 마이그레이션을 코드 배포보다 먼저 실행함을 언급', 'ESSENTIAL', 1),
(3653, 677, '구버전 코드는 모델에 없는 컬럼을 SELECT하지 않아 컬럼 추가가 안전함을 설명', 'ESSENTIAL', 2),
(3654, 677, '컬럼 삭제 시에는 코드에서 참조를 없앤 배포 후에 마이그레이션을 실행함을 언급', 'ESSENTIAL', 3),
(3655, 677, '먼저 삭제하면 구버전 코드가 삭제된 컬럼을 계속 SELECT해 실패한다는 이유를 제시', 'ESSENTIAL', 4),
(3656, 677, '새 컬럼은 nullable 또는 db_default로 추가해야 구버전 코드와 호환됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 678
(3657, 678, 'PostgreSQL은 DDL이 트랜잭션에 포함되어 중간 실패 시 전체 롤백됨을 언급', 'ESSENTIAL', 1),
(3658, 678, 'MySQL은 DDL이 암묵적 커밋을 유발해 절반만 적용된 상태가 남을 수 있음을 설명', 'ESSENTIAL', 2),
(3659, 678, '한 파일에 여러 스키마 변경을 넣지 않고 마이그레이션을 작게 나눠야 함을 제시', 'ESSENTIAL', 3),
(3660, 678, 'CREATE INDEX CONCURRENTLY처럼 트랜잭션 안에서 불가능한 작업에는 atomic = False를 지정함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 679
(3661, 679, 'makemigrations가 모델 변경을 감지해 마이그레이션 파일을 생성함을 설명', 'ESSENTIAL', 1),
(3662, 679, 'migrate가 미적용 마이그레이션을 의존성 순서로 실행함을 설명', 'ESSENTIAL', 2),
(3663, 679, '마이그레이션 적용 여부를 DB의 django_migrations 테이블로 추적함을 언급', 'ESSENTIAL', 3),
(3664, 679, 'makemigrations --check를 CI에 넣어 마이그레이션 커밋 누락을 감지함을 언급', 'SUPPLEMENTARY', 4),
(3665, 679, '배포 전 sqlmigrate로 실제 실행될 SQL을 확인함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 680
(3666, 680, 'apps.get_model()은 해당 마이그레이션 시점의 모델 상태를 사용함을 설명', 'ESSENTIAL', 1),
(3667, 680, '직접 import하면 현재 코드의 모델이 실행돼 그 시점에 없는 필드를 참조할 수 있음을 설명', 'ESSENTIAL', 2),
(3668, 680, 'RunPython은 스키마가 아닌 데이터 자체를 변환할 때 사용함을 언급', 'SUPPLEMENTARY', 3),
(3669, 680, '이력 모델에는 사용자 정의 메서드·save() 오버라이드·시그널이 없음을 언급', 'SUPPLEMENTARY', 4),
(3670, 680, '되돌릴 작업이 없으면 역방향 함수로 RunPython.noop을 지정해야 함을 언급', 'SUPPLEMENTARY', 5);
