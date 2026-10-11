package gravit.code.interview.dto.event;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewTranscriptionRequestedEvent(

        long answerId,

        String audioKey
) {

    public static InterviewTranscriptionRequestedEvent of(
            long answerId,
            String audioKey
    ) {
        return InterviewTranscriptionRequestedEvent.builder()
                .answerId(answerId)
                .audioKey(audioKey)
                .build();
    }
}
