package gravit.code.progress.infrastructure;

import gravit.code.progress.domain.LessonProgress;
import gravit.code.progress.domain.LessonProgressRepository;
import gravit.code.progress.dto.response.LessonProgressSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class LessonProgressRepositoryImpl implements LessonProgressRepository {

    private final LessonProgressJpaRepository lessonProgressJpaRepository;

    @Override
    public LessonProgress save(LessonProgress lessonProgress){
        return lessonProgressJpaRepository.save(lessonProgress);
    }

    @Override
    public Optional<LessonProgress> findByLessonIdAndUserId(Long lessonId, Long userId){
        return lessonProgressJpaRepository.findByLessonIdAndUserId(lessonId, userId);
    }

    @Override
    public List<LessonProgressSummaryResponse> findLessonProgressSummaryByUnitIdAndUserId(Long unitId, Long userId){
        return lessonProgressJpaRepository.findLessonProgressSummaryByUnitIdAndUserId(unitId, userId);
    }

}
