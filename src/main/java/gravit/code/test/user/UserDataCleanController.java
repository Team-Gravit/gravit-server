package gravit.code.test.user;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
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
    public ResponseEntity<String> clean(@RequestParam String email){
        // 이메일로 모든 userId 조회 (중복 가능)
        @SuppressWarnings("unchecked")
        List<Long> userIds = em.createNativeQuery(
                        "SELECT id FROM users WHERE email = :email")
                .setParameter("email", email)
                .getResultList();

        if(userIds.isEmpty()){
            return ResponseEntity.notFound().build();
        }

        // 각 userId에 대해 삭제 실행
        int deletedCount = 0;
        for(Long userId : userIds){
            deleteUserData(userId);
            deletedCount++;
        }

        return ResponseEntity.ok(deletedCount + " user(s) deleted");
    }

    private void deleteUserData(Long userId) {
        // 1. 친구 관계 (양방향)
        exec("DELETE FROM friends WHERE follower_id = :id OR followee_id = :id", userId);

        // 2. 공지사항
        exec("DELETE FROM notice WHERE author_id = :id", userId);

        // 3. 학습 관련
        exec("DELETE FROM learning WHERE user_id = :id", userId);
        exec("DELETE FROM lesson_submission WHERE user_id = :id", userId);
        exec("DELETE FROM problem_submission WHERE user_id = :id", userId);
        exec("DELETE FROM bookmark WHERE user_id = :id", userId);

        // 4. 리그/시즌
        exec("DELETE FROM user_league_history WHERE user_id = :id", userId);
        exec("DELETE FROM user_league WHERE user_id = :id", userId);

        // 5. 미션/리포트
        exec("DELETE FROM mission WHERE user_id = :id", userId);
        exec("DELETE FROM report WHERE user_id = :id", userId);

        // 6. 뱃지 및 사용자 통계
        exec("DELETE FROM user_badge WHERE user_id = :id", userId);
        exec("DELETE FROM user_mission_stat WHERE user_id = :id", userId);
        exec("DELETE FROM user_planet_completion WHERE user_id = :id", userId);
        exec("DELETE FROM user_qualified_solve_stat WHERE user_id = :id", userId);

        // 7. 사용자
        exec("DELETE FROM users WHERE id = :id", userId);
    }

    private void exec(String sql, Long id) {
        em.createNativeQuery(sql)
                .setParameter("id", id)
                .executeUpdate();
    }
}
