package gravit.code.learning.controller;

import gravit.code.chapterProgress.dto.response.ChapterInfoResponse;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.facade.LearningFacade;
import gravit.code.unitProgress.dto.response.UnitPageResponse;
import gravit.code.user.dto.response.UserLevelResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/learning")
@RequiredArgsConstructor
public class LearningController {

    private final LearningFacade learningFacade;

    // TODO userId -> 머지 후, @AuthenticationPrincipal로 전환

    @GetMapping("/chapters/{userId}")
    public ResponseEntity<List<ChapterInfoResponse>> getAllChapters(@PathVariable("userId") Long userId){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllChapters(userId));
    }

    @GetMapping("/units/{chapterId}/{userId}")
    public ResponseEntity<List<UnitPageResponse>> getAllUnits(@PathVariable("userId") Long userId,
                                                              @PathVariable("chapterId") Long chapterId){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getAllUnits(userId, chapterId));
    }

    @PostMapping("/results/{userId}")
    public ResponseEntity<UserLevelResponse> saveLearningResult(@PathVariable Long userId,
                                                                @Valid@RequestBody LearningResultSaveRequest request){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.saveLearningProgress(userId, request));
    }
}
