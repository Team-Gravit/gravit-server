package gravit.code.user.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "User Deletion API", description = "계정 삭제(요청/확정) API")
public interface UserDeletionControllerDocs {

    @Operation(
            summary = "계정 삭제 요청(인증 메일 발송)",
            description = """
                    로그인한 사용자에게 **계정 삭제 확인 메일**을 발송합니다.<br>
                    메일 내 확인 버튼(또는 링크)을 통해 최종 확정 단계로 이동합니다.<br>
                    🔐 <strong>Jwt 필요</strong><br>
                    ✅ 응답은 <code>202 Accepted</code>로, 요청이 접수되었음을 의미합니다.
                    """
    )
    @ApiResponses({
            @ApiResponse(responseCode = "202", description = "✅ 삭제 요청 접수(메일 발송 시도)"),
            @ApiResponse(responseCode = "404", description = "🚨 유저 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "유저 조회 실패",
                                    value = "{\"error\":\"USER_4041\",\"message\":\"존재하지 않는 유저입니다.\"}"
                            ),
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "400", description = "🚨 메일 발송 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "메일 발송 실패",
                                    value = "{\"error\":\"MAIL_4002\",\"message\":\"메일 전송에 실패하였습니다.\"}"
                            ),
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\":\"GLOBAL_5001\",\"message\":\"예기치 못한 예외 발생\"}"
                            ),
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/request")
    ResponseEntity<Void> request(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "삭제 확인 링크가 향할 프론트엔드 환경(local, dev, prod)", example = "prod")
            @RequestParam String dest
    );

    @Operation(
            summary = "계정 삭제 확정(메일 인증 코드 확인)",
            description = """
                    메일로 발급된 **삭제 인증 코드**를 확인하고 계정 삭제를 확정합니다.<br>
                    코드가 유효하면 즉시 삭제가 진행됩니다.<br>
                    🔐 <strong>Jwt 불필요</strong> (메일 링크 진입 가정)<br>
                    """
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 계정 삭제 확정 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 인증 코드가 유효하지 않거나 만료됨",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "인증 코드 무효/만료",
                                    value = "{\"error\":\"MAIL_4001\",\"message\":\"메일 인증 코드가 유효하지 않습니다.\"}"
                            ),
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 유저 조회 실패(코드에 해당하는 유저가 존재하지 않는 경우)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "유저 조회 실패",
                                    value = "{\"error\":\"USER_4041\",\"message\":\"존재하지 않는 유저입니다.\"}"
                            ),
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\":\"GLOBAL_5001\",\"message\":\"예기치 못한 예외 발생\"}"
                            ),
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/confirm")
    ResponseEntity<Void> confirm(
            @Parameter(description = "메일로 발급된 계정 삭제 인증 코드")
            @RequestParam String mailAuthCode
    );
}
