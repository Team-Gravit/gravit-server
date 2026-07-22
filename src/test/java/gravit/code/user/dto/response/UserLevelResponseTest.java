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
    }
}
