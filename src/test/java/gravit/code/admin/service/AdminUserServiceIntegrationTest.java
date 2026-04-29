package gravit.code.admin.service;

import gravit.code.admin.dto.response.AdminUserDetailResponse;
import gravit.code.admin.dto.response.AdminUserSummaryResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserStatus;
import gravit.code.user.fixture.UserFixtureBuilder;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Transactional
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class AdminUserServiceIntegrationTest {

    @Autowired
    private AdminUserService adminUserService;

    @Autowired
    private UserRepository userRepository;

    private User saveUser(
            String email,
            String providerId,
            String nickname,
            String handle,
            Role role
    ) {
        return userRepository.save(UserFixtureBuilder.유저(email, providerId, nickname, handle, role));
    }

    private User saveUserWithStatus(
            String email,
            String providerId,
            String nickname,
            String handle,
            Role role,
            UserStatus status
    ) {
        return userRepository.save(UserFixtureBuilder.상태_지정_유저(email, providerId, nickname, handle, role, status));
    }

    @Nested
    @DisplayName("백오피스 유저 목록을 조회할 때")
    class GetUsersSummary {

        @Test
        void 필터_없이_전체_유저를_최신순으로_반환한다() {
            // given
            saveUser("a@test.com", "provider_a", "유저A", "handleA", Role.USER);
            saveUser("b@test.com", "provider_b", "유저B", "handleB", Role.USER);
            User latest = saveUser("c@test.com", "provider_c", "유저C", "handleC", Role.USER);

            // when
            PageResponse<AdminUserSummaryResponse> result =
                    adminUserService.getUsersSummary(1, null, null, null);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(3);
                softly.assertThat(result.contents().get(0).userId()).isEqualTo(latest.getId());
                softly.assertThat(result.page()).isEqualTo(1);
                softly.assertThat(result.hasNext()).isFalse();
            });
        }

        @Test
        void 빈_검색어는_null로_처리되어_전체_유저를_반환한다() {
            // given
            saveUser("a@test.com", "provider_a", "유저A", "handleA", Role.USER);
            saveUser("b@test.com", "provider_b", "유저B", "handleB", Role.USER);

            // when
            PageResponse<AdminUserSummaryResponse> result =
                    adminUserService.getUsersSummary(1, "", null, null);

            // then
            assertThat(result.contents()).hasSize(2);
        }

        @Test
        void 검색어로_email을_필터링한다() {
            // given
            saveUser("alice@test.com", "provider_a", "유저A", "handleA", Role.USER);
            saveUser("bob@test.com", "provider_b", "유저B", "handleB", Role.USER);

            // when
            PageResponse<AdminUserSummaryResponse> result =
                    adminUserService.getUsersSummary(1, "alice", null, null);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(1);
                softly.assertThat(result.contents().get(0).email()).isEqualTo("alice@test.com");
            });
        }

        @Test
        void 검색어로_nickname을_필터링한다() {
            // given
            saveUser("a@test.com", "provider_a", "그래빗", "handleA", Role.USER);
            saveUser("b@test.com", "provider_b", "다른유저", "handleB", Role.USER);

            // when
            PageResponse<AdminUserSummaryResponse> result =
                    adminUserService.getUsersSummary(1, "그래빗", null, null);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(1);
                softly.assertThat(result.contents().get(0).nickname()).isEqualTo("그래빗");
            });
        }

        @Test
        void 검색어로_handle을_필터링한다() {
            // given
            saveUser("a@test.com", "provider_a", "유저A", "uniqueHandle", Role.USER);
            saveUser("b@test.com", "provider_b", "유저B", "anotherHandle", Role.USER);

            // when
            PageResponse<AdminUserSummaryResponse> result =
                    adminUserService.getUsersSummary(1, "unique", null, null);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(1);
                softly.assertThat(result.contents().get(0).handle()).isEqualTo("uniqueHandle");
            });
        }

        @Test
        void 상태로_유저를_필터링한다() {
            // given
            saveUserWithStatus("a@test.com", "provider_a", "유저A", "handleA", Role.USER, UserStatus.ACTIVE);
            saveUserWithStatus("b@test.com", "provider_b", "유저B", "handleB", Role.USER, UserStatus.SUSPENDED);
            saveUserWithStatus("c@test.com", "provider_c", "유저C", "handleC", Role.USER, UserStatus.SUSPENDED);

            // when
            PageResponse<AdminUserSummaryResponse> result =
                    adminUserService.getUsersSummary(1, null, UserStatus.SUSPENDED, null);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(2);
                softly.assertThat(result.contents())
                        .allMatch(u -> u.status() == UserStatus.SUSPENDED);
            });
        }

        @Test
        void 역할로_유저를_필터링한다() {
            // given
            saveUser("a@test.com", "provider_a", "유저A", "handleA", Role.USER);
            saveUser("b@test.com", "provider_b", "관리자B", "handleB", Role.ADMIN);

            // when
            PageResponse<AdminUserSummaryResponse> result =
                    adminUserService.getUsersSummary(1, null, null, Role.ADMIN);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(1);
                softly.assertThat(result.contents().get(0).role()).isEqualTo(Role.ADMIN);
            });
        }

        @Test
        void 페이지_번호가_0_이하이면_첫_페이지로_처리한다() {
            // given
            saveUser("a@test.com", "provider_a", "유저A", "handleA", Role.USER);
            saveUser("b@test.com", "provider_b", "유저B", "handleB", Role.USER);

            // when
            PageResponse<AdminUserSummaryResponse> result =
                    adminUserService.getUsersSummary(0, null, null, null);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.page()).isEqualTo(1);
                softly.assertThat(result.contents()).hasSize(2);
            });
        }

        @Test
        void 페이지_크기를_초과하면_다음_페이지가_존재한다() {
            // given
            for (int i = 1; i <= 11; i++) {
                saveUser("user" + i + "@test.com", "provider_" + i, "유저" + i, "handle" + i, Role.USER);
            }

            // when
            PageResponse<AdminUserSummaryResponse> firstPage =
                    adminUserService.getUsersSummary(1, null, null, null);
            PageResponse<AdminUserSummaryResponse> secondPage =
                    adminUserService.getUsersSummary(2, null, null, null);

            // then
            assertSoftly(softly -> {
                softly.assertThat(firstPage.contents()).hasSize(10);
                softly.assertThat(firstPage.hasNext()).isTrue();
                softly.assertThat(secondPage.contents()).hasSize(1);
                softly.assertThat(secondPage.hasNext()).isFalse();
            });
        }
    }

    @Nested
    @DisplayName("백오피스 유저 상세를 조회할 때")
    class GetUserDetail {

        @Test
        void 유저가_존재하면_상세_정보를_반환한다() {
            // given
            User user = saveUser("a@test.com", "provider_a", "유저A", "handleA", Role.USER);

            // when
            AdminUserDetailResponse result = adminUserService.getUserDetail(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.userId()).isEqualTo(user.getId());
                softly.assertThat(result.email()).isEqualTo("a@test.com");
                softly.assertThat(result.nickname()).isEqualTo("유저A");
                softly.assertThat(result.handle()).isEqualTo("handleA");
                softly.assertThat(result.role()).isEqualTo(Role.USER);
                softly.assertThat(result.status()).isEqualTo(UserStatus.ACTIVE);
                softly.assertThat(result.level()).isEqualTo(1);
                softly.assertThat(result.createdAt()).isNotNull();
            });
        }

        @Test
        void 유저가_존재하지_않으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> adminUserService.getUserDetail(999L))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(CustomErrorCode.USER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("백오피스 유저 상태를 변경할 때")
    class UpdateUserStatus {

        @Test
        void ACTIVE_유저를_SUSPENDED로_변경한다() {
            // given
            User user = saveUser("a@test.com", "provider_a", "유저A", "handleA", Role.USER);

            // when
            adminUserService.updateUserStatus(user.getId(), UserStatus.SUSPENDED);

            // then
            User updated = userRepository.findById(user.getId()).orElseThrow();
            assertThat(updated.getStatus()).isEqualTo(UserStatus.SUSPENDED);
        }

        @Test
        void SUSPENDED_유저를_ACTIVE로_변경한다() {
            // given
            User user = saveUserWithStatus("a@test.com", "provider_a", "유저A", "handleA", Role.USER, UserStatus.SUSPENDED);

            // when
            adminUserService.updateUserStatus(user.getId(), UserStatus.ACTIVE);

            // then
            User updated = userRepository.findById(user.getId()).orElseThrow();
            assertThat(updated.getStatus()).isEqualTo(UserStatus.ACTIVE);
        }

        @Test
        void DELETED로_변경하면_예외를_던진다() {
            // given
            User user = saveUser("a@test.com", "provider_a", "유저A", "handleA", Role.USER);

            // when & then
            assertThatThrownBy(() -> adminUserService.updateUserStatus(user.getId(), UserStatus.DELETED))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(CustomErrorCode.USER_STATUS_TRANSITION_INVALID);
        }

        @Test
        void 유저가_존재하지_않으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> adminUserService.updateUserStatus(999L, UserStatus.SUSPENDED))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(CustomErrorCode.USER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("백오피스 유저 역할을 변경할 때")
    class UpdateUserRole {

        @Test
        void USER를_ADMIN으로_변경한다() {
            // given
            User user = saveUser("a@test.com", "provider_a", "유저A", "handleA", Role.USER);

            // when
            adminUserService.updateUserRole(user.getId(), Role.ADMIN);

            // then
            User updated = userRepository.findById(user.getId()).orElseThrow();
            assertThat(updated.getRole()).isEqualTo(Role.ADMIN);
        }

        @Test
        void ADMIN을_USER로_변경한다() {
            // given
            User user = saveUser("a@test.com", "provider_a", "관리자A", "handleA", Role.ADMIN);

            // when
            adminUserService.updateUserRole(user.getId(), Role.USER);

            // then
            User updated = userRepository.findById(user.getId()).orElseThrow();
            assertThat(updated.getRole()).isEqualTo(Role.USER);
        }

        @Test
        void 유저가_존재하지_않으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> adminUserService.updateUserRole(999L, Role.ADMIN))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(CustomErrorCode.USER_NOT_FOUND);
        }
    }
}
