package gravit.code.auth.controller.docs;

import gravit.code.auth.dto.oauth.android.AccessTokenRequest;
import gravit.code.auth.dto.oauth.android.IdTokenRequest;
import gravit.code.auth.dto.response.LoginResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "OAuth2.0 Android API", description = "Android OAuth 관련 API")
public interface OAuthAndroidControllerDocs {

    @Operation(summary = "OAuth 회원가입/로그인 처리",
            description = "Android 에서 전달한 OAuth IdToken 및 provider 기반으로 사용자 정보를 조회하고 회원가입/로그인 처리를 합니다. <br>"
                    + "google, kakao 만 해당 api로 로그인 할 수 있습니다(IdToken 방식)"
                    + "IdToken 을 body에 담고, provider는 쿼리 파라미터로 담아서 사용합니다.")
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
            @ApiResponse(responseCode = "400", description = "🚨 유효하지 않은 OAuth IdToken",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 OAuth IdToken",
                                            value = "{\"error\" : \"AUTH_4004\", \"message\" : \"유효하지 않은 OAuth IdToken 입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "400", description = "🚨 IdToken 디코딩 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "IdToken 디코딩 실패",
                                            value = "{\"error\" : \"AUTH_4004\", \"message\" : \"IdToken을 JWT로 디코딩하는데 실패했습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "400", description = "🚨 Issuer 불일치",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "Issuer 불일치",
                                            value = "{\"error\" : \"AUTH_4005\", \"message\" : \"IdToken의 발급자(issuer)가 일치하지 않습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "400", description = "🚨 Audience 없음",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "Audience 없음",
                                            value = "{\"error\" : \"AUTH_4006\", \"message\" : \"IdToken에 audience claim이 존재하지 않습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "400", description = "🚨 Audience 불일치",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "Audience 불일치",
                                            value = "{\"error\" : \"AUTH_4007\", \"message\" : \"IdToken의 수신자(audience)가 일치하지 않습니다.\"}"
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
    @PostMapping
    ResponseEntity<LoginResponse> oauthLogin(
            @RequestParam("provider") String provider,
            @RequestBody IdTokenRequest request
    );

    @Operation(summary = "네이버 OAuth 회원가입/로그인 처리",
            description = "Android에서 전달한 네이버 AccessToken 으로 회원가입/로그인 처리를 합니다. <br>"
                    + "네이버는 IdToken 방식을 지원하지 않기 때문에, Android 가 네이버 SDK로 발급받은 AccessToken 을 전달하면 "
                    + "서버가 네이버에 사용자 정보를 조회해 검증합니다. <br>"
                    + "AccessToken 을 body에 담아서 사용합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 네이버 OAuth 회원가입/로그인 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 유효하지 않은 OAuth AccessToken",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 OAuth AccessToken",
                                            value = "{\"error\" : \"AUTH4003\", \"message\" : \"유효하지 않은 OAuth AccessToken\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "400", description = "🚨 사용자 정보 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "사용자 정보 조회 실패",
                                            value = "{\"error\" : \"AUTH_4010\", \"message\" : \"OAuth 제공자로부터 유효한 사용자 정보를 받지 못했습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "502", description = "🚨 OAuth 서버 통신 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "OAuth 서버 통신 실패",
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
    @PostMapping("/naver")
    ResponseEntity<LoginResponse> oauthNaverLogin(
            @RequestBody AccessTokenRequest request
    );
}
