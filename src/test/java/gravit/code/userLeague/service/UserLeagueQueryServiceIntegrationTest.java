package gravit.code.userLeague.service;

import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.dto.internal.LeagueRankRowDto;
import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class UserLeagueQueryServiceIntegrationTest {

    @Autowired
    private UserLeagueQueryService userLeagueQueryService;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private LeagueFixture leagueFixture;

    @Autowired
    private SeasonFixture seasonFixture;

    @Autowired
    private UserLeagueFixture userLeagueFixture;

    @Nested
    @DisplayName("내 리그 랭킹과 프로필을 조회할 때")
    class GetMyLeagueRankWithProfile {

        @Test
        void 리그에_참여한_유저이면_랭킹과_프로필을_반환한다() {
            // given
            User user = userFixture.일반_유저(1);
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            userLeagueFixture.참여(user, season, league, 50);

            // when
            MyLeagueRankWithProfileResponse result = userLeagueQueryService.getMyLeagueRankWithProfile(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.userId()).isEqualTo(user.getId());
                softly.assertThat(result.leagueId()).isEqualTo(league.getId());
                softly.assertThat(result.lp()).isEqualTo(50);
                softly.assertThat(result.rank()).isEqualTo(1);
                softly.assertThat(result.nickname()).isEqualTo(user.getNickname());
            });
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userLeagueQueryService.getMyLeagueRankWithProfile(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("리그별 랭킹을 페이징 조회할 때")
    class FindLeagueRanking {

        @Test
        void 해당_리그_참여자들의_랭킹을_반환한다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");

            User user1 = userFixture.일반_유저(1);
            User user2 = userFixture.일반_유저(2);
            userLeagueFixture.참여(user1, season, league, 80);
            userLeagueFixture.참여(user2, season, league, 40);

            // when
            SliceResponse<LeagueRankRowDto> result = userLeagueQueryService.findLeagueRanking(league.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(2);
                softly.assertThat(result.contents().get(0).userId()).isEqualTo(user1.getId()); // LP 높은 순
                softly.assertThat(result.contents().get(1).userId()).isEqualTo(user2.getId());
            });
        }

        @Test
        void 참여자가_없는_리그는_빈_결과를_반환한다() {
            // given
            League league = leagueFixture.브론즈_3();

            // when
            SliceResponse<LeagueRankRowDto> result = userLeagueQueryService.findLeagueRanking(league.getId(), 0);

            // then
            assertThat(result.contents()).isEmpty();
        }

        @Test
        void 음수_페이지는_0페이지로_처리한다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, league, 50);

            // when - 음수 page 전달
            SliceResponse<LeagueRankRowDto> result = userLeagueQueryService.findLeagueRanking(league.getId(), -5);

            // then - 정상 응답 반환
            assertThat(result.contents()).hasSize(1);
        }
    }

    @Nested
    @DisplayName("유저 기준 리그 랭킹을 페이징 조회할 때")
    class FindLeagueRankingByUser {

        @Test
        void 유저가_속한_리그의_랭킹을_반환한다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User user1 = userFixture.일반_유저(1);
            User user2 = userFixture.일반_유저(2);
            userLeagueFixture.참여(user1, season, league, 60);
            userLeagueFixture.참여(user2, season, league, 30);

            // when
            SliceResponse<LeagueRankRowDto> result = userLeagueQueryService.findLeagueRankingByUser(user1.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(2);
                softly.assertThat(result.contents().get(0).userId()).isEqualTo(user1.getId());
            });
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userLeagueQueryService.findLeagueRankingByUser(nonExistentUserId, 0))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }

        @Test
        void 음수_페이지는_0페이지로_처리한다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, league, 50);

            // when
            SliceResponse<LeagueRankRowDto> result = userLeagueQueryService.findLeagueRankingByUser(user.getId(), -3);

            // then
            assertThat(result.contents()).hasSize(1);
        }
    }
}
