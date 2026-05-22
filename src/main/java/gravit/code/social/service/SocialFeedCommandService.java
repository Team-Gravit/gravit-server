package gravit.code.social.service;

import gravit.code.social.domain.FeedEventType;
import gravit.code.social.domain.SocialFeed;
import gravit.code.social.repository.SocialFeedRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SocialFeedCommandService {

    private final SocialFeedRepository socialFeedRepository;

    @Transactional
    public void saveFeed(
            long actorId,
            FeedEventType eventType,
            String eventValue
    ) {
        socialFeedRepository.save(SocialFeed.create(actorId, eventType, eventValue));
    }
}
