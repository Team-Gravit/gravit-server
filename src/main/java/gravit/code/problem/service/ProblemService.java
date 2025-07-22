package gravit.code.problem.service;

import gravit.code.common.exception.domain.CustomErrorCode;
import gravit.code.common.exception.domain.RestApiException;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.repository.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProblemService {

    private final ProblemRepository problemRepository;

    @Transactional(readOnly = true)
    public List<LessonResponse> getLesson(Long lessonsId){
        List<LessonResponse> lessons = problemRepository.findByLessonId(lessonsId);

        if(lessons.isEmpty())
            throw new RestApiException(CustomErrorCode.LESSON_NOT_FOUND);

        return lessons;
    }
}
