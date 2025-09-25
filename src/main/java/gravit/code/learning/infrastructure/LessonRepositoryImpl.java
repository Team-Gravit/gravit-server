package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Lesson;
import gravit.code.learning.domain.LessonRepository;
import gravit.code.learning.dto.LearningAdditionalInfo;
import gravit.code.learning.dto.LearningIds;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class LessonRepositoryImpl implements LessonRepository {

    private final LessonJpaRepository lessonJpaRepository;

    @Override
    public Lesson save(Lesson lesson) {
        return lessonJpaRepository.save(lesson);
    }

    @Override
    public Optional<Lesson> findById(Long lessonId){
        return lessonJpaRepository.findById(lessonId);
    }

    @Override
    public long count(){
        return lessonJpaRepository.count();
    }

    @Override
    public boolean existsById(Long lessonId){
        return lessonJpaRepository.existsById(lessonId);
    }

    @Override
    public LearningIds findLearningIdsByLessonId(long lessonId){
        return lessonJpaRepository.findLearningIdsByLessonId(lessonId);
    }

    @Override
    public Optional<String> findLessonNameByLessonId(long lessonId){
        return lessonJpaRepository.findLessonNameByLessonId(lessonId);
    }

    @Override
    public Optional<LearningAdditionalInfo> findLearningAdditionalInfoByLessonId(long lessonId){
        return lessonJpaRepository.findLearningAdditionalInfoByLessonId(lessonId);
    }
}
