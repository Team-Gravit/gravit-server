package gravit.code.badge.repository;

import gravit.code.badge.domain.Badge;
import gravit.code.badge.domain.CriteriaType;
import gravit.code.badge.dto.BadgeCatalogRowDto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface BadgeRepository extends JpaRepository<Badge, Long> {
    List<Badge> findByCriteriaTypeAndCodeNot(
            CriteriaType criteriaType,
            String excludeCode
    );
    long countByCriteriaType(CriteriaType criteriaType);
    Optional<Badge> findByCode(String code);

    @Query("""
        select new gravit.code.badge.dto.BadgeCatalogRowDto(
            bc.id, bc.name, bc.displayOrder,bc.description,
            b.id, b.code, b.name, b.description,
            b.iconId, b.displayOrder
        )
        from Badge b
        join b.category bc
        order by bc.displayOrder asc, b.displayOrder asc, b.id asc
    """)
    List<BadgeCatalogRowDto> findCatalogOrdered();
}
