package gravit.code.test.season;

import gravit.code.season.infrastructure.RedisSeasonClosedCache;
import gravit.code.season.infrastructure.RedisSeasonPopupSeenStore;
import gravit.code.test.season.docs.TestSeasonCleanControllerDocs;
import gravit.code.userLeagueHistory.repository.UserLeagueHistoryRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Set;

import static org.springframework.http.HttpStatus.OK;

@Profile("!prod")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/test")
public class TestSeasonCleanController implements TestSeasonCleanControllerDocs {
    @PersistenceContext
    private EntityManager em;

    private final UserLeagueHistoryRepository userLeagueHistoryRepository;

    private final RedisTemplate<String, String> redisTemplate;

    @PostMapping("/season/clean")
    @Transactional
    public ResponseEntity<Void> cleanSeason() {

        int userLeagueUpdated = em.createNativeQuery(
                        "UPDATE user_league SET season_id = 1 WHERE season_id <> 1")
                .executeUpdate();

        int userLeagueHistoryDeleted = em.createNativeQuery(
                        "DELETE FROM user_league_history")
                .executeUpdate();

        int seasonsDeleted = em.createNativeQuery(
                        "DELETE FROM season WHERE id <> 1")
                .executeUpdate();

        int seasonsUpdateStatus = em.createNativeQuery(
                "UPDATE season SET status = 'ACTIVE' WHERE id = 1"
        ).executeUpdate();

        cleanSeasonRelatedCache();

        userLeagueHistoryRepository.deleteAll();

        return ResponseEntity.status(OK).build();
    }

    private void cleanSeasonRelatedCache() {
        redisTemplate.delete(RedisSeasonClosedCache.LAST_CLOSED_SEASON_ID_KEY);

        Set<String> keys = redisTemplate.keys(RedisSeasonPopupSeenStore.SEEN_KEY_PATTERN);
        if (keys != null && !keys.isEmpty()) {
            redisTemplate.delete(keys);
        }
    }

}
