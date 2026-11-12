package gravit.code.test.fixture;

import gravit.code.test.fixture.docs.TestQaFixtureControllerDocs;
import gravit.code.test.fixture.dto.response.QaFixtureManifestResponse;
import gravit.code.test.fixture.support.QaFixtureReloader;
import gravit.code.test.fixture.support.QaFixtureSet;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@Profile("!prod")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/test/fixtures/qa")
public class TestQaFixtureController implements TestQaFixtureControllerDocs {

    private final QaFixtureReloader qaFixtureReloader;

    @PostMapping("/reload")
    public ResponseEntity<QaFixtureManifestResponse> reload(@RequestParam String set) {
        return ResponseEntity.status(OK).body(qaFixtureReloader.reload(QaFixtureSet.from(set)));
    }
}
