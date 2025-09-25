package gravit.code.badge.infrastructure.user;

import gravit.code.badge.domain.CriteriaType;
import gravit.code.badge.domain.user.UserBadge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface UserBadgeRepository extends JpaRepository<UserBadge, Long> {
    boolean existsByUserIdAndBadge_Id(
            long userId,
            long badgeId
    );
    long countByUserIdAndBadge_CriteriaType(
            long userId,
            CriteriaType criteriaType
    );

    @Query("select ub.badge.id from UserBadge ub where ub.userId = :userId")
    List<Long> findBadgeIdsByUserId(@Param("userId") long userId);
}
