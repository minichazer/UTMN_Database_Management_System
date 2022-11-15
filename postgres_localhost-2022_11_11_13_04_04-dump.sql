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
        ORDER BY "visit_ID" DESC
        LIMIT 1;
    end;
$$;


ALTER FUNCTION main_schema.get_last_visit() OWNER TO postgres;

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
    date date NOT NULL,
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
-- Data for Name: Medicine; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Medicine" ("medicine_ID", name, cost) FROM stdin;
M-123-123	drugs	500100
\.


--
-- Data for Name: Patient; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Patient" ("patient_ID", first_name, second_name, patronymic, home_address, phone_number) FROM stdin;
P-238515-546	Антошка	Петькин	Амогусович	ул. Перекопская, д. 90, кв. 6	+79869484195
P-238515-583	Олежа	Олежкин	Абобусович	ул. Тихий проезд, д. 99, кв. 16	+79346303271
P-238515-608	Олежа	Олежкин	Абобусович	ул. Газовиков, д. 15, кв. 59	+79212483670
P-238515-641	Антошка	Антошкин	Абобусович	ул. Ю-Р.Г. Эрвье, д. 61, кв. 53	+79158008214
P-238515-671	Антошка	Антошкин	Амогусович	ул. Ленина, д. 52, кв. 80	+79953780494
P-238515-704	Антошка	Олежкин	Абобусович	ул. Республики, д. 1, кв. 90	+79647322310
P-238515-735	Олежа	Петькин	Амогусович	ул. Революции, д. 38, кв. 38	+79448111726
P-238515-766	Антошка	Ванькин	Абобусович	ул. Ю-Р.Г. Эрвье, д. 45, кв. 35	+79022895205
P-238515-798	Олежа	Антошкин	Амогусович	ул. Газовиков, д. 75, кв. 65	+79830987709
P-238515-828	Петька	Ванькин	Амогусович	ул. Революции, д. 93, кв. 83	+79818223606
P-247900-617	Ванёк	Петькин	Амогусович	ул. Тихий проезд, д. 89, кв. 26	+79754494437
P-247900-664	Олежа	Петькин	Кринжевич	ул. Ю-Р.Г. Эрвье, д. 68, кв. 16	+79243444637
P-247942-372	Ванёк	Олежкин	Абобусович	ул. Ю-Р.Г. Эрвье, д. 82, кв. 20	+79694714263
P-298811-572	Антошка	Олежкин	Кринжевич	ул. Мельникайте, д. 36, кв. 67	+79913394164
P-298811-620	Антошка	Петькин	Кринжевич	ул. Тихий проезд, д. 89, кв. 16	+79620179299
P-298811-658	Антошка	Ванькин	Амогусович	ул. Революции, д. 84, кв. 80	+79877325668
P-298811-707	Олежа	Олежкин	Кринжевич	ул. Первомайская, д. 18, кв. 46	+79232001707
P-298811-755	Олежа	Антошкин	Абобусович	ул. Полевая, д. 23, кв. 42	+79083737484
P-298811-802	Ванёк	Ванькин	Кринжевич	ул. Мельникайте, д. 90, кв. 19	+79392140059
P-298811-849	Антошка	Антошкин	Абобусович	ул. Широтная, д. 64, кв. 69	+79302371857
P-298811-896	Олежа	Антошкин	Амогусович	ул. Широтная, д. 80, кв. 3	+79150844807
P-298811-944	Антошка	Ванькин	Кринжевич	ул. Полевая, д. 15, кв. 72	+79298687094
P-298811-990	Ванёк	Петькин	Абобусович	ул. Перекопская, д. 46, кв. 92	+79907582801
P-299137-835	Петька	Петькин	Кринжевич	ул. Газовиков, д. 74, кв. 95	+79944253727
P-299137-878	Олежа	Олежкин	Амогусович	ул. Революции, д. 32, кв. 52	+79932733398
P-299137-924	Ванёк	Олежкин	Абобусович	ул. Республики, д. 21, кв. 37	+79163332886
P-299137-971	Петька	Петькин	Амогусович	ул. Республики, д. 35, кв. 64	+79229052713
P-299138-016	Ванёк	Петькин	Амогусович	ул. Революции, д. 80, кв. 7	+79481676259
P-299138-063	Антошка	Петькин	Абобусович	ул. Республики, д. 66, кв. 19	+79093277014
P-299138-110	Антошка	Ванькин	Абобусович	ул. Перекопская, д. 9, кв. 87	+79597713530
P-299138-157	Петька	Антошкин	Абобусович	ул. Широтная, д. 5, кв. 15	+79479738921
P-299138-204	Ванёк	Антошкин	Кринжевич	ул. Республики, д. 38, кв. 83	+79272123313
P-299138-250	Петька	Олежкин	Кринжевич	ул. Перекопская, д. 62, кв. 88	+79886123792
P-247942-333	Ванёк	Ванькин	Абобусович	ул. Мельникайте, д. 50, кв. 34	+79484265089
P-309889-038	Олежа	Олежкин	Кринжевич	ул. Перекопская, д. 53, кв. 1	+79014261255
P-309889-083	Антошка	Олежкин	Амогусович	ул. Газовиков, д. 27, кв. 14	+79890698242
P-312947-013	Олежа	Антошкин	Амогусович	ул. Ю-Р.Г. Эрвье, д. 66, кв. 33	+79490159448
test	test	test	test	test	test
P-312980-012	Антошка	Ванькин	Амогусович	ул. Ю-Р.Г. Эрвье, д. 38, кв. 90	+79438612866
testtesttesttest	testtesttesttest	testtesttesttest	testtesttesttest	testtesttesttest	testtesttesttest
P-313007-658	Антошка	Олежкин	Абобусович	ул. Полевая, д. 67, кв. 96	+79137029159
testtesttesttesttest	testtesttesttesttest	testtesttesttesttest	testtesttesttesttest	testtesttesttesttest	testtesttesttesttest
a560aadb-591e-11ed-b0d2-5800e391859e	Sergey	Kostin	Ktoto tamovich	boloto	krutoy
P-111111-500	МИХАИЛ	крутой	Абобусович	ул. Газовиков, д. 15, кв. 59	+79212483670
P-2558724-124	3	4	5	6	7
P-575880-184	arbuz	arbuzniy	arbuzevich	boloto	krutoy
\.


