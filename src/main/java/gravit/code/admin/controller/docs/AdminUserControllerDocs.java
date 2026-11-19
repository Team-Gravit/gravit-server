package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.UserRoleUpdateRequest;
import gravit.code.admin.dto.request.UserStatusUpdateRequest;
import gravit.code.admin.dto.response.NicknameResetResponse;
import gravit.code.admin.dto.response.UserDetailResponse;
import gravit.code.admin.dto.response.UserListItemResponse;
import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.UserStatus;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin User API", description = "백오피스 유저 관리 (DELETED 포함 조회)")
public interface AdminUserControllerDocs {

    @Operation(summary = "유저 목록", description = "search(email/nickname/handle 부분일치)·status·role 필터, 1-based page, size 20 고정.")
    @ApiResponses(@ApiResponse(responseCode = "200", description = "조회 성공"))
    ResponseEntity<PageResponse<UserListItemResponse>> getUsers(
            int page,
            String search,
            UserStatus status,
            Role role
    );

    @Operation(summary = "유저 상세")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 유저")
    })
    ResponseEntity<UserDetailResponse> getUser(Long userId);

    @Operation(summary = "유저 상태 변경", description = "ACTIVE/SUSPENDED/DELETED. 감사 로그 기록.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "변경 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 유저")
    })
    ResponseEntity<Void> updateStatus(
            LoginUser loginUser,
            Long userId,
            UserStatusUpdateRequest request
    );

    @Operation(summary = "유저 권한 변경", description = "ADMIN/USER. 감사 로그 기록.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "변경 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 유저")
    })
    ResponseEntity<Void> updateRole(
            LoginUser loginUser,
            Long userId,
            UserRoleUpdateRequest request
    );

    @Operation(summary = "유저 닉네임 초기화", description = "닉네임을 '유저' + 숫자 6자리 기본 닉네임으로 바꾼다. 그 유저에게 걸린 미처리 닉네임 신고(INAPPROPRIATE_NICKNAME)는 처리 완료가 된다. 감사 로그 기록.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "초기화 성공. 새 닉네임 반환"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 유저")
    })
    ResponseEntity<NicknameResetResponse> resetNickname(
            LoginUser loginUser,
            Long userId
    );
}
