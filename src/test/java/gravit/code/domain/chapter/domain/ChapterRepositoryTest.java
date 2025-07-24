package gravit.code.domain.chapter.domain;

import gravit.code.domain.chapterProgress.domain.ChapterProgress;
import gravit.code.domain.chapterProgress.domain.ChapterProgressRepository;
import gravit.code.domain.learning.dto.response.RecentLearningInfo;
import gravit.code.domain.lesson.domain.Lesson;
import gravit.code.domain.lesson.domain.LessonRepository;
import gravit.code.domain.problem.domain.Problem;
import gravit.code.domain.problem.domain.ProblemRepository;
import gravit.code.domain.problem.domain.ProblemType;
import gravit.code.domain.problemProgress.domain.ProblemProgress;
import gravit.code.domain.problemProgress.domain.ProblemProgressRepository;
import gravit.code.domain.unit.domain.Unit;
import gravit.code.domain.unit.domain.UnitRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@EnableJpaAuditing
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class ChapterRepositoryTest {

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private ProblemRepository problemRepository;

    @Autowired
    private ChapterProgressRepository chapterProgressRepository;

    @Autowired
    private ProblemProgressRepository problemProgressRepository;

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
    @DisplayName("최근에 푼 문제를 통해, 사용자의 최근 학습 정보를 조회한다.")
    void getRecentLearningInfoWithRecentlySolvedProblem(){
        //given
        Long userId = 1L;

        //when
        Optional<RecentLearningInfo> recentLearningInfo = chapterRepository.findRecentLearningChapter(userId);

        //then
        assertThat(recentLearningInfo).isPresent();
        assertThat(recentLearningInfo.get().chapterName()).isEqualTo("자료구조");
        assertThat(recentLearningInfo.get().chapterDescription()).isEqualTo("스택, 큐, 힙과 같은 자료구조에 대해 학습합니다.");
        assertThat(recentLearningInfo.get().totalUnits()).isEqualTo(10L);
        assertThat(recentLearningInfo.get().completedUnits()).isEqualTo(1L);
    }

    @Test
    @DisplayName("가장 최근에 푼 문제가 없다면, Optional.empty()를 반환한다.")
    void getRecentLearningInfoWithNoRecentlySolvedProblem(){
        //given
        Long userId = 2L;

        //when
        Optional<RecentLearningInfo> recentLearningInfo = chapterRepository.findRecentLearningChapter(userId);

        //then
        assertThat(recentLearningInfo).isNotPresent();
    }

    @Test
    @DisplayName("chapterId로 totalUnits를 조회할 수 있다.")
    void getTotalUnitsByChapterId(){
        //given
        Long chapterId = 1L;

        //when
        Long totalUnits = chapterRepository.getTotalUnitsByChapterId(chapterId);

        //then
        assertThat(totalUnits).isEqualTo(10L);
    }
}