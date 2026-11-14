package gravit.code.league.service;

import gravit.code.league.domain.League;
import gravit.code.league.dto.response.LeagueHomeResponse;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.season.service.port.SeasonClosedCache;
import gravit.code.season.service.port.SeasonPopupSeenStore;
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
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;

import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.BDDMockito.willCallRealMethod;
import static org.mockito.BDDMockito.willThrow;


@TCSpringBootTest
class LeagueServiceTest {

    @Autowired LeagueService leagueService;
    @MockitoSpyBean SeasonClosedCache seasonClosedCache;
    @MockitoSpyBean SeasonPopupSeenStore seasonPopupSeenStore;

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
                softly.assertThat(result.lastSeasonPopupDto().finalLp()).isEqualTo(900);
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

    @Nested
    @DisplayName("리그 홈 팝업 Redis 장애")
    class LeagueHomePopupRedisFailure {

        @BeforeEach
        void setUpPopupCondition() {
            seasonClosedCache.setLastClosedSeasonId(closedSeason.getId());
            historyFixture.히스토리_생성(closedSeason, user, league, 3, 900);
            userLeagueFixture.참여(user, activeSeason, nextLeague, 321);
        }

        @Test
        void 직전_시즌_조회가_실패하면_팝업_없이_응답한다() {
            // given
            willThrow(new RedisConnectionFailureException("Redis 연결 실패"))
                    .given(seasonClosedCache).getLastClosedSeasonId();

            // when
            LeagueHomeResponse result = leagueService.enterLeagueHome(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.containsPopup()).isFalse();
                softly.assertThat(result.lastSeasonPopupDto()).isNull();
            });
        }

        @Test
        void 팝업_확인_기록이_실패하면_팝업_없이_응답한다() {
            // given
            willThrow(new RedisConnectionFailureException("Redis 연결 실패"))
                    .given(seasonPopupSeenStore).markSeenIfFirst(anyLong(), anyLong(), any(Duration.class));

            // when
            LeagueHomeResponse result = leagueService.enterLeagueHome(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.containsPopup()).isFalse();
                softly.assertThat(result.lastSeasonPopupDto()).isNull();
            });
        }

        @Test
        void 팝업_확인_기록이_실패했으면_Redis_회복_뒤_다음_접속에서_팝업이_나온다() {
            // given
            willThrow(new RedisConnectionFailureException("Redis 연결 실패"))
                    .given(seasonPopupSeenStore).markSeenIfFirst(anyLong(), anyLong(), any(Duration.class));
            leagueService.enterLeagueHome(user.getId()); // 장애 중 접속 → 팝업 없음
            willCallRealMethod()
                    .given(seasonPopupSeenStore).markSeenIfFirst(anyLong(), anyLong(), any(Duration.class));

            // when
            LeagueHomeResponse result = leagueService.enterLeagueHome(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.containsPopup()).isTrue();
                softly.assertThat(result.lastSeasonPopupDto().rank()).isEqualTo(3);
            });
        }
    }
}
