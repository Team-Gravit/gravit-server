# [PLAN-625] 금지어가 들어간 닉네임 설정 차단

> 이슈: #625
> 브랜치: feat/625-nickname-banned-word

## 목표
닉네임은 리그 랭킹, 친구 검색, 소셜 피드에서 다른 사용자에게 노출된다. 지금은 길이(2~8자)와 문자 종류(한글 음절, 영문, 숫자)만 검사하므로, 금지어가 들어간 닉네임을 온보딩과 프로필 수정 모두에서 설정할 수 없게 막는다.

범위 확장(2026-11-18): 사전이 놓친 닉네임을 치우는 사후 대응까지 넣는다. 사용자가 다른 사용자의 닉네임을 신고하고(2부 A), 관리자가 신고를 처리하며 닉네임을 기본값으로 강제 초기화한다(2부 B). 1부는 입력 단계 차단, 2부는 사후 대응이다.

## 현재 구조
- 닉네임을 쓰는 경로는 두 곳이다: `UserService.onboard` → `User.onboard`, `UserService.updateUserProfile` → `User.updateProfile`. QA용 `TestUserCheatCreateController`도 `UserService.onboard`를 거친다.
- 형식 검사는 두 겹이다: 요청 DTO(`OnboardingRequest`, `UserProfileUpdateRequest`)의 `@Size`, `@Pattern`과 `User.validateNickname`(`NICKNAME_NOT_NULL`, `NICKNAME_LENGTH_INVALID`, `NICKNAME_PATTERN_INVALID`).
- 허용 문자가 `^[가-힣a-zA-Z0-9]+$`라서 **자모(초성만 쓰기), 공백, 특수문자를 섞는 우회는 이미 형식 검사에서 막힌다.** 남는 우회는 대소문자, 숫자 끼워 넣기(`금1지`), 비슷한 음절로 바꿔 쓰기, 영문 leet(영문자를 비슷한 숫자로 바꾸기)다.
- 가입 시 `OAuthLoginProcessor.registerNewUser`가 OAuth 제공자 이름을 임시 닉네임으로 넣지만, 온보딩 전 사용자는 리그와 소셜에 노출되지 않고 온보딩에서 닉네임을 새로 정한다. 이번 범위에서 제외한다.

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/user/policy/NicknameBannedWordPolicy.java` — 기동 시 금지어 목록을 읽고, 닉네임에 금지어가 들어 있으면 `NICKNAME_BANNED_WORD`를 던진다
- `src/main/resources/policy/nickname-banned-words.txt` — 금지어 목록(한 줄에 하나, `#`으로 시작하는 줄과 빈 줄은 무시). `# 욕설, 비하`, `# 성적 표현`, `# 예약어(사칭 방지)` 구획으로 나눈다. **저장소에 커밋하지 않는다**(`.gitignore`). 운영 값은 GitHub Secret `NICKNAME_BANNED_WORDS`이고 CD가 빌드 전에 이 경로로 파일을 만든다(D1 개정)
- `src/test/resources/policy/nickname-banned-words.txt`, `nickname-allowed-words.txt` — 테스트용 샘플 목록(`금지`, `badword`, `운영자` / `금지옥엽`). 테스트 클래스패스에서 main 리소스보다 먼저 잡힌다. CI에는 실제 목록이 없으므로 이 샘플로 컨텍스트가 뜬다
- `src/main/resources/policy/nickname-allowed-words.txt` — 허용 목록. 금지어를 품었지만 정상인 단어(`애자일` 등)를 적는다
- `src/test/java/gravit/code/user/policy/NicknameBannedWordPolicyTest.java` — 판정 기준 순수 JUnit 테스트

