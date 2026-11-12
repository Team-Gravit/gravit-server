package gravit.code.auth.controller;

import gravit.code.auth.controller.docs.OAuthControllerDocs;
import gravit.code.auth.domain.LoginClient;
import gravit.code.auth.dto.internal.AppleLoginDto;
import gravit.code.auth.dto.internal.WebLoginDto;
import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.dto.request.WebAuthCodeRequest;
import gravit.code.auth.dto.response.LoginResponse;
import gravit.code.auth.dto.response.LoginUrlResponse;
import gravit.code.auth.dto.response.WebLoginResponse;
import gravit.code.auth.service.oauth.OAuthLoginProcessor;
import gravit.code.auth.service.oauth.OAuthLoginUrlService;
import gravit.code.auth.service.oauth.OAuthUserInfoService;
import gravit.code.auth.service.oauth.apple.AppleOAuthService;
import gravit.code.auth.support.RefreshTokenCookieFactory;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpHeaders.ORIGIN;
import static org.springframework.http.HttpHeaders.SET_COOKIE;
import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/oauth")
public class OAuthController implements OAuthControllerDocs {

    private final OAuthUserInfoService oAuthClientService;
    private final OAuthLoginUrlService oAuthLoginUrlService;
    private final AppleOAuthService appleOAuthService;

    private final OAuthLoginProcessor oAuthLoginProcessor;
    private final RefreshTokenCookieFactory refreshTokenCookieFactory;

    @GetMapping("/login-url/{provider}")
    public ResponseEntity<LoginUrlResponse> authorizeUrl(
            @PathVariable("provider") String provider,
            @RequestHeader(value = ORIGIN, required = false) String origin,
            @RequestParam(required = false) String dest
    ) {
        LoginUrlResponse response = oAuthLoginUrlService.generateLoginUrl(provider, origin, dest);
        return ResponseEntity.status(OK).body(response);
    }

    @PostMapping("/{provider}")
    public ResponseEntity<WebLoginResponse> oauthLogin(
            @PathVariable("provider") String provider,
            @RequestBody @Valid WebAuthCodeRequest webAuthCodeRequest,
            @RequestHeader(value = ORIGIN, required = false) String origin,
            @RequestParam(required = false) String dest
    ) {
        OAuthUserInfo userInfo = oAuthClientService.getUserInfo(provider, WebLoginDto.of(webAuthCodeRequest, origin, dest));

        LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo, LoginClient.WEB);

        return webLoginResponse(loginResponse);
    }

    private ResponseEntity<WebLoginResponse> webLoginResponse(LoginResponse loginResponse) {
        return ResponseEntity.status(OK)
                .header(SET_COOKIE, refreshTokenCookieFactory.create(loginResponse.refreshToken()).toString())
                .body(WebLoginResponse.from(loginResponse));
    }

    @PostMapping("/apple")
    public ResponseEntity<WebLoginResponse> appleLogin(
            @RequestBody @Valid WebAuthCodeRequest webAuthCodeRequest,
            @RequestHeader(value = ORIGIN, required = false) String origin,
            @RequestParam(required = false) String dest
    ) {
        AppleLoginDto appleLoginDto = appleOAuthService.getUserInfo(WebLoginDto.of(webAuthCodeRequest, origin, dest));

        LoginResponse loginResponse = oAuthLoginProcessor.processApple(appleLoginDto);

        return webLoginResponse(loginResponse);
    }
}
