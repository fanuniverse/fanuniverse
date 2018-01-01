--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_similarity; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_similarity WITH SCHEMA public;


--
-- Name: EXTENSION pg_similarity; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_similarity IS 'support similarity queries';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE comments (
    id bigint NOT NULL,
    body text,
    user_id bigint,
    stars_count integer DEFAULT 0 NOT NULL,
    image_id bigint,
    user_profile_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT belongs_to_integrity CHECK (((((image_id IS NOT NULL))::integer + ((user_profile_id IS NOT NULL))::integer) = 1))
);


--
-- Name: assoc_for_comment(comments); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION assoc_for_comment(comment comments, OUT assoc_name text, OUT assoc_id integer) RETURNS record
    LANGUAGE plpgsql
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
  $$;


--
-- Name: stars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE stars (
    id bigint NOT NULL,
    user_id bigint,
    image_id bigint,
    comment_id bigint,
    CONSTRAINT belongs_to_integrity CHECK (((((image_id IS NOT NULL))::integer + ((comment_id IS NOT NULL))::integer) = 1))
);


--
-- Name: assoc_for_star(stars); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION assoc_for_star(star stars, OUT assoc_name text, OUT assoc_id integer) RETURNS record
    LANGUAGE plpgsql
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
  $$;


--
-- Name: counter_cache_incr(text, integer, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION counter_cache_incr(table_name text, id integer, counter_name text, step integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
    DECLARE
      table_name text := quote_ident(table_name);
      counter_name text := quote_ident(counter_name);
      updates text := counter_name || ' = ' || counter_name || ' + ' || step;
    BEGIN
      EXECUTE 'UPDATE ' || table_name || ' SET ' || updates || ' WHERE id = $1'
      USING id;
    END;
  $_$;


--
-- Name: counter_cache_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION counter_cache_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
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
  $_$;


--
-- Name: star_toggle(integer, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION star_toggle(user_id integer, assoc_fkey text, assoc_id integer, OUT status text, OUT new_stars_count integer) RETURNS record
    LANGUAGE plpgsql
    AS $_$
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
  $_$;


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE images (
    id bigint NOT NULL,
    tags text[],
    source text DEFAULT ''::text NOT NULL,
    suggested_by_id bigint,
    stars_count integer DEFAULT 0 NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    width integer,
    height integer,
    hash text,
    ext text,
    processed boolean DEFAULT false,
    merged_into_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE images_id_seq OWNED BY images.id;


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reports (
    id bigint NOT NULL,
    creator_id bigint,
    resolver_id bigint,
    body text NOT NULL,
    resolved boolean DEFAULT false,
    image_id bigint,
    comment_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT belongs_to_integrity CHECK (((((image_id IS NOT NULL))::integer + ((comment_id IS NOT NULL))::integer) = 1))
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_id_seq OWNED BY reports.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp without time zone
);


--
-- Name: stars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stars_id_seq OWNED BY stars.id;


--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_profiles (
    id bigint NOT NULL,
    bio text DEFAULT ''::text NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    user_id bigint
);


--
-- Name: user_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_profiles_id_seq OWNED BY user_profiles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id bigint NOT NULL,
    name text,
    email text,
    password_hash text,
    role text,
    avatar_file_ext text,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE versions (
    id bigint NOT NULL,
    event text NOT NULL,
    item_type text NOT NULL,
    item_id integer,
    item_changes jsonb NOT NULL,
    originator_id bigint,
    origin text,
    meta jsonb,
    inserted_at timestamp without time zone NOT NULL
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY images ALTER COLUMN id SET DEFAULT nextval('images_id_seq'::regclass);


--
-- Name: reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports ALTER COLUMN id SET DEFAULT nextval('reports_id_seq'::regclass);


--
-- Name: stars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stars ALTER COLUMN id SET DEFAULT nextval('stars_id_seq'::regclass);


--
-- Name: user_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_profiles ALTER COLUMN id SET DEFAULT nextval('user_profiles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: stars stars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stars
    ADD CONSTRAINT stars_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: comments_image_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_image_id_index ON comments USING btree (image_id) WHERE (image_id IS NOT NULL);


--
-- Name: comments_user_profile_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_user_profile_id_index ON comments USING btree (user_profile_id) WHERE (user_profile_id IS NOT NULL);


--
-- Name: images_tags_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX images_tags_index ON images USING gin (tags);


--
-- Name: stars_comment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stars_comment_id_index ON stars USING btree (comment_id) WHERE (comment_id IS NOT NULL);


--
-- Name: stars_image_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stars_image_id_index ON stars USING btree (image_id) WHERE (image_id IS NOT NULL);


--
-- Name: user_profiles_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_profiles_user_id_index ON user_profiles USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON users USING btree (email);


--
-- Name: users_lowercase_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_lowercase_name_index ON users USING btree (lower(name));


--
-- Name: versions_item_id_item_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_item_id_item_type_index ON versions USING btree (item_id, item_type);


--
-- Name: versions_originator_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_originator_id_index ON versions USING btree (originator_id);


--
-- Name: comments comments_update_counter_cache; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER comments_update_counter_cache AFTER INSERT OR DELETE OR UPDATE ON comments FOR EACH ROW EXECUTE PROCEDURE counter_cache_update('comments_count', 'assoc_for_comment');


--
-- Name: stars stars_update_counter_cache; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER stars_update_counter_cache AFTER INSERT OR DELETE OR UPDATE ON stars FOR EACH ROW EXECUTE PROCEDURE counter_cache_update('stars_count', 'assoc_for_star');


--
-- Name: comments comments_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_image_id_fkey FOREIGN KEY (image_id) REFERENCES images(id);


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: comments comments_user_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_user_profile_id_fkey FOREIGN KEY (user_profile_id) REFERENCES user_profiles(id);


--
-- Name: images images_merged_into_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_merged_into_id_fkey FOREIGN KEY (merged_into_id) REFERENCES images(id);


--
-- Name: images images_suggested_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_suggested_by_id_fkey FOREIGN KEY (suggested_by_id) REFERENCES users(id);


--
-- Name: reports reports_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT reports_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES comments(id);


--
-- Name: reports reports_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT reports_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES users(id);


--
-- Name: reports reports_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT reports_image_id_fkey FOREIGN KEY (image_id) REFERENCES images(id);


--
-- Name: reports reports_resolver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT reports_resolver_id_fkey FOREIGN KEY (resolver_id) REFERENCES users(id);


--
-- Name: stars stars_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stars
    ADD CONSTRAINT stars_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES comments(id);


--
-- Name: stars stars_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stars
    ADD CONSTRAINT stars_image_id_fkey FOREIGN KEY (image_id) REFERENCES images(id);


--
-- Name: stars stars_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stars
    ADD CONSTRAINT stars_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: versions versions_originator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_originator_id_fkey FOREIGN KEY (originator_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO "schema_migrations" (version) VALUES (20170414161847), (20170707095249), (20170924053801);

