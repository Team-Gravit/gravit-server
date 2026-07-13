package gravit.code.test.user;

import gravit.code.test.user.docs.TestUserDataCleanControllerDocs;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

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
        // 이메일로 모든 userId 조회 (중복 가능)
        @SuppressWarnings("unchecked")
        List<Long> userIds = em.createNativeQuery(
                        "SELECT id FROM users WHERE email = :email")
                .setParameter("email", email)
                .getResultList();

        if(userIds.isEmpty()){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        // 각 userId에 대해 삭제 실행
        int deletedCount = 0;
        for(Long userId : userIds){
            deleteUserData(userId);
            deletedCount++;
        }

        return ResponseEntity.status(HttpStatus.OK).body(deletedCount + " user(s) deleted");
    }

    private void deleteUserData(Long userId) {
        // 0. 소셜/알림 (users 참조 FK 보유 → users 삭제 전에 반드시 제거해야 FK 위반이 안 난다)
        //    congratulation 은 user_id·actor_id 로 users 를, feed_id 로 social_feed 를 참조하므로
        //    "내가 준/받은 축하" + "내 피드에 달린 (타인의) 축하"까지 함께 지워 social_feed 삭제도 가능하게 한다.
        exec("DELETE FROM congratulation WHERE user_id = :id OR actor_id = :id"
                + " OR feed_id IN (SELECT id FROM social_feed WHERE actor_id = :id)", userId);
        exec("DELETE FROM notification WHERE user_id = :id", userId);
        exec("DELETE FROM fcm_token WHERE user_id = :id", userId); // FK ON DELETE CASCADE 지만 명시적으로 정리
        exec("DELETE FROM social_feed WHERE actor_id = :id", userId); // congratulation 제거 후 (feed_id FK)
        exec("DELETE FROM user_feed WHERE user_id = :id", userId);

        // 1. 친구 관계 (양방향)
        exec("DELETE FROM friends WHERE follower_id = :id OR followee_id = :id", userId);

        // 2. 공지사항
        exec("DELETE FROM notice WHERE author_id = :id", userId);

        // 3. 학습 관련
        exec("DELETE FROM learning WHERE user_id = :id", userId);
        exec("DELETE FROM lesson_submission WHERE user_id = :id", userId);
        exec("DELETE FROM problem_submission WHERE user_id = :id", userId);
        exec("DELETE FROM bookmark WHERE user_id = :id", userId);
        exec("DELETE FROM wrong_answered_note WHERE user_id = :id", userId);
        exec("DELETE FROM daily_learning_record WHERE user_id = :id", userId);

        // 4. 리그/시즌
        exec("DELETE FROM user_league_history WHERE user_id = :id", userId);
        exec("DELETE FROM user_league WHERE user_id = :id", userId);

        // 5. 미션/리포트
        exec("DELETE FROM mission WHERE user_id = :id", userId);
        exec("DELETE FROM report WHERE user_id = :id", userId);

        // 6. 문의 (inquiry_answer 가 inquiry 를 참조 → 답변부터 제거)
        exec("DELETE FROM inquiry_answer WHERE inquiry_id IN (SELECT id FROM inquiry WHERE user_id = :id)", userId);
        exec("DELETE FROM inquiry WHERE user_id = :id", userId);

        // 7. 사용자
        // NOTE: user_badge·user_mission_stat·user_planet_completion·user_qualified_solve_stat 는
        //       V9(drop_badge_tables)에서 삭제된 테이블이라 더 이상 지우지 않는다.
        exec("DELETE FROM users WHERE id = :id", userId);
    }

    private void exec(String sql, Long id) {
        em.createNativeQuery(sql)
                .setParameter("id", id)
                .executeUpdate();
    }
}
