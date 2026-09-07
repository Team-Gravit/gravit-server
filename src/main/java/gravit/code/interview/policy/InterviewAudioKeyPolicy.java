package gravit.code.interview.policy;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAudioFormat;
import org.springframework.stereotype.Component;

@Component
public class InterviewAudioKeyPolicy {

    private static final String KEY_FORMAT = "interview/%d/%d.%s";
    private static final String KEY_PREFIX_FORMAT = "interview/%d/%d.";

    public String issue(
            long sessionId,
            int displayOrder,
            InterviewAudioFormat format
    ) {
        return String.format(KEY_FORMAT, sessionId, displayOrder, format.getExtension());
    }

    public void validate(
            long sessionId,
            int displayOrder,
            String audioKey
    ) {
        String prefix = String.format(KEY_PREFIX_FORMAT, sessionId, displayOrder);

        if (!audioKey.startsWith(prefix)) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_AUDIO_KEY_INVALID);
        }

        String extension = audioKey.substring(prefix.length());
        if (!InterviewAudioFormat.hasExtension(extension)) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_AUDIO_KEY_INVALID);
        }
    }
}
