package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Chapter;
import gravit.code.learning.domain.Unit;
import gravit.code.learning.dto.LearningAdditionalInfo;
import gravit.code.learning.dto.LearningIds;
import gravit.code.learning.fixture.*;
import gravit.code.support.TCRepositoryTest;
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
        Chapter chapter = ChapterFixture.기본_챕터();
        chapterJpaRepository.save(chapter);

        Unit unit1 = UnitFixture.기본_유닛(chapter.getId());
        Unit unit2 = UnitFixture.기본_유닛(chapter.getId());
        Unit unit3 = UnitFixture.기본_유닛(chapter.getId());
        Unit unit4 = UnitFixture.기본_유닛(chapter.getId());
        Unit unit5 = UnitFixture.기본_유닛(chapter.getId());
        Unit unit6 = UnitFixture.기본_유닛(chapter.getId());
        Unit unit7 = UnitFixture.기본_유닛(chapter.getId());
        Unit unit8 = UnitFixture.기본_유닛(chapter.getId());
        Unit unit9 = UnitFixture.기본_유닛(chapter.getId());
        Unit unit10 = UnitFixture.기본_유닛(chapter.getId());

        unitJpaRepository.saveAll(List.of(unit1, unit2, unit3, unit4, unit5, unit6, unit7, unit8, unit9, unit10));

        lessonJpaRepository.saveAll(List.of(
                LessonFixture.기본_레슨(unit1.getId()),
                LessonFixture.기본_레슨(unit2.getId()),
                LessonFixture.기본_레슨(unit3.getId()),
                LessonFixture.기본_레슨(unit4.getId()),
                LessonFixture.기본_레슨(unit5.getId()),
                LessonFixture.기본_레슨(unit6.getId()),
                LessonFixture.기본_레슨(unit7.getId()),
                LessonFixture.기본_레슨(unit8.getId()),
                LessonFixture.기본_레슨(unit9.getId()),
                LessonFixture.기본_레슨(unit10.getId())
        ));
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
            assertThat(lessonName.get()).isEqualTo("레슨이름");
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
            assertThat(learningAdditionalInfo.get().lessonName()).isEqualTo("레슨이름");
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
