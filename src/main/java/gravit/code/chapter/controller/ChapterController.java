package gravit.code.chapter.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.chapter.controller.docs.ChapterControllerDocs;
import gravit.code.chapter.domain.ChapterCategory;
import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.chapter.facade.ChapterFacade;
import gravit.code.chapter.service.ChapterQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/chapters")
public class ChapterController implements ChapterControllerDocs {

    private final ChapterFacade chapterFacade;

    private final ChapterQueryService chapterQueryService;

    @GetMapping
    public ResponseEntity<List<ChapterDetailResponse>> getAllChapter(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(OK).body(chapterFacade.getAllChapter(loginUser.getId()));
    }

    @GetMapping("/cs")
    public ResponseEntity<List<ChapterDetailResponse>> getCsChapters(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(OK).body(chapterFacade.getCsChapters(loginUser.getId()));
    }

    @GetMapping("/tracks")
    public ResponseEntity<List<ChapterCategory>> getTracks(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(OK).body(chapterQueryService.getTracks());
    }

    @GetMapping("/tracks/{track}")
    public ResponseEntity<List<ChapterDetailResponse>> getTrackChapters(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable ChapterCategory track
    ) {
        return ResponseEntity.status(OK).body(chapterFacade.getTrackChapters(loginUser.getId(), track));
    }
}
