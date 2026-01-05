package gravit.code.friend.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.friend.dto.SearchUser;
import gravit.code.friend.dto.response.FollowCountsResponse;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import gravit.code.friend.dto.response.FriendResponse;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Friend API", description = "팔로우/언팔로우 및 친구 목록 조회 API")
public interface FriendControllerDocs {

    @Operation(summary = "팔로잉", description = "다른 사용자를 팔로잉합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 팔로잉 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 자기 자신 팔로잉 불가",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "자기 자신 팔로잉 불가",
                                            value = "{\"error\" : \"FRIEND_4001\", \"message\" : \"자기 자신에게 팔로잉은 불가능합니다\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 팔로우 대상 유저 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "팔로우 대상 유저 조회 실패",
                                            value = "{\"error\" : \"FRIEND_4041\", \"message\" : \"팔로우 내역이 존재하지 않습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "409", description = "🚨 이미 팔로잉 중인 유저",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "이미 팔로잉 중인 유저",
                                            value = "{\"error\" : \"FRIEND_4091\", \"message\" : \"이미 팔로잉을 한 유저입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/following/{followeeId}")
    ResponseEntity<FriendResponse> following(
            @Parameter(description = "팔로잉할 대상 유저 ID")
            @PathVariable("followeeId") Long followeeId,
            @AuthenticationPrincipal LoginUser loginUser);


    @Operation(summary = "언팔로잉", description = "다른 사용자에 대한 팔로잉을 취소합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 언팔로잉 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 팔로우 내역 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "팔로우 내역 조회 실패",
                                            value = "{\"error\" : \"FRIEND_4041\", \"message\" : \"팔로우 내역이 존재하지 않습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/unfollowing/{followeeId}")
    ResponseEntity<Void> unFollowing(
            @Parameter(description = "언팔로잉할 대상 유저 ID")
            @PathVariable("followeeId") Long followeeId,
            @AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "팔로잉 거절 ", description = "다른 사용자가 나에게 보낸 팔로잉을 거절합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 팔로잉 거절 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 팔로우 내역 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "팔로우 내역 조회 실패",
                                            value = "{\"error\" : \"FRIEND_4041\", \"message\" : \"팔로우 내역이 존재하지 않습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/reject-following/{followerId}")
    ResponseEntity<Void> rejectFollowing(
            @Parameter(description = "나를 팔로잉한 대상 유저 ID")
            @PathVariable("followerId") Long followerId,
            @AuthenticationPrincipal LoginUser loginUser);


    @Operation(summary = "팔로워 목록 조회", description = "현재 사용자를 팔로우하고 있는 사용자 목록을 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>" +
            "<strong>Slice 페이징을 적용합니다</strong><br>" +
            "쿼리 파라미터로 page 값을 보내주세요(0부터 시작)"
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 팔로워 목록 조회 성공"),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @GetMapping("/follower")
    ResponseEntity<SliceResponse<FollowerResponse>> getFollowers(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam int page
    );


    @Operation(summary = "팔로잉 목록 조회", description = "현재 사용자가 팔로잉하고 있는 사용자 목록을 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>" +
            "<strong>Slice 페이징을 적용합니다</strong><br>" +
            "쿼리 파라미터로 page 값을 보내주세요(0부터 시작)"
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 팔로잉 목록 조회 성공"),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @GetMapping("/following")
    ResponseEntity<SliceResponse<FollowingResponse>> getFollowings(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam int page
    );


    @Operation(
            summary = "팔로워/팔로잉 카운트 조회",
            description = """
                현재 사용자의 팔로워 수와 팔로잉 수를 조회합니다.<br>
                🔐 <strong>Jwt 필요</strong><br>
                """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 카운트 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = FollowCountsResponse.class),
                            examples = {
                                    @ExampleObject(
                                            name = "성공 예시",
                                            value = """
                                                {
                                                  "followerCount": 4,
                                                  "followingCount": 10
                                                }
                                                """
                                    )
                            }
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 존재하지 않는 유저입니다",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = {
                                    @ExampleObject(
                                            name = "존재하지 않는 유저입니다.",
                                            value = """
                                                {
                                                  "error": "USER_4041",
                                                  "message": "존재하지 않는 유저입니다."
                                                }
                                                """
                                    )
                            }
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외",
                                            value = """
                                                {
                                                  "error": "GLOBAL_5001",
                                                  "message": "예기치 못한 예외 발생"
                                                }
                                                """
                                    )
                            }
                    )
            )
    })
    @GetMapping("/count")
    ResponseEntity<FollowCountsResponse> getFollowAndFollowingCount(@AuthenticationPrincipal LoginUser loginUser);

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
                            schema = @Schema(implementation = SliceResponse.class),
                            examples = @ExampleObject(
                                    name = "검색 결과 예시",
                                    value = """
                                            {
                                              "hasNextPage": false,
                                              "contents": [
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
                    responseCode = "500",
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