package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Chapter;
import gravit.code.learning.domain.Unit;
import gravit.code.learning.dto.LearningAdditionalInfo;
import gravit.code.learning.dto.LearningIds;
import gravit.code.learning.fixture.ChapterFixture;
import gravit.code.learning.fixture.LessonFixture;
import gravit.code.learning.fixture.UnitFixture;
import gravit.code.support.TCRepositoryTest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@TCRepositoryTest
class LessonJpaRepositoryTest {

    @Autowired
    private LessonJpaRepository lessonJpaRepository;

    @Autowired
    private ChapterJpaRepository chapterJpaRepository;

    @Autowired
    private ChapterFixture chapterFixture;

    @Autowired
    private LessonFixture lessonFixture;

    @Autowired
    private UnitFixture unitFixture;

    @BeforeEach
    void setUpTest(){
        Chapter chapter = chapterFixture.기본_챕터();
        chapterJpaRepository.save(chapter);

        Unit unit1 = unitFixture.기본_유닛(chapter.getId());
        Unit unit2 = unitFixture.기본_유닛(chapter.getId());
        Unit unit3 = unitFixture.기본_유닛(chapter.getId());
        Unit unit4 = unitFixture.기본_유닛(chapter.getId());
        Unit unit5 = unitFixture.기본_유닛(chapter.getId());
        Unit unit6 = unitFixture.기본_유닛(chapter.getId());
        Unit unit7 = unitFixture.기본_유닛(chapter.getId());
        Unit unit8 = unitFixture.기본_유닛(chapter.getId());
        Unit unit9 = unitFixture.기본_유닛(chapter.getId());
        Unit unit10 = unitFixture.기본_유닛(chapter.getId());

        lessonFixture.기본_레슨(unit1.getId());
        lessonFixture.기본_레슨(unit2.getId());
        lessonFixture.기본_레슨(unit3.getId());
        lessonFixture.기본_레슨(unit4.getId());
        lessonFixture.기본_레슨(unit5.getId());
        lessonFixture.기본_레슨(unit6.getId());
        lessonFixture.기본_레슨(unit7.getId());
        lessonFixture.기본_레슨(unit8.getId());
        lessonFixture.기본_레슨(unit9.getId());
        lessonFixture.기본_레슨(unit10.getId());
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
