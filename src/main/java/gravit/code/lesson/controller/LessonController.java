package gravit.code.lesson.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonSubmissionSaveResponse;
import gravit.code.lesson.facade.LessonFacade;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/lessons")
public class LessonController {

    private final LessonFacade lessonFacade;

    @GetMapping("/{unitId}")
    public ResponseEntity<LessonDetailResponse> getAllLessonInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(lessonFacade.getAllLessonInUnit(loginUser.getId(), unitId));
    }

    @PostMapping("/results")
    public ResponseEntity<LessonSubmissionSaveResponse> saveLessonSubmission(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody LearningSubmissionSaveRequest request
    ){
        return ResponseEntity.status(HttpStatus.OK).body(lessonFacade.saveLessonSubmission(loginUser.getId(), request));
    }
}
