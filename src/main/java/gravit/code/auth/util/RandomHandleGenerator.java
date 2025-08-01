package gravit.code.auth.util;

import gravit.code.domain.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Random;

/**
 * handle 길이는 8 자리로 fix
 */
@Component
@RequiredArgsConstructor
public class RandomHandleGenerator implements HandleGenerator{

    private static final String CHARACTERS = "abcdefghijklmnopqrstuvwxyz0123456789";
    private static final Random RANDOM = new Random();
    private static final int MAX_RETRY = 10;

    private final UserRepository userRepository;

    @Override
    public String generateUniqueHandle() {
        for (int i = 0; i < MAX_RETRY; i++) {
            String handle = generateHandle();
            if(!userRepository.existsByHandle(handle)) {
                return handle;
            }
        }
        throw new IllegalStateException("Handle 생성 실패: 중복으로 인해 유효한 handle 을 찾지 못했습니다.");
    }

    private String generateHandle(){
        int length = RANDOM.nextInt(5) + 6;
        StringBuilder handle = new StringBuilder(length);
        handle.append("@");

        for(int i = 0; i < length; i++){
            int index = RANDOM.nextInt(CHARACTERS.length());
            handle.append(CHARACTERS.charAt(index));
        }

        return handle.toString();
    }
}
