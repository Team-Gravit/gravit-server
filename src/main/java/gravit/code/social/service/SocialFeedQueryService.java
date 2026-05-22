package gravit.code.social.service;

import gravit.code.global.dto.response.SliceResponse;
import gravit.code.social.dto.internal.SocialFeedProjection;
import gravit.code.social.dto.response.SocialFeedResponse;
import gravit.code.social.repository.SocialFeedRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SocialFeedQueryService {

    private final SocialFeedRepository socialFeedRepository;

    private static final int PAGE_SIZE = 20;

    @Transactional(readOnly = true)
    public SliceResponse<SocialFeedResponse> getFeed(
            List<Long> followeeIds,
            int page
    ) {
        if (followeeIds.isEmpty()) {
            return SliceResponse.empty();
        }

        int safePage = Math.max(0, page);
        Pageable pageable = PageRequest.of(safePage, PAGE_SIZE);
        Slice<SocialFeedProjection> projections = socialFeedRepository.findFeedsByActorIds(followeeIds, pageable);
        Slice<SocialFeedResponse> responses = projections.map(SocialFeedResponse::from);
        return SliceResponse.of(responses);
    }
}
