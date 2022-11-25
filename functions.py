import datetime as dt
from datetime import timezone
import psycopg as pg
import random
import time
import os
from constants import ENTITY_TYPES, R_DATA


def get_current_timestamp() -> float:
    """
    Returns current date's timestamp.
    """
    return dt.datetime.now().timestamp()


def get_timestamp(date: str) -> float:
    """
    Returns date's timestamp.
    """
    return time.mktime(dt.datetime.strptime(date, "%d/%m/%Y").timetuple())


def timestamps_difference(ts1: float, ts2: float) -> str:
    """
    Gets the difference between two given timestamps and
    pre-format it for future using in entity creation.
    """
    return f"{round(abs(ts1 - ts2), 3):.3f}".replace(".", "-")


def generate_entity_ID(etype=random.choice(ENTITY_TYPES)) -> str:
    """
    Generates ID for entity of given type in format 'TYPE-TIMESTAMP'.
    """
    ts_011122 = get_timestamp("01/11/2022")
    ts_today = get_current_timestamp()
    time.sleep(0.000001)

    ID_date = timestamps_difference(ts_011122, ts_today)
    ID_entity_type = etype
    return f"{ID_entity_type}-{ID_date}"


def get_sql_content(filename: str) -> str:
    """
    Parses the given filename and returns the content of file.
    """
    path = f"{os.getcwd()}/queries/"
    with open(path + filename, "r") as f:
        content = f.read()
    return content


def create_entity(cursor: pg.cursor, entity_name: str, args: dict[str, str]) -> None:
    """
    Create a new row of entity type in its named table.
    """
    query = get_sql_content(f"create_{entity_name}.sql")
    cursor.execute(query, args)


def generate_entity(cursor: pg.cursor, etype: str) -> dict[str, str]:
    """
    Randomly generates data for an entity of given type.
    """
    if etype == "M":
        return {
            "medicine_ID": generate_entity_ID("M"),
            "name": random.choice(R_DATA["med_names"])
            + "-"
            + str(random.randint(2, 100)),
            "cost": random.randint(100, 1500),
        }

    if etype == "P":
        return {
            "patient_ID": generate_entity_ID("P"),
            "first_name": random.choice(R_DATA["first_names"]),
            "second_name": random.choice(R_DATA["second_names"]),
            "patronymic": random.choice(R_DATA["patronymic"]),
            "home_address": f"ул. {random.choice(R_DATA['streets'])}, д. {random.randint(1, 100)}, кв. {random.randint(1, 100)}",
            "phone_number": "+79"
            + "".join([str(random.randint(0, 9)) for i in range(9)]),
        }

    if etype == "S":
        return {
            "specialist_ID": generate_entity_ID("S"),
            "first_name": random.choice(R_DATA["first_names"]),
            "second_name": random.choice(R_DATA["second_names"]),
            "patronymic": random.choice(R_DATA["patronymic"]),
            "speciality": random.choice(R_DATA["speciality"]),
            "home_address": f"ул. {random.choice(R_DATA['streets'])}, д. {random.randint(1, 100)}, кв. {random.randint(1, 100)}",
            "phone_number": "+79"
            + "".join([str(random.randint(0, 9)) for i in range(9)]),
        }

    if etype == "V":
        patient_ID = (
            'SELECT "patient_ID" FROM main_schema."Patient" ORDER BY random() limit 1;'
        )
        cursor.execute(patient_ID)
        (patient_ID,) = cursor.fetchone()

        specialist_ID = 'SELECT "specialist_ID" FROM main_schema."Specialist" ORDER BY random() limit 1;'
        cursor.execute(specialist_ID)
        (specialist_ID,) = cursor.fetchone()

        return {
            "patient_ID": patient_ID,
            "specialist_ID": specialist_ID,
            "is_first": random.choice([True, False]),
            "visit_ID": generate_entity_ID("V"),
            "date": dt.datetime.now(timezone.utc),
            "anamnesis": "-",
            "diagnosis": "-",
            "treatment": "-",
            "drugs_cost": 0,
            "services_cost": random.randint(500, 1000),
        }


def populate(cursor: pg.cursor, n: int) -> None:
    """
    Creates random N entities (patient, specialist, visits, medicines)
    and INSERT generation to DB.
    """
    for i in range(n):
        medicine = generate_entity(cursor, "M")
        create_entity(cursor, "medicine", medicine)

        patient = generate_entity(cursor, "P")
        create_entity(cursor, "patient", patient)

        specialist = generate_entity(cursor, "S")
        create_entity(cursor, "specialist", specialist)

        visit = generate_entity(cursor, "V")
        create_entity(cursor, "visit", visit)

        # TODO: make a function to create Visit_Medicine row
        for j in range(1, random.randint(2, 4)):

            rand_medicine = cursor.execute(
                'SELECT "medicine_ID" FROM "Medicine" ORDER BY random() LIMIT 1;'
            )
            (rm,) = cursor.fetchone()

            visit_medicine = cursor.execute(
                'INSERT INTO "Visit_Medicine"("visit_ID", "medicine_ID") VALUES (%(lv)s, %(rm)s);',
                {"lv": visit["visit_ID"], "rm": rm},
            )

        # print(visit["visit_ID"], rm)
