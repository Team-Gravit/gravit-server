package gravit.code.lesson.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.common.LearningIds;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.dto.response.LessonSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonQueryService {

    private final LessonRepository lessonRepository;

    @Transactional(readOnly = true)
    public List<LessonSummary> getAllLessonInUnit(
            long userId,
            long unitId
    ) {
        return lessonRepository.findAllLessonSummaryByUnitId(unitId, userId);
    }

    @Transactional(readOnly = true)
    public LearningIds getLearningIdsByLessonId(long lessonId){
        return lessonRepository.findLearningIdsByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
    }

}
