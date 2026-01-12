package gravit.code.lesson.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LessonSubmissionCommandService {

    private final LessonSubmissionRepository lessonSubmissionRepository;
    private final LessonRepository lessonRepository;

    @Transactional
    public void saveLessonSubmission(
        long userId,
        LessonSubmissionSaveRequest request,
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

}
