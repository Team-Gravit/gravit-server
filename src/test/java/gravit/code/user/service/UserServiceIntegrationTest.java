package gravit.code.user.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.dto.response.UserResponse;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static gravit.code.global.exception.domain.CustomErrorCode.ALREADY_ONBOARDING;
import static gravit.code.global.exception.domain.CustomErrorCode.NICKNAME_LENGTH_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.PROFILE_IMG_NUM_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_PAGE_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_RESTORE_ONLY_POSSIBLE_DELETED_STATUS_USER;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class UserServiceIntegrationTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private LeagueFixture leagueFixture;

    @Nested
    @DisplayName("유저를 아이디로 조회할 때")
    class FindById {

        @Test
        void 존재하는_유저이면_UserResponse를_반환한다() {
            // given
            User user = userFixture.일반_유저(1);

            // when
            UserResponse result = userService.findById(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.userId()).isEqualTo(user.getId());
                softly.assertThat(result.nickname()).isEqualTo(user.getNickname());
                softly.assertThat(result.providerId()).isEqualTo(user.getProviderId());
            });
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userService.findById(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("온보딩을 진행할 때")
    class Onboarding {

        @Test
        void 정상_요청이면_온보딩에_성공한다() {
            // given
            leagueFixture.브론즈_3(); // OnboardingCompletedEvent 리스너가 리그 초기화 시 필요
            User user = userFixture.일반_유저(1);
            OnboardingRequest request = new OnboardingRequest("새닉네임", 3);

            // when
            UserResponse result = userService.onboarding(user.getId(), request);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.nickname()).isEqualTo("새닉네임");
                softly.assertThat(result.profileImgNumber()).isEqualTo(3);
                softly.assertThat(userRepository.findById(user.getId()).get().isOnboarded()).isTrue();
            });
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;
            OnboardingRequest request = new OnboardingRequest("닉네임", 1);

            // when & then
            assertThatThrownBy(() -> userService.onboarding(nonExistentUserId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }

        @Test
        void 이미_온보딩된_유저이면_예외를_던진다() {
            // given
            leagueFixture.브론즈_3(); // OnboardingCompletedEvent 리스너가 리그 초기화 시 필요
            User user = userFixture.일반_유저(1);
            userService.onboarding(user.getId(), new OnboardingRequest("닉네임", 1));

            // when & then
            assertThatThrownBy(() -> userService.onboarding(user.getId(), new OnboardingRequest("닉네임", 1)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(ALREADY_ONBOARDING);
        }

        @Test
        void 닉네임_길이가_범위를_벗어나면_예외를_던진다() {
            // given
            User user = userFixture.일반_유저(1);
            OnboardingRequest request = new OnboardingRequest("이름이너무길다길다", 1); // 9자

            // when & then
            assertThatThrownBy(() -> userService.onboarding(user.getId(), request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(NICKNAME_LENGTH_INVALID);
        }

        @Test
        void 프로필_이미지_번호가_범위를_벗어나면_예외를_던진다() {
            // given
            User user = userFixture.일반_유저(1);
            OnboardingRequest request = new OnboardingRequest("닉네임", 21); // 최대 20

            // when & then
            assertThatThrownBy(() -> userService.onboarding(user.getId(), request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROFILE_IMG_NUM_INVALID);
        }
    }

    @Nested
    @DisplayName("프로필을 수정할 때")
    class UpdateUserProfile {

        @Test
        void 정상_요청이면_프로필_수정에_성공한다() {
            // given
            User user = userFixture.일반_유저(1);
            UserProfileUpdateRequest request = new UserProfileUpdateRequest("새닉네임", 5);

            // when
            UserResponse result = userService.updateUserProfile(user.getId(), request);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.nickname()).isEqualTo("새닉네임");
                softly.assertThat(result.profileImgNumber()).isEqualTo(5);
            });
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userService.updateUserProfile(nonExistentUserId, new UserProfileUpdateRequest("닉네임", 1)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("마이페이지를 조회할 때")
    class GetMyPage {

        @Test
        void 존재하는_유저이면_마이페이지를_반환한다() {
            // given
            User user = userFixture.일반_유저(1);

            // when
            MyPageResponse result = userService.getMyPage(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.nickname()).isEqualTo(user.getNickname());
                softly.assertThat(result.handle()).isEqualTo(user.getHandle());
                softly.assertThat(result.follower()).isEqualTo(0);
                softly.assertThat(result.following()).isEqualTo(0);
            });
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userService.getMyPage(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_PAGE_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("탈퇴한 유저를 복원할 때")
    class RestoreUser {

        @Test
        void 삭제된_유저이면_복원에_성공한다() {
            // given
            User user = userFixture.일반_유저(1);
            String providerId = user.getProviderId();
            userRepository.deleteById(user.getId()); // soft-delete

            // when
            userService.restoreUser(providerId);

            // then
            assertThat(userRepository.findById(user.getId())).isPresent();
        }

        @Test
        void 삭제되지_않은_유저는_복원할_수_없다() {
            // given
            User user = userFixture.일반_유저(1);

            // when & then
            assertThatThrownBy(() -> userService.restoreUser(user.getProviderId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_RESTORE_ONLY_POSSIBLE_DELETED_STATUS_USER);
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            String nonExistentProviderId = "non-existent-provider";

            // when & then
            assertThatThrownBy(() -> userService.restoreUser(nonExistentProviderId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("레슨 제출로 유저 레벨을 업데이트할 때")
    class UpdateUserLevelByLessonSubmission {

        @Test
        void 첫_시도이면_정확도에_비례한_XP가_누적된다() {
            // given
            User user = userFixture.일반_유저(1);
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(1L, 60, 100);

            // when
            UserLevelResponse result = userService.updateUserLevelByLessonSubmission(user.getId(), request, true);

            // then
            // 20 point * 100% accuracy = 20 XP
            assertThat(result.xp()).isEqualTo(20);
        }

        @Test
        void 재시도이면_XP가_증가하지_않는다() {
            // given
            User user = userFixture.일반_유저(1);
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(1L, 60, 100);

            // when
            UserLevelResponse result = userService.updateUserLevelByLessonSubmission(user.getId(), request, false);

            // then
            assertThat(result.xp()).isEqualTo(0);
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(1L, 60, 100);

            // when & then
            assertThatThrownBy(() -> userService.updateUserLevelByLessonSubmission(nonExistentUserId, request, true))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }
    }
}
