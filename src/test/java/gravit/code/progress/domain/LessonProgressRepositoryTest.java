package gravit.code.progress.domain;

import gravit.code.learning.domain.Lesson;
import gravit.code.learning.infrastructure.LessonJpaRepository;
import gravit.code.progress.dto.response.LessonProgressSummaryResponse;
import gravit.code.progress.infrastructure.LessonProgressJpaRepository;
import gravit.code.user.domain.User;
import gravit.code.user.infrastructure.UserJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@EnableJpaAuditing
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
@ActiveProfiles("test")
class LessonProgressRepositoryTest {

    @Autowired
    private UserJpaRepository userRepository;

    @Autowired
    private LessonProgressJpaRepository lessonProgressRepository;

    @Autowired
    private LessonJpaRepository lessonRepository;

    @BeforeEach
    void setUp() {
        User validUser = userRepository.save(User.create("test@example.com", "google 123456", "테스트유저", "@test", 1, LocalDateTime.now()));

        Lesson lesson1 = lessonRepository.save(Lesson.create("스택 기본 개념", 10L, 1L));
        Lesson lesson2 = lessonRepository.save(Lesson.create("스택 구현하기", 8L, 1L));
        Lesson lesson3 = lessonRepository.save(Lesson.create("스택 활용 문제", 12L, 1L));
        Lesson lesson4 = lessonRepository.save(Lesson.create("스택 심화 응용", 15L, 1L));

        lessonProgressRepository.save(LessonProgress.create(validUser.getId(), lesson1.getId()));
        lessonProgressRepository.save(LessonProgress.create(validUser.getId(), lesson2.getId()));
        lessonProgressRepository.save(LessonProgress.create(validUser.getId(), lesson3.getId()));
    }

    @Nested
    @DisplayName("LessonProgressSummary를 조회할 때,")
    class FindLessonProgressSummary{

        @Test
        @DisplayName("userId가 유효하지 않으면 빈 리스트를 반환한다.")
        void withInvalidUserId(){
            //given
            Long unitId = 1L;
            Long userId = 111111L;

            //given
            List<LessonProgressSummaryResponse> lessonProgressSummaryResponse = lessonProgressRepository.findLessonProgressSummaryByUnitIdAndUserId(unitId, userId);

            //then
            assertThat(lessonProgressSummaryResponse).hasSize(0);
        }

        @Test
        @DisplayName("userId가 유효하면 정상적으로 반환한다.")
        void withValidUserId(){
            //given
            Long unitId = 1L;
            Long userId = 1L;

            //given
            List<LessonProgressSummaryResponse> lessonProgressSummaryResponse = lessonProgressRepository.findLessonProgressSummaryByUnitIdAndUserId(unitId, userId);

            //then
            assertThat(lessonProgressSummaryResponse).hasSize(4);
            assertThat(lessonProgressSummaryResponse.get(0).isCompleted()).isTrue();
            assertThat(lessonProgressSummaryResponse.get(3).lessonId()).isEqualTo(4L);
        }
    }
}