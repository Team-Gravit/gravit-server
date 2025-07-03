package gravit.code.userLessonProgress.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "user_lesson_progress")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserLessonProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "completed_problems", columnDefinition = "bigint", nullable = false)
    private Long completedProblems;

    @Column(name = "user_id",columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Column(name = "lesson_id",columnDefinition = "bigint", nullable = false)
    private Long lessonId;

    @Builder
    private UserLessonProgress(Long userId, Long lessonId) {
        this.completedProblems = 0L;
        this.userId = userId;
        this.lessonId = lessonId;
    }

    public static UserLessonProgress create(Long userId, Long lessonId) {
        return UserLessonProgress.builder()
                .userId(userId)
                .lessonId(lessonId)
                .build();
    }
}
