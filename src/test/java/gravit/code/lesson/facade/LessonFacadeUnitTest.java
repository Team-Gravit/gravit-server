package gravit.code.lesson.facade;

import gravit.code.bookmark.service.BookmarkService;
import gravit.code.chapter.dto.response.ChapterBriefResponse;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.learning.dto.internal.ConsecutiveSolvedDto;
import gravit.code.learning.dto.internal.LearningIdsDto;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.learning.service.LearningCommandService;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonSubmissionSaveResponse;
import gravit.code.lesson.dto.response.LessonSummaryResponse;
import gravit.code.lesson.service.LessonQueryService;
import gravit.code.lesson.service.LessonSubmissionCommandService;
import gravit.code.lesson.service.LessonSubmissionQueryService;
import gravit.code.problem.dto.request.ProblemSubmissionSaveRequest;
import gravit.code.problem.service.ProblemSubmissionCommandService;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.unit.service.UnitQueryService;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.service.UserService;
import gravit.code.userLeague.service.UserLeagueService;
import gravit.code.wrongAnsweredNote.service.WrongAnsweredNoteService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.transaction.support.TransactionCallback;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class LessonFacadeUnitTest {

    @InjectMocks
    private LessonFacade lessonFacade;

    @Mock
    private LessonQueryService lessonQueryService;

    @Mock
    private LessonSubmissionCommandService lessonSubmissionCommandService;

    @Mock
    private LessonSubmissionQueryService lessonSubmissionQueryService;

    @Mock
    private ChapterQueryService chapterQueryService;

    @Mock
    private UnitQueryService unitQueryService;

    @Mock
    private ProblemSubmissionCommandService problemSubmissionCommandService;

    @Mock
    private WrongAnsweredNoteService wrongAnsweredNoteService;

    @Mock
    private BookmarkService bookmarkService;

    @Mock
    private LearningCommandService learningCommandService;

    @Mock
    private UserService userService;

    @Mock
    private UserLeagueService userLeagueService;

    @Mock
    private ApplicationEventPublisher publisher;

    @Mock
    private TransactionTemplate transactionTemplate;

    @Nested
    @DisplayName("유닛별 레슨 목록을 조회할 때")
    class GetAllLessonInUnit {

        @Test
        void 유닛_정보와_레슨_목록_및_접근_여부를_반환한다() {
            // given
            long userId = 1L;
            long unitId = 1L;
            ChapterBriefResponse chapterSummary = new ChapterBriefResponse(10L, "운영체제");
            UnitSummaryResponse unitSummaryResponse = new UnitSummaryResponse(unitId, "프로세스", "프로세스 개념");
            List<LessonSummaryResponse> lessons = List.of(
                    new LessonSummaryResponse(1L, "레슨1", 5, true)
            );

            when(chapterQueryService.getChapterBriefByUnitId(unitId)).thenReturn(chapterSummary);
            when(unitQueryService.getUnitSummaryByUnitId(unitId)).thenReturn(unitSummaryResponse);
            when(lessonQueryService.getAllLessonInUnit(userId, unitId)).thenReturn(lessons);
            when(bookmarkService.checkBookmarkedProblemExists(userId, unitId)).thenReturn(true);
            when(wrongAnsweredNoteService.checkWrongAnsweredProblemExists(userId, unitId)).thenReturn(false);

            // when
            LessonDetailResponse result = lessonFacade.getAllLessonInUnit(userId, unitId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.chapterSummary().chapterId()).isEqualTo(10L);
                softly.assertThat(result.chapterSummary().title()).isEqualTo("운영체제");
                softly.assertThat(result.unitSummaryResponse().title()).isEqualTo("프로세스");
                softly.assertThat(result.lessonSummaries()).hasSize(1);
                softly.assertThat(result.bookmarkAccessible()).isTrue();
                softly.assertThat(result.wrongAnsweredNoteAccessible()).isFalse();
            });
        }

        @Test
        void 레슨이_없으면_빈_리스트를_반환한다() {
            // given
            long userId = 1L;
            long unitId = 1L;
            UnitSummaryResponse unitSummaryResponse = new UnitSummaryResponse(unitId, "프로세스", "프로세스 개념");

            when(chapterQueryService.getChapterBriefByUnitId(unitId)).thenReturn(new ChapterBriefResponse(10L, "운영체제"));
            when(unitQueryService.getUnitSummaryByUnitId(unitId)).thenReturn(unitSummaryResponse);
            when(lessonQueryService.getAllLessonInUnit(userId, unitId)).thenReturn(List.of());
            when(bookmarkService.checkBookmarkedProblemExists(userId, unitId)).thenReturn(false);
            when(wrongAnsweredNoteService.checkWrongAnsweredProblemExists(userId, unitId)).thenReturn(false);

            // when
            LessonDetailResponse result = lessonFacade.getAllLessonInUnit(userId, unitId);

            // then
            assertThat(result.lessonSummaries()).isEmpty();
        }
    }

    @Nested
    @DisplayName("레슨 풀이 결과를 저장할 때")
    class SaveLessonSubmission {

        @BeforeEach
        void 트랜잭션_경계는_콜백을_즉시_실행한다() {
            when(transactionTemplate.execute(any())).thenAnswer(invocation ->
                    invocation.getArgument(0, TransactionCallback.class).doInTransaction(null));
        }

        @Test
        void 첫_풀이면_이벤트를_발행한다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest lessonRequest = new LessonSubmissionSaveRequest(1L, 120, 80);
            List<ProblemSubmissionSaveRequest> problemRequests = List.of(
                    new ProblemSubmissionSaveRequest(1L, true, null, "LIFO")
            );
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(lessonRequest, problemRequests);

            when(lessonSubmissionQueryService.checkFirstLessonSubmission(userId, 1L)).thenReturn(true);
            when(lessonSubmissionCommandService.saveLessonSubmission(userId, lessonRequest)).thenReturn(100L);
            when(userService.updateUserLevelByLessonSubmission(eq(userId), eq(lessonRequest), eq(true)))
                    .thenReturn(UserLevelResponse.create(1, 20));
            when(lessonQueryService.getLearningIdsByLessonId(1L)).thenReturn(new LearningIdsDto(1L, 1L, 1L));
            when(learningCommandService.updateLearningStatus(userId, 1L)).thenReturn(new ConsecutiveSolvedDto(0, 1));

            // when
            LessonSubmissionSaveResponse result = lessonFacade.saveLessonSubmission(userId, request);

            // then
            assertThat(result.lessonSubmissionId()).isEqualTo(100L);
            verify(publisher).publishEvent(any(LessonCompletedEvent.class));
        }

        @Test
        void 재풀이면_이벤트를_발행하지_않는다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest lessonRequest = new LessonSubmissionSaveRequest(1L, 90, 85);
            List<ProblemSubmissionSaveRequest> problemRequests = List.of(
                    new ProblemSubmissionSaveRequest(1L, true, null, "LIFO")
            );
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(lessonRequest, problemRequests);

            when(lessonSubmissionQueryService.checkFirstLessonSubmission(userId, 1L)).thenReturn(false);
            when(lessonSubmissionCommandService.saveLessonSubmission(userId, lessonRequest)).thenReturn(200L);
            when(userService.updateUserLevelByLessonSubmission(eq(userId), eq(lessonRequest), eq(false)))
                    .thenReturn(UserLevelResponse.create(1, 0));
            when(lessonQueryService.getLearningIdsByLessonId(1L)).thenReturn(new LearningIdsDto(1L, 1L, 1L));
            when(learningCommandService.updateLearningStatus(userId, 1L)).thenReturn(new ConsecutiveSolvedDto(1, 1));

            // when
            LessonSubmissionSaveResponse result = lessonFacade.saveLessonSubmission(userId, request);

            // then
            assertThat(result.lessonSubmissionId()).isEqualTo(200L);
            verify(publisher, never()).publishEvent(any(LessonCompletedEvent.class));
        }

        @Test
        void 첫_풀이_판정을_레슨_제출_저장보다_먼저_한다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest lessonRequest = new LessonSubmissionSaveRequest(1L, 120, 80);
            List<ProblemSubmissionSaveRequest> problemRequests = List.of(
                    new ProblemSubmissionSaveRequest(1L, true, null, "LIFO")
            );
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(lessonRequest, problemRequests);

            when(lessonSubmissionQueryService.checkFirstLessonSubmission(userId, 1L)).thenReturn(true);
            when(userService.updateUserLevelByLessonSubmission(eq(userId), eq(lessonRequest), eq(true)))
                    .thenReturn(UserLevelResponse.create(1, 20));
            when(lessonQueryService.getLearningIdsByLessonId(1L)).thenReturn(new LearningIdsDto(1L, 1L, 1L));
            when(learningCommandService.updateLearningStatus(userId, 1L)).thenReturn(new ConsecutiveSolvedDto(0, 1));

            // when
            lessonFacade.saveLessonSubmission(userId, request);

            // then
            InOrder inOrder = inOrder(lessonSubmissionQueryService, lessonSubmissionCommandService);
            inOrder.verify(lessonSubmissionQueryService).checkFirstLessonSubmission(userId, 1L);
            inOrder.verify(lessonSubmissionCommandService).saveLessonSubmission(userId, lessonRequest);
        }

        @Test
        void 검증을_레슨_제출_저장보다_먼저_한다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest lessonRequest = new LessonSubmissionSaveRequest(1L, 120, 80);
            List<ProblemSubmissionSaveRequest> problemRequests = List.of(
                    new ProblemSubmissionSaveRequest(1L, true, null, "LIFO")
            );
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(lessonRequest, problemRequests);

            when(lessonSubmissionQueryService.checkFirstLessonSubmission(userId, 1L)).thenReturn(true);
            when(userService.updateUserLevelByLessonSubmission(eq(userId), eq(lessonRequest), eq(true)))
                    .thenReturn(UserLevelResponse.create(1, 20));
            when(lessonQueryService.getLearningIdsByLessonId(1L)).thenReturn(new LearningIdsDto(1L, 1L, 1L));
            when(learningCommandService.updateLearningStatus(userId, 1L)).thenReturn(new ConsecutiveSolvedDto(0, 1));

            // when
            lessonFacade.saveLessonSubmission(userId, request);

            // then
            InOrder inOrder = inOrder(lessonQueryService, problemSubmissionCommandService, lessonSubmissionCommandService);
            inOrder.verify(lessonQueryService).getLearningIdsByLessonId(1L);
            inOrder.verify(problemSubmissionCommandService).validateProblemSubmissions(problemRequests);
            inOrder.verify(lessonSubmissionCommandService).saveLessonSubmission(userId, lessonRequest);
            inOrder.verify(problemSubmissionCommandService).saveProblemSubmissions(userId, problemRequests);
        }

        @Test
        void 오답으로_돌아온_문제마다_오답_노트를_저장한다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest lessonRequest = new LessonSubmissionSaveRequest(1L, 120, 80);
            List<ProblemSubmissionSaveRequest> problemRequests = List.of(
                    new ProblemSubmissionSaveRequest(1L, false, null, "FIFO"),
                    new ProblemSubmissionSaveRequest(2L, false, 3L, null)
            );
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(lessonRequest, problemRequests);

            when(lessonSubmissionQueryService.checkFirstLessonSubmission(userId, 1L)).thenReturn(true);
            when(problemSubmissionCommandService.saveProblemSubmissions(userId, problemRequests)).thenReturn(List.of(1L, 2L));
            when(userService.updateUserLevelByLessonSubmission(eq(userId), eq(lessonRequest), eq(true)))
                    .thenReturn(UserLevelResponse.create(1, 20));
            when(lessonQueryService.getLearningIdsByLessonId(1L)).thenReturn(new LearningIdsDto(1L, 1L, 1L));
            when(learningCommandService.updateLearningStatus(userId, 1L)).thenReturn(new ConsecutiveSolvedDto(0, 1));

            // when
            lessonFacade.saveLessonSubmission(userId, request);

            // then
            verify(wrongAnsweredNoteService).saveWrongAnsweredNotes(userId, List.of(1L, 2L));
        }

        @Test
        void 오답이_없으면_오답_노트를_저장하지_않는다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest lessonRequest = new LessonSubmissionSaveRequest(1L, 120, 80);
            List<ProblemSubmissionSaveRequest> problemRequests = List.of(
                    new ProblemSubmissionSaveRequest(1L, true, null, "LIFO")
            );
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(lessonRequest, problemRequests);

            when(lessonSubmissionQueryService.checkFirstLessonSubmission(userId, 1L)).thenReturn(true);
            when(problemSubmissionCommandService.saveProblemSubmissions(userId, problemRequests)).thenReturn(List.of());
            when(userService.updateUserLevelByLessonSubmission(eq(userId), eq(lessonRequest), eq(true)))
                    .thenReturn(UserLevelResponse.create(1, 20));
            when(lessonQueryService.getLearningIdsByLessonId(1L)).thenReturn(new LearningIdsDto(1L, 1L, 1L));
            when(learningCommandService.updateLearningStatus(userId, 1L)).thenReturn(new ConsecutiveSolvedDto(0, 1));

            // when
            lessonFacade.saveLessonSubmission(userId, request);

            // then
            verify(wrongAnsweredNoteService).saveWrongAnsweredNotes(userId, List.of());
        }
    }
}
