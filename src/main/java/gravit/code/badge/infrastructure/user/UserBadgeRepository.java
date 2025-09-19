package gravit.code.badge.infrastructure.user;

import gravit.code.badge.domain.CriteriaType;
import gravit.code.badge.domain.user.UserBadge;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserBadgeRepository extends JpaRepository<UserBadge, Long> {
    boolean existsByUserIdAndBadge_Id(Long userId, Long badgeId);
    long countByUserIdAndBadge_CriteriaType(Long userId, CriteriaType criteriaType);
}
