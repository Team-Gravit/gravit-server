package gravit.code.domain.problem.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.domain.lesson.dto.response.LessonResponse;
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
    public List<LessonResponse> getAllProblemsInLesson(Long lessonsId){
        List<LessonResponse> lessons = problemRepository.findByLessonId(lessonsId);

        if(lessons.isEmpty())
            throw new RestApiException(CustomErrorCode.LESSON_NOT_FOUND);

        return lessons;
    }
}
