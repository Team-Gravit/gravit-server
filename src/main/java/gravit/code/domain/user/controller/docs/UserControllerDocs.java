package gravit.code.domain.user.controller.docs;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.domain.user.dto.request.OnboardingRequest;
import gravit.code.domain.user.dto.response.MyPageResponse;
import gravit.code.domain.user.dto.response.UserResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "User API", description = "유저 관련 API (정보 조회, 온보딩 등)")
public interface UserControllerDocs {
    // 유저 정보 조회
    @Operation(summary = "유저 정보 조회", description = "로그인한 사용자의 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공")
    })
    @GetMapping
    ResponseEntity<UserResponse> getUser(
            @AuthenticationPrincipal LoginUser loginUser);

    // 온보딩 정보 등록
    @Operation(summary = "온보딩 정보 등록", description = "최초 로그인 시 사용자 온보딩 정보를 저장합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "온보딩 완료")
    })
    @PatchMapping("/onboarding")
    ResponseEntity<UserResponse> onboardUser(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestBody OnboardingRequest request);

    // 마이 페이지 조회
    @Operation(summary = "마이페이지 조회", description = "사용자의 마이페이지 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공")
    })
    @GetMapping("/my-page")
    ResponseEntity<MyPageResponse> getMyPage(
            @AuthenticationPrincipal LoginUser loginUser);
}
