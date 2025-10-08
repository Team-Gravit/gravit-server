package gravit.code.test.season;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
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

        return ResponseEntity.ok().build();
    }

}
