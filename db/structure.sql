SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: main_or_microplot; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.main_or_microplot AS ENUM (
    'fertilized microplot',
    'main',
    'microplot',
    'nitrogen microplot',
    'rainout',
    'restored prairie',
    'stover microplot',
    'stover non removal microplot',
    'unfertilized microplot',
    'fertilized subplot',
    'unfertilized subplot',
    'stover non-removal subplot'
);


--
-- Name: oban_job_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oban_job_state AS ENUM (
    'available',
    'scheduled',
    'executing',
    'retryable',
    'completed',
    'discarded',
    'cancelled'
);


--
-- Name: planned_or_associated_biodiversity; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.planned_or_associated_biodiversity AS ENUM (
    'planned',
    'associated'
);


--
-- Name: retained; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.retained AS (
	id integer,
	location text,
	datetime timestamp with time zone,
	rain_mm_tot real
);


--
-- Name: tablefunc_crosstab_2; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tablefunc_crosstab_2 AS (
	row_name text,
	category_1 text,
	category_2 text
);


--
-- Name: tablefunc_crosstab_3; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tablefunc_crosstab_3 AS (
	row_name text,
	category_1 text,
	category_2 text,
	category_3 text
);


--
-- Name: tablefunc_crosstab_4; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tablefunc_crosstab_4 AS (
	row_name text,
	category_1 text,
	category_2 text,
	category_3 text,
	category_4 text
);


