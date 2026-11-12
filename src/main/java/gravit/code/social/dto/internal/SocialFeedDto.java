package gravit.code.social.dto.internal;

import gravit.code.social.domain.FeedEventType;

import java.time.LocalDateTime;

public record SocialFeedDto(
        Long id,

        Long actorId,

        String actorNickname,

        int actorProfileImgNumber,

        String actorHandle,

        FeedEventType eventType,

        String eventValue,

        LocalDateTime createdAt
) {
}
