package gravit.code.test.user;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/test")
public class UserDataCleanController {

    @PersistenceContext
    private EntityManager em;

    @PostMapping("/users/clean")
    @Transactional
    public ResponseEntity<Void> clean(@RequestParam String email){
        Long userId = (Long) em.createNativeQuery(
                "SELECT id FROM users WHERE email = :email")
                .setParameter("email", email)
                .getResultStream()
                .findFirst()
                .orElse(null);

        if(userId == null){
            return ResponseEntity.notFound().build();
        }

        exec("DELETE FROM friends WHERE follower_id = :id OR followee_id = :id", userId);
        exec("DELETE FROM chapter_progress WHERE user_id = :id", userId);
        exec("DELETE FROM unit_progress WHERE user_id = :id", userId);
        exec("DELETE FROM lesson_progress WHERE user_id = :id", userId);
        exec("DELETE FROM problem_progress WHERE user_id = :id", userId);
        exec("DELETE FROM learning WHERE user_id = :id", userId);
        exec("DELETE FROM user_league_history WHERE user_id = :id", userId);
        exec("DELETE FROM user_league WHERE user_id = :id", userId);
        exec("DELETE FROM mission WHERE user_id = :id", userId);
        exec("DELETE FROM report WHERE user_id = :id", userId);
        exec("DELETE FROM user_badge WHERE user_id = :id", userId);
        exec("DELETE FROM user_mission_stat WHERE user_id = :id", userId);
        exec("DELETE FROM user_planet_completion WHERE user_id = :id", userId);
        exec("DELETE FROM user_qualified_solve_stat WHERE user_id = :id", userId);

        exec("DELETE FROM users WHERE id = :id", userId);

        return ResponseEntity.ok().build();
    }

    private void exec(String sql, Long id) {
        em.createNativeQuery(sql)
                .setParameter("id", id)
                .executeUpdate();
    }
}
