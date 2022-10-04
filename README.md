# UTMN Database Management System
Assignments for UTMN Database Management System course (for one existing lab for now - Clinic)

## Task

A self-accounting clinic keeps a record of patients, their visits and the care provided by the specialists (doctors) of the clinic. 
There is a need to store information about all visits to the clinic by patients and which specialists they have seen.
Stored information about a self-supporting outpatient clinic and its patients can be grouped as follows:
- patient (medical history number, full name, home address, telephone number);
- specialist (personal number, full name, specialty, home address, telephone);
- visits (patient, specialist, first or repeat visit, date of visit, anamnesis, diagnosis, treatment, cost of medication, cost of services)
- an archive where the patient's information is transferred if a certain period of time (e.g. 3 years) has elapsed since their last visit.


## Config

### DB connection params

Note that you should specify your DB connection options (would be in separate file soon) if you want to use it for linking your DB connection:

   ```python
     DB_ARGS = {
      "dbname": dbname,
      "user": username,
      "password": password,
      "host": host,
      "options": ...,
    }
   ```
`password` var is stored in `secret.py` in root directory, you should change it by yourself (implement it soon).

## Structure 

### Planned:
<p align="center">
  <img src="https://i.imgur.com/U9554WZ.png" alt="Assignment's desirable ER-scheme">
</p>
     
### Current:
<p align="center">
  <img src="https://i.imgur.com/URhBiEV.png" alt="Assignment's current ER-scheme">
</p>

### Init schema
You can recreate the same model yourself by query `create_schema.sql`, or directly from the console by executing the following commands:
```sql
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
```
 
