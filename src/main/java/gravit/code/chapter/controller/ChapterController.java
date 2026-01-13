package gravit.code.chapter.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.chapter.facade.ChapterFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/chapters")
public class ChapterController implements ChapterControllerDocs {

    private final ChapterFacade chapterFacade;

    @GetMapping
    public ResponseEntity<List<ChapterDetailResponse>> getAllChapter(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(chapterFacade.getAllChapter(loginUser.getId()));
    }
}
