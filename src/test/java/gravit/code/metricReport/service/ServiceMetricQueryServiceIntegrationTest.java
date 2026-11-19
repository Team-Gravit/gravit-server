package gravit.code.metricReport.service;

import gravit.code.metricReport.domain.MetricPeriod;
import gravit.code.metricReport.dto.internal.InquiryItemDto;
import gravit.code.metricReport.dto.internal.ReportInquiryMetricDto;
import gravit.code.metricReport.dto.internal.ReportItemDto;
import gravit.code.metricReport.dto.internal.ServiceMetricReportDto;
import gravit.code.metricReport.dto.internal.TypeCountDto;
import gravit.code.metricReport.dto.internal.UserMetricDto;
import gravit.code.metricReport.fixture.MetricFixture;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

// 고정 시계 기준 now = 2025-08-05T12:00 (Asia/Seoul, 화요일). 어제 = 2025-08-04
@TCSpringBootTest
class ServiceMetricQueryServiceIntegrationTest {

    private static final LocalDate AUG_3 = LocalDate.of(2025, 8, 3);
    private static final LocalDate AUG_4 = LocalDate.of(2025, 8, 4);
    private static final LocalDate AUG_5 = LocalDate.of(2025, 8, 5);

    @Autowired
    private ServiceMetricQueryService serviceMetricQueryService;

    @Autowired
    private MetricFixture metricFixture;

    private static LocalDateTime 시각(
            LocalDate date,
            int hour,
            int minute
    ) {
        return date.atTime(hour, minute);
    }

    @Nested
    @DisplayName("가입 지표를 집계할 때")
    class Signups {

        @Test
        void 자정_경계를_기준으로_기간_안에_가입한_계정만_센다() {
            // given
            metricFixture.가입한_사용자(AUG_3.atTime(23, 59, 59));
            metricFixture.가입한_사용자(시각(AUG_4, 0, 0));
            metricFixture.가입한_사용자(AUG_4.atTime(23, 59, 59));
            metricFixture.가입한_사용자(시각(AUG_5, 0, 0));

            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY);

            // then
            assertSoftly(softly -> {
                softly.assertThat(report.current().users().newSignups()).isEqualTo(2);
                softly.assertThat(report.previous().users().newSignups()).isEqualTo(1);
            });
        }

        @Test
        void 탈퇴_상태_계정은_총_가입자에서_빠지고_신규_가입에는_포함된다() {
            // given
            metricFixture.가입한_사용자(시각(AUG_4, 10, 0));
            metricFixture.탈퇴한_사용자(시각(AUG_4, 11, 0));

            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY);

