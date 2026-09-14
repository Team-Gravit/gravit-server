package gravit.code.user.support;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Random;

import static gravit.code.global.exception.domain.CustomErrorCode.HANDLE_CONFLICT_TEN_TIMES;
import static gravit.code.global.exception.domain.CustomErrorCode.HANDLE_INVALID;

@Component
@RequiredArgsConstructor
public class RandomHandleGenerator{

    private static final String CHARACTERS = "abcdefghijklmnopqrstuvwxyz0123456789";
    private static final Random RANDOM = new Random();
    private static final int MAX_RETRY = 10;
    private static final int MAX_LENGTH = 8;
    private static final String HANDLE_PATTERN = "^[a-z0-9]{8}$";

    private final UserRepository userRepository;

    public String generateUniqueHandle() {
        for (int i = 0; i < MAX_RETRY; i++) {
            String handle = generateHandle();

            validateHandle(handle);

            if(!userRepository.existsByHandle(handle)) {
                return handle;
            }
        }
        throw new RestApiException(HANDLE_CONFLICT_TEN_TIMES);
    }

    private void validateHandle(String handle) {
        if(handle == null || !handle.matches(HANDLE_PATTERN))
            throw new RestApiException(HANDLE_INVALID);
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
