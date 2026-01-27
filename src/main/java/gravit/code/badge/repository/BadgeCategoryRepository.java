package gravit.code.badge.repository;

import gravit.code.badge.domain.BadgeCategory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BadgeCategoryRepository extends JpaRepository<BadgeCategory, Long> {
}
