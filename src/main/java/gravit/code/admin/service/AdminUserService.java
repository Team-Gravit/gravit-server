package gravit.code.admin.service;

import gravit.code.admin.dto.response.UserDetailResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.UserStatus;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class AdminUserService {

    private static final int USER_PAGE_SIZE = 10;
    private static final Sort USER_SORT = Sort.by(Sort.Direction.DESC, "id");

    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public PageResponse<UserDetailResponse> getUsers(
            int page,
            String search,
            UserStatus status,
            Role role
    ) {
        int safePage = getSafePage(page);
        String safeSearch = StringUtils.hasText(search) ? search : null; // 빈문자열 방지

        PageRequest pageRequest = PageRequest.of(safePage, USER_PAGE_SIZE, USER_SORT);
        Page<UserDetailResponse> response = userRepository.findByKeywordAndStatusAndRole(pageRequest, safeSearch, status, role);
        return PageResponse.from(response);
    }

    private int getSafePage(int page){
        return Math.max(0, page - 1);
    }
}
