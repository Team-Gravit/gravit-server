package gravit.code.auth.oauth.controller.docs;

import gravit.code.auth.oauth.dto.AuthCodeRequest;
import gravit.code.auth.oauth.dto.LoginResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.Map;

@Tag(name = "OAuth API", description = "OAuth 관련 API 명세")
public interface OAuthControllerDocs {

    // OAuth 로그인 URL 생성
    @Operation(summary = "로그인 URL 생성", description = "OAuth 정보를 바탕으로 로그인 URL을 생성합니다.")
    @ApiResponses(
            @ApiResponse(responseCode = "201", description = "로그인 URL 생성 성공")
    )
    @GetMapping("/login-url/{provider}")
    ResponseEntity<Map<String, String>> authorizeUrl(@Parameter(description = "제공자(kakao, naver, google) 이름") @PathVariable("provider") String provider);

    // OAuth 회원가입/로그인 처리
    @Operation(summary = "OAuth 회원가입/로그인 처리", description = "AuthCode 를 기반으로 사용자 정보를 조회하고 회원가입 및 로그인 처리를 합니다.")
    @ApiResponses(
            @ApiResponse(responseCode = "201", description = "OAuth 회원가입/로그인 성공")
    )
    @PostMapping("/{provider}")
    ResponseEntity<LoginResponse> oauthLogin(@Parameter(description = "제공자(kakao, naver, google) 이름") @PathVariable("provider") String provider,
                                             @RequestBody AuthCodeRequest request);


}
