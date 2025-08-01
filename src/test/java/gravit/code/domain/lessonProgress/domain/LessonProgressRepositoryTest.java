package gravit.code.domain.lessonProgress.domain;

import gravit.code.domain.lesson.domain.Lesson;
import gravit.code.domain.lesson.infrastructure.LessonJpaRepository;
import gravit.code.domain.lessonProgress.dto.response.LessonProgressSummaryResponse;
import gravit.code.domain.lessonProgress.infrastructure.LessonProgressJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.test.annotation.DirtiesContext;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@EnableJpaAuditing
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
class LessonProgressRepositoryTest {

    @Autowired
    private LessonProgressJpaRepository lessonProgressRepository;

    @Autowired
    private LessonJpaRepository lessonRepository;

    @BeforeEach
    void setUp() {

        Lesson lesson1 = lessonRepository.save(Lesson.create("스택 기초", 10L, 1L));
        Lesson lesson2 = lessonRepository.save(Lesson.create("스택 활용", 8L, 1L));
        Lesson lesson3 = lessonRepository.save(Lesson.create("스택 심화", 12L, 1L));
        Lesson lesson4 = lessonRepository.save(Lesson.create("스택 문제해결", 15L, 1L));

        lessonProgressRepository.save(LessonProgress.create(1L, lesson1.getId(), true));
        lessonProgressRepository.save(LessonProgress.create(1L, lesson2.getId(), true));
        lessonProgressRepository.save(LessonProgress.create(1L, lesson3.getId(), false));
    }

    @Test
    @DisplayName("lessonId와 userId를 통해 LessonProgress를 조회할 수 있다.")
    void getLessonProgressByLessonIdAndUserId(){
        // given
        Long userId = 1L;
        Long lessonId = 1L;

        // when
        Optional<LessonProgress> lessonProgress = lessonProgressRepository.findByLessonIdAndUserId(lessonId, userId);

        // then
        assertThat(lessonProgress).isPresent();
        assertThat(lessonProgress.get().getUserId()).isEqualTo(userId);
        assertThat(lessonProgress.get().getLessonId()).isEqualTo(lessonId);
    }

    @Test
    @DisplayName("lessonId와 userId로 LessonProgress의 존재 여부를 조회할 수 있다")
    void getLessonProgressExistByLessonIdAndUserId1(){
        //given
        Long userId = 1L;
        Long lessonId = 1L;

        //when
        boolean exists = lessonProgressRepository.existsByLessonIdAndUserId(lessonId, userId);

        //then
        assertThat(exists).isTrue();
    }

    @Test
    @DisplayName("lessonId와 userId로 LessonProgress의 존재 여부를 조회할 수 있다")
    void getLessonProgressExistByLessonIdAndUserId2(){
        //given
        Long userId = 222L;
        Long lessonId = 222L;

        //when
        boolean exists = lessonProgressRepository.existsByLessonIdAndUserId(lessonId, userId);

        //then
        assertThat(exists).isFalse();
    }

    @Test
    @DisplayName("unitId와 userId를 통해 진행도를 포함한 Lesson 정보를 조회할 수 있다.")
    void getLessonWithProgressByUserIdAndUnitId(){
        //given
        Long userId = 1L;
        Long unitId = 1L;

        //when
        List<LessonProgressSummaryResponse> lessonSummaryResponses = lessonProgressRepository.findLessonProgressSummaryByUnitIdAndUserId(unitId, userId);

        //then
        assertThat(lessonSummaryResponses).isNotEmpty();

        assertThat(lessonSummaryResponses.get(0).lessonId()).isEqualTo(1L);
        assertThat(lessonSummaryResponses.get(0).isCompleted()).isTrue();

        assertThat(lessonSummaryResponses.get(3).lessonId()).isEqualTo(4L);
        assertThat(lessonSummaryResponses.get(3).isCompleted()).isFalse();
    }
}