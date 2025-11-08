package gravit.code.learning.facade;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.infrastructure.LeagueRepository;
import gravit.code.learning.domain.*;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.dto.request.ProblemResultRequest;
import gravit.code.learning.dto.response.LearningResultSaveResponse;
import gravit.code.learning.dto.response.LessonResponse;
import gravit.code.learning.dto.response.UnitPageResponse;
import gravit.code.learning.fixture.*;
import gravit.code.learning.service.ChapterService;
import gravit.code.learning.service.LessonService;
import gravit.code.learning.service.ProblemService;
import gravit.code.progress.domain.*;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import gravit.code.progress.service.ChapterProgressService;
import gravit.code.progress.service.LessonProgressService;
import gravit.code.progress.service.ProblemProgressService;
import gravit.code.progress.service.UnitProgressService;
import gravit.code.season.domain.Season;
import gravit.code.season.infrastructure.SeasonRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import gravit.code.user.fixture.UserFixtureBuilder;
import gravit.code.user.service.UserService;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.domain.UserLeagueRepository;
import gravit.code.userLeague.service.UserLeagueService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
class LearningFacadeIntegrationTest {

    @Autowired
    private LearningFacade learningFacade;

    @Autowired
    private ApplicationEventPublisher publisher;

    @Autowired
    private UserService userService;

    @Autowired
    private ChapterService chapterService;

    @Autowired
    private LessonService lessonService;

    @Autowired
    private ProblemService problemService;

    @Autowired
    private UserLeagueService userLeagueService;

    @Autowired
    private ChapterProgressService chapterProgressService;

    @Autowired
    private UnitProgressService unitProgressService;

    @Autowired
    private LessonProgressService lessonProgressService;

    @Autowired
    private ProblemProgressService problemProgressService;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private ProblemRepository problemRepository;

    @Autowired
    private OptionRepository optionRepository;

    @Autowired
    private ChapterProgressRepository chapterProgressRepository;

    @Autowired
    private UnitProgressRepository unitProgressRepository;

    @Autowired
    private LessonProgressRepository lessonProgressRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserLeagueRepository userLeagueRepository;

    @Autowired
    private LeagueRepository leagueRepository;

    @Autowired
    private SeasonRepository seasonRepository;

    @Nested
    @DisplayName("유저 아이디로 전체 챕터와 진행도를 조회할 때")
    class FindChapterWithProgressByUserId{

        User user;

        Chapter chapter1, chapter2;
        ChapterProgress chapterProgress1, chapterProgress2;

        @BeforeEach
        void setUp(){

            user = UserFixtureBuilder.builder().build();
            userRepository.save(user);

            chapter1 = ChapterFixture.특정_챕터("챕터1", "챕터설명1");
            chapter2 = ChapterFixture.특정_챕터("챕터2", "챕터설명2");

            chapterRepository.saveAll(List.of(
                    chapter1, chapter2
            ));

            chapterProgress1 = ChapterProgressFixture.일반_챕터_진행도(10L, 5L, user.getId(), chapter1.getId());
            chapterProgress2 = ChapterProgressFixture.일반_챕터_진행도(10L, 6L, user.getId(), chapter2.getId());

            chapterProgressRepository.saveAll(List.of(
                    chapterProgress1, chapterProgress2
            ));
        }

        @Test
        void 전체_챕터와_진행도_조회에_성공한다(){
            // given
            final long validUserId = user.getId();

            // when
            List<ChapterProgressDetailResponse> responses = learningFacade.getAllChapters(validUserId);

            // then
            assertThat(responses).satisfies(r -> {
                assertThat(r.size()).isEqualTo(2);

                assertThat(r.get(0).chapterId()).isEqualTo(chapter1.getId());
                assertThat(r.get(0).totalUnits()).isEqualTo(chapter1.getTotalUnits());
                assertThat(r.get(0).completedUnits()).isEqualTo(chapterProgress1.getCompletedUnits());

                assertThat(r.get(1).chapterId()).isEqualTo(chapter2.getId());
                assertThat(r.get(1).totalUnits()).isEqualTo(chapter2.getTotalUnits());
                assertThat(r.get(1).completedUnits()).isEqualTo(chapterProgress2.getCompletedUnits());
            });
        }

