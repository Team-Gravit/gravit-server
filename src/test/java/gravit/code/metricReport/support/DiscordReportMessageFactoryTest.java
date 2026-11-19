package gravit.code.metricReport.support;

import gravit.code.metricReport.config.DiscordProps;
import gravit.code.metricReport.domain.MetricPeriod;
import gravit.code.metricReport.dto.internal.DiscordButtonDto;
import gravit.code.metricReport.dto.internal.DiscordEmbedDto;
import gravit.code.metricReport.dto.internal.DiscordMessageDto;
import gravit.code.metricReport.dto.internal.InquiryItemDto;
import gravit.code.metricReport.dto.internal.InterviewMetricDto;
import gravit.code.metricReport.dto.internal.LessonMetricDto;
import gravit.code.metricReport.dto.internal.MetricRangeDto;
import gravit.code.metricReport.dto.internal.ReportInquiryMetricDto;
import gravit.code.metricReport.dto.internal.ReportItemDto;
import gravit.code.metricReport.dto.internal.RetentionDto;
import gravit.code.metricReport.dto.internal.ServiceMetricReportDto;
import gravit.code.metricReport.dto.internal.ServiceMetricSnapshotDto;
import gravit.code.metricReport.dto.internal.TypeCountDto;
import gravit.code.metricReport.dto.internal.UserMetricDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.List;
import java.util.stream.LongStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

class DiscordReportMessageFactoryTest {

    private static final int FLAG_EPHEMERAL = 64;
    private static final int FLAG_SUPPRESS_NOTIFICATIONS = 4096;
    private static final String ADMIN_URL = "https://admin.test/";
    private static final LocalDateTime GENERATED_AT = LocalDateTime.of(2026, 11, 19, 16, 17);
    private static final MetricRangeDto WEEK = 구간("2026-11-12", "2026-11-18");
    private static final MetricRangeDto PREVIOUS_WEEK = 구간("2026-11-05", "2026-11-11");

    private final DiscordReportMessageFactory factory = 팩토리(ADMIN_URL);

    private static DiscordReportMessageFactory 팩토리(String adminUrl) {
        MetricChangeFormatter formatter = new MetricChangeFormatter();
        DiscordProps props = new DiscordProps(true, true, null, null, adminUrl, List.of(), List.of(), 10);
        return new DiscordReportMessageFactory(formatter, new MetricHighlightSelector(formatter), props);
    }

    private static MetricRangeDto 구간(
            String startDate,
            String endDate
    ) {
        return MetricRangeDto.of(LocalDate.parse(startDate), LocalDate.parse(endDate));
    }

    private static ServiceMetricSnapshotDto 이번_주() {
        UserMetricDto users = UserMetricDto.of(331, 1, 5.0, 15, 22, YearMonth.of(2026, 11), true, new RetentionDto(3, 3), new RetentionDto(7, 2));
        return ServiceMetricSnapshotDto.of(WEEK, users, new LessonMetricDto(8, 3, 29.1), new InterviewMetricDto(0, 0, 0));
    }

    private static ServiceMetricSnapshotDto 지난_주() {
        UserMetricDto users = UserMetricDto.of(331, 7, 5.6, 15, 22, YearMonth.of(2026, 11), true, new RetentionDto(3, 2), new RetentionDto(7, 0));
        return ServiceMetricSnapshotDto.of(PREVIOUS_WEEK, users, new LessonMetricDto(0, 0, null), new InterviewMetricDto(1, 0, 0));
    }

    private static ReportInquiryMetricDto 신고_문의() {
        return ReportInquiryMetricDto.of(
                List.of(new TypeCountDto("ANSWER_ERROR", 1), new TypeCountDto("TYPO_ERROR", 1)),
                9,
                List.of(
                        new ReportItemDto(2L, "ANSWER_ERROR", 3077L, GENERATED_AT),
                        new ReportItemDto(1L, "TYPO_ERROR", 212L, GENERATED_AT)
                ),
                List.of(new TypeCountDto("CONTENT_ERROR", 1), new TypeCountDto("OTHER", 1)),
                3,
                List.of(
                        new InquiryItemDto(2L, "CONTENT_ERROR", "Quiz problem", GENERATED_AT),
                        new InquiryItemDto(1L, "OTHER", "사용자가 쓴 문의 제목", GENERATED_AT)
                )
        );
    }

