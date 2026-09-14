package gravit.code.lesson.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.lesson.controller.docs.LessonControllerDocs;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonResultResponse;
import gravit.code.lesson.dto.response.LessonSubmissionSaveResponse;
import gravit.code.lesson.facade.LessonFacade;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.CREATED;
import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/lessons")
public class LessonController implements LessonControllerDocs {

    private final LessonFacade lessonFacade;

    @GetMapping("/{unitId}")
    public ResponseEntity<LessonDetailResponse> getAllLessonInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    ) {
        return ResponseEntity.status(OK).body(lessonFacade.getAllLessonInUnit(loginUser.getId(), unitId));
    }

    @PostMapping("/results")
    public ResponseEntity<LessonSubmissionSaveResponse> saveLessonSubmission(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody LearningSubmissionSaveRequest request
    ) {
        return ResponseEntity.status(CREATED).body(lessonFacade.saveLessonSubmission(loginUser.getId(), request));
    }

    @GetMapping("/results/{lessonSubmissionId}")
    public ResponseEntity<LessonResultResponse> getLessonResult(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("lessonSubmissionId") Long lessonSubmissionId
    ) {
        return ResponseEntity.status(OK).body(lessonFacade.getLessonResult(loginUser.getId(), lessonSubmissionId));
    }
}
