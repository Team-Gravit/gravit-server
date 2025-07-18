package gravit.code.problem.controller;

import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.problem.service.ProblemService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/problems")
public class ProblemController {

    private final ProblemService problemService;

    @GetMapping
    public ResponseEntity<List<LessonResponse>> getLesson(Long lessonsId){
        return ResponseEntity.status(HttpStatus.OK).body(problemService.getLesson(lessonsId));
    }
}