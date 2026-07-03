package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminUnitControllerDocs;
import gravit.code.admin.dto.request.UnitUpdateRequest;
import gravit.code.admin.dto.response.LessonListItemResponse;
import gravit.code.admin.dto.response.UnitDetailResponse;
import gravit.code.admin.service.AdminUnitService;
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
@RequestMapping("/api/v1/admin/units")
public class AdminUnitController implements AdminUnitControllerDocs {

    private final AdminUnitService adminUnitService;

    @GetMapping("/{unitId}")
    public ResponseEntity<UnitDetailResponse> getUnit(@PathVariable("unitId") Long unitId) {
        return ResponseEntity.status(HttpStatus.OK).body(adminUnitService.getUnit(unitId));
    }

    @PatchMapping("/{unitId}")
    public ResponseEntity<Void> updateUnit(
            @PathVariable("unitId") Long unitId,
            @Valid @RequestBody UnitUpdateRequest request
    ) {
        adminUnitService.updateUnit(unitId, request);
        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @GetMapping("/{unitId}/lessons")
    public ResponseEntity<PageResponse<LessonListItemResponse>> getLessons(
            @PathVariable("unitId") Long unitId,
            @RequestParam(value = "page", defaultValue = "1") int page
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(adminUnitService.getLessons(unitId, page));
    }
}
