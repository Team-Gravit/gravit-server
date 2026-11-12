package gravit.code.interview.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.interview.controller.docs.InterviewSessionControllerDocs;
import gravit.code.interview.dto.request.InterviewAudioUploadRequest;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interview.dto.request.InterviewSubmitRequest;
import gravit.code.interview.dto.request.InterviewTranscriptionRequest;
import gravit.code.interview.dto.response.InterviewAudioUploadResponse;
import gravit.code.interview.dto.response.InterviewSessionCreateResponse;
import gravit.code.interview.dto.response.InterviewSessionQuestionsResponse;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.dto.response.InterviewTranscriptionsResponse;
import gravit.code.interview.facade.InterviewSessionFacade;
import gravit.code.interview.service.InterviewAudioUploadService;
import gravit.code.interview.service.InterviewSessionCommandService;
import gravit.code.interview.service.InterviewSessionQueryService;
import gravit.code.interview.service.InterviewTranscriptionCommandService;
import gravit.code.interview.service.InterviewTranscriptionQueryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.ACCEPTED;
import static org.springframework.http.HttpStatus.CREATED;
import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/interview-sessions")
public class InterviewSessionController implements InterviewSessionControllerDocs {

    private final InterviewSessionFacade interviewSessionFacade;

    private final InterviewSessionCommandService interviewSessionCommandService;
    private final InterviewSessionQueryService interviewSessionQueryService;
    private final InterviewAudioUploadService interviewAudioUploadService;
    private final InterviewTranscriptionCommandService interviewTranscriptionCommandService;
    private final InterviewTranscriptionQueryService interviewTranscriptionQueryService;

    @PostMapping
    public ResponseEntity<InterviewSessionCreateResponse> create(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody InterviewSessionCreateRequest request
    ) {
        InterviewSessionCreateResponse session = interviewSessionFacade.create(loginUser.getId(), request);

        return ResponseEntity.status(CREATED).body(session);
    }

    @GetMapping("/{sessionId}/questions")
    public ResponseEntity<InterviewSessionQuestionsResponse> getQuestions(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId
    ) {
        InterviewSessionQuestionsResponse questions = interviewSessionQueryService.getQuestions(
                loginUser.getId(), sessionId);

        return ResponseEntity.status(OK).body(questions);
    }

    @PostMapping("/{sessionId}/audio-uploads")
    public ResponseEntity<InterviewAudioUploadResponse> issueUploadUrl(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId,
            @Valid @RequestBody InterviewAudioUploadRequest request
    ) {
        InterviewAudioUploadResponse upload = interviewAudioUploadService.issueUploadUrl(
                loginUser.getId(), sessionId, request);

        return ResponseEntity.status(OK).body(upload);
    }

    @PostMapping("/{sessionId}/transcriptions")
    public ResponseEntity<Void> requestTranscription(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId,
            @Valid @RequestBody InterviewTranscriptionRequest request
    ) {
        interviewTranscriptionCommandService.request(loginUser.getId(), sessionId, request);

        return ResponseEntity.status(ACCEPTED).build();
    }

    @GetMapping("/{sessionId}/transcriptions")
    public ResponseEntity<InterviewTranscriptionsResponse> getTranscriptions(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId
    ) {
        InterviewTranscriptionsResponse transcriptions = interviewTranscriptionQueryService.getTranscriptions(
                loginUser.getId(), sessionId);

        return ResponseEntity.status(OK).body(transcriptions);
    }

    @PatchMapping("/{sessionId}/abandon")
    public ResponseEntity<InterviewSessionStatusResponse> abandon(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId
    ) {
        InterviewSessionStatusResponse status = interviewSessionCommandService.abandon(loginUser.getId(), sessionId);

        return ResponseEntity.status(OK).body(status);
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
        return ResponseEntity.status(ACCEPTED).body(status);
    }

    @GetMapping("/{sessionId}/status")
    public ResponseEntity<InterviewSessionStatusResponse> getStatus(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long sessionId
    ) {
        InterviewSessionStatusResponse status = interviewSessionQueryService.getStatus(loginUser.getId(), sessionId);

        return ResponseEntity.status(OK).body(status);
    }
}
