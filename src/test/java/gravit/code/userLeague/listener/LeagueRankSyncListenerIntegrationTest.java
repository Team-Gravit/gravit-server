package gravit.code.userLeague.listener;

import gravit.code.global.event.LeagueRankChangedEvent;
import gravit.code.support.TCSpringBootTest;
import gravit.code.userLeague.dto.internal.LeagueRankEntry;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class LeagueRankSyncListenerIntegrationTest {

    private static final long SEASON_ID = 1L;
    private static final long LEAGUE_ID = 10L;
    private static final long OTHER_LEAGUE_ID = 20L;
    private static final long USER_ID = 1L;
    private static final long ENCODING_RANGE_VIOLATING_USER_ID = 0L;

    @Autowired
    private LeagueRankSyncListener leagueRankSyncListener;

    @Autowired
    private LeagueRankingStore leagueRankingStore;

    @Autowired
    private ApplicationEventPublisher publisher;

    @Autowired
    private TransactionTemplate transactionTemplate;

    private void publishInCommittedTransaction(LeagueRankChangedEvent event) {
        transactionTemplate.executeWithoutResult(status -> publisher.publishEvent(event));
    }

    @Nested
    @DisplayName("커밋된 뒤 랭킹에 반영할 때")
    class AfterCommit {

        @Test
        void 신규_참여는_랭킹에_등록된다() {
            // given
            LeagueRankChangedEvent event =
                    LeagueRankChangedEvent.joined(USER_ID, SEASON_ID, LEAGUE_ID, 100);

            // when
            publishInCommittedTransaction(event);

            // then
            assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, USER_ID)).contains(1);
        }

        @Test
        void 티어가_그대로면_리그_점수만_갱신된다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, USER_ID, 100);
            LeagueRankChangedEvent event =
                    LeagueRankChangedEvent.pointsChanged(USER_ID, SEASON_ID, LEAGUE_ID, LEAGUE_ID, 300);

            // when
            publishInCommittedTransaction(event);

            // then
            List<LeagueRankEntry> entries = leagueRankingStore.findPage(SEASON_ID, LEAGUE_ID, 0, 10);
            assertThat(entries).singleElement()
                    .extracting(LeagueRankEntry::leaguePoint)
                    .isEqualTo(300);
        }

        @Test
        void 티어가_바뀌면_이전_리그에서_제거된다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, USER_ID, 100);
            LeagueRankChangedEvent event =
                    LeagueRankChangedEvent.pointsChanged(USER_ID, SEASON_ID, LEAGUE_ID, OTHER_LEAGUE_ID, 150);

            // when
            publishInCommittedTransaction(event);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, USER_ID)).isEmpty();
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, OTHER_LEAGUE_ID, USER_ID)).contains(1);
            });
        }

        @Test
        void 탈퇴는_랭킹에서_제외된다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, USER_ID, 100);
            LeagueRankChangedEvent event =
                    LeagueRankChangedEvent.removed(USER_ID, SEASON_ID, LEAGUE_ID);

            // when
            publishInCommittedTransaction(event);

            // then
            assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, USER_ID)).isEmpty();
        }
    }

    @Nested
    @DisplayName("트랜잭션이 롤백되면")
    class Rollback {

        @Test
        void 랭킹에_반영되지_않는다() {
            // given
            LeagueRankChangedEvent event =
                    LeagueRankChangedEvent.joined(USER_ID, SEASON_ID, LEAGUE_ID, 100);

            // when
            transactionTemplate.executeWithoutResult(status -> {
                publisher.publishEvent(event);
                status.setRollbackOnly();
            });

            // then
            assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, USER_ID)).isEmpty();
        }
    }

    @Nested
    @DisplayName("랭킹 반영이 실패하면")
    class SyncFailure {

        @Test
        void 예외를_전파하지_않는다() {
            // given
            LeagueRankChangedEvent event = LeagueRankChangedEvent.joined(
                    ENCODING_RANGE_VIOLATING_USER_ID, SEASON_ID, LEAGUE_ID, 100);

            // when & then
            assertThatCode(() -> leagueRankSyncListener.handleLeagueRankChanged(event))
                    .doesNotThrowAnyException();
        }
    }
}
