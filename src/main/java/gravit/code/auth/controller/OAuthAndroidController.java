package gravit.code.auth.controller;

import gravit.code.auth.controller.docs.OAuthAndroidControllerDocs;
import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.dto.oauth.android.IdTokenRequest;
import gravit.code.auth.dto.response.LoginResponse;
import gravit.code.auth.service.oauth.OAuthLoginProcessor;
import gravit.code.auth.service.oauth.android.OAuthAndroidUserInfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/oauth/android")
public class OAuthAndroidController implements OAuthAndroidControllerDocs {

    private final OAuthAndroidUserInfoService oAuthAndroidClientService;
    private final OAuthLoginProcessor oAuthLoginProcessor;

    @PostMapping
    public ResponseEntity<LoginResponse> oauthLogin(@RequestBody IdTokenRequest request){
        String idToken = request.idToken();

        if(idToken == null){
            return  ResponseEntity.badRequest().build();
        }

        OAuthUserInfo userInfo = oAuthAndroidClientService.parseIdToken(idToken);

        LoginResponse loginResponse = oAuthLoginProcessor.process(userInfo);

        return ResponseEntity.status(HttpStatus.OK).body(loginResponse);
    }
}
