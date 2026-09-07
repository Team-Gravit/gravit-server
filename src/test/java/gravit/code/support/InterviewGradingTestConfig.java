package gravit.code.support;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;

// test 프로파일에서는 LLM 게이트웨이가 없으므로 판정 클라이언트를 스텁으로 대체한다.
// 테스트는 StubInterviewGradingClient 타입으로 주입받아 응답과 실패를 지정한다
@TestConfiguration
public class InterviewGradingTestConfig {

    @Bean
    @Primary
    public StubInterviewGradingClient stubInterviewGradingClient() {
        return new StubInterviewGradingClient();
    }
}
