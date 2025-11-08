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
     * POINT
     * findLearningIdsByLessonId의 행위는 레슨이 속한 챕터, 유닛 아이디를 조회하는 것이다.
     * 조회에 실패하였다는 것은 챕터, 유닛 아이디 조회의 실패를 의미하기도 하지만, 레슨 아이디가 유효하지 않다는 것을 의미하기도 한다.
     * 따라서, LearningIds 조회에 실패. 즉 해당 레슨이 속한 챕터, 유닛의 아이디 조회에 실패하였음을 알리는게 더 좋아보인다.
     */
    @Transactional(readOnly = true)
    public LearningIds getLearningIdsByLessonId(long lessonId){
        return lessonRepository.findLearningIdsByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
    }

    /**
     * POINT
     * 여기도 위와 동일한 맥락이다.
     */
    public LearningAdditionalInfo getLearningAdditionalInfoByLessonId(long lessonId){
        return lessonRepository.findLearningAdditionalInfoByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
    }
}
