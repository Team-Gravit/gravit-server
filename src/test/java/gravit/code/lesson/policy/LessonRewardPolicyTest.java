package gravit.code.lesson.policy;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class LessonRewardPolicyTest {

    private final LessonRewardPolicy lessonRewardPolicy = new LessonRewardPolicy();

    @Nested
    @DisplayName("레슨 보상을 계산할 때")
    class Calculate {

        @Test
        void 정답률이_0이면_보상이_0이다() {
            // when
            int reward = lessonRewardPolicy.calculate(LessonRewardPolicy.BASE_REWARD_POINTS, 0);

            // then
            assertThat(reward).isZero();
        }

        @Test
        void 정답률_비율만큼_반올림해_지급한다() {
            // when - 20 × 35 ÷ 100 = 7
            int reward = lessonRewardPolicy.calculate(LessonRewardPolicy.BASE_REWARD_POINTS, 35);

            // then
            assertThat(reward).isEqualTo(7);
        }

        @Test
        void 정답률이_100이면_기본_보상을_모두_지급한다() {
            // when
            int reward = lessonRewardPolicy.calculate(LessonRewardPolicy.BASE_REWARD_POINTS, 100);

            // then
            assertThat(reward).isEqualTo(LessonRewardPolicy.BASE_REWARD_POINTS);
        }
    }
}
