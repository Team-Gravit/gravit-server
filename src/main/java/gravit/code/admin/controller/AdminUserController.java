package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminUserControllerDocs;
import gravit.code.admin.dto.request.UserRoleUpdateRequest;
import gravit.code.admin.dto.request.UserStatusUpdateRequest;
import gravit.code.admin.dto.response.UserDetailResponse;
import gravit.code.admin.dto.response.UserListItemResponse;
import gravit.code.admin.service.AdminUserService;
import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.UserStatus;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/users")
public class AdminUserController implements AdminUserControllerDocs {

    private final AdminUserService adminUserService;

    @GetMapping
    public ResponseEntity<PageResponse<UserListItemResponse>> getUsers(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "search", required = false) String search,
            @RequestParam(value = "status", required = false) UserStatus status,
            @RequestParam(value = "role", required = false) Role role
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(adminUserService.getUsers(page, search, status, role));
    }

    @GetMapping("/{userId}")
    public ResponseEntity<UserDetailResponse> getUser(@PathVariable("userId") Long userId) {
        return ResponseEntity.status(HttpStatus.OK).body(adminUserService.getUser(userId));
    }

    @PatchMapping("/{userId}/status")
    public ResponseEntity<Void> updateStatus(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("userId") Long userId,
            @Valid @RequestBody UserStatusUpdateRequest request
    ) {
        adminUserService.updateStatus(loginUser.getId(), userId, request.status());
        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @PatchMapping("/{userId}/role")
    public ResponseEntity<Void> updateRole(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("userId") Long userId,
            @Valid @RequestBody UserRoleUpdateRequest request
    ) {
        adminUserService.updateRole(loginUser.getId(), userId, request.role());
        return ResponseEntity.status(HttpStatus.OK).build();
    }
}
