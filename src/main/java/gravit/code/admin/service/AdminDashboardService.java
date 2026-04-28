package gravit.code.admin.service;

import gravit.code.admin.dto.response.AdminDashboardSummaryResponse;
import gravit.code.report.repository.ReportRepository;
import gravit.code.stagingLabel.repository.StagingLabelRepository;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private final UserRepository userRepository;
    private final StagingLabelRepository stagingLabelRepository;
    private final ReportRepository reportRepository;

    @Transactional(readOnly = true)
    public AdminDashboardSummaryResponse getDashboardSummary() {
        long totalUsers = userRepository.count();
        long pendingLabelsCount = stagingLabelRepository.countPendingLabel();
        long unresolvedReportsCount = reportRepository.countUnresolvedReport();

        return AdminDashboardSummaryResponse.create(totalUsers, pendingLabelsCount, unresolvedReportsCount);
    }
}
