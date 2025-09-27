package gravit.code.learning.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.learning.controller.docs.LearningControllerDocs;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.dto.response.LearningResultSaveResponse;
import gravit.code.learning.dto.response.LessonResponse;
import gravit.code.learning.dto.response.UnitPageResponse;
import gravit.code.learning.facade.LearningFacade;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import gravit.code.report.service.ReportService;
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

    @GetMapping("/chapters")
    public ResponseEntity<List<ChapterProgressDetailResponse>> getAllChapters(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllChapters(loginUser.getId()));
    }

    @GetMapping("/{chapterId}/units")
    public ResponseEntity<UnitPageResponse> getAllUnitsInChapter(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("chapterId") Long chapterId
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllUnitsInChapter(loginUser.getId(), chapterId));
    }

    @GetMapping("/{lessonId}")
    public ResponseEntity<LessonResponse> getAllProblemsInLesson(@PathVariable("lessonId") Long lessonsId){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllProblemsInLesson(lessonsId));
    }

    @PostMapping("/results")
    public ResponseEntity<LearningResultSaveResponse> saveLearningResult(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid@RequestBody LearningResultSaveRequest request
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.saveLearningResult(loginUser.getId(), request));
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
