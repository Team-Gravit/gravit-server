package gravit.code.lessonProgress.repository;

import gravit.code.domain.lessonProgress.domain.LessonProgress;
import gravit.code.domain.lessonProgress.domain.LessonProgressRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@EnableJpaAuditing
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class LessonProgressRepositoryTest {

    @Autowired
    private LessonProgressRepository lessonProgressRepository;

    @BeforeEach
    void setUp() {
        LessonProgress lessonProgress = LessonProgress.create(
            1L,
                1L
        );
        lessonProgressRepository.save(lessonProgress);
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
}