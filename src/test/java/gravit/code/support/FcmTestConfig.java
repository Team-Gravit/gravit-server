package gravit.code.support;

import com.google.firebase.messaging.FirebaseMessaging;
import org.mockito.Mockito;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;

// test 프로파일에서는 FcmConfig(@Profile("!test"))가 비활성화되어 FirebaseMessaging 빈이 없으므로
// FcmService 주입이 가능하도록 mock 빈을 등록한다
@TestConfiguration
public class FcmTestConfig {

    @Bean
    public FirebaseMessaging firebaseMessaging() {
        return Mockito.mock(FirebaseMessaging.class);
    }
}
