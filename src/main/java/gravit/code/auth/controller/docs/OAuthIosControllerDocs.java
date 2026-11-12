package gravit.code.auth.controller.docs;

import gravit.code.auth.dto.oauth.AuthCodeRequest;
import gravit.code.auth.dto.oauth.app.AccessTokenRequest;
import gravit.code.auth.dto.oauth.app.IdTokenRequest;
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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "OAuth2.0 iOS API", description = "iOS OAuth 관련 API")
public interface OAuthIosControllerDocs {

    @Operation(
            summary = "Apple iOS 회원가입/로그인 처리",
            description = "iOS 앱이 네이티브 Sign in with Apple 모듈로 받은 authorizationCode를 Apple에서 토큰으로 교환하고, id_token을 검증해 회원가입 및 로그인 처리를 합니다.<br>"
                    + "body의 code에 authorizationCode를 담아 보냅니다. identityToken, nonce, redirect URI, dest는 받지 않습니다.<br>"
                    + "앱의 requestedScopes에 EMAIL이 포함되어야 하며, 웹 Apple 로그인과 같은 Apple 계정(sub)으로 이어집니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ Apple iOS 회원가입/로그인 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 요청 또는 Apple 응답이 유효하지 않음",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 AuthCode",
                                            value = "{\"error\" : \"AUTH_4002\", \"message\" : \"유효하지 않은 AuthCode 입니다.\"}"
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
            @RequestBody AuthCodeRequest authCodeRequest
    );

    @Operation(
            summary = "iOS OAuth 회원가입/로그인 처리",
            description = "iOS 앱에서 전달한 OAuth IdToken과 provider로 사용자 정보를 확인하고 회원가입 및 로그인 처리를 합니다.<br>"
                    + "google, kakao만 이 API로 로그인할 수 있습니다(IdToken 방식). IdToken은 body에, provider는 쿼리 파라미터로 보냅니다.<br>"
                    + "Google은 webClientId로 발급받은 IdToken을 보내야 합니다. 리프레시 토큰은 iOS 로그인으로 구분되어, 안드로이드 로그인을 끊지 않습니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ iOS OAuth 회원가입/로그인 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 요청 또는 IdToken이 유효하지 않음",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 OAuth 제공자",
                                            value = "{\"error\" : \"AUTH_4001\", \"message\" : \"유효하지 않은 OAuth 제공자 이름입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "유효하지 않은 OAuth IdToken",
                                            value = "{\"error\" : \"AUTH_4004\", \"message\" : \"유효하지 않은 OAuth IdToken 입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "IdToken 디코딩 실패",
                                            value = "{\"error\" : \"AUTH_4005\", \"message\" : \"유효하지 않은 OAuth IdToken 입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "Issuer 불일치",
                                            value = "{\"error\" : \"AUTH_4007\", \"message\" : \"IdToken 의 Issuer 가 매칭되지 않습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "Audience 없음",
                                            value = "{\"error\" : \"AUTH_4008\", \"message\" : \"IdToken 의 audience 가 비어있습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "Audience 불일치",
                                            value = "{\"error\" : \"AUTH_4009\", \"message\" : \"IdToken 의 audience 가 매칭되지 않습니다.\"}"
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
            @Parameter(description = "OAuth 제공자 이름(google, kakao)", example = "google")
            @RequestParam("provider") String provider,
            @RequestBody IdTokenRequest request
    );

    @Operation(
            summary = "iOS 네이버 OAuth 회원가입/로그인 처리",
            description = "iOS 앱에서 전달한 네이버 AccessToken으로 회원가입 및 로그인 처리를 합니다.<br>"
                    + "네이버는 IdToken 방식을 지원하지 않아, 앱이 네이버 SDK로 발급받은 AccessToken을 보내면 서버가 네이버에 사용자 정보를 조회해 검증합니다.<br>"
                    + "AccessToken은 body에 담아 보냅니다. 리프레시 토큰은 iOS 로그인으로 구분되어, 안드로이드 로그인을 끊지 않습니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ iOS 네이버 OAuth 회원가입/로그인 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 AccessToken 또는 사용자 정보가 유효하지 않음",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 OAuth AccessToken",
                                            value = "{\"error\" : \"AUTH4003\", \"message\" : \"유효하지 않은 OAuth AccessToken\"}"
                                    ),
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
