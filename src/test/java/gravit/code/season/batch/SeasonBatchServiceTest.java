package gravit.code.season.batch;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.dto.internal.LeagueRankEntry;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import gravit.code.userLeagueHistory.repository.UserLeagueHistoryRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.support.TransactionTemplate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;


@TCSpringBootTest
class SeasonBatchServiceTest {

    @Autowired SeasonBatchService seasonBatchService;
    @Autowired SeasonRepository seasonRepository;
    @Autowired UserLeagueRepository userLeagueRepository;
    @Autowired LeagueRankingStore leagueRankingStore;
    @Autowired UserLeagueHistoryRepository historyRepository;
    @PersistenceContext EntityManager entityManager;
    @Autowired TransactionTemplate transactionTemplate;

    @Autowired UserFixture userFixture;
    @Autowired LeagueFixture leagueFixture;
    @Autowired SeasonFixture seasonFixture;
    @Autowired UserLeagueFixture userLeagueFixture;

    // 소프트 리셋 검증에 필요한 리그 (sort_order 기준 매핑)
    // B3(1)→B3(1)/0LP, S3(4)→B2(2)/101LP, G1(9)→S1(6)/621LP
    private League bronze3;
    private League bronze2;
    private League silver3;
    private League silver1;
    private League gold1;
    private Season currentSeason;

    @BeforeEach
    void setUpLeaguesAndSeason() {
        bronze3 = leagueFixture.브론즈_3();
        bronze2 = leagueFixture.브론즈_2();
        silver3 = leagueFixture.실버_3();
        silver1 = leagueFixture.실버_1();
        gold1   = leagueFixture.골드_1();

        currentSeason = seasonFixture.진행중인_시즌("2025-S1");
    }

    @Nested
    @DisplayName("시즌 롤오버 실행 시")
    class WhenRollover {

        @Test
        @DisplayName("직전 시즌 티어 기반으로 소프트 리셋이 적용된다")
        void 소프트_리셋_매핑이_올바르게_적용된다() {
            User user1 = userFixture.일반_유저(1);
            User user2 = userFixture.일반_유저(2);
            User user3 = userFixture.일반_유저(3);

            userLeagueRepository.save(UserLeague.create(user1, currentSeason, bronze3)); // sort=1 → sort=1, LP=0
            userLeagueRepository.save(UserLeague.create(user2, currentSeason, silver3)); // sort=4 → sort=2, LP=101
            userLeagueRepository.save(UserLeague.create(user3, currentSeason, gold1));   // sort=9 → sort=6, LP=621

            seasonBatchService.finalizeAndRollover();

            // native SQL 벌크 업데이트 후 JPA 1차 캐시 무효화
            entityManager.clear();

            transactionTemplate.executeWithoutResult((status) ->{
                Season updatedSeason = seasonRepository.findById(currentSeason.getId()).orElseThrow();
                Season nextSeason = seasonRepository.findBySeasonKey("2025-S2").orElseThrow();
                UserLeague ul1 = userLeagueRepository.findByUserId(user1.getId()).orElseThrow();
                UserLeague ul2 = userLeagueRepository.findByUserId(user2.getId()).orElseThrow();
                UserLeague ul3 = userLeagueRepository.findByUserId(user3.getId()).orElseThrow();

                assertSoftly(softly -> {
                    // 현재 시즌 재조회
                    softly.assertThat(updatedSeason.getStatus()).isEqualTo(SeasonStatus.CLOSED);
                    softly.assertThat(nextSeason.getStatus()).isEqualTo(SeasonStatus.ACTIVE);

                    softly.assertThat(ul1.getLp()).isEqualTo(0);
                    softly.assertThat(ul1.getLeague().getSortOrder()).isEqualTo(1); // 브론즈 3 유지

                    softly.assertThat(ul2.getLp()).isEqualTo(101);
                    softly.assertThat(ul2.getLeague().getSortOrder()).isEqualTo(2); // 실버3 → 브론즈2

                    softly.assertThat(ul3.getLp()).isEqualTo(621);
                    softly.assertThat(ul3.getLeague().getSortOrder()).isEqualTo(6); // 골드1 → 실버1
                });
            });
        }

