package gravit.code.userLeague.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.repository.UserLeagueRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static gravit.code.global.exception.domain.CustomErrorCode.LEAGUE_NOT_MATCH_LEAGUE_POINT;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_LEAGUE_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
class UserLeaguePointServiceIntegrationTest {

    @Autowired
    private UserLeaguePointService userLeaguePointService;

    @Autowired
    private UserLeagueRepository userLeagueRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private LeagueFixture leagueFixture;

    @Autowired
    private SeasonFixture seasonFixture;

    @Autowired
    private UserLeagueFixture userLeagueFixture;

    @Nested
    @DisplayName("리그 포인트를 추가할 때")
    class AddLeaguePoints {

        @Test
        void LP가_정확도_비율만큼_누적된다() {
            // given
            League 브론즈3 = leagueFixture.브론즈_3(); // 0-100
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, 브론즈3, 0);

            // when
            userLeaguePointService.addLeaguePoints(user.getId(), 40, 100);

            // then
            // 0 + round(40 * 100 * 0.01) = 40 LP
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            assertThat(updated.getLp()).isEqualTo(40);
        }

        @Test
        void 정확도가_낮으면_적은_LP가_누적된다() {
            // given
            League 브론즈3 = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, 브론즈3, 0);

            // when
            userLeaguePointService.addLeaguePoints(user.getId(), 40, 50);

            // then
            // round(40 * 50 * 0.01) = round(20) = 20 LP
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            assertThat(updated.getLp()).isEqualTo(20);
        }

        @Test
        void LP가_다음_리그_범위에_진입하면_리그가_승급된다() {
            // given
            League 브론즈3 = leagueFixture.브론즈_3(); // 0-100
            League 브론즈2 = leagueFixture.브론즈_2(); // 101-200
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, 브론즈3, 80);

            // when - 80 + round(50 * 100 * 0.01) = 130 → 브론즈 2 범위(101-200) 진입
            userLeaguePointService.addLeaguePoints(user.getId(), 50, 100);

            // then
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            assertThat(updated.getLeague().getId()).isEqualTo(브론즈2.getId());
        }

        @Test
        void 유저리그가_존재하지_않으면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userLeaguePointService.addLeaguePoints(nonExistentUserId, 10, 100))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_LEAGUE_NOT_FOUND);
        }

        @Test
        void LP가_어떤_리그_범위에도_속하지_않으면_예외를_던진다() {
            // given - 브론즈 3(0-100)만 존재하고 브론즈 2가 없는 상태에서 LP가 101 이상이 되면 매핑 실패
            League 브론즈3 = leagueFixture.브론즈_3(); // 0-100
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, 브론즈3, 80);

            // when & then - 80 + 100 = 180 LP이지만 브론즈 2(101-200)가 없음
            assertThatThrownBy(() -> userLeaguePointService.addLeaguePoints(user.getId(), 100, 100))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LEAGUE_NOT_MATCH_LEAGUE_POINT);
        }
    }
}
