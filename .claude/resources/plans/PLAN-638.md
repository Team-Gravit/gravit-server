# [PLAN-638] 디스코드 서비스 지표 리포트와 현황 조회

> 이슈: #638
> 브랜치: feat/638-discord-service-metrics

## 목표
가입, DAU, MAU, 레슨, 면접, 신고·문의 지표를 매일 09:00과 매주 월요일에 디스코드 전용 채널로 조용히(무음) 보내고, PM이 원할 때 `/현황` 슬래시 커맨드로 본인만 보는 응답을 받게 한다. 집계 코드는 후속 자연어 `/질문`의 도구로 재사용한다.

## 설계 요약

```
[정기]  MetricReportScheduler ─→ MetricReportService ─→ ServiceMetricQueryService ─→ ServiceMetricRepository(JDBC)
                                        │                                          └→ AdminUserRepository, AdminReportRepository (재사용)
                                        └→ DiscordReportMessageFactory ─→ DiscordWebhookClient ─→ 디스코드 웹훅 (flags=SUPPRESS_NOTIFICATIONS)

[조회]  디스코드 ─POST→ DiscordInteractionController ─→ DiscordInteractionService
                                                         ├ DiscordSignatureVerifier (Ed25519)
                                                         ├ 권한 확인 (채널, 역할)
                                                         ├ ServiceMetricQueryService
                                                         └ DiscordReportMessageFactory ─→ HTTP 응답 본문 (flags=EPHEMERAL)
```

- 패키지는 새 도메인 `metricReport/`로 둔다. 어드민 웹 API가 아니고(디스코드 엔드포인트, 스케줄러, 외부 연동, 설정을 함께 가짐) 후속 `/질문`도 여기에 붙는다. 다른 도메인 테이블 조회는 어드민 패키지처럼 읽기 전용 쿼리로만 한다.
- 디스코드 애플리케이션은 Interactions Endpoint URL을 하나만 가질 수 있다. dev와 prod는 **디스코드 애플리케이션을 따로 만든다**(공개키, 웹훅, 채널이 모두 환경별).
- 상시 연결(Gateway) 봇 프로세스와 봇 토큰은 서버에 두지 않는다.

## 지표 정의

기간은 KST 날짜 구간 `[startDate, endDate]`이고, 시각 컬럼은 `[startDate 00:00, endDate+1 00:00)`로 비교한다.

| 기간(`MetricPeriod`) | 현재 구간 | 비교 구간 |
|---|---|---|
| `TODAY` 오늘 | 오늘 ~ 오늘(진행 중) | 없음 (부분 집계라 비교하지 않음) |
| `YESTERDAY` 어제 (일간 리포트) | 어제 | 그저께 |
| `LAST_7_DAYS` 최근 7일 | 어제 포함 7일 | 그 직전 7일 |
| `LAST_30_DAYS` 최근 30일 | 어제 포함 30일 | 그 직전 30일 |
| `LAST_WEEK` 지난주 (주간 리포트) | 지난주 월~일 | 그 전주 월~일 |

| 지표 | 정의 | 비교 표시 |
|---|---|---|
| 총 가입자 | 조회 시점에 탈퇴 상태가 아닌 계정 수 (`AdminUserRepository.countActiveUsers` 재사용) | 없음 (현재값) |
| 신규 가입 | 구간 안에 `users.created_at`이 있는 계정 수. 탈퇴 상태 포함, 실제 삭제된 계정은 남아 있지 않아 빠짐 | ▲▼ |
| 평균 DAU | 구간의 `user_daily_activity` 행 수 / 구간 일수 (하루 구간이면 그날 DAU) | ▲▼ |
| 기간 활성 사용자 | 구간 안에 활성 이력이 있는 서로 다른 사용자 수 (하루 구간이면 생략) | ▲▼ |
| MAU | 구간 종료일이 속한 달력 월의 1일 ~ 종료일 활성 사용자 수. 월말이 아니면 "진행 중" 표시 (`admin-report.md` 정의와 같음) | 없음 |
| D1 재방문율 | 코호트 = `[startDate-1, endDate-1]`에 가입한 계정. 그중 가입 1일 뒤(달력 날짜, KST) 그날 활성 이력이 있는 비율 (Classic N-day retention). 비율 옆에 `(재방문/코호트 인원)` 표시. 코호트 0명이면 `- (가입자 없음)` | ▲▼ (%p) |
| D7 재방문율 | 코호트 = `[startDate-7, endDate-7]`에 가입한 계정. 그중 가입 7일 뒤 그날 활성 이력이 있는 비율. 표시 규칙은 D1과 같음 | ▲▼ (%p) |
| 레슨 제출 수 / 학습자 수 / 평균 정답률 | 구간 안 `lesson_submission.created_at` 기준 행 수, 서로 다른 user 수, `accuracy` 평균 | ▲▼ (정답률은 %p) |
| 면접 시작 / 제출 / 채점된 답변 | 시작: `interview_session.started_at`이 구간 안. 제출: `ended_at`이 구간 안이고 상태가 `ABANDONED`가 아님. 채점된 답변: `interview_feedback.created_at`이 구간 안 | ▲▼ |
| 신고 | 구간 안 `report.submitted_at` 유형별 건수, 현재 미처리 총 건수, 신규 목록(유형, 문제 id) 최근순 최대 N건 | 없음 |
| 문의 | 구간 안 `inquiry.created_at` 유형별 건수, 현재 `PENDING` 총 건수, 신규 목록(유형, 제목) 최근순 최대 N건 | 없음 |

