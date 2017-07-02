-- This trigger updates counter caches when a comment is created, deleted,
-- or moved to another association by changing the fkey.
--
-- See `counter_cache_update` and `assoc_for_comment`
-- function definitions for more information.
CREATE TRIGGER comments_update_counter_cache
  AFTER INSERT OR UPDATE OR DELETE ON comments
  FOR EACH ROW EXECUTE PROCEDURE
    counter_cache_update('comments_count', 'assoc_for_comment');
