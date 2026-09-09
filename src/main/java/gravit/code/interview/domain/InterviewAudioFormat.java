package gravit.code.interview.domain;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.util.Arrays;

@Getter
@RequiredArgsConstructor
public enum InterviewAudioFormat {

    M4A("audio/m4a", "m4a"),
    MP4("audio/mp4", "m4a"),
    WEBM("audio/webm", "webm"),
    MPEG("audio/mpeg", "mp3");

    private final String contentType;
    private final String extension;

    public static InterviewAudioFormat from(String contentType) {
        return Arrays.stream(values())
                .filter(format -> format.contentType.equalsIgnoreCase(contentType))
                .findFirst()
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INTERVIEW_AUDIO_FORMAT_UNSUPPORTED));
    }

    public static boolean hasExtension(String extension) {
        return Arrays.stream(values())
                .anyMatch(format -> format.extension.equals(extension));
    }
}
