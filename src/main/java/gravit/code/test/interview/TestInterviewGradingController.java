package gravit.code.test.interview;

import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgmentDto;
import gravit.code.interviewFeedback.service.InterviewGradingService;
import gravit.code.test.interview.docs.TestInterviewGradingControllerDocs;
import gravit.code.test.interview.dto.request.TestInterviewGradingRequest;
import gravit.code.test.interview.dto.response.TestInterviewGradingResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@Profile("!prod")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/test")
public class TestInterviewGradingController implements TestInterviewGradingControllerDocs {

    private final InterviewGradingService interviewGradingService;

    @PostMapping("/interview/grading")
    public ResponseEntity<TestInterviewGradingResponse> gradeAnswer(@Valid @RequestBody TestInterviewGradingRequest request) {
        InterviewGradingJudgmentDto judgment = interviewGradingService.judge(request.toInput());

        return ResponseEntity.status(OK).body(TestInterviewGradingResponse.from(judgment));
    }
}
