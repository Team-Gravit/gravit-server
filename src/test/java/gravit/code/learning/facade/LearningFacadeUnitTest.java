//package gravit.code.learning.facade;
//
//import gravit.code.global.event.LessonCompletedEvent;
//import gravit.code.global.event.badge.QualifiedSolvedEvent;
//import gravit.code.global.exception.domain.CustomErrorCode;
//import gravit.code.global.exception.domain.RestApiException;
//import gravit.code.chapter.domain.Chapter;
//import gravit.code.option.domain.Option;
//import gravit.code.problem.domain.Problem;
//import gravit.code.unit.domain.Unit;
//import gravit.code.learning.dto.common.LearningSummary;
//import gravit.code.learning.dto.common.LearningIds;
//import gravit.code.learning.dto.event.UpdateLearningEvent;
//import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
//import gravit.code.problem.dto.request.ProblemSubmissionRequest;
//import gravit.code.option.dto.response.OptionResponse;
//import gravit.code.problem.dto.response.ProblemResponse;
//import gravit.code.learning.fixture.*;
//import gravit.code.chapter.service.ChapterService;
//import gravit.code.lesson.service.LessonService;
//import gravit.code.problem.service.ProblemService;
//import gravit.code.mission.dto.event.LessonMissionEvent;
//import gravit.code.progress.domain.ChapterProgress;
//import gravit.code.lesson.domain.LessonSubmission;
//import gravit.code.progress.domain.UnitProgress;
//import gravit.code.chapter.dto.response.ChapterDetailResponse;
//import gravit.code.lesson.dto.response.LessonProgressSummaryResponse;
//import gravit.code.unit.UnitProgressDetailResponse;
//import gravit.code.progress.service.ChapterProgressService;
//import gravit.code.lesson.service.LessonSubmissionService;
//import gravit.code.problem.service.ProblemSubmissionService;
//import gravit.code.progress.service.UnitProgressService;
//import gravit.code.user.dto.response.UserLevelResponse;
//import gravit.code.user.service.UserService;
//import gravit.code.userLeague.service.UserLeagueService;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.DisplayName;
//import org.junit.jupiter.api.Nested;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.extension.ExtendWith;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.junit.jupiter.MockitoExtension;
//import org.springframework.context.ApplicationEventPublisher;
//
//import java.util.List;
//
//import static org.assertj.core.api.Assertions.assertThatThrownBy;
//import static org.mockito.ArgumentMatchers.any;
//import static org.mockito.Mockito.*;
//
//@ExtendWith(MockitoExtension.class)
//public class LearningFacadeUnitTest {
//
//    @InjectMocks
//    private LearningFacade learningFacade;
//
//    @Mock
//    private ApplicationEventPublisher publisher;
//
//    @Mock
//    private UserService userService;
//
//    @Mock
//    private ChapterService chapterService;
//
//    @Mock
//    private LessonService lessonService;
//
//    @Mock
//    private ProblemService problemService;
//
//    @Mock
//    private UserLeagueService userLeagueService;
//
//    @Mock
//    private ChapterProgressService chapterProgressService;
//
//    @Mock
//    private UnitProgressService unitProgressService;
//
//    @Mock
//    private LessonSubmissionService lessonProgressService;
//
//    @Mock
//    private ProblemSubmissionService problemProgressService;
//
//    @Nested
//    @DisplayName("유저 아이디로 전체 챕터와 진행도를 조회할 때")
//    class FindChapterWithProgressByUserId{
//
//        final long userId = 1L;
//
//        Chapter chapter1;
//        Chapter chapter2;
//        Chapter chapter3;
//
//        final long chapter1Id = 1L;
//        final long chapter2Id = 2L;
//        final long chapter3Id = 3L;
//
//        ChapterProgress chapterProgress1;
//        ChapterProgress chapterProgress2;
//        ChapterProgress chapterProgress3;
//
//        ChapterDetailResponse chapterProgress1Details;
//        ChapterDetailResponse chapterProgress2Details;
//        ChapterDetailResponse chapterProgress3Details;
//
//        @BeforeEach
//        void setUp(){
//
//            chapter1 = ChapterFixture.특정_챕터("자료구조", "자료구조 설명");
//            chapter2 = ChapterFixture.특정_챕터("알고리즘", "알고리즘 설명");
//            chapter3 = ChapterFixture.특정_챕터("데이터베이스", "데이터베이스 설명");
//
//            chapterProgress1 = ChapterProgressFixture.완료된_챕터_진행도(10L, userId, chapter1Id);
//            chapterProgress2 = ChapterProgressFixture.완료_직전_챕터_진행도(10L, userId, chapter2Id);
//            chapterProgress3 = ChapterProgressFixture.일반_챕터_진행도(10L, 5L, userId, chapter3Id);
//
//            chapterProgress1Details = ChapterDetailResponse.create(chapter1Id, chapter1.getName(), chapter1.getDescription(), chapterProgress1.getTotalUnits(), chapterProgress1.getCompletedUnits());
//            chapterProgress2Details = ChapterDetailResponse.create(chapter2Id, chapter2.getName(), chapter2.getDescription(), chapterProgress2.getTotalUnits(), chapterProgress2.getCompletedUnits());
//            chapterProgress3Details = ChapterDetailResponse.create(chapter3Id, chapter3.getName(), chapter3.getDescription(), chapterProgress3.getTotalUnits(), chapterProgress3.getCompletedUnits());
//        }
//
//        @Test
//        void 전체_챕터와_진행도_조회에_성공한다(){
//            // given
//            final long validUserId = 1L;
//            when(chapterProgressService.getChapterProgressDetails(validUserId)).thenReturn(List.of(
//                    chapterProgress1Details, chapterProgress2Details, chapterProgress3Details
//            ));
//
//            // when
//            learningFacade.getAllChapterDetail(validUserId);
//
//            // then
//            verify(chapterProgressService).getChapterProgressDetails(validUserId);
//        }
//
//        @Test
//        void 유저_아이디가_유효하지_않으면_예외를_반환한다(){
//            // given
//            final long invalidUserId = 999L;
//            when(chapterProgressService.getChapterProgressDetails(invalidUserId)).thenThrow(new RestApiException(CustomErrorCode.USER_NOT_FOUND));
//
//            // when & then
//            assertThatThrownBy(() -> learningFacade.getAllChapterDetail(invalidUserId))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.USER_NOT_FOUND);
//        }
//    }
//
//
//    @Nested
//    @DisplayName("유저 아이디와 챕터 아이디로 유닛을 조회할 때")
//    class FindUnitByUserIdAndChapterId{
//
//        final long userId = 1L;
//
//        Chapter chapter;
//
//        final long chapterId = 1L;
//
//        Unit unit1;
//        Unit unit2;
//        Unit unit3;
//
//        final long unit1Id = 1L;
//        final long unit2Id = 2L;
//
//        final long lesson1Id = 1L, lesson2Id = 2L, lesson3Id = 3L;
//        final long lesson4Id = 4L, lesson5Id = 5L, lesson6Id = 6L;
//
//        UnitProgress unitProgress1;
//        UnitProgress unitProgress2;
//
//        UnitProgressDetailResponse unitProgress1Details;
//        UnitProgressDetailResponse unitProgress2Details;
//
//        List<LessonProgressSummaryResponse> unit1LessonProgresses;
//        List<LessonProgressSummaryResponse> unit2LessonProgresses;
//
//        @BeforeEach
//        void setUp(){
//            chapter = ChapterFixture.저장된_기본_챕터(chapterId);
//
//            unit1 = UnitFixture.기본_유닛(chapterId);
//            unit2 = UnitFixture.기본_유닛(chapterId);
//            unit3 = UnitFixture.기본_유닛(chapterId);
//
//            unitProgress1 = UnitProgressFixture.완료된_유닛_진행도(3L, userId, unit1Id);
//            unitProgress2 = UnitProgressFixture.완료_직전_유닛_진행도(3L, userId, unit2Id);
//
//            unitProgress1Details = UnitProgressDetailResponse.create(unit1Id, unit1.getName(), unit1.getTotalLessons(), unitProgress1.getCompletedLessons());
//            unitProgress2Details = UnitProgressDetailResponse.create(unit2Id, unit2.getName(), unit2.getTotalLessons(), unitProgress2.getCompletedLessons());
//
//            unit1LessonProgresses = List.of(
//                    LessonProgressSummaryResponse.create(lesson1Id, "레슨1", true),
//                    LessonProgressSummaryResponse.create(lesson2Id, "레슨2", true),
//                    LessonProgressSummaryResponse.create(lesson3Id, "레슨3", true)
//            );
//
//            unit2LessonProgresses = List.of(
//                    LessonProgressSummaryResponse.create(lesson4Id, "레슨4", true),
//                    LessonProgressSummaryResponse.create(lesson5Id, "레슨5", true),
//                    LessonProgressSummaryResponse.create(lesson6Id, "레슨6", false)
//            );
//        }
//
//        @Test
//        void 전체_유닛과_유닛_진행도_조회에_성공한다(){
//            // given
//            final long validUserId = userId;
//            final long validChapterId = chapterId;
//
//            when(chapterService.getChapterById(validChapterId)).thenReturn(chapter);
//            when(unitProgressService.findAllUnitProgress(validChapterId, validUserId)).thenReturn(List.of(
//                unitProgress1Details, unitProgress2Details
//            ));
//            when(lessonProgressService.getLessonProgressSummaries(unit1Id, validUserId)).thenReturn(unit1LessonProgresses);
//            when(lessonProgressService.getLessonProgressSummaries(unit2Id, validUserId)).thenReturn(unit2LessonProgresses);
//
//            // when
//            learningFacade.getAllUnitsInChapter(validUserId, validChapterId);
//
//            // then
//           verify(chapterService).getChapterById(validChapterId);
//           verify(unitProgressService).findAllUnitProgress(validChapterId, validUserId);
//           verify(lessonProgressService, times(2)).getLessonProgressSummaries(any(Long.class), any(Long.class));
//        }
//
//        @Test
//        void 챕터_아이디가_유효하지_않으면_예외를_반환한다(){
//            // given
//            final long validUserId = userId;
//            final long invalidChapterId = 999L;
//
//            when(chapterService.getChapterById(invalidChapterId)).thenThrow(new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));
//
//            // when & then
//            assertThatThrownBy(() -> learningFacade.getAllUnitsInChapter(validUserId, invalidChapterId))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_NOT_FOUND);
//        }
//
//        @Test
//        void 유닛_진행도_조회에_실패하면_예외를_반환한다(){
//            // given
//            final long invalidUserId = 999L;
//            final long validChapterId = chapterId;
//
//            when(chapterService.getChapterById(validChapterId)).thenReturn(chapter);
//            when(unitProgressService.findAllUnitProgress(validChapterId, invalidUserId)).thenThrow(new RestApiException(CustomErrorCode.USER_NOT_FOUND));
//
//            // when & then
//            assertThatThrownBy(() -> learningFacade.getAllUnitsInChapter(invalidUserId, validChapterId))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.USER_NOT_FOUND);
//        }
//    }
//
//    @Nested
//    @DisplayName("레슨의 문제를 모두 조회할 때")
//    class FindAllProblemInLesson{
//
//        final long chapterId = 1L;
//
//        final long lessonId = 1L;
//        final String lessonName = "배열";
//
//        Problem objectiveProblem1, objectiveProblem2;
//        Problem subjectProblem1, subjectProblem2;
//
//        Option option1, option2, option3,  option4;
//        Option option5, option6, option7,  option8;
//
//        ProblemResponse objectiveProblemResponse1, objectiveProblemResponse2;
//        ProblemResponse subjectProblemResponse1, subjectProblemResponse2;
//
//        LearningSummary learningAdditionalInfo;
//
//        @BeforeEach
//        void setUp(){
//            objectiveProblem1 = ProblemFixture.저장된_객관식_문제(1L, lessonId);
//            objectiveProblem2 = ProblemFixture.저장된_객관식_문제(2L, lessonId);
//
//            option1 = OptionFixture.저장된_정답_선지(1L, objectiveProblem1.getId());
//            option2 = OptionFixture.저장된_오답_선지(2L, objectiveProblem1.getId());
//            option3 = OptionFixture.저장된_오답_선지(3L, objectiveProblem1.getId());
//            option4 = OptionFixture.저장된_오답_선지(4L, objectiveProblem1.getId());
//
//            option5 = OptionFixture.저장된_정답_선지(5L, objectiveProblem2.getId());
//            option6 = OptionFixture.저장된_오답_선지(6L, objectiveProblem2.getId());
//            option7 = OptionFixture.저장된_오답_선지(7L, objectiveProblem2.getId());
//            option8 = OptionFixture.저장된_오답_선지(8L, objectiveProblem2.getId());
//
//            subjectProblem1 = ProblemFixture.저장된_주관식_문제(3L, lessonId);
//            subjectProblem2 = ProblemFixture.저장된_주관식_문제(4L, lessonId);
//
//            List<OptionResponse> objectiveProblem1Options = List.of(
//                    OptionResponse.from(option1),
//                    OptionResponse.from(option2),
//                    OptionResponse.from(option3),
//                    OptionResponse.from(option4)
//            );
//
//            List<OptionResponse> objectiveProblem2Options = List.of(
//                    OptionResponse.from(option5),
//                    OptionResponse.from(option6),
//                    OptionResponse.from(option7),
//                    OptionResponse.from(option8)
//            );
//
//            objectiveProblemResponse1 = ProblemResponse.create(objectiveProblem1, objectiveProblem1Options);
//            objectiveProblemResponse2 = ProblemResponse.create(objectiveProblem2, objectiveProblem2Options);
//            subjectProblemResponse1 = ProblemResponse.create(subjectProblem1, List.of());
//            subjectProblemResponse2 = ProblemResponse.create(subjectProblem2, List.of());
//
//            learningAdditionalInfo = LearningSummary.of(chapterId, lessonName);
//        }
//
//        @Test
//        void 문제_조회에_성공한다(){
//            // given
//            when(lessonService.getLearningAdditionalInfoByLessonId(lessonId)).thenReturn(learningAdditionalInfo);
//            when(problemService.getAllProblemInLesson(lessonId)).thenReturn(List.of(
//                    objectiveProblemResponse1, objectiveProblemResponse2,
//                    subjectProblemResponse1, subjectProblemResponse2
//            ));
//
//            // when
//            learningFacade.getAllProblemsInLesson(lessonId);
//
//            // then
//            verify(lessonService).getLearningAdditionalInfoByLessonId(lessonId);
//            verify(problemService).getAllProblemInLesson(lessonId);
//        }
//
//        @Test
//        void 레슨_아이디로_속한_챕터와_유닛_조회에_실패하면_예외를_반환한다(){
//            // given
//            final long invalidLessonId = 999L;
//
//            when(lessonService.getLearningAdditionalInfoByLessonId(invalidLessonId))
//                    .thenThrow(new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
//
//            // when & then
//            assertThatThrownBy(() -> learningFacade.getAllProblemsInLesson(invalidLessonId))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.LESSON_NOT_FOUND);
//        }
//    }
//
//    @Nested
//    @DisplayName("레슨 풀이 결과를 저장할 때")
//    class SaveLearningResult{
//
//        final long userId = 1L, invalidUserId = 999L;
//
//        final long chapterId = 1L, unitId = 1L, lessonId = 1L;
//        final long problem1Id = 1L, problem2Id = 1L;
//
//        final long invalidChapterId = 999L, invalidUnitId = 999L, invalidLessonId = 999L;
//
//        final String leagueName = "브론즈1";
//
//        LearningSubmissionSaveRequest request, invalidRequest;
//
//        ChapterProgress chapterProgress, invalidUserChapterProgress;
//        UnitProgress unitProgress, invalidUserUnitProgress;
//        LessonSubmission lessonProgressForFirstAttempt, lessonProgressForRetry, invalidUserLessonProgress;
//
//        LearningIds learningIds;
//
//        LearningIds learningIdsWithInvalidChapter, learningIdsWithInvalidUnit;
//
//        UserLevelResponse userLevelResponse;
//
//        @BeforeEach
//        void setUp(){
//            List<ProblemSubmissionRequest> problemResultRequests = List.of(
//                    new ProblemSubmissionRequest(problem1Id, true, 0L),
//                    new ProblemSubmissionRequest(problem2Id, true, 0L)
//            );
//
//            request = new LearningSubmissionSaveRequest(lessonId, 180, 100, problemResultRequests);
//            invalidRequest = new LearningSubmissionSaveRequest(invalidLessonId, 180, 100, problemResultRequests);
//
//            learningIds = LearningIds.of(chapterId, unitId, lessonId);
//
//            chapterProgress = ChapterProgressFixture.일반_챕터_진행도(10L, 5L, userId, chapterId);
//            unitProgress = UnitProgressFixture.일반_유닛_진행도(3L, 2L, userId, unitId);
//            lessonProgressForFirstAttempt = LessonProgressFixture.일반_레슨_진행도(userId, lessonId);
//            lessonProgressForRetry = LessonProgressFixture.완료_레슨_진행도(userId, lessonId);
//
//            invalidUserChapterProgress = ChapterProgressFixture.일반_챕터_진행도(10L, 5L, invalidUserId, chapterId);
//            invalidUserLessonProgress = LessonProgressFixture.일반_레슨_진행도(invalidUserId, lessonId);
//            invalidUserUnitProgress = UnitProgressFixture.일반_유닛_진행도(3L, 2L, invalidUserId, unitId);
//
//            learningIdsWithInvalidChapter = LearningIds.of(invalidChapterId, unitId, lessonId);
//            learningIdsWithInvalidUnit = LearningIds.of(chapterId, invalidUnitId, lessonId);
//
//            userLevelResponse = UserLevelResponse.create(1, 20);
//        }
//
//        @Test
//        void 첫번째_문제_풀이_결과_저장에_성공한다(){
//            // given
//            when(lessonProgressService.saveLessonSubmission(request.lessonId(), userId, request.learningTime()))
//                    .thenReturn(lessonProgressForFirstAttempt);
//            when(lessonService.getLearningIdsByLessonId(request.lessonId()))
//                    .thenReturn(learningIds);
//            when(chapterProgressService.ensureChapterProgress(chapterId, userId))
//                    .thenReturn(chapterProgress);
//            when(unitProgressService.ensureUnitProgress(unitId, userId))
//                    .thenReturn(unitProgress);
//            when(unitProgressService.updateUnitProgress(unitProgress))
//                    .thenReturn(false);
//            when(userLeagueService.getUserLeagueName(userId))
//                    .thenReturn(leagueName);
//            when(userService.updateUserLevelAndXp(userId, 20, request.accuracy()))
//                    .thenReturn(userLevelResponse);
//
//            // when
//            learningFacade.saveLearningResult(userId, request);
//
//            // then
//            verify(lessonProgressService).saveLessonSubmission(request.lessonId(), userId, request.learningTime());
//            verify(lessonService).getLearningIdsByLessonId(request.lessonId());
//            verify(chapterProgressService).ensureChapterProgress(chapterId, userId);
//            verify(unitProgressService).ensureUnitProgress(unitId, userId);
//            verify(unitProgressService).updateUnitProgress(unitProgress);
//            verify(problemProgressService).saveProblemResults(userId, request.problemResults());
//            verify(userLeagueService).getUserLeagueName(userId);
//            verify(userService).updateUserLevelAndXp(userId, 20, request.accuracy());
//
//            verify(publisher).publishEvent(any(UpdateLearningEvent.class));
//            verify(publisher).publishEvent(any(LessonCompletedEvent.class));
//            verify(publisher).publishEvent(any(LessonMissionEvent.class));
//            verify(publisher).publishEvent(any(QualifiedSolvedEvent.class));
//        }
//
//        @Test
//        void 재시도_문제_풀이_결과_저장에_성공한다(){
//            // given
//            when(lessonProgressService.saveLessonSubmission(request.lessonId(), userId, request.learningTime()))
//                    .thenReturn(lessonProgressForRetry);
//            when(lessonService.getLearningIdsByLessonId(request.lessonId()))
//                    .thenReturn(learningIds);
//            when(chapterProgressService.ensureChapterProgress(chapterId, userId))
//                    .thenReturn(chapterProgress);
//            when(unitProgressService.ensureUnitProgress(unitId, userId))
//                    .thenReturn(unitProgress);
//            when(unitProgressService.updateUnitProgress(unitProgress))
//                    .thenReturn(false);
//            when(userLeagueService.getUserLeagueName(userId))
//                    .thenReturn(leagueName);
//            when(userService.updateUserLevelAndXp(userId, 0, request.accuracy()))
//                    .thenReturn(userLevelResponse);
//
//            // when
//            learningFacade.saveLearningResult(userId, request);
//
//            // then
//            verify(lessonProgressService).saveLessonSubmission(request.lessonId(), userId, request.learningTime());
//            verify(lessonService).getLearningIdsByLessonId(request.lessonId());
//            verify(chapterProgressService).ensureChapterProgress(chapterId, userId);
//            verify(unitProgressService).ensureUnitProgress(unitId, userId);
//            verify(unitProgressService).updateUnitProgress(unitProgress);
//            verify(problemProgressService, never()).saveProblemResults(userId, request.problemResults());
//            verify(userLeagueService).getUserLeagueName(userId);
//            verify(userService).updateUserLevelAndXp(userId, 0, request.accuracy());
//
//            verify(publisher).publishEvent(any(UpdateLearningEvent.class));
//            verify(publisher, never()).publishEvent(any(LessonCompletedEvent.class));
//            verify(publisher, never()).publishEvent(any(LessonMissionEvent.class));
//            verify(publisher, never()).publishEvent(any(QualifiedSolvedEvent.class));
//        }
//
//        @Test
//        void 레슨_조회에_실패하면_예외를_반환한다(){
//            // given
//            when(lessonProgressService.saveLessonSubmission(invalidLessonId, userId, 180))
//                    .thenThrow(new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
//
//            // when & then
//            assertThatThrownBy(() -> learningFacade.saveLearningResult(userId, invalidRequest))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.LESSON_NOT_FOUND);
//        }
//
//        @Test
//        void 레슨이_속한_챕터와_유닛_조회에_실패하면_예외를_반환한다(){
//            // given
//            when(lessonProgressService.saveLessonSubmission(lessonId, userId, 180))
//                    .thenReturn(lessonProgressForFirstAttempt);
//            when(lessonService.getLearningIdsByLessonId(lessonId))
//                    .thenThrow(new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
//
//            // when & then
//            assertThatThrownBy(() -> learningFacade.saveLearningResult(userId, request))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.LESSON_NOT_FOUND);
//        }
//
//        @Test
//        void 챕터_조회에_실패하면_예외를_반환한다(){
//            // given
//            when(lessonProgressService.saveLessonSubmission(lessonId, userId, 180))
//                    .thenReturn(lessonProgressForFirstAttempt);
//            when(lessonService.getLearningIdsByLessonId(lessonId))
//                    .thenReturn(learningIdsWithInvalidChapter);
//            when(chapterProgressService.ensureChapterProgress(invalidChapterId, userId))
//                    .thenThrow(new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));
//
//            // when & then
//            assertThatThrownBy(() -> learningFacade.saveLearningResult(userId, request))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_NOT_FOUND);
//        }
//
//        @Test
//        void 유닛_조회에_실패하면_예외를_반환한다(){
//            // given
//            when(lessonProgressService.saveLessonSubmission(lessonId, userId, 180))
//                    .thenReturn(lessonProgressForFirstAttempt);
//            when(lessonService.getLearningIdsByLessonId(lessonId))
//                    .thenReturn(learningIdsWithInvalidUnit);
//            when(chapterProgressService.ensureChapterProgress(chapterId, userId))
//                    .thenReturn(chapterProgress);
//            when(unitProgressService.ensureUnitProgress(invalidUnitId, userId))
//                    .thenThrow(new RestApiException(CustomErrorCode.UNIT_NOT_FOUND));
//
//            // when & then
//            assertThatThrownBy(() -> learningFacade.saveLearningResult(userId, request))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.UNIT_NOT_FOUND);
//        }
//
//        @Test
//        void 유저_조회에_실패하면_예외를_반환한다(){
//            // given
//            when(lessonProgressService.saveLessonSubmission(lessonId, invalidUserId, 180))
//                    .thenReturn(invalidUserLessonProgress);
//            when(lessonService.getLearningIdsByLessonId(lessonId))
//                    .thenReturn(learningIds);
//            when(chapterProgressService.ensureChapterProgress(chapterId, invalidUserId))
//                    .thenReturn(invalidUserChapterProgress);
//            when(unitProgressService.ensureUnitProgress(unitId, invalidUserId))
//                    .thenReturn(invalidUserUnitProgress);
//            when(unitProgressService.updateUnitProgress(invalidUserUnitProgress))
//                    .thenReturn(false);
//            when(userService.updateUserLevelAndXp(invalidUserId, 20, 100))
//                    .thenThrow(new RestApiException(CustomErrorCode.USER_NOT_FOUND));
//
//            // when & then
//            assertThatThrownBy(() -> learningFacade.saveLearningResult(invalidUserId, request))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.USER_NOT_FOUND);
//        }
//    }
//}*/