- 목록에는 신고 내용, 문의 내용, 작성자를 넣지 않는다. 문의 제목은 50자에서 자르고 `…`를 붙인다.
- `TODAY`의 D1, D7은 재방문 판정일이 오늘(진행 중)이므로 부분 값임을 표시한다.
- 활성 기준은 `user.md`(인증된 요청이면 활성)를 그대로 따르므로 "접속 리텐션"이다. 핵심 행동(레슨 제출) 기준 리텐션은 후속으로 검토한다.

## 영향 범위
### 신규 파일
`src/main/java/gravit/code/metricReport/` 아래
- `config/DiscordProps.java` — `discord.*` 설정 record
- `domain/MetricPeriod.java` — 기간 enum과 구간 계산
- `dto/internal/MetricRangeDto.java` — 날짜 구간
- `dto/internal/UserMetricDto.java`, `LessonMetricDto.java`, `InterviewMetricDto.java`, `RetentionDto.java` — 영역별 집계
- `dto/internal/TypeCountDto.java`, `ReportItemDto.java`, `InquiryItemDto.java`, `ReportInquiryMetricDto.java` — 신고·문의 집계와 목록
- `dto/internal/ServiceMetricSnapshotDto.java`, `ServiceMetricReportDto.java` — 구간 스냅샷과 리포트 전체
- `dto/internal/DiscordMessageDto.java`, `DiscordEmbedDto.java`, `DiscordEmbedFieldDto.java`, `DiscordEmbedFooterDto.java`, `DiscordActionRowDto.java`, `DiscordButtonDto.java` — 디스코드 메시지 payload
- `dto/internal/DiscordInteractionDto.java`, `DiscordInteractionDataDto.java`, `DiscordInteractionOptionDto.java`, `DiscordMemberDto.java`, `DiscordInteractionResponseDto.java` — 디스코드 인터랙션 요청, 응답 payload
- `repository/custom/ServiceMetricRepository.java`, `ServiceMetricRepositoryImpl.java` — 지표 집계 JDBC 조회
- `repository/sql/ServiceMetricSql.java` — 집계 SQL 상수
- `service/ServiceMetricQueryService.java` — 기간별 리포트 집계
- `service/MetricReportService.java` — 정기 리포트 생성과 전송
- `service/DiscordInteractionService.java` — 인터랙션 검증, 권한, 분기
- `support/DiscordReportMessageFactory.java` — 리포트 → 디스코드 메시지 변환
- `infrastructure/DiscordWebhookClient.java` — 웹훅 전송
- `infrastructure/DiscordSignatureVerifier.java` — Ed25519 서명 검증
- `scheduler/MetricReportScheduler.java` — 일간, 주간 스케줄
- `controller/DiscordInteractionController.java`, `controller/docs/DiscordInteractionControllerDocs.java`

기타
- `infra/discord/commands.json` — `/현황` 슬래시 커맨드 정의 (디스코드 등록 API 본문 형식 그대로)
- `.github/workflows/register-discord-commands.yml` — 커맨드 정의가 바뀌면 디스코드에 등록 (결정 2)
- `.claude/spec/service-policy/metric-report.md` — 지표 정의, 기간, 공개 범위 정책

