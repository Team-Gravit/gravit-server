package gravit.code.badge.service;

import gravit.code.badge.domain.Badge;
import gravit.code.badge.domain.CriteriaType;
import gravit.code.badge.domain.user.UserBadge;
import gravit.code.badge.infrastructure.BadgeRepository;
import gravit.code.badge.infrastructure.user.UserBadgeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class BadgeGrantService {
    private final BadgeRepository badgeRepository;
    private final UserBadgeRepository userBadgeRepository;

    private static final String CODE_PLANETS_ALL = "PLANETS_ALL_COMPLETE";
    private static final String CODE_STREAK_ALL  = "STREAK_ALL_STAR";
    private static final String CODE_SPEED_ALL   = "SPEED_ALL_STAR";
    private static final String CODE_MISSION_ALL = "MISSION_ALL_STAR";

    @Transactional
    public void evaluatePlanet(Long userId, String planet, boolean allPlanetsCompleted) {
        for(Badge b : badgeRepository.findByCriteriaTypeAndCodeNot(CriteriaType.PLANET_COMPLETE, CODE_PLANETS_ALL)) {
            String need = b.getCriteriaParams().path("planet").asText();
            if(planet.equalsIgnoreCase(need)) grantIfAbsent(userId, b);
        }
        if(allPlanetsCompleted){
            Badge badge = badgeRepository.findByCode(CODE_PLANETS_ALL).orElseThrow();
            grantIfAbsent(userId, badge);
        }
    }

    @Transactional
    public void evaluateMissionCount(Long userId, int completedCount) {
        for (Badge b : badgeRepository.findByCriteriaTypeAndCodeNot(CriteriaType.MISSION_COUNT, CODE_MISSION_ALL)) {
            int need = b.getCriteriaParams().path("count").asInt();
            if (completedCount >= need) grantIfAbsent(userId, b);
        }

        maybeGrantAllStar(userId, CriteriaType.MISSION_COUNT, CODE_MISSION_ALL);
    }

    @Transactional
    public void evaluateQualifiedSolvedCount(Long userId, int qualifiedCount) {
        for (Badge b : badgeRepository.findByCriteriaTypeAndCodeNot(CriteriaType.SPEED_QUALIFIED_COUNT, CODE_SPEED_ALL)) {
            int need = b.getCriteriaParams().path("count").asInt();
            if (qualifiedCount >= need) {
                grantIfAbsent(userId, b);
            }
        }

        maybeGrantAllStar(userId, CriteriaType.SPEED_QUALIFIED_COUNT, CODE_SPEED_ALL);
    }

    @Transactional
    public void evaluateStreak(Long userId, int currentStreak){
        for(Badge b : badgeRepository.findByCriteriaTypeAndCodeNot(CriteriaType.STREAK_DAYS, CODE_STREAK_ALL)) {
            int need = b.getCriteriaParams().path("days").asInt();
            if(currentStreak >= need) grantIfAbsent(userId, b);
        }

        maybeGrantAllStar(userId, CriteriaType.STREAK_DAYS, CODE_STREAK_ALL);
    }

    private void grantIfAbsent(Long userId, Badge badge) {
        if (userBadgeRepository.existsByUserIdAndBadge_Id(userId, badge.getId())) return;

        UserBadge userBadge = UserBadge.builder().userId(userId).badge(badge).build();
        userBadgeRepository.save(userBadge);
    }

    private void maybeGrantAllStar(Long userId, CriteriaType criteriaType, String allStarCode) {
        long total = badgeRepository.countByCriteriaType(criteriaType);
        long totalExcludingAllStar = total - 1;
        log.info("totalExcludingAllStar : {}", totalExcludingAllStar);

        if(totalExcludingAllStar == 0) return;

        long owned = userBadgeRepository
                .countByUserIdAndBadge_CriteriaType(userId, criteriaType);

        log.info("owned : {}", owned);
        if(owned == totalExcludingAllStar) {
            Badge allStar = badgeRepository.findByCode(allStarCode).orElseThrow();
            grantIfAbsent(userId, allStar);
        }
    }
}
