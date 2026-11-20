package gravit.code.report.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import gravit.code.report.dto.request.UserReportSubmitRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Report API", description = "신고 관련 API")
public interface ReportControllerDocs {

    @Operation(summary = "문제 신고 제출", description = "특정 문제에 대한 오류를 신고합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 문제 신고 제출 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 문제 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "문제 조회 실패",
                                            value = "{\"error\" : \"PROBLEM_4041\", \"message\" : \"문제 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping
    ResponseEntity<Void> submitProblemReport(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody ProblemReportSubmitRequest request
    );

    @Operation(summary = "사용자 신고 제출", description = "다른 사용자의 부적절한 닉네임 등을 신고합니다. 신고 시점의 닉네임이 함께 저장됩니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 사용자 신고 제출 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 자기 자신 신고",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "자기 자신 신고",
                                            value = "{\"error\" : \"REPORT_4002\", \"message\" : \"자기 자신은 신고할 수 없습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 신고 대상 사용자 조회 실패(없거나 탈퇴)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유저 조회 실패",
                                            value = "{\"error\" : \"USER_4041\", \"message\" : \"존재하지 않는 유저입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "409", description = "🚨 같은 대상에 처리를 기다리는 내 신고가 있음",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "중복 신고",
                                            value = "{\"error\" : \"REPORT_4091\", \"message\" : \"이미 처리를 기다리는 신고가 있습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/users")
    ResponseEntity<Void> submitUserReport(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody UserReportSubmitRequest request
    );
}
