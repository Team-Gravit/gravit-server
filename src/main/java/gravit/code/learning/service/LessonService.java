package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.LessonRepository;
import gravit.code.learning.dto.LearningAdditionalInfo;
import gravit.code.learning.dto.LearningIds;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LessonService {
    private final LessonRepository lessonRepository;

    @Transactional(readOnly = true)
    public LearningIds getLearningIdsByLessonId(long lessonId){
        return lessonRepository.findLearningIdsByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
    }

    public LearningAdditionalInfo getLearningAdditionalInfoByLessonId(long lessonId){
        return lessonRepository.findLearningAdditionalInfoByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
    }
}
