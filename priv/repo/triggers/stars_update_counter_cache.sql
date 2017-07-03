-- This trigger updates counter caches when a star is created, deleted,
-- or moved to another association by changing the fkey.
--
-- See `counter_cache_update` and `assoc_for_star`
-- function definitions for more information.
CREATE TRIGGER stars_update_counter_cache
  AFTER INSERT OR UPDATE OR DELETE ON stars
  FOR EACH ROW EXECUTE PROCEDURE
    counter_cache_update('stars_count', 'assoc_for_star');
