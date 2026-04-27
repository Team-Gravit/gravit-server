package gravit.code.admin.controller;

import gravit.code.admin.dto.response.DashboardSummaryResponse;
import gravit.code.admin.service.AdminDashboardService;
import gravit.code.auth.domain.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/dashboard")
public class AdminDashboardController {

    private final AdminDashboardService adminDashboardService;

    @GetMapping("/dashboard/summary")
    public ResponseEntity<DashboardSummaryResponse> getDashboardSummary(@AuthenticationPrincipal LoginUser loginUser){
        return ResponseEntity.status(OK).body(adminDashboardService.getDashboardSummary());
    }
}
