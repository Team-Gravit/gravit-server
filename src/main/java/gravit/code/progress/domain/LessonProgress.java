package gravit.code.progress.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "lesson_progress")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class LessonProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "attempt_count", columnDefinition = "integer", nullable = false)
    private int attemptCount;

    @Column(name = "learning_time", columnDefinition = "integer", nullable = false)
    private int learningTime;

    @Column(name = "is_completed", columnDefinition = "boolean", nullable = false)
    private boolean isCompleted;

    @Column(name = "user_id",columnDefinition = "bigint", nullable = false)
    private long userId;

    @Column(name = "lesson_id",columnDefinition = "bigint", nullable = false)
    private long lessonId;

    @Builder
    private LessonProgress(long userId, long lessonId) {
        this.userId = userId;
        this.attemptCount = 0;
        this.learningTime = 0;
        this.lessonId = lessonId;
        this.isCompleted = false;
    }

    public static LessonProgress create(long userId, long lessonId) {
        return LessonProgress.builder()
                .userId(userId)
                .lessonId(lessonId)
                .build();
    }

    public void updateStatus(int learningTime){
        this.attemptCount += 1;
        this.learningTime = learningTime;
        this.isCompleted = true;
    }
}