package gravit.code.learning.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.internal.ConsecutiveSolvedDto;
import gravit.code.learning.repository.LearningRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.LEARNING_CONFLICT;
import static gravit.code.global.exception.domain.CustomErrorCode.LEARNING_NOT_FOUND;

@Slf4j
@Service
@RequiredArgsConstructor
public class LearningCommandService {

    private final LearningProgressRateService learningProgressRateService;

    private final LearningRepository learningRepository;

    @Transactional
    public void updateConsecutiveDays(){
        int resetCount = learningRepository.resetConsecutiveDays();

        log.info("연속 학습일 정산 완료 - 갱신 행 수: {}", resetCount);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void createLearning(long userId){
        if (learningRepository.existsByUserId(userId)) {
            throw new RestApiException(LEARNING_CONFLICT);
        }

        Learning learning = Learning.create(userId);
        learningRepository.save(learning);
    }

    @Transactional
    public ConsecutiveSolvedDto updateLearningStatus(
            long userId,
            long chapterId
    ) {
        Learning learning = learningRepository.findByUserId(userId)
                .orElseThrow(() -> new RestApiException(LEARNING_NOT_FOUND));

        int planetConquestRate = learningProgressRateService.getPlanetConquestRate(userId);

        ConsecutiveSolvedDto consecutiveSolvedDto = learning.updateLearningStatus(chapterId, planetConquestRate);

        learningRepository.save(learning);

        return consecutiveSolvedDto;
    }
}
