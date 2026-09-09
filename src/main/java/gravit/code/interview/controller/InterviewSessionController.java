package gravit.code.interview.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.interview.controller.docs.InterviewSessionControllerDocs;
import gravit.code.interview.dto.request.InterviewAudioUploadRequest;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interview.dto.request.InterviewSubmitRequest;
import gravit.code.interview.dto.response.InterviewAudioUploadResponse;
import gravit.code.interview.dto.response.InterviewSessionCreateResponse;
import gravit.code.interview.dto.response.InterviewSessionQuestionsResponse;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.facade.InterviewSessionFacade;
import gravit.code.interview.service.InterviewAudioUploadService;
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
    private final InterviewSessionQueryService interviewSessionQueryService;
    private final InterviewAudioUploadService interviewAudioUploadService;

    @PostMapping
    public ResponseEntity<InterviewSessionCreateResponse> create(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody InterviewSessionCreateRequest request
    ) {
        InterviewSessionCreateResponse session = interviewSessionFacade.create(loginUser.getId(), request);

        return ResponseEntity.status(HttpStatus.CREATED).body(session);
    }

    @GetMapping("/{sessionId}/questions")
    public ResponseEntity<InterviewSessionQuestionsResponse> getQuestions(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId
    ) {
        InterviewSessionQuestionsResponse questions = interviewSessionQueryService.getQuestions(
                loginUser.getId(), sessionId);

        return ResponseEntity.status(HttpStatus.OK).body(questions);
    }

    @PostMapping("/{sessionId}/audio-uploads")
    public ResponseEntity<InterviewAudioUploadResponse> issueUploadUrl(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId,
            @Valid @RequestBody InterviewAudioUploadRequest request
    ) {
        InterviewAudioUploadResponse upload = interviewAudioUploadService.issueUploadUrl(
                loginUser.getId(), sessionId, request);

        return ResponseEntity.status(HttpStatus.OK).body(upload);
    }

    @PatchMapping("/{sessionId}/abandon")
    public ResponseEntity<InterviewSessionStatusResponse> abandon(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId
    ) {
        InterviewSessionStatusResponse status = interviewSessionCommandService.abandon(loginUser.getId(), sessionId);

        return ResponseEntity.status(HttpStatus.OK).body(status);
    }

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
