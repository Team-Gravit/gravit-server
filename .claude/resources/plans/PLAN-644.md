# [PLAN-644] 디스코드 지표 리포트 가독성 개편

> 이슈: #644
> 브랜치: feat/644-metric-report-readability (base: dev)

## 목표
#638 리포트를 "결론 → 묶음 → 숫자" 위계로 다시 짠다. 작은 표본의 변화율 과장을 없애고, 리텐션을 사람이 읽는 말로 표기하며, 신고·문의 목록은 본문에서 빼고 어드민 링크로 처리 경로를 준다. 집계(`ServiceMetricQueryService`)는 바꾸지 않고 메시지 생성과 인터랙션 분기만 바꾼다.

## 결과 형식 (샘플 B 기준)

```
[제목, 어드민 링크] 📊 서비스 현황 · 최근 7일          ← 정기: 📊 일간 리포트 · 2025-08-04
-# 11-12 ~ 11-18 · 직전 7일(11-05 ~ 11-11) 대비       ← 오늘: -# 오늘 0시부터 지금까지 · 비교 없음
> 신규 가입 7명 → 1명
> 평균 정답률 29.1% · 직전 제출 없음
> 미처리 신고 9건 · 미답변 문의 3건
### 👥 사용자
신규 가입 **1명** `▼6`
평균 DAU **5.0명** `▼0.6` · 기간 활성 **15명** `→`     ← 하루 구간이면 "DAU **5명** `▼1`" 한 개만
총 가입자 **331명** · MAU **22명**
-# MAU는 11월 1일부터 집계 중
### 🔁 리텐션
가입 다음 날 다시 온 사람 **3명 중 3명** `표본 적음`
가입 7일째 다시 온 사람 **7명 중 2명** `표본 적음`
-# D1, D7 · 대상 10명 미만은 비율 비교 생략             ← 대상 10명 이상이면 "**42%** (21/50명) `▲3.0%p`"
### 📚 학습 · 🎤 면접
레슨 제출 **8건** `▲8` · 학습자 **3명** `▲3`
평균 정답률 **29.1%** `직전 없음`
면접 시작 **0건** `▼1` · 제출 **0건** `→` · 채점된 답변 **0건** `→`
### 🚨 처리 필요
미처리 신고 **9건** · 미답변 문의 **3건** → [어드민 열기](admin-url)
-# 이번 기간 신규 신고 2건, 문의 2건
[푸터] 생성 2026-11-19 16:17 KST
[버튼, /현황만] [채널에 공유] [신고·문의 목록] [어드민 열기↗]
```

- `-#`(작은 회색 글씨)는 줄 맨 앞에서만 동작하므로 보조 정보는 항상 별도 줄로 둔다.
- 임베드 필드는 쓰지 않고 description 하나에 담는다 (한도 4096자). 필드 1024자 제한과 모바일 격자 깨짐이 사라진다.

## 표기 규칙

| 대상 | 규칙 | 예 |
|---|---|---|
| 건수·인원 증감 | 직전 값 10 이상: 증감 수와 변화율 | `▲12 · +10.3%` |
| | 직전 값 10 미만(0 포함): 증감 수만 | `▼6` |
| | 같음 | `→` |
| 평균 DAU | 소수 첫째 자리 증감, 0.05 미만 차이는 `→` | `▼0.6` |
| 비율(정답률) 증감 | `%p`, 직전 값 없으면 `직전 없음` | `▲1.2%p`, `직전 없음` |
| 리텐션 | 대상 0명: `가입자 없음`. 대상 1~9명: `N명 중 M명` + `표본 적음`. 대상 10명 이상: `**42%** (21/50명)` + `%p` 증감 (직전 대상도 10명 이상일 때만) | |
| 비교 없음(오늘) | 증감 알약 없이 숫자만 | |

## 결론 줄 규칙 (`MetricHighlightSelector`, #641에서 LLM 요약으로 교체)

최대 3줄, 아래 순서로 채운다. `지표 이전 → 현재` 형식으로 써서 조사(이/가) 처리를 피한다.

