package gravit.code.lesson.fixture;

import gravit.code.lesson.domain.LessonSubmission;
import org.springframework.test.util.ReflectionTestUtils;

public class LessonSubmissionFixture {

    public static LessonSubmission 기본_레슨_제출(
            long lessonId,
            long userId
    ) {
        LessonSubmission submission = LessonSubmission.create(120, 100, lessonId, userId);
        ReflectionTestUtils.setField(submission, "id", 1L);
        return submission;
    }

    public static LessonSubmission 저장된_레슨_제출(
            long id,
            long lessonId,
            long userId
    ) {
        LessonSubmission submission = LessonSubmission.create(120, 100, lessonId, userId);
        ReflectionTestUtils.setField(submission, "id", id);
        return submission;
    }

    public static LessonSubmission 저장된_레슨_제출(
            long id,
            int learningTime,
            long lessonId,
            long userId
    ) {
        LessonSubmission submission = LessonSubmission.create(learningTime, 100, lessonId, userId);
        ReflectionTestUtils.setField(submission, "id", id);
        return submission;
    }

    public static LessonSubmission 저장된_레슨_제출(
            long id,
            int learningTime,
            int accuracy,
            long lessonId,
            long userId
    ) {
        LessonSubmission submission = LessonSubmission.create(learningTime, accuracy, lessonId, userId);
        ReflectionTestUtils.setField(submission, "id", id);
        return submission;
    }
}
