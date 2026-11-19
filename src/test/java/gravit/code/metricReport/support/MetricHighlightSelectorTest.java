package gravit.code.metricReport.support;

import gravit.code.metricReport.domain.MetricPeriod;
import gravit.code.metricReport.dto.internal.InterviewMetricDto;
import gravit.code.metricReport.dto.internal.LessonMetricDto;
import gravit.code.metricReport.dto.internal.MetricRangeDto;
import gravit.code.metricReport.dto.internal.ReportInquiryMetricDto;
import gravit.code.metricReport.dto.internal.RetentionDto;
import gravit.code.metricReport.dto.internal.ServiceMetricReportDto;
import gravit.code.metricReport.dto.internal.ServiceMetricSnapshotDto;
import gravit.code.metricReport.dto.internal.UserMetricDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class MetricHighlightSelectorTest {

    private static final MetricRangeDto WEEK = MetricRangeDto.of(LocalDate.of(2025, 7, 29), LocalDate.of(2025, 8, 4));
    private static final MetricRangeDto PREVIOUS_WEEK = MetricRangeDto.of(LocalDate.of(2025, 7, 22), LocalDate.of(2025, 7, 28));
    private static final MetricRangeDto TODAY = MetricRangeDto.of(LocalDate.of(2025, 8, 5), LocalDate.of(2025, 8, 5));

    private final MetricHighlightSelector selector = new MetricHighlightSelector(new MetricChangeFormatter());

    private static ServiceMetricSnapshotDto 스냅샷(
            MetricRangeDto range,
            long newSignups,
            double averageDau,
            long lessonSubmissions,
            Double accuracy,
            long interviewStarts
    ) {
        UserMetricDto users = UserMetricDto.of(100, newSignups, averageDau, 30, 50, YearMonth.of(2025, 8), true, new RetentionDto(0, 0), new RetentionDto(0, 0));
        return ServiceMetricSnapshotDto.of(
                range,
                users,
                new LessonMetricDto(lessonSubmissions, 5, accuracy),
                new InterviewMetricDto(interviewStarts, 0, 0)
        );
    }

    private static ReportInquiryMetricDto 미처리(
            long unresolvedReports,
            long pendingInquiries
    ) {
        return ReportInquiryMetricDto.of(List.of(), unresolvedReports, List.of(), List.of(), pendingInquiries, List.of());
    }

    private static ServiceMetricReportDto 리포트(
            MetricPeriod period,
            ServiceMetricSnapshotDto current,
            ServiceMetricSnapshotDto previous,
            ReportInquiryMetricDto pending
    ) {
        return ServiceMetricReportDto.of(period, current, previous, pending, LocalDateTime.of(2025, 8, 5, 9, 0));
    }

    @Nested
    @DisplayName("가장 크게 변한 지표를 고를 때")
    class BiggestChange {

        @Test
        void 직전_값이_10_이상인_지표_중_변화율이_가장_큰_것을_고른다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.LAST_7_DAYS,
                    스냅샷(WEEK, 30, 12.0, 100, 70.0, 3),
                    스냅샷(PREVIOUS_WEEK, 20, 10.0, 95, 70.0, 1),
                    미처리(0, 0)
            );

            // when & then
            assertThat(selector.select(report)).containsExactly("신규 가입 20명 → 30명");
        }

        @Test
        void 직전_값이_모두_10_미만이면_증감_수가_가장_큰_것을_고른다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.LAST_7_DAYS,
                    스냅샷(WEEK, 1, 5.0, 8, 70.0, 0),
                    스냅샷(PREVIOUS_WEEK, 7, 5.6, 0, 70.0, 1),
                    미처리(0, 0)
            );

            // when & then
            assertThat(selector.select(report)).containsExactly("레슨 제출 0건 → 8건");
        }

        @Test
        void 평균_DAU는_소수_첫째_자리로_쓴다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.LAST_7_DAYS,
                    스냅샷(WEEK, 10, 20.0, 10, 70.0, 0),
                    스냅샷(PREVIOUS_WEEK, 10, 12.5, 10, 70.0, 0),
                    미처리(0, 0)
            );

            // when & then
            assertThat(selector.select(report)).containsExactly("평균 DAU 12.5명 → 20.0명");
        }

        @Test
        void 모든_지표에_변화가_없으면_기본_문장을_쓴다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.LAST_7_DAYS,
                    스냅샷(WEEK, 10, 5.0, 10, 70.0, 1),
                    스냅샷(PREVIOUS_WEEK, 10, 5.0, 10, 70.0, 1),
                    미처리(0, 0)
            );

            // when & then
            assertThat(selector.select(report)).containsExactly("직전 기간과 비교해 눈에 띄는 변화가 없습니다");
        }
    }

    @Nested
    @DisplayName("비교할 수 없는 지표와 처리할 일을 고를 때")
    class IncomparableAndPending {

        @Test
        void 직전_정답률이_없으면_직전_제출_없음_줄과_미처리_줄을_차례로_붙인다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.LAST_7_DAYS,
                    스냅샷(WEEK, 1, 5.0, 8, 29.1, 0),
                    스냅샷(PREVIOUS_WEEK, 7, 5.6, 0, null, 1),
                    미처리(9, 3)
            );

            // when & then
            assertThat(selector.select(report)).containsExactly(
                    "레슨 제출 0건 → 8건",
                    "평균 정답률 29.1% · 직전 제출 없음",
                    "미처리 신고 9건 · 미답변 문의 3건"
            );
        }

        @Test
        void 미처리가_없으면_처리할_일_줄을_붙이지_않는다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.LAST_7_DAYS,
                    스냅샷(WEEK, 12, 5.0, 10, 70.0, 0),
                    스냅샷(PREVIOUS_WEEK, 10, 5.0, 10, 70.0, 0),
                    미처리(0, 0)
            );

            // when & then
            assertThat(selector.select(report)).doesNotContain("미처리 신고 0건 · 미답변 문의 0건");
        }

        @Test
        void 오늘_현황은_비교_대신_오늘_요약과_미처리_줄을_쓴다() {
            // given
            ServiceMetricReportDto report = 리포트(
                    MetricPeriod.TODAY,
                    스냅샷(TODAY, 2, 4.0, 3, 50.0, 0),
                    null,
                    미처리(1, 0)
            );

            // when & then
            assertThat(selector.select(report)).containsExactly(
                    "오늘 신규 가입 2명 · 활성 30명",
                    "미처리 신고 1건 · 미답변 문의 0건"
            );
        }
    }
}