1. **가장 크게 변한 지표 1개**: 후보는 신규 가입, DAU(평균), 레슨 제출, 면접 시작. 직전 값 10 이상인 후보가 있으면 변화율 절댓값이 가장 큰 것, 없으면 증감 수 절댓값이 가장 큰 것. 모두 변화 0이면 생략. 예: `신규 가입 7명 → 1명`
2. **비교할 수 없는 지표**: 평균 정답률의 직전 값이 없고 현재 값이 있으면 `평균 정답률 29.1% · 직전 제출 없음`
3. **처리 필요**: 미처리 신고 또는 미답변 문의가 1건 이상이면 `미처리 신고 9건 · 미답변 문의 3건`
- 오늘(비교 없음): 1, 2 대신 `오늘 신규 가입 N명 · 활성 N명` 한 줄 + 3
- 세 줄 모두 비면 `직전 기간과 비교해 눈에 띄는 변화가 없습니다`

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/metricReport/support/MetricHighlightSelector.java` — 결론 줄 규칙
- `src/main/java/gravit/code/metricReport/support/MetricChangeFormatter.java` — 증감·리텐션 표기 규칙 (팩토리와 결론 선택기가 함께 씀)
- `src/test/java/gravit/code/metricReport/support/MetricHighlightSelectorTest.java`
- `src/test/java/gravit/code/metricReport/support/MetricChangeFormatterTest.java`

### 수정 파일
- `src/main/java/gravit/code/metricReport/config/DiscordProps.java` — `String adminUrl` 추가
- `src/main/java/gravit/code/metricReport/dto/internal/DiscordEmbedDto.java` — `String url` 필드 추가 (제목 링크)
- `src/main/java/gravit/code/metricReport/dto/internal/DiscordButtonDto.java` — `String url` 필드, `STYLE_LINK = 5`, `link(label, url)` 팩토리 추가
- `src/main/java/gravit/code/metricReport/support/DiscordReportMessageFactory.java` — 본문을 섹션 description으로 재작성, `createListReply` 추가, 버튼 구성 변경
- `src/main/java/gravit/code/metricReport/service/DiscordInteractionService.java` — "신고·문의 목록" 버튼 분기 추가
- `src/main/resources/application-dev.yml`, `application-prod.yml`, `src/test/resources/application-test.yml` — `discord.admin-url`
- `src/test/java/gravit/code/metricReport/support/DiscordReportMessageFactoryTest.java` — 새 형식 기준으로 재작성
- `src/test/java/gravit/code/metricReport/controller/DiscordInteractionControllerIntegrationTest.java` — 목록 버튼, 링크 버튼 검증 추가
- `src/test/java/gravit/code/metricReport/service/MetricReportServiceIntegrationTest.java` — 제목 링크, 목록 미포함 검증
- `.claude/spec/service-policy/metric-report.md` — 작은 표본 규칙, 리텐션 표기, 목록 노출 범위 변경(정기 리포트 제외, `/현황` 버튼), 어드민 링크, 결론 줄 (정책 변경)

## 구현 계획

1. **Entity / Flyway / Repository / ServiceMetricQueryService**: 변경 없음

2. **Config**: `DiscordProps`에 `String adminUrl` 추가
   - dev, prod: `admin-url: https://gravit-admin.inuappcenter.kr/`
   - test: `admin-url: https://admin.test/`

3. **DTO**
   - `DiscordEmbedDto(String title, String url, String description, Integer color, List<DiscordEmbedFieldDto> fields, DiscordEmbedFooterDto footer)` — `url`이 있으면 제목이 링크가 된다. 기존 `of(...)`에 `url` 인자 추가
   - `DiscordButtonDto(int type, int style, String label, @JsonProperty("custom_id") String customId, String url)` — `STYLE_LINK = 5`, `secondary(label, customId)`는 `url = null`, `link(label, url)`는 `customId = null` (`@JsonInclude(NON_NULL)`로 빠짐)

