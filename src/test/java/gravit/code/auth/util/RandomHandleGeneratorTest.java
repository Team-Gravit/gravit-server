package gravit.code.auth.util;

import gravit.code.domain.user.domain.UserRepository;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RandomHandleGeneratorTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private RandomHandleGenerator randomHandleGenerator;

    @Test
    void 랜덤으로_숫자와_소문자로_이루어진_handle_을_생성합니다() {
        // given
        when(userRepository.existsByHandle(any(String.class))).thenReturn(false);

        // when
        String newHandle = randomHandleGenerator.generateUniqueHandle();

        // then
        assertSoftly(softly -> {
            softly.assertThat(newHandle.length()).isEqualTo(9);
            softly.assertThat(newHandle.charAt(0)).isEqualTo('@');
            softly.assertThat(newHandle.matches(".*\\d.*") || newHandle.matches(".*[a-z].*")).isTrue();
        });
    }

    @Test
    void 이미_handle이_존재한다면_10회_재시도하여_handle을_생성합니다() {
        // given
        when(userRepository.existsByHandle(any(String.class))).thenReturn(
                true,true, true, true, true, true, true, true, true, false);

        // when
        String newHandle = randomHandleGenerator.generateUniqueHandle();

        // then
        assertSoftly(softly -> {
            softly.assertThat(newHandle.length()).isEqualTo(9);
            softly.assertThat(newHandle.charAt(0)).isEqualTo('@');
            softly.assertThat(newHandle.matches(".*\\d.*") || newHandle.matches(".*[a-z].*")).isTrue();
        });
    }

    @Test
    void 핸들_생성_시_10회_이상_재시도를_하였다면_예외를_던집니다() {
        // given
        when(userRepository.existsByHandle(any(String.class))).thenReturn(
                true,true, true, true, true, true, true, true, true, true);

        // when
        // then
        assertThrows(RestApiException.class, ()-> randomHandleGenerator.generateUniqueHandle());

    }
}