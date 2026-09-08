package gravit.code.csnote.dto.internal;

import org.springframework.core.io.Resource;

public record CSNoteDto(
        String fileName,
        Resource content
) {
    public static CSNoteDto of(
            String fileName,
            Resource content
    ) {
        return new CSNoteDto(fileName, content);
    }
}