### 수정 파일
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` — `// User` 그룹에 `NICKNAME_BANNED_WORD` 추가
- `src/main/java/gravit/code/user/service/UserService.java` — `onboard`, `updateUserProfile`에서 엔티티 변경 전에 금지어 검사
- `src/main/java/gravit/code/user/controller/docs/UserControllerDocs.java` — 온보딩, 프로필 수정 400 응답 예시에 `USER_4008` 추가
- `src/test/java/gravit/code/user/service/UserServiceIntegrationTest.java` — 온보딩, 프로필 수정 금지어 실패 케이스 추가
- `.claude/spec/service-policy/user.md` — 닉네임 규칙에 금지어 정책 추가 (**정책 변경**)
- `.gitignore` — 금지어 목록 파일 제외
- `.github/workflows/cd-dev.yml`, `cd-prod.yml` — Firebase 키 생성 단계 뒤에 `닉네임 금지어 목록 파일 생성` 단계 추가(`env`로 받은 시크릿을 `printf`로 기록)
- `.claude/spec/secret-convention.md` — "의도적으로 공유하는 값"에 `NICKNAME_BANNED_WORDS` 추가(등록 순서, 로컬 준비 방법)

## 구현 계획
1. **Entity / Flyway**: 변경 없음. 금지어 목록은 DB가 아니라 리소스 파일로 관리한다(D1).
2. **Repository**: 변경 없음.
3. **Policy** (`user/policy/NicknameBannedWordPolicy`, `@Component`)
   - 상수
     - `private static final String BANNED_WORDS_PATH = "policy/nickname-banned-words.txt";`
    - `private static final String ALLOWED_WORDS_PATH = "policy/nickname-allowed-words.txt";`
    - `private static final String ALLOWED_WORD_MASK = "*";`
     - `private static final String COMMENT_PREFIX = "#";`
     - `private static final Pattern DIGITS = Pattern.compile("[0-9]");`
   - 필드: `private final Set<String> bannedWords;`, `private final List<String> allowedWords;`(긴 단어부터 정렬)
   - 생성자: `NicknameBannedWordPolicy()` — `loadWords(BANNED_WORDS_PATH)`, `loadWords(ALLOWED_WORDS_PATH)`로 두 목록을 읽어 불변 컬렉션으로 둔다. 금지어 파일을 못 읽거나 비어 있으면 `IllegalStateException`으로 기동을 실패시킨다(목록 없이 뜨면 검사가 조용히 꺼지므로).
     - `private static List<String> loadWords(String path)` — `ClassPathResource(path).getContentAsString(UTF_8)`를 줄 단위로 나눠 `strip()`, 빈 줄과 주석 줄을 빼고 `normalize()`를 적용해 모은다.
   - `public void validate(String nickname)` — `nickname`이 null이거나 비어 있으면 그대로 반환한다(형식 오류는 엔티티가 맡는다). `String masked = maskAllowedWords(normalize(nickname));` 뒤 `containsBannedWord(masked)` 또는 `containsBannedWord(removeDigits(masked))`가 참이면 `throw new RestApiException(NICKNAME_BANNED_WORD)`.
     - `private static String normalize(String text)` — `Normalizer.normalize(text, NFKC)` 뒤 `toLowerCase(Locale.ROOT)`.
     - `private String maskAllowedWords(String text)` — 허용 단어를 긴 것부터 `ALLOWED_WORD_MASK`로 바꾼다(`애자일` → `*`). 지우지 않고 바꾸는 이유는 앞뒤 글자가 붙어 새 금지어가 생기지 않게 하려는 것이다.
     - `private static String removeDigits(String text)` — `DIGITS`를 빈 문자열로 치환(`금1지` → `금지`).
     - `private boolean containsBannedWord(String text)` — `bannedWords.stream().anyMatch(text::contains)`. 닉네임이 8자 이하이고 목록이 수백 개 수준이라 단순 순회로 충분하다.
   - Spring 컨텍스트 없이 테스트할 수 있게, 두 목록을 받는 package-private 생성자 `NicknameBannedWordPolicy(Collection<String> bannedWords, Collection<String> allowedWords)`를 둔다(받은 단어도 `normalize()` 적용).
4. **Service** (`UserService`)
   - 주입 필드에 `private final NicknameBannedWordPolicy nicknameBannedWordPolicy;` 추가(4번 종류, `handleGenerator`, `lessonRewardPolicy`와 같은 묶음).
   - `onboard(long userId, OnboardingRequest request)` — 유저 조회 뒤, `user.onboard(...)` 전에 `nicknameBannedWordPolicy.validate(request.nickname());`.
   - `updateUserProfile(long userId, UserProfileUpdateRequest request)` — 유저 조회 뒤, `user.updateProfile(...)` 전에 같은 검사.
   - 엔티티 안에 넣지 않는 이유: 목록은 리소스 파일에서 읽는 빈이라 엔티티에 주입할 수 없다. 형식 검사(길이, 문자)는 지금처럼 엔티티가 맡는다.
