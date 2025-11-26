package gravit.code.learning.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.bookmark.dto.request.BookmarkDeleteRequest;
import gravit.code.bookmark.dto.request.BookmarkSaveRequest;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.learning.dto.response.LearningSubmissionSaveResponse;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
import gravit.code.problem.dto.response.BookmarkedProblemResponse;
import gravit.code.problem.dto.response.WrongAnsweredProblemsResponse;
import gravit.code.unit.dto.response.UnitDetailResponse;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import gravit.code.wrongAnsweredNote.dto.response.WrongAnsweredNoteDeleteRequest;
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
import org.springframework.web.bind.annotation.*;

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

    @Operation(summary = "레슨 목록 조회", description = "특정 유닛의 레슨 목록을 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 레슨 목록 조회 성공"),
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
    @GetMapping("/{unitId}/lessons")
    ResponseEntity<LessonDetailResponse> getAllLessonsInUnit(@AuthenticationPrincipal LoginUser loginUser,
                                                              @PathVariable("unitId") Long unitId);

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
    ResponseEntity<LessonResponse> getAllProblemsInLesson(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("lessonId") Long lessonsId
    );

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
    @PostMapping("/lessons/results")
    ResponseEntity<LearningSubmissionSaveResponse> saveLearningSubmission(@AuthenticationPrincipal LoginUser loginUser,
                                                                      @Valid @RequestBody LearningSubmissionSaveRequest request);

    @Operation(summary = "문제 결과 저장", description = "문제 풀이 결과를 저장합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 문제 결과 저장 성공"),
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
    @PostMapping("/problems/results")
    ResponseEntity<Void> saveProblemSubmission(@AuthenticationPrincipal LoginUser loginUser,
                                               @Valid @RequestBody ProblemSubmissionRequest request);

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

    @Operation(summary = "유닛 내 북마크된 문제 조회", description = "특정 유닛에서 사용자가 북마크한 문제 목록을 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 북마크된 문제 목록 조회 성공"),
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
            @ApiResponse(responseCode = "ANSWER_4041", description = "🚨 정답 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "정답 조회 실패",
                                            value = "{\"error\" : \"ANSWER_4041\", \"message\" : \"정답 조회에 실패하였습니다.\"}"
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
    @GetMapping("/{unitId}/bookmarks")
    ResponseEntity<BookmarkedProblemResponse> getBookmarkedProblemsInUnit(@AuthenticationPrincipal LoginUser loginUser,
                                                                           @PathVariable("unitId") Long unitId);

    @Operation(summary = "유닛 내 오답 문제 조회", description = "특정 유닛에서 사용자가 틀린 문제 목록을 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 오답 문제 목록 조회 성공"),
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
            @ApiResponse(responseCode = "ANSWER_4041", description = "🚨 정답 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "정답 조회 실패",
                                            value = "{\"error\" : \"ANSWER_4041\", \"message\" : \"정답 조회에 실패하였습니다.\"}"
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
    @GetMapping("/{unitId}/wrong-answered-notes")
    ResponseEntity<WrongAnsweredProblemsResponse> getWrongAnsweredProblemsInUnit(@AuthenticationPrincipal LoginUser loginUser,
                                                                                   @PathVariable("unitId") Long unitId);

    @Operation(summary = "오답노트 삭제", description = "특정 문제의 오답노트를 삭제합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "✅ 오답노트 삭제 성공"),
            @ApiResponse(responseCode = "WRONG_ANSWERED_NOTE_4041", description = "🚨 오답노트 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "오답노트 조회 실패",
                                            value = "{\"error\" : \"WRONG_ANSWERED_NOTE_4041\", \"message\" : \"오답노트 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @DeleteMapping("/wrong-answered-notes")
    ResponseEntity<Void> deleteWrongAnsweredNote(@AuthenticationPrincipal LoginUser loginUser,
                                                  @Valid @RequestBody WrongAnsweredNoteDeleteRequest request);

    @Operation(summary = "북마크 저장", description = "특정 문제를 북마크에 추가합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 북마크 저장 성공"),
            @ApiResponse(responseCode = "BOOKMARK_4091", description = "🚨 이미 북마크한 문제",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "북마크 중복",
                                            value = "{\"error\" : \"BOOKMARK_4091\", \"message\" : \"이미 북마크한 문제입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/bookmarks")
    ResponseEntity<Void> saveBookmark(@AuthenticationPrincipal LoginUser loginUser,
                                      @Valid @RequestBody BookmarkSaveRequest request);

    @Operation(summary = "북마크 삭제", description = "특정 문제의 북마크를 삭제합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "✅ 북마크 삭제 성공"),
            @ApiResponse(responseCode = "BOOKMARK_4041", description = "🚨 북마크 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "북마크 조회 실패",
                                            value = "{\"error\" : \"BOOKMARK_4041\", \"message\" : \"북마크 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @DeleteMapping("/bookmarks")
    ResponseEntity<Void> deleteBookmark(@AuthenticationPrincipal LoginUser loginUser,
                                        @Valid @RequestBody BookmarkDeleteRequest request);
}