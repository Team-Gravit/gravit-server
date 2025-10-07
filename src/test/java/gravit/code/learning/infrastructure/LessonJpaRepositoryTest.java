package gravit.code.learning.infrastructure;

import gravit.code.support.TCRepositoryTest;
import gravit.code.learning.domain.Chapter;
import gravit.code.learning.domain.Lesson;
import gravit.code.learning.domain.Unit;
import gravit.code.learning.dto.LearningAdditionalInfo;
import gravit.code.learning.dto.LearningIds;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@TCRepositoryTest
class LessonJpaRepositoryTest {

    @Autowired
    private LessonJpaRepository lessonJpaRepository;

    @Autowired
    private ChapterJpaRepository chapterJpaRepository;

    @Autowired
    private UnitJpaRepository unitJpaRepository;

    @BeforeEach
    void setUpTest(){
        Chapter chapter = Chapter.create("챕터1", "설명1", 10);
        chapterJpaRepository.save(chapter);

        Unit unit1 = Unit.create("유닛1", 1L, chapter.getId());
        Unit unit2 = Unit.create("유닛2", 1L, chapter.getId());
        Unit unit3 = Unit.create("유닛3", 1L, chapter.getId());
        Unit unit4 = Unit.create("유닛4", 1L, chapter.getId());
        Unit unit5 = Unit.create("유닛5", 1L, chapter.getId());
        Unit unit6 = Unit.create("유닛6", 1L, chapter.getId());
        Unit unit7 = Unit.create("유닛7", 1L, chapter.getId());
        Unit unit8 = Unit.create("유닛8", 1L, chapter.getId());
        Unit unit9 = Unit.create("유닛9", 1L, chapter.getId());
        Unit unit10 = Unit.create("유닛10", 1L, chapter.getId());

        List<Unit> dummyUnits = List.of(
                unit1, unit2, unit3, unit4, unit5,
                unit6, unit7, unit8, unit9, unit10
        );
        unitJpaRepository.saveAll(dummyUnits);

        Lesson lesson1 = Lesson.create("레슨1", 1L, unit1.getId());
        Lesson lesson2 = Lesson.create("레슨2", 1L, unit2.getId());
        Lesson lesson3 = Lesson.create("레슨3", 1L, unit3.getId());
        Lesson lesson4 = Lesson.create("레슨4", 1L, unit4.getId());
        Lesson lesson5 = Lesson.create("레슨5", 1L, unit5.getId());
        Lesson lesson6 = Lesson.create("레슨6", 1L, unit6.getId());
        Lesson lesson7 = Lesson.create("레슨7", 1L, unit7.getId());
        Lesson lesson8 = Lesson.create("레슨8", 1L, unit8.getId());
        Lesson lesson9 = Lesson.create("레슨9", 1L, unit9.getId());
        Lesson lesson10 = Lesson.create("레슨10", 1L, unit10.getId());

        List<Lesson> dummyLessons = List.of(
                lesson1, lesson2, lesson3, lesson4, lesson5,
                lesson6, lesson7, lesson8, lesson9, lesson10
        );

        lessonJpaRepository.saveAll(dummyLessons);
    }

    @Nested
    @DisplayName("레슨 아이디로 레슨이 속한 유닛, 챕터, 레슨 아이디를 조회할 때")
    class FindLearningIdsByLessonId {

        @Test
        void 챕터_유닛_레슨_아이디를_성공적으로_조회한다(){
            //given
            long validLessonId = 1L;
            long unitId = 1L;
            long chapterId = 1L;

            //when
            Optional<LearningIds> learningIds = lessonJpaRepository.findLearningIdsByLessonId(validLessonId);

            //then
            assertThat(learningIds).isPresent();

            assertThat(learningIds.get().lessonId()).isEqualTo(validLessonId);
            assertThat(learningIds.get().unitId()).isEqualTo(unitId);
            assertThat(learningIds.get().chapterId()).isEqualTo(chapterId);
        }

        @Test
        void 레슨_아이디가_유효하지_않으면_조회에_실패한다(){
            //given
            long invalidLessonId = 999L;

            //when
            Optional<LearningIds> learningIds = lessonJpaRepository.findLearningIdsByLessonId(invalidLessonId);

            //then
            assertThat(learningIds).isNotPresent();
        }
    }

    @Nested
    @DisplayName("레슨 아이디로 레슨 이름을 조회할 때")
    class FindLessonNameByLessonId{

        @Test
        void 레슨_이름을_성공적으로_조회한다(){
            //given
            long validLessonId = 1L;

            //when
            Optional<String> lessonName = lessonJpaRepository.findLessonNameByLessonId(validLessonId);

            //then
            assertThat(lessonName).isPresent();
            assertThat(lessonName.get()).isEqualTo("레슨1");
        }

        @Test
        void 레슨_아이디가_유효하지_않으면_조회에_실패한다(){
            //given
            long invalidLessonId = 999L;

            //when
            Optional<String> lessonName = lessonJpaRepository.findLessonNameByLessonId(invalidLessonId);

            //then
            assertThat(lessonName).isNotPresent();
        }
    }

    @Nested
    @DisplayName("레슨 아이디로 학습 부가 정보를 조회할 때")
    class FindLearningAdditionalInfoByLessonId{

        @Test
        void 학습_부가_정보_조회에_성공한다(){
            //given
            long validLessonId = 1L;

            //when
            Optional<LearningAdditionalInfo> learningAdditionalInfo = lessonJpaRepository.findLearningAdditionalInfoByLessonId(validLessonId);

            //then
            assertThat(learningAdditionalInfo).isPresent();

            assertThat(learningAdditionalInfo.get().chapterId()).isEqualTo(1L);
            assertThat(learningAdditionalInfo.get().lessonName()).isEqualTo("레슨1");
        }

        @Test
        void 레슨_아이디가_유효하지_않으면_조회에_실패한다(){
            //given
            long invalidLessonId = 999L;

            //when
            Optional<LearningAdditionalInfo> learningAdditionalInfo = lessonJpaRepository.findLearningAdditionalInfoByLessonId(invalidLessonId);

            //then
            assertThat(learningAdditionalInfo).isNotPresent();
        }
    }
}
