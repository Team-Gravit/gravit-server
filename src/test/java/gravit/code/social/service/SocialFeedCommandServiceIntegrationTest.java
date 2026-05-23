package gravit.code.social.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

import gravit.code.social.domain.FeedEventType;
import gravit.code.social.domain.SocialFeed;
import gravit.code.social.repository.SocialFeedRepository;
import gravit.code.support.TCSpringBootTest;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@TCSpringBootTest
class SocialFeedCommandServiceIntegrationTest {

    @Autowired
    private SocialFeedCommandService socialFeedCommandService;

    @Autowired
    private SocialFeedRepository socialFeedRepository;

    @Nested
    @DisplayName("피드를 생성할 때")
    class CreateFeed {

        @Test
        void 피드가_DB에_저장된다() {
            // given
            long actorId = 1L;
            FeedEventType eventType = FeedEventType.LEVEL_UP;
            String eventValue = "5";

            // when
            socialFeedCommandService.createFeed(actorId, eventType, eventValue);

            // then
            List<SocialFeed> feeds = socialFeedRepository.findAll();
            assertThat(feeds).hasSize(1);
            SocialFeed saved = feeds.get(0);
            assertSoftly(softly -> {
                softly.assertThat(saved.getActorId()).isEqualTo(actorId);
                softly.assertThat(saved.getEventType()).isEqualTo(eventType);
                softly.assertThat(saved.getEventValue()).isEqualTo(eventValue);
            });
        }

        @Test
        void 여러_피드를_저장할_수_있다() {
            // when
            socialFeedCommandService.createFeed(1L, FeedEventType.LEVEL_UP, "5");
            socialFeedCommandService.createFeed(2L, FeedEventType.STREAK_DAYS, "7");
            socialFeedCommandService.createFeed(3L, FeedEventType.TIER_PROMOTION, "골드");

            // then
            assertThat(socialFeedRepository.findAll()).hasSize(3);
        }
    }
}
