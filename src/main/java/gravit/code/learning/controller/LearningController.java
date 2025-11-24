package gravit.code.learning.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.bookmark.dto.request.BookmarkDeleteRequest;
import gravit.code.bookmark.dto.request.BookmarkSaveRequest;
import gravit.code.bookmark.service.BookmarkService;
import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.learning.controller.docs.LearningControllerDocs;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.learning.dto.response.LearningSubmissionSaveResponse;
import gravit.code.learning.facade.LearningFacade;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.dto.response.BookmarkedProblemResponse;
import gravit.code.problem.dto.response.WrongAnsweredProblemsResponse;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import gravit.code.report.service.ReportService;
import gravit.code.unit.dto.response.UnitDetailResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/learning")
public class LearningController implements LearningControllerDocs {

    private final LearningFacade learningFacade;
    private final ReportService reportService;
    private final BookmarkService bookmarkService;

    @GetMapping("/chapters")
    public ResponseEntity<List<ChapterDetailResponse>> getAllChapters(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllChapterDetail(loginUser.getId()));
    }

    @GetMapping("/{chapterId}/units")
    public ResponseEntity<UnitDetailResponse> getAllUnitsInChapter(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("chapterId") Long chapterId
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllUnitDetailInChapter(loginUser.getId(), chapterId));
    }

    @GetMapping("/{unitId}/lessons")
    public ResponseEntity<LessonDetailResponse> getAllLessonsInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllLessonInUnit(loginUser.getId(), unitId));
    }

    @GetMapping("/{lessonId}")
    public ResponseEntity<LessonResponse> getAllProblemsInLesson(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("lessonId") Long lessonsId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllProblemsInLesson(lessonsId, loginUser.getId()));
    }

    @PostMapping("/lesson/results")
    public ResponseEntity<LearningSubmissionSaveResponse> saveLearningSubmission(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid@RequestBody LearningSubmissionSaveRequest request
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.saveLearningSubmission(loginUser.getId(), request));
    }

    @PostMapping("/reports")
    public ResponseEntity<Void> submitProblemReport(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid@RequestBody ProblemReportSubmitRequest request
    ){
        reportService.submitProblemReport(loginUser.getId(), request);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{unitId}/bookmarks")
    public ResponseEntity<BookmarkedProblemResponse> getBookmarkedProblemsInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getBookmarkedProblemsInUnit(loginUser.getId(), unitId));
    }

    @PostMapping("/bookmarks")
    public ResponseEntity<Void> saveBookmark(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid@RequestBody BookmarkSaveRequest request
    ){
        bookmarkService.saveBookmark(loginUser.getId(), request);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/bookmarks")
    public ResponseEntity<Void> deleteBookmark(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid@RequestBody BookmarkDeleteRequest request
    ) {
        bookmarkService.deleteBookmark(loginUser.getId(), request);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{unitId}/wrong-answered-problems")
    public ResponseEntity<WrongAnsweredProblemsResponse> getWrongAnsweredProblemsInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getWrongAnsweredProblemsInUnit(loginUser.getId(), unitId));
    }
}
