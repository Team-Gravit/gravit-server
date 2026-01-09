package gravit.code.unit.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.unit.dto.response.UnitDetailResponse;
import gravit.code.unit.facade.UnitFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/units")
public class UnitController {

    private final UnitFacade unitFacade;

    @GetMapping("/{chapterId}")
    public ResponseEntity<UnitDetailResponse> getAllUnitInChapter(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("chapterId") Long chapterId
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(unitFacade.getAllUnitInChapter(loginUser.getId(), chapterId));
    }
}
