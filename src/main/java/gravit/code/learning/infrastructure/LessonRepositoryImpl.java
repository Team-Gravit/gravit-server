package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Lesson;
import gravit.code.learning.domain.LessonRepository;
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
}