테스트
- `src/test/java/gravit/code/metricReport/domain/MetricPeriodTest.java`
- `src/test/java/gravit/code/metricReport/support/DiscordReportMessageFactoryTest.java`
- `src/test/java/gravit/code/metricReport/infrastructure/DiscordSignatureVerifierTest.java`
- `src/test/java/gravit/code/metricReport/service/ServiceMetricQueryServiceIntegrationTest.java`
- `src/test/java/gravit/code/metricReport/service/MetricReportServiceIntegrationTest.java`
- `src/test/java/gravit/code/metricReport/controller/DiscordInteractionControllerIntegrationTest.java`
- `src/test/java/gravit/code/metricReport/fixture/MetricFixture.java` — 가입 시각, 활성 이력, 제출, 면접, 신고, 문의 저장형 fixture
- `src/test/java/gravit/code/metricReport/fixture/DiscordTestKey.java` — 테스트용 Ed25519 키쌍(개인키 hex)과 서명 헬퍼

### 수정 파일
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` — `// Discord` 그룹에 에러코드 3개 추가
- `src/main/java/gravit/code/security/config/SecurityConfig.java` — `POST /api/v1/discord/interactions` permitAll
- `src/main/java/gravit/code/security/filter/JwtAuthFilter.java` — `EXCLUDE_ENDPOINTS`에 `/* discord */ HttpEndpoint.exact("/api/v1/discord/interactions", HttpMethod.POST)`
- `src/main/resources/application-dev.yml`, `application-prod.yml` — `discord.*` 설정 블록, `springdoc.paths-to-exclude`에 `/api/v1/discord/**` 추가
- `src/test/resources/application-test.yml` — `discord.*` 테스트 값(테스트 공개키, 허용 채널·역할 id, 정기 리포트 off)
- `.github/workflows/cd-dev.yml`, `cd-prod.yml` — `discord.public-key`, `discord.report-webhook-url` 시크릿 주입
- `.claude/spec/secret-convention.md` — 환경별 분리 표에 디스코드 시크릿 5종(공개키, 리포트 웹훅, 봇 토큰, 애플리케이션 id, 길드 id), 디스코드 애플리케이션 생성과 커맨드 등록 절차. 봇 토큰은 등록 워크플로만 쓰고 서버에는 주입하지 않음을 명시
- `.claude/spec/service-policy/README.md` — `metric-report.md` 행 추가
- `.claude/rules/project-structure.md` — `metricReport/` 패키지 한 줄 추가
- `.claude/rules/api-docs-convention.md` — 적용 범위에 "디스코드 인터랙션(`/api/v1/discord/**`)은 외부 웹훅 계약이라 Swagger에서 빠진다. Docs는 `@Tag`만 필수" 한 줄 추가

## 구현 계획

1. **Entity / Flyway**: 변경 없음. 기존 테이블 읽기 전용 집계만 한다.

2. **Config**
   - `DiscordProps` — `@ConfigurationProperties(prefix = "discord")`
     ```java
     public record DiscordProps(
             boolean reportEnabled,          // 정기 리포트 on/off
             boolean interactionEnabled,     // /현황 on/off
             String publicKey,               // 애플리케이션 공개키(hex 64자)
             String reportWebhookUrl,
             List<String> allowedChannelIds,
             List<String> allowedRoleIds,
             int listLimit                   // 신고·문의 목록 최대 건수 (결정 3)
     )
     ```
   - yml 예 (`application-prod.yml`)
     ```yaml
     discord:
       report-enabled: true
       interaction-enabled: true
       public-key: ${DISCORD_PUBLIC_KEY:}        # CD에서 PROD_DISCORD_PUBLIC_KEY 주입
       report-webhook-url: ${DISCORD_REPORT_WEBHOOK_URL:}   # CD에서 PROD_DISCORD_REPORT_WEBHOOK_URL 주입
       allowed-channel-ids: [ ]                  # 배포 전 채널 id 기입 (비밀 아님)
       allowed-role-ids: [ ]                     # 배포 전 PM, 개발 역할 id 기입
       list-limit: 10
     ```

3. **Domain**: `MetricPeriod` enum
   - 상수: `TODAY("today", "오늘")`, `YESTERDAY("yesterday", "어제")`, `LAST_7_DAYS("7d", "최근 7일")`, `LAST_30_DAYS("30d", "최근 30일")`, `LAST_WEEK("last-week", "지난주")`. 필드 `optionValue`(슬래시 커맨드 선택지 값), `label`
   - `public MetricRangeDto toRange(LocalDate today)` — 위 표의 현재 구간
   - `public Optional<MetricRangeDto> toPreviousRange(LocalDate today)` — `TODAY`는 empty, 나머지는 현재 구간과 같은 길이의 직전 구간 (`LAST_WEEK`는 전주 월~일)
   - `public static MetricPeriod fromOptionValue(String optionValue)` — 없는 값이면 `RestApiException(DISCORD_UNSUPPORTED_INTERACTION)`, null이면 `TODAY`

