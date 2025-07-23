package gravit.code.domain.lessonProgress.infrastructure;

import gravit.code.domain.lessonProgress.domain.LessonProgress;
import gravit.code.domain.lessonProgress.domain.LessonProgressRepository;
import gravit.code.domain.lessonProgress.dto.response.LessonInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class LessonProgressRepositoryImpl implements LessonProgressRepository {

    private final LessonProgressJpaRepository lessonProgressJpaRepository;

    @Override
    public Optional<LessonProgress> findByLessonIdAndUserId(Long lessonId, Long userId){
        return lessonProgressJpaRepository.findByLessonIdAndUserId(lessonId, userId);
    }

    @Override
    public boolean existsByLessonIdAndUserId(Long lessonId, Long userId){
        return lessonProgressJpaRepository.existsByLessonIdAndUserId(lessonId, userId);
    }

    @Override
    public List<LessonInfo> findLessonsWithProgressByUnitId(@Param("userId") Long userId, @Param("unitId") Long unitId){
        return lessonProgressJpaRepository.findLessonsWithProgressByUnitId(userId, unitId);
    }

    @Override
    public LessonProgress save(LessonProgress lessonProgress){
        return lessonProgressJpaRepository.save(lessonProgress);
    }
}
