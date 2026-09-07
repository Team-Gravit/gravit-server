package gravit.code.interviewQuestion.service;

import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.domain.InterviewTopicKind;
import gravit.code.interviewQuestion.dto.response.InterviewTopicResponse;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewTopicQueryServiceIntegrationTest {

    private static final int CS_TOPIC_COUNT = 5;

    @Autowired
    private InterviewTopicQueryService interviewTopicQueryService;

    @Nested
    @DisplayName("공통 CS 주제를 조회할 때")
    class GetCsTopics {

        @Test
        void CS_종류_태그만_선언_순서대로_돌려준다() {
            // when
            List<InterviewTopicResponse> topics = interviewTopicQueryService.getCsTopics();

            // then
            assertSoftly(softly -> {
                softly.assertThat(topics).hasSize(CS_TOPIC_COUNT);
                softly.assertThat(topics.stream().map(InterviewTopicResponse::topic)).containsExactly(
                        InterviewTopic.DATA_STRUCTURE,
                        InterviewTopic.ALGORITHM,
                        InterviewTopic.DATABASE,
                        InterviewTopic.OPERATING_SYSTEM,
                        InterviewTopic.NETWORK
                );
            });
        }

        @Test
        void CS가_아닌_태그는_나오지_않는다() {
            // when
            List<InterviewTopicResponse> topics = interviewTopicQueryService.getCsTopics();

            // then
            assertThat(topics).allSatisfy(topic ->
                    assertThat(topic.topic().getKind()).isEqualTo(InterviewTopicKind.CS));
        }

        @Test
        void 표시명이_함께_나온다() {
            // when
            List<InterviewTopicResponse> topics = interviewTopicQueryService.getCsTopics();

            // then
            assertSoftly(softly -> {
                softly.assertThat(topics.get(0).displayName()).isEqualTo("자료구조");
                softly.assertThat(topics).allSatisfy(topic ->
                        assertThat(topic.displayName()).isEqualTo(topic.topic().getDisplayName()));
            });
        }
    }
}
