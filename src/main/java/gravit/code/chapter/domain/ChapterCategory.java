package gravit.code.chapter.domain;

import gravit.code.global.exception.domain.RestApiException;

import java.util.Arrays;
import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.CHAPTER_TRACK_INVALID;

public enum ChapterCategory {

    CS,
    COMMON,
    SERVER,
    WEB,
    AOS,
    IOS,
    LANGUAGE;

    public boolean isTrack() {
        return this != CS;
    }

    public void validateTrack() {
        if (!isTrack()) {
            throw new RestApiException(CHAPTER_TRACK_INVALID);
        }
    }

    public static List<ChapterCategory> tracks() {
        return Arrays.stream(values())
                .filter(ChapterCategory::isTrack)
                .toList();
    }
}
