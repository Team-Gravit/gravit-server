package gravit.code.auth.controller;

import gravit.code.auth.controller.docs.AuthTokenControllerDocs;
import gravit.code.auth.dto.request.RefreshTokenRequest;
import gravit.code.auth.dto.response.ReissueResponse;
import gravit.code.auth.service.AuthTokenService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/auth")
public class AuthTokenController implements AuthTokenControllerDocs {

    private final AuthTokenService authTokenService;

    @PostMapping("/refresh")
    public ResponseEntity<ReissueResponse> refreshToken(@RequestBody RefreshTokenRequest request) {
        String refreshToken = request.refreshToken();
        ReissueResponse response = authTokenService.reissue(refreshToken);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).body(response);
    }
}
