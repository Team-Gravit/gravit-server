package gravit.code.lesson.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.lesson.domain.LessonRepository;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.domain.LessonSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LessonSubmissionService {

    private final LessonSubmissionRepository lessonSubmissionRepository;
    private final LessonRepository lessonRepository;

    @Transactional
    public void saveLessonSubmission(
        LessonSubmissionSaveRequest request,
        long userId,
        boolean isFirstTry
    ) {
        if(!lessonRepository.existsById(request.lessonId()))
            throw new RestApiException(CustomErrorCode.LESSON_NOT_FOUND);

        LessonSubmission lessonSubmission;
        if(isFirstTry){
            lessonSubmission = LessonSubmission.create(
                    request.learningTime(),
                    request.lessonId(),
                    userId
            );
        }else{
            lessonSubmission = lessonSubmissionRepository.findByLessonIdAndUserId(request.lessonId(), userId)
                    .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_SUBMISSION_NOT_FOUND));

            lessonSubmission.updateLearningTime(request.learningTime());
            lessonSubmission.updateTryCount();
        }

        lessonSubmissionRepository.save(lessonSubmission);
    }

    @Transactional(readOnly = true)
    public int getLessonSubmissionCount(long lessonId, long userId) {
        return lessonSubmissionRepository.countLessonSubmissionByLessonIdAndUserId(lessonId, userId);
    }

    @Transactional(readOnly = true)
    public boolean checkUserSubmitted(long lessonId, long userId) {
        return lessonSubmissionRepository.existsByLessonIdAndUserId(lessonId, userId);
    }
}