    private static ServiceMetricReportDto 최근_7일_리포트() {
        return ServiceMetricReportDto.of(MetricPeriod.LAST_7_DAYS, 이번_주(), 지난_주(), 신고_문의(), GENERATED_AT);
    }

    private static String 본문(DiscordMessageDto message) {
        return message.embeds().getFirst().description();
    }

    @Nested
    @DisplayName("리포트 본문을 만들 때")
    class Body {

        @Test
        void 기간_줄_결론_인용_섹션_4개_순서로_쓴다() {
            // when
            String body = 본문(factory.createStatusReply(최근_7일_리포트()));

            // then
            assertThat(body).startsWith("""
                    -# 11-12 ~ 11-18 · 직전 같은 기간(11-05 ~ 11-11) 대비

                    > 레슨 제출 0건 → 8건
                    > 평균 정답률 29.1% · 직전 제출 없음
                    > 미처리 신고 9건 · 미답변 문의 3건

                    ### 👥 사용자""");
            assertThat(body.indexOf("### 👥 사용자"))
                    .isLessThan(body.indexOf("### 🔁 리텐션"));
            assertThat(body.indexOf("### 🔁 리텐션"))
                    .isLessThan(body.indexOf("### 📚 학습 · 🎤 면접"));
            assertThat(body.indexOf("### 📚 학습 · 🎤 면접"))
                    .isLessThan(body.indexOf("### 🚨 처리 필요"));
        }

        @Test
        void 숫자는_굵게_증감은_인라인_코드로_쓰고_작은_표본은_변화율을_뺀다() {
            // when
            String body = 본문(factory.createStatusReply(최근_7일_리포트()));

            // then
            assertThat(body).contains(
                    "신규 가입 **1명** `▼6`",
                    "평균 DAU **5.0명** `▼0.6` · 기간 활성 **15명** `→`",
                    "총 가입자 **331명** · MAU **22명**",
                    "-# MAU는 11월 1일부터 11월 18일까지 집계 중",
                    "레슨 제출 **8건** `▲8` · 학습자 **3명** `▲3`",
                    "평균 정답률 **29.1%** `직전 없음`",
                    "면접 시작 **0건** `▼1` · 제출 **0건** `→` · 채점된 답변 **0건** `→`"
            ).doesNotContain("%)", "-85.7%");
        }

        @Test
        void 리텐션은_사람이_읽는_말로_쓰고_대상이_적으면_표본_적음을_붙인다() {
            // when
            String body = 본문(factory.createStatusReply(최근_7일_리포트()));

            // then
            assertThat(body).contains(
                    "가입 다음 날 다시 온 사람 **3명 중 3명** `표본 적음`",
                    "가입 7일째 다시 온 사람 **7명 중 2명** `표본 적음`",
                    "-# D1, D7 · 대상 10명 미만은 비율 비교 생략"
            );
        }

        @Test
        void 처리_필요_줄에_어드민_링크를_달고_목록은_넣지_않는다() {
            // when
            String body = 본문(factory.createScheduledReport(최근_7일_리포트(), null));

            // then
            assertThat(body)
                    .contains("미처리 신고 **9건** · 미답변 문의 **3건** → [어드민 열기](" + ADMIN_URL + ")")
                    .contains("-# 이번 기간 신규 신고 2건, 문의 2건")
                    .doesNotContain("문제 #", "Quiz problem", "사용자가 쓴 문의 제목");
        }

        @Test
        void 작은_글씨_표기는_항상_줄_맨_앞에_둔다() {
            // when
            String body = 본문(factory.createStatusReply(최근_7일_리포트()));

            // then
            assertThat(body.lines().filter(line -> line.contains("-# ")))
                    .allMatch(line -> line.startsWith("-# "));
        }

