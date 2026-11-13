package gravit.code.userLeague.infrastructure;

import gravit.code.userLeague.dto.internal.LeagueRankEntryDto;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.Cursor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ScanOptions;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import static gravit.code.userLeague.infrastructure.LeagueRankScripts.EVICT_SCRIPT;
import static gravit.code.userLeague.infrastructure.LeagueRankScripts.PLACE_SCRIPT;
import static gravit.code.userLeague.infrastructure.LeagueRankScripts.PLACED;

@Component
public class RedisLeagueRankingStore implements LeagueRankingStore {

    private static final String KEY_PREFIX = "league:rank:";
    private static final String READY_KEY_PREFIX = "league:rank-ready:";
    private static final String READY_VALUE = "1";
    private static final String REBUILD_KEY_PREFIX = "league:rank-rebuild:";
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
    public boolean place(
            long seasonId,
            Collection<Long> leagueIds,
            long leagueId,
            long userId,
            int leaguePoint
    ) {
        String score = String.valueOf((long) LeagueRankScore.encode(leaguePoint, userId));
        List<String> keys = seasonLeagueKeys(seasonId, leagueIds, leagueId);
        int targetPosition = keys.indexOf(key(seasonId, leagueId)) + 1;

        Long result = redisTemplate.execute(
                PLACE_SCRIPT,
                keys,
                member(userId),
                String.valueOf(targetPosition),
                score
        );

        return result != null && result == PLACED;
    }

    private static List<String> seasonLeagueKeys(
            long seasonId,
            Collection<Long> leagueIds,
            long leagueId
    ) {
        Set<String> keys = new LinkedHashSet<>();

        leagueIds.forEach(id -> keys.add(key(seasonId, id)));
        keys.add(key(seasonId, leagueId));

        return new ArrayList<>(keys);
    }

    @Override
    public void evict(
            long seasonId,
            Collection<Long> leagueIds,
            long userId
    ) {
        if (leagueIds.isEmpty()) {
            return;
        }

        List<String> keys = leagueIds.stream()
                .map(leagueId -> key(seasonId, leagueId))
                .distinct()
                .toList();

        redisTemplate.execute(EVICT_SCRIPT, keys, member(userId));
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
    public List<LeagueRankEntryDto> findPage(
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

        List<LeagueRankEntryDto> entries = new ArrayList<>(tuples.size());

        int rank = offset + FIRST_RANK;
        for (ZSetOperations.TypedTuple<String> tuple : tuples) {
            entries.add(new LeagueRankEntryDto(
                    rank++,
                    Long.parseLong(tuple.getValue()),
                    LeagueRankScore.toLeaguePoint(tuple.getScore()),
                    leagueId
            ));
        }

        return entries;
    }

    @Override
    public Map<Long, Integer> findLeaguePoints(
            long seasonId,
            long leagueId,
            List<Long> userIds
    ) {
        if (userIds.isEmpty()) {
            return Map.of();
        }

        Object[] members = userIds.stream()
                .map(RedisLeagueRankingStore::member)
                .toArray();
        List<Double> scores = redisTemplate.opsForZSet().score(key(seasonId, leagueId), members);

        Map<Long, Integer> userIdToLeaguePoint = new LinkedHashMap<>();

        if (scores == null) {
            return userIdToLeaguePoint;
        }

        for (int i = 0; i < userIds.size(); i++) {
            Double score = scores.get(i);

            if (score != null) {
                userIdToLeaguePoint.put(userIds.get(i), LeagueRankScore.toLeaguePoint(score));
            }
        }

        return userIdToLeaguePoint;
    }

    @Override
    public void replaceAll(
            long seasonId,
            List<LeagueRankEntryDto> entries
    ) {
        deleteSeason(seasonId);

        groupByLeague(entries).forEach((leagueId, tuples) ->
                addInBatches(key(seasonId, leagueId), tuples));
    }

    @Override
    public void replaceLeague(
            long seasonId,
            long leagueId,
            List<LeagueRankEntryDto> entries
    ) {
        String key = key(seasonId, leagueId);
        String rebuildKey = rebuildKey(seasonId, leagueId);

        redisTemplate.unlink(rebuildKey);

        if (entries.isEmpty()) {
            redisTemplate.unlink(key);

            return;
        }

        Set<ZSetOperations.TypedTuple<String>> tuples = new LinkedHashSet<>();
        entries.forEach(entry -> tuples.add(tuple(entry)));

        addInBatches(rebuildKey, tuples);
        redisTemplate.rename(rebuildKey, key);
    }

    @Override
    public void deleteSeason(long seasonId) {
        Set<String> keys = scanSeasonKeys(seasonId);
        keys.addAll(scanKeys(seasonScanOptions(REBUILD_KEY_PREFIX, seasonId)));
        keys.add(readyKey(seasonId));

        redisTemplate.unlink(keys);
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

    @Override
    public long countRanked(
            long seasonId,
            long leagueId
    ) {
        Long ranked = redisTemplate.opsForZSet().zCard(key(seasonId, leagueId));

        return ranked == null ? 0 : ranked;
    }

    @Override
    public void markReady(long seasonId) {
        redisTemplate.opsForValue().set(readyKey(seasonId), READY_VALUE);
    }

    @Override
    public boolean isReady(long seasonId) {
        return Boolean.TRUE.equals(redisTemplate.hasKey(readyKey(seasonId)));
    }

    private Set<String> scanSeasonKeys(long seasonId) {
        return scanKeys(seasonKeyScanOptions(seasonId));
    }

    private Set<String> scanKeys(ScanOptions scanOptions) {
        Set<String> keys = new LinkedHashSet<>();

        try (Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
            while (cursor.hasNext()) {
                keys.add(cursor.next());
            }
        }

        return keys;
    }

    private ScanOptions seasonKeyScanOptions(long seasonId) {
        return seasonScanOptions(KEY_PREFIX, seasonId);
    }

    private static ScanOptions seasonScanOptions(
            String keyPrefix,
            long seasonId
    ) {
        return ScanOptions.scanOptions()
                .match(keyPrefix + seasonId + SEASON_KEY_PATTERN_SUFFIX)
                .count(SCAN_COUNT)
                .build();
    }

    private Map<Long, Set<ZSetOperations.TypedTuple<String>>> groupByLeague(List<LeagueRankEntryDto> entries) {
        Map<Long, Set<ZSetOperations.TypedTuple<String>>> leagueIdToTuples = new LinkedHashMap<>();

        for (LeagueRankEntryDto entry : entries) {
            leagueIdToTuples.computeIfAbsent(entry.leagueId(), leagueId -> new LinkedHashSet<>())
                    .add(tuple(entry));
        }

        return leagueIdToTuples;
    }

    private static ZSetOperations.TypedTuple<String> tuple(LeagueRankEntryDto entry) {
        return ZSetOperations.TypedTuple.of(
                member(entry.userId()),
                LeagueRankScore.encode(entry.leaguePoint(), entry.userId())
        );
    }

    private static String key(
            long seasonId,
            long leagueId
    ) {
        return KEY_PREFIX + seasonId + KEY_DELIMITER + leagueId;
    }

    private static String rebuildKey(
            long seasonId,
            long leagueId
    ) {
        return REBUILD_KEY_PREFIX + seasonId + KEY_DELIMITER + leagueId;
    }

    private static String readyKey(long seasonId) {
        return READY_KEY_PREFIX + seasonId;
    }

    private static String member(long userId) {
        return String.valueOf(userId);
    }
}
