package gravit.code.lesson.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.common.LearningIds;
import gravit.code.lesson.domain.LessonRepository;
import gravit.code.lesson.dto.response.LessonSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonService {

    private final LessonRepository lessonRepository;

    @Transactional(readOnly = true)
    public LearningIds getLearningIdsByLessonId(long lessonId){
        return lessonRepository.findLearningIdsByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public List<LessonSummary> getAllLessonByUnitId(
            long userId,
            long unitId
    ) {
        return lessonRepository.findAllLessonSummaryByUnitId(unitId, userId);
    }
}