        @Test
        void 하루_구간은_DAU_하나만_보여준다() {
            // given
            MetricRangeDto yesterday = 구간("2026-11-18", "2026-11-18");
            UserMetricDto users = UserMetricDto.of(331, 1, 5.0, 5, 22, YearMonth.of(2026, 11), true, new RetentionDto(0, 0), new RetentionDto(0, 0));
            ServiceMetricSnapshotDto current = ServiceMetricSnapshotDto.of(yesterday, users, new LessonMetricDto(0, 0, null), new InterviewMetricDto(0, 0, 0));
            ServiceMetricSnapshotDto previous = ServiceMetricSnapshotDto.of(구간("2026-11-17", "2026-11-17"), users, new LessonMetricDto(0, 0, null), new InterviewMetricDto(0, 0, 0));
            ServiceMetricReportDto report = ServiceMetricReportDto.of(MetricPeriod.YESTERDAY, current, previous, 신고_문의(), GENERATED_AT);

            // when
            String body = 본문(factory.createScheduledReport(report, null));

            // then
            assertSoftly(softly -> {
                softly.assertThat(body).contains("DAU **5명** `→`").doesNotContain("평균 DAU", "기간 활성");
                softly.assertThat(body).contains("가입 다음 날 다시 온 사람 `가입자 없음`");
                softly.assertThat(body).contains("평균 정답률 **-** `제출 없음`");
            });
        }

        @Test
        void 오늘_현황은_증감_없이_진행_중임을_알린다() {
            // given
            ServiceMetricSnapshotDto today = ServiceMetricSnapshotDto.of(
                    구간("2026-11-19", "2026-11-19"),
                    UserMetricDto.of(331, 2, 3.0, 3, 22, YearMonth.of(2026, 11), true, new RetentionDto(0, 0), new RetentionDto(0, 0)),
                    new LessonMetricDto(4, 2, 50.0),
                    new InterviewMetricDto(0, 0, 0)
            );
            ServiceMetricReportDto report = ServiceMetricReportDto.of(MetricPeriod.TODAY, today, null, 신고_문의(), GENERATED_AT);

            // when
            String body = 본문(factory.createStatusReply(report));

            // then
            assertThat(body)
                    .startsWith("-# 오늘 0시부터 지금까지 · 비교 없음\n\n> 오늘 신규 가입 2명 · 활성 3명")
                    .contains("신규 가입 **2명**\n", "평균 정답률 **50.0%**\n")
                    .doesNotContain("▲", "▼", "`→`", "직전 없음");
        }
    }

    @Nested
    @DisplayName("AI 요약을 붙일 때")
    class Summary {

        @Test
        void 요약이_있으면_결론_줄_자리에_AI_요약을_인용으로_넣고_섹션은_그대로_둔다() {
            // given
            String summary = "레슨 제출이 늘었지만 정답률이 낮다.\n\n미처리 신고 9건을 확인해야 한다.";

            // when
            String body = 본문(factory.createScheduledReport(최근_7일_리포트(), summary));

            // then
            assertSoftly(softly -> {
                softly.assertThat(body).contains("""
                        > 🧠 **AI 요약**
                        > 레슨 제출이 늘었지만 정답률이 낮다.
                        > 미처리 신고 9건을 확인해야 한다.

                        ### 👥 사용자""");
                softly.assertThat(body).doesNotContain("> 레슨 제출 0건 → 8건");
                softly.assertThat(body).contains("### 🔁 리텐션", "### 📚 학습 · 🎤 면접", "### 🚨 처리 필요");
            });
        }

        @Test
        void 요약이_없으면_규칙_결론_줄을_쓴다() {
            // when
            String body = 본문(factory.createScheduledReport(최근_7일_리포트(), null));

            // then
            assertThat(body).contains("> 레슨 제출 0건 → 8건").doesNotContain("AI 요약");
        }