            // then
            assertSoftly(softly -> {
                softly.assertThat(report.current().users().totalUsers()).isEqualTo(1);
                softly.assertThat(report.current().users().newSignups()).isEqualTo(2);
            });
        }
    }

    @Nested
    @DisplayName("활성 지표를 집계할 때")
    class ActiveUsers {

        @Test
        void 여러_날_구간은_평균_DAU와_서로_다른_활성_사용자_수를_낸다() {
            // given
            long userA = metricFixture.가입한_사용자(시각(LocalDate.of(2025, 7, 1), 9, 0));
            long userB = metricFixture.가입한_사용자(시각(LocalDate.of(2025, 7, 1), 9, 0));
            metricFixture.활동_이력(userA, LocalDate.of(2025, 7, 29), LocalDate.of(2025, 7, 30));
            metricFixture.활동_이력(userB, LocalDate.of(2025, 7, 30), AUG_5);

            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.LAST_7_DAYS);

            // then
            UserMetricDto users = report.current().users();
            assertSoftly(softly -> {
                softly.assertThat(users.averageDailyActiveUsers()).isEqualTo(3.0 / 7);
                softly.assertThat(users.activeUsers()).isEqualTo(2);
            });
        }

        @Test
        void MAU는_종료일이_속한_달의_1일부터_종료일까지_세고_진행_중으로_표시한다() {
            // given
            long userA = metricFixture.가입한_사용자(시각(LocalDate.of(2025, 7, 1), 9, 0));
            long userB = metricFixture.가입한_사용자(시각(LocalDate.of(2025, 7, 1), 9, 0));
            long userC = metricFixture.가입한_사용자(시각(LocalDate.of(2025, 7, 1), 9, 0));
            metricFixture.활동_이력(userA, LocalDate.of(2025, 8, 1), AUG_4);
            metricFixture.활동_이력(userB, AUG_4);
            metricFixture.활동_이력(userC, LocalDate.of(2025, 7, 31), AUG_5);

            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY);

            // then
            UserMetricDto users = report.current().users();
            assertSoftly(softly -> {
                softly.assertThat(users.mauMonth()).isEqualTo(YearMonth.of(2025, 8));
                softly.assertThat(users.monthlyActiveUsers()).isEqualTo(2);
                softly.assertThat(users.mauInProgress()).isTrue();
                softly.assertThat(users.activeUsers()).isEqualTo(2);
            });
        }
    }

    @Nested
    @DisplayName("재방문율을 집계할 때")
    class Retention {

        @Test
        void D1은_전날_가입자_중_가입_다음_날_활동한_사용자만_센다() {
            // given
            long returned = metricFixture.가입한_사용자(시각(AUG_3, 10, 0));
            long signupDayOnly = metricFixture.가입한_사용자(시각(AUG_3, 22, 0));
            long notInCohort = metricFixture.가입한_사용자(시각(AUG_4, 9, 0));
            metricFixture.활동_이력(returned, AUG_3, AUG_4);
            metricFixture.활동_이력(signupDayOnly, AUG_3);
            metricFixture.활동_이력(notInCohort, AUG_4);

            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY);

            // then
            assertSoftly(softly -> {
                softly.assertThat(report.current().users().d1Retention().cohortSize()).isEqualTo(2);
                softly.assertThat(report.current().users().d1Retention().retainedCount()).isEqualTo(1);
                softly.assertThat(report.current().users().d1Retention().rate()).isEqualTo(0.5);
            });
        }

        @Test
        void D7은_가입_7일_뒤_그날_활동만_세고_6일_뒤나_8일_뒤_활동은_세지_않는다() {
            // given
            LocalDate july28 = LocalDate.of(2025, 7, 28);
            long returned = metricFixture.가입한_사용자(시각(july28, 10, 0));
            long missed = metricFixture.가입한_사용자(시각(july28, 11, 0));
            metricFixture.활동_이력(returned, AUG_4);
            metricFixture.활동_이력(missed, AUG_3, AUG_5);

            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY);

            // then
            assertSoftly(softly -> {
                softly.assertThat(report.current().users().d7Retention().cohortSize()).isEqualTo(2);
                softly.assertThat(report.current().users().d7Retention().retainedCount()).isEqualTo(1);
            });
        }

        @Test
        void 대상_가입자가_없으면_비율이_없다() {
            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY);

            // then
            assertSoftly(softly -> {
                softly.assertThat(report.current().users().d1Retention().cohortSize()).isZero();
                softly.assertThat(report.current().users().d1Retention().rate()).isNull();
                softly.assertThat(report.current().users().d7Retention().rate()).isNull();
            });
        }
    }

    @Nested
    @DisplayName("레슨과 면접 지표를 집계할 때")
    class LessonsAndInterviews {

        @Test
        void 레슨은_제출_수_학습자_수_평균_정답률을_낸다() {
            // given
            metricFixture.레슨_제출(1L, 80, 시각(AUG_4, 9, 0));
            metricFixture.레슨_제출(1L, 60, 시각(AUG_4, 10, 0));
            metricFixture.레슨_제출(2L, 100, 시각(AUG_4, 23, 59));
            metricFixture.레슨_제출(3L, 0, 시각(AUG_5, 0, 0));

            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY);

            // then
            assertSoftly(softly -> {
                softly.assertThat(report.current().lessons().submissionCount()).isEqualTo(3);
                softly.assertThat(report.current().lessons().learnerCount()).isEqualTo(2);
                softly.assertThat(report.current().lessons().averageAccuracy()).isEqualTo(80.0);
            });
        }

        @Test
        void 제출이_없으면_평균_정답률이_없다() {
            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY);

            // then
            assertSoftly(softly -> {
                softly.assertThat(report.current().lessons().submissionCount()).isZero();
                softly.assertThat(report.current().lessons().averageAccuracy()).isNull();
            });
        }

        @Test
        void 면접은_시작한_세션_중단을_뺀_제출_세션_채점된_답변을_센다() {
            // given
            metricFixture.면접_세션("IN_PROGRESS", 시각(AUG_4, 9, 0), null);
            metricFixture.면접_세션("COMPLETED", 시각(AUG_3, 23, 50), 시각(AUG_4, 0, 10));
            metricFixture.면접_세션("GRADING", 시각(AUG_4, 10, 0), 시각(AUG_4, 10, 20));
            metricFixture.면접_세션("ABANDONED", 시각(AUG_4, 11, 0), 시각(AUG_4, 11, 5));
            metricFixture.채점_결과(1L, 시각(AUG_4, 0, 15));
            metricFixture.채점_결과(2L, 시각(AUG_4, 10, 25));
            metricFixture.채점_결과(3L, 시각(AUG_5, 0, 0));

            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY);

            // then
            assertSoftly(softly -> {
                softly.assertThat(report.current().interviews().startedCount()).isEqualTo(3);
                softly.assertThat(report.current().interviews().submittedCount()).isEqualTo(2);
                softly.assertThat(report.current().interviews().gradedAnswerCount()).isEqualTo(2);
            });
        }
    }

    @Nested
    @DisplayName("신고와 문의를 집계할 때")
    class ReportsAndInquiries {

        @Test
        void 신고는_기간_안의_유형별_건수와_현재_미처리_총_건수를_낸다() {
            // given
            metricFixture.신고("TYPO_ERROR", 10L, false, 시각(AUG_4, 9, 0));
            metricFixture.신고("TYPO_ERROR", 11L, true, 시각(AUG_4, 10, 0));
            metricFixture.신고("ANSWER_ERROR", 12L, false, 시각(AUG_4, 11, 0));
            metricFixture.신고("CONTENT_ERROR", 13L, false, 시각(AUG_3, 9, 0));

            // when
            ReportInquiryMetricDto metric = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY).reportsAndInquiries();

            // then
            assertSoftly(softly -> {
                softly.assertThat(metric.newReportCounts()).containsExactly(
                        new TypeCountDto("TYPO_ERROR", 2),
                        new TypeCountDto("ANSWER_ERROR", 1)
                );
                softly.assertThat(metric.unresolvedReportCount()).isEqualTo(3);
                softly.assertThat(metric.newReports()).extracting(ReportItemDto::problemId).containsExactly(12L, 11L, 10L);
            });
        }

        @Test
        void 목록은_최근순으로_최대_10건만_가져온다() {
            // given
            IntStream.rangeClosed(1, 12)
                    .forEach(minute -> metricFixture.신고("OTHER_ERROR", minute, false, 시각(AUG_4, 9, minute)));

            // when
            ReportInquiryMetricDto metric = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY).reportsAndInquiries();

            // then
            assertSoftly(softly -> {
                softly.assertThat(metric.newReportTotal()).isEqualTo(12);
                softly.assertThat(metric.newReports()).hasSize(10);
                softly.assertThat(metric.newReports().getFirst().problemId()).isEqualTo(12L);
                softly.assertThat(metric.newReports().getLast().problemId()).isEqualTo(3L);
            });
        }

        @Test
        void 문의는_기간_안의_유형별_건수와_현재_미답변_총_건수와_제목_목록을_낸다() {
            // given
            metricFixture.문의("BUG_REPORT", "로그인 후 화면이 하얗게 나와요", "PENDING", 시각(AUG_4, 9, 0));
            metricFixture.문의("FEATURE_SUGGESTION", "다크모드 지원해 주세요", "RESOLVED", 시각(AUG_4, 10, 0));
            metricFixture.문의("OTHER", "지난 문의", "PENDING", 시각(AUG_3, 9, 0));

            // when
            ReportInquiryMetricDto metric = serviceMetricQueryService.getReport(MetricPeriod.YESTERDAY).reportsAndInquiries();

            // then
            assertSoftly(softly -> {
                softly.assertThat(metric.newInquiryTotal()).isEqualTo(2);
                softly.assertThat(metric.pendingInquiryCount()).isEqualTo(2);
                softly.assertThat(metric.newInquiries()).extracting(InquiryItemDto::title)
                        .containsExactly("다크모드 지원해 주세요", "로그인 후 화면이 하얗게 나와요");
            });
        }
    }

    @Nested
    @DisplayName("기간별 비교 구간을 정할 때")
    class Comparison {

        @Test
        void 오늘_현황은_비교_구간이_없다() {
            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.TODAY);

            // then
            assertSoftly(softly -> {
                softly.assertThat(report.hasPrevious()).isFalse();
                softly.assertThat(report.current().range().startDate()).isEqualTo(AUG_5);
                softly.assertThat(report.generatedAt()).isEqualTo(시각(AUG_5, 12, 0));
            });
        }

        @Test
        void 지난주는_전주와_비교한다() {
            // when
            ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.LAST_WEEK);

            // then
            assertSoftly(softly -> {
                softly.assertThat(report.current().range().startDate()).isEqualTo(LocalDate.of(2025, 7, 28));
                softly.assertThat(report.previous().range().startDate()).isEqualTo(LocalDate.of(2025, 7, 21));
            });
        }
    }
}
