package gravit.code.user.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.chapter.dto.response.TopChapterResponse;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningReportResponse;
import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.learning.dto.response.LearningHistoryResponse;
import gravit.code.learning.dto.response.LearningSummaryResponse;
import gravit.code.learning.dto.response.WeakConceptResponse;
import gravit.code.learning.facade.LearningFacade;
import gravit.code.lesson.service.LessonSubmissionQueryService;
import gravit.code.problem.service.ProblemSubmissionQueryService;
import gravit.code.user.controller.docs.MyPageControllerDocs;
import gravit.code.user.dto.response.MyPageBannerResponse;
import gravit.code.user.facade.UserFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Validated
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/my-pages")
public class MyPageController implements MyPageControllerDocs {

    private final UserFacade userFacade;
    private final LearningFacade learningFacade;

    private final DailyLearningRecordService dailyLearningRecordService;
    private final LessonSubmissionQueryService lessonSubmissionQueryService;
    private final ProblemSubmissionQueryService problemSubmissionQueryService;

    @GetMapping("/banners")
    public ResponseEntity<MyPageBannerResponse> getMyPageBanner(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(userFacade.getMyPageBanner(loginUser.getId()));
    }

    @GetMapping("/learning/summaries")
    public ResponseEntity<LearningSummaryResponse> getMyPageSummary(@AuthenticationPrincipal LoginUser loginUser){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getMyPageSummary(loginUser.getId()));
    }

    @GetMapping("/learning/weak-concepts")
    public ResponseEntity<List<WeakConceptResponse>> getMyPageWeakConcepts(@AuthenticationPrincipal LoginUser loginUser){
        return ResponseEntity.status(HttpStatus.OK).body(problemSubmissionQueryService.getWeakConcepts(loginUser.getId()));
    }

    @GetMapping("/learning/weekly-report")
    public ResponseEntity<WeeklyLearningReportResponse> getMyPageWeeklyReport(@AuthenticationPrincipal LoginUser loginUser){
        return ResponseEntity.status(HttpStatus.OK).body(dailyLearningRecordService.getWeeklyLearningReport(loginUser.getId()));
    }

    @GetMapping("/learning/top-chapters")
    public ResponseEntity<List<TopChapterResponse>> getMyPageTopChapters(@AuthenticationPrincipal LoginUser loginUser){
        return ResponseEntity.status(HttpStatus.OK).body(lessonSubmissionQueryService.getTopChapters(loginUser.getId()));
    }

    @GetMapping("/learning/history")
    public ResponseEntity<LearningHistoryResponse> getMyPageLearningHistory(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam("year") int year
    ){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getMyPageLearningHistory(loginUser.getId(), year));
    }
}
