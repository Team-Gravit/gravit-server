package gravit.code;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(classes = GravitApplication.class)
@ActiveProfiles("test")
class GravitApplicationTests {

    @Test
    void contextLoads() {
    }

}
