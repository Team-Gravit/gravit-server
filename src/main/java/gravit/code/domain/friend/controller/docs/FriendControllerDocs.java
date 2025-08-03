package gravit.code.domain.friend.controller.docs;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.domain.friend.dto.response.FollowerResponse;
import gravit.code.domain.friend.dto.response.FollowingResponse;
import gravit.code.domain.friend.dto.response.FriendResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

import java.util.List;

@Tag(name = "Friend API", description = "팔로우/언팔로우 및 친구 목록 조회 API")
public interface FriendControllerDocs {
    // 팔로잉
    @Operation(summary = "팔로잉", description = "다른 사용자를 팔로잉합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "팔로잉 성공")
    })
    @PostMapping("/following/{followeeId}")
    ResponseEntity<FriendResponse> following(
            @Parameter(description = "팔로잉할 대상 유저 ID") @PathVariable("followeeId") Long followeeId,
            @AuthenticationPrincipal LoginUser loginUser);

    // 언팔로잉
    @Operation(summary = "언팔로잉", description = "다른 사용자에 대한 팔로잉를 취소합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "언팔로잉 성공")
    })
    @PostMapping("/unfollowing/{followeeId}")
    ResponseEntity<String> unFollowing(
            @Parameter(description = "언팔로잉할 대상 유저 ID") @PathVariable("followeeId") Long followeeId,
            @AuthenticationPrincipal LoginUser loginUser);

    // 내 팔로워들 조회
    @Operation(summary = "팔로워 목록 조회", description = "현재 사용자를 팔로우하고 있는 사용자 목록을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "팔로워 목록 조회 성공")
    })
    @GetMapping("/follower")
    ResponseEntity<List<FollowerResponse>> getFollowers(
            @AuthenticationPrincipal LoginUser loginUser);

    // 내 팔로잉들 조회
    @Operation(summary = "팔로잉 목록 조회", description = "현재 사용자가 팔로잉하고 있는 사용자 목록을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "팔로잉 목록 조회 성공")
    })
    @GetMapping("/following")
    ResponseEntity<List<FollowingResponse>> getFollowings(
            @AuthenticationPrincipal LoginUser loginUser);
}
