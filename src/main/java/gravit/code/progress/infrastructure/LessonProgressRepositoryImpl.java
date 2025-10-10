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
    public Optional<LessonProgress> findByLessonIdAndUserId(
            long lessonId,
            long userId
    ){
        return lessonProgressJpaRepository.findByLessonIdAndUserId(lessonId, userId);
    }

    @Override
    public List<LessonProgressSummaryResponse> findLessonProgressSummaryByUnitIdAndUserId(
            long unitId,
            long userId
    ){
        return lessonProgressJpaRepository.findLessonProgressSummaryByUnitIdAndUserId(unitId, userId);
    }

    @Override
    public long countByUserId(long userId){
        return lessonProgressJpaRepository.countByUserId(userId);
    }

    @Override
    public void saveAll(List<LessonProgress> lessonProgresses){
        lessonProgressJpaRepository.saveAll(lessonProgresses);
    }
}
