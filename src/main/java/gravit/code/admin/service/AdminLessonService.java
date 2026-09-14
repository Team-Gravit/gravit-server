package gravit.code.admin.service;

import gravit.code.admin.dto.request.LessonUpdateRequest;
import gravit.code.admin.dto.response.LessonDetailResponse;
import gravit.code.admin.dto.response.ProblemListItemResponse;
import gravit.code.admin.support.AdminPages;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.problem.repository.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.INVALID_PARAMS;
import static gravit.code.global.exception.domain.CustomErrorCode.LESSON_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class AdminLessonService {

    private final LessonRepository lessonRepository;
    private final ProblemRepository problemRepository;

    @Transactional(readOnly = true)
    public LessonDetailResponse getLesson(long lessonId) {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RestApiException(LESSON_NOT_FOUND));

        long problemCount = problemRepository.countByLessonId(lessonId);

        return LessonDetailResponse.of(lesson, problemCount);
    }

    @Transactional
    public void updateLesson(
            long lessonId,
            LessonUpdateRequest request
    ) {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RestApiException(LESSON_NOT_FOUND));

        if (request.title() != null) {
            validateNotBlank(request.title());
            lesson.updateTitle(request.title());
        }
    }

    @Transactional(readOnly = true)
    public PageResponse<ProblemListItemResponse> getProblems(
            long lessonId,
            int page
    ) {
        Pageable pageable = AdminPages.of(page, Sort.by(Sort.Direction.ASC, "id"));

        return PageResponse.from(problemRepository.findByLessonId(lessonId, pageable).map(ProblemListItemResponse::from));
    }

    private void validateNotBlank(String title) {
        if (title.isBlank()) {
            throw new RestApiException(INVALID_PARAMS);
        }
    }
}