4. **DTO (internal)**
   - `MetricRangeDto(LocalDate startDate, LocalDate endDate)` — `of()`, `startAt()`(= startDate 00:00), `endExclusiveAt()`(= endDate+1 00:00), `days()`, `isSingleDay()`
   - `UserMetricDto(long totalUsers, long newSignups, double averageDailyActiveUsers, long activeUsers, long monthlyActiveUsers, YearMonth mauMonth, boolean mauInProgress, RetentionDto d1Retention, RetentionDto d7Retention)`
   - `RetentionDto(long cohortSize, long retainedCount)` — JDBC 매핑 대상. `Double rate()`는 cohortSize 0이면 null. D1, D7 공용
   - `LessonMetricDto(long submissionCount, long learnerCount, Double averageAccuracy)`
   - `InterviewMetricDto(long startedCount, long submittedCount, long gradedAnswerCount)`
   - `TypeCountDto(String type, long count)`, `ReportItemDto(long reportId, String reportType, long problemId, LocalDateTime submittedAt)`, `InquiryItemDto(long inquiryId, String inquiryType, String title, LocalDateTime createdAt)`
   - `ReportInquiryMetricDto(List<TypeCountDto> newReportCounts, long unresolvedReportCount, List<ReportItemDto> newReports, List<TypeCountDto> newInquiryCounts, long pendingInquiryCount, List<InquiryItemDto> newInquiries)`
   - `ServiceMetricSnapshotDto(MetricRangeDto range, UserMetricDto users, LessonMetricDto lessons, InterviewMetricDto interviews)`
   - `ServiceMetricReportDto(MetricPeriod period, ServiceMetricSnapshotDto current, ServiceMetricSnapshotDto previous /* nullable */, ReportInquiryMetricDto reportsAndInquiries, LocalDateTime generatedAt)`
   - 디스코드 payload record는 모두 `@JsonInclude(NON_NULL)`, snake_case 필드는 `@JsonProperty`로 매핑
     - `DiscordMessageDto(String content, List<DiscordEmbedDto> embeds, List<DiscordActionRowDto> components, Integer flags)`
     - `DiscordEmbedDto(String title, String description, Integer color, List<DiscordEmbedFieldDto> fields, DiscordEmbedFooterDto footer)`, `DiscordEmbedFieldDto(String name, String value, boolean inline)`, `DiscordEmbedFooterDto(String text)`
     - `DiscordActionRowDto(int type /* 1 */, List<DiscordButtonDto> components)`, `DiscordButtonDto(int type /* 2 */, int style, String label, @JsonProperty("custom_id") String customId)`
     - `DiscordInteractionDto(int type, DiscordInteractionDataDto data, @JsonProperty("channel_id") String channelId, DiscordMemberDto member)` — 알 수 없는 필드는 무시
     - `DiscordInteractionDataDto(String name, List<DiscordInteractionOptionDto> options, @JsonProperty("custom_id") String customId)`, `DiscordInteractionOptionDto(String name, String value)`, `DiscordMemberDto(List<String> roles)`
     - `DiscordInteractionResponseDto(int type, DiscordMessageDto data)` — `pong()`(type 1), `message(DiscordMessageDto)`(type 4)

