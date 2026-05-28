package gravit.code.social.service;

import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.social.domain.FeedEventType;
import gravit.code.social.domain.SocialFeed;
import gravit.code.social.dto.internal.SocialFeedProjection;
import gravit.code.social.dto.response.SocialFeedResponse;
import gravit.code.social.repository.CongratulationRepository;
import gravit.code.social.repository.SocialFeedRepository;
import gravit.code.social.repository.UserFeedRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class SocialFeedService {

    private static final int PAGE_SIZE = 4;
    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");

    private final SocialFeedRepository socialFeedRepository;
    private final UserFeedRepository userFeedRepository;
    private final CongratulationRepository congratulationRepository;

    @Transactional
    public SocialFeed createFeed(
            long actorId,
            FeedEventType eventType,
            String eventValue
    ) {
        return socialFeedRepository.save(SocialFeed.create(actorId, eventType, eventValue));
    }

    @Transactional(readOnly = true)
    public SliceResponse<SocialFeedResponse> getFeed(
            long userId,
            int page
    ) {
        int safePage = Math.max(0, page);
        Pageable pageable = PageRequest.of(safePage, PAGE_SIZE);
        Slice<SocialFeedProjection> projections = userFeedRepository.findVisibleFeedsByUserId(userId, pageable);

        Set<Long> limitReachedActorIds = resolveActorIdsWithLimitReached(userId, projections.getContent());
        Slice<SocialFeedResponse> responses = projections.map(p ->
                SocialFeedResponse.from(p, !limitReachedActorIds.contains(p.actorId())));
        return SliceResponse.of(responses);
    }

    private Set<Long> resolveActorIdsWithLimitReached(
            long userId,
            List<SocialFeedProjection> projections
    ) {
        List<Long> actorIds = projections.stream()
                .map(SocialFeedProjection::actorId)
                .distinct()
                .toList();
        if (actorIds.isEmpty()) {
            return Set.of();
        }
        LocalDateTime startOfDay = LocalDate.now(SEOUL).atStartOfDay();
        return new HashSet<>(congratulationRepository.findActorIdsWithLimitReached(userId, actorIds, startOfDay));
    }

    @Transactional(readOnly = true)
    public long getActorId(long feedId) {
        SocialFeed feed = socialFeedRepository.findById(feedId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.SOCIAL_FEED_NOT_FOUND));
        return feed.getActorId();
    }
}
