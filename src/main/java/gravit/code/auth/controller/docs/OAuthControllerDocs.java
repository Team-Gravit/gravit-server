package gravit.code.auth.controller.docs;

import gravit.code.auth.dto.oauth.AuthCodeRequest;
import gravit.code.auth.dto.response.LoginResponse;
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
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;

@Tag(name = "OAuth2.0 API", description = "OAuth 관련 API")
public interface OAuthControllerDocs {

    @Operation(summary = "로그인 URL 생성", description = "OAuth 정보를 바탕으로 로그인 URL을 생성합니다")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 로그인 URL 생성 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 유효하지 않은 OAuth 제공자",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 OAuth 제공자",
                                            value = "{\"error\" : \"AUTH_4001\", \"message\" : \"유효하지 않은 OAuth 제공자 이름입니다.\"}"
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
    @GetMapping("/login-url/{provider}")
    ResponseEntity<Map<String, String>> authorizeUrl(
            @Parameter(description = "제공자(kakao, naver, google) 이름") @PathVariable("provider") String provider,
            @Parameter(description = "Dest(local, dev, prod)") @RequestParam String dest
    );

    @Operation(summary = "OAuth 회원가입/로그인 처리", description = "AuthCode를 기반으로 사용자 정보를 조회하고 회원가입 및 로그인 처리를 합니다")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ OAuth 회원가입/로그인 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 유효하지 않은 OAuth 제공자",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 OAuth 제공자",
                                            value = "{\"error\" : \"AUTH_4001\", \"message\" : \"유효하지 않은 OAuth 제공자 이름입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "400", description = "🚨 유효하지 않은 AuthCode",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 AuthCode",
                                            value = "{\"error\" : \"AUTH_4002\", \"message\" : \"유효하지 않은 AuthCode 입니다.\"}"
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
    @PostMapping("/{provider}")
    ResponseEntity<LoginResponse> oauthLogin(
            @Parameter(description = "제공자(kakao, naver, google) 이름") @PathVariable("provider") String provider,
            @RequestBody AuthCodeRequest authCodeRequest,
            @Parameter(description = "Dest(local, dev, prod)") @RequestParam String dest
    );

    @Operation(
            summary = "Apple 회원가입/로그인 처리",
            description = "Apple JS SDK 팝업으로 받은 AuthCode를 Apple에서 토큰으로 교환하고, id_token을 검증해 회원가입 및 로그인 처리를 합니다.<br>"
                    + "프론트의 redirectURI는 {dest 도메인}/login/oauth2/code/apple 이어야 하며, scope에 email이 포함되어야 합니다.<br>"
                    + "Apple은 localhost를 등록할 수 없어 dest=local로는 로그인할 수 없습니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ Apple 회원가입/로그인 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 요청 또는 Apple 응답이 유효하지 않음",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 AuthCode",
                                            value = "{\"error\" : \"AUTH_4002\", \"message\" : \"유효하지 않은 AuthCode 입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "유효하지 않은 Dest",
                                            value = "{\"error\" : \"DEST_4001\", \"message\" : \"유효하지 않은 Dest 입니다. (local/prod 만 유효합니다.)\"}"
                                    ),
                                    @ExampleObject(
                                            name = "Apple 응답에 IdToken 없음",
                                            value = "{\"error\" : \"AUTH_4004\", \"message\" : \"유효하지 않은 OAuth IdToken 입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "IdToken 서명 또는 만료 검증 실패",
                                            value = "{\"error\" : \"AUTH_4005\", \"message\" : \"유효하지 않은 OAuth IdToken 입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "IdToken Issuer 불일치",
                                            value = "{\"error\" : \"AUTH_4007\", \"message\" : \"IdToken 의 Issuer 가 매칭되지 않습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "IdToken audience 불일치",
                                            value = "{\"error\" : \"AUTH_4009\", \"message\" : \"IdToken 의 audience 가 매칭되지 않습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "이메일 등 필수 사용자 정보 누락",
                                            value = "{\"error\" : \"AUTH_4010\", \"message\" : \"OAuth 제공자로부터 유효한 사용자 정보를 받지 못했습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "502", description = "🚨 Apple 인증 서버 통신 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "Apple 인증 서버 통신 실패",
                                            value = "{\"error\" : \"AUTH_502\", \"message\" : \"OAuth 인증 서버와의 통신에 실패하였습니다.\"}"
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
    @PostMapping("/apple")
    ResponseEntity<LoginResponse> appleLogin(
            @RequestBody AuthCodeRequest authCodeRequest,
            @Parameter(description = "Dest(local, dev, prod)") @RequestParam String dest
    );
}
