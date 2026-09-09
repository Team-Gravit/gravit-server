package gravit.code.interview.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAudioFormat;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.dto.internal.InterviewAudioUploadDto;
import gravit.code.interview.dto.request.InterviewAudioUploadRequest;
import gravit.code.interview.dto.response.InterviewAudioUploadResponse;
import gravit.code.interview.infrastructure.InterviewAudioStorage;
import gravit.code.interview.policy.InterviewAudioKeyPolicy;
import gravit.code.interview.repository.InterviewSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class InterviewAudioUploadService {

    private final InterviewSessionRepository interviewSessionRepository;

    private final InterviewAudioKeyPolicy interviewAudioKeyPolicy;
    private final InterviewAudioStorage interviewAudioStorage;

    @Transactional(readOnly = true)
    public InterviewAudioUploadResponse issueUploadUrl(
            long userId,
            long sessionId,
            InterviewAudioUploadRequest request
    ) {
        InterviewSession session = interviewSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND));

        if (!session.isOwnedBy(userId)) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED);
        }
        if (session.isTextInput()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_INPUT_TYPE_MISMATCH);
        }
        if (!session.isInProgress()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_NOT_IN_PROGRESS);
        }

        InterviewAudioFormat format = InterviewAudioFormat.from(request.contentType());

        String audioKey = interviewAudioKeyPolicy.issue(sessionId, request.displayOrder(), format);

        InterviewAudioUploadDto upload = interviewAudioStorage.presignUpload(audioKey, format.getContentType());

        return InterviewAudioUploadResponse.of(audioKey, upload);
    }
}
