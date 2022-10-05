CREATE SCHEMA main_schema;

CREATE TABLE main_schema."Archive" (
    "visit_ID" text NOT NULL,
    "patient_ID" text NOT NULL
);

CREATE TABLE main_schema."Patient" (
    "patient_ID" text NOT NULL,
    first_name text NOT NULL,
    second_name text NOT NULL,
    patronymic text,
    home_address text,
    phone_number text NOT NULL
);

CREATE TABLE main_schema."Specialist" (
    "specialist_ID" text NOT NULL,
    first_name text NOT NULL,
    second_name text NOT NULL,
    patronymic text,
    speciality text NOT NULL,
    home_address text,
    phone_number text NOT NULL
);

CREATE TABLE main_schema."Visit" (
    "patient_ID" text NOT NULL,
    "specialist_ID" text NOT NULL,
    is_first boolean NOT NULL,
    "case_ID" text NOT NULL,
    date date NOT NULL,
    anamnesis text,
    diagnosis text NOT NULL,
    treatment text,
    drugs_cost double precision,
    services_cost double precision NOT NULL
);

ALTER TABLE ONLY main_schema."Visit"
    ADD CONSTRAINT "CaseID" PRIMARY KEY ("case_ID");

ALTER TABLE ONLY main_schema."Patient"
    ADD CONSTRAINT "PatientID" PRIMARY KEY ("patient_ID");

ALTER TABLE ONLY main_schema."Specialist"
    ADD CONSTRAINT "SpecialistID" PRIMARY KEY ("specialist_ID");

ALTER TABLE ONLY main_schema."Visit"
    ADD CONSTRAINT "PatientID" FOREIGN KEY ("patient_ID") REFERENCES main_schema."Patient"("patient_ID");

ALTER TABLE ONLY main_schema."Visit"
    ADD CONSTRAINT "SpecialistID" FOREIGN KEY ("specialist_ID") REFERENCES main_schema."Specialist"("specialist_ID");

ALTER TABLE ONLY main_schema."Archive"
    ADD CONSTRAINT "VisitID" FOREIGN KEY ("visit_ID") REFERENCES main_schema."Visit"("case_ID");