package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminDashboardControllerDocs;
import gravit.code.admin.dto.response.DailyActiveUserTrendResponse;
import gravit.code.admin.dto.response.DashboardSummaryResponse;
import gravit.code.admin.dto.response.MonthlyActiveUserTrendResponse;
import gravit.code.admin.service.AdminDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Validated
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/dashboard")
public class AdminDashboardController implements AdminDashboardControllerDocs {

    private final AdminDashboardService adminDashboardService;

    @GetMapping("/summary")
    public ResponseEntity<DashboardSummaryResponse> getSummary() {
        return ResponseEntity.status(HttpStatus.OK).body(adminDashboardService.getSummary());
    }

    @GetMapping("/active-users/daily")
    public ResponseEntity<DailyActiveUserTrendResponse> getDailyActiveUsers(
            @RequestParam(value = "days", defaultValue = "30") int days
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(adminDashboardService.getDailyActiveUsers(days));
    }

    @GetMapping("/active-users/monthly")
    public ResponseEntity<MonthlyActiveUserTrendResponse> getMonthlyActiveUsers(
            @RequestParam(value = "months", defaultValue = "12") int months
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(adminDashboardService.getMonthlyActiveUsers(months));
    }
}
