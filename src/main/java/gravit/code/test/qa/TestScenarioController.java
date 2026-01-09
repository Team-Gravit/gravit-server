package gravit.code.test.qa;

import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.learning.infrastructure.LearningJpaRepository;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.lesson.facade.LessonFacade;
import gravit.code.lesson.infrastructure.LessonJpaRepository;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.infrastructure.UnitJpaRepository;
import gravit.code.user.domain.User;
import gravit.code.user.infrastructure.UserJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.lang.reflect.Field;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/test")
@RequiredArgsConstructor
public class TestScenarioController {

    private final LessonFacade lessonFacade;
    private final LessonJpaRepository lessonJpaRepository;
    private final UnitJpaRepository unitJpaRepository;
    private final UserJpaRepository userJpaRepository;
    private final LearningJpaRepository learningJpaRepository;

    @PostMapping("/chapter-almost-clear")
    public ResponseEntity<Long> createChapterAlmostClearUser(
            @RequestParam Long userId,
            @RequestParam Long chapterId
    ){
        // 1. 해당 챕터의 유닛들 조회
        List<Unit> units = unitJpaRepository.findAll();
        List<Unit> chapterUnits = units.stream()
                .filter(u -> u.getChapterId() == chapterId)
                .toList();

        // 2. 챕터의 유닛 ID들 추출
        Set<Long> chapterUnitIds = chapterUnits.stream()
                .map(Unit::getId)
                .collect(Collectors.toSet());

        // 3. 해당 유닛들에 속한 레슨들 필터링
        List<Lesson> lessons = lessonJpaRepository.findAll();
        List<Lesson> chapterLessons = lessons.stream()
                .filter(l -> chapterUnitIds.contains(l.getUnitId()))
                .toList();


        // 4. 마지막 레슨을 제외한 모든 레슨 제출
        for (int i = 0; i < chapterLessons.size() - 2; i++) {
            Lesson lesson = chapterLessons.get(i);
            submitLesson(userId, lesson.getId());
        }

        return ResponseEntity.ok(userId);
    }

    private void submitLesson(Long userId, Long lessonId) {
        // 문제 제출 요청 생성 (모두 정답으로)
        List<ProblemSubmissionRequest> problemRequests = List.of();

        LessonSubmissionSaveRequest lessonRequest = new LessonSubmissionSaveRequest(
                lessonId,
                100, // accuracy
                60   // learningTime (초)
        );

        LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(
                lessonRequest,
                problemRequests
        );

        lessonFacade.saveLessonSubmission(userId, request);
    }

    @PostMapping("/consecutive_solved")
    public ResponseEntity<Long> testConsecutiveSolvedUser(
            @RequestParam Long userId,
            @RequestParam int consecutiveSolvedCount
    ) throws Exception {
        User user = userJpaRepository.findById(userId).get();

        Learning learning = learningJpaRepository.findByUserId(user.getId()).get();

        Field todaySolvedField = Learning.class.getDeclaredField("todaySolved");
        todaySolvedField.setAccessible(true);
        todaySolvedField.set(learning, false);

        Field consecutiveSolvedDaysField = Learning.class.getDeclaredField("consecutiveSolvedDays");
        consecutiveSolvedDaysField.setAccessible(true);
        consecutiveSolvedDaysField.setInt(learning, consecutiveSolvedCount);

        learningJpaRepository.save(learning);

        return ResponseEntity.ok(user.getId());
    }
}
