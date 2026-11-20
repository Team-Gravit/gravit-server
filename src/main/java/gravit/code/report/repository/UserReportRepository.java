package gravit.code.report.repository;

import gravit.code.report.domain.UserReport;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserReportRepository extends JpaRepository<UserReport, Long> {

    boolean existsByReporterIdAndTargetUserIdAndIsResolvedFalse(
            long reporterId,
            long targetUserId
    );
}
