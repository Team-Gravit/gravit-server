package gravit.code.admin.repository;

import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AdminReportRepository extends JpaRepository<Report, Long> {

    @Query("""
            SELECT r
            FROM Report r
            WHERE (:reportType IS NULL OR r.reportType = :reportType)
              AND (:isResolved IS NULL OR r.isResolved = :isResolved)
            ORDER BY r.id DESC
    """)
    Page<Report> search(
            @Param("reportType") ReportType reportType,
            @Param("isResolved") Boolean isResolved,
            Pageable pageable
    );

    long countByIsResolvedFalse();
}
