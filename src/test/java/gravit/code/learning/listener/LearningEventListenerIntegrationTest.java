//package gravit.code.learning.listener;
//
//import gravit.code.learning.domain.*;
//import gravit.code.learning.dto.event.CreateLearningEvent;
//import gravit.code.learning.dto.event.UpdateLearningEvent;
//import gravit.code.learning.fixture.ChapterFixture;
//import gravit.code.learning.fixture.LearningFixture;
//import gravit.code.learning.fixture.LessonFixture;
//import gravit.code.learning.fixture.LessonProgressFixture;
//import gravit.code.learning.service.LearningService;
//import gravit.code.learning.domain.LessonSubmission;
//import gravit.code.learning.domain.LessonSubmissionRepository;
//import gravit.code.support.TCSpringBootTest;
//import gravit.code.user.domain.User;
//import gravit.code.user.fixture.UserFixtureBuilder;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.DisplayName;
//import org.junit.jupiter.api.Nested;
//import org.junit.jupiter.api.Test;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.context.ApplicationEventPublisher;
//import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
//import org.springframework.test.context.transaction.TestTransaction;
//import org.springframework.transaction.annotation.Transactional;
//
//import java.util.List;
//import java.util.concurrent.TimeUnit;
//
//import static org.assertj.core.api.Assertions.assertThat;
//import static org.awaitility.Awaitility.await;
//import static org.mockito.Mockito.verify;
//
//@TCSpringBootTest
//class LearningEventListenerIntegrationTest {
//
//    @Autowired
//    private LearningRepository learningRepository;
//
//    @Autowired
//    private ChapterRepository chapterRepository;
//
//    @Autowired
//    private LessonRepository lessonRepository;
//
//    @Autowired
//    private LessonSubmissionRepository lessonProgressRepository;
//
//    @Autowired
//    private LearningService learningService;
//
//    @Autowired
//    private ApplicationEventPublisher publisher;
//
//    @MockitoSpyBean
//    private LearningEventListener learningEventListener;
//
//    @Nested
//    @DisplayName("유저의 학습정보를 업데이트하는 이벤트가 발행되면")
//    class UpdateLearning {
//
//        User user;
//
//        Chapter chapter;
//
//        Lesson lesson1;
//        Lesson lesson2;
//        Lesson lesson3;
//        Lesson lesson4;
//        Lesson lesson5;
//
//        LessonSubmission lesson1Progress;
//        LessonSubmission lesson2Progress;
//        LessonSubmission lesson3Progress;
//
//        Learning learning;
//
//        @BeforeEach
//        void setUp() {
//            user = UserFixtureBuilder.builder().buildWithId(1L);
//
//            chapter = ChapterFixture.기본_챕터();
//            chapterRepository.save(chapter);
//
//            lesson1 = LessonFixture.기본_레슨(1L);
//            lesson2 = LessonFixture.기본_레슨(1L);
//            lesson3 = LessonFixture.기본_레슨(1L);
//            lesson4 = LessonFixture.기본_레슨(1L);
//            lesson5 = LessonFixture.기본_레슨(1L);
//
//            lessonRepository.saveAll(List.of(lesson1, lesson2, lesson3, lesson4, lesson5));
//
//            lesson1Progress = LessonProgressFixture.일반_레슨_진행도(user.getId(), lesson1.getId());
//            lesson2Progress = LessonProgressFixture.일반_레슨_진행도(user.getId(), lesson2.getId());
//            lesson3Progress = LessonProgressFixture.일반_레슨_진행도(user.getId(), lesson3.getId());
//
//            lessonProgressRepository.saveAll(List.of(lesson1Progress, lesson2Progress, lesson3Progress));
//
//            learning = LearningFixture.기본_학습_정보(user.getId());
//            learningRepository.save(learning);
//        }
//
//        @Test
//        @Transactional
//        void 이벤트를_수신하여_처리하는_메소드가_호출된다() {
//            //given
//            UpdateLearningEvent updateLearningEvent = UpdateLearningEvent.of(user.getId(), chapter.getId());
//            //when
//            publisher.publishEvent(updateLearningEvent);
//
//            TestTransaction.flagForCommit();
//            TestTransaction.end();
//
//            //then
//            await().atMost(2, TimeUnit.SECONDS)
//                    .untilAsserted(() -> {
//                        verify(learningEventListener).updateLearning(updateLearningEvent);
//                    });
//        }
//
//        @Test
//        @Transactional
//        void 유저_학습정보를_성공적으로_업데이트한다() {
//            //given
//            UpdateLearningEvent updateLearningEvent = UpdateLearningEvent.of(user.getId(), chapter.getId());
//
//            //when
//            publisher.publishEvent(updateLearningEvent);
//
//            TestTransaction.flagForCommit();
//            TestTransaction.end();
//
//            //then
//            await().atMost(2, TimeUnit.SECONDS)
//                    .untilAsserted(() -> {
//                        Learning updatedLearning = learningRepository.findByUserId(user.getId()).get();
//
//                        assertThat(updatedLearning.getRecentChapterId()).isEqualTo(chapter.getId());
//                        assertThat(updatedLearning.getPlanetConquestRate()).isEqualTo(60);
//                        assertThat(updatedLearning.isTodaySolved()).isTrue();
//                    });
//        }
//
//        @Test
//        @Transactional
//        void 유저_학습정보_조회에_실패하면_유저_학습_정보가_업데이트되지_않는다() {
//            //given
//            long invalidUserId = 999L;
//            UpdateLearningEvent updateLearningEvent = UpdateLearningEvent.of(invalidUserId, chapter.getId());
//
//            //when
//            publisher.publishEvent(updateLearningEvent);
//
//            TestTransaction.flagForCommit();
//            TestTransaction.end();
//
//            //then
//            await().atMost(2, TimeUnit.SECONDS)
//                    .untilAsserted(() -> {
//                        Learning updatedLearning = learningRepository.findByUserId(user.getId()).get();
//
//                        // 변경사항이 반영되지 않았음을 의미
//                        assertThat(updatedLearning.getPlanetConquestRate()).isEqualTo(learning.getPlanetConquestRate());
//                    });
//        }
//    }
//
//    @Test
//    @Transactional
//    void 유저_학습정보_생성_이벤트가_발행되면_유저_학습정보를_성공적으로_생성한다() {
//        //given
//        long userId = 1L;
//
//        CreateLearningEvent createLearningEvent = CreateLearningEvent.of(userId);
//
//        //when
//        publisher.publishEvent(createLearningEvent);
//
//        TestTransaction.flagForCommit();
//        TestTransaction.end();
//
//        //then
//        await().atMost(2, TimeUnit.SECONDS)
//                .untilAsserted(() -> {
//
//                    // 변경사항이 반영되지 않았음을 의미
//                    assertThat(learningRepository.findByUserId(userId)).satisfies(l -> {
//                        assertThat(l.get()).isNotNull();
//                        assertThat(l.get().getRecentChapterId()).isZero();
//                        assertThat(l.get().getPlanetConquestRate()).isZero();
//                    });
//                });
//    }
//}