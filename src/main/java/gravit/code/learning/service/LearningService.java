package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.domain.LearningRepository;
import gravit.code.learning.domain.LessonRepository;
import gravit.code.learning.dto.StreakDto;
import gravit.code.progress.domain.LessonProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LearningService {

    private final LearningRepository learningRepository;
    private final LessonRepository lessonRepository;
    private final LessonProgressRepository lessonProgressRepository;

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

    public StreakDto updateLearningStatus(
            long userId,
            long chapterId
    ){
        Learning learning = learningRepository.findByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        long totalLesson = lessonRepository.count();
        long solvedLesson = lessonProgressRepository.countByUserId(userId);

        int planetConquestRate = Math.toIntExact(
                Math.round(((double) solvedLesson / totalLesson) * 100)
        );

        learningRepository.save(learning);

        return learning.updateLearningStatus(chapterId, planetConquestRate);
    }

    public void createLearning(long userId){
        Learning learning = Learning.create(userId);

        learningRepository.save(learning);
    }
}
