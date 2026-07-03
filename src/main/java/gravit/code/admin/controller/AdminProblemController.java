package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminProblemControllerDocs;
import gravit.code.admin.dto.request.ObjectiveProblemUpdateRequest;
import gravit.code.admin.dto.request.SubjectiveProblemUpdateRequest;
import gravit.code.admin.dto.response.ProblemDetailResponse;
import gravit.code.admin.service.AdminProblemService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/problems")
public class AdminProblemController implements AdminProblemControllerDocs {

    private final AdminProblemService adminProblemService;

    @GetMapping("/{problemId}")
    public ResponseEntity<ProblemDetailResponse> getProblem(@PathVariable("problemId") Long problemId) {
        return ResponseEntity.status(HttpStatus.OK).body(adminProblemService.getProblem(problemId));
    }

    @PatchMapping("/{problemId}/objective")
    public ResponseEntity<Void> updateObjective(
            @PathVariable("problemId") Long problemId,
            @Valid @RequestBody ObjectiveProblemUpdateRequest request
    ) {
        adminProblemService.updateObjective(problemId, request);
        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @PatchMapping("/{problemId}/subjective")
    public ResponseEntity<Void> updateSubjective(
            @PathVariable("problemId") Long problemId,
            @Valid @RequestBody SubjectiveProblemUpdateRequest request
    ) {
        adminProblemService.updateSubjective(problemId, request);
        return ResponseEntity.status(HttpStatus.OK).build();
    }
}
