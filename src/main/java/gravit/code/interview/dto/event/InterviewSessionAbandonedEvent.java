package gravit.code.interview.dto.event;

import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionAbandonedEvent(

        List<Long> voiceSessionIds
) {

    public static InterviewSessionAbandonedEvent from(List<Long> voiceSessionIds) {
        return InterviewSessionAbandonedEvent.builder()
                .voiceSessionIds(List.copyOf(voiceSessionIds))
                .build();
    }
}
