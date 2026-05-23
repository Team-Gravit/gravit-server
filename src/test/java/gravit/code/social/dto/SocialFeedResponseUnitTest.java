package gravit.code.social.dto;

import gravit.code.social.domain.FeedEventType;
import gravit.code.social.dto.internal.SocialFeedProjection;
import gravit.code.social.dto.response.SocialFeedResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class SocialFeedResponseUnitTest {

    private SocialFeedProjection createProjection(FeedEventType eventType, String eventValue) {
        return new SocialFeedProjection(
                1L, 10L, "테스터", 1, "tester",
                eventType, eventValue, LocalDateTime.now(), null
        );
    }

    @Nested
    @DisplayName("피드 메시지를 생성할 때")
    class GenerateMessage {

        @Test
        void PLANET_COMPLETE_메시지를_생성한다() {
            // given
            SocialFeedProjection projection = createProjection(FeedEventType.PLANET_COMPLETE, "지구");

            // when
            SocialFeedResponse response = SocialFeedResponse.from(projection);

            // then
            assertThat(response.message()).isEqualTo("테스터님이 지구 행성을 정복했어요!");
        }

        @Test
        void STREAK_DAYS_메시지를_생성한다() {
            // given
            SocialFeedProjection projection = createProjection(FeedEventType.STREAK_DAYS, "30");

            // when
            SocialFeedResponse response = SocialFeedResponse.from(projection);

            // then
            assertThat(response.message()).isEqualTo("테스터님이 30일 연속 학습을 달성했어요!");
        }

        @Test
        void TIER_PROMOTION_메시지를_생성한다() {
            // given
            SocialFeedProjection projection = createProjection(FeedEventType.TIER_PROMOTION, "골드");

            // when
            SocialFeedResponse response = SocialFeedResponse.from(projection);

            // then
            assertThat(response.message()).isEqualTo("테스터님이 골드로 승급했어요!");
        }

        @Test
        void LEVEL_UP_메시지를_생성한다() {
            // given
            SocialFeedProjection projection = createProjection(FeedEventType.LEVEL_UP, "5");

            // when
            SocialFeedResponse response = SocialFeedResponse.from(projection);

            // then
            assertThat(response.message()).isEqualTo("테스터님이 LV.5로 레벨업했어요!");
        }

        @Test
        void 프로젝션의_모든_필드가_응답에_매핑된다() {
            // given
            LocalDateTime now = LocalDateTime.now();
            SocialFeedProjection projection = new SocialFeedProjection(
                    99L, 10L, "테스터", 3, "tester_handle",
                    FeedEventType.LEVEL_UP, "7", now, null
            );

            // when
            SocialFeedResponse response = SocialFeedResponse.from(projection);

            // then
            assertThat(response.feedId()).isEqualTo(99L);
            assertThat(response.actorId()).isEqualTo(10L);
            assertThat(response.actorNickname()).isEqualTo("테스터");
            assertThat(response.actorProfileImgNumber()).isEqualTo(3);
            assertThat(response.actorHandle()).isEqualTo("tester_handle");
            assertThat(response.createdAt()).isEqualTo(now);
        }
    }
}
