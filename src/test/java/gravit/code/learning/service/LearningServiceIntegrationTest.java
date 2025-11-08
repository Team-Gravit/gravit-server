package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.*;
import gravit.code.learning.dto.StreakDto;
import gravit.code.learning.fixture.ChapterFixture;
import gravit.code.learning.fixture.LearningFixture;
import gravit.code.learning.fixture.LessonFixture;
import gravit.code.learning.fixture.LessonProgressFixture;
import gravit.code.progress.domain.LessonProgress;
import gravit.code.progress.domain.LessonProgressRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixtureBuilder;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
class LearningServiceIntegrationTest {

    @Autowired
    private LearningService learningService;

    @Autowired
    private LearningRepository learningRepository;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonProgressRepository lessonProgressRepository;

    @Nested
    @DisplayName("연속학습일을 업데이트할 때")
    class UpdateConsecutiveDays{

        User learningUser;
        Learning user1Learning;

        User notLearningUser;
        Learning user2Learning;

        @BeforeEach
        void setUp(){
            // 학습 진행 유저
            learningUser =  UserFixtureBuilder.builder().buildWithId(1L);
            user1Learning = LearningFixture.당일_학습_완료(learningUser.getId());
            learningRepository.save(user1Learning);

            // 학습 미진행 유저
            notLearningUser = UserFixtureBuilder.builder().buildWithId(2L);
            user2Learning = LearningFixture.당일_학습_미완료(notLearningUser.getId());
            learningRepository.save(user2Learning);
       }

        @Test
        void 당일_학습_미완료자는_연속학습일수가_0으로_초기화된다(){
            //given
            //when
            learningService.updateConsecutiveDays();

            //then
            assertThat(learningRepository.findByUserId(notLearningUser.getId()).get().getConsecutiveDays()).isZero();
        }
    }

    @Nested
    @DisplayName("사용자가 학습을 완료하여 학습 정보를 업데이트할 때")
    class UpdateLearning{

        User user1WithLearning;
        User user1WithNoLearning;

        Chapter chapter;

        Lesson lesson1;
        Lesson lesson2;
        Lesson lesson3;
        Lesson lesson4;
        Lesson lesson5;

        LessonProgress lesson1Progress;
        LessonProgress lesson2Progress;
        LessonProgress lesson3Progress;

        Learning learning1;

        @BeforeEach
        void setUp(){
            user1WithLearning = UserFixtureBuilder.builder().buildWithId(1L);
            user1WithNoLearning = UserFixtureBuilder.builder().buildWithId(2L);

            chapter = ChapterFixture.기본_챕터();
            chapterRepository.save(chapter);

            lesson1 = LessonFixture.기본_레슨(1L);
            lesson2 = LessonFixture.기본_레슨(1L);
            lesson3 = LessonFixture.기본_레슨(1L);
            lesson4 = LessonFixture.기본_레슨(1L);
            lesson5 = LessonFixture.기본_레슨(1L);

            lessonRepository.saveAll(List.of(lesson1, lesson2, lesson3, lesson4, lesson5));

            lesson1Progress = LessonProgressFixture.일반_레슨_진행도(user1WithLearning.getId(), lesson1.getId());
            lesson2Progress = LessonProgressFixture.일반_레슨_진행도(user1WithLearning.getId(), lesson2.getId());
            lesson3Progress = LessonProgressFixture.일반_레슨_진행도(user1WithLearning.getId(), lesson3.getId());

            lessonProgressRepository.saveAll(List.of(lesson1Progress, lesson2Progress, lesson3Progress));

            learning1 = LearningFixture.기본_학습_정보(user1WithLearning.getId());
            learningRepository.save(learning1);
        }

        @Test
        void 학습_정보_업데이트에_성공한다(){
            //given

            //when
            StreakDto streakDto =  learningService.updateLearningStatus(user1WithLearning.getId(), chapter.getId());

            //then
            assertThat(learningRepository.findByUserId(user1WithLearning.getId())).satisfies( l ->{
                assertThat(l.get()).isNotNull();
                assertThat(l.get().getRecentChapterId()).isEqualTo(chapter.getId());
                assertThat(l.get().getPlanetConquestRate()).isEqualTo(60);
            });
            assertThat(streakDto.before()).isEqualTo(streakDto.after());
        }

        @Test
        void 학습_정보_조회에_실패하면_예외를_반환한다(){
            //given

            //when & then
            assertThatThrownBy(() -> learningService.updateLearningStatus(user1WithNoLearning.getId(), chapter.getId()))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.LEARNING_NOT_FOUND);

        }
    }

    @Nested
    @DisplayName("학습 정보를 생성할 때")
    class CreateLearning{

        @Test
        void 학습_정보_생성에_성공한다(){
            //given
            long userId = 1L;

            //when
            learningService.createLearning(userId);

            //then
            assertThat(learningRepository.findByUserId(userId)).satisfies(l -> {
                assertThat(l.get()).isNotNull();
                assertThat(l.get().getUserId()).isEqualTo(userId);
                assertThat(l.get().getRecentChapterId()).isZero();
                assertThat(l.get().isTodaySolved()).isFalse();
                assertThat(l.get().getConsecutiveDays()).isZero();
                assertThat(l.get().getPlanetConquestRate()).isZero();
                assertThat(l.get().getVersion()).isZero();
            });
        }

        @Test
        void 이미_학습_정보가_존재하면_예외를_반환한다(){
            //given
            long userId = 2L;
            Learning learning = LearningFixture.기본_학습_정보(2L);
            learningRepository.save(learning);

            //when & then
            assertThatThrownBy(() -> learningService.createLearning(userId))
                    .isInstanceOf(DataAccessException.class);
        }
    }
}