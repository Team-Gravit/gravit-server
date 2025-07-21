package gravit.code.lessonProgress.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.Objects;

@Table(name = "lesson_progress")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class LessonProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "total_problems",columnDefinition = "bigint", nullable = false)
    private Long totalProblems;

    @Column(name = "completed_problems", columnDefinition = "bigint", nullable = false)
    private Long completedProblems;

    @Column(name = "user_id",columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Column(name = "lesson_id",columnDefinition = "bigint", nullable = false)
    private Long lessonId;

    @Builder
    private LessonProgress(Long totalProblems, Long userId, Long lessonId) {
        this.totalProblems = totalProblems;
        this.completedProblems = 0L;
        this.userId = userId;
        this.lessonId = lessonId;
    }

    public static LessonProgress create(Long totalProblems, Long userId, Long lessonId) {
        return LessonProgress.builder()
                .totalProblems(totalProblems)
                .userId(userId)
                .lessonId(lessonId)
                .build();
    }

    public void updateCompletedProblems(Long problemSize){
        this.completedProblems += problemSize;
    }

    public Boolean isLessonCompleted(){
        return Objects.equals(completedProblems, totalProblems);
    }
}
