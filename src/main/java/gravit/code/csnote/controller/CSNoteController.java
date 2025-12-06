package gravit.code.csnote.controller;

import static gravit.code.global.exception.domain.CustomErrorCode.CHAPTER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.UNIT_NOT_FOUND;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.domain.ChapterRepository;
import gravit.code.csnote.controller.docs.CSNoteControllerDocs;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.domain.UnitRepository;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
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
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/api/v1/cs-notes")
public class CSNoteController implements CSNoteControllerDocs {

    private final UnitRepository unitRepository;
    private final ChapterRepository chapterRepository;

    private static final String BASE_PATH = "static/notes";
    private static final String UNIT_PREFIX = "unit";
    private static final Map<String, String> chapterMap = Map.of(
            "자료구조", "data-structure",
            "알고리즘", "algorithm",
            "네트워크", "network"
    );

    @GetMapping("/{unitId}")
    public ResponseEntity<Resource> getNote(
            @PathVariable("unitId") Long unitId
    ){
        Unit unit = unitRepository.findById(unitId)
                .orElseThrow(() -> new RestApiException(UNIT_NOT_FOUND));

        Chapter chapter = chapterRepository.findById(unit.getChapterId())
                .orElseThrow(() -> new RestApiException(CHAPTER_NOT_FOUND));

        List<Long> unitIdsInChapter = unitRepository.findIdsByChapterIdOrderById(chapter.getId());
        int orderInChapter = calculateOrderInChapter(unitIdsInChapter, unitId);

        String chapterName = chapterMap.get(chapter.getTitle());
        String unitKey = makeUnitKey(orderInChapter);

        try{
            String filePath = String.format("%s/%s/%s.md", BASE_PATH, chapterName, unitKey);
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

    private int calculateOrderInChapter(List<Long> unitIdsInChapter, long targetUnitId) {
        int index = unitIdsInChapter.indexOf(targetUnitId);
        if(index == -1){
            throw new RestApiException(UNIT_NOT_FOUND);
        }
        return index + 1;
    }

    private String makeUnitKey(long unitId) {
        if(unitId < 10){
            String numStr = String.format("0%d", unitId);
            return String.format("%s%s", UNIT_PREFIX, numStr);
        }

        return String.format("%s%d", UNIT_PREFIX, unitId);
    }
}
