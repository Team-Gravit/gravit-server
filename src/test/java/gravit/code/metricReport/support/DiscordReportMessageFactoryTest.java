package gravit.code.metricReport.support;

import gravit.code.metricReport.domain.MetricPeriod;
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
    private static final int FIELD_USERS = 0;
    private static final int FIELD_RETENTION = 1;
    private static final int FIELD_LESSONS = 2;
    private static final int FIELD_INTERVIEWS = 3;
    private static final int FIELD_REPORTS = 4;
    private static final int FIELD_INQUIRIES = 5;
    private static final LocalDateTime GENERATED_AT = LocalDateTime.of(2025, 8, 5, 9, 0);
    private static final MetricRangeDto YESTERDAY = 구간("2025-08-04", "2025-08-04");
    private static final MetricRangeDto DAY_BEFORE = 구간("2025-08-03", "2025-08-03");

    private final DiscordReportMessageFactory factory = new DiscordReportMessageFactory();

    private static MetricRangeDto 구간(
            String startDate,
            String endDate
    ) {
        return MetricRangeDto.of(LocalDate.parse(startDate), LocalDate.parse(endDate));
    }

    private static UserMetricDto 사용자_지표(
            long newSignups,
            long activeUsers,
            RetentionDto d1Retention
    ) {
        return UserMetricDto.of(100, newSignups, activeUsers, activeUsers, 50, YearMonth.of(2025, 8), true, d1Retention, new RetentionDto(0, 0));
    }

    private static ServiceMetricSnapshotDto 스냅샷(
            MetricRangeDto range,
            UserMetricDto users
    ) {
        return ServiceMetricSnapshotDto.of(
                range,
                users,
                new LessonMetricDto(30, 10, 75.0),
                new InterviewMetricDto(5, 4, 20)
        );
    }

    private static ReportInquiryMetricDto 신고_문의_없음() {
        return ReportInquiryMetricDto.of(List.of(), 0, List.of(), List.of(), 0, List.of());
    }

    private static ServiceMetricReportDto 리포트(
            MetricPeriod period,
            ServiceMetricSnapshotDto current,
            ServiceMetricSnapshotDto previous,
            ReportInquiryMetricDto reportsAndInquiries
    ) {
        return ServiceMetricReportDto.of(period, current, previous, reportsAndInquiries, GENERATED_AT);
    }

    private static ServiceMetricReportDto 어제_리포트(ReportInquiryMetricDto reportsAndInquiries) {
        return 리포트(
                MetricPeriod.YESTERDAY,
                스냅샷(YESTERDAY, 사용자_지표(12, 40, new RetentionDto(3, 1))),
                스냅샷(DAY_BEFORE, 사용자_지표(10, 40, new RetentionDto(4, 1))),
                reportsAndInquiries
        );
    }

    private static String 필드_값(
            DiscordMessageDto message,
            int fieldIndex
    ) {
        return message.embeds().getFirst().fields().get(fieldIndex).value();
    }

    @Nested
    @DisplayName("정기 리포트를 만들 때")
    class CreateScheduledReport {

        @Test
        void 일간_리포트는_무음으로_보내고_버튼이_없다() {
            // when
            DiscordMessageDto message = factory.createScheduledReport(어제_리포트(신고_문의_없음()));

            // then
            assertSoftly(softly -> {
                softly.assertThat(message.flags()).isEqualTo(FLAG_SUPPRESS_NOTIFICATIONS);
                softly.assertThat(message.components()).isNull();
                softly.assertThat(message.embeds().getFirst().title()).isEqualTo("📊 일간 리포트 · 2025-08-04");
                softly.assertThat(message.embeds().getFirst().fields()).hasSize(6);
            });
        }

        @Test
        void 주간_리포트는_구간을_월일로_표시한다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.LAST_WEEK,
                    스냅샷(구간("2025-07-28", "2025-08-03"), 사용자_지표(12, 40, new RetentionDto(3, 1))),
                    스냅샷(구간("2025-07-21", "2025-07-27"), 사용자_지표(10, 40, new RetentionDto(4, 1))),
                    신고_문의_없음()
            );

            // when
            DiscordMessageDto message = factory.createScheduledReport(report);

            // then
            assertThat(message.embeds().getFirst().title()).isEqualTo("📊 주간 리포트 · 07-28 ~ 08-03");
        }
    }

    @Nested
    @DisplayName("현황 조회 응답을 만들 때")
    class CreateStatusReply {

        @Test
        void 요청자만_보게_하고_채널_공유_버튼을_단다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.LAST_7_DAYS,
                    스냅샷(구간("2025-07-29", "2025-08-04"), 사용자_지표(12, 40, new RetentionDto(3, 1))),
                    스냅샷(구간("2025-07-22", "2025-07-28"), 사용자_지표(10, 40, new RetentionDto(4, 1))),
                    신고_문의_없음()
            );

            // when
            DiscordMessageDto message = factory.createStatusReply(report);

            // then
            assertSoftly(softly -> {
                softly.assertThat(message.flags()).isEqualTo(FLAG_EPHEMERAL);
                softly.assertThat(message.components().getFirst().components().getFirst().customId()).isEqualTo("metric-share:7d");
                softly.assertThat(message.embeds().getFirst().title()).isEqualTo("📊 서비스 현황 · 최근 7일 (07-29 ~ 08-04)");
            });
        }

        @Test
        void 공유_메시지는_무음으로_공개하고_버튼이_없다() {
            // when
            DiscordMessageDto message = factory.createSharedReport(어제_리포트(신고_문의_없음()));

            // then
            assertSoftly(softly -> {
                softly.assertThat(message.flags()).isEqualTo(FLAG_SUPPRESS_NOTIFICATIONS);
                softly.assertThat(message.components()).isNull();
                softly.assertThat(message.embeds().getFirst().title()).isEqualTo("📊 서비스 현황 · 어제 (2025-08-04)");
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
                softly.assertThat(message.embeds()).isNull();
            });
        }
    }

    @Nested
    @DisplayName("증감을 표기할 때")
    class FormatChange {

        @Test
        void 증가하면_상승_화살표와_변화율을_붙인다() {
            // when
            DiscordMessageDto message = factory.createScheduledReport(어제_리포트(신고_문의_없음()));

            // then
            assertThat(필드_값(message, FIELD_USERS)).contains("신규 가입 12명 (▲2, +20.0%)");
        }

        @Test
        void 감소하면_하락_화살표와_음수_변화율을_붙인다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.YESTERDAY,
                    스냅샷(YESTERDAY, 사용자_지표(8, 40, new RetentionDto(3, 1))),
                    스냅샷(DAY_BEFORE, 사용자_지표(10, 40, new RetentionDto(3, 1))),
                    신고_문의_없음()
            );

            // when
            DiscordMessageDto message = factory.createScheduledReport(report);

            // then
            assertThat(필드_값(message, FIELD_USERS)).contains("신규 가입 8명 (▼2, -20.0%)");
        }

        @Test
        void 같으면_변화_없음으로_표시한다() {
            // when
            DiscordMessageDto message = factory.createScheduledReport(어제_리포트(신고_문의_없음()));

            // then
            assertSoftly(softly -> {
                softly.assertThat(필드_값(message, FIELD_USERS)).contains("DAU 40명 (→)");
                softly.assertThat(필드_값(message, FIELD_LESSONS)).contains("제출 30건 (→)", "평균 정답률 75.0% →");
                softly.assertThat(필드_값(message, FIELD_INTERVIEWS)).contains("시작 5건 (→)", "제출 4건 (→)", "채점된 답변 20건 (→)");
            });
        }

        @Test
        void 직전_값이_0이면_변화율_없이_증가량만_붙인다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.YESTERDAY,
                    스냅샷(YESTERDAY, 사용자_지표(5, 40, new RetentionDto(3, 1))),
                    스냅샷(DAY_BEFORE, 사용자_지표(0, 40, new RetentionDto(3, 1))),
                    신고_문의_없음()
            );

            // when
            DiscordMessageDto message = factory.createScheduledReport(report);

            // then
            assertThat(필드_값(message, FIELD_USERS)).contains("신규 가입 5명 (▲5)");
        }

        @Test
        void 오늘_현황은_비교하지_않고_진행_중임을_알린다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.TODAY,
                    스냅샷(구간("2025-08-05", "2025-08-05"), 사용자_지표(5, 40, new RetentionDto(3, 1))),
                    null,
                    신고_문의_없음()
            );

            // when
            DiscordMessageDto message = factory.createStatusReply(report);

            // then
            DiscordEmbedDto embed = message.embeds().getFirst();
            assertSoftly(softly -> {
                softly.assertThat(필드_값(message, FIELD_USERS)).contains("신규 가입 5명\n").doesNotContain("▲", "▼", "→");
                softly.assertThat(embed.description()).contains("비교하지 않습니다");
                softly.assertThat(embed.footer().text()).isEqualTo("생성 2025-08-05 09:00 KST · 오늘은 진행 중인 값");
            });
        }

        @Test
        void 여러_날_구간은_평균_DAU와_기간_활성을_보여준다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.LAST_7_DAYS,
                    스냅샷(구간("2025-07-29", "2025-08-04"), 사용자_지표(12, 40, new RetentionDto(3, 1))),
                    스냅샷(구간("2025-07-22", "2025-07-28"), 사용자_지표(10, 30, new RetentionDto(3, 1))),
                    신고_문의_없음()
            );

            // when
            DiscordMessageDto message = factory.createStatusReply(report);

            // then
            assertThat(필드_값(message, FIELD_USERS))
                    .contains("평균 DAU 40.0명 (▲10.0)", "기간 활성 40명 (▲10, +33.3%)", "MAU (2025-08, 진행 중) 50명")
                    .doesNotContain("\nDAU ");
        }
    }

    @Nested
    @DisplayName("재방문율을 표기할 때")
    class FormatRetention {

        @Test
        void 비율_옆에_재방문_인원과_대상_인원을_붙이고_퍼센트포인트로_비교한다() {
            // when
            DiscordMessageDto message = factory.createScheduledReport(어제_리포트(신고_문의_없음()));

            // then
            assertThat(필드_값(message, FIELD_RETENTION)).contains("D1 33.3% (1/3명) ▲8.3%p");
        }

        @Test
        void 대상_인원이_없으면_가입자_없음으로_표시한다() {
            // when
            DiscordMessageDto message = factory.createScheduledReport(어제_리포트(신고_문의_없음()));

            // then
            assertThat(필드_값(message, FIELD_RETENTION)).contains("D7 - (가입자 없음)");
        }
    }

    @Nested
    @DisplayName("신고와 문의 목록을 표기할 때")
    class FormatReportsAndInquiries {

        @Test
        void 새로_들어온_건이_없으면_없음으로_표시한다() {
            // when
            DiscordMessageDto message = factory.createScheduledReport(어제_리포트(신고_문의_없음()));

            // then
            assertSoftly(softly -> {
                softly.assertThat(필드_값(message, FIELD_REPORTS)).isEqualTo("신규 0건 · 미처리 총 0건\n새로 들어온 신고 없음");
                softly.assertThat(필드_값(message, FIELD_INQUIRIES)).isEqualTo("신규 0건 · 미답변 총 0건\n새로 들어온 문의 없음");
            });
        }

        @Test
        void 유형별_건수와_유형_문제번호_목록을_보여준다() {
            // given
            ReportInquiryMetricDto reportsAndInquiries = ReportInquiryMetricDto.of(
                    List.of(new TypeCountDto("TYPO_ERROR", 2), new TypeCountDto("ANSWER_ERROR", 1)),
                    5,
                    List.of(
                            new ReportItemDto(3L, "TYPO_ERROR", 1024L, GENERATED_AT),
                            new ReportItemDto(2L, "ANSWER_ERROR", 512L, GENERATED_AT),
                            new ReportItemDto(1L, "TYPO_ERROR", 87L, GENERATED_AT)
                    ),
                    List.of(),
                    0,
                    List.of()
            );

            // when
            DiscordMessageDto message = factory.createScheduledReport(어제_리포트(reportsAndInquiries));

            // then
            assertThat(필드_값(message, FIELD_REPORTS)).isEqualTo("""
                    신규 3건 (오타 2, 정답 오류 1) · 미처리 총 5건
                    - 오타 · 문제 #1024
                    - 정답 오류 · 문제 #512
                    - 오타 · 문제 #87""");
        }

        @Test
        void 목록_건수_제한으로_빠진_건은_외_N건으로_표시한다() {
            // given
            List<InquiryItemDto> inquiries = LongStream.rangeClosed(1, 10)
                    .mapToObj(id -> new InquiryItemDto(id, "BUG_REPORT", "문의 " + id, GENERATED_AT))
                    .toList();
            ReportInquiryMetricDto reportsAndInquiries = ReportInquiryMetricDto.of(
                    List.of(),
                    0,
                    List.of(),
                    List.of(new TypeCountDto("BUG_REPORT", 15)),
                    7,
                    inquiries
            );

            // when
            DiscordMessageDto message = factory.createScheduledReport(어제_리포트(reportsAndInquiries));

            // then
            assertThat(필드_값(message, FIELD_INQUIRIES))
                    .startsWith("신규 15건 (버그 15) · 미답변 총 7건\n- 버그 · 문의 1")
                    .endsWith("- 버그 · 문의 10\n외 5건");
        }

        @Test
        void 문의_제목이_50자를_넘으면_자르고_말줄임표를_붙인다() {
            // given
            String longTitle = "가".repeat(60);
            ReportInquiryMetricDto reportsAndInquiries = ReportInquiryMetricDto.of(
                    List.of(),
                    0,
                    List.of(),
                    List.of(new TypeCountDto("OTHER", 1)),
                    1,
                    List.of(new InquiryItemDto(1L, "OTHER", longTitle, GENERATED_AT))
            );

            // when
            DiscordMessageDto message = factory.createScheduledReport(어제_리포트(reportsAndInquiries));

            // then
            assertThat(필드_값(message, FIELD_INQUIRIES)).contains("- 기타 · " + "가".repeat(50) + "…");
        }

        @Test
        void 필드_값이_1024자를_넘으면_목록을_줄이고_외_N건으로_표시한다() {
            // given
            String title = "나".repeat(50);
            List<InquiryItemDto> inquiries = LongStream.rangeClosed(1, 30)
                    .mapToObj(id -> new InquiryItemDto(id, "OTHER", title, GENERATED_AT))
                    .toList();
            ReportInquiryMetricDto reportsAndInquiries = ReportInquiryMetricDto.of(
                    List.of(),
                    0,
                    List.of(),
                    List.of(new TypeCountDto("OTHER", 30)),
                    30,
                    inquiries
            );

            // when
            DiscordMessageDto message = factory.createScheduledReport(어제_리포트(reportsAndInquiries));

            // then
            String value = 필드_값(message, FIELD_INQUIRIES);
            long shownCount = value.lines().filter(line -> line.startsWith("- ")).count();
            assertSoftly(softly -> {
                softly.assertThat(value.length()).isLessThanOrEqualTo(1024);
                softly.assertThat(shownCount).isLessThan(30);
                softly.assertThat(value).endsWith("외 " + (30 - shownCount) + "건");
            });
        }
    }
}
