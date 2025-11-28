package gravit.code.test.badge;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.badge.ConsecutiveSolvedEvent;
import gravit.code.global.event.badge.MissionCompletedEvent;
import gravit.code.global.event.badge.PlanetCompletedEvent;
import gravit.code.global.event.badge.QualifiedSolvedEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/test")
@RequiredArgsConstructor
public class TestEventController {
    private final ApplicationEventPublisher publisher;
    private final TransactionTemplate tx;

    @PostMapping("/planet-completed")
    public ResponseEntity<Void> planetCompleted(@RequestBody LessonCompletedEvent event){
        tx.executeWithoutResult(s-> publisher.publishEvent(event));
        return ResponseEntity.ok().build();
    }

    @PostMapping("/mission-completed")
    public ResponseEntity<Void> mission(@RequestBody MissionCompletedEvent event) {
        tx.executeWithoutResult(s -> publisher.publishEvent(event));
        return ResponseEntity.ok().build();
    }

    @PostMapping("/qualified-solved")
    public ResponseEntity<Void> qualified(@RequestBody QualifiedSolvedEvent event) {
        tx.executeWithoutResult(s -> publisher.publishEvent(event));
        return ResponseEntity.ok().build();
    }

    @PostMapping("/streak")
    public ResponseEntity<Void> streak(@RequestBody ConsecutiveSolvedEvent event) {
        tx.executeWithoutResult(s -> publisher.publishEvent(event));
        return ResponseEntity.ok().build();
    }
}
