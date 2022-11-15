UPDATE "Patient"
SET "patient_ID" = _patient_id, first_name = _first_name, second_name = _second_name, patronymic = _patronymic, home_address = _home_address, phone_number = _phone_number
WHERE "patient_ID" LIKE _patient_ID;