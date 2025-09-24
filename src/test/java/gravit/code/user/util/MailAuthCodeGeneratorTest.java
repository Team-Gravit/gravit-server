package gravit.code.user.util;

import gravit.code.user.infrastructure.MailAuthCodeGenerator;
import org.junit.jupiter.api.Test;

class MailAuthCodeGeneratorTest {


    @Test
    void generate() {
        //given
        int length = 16;

        //when
        String result = MailAuthCodeGenerator.createMailAuthCode(length);

        //then
        System.out.println(result);
    }

}