5. **Facade**: 불필요 — 단일 Service.
6. **DTO**: 변경 없음. 금지어는 Bean Validation이 아니라 서비스 단계에서 `RestApiException`으로 거절한다(다른 닉네임 오류와 같은 `USER_400x` 응답 형식 유지).
7. **에러 코드**: `NICKNAME_BANNED_WORD(BAD_REQUEST, "USER_4008", "사용할 수 없는 단어가 포함된 닉네임입니다.")` — `USER_RESTORE_ONLY_POSSIBLE_DELETED_STATUS_USER`(USER_4007) 다음.
8. **Controller / Docs**: 엔드포인트 변경 없음(`POST /api/v1/users/onboarding`, `PATCH /api/v1/users`). `UserControllerDocs`의 두 메서드에 `🚨 금지어 포함 닉네임` 400 응답 예시(`{"error" : "USER_4008", "message" : "사용할 수 없는 단어가 포함된 닉네임입니다."}`)를 추가한다.
9. **정책 문서** (`user.md`): 닉네임 줄 아래에 추가 — "금지어(욕설, 비하, 성적 표현)와 사칭에 쓰일 수 있는 예약어(운영자, 관리자, 서비스 이름)가 들어간 닉네임은 온보딩과 프로필 수정에서 설정할 수 없다. 대소문자를 구분하지 않고, 사이에 숫자를 끼운 표기도 금지어로 본다. 금지어를 품었지만 정상인 단어는 허용 목록으로 통과시킨다. 금지어와 허용 목록은 서버 리소스 파일로 관리하며 바꾸려면 배포가 필요하다. 이미 금지어가 들어간 기존 닉네임은 강제로 바꾸지 않지만, 프로필을 수정하려면 닉네임도 바꿔야 한다."
10. **기존 사용자 현황**: 배포 전 운영 DB에서 확인할 SQL의 형태만 PR 본문에 남긴다(`nickname ILIKE ANY(ARRAY['%단어%', ...])` 건수 조회, 단어는 시크릿 목록에서 채움). 금지어 자체는 PR에 적지 않는다. 실행은 사용자가 한다.

## 결정 필요 (Decisions needed)
> 방향(2026-11-17 합의): 100% 차단을 목표로 하지 않는다. 입력 단계에서는 흔한 욕설과 사칭 예약어를 사전 + 정규화로 확실하게 막고, 놓친 것은 사후 대응(관리자 강제 변경, 후속)으로 치운다. 2~8자 닉네임은 문맥이 없어 ML 분류 모델은 쓰지 않는다.

- [x] D1 금지어 목록 관리 방식 — **A. 서버 리소스 파일**: 단순하고 PR로 이력이 남는다. 바꾸려면 배포가 필요하다 (B. DB + 관리자 API, C. 외부 라이브러리는 버림)
  - **개정(2026-11-18)**: 저장소가 public이라 금지어 목록은 커밋하지 않는다. Firebase 키와 같은 방식으로 GitHub Secret `NICKNAME_BANNED_WORDS`에 두고 CD에서 리소스 파일로 만든다. 허용 목록은 정상 단어뿐이라 저장소에 둔다. 대가: 금지어 변경 이력이 diff로 남지 않고, 로컬 `bootRun`에는 파일을 직접 만들어야 하며, 목록을 바꿀 때마다 시크릿을 갱신한다
- [x] D2 판정 범위 — **A. 소문자 + 포함 검사 + 숫자 제거 뒤 한 번 더**, 여기에 **허용 목록**(금지어를 품은 정상 단어)을 먼저 가린다. leet 치환은 오탐이 늘어 하지 않는다
  - 2026-11-18: 초안 허용 목록에 있던 사전 단어 4개(욕설 2개, 성적 표현 2개를 품은 단어)는 허용 목록에서 뺀다. 사전에 있는 단어라도 닉네임에서는 욕설, 성적 표현을 위장하는 용도로 쓰이는 경우가 많아 막는다. 허용 목록에는 닉네임으로 쓸 이유가 분명한 정상 단어(`애자일`, `메갈로돈`, `gravity`)만 둔다
