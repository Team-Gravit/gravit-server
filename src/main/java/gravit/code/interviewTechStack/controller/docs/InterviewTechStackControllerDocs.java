package gravit.code.interviewTechStack.controller.docs;

import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.interviewTechStack.domain.InterviewJobRole;
import gravit.code.interviewTechStack.dto.response.InterviewTechStackResponse;
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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Tag(name = "Interview Tech Stack API", description = "면접 기술 스택 관련 API")
public interface InterviewTechStackControllerDocs {

    @Operation(summary = "면접 기술 스택 목록 조회", description = "직무별 면접에서 고를 수 있는 기술 스택 목록을 노출 순서대로 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 면접 기술 스택 목록 조회 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 유효성 검사 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효성 검사 실패",
                                            value = "{\"error\" : \"GLOBAL_4001\", \"message\" : \"유효성 검사 실패\"}"
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
    @GetMapping
    ResponseEntity<List<InterviewTechStackResponse>> getTechStacks(
            @Parameter(description = "직무", example = "BACKEND") @RequestParam("jobRole") InterviewJobRole jobRole
    );
}
