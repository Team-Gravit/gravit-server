package gravit.code.interviewFeedback.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.interview.domain.InterviewSessionSort;
import gravit.code.interview.dto.response.InterviewSessionHistoryResponse;
import gravit.code.interviewFeedback.controller.docs.InterviewFeedbackControllerDocs;
import gravit.code.interviewFeedback.dto.response.InterviewDashboardResponse;
import gravit.code.interviewFeedback.dto.response.InterviewSessionAnswersResponse;
import gravit.code.interviewFeedback.dto.response.InterviewSessionSummaryResponse;
import gravit.code.interviewFeedback.dto.response.InterviewTopicAccuracyResponse;
import gravit.code.interviewFeedback.service.InterviewFeedbackQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/interview-sessions")
public class InterviewFeedbackController implements InterviewFeedbackControllerDocs {

    private final InterviewFeedbackQueryService interviewFeedbackQueryService;

    @GetMapping
    public ResponseEntity<SliceResponse<InterviewSessionHistoryResponse>> getSessionHistory(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "LATEST") InterviewSessionSort sort
    ) {
        SliceResponse<InterviewSessionHistoryResponse> history = interviewFeedbackQueryService.getSessionHistory(
                loginUser.getId(),
                page,
                sort
        );
        return ResponseEntity.status(HttpStatus.OK).body(history);
    }

    @GetMapping("/{sessionId}/summary")
    public ResponseEntity<InterviewSessionSummaryResponse> getSessionSummary(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId
    ) {
        InterviewSessionSummaryResponse summary = interviewFeedbackQueryService.getSessionSummary(loginUser.getId(), sessionId);
        return ResponseEntity.status(HttpStatus.OK).body(summary);
    }

    @GetMapping("/{sessionId}/answers")
    public ResponseEntity<InterviewSessionAnswersResponse> getSessionAnswers(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId
    ) {
        InterviewSessionAnswersResponse answers = interviewFeedbackQueryService.getSessionAnswers(loginUser.getId(), sessionId);
        return ResponseEntity.status(HttpStatus.OK).body(answers);
    }

    @GetMapping("/dashboard")
    public ResponseEntity<InterviewDashboardResponse> getDashboard(
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        InterviewDashboardResponse dashboard = interviewFeedbackQueryService.getDashboard(loginUser.getId());
        return ResponseEntity.status(HttpStatus.OK).body(dashboard);
    }

    @GetMapping("/weak-topics")
    public ResponseEntity<List<InterviewTopicAccuracyResponse>> getWeakTopics(
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        List<InterviewTopicAccuracyResponse> weakTopics = interviewFeedbackQueryService.getWeakTopics(loginUser.getId());
        return ResponseEntity.status(HttpStatus.OK).body(weakTopics);
    }
}
