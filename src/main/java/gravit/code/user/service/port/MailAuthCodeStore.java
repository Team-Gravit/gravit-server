package gravit.code.user.service.port;

public interface MailAuthCodeStore {
    void save(String mailAuthCode, long userId, int expireTime);
    Long consume(String mailAuthCode);
}