5. **Repository**: `ServiceMetricRepository`(interface) + `ServiceMetricRepositoryImpl`(`@Repository`, `NamedParameterJdbcTemplate`), SQL은 `ServiceMetricSql` 상수
   - `long countSignups(LocalDateTime startAt, LocalDateTime endExclusiveAt)` — `SELECT COUNT(*) FROM users WHERE created_at >= :startAt AND created_at < :endAt` (네이티브라 `@SQLRestriction` 미적용 → 탈퇴 상태 포함)
   - `long countDailyActivities(LocalDate startDate, LocalDate endDate)` — `user_daily_activity` 행 수
   - `long countDistinctActiveUsers(LocalDate startDate, LocalDate endDate)` — `COUNT(DISTINCT user_id)` (MAU에도 사용)
   - `RetentionDto findRetention(LocalDate cohortStartDate, LocalDate cohortEndDate, int dayOffset)` — D1은 `dayOffset = 1`, D7은 `7`
     ```sql
     SELECT COUNT(*) AS cohort_size,
            COUNT(*) FILTER (WHERE EXISTS (
                SELECT 1 FROM user_daily_activity uda
                WHERE uda.user_id = u.id AND uda.activity_date = CAST(u.created_at AS date) + :dayOffset
            )) AS retained_count
     FROM users u
     WHERE u.created_at >= :startAt AND u.created_at < :endAt
     ```
   - `LessonMetricDto findLessonMetric(LocalDateTime startAt, LocalDateTime endExclusiveAt)` — `COUNT(*)`, `COUNT(DISTINCT user_id)`, `AVG(accuracy)` from `lesson_submission`
   - `InterviewMetricDto findInterviewMetric(LocalDateTime startAt, LocalDateTime endExclusiveAt)` — 스칼라 서브쿼리 3개(시작, 제출 `status <> 'ABANDONED' AND ended_at` 구간, `interview_feedback.created_at` 구간)
   - `List<TypeCountDto> countReportsByType(LocalDateTime startAt, LocalDateTime endExclusiveAt)` — `GROUP BY report_type`
   - `List<ReportItemDto> findReports(LocalDateTime startAt, LocalDateTime endExclusiveAt, int limit)` — `ORDER BY submitted_at DESC, id DESC LIMIT :limit`, 컬럼은 `id, report_type, problem_id, submitted_at`만
   - `List<TypeCountDto> countInquiriesByType(...)`, `long countPendingInquiries()`, `List<InquiryItemDto> findInquiries(..., int limit)` — 컬럼은 `id, type, title, created_at`만
   - 재사용: `AdminUserRepository.countActiveUsers()`, `AdminReportRepository.countByIsResolvedFalse()`

6. **Service**
   - `ServiceMetricQueryService` (`@Transactional(readOnly = true)`)
     - `public ServiceMetricReportDto getReport(MetricPeriod period)` — `today = LocalDate.now(clock)` → `current = getSnapshot(period.toRange(today))` → `previous = period.toPreviousRange(today).map(this::getSnapshot).orElse(null)` → `reportsAndInquiries = getReportsAndInquiries(range)` → `ServiceMetricReportDto.of(...)`
     - `private ServiceMetricSnapshotDto getSnapshot(MetricRangeDto range)` — 위 레포지토리 호출 조합. 리텐션은 상수 `D1_DAY_OFFSET = 1`, `D7_DAY_OFFSET = 7`로 `findRetention(range.startDate().minusDays(offset), range.endDate().minusDays(offset), offset)`을 두 번 호출. MAU 구간은 `range.endDate().withDayOfMonth(1) ~ range.endDate()`, `mauInProgress = endDate가 월말이 아님 || endDate가 오늘`
     - `private ReportInquiryMetricDto getReportsAndInquiries(MetricRangeDto range)` — `props.listLimit()` 적용
     - 주입: `ServiceMetricRepository`, `AdminUserRepository`, `AdminReportRepository` / `Clock`, `DiscordProps`
   - `MetricReportService`
     - `public void sendDailyReport()` — `getReport(YESTERDAY)` → `messageFactory.createScheduledReport(report)` → `webhookClient.send(message)`
     - `public void sendWeeklyReport()` — 같은 흐름, `LAST_WEEK`
     - 트랜잭션 없음 (조회는 `ServiceMetricQueryService`가 경계를 가짐, 전송은 경계 밖)
   - `DiscordInteractionService`
     - `public DiscordInteractionResponseDto handle(String signature, String timestamp, String rawBody)`
       1. `interactionEnabled`가 false면 `DISCORD_INTERACTION_DISABLED`
       2. `signatureVerifier.isValid(...)`가 false면 `DISCORD_INVALID_SIGNATURE` (401, 디스코드가 엔드포인트 등록 시 일부러 잘못된 서명을 보내 401을 확인함)
       3. `objectMapper.readValue(rawBody, DiscordInteractionDto.class)`
       4. `type` 분기: `PING(1)` → `pong()` / `APPLICATION_COMMAND(2)` + name `현황` → `handleStatusCommand` / `MESSAGE_COMPONENT(3)` + custom_id `metric-share:` 접두 → `handleShare` / 그 외 `DISCORD_UNSUPPORTED_INTERACTION`
     - `private DiscordInteractionResponseDto handleStatusCommand(DiscordInteractionDto interaction)` — 권한 없으면 `messageFactory.createDeniedReply()`(나만 보기). 있으면 옵션 `기간` 값으로 `MetricPeriod.fromOptionValue` → `getReport` → `createStatusReply(report)`
     - `private DiscordInteractionResponseDto handleShare(DiscordInteractionDto interaction)` — 권한 확인 → custom_id에서 기간 파싱 → `getReport` 재계산 → `createSharedReport(report)`
     - `private boolean isAllowed(DiscordInteractionDto interaction)` — `channelId ∈ allowedChannelIds` 그리고 `member.roles ∩ allowedRoleIds ≠ ∅` (DM에서 호출해 member가 없으면 거부)
     - 응답은 동기(type 4)로 준다 (결정 1). 처리 시간을 `log.info`로 남겨 3초 한도 대비 여유를 본다
     - 주입: `ServiceMetricQueryService` / `DiscordReportMessageFactory`, `DiscordSignatureVerifier` / `ObjectMapper`, `DiscordProps`
     - 같은 도메인 서비스 호출이라 Facade 불필요

