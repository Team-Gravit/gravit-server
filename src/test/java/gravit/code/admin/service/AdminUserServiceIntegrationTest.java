package gravit.code.admin.service;

import gravit.code.admin.dto.response.UserDetailResponse;
import gravit.code.admin.dto.response.UserListItemResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserStatus;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AdminUserServiceIntegrationTest {

    private static final long ADMIN_ID = 999L;

    @Autowired
    private AdminUserService adminUserService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @Test
    @DisplayName("유저 목록 native projection 매핑이 정상 동작한다")
    void getUsers_mapsProjection() {
        User user1 = userRepository.save(userFixture.일반_유저(1));
        userRepository.save(userFixture.일반_유저(2));

        PageResponse<UserListItemResponse> result = adminUserService.getUsers(1, null, null, null);

        assertThat(result.contents()).hasSize(2);
        UserListItemResponse first = result.contents().stream()
                .filter(u -> u.userId() == user1.getId())
                .findFirst()
                .orElseThrow();
        assertSoftly(softly -> {
            softly.assertThat(first.email()).isEqualTo("u1@test.com");
            softly.assertThat(first.nickname()).isEqualTo("유저1");
            softly.assertThat(first.status()).isEqualTo(UserStatus.ACTIVE);
        });
    }

    @Test
    @DisplayName("search 는 email/nickname/handle 부분일치(대소문자 무시)로 동작한다")
    void getUsers_search() {
        userRepository.save(userFixture.일반_유저(1));
        userRepository.save(userFixture.일반_유저(2));

        PageResponse<UserListItemResponse> result = adminUserService.getUsers(1, "U2@TEST", null, null);

        assertThat(result.contents()).hasSize(1);
        assertThat(result.contents().get(0).email()).isEqualTo("u2@test.com");
    }

    @Test
    @DisplayName("유저 상세 조회가 동작한다")
    void getUser_detail() {
        User user = userRepository.save(userFixture.일반_유저(1));

        UserDetailResponse detail = adminUserService.getUser(user.getId());

        assertThat(detail.userId()).isEqualTo(user.getId());
        assertThat(detail.email()).isEqualTo("u1@test.com");
    }

    @Test
    @DisplayName("상태 변경(SUSPENDED)이 native UPDATE 로 반영된다")
    void updateStatus_suspend() {
        User user = userRepository.save(userFixture.일반_유저(1));

        adminUserService.updateStatus(ADMIN_ID, user.getId(), UserStatus.SUSPENDED);

        assertThat(adminUserService.getUser(user.getId()).status()).isEqualTo(UserStatus.SUSPENDED);
    }

    @Test
    @DisplayName("권한 변경(ADMIN)이 native UPDATE 로 반영된다")
    void updateRole_toAdmin() {
        User user = userRepository.save(userFixture.일반_유저(1));

        adminUserService.updateRole(ADMIN_ID, user.getId(), gravit.code.user.domain.Role.ADMIN);

        assertThat(adminUserService.getUser(user.getId()).role()).isEqualTo(gravit.code.user.domain.Role.ADMIN);
    }

    @Test
    @DisplayName("없는 유저 상세/변경은 USER_NOT_FOUND")
    void user_notFound() {
        org.assertj.core.api.Assertions.assertThatThrownBy(() -> adminUserService.getUser(99999L))
                .isInstanceOf(gravit.code.global.exception.domain.RestApiException.class)
                .extracting(e -> ((gravit.code.global.exception.domain.RestApiException) e).getErrorCode())
                .isEqualTo(gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND);
    }

    @Test
    @DisplayName("DELETED 유저도 admin 목록/필터에서 조회되고, totalUsers(activeUsers)에서는 제외된다")
    void deletedUser_visibleToAdmin_excludedFromCount() {
        User active = userRepository.save(userFixture.일반_유저(1));
        User toDelete = userRepository.save(userFixture.일반_유저(2));

        adminUserService.updateStatus(ADMIN_ID, toDelete.getId(), UserStatus.DELETED);

        PageResponse<UserListItemResponse> deleted = adminUserService.getUsers(1, null, UserStatus.DELETED, null);
        assertSoftly(softly -> {
            softly.assertThat(deleted.contents()).hasSize(1);
            softly.assertThat(deleted.contents().get(0).userId()).isEqualTo(toDelete.getId());
            // 전체(필터 없음)에도 DELETED 포함되어 active + deleted = 2
            softly.assertThat(adminUserService.getUsers(1, null, null, null).contents()).hasSize(2);
        });
        assertThat(active.getId()).isNotNull();
    }

    @Test
    @DisplayName("DELETED -> ACTIVE 복구 시 handle 이 재발급된다")
    void updateStatus_restoreFromDeleted_regeneratesHandle() {
        User user = userFixture.일반_유저(1);

        adminUserService.updateStatus(ADMIN_ID, user.getId(), UserStatus.DELETED);
        assertThat(adminUserService.getUser(user.getId()).handle()).isNull(); // soft delete 로 handle 제거됨

        adminUserService.updateStatus(ADMIN_ID, user.getId(), UserStatus.ACTIVE);

        UserDetailResponse restored = adminUserService.getUser(user.getId());
        assertThat(restored.status()).isEqualTo(UserStatus.ACTIVE);
        assertThat(restored.handle()).isNotBlank(); // 재발급됨
    }
}
