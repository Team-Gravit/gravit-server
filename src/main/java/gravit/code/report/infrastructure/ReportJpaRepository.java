package gravit.code.report.infrastructure;

import gravit.code.report.domain.Report;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReportJpaRepository extends JpaRepository<Report,Long> {

    boolean existsReportByProblemIdAndUserId(Long problemId ,Long userId);
}
