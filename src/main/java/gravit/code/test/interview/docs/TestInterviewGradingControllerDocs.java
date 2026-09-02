package gravit.code.test.interview.docs;

import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.test.interview.dto.request.TestInterviewGradingRequest;
import gravit.code.test.interview.dto.response.TestInterviewGradingResponse;
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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Test Interview Grading API", description = "[QA 전용] 면접 답변을 LLM으로 채점 판정하는 테스트 API")
public interface TestInterviewGradingControllerDocs {

    @Operation(
            summary = "[테스트] 면접 답변 채점 판정",
            description = "질문, 핵심 개념 목록, 답변을 보내면 LLM이 개념별 전달/누락, 잘못 말한 구간, 구조성과 명료성을 판정해 돌려줍니다.<br>"
                    + "점수 계산과 결과 저장은 하지 않습니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 판정 성공"),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 판정 실패 또는 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "판정 실패",
                                            value = "{\"error\": \"INTERVIEW_5001\", \"message\": \"면접 답변 채점 판정 요청이 실패했습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "서버 오류",
                                            value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            )
    })
    @PostMapping("/interview/grading")
    ResponseEntity<TestInterviewGradingResponse> gradeAnswer(@Valid @RequestBody TestInterviewGradingRequest request);
}