--
-- Data for Name: Specialist; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Specialist" ("specialist_ID", first_name, second_name, patronymic, speciality, home_address, phone_number) FROM stdin;
1	1	1	1	11	1	1
S-238515-567	Петька	Ванькин	Абобусович	терапевт	ул. Газовиков, д. 29, кв. 79	+79666578145
S-238515-593	Петька	Олежкин	Кринжевич	хирург	ул. Перекопская, д. 36, кв. 87	+79718027363
S-238515-624	Антошка	Олежкин	Амогусович	хирург	ул. Мельникайте, д. 26, кв. 33	+79479688746
S-238515-656	Олежа	Ванькин	Абобусович	хирург	ул. Республики, д. 82, кв. 74	+79570906658
S-238515-688	Ванёк	Олежкин	Абобусович	хирург	ул. Мельникайте, д. 91, кв. 51	+79394820512
S-238515-720	Петька	Антошкин	Абобусович	хирург	ул. Ленина, д. 38, кв. 86	+79766900149
S-238515-750	Антошка	Петькин	Абобусович	терапевт	ул. Газовиков, д. 38, кв. 16	+79936165747
S-238515-782	Ванёк	Олежкин	Кринжевич	терапевт	ул. Ю-Р.Г. Эрвье, д. 25, кв. 21	+79568182004
S-238515-813	Антошка	Петькин	Амогусович	терапевт	ул. Первомайская, д. 53, кв. 82	+79841820701
S-238515-844	Петька	Ванькин	Амогусович	стоматолог	ул. Полевая, д. 45, кв. 64	+79989632968
S-247900-636	Ванёк	Ванькин	Абобусович	ортопед	ул. Перекопская, д. 11, кв. 20	+79761697497
S-247900-678	Олежа	Антошкин	Кринжевич	стоматолог	ул. Ю-Р.Г. Эрвье, д. 8, кв. 39	+79357179767
S-247942-343	Ванёк	Ванькин	Кринжевич	офтальмолог	ул. Полевая, д. 27, кв. 57	+79289452007
S-247942-386	Антошка	Петькин	Кринжевич	терапевт	ул. Газовиков, д. 76, кв. 41	+79946378039
S-298811-590	Петька	Петькин	Кринжевич	стоматолог	ул. Ю-Р.Г. Эрвье, д. 32, кв. 79	+79670874048
S-298811-626	Петька	Антошкин	Абобусович	терапевт	ул. Ю-Р.Г. Эрвье, д. 29, кв. 85	+79541202880
S-298811-674	Антошка	Ванькин	Амогусович	офтальмолог	ул. Перекопская, д. 8, кв. 86	+79504166291
S-298811-724	Ванёк	Петькин	Абобусович	хирург	ул. Тихий проезд, д. 4, кв. 67	+79727063262
S-298811-770	Ванёк	Антошкин	Амогусович	хирург	ул. Полевая, д. 84, кв. 90	+79604216504
S-298811-819	Олежа	Олежкин	Кринжевич	хирург	ул. Тихий проезд, д. 77, кв. 79	+79260083268
S-298811-865	Олежа	Ванькин	Кринжевич	терапевт	ул. Республики, д. 49, кв. 12	+79900345281
S-298811-912	Олежа	Олежкин	Абобусович	ортопед	ул. Первомайская, д. 64, кв. 79	+79534880733
S-298811-961	Ванёк	Ванькин	Амогусович	терапевт	ул. Революции, д. 37, кв. 32	+79810809784
S-298812-005	Петька	Ванькин	Кринжевич	офтальмолог	ул. Газовиков, д. 84, кв. 12	+79358677938
S-299137-850	Петька	Ванькин	Амогусович	терапевт	ул. Революции, д. 26, кв. 27	+79913674982
S-299137-891	Петька	Ванькин	Абобусович	терапевт	ул. Перекопская, д. 19, кв. 80	+79217893228
S-299137-939	Петька	Петькин	Кринжевич	офтальмолог	ул. Широтная, д. 76, кв. 72	+79666055424
S-299137-985	Ванёк	Ванькин	Амогусович	стоматолог	ул. Газовиков, д. 21, кв. 58	+79215437349
S-299138-037	Петька	Ванькин	Кринжевич	офтальмолог	ул. Перекопская, д. 56, кв. 1	+79627034951
S-299138-078	Антошка	Антошкин	Кринжевич	терапевт	ул. Республики, д. 94, кв. 66	+79035989039
S-299138-125	Антошка	Олежкин	Абобусович	офтальмолог	ул. Революции, д. 83, кв. 9	+79848190177
S-299138-172	Олежа	Антошкин	Абобусович	терапевт	ул. Широтная, д. 93, кв. 18	+79217510953
S-299138-220	Петька	Ванькин	Кринжевич	хирург	ул. Полевая, д. 22, кв. 20	+79433461781
S-299138-266	Олежа	Ванькин	Абобусович	терапевт	ул. Ленина, д. 31, кв. 36	+79273058661
S-309889-056	Ванёк	Олежкин	Абобусович	терапевт	ул. Революции, д. 94, кв. 81	+79737346392
S-309889-097	Олежа	Ванькин	Абобусович	ортопед	ул. Первомайская, д. 90, кв. 20	+79409531382
\.


