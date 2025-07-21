package gravit.code.learning.controller;

import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.facade.LearningFacade;
import gravit.code.user.dto.response.UserLevelResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/learning")
@RequiredArgsConstructor
public class LearningController {

    private final LearningFacade learningFacade;

    @PostMapping("/results")
    public ResponseEntity<UserLevelResponse> saveLearningResult(Long userId, @Valid@RequestBody LearningResultSaveRequest request){
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.saveLearningProgress(userId, request));
    }
}
