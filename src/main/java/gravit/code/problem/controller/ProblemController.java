package gravit.code.problem.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
import gravit.code.problem.facade.ProblemFacade;
import gravit.code.problem.service.ProblemSubmissionCommandService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/problems")
public class ProblemController {

    private final ProblemFacade problemFacade;
    private final ProblemSubmissionCommandService problemSubmissionCommandService;

    @GetMapping("/{lessonId}")
    public ResponseEntity<LessonResponse> getAllProblemInLesson(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("lessonId") Long lessonsId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(problemFacade.getAllProblemInLesson(lessonsId, loginUser.getId()));
    }

    @PostMapping("/results")
    public ResponseEntity<Void> saveProblemSubmission(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody ProblemSubmissionRequest request
    ){
        problemSubmissionCommandService.saveProblemSubmission(loginUser.getId(), request);
        return ResponseEntity.ok().build();
    }
}
