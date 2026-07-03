package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminStagingControllerDocs;
import gravit.code.admin.domain.staging.LabelStatus;
import gravit.code.admin.dto.request.LabelStatusUpdateRequest;
import gravit.code.admin.dto.request.StagingAnswerUpdateRequest;
import gravit.code.admin.dto.request.StagingLessonUpdateRequest;
import gravit.code.admin.dto.request.StagingOptionUpdateRequest;
import gravit.code.admin.dto.request.StagingProblemUpdateRequest;
import gravit.code.admin.dto.response.StagingLabelDetailResponse;
import gravit.code.admin.dto.response.StagingLabelListItemResponse;
import gravit.code.admin.service.AdminStagingPromoteService;
import gravit.code.admin.service.AdminStagingService;
import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/staging")
public class AdminStagingController implements AdminStagingControllerDocs {

    private final AdminStagingService adminStagingService;
    private final AdminStagingPromoteService adminStagingPromoteService;

    @GetMapping("/labels")
    public ResponseEntity<PageResponse<StagingLabelListItemResponse>> getLabels(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "status", required = false) LabelStatus status
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(adminStagingService.getLabels(page, status));
    }

    @GetMapping("/labels/{label}")
    public ResponseEntity<StagingLabelDetailResponse> getLabelDetail(@PathVariable("label") String label) {
        return ResponseEntity.status(HttpStatus.OK).body(adminStagingService.getLabelDetail(label));
    }

    @PatchMapping("/lessons/{lessonId}")
    public ResponseEntity<Void> updateLesson(
            @PathVariable("lessonId") Long lessonId,
            @Valid @RequestBody StagingLessonUpdateRequest request
    ) {
        adminStagingService.updateLesson(lessonId, request);
        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @PatchMapping("/problems/{problemId}")
    public ResponseEntity<Void> updateProblem(
            @PathVariable("problemId") Long problemId,
            @Valid @RequestBody StagingProblemUpdateRequest request
    ) {
        adminStagingService.updateProblem(problemId, request);
        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @PatchMapping("/options/{optionId}")
    public ResponseEntity<Void> updateOption(
            @PathVariable("optionId") Long optionId,
            @Valid @RequestBody StagingOptionUpdateRequest request
    ) {
        adminStagingService.updateOption(optionId, request);
        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @PatchMapping("/answers/{answerId}")
    public ResponseEntity<Void> updateAnswer(
            @PathVariable("answerId") Long answerId,
            @Valid @RequestBody StagingAnswerUpdateRequest request
    ) {
        adminStagingService.updateAnswer(answerId, request);
        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @PatchMapping("/labels/{label}/status")
    public ResponseEntity<Void> promote(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("label") String label,
            @Valid @RequestBody LabelStatusUpdateRequest request
    ) {
        adminStagingPromoteService.promote(loginUser.getId(), label, request.status());
        return ResponseEntity.status(HttpStatus.OK).build();
    }
}
