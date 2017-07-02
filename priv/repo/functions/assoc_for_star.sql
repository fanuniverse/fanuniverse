-- This function is used by the `counter_cache_update` procedure
-- to determine the resource (table name and pkey) that holds the
-- counter cache.
CREATE OR REPLACE FUNCTION assoc_for_star(IN star stars,
                                          OUT assoc_name text,
                                          OUT assoc_id integer)
  AS $$
  BEGIN
    IF star.image_id IS NOT NULL THEN
      assoc_name := 'images';
      assoc_id := star.image_id;
    ELSIF star.comment_id IS NOT NULL THEN
      assoc_name := 'comments';
      assoc_id := star.comment_id;
    END IF;
  END
  $$ LANGUAGE plpgsql;
