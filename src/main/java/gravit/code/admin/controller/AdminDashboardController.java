package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminDashboardControllerDocs;
import gravit.code.admin.dto.response.DashboardSummaryResponse;
import gravit.code.admin.service.AdminDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/dashboard")
public class AdminDashboardController implements AdminDashboardControllerDocs {

    private final AdminDashboardService adminDashboardService;

    @GetMapping("/summary")
    public ResponseEntity<DashboardSummaryResponse> getDashboardSummary() {
        return ResponseEntity.status(OK).body(adminDashboardService.getDashboardSummary());
    }
}
