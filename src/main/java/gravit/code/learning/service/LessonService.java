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

    /**
     * TODO
     * findLearningIdsByLessonId가 Optional.empty()를 반환한다는 것이 레슨 조회에 실패했다는 것을 의미할 수 있는가?
     * Lesson Not Found보다 Invalid LessonId 이렇게 예외 처리를 하는 것이 더 좋아보인다.
     */
    @Transactional(readOnly = true)
    public LearningIds getLearningIdsByLessonId(long lessonId){
        return lessonRepository.findLearningIdsByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
    }

    /**
     * TODO
     * 여기도 위와 동일함.
     */
    public LearningAdditionalInfo getLearningAdditionalInfoByLessonId(long lessonId){
        return lessonRepository.findLearningAdditionalInfoByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
    }
}
