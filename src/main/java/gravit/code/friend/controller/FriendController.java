package gravit.code.friend.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.friend.controller.docs.FriendControllerDocs;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import gravit.code.friend.service.FriendService;
import gravit.code.friend.dto.response.FriendResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
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
        FriendResponse friendResponse = friendService.following(followerId, followeeId);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).body(friendResponse);
    }

    @PostMapping("/unfollowing/{followeeId}")
    public ResponseEntity<Void> unFollowing(@PathVariable("followeeId")Long followeeId,
                                              @AuthenticationPrincipal LoginUser loginUser) {
        friendService.unFollowing(loginUser.getId(), followeeId);
        HttpStatus status = HttpStatus.NO_CONTENT;
        return ResponseEntity.status(status).build();
    }

    @GetMapping("/follower")
    public ResponseEntity<List<FollowerResponse>> getFollowers(@AuthenticationPrincipal LoginUser loginUser){
        Long followeeId = loginUser.getId();
        List<FollowerResponse> followers = friendService.getFollowers(followeeId);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).body(followers);
    }

    @GetMapping("/following")
    public ResponseEntity<List<FollowingResponse>> getFollowings(@AuthenticationPrincipal LoginUser loginUser){
        Long followerId = loginUser.getId();
        List<FollowingResponse> followings = friendService.getFollowings(followerId);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).body(followings);
    }

}
