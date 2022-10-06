INSERT INTO main_schema."Visit" ("patient_ID", "specialist_ID", is_first, "case_ID", date, anamnesis, diagnosis, treatment, drugs_cost, services_cost)
VALUES (%(patient_ID)s, %(specialist_ID)s, %(is_first)s, %(case_ID)s, %(date)s, %(anamnesis)s, %(diagnosis)s, %(treatment)s, %(drugs_cost)s, %(services_cost)s);
