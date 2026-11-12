package gravit.code.auth.controller;

import gravit.code.auth.controller.docs.OAuthIosControllerDocs;
import gravit.code.auth.domain.LoginClient;
import gravit.code.auth.dto.internal.AppleLoginDto;
import gravit.code.auth.dto.oauth.AuthCodeRequest;
import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.dto.oauth.app.AccessTokenRequest;
import gravit.code.auth.dto.oauth.app.IdTokenRequest;
import gravit.code.auth.dto.response.LoginResponse;
import gravit.code.auth.service.oauth.OAuthLoginProcessor;
import gravit.code.auth.service.oauth.app.NaverAppUserInfoService;
import gravit.code.auth.service.oauth.app.OAuthAppUserInfoService;
import gravit.code.auth.service.oauth.apple.AppleOAuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/oauth/ios")
public class OAuthIosController implements OAuthIosControllerDocs {

    private final AppleOAuthService appleOAuthService;
    private final OAuthAppUserInfoService oAuthAppUserInfoService;
    private final NaverAppUserInfoService naverAppUserInfoService;
    private final OAuthLoginProcessor oAuthLoginProcessor;

    @PostMapping("/apple")
    public ResponseEntity<LoginResponse> appleLogin(
            @RequestBody @Valid AuthCodeRequest authCodeRequest
    ) {
        AppleLoginDto appleLoginDto = appleOAuthService.getIosUserInfo(authCodeRequest.code());

        LoginResponse loginResponse = oAuthLoginProcessor.processApple(appleLoginDto);

        return ResponseEntity.status(OK).body(loginResponse);
    }

    @PostMapping
    public ResponseEntity<LoginResponse> oauthLogin(
            @RequestParam("provider") String provider,
            @RequestBody IdTokenRequest request
    ) {
        OAuthUserInfo userInfo = oAuthAppUserInfoService.parseIosIdToken(provider, request.idToken());

        LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo, LoginClient.IOS);

        return ResponseEntity.status(OK).body(loginResponse);
    }

    @PostMapping("/naver")
    public ResponseEntity<LoginResponse> oauthNaverLogin(
            @RequestBody @Valid AccessTokenRequest request
    ) {
        OAuthUserInfo userInfo = naverAppUserInfoService.getUserInfo(request.accessToken());

        LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo, LoginClient.IOS);

        return ResponseEntity.status(OK).body(loginResponse);
    }
}
