package gravit.code.friend.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.friend.dto.SearchUser;
import gravit.code.friend.dto.response.PageSearchUserResponse;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Friend Search API", description = "사용자 핸들(Handle) 기반 검색 API")
public interface FriendSearchControllerDocs {

    @Operation(
            summary = "핸들&닉네임 검색",
            description = """
                    사용자 핸들&닉네임 으로 팔로우 대상 검색을 수행합니다.<br>
                    - (핸들의 경우) <br>
                    - 입력이 '@' 부터 시작하면 handle 기반 조회를 시도합니다. <br>
                    - 입력은 정규화됩니다: 선두 '@' 제거, 유니코드 정규화(NFKC), 소문자화, 허용 문자만 유지(소문자,숫자).<br>
                    - 매칭 우선순위: 정확 일치 > 접두 일치 > 부분 일치.<br>
                    - (닉네임의 경우) <br>
                    - 입력이 문자(알파벳, 한글) 이나 숫자로 시작하면 nickname 기반 조회를 시도합니다 <br>
                    - 입력은 정규화 됩니다. 유니코드 정규화(NFKC), 소문자화, 허용 문자만 유지(소문자, 한글, 숫자).<br>
                    - 매칭 우선순위: 정확 일치 > 접두 일치 > 부분 일치.<br>
                    🔐 <strong>Jwt 필요</strong><br>
                    🔐 <strong>다음 페이지가 존재하면 hasNextPage 가 true, 없으면 false</strong><br>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 검색 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = PageSearchUserResponse.class),
                            examples = @ExampleObject(
                                    name = "검색 결과 예시",
                                    value = """
                                            {
                                              "page": 0,
                                              "size": 10,
                                              "total": 1,
                                              "hasNext": false,
                                              "searchUsers": [
                                                {
                                                  "userId": 6,
                                                  "profileImgNumber": 6,
                                                  "nickname": "유저06",
                                                  "handle": "@zb000005",
                                                  "isFollowing": true
                                                }
                                              ]
                                            }
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "GLOBAL_5001",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "예외 예시",
                                    value = "{\"error\":\"GLOBAL_5001\",\"message\":\"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping
    ResponseEntity<SliceResponse<SearchUser>> search(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "검색할 핸들 문자열 (선두 '@' 허용, 대소문자 무시)") @RequestParam String handleQuery,
            @Parameter(description = "0부터 시작하는 페이지 인덱스", example = "0") @RequestParam(defaultValue = "0") int page
    );
}
