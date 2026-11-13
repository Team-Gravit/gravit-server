package gravit.code.userLeague.service;

import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.dto.event.LeagueRankChangedEvent;
import gravit.code.userLeague.dto.internal.LeagueRankEntryDto;
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
class LeagueRankSyncServiceIntegrationTest {

    @Autowired
    private LeagueRankSyncService leagueRankSyncService;

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
    private User user;

    @BeforeEach
    void setUpBaseData() {
        activeSeason = seasonFixture.진행중인_시즌("2026-S2");
        bronze3 = leagueFixture.브론즈_3();
        bronze2 = leagueFixture.브론즈_2();
        user = userFixture.일반_유저(1);
    }

    private List<LeagueRankEntryDto> rankingOf(League league) {
        return leagueRankingStore.findPage(activeSeason.getId(), league.getId(), 0, 10);
    }

    @Nested
    @DisplayName("이벤트 값으로 반영할 때")
    class Apply {

        @Test
        void 신규_참여는_랭킹에_등록된다() {
            // given
            LeagueRankChangedEvent event =
                    LeagueRankChangedEvent.joined(user.getId(), activeSeason.getId(), bronze3.getId(), 0);

            // when
            leagueRankSyncService.apply(event);

            // then
            assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), user.getId())).contains(1);
        }

        @Test
        void 티어가_바뀌면_이전_리그에서_빠지고_새_리그에_들어간다() {
            // given
            leagueRankingStore.put(activeSeason.getId(), bronze3.getId(), user.getId(), 90);
            LeagueRankChangedEvent event = LeagueRankChangedEvent.pointsChanged(
                    user.getId(), activeSeason.getId(), bronze3.getId(), bronze2.getId(), 120);

            // when
            leagueRankSyncService.apply(event);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), user.getId())).isEmpty();
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze2.getId(), user.getId())).contains(1);
            });
        }

        @Test
        void 늦게_도착한_낮은_점수는_무시된다() {
            // given
            leagueRankSyncService.apply(LeagueRankChangedEvent.pointsChanged(
                    user.getId(), activeSeason.getId(), bronze3.getId(), bronze2.getId(), 120));
            LeagueRankChangedEvent late = LeagueRankChangedEvent.pointsChanged(
                    user.getId(), activeSeason.getId(), bronze3.getId(), bronze3.getId(), 100);

            // when
            leagueRankSyncService.apply(late);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), user.getId())).isEmpty();
                softly.assertThat(rankingOf(bronze2))
                        .extracting(LeagueRankEntryDto::userId, LeagueRankEntryDto::leaguePoint)
                        .containsExactly(tuple(user.getId(), 120));
            });
        }

        @Test
        void 탈퇴는_시즌의_모든_리그에서_제외된다() {
            // given
            leagueRankingStore.put(activeSeason.getId(), bronze3.getId(), user.getId(), 90);
            leagueRankingStore.put(activeSeason.getId(), bronze2.getId(), user.getId(), 90);
            LeagueRankChangedEvent event =
                    LeagueRankChangedEvent.removed(user.getId(), activeSeason.getId(), bronze3.getId());

            // when
            leagueRankSyncService.apply(event);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), user.getId())).isEmpty();
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze2.getId(), user.getId())).isEmpty();
            });
        }

        @Test
        void 나중에_만든_리그로_옮겨도_이전_리그에서_빠진다() {
            // given
            leagueRankSyncService.apply(LeagueRankChangedEvent.joined(
                    user.getId(), activeSeason.getId(), bronze3.getId(), 90));
            League bronze1 = leagueFixture.브론즈_1();
            LeagueRankChangedEvent event = LeagueRankChangedEvent.pointsChanged(
                    user.getId(), activeSeason.getId(), bronze3.getId(), bronze1.getId(), 250);

            // when
            leagueRankSyncService.apply(event);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), user.getId())).isEmpty();
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze1.getId(), user.getId())).contains(1);
            });
        }
    }

    @Nested
    @DisplayName("DB 상태로 반영할 때")
    class SyncFromDatabase {

        @Test
        void DB의_현재_리그와_점수로_반영한다() {
            // given
            userLeagueFixture.참여(user, activeSeason, bronze2, 150);
            leagueRankingStore.put(activeSeason.getId(), bronze3.getId(), user.getId(), 90);

            // when
            leagueRankSyncService.syncFromDatabase(activeSeason.getId(), user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), user.getId())).isEmpty();
                softly.assertThat(rankingOf(bronze2))
                        .extracting(LeagueRankEntryDto::userId, LeagueRankEntryDto::leaguePoint)
                        .containsExactly(tuple(user.getId(), 150));
            });
        }

        @Test
        void 여러_번_반영해도_결과가_같다() {
            // given
            userLeagueFixture.참여(user, activeSeason, bronze2, 150);

            // when
            leagueRankSyncService.syncFromDatabase(activeSeason.getId(), user.getId());
            leagueRankSyncService.syncFromDatabase(activeSeason.getId(), user.getId());

            // then
            assertThat(rankingOf(bronze2))
                    .extracting(LeagueRankEntryDto::userId, LeagueRankEntryDto::leaguePoint)
                    .containsExactly(tuple(user.getId(), 150));
        }

        @Test
        void 탈퇴한_유저는_제외한다() {
            // given
            userLeagueFixture.참여(user, activeSeason, bronze3, 90);
            leagueRankingStore.put(activeSeason.getId(), bronze3.getId(), user.getId(), 90);
            userRepository.deleteById(user.getId());

            // when
            leagueRankSyncService.syncFromDatabase(activeSeason.getId(), user.getId());

            // then
            assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), user.getId())).isEmpty();
        }

        @Test
        void 리그에_참여하지_않은_유저는_제외한다() {
            // given
            leagueRankingStore.put(activeSeason.getId(), bronze3.getId(), user.getId(), 90);

            // when
            leagueRankSyncService.syncFromDatabase(activeSeason.getId(), user.getId());

            // then
            assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), user.getId())).isEmpty();
        }

        @Test
        void 시즌이_바뀌었으면_지난_시즌_키에서만_정리한다() {
            // given
            Season closedSeason = seasonFixture.종료된_시즌("2026-S1");
            userLeagueFixture.참여(user, activeSeason, bronze3, 50);
            leagueRankingStore.put(closedSeason.getId(), bronze3.getId(), user.getId(), 300);

            // when
            leagueRankSyncService.syncFromDatabase(closedSeason.getId(), user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(closedSeason.getId(), bronze3.getId(), user.getId())).isEmpty();
                softly.assertThat(leagueRankingStore.hasRanking(activeSeason.getId())).isFalse();
            });
        }
    }
}
