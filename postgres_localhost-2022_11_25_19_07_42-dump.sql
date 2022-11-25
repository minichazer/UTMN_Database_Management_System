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
-- Data for Name: Medicine; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Medicine" ("medicine_ID", name, cost) FROM stdin;
M-123-123	drugs	500100
M-1196612-029	Мексидол2	246
M-1196612-086	Цитрамон6	821
M-1196612-142	Кагоцел3	371
M-1196612-204	Нурофен2	648
M-1196612-266	Мирамистин7	352
M-1196612-328	Кагоцел6	1427
M-1196612-391	Кагоцел8	903
M-1196612-453	Кагоцел4	1389
M-1196612-517	Мирамистин2	1103
M-1196612-576	Нурофен6	1320
M-1264077-463	Кагоцел-8	452
M-1264077-559	Цитрамон-10	963
M-1264077-616	Мексидол-10	291
M-1264077-675	Мексидол-6	304
M-1264077-737	Кагоцел-10	1123
M-1264077-800	Мирамистин-6	1045
M-1264077-863	Нурофен-7	518
M-1264077-926	Мирамистин-6	1216
M-1264077-988	Мирамистин-3	125
M-1264078-052	Кагоцел-2	352
M-1264088-238	Нурофен-4	854
M-1264088-296	Мексидол-8	422
M-1264088-356	Кагоцел-4	730
M-1264088-420	Мирамистин-7	787
M-1264088-484	Нурофен-10	1326
M-1264088-546	Мирамистин-8	1061
M-1264088-610	Цитрамон-9	262
M-1264088-673	Мексидол-4	599
M-1264088-736	Цитрамон-2	1360
M-1264088-800	Кагоцел-3	322
M-1264840-485	Мирамистин-7	1168
M-1264840-577	Цитрамон-9	134
M-1264840-638	Нурофен-5	438
M-1264840-702	Мирамистин-9	1064
M-1264840-764	Мексидол-7	1236
M-1264840-826	Цитрамон-3	710
M-1264840-889	Кагоцел-5	557
M-1264840-952	Нурофен-3	276
M-1264841-016	Кагоцел-6	1364
M-1264841-078	Цитрамон-5	529
M-1264858-724	Нурофен-4	1229
M-1264858-783	Мексидол-6	967
M-2117675-583	Нурофен-21	1335
M-2118352-296	Кагоцел-80	624
M-2118463-245	Мирамистин-14	858
M-2119047-330	Мирамистин-29	1227
M-2119214-892	Цитрамон-60	453
M-2119222-638	Мексидол-71	465
M-2119226-904	Нурофен-81	1203
M-2119230-376	Мексидол-62	921
M-2119317-730	Цитрамон-39	1452
M-2119370-788	Мексидол-43	1088
M-2119373-939	Цитрамон-25	566
M-2119461-385	Кагоцел-54	1271
M-2119463-714	Мексидол-31	1068
M-2119474-090	Нурофен-22	312
M-2119837-019	Кагоцел-72	282
M-2124715-339	Нурофен-32	1154
M-2124838-922	Мексидол-7	1029
M-2125037-043	Нурофен-36	699
M-2125204-674	Кагоцел-37	1390
M-2125432-730	Мексидол-64	821
M-2125564-210	Мирамистин-21	160
M-2125758-161	Кагоцел-16	1156
M-2126080-537	Нурофен-44	495
M-2126114-336	Мирамистин-99	1195
M-2126145-948	Цитрамон-42	872
M-2126155-856	Мексидол-25	574
M-2126161-514	Цитрамон-64	1244
M-2126164-182	Нурофен-64	328
M-2126167-030	Кагоцел-46	433
M-2126170-103	Нурофен-75	492
M-2126243-085	Кагоцел-45	1051
M-2126298-759	Мирамистин-31	347
M-2126578-574	Нурофен-100	267
M-2126711-992	Кагоцел-56	550
M-2126785-272	Мексидол-15	428
M-2126795-693	Цитрамон-48	657
M-2126808-903	Мексидол-43	804
M-2126824-841	Мексидол-3	442
M-2126828-292	Цитрамон-84	680
M-2127395-900	Нурофен-25	552
M-2127456-985	Нурофен-8	965
M-2127482-091	Мексидол-91	712
M-2127491-278	Нурофен-81	450
M-2127491-786	Нурофен-32	1065
M-2127492-337	Нурофен-4	514
M-2127523-460	Мирамистин-69	300
M-2127669-770	Мексидол-8	799
M-2127772-848	Мирамистин-54	1431
M-2127831-153	Кагоцел-74	1103
M-2127982-481	Мексидол-77	1208
M-2127986-173	Кагоцел-46	947
M-2127989-482	Мирамистин-68	999
M-2127999-140	Нурофен-92	249
M-2128003-660	Мексидол-81	1444
M-2128007-031	Нурофен-16	305
M-2128046-426	Цитрамон-55	210
M-2128049-648	Мексидол-41	637
M-2128053-787	Мирамистин-56	301
M-2128125-329	Кагоцел-93	321
M-2128206-882	Цитрамон-54	494
M-2142108-159	Кагоцел-66	1062
M-2142124-828	Цитрамон-95	697
M-2142145-151	Кагоцел-86	1182
M-2142150-673	Мирамистин-23	609
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
P-1186130-938	Руслан	Гительман	ячеславович	болото	228
P-1195235-027	р8нгирт8н	р8и7н	87нр	р8и7н7	р8р87
P-1196612-039	Петька	Антошкин	Абобусович	ул. Первомайская, д. 6, кв. 63	+79866334531
P-1196612-095	Антошка	Антошкин	Амогусович	ул. Полевая, д. 83, кв. 19	+79301919177
P-1196612-157	Ванёк	Петькин	Абобусович	ул. Ю-Р.Г. Эрвье, д. 90, кв. 37	+79173241957
P-1196612-220	Ванёк	Ванькин	Кринжевич	ул. Газовиков, д. 88, кв. 41	+79650414588
P-1196612-281	Антошка	Антошкин	Амогусович	ул. Мельникайте, д. 40, кв. 32	+79478591753
P-1196612-349	Олежа	Антошкин	Амогусович	ул. Широтная, д. 2, кв. 81	+79011464833
P-1196612-405	Ванёк	Олежкин	Абобусович	ул. Тихий проезд, д. 38, кв. 99	+79100062811
P-1196612-468	Олежа	Олежкин	Кринжевич	ул. Ленина, д. 88, кв. 87	+79093293144
P-1196612-532	Антошка	Антошкин	Кринжевич	ул. Республики, д. 81, кв. 33	+79663825636
P-1196612-591	Антошка	Петькин	Амогусович	ул. Полевая, д. 66, кв. 42	+79689547961
P-1264077-479	Ванёк	Ванькин	Амогусович	ул. Газовиков, д. 26, кв. 2	+79529774930
P-1264077-564	Олежа	Олежкин	Абобусович	ул. Тихий проезд, д. 39, кв. 93	+79670040999
P-1264077-628	Петька	Олежкин	Абобусович	ул. Революции, д. 54, кв. 80	+79179740320
P-1264077-689	Петька	Антошкин	Кринжевич	ул. Широтная, д. 29, кв. 51	+79504083111
P-1264077-753	Ванёк	Ванькин	Амогусович	ул. Ю-Р.Г. Эрвье, д. 24, кв. 27	+79434905883
P-1264077-816	Ванёк	Петькин	Абобусович	ул. Тихий проезд, д. 29, кв. 33	+79778315238
P-1264077-878	Антошка	Ванькин	Абобусович	ул. Перекопская, д. 1, кв. 54	+79247686435
P-1264077-941	Антошка	Ванькин	Абобусович	ул. Мельникайте, д. 96, кв. 37	+79411891986
P-1264078-004	Антошка	Олежкин	Амогусович	ул. Перекопская, д. 57, кв. 39	+79268587429
P-1264078-068	Антошка	Олежкин	Абобусович	ул. Мельникайте, д. 69, кв. 53	+79378244701
P-1264088-248	Петька	Олежкин	Кринжевич	ул. Газовиков, д. 58, кв. 84	+79460927161
P-1264088-310	Петька	Антошкин	Амогусович	ул. Широтная, д. 22, кв. 67	+79802216777
P-1264088-372	Петька	Ванькин	Абобусович	ул. Ю-Р.Г. Эрвье, д. 88, кв. 43	+79823421829
P-1264088-435	Антошка	Ванькин	Абобусович	ул. Полевая, д. 16, кв. 87	+79415039904
P-1264088-499	Олежа	Олежкин	Абобусович	ул. Мельникайте, д. 78, кв. 81	+79203917339
P-1264088-562	Олежа	Антошкин	Абобусович	ул. Газовиков, д. 39, кв. 36	+79588000380
P-1264088-625	Олежа	Олежкин	Кринжевич	ул. Газовиков, д. 17, кв. 98	+79479813289
P-1264088-688	Петька	Антошкин	Кринжевич	ул. Ю-Р.Г. Эрвье, д. 39, кв. 38	+79915910403
P-1264088-754	Олежа	Олежкин	Амогусович	ул. Перекопская, д. 17, кв. 66	+79399269673
P-1264088-816	Антошка	Олежкин	Абобусович	ул. Ю-Р.Г. Эрвье, д. 77, кв. 53	+79618410866
P-1264840-517	Олежа	Антошкин	Кринжевич	ул. Первомайская, д. 82, кв. 82	+79751460233
P-1264840-592	Олежа	Ванькин	Амогусович	ул. Ю-Р.Г. Эрвье, д. 18, кв. 72	+79434643301
P-1264840-654	Антошка	Олежкин	Абобусович	ул. Газовиков, д. 96, кв. 87	+79279983428
P-1264840-717	Олежа	Антошкин	Кринжевич	ул. Перекопская, д. 35, кв. 24	+79256804610
P-1264840-779	Антошка	Антошкин	Амогусович	ул. Широтная, д. 30, кв. 46	+79866187327
P-1264840-841	Ванёк	Петькин	Кринжевич	ул. Ю-Р.Г. Эрвье, д. 64, кв. 45	+79720879825
P-1264840-904	Ванёк	Олежкин	Абобусович	ул. Ленина, д. 85, кв. 48	+79832070520
P-1264840-967	Олежа	Петькин	Абобусович	ул. Мельникайте, д. 43, кв. 10	+79559628827
P-1264841-031	Петька	Петькин	Амогусович	ул. Широтная, д. 38, кв. 47	+79590488191
P-1264841-093	Антошка	Антошкин	Кринжевич	ул. Первомайская, д. 94, кв. 64	+79523143810
P-1264858-735	Петька	Петькин	Амогусович	ул. Широтная, д. 78, кв. 31	+79701194911
P-1264858-796	Олежа	Антошкин	Амогусович	ул. Ю-Р.Г. Эрвье, д. 15, кв. 94	+79039302328
P-2117675-600	Петька	Олежкин	Кринжевич	ул. Ю-Р.Г. Эрвье, д. 52, кв. 50	+79689652085
P-2118352-311	Антошка	Петькин	Абобусович	ул. Революции, д. 68, кв. 76	+79152202274
P-2118463-266	Олежа	Антошкин	Кринжевич	ул. Революции, д. 42, кв. 65	+79349039638
P-2119047-341	Олежа	Ванькин	Кринжевич	ул. Революции, д. 62, кв. 64	+79663076167
P-2119214-909	Олежа	Антошкин	Кринжевич	ул. Революции, д. 45, кв. 7	+79488267550
P-2119222-647	Олежа	Ванькин	Кринжевич	ул. Первомайская, д. 54, кв. 46	+79407546736
P-2119226-918	Олежа	Антошкин	Амогусович	ул. Первомайская, д. 39, кв. 59	+79501677343
P-2119230-387	Петька	Петькин	Амогусович	ул. Республики, д. 64, кв. 68	+79762580181
P-2119317-736	Петька	Антошкин	Кринжевич	ул. Тихий проезд, д. 71, кв. 33	+79962272906
P-2119370-793	Олежа	Антошкин	Амогусович	ул. Газовиков, д. 15, кв. 68	+79201532305
P-2119373-954	Олежа	Петькин	Кринжевич	ул. Широтная, д. 23, кв. 20	+79277393414
P-2119461-394	Ванёк	Петькин	Абобусович	ул. Революции, д. 89, кв. 8	+79895386067
P-2119463-735	Петька	Петькин	Абобусович	ул. Широтная, д. 70, кв. 34	+79252543400
P-2119474-097	Ванёк	Антошкин	Абобусович	ул. Широтная, д. 68, кв. 86	+79548939000
P-2119837-033	Ванёк	Петькин	Абобусович	ул. Газовиков, д. 86, кв. 90	+79423561003
P-2124715-356	Антошка	Петькин	Амогусович	ул. Республики, д. 4, кв. 86	+79982099240
P-2124838-937	Петька	Петькин	Абобусович	ул. Перекопская, д. 4, кв. 78	+79326917530
P-2125037-059	Олежа	Ванькин	Абобусович	ул. Мельникайте, д. 86, кв. 49	+79499797610
P-2125204-692	Ванёк	Олежкин	Амогусович	ул. Мельникайте, д. 92, кв. 32	+79370655443
P-2125432-744	Антошка	Петькин	Кринжевич	ул. Широтная, д. 33, кв. 54	+79815819059
P-2125564-224	Петька	Антошкин	Абобусович	ул. Перекопская, д. 40, кв. 98	+79612991935
P-2125758-178	Олежа	Петькин	Абобусович	ул. Ю-Р.Г. Эрвье, д. 43, кв. 2	+79101416497
P-2126080-547	Олежа	Антошкин	Абобусович	ул. Первомайская, д. 11, кв. 16	+79494751091
P-2126114-345	Петька	Антошкин	Абобусович	ул. Первомайская, д. 76, кв. 35	+79521020367
P-2126145-960	Ванёк	Петькин	Абобусович	ул. Газовиков, д. 38, кв. 37	+79604105869
P-2126155-865	Ванёк	Антошкин	Амогусович	ул. Ленина, д. 99, кв. 26	+79327125177
P-2126161-519	Ванёк	Антошкин	Кринжевич	ул. Газовиков, д. 2, кв. 52	+79185006128
P-2126164-186	Олежа	Антошкин	Амогусович	ул. Широтная, д. 71, кв. 2	+79038521661
P-2126167-034	Олежа	Олежкин	Абобусович	ул. Тихий проезд, д. 8, кв. 42	+79976759542
P-2126170-115	Олежа	Ванькин	Абобусович	ул. Ленина, д. 53, кв. 91	+79343432402
P-2126243-094	Ванёк	Антошкин	Абобусович	ул. Революции, д. 14, кв. 62	+79332150641
P-2126298-773	Ванёк	Олежкин	Амогусович	ул. Республики, д. 10, кв. 95	+79940098533
P-2126578-591	Петька	Ванькин	Абобусович	ул. Ленина, д. 91, кв. 37	+79835454259
P-2126711-996	Антошка	Антошкин	Абобусович	ул. Перекопская, д. 82, кв. 58	+79350808185
P-2126785-291	Антошка	Олежкин	Кринжевич	ул. Широтная, д. 89, кв. 54	+79713945934
P-2126795-704	Олежа	Антошкин	Абобусович	ул. Первомайская, д. 32, кв. 9	+79515696757
P-2126808-918	Петька	Петькин	Кринжевич	ул. Революции, д. 49, кв. 54	+79156290192
P-2126824-845	Ванёк	Олежкин	Кринжевич	ул. Перекопская, д. 77, кв. 98	+79881848647
P-2126828-305	Ванёк	Антошкин	Кринжевич	ул. Революции, д. 72, кв. 48	+79709698432
P-2127395-906	Ванёк	Олежкин	Кринжевич	ул. Республики, д. 31, кв. 82	+79765819366
P-2127456-992	Ванёк	Олежкин	Кринжевич	ул. Ю-Р.Г. Эрвье, д. 42, кв. 73	+79313815435
P-2127482-105	Антошка	Ванькин	Кринжевич	ул. Тихий проезд, д. 30, кв. 2	+79297470296
P-2127491-293	Ванёк	Антошкин	Абобусович	ул. Ленина, д. 79, кв. 43	+79236723507
P-2127491-800	Антошка	Ванькин	Абобусович	ул. Газовиков, д. 65, кв. 14	+79381424722
P-2127492-353	Олежа	Антошкин	Амогусович	ул. Газовиков, д. 39, кв. 17	+79233155641
P-2127523-474	Антошка	Олежкин	Амогусович	ул. Газовиков, д. 20, кв. 83	+79976495374
P-2127669-781	Антошка	Олежкин	Амогусович	ул. Ленина, д. 89, кв. 96	+79719516481
P-2127772-866	Олежа	Ванькин	Абобусович	ул. Полевая, д. 86, кв. 34	+79159818053
P-2127831-164	Петька	Олежкин	Абобусович	ул. Республики, д. 76, кв. 13	+79050866098
P-2127982-494	Петька	Петькин	Кринжевич	ул. Тихий проезд, д. 43, кв. 21	+79757323615
P-2127986-186	Ванёк	Ванькин	Абобусович	ул. Широтная, д. 60, кв. 38	+79550518429
P-2127989-493	Олежа	Олежкин	Амогусович	ул. Широтная, д. 66, кв. 12	+79436617243
P-2127999-150	Петька	Антошкин	Амогусович	ул. Революции, д. 61, кв. 79	+79246372475
P-2128003-676	Антошка	Антошкин	Амогусович	ул. Газовиков, д. 26, кв. 10	+79839331709
P-2128007-038	Петька	Антошкин	Амогусович	ул. Первомайская, д. 65, кв. 82	+79472547705
P-2128046-442	Антошка	Ванькин	Амогусович	ул. Широтная, д. 79, кв. 82	+79310033659
P-2128049-658	Петька	Ванькин	Абобусович	ул. Мельникайте, д. 7, кв. 72	+79990946688
P-2128053-804	Петька	Антошкин	Амогусович	ул. Полевая, д. 16, кв. 25	+79868170268
P-2128125-341	Олежа	Ванькин	Кринжевич	ул. Революции, д. 4, кв. 12	+79943868031
P-2128206-886	Петька	Антошкин	Амогусович	ул. Республики, д. 12, кв. 59	+79326586840
P-2142108-169	Ванёк	Петькин	Кринжевич	ул. Широтная, д. 46, кв. 89	+79542687535
P-2142124-845	Петька	Олежкин	Амогусович	ул. Ю-Р.Г. Эрвье, д. 47, кв. 39	+79042063618
P-2142145-165	Ванёк	Олежкин	Абобусович	ул. Широтная, д. 74, кв. 41	+79283466291
P-2142150-688	Антошка	Ванькин	Абобусович	ул. Мельникайте, д. 85, кв. 77	+79807475220
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
S-1196612-050	Петька	Олежкин	Абобусович	офтальмолог	ул. Газовиков, д. 54, кв. 28	+79026689787
S-1196612-111	Ванёк	Петькин	Кринжевич	офтальмолог	ул. Ленина, д. 63, кв. 69	+79001366417
S-1196612-173	Антошка	Олежкин	Амогусович	стоматолог	ул. Республики, д. 23, кв. 88	+79269805390
S-1196612-235	Антошка	Петькин	Абобусович	стоматолог	ул. Ленина, д. 34, кв. 26	+79553273510
S-1196612-297	Ванёк	Антошкин	Абобусович	офтальмолог	ул. Революции, д. 81, кв. 45	+79264400121
S-1196612-359	Петька	Олежкин	Амогусович	хирург	ул. Перекопская, д. 10, кв. 3	+79813509866
S-1196612-427	Антошка	Олежкин	Амогусович	ортопед	ул. Первомайская, д. 81, кв. 88	+79237972111
S-1196612-483	Петька	Ванькин	Амогусович	терапевт	ул. Революции, д. 9, кв. 8	+79939483397
S-1196612-545	Ванёк	Петькин	Амогусович	хирург	ул. Тихий проезд, д. 95, кв. 85	+79780848913
S-1196612-607	Ванёк	Ванькин	Абобусович	хирург	ул. Первомайская, д. 82, кв. 90	+79730597018
S-1264077-499	Олежа	Петькин	Абобусович	терапевт	ул. Революции, д. 71, кв. 64	+79931075835
S-1264077-580	Петька	Олежкин	Абобусович	терапевт	ул. Первомайская, д. 95, кв. 48	+79339239345
S-1264077-643	Ванёк	Ванькин	Амогусович	терапевт	ул. Тихий проезд, д. 28, кв. 12	+79110004682
S-1264077-706	Петька	Антошкин	Кринжевич	стоматолог	ул. Ю-Р.Г. Эрвье, д. 30, кв. 23	+79815406406
S-1264077-769	Ванёк	Антошкин	Амогусович	ортопед	ул. Первомайская, д. 28, кв. 57	+79914661664
S-1264077-831	Олежа	Антошкин	Абобусович	стоматолог	ул. Широтная, д. 67, кв. 25	+79365118747
S-1264077-894	Петька	Олежкин	Абобусович	терапевт	ул. Ленина, д. 64, кв. 46	+79566978759
S-1264077-957	Олежа	Петькин	Абобусович	офтальмолог	ул. Газовиков, д. 27, кв. 93	+79536599892
S-1264078-021	Антошка	Олежкин	Амогусович	хирург	ул. Ю-Р.Г. Эрвье, д. 9, кв. 49	+79869018190
S-1264078-084	Ванёк	Олежкин	Амогусович	ортопед	ул. Широтная, д. 63, кв. 34	+79335039700
S-1264088-263	Олежа	Петькин	Кринжевич	офтальмолог	ул. Мельникайте, д. 13, кв. 47	+79858838769
S-1264088-326	Петька	Олежкин	Абобусович	ортопед	ул. Первомайская, д. 16, кв. 29	+79732031281
S-1264088-388	Петька	Ванькин	Абобусович	офтальмолог	ул. Ю-Р.Г. Эрвье, д. 38, кв. 45	+79458748371
S-1264088-451	Петька	Ванькин	Амогусович	ортопед	ул. Революции, д. 66, кв. 33	+79816225969
S-1264088-515	Олежа	Олежкин	Абобусович	терапевт	ул. Республики, д. 49, кв. 20	+79844972996
S-1264088-579	Олежа	Олежкин	Амогусович	офтальмолог	ул. Широтная, д. 40, кв. 94	+79354413593
S-1264088-641	Антошка	Петькин	Амогусович	офтальмолог	ул. Газовиков, д. 73, кв. 74	+79124713560
S-1264088-705	Олежа	Ванькин	Абобусович	стоматолог	ул. Республики, д. 51, кв. 57	+79727656250
S-1264088-768	Антошка	Ванькин	Кринжевич	хирург	ул. Ю-Р.Г. Эрвье, д. 28, кв. 23	+79210321102
S-1264088-832	Антошка	Петькин	Абобусович	терапевт	ул. Полевая, д. 39, кв. 13	+79782402028
S-1264840-541	Антошка	Ванькин	Амогусович	ортопед	ул. Республики, д. 90, кв. 51	+79743991645
S-1264840-608	Олежа	Олежкин	Абобусович	офтальмолог	ул. Перекопская, д. 65, кв. 51	+79271860415
S-1264840-670	Ванёк	Ванькин	Кринжевич	терапевт	ул. Газовиков, д. 98, кв. 39	+79370572878
S-1264840-732	Ванёк	Ванькин	Абобусович	терапевт	ул. Перекопская, д. 83, кв. 93	+79801618073
S-1264840-794	Петька	Олежкин	Абобусович	ортопед	ул. Ленина, д. 96, кв. 27	+79046726046
S-1264840-857	Ванёк	Олежкин	Кринжевич	офтальмолог	ул. Первомайская, д. 73, кв. 60	+79299604383
S-1264840-920	Антошка	Петькин	Абобусович	стоматолог	ул. Ленина, д. 41, кв. 87	+79256357660
S-1264840-984	Ванёк	Петькин	Абобусович	офтальмолог	ул. Первомайская, д. 47, кв. 19	+79110395266
S-1264841-048	Олежа	Антошкин	Абобусович	хирург	ул. Ю-Р.Г. Эрвье, д. 50, кв. 72	+79874293467
S-1264841-109	Олежа	Антошкин	Абобусович	хирург	ул. Революции, д. 32, кв. 39	+79120554554
S-1264858-751	Ванёк	Олежкин	Амогусович	хирург	ул. Широтная, д. 69, кв. 52	+79362691836
S-1264858-811	Олежа	Олежкин	Кринжевич	ортопед	ул. Ю-Р.Г. Эрвье, д. 98, кв. 93	+79980020840
S-2117675-618	Ванёк	Антошкин	Кринжевич	терапевт	ул. Мельникайте, д. 99, кв. 20	+79783045462
S-2118352-326	Олежа	Антошкин	Кринжевич	офтальмолог	ул. Ю-Р.Г. Эрвье, д. 46, кв. 84	+79584930273
S-2118463-279	Ванёк	Антошкин	Кринжевич	офтальмолог	ул. Республики, д. 38, кв. 44	+79097717081
S-2119047-356	Олежа	Петькин	Амогусович	терапевт	ул. Газовиков, д. 30, кв. 76	+79793161352
S-2119214-926	Ванёк	Ванькин	Кринжевич	ортопед	ул. Революции, д. 78, кв. 32	+79349164936
S-2119222-663	Антошка	Ванькин	Абобусович	терапевт	ул. Республики, д. 12, кв. 75	+79071164032
S-2119226-934	Ванёк	Олежкин	Кринжевич	ортопед	ул. Мельникайте, д. 55, кв. 85	+79432819098
S-2119230-403	Петька	Антошкин	Амогусович	ортопед	ул. Республики, д. 10, кв. 96	+79422575772
S-2119317-755	Антошка	Ванькин	Абобусович	терапевт	ул. Первомайская, д. 39, кв. 52	+79216738010
S-2119370-809	Ванёк	Антошкин	Амогусович	ортопед	ул. Революции, д. 83, кв. 66	+79870059677
S-2119373-970	Ванёк	Ванькин	Кринжевич	терапевт	ул. Республики, д. 100, кв. 48	+79438056607
S-2119461-410	Петька	Ванькин	Кринжевич	офтальмолог	ул. Тихий проезд, д. 36, кв. 28	+79755561246
S-2119463-744	Петька	Ванькин	Абобусович	терапевт	ул. Мельникайте, д. 48, кв. 22	+79669074974
S-2119474-113	Антошка	Антошкин	Абобусович	офтальмолог	ул. Ю-Р.Г. Эрвье, д. 14, кв. 14	+79827582058
S-2119837-048	Олежа	Ванькин	Абобусович	ортопед	ул. Газовиков, д. 90, кв. 62	+79834718919
S-2124715-372	Петька	Петькин	Абобусович	хирург	ул. Тихий проезд, д. 22, кв. 36	+79894294729
S-2124838-951	Антошка	Петькин	Амогусович	хирург	ул. Ю-Р.Г. Эрвье, д. 43, кв. 17	+79068005568
S-2125037-075	Петька	Ванькин	Амогусович	стоматолог	ул. Широтная, д. 3, кв. 50	+79918579941
S-2125204-708	Ванёк	Ванькин	Абобусович	офтальмолог	ул. Широтная, д. 53, кв. 56	+79146359078
S-2125432-760	Петька	Ванькин	Амогусович	хирург	ул. Республики, д. 27, кв. 100	+79313278102
S-2125564-239	Олежа	Ванькин	Кринжевич	ортопед	ул. Широтная, д. 93, кв. 63	+79125749777
S-2125758-193	Антошка	Антошкин	Амогусович	ортопед	ул. Полевая, д. 99, кв. 43	+79244159509
S-2126080-563	Петька	Олежкин	Абобусович	офтальмолог	ул. Первомайская, д. 31, кв. 68	+79142795082
S-2126114-359	Олежа	Петькин	Кринжевич	хирург	ул. Широтная, д. 45, кв. 92	+79524259989
S-2126145-975	Ванёк	Олежкин	Кринжевич	офтальмолог	ул. Перекопская, д. 7, кв. 18	+79407936133
S-2126155-880	Ванёк	Петькин	Абобусович	терапевт	ул. Мельникайте, д. 47, кв. 15	+79359769297
S-2126161-536	Олежа	Антошкин	Амогусович	терапевт	ул. Газовиков, д. 42, кв. 8	+79422986511
S-2126164-202	Ванёк	Ванькин	Абобусович	офтальмолог	ул. Тихий проезд, д. 10, кв. 60	+79992582350
S-2126167-052	Петька	Петькин	Кринжевич	хирург	ул. Республики, д. 76, кв. 78	+79263408042
S-2126170-131	Олежа	Ванькин	Абобусович	ортопед	ул. Широтная, д. 75, кв. 84	+79966472534
S-2126243-111	Антошка	Антошкин	Кринжевич	офтальмолог	ул. Широтная, д. 38, кв. 52	+79888183144
S-2126298-789	Антошка	Петькин	Амогусович	офтальмолог	ул. Мельникайте, д. 28, кв. 77	+79558793973
S-2126578-608	Олежа	Антошкин	Амогусович	стоматолог	ул. Перекопская, д. 85, кв. 10	+79872289395
S-2126712-012	Ванёк	Олежкин	Кринжевич	офтальмолог	ул. Перекопская, д. 83, кв. 23	+79466090808
S-2126785-305	Олежа	Олежкин	Абобусович	терапевт	ул. Ленина, д. 8, кв. 16	+79347047826
S-2126795-720	Олежа	Петькин	Амогусович	хирург	ул. Ленина, д. 80, кв. 74	+79992950726
S-2126808-933	Петька	Петькин	Амогусович	ортопед	ул. Ю-Р.Г. Эрвье, д. 86, кв. 63	+79666696878
S-2126824-863	Ванёк	Олежкин	Абобусович	терапевт	ул. Газовиков, д. 24, кв. 10	+79168686688
S-2126828-321	Олежа	Ванькин	Кринжевич	офтальмолог	ул. Ленина, д. 2, кв. 84	+79775920030
S-2127395-921	Антошка	Антошкин	Кринжевич	офтальмолог	ул. Газовиков, д. 86, кв. 5	+79343674421
S-2127457-007	Олежа	Антошкин	Кринжевич	офтальмолог	ул. Мельникайте, д. 9, кв. 21	+79443345813
S-2127482-121	Олежа	Ванькин	Амогусович	хирург	ул. Перекопская, д. 39, кв. 100	+79800234075
S-2127491-308	Ванёк	Ванькин	Кринжевич	хирург	ул. Ю-Р.Г. Эрвье, д. 66, кв. 89	+79984521926
S-2127491-816	Олежа	Антошкин	Абобусович	терапевт	ул. Газовиков, д. 20, кв. 6	+79518801586
S-2127492-370	Антошка	Петькин	Кринжевич	ортопед	ул. Широтная, д. 94, кв. 55	+79847930091
S-2127523-489	Олежа	Антошкин	Кринжевич	офтальмолог	ул. Перекопская, д. 20, кв. 36	+79066860019
S-2127669-796	Ванёк	Антошкин	Абобусович	хирург	ул. Перекопская, д. 79, кв. 1	+79916210869
S-2127772-882	Антошка	Ванькин	Кринжевич	терапевт	ул. Ленина, д. 76, кв. 7	+79802661541
S-2127831-179	Олежа	Ванькин	Кринжевич	стоматолог	ул. Газовиков, д. 1, кв. 22	+79879521692
S-2127982-509	Ванёк	Антошкин	Абобусович	ортопед	ул. Полевая, д. 39, кв. 29	+79550137896
S-2127986-201	Ванёк	Антошкин	Амогусович	хирург	ул. Ленина, д. 59, кв. 89	+79971054397
S-2127989-508	Петька	Антошкин	Абобусович	стоматолог	ул. Полевая, д. 39, кв. 95	+79461404791
S-2127999-166	Петька	Олежкин	Кринжевич	терапевт	ул. Республики, д. 74, кв. 39	+79739652534
S-2128003-692	Олежа	Олежкин	Амогусович	хирург	ул. Перекопская, д. 59, кв. 82	+79165941141
S-2128007-052	Петька	Антошкин	Абобусович	офтальмолог	ул. Революции, д. 34, кв. 59	+79855714422
S-2128046-458	Ванёк	Ванькин	Амогусович	офтальмолог	ул. Широтная, д. 21, кв. 73	+79890062864
S-2128049-675	Олежа	Олежкин	Кринжевич	офтальмолог	ул. Республики, д. 37, кв. 82	+79227715575
S-2128053-810	Антошка	Олежкин	Абобусович	офтальмолог	ул. Газовиков, д. 29, кв. 48	+79640115769
S-2128125-356	Олежа	Антошкин	Кринжевич	хирург	ул. Революции, д. 97, кв. 44	+79235124771
S-2128206-901	Ванёк	Ванькин	Амогусович	хирург	ул. Полевая, д. 42, кв. 36	+79940483862
S-2142108-184	Ванёк	Ванькин	Абобусович	ортопед	ул. Революции, д. 45, кв. 85	+79263358221
S-2142124-861	Ванёк	Антошкин	Амогусович	хирург	ул. Полевая, д. 30, кв. 55	+79923978193
S-2142145-179	Антошка	Олежкин	Абобусович	терапевт	ул. Ленина, д. 56, кв. 64	+79051886521
S-2142150-702	Олежа	Олежкин	Абобусович	терапевт	ул. Революции, д. 65, кв. 77	+79477124759
\.


