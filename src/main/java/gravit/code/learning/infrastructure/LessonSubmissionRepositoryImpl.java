package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.LessonSubmission;
import gravit.code.learning.domain.LessonSubmissionRepository;
import gravit.code.learning.dto.response.LessonProgressSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class LessonSubmissionRepositoryImpl implements LessonSubmissionRepository {

    private final LessonSubmissionJpaRepository lessonSubmissionJpaRepository;

    @Override
    public LessonSubmission save(LessonSubmission lessonSubmission){
        return lessonSubmissionJpaRepository.save(lessonSubmission);
    }

    @Override
    public Optional<LessonSubmission> findByLessonIdAndUserId(
            long lessonId,
            long userId
    ){
        return lessonSubmissionJpaRepository.findByLessonIdAndUserId(lessonId, userId);
    }

    @Override
    public List<LessonProgressSummaryResponse> findLessonProgressSummaryByUnitIdAndUserId(
            long unitId,
            long userId
    ){
        return lessonSubmissionJpaRepository.findLessonProgressSummaryByUnitIdAndUserId(unitId, userId);
    }

    @Override
    public long countByUserId(long userId){
        return lessonSubmissionJpaRepository.countByUserId(userId);
    }

    @Override
    public void saveAll(List<LessonSubmission> lessonSubmissions){
        lessonSubmissionJpaRepository.saveAll(lessonSubmissions);
    }

    @Override
    public int countSolvedLessonByChapterIdAndUserId(
            long chapterId,
            long userId
    ){
        return lessonSubmissionJpaRepository.countSolvedLessonByChapterIdAndUserId(chapterId, userId);
    }

    @Override
    public int countSolvedLessonByUnitIdAndUserId(
            long unitId,
            long userId
    ) {
        return lessonSubmissionJpaRepository.countSolvedLessonByUnitIdAndUserId(unitId, userId);
    }

    @Override
    public int countLessonSubmissionByLessonIdAndUserId(long lessonId, long userId) {
        return lessonSubmissionJpaRepository.countLessonSubmissionByLessonIdAndUserId(lessonId, userId);
    }

    @Override
    public boolean existsByLessonIdAndUserId(long lessonId, long userId) {
        return lessonSubmissionJpaRepository.existsByLessonIdAndUserId(lessonId, userId);
    }
}
