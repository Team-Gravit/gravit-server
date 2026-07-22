package gravit.code.lesson.domain;

import gravit.code.global.entity.BaseEntity;
import gravit.code.global.exception.domain.RestApiException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import static gravit.code.global.exception.domain.CustomErrorCode.INVALID_ACCURACY;

@Table(name = "lesson_submission")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class LessonSubmission extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "learning_time", nullable = false)
    private int learningTime;

    @Column(name = "accuracy", nullable = false)
    private int accuracy;

    @Column(name = "lesson_id", nullable = false)
    private long lessonId;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Builder(access = AccessLevel.PRIVATE)
    private LessonSubmission(
            int learningTime,
            int accuracy,
            long lessonId,
            long userId
    ) {
        validateAccuracy(accuracy);
        this.learningTime = learningTime;
        this.accuracy = accuracy;
        this.lessonId = lessonId;
        this.userId = userId;
    }

    public static LessonSubmission create(
            int learningTime,
            int accuracy,
            long lessonId,
            long userId
    ) {
        return LessonSubmission.builder()
                .learningTime(learningTime)
                .accuracy(accuracy)
                .lessonId(lessonId)
                .userId(userId)
                .build();
    }

    private static void validateAccuracy(int accuracy) {
        if (accuracy < 0 || accuracy > 100) {
            throw new RestApiException(INVALID_ACCURACY);
        }
    }
}