--
-- Data for Name: Visit; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Visit" ("patient_ID", "specialist_ID", is_first, "visit_ID", date, anamnesis, diagnosis, treatment, drugs_cost, services_cost) FROM stdin;
P-2119837-033	S-299137-850	t	V-2127523-509	2022-11-25 14:58:43.518889+05	-	-	-	1203	955
P-298811-620	S-2119230-403	f	V-2127669-815	2022-11-25 15:01:09.826269+05	-	-	-	\N	573
P-1264840-904	S-2117675-618	t	V-2128125-376	2022-11-25 15:08:45.386064+05	-	-	-	\N	551
P-2126711-996	S-2125037-075	f	V-2127772-900	2022-11-25 15:02:52.911117+05	-	-	-	1533	899
P-1196612-220	S-1264078-021	f	V-2127831-197	2022-11-25 15:03:51.208319+05	-	-	-	1236	524
P-299137-971	S-1264077-831	t	V-2127982-528	2022-11-25 15:06:22.538887+05	-	-	-	632	990
P-2126161-519	S-298811-626	f	V-2127986-219	2022-11-25 15:06:26.230027+05	-	-	-	735	932
P-1264858-796	S-2124838-951	f	V-2127989-528	2022-11-25 15:06:29.537631+05	-	-	-	1203	603
P-2126785-291	S-298811-912	t	V-2127999-184	2022-11-25 15:06:39.194843+05	-	-	-	2969	819
P-2126167-034	S-1264088-515	f	V-2128003-712	2022-11-25 15:06:43.722012+05	-	-	-	518	853
P-298811-707	S-2126243-111	t	V-2128007-070	2022-11-25 15:06:47.081063+05	-	-	-	1061	975
P-2125564-224	S-238515-720	t	V-2128046-476	2022-11-25 15:07:26.486289+05	-	-	-	501782	674
P-1264077-941	S-238515-720	f	V-2128049-693	2022-11-25 15:07:29.702624+05	-	-	-	1815	824
P-2119370-793	S-247942-343	t	V-2128053-831	2022-11-25 15:07:33.837836+05	-	-	-	0	817
P-2126828-305	S-299137-850	t	V-2128206-921	2022-11-25 15:10:06.932497+05	-	-	-	\N	545
P-2127831-164	S-1264858-751	t	V-2142108-206	2022-11-25 19:01:48.21143+05	-	-	-	1490	607
P-1264841-093	S-2126167-052	t	V-2142124-882	2022-11-25 19:02:04.890265+05	-	-	-	1344	779
P-1264088-816	S-1264840-732	t	V-2142145-198	2022-11-25 19:02:25.207688+05	-	-	-	1068	576
P-2128125-341	S-1264088-326	t	V-2142150-720	2022-11-25 19:02:30.731475+05	-	-	-	2520	662
P-299138-157	S-2126824-863	f	V-2127482-138	2022-11-25 14:58:02.149392+05	-	-	-	\N	514
P-299138-110	S-1264858-751	t	V-2127491-328	2022-11-25 14:58:11.338327+05	-	-	-	\N	531
P-2126711-996	S-1264088-832	t	V-2127491-836	2022-11-25 14:58:11.846288+05	-	-	-	\N	865
P-1186130-938	S-1264088-579	f	V-2127492-389	2022-11-25 14:58:12.398954+05	-	-	-	\N	618
\.


