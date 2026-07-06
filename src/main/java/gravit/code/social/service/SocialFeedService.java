package gravit.code.social.service;

import gravit.code.global.consts.TimeZoneConst;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.global.util.TimeAgoFormatter;
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
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class SocialFeedService {

    private static final int PAGE_SIZE = 4;

    private final SocialFeedRepository socialFeedRepository;
    private final UserFeedRepository userFeedRepository;
    private final CongratulationRepository congratulationRepository;
    private final TimeAgoFormatter timeAgoFormatter;

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
        Set<Long> congratulatedFeedIds = resolveCongratulatedFeedIds(userId, projections.getContent());
        Slice<SocialFeedResponse> responses = projections.map(p -> {
            boolean congratulated = congratulatedFeedIds.contains(p.id());
            boolean canCongratulate = !congratulated && !limitReachedActorIds.contains(p.actorId());
            return SocialFeedResponse.of(p, congratulated, canCongratulate, timeAgoFormatter.format(p.createdAt()));
        });
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
        LocalDateTime startOfDay = LocalDate.now(TimeZoneConst.KST).atStartOfDay();
        return new HashSet<>(congratulationRepository.findActorIdsWithLimitReached(userId, actorIds, startOfDay));
    }

    // 이 페이지의 피드 중 유저가 이미 축하한 피드 id 집합. Congratulation 테이블을 원천으로 하며,
    // 알림함(NotificationFacade)도 같은 데이터를 읽어 축하 완료 상태를 양쪽에서 동기화한다.
    private Set<Long> resolveCongratulatedFeedIds(
            long userId,
            List<SocialFeedProjection> projections
    ) {
        List<Long> feedIds = projections.stream()
                .map(SocialFeedProjection::id)
                .toList();
        if (feedIds.isEmpty()) {
            return Set.of();
        }
        return new HashSet<>(congratulationRepository.findCongratulatedFeedIds(userId, feedIds));
    }

    @Transactional(readOnly = true)
    public long getActorId(long feedId) {
        SocialFeed feed = socialFeedRepository.findById(feedId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.SOCIAL_FEED_NOT_FOUND));
        return feed.getActorId();
    }
}
