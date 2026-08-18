package gravit.code.lesson.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonResultResponse;
import gravit.code.lesson.dto.response.LessonSubmissionSaveResponse;
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

@Tag(name = "Lesson API", description = "레슨 관련 API")
public interface LessonControllerDocs {

    @Operation(summary = "레슨 목록 조회", description = "특정 유닛의 레슨 목록을 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 레슨 목록 조회 성공"),
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
            @ApiResponse(responseCode = "404", description = "🚨 챕터 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "챕터 조회 실패",
                                            value = "{\"error\" : \"CHAPTER_4041\", \"message\" : \"챕터 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @GetMapping("/{unitId}")
    ResponseEntity<LessonDetailResponse> getAllLessonInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    );

    @Operation(summary = "레슨 결과 저장", description = "레슨 완료 후 문제 풀이 결과를 저장하고 사용자 레벨을 업데이트합니다.<br>" +
            "생성된 레슨 제출 아이디만 반환하며, 결과 화면 정보는 <strong>레슨 결과 조회</strong> API로 받습니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "✅ 레슨 결과 저장 성공",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = LessonSubmissionSaveResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 레슨 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "레슨 조회 실패",
                                            value = "{\"error\" : \"LESSON_4041\", \"message\" : \"레슨 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
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
            @ApiResponse(responseCode = "404", description = "🚨 학습 정보 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "학습 정보 조회 실패",
                                            value = "{\"error\" : \"LEARNING_4041\", \"message\" : \"학습 정보 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/results")
    ResponseEntity<LessonSubmissionSaveResponse> saveLessonSubmission(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody LearningSubmissionSaveRequest request
    );

    @Operation(summary = "레슨 결과 조회", description = "레슨 제출 아이디로 결과 화면에 필요한 정보를 조회합니다.<br>" +
            "리그명과 레벨은 이번 제출로 확정된 값이 아니라 <strong>조회 시점의 현재 값</strong>입니다. " +
            "보상 반영이 재시도 큐로 넘어간 경우 아직 반영 전 값이 보일 수 있으며, 재조회하면 수렴합니다.<br>" +
            "본인의 제출만 조회할 수 있습니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 레슨 결과 조회 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 레슨 풀이 제출 이력 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "레슨 풀이 제출 이력 조회 실패",
                                            value = "{\"error\" : \"LESSON_4042\", \"message\" : \"레슨 풀이 제출 이력 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 유저 리그 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유저 리그 조회 실패",
                                            value = "{\"error\" : \"U_L_4041\", \"message\" : \"유저의 리그가 존재하지 않습니다\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 유저 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유저 조회 실패",
                                            value = "{\"error\" : \"USER_4041\", \"message\" : \"존재하지 않는 유저입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 유닛 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유닛 조회 실패",
                                            value = "{\"error\" : \"UNIT_4041\", \"message\" : \"유닛 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @GetMapping("/results/{lessonSubmissionId}")
    ResponseEntity<LessonResultResponse> getLessonResult(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("lessonSubmissionId") Long lessonSubmissionId
    );
}
