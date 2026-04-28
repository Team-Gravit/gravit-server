package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminUserControllerDocs;
import gravit.code.admin.dto.request.AdminUserStatusUpdateRequest;
import gravit.code.admin.dto.response.AdminUserDetailResponse;
import gravit.code.admin.dto.response.AdminUserSummaryResponse;
import gravit.code.admin.service.AdminUserService;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.UserStatus;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/users")
public class AdminUserController implements AdminUserControllerDocs {

    private final AdminUserService adminUserService;

    @GetMapping
    public ResponseEntity<PageResponse<AdminUserSummaryResponse>> getUsersSummary(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) UserStatus status,
            @RequestParam(required = false) Role role
    ){
        return ResponseEntity.status(OK).body(adminUserService.getUsersSummary(page, search, status, role));
    }

    @GetMapping("/{userId}")
    public ResponseEntity<AdminUserDetailResponse> getUserDetail(@PathVariable("userId") long userId) {
        return ResponseEntity.status(OK).body(adminUserService.getUserDetail(userId));
    }

    @PatchMapping("/{userId}/status")
    public ResponseEntity<Void> updateUserStatus(
            @PathVariable("userId") long userId,
            @Valid@RequestBody AdminUserStatusUpdateRequest request
    ) {
        adminUserService.updateUserStatus(userId, request.status());
        return ResponseEntity.ok().build();
    }
}
