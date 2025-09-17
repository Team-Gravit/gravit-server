package gravit.code.report.domain;

import gravit.code.admin.dto.response.ReportDetailResponse;
import gravit.code.admin.dto.response.ReportSummaryResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface ReportRepository {
    void save(Report report);
    boolean existsReportByProblemIdAndUserId(Long problemId ,Long userId);
    List<ReportSummaryResponse> findAllReportSummary(Pageable pageable);
    Optional<ReportDetailResponse> findReportDetailById(Long reportId);
    Optional<Report> findById(Long reportId);
}
