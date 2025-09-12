package gravit.code.report.domain;

public interface ReportRepository {
    void save(Report report);
    boolean existsReportByProblemIdAndUserId(Long problemId ,Long userId);
}
