package gravit.code.interview.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.interview.dto.request.InterviewSubmitRequest;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Interview Session API", description = "AI 면접 세션 답안 제출과 상태 조회 API")
public interface InterviewSessionControllerDocs {

    @Operation(
            summary = "면접 답안 일괄 제출",
            description = """
                    진행 중(IN_PROGRESS)인 세션의 답안 5건을 한 번에 제출합니다.<br>
                    문항 번호(displayOrder) 1~5를 각각 정확히 한 번씩 담아야 하며, 재제출은 불가능합니다.<br>
                    content가 null이거나 공백이면 무응답으로 저장됩니다.<br>
                    audioKey는 VOICE 세션에서만 담고, TEXT 세션은 null이어야 합니다.<br>
                    제출이 받아들여지면 세션이 채점 중(GRADING)이 되고 채점은 백그라운드에서 진행됩니다.
                    채점 완료 여부는 세션 상태 조회 API로 확인하세요.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "202",
                    description = "✅ 답안 제출 성공, 채점 시작",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewSessionStatusResponse.class),
                            examples = @ExampleObject(
                                    name = "답안 제출 성공 예시",
                                    value = """
                                            {
                                              "sessionId": 12,
                                              "status": "GRADING"
                                            }
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "🚨 요청 값이 유효하지 않음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효성 검사 실패",
                                            value = "{\"error\": \"GLOBAL_4001\", \"message\": \"유효성 검사 실패\"}"
                                    ),
                                    @ExampleObject(
                                            name = "문항 번호 오류",
                                            value = "{\"error\": \"INTERVIEW_4014\", \"message\": \"면접 답안은 문항 번호 1~5를 각각 한 번씩 포함해야 합니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "입력 방식 불일치",
                                            value = "{\"error\": \"INTERVIEW_4006\", \"message\": \"면접 세션의 답변 입력 방식과 일치하지 않습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "🚨 본인의 세션이 아님",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "세션 접근 거부",
                                    value = "{\"error\": \"INTERVIEW_4004\", \"message\": \"본인의 면접 세션만 접근할 수 있습니다.\"}"
                            ),
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 세션 또는 답안을 찾을 수 없음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "세션 없음",
                                            value = "{\"error\": \"INTERVIEW_4003\", \"message\": \"존재하지 않는 면접 세션입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "답안 없음",
                                            value = "{\"error\": \"INTERVIEW_4010\", \"message\": \"존재하지 않는 면접 답변입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "409",
                    description = "🚨 제출할 수 없는 상태",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "진행 중 세션 아님",
                                            value = "{\"error\": \"INTERVIEW_4005\", \"message\": \"진행 중인 면접 세션이 아닙니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "이미 제출된 답안",
                                            value = "{\"error\": \"INTERVIEW_4013\", \"message\": \"이미 제출된 면접 답안입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            )
    })
    @PatchMapping("/{sessionId}/submit")
    ResponseEntity<InterviewSessionStatusResponse> submit(
            @Parameter(hidden = true) @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "면접 세션 ID", example = "12") @PathVariable long sessionId,
            @Valid @RequestBody InterviewSubmitRequest request
    );

    @Operation(
            summary = "면접 세션 상태 조회",
            description = """
                    면접 세션의 현재 상태를 조회합니다. 답안 제출 후 채점 완료 여부를 확인할 때 사용합니다.<br>
                    IN_PROGRESS(진행 중), GRADING(채점 중), GRADING_FAILED(채점 실패), COMPLETED(완료), ABANDONED(취소) 다섯 가지입니다.<br>
                    COMPLETED가 되면 결과 조회 API를 호출할 수 있습니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 세션 상태 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewSessionStatusResponse.class),
                            examples = @ExampleObject(
                                    name = "세션 상태 조회 성공 예시",
                                    value = """
                                            {
                                              "sessionId": 12,
                                              "status": "COMPLETED"
                                            }
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "🚨 본인의 세션이 아님",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "세션 접근 거부",
                                    value = "{\"error\": \"INTERVIEW_4004\", \"message\": \"본인의 면접 세션만 접근할 수 있습니다.\"}"
                            ),
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 존재하지 않는 세션",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "세션 없음",
                                    value = "{\"error\": \"INTERVIEW_4003\", \"message\": \"존재하지 않는 면접 세션입니다.\"}"
                            ),
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            )
    })
    @GetMapping("/{sessionId}/status")
    ResponseEntity<InterviewSessionStatusResponse> getStatus(
            @Parameter(hidden = true) @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "면접 세션 ID", example = "12") @PathVariable long sessionId
    );
}
