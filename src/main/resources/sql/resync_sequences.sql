-- =====================================================
-- IDENTITY 시퀀스 재동기화
-- =====================================================
SELECT setval(pg_get_serial_sequence('chapter','id'),  (SELECT COALESCE(MAX(id),1) FROM chapter));
SELECT setval(pg_get_serial_sequence('unit','id'),     (SELECT COALESCE(MAX(id),1) FROM unit));
SELECT setval(pg_get_serial_sequence('lesson','id'),   (SELECT COALESCE(MAX(id),1) FROM lesson));
SELECT setval(pg_get_serial_sequence('problem','id'),  (SELECT COALESCE(MAX(id),1) FROM problem));
SELECT setval(pg_get_serial_sequence('option','id'),   (SELECT COALESCE(MAX(id),1) FROM "option"));
SELECT setval(pg_get_serial_sequence('answer','id'),   (SELECT COALESCE(MAX(id),1) FROM answer));
SELECT setval(pg_get_serial_sequence('league','id'),   (SELECT COALESCE(MAX(id),1) FROM league));
