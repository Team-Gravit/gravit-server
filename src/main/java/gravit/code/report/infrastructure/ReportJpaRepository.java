package gravit.code.report.infrastructure;

import gravit.code.admin.dto.response.ReportDetailResponse;
import gravit.code.admin.dto.response.ReportSummaryResponse;
import gravit.code.report.domain.Report;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ReportJpaRepository extends JpaRepository<Report,Long> {

    boolean existsReportByProblemIdAndUserId(Long problemId, Long userId);

    @Query("""
        SELECT new gravit.code.admin.dto.response.ReportSummaryResponse(r.id, r.reportType, r.problemId, r.isResolved, r.submittedAt)
        FROM Report r
        ORDER BY r.id DESC
    """)
    List<ReportSummaryResponse> findAllReportSummary(Pageable pageable);

    @Query("""
        SELECT new gravit.code.admin.dto.response.ReportDetailResponse(r.id, r.reportType, r.problemId, r.content, r.isResolved, r.submittedAt)
        FROM Report r
        WHERE r.id = :reportId
    """)
    Optional<ReportDetailResponse> findReportDetailById(@Param("reportId") Long reportId);
}
