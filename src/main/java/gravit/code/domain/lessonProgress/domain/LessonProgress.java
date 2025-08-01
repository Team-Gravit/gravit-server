package gravit.code.domain.lessonProgress.domain;

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

    @Column(name = "is_completed", columnDefinition = "boolean", nullable = false)
    private boolean isCompleted;

    @Column(name = "user_id",columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Column(name = "lesson_id",columnDefinition = "bigint", nullable = false)
    private Long lessonId;

    @Builder
    private LessonProgress(Long userId, Long lessonId, boolean isCompleted) {
        this.userId = userId;
        this.lessonId = lessonId;
        this.isCompleted = isCompleted;
    }

    public static LessonProgress create(Long userId, Long lessonId, boolean isCompleted) {
        return LessonProgress.builder()
                .userId(userId)
                .lessonId(lessonId)
                .isCompleted(isCompleted)
                .build();
    }

    public void updateStatus(){
        this.isCompleted = true;
    }
}
