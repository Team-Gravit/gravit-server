package gravit.code.badge.domain;

public enum CriteriaType {
    PLANET_COMPLETE,       // 특정 행성 완료
    ALL_PLANETS_COMPLETE,  // 모든 행성 완료
    STREAK_DAYS,           // 연속 학습 N일
    SPEED_QUALIFIED_COUNT ,       // (1회 기준) 제한 시간 이내 + 정답률 조건 충족
    MISSION_COUNT          // 누적 미션 N개
}
