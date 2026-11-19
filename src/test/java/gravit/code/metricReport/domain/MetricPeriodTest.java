package gravit.code.metricReport.domain;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.metricReport.dto.internal.MetricRangeDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static gravit.code.global.exception.domain.CustomErrorCode.DISCORD_UNSUPPORTED_INTERACTION;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class MetricPeriodTest {

    private static final LocalDate TUESDAY = LocalDate.of(2025, 8, 5);

    private static MetricRangeDto 구간(
            String startDate,
            String endDate
    ) {
        return MetricRangeDto.of(LocalDate.parse(startDate), LocalDate.parse(endDate));
    }

    @Nested
    @DisplayName("현재 구간과 비교 구간을 계산할 때")
    class ToRange {

        @Test
        void 오늘은_오늘_하루이고_비교_구간이_없다() {
            // when & then
            assertThat(MetricPeriod.TODAY.toRange(TUESDAY)).isEqualTo(구간("2025-08-05", "2025-08-05"));
            assertThat(MetricPeriod.TODAY.toPreviousRange(TUESDAY)).isEmpty();
        }

        @Test
        void 어제는_전날_하루이고_그저께와_비교한다() {
            // when & then
            assertThat(MetricPeriod.YESTERDAY.toRange(TUESDAY)).isEqualTo(구간("2025-08-04", "2025-08-04"));
            assertThat(MetricPeriod.YESTERDAY.toPreviousRange(TUESDAY)).contains(구간("2025-08-03", "2025-08-03"));
        }

        @Test
        void 최근_7일은_어제까지_7일이고_직전_7일과_비교한다() {
            // when & then
            assertThat(MetricPeriod.LAST_7_DAYS.toRange(TUESDAY)).isEqualTo(구간("2025-07-29", "2025-08-04"));
            assertThat(MetricPeriod.LAST_7_DAYS.toPreviousRange(TUESDAY)).contains(구간("2025-07-22", "2025-07-28"));
        }

        @Test
        void 최근_30일은_어제까지_30일이고_직전_30일과_비교한다() {
            // when & then
            assertThat(MetricPeriod.LAST_30_DAYS.toRange(TUESDAY)).isEqualTo(구간("2025-07-06", "2025-08-04"));
            assertThat(MetricPeriod.LAST_30_DAYS.toPreviousRange(TUESDAY)).contains(구간("2025-06-06", "2025-07-05"));
        }

        @Test
        void 지난주는_지난주_월요일부터_일요일이고_전주와_비교한다() {
            // when & then
            assertThat(MetricPeriod.LAST_WEEK.toRange(TUESDAY)).isEqualTo(구간("2025-07-28", "2025-08-03"));
            assertThat(MetricPeriod.LAST_WEEK.toPreviousRange(TUESDAY)).contains(구간("2025-07-21", "2025-07-27"));
        }

        @Test
        void 월요일과_일요일에도_지난주는_직전_월요일부터_일요일이다() {
            // given
            LocalDate monday = LocalDate.of(2025, 8, 4);
            LocalDate sunday = LocalDate.of(2025, 8, 10);

            // when & then
            assertThat(MetricPeriod.LAST_WEEK.toRange(monday)).isEqualTo(구간("2025-07-28", "2025-08-03"));
            assertThat(MetricPeriod.LAST_WEEK.toRange(sunday)).isEqualTo(구간("2025-07-28", "2025-08-03"));
        }
    }

    @Nested
    @DisplayName("슬래시 커맨드 선택지 값을 기간으로 바꿀 때")
    class FromOptionValue {

        @Test
        void 값이_없으면_오늘이다() {
            // when & then
            assertThat(MetricPeriod.fromOptionValue(null)).isEqualTo(MetricPeriod.TODAY);
        }

        @Test
        void 선택지_값에_맞는_기간을_반환한다() {
            // when & then
            assertThat(MetricPeriod.fromOptionValue("today")).isEqualTo(MetricPeriod.TODAY);
            assertThat(MetricPeriod.fromOptionValue("yesterday")).isEqualTo(MetricPeriod.YESTERDAY);
            assertThat(MetricPeriod.fromOptionValue("7d")).isEqualTo(MetricPeriod.LAST_7_DAYS);
            assertThat(MetricPeriod.fromOptionValue("30d")).isEqualTo(MetricPeriod.LAST_30_DAYS);
            assertThat(MetricPeriod.fromOptionValue("last-week")).isEqualTo(MetricPeriod.LAST_WEEK);
        }

        @Test
        void 모르는_값이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> MetricPeriod.fromOptionValue("90d"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(DISCORD_UNSUPPORTED_INTERACTION);
        }
    }
}
