package gravit.code.league.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

import gravit.code.league.domain.League;
import gravit.code.league.dto.response.LeagueHomeResponse;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.season.service.port.SeasonClosedCache;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeagueHistory.fixture.UserLeagueHistoryFixture;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;


@TCSpringBootTest
class LeagueServiceTest {

    @Autowired LeagueService leagueService;
    @Autowired SeasonClosedCache seasonClosedCache;

    @Autowired SeasonFixture seasonFixture;
    @Autowired UserFixture userFixture;
    @Autowired LeagueFixture leagueFixture;
    @Autowired UserLeagueHistoryFixture historyFixture;
    @Autowired UserLeagueFixture userLeagueFixture;

    private Season activeSeason;
    private Season closedSeason;
    private User user;
    private League league;
    private League nextLeague;

    @BeforeEach
    void setUpBaseData() {
        activeSeason = seasonFixture.진행중인_시즌("2025-S2");
        closedSeason = seasonFixture.종료된_시즌("2025-S1");

        user = userFixture.일반_유저(1);
        league = leagueFixture.골드_3();
        nextLeague = leagueFixture.실버_3();
    }

    @Nested
    @DisplayName("리그 홈 팝업")
    class LeagueHomePopup {

        @Test
        void 직전_시즌_캐시가_없으면_팝업_없이_응답한다() {
            // given & when
            LeagueHomeResponse result = leagueService.enterLeagueHome(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.containsPopup()).isFalse();
                softly.assertThat(result.lastSeasonPopupDto()).isNull();
            });
        }

        @Test
        void 직전_시즌이_있어도_유저_히스토리가_없으면_팝업_없이_응답한다() {
            // given
            seasonClosedCache.setLastClosedSeasonId(closedSeason.getId());

            // when
            LeagueHomeResponse result = leagueService.enterLeagueHome(user.getId());

            // then
            assertThat(result.containsPopup()).isFalse();
        }

        @Test
        void 조건을_모두_만족하는_첫_접속이면_직전_시즌_결과_팝업을_포함해_응답한다() {
            // given
            seasonClosedCache.setLastClosedSeasonId(closedSeason.getId());
            historyFixture.히스토리_생성(closedSeason, user, league, 3, 900);
            userLeagueFixture.참여(user, activeSeason, nextLeague, 321);

            // when
            LeagueHomeResponse result = leagueService.enterLeagueHome(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.containsPopup()).isTrue();
                softly.assertThat(result.lastSeasonPopupDto()).isNotNull();
                softly.assertThat(result.lastSeasonPopupDto().rank()).isEqualTo(3);
                softly.assertThat(result.lastSeasonPopupDto().leagueName()).isEqualTo("골드 3");
                softly.assertThat(result.lastSeasonPopupDto().nextLeagueName()).isEqualTo("실버 3");
                softly.assertThat(result.lastSeasonPopupDto().nextStartLp()).isEqualTo(321);
            });
        }

        @Test
        void 이미_팝업을_확인한_유저는_팝업_없이_응답한다() {
            // given
            seasonClosedCache.setLastClosedSeasonId(closedSeason.getId());
            historyFixture.히스토리_생성(closedSeason, user, league, 3, 900);
            userLeagueFixture.참여(user, activeSeason, nextLeague, 321);

            leagueService.enterLeagueHome(user.getId()); // 첫 접속 → 팝업 확인 (Redis에 seen 마킹)

            // when
            LeagueHomeResponse result = leagueService.enterLeagueHome(user.getId()); // 두 번째 접속

            // then
            assertThat(result.containsPopup()).isFalse();
        }
    }
}
