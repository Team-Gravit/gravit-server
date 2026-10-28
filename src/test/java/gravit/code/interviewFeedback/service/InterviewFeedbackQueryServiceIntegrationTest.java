package gravit.code.interviewFeedback.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionSort;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.domain.InterviewStack;
import gravit.code.interview.dto.response.InterviewRecentSessionResponse;
import gravit.code.interview.dto.response.InterviewScoreTrendResponse;
import gravit.code.interview.dto.response.InterviewSessionHistoryResponse;
import gravit.code.interview.dto.response.InterviewSessionHistoryPageResponse;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interview.repository.InterviewSessionTopicRepository;
import gravit.code.interviewFeedback.dto.response.InterviewAnswerDetailResponse;
import gravit.code.interviewFeedback.dto.response.InterviewAnswerScoreResponse;
import gravit.code.interviewFeedback.dto.response.InterviewDashboardResponse;
import gravit.code.interviewFeedback.dto.response.InterviewSessionAnswersResponse;
import gravit.code.interviewFeedback.dto.response.InterviewSessionSummaryResponse;
import gravit.code.interviewFeedback.dto.response.InterviewTopicAccuracyResponse;
import gravit.code.interviewFeedback.dto.response.InterviewWeakTopicResponse;
import gravit.code.interviewFeedback.repository.InterviewFeedbackRepository;
import gravit.code.interviewQuestion.domain.InterviewConceptType;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.dto.response.InterviewConceptResponse;
import gravit.code.interviewQuestion.dto.response.InterviewTopicResponse;
import gravit.code.interviewQuestion.repository.InterviewQuestionConceptRepository;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.repository.UnitRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_FEEDBACK_NOT_READY;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.개념;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.답변한_답안;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.무응답_답안;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.무응답_피드백;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.문제;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.미완료_세션;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.세션_주제;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.완료_세션;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.직군_완료_세션;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.피드백;
import static gravit.code.unit.fixture.UnitFixture.새_유닛;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewFeedbackQueryServiceIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final long NEW_USER_ID = 3L;
    private static final long UNKNOWN_SESSION_ID = 999L;
    private static final LocalDateTime BASE_TIME = LocalDateTime.of(2026, 9, 1, 10, 0);

    private static final long UNKNOWN_UNIT_ID = 999_999L;
    private static final long POOL_CHAPTER_ID = 1L;
    private static final long ALGORITHM_CHAPTER_ID = 2L;

    private static final String DATA_STRUCTURE_UNIT_TITLE = "배열과 연결 리스트";
    private static final String ALGORITHM_UNIT_TITLE = "정렬";
    private static final String NETWORK_UNIT_TITLE = "TCP와 UDP";
    private static final String DATABASE_UNIT_TITLE = "트랜잭션";

    @Autowired
    private InterviewFeedbackQueryService interviewFeedbackQueryService;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewSessionTopicRepository interviewSessionTopicRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Autowired
    private InterviewQuestionRepository interviewQuestionRepository;

    @Autowired
    private InterviewQuestionConceptRepository interviewQuestionConceptRepository;

    @Autowired
    private InterviewFeedbackRepository interviewFeedbackRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Nested
    @DisplayName("응시 이력을 조회할 때")
    class GetSessionHistory {

        @Test
        void 완료_세션만_최신순으로_조회된다() {
            // given
            InterviewSession first = saveCompletedSession(USER_ID, 1, daysAfter(1), 40, 18);
            saveTopics(first.getId(), InterviewTopic.NETWORK, InterviewTopic.DATA_STRUCTURE);
            InterviewSession second = interviewSessionRepository.save(
                    직군_완료_세션(USER_ID, 2, daysAfter(2), InterviewStack.JAVA_SPRING_BOOT, 47, 18)
            );
            saveTopics(second.getId(), InterviewTopic.SPRING_BOOT, InterviewTopic.JAVA, InterviewTopic.SERVER_COMMON);
            interviewSessionRepository.save(미완료_세션(USER_ID, 3, daysAfter(3), InterviewSessionStatus.IN_PROGRESS));
            interviewSessionRepository.save(미완료_세션(USER_ID, 4, daysAfter(4), InterviewSessionStatus.ABANDONED));
            saveCompletedSession(OTHER_USER_ID, 1, daysAfter(5), 70, 30);

            // when
            InterviewSessionHistoryPageResponse result = interviewFeedbackQueryService.getSessionHistory(
                    USER_ID,
                    0,
                    InterviewSessionSort.LATEST
            );

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.hasNextPage()).isFalse();
                softly.assertThat(result.totalPages()).isEqualTo(1);
                softly.assertThat(result.contents()).hasSize(2);

                InterviewSessionHistoryResponse latest = result.contents().get(0);
                softly.assertThat(latest.sessionId()).isEqualTo(second.getId());
                softly.assertThat(latest.sequence()).isEqualTo(2L);
                softly.assertThat(latest.mode()).isEqualTo(InterviewMode.JOB_SPECIFIC);
                softly.assertThat(latest.stack().stack()).isEqualTo(InterviewStack.JAVA_SPRING_BOOT);
                softly.assertThat(latest.stack().displayName()).isEqualTo("Java + Spring Boot");
                softly.assertThat(latest.topics()).extracting(InterviewTopicResponse::topic)
                        .containsExactly(InterviewTopic.SERVER_COMMON, InterviewTopic.JAVA, InterviewTopic.SPRING_BOOT);
                softly.assertThat(latest.startedAt()).isEqualTo(daysAfter(2));
                softly.assertThat(latest.score()).isEqualTo(65);
                softly.assertThat(latest.maxScore()).isEqualTo(100);

                InterviewSessionHistoryResponse oldest = result.contents().get(1);
                softly.assertThat(oldest.sessionId()).isEqualTo(first.getId());
                softly.assertThat(oldest.sequence()).isEqualTo(1L);
                softly.assertThat(oldest.mode()).isEqualTo(InterviewMode.COMMON_CS);
                softly.assertThat(oldest.stack()).isNull();
                softly.assertThat(oldest.topics()).extracting(InterviewTopicResponse::topic)
                        .containsExactly(InterviewTopic.DATA_STRUCTURE, InterviewTopic.NETWORK);
                softly.assertThat(oldest.topics()).extracting(InterviewTopicResponse::displayName)
                        .containsExactly("자료구조", "네트워크");
                softly.assertThat(oldest.score()).isEqualTo(58);
            });
        }

        @Test
        void 오래된_순을_요청하면_시작_시각_오름차순으로_조회된다() {
            // given
            InterviewSession first = saveCompletedSession(USER_ID, 1, daysAfter(1), 40, 18);
            InterviewSession second = saveCompletedSession(USER_ID, 2, daysAfter(2), 47, 18);

            // when
            InterviewSessionHistoryPageResponse result = interviewFeedbackQueryService.getSessionHistory(
                    USER_ID,
                    0,
                    InterviewSessionSort.OLDEST
            );

            // then
            assertThat(result.contents()).extracting(InterviewSessionHistoryResponse::sessionId)
                    .containsExactly(first.getId(), second.getId());
        }

        @Test
        void 완료_세션이_10건을_넘으면_다음_페이지가_있고_전체_페이지_수는_2다() {
            // given
            for (int attempt = 1; attempt <= 11; attempt++) {
                saveCompletedSession(USER_ID, attempt, daysAfter(attempt), 40, 18);
            }

            // when
            InterviewSessionHistoryPageResponse firstPage = interviewFeedbackQueryService.getSessionHistory(
                    USER_ID,
                    0,
                    InterviewSessionSort.LATEST
            );
            InterviewSessionHistoryPageResponse secondPage = interviewFeedbackQueryService.getSessionHistory(
                    USER_ID,
                    1,
                    InterviewSessionSort.LATEST
            );

            // then
            assertSoftly(softly -> {
                softly.assertThat(firstPage.hasNextPage()).isTrue();
                softly.assertThat(firstPage.totalPages()).isEqualTo(2);
                softly.assertThat(firstPage.contents()).hasSize(10);
                softly.assertThat(firstPage.contents().get(0).sequence()).isEqualTo(11L);
                softly.assertThat(secondPage.hasNextPage()).isFalse();
                softly.assertThat(secondPage.totalPages()).isEqualTo(2);
                softly.assertThat(secondPage.contents()).hasSize(1);
                softly.assertThat(secondPage.contents().get(0).sequence()).isEqualTo(1L);
            });
        }

        @Test
        void 페이지가_음수면_첫_페이지로_조회한다() {
            // given
            saveCompletedSession(USER_ID, 1, daysAfter(1), 40, 18);

            // when
            InterviewSessionHistoryPageResponse result = interviewFeedbackQueryService.getSessionHistory(
                    USER_ID,
                    -1,
                    InterviewSessionSort.LATEST
            );

            // then
            assertThat(result.contents()).hasSize(1);
        }

        @Test
        void 완료_세션이_없으면_빈_목록이고_전체_페이지_수는_0이다() {
            // when
            InterviewSessionHistoryPageResponse result = interviewFeedbackQueryService.getSessionHistory(
                    USER_ID,
                    0,
                    InterviewSessionSort.LATEST
            );

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.hasNextPage()).isFalse();
                softly.assertThat(result.totalPages()).isZero();
                softly.assertThat(result.contents()).isEmpty();
            });
        }
    }

    @Nested
    @DisplayName("세션 종합을 조회할 때")
    class GetSessionSummary {

        private InterviewSession firstSession;
        private InterviewSession secondSession;
        private InterviewSession gradedSession;
        private InterviewSession inProgressSession;
        private InterviewSession otherUserSession;
        private List<InterviewQuestion> questions;

        @BeforeEach
        void setUp() {
            firstSession = saveCompletedSession(USER_ID, 1, daysAfter(1), 40, 18);
            secondSession = saveCompletedSession(USER_ID, 2, daysAfter(2), 47, 18);
            questions = saveQuestionPool();
            gradedSession = saveGradedSession(USER_ID, 3, daysAfter(3), 24, 14, questions);
            saveCompletedSession(USER_ID, 4, daysAfter(4), 60, 25);
            inProgressSession = interviewSessionRepository.save(
                    미완료_세션(USER_ID, 5, daysAfter(5), InterviewSessionStatus.IN_PROGRESS)
            );
            otherUserSession = saveCompletedSession(OTHER_USER_ID, 1, daysAfter(6), 70, 30);
        }

        @Test
        void 점수와_만점_문항별_점수_약점_분야를_조회한다() {
            // when
            InterviewSessionSummaryResponse result = interviewFeedbackQueryService.getSessionSummary(
                    USER_ID,
                    gradedSession.getId()
            );

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.sessionId()).isEqualTo(gradedSession.getId());
                softly.assertThat(result.sequence()).isEqualTo(3L);
                softly.assertThat(result.startedAt()).isEqualTo(daysAfter(3));
                softly.assertThat(result.score()).isEqualTo(38);
                softly.assertThat(result.maxScore()).isEqualTo(100);
                softly.assertThat(result.accuracyScore()).isEqualTo(24);
                softly.assertThat(result.accuracyMaxScore()).isEqualTo(70);
                softly.assertThat(result.deliveryScore()).isEqualTo(14);
                softly.assertThat(result.deliveryMaxScore()).isEqualTo(30);

                softly.assertThat(result.answers()).extracting(InterviewAnswerScoreResponse::displayOrder)
                        .containsExactly(1, 2, 3, 4, 5);
                softly.assertThat(result.answers()).extracting(InterviewAnswerScoreResponse::accuracyScore)
                        .containsExactly(12, 4, 5, 3, 0);
                softly.assertThat(result.answers()).extracting(InterviewAnswerScoreResponse::deliveryScore)
                        .containsExactly(5, 2, 5, 2, 0);
                softly.assertThat(result.answers().get(0).topic().displayName()).isEqualTo("자료구조");

                softly.assertThat(result.weakTopics()).extracting(InterviewWeakTopicResponse::unitId)
                        .containsExactly(
                                questions.get(1).getUnitId(),
                                questions.get(2).getUnitId(),
                                questions.get(4).getUnitId()
                        );
                softly.assertThat(result.weakTopics()).extracting(InterviewWeakTopicResponse::unitTitle)
                        .containsExactly(ALGORITHM_UNIT_TITLE, NETWORK_UNIT_TITLE, DATABASE_UNIT_TITLE);
                softly.assertThat(result.weakTopics()).extracting(weak -> weak.topic().topic())
                        .containsExactly(InterviewTopic.ALGORITHM, InterviewTopic.NETWORK, InterviewTopic.DATABASE);
            });
        }

        @Test
        void 같은_주제의_서로_다른_유닛이_약점이면_유닛마다_나가고_유닛_제목으로_구분된다() {
            // given
            List<String> unitTitles = List.of("정렬", "이분 탐색", "그래프 탐색", "동적 계획법", "그리디");
            InterviewSession session = saveCompletedSession(USER_ID, 6, daysAfter(16), 20, 10);
            List<Long> unitIds = new ArrayList<>();
            for (int order = 1; order <= unitTitles.size(); order++) {
                long unitId = saveUnit(unitTitles.get(order - 1), ALGORITHM_CHAPTER_ID, order);
                InterviewQuestion question = interviewQuestionRepository.save(문제(InterviewTopic.ALGORITHM, unitId));
                saveGradedAnswer(session.getId(), question.getId(), order, 4, 1, 1);
                unitIds.add(unitId);
            }

            // when
            InterviewSessionSummaryResponse result = interviewFeedbackQueryService.getSessionSummary(
                    USER_ID,
                    session.getId()
            );

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.weakTopics()).extracting(InterviewWeakTopicResponse::unitId)
                        .containsExactlyElementsOf(unitIds);
                softly.assertThat(result.weakTopics()).extracting(InterviewWeakTopicResponse::unitTitle)
                        .containsExactlyElementsOf(unitTitles);
                softly.assertThat(result.weakTopics()).extracting(weak -> weak.topic().topic())
                        .containsOnly(InterviewTopic.ALGORITHM);
            });
        }

        @Test
        void 유닛이_없는_문항도_문항별_점수에_남고_약점_분야의_유닛_제목은_비어_있다() {
            // given
            InterviewSession session = saveCompletedSession(USER_ID, 6, daysAfter(16), 4, 2);
            InterviewQuestion question = interviewQuestionRepository.save(문제(InterviewTopic.NETWORK, UNKNOWN_UNIT_ID));
            saveGradedAnswer(session.getId(), question.getId(), 1, 4, 1, 1);

            // when
            InterviewSessionSummaryResponse result = interviewFeedbackQueryService.getSessionSummary(
                    USER_ID,
                    session.getId()
            );

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.answers()).extracting(InterviewAnswerScoreResponse::displayOrder)
                        .containsExactly(1);
                softly.assertThat(result.weakTopics()).extracting(InterviewWeakTopicResponse::unitId)
                        .containsExactly(UNKNOWN_UNIT_ID);
                softly.assertThat(result.weakTopics()).extracting(InterviewWeakTopicResponse::unitTitle)
                        .containsOnlyNulls();
            });
        }

        @Test
        void 전체_평균은_모든_사용자의_완료_세션을_정수로_반올림한다() {
            // when
            InterviewSessionSummaryResponse result = interviewFeedbackQueryService.getSessionSummary(
                    USER_ID,
                    gradedSession.getId()
            );

            // then
            // 완료 세션 정확도 (40, 47, 24, 60, 70) 평균 48.2 → 48, 전달력 (18, 18, 14, 25, 30) 평균 21
            assertThat(result.averageAccuracyScore()).isEqualTo(48);
            assertThat(result.averageDeliveryScore()).isEqualTo(21);
        }

        @Test
        void 최근_추이는_조회_세션을_포함해_오래된_순이고_이후_세션은_제외한다() {
            // when
            InterviewSessionSummaryResponse result = interviewFeedbackQueryService.getSessionSummary(
                    USER_ID,
                    gradedSession.getId()
            );

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.recentSessions()).extracting(InterviewRecentSessionResponse::sessionId)
                        .containsExactly(firstSession.getId(), secondSession.getId(), gradedSession.getId());
                softly.assertThat(result.recentSessions()).extracting(InterviewRecentSessionResponse::sequence)
                        .containsExactly(1L, 2L, 3L);
                softly.assertThat(result.recentSessions()).extracting(InterviewRecentSessionResponse::accuracyScore)
                        .containsExactly(40, 47, 24);
                softly.assertThat(result.recentSessions()).extracting(InterviewRecentSessionResponse::deliveryScore)
                        .containsExactly(18, 18, 14);
            });
        }

        @Test
        void 최근_추이는_최대_5개다() {
            // given
            saveCompletedSession(USER_ID, 6, daysAfter(16), 50, 20);
            saveCompletedSession(USER_ID, 7, daysAfter(17), 50, 20);
            InterviewSession latest = saveCompletedSession(USER_ID, 8, daysAfter(18), 50, 20);

            // when
            InterviewSessionSummaryResponse result = interviewFeedbackQueryService.getSessionSummary(
                    USER_ID,
                    latest.getId()
            );

            // then
            assertThat(result.recentSessions()).extracting(InterviewRecentSessionResponse::sequence)
                    .containsExactly(3L, 4L, 6L, 7L, 8L);
        }

        @Test
        void 없는_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewFeedbackQueryService.getSessionSummary(USER_ID, UNKNOWN_SESSION_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }

        @Test
        void 다른_사용자의_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewFeedbackQueryService.getSessionSummary(USER_ID, otherUserSession.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ACCESS_DENIED);
        }

        @Test
        void 완료되지_않은_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewFeedbackQueryService.getSessionSummary(USER_ID, inProgressSession.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_FEEDBACK_NOT_READY);
        }
    }

    @Nested
    @DisplayName("문항별 상세를 조회할 때")
    class GetSessionAnswers {

        private static final String AUDIO_KEY_FIELD = "audioKey";
        private static final String AUDIO_KEY_FORMAT = "interview/%d/1.m4a";

        private InterviewSession gradedSession;
        private InterviewSession inProgressSession;
        private InterviewSession otherUserSession;
        private List<InterviewQuestion> questions;

        @BeforeEach
        void setUp() {
            questions = saveQuestionPool();
            long firstQuestionId = questions.get(0).getId();
            interviewQuestionConceptRepository.save(개념(firstQuestionId, "보조 개념", InterviewConceptType.SUPPLEMENTARY, 2));
            interviewQuestionConceptRepository.save(개념(firstQuestionId, "필수 개념", InterviewConceptType.ESSENTIAL, 1));
            gradedSession = saveGradedSession(USER_ID, 1, daysAfter(1), 24, 14, questions);
            inProgressSession = interviewSessionRepository.save(
                    미완료_세션(USER_ID, 2, daysAfter(2), InterviewSessionStatus.IN_PROGRESS)
            );
            otherUserSession = saveCompletedSession(OTHER_USER_ID, 1, daysAfter(3), 70, 30);
        }

        @Test
        void 문항_순서대로_질문_답변_모범답안_개념_점수를_조회한다() {
            // when
            InterviewSessionAnswersResponse result = interviewFeedbackQueryService.getSessionAnswers(
                    USER_ID,
                    gradedSession.getId()
            );

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.sessionId()).isEqualTo(gradedSession.getId());
                softly.assertThat(result.startedAt()).isEqualTo(daysAfter(1));
                softly.assertThat(result.answers()).extracting(InterviewAnswerDetailResponse::displayOrder)
                        .containsExactly(1, 2, 3, 4, 5);

                InterviewAnswerDetailResponse first = result.answers().get(0);
                softly.assertThat(first.topic().topic()).isEqualTo(InterviewTopic.DATA_STRUCTURE);
                softly.assertThat(first.questionContent()).isEqualTo("자료구조 질문");
                softly.assertThat(first.answerContent()).isEqualTo("답변 1");
                softly.assertThat(first.audioUrl()).isNull();
                softly.assertThat(first.modelAnswer()).isEqualTo("자료구조 모범답안");
                softly.assertThat(first.concepts()).extracting(InterviewConceptResponse::name)
                        .containsExactly("필수 개념", "보조 개념");
                softly.assertThat(first.concepts()).extracting(InterviewConceptResponse::type)
                        .containsExactly(InterviewConceptType.ESSENTIAL, InterviewConceptType.SUPPLEMENTARY);
                softly.assertThat(first.improvementSuggestion()).isEqualTo("개선 제안 1");
                softly.assertThat(first.accuracyScore()).isEqualTo(12);
                softly.assertThat(first.accuracyMaxScore()).isEqualTo(14);
                softly.assertThat(first.structureScore()).isEqualTo(3);
                softly.assertThat(first.structureMaxScore()).isEqualTo(3);
                softly.assertThat(first.clarityScore()).isEqualTo(2);
                softly.assertThat(first.clarityMaxScore()).isEqualTo(3);

                softly.assertThat(result.answers().get(1).concepts()).isEmpty();
            });
        }

        @Test
        void 음성_키가_있는_문항은_재생_URL을_발급한다() {
            // given
            String audioKey = AUDIO_KEY_FORMAT.formatted(gradedSession.getId());
            InterviewAnswer answer = interviewAnswerRepository.findBySessionIdAndDisplayOrder(gradedSession.getId(), 1)
                    .orElseThrow();
            ReflectionTestUtils.setField(answer, AUDIO_KEY_FIELD, audioKey);
            interviewAnswerRepository.save(answer);

            // when
            InterviewSessionAnswersResponse result = interviewFeedbackQueryService.getSessionAnswers(
                    USER_ID,
                    gradedSession.getId()
            );

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.answers().get(0).audioUrl()).contains(audioKey);
                softly.assertThat(result.answers().get(0).audioUrl()).contains("X-Amz-Signature=");
                softly.assertThat(result.answers().get(1).audioUrl()).isNull();
            });
        }

        @Test
        void 무응답_문항은_답변과_개선_제안이_비어_있고_점수가_0이다() {
            // when
            InterviewSessionAnswersResponse result = interviewFeedbackQueryService.getSessionAnswers(
                    USER_ID,
                    gradedSession.getId()
            );

            // then
            InterviewAnswerDetailResponse noResponse = result.answers().get(4);
            assertSoftly(softly -> {
                softly.assertThat(noResponse.topic().topic()).isEqualTo(InterviewTopic.DATABASE);
                softly.assertThat(noResponse.answerContent()).isNull();
                softly.assertThat(noResponse.improvementSuggestion()).isNull();
                softly.assertThat(noResponse.accuracyScore()).isZero();
                softly.assertThat(noResponse.structureScore()).isZero();
                softly.assertThat(noResponse.clarityScore()).isZero();
                softly.assertThat(noResponse.modelAnswer()).isEqualTo("데이터베이스 모범답안");
            });
        }

        @Test
        void 없는_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewFeedbackQueryService.getSessionAnswers(USER_ID, UNKNOWN_SESSION_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }

        @Test
        void 다른_사용자의_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewFeedbackQueryService.getSessionAnswers(USER_ID, otherUserSession.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ACCESS_DENIED);
        }

        @Test
        void 완료되지_않은_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewFeedbackQueryService.getSessionAnswers(USER_ID, inProgressSession.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_FEEDBACK_NOT_READY);
        }
    }

    @Nested
    @DisplayName("메인 화면을 조회할 때")
    class GetDashboard {

        @BeforeEach
        void setUp() {
            saveTopicAccuracyData();
        }

        @Test
        void 완료_세션_수와_최근_5개_총점_평균을_조회한다() {
            // when
            InterviewDashboardResponse result = interviewFeedbackQueryService.getDashboard(USER_ID);

            // then
            // 최근 5개 총점 (66, 68, 70, 72, 77) 평균 70.6 → 71
            assertThat(result.completedSessionCount()).isEqualTo(7L);
            assertThat(result.recentAverageScore()).isEqualTo(71);
        }

        @Test
        void 최근_세션_3개는_최신순이고_점수_추이_5개는_오래된_순이다() {
            // when
            InterviewDashboardResponse result = interviewFeedbackQueryService.getDashboard(USER_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.recentSessions()).extracting(InterviewSessionHistoryResponse::sequence)
                        .containsExactly(7L, 6L, 5L);
                softly.assertThat(result.scoreTrends()).extracting(InterviewScoreTrendResponse::sequence)
                        .containsExactly(3L, 4L, 5L, 6L, 7L);
                softly.assertThat(result.scoreTrends()).extracting(InterviewScoreTrendResponse::score)
                        .containsExactly(66, 68, 70, 72, 77);
            });
        }

        @Test
        void 약점_주제는_정확도율_오름차순_하위_3개다() {
            // when
            InterviewDashboardResponse result = interviewFeedbackQueryService.getDashboard(USER_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.weakestTopics()).extracting(weak -> weak.topic().topic())
                        .containsExactly(InterviewTopic.NETWORK, InterviewTopic.ALGORITHM, InterviewTopic.DATABASE);
                softly.assertThat(result.weakestTopics()).extracting(InterviewTopicAccuracyResponse::accuracyRate)
                        .containsExactly(28.6, 35.7, 85.7);
            });
        }

        @Test
        void 완료_세션이_없으면_0과_빈_목록이다() {
            // when
            InterviewDashboardResponse result = interviewFeedbackQueryService.getDashboard(NEW_USER_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.completedSessionCount()).isZero();
                softly.assertThat(result.recentAverageScore()).isZero();
                softly.assertThat(result.weakestTopics()).isEmpty();
                softly.assertThat(result.recentSessions()).isEmpty();
                softly.assertThat(result.scoreTrends()).isEmpty();
            });
        }
    }

    @Nested
    @DisplayName("약점 주제 전체를 조회할 때")
    class GetWeakTopics {

        @Test
        void 주제별_정확도율을_오름차순으로_전부_조회하고_다른_사용자_데이터는_제외한다() {
            // given
            saveTopicAccuracyData();

            // when
            List<InterviewTopicAccuracyResponse> result = interviewFeedbackQueryService.getWeakTopics(USER_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).extracting(item -> item.topic().topic())
                        .containsExactly(
                                InterviewTopic.NETWORK,
                                InterviewTopic.ALGORITHM,
                                InterviewTopic.DATABASE,
                                InterviewTopic.DATA_STRUCTURE
                        );
                softly.assertThat(result).extracting(InterviewTopicAccuracyResponse::accuracyRate)
                        .containsExactly(28.6, 35.7, 85.7, 92.9);
                softly.assertThat(result.get(0).topic().displayName()).isEqualTo("네트워크");
            });
        }

        @Test
        void 정확도율이_같으면_태그_선언_순이다() {
            // given
            List<InterviewQuestion> questions = saveQuestionPool();
            InterviewSession session = saveCompletedSession(NEW_USER_ID, 1, daysAfter(1), 28, 12);
            saveGradedAnswer(session.getId(), questions.get(4).getId(), 1, 14, 3, 3);
            saveGradedAnswer(session.getId(), questions.get(0).getId(), 2, 14, 3, 3);

            // when
            List<InterviewTopicAccuracyResponse> result = interviewFeedbackQueryService.getWeakTopics(NEW_USER_ID);

            // then
            assertThat(result).extracting(item -> item.topic().topic())
                    .containsExactly(InterviewTopic.DATA_STRUCTURE, InterviewTopic.DATABASE);
            assertThat(result).extracting(InterviewTopicAccuracyResponse::accuracyRate)
                    .containsExactly(100.0, 100.0);
        }

        @Test
        void 완료_세션이_없으면_빈_목록이다() {
            // when
            List<InterviewTopicAccuracyResponse> result = interviewFeedbackQueryService.getWeakTopics(NEW_USER_ID);

            // then
            assertThat(result).isEmpty();
        }
    }

    private LocalDateTime daysAfter(int days) {
        return BASE_TIME.plusDays(days);
    }

    private InterviewSession saveCompletedSession(
            long userId,
            long attemptCount,
            LocalDateTime startedAt,
            int accuracyScore,
            int deliveryScore
    ) {
        return interviewSessionRepository.save(완료_세션(userId, attemptCount, startedAt, accuracyScore, deliveryScore));
    }

    private void saveTopics(
            long sessionId,
            InterviewTopic... topics
    ) {
        for (InterviewTopic topic : topics) {
            interviewSessionTopicRepository.save(세션_주제(sessionId, topic));
        }
    }

    private List<InterviewQuestion> saveQuestionPool() {
        long dataStructureUnitId = saveUnit(DATA_STRUCTURE_UNIT_TITLE, POOL_CHAPTER_ID, 1);
        long algorithmUnitId = saveUnit(ALGORITHM_UNIT_TITLE, POOL_CHAPTER_ID, 2);
        long networkUnitId = saveUnit(NETWORK_UNIT_TITLE, POOL_CHAPTER_ID, 3);
        long databaseUnitId = saveUnit(DATABASE_UNIT_TITLE, POOL_CHAPTER_ID, 4);

        return List.of(
                interviewQuestionRepository.save(문제(InterviewTopic.DATA_STRUCTURE, dataStructureUnitId)),
                interviewQuestionRepository.save(문제(InterviewTopic.ALGORITHM, algorithmUnitId)),
                interviewQuestionRepository.save(문제(InterviewTopic.NETWORK, networkUnitId)),
                interviewQuestionRepository.save(문제(InterviewTopic.NETWORK, networkUnitId)),
                interviewQuestionRepository.save(문제(InterviewTopic.DATABASE, databaseUnitId))
        );
    }

    private long saveUnit(
            String title,
            long chapterId,
            int displayOrder
    ) {
        return unitRepository.save(새_유닛(title, chapterId, displayOrder)).getId();
    }

    private InterviewSession saveGradedSession(
            long userId,
            long attemptCount,
            LocalDateTime startedAt,
            int accuracyScore,
            int deliveryScore,
            List<InterviewQuestion> questions
    ) {
        InterviewSession session = saveCompletedSession(userId, attemptCount, startedAt, accuracyScore, deliveryScore);
        saveGradedAnswer(session.getId(), questions.get(0).getId(), 1, 12, 3, 2);
        saveGradedAnswer(session.getId(), questions.get(1).getId(), 2, 4, 1, 1);
        saveGradedAnswer(session.getId(), questions.get(2).getId(), 3, 5, 2, 3);
        saveGradedAnswer(session.getId(), questions.get(3).getId(), 4, 3, 1, 1);
        saveNoResponseAnswer(session.getId(), questions.get(4).getId(), 5);
        return session;
    }

    private void saveGradedAnswer(
            long sessionId,
            long questionId,
            int displayOrder,
            int accuracyScore,
            int structureScore,
            int clarityScore
    ) {
        InterviewAnswer answer = interviewAnswerRepository.save(
                답변한_답안(sessionId, questionId, displayOrder, "답변 " + displayOrder, BASE_TIME)
        );
        interviewFeedbackRepository.save(
                피드백(answer.getId(), accuracyScore, structureScore, clarityScore, "개선 제안 " + displayOrder)
        );
    }

    private void saveNoResponseAnswer(
            long sessionId,
            long questionId,
            int displayOrder
    ) {
        InterviewAnswer answer = interviewAnswerRepository.save(무응답_답안(sessionId, questionId, displayOrder, BASE_TIME));
        interviewFeedbackRepository.save(무응답_피드백(answer.getId()));
    }

    private void saveTopicAccuracyData() {
        List<InterviewQuestion> questions = saveQuestionPool();
        InterviewSession sixth = null;
        InterviewSession seventh = null;
        for (int attempt = 1; attempt <= 7; attempt++) {
            int accuracyScore = attempt == 7 ? 57 : 40 + 2 * attempt;
            InterviewSession session = saveCompletedSession(USER_ID, attempt, daysAfter(attempt), accuracyScore, 20);
            if (attempt == 6) {
                sixth = session;
            }
            if (attempt == 7) {
                seventh = session;
            }
        }
        interviewSessionRepository.save(미완료_세션(USER_ID, 8, daysAfter(8), InterviewSessionStatus.IN_PROGRESS));

        saveGradedAnswer(sixth.getId(), questions.get(0).getId(), 1, 14, 3, 3);
        saveGradedAnswer(sixth.getId(), questions.get(1).getId(), 2, 7, 2, 2);
        saveGradedAnswer(sixth.getId(), questions.get(2).getId(), 3, 7, 2, 2);
        saveNoResponseAnswer(sixth.getId(), questions.get(3).getId(), 4);
        saveGradedAnswer(sixth.getId(), questions.get(4).getId(), 5, 10, 3, 2);

        saveGradedAnswer(seventh.getId(), questions.get(0).getId(), 1, 12, 3, 2);
        saveGradedAnswer(seventh.getId(), questions.get(1).getId(), 2, 3, 1, 1);
        saveGradedAnswer(seventh.getId(), questions.get(2).getId(), 3, 4, 1, 2);
        saveGradedAnswer(seventh.getId(), questions.get(3).getId(), 4, 5, 2, 1);
        saveGradedAnswer(seventh.getId(), questions.get(4).getId(), 5, 14, 3, 3);

        InterviewSession otherUserSession = saveCompletedSession(OTHER_USER_ID, 1, daysAfter(9), 70, 30);
        saveGradedAnswer(otherUserSession.getId(), questions.get(2).getId(), 1, 14, 3, 3);
    }
}
