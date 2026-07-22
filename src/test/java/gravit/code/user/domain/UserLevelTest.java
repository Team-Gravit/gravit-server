package gravit.code.user.domain;

import gravit.code.user.dto.response.UserLevelDetailResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.SoftAssertions.assertSoftly;

@DisplayName("UserLevel VO")
class UserLevelTest {

    private static UserLevel 레벨_1_상태() {
        return UserLevel.create(1, 0);
    }

    @Nested
    @DisplayName("XP로 레벨을 계산할 때")
    class CalculateLevel {

        @Test
        void 구간_경계_XP에서_레벨이_바뀐다() {
            // given & when & then
            assertSoftly(softly -> {
                softly.assertThat(레벨(0)).isEqualTo(1);
                softly.assertThat(레벨(99)).isEqualTo(1);
                softly.assertThat(레벨(100)).isEqualTo(2);
                softly.assertThat(레벨(199)).isEqualTo(2);
                softly.assertThat(레벨(200)).isEqualTo(3);
                softly.assertThat(레벨(2899)).isEqualTo(8);
                softly.assertThat(레벨(2900)).isEqualTo(9);
                softly.assertThat(레벨(3699)).isEqualTo(9);
                softly.assertThat(레벨(3700)).isEqualTo(10);
            });
        }

        @Test
        void 최고_레벨_구간을_넘는_XP도_레벨_10에_머문다() {
            // given
            UserLevel userLevel = 레벨_1_상태();

            // when
            userLevel.updateXp(99999);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userLevel.getLevel()).isEqualTo(10);
                softly.assertThat(userLevel.getXp()).isEqualTo(99999);
            });
        }

        private int 레벨(int totalXp) {
            UserLevel userLevel = 레벨_1_상태();
            userLevel.updateXp(totalXp);
            return userLevel.getLevel();
        }
    }

    @Nested
    @DisplayName("XP를 누적할 때")
    class UpdateXp {

        @Test
        void 기존_XP에_더해진_값으로_레벨이_다시_계산된다() {
            // given
            UserLevel userLevel = 레벨_1_상태();

            // when
            userLevel.updateXp(60);
            userLevel.updateXp(60);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userLevel.getXp()).isEqualTo(120);
                softly.assertThat(userLevel.getLevel()).isEqualTo(2);
            });
        }

        @Test
        void 구간을_넘지_못하면_레벨은_그대로다() {
            // given
            UserLevel userLevel = 레벨_1_상태();

            // when
            userLevel.updateXp(50);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userLevel.getXp()).isEqualTo(50);
                softly.assertThat(userLevel.getLevel()).isEqualTo(1);
            });
        }
    }

    @Nested
    @DisplayName("레벨 상세를 조회할 때")
    class GetUserLevelDetail {

        @Test
        void 구간_시작_XP면_진행률은_0이고_maxXp는_구간_끝이다() {
            // given
            UserLevel userLevel = UserLevel.create(3, 200);

            // when
            UserLevelDetailResponse response = userLevel.getUserLevelDetail();

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.level()).isEqualTo(3);
                softly.assertThat(response.currentXp()).isEqualTo(200);
                softly.assertThat(response.maxXp()).isEqualTo(400);
                softly.assertThat(response.levelRate()).isEqualTo(0.0);
            });
        }

        @Test
        void 구간_중간_XP면_구간_내_비율로_진행률이_계산된다() {
            // given - 레벨 3 구간(200~400)의 절반
            UserLevel userLevel = UserLevel.create(3, 300);

            // when
            UserLevelDetailResponse response = userLevel.getUserLevelDetail();

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.maxXp()).isEqualTo(400);
                softly.assertThat(response.levelRate()).isEqualTo(50.0);
            });
        }

        @Test
        void 진행률은_소수점_첫째자리까지_반올림된다() {
            // given - 레벨 4 구간(400~700)에서 2/300 진행 -> 0.666...%
            UserLevel userLevel = UserLevel.create(4, 402);

            // when
            UserLevelDetailResponse response = userLevel.getUserLevelDetail();

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.maxXp()).isEqualTo(700);
                softly.assertThat(response.levelRate()).isEqualTo(0.7);
            });
        }

        @Test
        void 최고_레벨이면_maxXp는_보유_XP이고_진행률은_100이다() {
            // given
            UserLevel userLevel = UserLevel.create(10, 5000);

            // when
            UserLevelDetailResponse response = userLevel.getUserLevelDetail();

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.level()).isEqualTo(10);
                softly.assertThat(response.currentXp()).isEqualTo(5000);
                softly.assertThat(response.maxXp()).isEqualTo(5000);
                softly.assertThat(response.levelRate()).isEqualTo(100.0);
            });
        }
    }
}
