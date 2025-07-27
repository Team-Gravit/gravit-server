package gravit.code.domain.friend.controller;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.domain.friend.controller.docs.FriendControllerDocs;
import gravit.code.domain.friend.dto.response.FollowerResponse;
import gravit.code.domain.friend.dto.response.FollowingResponse;
import gravit.code.domain.friend.service.FriendService;
import gravit.code.domain.friend.dto.response.FriendResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/friends")
@RequiredArgsConstructor
public class FriendController implements FriendControllerDocs {

    private final FriendService friendService;

    @PostMapping("/following/{followeeId}")
    public ResponseEntity<FriendResponse> following(@PathVariable("followeeId")Long followeeId,
                                                    @AuthenticationPrincipal LoginUser loginUser) {
        Long followerId = loginUser.getId();
        log.info("[following] followerId : {} , followeeId : {}", followerId, followeeId);
        FriendResponse friendResponse = friendService.following(loginUser.getId(), followeeId);
        return ResponseEntity.ok(friendResponse);
    }

    @PostMapping("/unfollowing/{followeeId}")
    public ResponseEntity<String> unFollowing(@PathVariable("followeeId")Long followeeId,
                                              @AuthenticationPrincipal LoginUser loginUser) {
        friendService.unFollowing(followeeId, loginUser.getId());
        return ResponseEntity.ok("팔로우를 성공적으로 취소하였습니다. followeeId = " + followeeId);
    }

    @GetMapping("/follower")
    public ResponseEntity<List<FollowerResponse>> getFollowers(@AuthenticationPrincipal LoginUser loginUser){
        Long followeeId = loginUser.getId();
        List<FollowerResponse> followers = friendService.getFollowers(followeeId);
        return ResponseEntity.ok(followers);
    }

    @GetMapping("/following")
    public ResponseEntity<List<FollowingResponse>> getFollowings(@AuthenticationPrincipal LoginUser loginUser){
        Long followerId = loginUser.getId();
        List<FollowingResponse> followings = friendService.getFollowings(followerId);
        return ResponseEntity.ok(followings);
    }

}
