package gravit.code.friend.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "팔로워 목록 슬라이스 응답")
public class FollowerSliceResponse {

    @Schema(description = "다음 페이지 존재 여부", example = "false")
    public boolean hasNextPage;

    @Schema(description = "팔로워 목록")
    public List<FollowerResponse> contents;
}
