package gravit.code.userLeague.infrastructure;

import gravit.code.userLeague.dto.internal.LeagueRankEntry;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.Cursor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ScanOptions;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

@Component
public class RedisLeagueRankingStore implements LeagueRankingStore {

    private static final String KEY_PREFIX = "league:rank:";
    private static final String KEY_DELIMITER = ":";
    private static final String SEASON_KEY_PATTERN_SUFFIX = ":*";
    private static final int SCAN_COUNT = 100;
    private static final int FIRST_RANK = 1;
    private static final int ADD_BATCH_SIZE = 1_000;

    private final RedisTemplate<String, String> redisTemplate;

    public RedisLeagueRankingStore(@Qualifier("rankingRedisTemplate") RedisTemplate<String, String> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    @Override
    public void put(
            long seasonId,
            long leagueId,
            long userId,
            int leaguePoint
    ) {
        redisTemplate.opsForZSet().add(
                key(seasonId, leagueId),
                member(userId),
                LeagueRankScore.encode(leaguePoint, userId)
        );
    }

    @Override
    public void move(
            long seasonId,
            long fromLeagueId,
            long toLeagueId,
            long userId,
            int leaguePoint
    ) {
        if (fromLeagueId != toLeagueId) {
            remove(seasonId, fromLeagueId, userId);
        }

        put(seasonId, toLeagueId, userId, leaguePoint);
    }

    @Override
    public void remove(
            long seasonId,
            long leagueId,
            long userId
    ) {
        redisTemplate.opsForZSet().remove(key(seasonId, leagueId), member(userId));
    }

    @Override
    public Optional<Integer> findRank(
            long seasonId,
            long leagueId,
            long userId
    ) {
        Long reverseRank = redisTemplate.opsForZSet().reverseRank(key(seasonId, leagueId), member(userId));

        return Optional.ofNullable(reverseRank)
                .map(rank -> rank.intValue() + FIRST_RANK);
    }

    @Override
    public List<LeagueRankEntry> findPage(
            long seasonId,
            long leagueId,
            int offset,
            int limit
    ) {
        Set<ZSetOperations.TypedTuple<String>> tuples = redisTemplate.opsForZSet()
                .reverseRangeWithScores(key(seasonId, leagueId), offset, (long) offset + limit - 1);

        if (tuples == null || tuples.isEmpty()) {
            return List.of();
        }

        List<LeagueRankEntry> entries = new ArrayList<>(tuples.size());

        int rank = offset + FIRST_RANK;
        for (ZSetOperations.TypedTuple<String> tuple : tuples) {
            entries.add(new LeagueRankEntry(
                    rank++,
                    Long.parseLong(tuple.getValue()),
                    LeagueRankScore.toLeaguePoint(tuple.getScore()),
                    leagueId
            ));
        }

        return entries;
    }

    @Override
    public void replaceAll(
            long seasonId,
            List<LeagueRankEntry> entries
    ) {
        deleteSeason(seasonId);

        groupByLeague(entries).forEach((leagueId, tuples) ->
                addInBatches(key(seasonId, leagueId), tuples));
    }

    @Override
    public void deleteSeason(long seasonId) {
        Set<String> keys = scanSeasonKeys(seasonId);

        if (!keys.isEmpty()) {
            redisTemplate.unlink(keys);
        }
    }

    private void addInBatches(
            String key,
            Set<ZSetOperations.TypedTuple<String>> tuples
    ) {
        Set<ZSetOperations.TypedTuple<String>> batch = new LinkedHashSet<>();

        for (ZSetOperations.TypedTuple<String> tuple : tuples) {
            batch.add(tuple);

            if (batch.size() == ADD_BATCH_SIZE) {
                redisTemplate.opsForZSet().add(key, batch);
                batch = new LinkedHashSet<>();
            }
        }

        if (!batch.isEmpty()) {
            redisTemplate.opsForZSet().add(key, batch);
        }
    }

    @Override
    public boolean hasRanking(long seasonId) {
        try (Cursor<String> cursor = redisTemplate.scan(seasonKeyScanOptions(seasonId))) {
            return cursor.hasNext();
        }
    }

    @Override
    public long countRanked(long seasonId) {
        long total = 0;

        for (String key : scanSeasonKeys(seasonId)) {
            Long ranked = redisTemplate.opsForZSet().zCard(key);

            if (ranked != null) {
                total += ranked;
            }
        }

        return total;
    }

    private Set<String> scanSeasonKeys(long seasonId) {
        Set<String> keys = new LinkedHashSet<>();

        try (Cursor<String> cursor = redisTemplate.scan(seasonKeyScanOptions(seasonId))) {
            while (cursor.hasNext()) {
                keys.add(cursor.next());
            }
        }

        return keys;
    }

    private ScanOptions seasonKeyScanOptions(long seasonId) {
        return ScanOptions.scanOptions()
                .match(KEY_PREFIX + seasonId + SEASON_KEY_PATTERN_SUFFIX)
                .count(SCAN_COUNT)
                .build();
    }

    private Map<Long, Set<ZSetOperations.TypedTuple<String>>> groupByLeague(List<LeagueRankEntry> entries) {
        Map<Long, Set<ZSetOperations.TypedTuple<String>>> byLeague = new LinkedHashMap<>();

        for (LeagueRankEntry entry : entries) {
            byLeague.computeIfAbsent(entry.leagueId(), leagueId -> new LinkedHashSet<>())
                    .add(ZSetOperations.TypedTuple.of(
                            member(entry.userId()),
                            LeagueRankScore.encode(entry.leaguePoint(), entry.userId())
                    ));
        }

        return byLeague;
    }

    private static String key(
            long seasonId,
            long leagueId
    ) {
        return KEY_PREFIX + seasonId + KEY_DELIMITER + leagueId;
    }

    private static String member(long userId) {
        return String.valueOf(userId);
    }
}
