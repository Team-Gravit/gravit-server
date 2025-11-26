package gravit.code.csnote.controller;

import gravit.code.csnote.controller.docs.CSNoteControllerDocs;
import java.nio.charset.StandardCharsets;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/cs-notes")
@Slf4j
public class CSNoteController implements CSNoteControllerDocs {

    private static final String BASE_PATH = "static/notes";

    @GetMapping("/{chapter}/{unit}")
    public ResponseEntity<Resource> getNote(
            @PathVariable("chapter") String chapter,
            @PathVariable("unit") String unit
    ){
        try{
            String filePath = String.format("%s/%s/%s.md", BASE_PATH, chapter, unit);
            ClassPathResource resource = new ClassPathResource(filePath);

            if(!resource.exists()){
                return ResponseEntity.notFound().build();
            }

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.TEXT_MARKDOWN);
            headers.setContentDisposition(
                    ContentDisposition.inline()
                            .filename(unit + ".md", StandardCharsets.UTF_8)
                            .build()
            );

            return ResponseEntity.ok().headers(headers).body(resource);

        }catch (Exception e){
            return ResponseEntity.internalServerError().build();
        }
    }
}
