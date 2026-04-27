package gravit.code.admin.service;

import gravit.code.admin.dto.response.DashboardSummaryResponse;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private final UserRepository userRepository;
    private final

    @Transactional(readOnly = true)
    public DashboardSummaryResponse getDashboardSummary() {
    }
}
