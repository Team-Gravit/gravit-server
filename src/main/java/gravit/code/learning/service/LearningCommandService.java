package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.internal.ConsecutiveSolvedDto;
import gravit.code.learning.repository.LearningRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LearningCommandService {

    private final LearningRepository learningRepository;
    private final LearningProgressRateService learningProgressRateService;

    @Transactional
    public void updateConsecutiveDays(){
        List<Learning> learnings = learningRepository.findAll();

        for(Learning learning : learnings){
            learning.updateConsecutiveDays();
        }

        learningRepository.saveAll(learnings);
    }

    @Transactional
    public void createLearning(long userId){
        Learning learning = Learning.create(userId);
        learningRepository.save(learning);
    }

    // main-page 조회 시 Learning이 없으면 즉시 생성해 반환한다(get-or-create).
    // 동시 생성은 learning.user_id 유니크 제약으로 중복이 차단된다.
    @Transactional
    public Learning getOrCreateLearning(long userId){
        return learningRepository.findByUserId(userId)
                .orElseGet(() -> learningRepository.save(Learning.create(userId)));
    }

    @Transactional
    public ConsecutiveSolvedDto updateLearningStatus(
            long userId,
            long chapterId
    ){
        Learning learning = learningRepository.findByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LEARNING_NOT_FOUND));

        int planetConquestRate = learningProgressRateService.getPlanetConquestRate(userId);

        ConsecutiveSolvedDto consecutiveSolvedDto = learning.updateLearningStatus(chapterId, planetConquestRate);

        learningRepository.save(learning);

        return consecutiveSolvedDto;
    }
}
