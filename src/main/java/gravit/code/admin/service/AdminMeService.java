package gravit.code.admin.service;

import gravit.code.admin.dto.response.AdminMeResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class AdminMeService {

    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public AdminMeResponse getMe(long adminId) {
        User admin = userRepository.findById(adminId)
                .orElseThrow(() -> new RestApiException(USER_NOT_FOUND));

        return AdminMeResponse.from(admin);
    }
}