7. **Support**: `DiscordReportMessageFactory` (`@Component`)
   - 상수: `FLAG_EPHEMERAL = 1 << 6`, `FLAG_SUPPRESS_NOTIFICATIONS = 1 << 12`, `SHARE_CUSTOM_ID_PREFIX = "metric-share:"`, `INQUIRY_TITLE_MAX_LENGTH = 50`, 임베드 색상
   - `public DiscordMessageDto createScheduledReport(ServiceMetricReportDto report)` — 무음 flag, 버튼 없음. 제목 `📊 일간 리포트 · 2025-08-04` / `📊 주간 리포트 · 07-28 ~ 08-03`
   - `public DiscordMessageDto createStatusReply(ServiceMetricReportDto report)` — `EPHEMERAL` flag, "채널에 공유" 버튼(`metric-share:{optionValue}`)
   - `public DiscordMessageDto createSharedReport(ServiceMetricReportDto report)` — 무음 flag, 버튼 없음
   - `public DiscordMessageDto createDeniedReply()` — `EPHEMERAL`, "이 채널이나 역할에서는 현황을 조회할 수 없습니다."
   - private: `buildEmbed(report)` → 필드 5개(👥 사용자, 🔁 재방문 - `D1 33.3% (1/3명) ▲5.0%p` / `D7 25.0% (2/8명) ▼1.2%p` 두 줄, 📚 레슨, 🎤 면접, 🚨 신고·문의), `formatCount(current, previous)` → `128 (▲12, +10.3%)`, 이전 0이면 `▲12`, 같으면 `→`, `formatRate(...)` → `%p`, `formatReports(...)`, `formatInquiries(...)`(제목 자르기, 0건이면 "새로 들어온 문의 없음"), 필드 값 1024자 제한 넘으면 목록을 줄이고 `외 N건`
   - 푸터: `생성 {yyyy-MM-dd HH:mm} KST · {TODAY면 "오늘은 진행 중인 값"}`

8. **Infrastructure**
   - `DiscordWebhookClient` (`@Component`)
     - `public void send(DiscordMessageDto message)` — `reportWebhookUrl`이 비어 있으면 `log.warn` 후 반환. `restClient.post().uri(url).contentType(JSON).body(message).retrieve().toBodilessEntity()`. `RestClientException`은 `log.error`로 남기고 삼킨다 (리포트 실패가 서비스에 영향 없음)
     - 주입: `RestClient`(기존 `RestClientConfig` 빈), `DiscordProps`
   - `DiscordSignatureVerifier` (`@Component`)
     - 상수: `ED25519_X509_PREFIX = "302a300506032b6570032100"` (raw 32바이트 공개키를 X.509로 감싸는 DER 헤더)
     - 생성자에서 `interactionEnabled`면 `KeyFactory.getInstance("Ed25519").generatePublic(new X509EncodedKeySpec(prefix + hex))`로 공개키를 만든다. 형식이 틀리면 기동 실패
     - `public boolean isValid(String signatureHex, String timestamp, String rawBody)` — 헤더 null, hex 형식 오류는 false. `Signature.getInstance("Ed25519")`로 `timestamp + rawBody`(UTF-8) 검증. JDK 내장이라 의존성 추가 없음

9. **Scheduler**: `MetricReportScheduler`
   - `@Scheduled(cron = "0 0 9 * * *", zone = "Asia/Seoul") public void sendDailyReport()`
   - `@Scheduled(cron = "0 5 9 * * MON", zone = "Asia/Seoul") public void sendWeeklyReport()` — 월요일은 일간(일요일분) 뒤에 주간이 올라간다
   - 둘 다 `reportEnabled`가 false면 바로 반환, `try-catch`로 `log.error` (기본 `taskScheduler` 단일 스레드를 막지 않게)

10. **Facade**: 불필요 — 다른 도메인 Service 조합 없음 (다른 도메인 테이블은 레포지토리 조회만)

