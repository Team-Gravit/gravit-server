package gravit.code.admin.service;

import gravit.code.admin.dto.response.AdminMeResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixtureBuilder;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AdminMeServiceIntegrationTest {

    @Autowired
    private AdminMeService adminMeService;

    @Autowired
    private UserFixtureBuilder userFixtureBuilder;

    @Nested
    @DisplayName("현재 운영자 프로필을 조회할 때")
    class GetMe {

        @Test
        @DisplayName("본인 정보가 AdminMeResponse 로 매핑되어 반환된다")
        void 본인_프로필_조회에_성공한다() {
            // given
            User admin = userFixtureBuilder.user()
                    .email("admin@gravit.com")
                    .providerId("admin_provider")
                    .nickname("운영자")
                    .handle("admin_handle")
                    .level(3) // UserFixtureBuilder 의 level 필드는 profileImgNumber 로 매핑된다
                    .create();

            // when
            AdminMeResponse response = adminMeService.getMe(admin.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.adminId()).isEqualTo(admin.getId());
                softly.assertThat(response.nickname()).isEqualTo("운영자");
                softly.assertThat(response.email()).isEqualTo("admin@gravit.com");
                softly.assertThat(response.profileImgNumber()).isEqualTo(3);
            });
        }

        @Test
        @DisplayName("존재하지 않는 유저면 USER_NOT_FOUND 예외가 발생한다")
        void 존재하지_않는_유저면_예외가_발생한다() {
            // given
            long notExistUserId = 99999L;

            // when & then
            assertThatThrownBy(() -> adminMeService.getMe(notExistUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }
    }
}
