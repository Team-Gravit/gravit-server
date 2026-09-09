package gravit.code.interview.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.interview.dto.request.InterviewAudioUploadRequest;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interview.dto.request.InterviewSubmitRequest;
import gravit.code.interview.dto.response.InterviewAudioUploadResponse;
import gravit.code.interview.dto.response.InterviewSessionCreateResponse;
import gravit.code.interview.dto.response.InterviewSessionQuestionsResponse;
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

@Tag(name = "Interview Session API", description = "AI 면접 세션 생성, 문제 조회, 음성 업로드 URL 발급, 답안 제출, 상태 조회, 중단 API")
public interface InterviewSessionControllerDocs {

    @Operation(
            summary = "면접 세션 생성",
            description = """
                    선택한 모드와 난이도로 세션을 만들고 5문항을 확정합니다.<br>
                    공통 CS(COMMON_CS) 모드는 topics에 중복 없는 CS 주제 1~5개를 담고 stack은 비웁니다.<br>
                    직군(JOB_SPECIFIC) 모드는 stack 하나를 담고 topics는 비웁니다.<br>
                    확정된 문제는 문제 목록 조회 API로 받습니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "201",
                    description = "✅ 세션 생성 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewSessionCreateResponse.class),
                            examples = @ExampleObject(
                                    name = "세션 생성 성공 예시",
                                    value = """
                                            {
                                              "sessionId": 12
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
                                            name = "직군 모드에 스택 없음",
                                            value = "{\"error\": \"INTERVIEW_4007\", \"message\": \"직군 면접은 스택을 선택해야 합니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "공통 CS 모드에 스택 지정",
                                            value = "{\"error\": \"INTERVIEW_4008\", \"message\": \"공통 CS 면접은 스택을 선택할 수 없습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "공통 CS 모드에 주제 없음",
                                            value = "{\"error\": \"INTERVIEW_4016\", \"message\": \"공통 CS 면접은 주제를 1개 이상 선택해야 합니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "직군 모드에 주제 지정",
                                            value = "{\"error\": \"INTERVIEW_4017\", \"message\": \"직군 면접은 주제를 선택할 수 없습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "주제 목록 오류",
                                            value = "{\"error\": \"INTERVIEW_4018\", \"message\": \"면접 주제는 중복 없는 CS 주제 1~5개여야 합니다.\"}"
                                    )
                            }
                    )
            ),
            @ApiResponse(
                    responseCode = "409",
                    description = "🚨 출제할 문제가 부족함",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "문제 풀 부족",
                                    value = "{\"error\": \"INTERVIEW_4009\", \"message\": \"면접 질문 풀이 부족하여 세션을 생성할 수 없습니다.\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 서버 내부 오류",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"서버 내부 오류가 발생했습니다.\"}"
                            )
                    )
            )
    })
    ResponseEntity<InterviewSessionCreateResponse> create(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody InterviewSessionCreateRequest request
    );

    @Operation(
            summary = "면접 세션 문제 목록 조회",
            description = """
                    세션에 확정된 5문항을 문항 번호 오름차순으로 반환합니다.<br>
                    진행 중, 채점 중, 완료, 채점 실패, 취소 어느 상태에서도 조회할 수 있습니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 문제 목록 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewSessionQuestionsResponse.class),
                            examples = @ExampleObject(
                                    name = "문제 목록 예시",
                                    value = """
                                            {
                                              "sessionId": 12,
                                              "questions": [
                                                { "displayOrder": 1, "content": "퀵 정렬의 동작 방식과 평균 시간복잡도를 설명해 주세요." },
                                                { "displayOrder": 2, "content": "해시 충돌이 발생하는 이유와 해결 방법을 설명해 주세요." },
                                                { "displayOrder": 3, "content": "트랜잭션의 격리 수준을 설명해 주세요." },
                                                { "displayOrder": 4, "content": "프로세스와 스레드의 차이를 설명해 주세요." },
                                                { "displayOrder": 5, "content": "TCP와 UDP의 차이를 설명해 주세요." }
                                              ]
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
                                    name = "접근 거부",
                                    value = "{\"error\": \"INTERVIEW_4004\", \"message\": \"본인의 면접 세션만 접근할 수 있습니다.\"}"
                            )
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
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 서버 내부 오류",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"서버 내부 오류가 발생했습니다.\"}"
                            )
                    )
            )
    })
    ResponseEntity<InterviewSessionQuestionsResponse> getQuestions(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "면접 세션 아이디", example = "12") @PathVariable long sessionId
    );

    @Operation(
            summary = "면접 음성 업로드 URL 발급",
            description = """
                    진행 중(IN_PROGRESS)인 음성(VOICE) 세션의 문항 하나에 대해 업로드용 presigned URL을 발급합니다.<br>
                    응답의 uploadUrl로 PUT 요청을 보내 음성 원본을 올리고, 함께 받은 audioKey를 답안 제출 본문에 담습니다.<br>
                    PUT 요청의 Content-Type은 발급 시 보낸 contentType과 같아야 합니다.<br>
                    URL은 10분 뒤 만료되며, 문항마다 필요한 시점에 각각 발급받습니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 업로드 URL 발급 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewAudioUploadResponse.class),
                            examples = @ExampleObject(
                                    name = "업로드 URL 발급 예시",
                                    value = """
                                            {
                                              "audioKey": "interview/12/1.m4a",
                                              "uploadUrl": "https://gravit-interview-audio.s3.ap-northeast-2.amazonaws.com/interview/12/1.m4a?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Expires=600&X-Amz-Signature=...",
                                              "expiresAt": "2026-09-08T14:30:00"
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
                                            name = "텍스트 세션에 발급 요청",
                                            value = "{\"error\": \"INTERVIEW_4006\", \"message\": \"면접 세션의 답변 입력 방식과 일치하지 않습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "지원하지 않는 음성 포맷",
                                            value = "{\"error\": \"INTERVIEW_4019\", \"message\": \"지원하지 않는 음성 포맷입니다.\"}"
                                    )
                            }
                    )
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "🚨 본인의 세션이 아님",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "접근 거부",
                                    value = "{\"error\": \"INTERVIEW_4004\", \"message\": \"본인의 면접 세션만 접근할 수 있습니다.\"}"
                            )
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
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "409",
                    description = "🚨 진행 중인 세션이 아님",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "진행 중 아님",
                                    value = "{\"error\": \"INTERVIEW_4005\", \"message\": \"진행 중인 면접 세션이 아닙니다.\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 서버 내부 오류",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"서버 내부 오류가 발생했습니다.\"}"
                            )
                    )
            )
    })
    ResponseEntity<InterviewAudioUploadResponse> issueUploadUrl(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "면접 세션 아이디", example = "12") @PathVariable long sessionId,
            @Valid @RequestBody InterviewAudioUploadRequest request
    );

    @Operation(
            summary = "면접 세션 중단",
            description = """
                    진행 중(IN_PROGRESS)인 세션을 취소(ABANDONED)합니다.<br>
                    제출 이후에는 취소할 수 없으며, 취소된 세션은 채점하지 않고 결과와 통계에도 포함하지 않습니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 세션 중단 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewSessionStatusResponse.class),
                            examples = @ExampleObject(
                                    name = "세션 중단 성공 예시",
                                    value = """
                                            {
                                              "sessionId": 12,
                                              "status": "ABANDONED"
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
                                    name = "접근 거부",
                                    value = "{\"error\": \"INTERVIEW_4004\", \"message\": \"본인의 면접 세션만 접근할 수 있습니다.\"}"
                            )
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
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "409",
                    description = "🚨 진행 중인 세션이 아님",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "진행 중 아님",
                                    value = "{\"error\": \"INTERVIEW_4005\", \"message\": \"진행 중인 면접 세션이 아닙니다.\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 서버 내부 오류",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"서버 내부 오류가 발생했습니다.\"}"
                            )
                    )
            )
    })
    ResponseEntity<InterviewSessionStatusResponse> abandon(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "면접 세션 아이디", example = "12") @PathVariable long sessionId
    );

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
                                    ),
                                    @ExampleObject(
                                            name = "음성 키 오류",
                                            value = "{\"error\": \"INTERVIEW_4020\", \"message\": \"서버가 발급한 음성 키가 아닙니다.\"}"
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