        @Test
        void 유저_아이디가_유효하지_않으면_예외를_반환한다(){
            // given
            final long invalidUserId = 999L;

            // when & then
            assertThatThrownBy(() -> learningFacade.getAllChapters(invalidUserId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.USER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("유저 아이디와 챕터 아이디로 유닛을 조회할 때")
    class FindUnitByUserIdAndChapterId{

        User user;

        Chapter chapter;

        Unit unit1, unit2;
        UnitProgress unitProgress1, unitProgress2;

        Lesson lesson1, lesson2;
        Lesson lesson3, lesson4;

        LessonProgress lessonProgress1, lessonProgress2;
        LessonProgress lessonProgress3, lessonProgress4;

        @BeforeEach
        void setUp(){
            user = UserFixtureBuilder.builder().build();
            userRepository.save(user);

            chapter = ChapterFixture.특정_챕터("챕터1", "챕터설명1");
            chapterRepository.save(chapter);

            unit1 = UnitFixture.기본_유닛(chapter.getId());
            unit2 = UnitFixture.기본_유닛(chapter.getId());
            unitRepository.saveAll(List.of(
                    unit1, unit2
            ));

            unitProgress1 = UnitProgressFixture.완료된_유닛_진행도(2L, user.getId(), unit1.getId());
            unitProgress2 = UnitProgressFixture.완료_직전_유닛_진행도(2L, user.getId(), unit2.getId());
            unitProgressRepository.saveAll(List.of(
                    unitProgress1, unitProgress2
            ));

            lesson1 = LessonFixture.기본_레슨(unit1.getId());
            lesson2 = LessonFixture.기본_레슨(unit1.getId());

            lesson3 = LessonFixture.기본_레슨(unit2.getId());
            lesson4 = LessonFixture.기본_레슨(unit2.getId());
            lessonRepository.saveAll(List.of(
                    lesson1, lesson2, lesson3, lesson4
            ));

            lessonProgress1 = LessonProgressFixture.완료_레슨_진행도(user.getId(), lesson1.getId());
            lessonProgress2 = LessonProgressFixture.완료_레슨_진행도(user.getId(), lesson2.getId());

            lessonProgress3 = LessonProgressFixture.완료_레슨_진행도(user.getId(), lesson3.getId());
            lessonProgress4 = LessonProgressFixture.미완료_레슨_진행도(user.getId(), lesson4.getId());

            lessonProgressRepository.saveAll(List.of(
                    lessonProgress1, lessonProgress2, lessonProgress3, lessonProgress4
            ));
        }

        @Test
        void 전체_유닛과_유닛_진행도_조회에_성공한다(){
            // given
            final long validUserId = user.getId();
            final long validChapterId = chapter.getId();

            // when
            UnitPageResponse unitPageResponse = learningFacade.getAllUnitsInChapter(validUserId, validChapterId);

            // then
            assertThat(unitPageResponse).satisfies(upr -> {
                assertThat(upr.chapterId()).isEqualTo(chapter.getId());
                assertThat(upr.unitDetails().get(0).unitProgressDetailResponse().unitId()).isEqualTo(1);
                assertThat(upr.unitDetails().get(1).lessonProgressSummaryResponses().get(0).lessonId()).isEqualTo(3);
                assertThat(upr.unitDetails().get(1).lessonProgressSummaryResponses().get(1).lessonId()).isEqualTo(4);
                assertThat(upr.unitDetails().get(1).lessonProgressSummaryResponses().get(0).isCompleted()).isTrue();
                assertThat(upr.unitDetails().get(1).lessonProgressSummaryResponses().get(1).isCompleted()).isFalse();
            });
        }

        @Test
        void 챕터_아이디가_유효하지_않으면_예외를_반환한다(){
            // given
            final long invalidChapterId = 999L;

            // when & then
            assertThatThrownBy(() -> learningFacade.getAllUnitsInChapter(user.getId(), invalidChapterId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_NOT_FOUND);
        }

        @Test
        void 유닛_진행도_조회에_실패하면_예외를_반환한다(){
            // given
            final long invalidUserId = 999L;

            // when & then
            assertThatThrownBy(() -> learningFacade.getAllUnitsInChapter(invalidUserId, chapter.getId()))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.USER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("레슨의 문제를 모두 조회할 때")
    class FindAllProblemInLesson{

        User user;

        Chapter chapter;
        Unit unit;
        Lesson lesson;

        Problem objectiveProblem, subjectiveProblem;

        Option option1, option2, option3, option4;

        @BeforeEach
        void setUp(){
            user = UserFixtureBuilder.builder().build();
            userRepository.save(user);

            chapter = ChapterFixture.특정_챕터("챕터", "챕터설명");
            chapterRepository.save(chapter);

            unit = UnitFixture.기본_유닛(chapter.getId());
            unitRepository.save(unit);

            lesson = LessonFixture.기본_레슨(unit.getId());
            lessonRepository.save(lesson);

            objectiveProblem = ProblemFixture.객관식_문제(lesson.getId());
            subjectiveProblem = ProblemFixture.주관식_문제(lesson.getId());
            problemRepository.saveAll(List.of(
                    objectiveProblem, subjectiveProblem
            ));

            option1 = OptionFixture.오답_선지(objectiveProblem.getId());
            option2 = OptionFixture.오답_선지(objectiveProblem.getId());
            option3 = OptionFixture.오답_선지(objectiveProblem.getId());
            option4 = OptionFixture.정답_선지(objectiveProblem.getId());
            optionRepository.saveAll(List.of(
                    option1, option2, option3, option4
            ));
        }

        @Test
        void 문제_조회에_성공한다(){
            // given
            final long lessonId = lesson.getId();

            // when
            LessonResponse lessonResponse = learningFacade.getAllProblemsInLesson(lessonId);

            // then
            assertThat(lessonResponse).satisfies(lr -> {
                assertThat(lr.chapterId()).isEqualTo(chapter.getId());
                assertThat(lr.problems()).hasSize(2);
                assertThat(lr.problems().get(0).problemType()).isEqualTo(ProblemType.OBJECTIVE);
                assertThat(lr.problems().get(0).options()).hasSize(4);
            });
        }

        @Test
        void 레슨_아이디가_유효하지_않으면_예외를_반환한다(){
            // given
            final long invalidLessonId = 999L;

            // when & then
            assertThatThrownBy(() -> learningFacade.getAllProblemsInLesson(invalidLessonId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.LESSON_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("레슨 풀이 결과를 저장할 때")
    class SaveLearningResult{

        User user;
        League league;
        UserLeague userLeague;
        Season season;

        Chapter chapter;

        Unit unit1, unit2;

        Lesson lesson1, lesson2;
        Lesson lesson3, lesson4;

        Problem problem1_1, problem1_2;
        Problem problem2_1, problem2_2;
        Problem problem3_1, problem3_2;
        Problem problem4_1, problem4_2;

        ChapterProgress chapterProgress1;
        UnitProgress unitProgress1, unitProgress2;
        LessonProgress lessonProgress1, lessonProgress2;
        LessonProgress lessonProgress3;

        LearningResultSaveRequest request;

        @BeforeEach
        void commonSetUp(){

            user = UserFixtureBuilder.builder().build();
            userRepository.save(user);

            // TODO 픽스처 패턴으로 전환
            league = League.create("브론즈1", 100, 0, 1);
            leagueRepository.save(league);

            season = Season.active("시즌키", LocalDateTime.now(), LocalDateTime.now());
            seasonRepository.save(season);

            userLeague = UserLeague.create(user, season, league);
            userLeagueRepository.save(userLeague);

            chapter = ChapterFixture.기본_챕터();
            chapterRepository.save(chapter);

            unit1 = UnitFixture.기본_유닛(chapter.getId());
            unit2 = UnitFixture.기본_유닛(chapter.getId());
            unitRepository.saveAll(List.of(unit1, unit2));

            lesson1 = LessonFixture.기본_레슨(unit1.getId());
            lesson2 = LessonFixture.기본_레슨(unit1.getId());
            lesson3 = LessonFixture.기본_레슨(unit2.getId());
            lesson4 = LessonFixture.기본_레슨(unit2.getId());
            lessonRepository.saveAll(List.of(lesson1, lesson2, lesson3, lesson4));

            problem1_1 = ProblemFixture.객관식_문제(lesson1.getId());
            problem1_2 = ProblemFixture.주관식_문제(lesson1.getId());

            problem2_1 = ProblemFixture.객관식_문제(lesson2.getId());
            problem2_2 = ProblemFixture.주관식_문제(lesson2.getId());

            problem3_1 = ProblemFixture.객관식_문제(lesson3.getId());
            problem3_2 = ProblemFixture.주관식_문제(lesson3.getId());

            problem4_1 = ProblemFixture.객관식_문제(lesson4.getId());
            problem4_2 = ProblemFixture.주관식_문제(lesson4.getId());

            problemRepository.saveAll(List.of(
                problem1_1, problem1_2,
                problem2_1, problem2_2,
                problem3_1, problem3_2,
                problem4_1, problem4_2
            ));
        }

        void case1SetUp(){
            request = new LearningResultSaveRequest(
                lesson2.getId(),
                180,
                100,
                List.of(
                    new ProblemResultRequest(problem2_1.getId(), true, 0L),
                    new ProblemResultRequest(problem2_2.getId(), true, 0L)
                )
            );

            chapterProgress1 = ChapterProgressFixture.일반_챕터_진행도(2L, 0L, user.getId(), chapter.getId());
            chapterProgressRepository.save(chapterProgress1);

            unitProgress1 = UnitProgressFixture.일반_유닛_진행도(2L, 1L, user.getId(), unit1.getId());
            unitProgressRepository.save(unitProgress1);

            lessonProgress1 = LessonProgressFixture.완료_레슨_진행도(user.getId(), lesson1.getId());
            lessonProgressRepository.save(lessonProgress1);
        }

        void case2SetUp(){
            request = new LearningResultSaveRequest(
                    lesson4.getId(),
                    180,
                    100,
                    List.of(
                            new ProblemResultRequest(problem4_1.getId(), true, 0L),
                            new ProblemResultRequest(problem4_2.getId(), true, 0L)
                    )
            );

            chapterProgress1 = ChapterProgressFixture.일반_챕터_진행도(2L, 1L, user.getId(), chapter.getId());
            chapterProgressRepository.save(chapterProgress1);

            unitProgress1 = UnitProgressFixture.완료된_유닛_진행도(2L, user.getId(), unit1.getId());
            unitProgress2 = UnitProgressFixture.완료_직전_유닛_진행도(2L, user.getId(), unit2.getId());
            unitProgressRepository.saveAll(List.of(
                    unitProgress1, unitProgress2
            ));

            lessonProgress1 = LessonProgressFixture.완료_레슨_진행도(user.getId(), lesson1.getId());
            lessonProgress2 = LessonProgressFixture.완료_레슨_진행도(user.getId(), lesson2.getId());
            lessonProgress3 = LessonProgressFixture.완료_레슨_진행도(user.getId(), lesson3.getId());
            lessonProgressRepository.saveAll(List.of(
                    lessonProgress1, lessonProgress2, lessonProgress3
            ));
        }

        void case3SetUp(){
            request = new LearningResultSaveRequest(
                    lesson4.getId(),
                    180,
                    100,
                    List.of(
                            new ProblemResultRequest(problem1_1.getId(), true, 0L),
                            new ProblemResultRequest(problem1_2.getId(), true, 0L)
                    )
            );
        }

        /**
         * Case1(풀이 레슨: lesson2)
         *
         * [풀이 전 상태]
         * 유닛의 푼 레슨수/총 레슨수 = 1/2
         * 챕터의 푼 유닛수/총 유닛수 = 0/2
         *
         * [풀이 후 상태]
         * 유닛의 푼 레슨수/총 레슨수 = 2/2
         * 챕터의 풋 유닛수/총 유닛수 = 1/2
         */
        @Test
        void 해당_레슨_풀이_시_유닛이_완료되고_챕터는_완료되지_않는_경우_결과_저장에_성공한다(){
            // given
            case1SetUp();

            // when
            LearningResultSaveResponse response = learningFacade.saveLearningResult(user.getId(), request);

            // then
            assertThat(unitProgressRepository.findByUnitIdAndUserId(unit1.getId(), user.getId()).get().getCompletedLessons()).isEqualTo(2L);
            assertThat(lessonProgressRepository.findByLessonIdAndUserId(lesson2.getId(), user.getId())).isPresent();
            assertThat(response).satisfies(r -> {
                assertThat(r.currentLevel()).isEqualTo(1L);
                assertThat(r.xp()).isEqualTo(20);
            });
        }

        /**
         * Case2(풀이 레슨: lesson4)
         * [풀이 전 상태]
         * 유닛의 푼 레슨수/총 레슨수 = 1/2
         * 챕터의 푼 유닛수/총 유닛수 = 1/2
         *
         * [풀이 후 상태]
         * 유닛의 푼 레슨수/총 레슨수 = 2/2
         * 챕터의 풋 유닛수/총 유닛수 = 2/2
         */
        @Test
        void 해당_레슨_풀이_시_유닛이_완료되고_챕터도_완료되는_경우_결과_저장에_성공한다(){
            // given
            case2SetUp();

            // when

            // then
        }

        /**
         * Case3(풀이 레슨: lesson1)
         * [풀이 전 상태]
         * 유닛의 푼 레슨수/총 레슨수 = 0/2
         * 챕터의 푼 유닛수/총 유닛수 = 0/2
         *
         * [풀이 후 상태]
         * 유닛의 푼 레슨수/총 레슨수 = 1/2
         * 챕터의 풋 유닛수/총 유닛수 = 0/2
         */
        @Test
        void 해당_레슨_풀이_시_유닛과_챕터_둘_다_완료되지_않는_경우_결과_저장에_성공한다(){
            // given
            case3SetUp();
            // when

            // then
        }

        @Test
        void 해당_레슨_재풀이_시_유닛_진행도와_챕터_진행도가_업데이트되지_않으며_결과_저장에_성공한다(){

        }
    }
}