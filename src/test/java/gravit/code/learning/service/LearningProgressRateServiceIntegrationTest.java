package gravit.code.learning.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Transactional
class LearningProgressRateServiceIntegrationTest {

    @Autowired
    private LearningProgressRateService learningProgressRateService;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Autowired
    private UserRepository userRepository;

    @Nested
    @DisplayName("챕터 진행률을 조회할 때")
    class GetChapterProgress {

        @Test
        void 풀이한_레슨이_없으면_0을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonRepository.save(Lesson.create("레슨2", unit.getId()));

            // when
            double result = learningProgressRateService.getChapterProgress(chapter.getId(), userId);

            // then
            assertThat(result).isEqualTo(0.0);
        }

        @Test
        void 일부_레슨을_풀었으면_진행률을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonRepository.save(Lesson.create("레슨3", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson1.getId(), userId));

            // when
            double result = learningProgressRateService.getChapterProgress(chapter.getId(), userId);

            // then
            assertThat(result).isEqualTo(33.0); // floor(1/3 * 100)
        }

        @Test
        void 모든_레슨을_풀었으면_100을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Lesson lesson2 = lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson1.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(90, 100, lesson2.getId(), userId));

            // when
            double result = learningProgressRateService.getChapterProgress(chapter.getId(), userId);

            // then
            assertThat(result).isEqualTo(100.0);
        }
    }

    @Nested
    @DisplayName("유닛 진행률을 조회할 때")
    class GetUnitProgress {

        @Test
        void 풀이한_레슨이_없으면_0을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            lessonRepository.save(Lesson.create("레슨1", unit.getId()));

            // when
            double result = learningProgressRateService.getUnitProgress(unit.getId(), userId);

            // then
            assertThat(result).isEqualTo(0.0);
        }

        @Test
        void 일부_레슨을_풀었으면_진행률을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonRepository.save(Lesson.create("레슨3", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson1.getId(), userId));

            // when
            double result = learningProgressRateService.getUnitProgress(unit.getId(), userId);

            // then
            assertThat(result).isEqualTo(33.0); // floor(1/3 * 100)
        }

        @Test
        void 모든_레슨을_풀었으면_100을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Lesson lesson2 = lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson1.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(90, 100, lesson2.getId(), userId));

            // when
            double result = learningProgressRateService.getUnitProgress(unit.getId(), userId);

            // then
            assertThat(result).isEqualTo(100.0);
        }
    }

    @Nested
    @DisplayName("행성 정복률을 조회할 때")
    class GetPlanetConquestRate {

        @Test
        void 풀이한_레슨이_없으면_0을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonRepository.save(Lesson.create("레슨2", unit.getId()));

            // when
            int result = learningProgressRateService.getPlanetConquestRate(userId);

            // then
            assertThat(result).isEqualTo(0);
        }

        @Test
        void 일부_레슨을_풀었으면_정복률을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonRepository.save(Lesson.create("레슨3", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson1.getId(), userId));

            // when
            int result = learningProgressRateService.getPlanetConquestRate(userId);

            // then
            assertThat(result).isEqualTo(33); // round(1/3 * 100) = 33
        }

        @Test
        void 모든_레슨을_풀었으면_100을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Lesson lesson2 = lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson1.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(90, 100, lesson2.getId(), userId));

            // when
            int result = learningProgressRateService.getPlanetConquestRate(userId);

            // then
            assertThat(result).isEqualTo(100);
        }
    }

    @Nested
    @DisplayName("학습 랭크 백분위를 조회할 때")
    class GetLearningRankPercentile {

        @Test
        void 풀이가_많은_사용자는_상위_백분위를_받는다() {
            // given
            User user1 = userRepository.save(User.create("a@a.com", "p1", "유저1", "user1", 1, Role.USER));
            User user2 = userRepository.save(User.create("b@b.com", "p2", "유저2", "user2", 1, Role.USER));
            User user3 = userRepository.save(User.create("c@c.com", "p3", "유저3", "user3", 1, Role.USER));

            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Lesson lesson2 = lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            Lesson lesson3 = lessonRepository.save(Lesson.create("레슨3", unit.getId()));

            // user1: 3개, user2: 1개, user3: 0개
            lessonSubmissionRepository.save(LessonSubmission.create(60, 100, lesson1.getId(), user1.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 100, lesson2.getId(), user1.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 100, lesson3.getId(), user1.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(60, 100, lesson1.getId(), user2.getId()));

            // when
            int top = learningProgressRateService.getLearningRankPercentile(user1.getId());
            int bottom = learningProgressRateService.getLearningRankPercentile(user3.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(top).isLessThanOrEqualTo(bottom);
                softly.assertThat(top).isBetween(1, 100);
                softly.assertThat(bottom).isEqualTo(100);
            });
        }

        @Test
        void 사용자가_users_테이블에_없으면_100을_반환한다() {
            // given
            long unknownUserId = 999L;

            // when
            int result = learningProgressRateService.getLearningRankPercentile(unknownUserId);

            // then
            assertThat(result).isEqualTo(100);
        }
    }
}
