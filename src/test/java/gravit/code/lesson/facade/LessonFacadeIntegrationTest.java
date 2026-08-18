package gravit.code.lesson.facade;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.repository.LeagueRepository;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.learning.repository.LearningRepository;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonResultResponse;
import gravit.code.lesson.dto.response.LessonSubmissionSaveResponse;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.request.ProblemSubmissionSaveRequest;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.problem.repository.ProblemSubmissionRepository;
import gravit.code.season.domain.Season;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.wrongAnsweredNote.repository.WrongAnsweredNoteRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.LESSON_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.LESSON_SUBMISSION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_TYPE_MISMATCH;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class LessonFacadeIntegrationTest {

    @Autowired
    private LessonFacade lessonFacade;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Autowired
    private ProblemRepository problemRepository;

    @Autowired
    private ProblemSubmissionRepository problemSubmissionRepository;

    @Autowired
    private WrongAnsweredNoteRepository wrongAnsweredNoteRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private LeagueRepository leagueRepository;

    @Autowired
    private SeasonRepository seasonRepository;

    @Autowired
    private UserLeagueRepository userLeagueRepository;

    @Autowired
    private LearningRepository learningRepository;

    @Nested
    @DisplayName("유닛별 레슨 목록을 조회할 때")
    class GetAllLessonInUnit {

        @Test
        void 유닛_정보와_레슨_목록을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson1.getId(), userId));

            // when
            LessonDetailResponse result = lessonFacade.getAllLessonInUnit(userId, unit.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.chapterSummary().chapterId()).isEqualTo(chapter.getId());
                softly.assertThat(result.chapterSummary().title()).isEqualTo("운영체제");
                softly.assertThat(result.unitSummaryResponse().title()).isEqualTo("프로세스");
                softly.assertThat(result.lessonSummaries()).hasSize(2);
                softly.assertThat(result.lessonSummaries().get(0).isSolved()).isTrue();
                softly.assertThat(result.lessonSummaries().get(1).isSolved()).isFalse();
            });
        }

        @Test
        void 레슨이_없으면_빈_리스트를_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));

            // when
            LessonDetailResponse result = lessonFacade.getAllLessonInUnit(userId, unit.getId());

            // then
            assertThat(result.lessonSummaries()).isEmpty();
        }
    }

    @Nested
    @DisplayName("레슨 풀이 결과를 저장할 때")
    class SaveLessonSubmission {

        private static final long NOT_EXIST_LESSON_ID = 999_999L;
        private static final long NOT_EXIST_PROBLEM_ID = 999_999L;

        private Lesson 레슨() {
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));

            return lessonRepository.save(Lesson.create("레슨1", unit.getId()));
        }

        @Test
        void 레슨이_존재하지_않으면_아무것도_저장하지_않는다() {
            // given
            long userId = 1L;
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(
                    new LessonSubmissionSaveRequest(NOT_EXIST_LESSON_ID, 120, 80),
                    List.of(new ProblemSubmissionSaveRequest(1L, true, null, "LIFO"))
            );

            // when
            assertThatThrownBy(() -> lessonFacade.saveLessonSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LESSON_NOT_FOUND);

            // then
            assertSoftly(softly -> {
                softly.assertThat(lessonSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(problemSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 문제_유형에_맞지_않는_제출이_있으면_레슨_제출도_저장되지_않는다() {
            // given
            long userId = 1L;
            Lesson lesson = 레슨();
            Problem problem = problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "다음 중 올바른 것을 고르시오.", "큐의 특성은?", lesson.getId()));
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(
                    new LessonSubmissionSaveRequest(lesson.getId(), 120, 80),
                    List.of(new ProblemSubmissionSaveRequest(problem.getId(), false, null, null))
            );

            // when
            assertThatThrownBy(() -> lessonFacade.saveLessonSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);

            // then
            assertSoftly(softly -> {
                softly.assertThat(lessonSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(problemSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 존재하지_않는_문제가_있으면_레슨_제출도_저장되지_않는다() {
            // given
            long userId = 1L;
            Lesson lesson = 레슨();
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(
                    new LessonSubmissionSaveRequest(lesson.getId(), 120, 80),
                    List.of(new ProblemSubmissionSaveRequest(NOT_EXIST_PROBLEM_ID, true, null, "LIFO"))
            );

            // when
            assertThatThrownBy(() -> lessonFacade.saveLessonSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_NOT_FOUND);

            // then
            assertSoftly(softly -> {
                softly.assertThat(lessonSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(problemSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
            });
        }
    }

    @Nested
    @DisplayName("레슨 결과를 조회할 때")
    class GetLessonResult {

        private static final ZoneId KST = ZoneId.of("Asia/Seoul");
        private static final long OTHER_USER_ID = 999_999L;
        private static final int 승급_직전_LP = 90;

        private User 유저() {
            return userRepository.save(User.create("test@test.com", "provider_1", "테스터", "handle1", 3, Role.USER));
        }

        private void 브론즈로_리그에_참여시킨다(
                User user,
                int lp
        ) {
            League bronze = leagueRepository.save(League.create("브론즈", 100, 0, 1));
            leagueRepository.save(League.create("실버", 200, 101, 2));
            Season season = seasonRepository.save(Season.active("2026-W18", LocalDateTime.now(KST), LocalDateTime.now(KST).plusWeeks(1)));

            UserLeague userLeague = UserLeague.create(user, season, bronze);
            userLeague.addLeaguePoints(lp);
            userLeagueRepository.save(userLeague);
        }

        private Lesson 레슨() {
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));

            return lessonRepository.save(Lesson.create("레슨1", unit.getId()));
        }

        private LearningSubmissionSaveRequest 정답_제출(
                long lessonId,
                int accuracy
        ) {
            Problem problem = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "설명하시오.", "큐의 특성은?", lessonId));

            return new LearningSubmissionSaveRequest(
                    new LessonSubmissionSaveRequest(lessonId, 120, accuracy),
                    List.of(new ProblemSubmissionSaveRequest(problem.getId(), true, null, "FIFO"))
            );
        }

        @Test
        void 제출_직후_조회하면_리그_보상이_반영된_리그명을_반환한다() {
            // given
            User user = 유저();
            브론즈로_리그에_참여시킨다(user, 승급_직전_LP);
            learningRepository.save(Learning.create(user.getId()));
            Lesson lesson = 레슨();
            LearningSubmissionSaveRequest request = 정답_제출(lesson.getId(), 100);

            // when
            LessonSubmissionSaveResponse saved = lessonFacade.saveLessonSubmission(user.getId(), request);
            LessonResultResponse result = lessonFacade.getLessonResult(user.getId(), saved.lessonSubmissionId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.leagueName()).isEqualTo("실버");
                softly.assertThat(result.unitSummaryResponse().title()).isEqualTo("프로세스");
            });
        }

        @Test
        void 같은_레슨을_다시_제출하면_서로_다른_제출_아이디를_반환한다() {
            // given
            User user = 유저();
            브론즈로_리그에_참여시킨다(user, 승급_직전_LP);
            learningRepository.save(Learning.create(user.getId()));
            Lesson lesson = 레슨();

            // when
            LessonSubmissionSaveResponse first = lessonFacade.saveLessonSubmission(user.getId(), 정답_제출(lesson.getId(), 100));
            LessonSubmissionSaveResponse second = lessonFacade.saveLessonSubmission(user.getId(), 정답_제출(lesson.getId(), 80));

            // then
            assertSoftly(softly -> {
                softly.assertThat(second.lessonSubmissionId()).isNotEqualTo(first.lessonSubmissionId());
                softly.assertThat(lessonSubmissionRepository.findAll()).hasSize(2);
            });
        }

        @Test
        void 타인의_제출_아이디로_조회하면_실패한다() {
            // given
            User user = 유저();
            Lesson lesson = 레슨();
            LessonSubmission submission = lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson.getId(), user.getId()));

            // when & then
            assertThatThrownBy(() -> lessonFacade.getLessonResult(OTHER_USER_ID, submission.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LESSON_SUBMISSION_NOT_FOUND);
        }
    }
}
