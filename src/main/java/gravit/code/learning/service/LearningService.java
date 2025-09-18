package gravit.code.learning.service;

import gravit.code.learning.domain.Learning;
import gravit.code.learning.domain.LearningRepository;
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
}
