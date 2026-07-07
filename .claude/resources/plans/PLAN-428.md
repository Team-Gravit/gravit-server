# [PLAN-428] V25 마이그레이션 배포 실패 수정 (알림 타입 제약 위반)

> 이슈: #428
> 브랜치: hotfix/428-notification-type-check

## 목표
V25가 `ck_notification_type`에서 `VERSION`을 제거하기 전에 기존 `type = 'VERSION'` 알림 행을 정리하도록 보완하여, `ADD CONSTRAINT` 시 `23514`(check violation)로 Flyway migrate가 실패하고 애플리케이션 기동이 중단되는 문제를 해소한다. dev 배포를 복구하고, 동일 데이터를 가진 향후 환경(prod 승격 포함)에서도 재발하지 않게 한다.

## 실측 데이터 (dev DB, 2026-07-07 확인)
- `notification` 전체 23건 중 `type = 'VERSION'`은 **2건**: `id=11`(user_id 100007), `id=19`(user_id 100000). 둘 다 `target_id` NULL.
- 나머지 21건은 전부 신규 허용 목록 내 타입 → **유일한 제약 위반 값은 `VERSION`**. `NOT IN` 방어 삭제가 불필요함을 실측으로 확인. `DELETE ... WHERE type='VERSION'`은 id 11·19만 삭제하고 나머지는 보존한다.

## 배경 / 제약 (중요)
- **왜 V25를 직접 고쳐야 하는가**: 실패하는 문장이 V25 내부의 `ADD CONSTRAINT`이고, Flyway는 버전 순서대로 실행하므로 V25가 통과하지 못하면 이후 어떤 신규 마이그레이션(V27+)도 실행되지 않는다. 즉 "새 마이그레이션 추가"로는 이 실패를 우회할 수 없고, **V25 자체가 성공하도록 만들어야 한다**.
- **마이그레이션 규칙과의 충돌**: `.claude/rules/migration.md`는 "적용된 파일은 절대 수정하지 마라(checksum 실패)"이다. 그러나 dev DB에서 V25는 **성공한 적이 없다** — PostgreSQL은 DDL 트랜잭션을 지원하므로 실패한 마이그레이션은 스키마 히스토리 삽입까지 함께 롤백되어 dev 히스토리의 최신 성공 버전은 V24이다. 따라서 dev 기준으로는 V25를 편집해도 checksum 충돌이 없다(수정된 V25가 pending 상태로 재실행됨).
- **로컬/기타 환경 주의**: VERSION 행이 없던 로컬 DB에서는 기존 V25가 이미 성공했을 수 있고, 그 경우 편집 시 checksum 불일치가 발생한다 → `./gradlew flywayRepair`(또는 Flyway repair)로 checksum 재정렬 필요. CI 통합테스트(Testcontainers)는 매번 신규 DB라 영향 없음.

## 영향 범위
### 신규 파일
- 없음

### 수정 파일
- `src/main/resources/db/migration/V25__notification_subtext_and_remove_version_type.sql` — `DROP CONSTRAINT`와 `ADD CONSTRAINT` 사이에, 제거 대상인 `type = 'VERSION'` 행을 정리하는 문장을 추가한다. `sub_text` 컬럼 추가 및 새 허용 목록 자체는 변경하지 않는다.

## 구현 계획
> 마이그레이션 단독 수정. 애플리케이션 레이어(Repository/Service/Facade/DTO/Controller) 변경 없음.

1. **Flyway (V25 편집)**: 아래 순서가 되도록 constraint 블록을 보완한다.
   ```sql
   -- 미사용 VERSION 타입 제거 (기획에서 삭제된 항목)
   ALTER TABLE notification DROP CONSTRAINT IF EXISTS ck_notification_type;

   -- 제거된 VERSION 타입의 기존 알림 행 정리 (신규 제약 추가 전 위반 행 제거)
   DELETE FROM notification WHERE type = 'VERSION';

   ALTER TABLE notification ADD CONSTRAINT ck_notification_type CHECK (
       type IN (
           'CONSECUTIVE_LEARNING_WARNING', 'DAILY_INCOMPLETE', 'INACTIVITY', 'SEASON_ENDING',
           'SEASON_RESET', 'FOLLOW', 'CONGRATULATION', 'FRIEND_ACTIVITY',
           'NOTICE', 'NEW_CONTENT', 'INQUIRY_ANSWERED'
       )
   );
   ```
   - `VERSION`은 V15~V24까지만 허용되던 값이며(구 `STREAK_WARNING`은 V18에서 이미 `CONSECUTIVE_LEARNING_WARNING`으로 이관됨), 신규 목록에서 유일하게 빠진 값이므로 정리 대상은 `VERSION`으로 특정된다.
   - 파일 상단 주석의 "실제 생성 이력 없음" 문구는 사실과 달랐으므로 제거/수정한다.
2. **Repository / Service / Facade / DTO / Controller**: 변경 없음. `NotificationType` enum에는 이미 `VERSION`이 없어 코드-스키마 정합성은 유지된다.

## 결정 필요 (Decisions needed)
- [x] **V25 직접 편집 승인** — (A) V25를 편집해 정리 단계 추가 **← 확정**. 유일하게 실효성 있는 코드 수정, dev는 롤백 상태라 재실행으로 해결, 로컬은 `flywayRepair`로 커버.
- [x] **VERSION 행 처리 방식** — (A) `DELETE` **← 확정**. VERSION은 제거된 기능이라 이관할 대상 타입이 없음.
- [x] **정리 범위** — (A) `type = 'VERSION'`만 정확히 삭제 **← 확정**. 유일한 위반 값이 VERSION으로 특정됨.

## 검증
- **빌드/검증**: `./gradlew build`(flyway validate 포함) 통과. 로컬에서 기존 V25가 성공 상태였다면 checksum 불일치가 나므로 `./gradlew flywayRepair` 후 재빌드.
- **통합 테스트**: Testcontainers 기반 알림 통합 테스트(`NotificationServiceIntegrationTest`, `NotificationQueryServiceIntegrationTest`, `NotificationFacadeIntegrationTest` 등)가 신규 DB에서 V25 포함 전체 마이그레이션을 적용하며 그대로 통과하는지 확인.
- **재배포 검증(dev)**: 수정된 V25 반영 후 dev 재배포 → Flyway가 V25(재실행)·V26를 정상 적용하고 애플리케이션이 기동되는지 확인. VERSION 행이 삭제되고 나머지 알림은 보존되는지 확인.

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