- [x] D3 초기 금지어 목록 출처 — **A. 팀이 직접 작성**: 구현 때 대표 욕설, 비하, 성적 표현 수십 개와 예약어(`운영자`, `관리자`, `admin`, `gravit`, `그래빗`)로 초안을 만들고 PR에서 검토한다. 짧고 확실한 단어 위주
- [x] D4 이미 금지어가 들어간 기존 닉네임 — **A. 현황만 확인하고 그대로 둠**: 다음 프로필 수정 때 바꾸게 된다
- [x] D5 사칭 예약어 — 금지어 파일의 별도 구획으로 같은 검사, 같은 에러 코드로 막는다

## 후속 후보
- 관리자 닉네임 강제 변경(신고 또는 운영자 판단). 사전이 놓친 표현을 치우는 마지막 안전장치이고, 걸린 표현을 금지어 목록에 다시 넣는다
- 닉네임 변경 주기 제한

## 검증
- 대상 테스트
  - `NicknameBannedWordPolicyTest`(순수 JUnit, 목록을 생성자로 주입)
    - 금지어가 그대로 들어가면 `NICKNAME_BANNED_WORD`를 던진다
    - 금지어가 닉네임 중간에 들어가도 던진다
    - 대문자로 써도 던진다(`BADWORD`)
    - 사이에 숫자를 끼워도 던진다(`금1지`)
    - 금지어가 없으면 통과한다
    - 허용 목록 단어(샘플 `금지옥엽`)는 통과한다
    - 허용 단어를 가린 뒤에도 남은 금지어가 있으면 던진다
    - 예약어(`운영자`)가 들어가면 던진다
    - null, 빈 문자열은 통과한다(형식 검사는 엔티티 몫)
  - `UserServiceIntegrationTest`
    - 온보딩: 금지어 닉네임이면 `NICKNAME_BANNED_WORD`, 온보딩 상태가 바뀌지 않는다
    - 프로필 수정: 금지어 닉네임이면 `NICKNAME_BANNED_WORD`, 닉네임이 바뀌지 않는다
  - 실제 리소스 파일이 비어 있지 않고 기동 시 읽히는지는 통합 테스트(정책 빈 주입 뒤 목록의 단어 하나로 거절 확인)로 확인한다

---

# 2부: 사용자 신고와 관리자 닉네임 초기화 (2026-11-18 범위 확장)

## 현재 구조
- 신고는 문제 신고뿐이다. `report` 테이블은 `problem_id`가 `NOT NULL`이고 `ReportType`은 콘텐츠 오류 4종이다(`ReportController.submitProblemReport`, `AdminReportController`).
- 문의(`inquiry`)는 대상 지정 없이 관리자와 주고받는 창구라 신고와 성격이 다르다.
- 관리자 사용자 관리(`AdminUserService`)는 상태와 권한 변경만 있고 닉네임을 바꾸는 기능이 없다. 변경은 `AdminUserRepository`의 네이티브 UPDATE + `AuditLogRecorder.record`로 감사 로그를 남기는 패턴이다.
- `audit_log.action`은 `CHECK` 제약(`audit_log_action_check`, V22)으로 5종만 허용한다.
- 탈퇴 7일 뒤 실제 삭제(`UserCleanDeletionSql`)는 `report`를 `user_id`로 지운다.

