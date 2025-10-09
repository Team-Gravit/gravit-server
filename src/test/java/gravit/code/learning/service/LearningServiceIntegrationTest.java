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

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
class LearningServiceIntegrationTest {

    @Autowired
    private LearningService learningService;

    @Autowired
    private LearningRepository learningRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonProgressRepository lessonProgressRepository;

    @Autowired
    private LearningFixture learningFixture;

    @Autowired
    private UserFixtureBuilder userFixtureBuilder;

    @Autowired
    private LessonProgressFixture lessonProgressFixture;

    @Autowired
    private LessonFixture lessonFixture;

    @Autowired
    private ChapterFixture chapterFixture;


    @Nested
    @DisplayName("연속학습일을 업데이트할 때")
    class UpdateConsecutiveDays{

        User learningUser;
        Learning user1Learning;

        User notLearningUser;
        Learning user2Learning;

        @BeforeEach
        void setUp(){
            // 학습 비진행 유저
            learningUser =  userFixtureBuilder.buildWithId(1L);
            user1Learning = learningFixture.당일_학습_완료(learningUser.getId());

            // 학습 진행 유저
            notLearningUser = userFixtureBuilder.buildWithId(2L);
            user2Learning = learningFixture.당일_학습_미완료(notLearningUser.getId());
       }

        @Test
        void 당일_학습_완료자는_연속학습일수가_1만큼_증가한다(){
            //given
            //when
            learningService.updateConsecutiveDays();

            //then
            assertThat(learningRepository.findByUserId(learningUser.getId()).get().getConsecutiveDays()).isEqualTo(user1Learning.getConsecutiveDays()+1);
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
    @DisplayName("사용자가 학습을 완료하여 학습 정보를 업데이트할 떄")
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
            user1WithLearning = userFixtureBuilder.buildWithId(1L);
            user1WithNoLearning = userFixtureBuilder.buildWithId(2L);

            chapter = chapterFixture.기본_챕터();

            lesson1 = lessonFixture.기본_레슨(1L);
            lesson2 = lessonFixture.기본_레슨(1L);
            lesson3 = lessonFixture.기본_레슨(1L);
            lesson4 = lessonFixture.기본_레슨(1L);
            lesson5 = lessonFixture.기본_레슨(1L);

            lesson1Progress = lessonProgressFixture.일반_레슨_진행도(user1WithLearning.getId(), lesson1.getId());
            lesson2Progress = lessonProgressFixture.일반_레슨_진행도(user1WithLearning.getId(), lesson2.getId());
            lesson3Progress = lessonProgressFixture.일반_레슨_진행도(user1WithLearning.getId(), lesson3.getId());

            learning1 = learningFixture.기본_학습_정보(user1WithLearning.getId());
        }

        @Test
        void 학습_정보_업데이트에_성공한다(){
            //given

            //when
            StreakDto streakDto =  learningService.updateLearningStatus(user1WithLearning.getId(), chapter.getId());

            //then
            assertThat(learningRepository.findByUserId(user1WithLearning.getId()).get()).satisfies( l ->{
                assertThat(l.getRecentChapterId()).isEqualTo(chapter.getId());
                assertThat(l.getPlanetConquestRate()).isEqualTo(60);
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
}