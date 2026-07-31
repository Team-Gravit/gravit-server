package gravit.code.userLeague.service;

import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.dto.internal.LeagueRankEntry;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class LeagueRankingRebuildServiceIntegrationTest {

    @Autowired
    private LeagueRankingRebuildService leagueRankingRebuildService;

    @Autowired
    private LeagueRankingStore leagueRankingStore;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SeasonFixture seasonFixture;
    @Autowired
    private UserFixture userFixture;
    @Autowired
    private LeagueFixture leagueFixture;
    @Autowired
    private UserLeagueFixture userLeagueFixture;

    private Season activeSeason;
    private League bronze3;
    private League bronze2;

    @BeforeEach
    void setUpBaseData() {
        activeSeason = seasonFixture.진행중인_시즌("2026-S2");
        bronze3 = leagueFixture.브론즈_3();
        bronze2 = leagueFixture.브론즈_2();
    }

    @Nested
    @DisplayName("시즌 전체를 재구축할 때")
    class Rebuild {

        @Test
        void 참여자_전원이_리그_점수_순으로_반영된다() {
            // given
            User first = userFixture.일반_유저(1);
            User second = userFixture.일반_유저(2);
            userLeagueFixture.참여(first, activeSeason, bronze3, 50);
            userLeagueFixture.참여(second, activeSeason, bronze3, 90);

            // when
            int rebuilt = leagueRankingRebuildService.rebuild(activeSeason.getId());

            // then
            List<LeagueRankEntry> entries =
                    leagueRankingStore.findPage(activeSeason.getId(), bronze3.getId(), 0, 10);

            assertSoftly(softly -> {
                softly.assertThat(rebuilt).isEqualTo(2);
                softly.assertThat(entries)
                        .extracting(LeagueRankEntry::rank, LeagueRankEntry::userId, LeagueRankEntry::leaguePoint)
                        .containsExactly(
                                tuple(1, second.getId(), 90),
                                tuple(2, first.getId(), 50)
                        );
            });
        }

        @Test
        void 리그별로_나뉘어_저장된다() {
            // given
            User bronze3User = userFixture.일반_유저(1);
            User bronze2User = userFixture.일반_유저(2);
            userLeagueFixture.참여(bronze3User, activeSeason, bronze3, 50);
            userLeagueFixture.참여(bronze2User, activeSeason, bronze2, 150);

            // when
            leagueRankingRebuildService.rebuild(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), bronze3User.getId()))
                        .contains(1);
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), bronze2User.getId()))
                        .isEmpty();
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze2.getId(), bronze2User.getId()))
                        .contains(1);
            });
        }

        @Test
        void 탈퇴한_유저는_제외된다() {
            // given
            User active = userFixture.일반_유저(1);
            User deleted = userFixture.일반_유저(2);
            userLeagueFixture.참여(active, activeSeason, bronze3, 50);
            userLeagueFixture.참여(deleted, activeSeason, bronze3, 90);
            userRepository.deleteById(deleted.getId());

            // when
            int rebuilt = leagueRankingRebuildService.rebuild(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(rebuilt).isEqualTo(1);
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), active.getId()))
                        .contains(1);
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), deleted.getId()))
                        .isEmpty();
            });
        }

        @Test
        void 다른_시즌_참여자는_포함되지_않는다() {
            // given
            Season closedSeason = seasonFixture.종료된_시즌("2026-S1");
            User activeSeasonUser = userFixture.일반_유저(1);
            User closedSeasonUser = userFixture.일반_유저(2);
            userLeagueFixture.참여(activeSeasonUser, activeSeason, bronze3, 50);
            userLeagueFixture.참여(closedSeasonUser, closedSeason, bronze3, 90);

            // when
            int rebuilt = leagueRankingRebuildService.rebuild(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(rebuilt).isEqualTo(1);
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), closedSeasonUser.getId()))
                        .isEmpty();
            });
        }

        @Test
        void 기존_랭킹을_교체한다() {
            // given
            User participant = userFixture.일반_유저(1);
            userLeagueFixture.참여(participant, activeSeason, bronze3, 50);

            long staleUserId = 9_999L;
            leagueRankingStore.put(activeSeason.getId(), bronze3.getId(), staleUserId, 100);

            // when
            leagueRankingRebuildService.rebuild(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), staleUserId))
                        .isEmpty();
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), participant.getId()))
                        .contains(1);
            });
        }

        @Test
        void 참여자가_없으면_반영_인원이_없다() {
            // when
            int rebuilt = leagueRankingRebuildService.rebuild(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(rebuilt).isZero();
                softly.assertThat(leagueRankingStore.hasRanking(activeSeason.getId())).isFalse();
            });
        }
    }

    @Nested
    @DisplayName("랭킹 인원이 어긋날 때만 재구축할 때")
    class RebuildIfStale {

        @Test
        void 랭킹이_없으면_재구축한다() {
            // given
            User participant = userFixture.일반_유저(1);
            userLeagueFixture.참여(participant, activeSeason, bronze3, 50);

            // when
            int rebuilt = leagueRankingRebuildService.rebuildIfStale(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(rebuilt).isEqualTo(1);
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), participant.getId()))
                        .contains(1);
            });
        }

        @Test
        void 인원이_일치하면_건너뛴다() {
            // given
            User participant = userFixture.일반_유저(1);
            userLeagueFixture.참여(participant, activeSeason, bronze3, 50);
            leagueRankingRebuildService.rebuild(activeSeason.getId());

            // when
            int rebuilt = leagueRankingRebuildService.rebuildIfStale(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(rebuilt).isZero();
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), participant.getId()))
                        .contains(1);
            });
        }

        @Test
        void 일부_유저가_누락되어_있으면_재구축한다() {
            // given - 다른 리그 키는 살아 있고 브론즈3 유저만 저장소에서 빠진 상태
            User missing = userFixture.일반_유저(1);
            User ranked = userFixture.일반_유저(2);
            userLeagueFixture.참여(missing, activeSeason, bronze3, 50);
            userLeagueFixture.참여(ranked, activeSeason, bronze2, 70);
            leagueRankingStore.put(activeSeason.getId(), bronze2.getId(), ranked.getId(), 70);

            // when
            int rebuilt = leagueRankingRebuildService.rebuildIfStale(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(rebuilt).isEqualTo(2);
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), missing.getId()))
                        .contains(1);
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze2.getId(), ranked.getId()))
                        .contains(1);
            });
        }

        @Test
        void 저장소에만_남은_유령_유저가_있으면_재구축한다() {
            // given
            User participant = userFixture.일반_유저(1);
            userLeagueFixture.참여(participant, activeSeason, bronze3, 50);
            leagueRankingRebuildService.rebuild(activeSeason.getId());

            long ghostUserId = 9_999L;
            leagueRankingStore.put(activeSeason.getId(), bronze3.getId(), ghostUserId, 100);

            // when
            int rebuilt = leagueRankingRebuildService.rebuildIfStale(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(rebuilt).isEqualTo(1);
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), ghostUserId))
                        .isEmpty();
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), participant.getId()))
                        .contains(1);
            });
        }
    }
}
