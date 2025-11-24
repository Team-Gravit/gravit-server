package gravit.code.lesson.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "lesson_submission")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class LessonSubmission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "learning_time", nullable = false)
    private int learningTime;

    @Column(name = "try_count", nullable = false)
    private int tryCount;

    @Column(name = "lesson_id", nullable = false)
    private long lessonId;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Builder(access = AccessLevel.PRIVATE)
    private LessonSubmission(
            int learningTime,
            long lessonId,
            long userId
    ) {
        this.learningTime = learningTime;
        this.tryCount = 1;
        this.lessonId = lessonId;
        this.userId = userId;
    }

    public static LessonSubmission create(
            int learningTime,
            long lessonId,
            long userId
    ) {
        return LessonSubmission.builder()
                .learningTime(learningTime)
                .lessonId(lessonId)
                .userId(userId)
                .build();
    }

    public void updateLearningTime(int learningTime){
        this.learningTime = learningTime;
    }

    public void updateTryCount() {
        this.tryCount++;
    }
}