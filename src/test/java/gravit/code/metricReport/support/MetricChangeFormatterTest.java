package gravit.code.metricReport.support;

import gravit.code.metricReport.dto.internal.RetentionDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class MetricChangeFormatterTest {

    private final MetricChangeFormatter formatter = new MetricChangeFormatter();

    @Nested
    @DisplayName("건수 증감을 표기할 때")
    class CountChange {

        @Test
        void 직전_값이_10_이상이면_증감_수와_변화율을_붙인다() {
            // when & then
            assertThat(formatter.countChange(11, 10L)).isEqualTo("▲1 · +10.0%");
            assertThat(formatter.countChange(1_100, 1_250L)).isEqualTo("▼150 · -12.0%");
        }

        @Test
        void 직전_값이_10_미만이면_증감_수만_붙인다() {
            // when & then
            assertThat(formatter.countChange(1, 7L)).isEqualTo("▼6");
            assertThat(formatter.countChange(12, 9L)).isEqualTo("▲3");
            assertThat(formatter.countChange(8, 0L)).isEqualTo("▲8");
        }

        @Test
        void 같으면_변화_없음_화살표를_쓴다() {
            // when & then
            assertThat(formatter.countChange(15, 15L)).isEqualTo("→");
        }

        @Test
        void 비교_대상이_없으면_빈_문자열이다() {
            // when & then
            assertThat(formatter.countChange(15, null)).isEmpty();
        }
    }

    @Nested
    @DisplayName("평균과 비율 증감을 표기할 때")
    class AverageAndPercent {

        @Test
        void 평균은_소수_첫째_자리로_표기하고_005_미만_차이는_변화_없음이다() {
            // when & then
            assertThat(formatter.averageChange(5.0, 5.6)).isEqualTo("▼0.6");
            assertThat(formatter.averageChange(5.04, 5.0)).isEqualTo("→");
            assertThat(formatter.averageChange(5.0, null)).isEmpty();
        }

        @Test
        void 비율은_퍼센트포인트로_표기하고_직전_값이_없으면_직전_없음이다() {
            // when & then
            assertThat(formatter.percentPointChange(30.3, 29.1)).isEqualTo("▲1.2%p");
            assertThat(formatter.percentPointChange(29.1, null)).isEqualTo("직전 없음");
            assertThat(formatter.percentPointChange(null, 29.1)).isEmpty();
        }
    }

    @Nested
    @DisplayName("리텐션을 표기할 때")
    class Retention {

        @Test
        void 대상이_없으면_가입자_없음이다() {
            // when & then
            assertThat(formatter.retention(new RetentionDto(0, 0), new RetentionDto(20, 10))).isEqualTo("`가입자 없음`");
        }

        @Test
        void 대상이_10명_미만이면_인원으로만_쓰고_표본_적음을_붙인다() {
            // when & then
            assertThat(formatter.retention(new RetentionDto(9, 3), new RetentionDto(20, 10)))
                    .isEqualTo("**9명 중 3명** `표본 적음`");
        }

        @Test
        void 대상이_10명_이상이고_직전도_10명_이상이면_비율과_퍼센트포인트_증감을_붙인다() {
            // when & then
            assertThat(formatter.retention(new RetentionDto(50, 21), new RetentionDto(40, 16)))
                    .isEqualTo("**42.0%** (21/50명) `▲2.0%p`");
        }

        @Test
        void 직전_대상이_10명_미만이면_증감을_붙이지_않는다() {
            // when & then
            assertThat(formatter.retention(new RetentionDto(10, 5), new RetentionDto(9, 9)))
                    .isEqualTo("**50.0%** (5/10명)");
            assertThat(formatter.retention(new RetentionDto(10, 5), null))
                    .isEqualTo("**50.0%** (5/10명)");
        }
    }
}
