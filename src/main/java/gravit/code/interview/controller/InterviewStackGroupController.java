package gravit.code.interview.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.interview.controller.docs.InterviewStackGroupControllerDocs;
import gravit.code.interview.domain.InterviewStackGroup;
import gravit.code.interview.dto.response.InterviewStackGroupResponse;
import gravit.code.interview.dto.response.InterviewStackResponse;
import gravit.code.interview.service.InterviewStackQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/interview-stack-groups")
public class InterviewStackGroupController implements InterviewStackGroupControllerDocs {

    private final InterviewStackQueryService interviewStackQueryService;

    @GetMapping
    public ResponseEntity<List<InterviewStackGroupResponse>> getStackGroups(
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        List<InterviewStackGroupResponse> stackGroups = interviewStackQueryService.getStackGroups();

        return ResponseEntity.status(HttpStatus.OK).body(stackGroups);
    }

    @GetMapping("/{stackGroup}/stacks")
    public ResponseEntity<List<InterviewStackResponse>> getStacks(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable InterviewStackGroup stackGroup
    ) {
        List<InterviewStackResponse> stacks = interviewStackQueryService.getStacks(stackGroup);

        return ResponseEntity.status(HttpStatus.OK).body(stacks);
    }
}
