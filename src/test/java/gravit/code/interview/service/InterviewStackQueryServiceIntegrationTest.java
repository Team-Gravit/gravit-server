package gravit.code.interview.service;

import gravit.code.interview.domain.InterviewStack;
import gravit.code.interview.domain.InterviewStackGroup;
import gravit.code.interview.dto.response.InterviewStackGroupResponse;
import gravit.code.interview.dto.response.InterviewStackResponse;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Comparator;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewStackQueryServiceIntegrationTest {

    private static final int STACK_GROUP_COUNT = 4;
    private static final int SERVER_STACK_COUNT = 4;
    private static final int IOS_STACK_COUNT = 1;

    @Autowired
    private InterviewStackQueryService interviewStackQueryService;

    @Nested
    @DisplayName("직군 그룹을 조회할 때")
    class GetStackGroups {

        @Test
        void 노출_순서_오름차순으로_돌려준다() {
            // when
            List<InterviewStackGroupResponse> stackGroups = interviewStackQueryService.getStackGroups();

            // then
            assertSoftly(softly -> {
                softly.assertThat(stackGroups).hasSize(STACK_GROUP_COUNT);
                softly.assertThat(stackGroups.stream().map(InterviewStackGroupResponse::stackGroup))
                        .containsExactly(
                                InterviewStackGroup.SERVER,
                                InterviewStackGroup.WEB,
                                InterviewStackGroup.AOS,
                                InterviewStackGroup.IOS
                        );
                softly.assertThat(stackGroups.get(3).displayName()).isEqualTo("iOS");
            });
        }
    }

    @Nested
    @DisplayName("그룹별 스택을 조회할 때")
    class GetStacks {

        @Test
        void SERVER_그룹은_노출_순서대로_4건을_돌려준다() {
            // when
            List<InterviewStackResponse> stacks = interviewStackQueryService.getStacks(InterviewStackGroup.SERVER);

            // then
            assertSoftly(softly -> {
                softly.assertThat(stacks).hasSize(SERVER_STACK_COUNT);
                softly.assertThat(stacks.stream().map(InterviewStackResponse::stack)).containsExactly(
                        InterviewStack.JAVA_SPRING_BOOT,
                        InterviewStack.KOTLIN_SPRING_BOOT,
                        InterviewStack.NODE_NEST,
                        InterviewStack.PYTHON_DJANGO
                );
                softly.assertThat(stacks.get(0).displayName()).isEqualTo("Java + Spring Boot");
            });
        }

        @Test
        void IOS_그룹은_1건을_돌려준다() {
            // when
            List<InterviewStackResponse> stacks = interviewStackQueryService.getStacks(InterviewStackGroup.IOS);

            // then
            assertSoftly(softly -> {
                softly.assertThat(stacks).hasSize(IOS_STACK_COUNT);
                softly.assertThat(stacks.get(0).stack()).isEqualTo(InterviewStack.SWIFT_SWIFTUI);
            });
        }

        @ParameterizedTest
        @EnumSource(InterviewStackGroup.class)
        void 모든_그룹에서_해당_그룹의_스택만_노출_순서대로_나온다(InterviewStackGroup stackGroup) {
            // when
            List<InterviewStackResponse> stacks = interviewStackQueryService.getStacks(stackGroup);

            // then
            assertSoftly(softly -> {
                softly.assertThat(stacks).isNotEmpty();
                softly.assertThat(stacks).allSatisfy(stack ->
                        assertThat(stack.stack().getGroup()).isEqualTo(stackGroup));
                softly.assertThat(stacks.stream().map(stack -> stack.stack().getDisplayOrder()))
                        .isSortedAccordingTo(Comparator.naturalOrder());
            });
        }
    }
}