## 영향 범위
### 신규 파일
- `src/main/resources/db/migration/V54__add_user_report.sql` — `user_report` 테이블, 미처리 중복 방지 부분 유니크 인덱스, 대상별 미처리 조회 인덱스
- `src/main/resources/db/migration/V55__add_user_nickname_reset_audit_action.sql` — `audit_log_action_check`에 `USER_NICKNAME_RESET` 추가
- `src/main/java/gravit/code/report/domain/UserReport.java` — 사용자 신고 엔티티
- `src/main/java/gravit/code/report/domain/UserReportType.java` — `INAPPROPRIATE_NICKNAME`, `OTHER`
- `src/main/java/gravit/code/report/repository/UserReportRepository.java`
- `src/main/java/gravit/code/report/dto/request/UserReportSubmitRequest.java`
- `src/main/java/gravit/code/user/support/DefaultNicknameGenerator.java` — `유저` + 숫자 6자리
- `src/main/java/gravit/code/admin/repository/AdminUserReportRepository.java` — 관리자 목록 검색, 대상의 미처리 닉네임 신고 일괄 처리
- `src/main/java/gravit/code/admin/service/AdminUserReportService.java`
- `src/main/java/gravit/code/admin/controller/AdminUserReportController.java`, `controller/docs/AdminUserReportControllerDocs.java`
- `src/main/java/gravit/code/admin/dto/response/UserReportListItemResponse.java`
- `src/main/java/gravit/code/admin/dto/response/NicknameResetResponse.java`

### 수정 파일
- `src/main/java/gravit/code/report/service/ReportService.java` — `submitUserReport` 추가
- `src/main/java/gravit/code/report/controller/ReportController.java`, `docs/ReportControllerDocs.java` — `POST /api/v1/reports/users`
- `src/main/java/gravit/code/admin/service/AdminUserService.java` — `resetNickname` 추가
- `src/main/java/gravit/code/admin/repository/AdminUserRepository.java` — `updateNicknameById` 추가
- `src/main/java/gravit/code/admin/controller/AdminUserController.java`, `docs/AdminUserControllerDocs.java` — `PATCH /api/v1/admin/users/{userId}/nickname/reset`
- `src/main/java/gravit/code/admin/domain/audit/AuditAction.java` — `USER_NICKNAME_RESET`
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` — `// Report` 그룹에 3종
- `src/main/java/gravit/code/user/repository/sql/UserCleanDeletionSql.java` — `user_report` 삭제 CTE
- `.claude/spec/service-policy/admin-report.md` — 사용자 신고, 관리자 처리, 닉네임 초기화 정책 (**정책 추가**)
- `.claude/spec/service-policy/user.md` — 관리자 닉네임 초기화, 실제 삭제 범위에 사용자 신고 추가 (**정책 변경**)

## 구현 계획
### A. 사용자 신고
1. **Flyway** `V54__add_user_report.sql`
   ```sql
   CREATE TABLE user_report
   (
       id                BIGINT GENERATED BY DEFAULT AS IDENTITY,
       reporter_id       BIGINT       NOT NULL,
       target_user_id    BIGINT       NOT NULL,
       report_type       VARCHAR(255) NOT NULL CHECK (report_type IN ('INAPPROPRIATE_NICKNAME', 'OTHER')),
       reported_nickname VARCHAR(255) NOT NULL,
       content           TEXT,
       is_resolved       BOOLEAN      NOT NULL,
       submitted_at      TIMESTAMP(6) NOT NULL,
       PRIMARY KEY (id)
   );
   -- 같은 신고자가 같은 대상에 미처리 신고를 두 개 이상 갖지 못하게 한다(동시 요청 방어)
   CREATE UNIQUE INDEX IF NOT EXISTS ux_user_report_unresolved_pair ON user_report (reporter_id, target_user_id) WHERE is_resolved = false;
   -- 닉네임 초기화 때 대상의 미처리 신고를 찾는다
   CREATE INDEX IF NOT EXISTS ix_user_report_target_unresolved ON user_report (target_user_id) WHERE is_resolved = false;
   ```
   - FK는 두지 않는다(기존 `report`와 같음. 실제 삭제는 `UserCleanDeletionSql`이 맡는다).
2. **Entity** `UserReport`(`report/domain`, `Report`와 같은 형태)
   - 필드: `id`, `reporterId`, `targetUserId`, `reportType`(`@Enumerated(STRING)`), `reportedNickname`, `content`, `isResolved`, `submittedAt`(`LocalDateTime.now(TimeZoneConst.KST)`)
   - `public static UserReport create(long reporterId, long targetUserId, UserReportType reportType, String reportedNickname, String content)` — 생성 전에 `validateNotSelf(reporterId, targetUserId)`(같으면 `USER_REPORT_SELF_NOT_ALLOWED`)
   - `public void changeResolved(boolean isResolved)`
   - `reportedNickname`은 신고 시점 닉네임 스냅샷이다. 대상이 나중에 닉네임을 바꿔도 무엇이 신고됐는지 남는다.
