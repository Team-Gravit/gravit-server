package gravit.code.report.repository;

import gravit.code.report.domain.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface ReportRepository extends JpaRepository<Report,Long> {

    Report save(Report report);

    Optional<Report> findById(long reportId);

    boolean existsReportByProblemIdAndUserId(
            long problemId,
            long userId
    );

    @Query("""
        SELECT count(r)
        FROM Report r
        WHERE r.isResolved = false
    """)
    long countUnresolvedReport();
}
