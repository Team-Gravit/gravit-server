package gravit.code.lesson.service;

import gravit.code.lesson.repository.LessonSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LessonSubmissionQueryService {

    private final LessonSubmissionRepository lessonSubmissionRepository;

    @Transactional(readOnly = true)
    public int getLessonSubmissionCount(
            long userId,
            long lessonId
    ) {
        return lessonSubmissionRepository.countLessonSubmissionByLessonIdAndUserId(lessonId, userId);
    }

    @Transactional(readOnly = true)
    public boolean checkFirstLessonSubmission(
            long userId,
            long lessonId
    ) {
        return !lessonSubmissionRepository.existsByLessonIdAndUserId(lessonId, userId);
    }

}
