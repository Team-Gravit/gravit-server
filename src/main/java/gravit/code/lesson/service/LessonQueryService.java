package gravit.code.lesson.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.internal.LearningIdsDto;
import gravit.code.lesson.dto.response.LessonSummaryResponse;
import gravit.code.lesson.repository.LessonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.LESSON_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class LessonQueryService {

    private final LessonRepository lessonRepository;


    @Transactional(readOnly = true)
    public List<LessonSummaryResponse> getAllLessonInUnit(
            long userId,
            long unitId
    ) {
        return lessonRepository.findAllLessonSummaryByUnitId(unitId, userId);
    }

    @Transactional(readOnly = true)
    public LearningIdsDto getLearningIdsByLessonId(long lessonId){
        return lessonRepository.findLearningIdsByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(LESSON_NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public int getTotalLessonCount() {
        return Math.toIntExact(lessonRepository.count());
    }
}
