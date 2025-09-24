package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.LessonRepository;
import gravit.code.learning.dto.LearningIds;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LessonService {
    private final LessonRepository lessonRepository;

    public LearningIds findLearningIdsByLessonId(long lessonId){
        if(!lessonRepository.existsById(lessonId))
            throw new RestApiException(CustomErrorCode.LESSON_NOT_FOUND);

        return lessonRepository.findLearningIdsByLessonId(lessonId);
    }

    public String findLessonName(long lessonId){
        return lessonRepository.findLessonNameByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
    }

}
