package gravit.code.userLeague.infrastructure;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import gravit.code.userLeague.dto.internal.LeagueRankEntry;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.RedisTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Properties;
import java.util.stream.IntStream;

import static gravit.code.global.exception.domain.CustomErrorCode.LEAGUE_RANK_USER_ID_OUT_OF_RANGE;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class RedisLeagueRankingStoreIntegrationTest {

    private static final long SEASON_ID = 1L;
    private static final long OTHER_SEASON_ID = 2L;
    private static final long LEAGUE_ID = 10L;
    private static final long OTHER_LEAGUE_ID = 20L;
    // RedisLeagueRankingStore.ADD_BATCH_SIZE 와 같은 값. 배치 경계를 넘기는 데 쓴다.
    private static final int BATCH_SIZE = 1_000;

    @Autowired
    private RedisLeagueRankingStore leagueRankingStore;

    @Autowired
    @Qualifier("rankingRedisTemplate")
    private RedisTemplate<String, String> rankingRedisTemplate;

    private void resetCommandStats() {
        rankingRedisTemplate.execute((RedisCallback<Object>) connection -> {
            connection.serverCommands().resetConfigStats();

            return null;
        });
    }

    // INFO commandstats 의 "cmdstat_zadd:calls=3,usec=..." 에서 calls 만 뽑는다
    private long zaddCallCount() {
        Properties stats = rankingRedisTemplate.execute(
                (RedisCallback<Properties>) connection -> connection.serverCommands().info("commandstats"));

        if (stats == null) {
            return 0;
        }

        String zadd = stats.getProperty("cmdstat_zadd");

        if (zadd == null) {
            return 0;
        }

        return Long.parseLong(zadd.split(",")[0].split("=")[1]);
    }

    @Nested
    @DisplayName("순위를 조회할 때")
    class FindRank {

        @Test
        void 리그_점수가_높은_유저가_앞선다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 3L, 200);

            // when
            Optional<Integer> higher = leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 3L);
            Optional<Integer> lower = leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 1L);

            // then
            assertSoftly(softly -> {
                softly.assertThat(higher).contains(1);
                softly.assertThat(lower).contains(2);
            });
        }

        @Test
        void 리그_점수가_같으면_먼저_가입한_유저가_앞선다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 2L, 100);
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);

            // when
            Optional<Integer> earlier = leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 1L);
            Optional<Integer> later = leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 2L);

            // then
            assertSoftly(softly -> {
                softly.assertThat(earlier).contains(1);
                softly.assertThat(later).contains(2);
            });
        }

        @Test
        void 순위는_1부터_시작한다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);

            // when
            Optional<Integer> rank = leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 1L);

            // then
            assertThat(rank).contains(1);
        }

        @Test
        void 등록되지_않은_유저는_빈_값이다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);

            // when
            Optional<Integer> rank = leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 999L);

            // then
            assertThat(rank).isEmpty();
        }

        @Test
        void 다른_리그의_유저는_빈_값이다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);

            // when
            Optional<Integer> rank = leagueRankingStore.findRank(SEASON_ID, OTHER_LEAGUE_ID, 1L);

            // then
            assertThat(rank).isEmpty();
        }
    }

    @Nested
    @DisplayName("페이지를 조회할 때")
    class FindPage {

        @Test
        void 리그_점수와_가입_순서대로_정렬된다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 2L, 100);
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 3L, 200);

            // when
            List<LeagueRankEntry> entries = leagueRankingStore.findPage(SEASON_ID, LEAGUE_ID, 0, 10);

            // then
            assertThat(entries)
                    .extracting(LeagueRankEntry::rank, LeagueRankEntry::userId, LeagueRankEntry::leaguePoint)
                    .containsExactly(
                            tuple(1, 3L, 200),
                            tuple(2, 1L, 100),
                            tuple(3, 2L, 100)
                    );
        }

        @Test
        void offset_다음_순위부터_이어진다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 2L, 100);
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 3L, 200);

            // when
            List<LeagueRankEntry> entries = leagueRankingStore.findPage(SEASON_ID, LEAGUE_ID, 1, 2);

            // then
            assertThat(entries)
                    .extracting(LeagueRankEntry::rank, LeagueRankEntry::userId)
                    .containsExactly(
                            tuple(2, 1L),
                            tuple(3, 2L)
                    );
        }

        @Test
        void 저장한_리그_점수가_그대로_복호된다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 9999);

            // when
            List<LeagueRankEntry> entries = leagueRankingStore.findPage(SEASON_ID, LEAGUE_ID, 0, 10);

            // then
            assertThat(entries).singleElement()
                    .extracting(LeagueRankEntry::leaguePoint)
                    .isEqualTo(9999);
        }

        @Test
        void 조회_구간에_아무도_없으면_빈_목록이다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);

            // when
            List<LeagueRankEntry> entries = leagueRankingStore.findPage(SEASON_ID, LEAGUE_ID, 10, 10);

            // then
            assertThat(entries).isEmpty();
        }

        @Test
        void 랭킹이_없는_리그는_빈_목록이다() {
            // when
            List<LeagueRankEntry> entries = leagueRankingStore.findPage(SEASON_ID, LEAGUE_ID, 0, 10);

            // then
            assertThat(entries).isEmpty();
        }
    }

    @Nested
    @DisplayName("리그를 옮길 때")
    class Move {

        @Test
        void 티어가_바뀌면_이전_리그에서_제거된다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);

            // when
            leagueRankingStore.move(SEASON_ID, LEAGUE_ID, OTHER_LEAGUE_ID, 1L, 350);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 1L)).isEmpty();
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, OTHER_LEAGUE_ID, 1L)).contains(1);
            });
        }

        @Test
        void 같은_리그면_리그_점수만_갱신된다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 2L, 200);

            // when
            leagueRankingStore.move(SEASON_ID, LEAGUE_ID, LEAGUE_ID, 1L, 300);

            // then
            List<LeagueRankEntry> entries = leagueRankingStore.findPage(SEASON_ID, LEAGUE_ID, 0, 10);
            assertThat(entries)
                    .extracting(LeagueRankEntry::userId, LeagueRankEntry::leaguePoint)
                    .containsExactly(
                            tuple(1L, 300),
                            tuple(2L, 200)
                    );
        }
    }

    @Nested
    @DisplayName("랭킹에서 제거할 때")
    class Remove {

        @Test
        void 제거된_유저는_순위가_없다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 2L, 200);

            // when
            leagueRankingStore.remove(SEASON_ID, LEAGUE_ID, 1L);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 1L)).isEmpty();
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 2L)).contains(1);
            });
        }
    }

    @Nested
    @DisplayName("시즌 전체를 교체할 때")
    class ReplaceAll {

        @Test
        void 기존_랭킹을_지우고_새로_채운다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);

            // when
            leagueRankingStore.replaceAll(SEASON_ID, List.of(
                    new LeagueRankEntry(0, 2L, 500, LEAGUE_ID),
                    new LeagueRankEntry(0, 3L, 700, OTHER_LEAGUE_ID)
            ));

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 1L)).isEmpty();
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 2L)).contains(1);
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, OTHER_LEAGUE_ID, 3L)).contains(1);
            });
        }

        @Test
        void 다른_시즌의_랭킹은_건드리지_않는다() {
            // given
            leagueRankingStore.put(OTHER_SEASON_ID, LEAGUE_ID, 1L, 100);

            // when
            leagueRankingStore.replaceAll(SEASON_ID, List.of(new LeagueRankEntry(0, 2L, 500, LEAGUE_ID)));

            // then
            assertThat(leagueRankingStore.findRank(OTHER_SEASON_ID, LEAGUE_ID, 1L)).contains(1);
        }

        @Test
        void 배치_크기를_넘는_인원도_전원_반영된다() {
            // given - 배치 경계(1,000)를 두 번 넘겨 배치가 3회 이상 돌게 한다.
            //         한 번에 보내면 커맨드 타임아웃 100ms를 넘겨 일부만 들어간다.
            int total = BATCH_SIZE * 2 + 500;
            List<LeagueRankEntry> entries = IntStream.rangeClosed(1, total)
                    .mapToObj(seq -> new LeagueRankEntry(0, seq, total - seq + 1, LEAGUE_ID))
                    .toList();

            // when
            leagueRankingStore.replaceAll(SEASON_ID, entries);

            // then - 인원과 배치 경계 앞뒤의 순위를 확인한다
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.countRanked(SEASON_ID)).isEqualTo(total);
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 1L)).contains(1);
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, BATCH_SIZE)).contains(BATCH_SIZE);
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, BATCH_SIZE + 1)).contains(BATCH_SIZE + 1);
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, total)).contains(total);
            });
        }

        @Test
        void 배치_크기를_넘어도_리그별로_나뉘어_저장된다() {
            // given - 두 리그에 배치 경계를 넘는 인원을 나눠 담는다
            int perLeague = BATCH_SIZE + 200;
            List<LeagueRankEntry> entries = new ArrayList<>();

            for (int seq = 1; seq <= perLeague; seq++) {
                entries.add(new LeagueRankEntry(0, seq, perLeague - seq + 1, LEAGUE_ID));
                entries.add(new LeagueRankEntry(0, perLeague + seq, perLeague - seq + 1, OTHER_LEAGUE_ID));
            }

            // when
            leagueRankingStore.replaceAll(SEASON_ID, entries);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.countRanked(SEASON_ID)).isEqualTo(perLeague * 2L);
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, perLeague)).contains(perLeague);
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, OTHER_LEAGUE_ID, perLeague * 2L))
                        .contains(perLeague);
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, perLeague + 1L)).isEmpty();
            });
        }

        @Test
        void 배치_크기마다_나누어_전송한다() {
            // given - 커맨드 타임아웃(100ms) 초과는 운영 규모(리그 27만 명)에서만 재현되므로
            //         증상이 아니라 "몇 번에 나눠 보냈는가"를 단언한다.
            //         2,500명이면 1,000 + 1,000 + 500 으로 정확히 세 번이어야 한다.
            //         한 번이면 배치가 사라진 것이고, 두 번이면 마지막 잔여분을 안 보낸 것이다.
            int total = BATCH_SIZE * 2 + 500;
            resetCommandStats();

            // when
            leagueRankingStore.replaceAll(SEASON_ID, IntStream.rangeClosed(1, total)
                    .mapToObj(seq -> new LeagueRankEntry(0, seq, total - seq + 1, LEAGUE_ID))
                    .toList());

            // then
            assertThat(zaddCallCount()).isEqualTo(3);
        }

        @Test
        void 배치_크기를_넘는_시즌도_한_번에_지워진다() {
            // given - deleteSeason 도 크기에 비례하는 명령이라 같은 위험을 안는다
            int total = BATCH_SIZE * 2;
            leagueRankingStore.replaceAll(SEASON_ID, IntStream.rangeClosed(1, total)
                    .mapToObj(seq -> new LeagueRankEntry(0, seq, total - seq + 1, LEAGUE_ID))
                    .toList());

            // when
            leagueRankingStore.deleteSeason(SEASON_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.hasRanking(SEASON_ID)).isFalse();
                softly.assertThat(leagueRankingStore.countRanked(SEASON_ID)).isZero();
            });
        }
    }

    @Nested
    @DisplayName("시즌 랭킹을 삭제할 때")
    class DeleteSeason {

        @Test
        void 해당_시즌의_모든_리그가_지워진다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);
            leagueRankingStore.put(SEASON_ID, OTHER_LEAGUE_ID, 2L, 200);

            // when
            leagueRankingStore.deleteSeason(SEASON_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, 1L)).isEmpty();
                softly.assertThat(leagueRankingStore.findRank(SEASON_ID, OTHER_LEAGUE_ID, 2L)).isEmpty();
            });
        }

        @Test
        void 다른_시즌은_남는다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);
            leagueRankingStore.put(OTHER_SEASON_ID, LEAGUE_ID, 2L, 200);

            // when
            leagueRankingStore.deleteSeason(SEASON_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(leagueRankingStore.hasRanking(SEASON_ID)).isFalse();
                softly.assertThat(leagueRankingStore.hasRanking(OTHER_SEASON_ID)).isTrue();
            });
        }
    }

    @Nested
    @DisplayName("시즌 랭킹 존재를 확인할 때")
    class HasRanking {

        @Test
        void 랭킹이_있으면_참이다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);

            // when & then
            assertThat(leagueRankingStore.hasRanking(SEASON_ID)).isTrue();
        }

        @Test
        void 랭킹이_없으면_거짓이다() {
            // when & then
            assertThat(leagueRankingStore.hasRanking(SEASON_ID)).isFalse();
        }
    }

    @Nested
    @DisplayName("시즌 랭킹 인원을 셀 때")
    class CountRanked {

        @Test
        void 시즌의_모든_리그_인원을_합산한다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 2L, 200);
            leagueRankingStore.put(SEASON_ID, OTHER_LEAGUE_ID, 3L, 300);

            // when & then
            assertThat(leagueRankingStore.countRanked(SEASON_ID)).isEqualTo(3);
        }

        @Test
        void 다른_시즌_인원은_세지_않는다() {
            // given
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1L, 100);
            leagueRankingStore.put(OTHER_SEASON_ID, LEAGUE_ID, 2L, 200);

            // when & then
            assertThat(leagueRankingStore.countRanked(SEASON_ID)).isEqualTo(1);
        }

        @Test
        void 랭킹이_없으면_0이다() {
            // when & then
            assertThat(leagueRankingStore.countRanked(SEASON_ID)).isZero();
        }
    }

    @Nested
    @DisplayName("유저 식별자가 점수 인코딩 범위를 벗어나면")
    class UserIdOutOfRange {

        @Test
        void 영이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 0L, 100))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LEAGUE_RANK_USER_ID_OUT_OF_RANGE);
        }

        @Test
        void 십억_이상이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> leagueRankingStore.put(SEASON_ID, LEAGUE_ID, 1_000_000_000L, 100))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LEAGUE_RANK_USER_ID_OUT_OF_RANGE);
        }

        @Test
        void 십억_미만이면_정상_등록된다() {
            // given
            long maxUserId = 999_999_999L;

            // when
            leagueRankingStore.put(SEASON_ID, LEAGUE_ID, maxUserId, 9999);

            // then
            assertThat(leagueRankingStore.findRank(SEASON_ID, LEAGUE_ID, maxUserId)).contains(1);
        }
    }
}
