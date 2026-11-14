package gravit.code.userLeague.infrastructure;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.service.LeagueRankSyncService;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.LEAGUE_RANK_USER_ID_OUT_OF_RANGE;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_LEAGUE_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.doThrow;

@TCSpringBootTest
class LeagueRankSyncRetryTargetIntegrationTest {

    private static final long SEASON_ID = 1L;
    private static final long USER_ID = 1L;

    @Autowired
    private LeagueRankSyncRetryTarget leagueRankSyncRetryTarget;

    @Autowired
    private LeagueRankingStore leagueRankingStore;

    @MockitoSpyBean
    private LeagueRankSyncService leagueRankSyncService;

    @Autowired
    private UserFixture userFixture;
    @Autowired
    private LeagueFixture leagueFixture;
    @Autowired
    private SeasonFixture seasonFixture;
    @Autowired
    private UserLeagueFixture userLeagueFixture;

    private Map<String, String> 재시도_페이로드(
            long seasonId,
            long userId
    ) {
        return Map.of(
                "seasonId", String.valueOf(seasonId),
                "userId", String.valueOf(userId)
        );
    }

    @Nested
    @DisplayName("재시도 큐 항목을 재처리할 때")
    class Reprocess {

        @Test
        void 큐_키는_리스너가_적재하는_키와_같다() {
            // when
            String queueKey = leagueRankSyncRetryTarget.queueKey();

            // then
            assertThat(queueKey).isEqualTo("league-rank-sync-retry");
        }

        @Test
        void DB의_현재_리그와_점수로_랭킹에_반영한다() {
            // given
            League bronze2 = leagueFixture.브론즈_2();
            Season season = seasonFixture.진행중인_시즌("2026-S2");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, bronze2, 150);

            // when
            leagueRankSyncRetryTarget.reprocess(재시도_페이로드(season.getId(), user.getId()));

            // then
            assertThat(leagueRankingStore.findRank(season.getId(), bronze2.getId(), user.getId())).contains(1);
        }

        @Test
        void 점수_인코딩_범위를_벗어나면_재시도하지_않고_끝낸다() {
            // given
            doThrow(new RestApiException(LEAGUE_RANK_USER_ID_OUT_OF_RANGE))
                    .when(leagueRankSyncService).syncFromDatabase(anyLong(), anyLong());

            // when & then
            assertThatCode(() -> leagueRankSyncRetryTarget.reprocess(재시도_페이로드(SEASON_ID, USER_ID)))
                    .doesNotThrowAnyException();
        }

        @Test
        void 그_밖의_실패는_다시_던져_재시도되게_한다() {
            // given
            doThrow(new RestApiException(USER_LEAGUE_NOT_FOUND))
                    .when(leagueRankSyncService).syncFromDatabase(anyLong(), anyLong());

            // when & then
            assertThatThrownBy(() -> leagueRankSyncRetryTarget.reprocess(재시도_페이로드(SEASON_ID, USER_ID)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_LEAGUE_NOT_FOUND);
        }
    }
}
