package gravit.code.interview.domain;

import gravit.code.interview.domain.enums.InterviewAnswerStatus;
import gravit.code.interview.domain.enums.InterviewAxis;
import gravit.code.interview.domain.enums.InterviewConceptType;
import gravit.code.interview.domain.enums.InterviewDifficulty;
import gravit.code.interview.domain.enums.InterviewInputType;
import gravit.code.interview.domain.enums.InterviewJobRole;
import gravit.code.interview.domain.enums.InterviewLevel;
import gravit.code.interview.domain.enums.InterviewMode;
import gravit.code.interview.domain.enums.InterviewSessionStatus;
import gravit.code.interview.domain.grading.InterviewAnswerConceptResult;
import gravit.code.interview.domain.grading.InterviewAnswerWrongConcept;
import gravit.code.interview.domain.grading.InterviewFeedback;
import gravit.code.interview.domain.master.InterviewCategory;
import gravit.code.interview.domain.master.InterviewQuestion;
import gravit.code.interview.domain.master.InterviewQuestionConcept;
import gravit.code.interview.domain.master.InterviewStackAxis;
import gravit.code.interview.domain.master.InterviewTechStack;
import gravit.code.interview.domain.session.InterviewAnswer;
import gravit.code.interview.domain.session.InterviewSession;
import gravit.code.support.TCSpringBootTest;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.support.TransactionTemplate;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewEntityMappingIntegrationTest {

    private static final int QUESTION_COUNT = 5;
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

    @PersistenceContext
    private EntityManager em;

    @Autowired
    private TransactionTemplate transactionTemplate;

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
                    InterviewJobRole.BACKEND,
                    TECH_STACK_ID,
                    InterviewLevel.HIGH,
                    QUESTION_COUNT
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
                    null,
                    InterviewLevel.LOW,
                    QUESTION_COUNT
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
                softly.assertThat(foundSession.getJobRole()).isNull();
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
