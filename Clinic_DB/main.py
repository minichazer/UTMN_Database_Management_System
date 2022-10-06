import datetime as dt
import psycopg as pg
import random
import time
import os
from constants import ENTITY_TYPES, DB_ARGS, R_DATA


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
    ts_031022 = get_timestamp("03/10/2022")
    ts_today = get_current_timestamp()
    time.sleep(0.000001)

    ID_date = timestamps_difference(ts_031022, ts_today)
    ID_entity_type = etype
    return f"{ID_entity_type}-{ID_date}"


def get_sql_content(filename: str) -> str:
    """
    Parses the given filename and returns the content of file.
    """
    path = f"{os.getcwd()}\\Clinic_DB\\queries\\"
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
        patient_ID = 'SELECT "patient_ID" FROM main_schema."Patient" ORDER BY random() limit 1;'
        cursor.execute(patient_ID)
        (patient_ID,) = cursor.fetchone()

        specialist_ID = 'SELECT "specialist_ID" FROM main_schema."Specialist" ORDER BY random() limit 1;'
        cursor.execute(specialist_ID)
        (specialist_ID,) = cursor.fetchone()

        return {
            "patient_ID": patient_ID,
            "specialist_ID": specialist_ID,
            "is_first": random.choice([True, False]),
            "case_ID": generate_entity_ID("V"),
            "date": dt.date.today().strftime("%d/%m/%Y"),
            "anamnesis": "-",
            "diagnosis": "-",
            "treatment": "-",
            "drugs_cost": 0,
            "services_cost": random.randint(500, 1000),
        }


def populate(cursor: pg.cursor, n: int) -> None:
    """
    Creates random N entities (patient, specialist, todo: visits)
    and INSESRT generation to DB.
    """
    for i in range(n):
        patient = generate_entity(cursor, "P")
        create_entity(cursor, "patient", patient)

        specialist = generate_entity(cursor, "S")
        create_entity(cursor, "specialist", specialist)

        visit = generate_entity(cursor, "V")
        create_entity(cursor, "visit", visit)


def select_row(cursor: pg.cursor, table_name: str, eID: str) -> tuple:
    query = get_sql_content(f"select_{table_name}.sql")
    cursor.execute(query, {f"{table_name}_ID": eID})
    return cursor.fetchone()


def select_allrows(cursor: pg.cursor, table_name: str) -> list[tuple]:
    query = get_sql_content(f"select_table_{table_name}.sql")
    cursor.execute(query)
    return cursor.fetchall()


def delete_row(cursor: pg.cursor, table_name: str, eID: str) -> str:
    query = get_sql_content(f"delete_{table_name}.sql")
    cursor.execute(query, {f"{table_name}_ID": eID})
    return f"Rows affected: {cursor.rowcount}"


def clear_tables(cursor: pg.cursor) -> None:
    """
    Renew the schema by deleting all rows in all tables.
    """
    query = get_sql_content("clear_tables.sql")
    cursor.execute(query)
    return f"Rows affected: {cursor.rowcount}"


if __name__ == "__main__":
    with pg.connect(**DB_ARGS) as conn:
        with conn.cursor() as cur:

            # populate(cur, 2)

            # print(select_patient(cur, "P-247900-617"))
            # print(select_specialist(cur, "S-238515-688"))
            # print(select_visit(cur, "V-247900-695"))

            print(select_row(cur, "patient", "P-247900-617"))
            print(delete_row(cur, "patient", "1"))
            # print(select_allrows(cur, "visit"))

            # TODO:
            # implement choice menu for SQL queries
            # compare speed of named params and pre-formatted query (with args)

            conn.commit()
