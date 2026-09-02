package gravit.code.interviewTechStack.controller;

import gravit.code.interviewTechStack.controller.docs.InterviewTechStackControllerDocs;
import gravit.code.interviewTechStack.domain.InterviewJobRole;
import gravit.code.interviewTechStack.dto.response.InterviewTechStackResponse;
import gravit.code.interviewTechStack.service.InterviewTechStackQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/interview-tech-stacks")
public class InterviewTechStackController implements InterviewTechStackControllerDocs {

    private final InterviewTechStackQueryService interviewTechStackQueryService;

    @GetMapping
    public ResponseEntity<List<InterviewTechStackResponse>> getTechStacks(
            @RequestParam("jobRole") InterviewJobRole jobRole
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(interviewTechStackQueryService.getTechStacks(jobRole));
    }
}
