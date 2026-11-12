package gravit.code.auth.controller;

import gravit.code.auth.controller.docs.AuthTokenControllerDocs;
import gravit.code.auth.dto.request.RefreshTokenRequest;
import gravit.code.auth.dto.response.ReissueResponse;
import gravit.code.auth.service.AuthTokenService;
import gravit.code.auth.support.RefreshTokenCookieFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static gravit.code.auth.support.RefreshTokenCookieFactory.COOKIE_NAME;
import static org.springframework.http.HttpHeaders.SET_COOKIE;
import static org.springframework.http.HttpStatus.NO_CONTENT;
import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/auth")
public class AuthTokenController implements AuthTokenControllerDocs {

    private final AuthTokenService authTokenService;

    private final RefreshTokenCookieFactory refreshTokenCookieFactory;

    @PostMapping("/reissue")
    public ResponseEntity<ReissueResponse> reissueToken(
            @CookieValue(name = COOKIE_NAME, required = false) String cookieRefreshToken,
            @RequestBody(required = false) RefreshTokenRequest request
    ) {
        ReissueResponse response = authTokenService.reissue(selectRefreshToken(cookieRefreshToken, request));
        return ResponseEntity.status(OK).body(response);
    }

    private String selectRefreshToken(
            String cookieRefreshToken,
            RefreshTokenRequest request
    ) {
        if (cookieRefreshToken != null && !cookieRefreshToken.isBlank()) {
            return cookieRefreshToken;
        }

        return request == null ? null : request.refreshToken();
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            @CookieValue(name = COOKIE_NAME, required = false) String cookieRefreshToken,
            @RequestBody(required = false) RefreshTokenRequest request
    ) {
        authTokenService.logout(selectRefreshToken(cookieRefreshToken, request));

        return ResponseEntity.status(NO_CONTENT)
                .header(SET_COOKIE, refreshTokenCookieFactory.expire().toString())
                .build();
    }
}
