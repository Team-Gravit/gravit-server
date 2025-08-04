package gravit.code.domain.learning.controller;

import gravit.code.domain.chapterProgress.dto.response.ChapterProgressDetailResponse;
import gravit.code.auth.oauth.LoginUser;
import gravit.code.domain.learning.controller.docs.LearningControllerSpecification;
import gravit.code.domain.learning.dto.request.LearningResultSaveRequest;
import gravit.code.domain.learning.facade.LearningFacade;
import gravit.code.domain.problem.dto.response.ProblemResponse;
import gravit.code.domain.unitProgress.dto.response.UnitPageResponse;
import gravit.code.domain.user.dto.response.UserLevelResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/learning")
public class LearningController implements LearningControllerSpecification {

    private final LearningFacade learningFacade;

    @GetMapping("/chapters")
    public ResponseEntity<List<ChapterProgressDetailResponse>> getAllChapters(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllChapters(loginUser.getId()));
    }

    @GetMapping("/{chapterId}/units")
    public ResponseEntity<List<UnitPageResponse>> getAllUnits(@AuthenticationPrincipal LoginUser loginUser,
                                                              @PathVariable("chapterId") Long chapterId){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllUnitsInChapter(loginUser.getId(), chapterId));
    }

    @GetMapping("/{lessonId}/problems")
    public ResponseEntity<List<ProblemResponse>> getProblems(@PathVariable("lessonId") Long lessonsId){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllProblemsInLesson(lessonsId));
    }

    @PostMapping("/results")
    public ResponseEntity<UserLevelResponse> saveLearningResult(@AuthenticationPrincipal LoginUser loginUser,
                                                                @Valid@RequestBody LearningResultSaveRequest request){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.saveLearningResult(loginUser.getId(), request));
    }
}
