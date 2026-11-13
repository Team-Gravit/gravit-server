package gravit.code.userLeague.listener;

import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.userLeague.dto.event.LeagueRankChangedEvent;
import gravit.code.userLeague.dto.internal.LeagueRankEntryDto;
import gravit.code.userLeague.infrastructure.LeagueRankSyncRetryTarget;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class LeagueRankSyncListenerIntegrationTest {

    private static final long SEASON_ID = 1L;
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

    @Autowired
    private LeagueFixture leagueFixture;

    @MockitoSpyBean
    private RetryEventPublisher retryEventPublisher;

    private long leagueId;
    private long otherLeagueId;

    @BeforeEach
    void setUpLeagues() {
        leagueId = leagueFixture.브론즈_3().getId();
        otherLeagueId = leagueFixture.브론즈_2().getId();
    }

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
                    LeagueRankChangedEvent.joined(USER_ID, SEASON_ID, leagueId, 100);

            // when
            publishInCommittedTransaction(event);

            // then
            assertThat(leagueRankingStore.findRank(SEASON_ID, leagueId, USER_ID)).contains(1);
        }

        @Test
        void 티어가_그대로면_리그_점수만_갱신된다() {
            // given
            leagueRankingStore.put(SEASON_ID, leagueId, USER_ID, 100);
            LeagueRankChangedEvent event =
                    LeagueRankChangedEvent.pointsChanged(USER_ID, SEASON_ID, leagueId, leagueId, 300);

            // when
            publishInCommittedTransaction(event);

            // then
            List<LeagueRankEntryDto> entries = leagueRankingStore.findPage(SEASON_ID, leagueId, 0, 10);
            assertThat(entries).singleElement()
                    .extracting(LeagueRankEntryDto::leaguePoint)
                    .isEqualTo(300);
        }

        @Test
        void 티어가_바뀌면_이전_리그에서_제거된다() {
            // given
            leagueRankingStore.put(SEASON_ID, leagueId, USER_ID, 100);
            LeagueRankChangedEvent event =
                    LeagueRankChangedEvent.pointsChanged(USER_ID, SEASON_ID, leagueId, otherLeagueId, 150);

            // when
            publishInCommittedTransaction(event);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, leagueId, USER_ID)).isEmpty();
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, otherLeagueId, USER_ID)).contains(1);
            });
        }

        @Test
        void 탈퇴는_랭킹에서_제외된다() {
            // given
            leagueRankingStore.put(SEASON_ID, leagueId, USER_ID, 100);
            LeagueRankChangedEvent event =
                    LeagueRankChangedEvent.removed(USER_ID, SEASON_ID, leagueId);

            // when
            publishInCommittedTransaction(event);

            // then
            assertThat(leagueRankingStore.findRank(SEASON_ID, leagueId, USER_ID)).isEmpty();
        }
    }

    @Nested
    @DisplayName("트랜잭션이 롤백되면")
    class Rollback {

        @Test
        void 랭킹에_반영되지_않는다() {
            // given
            LeagueRankChangedEvent event =
                    LeagueRankChangedEvent.joined(USER_ID, SEASON_ID, leagueId, 100);

            // when
            transactionTemplate.executeWithoutResult(status -> {
                publisher.publishEvent(event);
                status.setRollbackOnly();
            });

            // then
            assertThat(leagueRankingStore.findRank(SEASON_ID, leagueId, USER_ID)).isEmpty();
        }
    }

    @Nested
    @DisplayName("랭킹 반영이 실패하면")
    class SyncFailure {

        @Test
        void 예외를_전파하지_않는다() {
            // given
            LeagueRankChangedEvent event = LeagueRankChangedEvent.joined(
                    ENCODING_RANGE_VIOLATING_USER_ID, SEASON_ID, leagueId, 100);

            // when & then
            assertThatCode(() -> leagueRankSyncListener.handleLeagueRankChanged(event))
                    .doesNotThrowAnyException();
        }

        @Test
        void 재시도_큐에_시즌과_유저를_적재한다() {
            // given
            LeagueRankChangedEvent event = LeagueRankChangedEvent.joined(
                    ENCODING_RANGE_VIOLATING_USER_ID, SEASON_ID, leagueId, 100);

            // when
            leagueRankSyncListener.handleLeagueRankChanged(event);

            // then
            verify(retryEventPublisher).publish(LeagueRankSyncRetryTarget.QUEUE_KEY, Map.of(
                    LeagueRankSyncRetryTarget.FIELD_SEASON_ID, String.valueOf(SEASON_ID),
                    LeagueRankSyncRetryTarget.FIELD_USER_ID, String.valueOf(ENCODING_RANGE_VIOLATING_USER_ID)
            ));
        }

        @Test
        void 재시도_큐_적재까지_실패해도_예외를_전파하지_않는다() {
            // given
            LeagueRankChangedEvent event = LeagueRankChangedEvent.joined(
                    ENCODING_RANGE_VIOLATING_USER_ID, SEASON_ID, leagueId, 100);
            doThrow(new IllegalStateException("redis down"))
                    .when(retryEventPublisher).publish(anyString(), anyMap());

            // when & then
            assertThatCode(() -> leagueRankSyncListener.handleLeagueRankChanged(event))
                    .doesNotThrowAnyException();
        }
    }

    @Nested
    @DisplayName("랭킹 반영이 성공하면")
    class SyncSuccess {

        @Test
        void 재시도_큐에_적재하지_않는다() {
            // given
            LeagueRankChangedEvent event = LeagueRankChangedEvent.joined(USER_ID, SEASON_ID, leagueId, 100);

            // when
            leagueRankSyncListener.handleLeagueRankChanged(event);

            // then
            verify(retryEventPublisher, never()).publish(anyString(), any());
        }
    }
}
