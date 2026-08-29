package gravit.code.interview.domain;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interviewFeedback.domain.InterviewAnswerConceptResult;
import gravit.code.interviewFeedback.domain.InterviewAnswerWrongConcept;
import gravit.code.interviewFeedback.domain.InterviewFeedback;
import gravit.code.interviewQuestion.domain.InterviewCategory;
import gravit.code.interviewQuestion.domain.InterviewConceptType;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;
import gravit.code.interviewTechStack.domain.InterviewAxis;
import gravit.code.interviewTechStack.domain.InterviewJobRole;
import gravit.code.interviewTechStack.domain.InterviewStackAxis;
import gravit.code.interviewTechStack.domain.InterviewTechStack;
import gravit.code.support.TCSpringBootTest;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.support.TransactionTemplate;

import java.math.BigDecimal;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_CATEGORY_AXIS_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_SCORE_INVALID;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewEntityMappingIntegrationTest {

    private static final int EXPECTED_ACCURACY_MAX_SCORE = 70;
    private static final int EXPECTED_COHERENCE_MAX_SCORE = 30;

    private static final long USER_ID = 1L;
    private static final long UNIT_ID = 1L;
    private static final long CATEGORY_ID = 1L;
    private static final long QUESTION_ID = 1L;
    private static final long SESSION_ID = 1L;
    private static final long ANSWER_ID = 1L;
    private static final long CONCEPT_ID = 1L;
    private static final long TECH_STACK_ID = 1L;
    private static final int FIRST_ORDER = 1;
    private static final String AUDIO_KEY = "interview/session-1/answer-1.m4a";

    @PersistenceContext
    private EntityManager em;

    @Autowired
    private TransactionTemplate transactionTemplate;

    @Nested
    @DisplayName("카테고리를 만들 때")
    class CreateCategory {

        @Test
        void 공통_CS_카테고리는_축_없이_만들어진다() {
            // given & when
            InterviewCategory category = InterviewCategory.create(InterviewMode.COMMON_CS, "네트워크", null);

            // then
            assertThat(category.getAxis()).isNull();
        }

        @Test
        void 직무별_카테고리는_축과_함께_만들어진다() {
            // given & when
            InterviewCategory category = InterviewCategory.create(
                    InterviewMode.JOB_SPECIFIC, "Spring", InterviewAxis.FRAMEWORK);

            // then
            assertThat(category.getAxis()).isEqualTo(InterviewAxis.FRAMEWORK);
        }

        @Test
        void 공통_CS_카테고리에_축을_주면_예외가_발생한다() {
            // given & when & then
            assertThatThrownBy(() ->
                    InterviewCategory.create(InterviewMode.COMMON_CS, "네트워크", InterviewAxis.COMMON))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_CATEGORY_AXIS_INVALID);
        }

        @Test
        void 직무별_카테고리에_축이_없으면_예외가_발생한다() {
            // given & when & then
            assertThatThrownBy(() ->
                    InterviewCategory.create(InterviewMode.JOB_SPECIFIC, "Spring", null))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_CATEGORY_AXIS_INVALID);
        }
    }

    @Nested
    @DisplayName("세션을 생성할 때")
    class CreateSession {

        @Test
        void 세션을_생성하면_진행중_상태와_만점이_채워진다() {
            // given & when
            InterviewSession session = InterviewSession.create(
                    USER_ID,
                    InterviewMode.JOB_SPECIFIC,
                    InterviewInputType.TEXT,
                    TECH_STACK_ID,
                    InterviewLevel.HIGH
            );

            // then
            assertSoftly(softly -> {
                softly.assertThat(session.getStatus()).isEqualTo(InterviewSessionStatus.IN_PROGRESS);
                softly.assertThat(session.getAccuracyMaxScore()).isEqualTo(EXPECTED_ACCURACY_MAX_SCORE);
                softly.assertThat(session.getCoherenceMaxScore()).isEqualTo(EXPECTED_COHERENCE_MAX_SCORE);
                softly.assertThat(session.getAccuracyScore()).isZero();
                softly.assertThat(session.getCoherenceScore()).isZero();
                softly.assertThat(session.getGradedAnswerCount()).isZero();
                softly.assertThat(session.getStartedAt()).isNotNull();
                softly.assertThat(session.getEndedAt()).isNull();
            });
        }
    }

    @Nested
    @DisplayName("세션을 완료할 때")
    class CompleteSession {

        @Test
        void 만점_이하의_점수는_그대로_기록된다() {
            // given
            InterviewSession session = 진행중_세션();

            // when
            session.complete(EXPECTED_ACCURACY_MAX_SCORE, EXPECTED_COHERENCE_MAX_SCORE);

            // then
            assertSoftly(softly -> {
                softly.assertThat(session.getStatus()).isEqualTo(InterviewSessionStatus.COMPLETED);
                softly.assertThat(session.getAccuracyScore()).isEqualTo(EXPECTED_ACCURACY_MAX_SCORE);
                softly.assertThat(session.getCoherenceScore()).isEqualTo(EXPECTED_COHERENCE_MAX_SCORE);
                softly.assertThat(session.getEndedAt()).isNotNull();
            });
        }

        @Test
        void 만점을_넘는_점수는_예외가_발생한다() {
            // given
            InterviewSession session = 진행중_세션();

            // when & then
            assertThatThrownBy(() -> session.complete(EXPECTED_ACCURACY_MAX_SCORE + 1, EXPECTED_COHERENCE_MAX_SCORE))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_SCORE_INVALID);
        }

        @Test
        void 음수_점수는_예외가_발생한다() {
            // given
            InterviewSession session = 진행중_세션();

            // when & then
            assertThatThrownBy(() -> session.complete(EXPECTED_ACCURACY_MAX_SCORE, -1))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_SCORE_INVALID);
        }

        private InterviewSession 진행중_세션() {
            return InterviewSession.create(
                    USER_ID,
                    InterviewMode.COMMON_CS,
                    InterviewInputType.TEXT,
                    null,
                    InterviewLevel.MEDIUM
            );
        }
    }

    @Nested
    @DisplayName("답변을 제출할 때")
    class SubmitAnswer {

        @Test
        void 답변이_비어있으면_무응답으로_기록된다() {
            // given
            InterviewAnswer answer = InterviewAnswer.createPending(SESSION_ID, QUESTION_ID, FIRST_ORDER);

            // when
            answer.submit("   ", null);

            // then
            assertThat(answer.getStatus()).isEqualTo(InterviewAnswerStatus.NO_RESPONSE);
        }

        @Test
        void 음성_답변의_변환_결과가_비어있으면_음성_파일을_남기고_무응답으로_기록된다() {
            // given
            InterviewAnswer answer = InterviewAnswer.createPending(SESSION_ID, QUESTION_ID, FIRST_ORDER);

            // when
            answer.submit(null, AUDIO_KEY);

            // then
            assertSoftly(softly -> {
                softly.assertThat(answer.getStatus()).isEqualTo(InterviewAnswerStatus.NO_RESPONSE);
                softly.assertThat(answer.getAudioKey()).isEqualTo(AUDIO_KEY);
            });
        }

        @Test
        void 음성_답변의_변환_결과가_있으면_응답으로_기록된다() {
            // given
            InterviewAnswer answer = InterviewAnswer.createPending(SESSION_ID, QUESTION_ID, FIRST_ORDER);

            // when
            answer.submit("TCP는 연결 지향 프로토콜입니다", AUDIO_KEY);

            // then
            assertSoftly(softly -> {
                softly.assertThat(answer.getStatus()).isEqualTo(InterviewAnswerStatus.ANSWERED);
                softly.assertThat(answer.getAudioKey()).isEqualTo(AUDIO_KEY);
            });
        }

        @Test
        void 답변에_내용이_있으면_응답으로_기록된다() {
            // given
            InterviewAnswer answer = InterviewAnswer.createPending(SESSION_ID, QUESTION_ID, FIRST_ORDER);

            // when
            answer.submit("TCP는 연결 지향 프로토콜입니다", null);

            // then
            assertSoftly(softly -> {
                softly.assertThat(answer.getStatus()).isEqualTo(InterviewAnswerStatus.ANSWERED);
                softly.assertThat(answer.getAnsweredAt()).isNotNull();
            });
        }
    }

    @Nested
    @DisplayName("채점 결과를 만들 때")
    class CreateGradingResult {

        @Test
        void 무응답_피드백은_모든_점수가_0이다() {
            // given & when
            InterviewFeedback feedback = InterviewFeedback.createNoResponse(ANSWER_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(feedback.getAccuracyScore()).isZero();
                softly.assertThat(feedback.getStructureScore()).isZero();
                softly.assertThat(feedback.getClarityScore()).isZero();
                softly.assertThat(feedback.getIrrelevantStatementCount()).isZero();
                softly.assertThat(feedback.getAccuracyMultiplier()).isEqualByComparingTo(BigDecimal.ONE);
                softly.assertThat(feedback.getImprovementSuggestion()).isNull();
            });
        }

        @Test
        void 개념_판정은_전달과_누락이_서로_다른_필드를_채운다() {
            // given & when
            InterviewAnswerConceptResult covered =
                    InterviewAnswerConceptResult.covered(ANSWER_ID, CONCEPT_ID, "3-way handshake로 연결을 맺습니다");
            InterviewAnswerConceptResult missing =
                    InterviewAnswerConceptResult.missing(ANSWER_ID, CONCEPT_ID, "흐름 제어를 함께 설명해보세요");

            // then
            assertSoftly(softly -> {
                softly.assertThat(covered.isCovered()).isTrue();
                softly.assertThat(covered.getQuote()).isNotNull();
                softly.assertThat(covered.getMissingFeedbackText()).isNull();

                softly.assertThat(missing.isCovered()).isFalse();
                softly.assertThat(missing.getQuote()).isNull();
                softly.assertThat(missing.getMissingFeedbackText()).isNotNull();
            });
        }
    }

    @Nested
    @DisplayName("엔티티를 저장할 때")
    class PersistEntity {

        @Test
        void 엔티티_10종이_저장되고_조회된다() {
            // given
            InterviewCategory category = InterviewCategory.create(
                    InterviewMode.JOB_SPECIFIC, "Spring", InterviewAxis.FRAMEWORK);
            InterviewTechStack techStack = InterviewTechStack.create(
                    InterviewJobRole.BACKEND, "SPRING_BOOT", "Java + Spring Boot", 1);
            InterviewStackAxis stackAxis = InterviewStackAxis.create(
                    TECH_STACK_ID, InterviewAxis.FRAMEWORK, CATEGORY_ID);
            InterviewQuestion question = InterviewQuestion.create(
                    CATEGORY_ID, UNIT_ID, "TCP와 UDP의 차이를 설명하세요", InterviewDifficulty.MEDIUM);
            InterviewQuestionConcept concept = InterviewQuestionConcept.create(
                    QUESTION_ID, "TCP가 연결 지향이고 UDP가 비연결 지향임을 언급", InterviewConceptType.ESSENTIAL);
            InterviewSession session = InterviewSession.create(
                    USER_ID,
                    InterviewMode.COMMON_CS,
                    InterviewInputType.VOICE,
                    null,
                    InterviewLevel.LOW
            );
            InterviewAnswer answer = InterviewAnswer.createPending(SESSION_ID, QUESTION_ID, FIRST_ORDER);
            InterviewFeedback feedback = InterviewFeedback.create(
                    ANSWER_ID, 12, 3, 2, 1, new BigDecimal("0.5"), "결론을 먼저 말해보세요");
            InterviewAnswerConceptResult conceptResult = InterviewAnswerConceptResult.covered(
                    ANSWER_ID, CONCEPT_ID, "연결 지향입니다");
            InterviewAnswerWrongConcept wrongConcept = InterviewAnswerWrongConcept.create(
                    ANSWER_ID, "UDP가 재전송을 보장합니다", "UDP는 재전송을 보장하지 않습니다");

            // when
            transactionTemplate.executeWithoutResult(status -> {
                em.persist(category);
                em.persist(techStack);
                em.persist(stackAxis);
                em.persist(question);
                em.persist(concept);
                em.persist(session);
                em.persist(answer);
                em.persist(feedback);
                em.persist(conceptResult);
                em.persist(wrongConcept);
                em.flush();
                em.clear();
            });

            // then
            transactionTemplate.executeWithoutResult(status -> assertSoftly(softly -> {
                InterviewCategory foundCategory = em.find(InterviewCategory.class, category.getId());
                softly.assertThat(foundCategory.getMode()).isEqualTo(InterviewMode.JOB_SPECIFIC);
                softly.assertThat(foundCategory.getAxis()).isEqualTo(InterviewAxis.FRAMEWORK);

                InterviewTechStack foundTechStack = em.find(InterviewTechStack.class, techStack.getId());
                softly.assertThat(foundTechStack.getCode()).isEqualTo("SPRING_BOOT");
                softly.assertThat(foundTechStack.getJobRole()).isEqualTo(InterviewJobRole.BACKEND);

                InterviewStackAxis foundStackAxis = em.find(InterviewStackAxis.class, stackAxis.getId());
                softly.assertThat(foundStackAxis.getCategoryId()).isEqualTo(CATEGORY_ID);

                InterviewQuestion foundQuestion = em.find(InterviewQuestion.class, question.getId());
                softly.assertThat(foundQuestion.getDifficulty()).isEqualTo(InterviewDifficulty.MEDIUM);
                softly.assertThat(foundQuestion.getUnitId()).isEqualTo(UNIT_ID);

                InterviewQuestionConcept foundConcept = em.find(InterviewQuestionConcept.class, concept.getId());
                softly.assertThat(foundConcept.getType()).isEqualTo(InterviewConceptType.ESSENTIAL);

                InterviewSession foundSession = em.find(InterviewSession.class, session.getId());
                softly.assertThat(foundSession.getStatus()).isEqualTo(InterviewSessionStatus.IN_PROGRESS);
                softly.assertThat(foundSession.getInputType()).isEqualTo(InterviewInputType.VOICE);
                softly.assertThat(foundSession.getTechStackId()).isNull();
                softly.assertThat(foundSession.getAccuracyMaxScore()).isEqualTo(EXPECTED_ACCURACY_MAX_SCORE);

                InterviewAnswer foundAnswer = em.find(InterviewAnswer.class, answer.getId());
                softly.assertThat(foundAnswer.getStatus()).isEqualTo(InterviewAnswerStatus.PENDING);
                softly.assertThat(foundAnswer.getDisplayOrder()).isEqualTo(FIRST_ORDER);
                softly.assertThat(foundAnswer.getContent()).isNull();

                InterviewFeedback foundFeedback = em.find(InterviewFeedback.class, feedback.getId());
                softly.assertThat(foundFeedback.getAccuracyMultiplier()).isEqualByComparingTo(new BigDecimal("0.5"));
                softly.assertThat(foundFeedback.getStructureScore()).isEqualTo(3);

                InterviewAnswerConceptResult foundConceptResult =
                        em.find(InterviewAnswerConceptResult.class, conceptResult.getId());
                softly.assertThat(foundConceptResult.isCovered()).isTrue();

                InterviewAnswerWrongConcept foundWrongConcept =
                        em.find(InterviewAnswerWrongConcept.class, wrongConcept.getId());
                softly.assertThat(foundWrongConcept.getCorrectionText()).isEqualTo("UDP는 재전송을 보장하지 않습니다");
            }));
        }
    }
}