11. **Controller**: `DiscordInteractionController implements DiscordInteractionControllerDocs`
    - `@RequestMapping("/api/v1/discord")`
    - `POST /api/v1/discord/interactions → handleInteraction(@RequestHeader(value = "X-Signature-Ed25519", required = false) String signature, @RequestHeader(value = "X-Signature-Timestamp", required = false) String timestamp, @RequestBody String body)` → `ResponseEntity.status(OK).body(discordInteractionService.handle(...))`
    - 본문을 `String`으로 받아 서명 원문을 그대로 보존한다
    - Docs: `@Tag(name = "Discord API")`만. 경로는 Swagger에서 제외

12. **에러코드** (`CustomErrorCode`, `// Discord` 그룹)
    - `DISCORD_INVALID_SIGNATURE(UNAUTHORIZED, "DISCORD_4011", "디스코드 요청 서명이 올바르지 않습니다.")`
    - `DISCORD_UNSUPPORTED_INTERACTION(BAD_REQUEST, "DISCORD_4001", "지원하지 않는 디스코드 요청입니다.")`
    - `DISCORD_INTERACTION_DISABLED(NOT_FOUND, "DISCORD_4041", "디스코드 조회 기능이 꺼져 있습니다.")`

13. **커맨드 등록 워크플로**: `.github/workflows/register-discord-commands.yml`
    - 트리거: `push` to `dev`, `main` + `paths: infra/discord/commands.json`, 그리고 `workflow_dispatch`(처음 등록, 재등록용)
    - 환경 선택: `dev` 브랜치 → `DEV_DISCORD_*`, `main` → `PROD_DISCORD_*` 시크릿
    - 단계: `curl -sS --fail-with-body -X PUT "https://discord.com/api/v10/applications/$APP_ID/guilds/$GUILD_ID/commands" -H "Authorization: Bot $BOT_TOKEN" -H "Content-Type: application/json" --data @infra/discord/commands.json`
    - 일괄 덮어쓰기(PUT)라 여러 번 실행해도 명령어가 중복되지 않는다. `permissions: {}`
    - 봇 토큰은 이 워크플로에서만 쓴다. CD 워크플로와 서버 설정에는 넣지 않는다
    - `commands.json`: `[{ "name": "현황", "description": "서비스 지표 현황을 조회합니다", "type": 1, "options": [{ "type": 3, "name": "기간", "description": "조회 기간", "required": false, "choices": [{"name":"오늘","value":"today"},{"name":"어제","value":"yesterday"},{"name":"최근 7일","value":"7d"},{"name":"최근 30일","value":"30d"}] }] }]` — choices의 `value`는 `MetricPeriod.optionValue`와 같아야 한다

14. **배포 준비 (코드 밖, PR 본문 체크리스트)**
    - dev, prod 디스코드 애플리케이션 생성 → 공개키를 `DEV_DISCORD_PUBLIC_KEY`, `PROD_DISCORD_PUBLIC_KEY`로 등록
    - 각 서버의 `#서비스-지표` 채널 웹훅 생성 → `DEV_DISCORD_REPORT_WEBHOOK_URL`, `PROD_DISCORD_REPORT_WEBHOOK_URL` 등록
    - yml에 채널 id, 역할 id 기입
    - 배포 후 Interactions Endpoint URL을 `https://{도메인}/api/v1/discord/interactions`로 저장 (디스코드가 PING과 잘못된 서명을 보내 검증)
    - `DEV_`, `PROD_` 접두의 `DISCORD_BOT_TOKEN`, `DISCORD_APPLICATION_ID`, `DISCORD_GUILD_ID` 등록 → 등록 워크플로 `workflow_dispatch`로 첫 등록

## 결정 필요 (Decisions needed)
- [x] 1. `/현황` 응답 방식 — **동기 응답(type 4)으로 확정**. 처리 시간을 로그로 남기고, 3초 한도에 가까워지면 지연 응답(type 5 + 후속 수정)으로 바꾼다
- [x] 2. 슬래시 커맨드 등록 — **GitHub Actions 등록으로 확정**. `commands.json`이 바뀌어 머지되면 워크플로가 등록한다. 봇 토큰은 GitHub Secrets에만 두고 서버에는 두지 않는다 (수동 등록은 갱신 누락 위험, 기동 시 자동 등록은 서버에 봇 토큰 보관이 필요해 제외)
- [x] 3. 신고·문의 목록 최대 건수 — **10건으로 확정** (`discord.list-limit: 10`, 설정값이라 코드 수정 없이 변경 가능)

