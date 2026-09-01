package gravit.code.interviewTechStack.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interviewTechStack.domain.InterviewAxis;
import gravit.code.interviewTechStack.domain.InterviewJobRole;
import gravit.code.interviewTechStack.dto.response.InterviewTechStackResponse;
import gravit.code.interviewTechStack.repository.InterviewStackAxisRepository;
import gravit.code.interviewTechStack.repository.InterviewTechStackRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_TECH_STACK_NOT_FOUND;
import static gravit.code.interviewTechStack.fixture.InterviewTechStackFixture.기술스택;
import static gravit.code.interviewTechStack.fixture.InterviewTechStackFixture.축_매핑;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
class InterviewTechStackQueryServiceIntegrationTest {

    private static final long NOT_EXIST_TECH_STACK_ID = 999L;
    private static final long COMMON_CATEGORY_ID = 10L;
    private static final long FRAMEWORK_CATEGORY_ID = 20L;

    @Autowired
    private InterviewTechStackQueryService interviewTechStackQueryService;

    @Autowired
    private InterviewTechStackRepository interviewTechStackRepository;

    @Autowired
    private InterviewStackAxisRepository interviewStackAxisRepository;

    @Nested
    @DisplayName("직무별 기술 스택 목록을 조회할 때")
    class GetTechStacks {

        @Test
        void 노출_순서대로_반환한다() {
            // given
            interviewTechStackRepository.save(기술스택(InterviewJobRole.BACKEND, "SPRING", "Spring", 2));
            interviewTechStackRepository.save(기술스택(InterviewJobRole.BACKEND, "NODE", "Node.js", 1));

            // when
            List<InterviewTechStackResponse> responses =
                    interviewTechStackQueryService.getTechStacks(InterviewJobRole.BACKEND);

            // then
            assertThat(responses)
                    .extracting(InterviewTechStackResponse::code)
                    .containsExactly("NODE", "SPRING");
        }

        @Test
        void 다른_직무의_스택은_나오지_않는다() {
            // given
            interviewTechStackRepository.save(기술스택(InterviewJobRole.BACKEND, "SPRING", "Spring", 1));
            interviewTechStackRepository.save(기술스택(InterviewJobRole.ANDROID, "KOTLIN", "Kotlin", 1));

            // when
            List<InterviewTechStackResponse> responses =
                    interviewTechStackQueryService.getTechStacks(InterviewJobRole.ANDROID);

            // then
            assertThat(responses)
                    .extracting(InterviewTechStackResponse::code)
                    .containsExactly("KOTLIN");
        }

        @Test
        void 해당_직무의_스택이_없으면_빈_목록을_반환한다() {
            // given
            interviewTechStackRepository.save(기술스택(InterviewJobRole.BACKEND, "SPRING", "Spring", 1));

            // when
            List<InterviewTechStackResponse> responses =
                    interviewTechStackQueryService.getTechStacks(InterviewJobRole.IOS);

            // then
            assertThat(responses).isEmpty();
        }
    }

    @Nested
    @DisplayName("기술 스택의 카테고리를 조회할 때")
    class GetCategoryIds {

        @Test
        void 축에_매핑된_카테고리를_모두_반환한다() {
            // given
            long techStackId = interviewTechStackRepository
                    .save(기술스택(InterviewJobRole.BACKEND, "SPRING", "Spring", 1))
                    .getId();
            interviewStackAxisRepository.save(축_매핑(techStackId, InterviewAxis.COMMON, COMMON_CATEGORY_ID));
            interviewStackAxisRepository.save(축_매핑(techStackId, InterviewAxis.FRAMEWORK, FRAMEWORK_CATEGORY_ID));

            // when
            List<Long> categoryIds = interviewTechStackQueryService.getCategoryIdsByTechStack(techStackId);

            // then
            assertThat(categoryIds).containsExactlyInAnyOrder(COMMON_CATEGORY_ID, FRAMEWORK_CATEGORY_ID);
        }

        @Test
        void 축_매핑이_없으면_빈_목록을_반환한다() {
            // given
            long techStackId = interviewTechStackRepository
                    .save(기술스택(InterviewJobRole.BACKEND, "SPRING", "Spring", 1))
                    .getId();

            // when
            List<Long> categoryIds = interviewTechStackQueryService.getCategoryIdsByTechStack(techStackId);

            // then
            assertThat(categoryIds).isEmpty();
        }

        @Test
        void 존재하지_않는_스택이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewTechStackQueryService.getCategoryIdsByTechStack(NOT_EXIST_TECH_STACK_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_TECH_STACK_NOT_FOUND);
        }
    }
}
