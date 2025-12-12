package gravit.code.auth.controller;

import gravit.code.auth.controller.docs.OAuthAndroidControllerDocs;
import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.dto.oauth.android.IdTokenRequest;
import gravit.code.auth.dto.oauth.android.NaverAndroidUserInfo;
import gravit.code.auth.dto.oauth.android.NaverAndroidUserInfoRequest;
import gravit.code.auth.dto.response.LoginResponse;
import gravit.code.auth.service.oauth.OAuthLoginProcessor;
import gravit.code.auth.service.oauth.android.OAuthAndroidUserInfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/oauth/android")
public class OAuthAndroidController implements OAuthAndroidControllerDocs {

    private final OAuthAndroidUserInfoService oAuthAndroidClientService;
    private final OAuthLoginProcessor oAuthLoginProcessor;

    @PostMapping
    public ResponseEntity<LoginResponse> oauthLogin(
            @RequestParam("provider") String provider,
            @RequestBody IdTokenRequest request
    ){
        String idToken = request.idToken();
        OAuthUserInfo userInfo = oAuthAndroidClientService.parseIdToken(provider, idToken);
        LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo);

        return ResponseEntity.status(HttpStatus.OK).body(loginResponse);
    }

    // naver는 IdToken 방식을 지원하지 않기 때문에 안드로이드에서 유저 정보를 넘기게
    @PostMapping("/naver")
    public ResponseEntity<LoginResponse> oauthNaverLogin(
            @RequestBody NaverAndroidUserInfoRequest request
    ){
        String providerId = request.providerId();
        String email = request.email();
        String nickname = request.nickname();

        OAuthUserInfo userInfo = new NaverAndroidUserInfo(providerId, email, nickname);
        LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo);

        return ResponseEntity.status(HttpStatus.OK).body(loginResponse);
    }
}
