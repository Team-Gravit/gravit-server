package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewAnswerStatus;
import gravit.code.interview.dto.response.InterviewAnswerSubmitResponse;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_ANSWER_NOT_FOUND;
import static gravit.code.interview.fixture.InterviewSessionFixture.대기_답변;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewAnswerCommandServiceIntegrationTest {

    private static final long SESSION_ID = 1L;
    private static final int FIRST_ORDER = 1;
    private static final int NOT_EXIST_ORDER = 99;
    private static final String ANSWER_CONTENT = "인덱스는 조회 성능을 높이기 위한 자료구조입니다.";

    @Autowired
    private InterviewAnswerCommandService interviewAnswerCommandService;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Nested
    @DisplayName("답변 행을 미리 만들 때")
    class CreatePendingAnswers {

        @Test
        void 질문_순서대로_대기_상태의_답변을_만든다() {
            // given
            List<Long> questionIds = List.of(11L, 22L, 33L, 44L, 55L);

            // when
            List<Long> answerIds = interviewAnswerCommandService.createPendingAnswers(SESSION_ID, questionIds);

            // then
            List<InterviewAnswer> answers = interviewAnswerRepository.findAllById(answerIds);

            assertSoftly(softly -> {
                softly.assertThat(answerIds).hasSize(questionIds.size());
                softly.assertThat(answers)
                        .extracting(InterviewAnswer::getStatus)
                        .containsOnly(InterviewAnswerStatus.PENDING);
                softly.assertThat(answers)
                        .extracting(InterviewAnswer::getDisplayOrder)
                        .containsExactlyInAnyOrder(1, 2, 3, 4, 5);
            });
        }

        @Test
        void 반환한_답변_아이디는_질문_순서와_같다() {
            // given
            List<Long> questionIds = List.of(11L, 22L, 33L);

            // when
            List<Long> answerIds = interviewAnswerCommandService.createPendingAnswers(SESSION_ID, questionIds);

            // then
            List<Long> questionIdsInOrder = answerIds.stream()
                    .map(answerId -> interviewAnswerRepository.findById(answerId).orElseThrow().getQuestionId())
                    .toList();

            assertThat(questionIdsInOrder).isEqualTo(questionIds);
        }
    }

    @Nested
    @DisplayName("답변을 제출할 때")
    class Submit {

        @Test
        void 본문이_있으면_응답_완료로_기록한다() {
            // given
            interviewAnswerRepository.save(대기_답변(SESSION_ID, 11L, FIRST_ORDER));

            // when
            InterviewAnswerSubmitResponse response =
                    interviewAnswerCommandService.submit(SESSION_ID, FIRST_ORDER, ANSWER_CONTENT);

            // then
            InterviewAnswer saved = interviewAnswerRepository.findById(response.answerId()).orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(response.status()).isEqualTo(InterviewAnswerStatus.ANSWERED);
                softly.assertThat(saved.getContent()).isEqualTo(ANSWER_CONTENT);
                softly.assertThat(saved.getAnsweredAt()).isNotNull();
            });
        }

        @Test
        void 본문이_비어_있으면_무응답으로_기록한다() {
            // given
            interviewAnswerRepository.save(대기_답변(SESSION_ID, 11L, FIRST_ORDER));

            // when
            InterviewAnswerSubmitResponse response =
                    interviewAnswerCommandService.submit(SESSION_ID, FIRST_ORDER, "   ");

            // then
            assertThat(response.status()).isEqualTo(InterviewAnswerStatus.NO_RESPONSE);
        }

        @Test
        void 본문이_null이면_무응답으로_기록한다() {
            // given
            interviewAnswerRepository.save(대기_답변(SESSION_ID, 11L, FIRST_ORDER));

            // when
            InterviewAnswerSubmitResponse response =
                    interviewAnswerCommandService.submit(SESSION_ID, FIRST_ORDER, null);

            // then
            assertThat(response.status()).isEqualTo(InterviewAnswerStatus.NO_RESPONSE);
        }

        @Test
        void 다시_제출하면_덮어쓴다() {
            // given
            interviewAnswerRepository.save(대기_답변(SESSION_ID, 11L, FIRST_ORDER));
            interviewAnswerCommandService.submit(SESSION_ID, FIRST_ORDER, "첫 번째 답변입니다.");

            // when
            InterviewAnswerSubmitResponse response =
                    interviewAnswerCommandService.submit(SESSION_ID, FIRST_ORDER, ANSWER_CONTENT);

            // then
            InterviewAnswer saved = interviewAnswerRepository.findById(response.answerId()).orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(saved.getContent()).isEqualTo(ANSWER_CONTENT);
                softly.assertThat(interviewAnswerRepository.count()).isEqualTo(1);
            });
        }

        @Test
        void 존재하지_않는_출제_순서면_예외를_던진다() {
            // given
            interviewAnswerRepository.save(대기_답변(SESSION_ID, 11L, FIRST_ORDER));

            // when & then
            assertThatThrownBy(() -> interviewAnswerCommandService.submit(SESSION_ID, NOT_EXIST_ORDER, ANSWER_CONTENT))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_ANSWER_NOT_FOUND);
        }
    }
}
