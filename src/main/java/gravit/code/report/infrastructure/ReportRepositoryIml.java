package gravit.code.report.infrastructure;

import gravit.code.admin.dto.response.ReportDetailResponse;
import gravit.code.admin.dto.response.ReportSummaryResponse;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ReportRepositoryIml implements ReportRepository {

    private final ReportJpaRepository reportJpaRepository;

    @Override
    public void save(Report report){
        reportJpaRepository.save(report);
    }

    @Override
    public boolean existsReportByProblemIdAndUserId(Long problemId, Long userId){
        return reportJpaRepository.existsReportByProblemIdAndUserId(problemId,userId);
    }

    @Override
    public List<ReportSummaryResponse> findAllReportSummary(Pageable pageable){
        return reportJpaRepository.findAllReportSummary(pageable);
    }

    @Override
    public Optional<ReportDetailResponse> findReportDetailById(Long reportId){
        return reportJpaRepository.findReportDetailById(reportId);
    }

    @Override
    public Optional<Report> findById(Long reportId){
        return reportJpaRepository.findById(reportId);
    }
}
