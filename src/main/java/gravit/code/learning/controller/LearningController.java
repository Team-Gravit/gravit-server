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
import gravit.code.learning.facade.LearningQueryFacade;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
import gravit.code.problem.dto.response.BookmarkedProblemResponse;
import gravit.code.problem.dto.response.WrongAnsweredProblemsResponse;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import gravit.code.report.service.ReportService;
import gravit.code.unit.dto.response.UnitDetailResponse;
import gravit.code.wrongAnsweredNote.dto.response.WrongAnsweredNoteDeleteRequest;
import gravit.code.wrongAnsweredNote.service.WrongAnsweredNoteService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/learning")
public class LearningController implements LearningControllerDocs {

    private final LearningFacade learningFacade;
    private final LearningQueryFacade learningQueryFacade;
    private final ReportService reportService;
    private final BookmarkService bookmarkService;
    private final WrongAnsweredNoteService wrongAnsweredNoteService;

    @GetMapping("/chapters")
    public ResponseEntity<List<ChapterDetailResponse>> getAllChapters(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(learningQueryFacade.getAllChapterDetail(loginUser.getId()));
    }

    @GetMapping("/{chapterId}/units")
    public ResponseEntity<UnitDetailResponse> getAllUnitsInChapter(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("chapterId") Long chapterId
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(learningQueryFacade.getAllUnitDetailInChapter(loginUser.getId(), chapterId));
    }

    @GetMapping("/{unitId}/lessons")
    public ResponseEntity<LessonDetailResponse> getAllLessonsInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningQueryFacade.getAllLessonInUnit(loginUser.getId(), unitId));
    }

    @GetMapping("/{lessonId}")
    public ResponseEntity<LessonResponse> getAllProblemsInLesson(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("lessonId") Long lessonsId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningQueryFacade.getAllProblemsInLesson(lessonsId, loginUser.getId()));
    }

    @PostMapping("/lessons/results")
    public ResponseEntity<LearningSubmissionSaveResponse> saveLearningSubmission(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid@RequestBody LearningSubmissionSaveRequest request
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.saveLearningSubmission(loginUser.getId(), request));
    }

    @PostMapping("/problems/results")
    public ResponseEntity<Void> saveProblemSubmission(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid@RequestBody ProblemSubmissionRequest request
    ){
        learningFacade.saveProblemSubmission(loginUser.getId(), request);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{unitId}/bookmarks")
    public ResponseEntity<BookmarkedProblemResponse> getBookmarkedProblemsInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningQueryFacade.getBookmarkedProblemsInUnit(loginUser.getId(), unitId));
    }

    @GetMapping("/{unitId}/wrong-answered-notes")
    public ResponseEntity<WrongAnsweredProblemsResponse> getWrongAnsweredProblemsInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningQueryFacade.getWrongAnsweredProblemsInUnit(loginUser.getId(), unitId));
    }

    @DeleteMapping("/wrong-answered-notes")
    public ResponseEntity<Void> deleteWrongAnsweredNote(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid@RequestBody WrongAnsweredNoteDeleteRequest request
    ){
        wrongAnsweredNoteService.deleteWrongAnsweredNote(loginUser.getId(), request.problemId());
        return ResponseEntity.noContent().build();
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

    @PostMapping("/reports")
    public ResponseEntity<Void> submitProblemReport(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid@RequestBody ProblemReportSubmitRequest request
    ){
        reportService.submitProblemReport(loginUser.getId(), request);
        return ResponseEntity.ok().build();
    }
}
