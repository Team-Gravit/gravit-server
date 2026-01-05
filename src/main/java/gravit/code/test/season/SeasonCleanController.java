package gravit.code.test.season;

import gravit.code.userLeagueHistory.repository.UserLeagueHistoryRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/test")
public class SeasonCleanController {
    @PersistenceContext
    private EntityManager em;

    private final RedisTemplate<String, String> redisTemplate;

    private final UserLeagueHistoryRepository userLeagueHistoryRepository;

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

        return ResponseEntity.ok().build();
    }

    private void cleanSeasonRelatedCache() {
        // 1. lastClosedSeasonId 삭제
        redisTemplate.delete("season:lastClosedSeasonId");

        // 2. 시즌 팝업 본 기록 전체 삭제 (패턴 매칭)
        Set<String> keys = redisTemplate.keys("season:seen:*");
        if (keys != null && !keys.isEmpty()) {
            redisTemplate.delete(keys);
        }
    }

}
