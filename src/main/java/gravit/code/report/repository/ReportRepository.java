package gravit.code.report.repository;

import gravit.code.report.domain.Report;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ReportRepository extends JpaRepository<Report,Long> {

    Report save(Report report);

    Optional<Report> findById(long reportId);

    boolean existsReportByProblemIdAndUserId(
            long problemId,
            long userId
    );
}
