package gravit.code.badge.infrastructure;

import gravit.code.badge.domain.Badge;
import gravit.code.badge.domain.CriteriaType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface BadgeRepository extends JpaRepository<Badge, Long> {
    List<Badge> findByCriteriaTypeAndCodeNot(CriteriaType criteriaType, String excludeCode);
    long countByCriteriaType(CriteriaType criteriaType);
    Optional<Badge> findByCode(String code);
}
