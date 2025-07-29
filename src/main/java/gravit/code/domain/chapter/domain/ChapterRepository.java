package gravit.code.domain.chapter.domain;

public interface ChapterRepository {
    Chapter save(Chapter chapter);
    Long getTotalUnitsByChapterId(Long chapterId);
}