3. **Enum** `UserReportType` — `INAPPROPRIATE_NICKNAME`, `OTHER`. `ReportType`과 같이 `@JsonValue`, `@JsonCreator from(String)`.
4. **Repository** `UserReportRepository extends JpaRepository<UserReport, Long>`
   - `boolean existsByReporterIdAndTargetUserIdAndIsResolvedFalse(long reporterId, long targetUserId)`
5. **Service** `ReportService.submitUserReport(long reporterId, UserReportSubmitRequest request)` (`@Transactional`)
   - 주입 추가: `UserRepository`(기존 `ProblemRepository`를 직접 쓰는 패턴과 같음)
   - 흐름: `userRepository.findById(targetUserId)`(탈퇴 사용자는 `@SQLRestriction`으로 빠져 `USER_NOT_FOUND`) → `UserReport.create(...)`(자기 신고 거절) → `existsBy...IsResolvedFalse`면 `USER_REPORT_DUPLICATED` → `saveAndFlush`. 동시 요청이 부분 유니크 인덱스에 걸리면 `DataIntegrityViolationException`을 잡아 `USER_REPORT_DUPLICATED`로 바꾼다.
6. **DTO** `UserReportSubmitRequest(Long targetUserId, String reportType, String content)`
   - `targetUserId`: `@NotNull`
   - `reportType`: `@NotBlank` + `@EnumValidation(target = UserReportType.class)`
   - `content`: 선택, `@Size(max = 500)`
7. **Controller** `ReportController` — `POST /api/v1/reports/users` → `submitUserReport(@AuthenticationPrincipal LoginUser, @Valid @RequestBody UserReportSubmitRequest)`, 응답 `200`(문제 신고와 같은 계약). 인증 필요 경로라 `SecurityConfig` 변경 없음.

### B. 관리자 처리와 닉네임 초기화
1. **Flyway** `V55__add_user_nickname_reset_audit_action.sql` — `ALTER TABLE audit_log DROP CONSTRAINT IF EXISTS audit_log_action_check;` 뒤 기존 5종 + `USER_NICKNAME_RESET`으로 다시 건다(V19, V24와 같은 방식).
2. **AuditAction** — `USER_NICKNAME_RESET` 추가.
3. **Repository** `AdminUserReportRepository extends JpaRepository<UserReport, Long>`(`admin/repository`, `AdminReportRepository`와 같은 형태)
   - `Page<UserReport> search(UserReportType reportType, Boolean isResolved, Pageable pageable)` — JPQL, `ORDER BY r.id DESC`
   - `@Modifying int resolveUnresolvedByTargetUserIdAndReportType(long targetUserId, UserReportType reportType)` — `UPDATE UserReport r SET r.isResolved = true WHERE r.targetUserId = :targetUserId AND r.reportType = :reportType AND r.isResolved = false`
4. **Repository** `AdminUserRepository.updateNicknameById(long id, String nickname)` — 네이티브 `UPDATE users SET nickname = :nickname WHERE id = :id`(`updateRoleById`와 같은 형태)
5. **Support** `DefaultNicknameGenerator`(`user/support`, `@Component`)
   - 상수 `PREFIX = "유저"`, `DIGIT_COUNT = 6`, `DIGIT_BOUND = 1_000_000`
   - `public String generate()` — `PREFIX + String.format("%06d", random.nextInt(DIGIT_BOUND))`. 8자, 형식 검사와 금지어 검사를 항상 통과한다. 닉네임은 유일할 필요가 없으므로 중복 확인은 하지 않는다.
6. **Service** `AdminUserService.resetNickname(long adminId, long userId)` (`@Transactional`) → `NicknameResetResponse`
   - 주입 추가: `AdminUserReportRepository`, `DefaultNicknameGenerator`
   - 흐름: `findRowById`(없으면 `USER_NOT_FOUND`) → `before = user.getNickname()` → `generate()` → `updateNicknameById` → `resolveUnresolvedByTargetUserIdAndReportType(userId, INAPPROPRIATE_NICKNAME)` → `auditLogRecorder.record(adminId, USER_NICKNAME_RESET, userId, before, after)` → `NicknameResetResponse.of(userId, after)`
   - 닉네임 신고만 자동 처리한다. `OTHER` 신고는 닉네임과 다른 사유일 수 있어 관리자가 따로 처리한다.
