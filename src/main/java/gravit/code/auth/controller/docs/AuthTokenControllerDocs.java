package gravit.code.auth.controller.docs;

import gravit.code.auth.dto.request.RefreshTokenRequest;
import gravit.code.auth.dto.response.ReissueResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "AuthToken API", description = "인증 토큰 관련 API")
public interface AuthTokenControllerDocs {

    @Operation(summary = "리프레시 토큰으로 엑세스 토큰 재발급", description = "유효한 리프레시 토큰으로 엑세스 토큰을 재발급합니다. <br> 만약 리프레시 토큰이 유효하지 않다면 재 로그인이 필요합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "엑세스 토큰 재발급 성공"),
            @ApiResponse(responseCode = "JWT_4016", description = "만료된 리프레시 토큰입니다.",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효하지 않은 OAuth 제공자",
                                            value = "{\"error\" : \"JWT_4016\", \"message\" : \"만료된 리프레시 토큰입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "USER_4001", description = "존재하지 않는 유저입니다.",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"USER_4001\", \"message\" : \"존재하지 않는 유저입니다\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/reissue")
    ResponseEntity<ReissueResponse> reissueToken(@RequestBody RefreshTokenRequest request);


}
