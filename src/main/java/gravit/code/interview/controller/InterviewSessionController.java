package gravit.code.interview.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.interview.controller.docs.InterviewSessionControllerDocs;
import gravit.code.interview.dto.request.InterviewAnswerSubmitRequest;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interview.dto.response.InterviewAnswerSubmitResponse;
import gravit.code.interview.dto.response.InterviewSessionCreateResponse;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.facade.InterviewSessionFacade;
import gravit.code.interview.service.InterviewSessionCommandService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/interview-sessions")
public class InterviewSessionController implements InterviewSessionControllerDocs {

    private final InterviewSessionFacade interviewSessionFacade;
    private final InterviewSessionCommandService interviewSessionCommandService;

    @PostMapping
    public ResponseEntity<InterviewSessionCreateResponse> createSession(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody InterviewSessionCreateRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED).body(interviewSessionFacade.createSession(loginUser.getId(), request));
    }

    @PatchMapping("/{sessionId}/answers/{displayOrder}")
    public ResponseEntity<InterviewAnswerSubmitResponse> submitAnswer(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("sessionId") Long sessionId,
            @PathVariable("displayOrder") Integer displayOrder,
            @Valid @RequestBody InterviewAnswerSubmitRequest request
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(interviewSessionFacade.submitAnswer(loginUser.getId(), sessionId, displayOrder, request));
    }

    @PatchMapping("/{sessionId}/complete")
    public ResponseEntity<InterviewSessionStatusResponse> completeSession(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("sessionId") Long sessionId
    ) {
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(interviewSessionCommandService.startGrading(loginUser.getId(), sessionId));
    }

    @PatchMapping("/{sessionId}/abandon")
    public ResponseEntity<InterviewSessionStatusResponse> abandonSession(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("sessionId") Long sessionId
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(interviewSessionCommandService.abandon(loginUser.getId(), sessionId));
    }
}
