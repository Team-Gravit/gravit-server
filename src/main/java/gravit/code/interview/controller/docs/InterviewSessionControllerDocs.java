package gravit.code.interview.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.interview.dto.request.InterviewAnswerSubmitRequest;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interview.dto.response.InterviewAnswerSubmitResponse;
import gravit.code.interview.dto.response.InterviewSessionCreateResponse;
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
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Interview Session API", description = "면접 세션 관련 API")
public interface InterviewSessionControllerDocs {

    @Operation(summary = "면접 세션 생성", description = "면접 세션을 만들고 질문 5개를 배정합니다.<br>" +
            "직무별 모드는 기술 스택이 필요하고, 공통 CS 모드는 기술 스택을 보내면 안 됩니다.<br>" +
            "답변 입력 방식은 현재 <strong>TEXT만 지원</strong>합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "✅ 면접 세션 생성 성공",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewSessionCreateResponse.class))
            ),
            @ApiResponse(responseCode = "400", description = "🚨 기술 스택 선택 오류",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "직무별 면접에 기술 스택 누락",
                                            value = "{\"error\" : \"INTERVIEW_4007\", \"message\" : \"직무별 면접은 기술 스택 선택이 필요합니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "공통 CS 면접에 기술 스택 지정",
                                            value = "{\"error\" : \"INTERVIEW_4008\", \"message\" : \"공통 CS 면접은 기술 스택을 선택할 수 없습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "지원하지 않는 답변 입력 방식",
                                            value = "{\"error\" : \"INTERVIEW_4013\", \"message\" : \"아직 지원하지 않는 답변 입력 방식입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 기술 스택 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "기술 스택 조회 실패",
                                            value = "{\"error\" : \"INTERVIEW_4014\", \"message\" : \"존재하지 않는 면접 기술 스택입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "409", description = "🚨 세션을 만들 수 없는 상태",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "이미 진행 중인 세션 존재",
                                            value = "{\"error\" : \"INTERVIEW_4011\", \"message\" : \"이미 진행 중인 면접 세션이 있습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "질문 풀 부족",
                                            value = "{\"error\" : \"INTERVIEW_4009\", \"message\" : \"면접 질문 풀이 부족하여 세션을 생성할 수 없습니다.\"}"
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
    ResponseEntity<InterviewSessionCreateResponse> createSession(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody InterviewSessionCreateRequest request
    );

    @Operation(summary = "면접 답변 제출", description = "출제 순서로 지정한 문항에 답변을 제출합니다.<br>" +
            "진행 중인 세션이면 다시 제출해 덮어쓸 수 있고, 본문이 비어 있으면 무응답으로 기록됩니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 면접 답변 제출 성공",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewAnswerSubmitResponse.class))
            ),
            @ApiResponse(responseCode = "400", description = "🚨 답변 입력 방식 불일치",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "답변 입력 방식 불일치",
                                            value = "{\"error\" : \"INTERVIEW_4006\", \"message\" : \"면접 세션의 답변 입력 방식과 일치하지 않습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "403", description = "🚨 본인 세션이 아님",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "본인 세션이 아님",
                                            value = "{\"error\" : \"INTERVIEW_4004\", \"message\" : \"본인의 면접 세션만 접근할 수 있습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 세션 또는 답변 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "세션 조회 실패",
                                            value = "{\"error\" : \"INTERVIEW_4003\", \"message\" : \"존재하지 않는 면접 세션입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "답변 조회 실패",
                                            value = "{\"error\" : \"INTERVIEW_4010\", \"message\" : \"존재하지 않는 면접 답변입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "409", description = "🚨 진행 중인 세션이 아님",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "진행 중인 세션이 아님",
                                            value = "{\"error\" : \"INTERVIEW_4005\", \"message\" : \"진행 중인 면접 세션이 아닙니다.\"}"
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
    @PatchMapping("/{sessionId}/answers/{displayOrder}")
    ResponseEntity<InterviewAnswerSubmitResponse> submitAnswer(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "면접 세션 아이디") @PathVariable("sessionId") Long sessionId,
            @Parameter(description = "출제 순서", example = "1") @PathVariable("displayOrder") Integer displayOrder,
            @Valid @RequestBody InterviewAnswerSubmitRequest request
    );

    @Operation(summary = "면접 세션 종료", description = "면접을 끝내고 채점을 요청합니다. 세션은 채점 중 상태가 되고 점수는 채점이 끝난 뒤에 조회할 수 있습니다.<br>" +
            "답변하지 않은 문항이 남아 있어도 종료할 수 있으며, 무응답은 0점으로 채점됩니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "202", description = "✅ 면접 채점 요청 성공",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewSessionStatusResponse.class))
            ),
            @ApiResponse(responseCode = "403", description = "🚨 본인 세션이 아님",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "본인 세션이 아님",
                                            value = "{\"error\" : \"INTERVIEW_4004\", \"message\" : \"본인의 면접 세션만 접근할 수 있습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 세션 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "세션 조회 실패",
                                            value = "{\"error\" : \"INTERVIEW_4003\", \"message\" : \"존재하지 않는 면접 세션입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "409", description = "🚨 진행 중인 세션이 아님",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "진행 중인 세션이 아님",
                                            value = "{\"error\" : \"INTERVIEW_4005\", \"message\" : \"진행 중인 면접 세션이 아닙니다.\"}"
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
    @PatchMapping("/{sessionId}/complete")
    ResponseEntity<InterviewSessionStatusResponse> completeSession(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "면접 세션 아이디") @PathVariable("sessionId") Long sessionId
    );

    @Operation(summary = "면접 세션 중단", description = "진행 중인 면접을 채점 없이 중단합니다. 중단한 세션은 점수 없이 진행 정보만 남습니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 면접 세션 중단 성공",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewSessionStatusResponse.class))
            ),
            @ApiResponse(responseCode = "403", description = "🚨 본인 세션이 아님",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "본인 세션이 아님",
                                            value = "{\"error\" : \"INTERVIEW_4004\", \"message\" : \"본인의 면접 세션만 접근할 수 있습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 세션 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "세션 조회 실패",
                                            value = "{\"error\" : \"INTERVIEW_4003\", \"message\" : \"존재하지 않는 면접 세션입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "409", description = "🚨 진행 중인 세션이 아님",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "진행 중인 세션이 아님",
                                            value = "{\"error\" : \"INTERVIEW_4005\", \"message\" : \"진행 중인 면접 세션이 아닙니다.\"}"
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
    @PatchMapping("/{sessionId}/abandon")
    ResponseEntity<InterviewSessionStatusResponse> abandonSession(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "면접 세션 아이디") @PathVariable("sessionId") Long sessionId
    );
}
