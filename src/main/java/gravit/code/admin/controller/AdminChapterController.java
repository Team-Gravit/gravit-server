package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminChapterControllerDocs;
import gravit.code.admin.dto.request.ChapterUpdateRequest;
import gravit.code.admin.dto.response.ChapterDetailResponse;
import gravit.code.admin.dto.response.ChapterListItemResponse;
import gravit.code.admin.dto.response.ChapterStatsResponse;
import gravit.code.admin.dto.response.UnitListItemResponse;
import gravit.code.admin.service.AdminChapterService;
import gravit.code.global.dto.response.PageResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/chapters")
public class AdminChapterController implements AdminChapterControllerDocs {

    private final AdminChapterService adminChapterService;

    @GetMapping
    public ResponseEntity<PageResponse<ChapterListItemResponse>> getChapters(
            @RequestParam(value = "page", defaultValue = "1") int page
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(adminChapterService.getChapters(page));
    }

    @GetMapping("/{chapterId}")
    public ResponseEntity<ChapterDetailResponse> getChapter(@PathVariable("chapterId") Long chapterId) {
        return ResponseEntity.status(HttpStatus.OK).body(adminChapterService.getChapter(chapterId));
    }

    @GetMapping("/{chapterId}/stats")
    public ResponseEntity<ChapterStatsResponse> getChapterStats(@PathVariable("chapterId") Long chapterId) {
        return ResponseEntity.status(HttpStatus.OK).body(adminChapterService.getChapterStats(chapterId));
    }

    @PatchMapping("/{chapterId}")
    public ResponseEntity<Void> updateChapter(
            @PathVariable("chapterId") Long chapterId,
            @Valid @RequestBody ChapterUpdateRequest request
    ) {
        adminChapterService.updateChapter(chapterId, request);
        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @GetMapping("/{chapterId}/units")
    public ResponseEntity<PageResponse<UnitListItemResponse>> getUnits(
            @PathVariable("chapterId") Long chapterId,
            @RequestParam(value = "page", defaultValue = "1") int page
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(adminChapterService.getUnits(chapterId, page));
    }
}
