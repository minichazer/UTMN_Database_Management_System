from dataclasses import replace
import datetime
import time
import random
from secret import password as pwd
import psycopg


# П - пациент, С - специалист, В - визит
ENTITY_TYPES = ["П", "С", "В"]


def get_current_timestamp() -> float:
    """ """
    return datetime.datetime.now().timestamp()


def get_timestamp(date: str) -> float:
    """ """
    return time.mktime(datetime.datetime.strptime(date, "%d/%m/%Y").timetuple())


def timestamps_difference(ts1: float, ts2: float) -> str:
    """ """
    return f"{round(abs(ts1 - ts2), 3):.3f}".replace(".", "-")


def create_entity(etype=random.choice(ENTITY_TYPES)) -> str:
    """ """
    ts_031022 = get_timestamp("03/10/2022")
    ts_today = get_current_timestamp()

    # delay to not intersect the same timestamp
    time.sleep(random.randint(1, 5) / 50)

    ID_date = timestamps_difference(ts_031022, ts_today)
    ID_entity_type = etype
    return f"{ID_entity_type}-{ID_date}"


def get_sql_content(filename: str) -> str:
    # content = ""
    with open(filename, "r") as f:
        content = f.read()
    return content


if __name__ == "__main__":

    args = {
        "dbname": "Clinic",
        "user": "postgres",
        "password": pwd,
        "host": "localhost",
        "options": "-c search_path=main_schema",
    }

    with psycopg.connect(**args) as conn:
        with conn.cursor() as cur:

            # query = "SELECT * FROM main_schema.test"
            # cursor.execute(query)

            # insert_row.sql
            # query = get_sql_content("insert_row.sql")
            # cur.execute(query, {"col1": "zxc3", "col2": 22813})

            # delete_row.sql
            # query = get_sql_content("delete_row.sql")
            # cur.execute(query, {"col1": "zxc1"})

            # select_row.sql
            # query = get_sql_content("select_row.sql")
            # cur.execute(query, {"col1": "superXD"})
            # result = cur.fetchone()
            # print(result)

            # update_row.sql
            # query = get_sql _content("update_row.sql")
            # cur.execute(query, {"change_what": "MEGAsuperXD", "change_res" : "superXD"})

            conn.commit()
