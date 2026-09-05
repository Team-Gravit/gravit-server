package gravit.code.interview.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.interview.controller.docs.InterviewSessionControllerDocs;
import gravit.code.interview.dto.request.InterviewSubmitRequest;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.service.InterviewSessionCommandService;
import gravit.code.interview.service.InterviewSessionQueryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/interview-sessions")
public class InterviewSessionController implements InterviewSessionControllerDocs {

    private final InterviewSessionCommandService interviewSessionCommandService;
    private final InterviewSessionQueryService interviewSessionQueryService;

    @PatchMapping("/{sessionId}/submit")
    public ResponseEntity<InterviewSessionStatusResponse> submit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId,
            @Valid @RequestBody InterviewSubmitRequest request
    ) {
        InterviewSessionStatusResponse status = interviewSessionCommandService.submit(
                loginUser.getId(),
                sessionId,
                request.answers()
        );
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(status);
    }

    @GetMapping("/{sessionId}/status")
    public ResponseEntity<InterviewSessionStatusResponse> getStatus(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId
    ) {
        InterviewSessionStatusResponse status = interviewSessionQueryService.getStatus(loginUser.getId(), sessionId);

        return ResponseEntity.status(HttpStatus.OK).body(status);
    }
}