        @Test
        @DisplayName("다음 PREP 시즌이 없으면 새로 생성한다")
        void 다음_시즌이_없으면_새로_생성하고_활성화한다() {
            seasonBatchService.finalizeAndRollover();
            entityManager.clear();

            Season updatedSeason = seasonRepository.findById(currentSeason.getId()).orElseThrow();
            assertThat(seasonRepository.findBySeasonKey("2025-S2")).isPresent();
            assertThat(updatedSeason.getStatus()).isEqualTo(SeasonStatus.CLOSED);
        }

        @Test
        @DisplayName("다음 시즌 랭킹이 재구축되고 이전 시즌 랭킹은 삭제된다")
        void 랭킹이_다음_시즌으로_이관된다() {
            User user = userFixture.일반_유저(1);
            userLeagueRepository.save(UserLeague.create(user, currentSeason, silver3)); // sort=4 → 브론즈2, LP=101
            leagueRankingStore.put(currentSeason.getId(), silver3.getId(), user.getId(), 400);

            seasonBatchService.finalizeAndRollover();
            entityManager.clear();

            Season nextSeason = seasonRepository.findBySeasonKey("2025-S2").orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.hasRanking(currentSeason.getId())).isFalse();
                softly.assertThat(leagueRankingStore.findPage(nextSeason.getId(), bronze2.getId(), 0, 10))
                        .singleElement()
                        .extracting(LeagueRankEntry::userId, LeagueRankEntry::leaguePoint)
                        .containsExactly(user.getId(), 101);
            });
        }

        @Test
        @DisplayName("최종 순위의 동점은 먼저 가입한 유저가 앞선다")
        void 최종_순위의_동점은_user_id_오름차순이다() {
            // given - 같은 리그, 같은 LP. updated_at 은 나중에 가입한 유저가 더 이르게 만든다.
            //         옛 기준(updated_at ASC 우선)이면 순위가 뒤집힌다.
            User earlier = userFixture.일반_유저(1);
            User later = userFixture.일반_유저(2);
            userLeagueFixture.참여(earlier, currentSeason, silver3, 400);
            userLeagueFixture.참여(later, currentSeason, silver3, 400);

            updateUserLeagueUpdatedAt(earlier.getId(), 0);
            updateUserLeagueUpdatedAt(later.getId(), 1);

            // when
            seasonBatchService.finalizeAndRollover();
            entityManager.clear();

            // then
            assertSoftly(softly -> {
                softly.assertThat(finalRankOf(earlier.getId())).isEqualTo(1);
                softly.assertThat(finalRankOf(later.getId())).isEqualTo(2);
            });
        }

        private void updateUserLeagueUpdatedAt(
                long userId,
                int daysAgo
        ) {
            transactionTemplate.executeWithoutResult(status ->
                    entityManager.createNativeQuery("""
                                    UPDATE user_league
                                    SET updated_at = now() - (:daysAgo * INTERVAL '1 day')
                                    WHERE user_id = :userId
                                    """)
                            .setParameter("daysAgo", daysAgo)
                            .setParameter("userId", userId)
                            .executeUpdate());
        }

        private int finalRankOf(long userId) {
            return historyRepository.findByUserIdAndSeasonId(userId, currentSeason.getId())
                    .orElseThrow()
                    .getFinalRank();
        }

        @Test
        @DisplayName("ACTIVE 시즌이 없으면 예외를 던진다")
        void ACTIVE_시즌이_없으면_예외를_던진다() {
            // 현재 시즌을 CLOSED 상태로 변환
            Season activeSeason = seasonRepository.findByStatus(SeasonStatus.ACTIVE).orElseThrow();
            activeSeason.finalizing();
            activeSeason.close();

            seasonRepository.save(activeSeason);

            assertThatThrownBy(() -> seasonBatchService.finalizeAndRollover())
                    .isInstanceOf(RestApiException.class);
        }
    }
}
