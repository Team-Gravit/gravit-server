package gravit.code.learning.controller;

import gravit.code.chapterProgress.dto.response.ChapterInfoResponse;
import gravit.code.common.auth.oauth.LoginUser;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.facade.LearningFacade;
import gravit.code.unitProgress.dto.response.UnitPageResponse;
import gravit.code.user.dto.response.UserLevelResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/learning")
@RequiredArgsConstructor
public class LearningController {

    private final LearningFacade learningFacade;

    @GetMapping("/chapters")
    public ResponseEntity<List<ChapterInfoResponse>> getAllChapters(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllChapters(loginUser.getId()));
    }

    @GetMapping("/{chapterId}/units")
    public ResponseEntity<List<UnitPageResponse>> getAllUnits(@AuthenticationPrincipal LoginUser loginUser,
                                                              @PathVariable("chapterId") Long chapterId){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllUnits(loginUser.getId(), chapterId));
    }

    @PostMapping("/results")
    public ResponseEntity<UserLevelResponse> saveLearningResult(@AuthenticationPrincipal LoginUser loginUser,
                                                                @Valid@RequestBody LearningResultSaveRequest request){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.saveLearningProgress(loginUser.getId(), request));
    }
}
