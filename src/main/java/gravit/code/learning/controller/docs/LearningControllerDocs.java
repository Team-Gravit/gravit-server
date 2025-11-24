package gravit.code.learning.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.learning.dto.response.LearningSubmissionSaveResponse;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.unit.dto.response.UnitDetailResponse;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
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

import java.util.List;

@Tag(name = "Learning API", description = "학습 관련 API")
public interface LearningControllerDocs {

    @Operation(summary = "챕터 조회", description = "유저의 챕터 진행도를 포함한 챕터 목록을 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 챕터 목록 조회 성공"),
            @ApiResponse(responseCode = "USER_4041", description = "🚨 유저 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유저 조회 실패",
                                            value = "{\"error\" : \"USER_4041\", \"message\" : \"존재하지 않는 유저입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @GetMapping("/chapters")
    ResponseEntity<List<ChapterDetailResponse>> getAllChapters(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "유닛 조회", description = "유저의 유닛 진행도를 포함한 유닛 목록을 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 유닛 목록 조회 성공"),
            @ApiResponse(responseCode = "CHAPTER_4041", description = "🚨 챕터 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "챕터 조회 실패",
                                            value = "{\"error\" : \"CHAPTER_4041\", \"message\" : \"챕터 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "USER_4041", description = "🚨 유저 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유저 조회 실패",
                                            value = "{\"error\" : \"USER_4041\", \"message\" : \"존재하지 않는 유저입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @GetMapping("/{chapterId}/units")
    ResponseEntity<UnitDetailResponse> getAllUnitsInChapter(@AuthenticationPrincipal LoginUser loginUser,
                                                            @PathVariable("chapterId") Long chapterId);

    @Operation(summary = "레슨 문제 조회", description = "특정 레슨을 구성하는 문제 목록을 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 레슨 문제 목록 조회 성공"),
            @ApiResponse(responseCode = "CHAPTER_4041", description = "🚨 챕터 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "챕터 조회 실패",
                                            value = "{\"error\" : \"CHAPTER_4041\", \"message\" : \"챕터 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "LESSON_4041", description = "🚨 레슨 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "레슨 조회 실패",
                                            value = "{\"error\" : \"LESSON_4041\", \"message\" : \"레슨 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "PROBLEM_4041", description = "🚨 문제 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "문제 조회 실패",
                                            value = "{\"error\" : \"PROBLEM_4041\", \"message\" : \"문제 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "OPTION_4041", description = "🚨 옵션 조회 실패",
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
    ResponseEntity<LessonResponse> getAllProblemsInLesson(@PathVariable("lessonId") Long lessonsId);

    @Operation(summary = "학습 결과 저장", description = "레슨 완료 후 문제 풀이 결과를 저장하고 사용자 레벨을 업데이트합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 학습 결과 저장 성공"),
            @ApiResponse(responseCode = "USER_4041", description = "🚨 유저 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유저 조회 실패",
                                            value = "{\"error\" : \"USER_4041\", \"message\" : \"존재하지 않는 유저입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "UNIT_4041", description = "🚨 유닛 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유닛 조회 실패",
                                            value = "{\"error\" : \"UNIT_4041\", \"message\" : \"유닛 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "LESSON_4041", description = "🚨 레슨 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "레슨 조회 실패",
                                            value = "{\"error\" : \"LESSON_4041\", \"message\" : \"레슨 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/results")
    ResponseEntity<LearningSubmissionSaveResponse> saveLearningSubmission(@AuthenticationPrincipal LoginUser loginUser,
                                                                      @Valid @RequestBody LearningSubmissionSaveRequest request);

    @Operation(summary = "문제 신고 제출", description = "특정 문제에 대한 오류를 신고합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 문제 신고 제출 성공"),
            @ApiResponse(responseCode = "PROBLEM_4041", description = "🚨 문제 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "문제 조회 실패",
                                            value = "{\"error\" : \"PROBLEM_4041\", \"message\" : \"문제 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/reports")
    ResponseEntity<Void> submitProblemReport(@AuthenticationPrincipal LoginUser loginUser,
                                             @Valid @RequestBody ProblemReportSubmitRequest request);
}