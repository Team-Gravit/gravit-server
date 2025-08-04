package gravit.code.auth.oauth.controller.docs;

import gravit.code.auth.oauth.dto.AuthCodeRequest;
import gravit.code.auth.oauth.dto.LoginResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.Map;

@Tag(name = "OAuth2.0 API", description = "OAuth 관련 API")
public interface OAuthControllerDocs {

    @Operation(summary = "로그인 URL 생성", description = "OAuth 정보를 바탕으로 로그인 URL을 생성합니다")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 로그인 URL 생성 성공"),
            @ApiResponse(responseCode = "AUTH_4001", description = "🚨 유효하지 않은 OAuth 제공자",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 OAuth 제공자",
                                            value = "{\"error\" : \"AUTH_4001\", \"message\" : \"유효하지 않은 OAuth 제공자 이름입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "GLOBAL_5001", description = "🚨 예기치 못한 예외 발생",
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
    @GetMapping("/login-url/{provider}")
    ResponseEntity<Map<String, String>> authorizeUrl(@Parameter(description = "제공자(kakao, naver, google) 이름") @PathVariable("provider") String provider);

    @Operation(summary = "OAuth 회원가입/로그인 처리", description = "AuthCode를 기반으로 사용자 정보를 조회하고 회원가입 및 로그인 처리를 합니다")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ OAuth 회원가입/로그인 성공"),
            @ApiResponse(responseCode = "AUTH_4001", description = "🚨 유효하지 않은 OAuth 제공자",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 OAuth 제공자",
                                            value = "{\"error\" : \"AUTH_4001\", \"message\" : \"유효하지 않은 OAuth 제공자 이름입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "AUTH_4002", description = "🚨 유효하지 않은 AuthCode",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 AuthCode",
                                            value = "{\"error\" : \"AUTH_4002\", \"message\" : \"유효하지 않은 AuthCode 입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "GLOBAL_5001", description = "🚨 예기치 못한 예외 발생",
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
    @PostMapping("/{provider}")
    ResponseEntity<LoginResponse> oauthLogin(@Parameter(description = "제공자(kakao, naver, google) 이름") @PathVariable("provider") String provider,
                                             @RequestBody AuthCodeRequest request);
}