7. **Service** `AdminUserReportService`
   - `getUserReports(int page, UserReportType reportType, Boolean isResolved)` (`readOnly`) → `PageResponse<UserReportListItemResponse>`
   - `updateResolved(long reportId, boolean isResolved)` — 없으면 `USER_REPORT_NOT_FOUND`. 미처리로 되돌릴 때 같은 쌍의 미처리 신고가 이미 있으면 인덱스에 걸리므로 `saveAndFlush` 뒤 `DataIntegrityViolationException`을 `USER_REPORT_DUPLICATED`로 바꾼다.
8. **DTO**
   - `UserReportListItemResponse` — `reportId`, `reporterId`, `targetUserId`, `reportType`, `reportedNickname`, `content`, `isResolved`, `submittedAt`. `from(UserReport)`
   - `NicknameResetResponse` — `userId`, `nickname`(초기화로 확정된 새 닉네임). `of(...)`
   - 처리 상태 변경 요청은 기존 `ReportStatusUpdateRequest`를 재사용한다.
9. **Controller**
   - `AdminUserReportController`(`/api/v1/admin/user-reports`): `GET`(page, reportType, isResolved) → `getUserReports`, `PATCH /{reportId}/status` → `updateStatus`
   - `AdminUserController`: `PATCH /{userId}/nickname/reset` → `resetNickname(@AuthenticationPrincipal LoginUser, userId)`, 응답 `200` + `NicknameResetResponse`
   - `/api/v1/admin/**`는 이미 `hasRole("ADMIN")`이라 보안 설정 변경 없음.
10. **에러 코드** (`// Report` 그룹)
    - `USER_REPORT_SELF_NOT_ALLOWED(BAD_REQUEST, "REPORT_4002", "자기 자신은 신고할 수 없습니다.")`
    - `USER_REPORT_NOT_FOUND(NOT_FOUND, "REPORT_4042", "사용자 신고 조회에 실패하였습니다.")`
    - `USER_REPORT_DUPLICATED(CONFLICT, "REPORT_4091", "이미 처리를 기다리는 신고가 있습니다.")`
11. **실제 삭제** `UserCleanDeletionSql` — `d_report` 옆에 `d_user_report AS (DELETE FROM user_report WHERE reporter_id = :id OR target_user_id = :id)`
12. **정책 문서**
    - `admin-report.md`: 사용자 신고는 로그인한 사용자가 다른 활성 사용자에 대해 할 수 있다. 사유는 부적절한 닉네임과 기타 두 가지이고 상세 내용은 선택이다(500자 이하). 자기 자신은 신고할 수 없다. 같은 대상에 처리되지 않은 내 신고가 있으면 다시 신고할 수 없고, 처리된 뒤에는 다시 할 수 있다. 신고에는 신고 시점의 닉네임이 함께 남는다. 관리자는 사용자 신고 목록을 사유와 처리 여부로 걸러 보고 처리 여부를 바꿀 수 있다.
    - `admin-report.md` + `user.md`: 관리자는 사용자의 닉네임을 `유저` + 숫자 6자리 기본 닉네임으로 초기화할 수 있다. 초기화하면 그 사용자에게 걸린 처리되지 않은 닉네임 신고가 모두 처리 완료가 되고, 감사 로그에 이전과 이후 닉네임이 남는다. 사용자에게 알림은 보내지 않는다(후속).
    - `user.md` 실제 삭제 범위: 보낸 사용자 신고와 받은 사용자 신고를 함께 지운다.

