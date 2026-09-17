package gravit.code.admin.service;

import gravit.code.admin.domain.AdminUser;
import gravit.code.admin.domain.audit.AuditAction;
import gravit.code.admin.dto.response.UserDetailResponse;
import gravit.code.admin.dto.response.UserListItemResponse;
import gravit.code.admin.repository.AdminUserRepository;
import gravit.code.admin.support.AdminPages;
import gravit.code.admin.support.AuditLogRecorder;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.UserStatus;
import gravit.code.user.support.RandomHandleGenerator;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class AdminUserService {

    private final AdminUserRepository adminUserRepository;

    private final AuditLogRecorder auditLogRecorder;
    private final RandomHandleGenerator handleGenerator;

    @Transactional(readOnly = true)
    public PageResponse<UserListItemResponse> getUsers(
            int page,
            String search,
            UserStatus status,
            Role role
    ) {
        Pageable pageable = AdminPages.of(page);
        String normalizedSearch = (search == null || search.isBlank()) ? null : search.trim();
        String statusName = (status == null) ? null : status.name();
        String roleName = (role == null) ? null : role.name();

        return PageResponse.from(
                adminUserRepository.searchUsers(normalizedSearch, statusName, roleName, pageable)
                        .map(UserListItemResponse::from)
        );
    }

    @Transactional(readOnly = true)
    public UserDetailResponse getUser(long userId) {
        AdminUser user = adminUserRepository.findRowById(userId)
                .orElseThrow(() -> new RestApiException(USER_NOT_FOUND));

        return UserDetailResponse.from(user);
    }

    @Transactional
    public void updateStatus(
            long adminId,
            long userId,
            UserStatus status
    ) {
        AdminUser user = adminUserRepository.findRowById(userId)
                .orElseThrow(() -> new RestApiException(USER_NOT_FOUND));

        String before = user.getStatus();

        if (isRestore(before, status)) {
            String newHandle = handleGenerator.generateUniqueHandle();
            adminUserRepository.restoreStatusById(userId, status.name(), newHandle);
        } else {
            adminUserRepository.updateStatusById(userId, status.name());
        }

        auditLogRecorder.record(adminId, AuditAction.USER_STATUS_CHANGE, String.valueOf(userId), before, status.name());
    }

    @Transactional
    public void updateRole(
            long adminId,
            long userId,
            Role role
    ) {
        AdminUser user = adminUserRepository.findRowById(userId)
                .orElseThrow(() -> new RestApiException(USER_NOT_FOUND));

        String before = user.getRole();

        adminUserRepository.updateRoleById(userId, role.name());

        auditLogRecorder.record(adminId, AuditAction.USER_ROLE_CHANGE, String.valueOf(userId), before, role.name());
    }

    private boolean isRestore(
            String beforeStatus,
            UserStatus target
    ) {
        return UserStatus.DELETED.name().equals(beforeStatus) && target != UserStatus.DELETED;
    }
}
