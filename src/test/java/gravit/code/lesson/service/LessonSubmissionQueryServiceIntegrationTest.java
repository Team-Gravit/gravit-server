package gravit.code.lesson.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.dto.response.TopChapterResponse;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.learning.dto.response.WeakConceptResponse;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemSubmission;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.problem.repository.ProblemSubmissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class LessonSubmissionQueryServiceIntegrationTest {

    @Autowired
    private LessonSubmissionQueryService lessonSubmissionQueryService;

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

    @Nested
    @DisplayName("레슨 제출 횟수를 조회할 때")
    class GetLessonSubmissionCount {

        @Test
        void 제출_기록이_있으면_횟수를_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson.getId(), userId));

            // when
            int result = lessonSubmissionQueryService.getLessonSubmissionTryCount(userId, lesson.getId());

            // then
            assertThat(result).isEqualTo(1);
        }

        @Test
        void 제출_기록이_없으면_0을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));

            // when
            int result = lessonSubmissionQueryService.getLessonSubmissionTryCount(userId, lesson.getId());

            // then
            assertThat(result).isZero();
        }
    }

    @Nested
    @DisplayName("첫 번째 레슨 제출인지 확인할 때")
    class CheckFirstLessonSubmission {

        @Test
        void 첫_제출이면_true를_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));

            // when
            boolean result = lessonSubmissionQueryService.checkFirstLessonSubmission(userId, lesson.getId());

            // then
            assertThat(result).isTrue();
        }

        @Test
        void 이미_제출한_적이_있으면_false를_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson.getId(), userId));

            // when
            boolean result = lessonSubmissionQueryService.checkFirstLessonSubmission(userId, lesson.getId());

            // then
            assertThat(result).isFalse();
        }
    }

    @Nested
    @DisplayName("완료한 레슨 수를 조회할 때")
    class GetCompletedLessonCount {

        @Test
        void 제출_기록이_여러_개_있으면_그_수를_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Lesson lesson2 = lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 80, lesson1.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(150, 90, lesson2.getId(), userId));

            // when
            int result = lessonSubmissionQueryService.getCompletedLessonCount(userId);

            // then
            assertThat(result).isEqualTo(2);
        }

        @Test
        void 제출_기록이_없으면_0을_반환한다() {
            // given
            long userId = 1L;

            // when
            int result = lessonSubmissionQueryService.getCompletedLessonCount(userId);

            // then
            assertThat(result).isZero();
        }

        @Test
        void 다른_사용자의_제출_기록은_무시된다() {
            // given
            long userId = 1L;
            long otherUserId = 2L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 80, lesson.getId(), otherUserId));

            // when
            int result = lessonSubmissionQueryService.getCompletedLessonCount(userId);

            // then
            assertThat(result).isZero();
        }
    }

    @Nested
    @DisplayName("총 학습 시간을 조회할 때")
    class GetTotalLearningHours {

        @Test
        void 학습_기록이_여러_개면_초를_시간으로_환산하여_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Lesson lesson2 = lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(3600, 80, lesson1.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(1800, 90, lesson2.getId(), userId));

            // when
            double result = lessonSubmissionQueryService.getTotalLearningHours(userId);

            // then
            assertThat(result).isEqualTo(1.5);
        }

        @Test
        void 학습_기록이_없으면_0을_반환한다() {
            // given
            long userId = 1L;

            // when
            double result = lessonSubmissionQueryService.getTotalLearningHours(userId);

            // then
            assertThat(result).isZero();
        }

        @Test
        void 다른_사용자의_학습_시간은_합산되지_않는다() {
            // given
            long userId = 1L;
            long otherUserId = 2L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(3600, 80, lesson.getId(), otherUserId));

            // when
            double result = lessonSubmissionQueryService.getTotalLearningHours(userId);

            // then
            assertThat(result).isZero();
        }
    }

    @Nested
    @DisplayName("평균 정확도를 조회할 때")
    class GetAverageAccuracy {

        @Test
        void 정확도들의_평균을_정수로_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Lesson lesson2 = lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 80, lesson1.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson2.getId(), userId));

            // when
            int result = lessonSubmissionQueryService.getAverageAccuracy(userId);

            // then
            assertThat(result).isEqualTo(90);
        }

        @Test
        void 학습_기록이_없으면_0을_반환한다() {
            // given
            long userId = 1L;

            // when
            int result = lessonSubmissionQueryService.getAverageAccuracy(userId);

            // then
            assertThat(result).isZero();
        }
    }

    @Nested
    @DisplayName("피크 학습 시간을 조회할 때")
    class GetPeakLearningHour {

        @Test
        void 학습_기록이_있으면_가장_많이_학습한_시간을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 80, lesson.getId(), userId));

            // when
            int result = lessonSubmissionQueryService.getPeakLearningHour(userId);

            // then
            assertThat(result).isBetween(0, 23);
        }

        @Test
        void 학습_기록이_없으면_음수_1을_반환한다() {
            // given
            long userId = 1L;

            // when
            int result = lessonSubmissionQueryService.getPeakLearningHour(userId);

            // then
            assertThat(result).isEqualTo(-1);
        }
    }

    @Nested
    @DisplayName("이번 주 TOP 챕터를 조회할 때")
    class GetTopChapters {

        @Test
        void 풀이_수가_많은_순으로_최대_3개의_챕터를_반환한다() {
            // given
            long userId = 1L;
            Chapter ch1 = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Chapter ch2 = chapterRepository.save(Chapter.create("운영체제", "OS 기초"));
            Chapter ch3 = chapterRepository.save(Chapter.create("네트워크", "네트워크 기초"));
            Chapter ch4 = chapterRepository.save(Chapter.create("데이터베이스", "DB 기초"));

            Unit u1 = unitRepository.save(Unit.create("연결리스트", "linked list", ch1.getId()));
            Unit u2 = unitRepository.save(Unit.create("프로세스", "process", ch2.getId()));
            Unit u3 = unitRepository.save(Unit.create("TCP", "tcp", ch3.getId()));
            Unit u4 = unitRepository.save(Unit.create("정규화", "normalization", ch4.getId()));

            Lesson l1a = lessonRepository.save(Lesson.create("레슨1a", u1.getId()));
            Lesson l1b = lessonRepository.save(Lesson.create("레슨1b", u1.getId()));
            Lesson l1c = lessonRepository.save(Lesson.create("레슨1c", u1.getId()));
            Lesson l2 = lessonRepository.save(Lesson.create("레슨2", u2.getId()));
            Lesson l2b = lessonRepository.save(Lesson.create("레슨2b", u2.getId()));
            Lesson l3 = lessonRepository.save(Lesson.create("레슨3", u3.getId()));
            Lesson l4 = lessonRepository.save(Lesson.create("레슨4", u4.getId()));

            lessonSubmissionRepository.save(LessonSubmission.create(60, 80, l1a.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 80, l1b.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 80, l1c.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 80, l2.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 80, l2b.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 80, l3.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 80, l4.getId(), userId));

            // when
            List<TopChapterResponse> result = lessonSubmissionQueryService.getTopChapters(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(3);
                softly.assertThat(result.get(0).rank()).isEqualTo(1);
                softly.assertThat(result.get(0).chapterTitle()).isEqualTo("자료구조");
                softly.assertThat(result.get(0).solvedLessonCount()).isEqualTo(3);
                softly.assertThat(result.get(1).rank()).isEqualTo(2);
                softly.assertThat(result.get(1).chapterTitle()).isEqualTo("운영체제");
                softly.assertThat(result.get(1).solvedLessonCount()).isEqualTo(2);
                softly.assertThat(result.get(2).rank()).isEqualTo(3);
                softly.assertThat(result.get(2).solvedLessonCount()).isEqualTo(1);
            });
        }

        @Test
        void 풀이_기록이_없으면_빈_리스트를_반환한다() {
            // given
            long userId = 1L;

            // when
            List<TopChapterResponse> result = lessonSubmissionQueryService.getTopChapters(userId);

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 다른_사용자의_풀이는_집계되지_않는다() {
            // given
            long userId = 1L;
            long otherUserId = 2L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "linked list", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 80, lesson.getId(), otherUserId));

            // when
            List<TopChapterResponse> result = lessonSubmissionQueryService.getTopChapters(userId);

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("취약 개념을 조회할 때")
    class GetWeakConcepts {

        @Test
        void 오답률이_높은_순으로_최대_7개의_레슨을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "linked list", chapter.getId()));
            Lesson lessonLow = lessonRepository.save(Lesson.create("취약레슨", unit.getId()));
            Lesson lessonHigh = lessonRepository.save(Lesson.create("강한레슨", unit.getId()));

            Problem lowP1 = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지문1", "내용1", lessonLow.getId()));
            Problem lowP2 = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지문2", "내용2", lessonLow.getId()));
            problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지문3", "내용3", lessonLow.getId()));
            problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지문4", "내용4", lessonLow.getId()));
            problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지문5", "내용5", lessonLow.getId()));

            Problem highP1 = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지문6", "내용6", lessonHigh.getId()));
            for (int i = 7; i <= 15; i++) {
                problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지문" + i, "내용" + i, lessonHigh.getId()));
            }

            lessonSubmissionRepository.save(LessonSubmission.create(60, 20, lessonLow.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 90, lessonHigh.getId(), userId));

            problemSubmissionRepository.save(ProblemSubmission.create(false, lowP1.getId(), userId));
            problemSubmissionRepository.save(ProblemSubmission.create(false, lowP2.getId(), userId));
            problemSubmissionRepository.save(ProblemSubmission.create(false, lowP2.getId(), userId));
            problemSubmissionRepository.save(ProblemSubmission.create(false, lowP2.getId(), userId));
            problemSubmissionRepository.save(ProblemSubmission.create(false, highP1.getId(), userId));

            // when
            List<WeakConceptResponse> result = lessonSubmissionQueryService.getWeakConcepts(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(0).rank()).isEqualTo(1);
                softly.assertThat(result.get(0).wrongAnswerCount()).isEqualTo(4);
                softly.assertThat(result.get(0).wrongAnswerRate()).isEqualTo(80);
                softly.assertThat(result.get(1).rank()).isEqualTo(2);
                softly.assertThat(result.get(1).wrongAnswerCount()).isEqualTo(1);
                softly.assertThat(result.get(1).wrongAnswerRate()).isEqualTo(10);
            });
        }

        @Test
        void 풀이_기록이_없으면_빈_리스트를_반환한다() {
            // given
            long userId = 1L;

            // when
            List<WeakConceptResponse> result = lessonSubmissionQueryService.getWeakConcepts(userId);

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 다른_사용자의_풀이는_집계되지_않는다() {
            // given
            long userId = 1L;
            long otherUserId = 2L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "linked list", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지문1", "내용1", lesson.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 20, lesson.getId(), otherUserId));

            // when
            List<WeakConceptResponse> result = lessonSubmissionQueryService.getWeakConcepts(userId);

            // then
            assertThat(result).isEmpty();
        }
    }
}