## 결정 (2026-11-18 확정)
- [x] D6 사용자 신고 저장소 — 기존 `report`를 넓히지 않고 새 `user_report` 테이블. 기존 문제 신고 API와 관리자 화면을 건드리지 않는다
- [x] D7 신고 사유 — `INAPPROPRIATE_NICKNAME`, `OTHER`. 상세 내용은 선택
- [x] D8 중복 신고 — 같은 신고자, 같은 대상의 미처리 신고가 있으면 409. 처리 뒤에는 다시 신고 가능. 동시 요청은 부분 유니크 인덱스로 막는다
- [x] D9 관리자 강제 변경 — `유저` + 숫자 6자리 기본 닉네임으로 초기화(관리자 입력 없음)
- [x] D10 사용자 알림 — 이번에는 보내지 않는다. 새 알림 종류는 앱 업데이트가 필요해 프론트 일정과 함께 후속
- [x] 기본값(구조): 신고 시점 닉네임 스냅샷 저장, 자기 신고와 탈퇴 사용자 신고 불가, 초기화 시 대상의 미처리 닉네임 신고 자동 처리, 초기화는 감사 로그 기록, 실제 삭제 때 보낸 신고와 받은 신고 삭제

## 후속 후보 (2부)
- 닉네임 초기화 알림(`NICKNAME_RESET`, 인앱 + 푸시). 앱의 알림 종류 처리와 함께
- 정지(`SUSPENDED`) 상태가 로그인과 API를 실제로 막지 않음. 별도 이슈
- 신고 누적 수로 관리자 목록 정렬, 신고 대상별 묶어 보기
- #626 사용자 차단과 신고 진입 화면 통합

## 프론트 영향
- 앱: 리그 랭킹, 친구 검색, 프로필 화면에 신고 진입점과 `POST /api/v1/reports/users` 호출, 409 `REPORT_4091` 안내 문구
- 관리자 웹: 사용자 신고 목록과 처리, 사용자 상세의 닉네임 초기화 버튼

## 검증 (2부)
- `ReportService` 통합 테스트: 신고 저장과 닉네임 스냅샷, 자기 신고 `USER_REPORT_SELF_NOT_ALLOWED`, 탈퇴 또는 없는 대상 `USER_NOT_FOUND`, 미처리 중복 `USER_REPORT_DUPLICATED`, 처리된 뒤 재신고 성공
- `AdminUserService` 통합 테스트: 초기화 뒤 닉네임이 `^유저[0-9]{6}$`, 대상의 미처리 닉네임 신고만 처리 완료(`OTHER`와 다른 대상은 그대로), 감사 로그 before/after, 없는 사용자 `USER_NOT_FOUND`
- `AdminUserReportService` 통합 테스트: 사유와 처리 여부 필터, 처리 상태 변경, 없는 신고 `USER_REPORT_NOT_FOUND`
- `UserDeletion` 실제 삭제 테스트: 보낸 신고와 받은 신고가 함께 지워진다
- Flyway: 새 마이그레이션이 테스트 컨테이너에서 적용되고 `flywayValidate`(빌드) 통과

## Deviation Log
- `NicknameBannedWordPolicy.validate`: 허용 단어 가리기를 숫자 제거 뒤에도 한 번 더 적용(`containsBannedWord(maskAllowedWords(removeDigits(normalized)))`) — 이유: 계획대로 가린 뒤 숫자를 빼면 `금1지옥엽`이 `금지옥엽`이 되며 `금지`로 거절된다. 허용 단어에 숫자를 끼운 표기도 허용 단어로 본다
- `NicknameBannedWordPolicy`: 금지어가 비었는지 검사를 package-private 생성자로 옮김 — 이유: 리소스 생성자와 테스트 생성자가 같은 경로를 타게 해, 빈 목록으로 검사가 꺼지는 경우를 한 곳에서 막는다
- `DefaultNicknameGenerator`: 상수 `DIGIT_COUNT` 대신 `DIGIT_FORMAT = "%06d"`, 난수는 `SecureRandom` — 이유: 자릿수는 형식 문자열 하나로 정해지고, 기본 닉네임이 예측되지 않게 한다
- 검증 메모: 테스트 프로필은 Flyway를 끄고 Hibernate `ddl-auto: create`로 테이블을 만든다. V54 부분 유니크 인덱스와 V55 제약 변경은 테스트에서 실행되지 않는다. 동시 중복 신고 방어와 미처리 되돌리기 409는 실제 PostgreSQL에서 따로 확인해야 한다
