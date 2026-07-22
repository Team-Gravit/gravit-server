package gravit.code.wrongAnsweredNote.fixture;

import gravit.code.global.consts.TimeZoneConst;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredNote;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;

public class WrongAnsweredNoteFixture {

    public static WrongAnsweredNote 기본_오답노트(
            long problemId,
            long userId
    ) {
        WrongAnsweredNote note = WrongAnsweredNote.create(problemId, userId);
        ReflectionTestUtils.setField(note, "id", 1L);
        return note;
    }

    public static WrongAnsweredNote 저장된_오답노트(
            long id,
            long problemId,
            long userId
    ) {
        WrongAnsweredNote note = WrongAnsweredNote.create(problemId, userId);
        ReflectionTestUtils.setField(note, "id", id);
        return note;
    }

    public static WrongAnsweredNote 극복된_오답노트(
            long problemId,
            long userId
    ) {
        WrongAnsweredNote note = 기본_오답노트(problemId, userId);
        ReflectionTestUtils.setField(note, "resolvedAt", LocalDateTime.now(TimeZoneConst.KST));
        return note;
    }

    public static WrongAnsweredNote 누적_오답노트(
            long problemId,
            long userId,
            int wrongCount
    ) {
        WrongAnsweredNote note = 기본_오답노트(problemId, userId);
        ReflectionTestUtils.setField(note, "wrongCount", wrongCount);
        return note;
    }
}
