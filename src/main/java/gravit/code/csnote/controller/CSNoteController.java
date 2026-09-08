package gravit.code.csnote.controller;

import gravit.code.csnote.controller.docs.CSNoteControllerDocs;
import gravit.code.csnote.dto.internal.CSNoteDto;
import gravit.code.csnote.service.CSNoteService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/cs-notes")
public class CSNoteController implements CSNoteControllerDocs {

    private final CSNoteService csNoteService;

    @GetMapping("/units/{unitId}")
    public ResponseEntity<Resource> getNoteByUnitId(
            @PathVariable("unitId") Long unitId
    ) {
        CSNoteDto note = csNoteService.getNoteByUnitId(unitId);

        return ResponseEntity.status(HttpStatus.OK)
                .headers(createHeaders(note.fileName()))
                .body(note.content());
    }

    @Deprecated(forRemoval = true)
    @GetMapping("/{unitId}")
    public ResponseEntity<Resource> getNote(
            @PathVariable("unitId") Long unitId
    ) {
        return getNoteByUnitId(unitId);
    }

    private HttpHeaders createHeaders(String fileName) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.TEXT_MARKDOWN);
        headers.setContentDisposition(
                ContentDisposition.inline()
                        .filename(fileName, StandardCharsets.UTF_8)
                        .build()
        );

        return headers;
    }
}
