package gravit.code.interview.facade;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewAnswerStatus;
import gravit.code.interview.dto.request.InterviewAnswerSubmitRequest;
import gravit.code.interview.dto.response.InterviewAnswerSubmitResponse;
import gravit.code.interview.dto.response.InterviewSessionCreateResponse;
import gravit.code.interview.dto.response.InterviewSessionQuestionResponse;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.repository.InterviewCategoryRepository;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import gravit.code.interviewTechStack.domain.InterviewAxis;
import gravit.code.interviewTechStack.domain.InterviewJobRole;
import gravit.code.interviewTechStack.repository.InterviewStackAxisRepository;
import gravit.code.interviewTechStack.repository.InterviewTechStackRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_QUESTION_POOL_INSUFFICIENT;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ALREADY_IN_PROGRESS;
import static gravit.code.interview.fixture.InterviewSessionFixture.공통CS_생성요청;
import static gravit.code.interview.fixture.InterviewSessionFixture.공통CS_진행중_세션;
import static gravit.code.interview.fixture.InterviewSessionFixture.직무별_생성요청;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.공통CS_카테고리;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.난이도별_질문;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.직무별_카테고리;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.질문_여러개;
import static gravit.code.interviewTechStack.fixture.InterviewTechStackFixture.기술스택;
import static gravit.code.interviewTechStack.fixture.InterviewTechStackFixture.축_매핑;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewSessionFacadeIntegrationTest {

    private static final long USER_ID = 1L;
    private static final int QUESTION_COUNT = 5;
    private static final int FIRST_ORDER = 1;
    private static final String ANSWER_CONTENT = "인덱스는 조회 성능을 높이기 위한 자료구조입니다.";

    @Autowired
    private InterviewSessionFacade interviewSessionFacade;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Autowired
    private InterviewCategoryRepository interviewCategoryRepository;

    @Autowired
    private InterviewQuestionRepository interviewQuestionRepository;

    @Autowired
    private InterviewTechStackRepository interviewTechStackRepository;

    @Autowired
    private InterviewStackAxisRepository interviewStackAxisRepository;

    @Nested
    @DisplayName("공통 CS 세션을 만들 때")
    class CreateCommonCsSession {

        @Test
        void 세션과_답변_다섯_행을_함께_저장한다() {
            // given
            공통CS_질문을_채운다();

            // when
            InterviewSessionCreateResponse response = interviewSessionFacade.createSession(USER_ID, 공통CS_생성요청());

            // then
            List<InterviewAnswer> answers = interviewAnswerRepository.findAll();

            assertSoftly(softly -> {
                softly.assertThat(interviewSessionRepository.count()).isEqualTo(1);
                softly.assertThat(answers).hasSize(QUESTION_COUNT);
                softly.assertThat(answers)
                        .extracting(InterviewAnswer::getSessionId)
                        .containsOnly(response.sessionId());
                softly.assertThat(answers)
                        .extracting(InterviewAnswer::getStatus)
                        .containsOnly(InterviewAnswerStatus.PENDING);
            });
        }

        @Test
        void 응답의_출제_순서는_1부터_5까지다() {
            // given
            공통CS_질문을_채운다();

            // when
            InterviewSessionCreateResponse response = interviewSessionFacade.createSession(USER_ID, 공통CS_생성요청());

            // then
            assertThat(response.questions())
                    .extracting(InterviewSessionQuestionResponse::displayOrder)
                    .containsExactly(1, 2, 3, 4, 5);
        }

        @Test
        void 응답의_답변_아이디와_출제_순서가_저장된_행과_일치한다() {
            // given
            공통CS_질문을_채운다();

            // when
            InterviewSessionCreateResponse response = interviewSessionFacade.createSession(USER_ID, 공통CS_생성요청());

            // then
            assertSoftly(softly -> response.questions().forEach(question -> {
                InterviewAnswer saved = interviewAnswerRepository.findById(question.answerId()).orElseThrow();
                softly.assertThat(saved.getDisplayOrder()).isEqualTo(question.displayOrder());
            }));
        }

        @Test
        void 진행_중인_세션이_있으면_예외를_던진다() {
            // given
            공통CS_질문을_채운다();
            interviewSessionRepository.save(공통CS_진행중_세션(USER_ID));

            // when & then
            assertThatThrownBy(() -> interviewSessionFacade.createSession(USER_ID, 공통CS_생성요청()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ALREADY_IN_PROGRESS);
        }

        @Test
        void 질문_풀이_모자라면_세션도_답변도_저장하지_않는다() {
            // given
            long categoryId = interviewCategoryRepository.save(공통CS_카테고리("운영체제")).getId();
            interviewQuestionRepository.saveAll(질문_여러개(categoryId, InterviewDifficulty.MEDIUM, 3));

            // when & then
            assertThatThrownBy(() -> interviewSessionFacade.createSession(USER_ID, 공통CS_생성요청()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_QUESTION_POOL_INSUFFICIENT);

            assertSoftly(softly -> {
                softly.assertThat(interviewSessionRepository.count()).isEqualTo(0);
                softly.assertThat(interviewAnswerRepository.count()).isEqualTo(0);
            });
        }
    }

    @Nested
    @DisplayName("직무별 세션을 만들 때")
    class CreateJobSpecificSession {

        @Test
        void 기술_스택의_축에_묶인_카테고리에서_질문을_뽑는다() {
            // given
            long techStackId = 축별_질문을_갖춘_기술스택을_만든다();

            // when
            InterviewSessionCreateResponse response =
                    interviewSessionFacade.createSession(USER_ID, 직무별_생성요청(techStackId));

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.questions()).hasSize(QUESTION_COUNT);
                softly.assertThat(interviewAnswerRepository.count()).isEqualTo(QUESTION_COUNT);
            });
        }
    }

    @Nested
    @DisplayName("답변을 제출할 때")
    class SubmitAnswer {

        @Test
        void 생성된_세션의_첫_문항에_답변할_수_있다() {
            // given
            공통CS_질문을_채운다();
            InterviewSessionCreateResponse session = interviewSessionFacade.createSession(USER_ID, 공통CS_생성요청());

            // when
            InterviewAnswerSubmitResponse response = interviewSessionFacade.submitAnswer(
                    USER_ID,
                    session.sessionId(),
                    FIRST_ORDER,
                    new InterviewAnswerSubmitRequest(ANSWER_CONTENT)
            );

            // then
            InterviewAnswer saved = interviewAnswerRepository.findById(response.answerId()).orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(response.status()).isEqualTo(InterviewAnswerStatus.ANSWERED);
                softly.assertThat(saved.getContent()).isEqualTo(ANSWER_CONTENT);
                softly.assertThat(saved.getDisplayOrder()).isEqualTo(FIRST_ORDER);
            });
        }
    }

    private void 공통CS_질문을_채운다() {
        long categoryId = interviewCategoryRepository.save(공통CS_카테고리("운영체제")).getId();
        interviewQuestionRepository.saveAll(난이도별_질문(categoryId, 5));
    }

    private long 축별_질문을_갖춘_기술스택을_만든다() {
        long techStackId = interviewTechStackRepository
                .save(기술스택(InterviewJobRole.BACKEND, "SPRING", "Spring", 1))
                .getId();

        for (InterviewAxis axis : InterviewAxis.values()) {
            long categoryId = interviewCategoryRepository
                    .save(직무별_카테고리("스프링 " + axis, axis))
                    .getId();

            interviewStackAxisRepository.save(축_매핑(techStackId, axis, categoryId));
            interviewQuestionRepository.saveAll(난이도별_질문(categoryId, 2));
        }

        return techStackId;
    }
}