        @Test
        void 요약_입력에는_섹션만_넣고_결론_줄_어드민_링크_목록은_넣지_않는다() {
            // when
            String input = factory.createSummaryInput(최근_7일_리포트());

            // then
            assertThat(input)
                    .startsWith("-# 11-12 ~ 11-18 · 직전 같은 기간(11-05 ~ 11-11) 대비\n\n### 👥 사용자")
                    .contains("### 🔁 리텐션", "### 📚 학습 · 🎤 면접", "미처리 신고 **9건** · 미답변 문의 **3건**")
                    .doesNotContain("> ", "어드민 열기", ADMIN_URL, "문제 #", "Quiz problem", "사용자가 쓴 문의 제목");
        }
    }

    @Nested
    @DisplayName("메시지 종류별로 만들 때")
    class MessageTypes {

        @Test
        void 정기_리포트는_무음이고_제목이_어드민_링크이며_버튼이_없다() {
            // given
            ServiceMetricReportDto report = ServiceMetricReportDto.of(MetricPeriod.LAST_WEEK, 이번_주(), 지난_주(), 신고_문의(), GENERATED_AT);

            // when
            DiscordMessageDto message = factory.createScheduledReport(report, null);

            // then
            DiscordEmbedDto embed = message.embeds().getFirst();
            assertSoftly(softly -> {
                softly.assertThat(message.flags()).isEqualTo(FLAG_SUPPRESS_NOTIFICATIONS);
                softly.assertThat(message.components()).isNull();
                softly.assertThat(embed.title()).isEqualTo("📊 주간 리포트 · 11-12 ~ 11-18");
                softly.assertThat(embed.url()).isEqualTo(ADMIN_URL);
                softly.assertThat(embed.fields()).isNull();
                softly.assertThat(embed.footer().text()).isEqualTo("생성 2026-11-19 16:17 KST");
            });
        }

        @Test
        void 현황_응답은_나만_보기이고_공유_목록_어드민_버튼을_단다() {
            // when
            DiscordMessageDto message = factory.createStatusReply(최근_7일_리포트());

            // then
            List<DiscordButtonDto> buttons = message.components().getFirst().components();
            assertSoftly(softly -> {
                softly.assertThat(message.flags()).isEqualTo(FLAG_EPHEMERAL);
                softly.assertThat(message.embeds().getFirst().title()).isEqualTo("📊 서비스 현황 · 최근 7일");
                softly.assertThat(buttons).extracting(DiscordButtonDto::customId)
                        .containsExactly("metric-share:7d", "metric-list:7d", null);
                softly.assertThat(buttons.getLast().style()).isEqualTo(DiscordButtonDto.STYLE_LINK);
                softly.assertThat(buttons.getLast().url()).isEqualTo(ADMIN_URL);
            });
        }

        @Test
        void 공유_메시지는_무음이고_어드민_링크_버튼만_단다() {
            // when
            DiscordMessageDto message = factory.createSharedReport(최근_7일_리포트());

            // then
            assertSoftly(softly -> {
                softly.assertThat(message.flags()).isEqualTo(FLAG_SUPPRESS_NOTIFICATIONS);
                softly.assertThat(message.components().getFirst().components())
                        .extracting(DiscordButtonDto::url)
                        .containsExactly(ADMIN_URL);
            });
        }

        @Test
        void 어드민_주소가_없으면_링크와_링크_버튼을_뺀다() {
            // given
            DiscordReportMessageFactory noAdminFactory = 팩토리("");

            // when
            DiscordMessageDto status = noAdminFactory.createStatusReply(최근_7일_리포트());
            DiscordMessageDto shared = noAdminFactory.createSharedReport(최근_7일_리포트());

            // then
            assertSoftly(softly -> {
                softly.assertThat(status.embeds().getFirst().url()).isNull();
                softly.assertThat(status.components().getFirst().components()).hasSize(2);
                softly.assertThat(본문(status)).doesNotContain("어드민 열기");
                softly.assertThat(shared.components()).isNull();
            });
        }

        @Test
        void 권한이_없으면_거부_안내를_요청자에게만_보인다() {
            // when
            DiscordMessageDto message = factory.createDeniedReply();

            // then
            assertSoftly(softly -> {
                softly.assertThat(message.flags()).isEqualTo(FLAG_EPHEMERAL);
                softly.assertThat(message.content()).isEqualTo("이 채널이나 역할에서는 현황을 조회할 수 없습니다.");
            });
        }
    }

