package gravit.code.auth.oauth.controller;

import gravit.code.auth.oauth.dto.LoginResponse;
import gravit.code.auth.oauth.dto.OAuthUserInfo;
import gravit.code.auth.oauth.processor.OAuthLoginProcessor;
import gravit.code.auth.oauth.service.OAuthLoginService;
import gravit.code.auth.oauth.service.OAuthLoginUrlService;
import gravit.code.auth.oauth.service.OAuthServiceFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/oauth")
public class OAuthController {
    private final OAuthServiceFactory oAuthServiceFactory;
    private final OAuthLoginProcessor oAuthLoginProcessor;
    private final OAuthLoginUrlService oAuthLoginUrlService;

    @GetMapping("/login-url/{provider}")
    public ResponseEntity<Map<String, String>> authorizeUrl(@PathVariable("provider") String provider) {
        String loginUrl = oAuthLoginUrlService.generateLoginUrl(provider);
        return  ResponseEntity.ok(Map.of("loginUrl", loginUrl));
    }

    @PostMapping("/{provider}")
    public ResponseEntity<LoginResponse> oauthLogin(@PathVariable("provider") String provider,
                                                    @RequestBody Map<String, String> authCode){
        String code = authCode.get("code");
        if(code == null){
            return  ResponseEntity.badRequest().build();
        }

        OAuthLoginService loginService = oAuthServiceFactory.getService(provider);
        OAuthUserInfo userInfo = loginService.getUserInfo(code);

        LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo);

        return ResponseEntity.status(HttpStatus.OK).body(loginResponse);
    }
}