--
-- Data for Name: Visit; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Visit" ("patient_ID", "specialist_ID", is_first, "visit_ID", date, anamnesis, diagnosis, treatment, drugs_cost, services_cost) FROM stdin;
P-238515-704	S-238515-782	t	V-238515-200	2022-10-05	-	-	-	0	0
P-238515-641	S-238515-624	f	V-247900-652	2022-10-05	-	-	-	0	545
P-247900-617	S-247942-343	f	V-247942-358	2022-10-05	-	-	-	0	711
P-238515-766	S-238515-813	f	V-247942-402	2022-10-05	-	-	-	0	819
P-238515-671	S-238515-593	t	V-298811-607	2022-10-06	-	-	-	0	639
P-238515-546	S-247900-678	t	V-298811-643	2022-10-06	-	-	-	0	720
P-238515-766	S-238515-782	f	V-298811-693	2022-10-06	-	-	-	0	627
P-238515-608	S-238515-844	t	V-298811-742	2022-10-06	-	-	-	0	877
P-298811-707	S-298811-674	f	V-298811-789	2022-10-06	-	-	-	0	839
P-247900-617	S-238515-750	f	V-298811-840	2022-10-06	-	-	-	0	652
P-298811-572	S-247900-678	t	V-298811-883	2022-10-06	-	-	-	0	859
P-238515-641	S-238515-750	t	V-298811-933	2022-10-06	-	-	-	0	679
P-298811-707	S-238515-688	t	V-298811-977	2022-10-06	-	-	-	0	985
P-238515-641	S-247900-678	t	V-298812-030	2022-10-06	-	-	-	0	514
P-298811-802	S-238515-624	f	V-299137-864	2022-10-06	-	-	-	0	660
P-238515-546	S-238515-593	t	V-299137-912	2022-10-06	-	-	-	0	921
P-238515-735	S-247942-386	f	V-299137-958	2022-10-06	-	-	-	0	670
P-299137-878	S-238515-782	f	V-299138-004	2022-10-06	-	-	-	0	901
P-298811-802	S-298811-865	t	V-299138-050	2022-10-06	-	-	-	0	982
P-238515-583	S-298812-005	f	V-299138-097	2022-10-06	-	-	-	0	732
P-238515-671	S-299137-850	f	V-299138-145	2022-10-06	-	-	-	0	658
P-298811-707	S-247900-636	f	V-299138-191	2022-10-06	-	-	-	0	907
P-238515-583	S-238515-750	t	V-299138-238	2022-10-06	-	-	-	0	996
P-299137-878	S-299138-037	f	V-299138-285	2022-10-06	-	-	-	0	702
P-247900-664	S-309889-056	t	V-309889-071	2022-10-06	-	-	-	0	575
P-247900-664	S-298811-674	f	V-309889-113	2022-10-06	-	-	-	0	800
\.


--
-- Data for Name: Visit_Medicine; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Visit_Medicine" ("visit_ID", "medicine_ID") FROM stdin;
V-298811-883	M-123-123
\.


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
-- PostgreSQL database dump complete
--

