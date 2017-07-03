-- This function is used by the application tier to toggle
-- (delete if exists, otherwise add) a star for a given user_id
-- and association fkey and id.
-- It returns the status text ('added' or 'removed') and number
-- of stars for the association after the operation.
CREATE OR REPLACE FUNCTION star_toggle(IN user_id integer,
                                       IN assoc_fkey text,
                                       IN assoc_id integer,
                                       OUT status text,
                                       OUT new_stars_count integer)
  AS $$
  DECLARE
    assoc_fkey text := quote_ident(assoc_fkey);
    touched_star stars;
    assoc_name text;
  BEGIN
    EXECUTE format(
      'SELECT * FROM stars WHERE user_id = $1 AND %I = $2', assoc_fkey)
    USING user_id, assoc_id
    INTO touched_star;

    IF touched_star.id IS NOT NULL THEN
      status := 'removed';

      EXECUTE format(
        'DELETE FROM stars WHERE user_id = $1 AND %I = $2', assoc_fkey)
      USING user_id, assoc_id;
    ELSE
      status := 'added';

      EXECUTE format(
        'INSERT INTO stars (user_id, %I) VALUES ($1, $2) RETURNING *', assoc_fkey)
      USING user_id, assoc_id
      INTO touched_star;
    END IF;

    EXECUTE 'SELECT assoc_name FROM assoc_for_star($1)'
    USING touched_star
    INTO assoc_name;

    EXECUTE format(
      'SELECT stars_count FROM %I WHERE id = $1', assoc_name)
    USING assoc_id
    INTO new_stars_count;
  END
  $$ LANGUAGE plpgsql;
