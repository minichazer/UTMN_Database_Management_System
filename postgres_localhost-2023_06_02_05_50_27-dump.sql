--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: main_schema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA main_schema;


ALTER SCHEMA main_schema OWNER TO postgres;

--
-- Name: count_medicine_alltime(); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.count_medicine_alltime() RETURNS TABLE(medicine_id text, medicine_name text, cost double precision)
    LANGUAGE plpgsql
    AS $$
    begin
        RETURN QUERY
            SELECT t."medicine_ID", t.name, t.count * t.cost 
            FROM (
                SELECT VM."medicine_ID", M.name as name, count(*) as count, M.cost as cost
                FROM "Visit_Medicine" as VM
                JOIN "Medicine" as M
                ON VM."medicine_ID" LIKE M."medicine_ID"
                GROUP BY 1, 2, 4) t;
    end;
$$;


ALTER FUNCTION main_schema.count_medicine_alltime() OWNER TO postgres;

--
-- Name: create_patient(text, text, text, text, text, text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.create_patient(_patient_id text, _first_name text, _second_name text, _patronymic text, _home_address text, _phone_number text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    begin
        INSERT INTO "Patient"("patient_ID", first_name, second_name, patronymic, home_address, phone_number)
        VALUES (_patient_ID, _first_name, _second_name, _patronymic, _home_address, _phone_number);
    end;
$$;


ALTER FUNCTION main_schema.create_patient(_patient_id text, _first_name text, _second_name text, _patronymic text, _home_address text, _phone_number text) OWNER TO postgres;

--
-- Name: create_specialist(text, text, text, text, text, text, text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.create_specialist(_specialist_id text, _first_name text, _second_name text, _patronymic text, _speciality text, _home_address text, _phone_number text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    begin
        INSERT INTO "Specialist"("specialist_ID", first_name, second_name, patronymic, speciality, home_address, phone_number)
        VALUES (_specialist_id, _first_name, _second_name, _patronymic, _speciality, _home_address, _phone_number);
    end;
$$;


ALTER FUNCTION main_schema.create_specialist(_specialist_id text, _first_name text, _second_name text, _patronymic text, _speciality text, _home_address text, _phone_number text) OWNER TO postgres;

--
-- Name: create_visit(text, text, boolean, text, text, text, text, text, double precision, double precision); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.create_visit(_patient_id text, _specialist_id text, _is_first boolean, _visit_id text, _date text, _anamnesis text, _diagnosis text, _treatment text, _drugs_cost double precision, _services_cost double precision) RETURNS void
    LANGUAGE plpgsql
    AS $$
    begin
        INSERT INTO "Visit"("patient_ID", "specialist_ID", is_first, "visit_ID", date, anamnesis, diagnosis, treatment, drugs_cost, services_cost)
        VALUES (_patient_ID, _specialist_ID, _is_first, _visit_ID, _date, _anamnesis, _diagnosis, _treatment, _drugs_cost, _services_cost);
    end;
$$;


ALTER FUNCTION main_schema.create_visit(_patient_id text, _specialist_id text, _is_first boolean, _visit_id text, _date text, _anamnesis text, _diagnosis text, _treatment text, _drugs_cost double precision, _services_cost double precision) OWNER TO postgres;

--
-- Name: delete_patient(text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.delete_patient(_patient_id text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    begin
        DELETE FROM "Patient"
        WHERE "patient_ID" LIKE _patient_ID;
    end;
$$;


ALTER FUNCTION main_schema.delete_patient(_patient_id text) OWNER TO postgres;

--
-- Name: delete_specialist(text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.delete_specialist(_specialist_id text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    begin
        DELETE FROM "Specialist"
        WHERE "specialist_ID" LIKE _specialist_ID;
    end;
$$;


ALTER FUNCTION main_schema.delete_specialist(_specialist_id text) OWNER TO postgres;

--
-- Name: delete_visit(text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.delete_visit(_visit_id text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    begin
        DELETE FROM "Visit"
        WHERE "visit_ID" LIKE _visit_ID;
    end;
$$;


ALTER FUNCTION main_schema.delete_visit(_visit_id text) OWNER TO postgres;

--
-- Name: do_trigger_job(); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.do_trigger_job() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    declare
        _visit_id text;
        cost double precision;
    begin
        _visit_id = get_last_visit();
        cost = get_sum_of_all_medicines(_visit_id);
        PERFORM update_visit_drugs_cost(_visit_id, cost);
        RAISE NOTICE 'visit_id: %, new_cost: %', _visit_id, cost;
        RETURN NEW;
    end;
$$;


ALTER FUNCTION main_schema.do_trigger_job() OWNER TO postgres;

--
-- Name: get_all_medicines_by_visit(text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.get_all_medicines_by_visit(_visit_id text) RETURNS TABLE(visit_id text, medicine_id text)
    LANGUAGE plpgsql
    AS $$
    begin
        RETURN QUERY
        SELECT *
        FROM "Visit_Medicine"
        WHERE "visit_ID" LIKE _visit_ID;
    end;
$$;


ALTER FUNCTION main_schema.get_all_medicines_by_visit(_visit_id text) OWNER TO postgres;

--
-- Name: get_entries_num(); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.get_entries_num() RETURNS TABLE(result bigint)
    LANGUAGE plpgsql
    AS $$
    begin
        RETURN QUERY
        SELECT count(*) AS pn FROM "Patient"
        UNION ALL
        SELECT count(*) AS sn FROM "Specialist"
        UNION ALL
        SELECT count(*) AS vn FROM "Visit"
        UNION ALL
        SELECT count(*) AS vmn FROM "Visit_Medicine";
    end;
$$;


ALTER FUNCTION main_schema.get_entries_num() OWNER TO postgres;

--
-- Name: get_income(); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.get_income() RETURNS TABLE(income double precision)
    LANGUAGE plpgsql
    AS $$
    begin
        RETURN QUERY
        SELECT sum(services_cost) as total_income FROM "Visit";
    end;
$$;


ALTER FUNCTION main_schema.get_income() OWNER TO postgres;

--
-- Name: get_last_visit(); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.get_last_visit() RETURNS TABLE(last_modified_id text)
    LANGUAGE plpgsql
    AS $$
    begin
        RETURN QUERY
        SELECT "visit_ID"
        FROM "Visit"
        ORDER BY date DESC
        LIMIT 1;
    end;
$$;


ALTER FUNCTION main_schema.get_last_visit() OWNER TO postgres;

--
-- Name: get_sum_of_all_medicines(text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.get_sum_of_all_medicines(_visit_id text) RETURNS TABLE(total_medicines_cost double precision)
    LANGUAGE plpgsql
    AS $$
    begin
        RETURN QUERY
        SELECT sum(M.cost)
        FROM "Visit_Medicine" AS VM
        JOIN "Medicine" AS M
        ON VM."medicine_ID" = M."medicine_ID"
        WHERE "visit_ID" = _visit_id;
    end;
$$;


ALTER FUNCTION main_schema.get_sum_of_all_medicines(_visit_id text) OWNER TO postgres;

--
-- Name: random_between(integer, integer); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.random_between(low integer, high integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    begin
        RETURN floor(random()* (high-low + 1) + low);
    end;
$$;


ALTER FUNCTION main_schema.random_between(low integer, high integer) OWNER TO postgres;

--
-- Name: select_patient(text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.select_patient(_patient_id text) RETURNS TABLE(patient_id text, first_name text, second_name text, patronymic text, home_address text, phone_number text)
    LANGUAGE plpgsql
    AS $$
    begin
        RETURN QUERY
        SELECT * FROM "Patient"
        WHERE "patient_ID" LIKE _patient_ID;
    end;
$$;


ALTER FUNCTION main_schema.select_patient(_patient_id text) OWNER TO postgres;

--
-- Name: select_specialist(text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.select_specialist(_specialist_id text) RETURNS TABLE(specialist_id text, first_name text, second_name text, patronymic text, speciality text, home_address text, phone_number text)
    LANGUAGE plpgsql
    AS $$
    begin
        RETURN QUERY
        SELECT * FROM "Specialist"
        WHERE "specialist_ID" LIKE _specialist_ID;
    end;
$$;


ALTER FUNCTION main_schema.select_specialist(_specialist_id text) OWNER TO postgres;

--
-- Name: select_visit(text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.select_visit(_visit_id text) RETURNS TABLE(patient_id text, specialist_id text, is_first boolean, visit_id text, date text, anamnesis text, diagnosis text, treatment text, drugs_cost double precision, services_cost double precision)
    LANGUAGE plpgsql
    AS $$
    begin
        RETURN QUERY
        SELECT * FROM "Visit"
        WHERE "visit_ID" LIKE _visit_ID;
    end;
$$;


ALTER FUNCTION main_schema.select_visit(_visit_id text) OWNER TO postgres;

--
-- Name: test(); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.test() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO main_schema."Patient"("patient_ID", first_name, second_name, patronymic, home_address, phone_number)
    VALUES (gen_random_uuid(), 'AMONGUS', 'FAMILIYA_AMONGUS', 'AMONGUSOVICH', 'kukuevo', 'krutoy');
    RETURN NEW;
END;
$$;


ALTER FUNCTION main_schema.test() OWNER TO postgres;

--
-- Name: update_patient(text, text, text, text, text, text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.update_patient(_patient_id text, _first_name text, _second_name text, _patronymic text, _home_address text, _phone_number text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    begin
        UPDATE "Patient"
        SET "patient_ID" = _patient_id, first_name = _first_name, second_name = _second_name, patronymic = _patronymic, home_address = _home_address, phone_number = _phone_number
        WHERE "patient_ID" LIKE _patient_ID;
    end;
$$;


ALTER FUNCTION main_schema.update_patient(_patient_id text, _first_name text, _second_name text, _patronymic text, _home_address text, _phone_number text) OWNER TO postgres;

--
-- Name: update_specialist(text, text, text, text, text, text, text); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.update_specialist(_specialist_id text, _first_name text, _second_name text, _patronymic text, _speciality text, _home_address text, _phone_number text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    begin
        UPDATE "Specialist"
        SET "specialist_ID" = _specialist_ID, first_name = _first_name, second_name = _second_name, patronymic = _patronymic, speciality = _speciality, home_address = _home_address, phone_number = _phone_number
        WHERE "specialist_ID" LIKE _specialist_ID;
    end;
$$;


ALTER FUNCTION main_schema.update_specialist(_specialist_id text, _first_name text, _second_name text, _patronymic text, _speciality text, _home_address text, _phone_number text) OWNER TO postgres;

--
-- Name: update_visit(text, text, boolean, text, text, text, text, text, double precision, double precision); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.update_visit(_patient_id text, _specialist_id text, _is_first boolean, _visit_id text, _date text, _anamnesis text, _diagnosis text, _treatment text, _drugs_cost double precision, _services_cost double precision) RETURNS void
    LANGUAGE plpgsql
    AS $$
    begin
        UPDATE "Visit"
        SET "patient_ID" = _patient_id, 
            "specialist_ID" = _specialist_id, 
            is_first = _is_first, 
            "visit_ID" = _visit_id, 
            date = _date, 
            anamnesis = _anamnesis, 
            diagnosis = _diagnosis, 
            drugs_cost = _drugs_cost, 
            services_cost = _services_cost
        WHERE "visit_ID" LIKE _visit_id;
    end;
$$;


ALTER FUNCTION main_schema.update_visit(_patient_id text, _specialist_id text, _is_first boolean, _visit_id text, _date text, _anamnesis text, _diagnosis text, _treatment text, _drugs_cost double precision, _services_cost double precision) OWNER TO postgres;

--
-- Name: update_visit_drugs_cost(text, double precision); Type: FUNCTION; Schema: main_schema; Owner: postgres
--

CREATE FUNCTION main_schema.update_visit_drugs_cost(_visit_id text, _cost double precision) RETURNS void
    LANGUAGE plpgsql
    AS $$
    begin
        UPDATE "Visit"
        SET drugs_cost = _cost
        WHERE "visit_ID" LIKE _visit_id;
    end;
$$;


ALTER FUNCTION main_schema.update_visit_drugs_cost(_visit_id text, _cost double precision) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Medicine; Type: TABLE; Schema: main_schema; Owner: postgres
--

CREATE TABLE main_schema."Medicine" (
    "medicine_ID" text NOT NULL,
    name text NOT NULL,
    cost double precision
);


ALTER TABLE main_schema."Medicine" OWNER TO postgres;

--
-- Name: Patient; Type: TABLE; Schema: main_schema; Owner: postgres
--

CREATE TABLE main_schema."Patient" (
    "patient_ID" text NOT NULL,
    first_name text NOT NULL,
    second_name text NOT NULL,
    patronymic text,
    home_address text,
    phone_number text NOT NULL
);


ALTER TABLE main_schema."Patient" OWNER TO postgres;

--
-- Name: Specialist; Type: TABLE; Schema: main_schema; Owner: postgres
--

CREATE TABLE main_schema."Specialist" (
    "specialist_ID" text NOT NULL,
    first_name text NOT NULL,
    second_name text NOT NULL,
    patronymic text,
    speciality text NOT NULL,
    home_address text,
    phone_number text NOT NULL
);


ALTER TABLE main_schema."Specialist" OWNER TO postgres;

--
-- Name: Visit; Type: TABLE; Schema: main_schema; Owner: postgres
--

CREATE TABLE main_schema."Visit" (
    "patient_ID" text NOT NULL,
    "specialist_ID" text NOT NULL,
    is_first boolean NOT NULL,
    "visit_ID" text NOT NULL,
    date timestamp with time zone NOT NULL,
    anamnesis text,
    diagnosis text NOT NULL,
    treatment text,
    drugs_cost double precision,
    services_cost double precision NOT NULL
);


ALTER TABLE main_schema."Visit" OWNER TO postgres;

--
-- Name: Visit_Medicine; Type: TABLE; Schema: main_schema; Owner: postgres
--

CREATE TABLE main_schema."Visit_Medicine" (
    "visit_ID" text NOT NULL,
    "medicine_ID" text NOT NULL
);


ALTER TABLE main_schema."Visit_Medicine" OWNER TO postgres;

--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_group ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_group_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_permission ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


ALTER TABLE public.auth_user OWNER TO postgres;

--
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user_groups (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.auth_user_groups OWNER TO postgres;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_user_groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user_user_permissions (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_permissions OWNER TO postgres;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auth_user_user_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: clinicapp_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clinicapp_user (
    id bigint NOT NULL,
    username character varying(255) NOT NULL,
    password character varying(255) NOT NULL
);


ALTER TABLE public.clinicapp_user OWNER TO postgres;

--
-- Name: clinicapp_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.clinicapp_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.clinicapp_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.django_admin_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.django_content_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO postgres;

--
-- Data for Name: Medicine; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Medicine" ("medicine_ID", name, cost) FROM stdin;
M-132752-553	Мирамистин-99	1300
M-132752-566	Кагоцел-40	439
M-132752-573	Мирамистин-81	1470
M-132752-589	Нурофен-70	109
M-132752-605	Цитрамон-77	712
M-132779-983	Нурофен-67	1331
M-132779-993	Мирамистин-54	577
M-132780-008	Мирамистин-12	1306
M-132780-024	Мирамистин-73	432
M-132780-040	Кагоцел-47	939
M-557471-699	Мирамистин-75	1218
\.


--
-- Data for Name: Patient; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Patient" ("patient_ID", first_name, second_name, patronymic, home_address, phone_number) FROM stdin;
P-490680-422	Олежа	Олежкин	Абобусович	ул. Газовиков, д. 55, кв. 100	+79096530670
P-490680-523	Петька	Ванькин	Кринжевич	ул. Революции, д. 36, кв. 77	+79035766352
P-490680-564	Антошка	Ванькин	Абобусович	ул. Ленина, д. 3, кв. 25	+79884027886
P-490680-619	Петька	Ванькин	Амогусович	ул. Полевая, д. 92, кв. 51	+79688568961
P-490680-674	Ванёк	Ванькин	Абобусович	ул. Революции, д. 26, кв. 35	+79959720334
P-490680-718	Антошка	Олежкин	Абобусович	ул. Полевая, д. 3, кв. 76	+79536827562
P-490680-773	Антошка	Ванькин	Абобусович	ул. Широтная, д. 83, кв. 2	+79551830409
P-490680-816	Ванёк	Петькин	Амогусович	ул. Мельникайте, д. 39, кв. 11	+79338663832
P-490680-867	Ванёк	Антошкин	Амогусович	ул. Республики, д. 27, кв. 3	+79911445688
P-490680-907	Антошка	Олежкин	Абобусович	ул. Широтная, д. 60, кв. 100	+79022338733
P-490680-957	Олежа	Ванькин	Абобусович	ул. Ю-Р.Г. Эрвье, д. 47, кв. 5	+79815750990
P-490681-008	Антошка	Олежкин	Амогусович	ул. Широтная, д. 77, кв. 91	+79392452162
P-490681-050	Ванёк	Ванькин	Абобусович	ул. Ленина, д. 27, кв. 33	+79861753863
P-490681-103	Петька	Петькин	Амогусович	ул. Перекопская, д. 62, кв. 48	+79365233226
P-490681-165	Антошка	Антошкин	Амогусович	ул. Ленина, д. 20, кв. 65	+79608867405
P-490681-207	Петька	Олежкин	Амогусович	ул. Ю-Р.Г. Эрвье, д. 81, кв. 99	+79121249374
P-490681-259	Олежа	Антошкин	Амогусович	ул. Газовиков, д. 95, кв. 80	+79585910890
P-490681-316	Антошка	Антошкин	Абобусович	ул. Революции, д. 92, кв. 67	+79548955144
P-490681-363	Петька	Ванькин	Кринжевич	ул. Мельникайте, д. 28, кв. 61	+79160939405
P-490681-406	Ванёк	Олежкин	Абобусович	ул. Перекопская, д. 52, кв. 18	+79560898011
P-490681-456	Ванёк	Антошкин	Абобусович	ул. Газовиков, д. 27, кв. 100	+79714933589
P-490681-505	Олежа	Антошкин	Абобусович	ул. Ю-Р.Г. Эрвье, д. 32, кв. 55	+79542090942
P-490681-552	Олежа	Петькин	Абобусович	ул. Республики, д. 87, кв. 18	+79368742086
P-490681-597	Олежа	Олежкин	Амогусович	ул. Газовиков, д. 5, кв. 16	+79563390054
P-490681-651	Петька	Петькин	Кринжевич	ул. Широтная, д. 85, кв. 89	+79703429831
P-490681-707	Петька	Антошкин	Абобусович	ул. Газовиков, д. 92, кв. 23	+79751518643
P-490681-757	Олежа	Петькин	Амогусович	ул. Ю-Р.Г. Эрвье, д. 77, кв. 49	+79664121842
P-490681-814	Олежа	Антошкин	Амогусович	ул. Революции, д. 93, кв. 79	+79494800177
P-490681-874	Петька	Олежкин	Амогусович	ул. Широтная, д. 66, кв. 96	+79492669292
P-490681-932	Олежа	Олежкин	Кринжевич	ул. Широтная, д. 47, кв. 71	+79025892626
P-490681-992	Антошка	Ванькин	Кринжевич	ул. Перекопская, д. 95, кв. 29	+79014860902
P-490682-036	Ванёк	Петькин	Амогусович	ул. Газовиков, д. 31, кв. 88	+79011154371
P-490682-082	Петька	Петькин	Кринжевич	ул. Полевая, д. 47, кв. 27	+79884255264
P-490682-128	Олежа	Олежкин	Амогусович	ул. Газовиков, д. 14, кв. 28	+79623376425
P-490682-177	Ванёк	Петькин	Амогусович	ул. Первомайская, д. 27, кв. 2	+79792367162
P-490682-225	Ванёк	Ванькин	Кринжевич	ул. Революции, д. 3, кв. 3	+79279437288
P-490682-275	Ванёк	Олежкин	Абобусович	ул. Тихий проезд, д. 6, кв. 55	+79922502990
P-490682-326	Олежа	Ванькин	Абобусович	ул. Революции, д. 42, кв. 18	+79940655143
P-490682-385	Петька	Ванькин	Амогусович	ул. Широтная, д. 53, кв. 14	+79345610282
P-490682-443	Олежа	Ванькин	Кринжевич	ул. Ленина, д. 42, кв. 65	+79797975647
P-490682-488	Ванёк	Ванькин	Амогусович	ул. Широтная, д. 87, кв. 99	+79767398751
P-490682-536	Петька	Олежкин	Абобусович	ул. Газовиков, д. 5, кв. 30	+79582623107
P-490682-587	Ванёк	Ванькин	Амогусович	ул. Ленина, д. 34, кв. 52	+79576585782
P-490682-644	Антошка	Антошкин	Кринжевич	ул. Широтная, д. 52, кв. 90	+79498932588
P-490682-686	Олежа	Петькин	Абобусович	ул. Перекопская, д. 47, кв. 4	+79072105605
P-490682-740	Ванёк	Олежкин	Абобусович	ул. Мельникайте, д. 100, кв. 3	+79459824450
P-490682-798	Петька	Олежкин	Абобусович	ул. Ленина, д. 89, кв. 73	+79430476791
P-490682-841	Олежа	Петькин	Амогусович	ул. Республики, д. 15, кв. 68	+79074068098
P-490682-896	Ванёк	Петькин	Амогусович	ул. Ю-Р.Г. Эрвье, д. 10, кв. 50	+79615106329
P-490682-959	Ванёк	Ванькин	Кринжевич	ул. Газовиков, д. 98, кв. 3	+79980533245
P-490683-020	Петька	Антошкин	Кринжевич	ул. Ленина, д. 88, кв. 11	+79404559135
P-490683-075	Антошка	Антошкин	Кринжевич	ул. Тихий проезд, д. 30, кв. 55	+79762197420
P-490683-130	Петька	Петькин	Амогусович	ул. Революции, д. 4, кв. 43	+79882767001
P-490683-184	Петька	Ванькин	Кринжевич	ул. Полевая, д. 91, кв. 4	+79019873805
P-490683-235	Петька	Олежкин	Кринжевич	ул. Газовиков, д. 1, кв. 62	+79102117471
P-490683-283	Антошка	Олежкин	Амогусович	ул. Революции, д. 16, кв. 15	+79793784488
P-490683-337	Олежа	Петькин	Абобусович	ул. Республики, д. 94, кв. 3	+79904599204
P-490683-385	Ванёк	Олежкин	Абобусович	ул. Перекопская, д. 52, кв. 76	+79111238655
P-490683-433	Антошка	Олежкин	Амогусович	ул. Республики, д. 71, кв. 73	+79024127102
P-490683-480	Антошка	Петькин	Кринжевич	ул. Полевая, д. 20, кв. 91	+79039965394
P-490683-525	Олежа	Олежкин	Кринжевич	ул. Первомайская, д. 61, кв. 14	+79075637708
P-490683-574	Олежа	Олежкин	Амогусович	ул. Перекопская, д. 15, кв. 96	+79926787163
P-490683-616	Антошка	Олежкин	Кринжевич	ул. Широтная, д. 46, кв. 93	+79375909064
P-490683-670	Олежа	Ванькин	Амогусович	ул. Республики, д. 27, кв. 95	+79404068367
P-490683-718	Антошка	Ванькин	Абобусович	ул. Перекопская, д. 8, кв. 6	+79864875066
P-490683-764	Ванёк	Антошкин	Абобусович	ул. Первомайская, д. 11, кв. 29	+79249116872
P-490683-810	Петька	Олежкин	Кринжевич	ул. Республики, д. 66, кв. 12	+79626630575
P-490683-856	Антошка	Антошкин	Абобусович	ул. Ю-Р.Г. Эрвье, д. 22, кв. 88	+79799680879
P-490683-908	Петька	Олежкин	Абобусович	ул. Мельникайте, д. 88, кв. 94	+79394156994
P-490683-965	Петька	Антошкин	Абобусович	ул. Ленина, д. 26, кв. 1	+79028324109
P-490684-012	Петька	Петькин	Кринжевич	ул. Тихий проезд, д. 50, кв. 67	+79066855589
P-490684-058	Ванёк	Олежкин	Амогусович	ул. Первомайская, д. 95, кв. 16	+79208382487
P-490684-105	Олежа	Петькин	Абобусович	ул. Ю-Р.Г. Эрвье, д. 19, кв. 65	+79302128004
P-490684-151	Антошка	Ванькин	Абобусович	ул. Мельникайте, д. 52, кв. 17	+79749547650
P-490684-199	Ванёк	Антошкин	Амогусович	ул. Ленина, д. 10, кв. 66	+79681585262
P-490684-249	Олежа	Петькин	Амогусович	ул. Первомайская, д. 58, кв. 23	+79162869545
P-490684-302	Олежа	Ванькин	Абобусович	ул. Республики, д. 47, кв. 19	+79295048603
P-490684-350	Антошка	Ванькин	Кринжевич	ул. Полевая, д. 43, кв. 22	+79358313671
P-490684-394	Антошка	Ванькин	Кринжевич	ул. Широтная, д. 74, кв. 63	+79162771381
P-490684-448	Олежа	Олежкин	Амогусович	ул. Мельникайте, д. 8, кв. 67	+79781977755
P-490684-489	Антошка	Петькин	Кринжевич	ул. Ю-Р.Г. Эрвье, д. 27, кв. 69	+79071745552
P-490684-540	Ванёк	Антошкин	Кринжевич	ул. Перекопская, д. 71, кв. 80	+79182711984
P-490684-582	Антошка	Петькин	Амогусович	ул. Широтная, д. 58, кв. 43	+79461701619
P-490684-631	Ванёк	Олежкин	Кринжевич	ул. Первомайская, д. 97, кв. 15	+79489458986
P-490684-674	Олежа	Антошкин	Амогусович	ул. Широтная, д. 90, кв. 35	+79209223069
P-490684-727	Олежа	Ванькин	Кринжевич	ул. Перекопская, д. 42, кв. 52	+79887930226
P-490684-774	Антошка	Олежкин	Абобусович	ул. Газовиков, д. 60, кв. 88	+79602743051
P-490684-815	Антошка	Олежкин	Амогусович	ул. Ю-Р.Г. Эрвье, д. 53, кв. 55	+79027302714
P-490684-869	Антошка	Ванькин	Кринжевич	ул. Полевая, д. 57, кв. 3	+79853447592
P-490684-912	Олежа	Антошкин	Абобусович	ул. Газовиков, д. 29, кв. 45	+79440991006
P-490684-960	Антошка	Ванькин	Кринжевич	ул. Газовиков, д. 50, кв. 72	+79369228803
P-490685-007	Антошка	Антошкин	Амогусович	ул. Газовиков, д. 44, кв. 14	+79417556348
P-490685-051	Антошка	Олежкин	Амогусович	ул. Ю-Р.Г. Эрвье, д. 60, кв. 94	+79598972430
P-490685-110	Олежа	Ванькин	Кринжевич	ул. Ленина, д. 9, кв. 71	+79666171019
P-490685-162	Антошка	Петькин	Кринжевич	ул. Широтная, д. 27, кв. 64	+79101085244
P-490685-213	Ванёк	Антошкин	Абобусович	ул. Широтная, д. 1, кв. 52	+79578066106
P-490685-262	Антошка	Антошкин	Кринжевич	ул. Республики, д. 61, кв. 66	+79193440552
P-490685-301	Петька	Петькин	Абобусович	ул. Ленина, д. 11, кв. 46	+79545720062
P-490685-350	Антошка	Олежкин	Амогусович	ул. Тихий проезд, д. 46, кв. 80	+79171034784
P-490685-394	Петька	Антошкин	Кринжевич	ул. Перекопская, д. 63, кв. 35	+79301878381
\.


--
-- Data for Name: Specialist; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Specialist" ("specialist_ID", first_name, second_name, patronymic, speciality, home_address, phone_number) FROM stdin;
S-490680-442	Олежа	Петькин	Абобусович	офтальмолог	ул. Газовиков, д. 28, кв. 26	+79174006379
S-490680-528	Олежа	Ванькин	Кринжевич	терапевт	ул. Революции, д. 52, кв. 25	+79925505728
S-490680-576	Петька	Петькин	Кринжевич	офтальмолог	ул. Тихий проезд, д. 97, кв. 16	+79209821110
S-490680-638	Петька	Петькин	Абобусович	стоматолог	ул. Тихий проезд, д. 80, кв. 91	+79332954402
S-490680-685	Олежа	Ванькин	Амогусович	ортопед	ул. Республики, д. 82, кв. 11	+79199293821
S-490680-732	Петька	Олежкин	Абобусович	офтальмолог	ул. Первомайская, д. 51, кв. 85	+79948669569
S-490680-778	Олежа	Антошкин	Кринжевич	стоматолог	ул. Революции, д. 3, кв. 82	+79885079502
S-490680-825	Ванёк	Ванькин	Амогусович	хирург	ул. Революции, д. 55, кв. 34	+79213399614
S-490680-873	Петька	Антошкин	Кринжевич	хирург	ул. Первомайская, д. 10, кв. 72	+79142135056
S-490680-919	Ванёк	Олежкин	Амогусович	терапевт	ул. Полевая, д. 86, кв. 84	+79214917608
S-490680-967	Петька	Петькин	Кринжевич	стоматолог	ул. Широтная, д. 35, кв. 7	+79336740925
S-490681-015	Олежа	Петькин	Абобусович	хирург	ул. Ленина, д. 86, кв. 55	+79824388866
S-490681-061	Олежа	Олежкин	Кринжевич	офтальмолог	ул. Республики, д. 59, кв. 48	+79562599222
S-490681-123	Антошка	Олежкин	Абобусович	стоматолог	ул. Ленина, д. 45, кв. 54	+79009730173
S-490681-170	Олежа	Петькин	Кринжевич	терапевт	ул. Ленина, д. 35, кв. 1	+79939836336
S-490681-216	Петька	Олежкин	Кринжевич	терапевт	ул. Полевая, д. 42, кв. 30	+79874435077
S-490681-278	Олежа	Олежкин	Абобусович	ортопед	ул. Широтная, д. 8, кв. 30	+79945574506
S-490681-324	Олежа	Олежкин	Абобусович	ортопед	ул. Ю-Р.Г. Эрвье, д. 77, кв. 36	+79188957827
S-490681-372	Олежа	Ванькин	Абобусович	ортопед	ул. Республики, д. 70, кв. 24	+79645060159
S-490681-419	Ванёк	Антошкин	Кринжевич	стоматолог	ул. Ю-Р.Г. Эрвье, д. 11, кв. 11	+79782499895
S-490681-466	Петька	Петькин	Амогусович	офтальмолог	ул. Мельникайте, д. 68, кв. 17	+79195958507
S-490681-515	Петька	Олежкин	Амогусович	ортопед	ул. Первомайская, д. 78, кв. 57	+79657693192
S-490681-561	Ванёк	Олежкин	Амогусович	терапевт	ул. Газовиков, д. 20, кв. 96	+79416120110
S-490681-607	Ванёк	Ванькин	Кринжевич	терапевт	ул. Республики, д. 85, кв. 5	+79756509990
S-490681-671	Олежа	Антошкин	Амогусович	офтальмолог	ул. Мельникайте, д. 23, кв. 18	+79530776802
S-490681-718	Олежа	Антошкин	Абобусович	хирург	ул. Ю-Р.Г. Эрвье, д. 98, кв. 6	+79737117729
S-490681-765	Ванёк	Ванькин	Амогусович	хирург	ул. Ленина, д. 48, кв. 46	+79874245181
S-490681-827	Петька	Антошкин	Абобусович	хирург	ул. Республики, д. 64, кв. 15	+79828474401
S-490681-889	Олежа	Олежкин	Амогусович	терапевт	ул. Ю-Р.Г. Эрвье, д. 6, кв. 2	+79927493211
S-490681-952	Олежа	Антошкин	Кринжевич	стоматолог	ул. Республики, д. 71, кв. 90	+79428460560
S-490682-001	Ванёк	Петькин	Кринжевич	офтальмолог	ул. Ленина, д. 61, кв. 38	+79998617892
S-490682-045	Ванёк	Петькин	Абобусович	офтальмолог	ул. Ленина, д. 46, кв. 12	+79103678666
S-490682-091	Антошка	Антошкин	Амогусович	ортопед	ул. Тихий проезд, д. 15, кв. 41	+79941617138
S-490682-138	Антошка	Ванькин	Абобусович	терапевт	ул. Широтная, д. 56, кв. 65	+79291678817
S-490682-184	Олежа	Антошкин	Амогусович	хирург	ул. Мельникайте, д. 73, кв. 9	+79921225343
S-490682-231	Ванёк	Антошкин	Абобусович	офтальмолог	ул. Полевая, д. 50, кв. 1	+79945929704
S-490682-291	Ванёк	Ванькин	Амогусович	ортопед	ул. Полевая, д. 13, кв. 63	+79300584691
S-490682-339	Олежа	Петькин	Кринжевич	офтальмолог	ул. Газовиков, д. 90, кв. 58	+79091220375
S-490682-403	Петька	Антошкин	Кринжевич	хирург	ул. Первомайская, д. 88, кв. 74	+79030036458
S-490682-451	Олежа	Олежкин	Амогусович	терапевт	ул. Широтная, д. 2, кв. 65	+79703818390
S-490682-496	Петька	Ванькин	Абобусович	стоматолог	ул. Революции, д. 46, кв. 47	+79656683529
S-490682-542	Антошка	Ванькин	Абобусович	ортопед	ул. Мельникайте, д. 61, кв. 42	+79712096437
S-490682-604	Олежа	Ванькин	Кринжевич	офтальмолог	ул. Первомайская, д. 76, кв. 80	+79974496543
S-490682-650	Олежа	Ванькин	Кринжевич	офтальмолог	ул. Ленина, д. 69, кв. 9	+79136114463
S-490682-696	Олежа	Петькин	Кринжевич	офтальмолог	ул. Первомайская, д. 88, кв. 27	+79970010088
S-490682-759	Петька	Ванькин	Абобусович	офтальмолог	ул. Перекопская, д. 58, кв. 44	+79661075968
S-490682-806	Ванёк	Антошкин	Абобусович	хирург	ул. Ю-Р.Г. Эрвье, д. 94, кв. 46	+79663541493
S-490682-852	Антошка	Ванькин	Кринжевич	терапевт	ул. Ленина, д. 18, кв. 67	+79220953851
S-490682-915	Антошка	Ванькин	Абобусович	ортопед	ул. Республики, д. 86, кв. 100	+79936853603
S-490682-979	Антошка	Олежкин	Абобусович	терапевт	ул. Тихий проезд, д. 90, кв. 82	+79050419280
S-490683-040	Олежа	Антошкин	Кринжевич	хирург	ул. Республики, д. 86, кв. 64	+79257655289
S-490683-086	Олежа	Петькин	Амогусович	офтальмолог	ул. Ленина, д. 18, кв. 65	+79255913264
S-490683-148	Ванёк	Антошкин	Кринжевич	ортопед	ул. Революции, д. 88, кв. 63	+79076275949
S-490683-196	Олежа	Антошкин	Абобусович	терапевт	ул. Газовиков, д. 88, кв. 30	+79447919891
S-490683-241	Ванёк	Петькин	Амогусович	стоматолог	ул. Революции, д. 100, кв. 35	+79887422006
S-490683-305	Ванёк	Ванькин	Кринжевич	офтальмолог	ул. Ю-Р.Г. Эрвье, д. 54, кв. 2	+79211075949
S-490683-349	Ванёк	Петькин	Амогусович	стоматолог	ул. Тихий проезд, д. 50, кв. 6	+79811569130
S-490683-396	Петька	Антошкин	Абобусович	ортопед	ул. Широтная, д. 37, кв. 18	+79965974412
S-490683-442	Петька	Антошкин	Кринжевич	хирург	ул. Широтная, д. 82, кв. 21	+79996056045
S-490683-489	Ванёк	Антошкин	Кринжевич	стоматолог	ул. Полевая, д. 25, кв. 33	+79825795192
S-490683-536	Олежа	Ванькин	Кринжевич	хирург	ул. Республики, д. 10, кв. 26	+79427760940
S-490683-583	Антошка	Антошкин	Абобусович	стоматолог	ул. Республики, д. 21, кв. 93	+79566202325
S-490683-630	Ванёк	Олежкин	Абобусович	хирург	ул. Революции, д. 78, кв. 16	+79972778873
S-490683-676	Ванёк	Ванькин	Абобусович	офтальмолог	ул. Мельникайте, д. 45, кв. 57	+79324257226
S-490683-723	Петька	Антошкин	Кринжевич	ортопед	ул. Республики, д. 78, кв. 46	+79408896430
S-490683-771	Ванёк	Петькин	Абобусович	хирург	ул. Полевая, д. 68, кв. 68	+79019142027
S-490683-817	Антошка	Антошкин	Абобусович	ортопед	ул. Широтная, д. 36, кв. 20	+79720143450
S-490683-863	Ванёк	Петькин	Абобусович	стоматолог	ул. Республики, д. 81, кв. 20	+79962468704
S-490683-925	Петька	Петькин	Амогусович	офтальмолог	ул. Мельникайте, д. 2, кв. 96	+79229006528
S-490683-972	Петька	Ванькин	Амогусович	терапевт	ул. Полевая, д. 32, кв. 14	+79564748041
S-490684-019	Ванёк	Олежкин	Абобусович	офтальмолог	ул. Ю-Р.Г. Эрвье, д. 34, кв. 56	+79755956735
S-490684-064	Антошка	Петькин	Кринжевич	хирург	ул. Ленина, д. 82, кв. 29	+79769088991
S-490684-112	Антошка	Олежкин	Абобусович	хирург	ул. Широтная, д. 48, кв. 70	+79272484668
S-490684-158	Антошка	Петькин	Абобусович	терапевт	ул. Революции, д. 77, кв. 12	+79417329030
S-490684-204	Олежа	Петькин	Кринжевич	хирург	ул. Перекопская, д. 48, кв. 60	+79969468882
S-490684-267	Петька	Олежкин	Амогусович	офтальмолог	ул. Ленина, д. 21, кв. 99	+79248780426
S-490684-312	Петька	Петькин	Кринжевич	ортопед	ул. Перекопская, д. 51, кв. 76	+79302369547
S-490684-360	Олежа	Петькин	Абобусович	хирург	ул. Ю-Р.Г. Эрвье, д. 5, кв. 30	+79277781272
S-490684-406	Олежа	Антошкин	Амогусович	хирург	ул. Газовиков, д. 65, кв. 77	+79355401223
S-490684-454	Петька	Ванькин	Амогусович	стоматолог	ул. Тихий проезд, д. 86, кв. 79	+79270495879
S-490684-501	Петька	Олежкин	Абобусович	офтальмолог	ул. Газовиков, д. 56, кв. 21	+79493935050
S-490684-547	Петька	Ванькин	Кринжевич	стоматолог	ул. Мельникайте, д. 53, кв. 66	+79491529804
S-490684-594	Ванёк	Петькин	Кринжевич	хирург	ул. Перекопская, д. 4, кв. 37	+79744606104
S-490684-640	Олежа	Антошкин	Абобусович	хирург	ул. Тихий проезд, д. 67, кв. 23	+79049886984
S-490684-687	Ванёк	Ванькин	Кринжевич	хирург	ул. Первомайская, д. 100, кв. 59	+79604934698
S-490684-734	Ванёк	Олежкин	Кринжевич	офтальмолог	ул. Широтная, д. 27, кв. 78	+79098721208
S-490684-781	Ванёк	Антошкин	Амогусович	ортопед	ул. Ленина, д. 95, кв. 23	+79504726139
S-490684-827	Антошка	Ванькин	Амогусович	ортопед	ул. Широтная, д. 41, кв. 57	+79855206099
S-490684-877	Олежа	Ванькин	Кринжевич	хирург	ул. Республики, д. 87, кв. 63	+79335336999
S-490684-923	Антошка	Ванькин	Кринжевич	хирург	ул. Ленина, д. 71, кв. 26	+79392228516
S-490684-971	Петька	Петькин	Абобусович	стоматолог	ул. Перекопская, д. 31, кв. 6	+79883636232
S-490685-016	Антошка	Антошкин	Абобусович	офтальмолог	ул. Широтная, д. 57, кв. 32	+79282023721
S-490685-064	Петька	Ванькин	Кринжевич	хирург	ул. Мельникайте, д. 23, кв. 26	+79118745735
S-490685-126	Олежа	Антошкин	Абобусович	хирург	ул. Мельникайте, д. 68, кв. 30	+79625583995
S-490685-173	Олежа	Петькин	Абобусович	стоматолог	ул. Первомайская, д. 47, кв. 59	+79243389147
S-490685-220	Ванёк	Петькин	Абобусович	хирург	ул. Революции, д. 53, кв. 81	+79824081925
S-490685-268	Ванёк	Петькин	Кринжевич	офтальмолог	ул. Мельникайте, д. 68, кв. 93	+79605121118
S-490685-312	Петька	Петькин	Кринжевич	стоматолог	ул. Революции, д. 85, кв. 22	+79463134645
S-490685-359	Петька	Петькин	Амогусович	хирург	ул. Тихий проезд, д. 98, кв. 16	+79329229140
S-490685-406	Олежа	Олежкин	Амогусович	ортопед	ул. Революции, д. 21, кв. 12	+79025244275
\.


--
-- Data for Name: Visit; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Visit" ("patient_ID", "specialist_ID", is_first, "visit_ID", date, anamnesis, diagnosis, treatment, drugs_cost, services_cost) FROM stdin;
P-490681-050	S-490680-442	t	V-490681-079	2023-05-15 16:18:01.089151+05	-	-	-	1863	800
P-490680-523	S-490680-825	t	V-490681-140	2023-05-15 16:18:01.150976+05	-	-	-	980	749
P-490680-564	S-490680-576	f	V-490681-187	2023-05-15 16:18:01.197576+05	-	-	-	2524	540
P-490680-907	S-490681-061	t	V-490681-234	2023-05-15 16:18:01.243711+05	-	-	-	1218	868
P-490680-564	S-490680-778	f	V-490681-294	2023-05-15 16:18:01.305632+05	-	-	-	2090	893
P-490680-907	S-490681-278	t	V-490681-342	2023-05-15 16:18:01.353568+05	-	-	-	3208	818
P-490680-523	S-490681-061	f	V-490681-389	2023-05-15 16:18:01.401566+05	-	-	-	1306	725
P-490680-422	S-490680-442	t	V-490680-471	2023-05-15 16:18:00.480298+05	-	-	-	2436	778
P-490680-422	S-490680-528	f	V-490680-545	2023-05-15 16:18:00.558632+05	-	-	-	1877	909
P-490680-564	S-490680-442	t	V-490680-594	2023-05-15 16:18:00.605155+05	-	-	-	1524	683
P-490680-619	S-490680-576	f	V-490680-655	2023-05-15 16:18:00.667159+05	-	-	-	1440	754
P-490680-674	S-490680-638	f	V-490680-702	2023-05-15 16:18:00.713271+05	-	-	-	1470	505
P-490680-674	S-490680-442	t	V-490680-753	2023-05-15 16:18:00.75986+05	-	-	-	3652	755
P-490680-564	S-490680-442	f	V-490680-796	2023-05-15 16:18:00.806818+05	-	-	-	1650	568
P-490680-773	S-490680-732	t	V-490680-843	2023-05-15 16:18:00.854254+05	-	-	-	3038	919
P-490680-718	S-490680-732	t	V-490680-891	2023-05-15 16:18:00.901203+05	-	-	-	1331	505
P-490680-867	S-490680-825	f	V-490680-937	2023-05-15 16:18:00.947838+05	-	-	-	1516	721
P-490680-957	S-490680-919	f	V-490680-987	2023-05-15 16:18:00.995109+05	-	-	-	1409	835
P-490680-564	S-490680-685	t	V-490681-034	2023-05-15 16:18:01.042094+05	-	-	-	1218	984
P-490681-363	S-490680-967	t	V-490681-436	2023-05-15 16:18:01.449564+05	-	-	-	2309	651
P-490681-316	S-490681-324	f	V-490681-483	2023-05-15 16:18:01.495384+05	-	-	-	1745	866
P-490681-103	S-490680-442	t	V-490681-533	2023-05-15 16:18:01.542242+05	-	-	-	1516	893
P-490681-259	S-490681-061	t	V-490681-579	2023-05-15 16:18:01.589075+05	-	-	-	109	952
P-490681-165	S-490681-515	t	V-490681-626	2023-05-15 16:18:01.636034+05	-	-	-	2950	824
P-490680-907	S-490680-778	f	V-490681-689	2023-05-15 16:18:01.699731+05	-	-	-	1218	729
P-490681-050	S-490681-123	t	V-490681-735	2023-05-15 16:18:01.745671+05	-	-	-	2239	621
P-490681-707	S-490681-123	t	V-490681-783	2023-05-15 16:18:01.793122+05	-	-	-	2082	567
P-490680-816	S-490681-372	t	V-490681-845	2023-05-15 16:18:01.854436+05	-	-	-	1728	727
P-490680-718	S-490680-442	t	V-490681-908	2023-05-15 16:18:01.917132+05	-	-	-	2479	784
P-490681-363	S-490680-732	t	V-490681-970	2023-05-15 16:18:01.980521+05	-	-	-	712	855
P-490680-674	S-490682-001	t	V-490682-018	2023-05-15 16:18:02.026616+05	-	-	-	1306	679
P-490680-619	S-490680-873	f	V-490682-063	2023-05-15 16:18:02.073719+05	-	-	-	1218	864
P-490681-363	S-490681-216	f	V-490682-109	2023-05-15 16:18:02.119542+05	-	-	-	1300	706
P-490681-992	S-490680-638	t	V-490682-155	2023-05-15 16:18:02.165862+05	-	-	-	1651	945
P-490681-316	S-490681-123	t	V-490682-201	2023-05-15 16:18:02.212238+05	-	-	-	1579	820
P-490681-406	S-490680-967	t	V-490682-252	2023-05-15 16:18:02.258622+05	-	-	-	1306	986
P-490682-036	S-490681-827	t	V-490682-308	2023-05-15 16:18:02.320347+05	-	-	-	821	931
P-490681-008	S-490681-515	f	V-490682-359	2023-05-15 16:18:02.367878+05	-	-	-	4107	863
P-490681-707	S-490681-889	t	V-490682-421	2023-05-15 16:18:02.431991+05	-	-	-	1650	941
P-490680-674	S-490680-685	t	V-490682-466	2023-05-15 16:18:02.478967+05	-	-	-	2614	574
P-490681-992	S-490681-278	f	V-490682-512	2023-05-15 16:18:02.524395+05	-	-	-	2688	783
P-490680-564	S-490681-061	f	V-490682-560	2023-05-15 16:18:02.570262+05	-	-	-	1303	611
P-490681-207	S-490681-419	t	V-490682-622	2023-05-15 16:18:02.632156+05	-	-	-	218	736
P-490681-552	S-490681-170	f	V-490682-669	2023-05-15 16:18:02.678002+05	-	-	-	1331	649
P-490680-867	S-490681-419	t	V-490682-715	2023-05-15 16:18:02.724546+05	-	-	-	2266	775
P-490682-275	S-490681-278	f	V-490682-778	2023-05-15 16:18:02.786669+05	-	-	-	2047	723
P-490682-225	S-490681-061	t	V-490682-823	2023-05-15 16:18:02.833625+05	-	-	-	1331	742
P-490680-867	S-490682-650	t	V-490682-871	2023-05-15 16:18:02.880653+05	-	-	-	2734	637
P-490680-674	S-490680-732	t	V-490682-937	2023-05-15 16:18:02.943122+05	-	-	-	2620	625
P-490681-103	S-490682-045	t	V-490682-998	2023-05-15 16:18:03.005438+05	-	-	-	1877	810
P-490680-523	S-490682-696	f	V-490683-058	2023-05-15 16:18:03.067692+05	-	-	-	1218	672
P-490682-686	S-490681-170	t	V-490683-104	2023-05-15 16:18:03.113706+05	-	-	-	2457	993
P-490680-619	S-490680-576	f	V-490683-167	2023-05-15 16:18:03.176158+05	-	-	-	1218	686
P-490682-740	S-490682-852	f	V-490683-213	2023-05-15 16:18:03.22249+05	-	-	-	2776	504
P-490681-814	S-490681-718	t	V-490683-260	2023-05-15 16:18:03.26813+05	-	-	-	712	792
P-490681-103	S-490682-650	f	V-490683-318	2023-05-15 16:18:03.331162+05	-	-	-	1218	662
P-490681-259	S-490683-305	f	V-490683-366	2023-05-15 16:18:03.378296+05	-	-	-	1415	716
P-490682-841	S-490682-696	t	V-490683-412	2023-05-15 16:18:03.42447+05	-	-	-	2677	999
P-490682-644	S-490681-419	t	V-490683-459	2023-05-15 16:18:03.471956+05	-	-	-	1470	929
P-490682-536	S-490681-718	t	V-490683-506	2023-05-15 16:18:03.518126+05	-	-	-	1151	530
P-490680-422	S-490683-241	t	V-490683-553	2023-05-15 16:18:03.565137+05	-	-	-	2136	738
P-490682-644	S-490681-216	f	V-490683-600	2023-05-15 16:18:03.611831+05	-	-	-	1300	726
P-490681-008	S-490682-496	t	V-490683-649	2023-05-15 16:18:03.658382+05	-	-	-	2688	725
P-490681-008	S-490682-001	f	V-490683-695	2023-05-15 16:18:03.704524+05	-	-	-	1930	936
P-490682-644	S-490682-291	t	V-490683-742	2023-05-15 16:18:03.751865+05	-	-	-	1371	670
P-490682-587	S-490682-915	t	V-490683-789	2023-05-15 16:18:03.79842+05	-	-	-	1877	774
P-490683-525	S-490681-324	t	V-490683-836	2023-05-15 16:18:03.845129+05	-	-	-	2524	866
P-490682-587	S-490681-952	t	V-490683-882	2023-05-15 16:18:03.891465+05	-	-	-	1583	692
P-490681-207	S-490683-442	f	V-490683-945	2023-05-15 16:18:03.953249+05	-	-	-	1579	501
P-490683-130	S-490683-349	f	V-490683-992	2023-05-15 16:18:03.999596+05	-	-	-	939	841
P-490680-907	S-490681-466	f	V-490684-037	2023-05-15 16:18:04.045791+05	-	-	-	1877	696
P-490682-740	S-490683-086	t	V-490684-083	2023-05-15 16:18:04.09273+05	-	-	-	1440	666
P-490683-283	S-490682-291	f	V-490684-130	2023-05-15 16:18:04.13894+05	-	-	-	1009	762
P-490682-896	S-490681-466	f	V-490684-176	2023-05-15 16:18:04.186712+05	-	-	-	1909	899
P-490682-326	S-490682-759	t	V-490684-224	2023-05-15 16:18:04.232064+05	-	-	-	2963	517
P-490683-337	S-490683-536	t	V-490684-286	2023-05-15 16:18:04.294383+05	-	-	-	2637	544
P-490683-184	S-490683-630	t	V-490684-330	2023-05-15 16:18:04.342394+05	-	-	-	1657	829
P-490681-363	S-490683-442	t	V-490684-377	2023-05-15 16:18:04.38917+05	-	-	-	1331	531
P-490681-932	S-490682-184	t	V-490684-423	2023-05-15 16:18:04.435705+05	-	-	-	3906	883
P-490681-207	S-490683-086	t	V-490684-472	2023-05-15 16:18:04.482722+05	-	-	-	1470	721
P-490682-036	S-490682-184	t	V-490684-518	2023-05-15 16:18:04.530072+05	-	-	-	2950	832
P-490681-406	S-490680-967	f	V-490684-565	2023-05-15 16:18:04.577097+05	-	-	-	939	755
P-490680-773	S-490683-148	f	V-490684-611	2023-05-15 16:18:04.623066+05	-	-	-	2631	629
P-490682-686	S-490683-196	f	V-490684-658	2023-05-15 16:18:04.669332+05	-	-	-	1331	858
P-490680-674	S-490684-360	t	V-490684-704	2023-05-15 16:18:04.716414+05	-	-	-	3353	649
P-490682-798	S-490682-542	f	V-490684-751	2023-05-15 16:18:04.762949+05	-	-	-	3740	605
P-490680-564	S-490682-291	t	V-490684-799	2023-05-15 16:18:04.810067+05	-	-	-	439	594
P-490681-552	S-490680-638	t	V-490684-845	2023-05-15 16:18:04.856979+05	-	-	-	1877	958
P-490681-259	S-490681-123	t	V-490684-894	2023-05-15 16:18:04.904026+05	-	-	-	1470	956
P-490681-363	S-490683-396	f	V-490684-940	2023-05-15 16:18:04.951272+05	-	-	-	1300	500
P-490681-406	S-490683-676	t	V-490684-994	2023-05-15 16:18:04.99874+05	-	-	-	577	982
P-490684-912	S-490681-123	t	V-490685-034	2023-05-15 16:18:05.045963+05	-	-	-	1300	916
P-490681-456	S-490681-889	t	V-490685-082	2023-05-15 16:18:05.093027+05	-	-	-	4076	786
P-490684-199	S-490681-419	t	V-490685-145	2023-05-15 16:18:05.154394+05	-	-	-	439	523
P-490683-235	S-490685-016	f	V-490685-191	2023-05-15 16:18:05.201234+05	-	-	-	2631	703
P-490680-523	S-490683-630	f	V-490685-238	2023-05-15 16:18:05.248435+05	-	-	-	1306	848
P-490683-574	S-490680-576	t	V-490685-285	2023-05-15 16:18:05.294973+05	-	-	-	577	828
P-490685-301	S-490682-091	f	V-490685-330	2023-05-15 16:18:05.341233+05	-	-	-	686	966
P-490682-959	S-490683-583	t	V-490685-376	2023-05-15 16:18:05.38825+05	-	-	-	432	803
P-490681-505	S-490684-406	f	V-490685-424	2023-05-15 16:18:05.435014+05	-	-	-	2047	635
\.


--
-- Data for Name: Visit_Medicine; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Visit_Medicine" ("visit_ID", "medicine_ID") FROM stdin;
V-490680-471	M-557471-699
V-490680-471	M-557471-699
V-490680-545	M-132779-993
V-490680-545	M-132752-553
V-490680-594	M-132752-589
V-490680-594	M-132780-008
V-490680-594	M-132752-589
V-490680-655	M-132752-589
V-490680-655	M-132779-983
V-490680-702	M-132752-573
V-490680-753	M-132752-573
V-490680-753	M-132752-573
V-490680-753	M-132752-605
V-490680-796	M-557471-699
V-490680-796	M-132780-024
V-490680-843	M-132780-008
V-490680-843	M-132752-553
V-490680-843	M-132780-024
V-490680-891	M-132779-983
V-490680-937	M-132780-040
V-490680-937	M-132779-993
V-490680-987	M-132752-589
V-490680-987	M-132752-553
V-490681-034	M-557471-699
V-490681-079	M-132752-566
V-490681-079	M-132752-605
V-490681-079	M-132752-605
V-490681-140	M-132752-566
V-490681-140	M-132752-589
V-490681-140	M-132780-024
V-490681-187	M-132780-008
V-490681-187	M-557471-699
V-490681-234	M-557471-699
V-490681-294	M-132752-605
V-490681-294	M-132752-566
V-490681-294	M-132780-040
V-490681-342	M-132780-008
V-490681-342	M-132752-573
V-490681-342	M-132780-024
V-490681-389	M-132780-008
V-490681-436	M-132780-024
V-490681-436	M-132752-553
V-490681-436	M-132779-993
V-490681-483	M-132780-008
V-490681-483	M-132752-566
V-490681-533	M-132780-040
V-490681-533	M-132779-993
V-490681-579	M-132752-589
V-490681-626	M-132752-553
V-490681-626	M-557471-699
V-490681-626	M-132780-024
V-490681-689	M-557471-699
V-490681-735	M-132752-553
V-490681-735	M-132780-040
V-490681-783	M-557471-699
V-490681-783	M-132780-024
V-490681-783	M-132780-024
V-490681-845	M-132752-566
V-490681-845	M-132779-993
V-490681-845	M-132752-605
V-490681-908	M-132780-024
V-490681-908	M-132752-573
V-490681-908	M-132779-993
V-490681-970	M-132752-605
V-490682-018	M-132780-008
V-490682-063	M-557471-699
V-490682-109	M-132752-553
V-490682-155	M-132752-605
V-490682-155	M-132780-040
V-490682-201	M-132752-573
V-490682-201	M-132752-589
V-490682-252	M-132780-008
V-490682-308	M-132752-605
V-490682-308	M-132752-589
V-490682-359	M-132779-983
V-490682-359	M-132752-573
V-490682-359	M-132780-008
V-490682-421	M-557471-699
V-490682-421	M-132780-024
V-490682-466	M-132752-573
V-490682-466	M-132780-024
V-490682-466	M-132752-605
V-490682-512	M-557471-699
V-490682-512	M-132752-573
V-490682-560	M-132780-024
V-490682-560	M-132780-024
V-490682-560	M-132752-566
V-490682-622	M-132752-589
V-490682-622	M-132752-589
V-490682-669	M-132779-983
V-490682-715	M-557471-699
V-490682-715	M-132780-040
V-490682-715	M-132752-589
V-490682-778	M-132779-993
V-490682-778	M-132752-573
V-490682-823	M-132779-983
V-490682-871	M-132779-993
V-490682-871	M-132780-040
V-490682-871	M-557471-699
V-490682-937	M-132752-605
V-490682-937	M-132779-993
V-490682-937	M-132779-983
V-490682-998	M-132779-993
V-490682-998	M-132752-553
V-490683-058	M-557471-699
V-490683-104	M-132780-008
V-490683-104	M-132752-566
V-490683-104	M-132752-605
V-490683-167	M-557471-699
V-490683-213	M-132752-573
V-490683-213	M-132780-008
V-490683-260	M-132752-605
V-490683-318	M-557471-699
V-490683-366	M-132780-008
V-490683-366	M-132752-589
V-490683-412	M-132780-024
V-490683-412	M-132780-040
V-490683-412	M-132780-008
V-490683-459	M-132752-573
V-490683-506	M-132752-605
V-490683-506	M-132752-566
V-490683-553	M-132752-605
V-490683-553	M-132752-605
V-490683-553	M-132752-605
V-490683-600	M-132752-553
V-490683-649	M-557471-699
V-490683-649	M-132752-573
V-490683-695	M-557471-699
V-490683-695	M-132752-605
V-490683-742	M-132780-024
V-490683-742	M-132780-040
V-490683-789	M-132752-553
V-490683-789	M-132779-993
V-490683-836	M-132780-008
V-490683-836	M-557471-699
V-490683-882	M-132752-605
V-490683-882	M-132752-566
V-490683-882	M-132780-024
V-490683-945	M-132752-589
V-490683-945	M-132752-573
V-490683-992	M-132780-040
V-490684-037	M-132752-553
V-490684-037	M-132779-993
V-490684-083	M-132752-589
V-490684-083	M-132779-983
V-490684-130	M-132780-024
V-490684-130	M-132779-993
V-490684-176	M-132752-566
V-490684-176	M-132752-573
V-490684-224	M-557471-699
V-490684-224	M-132780-008
V-490684-224	M-132752-566
V-490684-286	M-132779-983
V-490684-286	M-132780-008
V-490684-330	M-557471-699
V-490684-330	M-132752-566
V-490684-377	M-132779-983
V-490684-423	M-132752-553
V-490684-423	M-132752-553
V-490684-423	M-132780-008
V-490684-472	M-132752-573
V-490684-518	M-557471-699
V-490684-518	M-132780-024
V-490684-518	M-132752-553
V-490684-565	M-132780-040
V-490684-611	M-132752-553
V-490684-611	M-132779-983
V-490684-658	M-132779-983
V-490684-704	M-132779-993
V-490684-704	M-132752-573
V-490684-704	M-132780-008
V-490684-751	M-132779-983
V-490684-751	M-132752-573
V-490684-751	M-132780-040
V-490684-799	M-132752-566
V-490684-845	M-132779-993
V-490684-845	M-132752-553
V-490684-894	M-132752-573
V-490684-940	M-132752-553
V-490684-994	M-132779-993
V-490685-034	M-132752-553
V-490685-082	M-132752-573
V-490685-082	M-132752-553
V-490685-082	M-132780-008
V-490685-145	M-132752-566
V-490685-191	M-132779-983
V-490685-191	M-132752-553
V-490685-238	M-132780-008
V-490685-285	M-132779-993
V-490685-330	M-132752-589
V-490685-330	M-132779-993
V-490685-376	M-132780-024
V-490685-424	M-132779-993
V-490685-424	M-132752-573
\.


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add log entry	1	add_logentry
2	Can change log entry	1	change_logentry
3	Can delete log entry	1	delete_logentry
4	Can view log entry	1	view_logentry
5	Can add permission	2	add_permission
6	Can change permission	2	change_permission
7	Can delete permission	2	delete_permission
8	Can view permission	2	view_permission
9	Can add group	3	add_group
10	Can change group	3	change_group
11	Can delete group	3	delete_group
12	Can view group	3	view_group
13	Can add user	4	add_user
14	Can change user	4	change_user
15	Can delete user	4	delete_user
16	Can view user	4	view_user
17	Can add content type	5	add_contenttype
18	Can change content type	5	change_contenttype
19	Can delete content type	5	delete_contenttype
20	Can view content type	5	view_contenttype
21	Can add session	6	add_session
22	Can change session	6	change_session
23	Can delete session	6	delete_session
24	Can view session	6	view_session
25	Can add medicine	7	add_medicine
26	Can change medicine	7	change_medicine
27	Can delete medicine	7	delete_medicine
28	Can view medicine	7	view_medicine
29	Can add patient	8	add_patient
30	Can change patient	8	change_patient
31	Can delete patient	8	delete_patient
32	Can view patient	8	view_patient
33	Can add specialist	9	add_specialist
34	Can change specialist	9	change_specialist
35	Can delete specialist	9	delete_specialist
36	Can view specialist	9	view_specialist
37	Can add visit	10	add_visit
38	Can change visit	10	change_visit
39	Can delete visit	10	delete_visit
40	Can view visit	10	view_visit
41	Can add visit medicine	11	add_visitmedicine
42	Can change visit medicine	11	change_visitmedicine
43	Can delete visit medicine	11	delete_visitmedicine
44	Can view visit medicine	11	view_visitmedicine
45	Can add user	12	add_user
46	Can change user	12	change_user
47	Can delete user	12	delete_user
48	Can view user	12	view_user
\.


--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM stdin;
\.


--
-- Data for Name: auth_user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Data for Name: auth_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Data for Name: clinicapp_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clinicapp_user (id, username, password) FROM stdin;
3	meow	murr
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	admin	logentry
2	auth	permission
3	auth	group
4	auth	user
5	contenttypes	contenttype
6	sessions	session
7	clinicapp	medicine
8	clinicapp	patient
9	clinicapp	specialist
10	clinicapp	visit
11	clinicapp	visitmedicine
12	clinicapp	user
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2023-06-02 04:31:16.072728+05
2	auth	0001_initial	2023-06-02 04:31:16.136901+05
3	admin	0001_initial	2023-06-02 04:31:16.16237+05
4	admin	0002_logentry_remove_auto_add	2023-06-02 04:31:16.167389+05
5	admin	0003_logentry_add_action_flag_choices	2023-06-02 04:31:16.171944+05
6	contenttypes	0002_remove_content_type_name	2023-06-02 04:31:16.18322+05
7	auth	0002_alter_permission_name_max_length	2023-06-02 04:31:16.188204+05
8	auth	0003_alter_user_email_max_length	2023-06-02 04:31:16.194187+05
9	auth	0004_alter_user_username_opts	2023-06-02 04:31:16.198176+05
10	auth	0005_alter_user_last_login_null	2023-06-02 04:31:16.203164+05
11	auth	0006_require_contenttypes_0002	2023-06-02 04:31:16.205159+05
12	auth	0007_alter_validators_add_error_messages	2023-06-02 04:31:16.210148+05
13	auth	0008_alter_user_username_max_length	2023-06-02 04:31:16.224673+05
14	auth	0009_alter_user_last_name_max_length	2023-06-02 04:31:16.229663+05
15	auth	0010_alter_group_name_max_length	2023-06-02 04:31:16.235675+05
16	auth	0011_update_proxy_permissions	2023-06-02 04:31:16.241659+05
17	auth	0012_alter_user_first_name_max_length	2023-06-02 04:31:16.246648+05
18	clinicapp	0001_initial	2023-06-02 04:31:16.25061+05
19	clinicapp	0002_user	2023-06-02 04:31:16.262575+05
20	sessions	0001_initial	2023-06-02 04:31:16.273719+05
21	clinicapp	0003_delete_user	2023-06-02 04:59:38.331123+05
22	clinicapp	0004_user	2023-06-02 04:59:58.880926+05
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
818kvuaflfs0gbyf8gagh0nlyoygres0	eyJ1c2VybmFtZSI6Im1lb3cifQ:1q4sZK:LPR1ECNtlwroYY24-dL5ZUGOfl2AtjNIJs1ocH_LUrg	2023-06-16 05:23:02.971985+05
\.


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 48, true);


--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_user_groups_id_seq', 1, false);


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_user_id_seq', 1, false);


--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_user_user_permissions_id_seq', 1, false);


--
-- Name: clinicapp_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clinicapp_user_id_seq', 4, true);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 12, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 22, true);


--
-- Name: Medicine MedicineID; Type: CONSTRAINT; Schema: main_schema; Owner: postgres
--

ALTER TABLE ONLY main_schema."Medicine"
    ADD CONSTRAINT "MedicineID" PRIMARY KEY ("medicine_ID");


--
-- Name: Patient PatientID; Type: CONSTRAINT; Schema: main_schema; Owner: postgres
--

ALTER TABLE ONLY main_schema."Patient"
    ADD CONSTRAINT "PatientID" PRIMARY KEY ("patient_ID");


--
-- Name: Specialist SpecialistID; Type: CONSTRAINT; Schema: main_schema; Owner: postgres
--

ALTER TABLE ONLY main_schema."Specialist"
    ADD CONSTRAINT "SpecialistID" PRIMARY KEY ("specialist_ID");


--
-- Name: Visit VisitID; Type: CONSTRAINT; Schema: main_schema; Owner: postgres
--

ALTER TABLE ONLY main_schema."Visit"
    ADD CONSTRAINT "VisitID" PRIMARY KEY ("visit_ID");


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);


--
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);


--
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: clinicapp_user clinicapp_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinicapp_user
    ADD CONSTRAINT clinicapp_user_pkey PRIMARY KEY (id);


--
-- Name: clinicapp_user clinicapp_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clinicapp_user
    ADD CONSTRAINT clinicapp_user_username_key UNIQUE (username);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_group_id_97559544; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_user_id_6a12ed8b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_permission_id_1fbb5f2c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_user_id_a95ead1b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);


--
-- Name: auth_user_username_6821ab7c_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);


--
-- Name: clinicapp_user_username_9ff1b4bd_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX clinicapp_user_username_9ff1b4bd_like ON public.clinicapp_user USING btree (username varchar_pattern_ops);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: Visit_Medicine receipt_sum; Type: TRIGGER; Schema: main_schema; Owner: postgres
--

CREATE TRIGGER receipt_sum AFTER INSERT ON main_schema."Visit_Medicine" FOR EACH ROW EXECUTE FUNCTION main_schema.do_trigger_job();


--
-- Name: Visit_Medicine MedicineID; Type: FK CONSTRAINT; Schema: main_schema; Owner: postgres
--

ALTER TABLE ONLY main_schema."Visit_Medicine"
    ADD CONSTRAINT "MedicineID" FOREIGN KEY ("medicine_ID") REFERENCES main_schema."Medicine"("medicine_ID");


--
-- Name: Visit PatientID; Type: FK CONSTRAINT; Schema: main_schema; Owner: postgres
--

ALTER TABLE ONLY main_schema."Visit"
    ADD CONSTRAINT "PatientID" FOREIGN KEY ("patient_ID") REFERENCES main_schema."Patient"("patient_ID");


--
-- Name: Visit SpecialistID; Type: FK CONSTRAINT; Schema: main_schema; Owner: postgres
--

ALTER TABLE ONLY main_schema."Visit"
    ADD CONSTRAINT "SpecialistID" FOREIGN KEY ("specialist_ID") REFERENCES main_schema."Specialist"("specialist_ID");


--
-- Name: Visit_Medicine VisitID; Type: FK CONSTRAINT; Schema: main_schema; Owner: postgres
--

ALTER TABLE ONLY main_schema."Visit_Medicine"
    ADD CONSTRAINT "VisitID" FOREIGN KEY ("visit_ID") REFERENCES main_schema."Visit"("visit_ID");


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

