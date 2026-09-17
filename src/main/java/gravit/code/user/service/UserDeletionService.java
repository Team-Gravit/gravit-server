package gravit.code.user.service;

import gravit.code.global.consts.RedirectHostConst;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.config.UserDeleteMailProps;
import gravit.code.user.domain.User;
import gravit.code.user.infrastructure.RedisUserCleanManager;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.service.port.MailAuthCodeStore;
import gravit.code.user.service.port.MailSender;
import gravit.code.user.support.MailAuthCodeGenerator;
import gravit.code.userLeague.dto.event.LeagueRankChangedEvent;
import gravit.code.userLeague.repository.UserLeagueRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.DEST_NOT_VALID;
import static gravit.code.global.exception.domain.CustomErrorCode.INVALID_MAIL_AUTH_CODE;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserDeletionService {

    private static final String MAIL_SUBJECT = "[Gravit!] 회원 탈퇴 확인";
    private static final String DELETE_CONFIRM_PAGE_PATH = "/user/me/delete/page";

    private final UserRepository userRepository;
    private final UserLeagueRepository userLeagueRepository;

    private final MailSender mailSender;
    private final MailAuthCodeStore mailAuthCodeStore;
    private final RedisUserCleanManager cleanManager;

    private final UserDeleteMailProps props;
    private final ApplicationEventPublisher publisher;

    public void requestDeleteMailWithMailAuthCode(
            long userId,
            String dest
    ) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RestApiException(USER_NOT_FOUND));

        String frontendConfirmUrl = makeDeleteLink(dest);

        String mailAuthCode = MailAuthCodeGenerator.createMailAuthCode(props.codeLength());

        mailAuthCodeStore.save(mailAuthCode, userId, props.expireTime());

        String deleteLink = UriComponentsBuilder
                .fromUriString(frontendConfirmUrl)
                .queryParam("mailAuthCode", mailAuthCode)
                .build(true)
                .toUriString();

        mailSender.sendEmailWithDeleteLink(user.getEmail(), props.serviceEmail(), MAIL_SUBJECT, deleteLink);
    }

    private String makeDeleteLink(String dest) {
        String base = RedirectHostConst.DEST_BASE.get(dest);

        if (base == null || base.isBlank()) {
            throw new RestApiException(DEST_NOT_VALID);
        }

        return base + DELETE_CONFIRM_PAGE_PATH;
    }

    @Transactional
    public void confirmDeleteByMailAuthCode(String mailAuthCode) {
        Long userId = mailAuthCodeStore.consume(mailAuthCode);

        if (userId == null) {
            throw new RestApiException(INVALID_MAIL_AUTH_CODE);
        }

        userRepository.findById(userId)
                .ifPresent(user -> {
                    Optional<LeagueRankChangedEvent> rankRemoved = toRankRemovedEvent(user.getId());

                    userRepository.deleteById(user.getId());

                    rankRemoved.ifPresent(publisher::publishEvent);
                });

        cleanManager.storeDeletionUser(userId);
    }

    @Transactional
    public boolean cleanUserDeletion(long userId) {
        if (userRepository.findWithdrawnIdForUpdate(userId).isEmpty()) {
            return false;
        }

        userRepository.cleanUserDeletion(userId);

        return true;
    }

    private Optional<LeagueRankChangedEvent> toRankRemovedEvent(long userId) {
        return userLeagueRepository.findRankKeyByUserId(userId)
                .map(rankKey -> LeagueRankChangedEvent.removed(
                        userId,
                        rankKey.seasonId(),
                        rankKey.leagueId()
                ));
    }
}
