package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminProblemControllerDocs;
import gravit.code.admin.dto.request.ProblemCreateRequest;
import gravit.code.admin.dto.request.ProblemUpdateRequest;
import gravit.code.admin.service.AdminProblemService;
import gravit.code.problem.dto.response.ProblemResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/problems")
public class AdminProblemController implements AdminProblemControllerDocs {

    private final AdminProblemService adminProblemService;

    @GetMapping("/{problemId}")
    public ResponseEntity<ProblemResponse> getProblem(@PathVariable("problemId") Long problemId){
        return ResponseEntity.status(HttpStatus.OK).body(adminProblemService.getProblem(problemId));
    }

    @PostMapping
    public ResponseEntity<Void> createProblem(@Valid@RequestBody ProblemCreateRequest request){
        adminProblemService.createProblem(request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PutMapping
    public ResponseEntity<Void> updateProblem(@Valid@RequestBody ProblemUpdateRequest request){
        adminProblemService.updateProblem(request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{problemId}")
    public ResponseEntity<Void> deleteProblem(@PathVariable("problemId") Long problemId){
        adminProblemService.deleteProblem(problemId);
        return ResponseEntity.noContent().build();
    }
}