4. **Support**
   - `MetricChangeFormatter` (상태 없는 `@Component`, 팩토리와 선택기에 주입. 순수 JUnit 테스트에서는 `new`로 생성)
     - 상수 `SMALL_SAMPLE_THRESHOLD = 10`, `UNCHANGED_THRESHOLD = 0.05`
     - `String countChange(long current, Long previous)` — 위 표의 건수 규칙. previous null이면 빈 문자열
     - `String averageChange(double current, Double previous)`
     - `String percentPointChange(Double currentPercent, Double previousPercent)` — 현재 null이면 빈 문자열, 직전 null이면 `직전 없음`
     - `String retention(RetentionDto current, RetentionDto previous)` — 리텐션 규칙 전체 (값 + 알약)
     - `String number(long value)`, `String pill(String text)` (빈 문자열이면 빈 문자열, 아니면 `` `text` ``)
   - `MetricHighlightSelector` (`@Component`, `MetricChangeFormatter` 주입)
     - `public List<String> select(ServiceMetricReportDto report)` — 위 결론 줄 규칙
     - private `findBiggestChange(current, previous)`, `findIncomparable(current, previous)`, `findPendingWork(reportsAndInquiries)`, `summarizeToday(current)`
   - `DiscordReportMessageFactory` (`MetricChangeFormatter`, `MetricHighlightSelector` 주입. 기존 기본 생성자 → `@RequiredArgsConstructor`)
     - 상수 추가: `LIST_CUSTOM_ID_PREFIX = "metric-list:"` (public), `SMALL_TEXT_PREFIX = "-# "`, `SECTION_PREFIX = "### "`, `QUOTE_PREFIX = "> "`
     - `public DiscordMessageDto createScheduledReport(ServiceMetricReportDto report)` — 제목(일간/주간), 무음, 버튼 없음
     - `public DiscordMessageDto createStatusReply(ServiceMetricReportDto report)` — 나만 보기, 버튼 3개: `채널에 공유`(`metric-share:{period}`), `신고·문의 목록`(`metric-list:{period}`), `어드민 열기`(링크)
     - `public DiscordMessageDto createSharedReport(ServiceMetricReportDto report)` — 무음, 버튼 `어드민 열기`(링크)만
     - `public DiscordMessageDto createListReply(ServiceMetricReportDto report)` — 나만 보기, 임베드 필드 2개(🚨 신고, 💬 문의)에 #638의 목록 형식(유형별 건수 헤더 + 최근 10건 + `외 N건`, 1024자 제한) 그대로
     - `public DiscordMessageDto createDeniedReply()` — 변경 없음
     - private `buildReportEmbed(title, report)` → `DiscordEmbedDto.of(title, props.adminUrl(), buildBody(report), ...)`
     - private `buildBody(report)` — 순서: `buildRangeLine` → `buildHighlights`(인용) → `buildUserSection` → `buildRetentionSection` → `buildLearningSection` → `buildPendingSection`
     - 기존 `formatReports`/`formatInquiries`/`joinWithinLimit`/`buildListBody`/`truncateTitle`/`formatTypeBreakdown`은 `createListReply` 아래로 옮겨 재사용. 증감 관련 private 메서드(`formatCount`, `formatAverage`, `appendPercentPointChange`, `formatRetentionRate`)는 `MetricChangeFormatter`로 이동하고 삭제
   - `DiscordProps` 주입 추가 (`adminUrl`)

5. **Service**: `DiscordInteractionService`
   - `MESSAGE_COMPONENT` 분기: `handleShare` → `handleComponent`로 이름 변경, custom_id 접두로 분기
     - `metric-share:` → 기존 공유 처리
     - `metric-list:` → 권한 확인 → 기간 파싱 → `getReportWithTiming` → `createListReply`
     - 그 외 → `DISCORD_UNSUPPORTED_INTERACTION`
   - private `parsePeriod(String customId, String prefix)`로 기간 파싱 공용화

6. **Facade / Controller**: 변경 없음

7. **정책 문서** `metric-report.md`
   - 신고와 문의: "정기 리포트와 공유 메시지에는 건수만 보이고, 목록은 `/현황`의 목록 버튼으로 요청자에게만 보인다"로 변경
   - 지표 정의: 리텐션 표기와 10명 기준, 건수 변화율 10 기준 추가
   - 결론 줄 규칙, 어드민 링크 추가

## 결정 필요 (Decisions needed)
- [x] 1. 샘플 B에서 `###`(소제목)과 `-#`(작은 회색 글씨)가 임베드 description에서 적용되는지 — **적용됨으로 확인 (2026-11-19 테스트 채널)**. 계획대로 `###`, `-#`를 쓰고 대체 표기는 만들지 않는다

