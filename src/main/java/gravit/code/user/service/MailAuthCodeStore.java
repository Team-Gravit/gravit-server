package gravit.code.user.service;

public interface MailAuthCodeStore {
    void save(
            String mailAuthCode,
            long userId,
            int expireTime
    );
    Long consume(String mailAuthCode);
}