--
-- Data for Name: Visit_Medicine; Type: TABLE DATA; Schema: main_schema; Owner: postgres
--

COPY main_schema."Visit_Medicine" ("visit_ID", "medicine_ID") FROM stdin;
V-2127482-138	M-2126808-903
V-2127482-138	M-1264077-988
V-2127491-328	M-1264088-484
V-2127491-328	M-2119461-385
V-2127491-836	M-2127482-091
V-2127491-836	M-2126578-574
V-2127492-389	M-2119214-892
V-2127492-389	M-2118352-296
V-2127523-509	M-2127523-460
V-2127523-509	M-1196612-391
V-2127669-815	M-2119463-714
V-2127669-815	M-1264840-577
V-2127669-815	M-1264077-926
V-2127772-900	M-2118463-245
V-2127772-900	M-2126164-182
V-2127772-900	M-2126298-759
V-2127831-197	M-1264840-764
V-2127982-528	M-2126164-182
V-2127982-528	M-1264077-675
V-2127986-219	M-2119214-892
V-2127986-219	M-2119837-019
V-2127989-528	M-2119226-904
V-2127999-184	M-2126161-514
V-2127999-184	M-1264840-485
V-2127999-184	M-1264840-889
V-2128003-712	M-1264077-863
V-2128007-070	M-1264088-546
V-2128046-476	M-123-123
V-2128046-476	M-1264088-800
V-2128046-476	M-1264088-736
V-2128049-693	M-2119222-638
V-2128049-693	M-1264077-926
V-2128049-693	M-1264840-577
V-2128053-831	M-1264840-702
V-2128053-831	M-2127456-985
V-2128125-376	M-1264077-675
V-2128206-921	M-2126711-992
V-2128206-921	M-1264858-724
V-2128206-921	M-2127491-786
V-2142108-206	M-2127982-481
V-2142108-206	M-2119837-019
V-2142124-882	M-1264840-952
V-2142124-882	M-2119463-714
V-2142145-198	M-2119463-714
V-2142150-720	M-2119463-714
V-2142150-720	M-2119317-730
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
-- PostgreSQL database dump complete
--