## 검증
- `MetricChangeFormatterTest` (순수 JUnit) — 직전 9/10 경계에서 변화율 유무, 0 → N, 같음 `→`, 평균 0.05 경계, `%p`와 `직전 없음`, 리텐션 대상 0명·9명·10명 경계, 직전 대상 10명 미만이면 `%p` 생략
- `MetricHighlightSelectorTest` (순수 JUnit) — 직전 10 이상 후보 중 변화율 최대 선택, 모두 10 미만이면 증감 수 최대 선택, 변화 0이면 생략, 정답률 직전 없음 줄, 미처리 0건이면 생략, 오늘 요약 줄, 모두 비면 기본 문장, 최대 3줄
- `DiscordReportMessageFactoryTest` — 제목 링크(`url`), 섹션 4개 순서, 하루 구간은 DAU 한 개·여러 날은 평균 DAU와 기간 활성, `-#` 줄이 줄 맨 앞에 있음, 정기·공유 본문에 문제 번호와 문의 제목이 없음, `/현황` 버튼 3개(custom_id 2개 + 링크 url), 공유는 링크 버튼만, 목록 응답은 나만 보기 + 필드 2개 + `외 N건`
- `DiscordInteractionControllerIntegrationTest` — 목록 버튼(`metric-list:7d`) → 나만 보기 목록, 권한 없으면 거부, 모르는 접두 400
- `MetricReportServiceIntegrationTest` — 정기 리포트 제목 url이 어드민 주소, 버튼 없음

## 후속 작업 영향
- #641(LLM 요약)은 이 작업 위로 rebase하고, `MetricHighlightSelector`의 결론 줄 자리를 LLM 요약으로 교체한다. LLM 입력은 `createSummaryInput` 대신 본문(`buildBody`)에서 결론 줄을 뺀 텍스트를 쓰는 쪽으로 PLAN-641을 갱신한다.

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)

- `dto/internal/MetricChangeCandidateDto.java`: 계획에 없던 DTO 추가 (결론 줄 후보의 이름, 현재, 직전, 단위, 소수 여부) — 이유: 후보 4개를 같은 규칙으로 비교하려면 값 묶음이 필요하고, DTO 컨벤션상 클래스 안 중첩 record 대신 별도 파일로 둠
- `MetricChangeFormatter`: `decimal(double)` 추가 — 이유: 평균 DAU를 팩토리와 결론 선택기가 같은 형식(`%,.1f`)으로 쓰게 함
- `DiscordReportMessageFactory`: 기간 줄을 `직전 7일(...)` 대신 `직전 같은 기간(...)`으로 통일 — 이유: 어제, 30일, 지난주에도 같은 문구가 맞음
- `DiscordReportMessageFactory`: 푸터의 `오늘은 진행 중인 값` 제거 — 이유: 기간 줄 `오늘 0시부터 지금까지 · 비교 없음`과 중복
- `MetricChangeFormatter.retention`: 대상 10명 이상 비율을 `42%`가 아닌 `42.0%`로 표기 — 이유: 정답률 등 다른 비율과 소수 자리 통일
- `DiscordReportMessageFactory`: 정답률 값이 없으면 `평균 정답률 **-** \`제출 없음\`` — 이유: 계획에 값 없음 표기가 빠져 있었음
- `DiscordReportMessageFactory.createListReply`: 목록 임베드에 기간 작은 글씨 줄과 어드민 링크 버튼 추가 — 이유: 목록을 보고 바로 처리하러 가는 경로
- 어드민 주소가 비어 있으면 제목 링크, 처리 필요 줄 링크, 링크 버튼을 모두 생략 — 이유: 설정 누락 시 깨진 링크 대신 링크 없이 동작
- `MetricReportScheduler`, `MetricReportService`: 일간 리포트(매일 09:00)와 `sendDailyReport`를 없애고 주간 리포트를 월요일 09:05 → 09:00으로 변경. `createScheduledReport`의 일간 제목 분기 제거 — 이유: 사용자 요청(2026-11-19), 매일 보내기보다 주 1회. 다른 기간은 `/현황`으로 조회
