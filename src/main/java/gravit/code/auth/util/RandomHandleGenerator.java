package gravit.code.auth.util;

import gravit.code.domain.user.domain.UserRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Random;

/**
 * handle 길이는 8 자리로 fix (저장은 @ 미 포함)
 */
@Component
@RequiredArgsConstructor
public class RandomHandleGenerator implements HandleGenerator{

    private static final String CHARACTERS = "abcdefghijklmnopqrstuvwxyz0123456789";
    private static final Random RANDOM = new Random();
    private static final int MAX_RETRY = 10;
    private static final int MAX_LENGTH = 8;

    private final UserRepository userRepository;

    @Override
    public String generateUniqueHandle() {
        for (int i = 0; i < MAX_RETRY; i++) {
            String handle = generateHandle();

            validateHandle(handle);

            if(!userRepository.existsByHandle(handle)) {
                return handle;
            }
        }
        throw new RestApiException(CustomErrorCode.HANDLE_CONFLICT_TEN_TIMES);
    }

    private void validateHandle(String handle) {
        if(handle == null || !handle.matches("^[a-z0-9]{8}$"))
            throw new RestApiException(CustomErrorCode.HANDLE_INVALID);
    }

    private String generateHandle(){
        StringBuilder handle = new StringBuilder(MAX_LENGTH);

        for(int i = 0; i < MAX_LENGTH; i++){
            int index = RANDOM.nextInt(CHARACTERS.length());
            handle.append(CHARACTERS.charAt(index));
        }

        return handle.toString();
    }
}
