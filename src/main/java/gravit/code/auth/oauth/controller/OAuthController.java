package gravit.code.auth.oauth.controller;

import gravit.code.auth.oauth.controller.docs.OAuthControllerDocs;
import gravit.code.auth.oauth.dto.AuthCodeRequest;
import gravit.code.auth.oauth.dto.LoginResponse;
import gravit.code.auth.oauth.dto.OAuthUserInfo;
import gravit.code.auth.oauth.processor.OAuthLoginProcessor;
import gravit.code.auth.oauth.service.OAuthClientService;
import gravit.code.auth.oauth.service.OAuthLoginUrlService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/oauth")
@Slf4j
public class OAuthController implements OAuthControllerDocs {
    private final OAuthClientService oAuthClientService;
    private final OAuthLoginProcessor oAuthLoginProcessor;
    private final OAuthLoginUrlService oAuthLoginUrlService;

    /**
     * login url 를 프론트에 응답합니다.
     */
    @GetMapping("/login-url/{provider}")
    public ResponseEntity<Map<String, String>> authorizeUrl(@PathVariable("provider") String provider,
                                                            @RequestParam String dest) {
        String loginUrl = oAuthLoginUrlService.generateLoginUrl(provider, dest);
        return ResponseEntity.ok(Map.of("loginUrl", loginUrl));
    }

    /**
     * auth code 를 기반으로 소셜 로그인 시도 한 유져의 정보를 가져와 회원가입 및 로그인을 처리합니다.
     */

    @PostMapping("/{provider}")
    public ResponseEntity<LoginResponse> oauthLogin(@PathVariable("provider") String provider,
                                                    @RequestBody AuthCodeRequest authCodeRequest,
                                                    @RequestParam String dest){
        String code = authCodeRequest.code();

        if(code == null){
            return  ResponseEntity.badRequest().build();
        }

        OAuthUserInfo userInfo = oAuthClientService.getUserInfo(code, provider, dest);

        LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo);

        return ResponseEntity.status(HttpStatus.OK).body(loginResponse);
    }
}
