package gravit.code.report.infrastructure;

import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

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
}
