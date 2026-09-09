package gravit.code.interview.policy;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.domain.InterviewStack;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolDto;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_QUESTION_POOL_INSUFFICIENT;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_STACK_NOT_ALLOWED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_STACK_REQUIRED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_TOPIC_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_TOPIC_NOT_ALLOWED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_TOPIC_REQUIRED;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewQuestionAllocationPolicyIntegrationTest {

    private static final int QUESTION_COUNT = 5;
    private static final int SHUFFLE_ATTEMPTS = 30;
    private static final int ORDER_ATTEMPTS = 50;

    private static final List<InterviewTopic> CS_TOPICS = List.of(
            InterviewTopic.DATA_STRUCTURE,
            InterviewTopic.ALGORITHM,
            InterviewTopic.DATABASE,
            InterviewTopic.OPERATING_SYSTEM,
            InterviewTopic.NETWORK
    );

    @Autowired
    private InterviewQuestionAllocationPolicy interviewQuestionAllocationPolicy;

    private static List<InterviewQuestionPoolDto> 문제_풀(Map<InterviewTopic, Integer> topicToCount) {
        List<InterviewQuestionPoolDto> pool = new ArrayList<>();
        long questionId = 1L;
        for (Map.Entry<InterviewTopic, Integer> entry : topicToCount.entrySet()) {
            for (int index = 0; index < entry.getValue(); index++) {
                pool.add(new InterviewQuestionPoolDto(entry.getKey(), questionId++));
            }
        }
        return pool;
    }

    private static Map<InterviewTopic, Integer> 몫이_같은_풀_크기(
            Map<InterviewTopic, Integer> topicToQuota
    ) {
        return new LinkedHashMap<>(topicToQuota);
    }

    @Nested
    @DisplayName("모드 조합을 검증할 때")
    class Validate {

        @Test
        void 공통CS에_스택을_주면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, InterviewStack.JAVA_SPRING_BOOT, List.of(InterviewTopic.ALGORITHM)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_STACK_NOT_ALLOWED);
        }

        @Test
        void 직군에_스택이_없으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.JOB_SPECIFIC, null, null))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_STACK_REQUIRED);
        }

        @Test
        void 직군에_주제를_주면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.JOB_SPECIFIC, InterviewStack.JAVA_SPRING_BOOT, List.of(InterviewTopic.ALGORITHM)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_TOPIC_NOT_ALLOWED);
        }

        @Test
        void 공통CS에_주제가_null이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, null, null))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_TOPIC_REQUIRED);
        }

        @Test
        void 공통CS에_주제가_비어있으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, null, List.of()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_TOPIC_REQUIRED);
        }

        @Test
        void 공통CS에_주제가_6개면_예외를_던진다() {
            // given
            List<InterviewTopic> tooMany = List.of(
                    InterviewTopic.DATA_STRUCTURE,
                    InterviewTopic.ALGORITHM,
                    InterviewTopic.DATABASE,
                    InterviewTopic.OPERATING_SYSTEM,
                    InterviewTopic.NETWORK,
                    InterviewTopic.DATA_STRUCTURE
            );

            // when & then
            assertThatThrownBy(() -> interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, null, tooMany))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_TOPIC_INVALID);
        }

        @Test
        void 공통CS에_중복_주제가_있으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, null,
                    List.of(InterviewTopic.ALGORITHM, InterviewTopic.ALGORITHM)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_TOPIC_INVALID);
        }

        @Test
        void 공통CS에_CS가_아닌_주제가_있으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, null,
                    List.of(InterviewTopic.ALGORITHM, InterviewTopic.JAVA)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_TOPIC_INVALID);
        }
    }

    @Nested
    @DisplayName("공통 CS 배분을 할 때")
    class AllocateCommonCs {

        @ParameterizedTest
        @CsvSource({
                "1, 5",
                "2, '3,2'",
                "3, '2,2,1'",
                "4, '2,1,1,1'",
                "5, '1,1,1,1,1'"
        })
        void 주제_수에_따라_정책표대로_배분한다(
                int topicCount,
                String expectedQuotas
        ) {
            // given
            List<InterviewTopic> topics = CS_TOPICS.subList(0, topicCount);
            List<Integer> expected = new ArrayList<>();
            for (String quota : expectedQuotas.split(",")) {
                expected.add(Integer.parseInt(quota.trim()));
            }

            // when
            Map<InterviewTopic, Integer> topicToQuota =
                    interviewQuestionAllocationPolicy.allocate(InterviewMode.COMMON_CS, null, topics);

            // then
            assertSoftly(softly -> {
                softly.assertThat(topicToQuota.values().stream().mapToInt(Integer::intValue).sum())
                        .isEqualTo(QUESTION_COUNT);
                softly.assertThat(topicToQuota.values()).containsExactlyInAnyOrderElementsOf(expected);
                softly.assertThat(topicToQuota.keySet()).containsExactlyInAnyOrderElementsOf(topics);
            });
        }

        @Test
        void 많은_몫을_받는_주제가_고정되지_않는다() {
            // given
            List<InterviewTopic> topics = CS_TOPICS.subList(0, 2);

            // when
            Set<InterviewTopic> topicsWithLargerQuota = new HashSet<>();
            for (int attempt = 0; attempt < SHUFFLE_ATTEMPTS; attempt++) {
                Map<InterviewTopic, Integer> topicToQuota =
                        interviewQuestionAllocationPolicy.allocate(InterviewMode.COMMON_CS, null, topics);

                topicToQuota.forEach((topic, quota) -> {
                    if (quota == 3) {
                        topicsWithLargerQuota.add(topic);
                    }
                });
            }

            // then
            assertThat(topicsWithLargerQuota).hasSize(2);
        }
    }

    @Nested
    @DisplayName("직군 배분을 할 때")
    class AllocateJobSpecific {

        @Test
        void 스택_구성_태그에_공통1_언어2_프레임워크2를_이_순서로_배분한다() {
            // when
            Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.JOB_SPECIFIC, InterviewStack.JAVA_SPRING_BOOT, null);

            // then
            assertSoftly(softly -> {
                softly.assertThat(topicToQuota.keySet()).containsExactly(
                        InterviewTopic.SERVER_COMMON, InterviewTopic.JAVA, InterviewTopic.SPRING_BOOT);
                softly.assertThat(topicToQuota.values()).containsExactly(1, 2, 2);
                softly.assertThat(topicToQuota.values().stream().mapToInt(Integer::intValue).sum())
                        .isEqualTo(QUESTION_COUNT);
            });
        }

        @Test
        void 스택이_달라도_배분_비율은_같다() {
            // when
            Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.JOB_SPECIFIC, InterviewStack.SWIFT_SWIFTUI, null);

            // then
            assertSoftly(softly -> {
                softly.assertThat(topicToQuota.keySet()).containsExactly(
                        InterviewTopic.IOS_COMMON, InterviewTopic.SWIFT, InterviewTopic.SWIFTUI);
                softly.assertThat(topicToQuota.values()).containsExactly(1, 2, 2);
            });
        }
    }

    @Nested
    @DisplayName("문제를 선별할 때")
    class Select {

        @Test
        void 몫만큼_중복_없이_뽑는다() {
            // given
            Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, null, CS_TOPICS.subList(0, 3));
            List<InterviewQuestionPoolDto> pool = 문제_풀(Map.of(
                    InterviewTopic.DATA_STRUCTURE, 5,
                    InterviewTopic.ALGORITHM, 5,
                    InterviewTopic.DATABASE, 5
            ));

            // when
            List<Long> orderedQuestionIds =
                    interviewQuestionAllocationPolicy.select(InterviewMode.COMMON_CS, topicToQuota, pool);

            // then
            assertSoftly(softly -> {
                softly.assertThat(orderedQuestionIds).hasSize(QUESTION_COUNT);
                softly.assertThat(orderedQuestionIds).doesNotHaveDuplicates();
            });
        }

        @Test
        void 풀이_몫과_정확히_같아도_성공한다() {
            // given
            Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, null, CS_TOPICS);
            List<InterviewQuestionPoolDto> pool = 문제_풀(몫이_같은_풀_크기(topicToQuota));

            // when
            List<Long> orderedQuestionIds =
                    interviewQuestionAllocationPolicy.select(InterviewMode.COMMON_CS, topicToQuota, pool);

            // then
            assertThat(orderedQuestionIds).hasSize(QUESTION_COUNT).doesNotHaveDuplicates();
        }

        @Test
        void 태그_하나만_몫에_미달해도_예외를_던진다() {
            // given
            Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, null, List.of(InterviewTopic.ALGORITHM, InterviewTopic.NETWORK));
            Map<InterviewTopic, Integer> poolSizes = 몫이_같은_풀_크기(topicToQuota);
            InterviewTopic starved = poolSizes.keySet().iterator().next();
            poolSizes.put(starved, poolSizes.get(starved) - 1);

            // when & then
            assertThatThrownBy(() -> interviewQuestionAllocationPolicy.select(
                    InterviewMode.COMMON_CS, topicToQuota, 문제_풀(poolSizes)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_QUESTION_POOL_INSUFFICIENT);
        }

        @Test
        void 풀이_비어있으면_예외를_던진다() {
            // given
            Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, null, List.of(InterviewTopic.ALGORITHM));

            // when & then
            assertThatThrownBy(() -> interviewQuestionAllocationPolicy.select(
                    InterviewMode.COMMON_CS, topicToQuota, List.of()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_QUESTION_POOL_INSUFFICIENT);
        }

        @Test
        void 후보가_몫보다_많으면_매번_같은_조합이_나오지_않는다() {
            // given
            Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, null, List.of(InterviewTopic.ALGORITHM));
            List<InterviewQuestionPoolDto> pool = 문제_풀(Map.of(InterviewTopic.ALGORITHM, 20));

            // when
            Set<List<Long>> results = new HashSet<>();
            for (int attempt = 0; attempt < SHUFFLE_ATTEMPTS; attempt++) {
                results.add(interviewQuestionAllocationPolicy.select(InterviewMode.COMMON_CS, topicToQuota, pool));
            }

            // then
            assertThat(results).hasSizeGreaterThan(1);
        }
    }

    @Nested
    @DisplayName("문항 순서를 정할 때")
    class Order {

        @Test
        void 공통CS는_순서가_고정되지_않는다() {
            // given
            Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.COMMON_CS, null, CS_TOPICS);
            List<InterviewQuestionPoolDto> pool = 문제_풀(몫이_같은_풀_크기(topicToQuota));

            // when
            Set<List<Long>> orders = new HashSet<>();
            for (int attempt = 0; attempt < ORDER_ATTEMPTS; attempt++) {
                orders.add(interviewQuestionAllocationPolicy.select(InterviewMode.COMMON_CS, topicToQuota, pool));
            }

            // then
            assertSoftly(softly -> {
                softly.assertThat(orders).hasSizeGreaterThan(1);
                softly.assertThat(orders).allSatisfy(order ->
                        assertThat(order).hasSize(QUESTION_COUNT).doesNotHaveDuplicates());
            });
        }

        @Test
        void 직군은_항상_공통_언어_프레임워크_순이다() {
            // given
            Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
                    InterviewMode.JOB_SPECIFIC, InterviewStack.JAVA_SPRING_BOOT, null);
            List<InterviewQuestionPoolDto> pool = List.of(
                    new InterviewQuestionPoolDto(InterviewTopic.SPRING_BOOT, 301L),
                    new InterviewQuestionPoolDto(InterviewTopic.SPRING_BOOT, 302L),
                    new InterviewQuestionPoolDto(InterviewTopic.JAVA, 201L),
                    new InterviewQuestionPoolDto(InterviewTopic.JAVA, 202L),
                    new InterviewQuestionPoolDto(InterviewTopic.SERVER_COMMON, 101L)
            );

            // when & then
            for (int attempt = 0; attempt < ORDER_ATTEMPTS; attempt++) {
                List<Long> orderedQuestionIds =
                        interviewQuestionAllocationPolicy.select(InterviewMode.JOB_SPECIFIC, topicToQuota, pool);

                assertSoftly(softly -> {
                    softly.assertThat(orderedQuestionIds).hasSize(QUESTION_COUNT);
                    softly.assertThat(orderedQuestionIds.get(0)).isEqualTo(101L);
                    softly.assertThat(orderedQuestionIds.subList(1, 3)).containsExactlyInAnyOrder(201L, 202L);
                    softly.assertThat(orderedQuestionIds.subList(3, 5)).containsExactlyInAnyOrder(301L, 302L);
                });
            }
        }
    }
}
