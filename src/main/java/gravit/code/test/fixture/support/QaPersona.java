package gravit.code.test.fixture.support;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum QaPersona {

    PRE_ONBOARDING("pre-onboarding", "온보딩 전. 학습, 미션, 리그 행 없음"),
    FRESH("fresh", "온보딩 직후, 학습 이력 0"),
    LEARNER("learner", "최근 14일 제출 이력(정답, 오답 혼합), 오답노트, 북마크, 주간 기록"),
    STREAK("streak", "연속 학습 6일, 오늘 미학습. 오늘 새 레슨 1개로 7일 달성"),
    CHAPTER_ALMOST("chapter-almost", "챕터 1 레슨을 마지막 1개만 남기고 모두 제출"),
    SOCIAL("social", "맞팔로우, 단방향 팔로워, 친구 피드, 받은 축하와 보낸 축하"),
    LEAGUE_EDGE("league-edge", "실버 2 LP 615. 정확도 28% 이상 신규 레슨 1개로 실버 1 승급, 지난 시즌 리그 이력"),
    MISSION("mission", "오늘 미션(레슨 2개 완료) 진행 1/2, 신규 레슨 1개로 완료"),
    INTERVIEWER("interviewer", "면접 세션 COMPLETED, GRADING_FAILED, GRADING, IN_PROGRESS 각 1건. 완료 세션 약점 2문항"),
    INQUIRER("inquirer", "답변 완료 문의 1건과 답변 알림, 답변 대기 문의 1건"),
    WITHDRAWING("withdrawing", "탈퇴 유예 중. 토큰 발급 불가(404), 복구는 PATCH /api/v1/users/restore?providerId={providerId}"),
    SUSPENDED("suspended", "정지(status = SUSPENDED)"),
    ADMIN("admin", "관리자(role = ADMIN), inquirer 문의 답변자");

    private static final String PROVIDER_ID_PLACEHOLDER = "{providerId}";

    private final String key;
    private final String descriptionTemplate;

    public String providerId(QaFixtureSet set) {
        return set.providerIdPrefix() + key;
    }

    public String description(QaFixtureSet set) {
        return descriptionTemplate.replace(PROVIDER_ID_PLACEHOLDER, providerId(set));
    }
}