## 검증
- `MetricPeriodTest` (순수 JUnit) — 2025-08-05(화) 기준 각 기간의 현재·비교 구간, `LAST_WEEK` = 07-28~08-03 / 07-21~07-27, `TODAY` 비교 구간 없음, 잘못된 옵션 값 → `DISCORD_UNSUPPORTED_INTERACTION`
- `DiscordSignatureVerifierTest` (순수 JUnit) — 테스트 키쌍으로 서명한 요청 true, 본문 변조 false, timestamp 변조 false, hex 아닌 서명 false, null 헤더 false
- `DiscordReportMessageFactoryTest` (순수 JUnit) — 정기 리포트 flag 4096, `/현황` 응답 flag 64와 공유 버튼 custom_id, 공유 메시지 flag 4096·버튼 없음, 증감 표기(▲, ▼, →, 이전 0), 문의 제목 50자 자르기, 목록 1024자 초과 시 `외 N건`, 재방문율의 분모 표기 `(1/3명)`과 코호트 0명일 때 `- (가입자 없음)`
- `ServiceMetricQueryServiceIntegrationTest` — 구간 경계(자정 직전·직후 가입, 제출), 평균 DAU와 기간 활성 수, MAU 진행 중 표시, D1, D7 코호트·재방문(가입 당일만 활동한 사용자는 미포함, 가입 6일 뒤나 8일 뒤 활동은 D7에 미포함, 코호트 0명이면 rate null), 면접 ABANDONED 제출 제외, 신고·문의 유형별 집계와 최근순 limit, 목록에 내용과 작성자가 없음, 탈퇴 상태 사용자는 총 가입자에서 빠지고 신규 가입에는 포함
- `MetricReportServiceIntegrationTest` — `@MockitoBean DiscordWebhookClient`로 일간은 어제, 주간은 지난주 리포트가 무음 flag로 전송되는지 검증
- `DiscordInteractionControllerIntegrationTest` (MockMvc, 테스트 개인키로 서명) — PING → `{"type":1}`, 잘못된 서명 → 401 `DISCORD_4011`, 서명 헤더 누락 → 401, 허용 채널·역할의 `/현황` → type 4 + flag 64 + 공유 버튼, 허용되지 않은 채널 → 거부 메시지(flag 64), 공유 버튼 → flag 4096·64 없음, 모르는 커맨드 → 400 `DISCORD_4001`, JWT 없이 호출해도 인증 필터에 막히지 않음

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)

- `ServiceMetricQueryService`: `getSnapshot(MetricRangeDto range)` → `getSnapshot(MetricRangeDto range, LocalDate today)`, 사용자 지표는 `getUserMetric`, 리텐션은 `getRetention`으로 분리 — 이유: `mauInProgress` 판정에 오늘 날짜가 필요하고, 조회 시점 하나(`now`)를 리포트 전체가 공유하게 하려고
- `DiscordReportMessageFactory`: 임베드 필드 `🚨 신고·문의` 하나를 `🚨 신고`, `💬 문의` 두 필드로 분리 (필드 6개) — 이유: 디스코드 1024자 제한이 필드마다 걸려 목록이 덜 잘리고, 읽기도 쉬움
- `DiscordWebhookClient`: `RestClientException` 로그를 예외 전체가 아닌 상태 코드, 응답 본문, 예외 클래스명만 남김 — 이유: `ResourceAccessException` 메시지에 요청 URL이 들어가는데 웹훅 URL에 토큰이 포함돼 로그(Loki)로 유출됨
- `MetricRangeDto.minusDays(long)`, `ReportInquiryMetricDto.newReportTotal()`·`newInquiryTotal()`, `ServiceMetricReportDto.hasPrevious()`: 계획에 없던 보조 메서드 추가 — 이유: 직전 구간·코호트 구간 계산과 "외 N건" 계산을 한 곳에 둠
- `register-discord-commands.yml`: `permissions: {}` → `permissions: contents: read` — 이유: `commands.json`을 읽으려면 체크아웃이 필요하고, 체크아웃에 읽기 권한이 필요
- `application-test.yml`: 테스트 전용 Ed25519 키쌍을 새로 만들어 공개키만 넣음. 짝이 되는 개인키 seed(hex)는 `9419872a9994e5e6464a12fbafa2bb2362c58ea54a97c287e885888101af83f2`이며 `write-test`에서 `DiscordTestKey` 상수로 쓴다 (테스트 전용 값, 실제 디스코드와 무관)
- 테스트 파일(`MetricPeriodTest` 외 7개)은 작성하지 않음 — 이유: `implement` 스킬 범위 밖. `write-test`로 이어서 작성한다