    @Nested
    @DisplayName("신고와 문의 목록 응답을 만들 때")
    class ListReply {

        @Test
        void 나만_보기로_유형별_건수와_목록을_보여준다() {
            // when
            DiscordMessageDto message = factory.createListReply(최근_7일_리포트());

            // then
            DiscordEmbedDto embed = message.embeds().getFirst();
            assertSoftly(softly -> {
                softly.assertThat(message.flags()).isEqualTo(FLAG_EPHEMERAL);
                softly.assertThat(embed.title()).isEqualTo("🗂️ 신고·문의 목록 · 최근 7일");
                softly.assertThat(embed.fields().get(0).value()).isEqualTo("""
                        신규 2건 (정답 오류 1, 오타 1) · 미처리 총 9건
                        - 정답 오류 · 문제 #3077
                        - 오타 · 문제 #212""");
                softly.assertThat(embed.fields().get(1).value()).contains("- 콘텐츠 오류 · Quiz problem");
            });
        }

        @Test
        void 목록_건수_제한으로_빠진_건은_외_N건으로_표시한다() {
            // given
            List<InquiryItemDto> inquiries = LongStream.rangeClosed(1, 10)
                    .mapToObj(id -> new InquiryItemDto(id, "BUG_REPORT", "문의 " + id, GENERATED_AT))
                    .toList();
            ReportInquiryMetricDto metric = ReportInquiryMetricDto.of(List.of(), 0, List.of(), List.of(new TypeCountDto("BUG_REPORT", 15)), 7, inquiries);
            ServiceMetricReportDto report = ServiceMetricReportDto.of(MetricPeriod.LAST_7_DAYS, 이번_주(), 지난_주(), metric, GENERATED_AT);

            // when
            DiscordMessageDto message = factory.createListReply(report);

            // then
            assertThat(message.embeds().getFirst().fields().get(1).value())
                    .startsWith("신규 15건 (버그 15) · 미답변 총 7건\n- 버그 · 문의 1")
                    .endsWith("- 버그 · 문의 10\n외 5건");
        }

        @Test
        void 필드_값이_1024자를_넘으면_목록을_줄이고_외_N건으로_표시한다() {
            // given
            List<InquiryItemDto> inquiries = LongStream.rangeClosed(1, 30)
                    .mapToObj(id -> new InquiryItemDto(id, "OTHER", "나".repeat(50), GENERATED_AT))
                    .toList();
            ReportInquiryMetricDto metric = ReportInquiryMetricDto.of(List.of(), 0, List.of(), List.of(new TypeCountDto("OTHER", 30)), 30, inquiries);
            ServiceMetricReportDto report = ServiceMetricReportDto.of(MetricPeriod.LAST_7_DAYS, 이번_주(), 지난_주(), metric, GENERATED_AT);

            // when
            String value = factory.createListReply(report).embeds().getFirst().fields().get(1).value();

            // then
            long shownCount = value.lines().filter(line -> line.startsWith("- ")).count();
            assertSoftly(softly -> {
                softly.assertThat(value.length()).isLessThanOrEqualTo(1024);
                softly.assertThat(value).endsWith("외 " + (30 - shownCount) + "건");
            });
        }

        @Test
        void 문의_제목이_50자를_넘으면_자르고_말줄임표를_붙인다() {
            // given
            ReportInquiryMetricDto metric = ReportInquiryMetricDto.of(
                    List.of(), 0, List.of(),
                    List.of(new TypeCountDto("OTHER", 1)), 1,
                    List.of(new InquiryItemDto(1L, "OTHER", "가".repeat(60), GENERATED_AT))
            );
            ServiceMetricReportDto report = ServiceMetricReportDto.of(MetricPeriod.LAST_7_DAYS, 이번_주(), 지난_주(), metric, GENERATED_AT);

            // when
            String value = factory.createListReply(report).embeds().getFirst().fields().get(1).value();

            // then
            assertThat(value).contains("- 기타 · " + "가".repeat(50) + "…");
        }
    }
}
