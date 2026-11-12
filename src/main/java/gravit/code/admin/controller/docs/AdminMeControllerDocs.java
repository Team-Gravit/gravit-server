package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.response.AdminMeResponse;
import gravit.code.auth.domain.LoginUser;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin Me API", description = "현재 로그인한 운영자 본인 프로필")
public interface AdminMeControllerDocs {

    @Operation(summary = "현재 운영자 프로필", description = "인증된 운영자 본인의 adminId·nickname·email·profileImgNumber 조회. 백오피스 사이드바 표시용.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "401", description = "미인증(토큰 없음/무효)"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 유저")
    })
    ResponseEntity<AdminMeResponse> getMe(LoginUser loginUser);
}
