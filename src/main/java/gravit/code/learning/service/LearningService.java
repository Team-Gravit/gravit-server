package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.domain.LearningRepository;
import gravit.code.learning.dto.common.ConsecutiveSolvedDto;
import gravit.code.lesson.domain.LessonRepository;
import gravit.code.lesson.service.LessonService;
import gravit.code.lesson.domain.LessonSubmissionRepository;
import gravit.code.learning.dto.response.LearningDetail;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LearningService {

    private final LessonService lessonService;

    private final LearningRepository learningRepository;
    private final LessonRepository lessonRepository;
    private final LessonSubmissionRepository lessonSubmissionRepository;

    @Transactional
    public void updateConsecutiveDays(){
        int size = 10;
        int page = 0;

        while(true){
            Pageable pageable = PageRequest.of(page,size);
            List<Learning> learnings = learningRepository.findAll(pageable);

            if(learnings.isEmpty())
                break;

            for(Learning learning : learnings){
                learning.updateConsecutiveDays();
            }

            learningRepository.saveAll(learnings);

            page++;
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public ConsecutiveSolvedDto updateLearningStatus(
            long userId,
            long chapterId
    ){
        Learning learning = learningRepository.findByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LEARNING_NOT_FOUND));

        long totalLesson = lessonRepository.count();
        long solvedLesson = lessonSubmissionRepository.countByUserId(userId);

        int planetConquestRate = Math.toIntExact(
                Math.round(((double) solvedLesson / totalLesson) * 100)
        );

        ConsecutiveSolvedDto consecutiveSolvedDto = learning.updateLearningStatus(chapterId, planetConquestRate);

        learningRepository.save(learning);

        return consecutiveSolvedDto;
    }

    @Transactional
    public void createLearning(long userId){
        Learning learning = Learning.create(userId);
        learningRepository.save(learning);
    }

    @Transactional(readOnly = true)
    public LearningDetail getUserLearningDetail(long userId) {
        LearningDetail learningDetail = learningRepository.findLearningDetailByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LEARNING_NOT_FOUND));

        double progressRate = lessonService.getProgressRateByChapterId(learningDetail.recentSolvedChapterId(), userId);

        return learningDetail.withRecentSolvedChapterProgressRate(progressRate);
    }
}
