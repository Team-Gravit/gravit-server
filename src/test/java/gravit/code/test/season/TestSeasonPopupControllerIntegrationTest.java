package gravit.code.test.season;

import gravit.code.league.domain.League;
import gravit.code.league.dto.response.LeagueHomeResponse;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.league.service.LeagueService;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.season.infrastructure.RedisSeasonClosedCache;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeagueHistory.fixture.UserLeagueHistoryFixture;
import gravit.code.userLeagueHistory.repository.UserLeagueHistoryRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.test.web.servlet.MockMvc;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@TCSpringBootTest
@AutoConfigureMockMvc
class TestSeasonPopupControllerIntegrationTest {

    private static final String URI = "/api/v1/test/season/popup";
    private static final long UNKNOWN_USER_ID = 999_999L;

    @Autowired MockMvc mockMvc;
    @Autowired LeagueService leagueService;
    @Autowired RedisTemplate<String, String> redisTemplate;
    @Autowired SeasonFixture seasonFixture;
    @Autowired UserFixture userFixture;
    @Autowired LeagueFixture leagueFixture;
    @Autowired UserLeagueHistoryFixture historyFixture;
    @Autowired UserLeagueFixture userLeagueFixture;
    @Autowired UserLeagueHistoryRepository userLeagueHistoryRepository;
    @Autowired SeasonRepository seasonRepository;

    private Season activeSeason;
    private Season closedSeason;
    private User user;

    @BeforeEach
    void setUp() {
        activeSeason = seasonFixture.진행중인_시즌("2025-S2");
        closedSeason = seasonFixture.종료된_시즌("2025-S1");
        user = userFixture.일반_유저(1);
        League league = leagueFixture.골드_3();
        League nextLeague = leagueFixture.실버_3();
        historyFixture.히스토리_생성(closedSeason, user, league, 2, 700);
        userLeagueFixture.참여(user, activeSeason, nextLeague, 321);
        // 배치가 남기는 캐시가 없는 상태(= 지금의 개발 서버)에서 시작한다
        redisTemplate.delete(RedisSeasonClosedCache.LAST_CLOSED_SEASON_ID_KEY);
    }

    @Nested
    @DisplayName("시즌 팝업 다시 보기를 요청하면")
    class ResetPopup {

        @Test
        void 직전_시즌_캐시를_채우고_그_유저의_다음_리그_진입에_팝업이_뜬다() throws Exception {
            // given — 캐시가 비어 있으면 팝업이 없다
            assertThat(leagueService.enterLeagueHome(user.getId()).containsPopup()).isFalse();

            // when
            mockMvc.perform(post(URI).param("userId", String.valueOf(user.getId())))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.lastClosedSeasonId").value(closedSeason.getId()))
                    .andExpect(jsonPath("$.lastClosedSeasonKey").value("2025-S1"))
                    .andExpect(jsonPath("$.hasLeagueHistory").value(true));

            // then — 첫 진입은 팝업, 두 번째는 없음(한 번만)
            LeagueHomeResponse first = leagueService.enterLeagueHome(user.getId());
            assertThat(first.containsPopup()).isTrue();
            assertThat(first.lastSeasonPopupDto().rank()).isEqualTo(2);
            assertThat(first.lastSeasonPopupDto().finalLp()).isEqualTo(700);
            assertThat(leagueService.enterLeagueHome(user.getId()).containsPopup()).isFalse();
        }

        @Test
        void 이미_본_유저도_다시_요청하면_팝업을_다시_본다() throws Exception {
            // given — 한 번 보고 seen 키가 남은 상태
            mockMvc.perform(post(URI).param("userId", String.valueOf(user.getId()))).andExpect(status().isOk());
            leagueService.enterLeagueHome(user.getId());
            assertThat(leagueService.enterLeagueHome(user.getId()).containsPopup()).isFalse();

            // when
            mockMvc.perform(post(URI).param("userId", String.valueOf(user.getId()))).andExpect(status().isOk());

            // then
            assertThat(leagueService.enterLeagueHome(user.getId()).containsPopup()).isTrue();
        }

        @Test
        void 이력이_없는_유저는_hasLeagueHistory가_false_다() throws Exception {
            User other = userFixture.일반_유저(2);

            mockMvc.perform(post(URI).param("userId", String.valueOf(other.getId())))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.hasLeagueHistory").value(false));
        }

        @Test
        void 없는_유저면_404를_반환한다() throws Exception {
            mockMvc.perform(post(URI).param("userId", String.valueOf(UNKNOWN_USER_ID)))
                    .andExpect(status().isNotFound())
                    .andExpect(jsonPath("$.error").value(USER_NOT_FOUND.getCode()));
        }
    }

    @Nested
    @DisplayName("종료된 시즌이 없으면")
    class NoClosedSeason {

        @Test
        void 종료_시즌이_없으면_404를_반환한다() throws Exception {
            // given — 종료 시즌(과 그 이력)을 지워 CLOSED 시즌이 없는 상태를 만든다
            userLeagueHistoryRepository.deleteAll();
            seasonRepository.delete(closedSeason);

            mockMvc.perform(post(URI).param("userId", String.valueOf(user.getId())))
                    .andExpect(status().isNotFound());
        }
    }
}