--
-- Name: _final_median(numeric[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._final_median(numeric[]) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
   SELECT AVG(val)
   FROM (
     SELECT val
     FROM unnest($1) val
     ORDER BY 1
     LIMIT  2 - MOD(array_upper($1, 1), 2)
     OFFSET CEIL(array_upper($1, 1) / 2.0) - 1
   ) sub;
$_$;


--
-- Name: _final_random(anyarray); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._final_random(anyarray) RETURNS anyelement
    LANGUAGE sql IMMUTABLE
    AS $_$
 SELECT $1[array_lower($1,1) + floor((1 + array_upper($1, 1) - array_lower($1, 1))*random())];
$_$;


--
-- Name: add_rain(real, real); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_rain(real, real) RETURNS real
    LANGUAGE sql
    AS $_$
  SELECT $1 + $2;
  $_$;


--
-- Name: add_rain_mm_tot(real, real); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_rain_mm_tot(real, real) RETURNS real
    LANGUAGE sql
    AS $_$
  SELECT $1 + $2;
  $_$;


--
-- Name: array_unique(anyarray); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.array_unique(non_unique_array_vals anyarray) RETURNS TABLE(unique_array anyarray)
    LANGUAGE plpgsql
    AS $$
		BEGIN
			RETURN QUERY SELECT
				ARRAY_AGG(unique_vals.val)
			FROM
				(
					SELECT
						UNNEST(non_unique_array_vals) AS val
					GROUP BY
						val
				) AS unique_vals
			;
		END;
	$$;


--
-- Name: comma_aggregate(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.comma_aggregate(character varying, character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
begin
  if length($1)>0 and length($2)>0 then
      return $1 || ', ' || $2;
  elsif length($2)>0 then
    return $2;
  end if;
  return $1;
end;
$_$;


--
-- Name: commacat(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.commacat(acc text, instr text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF acc IS NULL OR acc = '' THEN
      RETURN instr;
    ELSE
      RETURN acc || ', ' || instr;
    END IF;
  END;
$$;


--
-- Name: connectby(text, text, text, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.connectby(text, text, text, text, integer) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'connectby_text';


--
-- Name: connectby(text, text, text, text, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.connectby(text, text, text, text, integer, text) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'connectby_text';


--
-- Name: connectby(text, text, text, text, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.connectby(text, text, text, text, text, integer) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'connectby_text_serial';


--
-- Name: connectby(text, text, text, text, text, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.connectby(text, text, text, text, text, integer, text) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'connectby_text_serial';


--
-- Name: convert_qubic_soil_moisture_to_quadratic(double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.convert_qubic_soil_moisture_to_quadratic(m double precision) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
declare
period double precision;
begin
period = 3 + 0.10734527345104317/
    (3.131541e-6 + 0.000013229999999999999* 6.345 + 0.000013229999999999999*
       Sqrt(-0.1250916053673519 + m)*Sqrt(0.5984916053673519 + m))^
     (1.0/3.0) + 377.9526314209999*
    (3.131541e-6 + 0.000013229999999999999*m + 0.000013229999999999999*
       Sqrt(-0.1250916053673519 + m)*Sqrt(0.5984916053673519 + m))^(1.0/3.0);
       return round((-0.0663 - 0.0063 * period + 0.0007 * period^2)::numeric,3);
       end
       $$;


--
-- Name: crc32(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crc32(word text) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
          DECLARE tmp bigint;
          DECLARE i int;
          DECLARE j int;
          DECLARE byte_length int;
          DECLARE word_array bytea;
          BEGIN
            IF COALESCE(word, '') = '' THEN
              return 0;
            END IF;

            i = 0;
            tmp = 4294967295;
            byte_length = bit_length(word) / 8;
            word_array = decode(replace(word, E'\\', E'\\\\'), 'escape');
            LOOP
              tmp = (tmp # get_byte(word_array, i))::bigint;
              i = i + 1;
              j = 0;
              LOOP
                tmp = ((tmp >> 1) # (3988292384 * (tmp & 1)))::bigint;
                j = j + 1;
                IF j >= 8 THEN
                  EXIT;
                END IF;
              END LOOP;
              IF i >= byte_length THEN
                EXIT;
              END IF;
            END LOOP;
            return (tmp # 4294967295);
          END
        $$;


--
-- Name: crosstab(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crosstab(text) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab';


--
-- Name: crosstab(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crosstab(text, integer) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab';


--
-- Name: crosstab(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crosstab(text, text) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab_hash';


--
-- Name: crosstab2(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crosstab2(text) RETURNS SETOF public.tablefunc_crosstab_2
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab';


--
-- Name: crosstab3(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crosstab3(text) RETURNS SETOF public.tablefunc_crosstab_3
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab';


--
-- Name: crosstab4(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crosstab4(text) RETURNS SETOF public.tablefunc_crosstab_4
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab';


--
-- Name: date_ceiling(timestamp without time zone, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.date_ceiling(input_ts timestamp without time zone, interval_str text) RETURNS timestamp without time zone
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    interval_val interval;
BEGIN
    RETURN CASE
        WHEN date_trunc(interval_str, input_ts) = input_ts THEN
            input_ts
        ELSE
            date_trunc(interval_str, input_ts) +
            CASE interval_str
                WHEN 'minute' THEN interval '1 minute'
                WHEN 'hour' THEN interval '1 hour'
                WHEN 'day' THEN interval '1 day'
                WHEN 'week' THEN interval '1 week'
                WHEN 'month' THEN interval '1 month'
                WHEN 'quarter' THEN interval '3 months'
                WHEN 'year' THEN interval '1 year'
                ELSE interval '1 day' -- default case
            END
    END;
END;
$$;


--
-- Name: datediff_seconds(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.datediff_seconds(start_t timestamp without time zone, end_t timestamp without time zone) RETURNS double precision
    LANGUAGE sql
    AS $_$
    SELECT EXTRACT(epoch FROM $2 - $1)
$_$;


--
-- Name: datediff_seconds(timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.datediff_seconds(start_t timestamp with time zone, end_t timestamp with time zone) RETURNS double precision
    LANGUAGE sql
    AS $_$
    SELECT EXTRACT(epoch FROM $2 - $1)
$_$;


--
-- Name: find_fk_references(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_fk_references(p_target_table text, p_target_column text, p_target_value text) RETURNS TABLE(referencing_table text, referencing_column text, row_data jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    ref_rec RECORD;
    query TEXT;
BEGIN
    FOR ref_rec IN
        SELECT DISTINCT
            conrelid::regclass::text AS ref_table,
            a.attname AS ref_column
        FROM pg_constraint c
            JOIN LATERAL unnest(c.conkey) WITH ORDINALITY AS u(attnum, pos) ON TRUE
            JOIN LATERAL unnest(c.confkey) WITH ORDINALITY AS uf(attnum, pos) ON u.pos = uf.pos
            JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = u.attnum
            JOIN pg_attribute af ON af.attrelid = c.confrelid AND af.attnum = uf.attnum
        WHERE c.contype = 'f'
          AND c.confrelid = p_target_table::regclass
          AND af.attname = p_target_column
    LOOP
        query := format(
            'SELECT %L, %L, to_jsonb(t.*) FROM %s t WHERE %I = %L',
            ref_rec.ref_table,
            ref_rec.ref_column,
            ref_rec.ref_table,
            ref_rec.ref_column,
            p_target_value
        );

        RETURN QUERY EXECUTE query;
    END LOOP;
END;
$$;


--
-- Name: first_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.first_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT $1;
$_$;


--
-- Name: foo(text, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.foo(site text, date timestamp without time zone) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
  case when  site = 'bar'
    then
      return site;
  else
    return NULL;
  end case;
end
$$;


--
-- Name: gen_barcode(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gen_barcode(len integer DEFAULT 21) RETURNS text
    LANGUAGE plpgsql PARALLEL SAFE
    AS $$DECLARE
	bcode text;
BEGIN
bcode = nanoid(len);

INSERT INTO public.barcode (id) VALUES(bcode);
RETURN bcode;
END$$;


--
-- Name: FUNCTION gen_barcode(len integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.gen_barcode(len integer) IS 'generate a kbs nanoid barcode';


--
-- Name: gen_barcode(integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gen_barcode(len integer DEFAULT 21, my_table text DEFAULT 'unknown'::text) RETURNS text
    LANGUAGE plpgsql PARALLEL SAFE
    AS $$DECLARE
bcode text;
BEGIN
bcode = nanoid(len);

INSERT INTO public.barcode (id, table_destiny) VALUES(bcode, my_table);
RETURN bcode;
END$$;


--
-- Name: FUNCTION gen_barcode(len integer, my_table text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.gen_barcode(len integer, my_table text) IS 'generate kbs nanoid barcode and add it to the barcode table with an indication of where the barcode is used.';


--
-- Name: gen_barcode_old(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gen_barcode_old() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE bcode text;
BEGIN

set statement_timeout to '10s'; -- to avoid endless loop
LOOP
bcode = nanoid(21);
BEGIN

INSERT INTO public.barcode (id)
VALUES(bcode);
EXIT;

EXCEPTION
WHEN sqlstate '23505' then

END;
END LOOP;
RETURN bcode;
END
$$;


--
-- Name: get_plots_2(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_plots_2(p_pattern character varying) RETURNS TABLE(main_or_microplot character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
   var_r record;
BEGIN
   for var_r in(
            select schema_table
            from test.main_or_microplot_tables
	     where schema_table ilike p_pattern

        )
   LOOP
      RETURN QUERY EXECUTE
      format (--'SELECT count(*) AS count FROM %I.company_summary'
		  'SELECT main_or_microplot FROM %I.var_r'
             );
   END LOOP;
END
$$;


--
-- Name: getrain2(text, timestamp with time zone, real); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.getrain2(location text, datetime timestamp with time zone, rain real) RETURNS real
    LANGUAGE plpgsql
    AS $$
BEGIN
           CASE
           WHEN location = 'Lux Arbor' AND extract(doy from datetime) BETWEEN 75 AND 315
                OR location = 'Escanaba' AND extract(doy from datetime) BETWEEN 75 AND 315
                OR location = 'Rhinelander'  AND extract(doy from datetime) BETWEEN 75 AND 315
                OR location = 'Hancock' AND extract(doy from datetime) BETWEEN 75 AND 315
                OR location = 'Sauk Prairie' AND extract(doy from datetime) BETWEEN 75 AND 315
                OR location = 'Oregon' AND extract(doy from datetime) BETWEEN 75 AND 315
                OR location = 'Lake City' AND extract(doy from datetime) BETWEEN 75 AND 315
             THEN RETURN rain;
           ELSE RETURN NULL;
           END CASE;
END;
$$;


--
-- Name: hex(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.hex(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  select encode($1::bytea, 'hex')
$_$;


--
-- Name: isnan(double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.isnan(double precision) RETURNS boolean
    LANGUAGE sql
    AS $_$
select $1 > 0 and -$1 > 0 $_$;


--
-- Name: linear_interpolate(double precision, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.linear_interpolate(x_i double precision, x_0 double precision, y_0 double precision, x_1 double precision, y_1 double precision) RETURNS double precision
    LANGUAGE sql
    AS $_$
    SELECT (($5 - $3) / ($4 - $2)) * ($1 - $2) + $3;
$_$;


--
-- Name: linear_interpolate(timestamp with time zone, timestamp with time zone, double precision, timestamp with time zone, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.linear_interpolate(x_i timestamp with time zone, x_0 timestamp with time zone, y_0 double precision, x_1 timestamp with time zone, y_1 double precision) RETURNS double precision
    LANGUAGE sql
    AS $_$
    SELECT linear_interpolate(timestamp_to_seconds($1),
        timestamp_to_seconds($2),
        $3,
        timestamp_to_seconds($4),
        $5);
$_$;


--
-- Name: linear_interpolate(timestamp with time zone, timestamp with time zone, numeric, timestamp with time zone, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.linear_interpolate(x_i timestamp with time zone, x_0 timestamp with time zone, y_0 numeric, x_1 timestamp with time zone, y_1 numeric) RETURNS double precision
    LANGUAGE sql
    AS $_$
    SELECT linear_interpolate(timestamp_to_seconds($1),
        timestamp_to_seconds($2),
        $3,
        timestamp_to_seconds($4),
        $5);
$_$;


--
-- Name: nanoid(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.nanoid(size integer DEFAULT 21) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  id text := '';
  i int := 0;
  urlAlphabet char(64) := '0123456789-ABCDEFGHIJKLMNOPQRSTUVWXYZ~!?.';
  bytes bytea := gen_random_bytes(size);
  byte int;
  pos int;
BEGIN
  WHILE i < size LOOP
    byte := get_byte(bytes, i);
    pos := (byte & 63) + 1; -- + 1 because substr starts at 1 for some reason
    id := id || substr(urlAlphabet, pos, 1);
    i = i + 1;
  END LOOP;
  RETURN 'KBS'||id;
END
$$;


--
-- Name: normal_rand(integer, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.normal_rand(integer, double precision, double precision) RETURNS SETOF double precision
    LANGUAGE c STRICT
    AS '$libdir/tablefunc', 'normal_rand';


--
-- Name: pg_schema_size(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pg_schema_size(text) RETURNS bigint
    LANGUAGE sql
    AS $_$
select sum(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::bigint from pg_tables where schemaname = $1
$_$;


--
-- Name: rain_mm_tot(text, timestamp with time zone, real); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rain_mm_tot(location text, datetime timestamp with time zone, rain real) RETURNS real
    LANGUAGE plpgsql
    AS $$
BEGIN
           CASE
           WHEN location = 'Lux Arbor' AND extract(doy from datetime) BETWEEN 75 AND 315 OR
                location = 'Escanaba' AND extract(doy from datetime) BETWEEN 75 AND 315 OR
                location = 'Rhinelander' AND extract(doy from datetime) BETWEEN 75 AND 315 OR
                location = 'Hancock' AND extract(doy from datetime) BETWEEN 75 AND 315 OR
                location = 'Sauk Prairie' AND extract(doy from datetime) BETWEEN 75 AND 315 OR
                location = 'Oregon' AND extract(doy from datetime) BETWEEN 75 AND 315 OR
                location = 'Lake City' AND extract(doy from datetime) BETWEEN 75 AND 315
             THEN RETURN rain;
           ELSE RETURN NULL;
           END CASE;
END;
$$;


--
-- Name: roundsf(numeric, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.roundsf(value numeric, sf integer) RETURNS numeric
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
declare result numeric;
begin
if (value = 0) then
  result = 0;
else
  result = round(value, sf - 1 - floor(log10(abs(value)))::integer);
 end if;
 return result;
end;
$$;


--
-- Name: roundtosignificantfigures(double precision, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.roundtosignificantfigures(num double precision, n integer) RETURNS double precision
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
result float;
d integer;
pow float;
wnum float;
magnitude float;
shifted float;
begin
 result := 0;
 wnum := num;
 if wnum < 0 then
   wnum := -num;
 end if;
 if wnum <> 0 then
    d := ceil(log(wnum));
    pow := n - d;
    magnitude := power(10, pow);
    shifted := round(wnum*magnitude);
    result := shifted/magnitude;
  end if;

  return result;
end; $$;


--
-- Name: sig_digits(anyelement, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sig_digits(n anyelement, digits integer) RETURNS numeric
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
    SELECT round(n, digits - 1 - floor(log(n))::int)
$$;


--
-- Name: sizedb(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sizedb() RETURNS text
    LANGUAGE sql
    AS $$
SELECT pg_size_pretty(pg_database_size(current_database()));
$$;


--
-- Name: timestamp_to_seconds(timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.timestamp_to_seconds(timestamp_t timestamp with time zone) RETURNS double precision
    LANGUAGE sql
    AS $$
    SELECT EXTRACT(epoch from timestamp_t)
$$;


--
-- Name: comma(character varying); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.comma(character varying) (
    SFUNC = public.comma_aggregate,
    STYPE = character varying,
    INITCOND = ''
);


--
-- Name: first(anyelement); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.first(anyelement) (
    SFUNC = public.first_agg,
    STYPE = anyelement
);


--
-- Name: median(numeric); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.median(numeric) (
    SFUNC = array_append,
    STYPE = numeric[],
    INITCOND = '{}',
    FINALFUNC = public._final_median
);


--
-- Name: textcat_all(text); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.textcat_all(text) (
    SFUNC = public.commacat,
    STYPE = text,
    INITCOND = ''
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: areas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.areas (
    gid integer NOT NULL,
    site character varying,
    feature character varying,
    replicate character varying,
    extra_name character varying,
    start_date date,
    end_date date,
    treatment character varying,
    experiment character varying,
    sponsor smallint,
    the_geom public.geometry,
    gps_date date,
    gps_corr character varying,
    gps_type character varying,
    height real,
    vert_precision real,
    horiz_precision real,
    comment text,
    station character varying,
    easting double precision,
    northing double precision,
    people text,
    longitude real,
    latitude real,
    disturbance_type text,
    material text,
    year bigint,
    "2016" boolean,
    "2017" boolean,
    kbs_id integer,
    label text,
    tillage_st smallint,
    topography smallint,
    name text,
    crop text,
    to_label character varying(20),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'MULTIPOLYGON'::text) OR (public.geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid CHECK ((public.st_srid(the_geom) > 1999))
);


--
-- Name: treatments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.treatments (
    id integer NOT NULL,
    name character varying(255),
    description text,
    study_id integer,
    weight integer,
    deprecated_names text,
    management text,
    dominant_plants text,
    start_date date,
    end_date date,
    use_in_citations boolean DEFAULT true,
    project_id bigint,
    parent_id integer,
    rgt integer NOT NULL,
    lft integer NOT NULL
);


--
-- Name: studies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.studies (
    id integer NOT NULL,
    name character varying(255),
    description text,
    weight integer,
    parent_id integer,
    lft integer,
    rgt integer,
    synopsis text,
    url character varying(255),
    code character varying(255),
    warning text,
    source text,
    old_names text,
    updated_at timestamp without time zone DEFAULT now(),
    created_at timestamp without time zone DEFAULT now(),
    short_name character varying(255)
);


--
-- Name: analysis_labs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analysis_labs (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    name text NOT NULL
);


--
-- Name: 2_ed_lux_arbor_microplots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."2_ed_lux_arbor_microplots" (
    id integer NOT NULL,
    geom public.geometry(PointZ,4326),
    x numeric,
    y numeric,
    z bigint,
    rowid bigint,
    treatment bigint,
    replicate bigint,
    feature_fu character varying(254),
    longitude numeric,
    latitude numeric,
    fertilizer character varying(254),
    name character varying(254),
    vertex bigint,
    rcvr_type character varying(254)
);


--
-- Name: 2_ed_lux_arbor_microplots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."2_ed_lux_arbor_microplots_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: 2_ed_lux_arbor_microplots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."2_ed_lux_arbor_microplots_id_seq" OWNED BY public."2_ed_lux_arbor_microplots".id;


--
-- Name: LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a_v2025; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a_v2025" (
    id integer CONSTRAINT "LTAR_Standard_GIS_Layers_v2025 — ltar_experiment__id_not_null" NOT NULL,
    geom public.geometry(MultiPolygonZM,3857),
    objectid bigint,
    site_id character varying(50),
    site_name character varying(50),
    status character varying(50),
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    exp_unit_id character varying(80),
    treatment_id character varying(80),
    flag character varying(20),
    shape_length double precision,
    shape_area double precision,
    ltar_feature_id character varying(255)
);


--
-- Name: LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy__id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy__id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy__id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy__id_seq" OWNED BY public."LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a_v2025".id;


--
-- Name: Source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Source" (
    "F1" double precision,
    "F2" double precision
);


--
-- Name: TABLE "Source"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."Source" IS 'i don''t remember what this is for. Need to investigate.';


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    service_name character varying NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: affiliations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.affiliations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: affiliations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.affiliations (
    id integer DEFAULT nextval('public.affiliations_id_seq'::regclass) NOT NULL,
    person_id integer NOT NULL,
    role_id integer NOT NULL,
    dataset_id integer,
    seniority integer,
    title character varying(255),
    supervisor character varying(255),
    started_on date,
    left_on date,
    research_interest character varying(255),
    lno_record_id character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: aglog_missing_glbrc_planting_observations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.aglog_missing_glbrc_planting_observations AS
 SELECT observations.id,
    observations.obs_date,
    companies.name AS site,
    treatments.name AS treatment,
    observations.comment
   FROM aglog.companies,
    (((((aglog.observations
     JOIN aglog.areas_observations ON ((observations.id = areas_observations.observation_id)))
     JOIN aglog.areas ON ((areas.id = areas_observations.area_id)))
     JOIN aglog.observation_types_observations ON ((observation_types_observations.observation_id = observations.id)))
     JOIN aglog.observation_types ON ((observation_types.id = observation_types_observations.observation_type_id)))
     LEFT JOIN aglog.treatments ON ((areas.treatment_id = treatments.id)))
  WHERE ((areas.replicate = 1) AND ((observation_types.name)::text = 'Planting'::text) AND (areas.study_id = 6) AND (companies.id = observations.company_id) AND (NOT (observations.id IN ( SELECT observations_1.id
           FROM aglog.companies companies_1,
            ((((((((((((aglog.observations observations_1
             JOIN aglog.areas_observations areas_observations_1 ON ((observations_1.id = areas_observations_1.observation_id)))
             JOIN aglog.areas areas_1 ON ((areas_1.id = areas_observations_1.area_id)))
             JOIN aglog.observation_types_observations observation_types_observations_1 ON ((observation_types_observations_1.observation_id = observations_1.id)))
             JOIN aglog.observation_types observation_types_1 ON ((observation_types_1.id = observation_types_observations_1.observation_type_id)))
             LEFT JOIN aglog.activities ON ((activities.observation_id = observations_1.id)))
             LEFT JOIN aglog.setups ON ((setups.activity_id = activities.id)))
             LEFT JOIN aglog.material_transactions ON ((material_transactions.setup_id = setups.id)))
             LEFT JOIN aglog.materials ON ((materials.id = material_transactions.material_id)))
             LEFT JOIN aglog.material_types ON ((material_types.id = materials.material_type_id)))
             LEFT JOIN aglog.units ON ((material_transactions.unit_id = units.id)))
             LEFT JOIN aglog.treatments treatments_1 ON ((areas_1.treatment_id = treatments_1.id)))
             LEFT JOIN aglog.equipment ON ((equipment.id = setups.equipment_id)))
          WHERE ((areas_1.replicate = 1) AND ((materials.* IS NULL) OR (material_types.id = 4)) AND ((observation_types_1.name)::text = 'Planting'::text) AND ((equipment.id IS NULL) OR (equipment.use_material IS TRUE)) AND (areas_1.study_id = 6) AND (companies_1.id = observations_1.company_id))))))
  ORDER BY observations.id, companies.name, treatments.name, observations.obs_date DESC;


--
-- Name: all_plots_and_station_years; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.all_plots_and_station_years AS
 SELECT stations.treatment,
    stations.replicate,
    stations.station,
    t1.year
   FROM kbs019.stations,
    ( SELECT generate_series.generate_series AS year
           FROM generate_series(1989, 2010) generate_series(generate_series)) t1;


--
-- Name: analysis_labs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.analysis_labs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_labs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.analysis_labs_id_seq OWNED BY public.analysis_labs.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: areas_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.areas_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: areas_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.areas_gid_seq OWNED BY public.areas.gid;


--
-- Name: areas_temporary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.areas_temporary (
    gid integer NOT NULL,
    site character varying,
    feature character varying,
    replicate character varying,
    extra_name character varying,
    start_date date,
    end_date date,
    treatment character varying,
    experiment character varying,
    sponsor smallint,
    the_geom public.geometry,
    gps_date date,
    gps_corr character varying,
    gps_type character varying,
    height real,
    vert_precision real,
    horiz_precision real,
    comment text,
    station character varying,
    easting double precision,
    northing double precision,
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'MULTIPOLYGON'::text) OR (public.geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL)))
);


--
-- Name: areas_temporary_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.areas_temporary_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: areas_temporary_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.areas_temporary_gid_seq OWNED BY public.areas_temporary.gid;


--
-- Name: authors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authors (
    id integer NOT NULL,
    sur_name character varying(255),
    given_name character varying(255),
    middle_name character varying(255),
    seniority integer,
    person_id integer,
    citation_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    suffix character varying(255),
    orchid integer
);


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authors_id_seq OWNED BY public.authors.id;


--
-- Name: barcode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.barcode (
    id character(24) DEFAULT public.nanoid(13) NOT NULL,
    table_destiny text
);


--
-- Name: chambers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chambers (
    id integer NOT NULL,
    inserted_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    barcode character(21) NOT NULL
);


--
-- Name: TABLE chambers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.chambers IS 'This can probably be deleted. I think it was a leftover from mdard which moved to it''s own db.';


--
-- Name: citation_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.citation_types (
    id integer NOT NULL,
    abbreviation character varying(255),
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: citation_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.citation_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: citation_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.citation_types_id_seq OWNED BY public.citation_types.id;


--
-- Name: citations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.citations (
    id integer NOT NULL,
    title text,
    abstract text,
    pub_date date,
    pub_year integer,
    citation_type_id integer,
    address text,
    notes text,
    publication character varying(255),
    start_page_number character varying(255),
    ending_page_number character varying(255),
    periodical_full_name text,
    periodical_abbreviation character varying(255),
    volume character varying(255),
    issue character varying(255),
    city character varying(255),
    publisher character varying(255),
    secondary_title character varying(255),
    series_title character varying(255),
    isbn character varying(255),
    doi character varying(255),
    full_text text,
    publisher_url character varying(255),
    website_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pdf_file_name character varying(255),
    pdf_content_type character varying(255),
    pdf_file_size integer,
    pdf_updated_at timestamp without time zone,
    state character varying(255),
    open_access boolean DEFAULT false,
    type character varying(255),
    has_lter_acknowledgement boolean,
    annotation character varying(255),
    data_url character varying,
    from_reporting_system_on timestamp with time zone,
    is_referenced_by_count integer DEFAULT 0,
    abstract_backup text,
    inserted_at timestamp without time zone
);


--
-- Name: citations_datatables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.citations_datatables (
    citation_id integer,
    datatable_id integer
);


--
-- Name: citations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.citations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: citations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.citations_id_seq OWNED BY public.citations.id;


--
-- Name: citations_treatments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.citations_treatments (
    citation_id integer,
    treatment_id integer
);


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    datatable_id integer
);


--
-- Name: collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collections_id_seq OWNED BY public.collections.id;


--
-- Name: columns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.columns (
    id integer NOT NULL,
    datatable_id integer,
    variate_id integer,
    "position" integer,
    name character varying(255)
);


--
-- Name: columns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: columns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.columns_id_seq OWNED BY public.columns.id;


--
-- Name: core_areas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_areas (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: core_areas_datatables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_areas_datatables (
    id integer NOT NULL,
    core_area_id integer,
    datatable_id integer
);


--
-- Name: core_areas_datatables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.core_areas_datatables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: core_areas_datatables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.core_areas_datatables_id_seq OWNED BY public.core_areas_datatables.id;


--
-- Name: core_areas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.core_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: core_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.core_areas_id_seq OWNED BY public.core_areas.id;


--
-- Name: daily_cumulative_precip_mle; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.daily_cumulative_precip_mle AS
 SELECT location,
    datetime,
    (date_trunc('day'::text, datetime))::date AS date,
    rain_mm_tot,
    sum(rain_mm_tot) OVER (PARTITION BY location, ((date_trunc('day'::text, datetime))::date) ORDER BY location) AS sum
   FROM weather.marginal_land_hour;


--
-- Name: data_contributions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_contributions (
    id integer NOT NULL,
    person_id integer,
    datatable_id integer,
    role_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    seniority integer
);


--
-- Name: data_contributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.data_contributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_contributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_contributions_id_seq OWNED BY public.data_contributions.id;


--
-- Name: data_usages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_usages (
    id bigint NOT NULL,
    dataset_id integer,
    citation_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: data_usages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.data_usages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_usages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_usages_id_seq OWNED BY public.data_usages.id;


--
-- Name: data_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_versions (
    id integer NOT NULL,
    dataset_id integer,
    doi character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: data_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.data_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_versions_id_seq OWNED BY public.data_versions.id;


--
-- Name: datafiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datafiles (
    id integer NOT NULL,
    title text,
    description text,
    original_data_file_name character varying(255),
    original_data_content_type character varying(255),
    original_data_file_size integer,
    person_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: datafiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.datafiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datafiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.datafiles_id_seq OWNED BY public.datafiles.id;


--
-- Name: dataset_dois; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dataset_dois (
    id integer NOT NULL,
    dataset_id integer NOT NULL,
    doi character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    version integer NOT NULL,
    nsf_par_id bigint
);


--
-- Name: dataset_dois_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dataset_dois_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dataset_dois_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dataset_dois_id_seq OWNED BY public.dataset_dois.id;


--
-- Name: dataset_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dataset_files (
    id integer NOT NULL,
    name text,
    dataset_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying(255),
    data_content_type character varying(255),
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: dataset_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dataset_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dataset_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dataset_files_id_seq OWNED BY public.dataset_files.id;


--
-- Name: datasets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.datasets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datasets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datasets (
    id integer DEFAULT nextval('public.datasets_id_seq'::regclass) NOT NULL,
    dataset character varying(255),
    title character varying(255),
    abstract text NOT NULL,
    old_keywords character varying(255),
    status character varying(255),
    initiated date,
    completed date,
    released date,
    on_web boolean DEFAULT true,
    version integer DEFAULT 1,
    core_dataset boolean DEFAULT false,
    project_id integer,
    metacat_id integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    sponsor_id integer DEFAULT 1,
    website_id integer DEFAULT 1,
    pasta_ready boolean DEFAULT false,
    data_end_date date,
    cc0 boolean DEFAULT false NOT NULL,
    west_bounding_coordinate double precision,
    east_bounding_coordinate double precision,
    north_bounding_coordinate double precision,
    south_bounding_coordinate double precision,
    doi text,
    abstract_backup text,
    licence character varying(25)
);


--
-- Name: datasets_studies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datasets_studies (
    dataset_id integer,
    study_id integer
);


--
-- Name: datasets_themes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datasets_themes (
    theme_id integer,
    dataset_id integer
);


--
-- Name: datatables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.datatables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datatables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datatables (
    id integer DEFAULT nextval('public.datatables_id_seq'::regclass) NOT NULL,
    name character varying(255) NOT NULL,
    title character varying(255),
    comments text,
    dataset_id integer NOT NULL,
    data_url character varying(255),
    is_restricted boolean,
    description text,
    object text,
    metadata_url character varying(255),
    is_sql boolean,
    update_frequency_days integer,
    last_updated_on date,
    access_statement text,
    excerpt_limit integer,
    begin_date date,
    end_date date,
    on_web boolean DEFAULT true,
    theme_id integer,
    core_area_id integer,
    weight integer DEFAULT 100,
    study_id integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    is_secondary boolean DEFAULT false,
    is_utf_8 boolean DEFAULT false,
    metadata_only boolean DEFAULT false,
    summary_graph text,
    deprecated_in_favor_of integer,
    deprecation_notice text,
    number_of_released_records integer,
    scores text,
    completed_on date,
    workflow_state text,
    csv_cache_file_name character varying(255),
    csv_cache_content_type character varying(255),
    csv_cache_file_size integer,
    csv_cache_updated_at timestamp without time zone,
    update_cache_days integer,
    sponsor_id integer,
    connection_url text,
    description_backup text
);


--
-- Name: datatables_dois; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datatables_dois (
    id integer NOT NULL,
    datatable_id integer NOT NULL,
    doi text NOT NULL,
    inserted_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    paper_doi text,
    data_begin_year integer,
    data_end_year integer,
    treatments text
);


--
-- Name: datatables_dois_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.datatables_dois_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datatables_dois_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.datatables_dois_id_seq OWNED BY public.datatables_dois.id;


--
-- Name: datatables_protocols; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datatables_protocols (
    datatable_id integer NOT NULL,
    protocol_id integer NOT NULL
);


--
-- Name: datatables_variates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datatables_variates (
    id integer NOT NULL
);


--
-- Name: datatables_variates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.datatables_variates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datatables_variates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.datatables_variates_id_seq OWNED BY public.datatables_variates.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error character varying(255),
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: devise_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.devise_invitations (
    id bigint NOT NULL,
    invitation_token character varying,
    invitation_created_at timestamp(6) without time zone,
    invitation_sent_at timestamp(6) without time zone,
    invitation_accepted_at timestamp(6) without time zone,
    superseded_at timestamp(6) without time zone,
    superseded_reason character varying,
    revoked_at timestamp(6) without time zone,
    resource_created_at timestamp(6) without time zone,
    invite_key json DEFAULT '{}'::json NOT NULL,
    invite_key_digest character varying NOT NULL,
    invitable_type character varying,
    invitable_id bigint,
    invited_by_type character varying,
    invited_by_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: devise_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.devise_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devise_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.devise_invitations_id_seq OWNED BY public.devise_invitations.id;


--
-- Name: editors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.editors (
    id integer NOT NULL,
    sur_name character varying(255),
    given_name character varying(255),
    middle_name character varying(255),
    seniority integer,
    person_id integer,
    citation_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    suffix character varying(255)
);


--
-- Name: editors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.editors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: editors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.editors_id_seq OWNED BY public.editors.id;


--
-- Name: emeritus_investigator_and_students_email_list; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.emeritus_investigator_and_students_email_list AS
SELECT
    NULL::integer AS id,
    NULL::character varying(255) AS email,
    NULL::character varying(255) AS given_name,
    NULL::character varying(255) AS sur_name,
    NULL::character varying[] AS roles,
    NULL::character varying(255) AS organization,
    NULL::character varying(255) AS sub_organization,
    NULL::character varying(255) AS street_address,
    NULL::character varying(255) AS city,
    NULL::character varying(255) AS locale,
    NULL::character varying(255) AS country,
    NULL::character varying(255) AS postal_code,
    NULL::character varying(255) AS phone,
    NULL::character varying(255) AS fax;


--
-- Name: eml_docs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.eml_docs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eml_docs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eml_docs (
    id integer DEFAULT nextval('public.eml_docs_id_seq'::regclass) NOT NULL
);


--
-- Name: enumerated_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enumerated_values (
    id bigint NOT NULL,
    variate_id bigint NOT NULL,
    code character varying,
    description character varying NOT NULL,
    created_at timestamp(6) without time zone DEFAULT now() NOT NULL,
    updated_at timestamp(6) without time zone DEFAULT now() NOT NULL
);


--
-- Name: enumerated_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enumerated_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enumerated_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enumerated_values_id_seq OWNED BY public.enumerated_values.id;


--
-- Name: farm_fields0; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.farm_fields0 (
    fid integer NOT NULL,
    no_turner character varying,
    perimeter numeric,
    treatment character varying,
    crop2006 character varying,
    replicate character varying,
    comment character varying,
    fieldname character varying,
    field_id character varying,
    lter_field character varying,
    organic_06 character varying,
    organicsta character varying,
    size character varying,
    size_class character varying,
    acres double precision,
    hectares double precision,
    oct07 character varying,
    april2008 character varying,
    the_geom public.geometry(MultiPolygon,4326),
    id2023 character varying(40)
);


--
-- Name: farm_fields0_fid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.farm_fields0_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: farm_fields0_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.farm_fields0_fid_seq OWNED BY public.farm_fields0.fid;


--
-- Name: fertilization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fertilization (
    id integer NOT NULL,
    site_id integer,
    dataset_id integer,
    fertilization_date date,
    fertilization_id integer,
    treatment character varying,
    replicate character varying,
    fertilization_date_description character varying
);


--
-- Name: fertilization_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fertilization_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fertilization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fertilization_id_seq OWNED BY public.fertilization.id;


--
-- Name: gas_chambers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gas_chambers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gas_chambers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gas_chambers_id_seq OWNED BY public.chambers.id;


--
-- Name: gas_chambers_temp; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.gas_chambers_temp AS
 SELECT gid,
    site,
    feature,
    replicate,
    extra_name,
    start_date,
    end_date,
    treatment,
    experiment,
    sponsor,
    the_geom,
    gps_date,
    gps_corr,
    gps_type,
    height,
    vert_precision,
    horiz_precision,
    comment,
    station,
    easting,
    northing,
    people,
    longitude,
    latitude
   FROM public.areas
  WHERE (((feature)::text = 'gas flux chamber - static'::text) AND (date_part('year'::text, start_date) = (2019)::double precision));


--
-- Name: invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invites (
    id integer NOT NULL,
    firstname character varying(255),
    lastname character varying(255),
    email character varying(255),
    invite_code character varying(40),
    invited_at timestamp without time zone,
    redeemed_at timestamp without time zone,
    glbrc_member boolean
);


--
-- Name: invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invites_id_seq OWNED BY public.invites.id;


--
-- Name: kbs002_009; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.kbs002_009 AS
 SELECT date_part('year'::text, lter_precipitation.date) AS year,
    date_part('doy'::text, lter_precipitation.date) AS doy,
    ((lter_solar_radiation.solar_radiation * (86400)::double precision) / (1000000)::double precision) AS solar_radiation,
    lter_air_temp_max.air_temp_max,
    lter_air_temp_min.air_temp_min,
    lter_precipitation.precip AS precipitation,
    ''::text AS dew_point,
    ((lter_wind_speed.wind_speed_mean * (86400)::double precision) / (1000)::double precision) AS wind_run,
    lter_par.par
   FROM ((((((weather.lter_precipitation
     LEFT JOIN weather.lter_air_temp_mean ON ((lter_precipitation.date = lter_air_temp_mean.date)))
     LEFT JOIN weather.lter_air_temp_max ON ((lter_precipitation.date = lter_air_temp_max.date)))
     LEFT JOIN weather.lter_air_temp_min ON ((lter_precipitation.date = lter_air_temp_min.date)))
     LEFT JOIN weather.lter_solar_radiation ON ((lter_precipitation.date = lter_solar_radiation.date)))
     LEFT JOIN weather.lter_par ON ((lter_precipitation.date = lter_par.date)))
     LEFT JOIN weather.lter_wind_speed ON ((lter_precipitation.date = lter_wind_speed.date)))
  ORDER BY lter_precipitation.date;


--
-- Name: kbs013_001_2; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.kbs013_001_2 AS
 SELECT sample_date,
    treatment,
    replicate,
    ch4_c,
    co2_c,
    n2o_n,
    year
   FROM ( SELECT lter_gas_data.sample_date,
            lter_gas_data.treatment,
            ('R'::text || (lter_gas_data.replicate)::text) AS replicate,
            round(lter_gas_data.ch4_c, 1) AS ch4_c,
            round(lter_gas_data.co2_c, 1) AS co2_c,
            round(lter_gas_data.n2o_n, 1) AS n2o_n,
            date_part(' Year '::text, lter_gas_data.sample_date) AS year
           FROM kbs013.lter_gas_data
        UNION
         SELECT lter_gas_data_2000.sample_date,
            lter_gas_data_2000.treatment,
            lter_gas_data_2000.replicate,
            round(((lter_gas_data_2000.ch4_flux * lid_volumes.volume) * 103.5475), 1) AS ch4_c,
            round((((lter_gas_data_2000.co2_flux * lid_volumes.volume) * 103.5475) / (1000)::numeric), 1) AS co2_c,
            round(((lter_gas_data_2000.n2o_flux * lid_volumes.volume) * 241.61), 1) AS n2o_n,
            date_part('year'::text, lter_gas_data_2000.sample_date) AS year
           FROM kbs013.lter_gas_data_2000,
            kbs013.lid_volumes
          WHERE (lter_gas_data_2000.lid_type = lid_volumes.lid)
        UNION
         SELECT lter_gas_data_2003.sample_date,
            ('T'::text || (lter_gas_data_2003.treatment)::text) AS treatment,
            ('R'::text || (lter_gas_data_2003.replicate)::text) AS replicate,
            lter_gas_data_2003.ch4_c,
            lter_gas_data_2003.co2_c,
            lter_gas_data_2003.n2o_n,
            date_part('year'::text, lter_gas_data_2003.sample_date) AS year
           FROM kbs013.lter_gas_data_2003
        UNION
         SELECT kbs013_001_2.sampled_on AS sample_date,
            kbs013_001_2.treatment,
            kbs013_001_2.replicate,
            round((kbs013_001_2.ch4_c)::numeric, 1) AS ch4_c,
            round(((kbs013_001_2.co2_c / (1000)::double precision))::numeric, 0) AS co2_c,
            round((kbs013_001_2.n2o_n)::numeric, 1) AS n2o_n,
            date_part(' year '::text, kbs013_001_2.sampled_on) AS year
           FROM webgas.kbs013_001_2
          WHERE (kbs013_001_2.sub_plot IS NULL)) t1
  WHERE (((treatment)::text !~~ ' TDF%'::text) AND ((treatment)::text !~~ 'TCF%'::text) AND ((treatment)::text !~~ 'TSF%'::text))
  ORDER BY sample_date, treatment, replicate;


--
-- Name: kbs020_007; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.kbs020_007 AS
 SELECT interaction_plots_nutrients.sample_date,
    date_part('year'::text, interaction_plots_nutrients.sample_date) AS year,
    locations.id AS location_id,
    interaction_plots_nutrients.plot,
    locations.replicate,
    interaction_plots_nutrients.treatment,
    interaction_plots_nutrients.depth,
    interaction_plots_nutrients.aluminum_ppm,
    interaction_plots_nutrients.arsenic_ppm,
    interaction_plots_nutrients.boron_ppm,
    interaction_plots_nutrients.barium_ppm,
    interaction_plots_nutrients.beryllium_ppm,
    interaction_plots_nutrients.calcium_ppm,
    interaction_plots_nutrients.cadmium_ppm,
    interaction_plots_nutrients.cobalt_ppm,
    interaction_plots_nutrients.chromium_ppm,
    interaction_plots_nutrients.copper_ppm,
    interaction_plots_nutrients.iron_ppm,
    interaction_plots_nutrients.potassium_ppm,
    interaction_plots_nutrients.lithium_ppm,
    interaction_plots_nutrients.magnesium_ppm,
    interaction_plots_nutrients.manganese_ppm,
    interaction_plots_nutrients.molybdenum_ppm,
    interaction_plots_nutrients.sodium_ppm,
    interaction_plots_nutrients.nickel_ppm,
    interaction_plots_nutrients.phosphorus_ppm,
    interaction_plots_nutrients.lead_ppm,
    interaction_plots_nutrients.sulfur_ppm,
    interaction_plots_nutrients.silicon_ppm,
    interaction_plots_nutrients.strontium_ppm,
    interaction_plots_nutrients.titanium_ppm,
    interaction_plots_nutrients.vanadium_ppm,
    interaction_plots_nutrients.zinc_ppm
   FROM kbs020.interaction_plots_nutrients,
    kbs020.locations
  WHERE ((interaction_plots_nutrients.plot)::text = locations.plot);


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    gid integer NOT NULL,
    extra_name character varying(254),
    treatment character varying(254),
    latitude numeric,
    longitude numeric,
    end_date date,
    gps_height character varying(254),
    gps_date character varying(254),
    gps_correc character varying(254),
    site character varying(100),
    experiment character varying(100),
    gps_type character varying(100),
    vert_prec double precision,
    comments character varying(250),
    station character varying(50),
    replicate character varying(50),
    horz_prec double precision,
    feature character varying(100),
    northing double precision,
    easting double precision,
    sponsor smallint,
    start_date date,
    the_geom public.geometry,
    CONSTRAINT check_st_ndims CHECK ((public.st_ndims(the_geom) = 4)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_st_srid CHECK ((public.st_srid(the_geom) = 4326))
);


--
-- Name: TABLE locations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.locations IS 'old table can be deleted 2010-12-10 sven bohm
';


--
-- Name: locations_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locations_gid_seq OWNED BY public.locations.gid;


--
-- Name: measurement_scales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.measurement_scales (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: measurement_scales_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.measurement_scales_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: measurement_scales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.measurement_scales_id_seq OWNED BY public.measurement_scales.id;


--
-- Name: meeting_abstract_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meeting_abstract_types (
    id integer NOT NULL,
    name text,
    "order" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: meeting_abstract_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meeting_abstract_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meeting_abstract_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meeting_abstract_types_id_seq OWNED BY public.meeting_abstract_types.id;


--
-- Name: meeting_abstracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meeting_abstracts (
    id integer NOT NULL,
    title text,
    authors text,
    abstract text,
    meeting_id integer,
    pdf_file_name character varying(255),
    pdf_content_type character varying(255),
    pdf_file_size integer,
    pdf_updated_at timestamp without time zone,
    author_affiliations text,
    meeting_abstract_type_id integer,
    updated_at timestamp without time zone,
    abstract_backup text
);


--
-- Name: meeting_abstracts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meeting_abstracts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meeting_abstracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meeting_abstracts_id_seq OWNED BY public.meeting_abstracts.id;


--
-- Name: meetings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meetings (
    id integer NOT NULL,
    date date,
    title character varying(255),
    announcement text,
    venue_type_id integer,
    date_to date,
    announcement_backup text
);


--
-- Name: meetings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.meetings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meetings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.meetings_id_seq OWNED BY public.meetings.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id integer NOT NULL,
    sponsor_id integer,
    user_id integer,
    inserted_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.memberships_id_seq OWNED BY public.memberships.id;


--
-- Name: methocols_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.methocols_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mle_days_after_rainfall; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.mle_days_after_rainfall AS
 SELECT location,
    date,
    daily_cumulative_precip,
    prev_date,
        CASE
            WHEN (daily_cumulative_precip > (0)::double precision) THEN (0)::double precision
            ELSE (((1)::double precision + date_part('day'::text, date)) - date_part('day'::text, prev_date))
        END AS days_after_rainfall
   FROM ( SELECT DISTINCT t1.location,
            t1.date,
            t1.daily_cumulative_precip,
            lag(t1.date, 1, '-infinity'::date) OVER (ORDER BY t1.date) AS prev_date
           FROM ( SELECT DISTINCT marginal_land_hour.location,
                    (date_trunc('day'::text, marginal_land_hour.datetime))::date AS date,
                    sum(marginal_land_hour.rain_mm_tot) OVER (PARTITION BY marginal_land_hour.location, ((date_trunc('day'::text, marginal_land_hour.datetime))::date) ORDER BY ((date_trunc('day'::text, marginal_land_hour.datetime))::date)) AS daily_cumulative_precip
                   FROM weather.marginal_land_hour) t1) t2
  GROUP BY location, date, daily_cumulative_precip, prev_date;


--
-- Name: mle_polygons; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.mle_polygons AS
 SELECT site,
    name,
    fertilizat,
    public.st_collect(geom) AS geom
   FROM test."MLE_nodes_2"
  GROUP BY site, name, fertilizat
  ORDER BY site, name, fertilizat;


--
-- Name: myprogress; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.myprogress
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: n2o_project_weather; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.n2o_project_weather AS
 SELECT t2.name AS site,
    t3.dataset_name,
    t1.date,
    t1.max_air_temperature,
    t1.min_air_temperature,
    t1.mean_air_temperature,
    t1.daily_precipitation
   FROM ((test."N2O_weather" t1
     LEFT JOIN test.site t2 ON ((t1.site_id = t2.id)))
     LEFT JOIN test.datasets t3 ON ((t1.dataset_id = t3.id)));


--
-- Name: non_emeritus_email_list; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.non_emeritus_email_list AS
SELECT
    NULL::integer AS id,
    NULL::character varying(255) AS email,
    NULL::character varying(255) AS given_name,
    NULL::character varying(255) AS sur_name,
    NULL::character varying[] AS roles,
    NULL::character varying(255) AS organization,
    NULL::character varying(255) AS sub_organization,
    NULL::character varying(255) AS street_address,
    NULL::character varying(255) AS city,
    NULL::character varying(255) AS locale,
    NULL::character varying(255) AS country,
    NULL::character varying(255) AS postal_code,
    NULL::character varying(255) AS phone,
    NULL::character varying(255) AS fax;


--
-- Name: oban_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oban_jobs (
    id bigint NOT NULL,
    state public.oban_job_state DEFAULT 'available'::public.oban_job_state NOT NULL,
    queue text DEFAULT 'default'::text NOT NULL,
    worker text NOT NULL,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    errors jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    attempt integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 20 NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    scheduled_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    attempted_at timestamp without time zone,
    completed_at timestamp without time zone,
    attempted_by text[],
    discarded_at timestamp without time zone,
    priority integer DEFAULT 0 NOT NULL,
    tags text[] DEFAULT ARRAY[]::text[],
    meta jsonb DEFAULT '{}'::jsonb,
    cancelled_at timestamp without time zone,
    CONSTRAINT attempt_range CHECK (((attempt >= 0) AND (attempt <= max_attempts))),
    CONSTRAINT positive_max_attempts CHECK ((max_attempts > 0)),
    CONSTRAINT queue_length CHECK (((char_length(queue) > 0) AND (char_length(queue) < 128))),
    CONSTRAINT worker_length CHECK (((char_length(worker) > 0) AND (char_length(worker) < 128)))
);


--
-- Name: TABLE oban_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.oban_jobs IS '12';


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oban_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oban_jobs_id_seq OWNED BY public.oban_jobs.id;


--
-- Name: oban_peers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.oban_peers (
    name text NOT NULL,
    node text NOT NULL,
    started_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: ownerships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ownerships (
    id integer NOT NULL,
    datatable_id integer,
    user_id integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: ownerships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ownerships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ownerships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ownerships_id_seq OWNED BY public.ownerships.id;


--
-- Name: page_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_images (
    id integer NOT NULL,
    title character varying(255),
    attribution character varying(255),
    page_id integer,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone
);


--
-- Name: page_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_images_id_seq OWNED BY public.page_images.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id integer NOT NULL,
    title character varying(255),
    body text,
    url character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    body_backup text,
    body_markdown boolean DEFAULT false
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.people (
    id integer DEFAULT nextval('public.people_id_seq'::regclass) NOT NULL,
    person character varying(255),
    sur_name character varying(255),
    given_name character varying(255),
    middle_name character varying(255),
    friendly_name character varying(255),
    title character varying(255),
    sub_organization character varying(255),
    organization character varying(255),
    street_address character varying(255),
    city character varying(255),
    locale character varying(255),
    country character varying(255),
    postal_code character varying(255),
    phone character varying(255),
    fax character varying(255),
    email character varying(255),
    url character varying(255),
    deceased boolean,
    open_id character varying(255),
    is_postdoc boolean,
    updated_at timestamp without time zone DEFAULT now(),
    created_at timestamp without time zone DEFAULT now(),
    orcid_id character varying,
    graduation_year integer,
    thesis_id integer,
    lter_awards text,
    lter_thesis boolean DEFAULT false,
    thesis_url text,
    thesis_type character(3),
    lno_contact_id character varying(255),
    lno_name text
);


--
-- Name: permission_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permission_requests (
    id integer NOT NULL,
    datatable_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: permission_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permission_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permission_requests_id_seq OWNED BY public.permission_requests.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    datatable_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    owner_id integer,
    decision character varying(255),
    expires_on date,
    expiry_reminder_sent_at timestamp(6) without time zone,
    intended_use text,
    site character varying
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: permissions_legacy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions_legacy (
    id integer,
    user_id integer,
    datatable_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    owner_id integer,
    decision character varying(255)
);


--
-- Name: person_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person_projects (
    id bigint NOT NULL,
    person_id integer,
    project_id integer,
    role_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: person_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.person_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: person_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.person_projects_id_seq OWNED BY public.person_projects.id;


--
-- Name: plot_nodes_geospatial; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.plot_nodes_geospatial AS
 SELECT id,
    site,
    experiment,
    treatment,
    replicate,
    feature,
    plot_name,
    edge_id,
    x,
    y,
    z
   FROM ( SELECT dp.id,
            dp.plot_name,
            (dp.dp).path[2] AS edge_id,
            public.st_x((dp.dp).geom) AS x,
            public.st_y((dp.dp).geom) AS y,
            public.st_z((dp.dp).geom) AS z,
            dp.site,
            dp.experiment,
            dp.treatment,
            dp.replicate,
            dp.feature
           FROM ( SELECT areas.gid AS id,
                    areas.site,
                    areas.experiment,
                    areas.treatment,
                    areas.replicate,
                    areas.feature,
                    concat('G', areas.treatment, 'R', areas.replicate) AS plot_name,
                    public.st_dumppoints((public.st_astext(public.st_geometryn(areas.the_geom, 1)))::public.geometry) AS dp
                   FROM public.areas) dp) foo;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    title character varying(255),
    abstract text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    funder_name character varying,
    funder_identifier character varying,
    award_number character varying,
    award_url character varying,
    "organizationName" text,
    role text
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: protocols; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.protocols (
    id integer DEFAULT nextval('public.methocols_id_seq'::regclass) NOT NULL,
    name character varying(255),
    title character varying(255),
    version_tag integer DEFAULT 1,
    in_use_from date,
    in_use_to date,
    description text,
    abstract text,
    body text,
    person_id integer,
    created_on date,
    updated_on date,
    change_summary text,
    dataset_id integer,
    active boolean DEFAULT true,
    deprecates integer,
    pdf_file_name character varying(255),
    pdf_content_type character varying(255),
    pdf_file_size integer,
    pdf_updated_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    body_backup text,
    description_backup text,
    abstract_backup text,
    change_summary_backup text
);


--
-- Name: protocols_sponsors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.protocols_sponsors (
    protocol_id integer,
    sponsor_id integer
);


--
-- Name: protocols_websites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.protocols_websites (
    protocol_id integer,
    website_id integer
);


--
-- Name: publications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publications (
    id integer DEFAULT nextval('public.publications_id_seq'::regclass) NOT NULL,
    publication_type_id integer,
    citation text,
    abstract text,
    year integer,
    file_url character varying(255),
    title text,
    authors text,
    source_id integer,
    parent_id integer,
    content_type character varying(255),
    filename character varying(255),
    size integer,
    width integer,
    height integer,
    deprecated boolean
);


--
-- Name: publications_treatments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publications_treatments (
    treatment_id integer,
    publication_id integer
);


--
-- Name: publication_numbers_by_treatment_and_year; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.publication_numbers_by_treatment_and_year AS
 SELECT publications.year,
    count(*) AS count,
    treatments.name
   FROM public.publications,
    public.publications_treatments,
    public.treatments
  WHERE ((publications.id = publications_treatments.publication_id) AND (treatments.id = publications_treatments.treatment_id))
  GROUP BY publications.year, treatments.name
  ORDER BY publications.year, treatments.name;


--
-- Name: publication_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publication_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publication_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publication_types (
    id integer DEFAULT nextval('public.publication_types_id_seq'::regclass) NOT NULL,
    name character varying(255)
);


--
-- Name: replicates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.replicates (
    replicate character varying(50) NOT NULL,
    description character varying(255)
);


--
-- Name: role_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_types (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: role_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_types_id_seq OWNED BY public.role_types.id;


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer DEFAULT nextval('public.roles_id_seq'::regclass) NOT NULL,
    name character varying(255),
    role_type_id integer,
    seniority integer,
    show_in_overview boolean DEFAULT true,
    show_in_detailview boolean DEFAULT true
);


--
-- Name: root_excavations_avg_measure_cm; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.root_excavations_avg_measure_cm AS
 SELECT treatment,
    replicate,
    dimension,
    avg(measure_cm) AS avg_measure_cm
   FROM glbrc.root_excavations_measurements
  GROUP BY treatment, replicate, dimension;


--
-- Name: root_excavations_soil_volumes; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.root_excavations_soil_volumes AS
 SELECT treatment,
    replicate,
    exp(sum(ln(avg_measure_cm))) AS soil_volumn_cm3
   FROM public.root_excavations_avg_measure_cm
  GROUP BY treatment, replicate;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255),
    inserted_at timestamp(0) without time zone,
    "version-elixir" bigint
);


--
-- Name: scribbles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scribbles (
    id integer NOT NULL,
    person_id integer,
    protocol_id integer,
    weight integer
);


--
-- Name: scribbles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scribbles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scribbles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scribbles_id_seq OWNED BY public.scribbles.id;


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id integer DEFAULT nextval('public.sessions_id_seq'::regclass) NOT NULL,
    session_id character varying(255),
    data text,
    updated_at timestamp without time zone
);


--
-- Name: site; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site (
    id integer NOT NULL,
    name character varying,
    geometry character varying
);


--
-- Name: site_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_id_seq OWNED BY public.site.id;


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id integer NOT NULL,
    sitename character varying(255) NOT NULL,
    description text,
    start_date date,
    end_date date,
    sitecode character varying(255),
    updated_at timestamp without time zone,
    created_at timestamp without time zone
);


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sites_id_seq OWNED BY public.sites.id;


--
-- Name: slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slugs (
    id integer NOT NULL,
    name character varying(255),
    sluggable_id integer,
    sequence integer DEFAULT 1 NOT NULL,
    sluggable_type character varying(40),
    scope character varying(255),
    created_at timestamp without time zone
);


--
-- Name: slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slugs_id_seq OWNED BY public.slugs.id;


--
-- Name: solid_queue_batch_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_batch_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    batch_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_batch_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_batch_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_batch_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_batch_executions_id_seq OWNED BY public.solid_queue_batch_executions.id;


--
-- Name: solid_queue_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_batches (
    id bigint NOT NULL,
    active_job_batch_id character varying,
    description character varying,
    on_finish text,
    on_success text,
    on_failure text,
    metadata text,
    total_jobs integer DEFAULT 0 NOT NULL,
    completed_jobs integer DEFAULT 0 NOT NULL,
    failed_jobs integer DEFAULT 0 NOT NULL,
    enqueued_at timestamp(6) without time zone,
    finished_at timestamp(6) without time zone,
    failed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_batches_id_seq OWNED BY public.solid_queue_batches.id;


--
-- Name: solid_queue_blocked_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_blocked_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    queue_name character varying NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    concurrency_key character varying NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_blocked_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_blocked_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_blocked_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_blocked_executions_id_seq OWNED BY public.solid_queue_blocked_executions.id;


--
-- Name: solid_queue_claimed_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_claimed_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    process_id bigint,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_claimed_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_claimed_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_claimed_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_claimed_executions_id_seq OWNED BY public.solid_queue_claimed_executions.id;


--
-- Name: solid_queue_failed_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_failed_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    error text,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_failed_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_failed_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_failed_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_failed_executions_id_seq OWNED BY public.solid_queue_failed_executions.id;


--
-- Name: solid_queue_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_jobs (
    id bigint NOT NULL,
    queue_name character varying NOT NULL,
    class_name character varying NOT NULL,
    arguments text,
    priority integer DEFAULT 0 NOT NULL,
    active_job_id character varying,
    scheduled_at timestamp(6) without time zone,
    finished_at timestamp(6) without time zone,
    concurrency_key character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    batch_id bigint
);


--
-- Name: solid_queue_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_jobs_id_seq OWNED BY public.solid_queue_jobs.id;


--
-- Name: solid_queue_pauses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_pauses (
    id bigint NOT NULL,
    queue_name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_pauses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_pauses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_pauses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_pauses_id_seq OWNED BY public.solid_queue_pauses.id;


--
-- Name: solid_queue_processes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_processes (
    id bigint NOT NULL,
    kind character varying NOT NULL,
    last_heartbeat_at timestamp(6) without time zone NOT NULL,
    supervisor_id bigint,
    pid integer NOT NULL,
    hostname character varying,
    metadata text,
    created_at timestamp(6) without time zone NOT NULL,
    name character varying NOT NULL
);


--
-- Name: solid_queue_processes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_processes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_processes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_processes_id_seq OWNED BY public.solid_queue_processes.id;


--
-- Name: solid_queue_ready_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_ready_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    queue_name character varying NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_ready_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_ready_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_ready_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_ready_executions_id_seq OWNED BY public.solid_queue_ready_executions.id;


--
-- Name: solid_queue_recurring_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_recurring_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    task_key character varying NOT NULL,
    run_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_recurring_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_recurring_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_recurring_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_recurring_executions_id_seq OWNED BY public.solid_queue_recurring_executions.id;


--
-- Name: solid_queue_recurring_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_recurring_tasks (
    id bigint NOT NULL,
    key character varying NOT NULL,
    schedule character varying NOT NULL,
    command character varying(2048),
    class_name character varying,
    arguments text,
    queue_name character varying,
    priority integer DEFAULT 0,
    static boolean DEFAULT true NOT NULL,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_recurring_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_recurring_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_recurring_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_recurring_tasks_id_seq OWNED BY public.solid_queue_recurring_tasks.id;


--
-- Name: solid_queue_scheduled_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_scheduled_executions (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    queue_name character varying NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    scheduled_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_scheduled_executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_scheduled_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_scheduled_executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_scheduled_executions_id_seq OWNED BY public.solid_queue_scheduled_executions.id;


--
-- Name: solid_queue_semaphores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_queue_semaphores (
    id bigint NOT NULL,
    key character varying NOT NULL,
    value integer DEFAULT 1 NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: solid_queue_semaphores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_queue_semaphores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_queue_semaphores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_queue_semaphores_id_seq OWNED BY public.solid_queue_semaphores.id;


--
-- Name: sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sources (
    id integer DEFAULT nextval('public.sources_id_seq'::regclass) NOT NULL,
    title character varying(255)
);


--
-- Name: species_transect_schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.species_transect_schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: sponsors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sponsors (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    data_restricted boolean DEFAULT false,
    data_use_statement text,
    terms_of_use_url character varying,
    data_use_statement_backup text
);


--
-- Name: TABLE sponsors; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.sponsors IS 'Control the accessibility of data';


--
-- Name: sponsors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sponsors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sponsors_id_seq OWNED BY public.sponsors.id;


--
-- Name: studies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.studies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: studies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.studies_id_seq OWNED BY public.studies.id;


--
-- Name: study_urls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_urls (
    id integer NOT NULL,
    website_id integer,
    study_id integer,
    url character varying(255)
);


--
-- Name: study_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_urls_id_seq OWNED BY public.study_urls.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    tagger_id integer,
    tagger_type character varying(255),
    taggable_type character varying(255),
    context character varying(255),
    created_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taggings_id_seq OWNED BY public.taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    name character varying(255),
    taggings_count integer DEFAULT 0
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: temp_affiliations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.temp_affiliations AS
 WITH t1 AS (
         SELECT people.id,
            people.sur_name,
            people.given_name,
            role_types.name AS role,
            roles.name AS role_type
           FROM (((public.people
             JOIN public.affiliations ON ((affiliations.person_id = people.id)))
             JOIN public.roles ON ((affiliations.role_id = roles.id)))
             JOIN public.role_types ON ((role_types.id = roles.role_type_id)))
          WHERE ((role_types.name)::text = ANY (ARRAY[('lno'::character varying)::text, ('lter'::character varying)::text]))
        )
 SELECT id,
    sur_name,
    given_name,
    role,
    count(*) AS n
   FROM t1
  WHERE ((role_type)::text !~~ 'Emeritus%'::text)
  GROUP BY id, sur_name, given_name, role
  ORDER BY id, role;


--
-- Name: templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.templates (
    id integer NOT NULL,
    website_id integer,
    controller character varying(255),
    action character varying(255),
    layout text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.templates_id_seq OWNED BY public.templates.id;


--
-- Name: test_gas_flux_chamber_locations_delete; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.test_gas_flux_chamber_locations_delete AS
 SELECT gid,
    site,
    feature,
    replicate,
    extra_name,
    start_date,
    end_date,
    treatment,
    experiment,
    sponsor,
    the_geom,
    gps_date,
    gps_corr,
    gps_type,
    height,
    vert_precision,
    horiz_precision,
    comment,
    station,
    easting,
    northing,
    people,
    longitude,
    latitude,
    disturbance_type,
    material,
    year,
    "2016",
    "2017"
   FROM public.areas
  WHERE (((feature)::text ~~ '%gas flux%'::text) AND ((site)::text = 'KBS GLBRC Intensive Site'::text));


--
-- Name: themes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.themes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: themes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.themes (
    id integer DEFAULT nextval('public.themes_id_seq'::regclass) NOT NULL,
    name character varying(255),
    weight integer,
    parent_id integer,
    lft integer,
    rgt integer,
    updated_at timestamp without time zone,
    created_at timestamp without time zone
);


--
-- Name: treatments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.treatments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: treatments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.treatments_id_seq OWNED BY public.treatments.id;


--
-- Name: units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.units (
    id integer DEFAULT nextval('public.units_id_seq'::regclass) NOT NULL,
    name character varying(255),
    description text,
    in_eml boolean DEFAULT false,
    definition text,
    deprecated_in_favor_of integer,
    unit_type character varying(255),
    parent_si character varying(255),
    multiplier_to_si double precision,
    abbreviation character varying,
    label character varying(255),
    offset_to_si double precision,
    updated_at timestamp without time zone DEFAULT now(),
    inserted_at timestamp without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255),
    encrypted_password character varying(128),
    salt character varying(128),
    confirmation_token character varying(128),
    remember_token character varying(128),
    email_confirmed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    identity_url character varying(255),
    role character varying(255),
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    provider character varying,
    uid character varying,
    inserted_at timestamp without time zone,
    confirmed_at timestamp without time zone,
    hashed_password character varying(256),
    last_glbrc_groups text[] DEFAULT '{}'::text[] NOT NULL,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp(6) without time zone,
    first_name character varying,
    last_name character varying,
    institution character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq1 OWNED BY public.users.id;


--
-- Name: users_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_tokens (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_tokens_id_seq OWNED BY public.users_tokens.id;


--
-- Name: variates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.variates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: variates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.variates (
    id integer DEFAULT nextval('public.variates_id_seq'::regclass) NOT NULL,
    name character varying(255),
    datatable_id integer,
    weight integer,
    description text,
    missing_value_indicator character varying(255),
    unit_id integer,
    measurement_scale character varying(255),
    data_type character varying(255),
    min_valid double precision,
    max_valid double precision,
    date_format character varying(255),
    "precision" double precision,
    query text,
    variate_theme_id integer,
    inserted_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: venue_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.venue_types (
    id integer NOT NULL,
    name character varying(255),
    description text
);


--
-- Name: venue_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.venue_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: venue_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.venue_types_id_seq OWNED BY public.venue_types.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id integer NOT NULL,
    versioned_id integer,
    versioned_type character varying(255),
    user_id integer,
    user_type character varying(255),
    user_name character varying(255),
    modifications text,
    number integer,
    reverted_from integer,
    tag character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: visualizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visualizations (
    id integer NOT NULL,
    datatable_id integer,
    title character varying(255),
    body text,
    query text,
    graph_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    x_axis_label character varying(255),
    y_axis_label character varying(255),
    weight integer
);


--
-- Name: visualizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visualizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visualizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visualizations_id_seq OWNED BY public.visualizations.id;


--
-- Name: websites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.websites (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    data_catalog_intro text,
    url text
);


--
-- Name: websites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.websites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: websites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.websites_id_seq OWNED BY public.websites.id;


--
-- Name: 2_ed_lux_arbor_microplots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2_ed_lux_arbor_microplots" ALTER COLUMN id SET DEFAULT nextval('public."2_ed_lux_arbor_microplots_id_seq"'::regclass);


--
-- Name: LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a_v2025 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a_v2025" ALTER COLUMN id SET DEFAULT nextval('public."LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy__id_seq"'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: analysis_labs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analysis_labs ALTER COLUMN id SET DEFAULT nextval('public.analysis_labs_id_seq'::regclass);


--
-- Name: areas gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas ALTER COLUMN gid SET DEFAULT nextval('public.areas_gid_seq'::regclass);


--
-- Name: areas_temporary gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas_temporary ALTER COLUMN gid SET DEFAULT nextval('public.areas_temporary_gid_seq'::regclass);


--
-- Name: authors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authors ALTER COLUMN id SET DEFAULT nextval('public.authors_id_seq'::regclass);


--
-- Name: chambers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chambers ALTER COLUMN id SET DEFAULT nextval('public.gas_chambers_id_seq'::regclass);


--
-- Name: citation_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citation_types ALTER COLUMN id SET DEFAULT nextval('public.citation_types_id_seq'::regclass);


--
-- Name: citations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citations ALTER COLUMN id SET DEFAULT nextval('public.citations_id_seq'::regclass);


--
-- Name: collections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections ALTER COLUMN id SET DEFAULT nextval('public.collections_id_seq'::regclass);


--
-- Name: columns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.columns ALTER COLUMN id SET DEFAULT nextval('public.columns_id_seq'::regclass);


--
-- Name: core_areas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_areas ALTER COLUMN id SET DEFAULT nextval('public.core_areas_id_seq'::regclass);


--
-- Name: core_areas_datatables id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_areas_datatables ALTER COLUMN id SET DEFAULT nextval('public.core_areas_datatables_id_seq'::regclass);


--
-- Name: data_contributions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_contributions ALTER COLUMN id SET DEFAULT nextval('public.data_contributions_id_seq'::regclass);


--
-- Name: data_usages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_usages ALTER COLUMN id SET DEFAULT nextval('public.data_usages_id_seq'::regclass);


--
-- Name: data_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_versions ALTER COLUMN id SET DEFAULT nextval('public.data_versions_id_seq'::regclass);


--
-- Name: datafiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datafiles ALTER COLUMN id SET DEFAULT nextval('public.datafiles_id_seq'::regclass);


--
-- Name: dataset_dois id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_dois ALTER COLUMN id SET DEFAULT nextval('public.dataset_dois_id_seq'::regclass);


--
-- Name: dataset_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_files ALTER COLUMN id SET DEFAULT nextval('public.dataset_files_id_seq'::regclass);


--
-- Name: datatables_dois id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatables_dois ALTER COLUMN id SET DEFAULT nextval('public.datatables_dois_id_seq'::regclass);


--
-- Name: datatables_variates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatables_variates ALTER COLUMN id SET DEFAULT nextval('public.datatables_variates_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: devise_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devise_invitations ALTER COLUMN id SET DEFAULT nextval('public.devise_invitations_id_seq'::regclass);


--
-- Name: editors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.editors ALTER COLUMN id SET DEFAULT nextval('public.editors_id_seq'::regclass);


--
-- Name: enumerated_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enumerated_values ALTER COLUMN id SET DEFAULT nextval('public.enumerated_values_id_seq'::regclass);


--
-- Name: farm_fields0 fid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.farm_fields0 ALTER COLUMN fid SET DEFAULT nextval('public.farm_fields0_fid_seq'::regclass);


--
-- Name: fertilization id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fertilization ALTER COLUMN id SET DEFAULT nextval('public.fertilization_id_seq'::regclass);


--
-- Name: invites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invites ALTER COLUMN id SET DEFAULT nextval('public.invites_id_seq'::regclass);


--
-- Name: locations gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations ALTER COLUMN gid SET DEFAULT nextval('public.locations_gid_seq'::regclass);


--
-- Name: measurement_scales id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurement_scales ALTER COLUMN id SET DEFAULT nextval('public.measurement_scales_id_seq'::regclass);


--
-- Name: meeting_abstract_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_abstract_types ALTER COLUMN id SET DEFAULT nextval('public.meeting_abstract_types_id_seq'::regclass);


--
-- Name: meeting_abstracts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_abstracts ALTER COLUMN id SET DEFAULT nextval('public.meeting_abstracts_id_seq'::regclass);


--
-- Name: meetings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meetings ALTER COLUMN id SET DEFAULT nextval('public.meetings_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: oban_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs ALTER COLUMN id SET DEFAULT nextval('public.oban_jobs_id_seq'::regclass);


--
-- Name: ownerships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ownerships ALTER COLUMN id SET DEFAULT nextval('public.ownerships_id_seq'::regclass);


--
-- Name: page_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_images ALTER COLUMN id SET DEFAULT nextval('public.page_images_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- Name: permission_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_requests ALTER COLUMN id SET DEFAULT nextval('public.permission_requests_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: person_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_projects ALTER COLUMN id SET DEFAULT nextval('public.person_projects_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: role_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_types ALTER COLUMN id SET DEFAULT nextval('public.role_types_id_seq'::regclass);


--
-- Name: scribbles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scribbles ALTER COLUMN id SET DEFAULT nextval('public.scribbles_id_seq'::regclass);


--
-- Name: site id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site ALTER COLUMN id SET DEFAULT nextval('public.site_id_seq'::regclass);


--
-- Name: sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites ALTER COLUMN id SET DEFAULT nextval('public.sites_id_seq'::regclass);


--
-- Name: slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slugs ALTER COLUMN id SET DEFAULT nextval('public.slugs_id_seq'::regclass);


--
-- Name: solid_queue_batch_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_batch_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_batch_executions_id_seq'::regclass);


--
-- Name: solid_queue_batches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_batches ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_batches_id_seq'::regclass);


--
-- Name: solid_queue_blocked_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_blocked_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_blocked_executions_id_seq'::regclass);


--
-- Name: solid_queue_claimed_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_claimed_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_claimed_executions_id_seq'::regclass);


--
-- Name: solid_queue_failed_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_failed_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_failed_executions_id_seq'::regclass);


--
-- Name: solid_queue_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_jobs ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_jobs_id_seq'::regclass);


--
-- Name: solid_queue_pauses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_pauses ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_pauses_id_seq'::regclass);


--
-- Name: solid_queue_processes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_processes ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_processes_id_seq'::regclass);


--
-- Name: solid_queue_ready_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_ready_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_ready_executions_id_seq'::regclass);


--
-- Name: solid_queue_recurring_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_recurring_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_recurring_executions_id_seq'::regclass);


--
-- Name: solid_queue_recurring_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_recurring_tasks ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_recurring_tasks_id_seq'::regclass);


--
-- Name: solid_queue_scheduled_executions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_scheduled_executions ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_scheduled_executions_id_seq'::regclass);


--
-- Name: solid_queue_semaphores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_semaphores ALTER COLUMN id SET DEFAULT nextval('public.solid_queue_semaphores_id_seq'::regclass);


--
-- Name: sponsors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sponsors ALTER COLUMN id SET DEFAULT nextval('public.sponsors_id_seq'::regclass);


--
-- Name: studies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studies ALTER COLUMN id SET DEFAULT nextval('public.studies_id_seq'::regclass);


--
-- Name: study_urls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_urls ALTER COLUMN id SET DEFAULT nextval('public.study_urls_id_seq'::regclass);


--
-- Name: taggings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings ALTER COLUMN id SET DEFAULT nextval('public.taggings_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates ALTER COLUMN id SET DEFAULT nextval('public.templates_id_seq'::regclass);


--
-- Name: treatments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatments ALTER COLUMN id SET DEFAULT nextval('public.treatments_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq1'::regclass);


--
-- Name: users_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens ALTER COLUMN id SET DEFAULT nextval('public.users_tokens_id_seq'::regclass);


--
-- Name: venue_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_types ALTER COLUMN id SET DEFAULT nextval('public.venue_types_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: visualizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visualizations ALTER COLUMN id SET DEFAULT nextval('public.visualizations_id_seq'::regclass);


--
-- Name: websites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.websites ALTER COLUMN id SET DEFAULT nextval('public.websites_id_seq'::regclass);


--
-- Name: 2_ed_lux_arbor_microplots 2_ed_lux_arbor_microplots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2_ed_lux_arbor_microplots"
    ADD CONSTRAINT "2_ed_lux_arbor_microplots_pkey" PRIMARY KEY (id);


--
-- Name: LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a_v2025 LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a__pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a_v2025"
    ADD CONSTRAINT "LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a__pkey" PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: affiliations affiliations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliations
    ADD CONSTRAINT affiliations_pkey PRIMARY KEY (id);


--
-- Name: analysis_labs analysis_labs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analysis_labs
    ADD CONSTRAINT analysis_labs_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: areas areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_pkey PRIMARY KEY (gid);


--
-- Name: areas_temporary areas_temporary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.areas_temporary
    ADD CONSTRAINT areas_temporary_pkey PRIMARY KEY (gid);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: citation_types citation_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citation_types
    ADD CONSTRAINT citation_types_pkey PRIMARY KEY (id);


--
-- Name: citations citations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citations
    ADD CONSTRAINT citations_pkey PRIMARY KEY (id);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: columns columns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.columns
    ADD CONSTRAINT columns_pkey PRIMARY KEY (id);


--
-- Name: core_areas_datatables core_areas_datatables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_areas_datatables
    ADD CONSTRAINT core_areas_datatables_pkey PRIMARY KEY (id);


--
-- Name: core_areas core_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_areas
    ADD CONSTRAINT core_areas_pkey PRIMARY KEY (id);


--
-- Name: data_contributions data_contributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_contributions
    ADD CONSTRAINT data_contributions_pkey PRIMARY KEY (id);


--
-- Name: data_usages data_usages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_usages
    ADD CONSTRAINT data_usages_pkey PRIMARY KEY (id);


--
-- Name: data_versions data_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_versions
    ADD CONSTRAINT data_versions_pkey PRIMARY KEY (id);


--
-- Name: datafiles datafiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datafiles
    ADD CONSTRAINT datafiles_pkey PRIMARY KEY (id);


--
-- Name: dataset_dois dataset_dois_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_dois
    ADD CONSTRAINT dataset_dois_pkey PRIMARY KEY (id);


--
-- Name: dataset_files dataset_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_files
    ADD CONSTRAINT dataset_files_pkey PRIMARY KEY (id);


--
-- Name: datasets datasets_dataset_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datasets
    ADD CONSTRAINT datasets_dataset_key UNIQUE (dataset);


--
-- Name: datasets datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datasets
    ADD CONSTRAINT datasets_pkey PRIMARY KEY (id);


--
-- Name: datatables_dois datatables_dois_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatables_dois
    ADD CONSTRAINT datatables_dois_pkey PRIMARY KEY (id);


--
-- Name: datatables datatables_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatables
    ADD CONSTRAINT datatables_name_key UNIQUE NULLS NOT DISTINCT (name);


--
-- Name: datatables datatables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatables
    ADD CONSTRAINT datatables_pkey PRIMARY KEY (id);


--
-- Name: datatables_protocols datatables_protocols_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatables_protocols
    ADD CONSTRAINT datatables_protocols_pkey PRIMARY KEY (datatable_id, protocol_id);


--
-- Name: datatables_variates datatables_variates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatables_variates
    ADD CONSTRAINT datatables_variates_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: devise_invitations devise_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devise_invitations
    ADD CONSTRAINT devise_invitations_pkey PRIMARY KEY (id);


--
-- Name: editors editors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.editors
    ADD CONSTRAINT editors_pkey PRIMARY KEY (id);


--
-- Name: eml_docs eml_docs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eml_docs
    ADD CONSTRAINT eml_docs_pkey PRIMARY KEY (id);


--
-- Name: enumerated_values enumerated_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enumerated_values
    ADD CONSTRAINT enumerated_values_pkey PRIMARY KEY (id);


--
-- Name: farm_fields0 farm_fields0_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.farm_fields0
    ADD CONSTRAINT farm_fields0_pkey PRIMARY KEY (fid);


--
-- Name: fertilization fertilization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fertilization
    ADD CONSTRAINT fertilization_pkey PRIMARY KEY (id);


--
-- Name: chambers gas_chambers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chambers
    ADD CONSTRAINT gas_chambers_pkey PRIMARY KEY (id);


--
-- Name: invites invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (gid);


--
-- Name: measurement_scales measurement_scales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurement_scales
    ADD CONSTRAINT measurement_scales_pkey PRIMARY KEY (id);


--
-- Name: meeting_abstract_types meeting_abstract_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_abstract_types
    ADD CONSTRAINT meeting_abstract_types_pkey PRIMARY KEY (id);


--
-- Name: meeting_abstracts meeting_abstracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_abstracts
    ADD CONSTRAINT meeting_abstracts_pkey PRIMARY KEY (id);


--
-- Name: meetings meetings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meetings
    ADD CONSTRAINT meetings_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_sponsor_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_sponsor_id_user_id_key UNIQUE NULLS NOT DISTINCT (sponsor_id, user_id);


--
-- Name: protocols methocols_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.protocols
    ADD CONSTRAINT methocols_pkey PRIMARY KEY (id);


--
-- Name: barcode nanobarcode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.barcode
    ADD CONSTRAINT nanobarcode_pkey PRIMARY KEY (id);


--
-- Name: oban_jobs non_negative_priority; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.oban_jobs
    ADD CONSTRAINT non_negative_priority CHECK ((priority >= 0)) NOT VALID;


--
-- Name: oban_jobs oban_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs
    ADD CONSTRAINT oban_jobs_pkey PRIMARY KEY (id);


--
-- Name: oban_peers oban_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_peers
    ADD CONSTRAINT oban_peers_pkey PRIMARY KEY (name);


--
-- Name: ownerships ownerships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ownerships
    ADD CONSTRAINT ownerships_pkey PRIMARY KEY (id);


--
-- Name: page_images page_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_images
    ADD CONSTRAINT page_images_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: people people_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_email_key UNIQUE (email);


--
-- Name: people people_lno_contact_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_lno_contact_id_key UNIQUE (lno_contact_id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: people people_sur_name_given_name_middle_name_friendly_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_sur_name_given_name_middle_name_friendly_name_key UNIQUE (sur_name, given_name, middle_name, friendly_name);


--
-- Name: permission_requests permission_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_requests
    ADD CONSTRAINT permission_requests_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: person_projects person_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_projects
    ADD CONSTRAINT person_projects_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: publication_types publication_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication_types
    ADD CONSTRAINT publication_types_pkey PRIMARY KEY (id);


--
-- Name: publications publications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


--
-- Name: role_types role_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_types
    ADD CONSTRAINT role_types_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: scribbles scribbles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scribbles
    ADD CONSTRAINT scribbles_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: site site_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: slugs slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slugs
    ADD CONSTRAINT slugs_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_batch_executions solid_queue_batch_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_batch_executions
    ADD CONSTRAINT solid_queue_batch_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_batches solid_queue_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_batches
    ADD CONSTRAINT solid_queue_batches_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_blocked_executions solid_queue_blocked_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_blocked_executions
    ADD CONSTRAINT solid_queue_blocked_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_claimed_executions solid_queue_claimed_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_claimed_executions
    ADD CONSTRAINT solid_queue_claimed_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_failed_executions solid_queue_failed_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_failed_executions
    ADD CONSTRAINT solid_queue_failed_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_jobs solid_queue_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_jobs
    ADD CONSTRAINT solid_queue_jobs_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_pauses solid_queue_pauses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_pauses
    ADD CONSTRAINT solid_queue_pauses_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_processes solid_queue_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_processes
    ADD CONSTRAINT solid_queue_processes_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_ready_executions solid_queue_ready_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_ready_executions
    ADD CONSTRAINT solid_queue_ready_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_recurring_executions solid_queue_recurring_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_recurring_executions
    ADD CONSTRAINT solid_queue_recurring_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_recurring_tasks solid_queue_recurring_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_recurring_tasks
    ADD CONSTRAINT solid_queue_recurring_tasks_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_scheduled_executions solid_queue_scheduled_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_scheduled_executions
    ADD CONSTRAINT solid_queue_scheduled_executions_pkey PRIMARY KEY (id);


--
-- Name: solid_queue_semaphores solid_queue_semaphores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_semaphores
    ADD CONSTRAINT solid_queue_semaphores_pkey PRIMARY KEY (id);


--
-- Name: sources sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- Name: species_transect_schema_migrations species_transect_schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species_transect_schema_migrations
    ADD CONSTRAINT species_transect_schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sponsors sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sponsors
    ADD CONSTRAINT sponsors_pkey PRIMARY KEY (id);


--
-- Name: studies studies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studies
    ADD CONSTRAINT studies_pkey PRIMARY KEY (id);


--
-- Name: study_urls study_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_urls
    ADD CONSTRAINT study_urls_pkey PRIMARY KEY (id);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: themes themes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.themes
    ADD CONSTRAINT themes_pkey PRIMARY KEY (id);


--
-- Name: treatments treatments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatments
    ADD CONSTRAINT treatments_pkey PRIMARY KEY (id);


--
-- Name: units unit_names_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT unit_names_key UNIQUE (name);


--
-- Name: units units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_tokens users_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_pkey PRIMARY KEY (id);


--
-- Name: variates variates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variates
    ADD CONSTRAINT variates_pkey PRIMARY KEY (id);


--
-- Name: venue_types venue_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_types
    ADD CONSTRAINT venue_types_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: visualizations visualizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visualizations
    ADD CONSTRAINT visualizations_pkey PRIMARY KEY (id);


--
-- Name: websites websites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.websites
    ADD CONSTRAINT websites_pkey PRIMARY KEY (id);


--
-- Name: data_contributions_uniq_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX data_contributions_uniq_idx ON public.data_contributions USING btree (datatable_id, person_id, role_id);


--
-- Name: gas_chambers_index_2; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX gas_chambers_index_2 ON public.chambers USING btree (barcode DESC);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_affiliations_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliations_on_dataset_id ON public.affiliations USING btree (dataset_id);


--
-- Name: index_affiliations_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliations_on_person_id ON public.affiliations USING btree (person_id);


--
-- Name: index_affiliations_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_affiliations_on_role_id ON public.affiliations USING btree (role_id);


--
-- Name: index_authors_on_citation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_on_citation_id ON public.authors USING btree (citation_id);


--
-- Name: index_authors_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authors_on_person_id ON public.authors USING btree (person_id);


--
-- Name: index_citations_on_citation_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_citations_on_citation_type_id ON public.citations USING btree (citation_type_id);


--
-- Name: index_citations_on_website_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_citations_on_website_id ON public.citations USING btree (website_id);


--
-- Name: index_collections_on_datatable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_datatable_id ON public.collections USING btree (datatable_id);


--
-- Name: index_columns_on_datatable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_columns_on_datatable_id ON public.columns USING btree (datatable_id);


--
-- Name: index_columns_on_variate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_columns_on_variate_id ON public.columns USING btree (variate_id);


--
-- Name: index_datafiles_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datafiles_on_person_id ON public.datafiles USING btree (person_id);


--
-- Name: index_datasets_on_metacat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datasets_on_metacat_id ON public.datasets USING btree (metacat_id);


--
-- Name: index_datasets_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datasets_on_project_id ON public.datasets USING btree (project_id);


--
-- Name: index_datasets_on_sponsor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datasets_on_sponsor_id ON public.datasets USING btree (sponsor_id);


--
-- Name: index_datasets_on_website_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datasets_on_website_id ON public.datasets USING btree (website_id);


--
-- Name: index_datasets_studies_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datasets_studies_on_dataset_id ON public.datasets_studies USING btree (dataset_id);


--
-- Name: index_datasets_studies_on_study_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datasets_studies_on_study_id ON public.datasets_studies USING btree (study_id);


--
-- Name: index_datasets_themes_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datasets_themes_on_dataset_id ON public.datasets_themes USING btree (dataset_id);


--
-- Name: index_datasets_themes_on_theme_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datasets_themes_on_theme_id ON public.datasets_themes USING btree (theme_id);


--
-- Name: index_datatables_on_core_area_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datatables_on_core_area_id ON public.datatables USING btree (core_area_id);


--
-- Name: index_datatables_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datatables_on_dataset_id ON public.datatables USING btree (dataset_id);


--
-- Name: index_datatables_on_study_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datatables_on_study_id ON public.datatables USING btree (study_id);


--
-- Name: index_datatables_on_theme_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datatables_on_theme_id ON public.datatables USING btree (theme_id);


--
-- Name: index_datatables_protocols_on_datatable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datatables_protocols_on_datatable_id ON public.datatables_protocols USING btree (datatable_id);


--
-- Name: index_datatables_protocols_on_protocol_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datatables_protocols_on_protocol_id ON public.datatables_protocols USING btree (protocol_id);


--
-- Name: index_devise_invitations_on_invitable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_devise_invitations_on_invitable ON public.devise_invitations USING btree (invitable_type, invitable_id);


--
-- Name: index_devise_invitations_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_devise_invitations_on_invitation_token ON public.devise_invitations USING btree (invitation_token);


--
-- Name: index_devise_invitations_on_invited_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_devise_invitations_on_invited_by ON public.devise_invitations USING btree (invited_by_type, invited_by_id);


--
-- Name: index_devise_invitations_on_type_and_invite_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_devise_invitations_on_type_and_invite_key ON public.devise_invitations USING btree (invitable_type, invite_key_digest);


--
-- Name: index_enumerated_values_on_variate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enumerated_values_on_variate_id ON public.enumerated_values USING btree (variate_id);


--
-- Name: index_invites_on_id_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invites_on_id_and_email ON public.invites USING btree (id, email);


--
-- Name: index_invites_on_id_and_invite_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invites_on_id_and_invite_code ON public.invites USING btree (id, invite_code);


--
-- Name: index_meeting_abstracts_on_meeting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meeting_abstracts_on_meeting_id ON public.meeting_abstracts USING btree (meeting_id);


--
-- Name: index_meetings_on_venue_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_meetings_on_venue_type_id ON public.meetings USING btree (venue_type_id);


--
-- Name: index_ownerships_on_datatable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ownerships_on_datatable_id ON public.ownerships USING btree (datatable_id);


--
-- Name: index_ownerships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ownerships_on_user_id ON public.ownerships USING btree (user_id);


--
-- Name: index_page_images_on_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_images_on_page_id ON public.page_images USING btree (page_id);


--
-- Name: index_permission_requests_on_datatable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permission_requests_on_datatable_id ON public.permission_requests USING btree (datatable_id);


--
-- Name: index_permission_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permission_requests_on_user_id ON public.permission_requests USING btree (user_id);


--
-- Name: index_permissions_on_datatable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_datatable_id ON public.permissions USING btree (datatable_id);


--
-- Name: index_permissions_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_owner_id ON public.permissions USING btree (owner_id);


--
-- Name: index_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_user_id ON public.permissions USING btree (user_id);


--
-- Name: index_permissions_on_user_id_and_datatable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_user_id_and_datatable_id ON public.permissions USING btree (user_id, datatable_id);


--
-- Name: index_protocols_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_protocols_on_dataset_id ON public.protocols USING btree (dataset_id);


--
-- Name: index_protocols_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_protocols_on_person_id ON public.protocols USING btree (person_id);


--
-- Name: index_protocols_sponsors_on_protocol_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_protocols_sponsors_on_protocol_id ON public.protocols_sponsors USING btree (protocol_id);


--
-- Name: index_protocols_sponsors_on_sponsor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_protocols_sponsors_on_sponsor_id ON public.protocols_sponsors USING btree (sponsor_id);


--
-- Name: index_protocols_websites_on_protocol_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_protocols_websites_on_protocol_id ON public.protocols_websites USING btree (protocol_id);


--
-- Name: index_protocols_websites_on_website_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_protocols_websites_on_website_id ON public.protocols_websites USING btree (website_id);


--
-- Name: index_publications_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publications_on_parent_id ON public.publications USING btree (parent_id);


--
-- Name: index_publications_on_publication_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publications_on_publication_type_id ON public.publications USING btree (publication_type_id);


--
-- Name: index_publications_on_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publications_on_source_id ON public.publications USING btree (source_id);


--
-- Name: index_publications_treatments_on_publication_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publications_treatments_on_publication_id ON public.publications_treatments USING btree (publication_id);


--
-- Name: index_publications_treatments_on_treatment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publications_treatments_on_treatment_id ON public.publications_treatments USING btree (treatment_id);


--
-- Name: index_roles_on_role_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_role_type_id ON public.roles USING btree (role_type_id);


--
-- Name: index_scribbles_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scribbles_on_person_id ON public.scribbles USING btree (person_id);


--
-- Name: index_scribbles_on_protocol_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scribbles_on_protocol_id ON public.scribbles USING btree (protocol_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_session_id ON public.sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON public.sessions USING btree (updated_at);


--
-- Name: index_slugs_on_n_s_s_and_s; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_slugs_on_n_s_s_and_s ON public.slugs USING btree (name, sluggable_type, sequence, scope);


--
-- Name: index_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slugs_on_sluggable_id ON public.slugs USING btree (sluggable_id);


--
-- Name: index_solid_queue_batch_executions_on_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_batch_executions_on_batch_id ON public.solid_queue_batch_executions USING btree (batch_id);


--
-- Name: index_solid_queue_batch_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_batch_executions_on_job_id ON public.solid_queue_batch_executions USING btree (job_id);


--
-- Name: index_solid_queue_batches_on_active_job_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_batches_on_active_job_batch_id ON public.solid_queue_batches USING btree (active_job_batch_id);


--
-- Name: index_solid_queue_batches_on_finished_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_batches_on_finished_at ON public.solid_queue_batches USING btree (finished_at);


--
-- Name: index_solid_queue_blocked_executions_for_maintenance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_blocked_executions_for_maintenance ON public.solid_queue_blocked_executions USING btree (expires_at, concurrency_key);


--
-- Name: index_solid_queue_blocked_executions_for_release; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_blocked_executions_for_release ON public.solid_queue_blocked_executions USING btree (concurrency_key, priority, job_id);


--
-- Name: index_solid_queue_blocked_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_blocked_executions_on_job_id ON public.solid_queue_blocked_executions USING btree (job_id);


--
-- Name: index_solid_queue_claimed_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_claimed_executions_on_job_id ON public.solid_queue_claimed_executions USING btree (job_id);


--
-- Name: index_solid_queue_claimed_executions_on_process_id_and_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_claimed_executions_on_process_id_and_job_id ON public.solid_queue_claimed_executions USING btree (process_id, job_id);


--
-- Name: index_solid_queue_dispatch_all; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_dispatch_all ON public.solid_queue_scheduled_executions USING btree (scheduled_at, priority, job_id);


--
-- Name: index_solid_queue_failed_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_failed_executions_on_job_id ON public.solid_queue_failed_executions USING btree (job_id);


--
-- Name: index_solid_queue_jobs_for_alerting; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_jobs_for_alerting ON public.solid_queue_jobs USING btree (scheduled_at, finished_at);


--
-- Name: index_solid_queue_jobs_for_filtering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_jobs_for_filtering ON public.solid_queue_jobs USING btree (queue_name, finished_at);


--
-- Name: index_solid_queue_jobs_on_active_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_jobs_on_active_job_id ON public.solid_queue_jobs USING btree (active_job_id);


--
-- Name: index_solid_queue_jobs_on_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_jobs_on_batch_id ON public.solid_queue_jobs USING btree (batch_id);


--
-- Name: index_solid_queue_jobs_on_class_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_jobs_on_class_name ON public.solid_queue_jobs USING btree (class_name);


--
-- Name: index_solid_queue_jobs_on_finished_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_jobs_on_finished_at ON public.solid_queue_jobs USING btree (finished_at);


--
-- Name: index_solid_queue_pauses_on_queue_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_pauses_on_queue_name ON public.solid_queue_pauses USING btree (queue_name);


--
-- Name: index_solid_queue_poll_all; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_poll_all ON public.solid_queue_ready_executions USING btree (priority, job_id);


--
-- Name: index_solid_queue_poll_by_queue; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_poll_by_queue ON public.solid_queue_ready_executions USING btree (queue_name, priority, job_id);


--
-- Name: index_solid_queue_processes_on_last_heartbeat_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_processes_on_last_heartbeat_at ON public.solid_queue_processes USING btree (last_heartbeat_at);


--
-- Name: index_solid_queue_processes_on_name_and_supervisor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_processes_on_name_and_supervisor_id ON public.solid_queue_processes USING btree (name, supervisor_id);


--
-- Name: index_solid_queue_processes_on_supervisor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_processes_on_supervisor_id ON public.solid_queue_processes USING btree (supervisor_id);


--
-- Name: index_solid_queue_ready_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_ready_executions_on_job_id ON public.solid_queue_ready_executions USING btree (job_id);


--
-- Name: index_solid_queue_recurring_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_recurring_executions_on_job_id ON public.solid_queue_recurring_executions USING btree (job_id);


--
-- Name: index_solid_queue_recurring_executions_on_task_key_and_run_at; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_recurring_executions_on_task_key_and_run_at ON public.solid_queue_recurring_executions USING btree (task_key, run_at);


--
-- Name: index_solid_queue_recurring_tasks_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_recurring_tasks_on_key ON public.solid_queue_recurring_tasks USING btree (key);


--
-- Name: index_solid_queue_recurring_tasks_on_static; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_recurring_tasks_on_static ON public.solid_queue_recurring_tasks USING btree (static);


--
-- Name: index_solid_queue_scheduled_executions_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_scheduled_executions_on_job_id ON public.solid_queue_scheduled_executions USING btree (job_id);


--
-- Name: index_solid_queue_semaphores_on_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_semaphores_on_expires_at ON public.solid_queue_semaphores USING btree (expires_at);


--
-- Name: index_solid_queue_semaphores_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solid_queue_semaphores_on_key ON public.solid_queue_semaphores USING btree (key);


--
-- Name: index_solid_queue_semaphores_on_key_and_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_queue_semaphores_on_key_and_value ON public.solid_queue_semaphores USING btree (key, value);


--
-- Name: index_studies_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studies_on_parent_id ON public.studies USING btree (parent_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON public.taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_taggings_on_tagger_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tagger_id ON public.taggings USING btree (tagger_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_templates_on_website_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_templates_on_website_id ON public.templates USING btree (website_id);


--
-- Name: index_themes_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_themes_on_parent_id ON public.themes USING btree (parent_id);


--
-- Name: index_treatments_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_treatments_on_project_id ON public.treatments USING btree (project_id);


--
-- Name: index_treatments_on_study_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_treatments_on_study_id ON public.treatments USING btree (study_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_id_and_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_id_and_confirmation_token ON public.users USING btree (id, confirmation_token);


--
-- Name: index_users_on_identity_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_identity_url ON public.users USING btree (identity_url);


--
-- Name: index_users_on_remember_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_remember_token ON public.users USING btree (remember_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_variates_on_datatable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_variates_on_datatable_id ON public.variates USING btree (datatable_id);


--
-- Name: index_variates_on_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_variates_on_unit_id ON public.variates USING btree (unit_id);


--
-- Name: index_variates_on_variate_theme_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_variates_on_variate_theme_id ON public.variates USING btree (variate_theme_id);


--
-- Name: index_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_created_at ON public.versions USING btree (created_at);


--
-- Name: index_versions_on_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_number ON public.versions USING btree (number);


--
-- Name: index_versions_on_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_tag ON public.versions USING btree (tag);


--
-- Name: index_versions_on_user_id_and_user_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_user_id_and_user_type ON public.versions USING btree (user_id, user_type);


--
-- Name: index_versions_on_user_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_user_name ON public.versions USING btree (user_name);


--
-- Name: index_versions_on_versioned_id_and_versioned_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_versioned_id_and_versioned_type ON public.versions USING btree (versioned_id, versioned_type);


--
-- Name: oban_jobs_args_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_args_index ON public.oban_jobs USING gin (args);


--
-- Name: oban_jobs_meta_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_meta_index ON public.oban_jobs USING gin (meta);


--
-- Name: oban_jobs_state_queue_priority_scheduled_at_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_queue_priority_scheduled_at_id_index ON public.oban_jobs USING btree (state, queue, priority, scheduled_at, id);


--
-- Name: sidx_2_ed_lux_arbor_microplots_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sidx_2_ed_lux_arbor_microplots_geom ON public."2_ed_lux_arbor_microplots" USING gist (geom);


--
-- Name: sidx_LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a_; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "sidx_LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a_" ON public."LTAR_Standard_GIS_Layers_v2025 — ltar_experiment_bndy_a_v2025" USING gist (geom);


--
-- Name: spatial_farm_fields0_the_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX spatial_farm_fields0_the_geom ON public.farm_fields0 USING gist (the_geom);


--
-- Name: studies_code_uindex; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX studies_code_uindex ON public.studies USING btree (code);


--
-- Name: studies_index_4; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX studies_index_4 ON public.studies USING btree (name);


--
-- Name: taggings_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX taggings_idx ON public.taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);


--
-- Name: themes_name_parent_id_uindex; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX themes_name_parent_id_uindex ON public.themes USING btree (name, parent_id);


--
-- Name: treatments_lft_rgt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatments_lft_rgt_idx ON public.treatments USING btree (lft, rgt) WITH (deduplicate_items='true');


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: users_tokens_context_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_tokens_context_token_index ON public.users_tokens USING btree (context, token);


--
-- Name: users_tokens_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_tokens_user_id_index ON public.users_tokens USING btree (user_id);


--
-- Name: emeritus_investigator_and_students_email_list _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.emeritus_investigator_and_students_email_list AS
 SELECT people.id,
    people.email,
    people.given_name,
    people.sur_name,
    public.array_unique(array_agg(roles.name)) AS roles,
    people.organization,
    people.sub_organization,
    people.street_address,
    people.city,
    people.locale,
    people.country,
    people.postal_code,
    people.phone,
    people.fax
   FROM ((public.people
     JOIN public.affiliations ON ((affiliations.person_id = people.id)))
     JOIN public.roles ON ((roles.id = affiliations.role_id)))
  WHERE ((roles.role_type_id = 2) AND (affiliations.role_id = ANY (ARRAY[16, 17, 18])))
  GROUP BY people.id
  ORDER BY people.id;


--
-- Name: non_emeritus_email_list _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.non_emeritus_email_list AS
 SELECT people.id,
    people.email,
    people.given_name,
    people.sur_name,
    public.array_unique(array_agg(roles.name)) AS roles,
    people.organization,
    people.sub_organization,
    people.street_address,
    people.city,
    people.locale,
    people.country,
    people.postal_code,
    people.phone,
    people.fax
   FROM ((public.people
     JOIN public.affiliations ON ((affiliations.person_id = people.id)))
     JOIN public.roles ON ((roles.id = affiliations.role_id)))
  WHERE ((roles.role_type_id = 2) AND (affiliations.role_id = ANY (ARRAY[10, 11, 12, 13, 14, 15])))
  GROUP BY people.id
  ORDER BY people.id;


--
-- Name: affiliations affiliations_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliations
    ADD CONSTRAINT affiliations_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: affiliations affiliations_role_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.affiliations
    ADD CONSTRAINT affiliations_role_id_fkey1 FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: authors authors_citation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_citation_id_fk FOREIGN KEY (citation_id) REFERENCES public.citations(id);


--
-- Name: authors authors_citation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_citation_id_fkey FOREIGN KEY (citation_id) REFERENCES public.citations(id);


--
-- Name: citations_treatments citations_treatments_citation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citations_treatments
    ADD CONSTRAINT citations_treatments_citation_id_fkey FOREIGN KEY (citation_id) REFERENCES public.citations(id) NOT VALID;


--
-- Name: citations_treatments citations_treatments_treatment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.citations_treatments
    ADD CONSTRAINT citations_treatments_treatment_id_fkey FOREIGN KEY (treatment_id) REFERENCES public.treatments(id) NOT VALID;


--
-- Name: data_contributions data_contributions_datatable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_contributions
    ADD CONSTRAINT data_contributions_datatable_id_fkey FOREIGN KEY (datatable_id) REFERENCES public.datatables(id) NOT VALID;


--
-- Name: data_contributions data_contributions_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_contributions
    ADD CONSTRAINT data_contributions_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.people(id) NOT VALID;


--
-- Name: data_contributions data_contributions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_contributions
    ADD CONSTRAINT data_contributions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) NOT VALID;


--
-- Name: dataset_dois dataset_dois_datasets_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset_dois
    ADD CONSTRAINT dataset_dois_datasets_id_fk FOREIGN KEY (dataset_id) REFERENCES public.datasets(id);


--
-- Name: datasets datasets_projects_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datasets
    ADD CONSTRAINT datasets_projects_id_fk FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: datasets datasets_website_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datasets
    ADD CONSTRAINT datasets_website_id_fkey FOREIGN KEY (website_id) REFERENCES public.websites(id) NOT VALID;


--
-- Name: datatables datatables_dataset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatables
    ADD CONSTRAINT datatables_dataset_id_fkey FOREIGN KEY (dataset_id) REFERENCES public.datasets(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: datatables_dois datatables_dois_datatable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatables_dois
    ADD CONSTRAINT datatables_dois_datatable_id_fkey FOREIGN KEY (datatable_id) REFERENCES public.datatables(id) NOT VALID;


--
-- Name: datatables datatables_study_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatables
    ADD CONSTRAINT datatables_study_id_fkey FOREIGN KEY (study_id) REFERENCES public.studies(id) NOT VALID;


--
-- Name: datatables datatables_theme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datatables
    ADD CONSTRAINT datatables_theme_id_fkey FOREIGN KEY (theme_id) REFERENCES public.themes(id) NOT VALID;


--
-- Name: editors editors_citation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.editors
    ADD CONSTRAINT editors_citation_id_fk FOREIGN KEY (citation_id) REFERENCES public.citations(id);


--
-- Name: editors editors_citation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.editors
    ADD CONSTRAINT editors_citation_id_fkey FOREIGN KEY (citation_id) REFERENCES public.citations(id);


--
-- Name: permission_requests fk_rails_1378971e13; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_requests
    ADD CONSTRAINT fk_rails_1378971e13 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: permission_requests fk_rails_16c54e3f88; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_requests
    ADD CONSTRAINT fk_rails_16c54e3f88 FOREIGN KEY (datatable_id) REFERENCES public.datatables(id) ON DELETE CASCADE;


--
-- Name: permissions fk_rails_2c935ad5c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT fk_rails_2c935ad5c0 FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: solid_queue_recurring_executions fk_rails_318a5533ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_recurring_executions
    ADD CONSTRAINT fk_rails_318a5533ed FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: solid_queue_failed_executions fk_rails_39bbc7a631; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_failed_executions
    ADD CONSTRAINT fk_rails_39bbc7a631 FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: solid_queue_blocked_executions fk_rails_4cd34e2228; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_blocked_executions
    ADD CONSTRAINT fk_rails_4cd34e2228 FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: solid_queue_batch_executions fk_rails_7c5e073422; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_batch_executions
    ADD CONSTRAINT fk_rails_7c5e073422 FOREIGN KEY (batch_id) REFERENCES public.solid_queue_batches(id) ON DELETE CASCADE;


--
-- Name: solid_queue_ready_executions fk_rails_81fcbd66af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_ready_executions
    ADD CONSTRAINT fk_rails_81fcbd66af FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: treatments fk_rails_8bc3744aed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatments
    ADD CONSTRAINT fk_rails_8bc3744aed FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: solid_queue_claimed_executions fk_rails_9cfe4d4944; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_claimed_executions
    ADD CONSTRAINT fk_rails_9cfe4d4944 FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: solid_queue_batch_executions fk_rails_bc9f981155; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_batch_executions
    ADD CONSTRAINT fk_rails_bc9f981155 FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: solid_queue_scheduled_executions fk_rails_c4316f352d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_queue_scheduled_executions
    ADD CONSTRAINT fk_rails_c4316f352d FOREIGN KEY (job_id) REFERENCES public.solid_queue_jobs(id) ON DELETE CASCADE;


--
-- Name: permissions fk_rails_c62eaf1308; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT fk_rails_c62eaf1308 FOREIGN KEY (datatable_id) REFERENCES public.datatables(id) ON DELETE CASCADE;


--
-- Name: permissions fk_rails_d9cfa3c257; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT fk_rails_d9cfa3c257 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: memberships memberships_sponsor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_sponsor_id_fkey FOREIGN KEY (sponsor_id) REFERENCES public.sponsors(id) NOT VALID;


--
-- Name: memberships memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE NOT VALID;


--
-- Name: ownerships ownerships_datatable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ownerships
    ADD CONSTRAINT ownerships_datatable_id_fkey FOREIGN KEY (datatable_id) REFERENCES public.datatables(id) NOT VALID;


--
-- Name: ownerships ownerships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ownerships
    ADD CONSTRAINT ownerships_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;


--
-- Name: roles roles_role_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_type_id_fkey FOREIGN KEY (role_type_id) REFERENCES public.role_types(id) NOT VALID;


--
-- Name: datasets sponsorsdatasets___fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datasets
    ADD CONSTRAINT sponsorsdatasets___fk FOREIGN KEY (sponsor_id) REFERENCES public.sponsors(id);


--
-- Name: studies studies_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studies
    ADD CONSTRAINT studies_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.studies(id) NOT VALID;


--
-- Name: themes themes_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.themes
    ADD CONSTRAINT themes_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.themes(id) NOT VALID;


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: variates variates_datatable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variates
    ADD CONSTRAINT variates_datatable_id_fkey FOREIGN KEY (datatable_id) REFERENCES public.datatables(id);


--
-- Name: variates variates_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variates
    ADD CONSTRAINT variates_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public, topology;

INSERT INTO "schema_migrations" (version) VALUES
(NULL),
('9'),
('8'),
('7'),
('6'),
('5'),
('40'),
('4'),
('39'),
('38'),
('37'),
('36'),
('34'),
('33'),
('32'),
('30'),
('3'),
('29'),
('28'),
('27'),
('26'),
('25'),
('24'),
('23'),
('22'),
('21'),
('20261101000000'),
('20261030000001'),
('20261030000000'),
('20261029000001'),
('20261029000000'),
('20261027000000'),
('20261025130000'),
('20261025120000'),
('20260304180000'),
('20250327123702'),
('20250326210809'),
('20240618131120'),
('20240112172554'),
('20221212152450'),
('20211208002722'),
('20210923164448'),
('20210923164447'),
('20201002151050'),
('20200916194216'),
('20200506173812'),
('20200506165912'),
('20200505181700'),
('20200505181122'),
('20191031205417'),
('2019100910519'),
('20190709144757'),
('20190619231959'),
('20180123093046'),
('20170404144127'),
('20170404141748'),
('20170301190117'),
('20160916154054'),
('20160816220121'),
('20151204212403'),
('20151129234644'),
('20151119164655'),
('20151106193053'),
('20151104175424'),
('20151104175423'),
('20151104175422'),
('20151104175421'),
('20150930224832'),
('20150924005714'),
('20150918163623'),
('20150617005803'),
('20150611164752'),
('20150423171537'),
('20150423142030'),
('20150422193942'),
('20150112164039'),
('20140206152903'),
('20131213162905'),
('20131205151150'),
('20130516232103'),
('20130516231618'),
('20130423132337'),
('20130419193128'),
('20130328142628'),
('20130322204214'),
('20130322194847'),
('20130322164703'),
('20130322124353'),
('20121210165342'),
('20120905200040'),
('20111007134839'),
('20110830122320'),
('20110713195943'),
('20110628041235'),
('20110627142731'),
('20110624133951'),
('20110623191510'),
('20110622202236'),
('20110616222204'),
('20110610165828'),
('20110527143940'),
('20110526202454'),
('20110524012030'),
('20110419142830'),
('20110418185339'),
('20110412140726'),
('20110310133802'),
('20110222164316'),
('20110221191724'),
('20110126223229'),
('20110125220122'),
('20110107144139'),
('20110105030350'),
('20100929130709'),
('20100925124905'),
('20100923123838'),
('20100922122806'),
('20100922120735'),
('20100921002508'),
('20100920180136'),
('20100920173545'),
('20100920171638'),
('20100917125414'),
('20100915140148'),
('20100913181251'),
('20100913181150'),
('20100829033625'),
('20100829031613'),
('20100827221259'),
('20100827133514'),
('20100826133415'),
('20100825181536'),
('20100825152246'),
('20100824133608'),
('20100823151410'),
('20100819190303'),
('20100819190128'),
('20100819185609'),
('20100812131935'),
('20100811131632'),
('20100719124908'),
('20100719021435'),
('20100701150102'),
('20100701135327'),
('20100630163503'),
('20100630152706'),
('20100630133605'),
('20100618120203'),
('20100617135237'),
('20100617135236'),
('20100617125810'),
('20100611152400'),
('20100610180033'),
('20100610140540'),
('20100603185306'),
('20100428160039'),
('20100426124331'),
('20100422140202'),
('20100421190055'),
('20100414132157'),
('20100308223149'),
('20100304164208'),
('20100303123318'),
('20100216183217'),
('20100216182425'),
('20100216144410'),
('20100210141959'),
('20100204163035'),
('20100204160939'),
('20100204160730'),
('20100203163100'),
('20100201141347'),
('20100130030415'),
('20100127131313'),
('20100112202031'),
('20100111173650'),
('20100106171849'),
('20091218222157'),
('20091210174724'),
('20091110032539'),
('20090916124443'),
('20090402123303'),
('20090226150345'),
('20081025184324'),
('20081014142555'),
('20081007181620'),
('20080820172515'),
('20080729153355'),
('20'),
('2'),
('19'),
('18'),
('17'),
('16'),
('15'),
('14'),
('13'),
('12'),
('11'),
('10'),
('1');
