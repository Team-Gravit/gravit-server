package gravit.code.userLeague.service;

import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.dto.internal.LeagueRankEntryDto;
import gravit.code.userLeague.dto.internal.LeagueRankReconcileResultDto;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.clearInvocations;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class LeagueRankingReconcileServiceIntegrationTest {

    private static final long STRANGER_USER_ID = 999_999L;

    @Autowired
    private LeagueRankingReconcileService leagueRankingReconcileService;

    @MockitoSpyBean
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
    private User first;
    private User second;

    @BeforeEach
    void setUpBaseData() {
        activeSeason = seasonFixture.진행중인_시즌("2026-S2");
        bronze3 = leagueFixture.브론즈_3();
        bronze2 = leagueFixture.브론즈_2();
        first = userFixture.일반_유저(1);
        second = userFixture.일반_유저(2);
        userLeagueFixture.참여(first, activeSeason, bronze3, 50);
        userLeagueFixture.참여(second, activeSeason, bronze2, 150);
    }

    private void putAsDatabase() {
        leagueRankingStore.put(activeSeason.getId(), bronze3.getId(), first.getId(), 50);
        leagueRankingStore.put(activeSeason.getId(), bronze2.getId(), second.getId(), 150);
    }

    private List<LeagueRankEntryDto> rankingOf(League league) {
        return leagueRankingStore.findPage(activeSeason.getId(), league.getId(), 0, 10);
    }

    @Nested
    @DisplayName("시즌 랭킹을 DB와 대조할 때")
    class Reconcile {

        @Test
        void 점수가_틀린_유저를_DB_점수로_고친다() {
            // given
            leagueRankingStore.put(activeSeason.getId(), bronze3.getId(), first.getId(), 30);
            leagueRankingStore.put(activeSeason.getId(), bronze2.getId(), second.getId(), 150);

            // when
            LeagueRankReconcileResultDto result = leagueRankingReconcileService.reconcile(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.placed()).isEqualTo(1);
                softly.assertThat(rankingOf(bronze3))
                        .extracting(LeagueRankEntryDto::userId, LeagueRankEntryDto::leaguePoint)
                        .containsExactly(tuple(first.getId(), 50));
            });
        }

        @Test
        void 랭킹에_없는_유저를_넣는다() {
            // given
            leagueRankingStore.put(activeSeason.getId(), bronze2.getId(), second.getId(), 150);

            // when
            LeagueRankReconcileResultDto result = leagueRankingReconcileService.reconcile(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.placed()).isEqualTo(1);
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), first.getId()))
                        .contains(1);
            });
        }

        @Test
        void 다른_리그에_있는_유저를_DB_리그로_옮긴다() {
            // given
            leagueRankingStore.put(activeSeason.getId(), bronze2.getId(), first.getId(), 50);
            leagueRankingStore.put(activeSeason.getId(), bronze2.getId(), second.getId(), 150);

            // when
            leagueRankingReconcileService.reconcile(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), first.getId()))
                        .contains(1);
                softly.assertThat(rankingOf(bronze2))
                        .extracting(LeagueRankEntryDto::userId)
                        .containsExactly(second.getId());
            });
        }

        @Test
        void 탈퇴한_유저가_남아_있으면_그_리그를_재구축해_지운다() {
            // given
            putAsDatabase();
            userRepository.deleteById(second.getId());

            // when
            LeagueRankReconcileResultDto result = leagueRankingReconcileService.reconcile(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.scanned()).isEqualTo(1);
                softly.assertThat(result.rebuiltLeagues()).isEqualTo(1);
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze2.getId(), second.getId()))
                        .isEmpty();
                softly.assertThat(leagueRankingStore.findRank(activeSeason.getId(), bronze3.getId(), first.getId()))
                        .contains(1);
            });
        }

        @Test
        void DB에_없는_유저가_리그에_있으면_그_리그를_재구축한다() {
            // given
            putAsDatabase();
            leagueRankingStore.put(activeSeason.getId(), bronze3.getId(), STRANGER_USER_ID, 70);

            // when
            LeagueRankReconcileResultDto result = leagueRankingReconcileService.reconcile(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.rebuiltLeagues()).isEqualTo(1);
                softly.assertThat(rankingOf(bronze3))
                        .extracting(LeagueRankEntryDto::userId)
                        .containsExactly(first.getId());
                softly.assertThat(rankingOf(bronze2))
                        .extracting(LeagueRankEntryDto::userId)
                        .containsExactly(second.getId());
            });
        }

        @Test
        void 묶음_크기를_넘는_인원도_전원_대조한다() {
            // given
            for (int i = 3; i <= 1_002; i++) {
                userLeagueFixture.참여(userFixture.일반_유저(i), activeSeason, bronze3, 10);
            }

            // when
            LeagueRankReconcileResultDto result = leagueRankingReconcileService.reconcile(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.scanned()).isEqualTo(1_002);
                softly.assertThat(result.placed()).isEqualTo(1_002);
                softly.assertThat(leagueRankingStore.countRanked(activeSeason.getId())).isEqualTo(1_002);
            });
        }

        @Test
        void 어긋남이_없으면_아무것도_쓰지_않는다() {
            // given
            putAsDatabase();
            clearInvocations(leagueRankingStore);

            // when
            LeagueRankReconcileResultDto result = leagueRankingReconcileService.reconcile(activeSeason.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.scanned()).isEqualTo(2);
                softly.assertThat(result.hasMismatch()).isFalse();
            });
            verify(leagueRankingStore, never()).place(anyLong(), any(), anyLong(), anyLong(), anyInt());
            verify(leagueRankingStore, never()).evict(anyLong(), any(), anyLong());
            verify(leagueRankingStore, never()).replaceLeague(anyLong(), anyLong(), any());
        }
    }

    @Nested
    @DisplayName("진행 중인 시즌을 대조할 때")
    class ReconcileActiveSeason {

        @Test
        void 진행_중인_시즌을_대조한다() {
            // when
            LeagueRankReconcileResultDto result = leagueRankingReconcileService.reconcileActiveSeason();

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.scanned()).isEqualTo(2);
                softly.assertThat(leagueRankingStore.countRanked(activeSeason.getId())).isEqualTo(2);
            });
        }
    }
}
