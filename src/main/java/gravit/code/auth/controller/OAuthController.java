package gravit.code.auth.controller;

import gravit.code.auth.controller.docs.OAuthControllerDocs;
import gravit.code.auth.dto.oauth.AuthCodeRequest;
import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.dto.response.LoginResponse;
import gravit.code.auth.service.oauth.OAuthLoginProcessor;
import gravit.code.auth.service.oauth.OAuthLoginUrlService;
import gravit.code.auth.service.oauth.OAuthUserInfoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/oauth")
@Slf4j
public class OAuthController implements OAuthControllerDocs {

    private final OAuthUserInfoService oAuthClientService;
    private final OAuthLoginUrlService oAuthLoginUrlService;

    private final OAuthLoginProcessor oAuthLoginProcessor;

    @GetMapping("/login-url/{provider}")
    public ResponseEntity<Map<String, String>> authorizeUrl(
            @PathVariable("provider") String provider,
            @RequestParam String dest
    ) {
        String loginUrl = oAuthLoginUrlService.generateLoginUrl(provider, dest);
        return ResponseEntity.status(OK).body(Map.of("loginUrl", loginUrl));
    }

    @PostMapping("/{provider}")
    public ResponseEntity<LoginResponse> oauthLogin(
            @PathVariable("provider") String provider,
            @RequestBody AuthCodeRequest authCodeRequest,
            @RequestParam String dest
    ){
        String code = authCodeRequest.code();

        if(code == null){
            return  ResponseEntity.status(BAD_REQUEST).build();
        }

        OAuthUserInfo userInfo = oAuthClientService.getUserInfo(code, provider, dest);

        LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo);

        return ResponseEntity.status(OK).body(loginResponse);
    }
}
