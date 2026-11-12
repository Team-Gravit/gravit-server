package gravit.code.test.season;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.season.domain.Season;
import gravit.code.season.infrastructure.RedisSeasonPopupSeenStore;
import gravit.code.season.service.port.SeasonClosedCache;
import gravit.code.test.season.docs.TestSeasonPopupControllerDocs;
import gravit.code.test.season.dto.response.TestSeasonPopupResponse;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeagueHistory.repository.UserLeagueHistoryRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Set;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static org.springframework.http.HttpStatus.NOT_FOUND;
import static org.springframework.http.HttpStatus.OK;

/**
 * [QA 전용] 특정 유저가 다음 리그 진입 때 시즌 결과·시즌 시작 팝업을 다시 보게 만든다.
 *
 * 팝업은 (1) Redis lastClosedSeasonId, (2) 그 시즌의 user_league_history, (3) 현재 시즌 user_league,
 * (4) Redis season:seen:{seasonId}:{userId} 미기록 — 네 조건이 모두 맞을 때 한 번 뜬다.
 * (1)은 롤오버 배치만 기록해 사라지면 다시 만들 수 없고, (4)는 한 번 보면 끝이라 QA에서 재현할 길이 없었다.
 * 이 API는 가장 최근 CLOSED 시즌으로 (1)을 채우고 해당 유저의 (4)를 지운다. (2)·(3)은 데이터가 있어야 한다
 * (QA 페르소나 `league-edge`가 갖고 있다). 유저 한 명의 Redis 키만 건드리므로 다른 사용자에게 영향이 없다.
 *
 * 다른 치트 컨트롤러처럼 운영 코드는 바꾸지 않는다 — 시즌 조회는 JPQL, seen 키 삭제는 공개 패턴으로 찾아서 한다.
 */
@Profile("!prod")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/test")
public class TestSeasonPopupController implements TestSeasonPopupControllerDocs {

    @PersistenceContext
    private EntityManager em;

    private final UserRepository userRepository;
    private final UserLeagueHistoryRepository userLeagueHistoryRepository;
    private final SeasonClosedCache seasonClosedCache;
    private final RedisTemplate<String, String> redisTemplate;

    @PostMapping("/season/popup")
    public ResponseEntity<TestSeasonPopupResponse> resetSeasonPopup(@RequestParam Long userId) {
        if (!userRepository.existsById(userId)) {
            throw new RestApiException(USER_NOT_FOUND);
        }
        // CLOSED 시즌이 없으면 팝업을 만들 수 없다 — 다른 치트(users/clean)처럼 빈 404
        java.util.Optional<Season> found = findLastClosedSeason();
        if (found.isEmpty()) {
            return ResponseEntity.status(NOT_FOUND).build();
        }
        Season lastClosed = found.get();

        seasonClosedCache.setLastClosedSeasonId(lastClosed.getId());
        deleteSeenKeys(lastClosed.getId(), userId);

        boolean hasHistory = userLeagueHistoryRepository.existsByUserIdAndSeasonId(userId, lastClosed.getId());
        return ResponseEntity.status(OK).body(
                new TestSeasonPopupResponse(userId, lastClosed.getId(), lastClosed.getSeasonKey(), hasHistory)
        );
    }

    private java.util.Optional<Season> findLastClosedSeason() {
        List<Season> closed = em.createQuery(
                        "select s from Season s where s.status = 'CLOSED' order by s.endsAt desc", Season.class)
                .setMaxResults(1)
                .getResultList();
        return closed.stream().findFirst();
    }

    /** 공개 패턴(season:seen:*)으로 찾아 이 시즌·유저의 키만 지운다 — 키 형식은 저장소 내부 사정이라 여기서 조립하지 않는다 */
    private void deleteSeenKeys(long seasonId, long userId) {
        Set<String> keys = redisTemplate.keys(RedisSeasonPopupSeenStore.SEEN_KEY_PATTERN);
        if (keys == null || keys.isEmpty()) return;
        String suffix = ":" + seasonId + ":" + userId;
        List<String> mine = keys.stream().filter(k -> k.endsWith(suffix)).toList();
        if (!mine.isEmpty()) redisTemplate.delete(mine);
    }
}
