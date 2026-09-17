package gravit.code.test.user;

import gravit.code.test.user.docs.TestUserDataCleanControllerDocs;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import static org.springframework.http.HttpStatus.NOT_FOUND;
import static org.springframework.http.HttpStatus.OK;

@Profile("!prod")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/test")
public class TestUserDataCleanController implements TestUserDataCleanControllerDocs {

    @PersistenceContext
    private EntityManager em;

    @PostMapping("/users/clean")
    @Transactional
    public ResponseEntity<String> clean(@RequestParam String email){
        @SuppressWarnings("unchecked")
        List<Long> userIds = em.createNativeQuery(
                        "SELECT id FROM users WHERE email = :email")
                .setParameter("email", email)
                .getResultList();

        if(userIds.isEmpty()){
            return ResponseEntity.status(NOT_FOUND).build();
        }

        int deletedCount = 0;
        for(Long userId : userIds){
            deleteUserData(userId);
            deletedCount++;
        }

        return ResponseEntity.status(OK).body(deletedCount + " user(s) deleted");
    }

    private void deleteUserData(Long userId) {
        exec("DELETE FROM congratulation WHERE user_id = :id OR actor_id = :id"
                + " OR feed_id IN (SELECT id FROM social_feed WHERE actor_id = :id)", userId);
        exec("DELETE FROM notification WHERE user_id = :id", userId);
        exec("DELETE FROM fcm_token WHERE user_id = :id", userId);
        exec("DELETE FROM social_feed WHERE actor_id = :id", userId);
        exec("DELETE FROM user_feed WHERE user_id = :id", userId);

        exec("DELETE FROM friends WHERE follower_id = :id OR followee_id = :id", userId);

        exec("DELETE FROM notice WHERE author_id = :id", userId);

        exec("DELETE FROM learning WHERE user_id = :id", userId);
        exec("DELETE FROM lesson_submission WHERE user_id = :id", userId);
        exec("DELETE FROM problem_submission WHERE user_id = :id", userId);
        exec("DELETE FROM bookmark WHERE user_id = :id", userId);
        exec("DELETE FROM wrong_answered_note WHERE user_id = :id", userId);
        exec("DELETE FROM daily_learning_record WHERE user_id = :id", userId);

        exec("DELETE FROM user_league_history WHERE user_id = :id", userId);
        exec("DELETE FROM user_league WHERE user_id = :id", userId);

        exec("DELETE FROM user_mission WHERE user_id = :id", userId);
        exec("DELETE FROM report WHERE user_id = :id", userId);

        exec("DELETE FROM inquiry_answer WHERE inquiry_id IN (SELECT id FROM inquiry WHERE user_id = :id)", userId);
        exec("DELETE FROM inquiry WHERE user_id = :id", userId);

        exec("DELETE FROM users WHERE id = :id", userId);
    }

    private void exec(
            String sql,
            Long id
    ) {
        em.createNativeQuery(sql)
                .setParameter("id", id)
                .executeUpdate();
    }
}
