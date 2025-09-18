package gravit.code.learning.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.learning.controller.docs.LearningControllerSpecification;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.dto.response.LessonResponse;
import gravit.code.learning.facade.LearningFacade;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import gravit.code.progress.dto.response.UnitPageResponse;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import gravit.code.report.service.ReportService;
import gravit.code.user.dto.response.UserLevelResponse;
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
public class LearningController implements LearningControllerSpecification {

    private final LearningFacade learningFacade;
    private final ReportService reportService;

    @GetMapping("/chapters")
    public ResponseEntity<List<ChapterProgressDetailResponse>> getAllChapters(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllChapters(loginUser.getId()));
    }

    @GetMapping("/{chapterId}/units")
    public ResponseEntity<List<UnitPageResponse>> getAllUnits(@AuthenticationPrincipal LoginUser loginUser,
                                                              @PathVariable("chapterId") Long chapterId){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllUnitsInChapter(loginUser.getId(), chapterId));
    }

    @GetMapping("/{lessonId}/problems")
    public ResponseEntity<LessonResponse> getProblems(@PathVariable("lessonId") Long lessonsId){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllProblemsInLesson(lessonsId));
    }

    @PostMapping("/results")
    public ResponseEntity<UserLevelResponse> saveLearningResult(@AuthenticationPrincipal LoginUser loginUser,
                                                                @Valid@RequestBody LearningResultSaveRequest request){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.saveLearningResult(loginUser.getId(), request));
    }

    @PostMapping("/reports")
    public ResponseEntity<Boolean> submitProblemReport(@AuthenticationPrincipal LoginUser loginUser,
                                                       @Valid@RequestBody ProblemReportSubmitRequest request){
        return ResponseEntity.status(HttpStatus.OK).body(reportService.submitProblemReport(loginUser.getId(),request));
    }
}
