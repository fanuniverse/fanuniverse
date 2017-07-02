-- Based on http://shuber.io/porting-activerecord-counter-cache-behavior-to-postgres/

-- This trigger function accepts two arguments:
-- 1) name of a counter cache column belonging to a foreign table,
--    e.g. 'comments_count';
-- 2) name of a function that returns the foreign table name and key (ID),
--    e.g. 'comment_assoc';
CREATE OR REPLACE FUNCTION counter_cache_update()
  RETURNS trigger AS $$
    DECLARE
      counter_name text := quote_ident(TG_ARGV[0]);
      assoc_fun_name text := quote_ident(TG_ARGV[1]);

      old_assoc text;
      old_assoc_id integer;

      new_assoc text;
      new_assoc_id integer;

      assoc_changed boolean;
    BEGIN
      IF TG_OP != 'INSERT' THEN -- OLD record is available
        EXECUTE 'SELECT * FROM ' || assoc_fun_name || '($1)'
        USING OLD
        INTO old_assoc, old_assoc_id;
      END IF;
      IF TG_OP != 'DELETE' THEN -- NEW record is available
        EXECUTE 'SELECT * FROM ' || assoc_fun_name || '($1)'
        USING NEW
        INTO new_assoc, new_assoc_id;
      END IF;

      assoc_changed :=
        (old_assoc IS NOT NULL) AND
        (new_assoc IS NOT NULL) AND
        ((old_assoc != new_assoc) OR (old_assoc_id != new_assoc_id));

      IF TG_OP = 'INSERT' OR assoc_changed THEN
        PERFORM counter_cache_incr(new_assoc, new_assoc_id, counter_name, 1);
      END IF;

      IF TG_OP = 'DELETE' OR assoc_changed THEN
        PERFORM counter_cache_incr(old_assoc, old_assoc_id, counter_name, -1);
      END IF;

      IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        RETURN NEW;
      ELSE
        RETURN OLD;
      END IF;
   END;
  $$ LANGUAGE plpgsql;
