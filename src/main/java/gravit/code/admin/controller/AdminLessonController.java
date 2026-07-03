package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminLessonControllerDocs;
import gravit.code.admin.dto.request.LessonUpdateRequest;
import gravit.code.admin.dto.response.LessonDetailResponse;
import gravit.code.admin.dto.response.ProblemListItemResponse;
import gravit.code.admin.service.AdminLessonService;
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
@RequestMapping("/api/v1/admin/lessons")
public class AdminLessonController implements AdminLessonControllerDocs {

    private final AdminLessonService adminLessonService;

    @GetMapping("/{lessonId}")
    public ResponseEntity<LessonDetailResponse> getLesson(@PathVariable("lessonId") Long lessonId) {
        return ResponseEntity.status(HttpStatus.OK).body(adminLessonService.getLesson(lessonId));
    }

    @PatchMapping("/{lessonId}")
    public ResponseEntity<Void> updateLesson(
            @PathVariable("lessonId") Long lessonId,
            @Valid @RequestBody LessonUpdateRequest request
    ) {
        adminLessonService.updateLesson(lessonId, request);
        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @GetMapping("/{lessonId}/problems")
    public ResponseEntity<PageResponse<ProblemListItemResponse>> getProblems(
            @PathVariable("lessonId") Long lessonId,
            @RequestParam(value = "page", defaultValue = "1") int page
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(adminLessonService.getProblems(lessonId, page));
    }
}
