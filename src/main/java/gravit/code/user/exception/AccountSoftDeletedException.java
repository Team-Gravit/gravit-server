package gravit.code.user.exception;

import lombok.Getter;

@Getter
public class AccountSoftDeletedException extends RuntimeException {
    private final String providerId;

    public AccountSoftDeletedException(String providerId) {
        super("Account soft-deleted");
        this.providerId = providerId;
    }
}
