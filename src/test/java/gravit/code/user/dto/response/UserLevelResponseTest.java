package gravit.code.user.dto.response;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.SoftAssertions.assertSoftly;

@DisplayName("UserLevelResponse")
class UserLevelResponseTest {

    @Nested
    @DisplayName("학습 종료 후 레벨 정보를 만들 때")
    class Create {

        @Test
        void 중간_레벨이면_다음_레벨은_현재보다_하나_높다() {
            // given & when
            UserLevelResponse response = UserLevelResponse.create(3, 250);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.currentLevel()).isEqualTo(3);
                softly.assertThat(response.nextLevel()).isEqualTo(4);
                softly.assertThat(response.xp()).isEqualTo(250);
            });
        }

        @Test
        void 최고_레벨이면_존재하지_않는_다음_레벨_대신_현재_레벨을_반환한다() {
            // given & when
            UserLevelResponse response = UserLevelResponse.create(10, 5000);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.currentLevel()).isEqualTo(10);
                softly.assertThat(response.nextLevel()).isEqualTo(10);
                softly.assertThat(response.xp()).isEqualTo(5000);
            });
        }

        @Test
        void 중간_레벨이면_현재_레벨_시작_경험치와_다음_레벨_시작_경험치를_경계값으로_반환한다() {
            // given & when
            UserLevelResponse response = UserLevelResponse.create(3, 250);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.minXp()).isEqualTo(200);
                softly.assertThat(response.maxXp()).isEqualTo(400);
            });
        }

        @Test
        void 경험치가_레벨_시작_경험치와_같으면_최소_경험치가_현재_경험치와_같다() {
            // given & when
            UserLevelResponse response = UserLevelResponse.create(3, 200);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.minXp()).isEqualTo(200);
                softly.assertThat(response.maxXp()).isEqualTo(400);
            });
        }

        @Test
        void 최고_레벨이면_최대_경험치로_현재_경험치를_반환한다() {
            // given & when
            UserLevelResponse response = UserLevelResponse.create(10, 5000);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.minXp()).isEqualTo(3700);
                softly.assertThat(response.maxXp()).isEqualTo(5000);
            });
        }

        @Test
        void 최고_레벨에_막_도달하면_최소_경험치와_최대_경험치가_같다() {
            // given & when
            UserLevelResponse response = UserLevelResponse.create(10, 3700);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.minXp()).isEqualTo(3700);
                softly.assertThat(response.maxXp()).isEqualTo(3700);
            });
        }
    }
}
