package gravit.code.admin.repository;

import gravit.code.report.domain.UserReport;
import gravit.code.report.domain.UserReportType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AdminUserReportRepository extends JpaRepository<UserReport, Long> {

    @Query("""
            SELECT r
            FROM UserReport r
            WHERE (:reportType IS NULL OR r.reportType = :reportType)
              AND (:isResolved IS NULL OR r.isResolved = :isResolved)
            ORDER BY r.id DESC
    """)
    Page<UserReport> search(
            @Param("reportType") UserReportType reportType,
            @Param("isResolved") Boolean isResolved,
            Pageable pageable
    );

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
            UPDATE UserReport r
            SET r.isResolved = true
            WHERE r.targetUserId = :targetUserId AND r.reportType = :reportType AND r.isResolved = false
    """)
    int resolveUnresolvedByTargetUserIdAndReportType(
            @Param("targetUserId") long targetUserId,
            @Param("reportType") UserReportType reportType
    );
}
