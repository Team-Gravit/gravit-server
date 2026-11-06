package gravit.code.auth.controller.docs;

import gravit.code.auth.dto.request.WebAuthCodeRequest;
import gravit.code.auth.dto.response.LoginUrlResponse;
import gravit.code.auth.dto.response.WebLoginResponse;
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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;

import static org.springframework.http.HttpHeaders.ORIGIN;

@Tag(name = "OAuth2.0 API", description = "OAuth 관련 API")
public interface OAuthControllerDocs {

    @Operation(
            summary = "로그인 URL 생성",
            description = "OAuth 정보를 바탕으로 로그인 URL과 state를 생성합니다.<br>"
                    + "redirect 호스트는 요청의 Origin 헤더로 판별하고, Origin이 등록된 웹 호스트가 아니면 dest로 판별합니다. 브라우저에서 호출하면 dest를 보내지 않아도 됩니다.<br>"
                    + "응답의 state는 로그인 URL에 함께 들어 있으며, 10분 뒤 만료되고 한 번만 쓸 수 있습니다. OAuth 콜백 쿼리로 돌아온 state를 로그인 요청 body에 그대로 담아 보내야 합니다.<br>"
                    + "provider가 apple이면 Apple 인가 URL을 돌려줍니다. Apple JS SDK를 쓰는 경우 응답의 state를 SDK init에 넣어야 합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 로그인 URL 생성 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 유효하지 않은 OAuth 제공자 또는 웹 로그인 환경",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 OAuth 제공자",
                                            value = "{\"error\" : \"AUTH_4001\", \"message\" : \"유효하지 않은 OAuth 제공자 이름입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "웹 로그인 환경 판별 실패",
                                            value = "{\"error\" : \"DEST_4001\", \"message\" : \"웹 로그인 환경을 판별할 수 없습니다.\"}"
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
    ResponseEntity<LoginUrlResponse> authorizeUrl(
            @Parameter(description = "제공자(kakao, naver, google, apple) 이름") @PathVariable("provider") String provider,
            @Parameter(hidden = true) @RequestHeader(value = ORIGIN, required = false) String origin,
            @Parameter(description = "Dest(local, dev, prod, admin). Origin으로 판별할 수 없을 때만 사용 (선택)") @RequestParam(required = false) String dest
    );

    @Operation(
            summary = "OAuth 회원가입/로그인 처리",
            description = "AuthCode와 state를 기반으로 사용자 정보를 조회하고 회원가입 및 로그인 처리를 합니다.<br>"
                    + "state는 로그인 URL 조회 때 서버가 발급한 값이어야 하며 한 번만 쓸 수 있습니다.<br>"
                    + "redirect 호스트는 Origin 헤더로 판별하고, 판별할 수 없을 때만 dest를 사용합니다.<br>"
                    + "리프레시 토큰은 응답 본문이 아닌 <strong>HttpOnly 쿠키(refreshToken, Path=/api/v1/auth)</strong>로 발급합니다. 요청에 <code>credentials: 'include'</code>가 필요합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ OAuth 회원가입/로그인 성공",
                    headers = @Header(name = "Set-Cookie", description = "refreshToken=...; Path=/api/v1/auth; Secure; HttpOnly; SameSite=...")
            ),
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
                                    ),
                                    @ExampleObject(
                                            name = "유효하지 않은 state",
                                            value = "{\"error\" : \"AUTH_4011\", \"message\" : \"유효하지 않은 OAuth state 입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "웹 로그인 환경 판별 실패",
                                            value = "{\"error\" : \"DEST_4001\", \"message\" : \"웹 로그인 환경을 판별할 수 없습니다.\"}"
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
    ResponseEntity<WebLoginResponse> oauthLogin(
            @Parameter(description = "제공자(kakao, naver, google) 이름") @PathVariable("provider") String provider,
            @RequestBody WebAuthCodeRequest webAuthCodeRequest,
            @Parameter(hidden = true) @RequestHeader(value = ORIGIN, required = false) String origin,
            @Parameter(description = "Dest(local, dev, prod, admin). Origin으로 판별할 수 없을 때만 사용 (선택)") @RequestParam(required = false) String dest
    );

    @Operation(
            summary = "Apple 회원가입/로그인 처리",
            description = "Apple JS SDK 팝업으로 받은 AuthCode를 Apple에서 토큰으로 교환하고, id_token을 검증해 회원가입 및 로그인 처리를 합니다.<br>"
                    + "state는 login-url/apple 조회 때 서버가 발급한 값이어야 하며 한 번만 쓸 수 있습니다.<br>"
                    + "프론트의 redirectURI는 {웹 도메인}/login/oauth2/code/apple 이어야 하며, scope에 email이 포함되어야 합니다. 웹 도메인은 Origin 헤더로 판별하고, 판별할 수 없을 때만 dest를 사용합니다.<br>"
                    + "Apple은 localhost를 등록할 수 없어 로컬 환경으로는 로그인할 수 없습니다.<br>"
                    + "리프레시 토큰은 응답 본문이 아닌 <strong>HttpOnly 쿠키(refreshToken, Path=/api/v1/auth)</strong>로 발급합니다. 요청에 <code>credentials: 'include'</code>가 필요합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ Apple 회원가입/로그인 성공",
                    headers = @Header(name = "Set-Cookie", description = "refreshToken=...; Path=/api/v1/auth; Secure; HttpOnly; SameSite=...")
            ),
            @ApiResponse(responseCode = "400", description = "🚨 요청 또는 Apple 응답이 유효하지 않음",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 AuthCode",
                                            value = "{\"error\" : \"AUTH_4002\", \"message\" : \"유효하지 않은 AuthCode 입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "유효하지 않은 state",
                                            value = "{\"error\" : \"AUTH_4011\", \"message\" : \"유효하지 않은 OAuth state 입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "웹 로그인 환경 판별 실패",
                                            value = "{\"error\" : \"DEST_4001\", \"message\" : \"웹 로그인 환경을 판별할 수 없습니다.\"}"
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
    ResponseEntity<WebLoginResponse> appleLogin(
            @RequestBody WebAuthCodeRequest webAuthCodeRequest,
            @Parameter(hidden = true) @RequestHeader(value = ORIGIN, required = false) String origin,
            @Parameter(description = "Dest(dev, prod). Origin으로 판별할 수 없을 때만 사용 (선택)") @RequestParam(required = false) String dest
    );
}
