package gravit.code.fcm.dto.response;

import lombok.Builder;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
public record FcmTokenExistsResponse(
        boolean registered
) {
    public static FcmTokenExistsResponse create(boolean registered){
        return FcmTokenExistsResponse.builder()
                .registered(registered)
                .build();
    }
}
