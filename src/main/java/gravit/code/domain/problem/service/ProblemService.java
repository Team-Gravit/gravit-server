package gravit.code.domain.problem.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.domain.problem.dto.response.ProblemInfo;
import gravit.code.domain.problem.domain.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProblemService {

    private final ProblemRepository problemRepository;

    @Transactional(readOnly = true)
    public List<ProblemInfo> getAllProblems(Long lessonsId){
        List<ProblemInfo> lessons = problemRepository.findAllProblemsByLessonId(lessonsId);

        if(lessons.isEmpty())
            throw new RestApiException(CustomErrorCode.LESSON_NOT_FOUND);

        return lessons;
    }
}
