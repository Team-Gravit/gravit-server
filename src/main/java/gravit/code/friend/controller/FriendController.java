package gravit.code.friend.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.friend.controller.docs.FriendControllerDocs;
import gravit.code.friend.dto.FollowCountsResponse;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import gravit.code.friend.service.FriendService;
import gravit.code.friend.dto.response.FriendResponse;
import gravit.code.global.dto.response.SliceResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/v1/friends")
@RequiredArgsConstructor
public class FriendController implements FriendControllerDocs {

    private final FriendService friendService;

    @PostMapping("/following/{followeeId}")
    public ResponseEntity<FriendResponse> following(
            @PathVariable("followeeId")Long followeeId,
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        long followerId = loginUser.getId();
        FriendResponse friendResponse = friendService.following(followerId, followeeId);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).body(friendResponse);
    }

    @PostMapping("/unfollowing/{followeeId}")
    public ResponseEntity<Void> unFollowing(
            @PathVariable("followeeId")Long followeeId,
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        long userId = loginUser.getId();
        friendService.unFollowing(userId, followeeId);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).build();
    }

    @PostMapping("/reject-following/{followerId}")
    public ResponseEntity<Void> rejectFollowing(
            @PathVariable("followerId") Long followerId,
            @AuthenticationPrincipal LoginUser loginUser) {
        long userId = loginUser.getId();
        friendService.rejectFollowing(userId, followerId);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).build();
    }

    @GetMapping("/follower")
    public ResponseEntity<SliceResponse<FollowerResponse>> getFollowers(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "0") int page
    ){
        Long followeeId = loginUser.getId();
        SliceResponse<FollowerResponse> followers = friendService.getFollowers(followeeId, page);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).body(followers);
    }

    @GetMapping("/following")
    public ResponseEntity<SliceResponse<FollowingResponse>> getFollowings(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "0") int page
    ){
        Long followerId = loginUser.getId();
        SliceResponse<FollowingResponse> followings = friendService.getFollowings(followerId, page);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).body(followings);
    }

    @GetMapping("/count")
    public ResponseEntity<FollowCountsResponse> getFollowAndFollowingCount(@AuthenticationPrincipal LoginUser loginUser){
        long userId = loginUser.getId();
        FollowCountsResponse followAndFollowingCounts = friendService.getFollowAndFollowingCounts(userId);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).body(followAndFollowingCounts);
    }

}
