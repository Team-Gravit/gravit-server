package gravit.code.userLeagueHistory.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.dto.response.LeagueHistoryResponse;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
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
class LeagueHistoryServiceTest {

    @Autowired LeagueHistoryService leagueHistoryService;

    @Autowired SeasonFixture seasonFixture;
    @Autowired UserFixture userFixture;
    @Autowired LeagueFixture leagueFixture;
    @Autowired UserLeagueFixture userLeagueFixture;
    @Autowired UserLeagueHistoryFixture historyFixture;

    @Nested
    @DisplayName("ACTIVE 시즌이 없을 때")
    class WhenNoActiveSeason {

        @Test
        void ACTIVE_시즌이_없으면_예외를_던진다() {
            assertThatThrownBy(() -> leagueHistoryService.getMyLeagueHistory(1L))
                    .isInstanceOf(RestApiException.class);
        }
    }

    @Nested
    @DisplayName("리그 히스토리 조회")
    class GetMyLeagueHistory {

        Season activeSeason;
        User user;
        League bronze3; // sortOrder 1
        League silver3; // sortOrder 4
        League gold3;   // sortOrder 7

        @BeforeEach
        void setUp() {
            activeSeason = seasonFixture.진행중인_시즌("2025-S2");
            user = userFixture.일반_유저(1);
            bronze3 = leagueFixture.브론즈_3();
            silver3 = leagueFixture.실버_3();
            gold3 = leagueFixture.골드_3();
        }

        @Test
        void 첫_시즌_참여_유저는_현재_시즌_데이터만_반환한다() {
            // given
            userLeagueFixture.참여(user, activeSeason, bronze3, 50);

            // when
            LeagueHistoryResponse result = leagueHistoryService.getMyLeagueHistory(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.totalSeasonCount()).isEqualTo(1);
                softly.assertThat(result.top3SeasonCount()).isEqualTo(0);
                softly.assertThat(result.bestLeagueName()).isEqualTo("브론즈 3");
                softly.assertThat(result.seasonHistory()).hasSize(1);
                softly.assertThat(result.seasonHistory().get(0).seasonKey()).isEqualTo("2025-S2");
            });
        }

        @Test
        void 과거_시즌_기록이_현재_시즌보다_먼저_표시된다() {
            // given
            Season closedSeason = seasonFixture.종료된_시즌("2025-S1");
            historyFixture.히스토리_생성(closedSeason, user, silver3, 2, 500);
            userLeagueFixture.참여(user, activeSeason, bronze3, 50);

            // when
            LeagueHistoryResponse result = leagueHistoryService.getMyLeagueHistory(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.totalSeasonCount()).isEqualTo(2);
                softly.assertThat(result.seasonHistory()).hasSize(2);
                softly.assertThat(result.seasonHistory().get(0).seasonKey()).isEqualTo("2025-S1");
                softly.assertThat(result.seasonHistory().get(1).seasonKey()).isEqualTo("2025-S2");
            });
        }

        @Nested
        @DisplayName("top3SeasonCount")
        class Top3SeasonCount {

            @Test
            void rank_3위_이내인_종료된_시즌만_카운팅한다() {
                // given
                Season s1 = seasonFixture.종료된_시즌("2024-S1");
                Season s2 = seasonFixture.종료된_시즌("2024-S2");
                historyFixture.히스토리_생성(s1, user, silver3, 3, 450); // rank 3 → 카운팅
                historyFixture.히스토리_생성(s2, user, bronze3, 4, 50);  // rank 4 → 미포함
                userLeagueFixture.참여(user, activeSeason, bronze3, 50);

                // when
                LeagueHistoryResponse result = leagueHistoryService.getMyLeagueHistory(user.getId());

                // then
                assertThat(result.top3SeasonCount()).isEqualTo(1);
            }

            @Test
            void 현재_시즌_순위는_top3_카운팅에서_제외된다() {
                // given - 현재 시즌에서 단독 1위여도 카운팅되지 않음
                userLeagueFixture.참여(user, activeSeason, bronze3, 100);

                // when
                LeagueHistoryResponse result = leagueHistoryService.getMyLeagueHistory(user.getId());

                // then
                assertThat(result.top3SeasonCount()).isEqualTo(0);
            }
        }

        @Nested
        @DisplayName("역대 최고 티어")
        class BestLeague {

            @Test
            void 과거_시즌_중_가장_높은_티어를_반환한다() {
                // given
                Season closedSeason = seasonFixture.종료된_시즌("2025-S1");
                historyFixture.히스토리_생성(closedSeason, user, gold3, 1, 900); // sortOrder 7
                userLeagueFixture.참여(user, activeSeason, bronze3, 50);          // sortOrder 1

                // when
                LeagueHistoryResponse result = leagueHistoryService.getMyLeagueHistory(user.getId());

                // then
                assertThat(result.bestLeagueName()).isEqualTo("골드 3");
            }

            @Test
            void 현재_시즌이_역대_최고_티어면_현재_시즌_티어를_반환한다() {
                // given
                Season closedSeason = seasonFixture.종료된_시즌("2025-S1");
                historyFixture.히스토리_생성(closedSeason, user, bronze3, 1, 50); // sortOrder 1
                userLeagueFixture.참여(user, activeSeason, gold3, 900);            // sortOrder 7

                // when
                LeagueHistoryResponse result = leagueHistoryService.getMyLeagueHistory(user.getId());

                // then
                assertThat(result.bestLeagueName()).isEqualTo("골드 3");
            }
        }

        @Nested
        @DisplayName("현재 시즌 순위")
        class CurrentSeasonRank {

            @Test
            void 같은_리그에서_LP가_가장_높으면_1위이다() {
                // given
                User other = userFixture.일반_유저(2);
                userLeagueFixture.참여(user, activeSeason, bronze3, 100);  // 1위
                userLeagueFixture.참여(other, activeSeason, bronze3, 50);  // 2위

                // when
                LeagueHistoryResponse result = leagueHistoryService.getMyLeagueHistory(user.getId());

                // then
                assertThat(result.currentSeasonRank()).isEqualTo(1);
            }

            @Test
            void 같은_리그에서_LP가_낮으면_2위이다() {
                // given
                User other = userFixture.일반_유저(2);
                userLeagueFixture.참여(other, activeSeason, bronze3, 100); // 1위
                userLeagueFixture.참여(user, activeSeason, bronze3, 50);   // 2위

                // when
                LeagueHistoryResponse result = leagueHistoryService.getMyLeagueHistory(user.getId());

                // then
                assertThat(result.currentSeasonRank()).isEqualTo(2);
            }

            @Test
            void 현재_시즌에_참여하지_않으면_순위가_0이다() {
                // given & when
                LeagueHistoryResponse result = leagueHistoryService.getMyLeagueHistory(user.getId());

                // then
                assertThat(result.currentSeasonRank()).isEqualTo(0);
            }
        }
    }
}
