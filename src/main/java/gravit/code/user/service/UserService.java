package gravit.code.user.service;

import gravit.code.common.exception.domain.CustomErrorCode;
import gravit.code.common.exception.domain.RestApiException;
import gravit.code.user.domain.User;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public UserLevelResponse updateUserLevel(Long userId){
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.updateXp(20);

        return UserLevelResponse.create(user.getLevel(), user.getXp());
    }
}
