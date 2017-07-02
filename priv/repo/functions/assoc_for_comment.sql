-- This function is used by the `counter_cache_update` procedure
-- to determine the resource (table name and pkey) that holds the
-- counter cache.
CREATE OR REPLACE FUNCTION assoc_for_comment(IN comment comments,
                                             OUT assoc_name text,
                                             OUT assoc_id integer)
  AS $$
  BEGIN
    IF comment.image_id IS NOT NULL THEN
      assoc_name := 'images';
      assoc_id := comment.image_id;
    ELSIF comment.user_profile_id IS NOT NULL THEN
      assoc_name := 'user_profiles';
      assoc_id := comment.user_profile_id;
    END IF;
  END
  $$ LANGUAGE plpgsql;
