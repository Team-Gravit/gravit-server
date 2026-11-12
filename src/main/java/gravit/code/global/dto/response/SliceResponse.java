package gravit.code.global.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;
import org.springframework.data.domain.Slice;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record SliceResponse<T>(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        boolean hasNextPage,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        List<T> contents
){
    public static <T> SliceResponse<T> of(
            boolean hasNextPage,
            List<T> contents
    ) {
        return SliceResponse.<T>builder()
                .hasNextPage(hasNextPage)
                .contents(contents)
                .build();
    }

    public static <T> SliceResponse<T> empty() {
        return SliceResponse.<T>builder()
                .hasNextPage(false)
                .contents(List.of())
                .build();
    }

    public static <T> SliceResponse<T> of(Slice<T> slice) {
        return SliceResponse.<T>builder()
                .hasNextPage(slice.hasNext())
                .contents(slice.getContent())
                .build();
    }
}
