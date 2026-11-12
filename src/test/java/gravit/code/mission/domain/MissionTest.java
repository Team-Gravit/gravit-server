package gravit.code.mission.domain;

import gravit.code.mission.fixture.MissionFixture;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

class MissionTest {

    private static final int ACCURACY_PERFECT = 100;
    private static final int ACCURACY_NOT_PERFECT = 99;
    private static final int LEARNING_TIME = 120;

    @Nested
    @DisplayName("레슨 완료 이벤트의 진행량을 계산할 때")
    class CalculateLessonIncrement {

        @Test
        void 레슨_완료_미션은_정답율과_무관하게_1을_반환한다() {
            // given
            Mission mission = MissionFixture.미션정의_레슨_3개();

            // when
            int increment = mission.calculateLessonIncrement(ACCURACY_NOT_PERFECT, LEARNING_TIME);

            // then
            assertThat(increment).isEqualTo(1);
        }

        @Test
        void 정답율_100_미션은_정답율이_100일_때만_1을_반환한다() {
            // given
            Mission mission = MissionFixture.미션정의_정답율_100_레슨_1개();

            // when
            int perfect = mission.calculateLessonIncrement(ACCURACY_PERFECT, LEARNING_TIME);
            int notPerfect = mission.calculateLessonIncrement(ACCURACY_NOT_PERFECT, LEARNING_TIME);

            // then
            assertSoftly(softly -> {
                softly.assertThat(perfect).isEqualTo(1);
                softly.assertThat(notPerfect).isZero();
            });
        }

        @Test
        void 학습_시간_미션은_학습_초를_그대로_반환한다() {
            // given
            Mission mission = MissionFixture.미션정의_학습_15분();

            // when
            int increment = mission.calculateLessonIncrement(ACCURACY_NOT_PERFECT, LEARNING_TIME);

            // then
            assertThat(increment).isEqualTo(LEARNING_TIME);
        }

        @Test
        void 학습_시간_미션은_1회_반영_상한을_넘지_않는다() {
            // given
            Mission mission = MissionFixture.미션정의_학습_15분();

            // when
            int increment = mission.calculateLessonIncrement(ACCURACY_NOT_PERFECT, 400);

            // then
            assertThat(increment).isEqualTo(300);
        }

        @Test
        void 팔로우_미션은_레슨_이벤트에_반응하지_않는다() {
            // given
            Mission mission = MissionFixture.미션정의_팔로우();

            // when
            int increment = mission.calculateLessonIncrement(ACCURACY_PERFECT, LEARNING_TIME);

            // then
            assertThat(increment).isZero();
        }
    }

    @Nested
    @DisplayName("팔로우 이벤트의 진행량을 계산할 때")
    class CalculateFollowIncrement {

        @Test
        void 팔로우_미션이면_1을_반환한다() {
            // given
            Mission mission = MissionFixture.미션정의_팔로우();

            // when
            int increment = mission.calculateFollowIncrement();

            // then
            assertThat(increment).isEqualTo(1);
        }

        @Test
        void 팔로우_미션이_아니면_0을_반환한다() {
            // given
            Mission mission = MissionFixture.미션정의_레슨_1개();

            // when
            int increment = mission.calculateFollowIncrement();

            // then
            assertThat(increment).isZero();
        }
    }

    @Nested
    @DisplayName("목표 달성 여부를 판정할 때")
    class IsAchieved {

        @Test
        void 진행량이_목표에_도달하면_참을_반환한다() {
            // given
            Mission mission = MissionFixture.미션정의_레슨_3개();

            // when & then
            assertSoftly(softly -> {
                softly.assertThat(mission.isAchieved(2)).isFalse();
                softly.assertThat(mission.isAchieved(3)).isTrue();
                softly.assertThat(mission.isAchieved(4)).isTrue();
            });
        }
    }

    @Nested
    @DisplayName("진행률을 백분율로 환산할 때")
    class CalculateProgressRate {

        @Test
        void 레슨_1개_미션에서_1개를_완료하면_100이다() {
            // given
            Mission mission = MissionFixture.미션정의_레슨_1개();

            // when & then
            assertThat(mission.calculateProgressRate(1)).isEqualTo(100.0);
        }

        @Test
        void 레슨_3개_미션의_진행률은_소수_첫째_자리로_반올림된다() {
            // given
            Mission mission = MissionFixture.미션정의_레슨_3개();

            // when & then
            assertSoftly(softly -> {
                softly.assertThat(mission.calculateProgressRate(0)).isEqualTo(0.0);
                softly.assertThat(mission.calculateProgressRate(1)).isEqualTo(33.3);
                softly.assertThat(mission.calculateProgressRate(2)).isEqualTo(66.7);
                softly.assertThat(mission.calculateProgressRate(3)).isEqualTo(100.0);
            });
        }

        @Test
        void 진행량이_목표를_넘어도_100을_넘지_않는다() {
            // given
            Mission mission = MissionFixture.미션정의_레슨_3개();

            // when & then
            assertThat(mission.calculateProgressRate(5)).isEqualTo(100.0);
        }

        @Test
        void 학습_5분_미션에서_120초를_학습하면_40이다() {
            // given
            Mission mission = MissionFixture.미션정의_학습_5분();

            // when & then
            assertThat(mission.calculateProgressRate(120)).isEqualTo(40.0);
        }

        @Test
        void 학습_15분_미션의_목표는_900초다() {
            // given
            Mission mission = MissionFixture.미션정의_학습_15분();

            // when & then
            assertSoftly(softly -> {
                softly.assertThat(mission.calculateProgressRate(600)).isEqualTo(66.7);
                softly.assertThat(mission.calculateProgressRate(900)).isEqualTo(100.0);
            });
        }
    }
}
