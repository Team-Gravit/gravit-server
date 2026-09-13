package gravit.code.interview.policy;

import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;

@TCSpringBootTest
class InterviewRewardPolicyIntegrationTest {

    private static final int SESSION_MAX_SCORE = 100;

    @Autowired
    private InterviewRewardPolicy interviewRewardPolicy;

    @Nested
    @DisplayName("지급량을 계산할 때")
    class Calculate {

        @ParameterizedTest
        @CsvSource({
                "100, 30",
                "80, 24",
                "60, 18",
                "0, 0"
        })
        void 세션_점수_비율에_기본_보상_30을_곱한다(
                int score,
                int expectedReward
        ) {
            // when
            int reward = interviewRewardPolicy.calculate(score, SESSION_MAX_SCORE);

            // then
            assertThat(reward).isEqualTo(expectedReward);
        }

        @ParameterizedTest
        @CsvSource({
                "1, 0",
                "2, 1",
                "57, 17",
                "59, 18"
        })
        void 소수점_첫째_자리에서_반올림한다(
                int score,
                int expectedReward
        ) {
            // when
            int reward = interviewRewardPolicy.calculate(score, SESSION_MAX_SCORE);

            // then
            assertThat(reward).isEqualTo(expectedReward);
        }

        @ParameterizedTest
        @CsvSource({
                "5, 2",
                "15, 5"
        })
        void 소수부가_정확히_절반이면_올린다(
                int score,
                int expectedReward
        ) {
            // when
            int reward = interviewRewardPolicy.calculate(score, SESSION_MAX_SCORE);

            // then
            assertThat(reward).isEqualTo(expectedReward);
        }

        @Test
        void 전달받은_만점을_기준으로_비율을_계산한다() {
            // when - round(30 × 35 ÷ 70) = 15
            int reward = interviewRewardPolicy.calculate(35, 70);

            // then
            assertThat(reward).isEqualTo(15);
        }
    }
}
