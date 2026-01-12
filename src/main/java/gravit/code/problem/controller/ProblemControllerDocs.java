package gravit.code.problem.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Problem API", description = "문제 관련 API")
public interface ProblemControllerDocs {

    @Operation(summary = "레슨 문제 조회", description = "특정 레슨을 구성하는 문제 목록을 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 레슨 문제 목록 조회 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 유닛 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유닛 조회 실패",
                                            value = "{\"error\" : \"UNIT_4041\", \"message\" : \"유닛 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 정답 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "정답 조회 실패",
                                            value = "{\"error\" : \"ANSWER_4041\", \"message\" : \"정답 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 옵션 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "옵션 조회 실패",
                                            value = "{\"error\" : \"OPTION_4041\", \"message\" : \"옵션 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @GetMapping("/{lessonId}")
    ResponseEntity<LessonResponse> getAllProblemInLesson(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("lessonId") Long lessonsId
    );

    @Operation(summary = "문제 결과 저장", description = "문제 풀이 결과를 저장합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 문제 결과 저장 성공")
    })
    @PostMapping("/results")
    ResponseEntity<Void> saveProblemSubmission(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody ProblemSubmissionRequest request
    );
}
