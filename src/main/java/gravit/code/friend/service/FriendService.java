package gravit.code.friend.service;


import gravit.code.friend.domain.Friend;
import gravit.code.friend.domain.FriendRepository;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import gravit.code.friend.dto.response.FriendResponse;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.user.domain.UserRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class FriendService {

    private final ApplicationEventPublisher publisher;

    private final FriendRepository friendRepository;
    private final UserRepository userRepository;

    @Transactional
    public FriendResponse following(Long followerId, Long followeeId) {
        log.info("팔로우 요청 순서 : follower : {}, followee : {}", followerId, followeeId);

        // 자기 자신에게 팔로잉 불가능
        if(followeeId.equals(followerId)){
            throw new RestApiException(CustomErrorCode.UNABLE_FOLLOWING_YOURSELF);
        }

        // 팔로잉 대상 유저가 존재하는지 확인
        userRepository.findById(followeeId)
                .orElseThrow(()-> new RestApiException(CustomErrorCode.FRIEND_NOT_FOUND));

        // 이미 팔로우 중인지 중복 체크
        if(friendRepository.existsByFollowerIdAndFolloweeId(followerId, followeeId)){
            throw new RestApiException(CustomErrorCode.FRIEND_CONFLICT);
        }

        Friend friend = Friend.create(followerId, followeeId);

        friendRepository.save(friend);

        publisher.publishEvent(new FollowMissionEvent(followeeId));

        return FriendResponse.from(friend);
    }

    @Transactional
    public void unFollowing(Long followerId, Long followeeId) {
        Optional<Friend> friend = friendRepository.findByFolloweeIdAndFollowerId(followeeId, followerId);

        // 만약 팔로우 한 내역이 존재하지 않는다면
        if(friend.isEmpty()){
            throw new RestApiException(CustomErrorCode.FRIEND_NOT_FOUND);
        }

        friendRepository.delete(friend.get());
    }

    @Transactional(readOnly = true)
    public List<FollowerResponse> getFollowers(Long followeeId) {
        return friendRepository.findByFollowersByFolloweeId(followeeId);
    }

    @Transactional(readOnly = true)
    public List<FollowingResponse> getFollowings(Long followerId) {
        return friendRepository.findByFollowingsByFollowerId(followerId);
    }
}
