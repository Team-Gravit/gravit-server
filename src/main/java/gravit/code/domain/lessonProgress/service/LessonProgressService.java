package gravit.code.domain.lessonProgress.service;

import gravit.code.domain.lessonProgress.domain.LessonProgress;
import gravit.code.domain.lessonProgress.domain.LessonProgressRepository;
import gravit.code.domain.lessonProgress.dto.response.LessonProgressSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonProgressService {

    private final LessonProgressRepository lessonProgressRepository;

    public void updateLessonProgressStatus(Long lessonId, Long userId){

        LessonProgress lessonProgress = lessonProgressRepository.findByLessonIdAndUserId(userId, lessonId)
                .orElseGet(() -> LessonProgress.create(userId, lessonId, false));

        lessonProgress.updateStatus();
    }

    public List<LessonProgressSummaryResponse> getLessonProgressSummaries(Long userId, Long unitId){
        return lessonProgressRepository.findLessonProgressSummaryByUnitIdAndUserId(userId, unitId);
    }
}
