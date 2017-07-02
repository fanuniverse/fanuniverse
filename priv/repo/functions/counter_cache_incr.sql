-- This function is used by `counter_cache_update` to increment/decrement
-- counter cache belonging to a given table.
CREATE OR REPLACE FUNCTION counter_cache_incr(table_name text,
                                              id integer,
                                              counter_name text,
                                              step integer)
  RETURNS VOID AS $$
    DECLARE
      table_name text := quote_ident(table_name);
      counter_name text := quote_ident(counter_name);
      updates text := counter_name || ' = ' || counter_name || ' + ' || step;
    BEGIN
      EXECUTE 'UPDATE ' || table_name || ' SET ' || updates || ' WHERE id = $1'
      USING id;
    END;
  $$ LANGUAGE plpgsql;
