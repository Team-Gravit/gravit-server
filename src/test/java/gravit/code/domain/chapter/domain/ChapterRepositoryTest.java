package gravit.code.domain.chapter.domain;

import gravit.code.domain.chapter.infrastructure.ChapterJpaRepository;
import gravit.code.domain.chapterProgress.domain.ChapterProgress;
import gravit.code.domain.chapterProgress.infrastructure.ChapterProgressJpaRepository;
import gravit.code.domain.lesson.domain.Lesson;
import gravit.code.domain.lesson.infrastructure.LessonJpaRepository;
import gravit.code.domain.problem.domain.Problem;
import gravit.code.domain.problem.domain.ProblemType;
import gravit.code.domain.problem.infrastructure.ProblemJpaRepository;
import gravit.code.domain.problemProgress.domain.ProblemProgress;
import gravit.code.domain.problemProgress.infrastructure.ProblemProgressJpaRepository;
import gravit.code.domain.unit.domain.Unit;
import gravit.code.domain.unit.infrastructure.UnitJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.test.annotation.DirtiesContext;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@EnableJpaAuditing
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
class ChapterRepositoryTest {

    @Autowired
    private ChapterJpaRepository chapterRepository;

    @Autowired
    private UnitJpaRepository unitRepository;

    @Autowired
    private LessonJpaRepository lessonRepository;

    @Autowired
    private ProblemJpaRepository problemRepository;

    @Autowired
    private ChapterProgressJpaRepository chapterProgressRepository;

    @Autowired
    private ProblemProgressJpaRepository problemProgressRepository;

    @BeforeEach
    void setUp(){

        Chapter chapter = Chapter.create(
                "자료구조", "스택, 큐, 힙과 같은 자료구조에 대해 학습합니다.", 10L
        );
        chapterRepository.save(chapter);

        Unit unit = Unit.create(
                "스택", 3L, chapter.getId()
        );
        unitRepository.save(unit);

        Lesson lesson = Lesson.create(
            "스택(1/3)", 12L, unit.getId()
        );
        lessonRepository.save(lesson);

        Problem problem = Problem.create(
            ProblemType.FILL_BLANK, "질문1", "정답1", "-", lesson.getId()
        );
        problemRepository.save(problem);

        ChapterProgress chapterProgress = ChapterProgress.create(
                10L, 1L, chapter.getId()
        );
        chapterProgressRepository.save(chapterProgress);

        ProblemProgress problemProgress1 = ProblemProgress.create(
                true, 0L, 1L, problem.getId()
        );

        ProblemProgress problemProgress2 = ProblemProgress.create(
                true, 0L, 1L, problem.getId()
        );

        List<ProblemProgress> problemProgressList = List.of(problemProgress1, problemProgress2);
        problemProgressRepository.saveAll(problemProgressList);
    }


    @Test
    @DisplayName("chapterId로 totalUnits를 조회할 수 있다.")
    void getTotalUnitsByChapterId(){
        //given
        Long chapterId = 1L;

        //when
        Long totalUnits = chapterRepository.findTotalUnitsByChapterId(chapterId);

        //then
        assertThat(totalUnits).isEqualTo(10L);
    }
}