package gravit.code.friend.dto.response;

import gravit.code.friend.dto.internal.SearchUserDto;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "사용자 검색 슬라이스 응답")
public class SearchUserSliceResponse {

    @Schema(description = "다음 페이지 존재 여부", example = "false")
    public boolean hasNextPage;

    @Schema(description = "검색 결과 목록")
    public List<SearchUserDto> contents;
}
