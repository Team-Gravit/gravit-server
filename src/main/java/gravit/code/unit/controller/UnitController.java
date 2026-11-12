package gravit.code.unit.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.unit.controller.docs.UnitControllerDocs;
import gravit.code.unit.dto.response.UnitPageResponse;
import gravit.code.unit.facade.UnitFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/units")
public class UnitController implements UnitControllerDocs {

    private final UnitFacade unitFacade;

    @GetMapping("/{chapterId}")
    public ResponseEntity<UnitPageResponse> getAllUnitInChapter(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("chapterId") Long chapterId
    ) {
        return ResponseEntity.status(OK).body(unitFacade.getAllUnitInChapter(loginUser.getId(), chapterId));
    }
}
