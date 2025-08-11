package gravit.code.auth.oauth.controller;

import gravit.code.auth.oauth.controller.docs.OAuthAndroidControllerDocs;
import gravit.code.auth.oauth.dto.LoginResponse;
import gravit.code.auth.oauth.dto.OAuthAccessToken;
import gravit.code.auth.oauth.dto.OAuthUserInfo;
import gravit.code.auth.oauth.processor.OAuthLoginProcessor;
import gravit.code.auth.oauth.service.OAuthAndroidClientService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/oauth/android")
public class OAuthAndroidController implements OAuthAndroidControllerDocs {

    private final OAuthAndroidClientService oAuthAndroidClientService;
    private final OAuthLoginProcessor oAuthLoginProcessor;

    @PostMapping("/{provider}")
    public ResponseEntity<LoginResponse> oauthLogin(@PathVariable("provider") String provider,
                                                    @RequestBody OAuthAccessToken request){
        String oauthAccessToken = request.accessToken();

        if(oauthAccessToken == null){
            return  ResponseEntity.badRequest().build();
        }

        OAuthUserInfo userInfo = oAuthAndroidClientService.getUserInfo(oauthAccessToken, provider);

        LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo);

        return ResponseEntity.status(HttpStatus.OK).body(loginResponse);
    }
}
