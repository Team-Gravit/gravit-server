package gravit.code.user.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@DisplayName("Level enum")
class LevelTest {

    @Nested
    @DisplayName("XP로 레벨을 찾을 때")
    class FromXp {

        @Test
        void 구간에_해당하는_레벨을_반환한다() {
            // given & when & then
            assertSoftly(softly -> {
                softly.assertThat(Level.fromXp(0)).isEqualTo(Level.LEVEL_1);
                softly.assertThat(Level.fromXp(99)).isEqualTo(Level.LEVEL_1);
                softly.assertThat(Level.fromXp(100)).isEqualTo(Level.LEVEL_2);
                softly.assertThat(Level.fromXp(399)).isEqualTo(Level.LEVEL_3);
                softly.assertThat(Level.fromXp(400)).isEqualTo(Level.LEVEL_4);
                softly.assertThat(Level.fromXp(3699)).isEqualTo(Level.LEVEL_9);
                softly.assertThat(Level.fromXp(3700)).isEqualTo(Level.LEVEL_10);
            });
        }

        @Test
        void 최고_레벨의_시작_XP를_넘어도_최고_레벨을_반환한다() {
            // given & when & then
            assertThat(Level.fromXp(Integer.MAX_VALUE)).isEqualTo(Level.LEVEL_10);
        }

        @Test
        void 음수_XP는_최저_레벨을_반환한다() {
            // given & when & then
            assertThat(Level.fromXp(-1)).isEqualTo(Level.LEVEL_1);
        }
    }

    @Nested
    @DisplayName("레벨 값으로 레벨을 찾을 때")
    class FromLevel {

        @Test
        void 일치하는_레벨을_반환한다() {
            // given & when & then
            assertSoftly(softly -> {
                softly.assertThat(Level.fromLevel(1)).isEqualTo(Level.LEVEL_1);
                softly.assertThat(Level.fromLevel(7)).isEqualTo(Level.LEVEL_7);
                softly.assertThat(Level.fromLevel(10)).isEqualTo(Level.LEVEL_10);
            });
        }

        @Test
        void 존재하지_않는_레벨이면_예외를_던진다() {
            // given & when & then
            assertThatThrownBy(() -> Level.fromLevel(11))
                    .isInstanceOf(IllegalArgumentException.class)
                    .hasMessageContaining("11");
        }

        @Test
        void 레벨이_0_이하면_예외를_던진다() {
            // given & when & then
            assertThatThrownBy(() -> Level.fromLevel(0))
                    .isInstanceOf(IllegalArgumentException.class);
        }
    }

    @Nested
    @DisplayName("최고 레벨을 판별할 때")
    class IsMax {

        @Test
        void 마지막_상수만_최고_레벨이다() {
            // given & when & then
            assertSoftly(softly -> {
                softly.assertThat(Level.LEVEL_10.isMax()).isTrue();
                softly.assertThat(Level.LEVEL_9.isMax()).isFalse();
                softly.assertThat(Level.LEVEL_1.isMax()).isFalse();
            });
        }
    }

    @Nested
    @DisplayName("구간 끝 XP를 구할 때")
    class GetEndXp {

        @Test
        void 다음_레벨의_시작_XP를_반환한다() {
            // given & when & then
            assertSoftly(softly -> {
                softly.assertThat(Level.LEVEL_1.getEndXp()).isEqualTo(Level.LEVEL_2.getStartXp());
                softly.assertThat(Level.LEVEL_1.getEndXp()).isEqualTo(100);
                softly.assertThat(Level.LEVEL_4.getEndXp()).isEqualTo(700);
                softly.assertThat(Level.LEVEL_9.getEndXp()).isEqualTo(3700);
            });
        }

        @Test
        void 최고_레벨은_상한이_없어_예외를_던진다() {
            // given & when & then
            assertThatThrownBy(Level.LEVEL_10::getEndXp)
                    .isInstanceOf(IllegalStateException.class);
        }
    }

    @Nested
    @DisplayName("구간표 자체를 검증할 때")
    class Table {

        @Test
        void 레벨_값은_1부터_1씩_증가한다() {
            // given & when & then
            assertSoftly(softly -> {
                Level[] levels = Level.values();
                for (int i = 0; i < levels.length; i++) {
                    softly.assertThat(levels[i].getLevel()).isEqualTo(i + 1);
                }
            });
        }

        @Test
        void 시작_XP는_순증가한다() {
            // given & when & then
            assertSoftly(softly -> {
                Level[] levels = Level.values();
                for (int i = 1; i < levels.length; i++) {
                    softly.assertThat(levels[i].getStartXp())
                            .as("%s의 시작 XP는 %s보다 커야 한다", levels[i], levels[i - 1])
                            .isGreaterThan(levels[i - 1].getStartXp());
                }
            });
        }

        @Test
        void 모든_XP는_어떤_레벨엔가_속한다() {
            // given & when & then
            assertSoftly(softly -> {
                for (Level level : Level.values()) {
                    softly.assertThat(Level.fromXp(level.getStartXp())).isEqualTo(level);

                    if (!level.isMax()) {
                        softly.assertThat(Level.fromXp(level.getEndXp() - 1)).isEqualTo(level);
                    }
                }
            });
        }
    }
}
