package gravit.code.lesson.service;

import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LessonSubmissionCommandService {

    private final LessonSubmissionRepository lessonSubmissionRepository;

    @Transactional
    public void saveLessonSubmission(
        long userId,
        LessonSubmissionSaveRequest request
    ) {
        LessonSubmission lessonSubmission = LessonSubmission.create(
                request.learningTime(),
                request.accuracy(),
                request.lessonId(),
                userId
        );

        lessonSubmissionRepository.save(lessonSubmission);
    }
}
