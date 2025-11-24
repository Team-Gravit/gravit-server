package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Lesson;
import gravit.code.learning.domain.LessonRepository;
import gravit.code.learning.dto.common.LearningAdditionalInfo;
import gravit.code.learning.dto.common.LearningIds;
import gravit.code.learning.dto.response.LessonSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class LessonRepositoryImpl implements LessonRepository {

    private final LessonJpaRepository lessonJpaRepository;

    @Override
    public Optional<Lesson> findById(long lessonId){
        return lessonJpaRepository.findById(lessonId);
    }

    @Override
    public Optional<LearningIds> findLearningIdsByLessonId(long lessonId){
        return lessonJpaRepository.findLearningIdsByLessonId(lessonId);
    }

    @Override
    public Optional<LearningAdditionalInfo> findLearningAdditionalInfoByLessonId(long lessonId){
        return lessonJpaRepository.findLearningAdditionalInfoByLessonId(lessonId);
    }

    @Override
    public List<LessonSummary> findAllLessonSummaryByUnitId(
            long unitId,
            long userId
    ) {
        return lessonJpaRepository.findAllLessonSummaryByUnitId(unitId, userId);
    }

    @Override
    public long count(){
        return lessonJpaRepository.count();
    }

    @Override
    public int countTotalLessonByChapterId(long chapterId) {
        return lessonJpaRepository.countTotalLessonByChapterId(chapterId);
    }

    @Override
    public int countTotalLessonByUnitId(long unitId) {
        return lessonJpaRepository.countTotalLessonByUnitId(unitId);
    }

    @Override
    public boolean existsById(long lessonId){
        return lessonJpaRepository.existsById(lessonId);
    }

    @Override
    public Lesson save(Lesson lesson) {
        return lessonJpaRepository.save(lesson);
    }

    @Override
    public void saveAll(List<Lesson> lessons) {
        lessonJpaRepository.saveAll(lessons);
    }
}
