package gravit.code.interviewQuestion.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.interviewQuestion.controller.docs.InterviewTopicControllerDocs;
import gravit.code.interviewQuestion.dto.response.InterviewTopicResponse;
import gravit.code.interviewQuestion.service.InterviewTopicQueryService;
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
@RequestMapping("/api/v1/interview-topics")
public class InterviewTopicController implements InterviewTopicControllerDocs {

    private final InterviewTopicQueryService interviewTopicQueryService;

    @GetMapping
    public ResponseEntity<List<InterviewTopicResponse>> getCsTopics(@AuthenticationPrincipal LoginUser loginUser) {
        List<InterviewTopicResponse> topics = interviewTopicQueryService.getCsTopics();

        return ResponseEntity.status(HttpStatus.OK).body(topics);
    }
}
