package gravit.code.learning.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.bookmark.dto.request.BookmarkDeleteRequest;
import gravit.code.bookmark.dto.request.BookmarkSaveRequest;
import gravit.code.bookmark.service.BookmarkService;
import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.learning.controller.docs.LearningControllerDocs;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.lesson.dto.response.LessonSubmissionSaveResponse;
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
    public ResponseEntity<LessonSubmissionSaveResponse> saveLearningSubmission(
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
        wrongAnsweredNoteService.deleteWrongAnsweredNoteIfExists(loginUser.getId(), request.problemId());
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
