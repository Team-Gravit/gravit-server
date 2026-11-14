package gravit.code.auth.controller.docs;

import gravit.code.auth.dto.request.RefreshTokenRequest;
import gravit.code.auth.dto.response.ReissueResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.headers.Header;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import static gravit.code.auth.support.RefreshTokenCookieFactory.COOKIE_NAME;

@Tag(name = "AuthToken API", description = "인증 토큰 관련 API")
public interface AuthTokenControllerDocs {

    @Operation(
            summary = "리프레시 토큰으로 엑세스 토큰 재발급",
            description = "유효한 리프레시 토큰으로 엑세스 토큰을 재발급합니다. <br> 만약 리프레시 토큰이 유효하지 않다면 재 로그인이 필요합니다.<br>"
                    + "refreshToken 쿠키가 있으면 쿠키를 우선 사용하고, 없으면 body의 refreshToken을 사용합니다. 웹은 <code>credentials: 'include'</code>로 호출하고 body를 비워도 됩니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 엑세스 토큰 재발급 성공"),
            @ApiResponse(responseCode = "401", description = "🚨 비어 있거나 만료된 리프레시 토큰, 또는 탈퇴한 사용자",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "빈 리프레시 토큰",
                                            value = "{\"error\" : \"JWT_4013\", \"message\" : \"빈 토큰입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "만료된 리프레시 토큰",
                                            value = "{\"error\" : \"JWT_4016\", \"message\" : \"만료된 리프레시 토큰입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "탈퇴했거나 존재하지 않는 사용자",
                                            value = "{\"error\" : \"JWT_4017\", \"message\" : \"탈퇴했거나 존재하지 않는 사용자의 토큰입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/reissue")
    ResponseEntity<ReissueResponse> reissueToken(
            @Parameter(hidden = true) @CookieValue(name = COOKIE_NAME, required = false) String cookieRefreshToken,
            @RequestBody(required = false) RefreshTokenRequest request
    );

    @Operation(
            summary = "로그아웃",
            description = "리프레시 토큰을 무효화하고 refreshToken 쿠키를 만료시킵니다. 인증 없이 호출할 수 있습니다.<br>"
                    + "refreshToken 쿠키가 있으면 쿠키를 우선 사용하고, 없으면 body의 refreshToken을 사용합니다. 웹은 <code>credentials: 'include'</code>로 호출하고 body를 비워도 됩니다.<br>"
                    + "토큰이 없거나 만료, 위조된 경우에도 항상 204와 만료 쿠키를 응답합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "✅ 로그아웃 성공",
                    headers = @Header(name = "Set-Cookie", schema = @Schema(type = "string"), description = "refreshToken=; Path=/api/v1/auth; Max-Age=0; Secure; HttpOnly; SameSite=...")
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/logout")
    ResponseEntity<Void> logout(
            @Parameter(hidden = true) @CookieValue(name = COOKIE_NAME, required = false) String cookieRefreshToken,
            @RequestBody(required = false) RefreshTokenRequest request
    );
}
