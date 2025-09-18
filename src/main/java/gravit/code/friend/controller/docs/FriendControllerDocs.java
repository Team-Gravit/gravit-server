package gravit.code.friend.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import gravit.code.friend.dto.response.FriendResponse;
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

import java.util.List;

@Tag(name = "Friend API", description = "팔로우/언팔로우 및 친구 목록 조회 API")
public interface FriendControllerDocs {

    @Operation(summary = "팔로잉", description = "다른 사용자를 팔로잉합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 팔로잉 성공"),
            @ApiResponse(responseCode = "FRIEND_4001", description = "🚨 자기 자신 팔로잉 불가",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "자기 자신 팔로잉 불가",
                                            value = "{\"error\" : \"FRIEND_4001\", \"message\" : \"자기 자신에게 팔로잉은 불가능합니다\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "FRIEND_4041", description = "🚨 팔로우 대상 유저 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "팔로우 대상 유저 조회 실패",
                                            value = "{\"error\" : \"FRIEND_4041\", \"message\" : \"팔로우 내역이 존재하지 않습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "FRIEND_4091", description = "🚨 이미 팔로잉 중인 유저",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "이미 팔로잉 중인 유저",
                                            value = "{\"error\" : \"FRIEND_4091\", \"message\" : \"이미 팔로잉을 한 유저입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "GLOBAL_5001", description = "🚨 예기치 못한 예외 발생",
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
            @Parameter(description = "팔로잉할 대상 유저 ID") @PathVariable("followeeId") Long followeeId,
            @AuthenticationPrincipal LoginUser loginUser);


    @Operation(summary = "언팔로잉", description = "다른 사용자에 대한 팔로잉을 취소합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 언팔로잉 성공"),
            @ApiResponse(responseCode = "FRIEND_4041", description = "🚨 팔로우 내역 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "팔로우 내역 조회 실패",
                                            value = "{\"error\" : \"FRIEND_4041\", \"message\" : \"팔로우 내역이 존재하지 않습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "GLOBAL_5001", description = "🚨 예기치 못한 예외 발생",
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
    ResponseEntity<String> unFollowing(
            @Parameter(description = "언팔로잉할 대상 유저 ID") @PathVariable("followeeId") Long followeeId,
            @AuthenticationPrincipal LoginUser loginUser);


    @Operation(summary = "팔로워 목록 조회", description = "현재 사용자를 팔로우하고 있는 사용자 목록을 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 팔로워 목록 조회 성공"),
            @ApiResponse(responseCode = "GLOBAL_5001", description = "🚨 예기치 못한 예외 발생",
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
    ResponseEntity<List<FollowerResponse>> getFollowers(
            @AuthenticationPrincipal LoginUser loginUser);


    @Operation(summary = "팔로잉 목록 조회", description = "현재 사용자가 팔로잉하고 있는 사용자 목록을 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 팔로잉 목록 조회 성공"),
            @ApiResponse(responseCode = "GLOBAL_5001", description = "🚨 예기치 못한 예외 발생",
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
    ResponseEntity<List<FollowingResponse>> getFollowings(
            @AuthenticationPrincipal LoginUser loginUser);
}