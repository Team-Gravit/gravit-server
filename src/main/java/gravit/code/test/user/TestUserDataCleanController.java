package gravit.code.test.user;

import gravit.code.test.user.docs.TestUserDataCleanControllerDocs;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.dto.event.LeagueRankChangedEvent;
import gravit.code.userLeague.repository.UserLeagueRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
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

    private final UserRepository userRepository;
    private final UserLeagueRepository userLeagueRepository;
    private final ApplicationEventPublisher publisher;

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

        userIds.forEach(this::deleteUserData);

        return ResponseEntity.status(OK).body(userIds.size() + " user(s) deleted");
    }

    private void deleteUserData(long userId) {
        // 랭킹 키는 user_league 삭제 전에 조회해야 한다. Redis 제거는 커밋 후 리스너가 수행한다
        userLeagueRepository.findRankKeyByUserId(userId)
                .map(rankKey -> LeagueRankChangedEvent.removed(userId, rankKey.seasonId(), rankKey.leagueId()))
                .ifPresent(publisher::publishEvent);

        em.createNativeQuery("DELETE FROM user_daily_activity WHERE user_id = :id")
                .setParameter("id", userId)
                .executeUpdate();

        userRepository.cleanUserDeletion(userId);
    }
}
