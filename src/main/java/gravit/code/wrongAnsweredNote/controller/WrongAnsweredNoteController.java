package gravit.code.wrongAnsweredNote.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.problem.dto.response.WrongAnsweredProblemsResponse;
import gravit.code.wrongAnsweredNote.dto.response.WrongAnsweredNoteDeleteRequest;
import gravit.code.wrongAnsweredNote.facade.WrongAnsweredNoteFacade;
import gravit.code.wrongAnsweredNote.service.WrongAnsweredNoteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/wrong-answered-notes")
public class WrongAnsweredNoteController {

    private final WrongAnsweredNoteFacade wrongAnsweredNoteFacade;
    private final WrongAnsweredNoteService wrongAnsweredNoteService;

    @GetMapping("/{unitId}")
    public ResponseEntity<WrongAnsweredProblemsResponse> getWrongAnsweredProblemsInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(wrongAnsweredNoteFacade.getAllWrongAnsweredProblemInUnit(loginUser.getId(), unitId));
    }

    @DeleteMapping
    public ResponseEntity<Void> deleteWrongAnsweredNote(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody WrongAnsweredNoteDeleteRequest request
    ){
        wrongAnsweredNoteService.deleteWrongAnsweredNoteIfExists(loginUser.getId(), request.problemId());
        return ResponseEntity.noContent().build();
    }
}
