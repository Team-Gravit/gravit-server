package gravit.code.learning.service;

import gravit.code.learning.domain.Learning;
import gravit.code.learning.domain.LearningRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LearningService {

    private final LearningRepository learningRepository;

    @Transactional
    public void updateConsecutiveDays(){
        List<Learning> learnings = learningRepository.findAllByTodaySolved(false);

        for(Learning learning : learnings){
            learning.resetConsecutiveDays();
        }

        learningRepository.saveAll(learnings);
    }
}
