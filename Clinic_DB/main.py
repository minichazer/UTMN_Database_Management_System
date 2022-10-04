import datetime
import psycopg
import random
import time
from secret import password


# П - пациент, С - специалист, В - визит
ENTITY_TYPES = ["П", "С", "В"]
DB_ARGS = {
    "dbname": "Clinic",
    "user": "postgres",
    "password": password,
    "host": "localhost",
    "options": "-c search_path=main_schema",
}


def get_current_timestamp() -> float:
    """
    Returns current date's timestamp.
    """
    return datetime.datetime.now().timestamp()


def get_timestamp(date: str) -> float:
    """
    Returns date's timestamp.
    """
    return time.mktime(datetime.datetime.strptime(date, "%d/%m/%Y").timetuple())


def timestamps_difference(ts1: float, ts2: float) -> str:
    """
    Gets the difference between two given timestamps and
    pre-format it for future using in entity creation.
    """
    return f"{round(abs(ts1 - ts2), 3):.3f}".replace(".", "-")


def create_entity(etype=random.choice(ENTITY_TYPES)) -> str:
    """
    Creates an instance (string for now) of given type entity.
    """
    ts_031022 = get_timestamp("03/10/2022")
    ts_today = get_current_timestamp()

    # delay to not intersect the same timestamp
    time.sleep(random.randint(1, 5) / 50)

    ID_date = timestamps_difference(ts_031022, ts_today)
    ID_entity_type = etype
    return f"{ID_entity_type}-{ID_date}"


def get_sql_content(filename: str) -> str:
    """
    Parses the given path and returns the content of file.
    """
    with open(filename, "r") as f:
        content = f.read()
    return content


if __name__ == "__main__":
    with psycopg.connect(**DB_ARGS) as conn:
        with conn.cursor() as cur:

            query = "SELECT * FROM test"
            cur.execute(query)

            # TODO: implement choice menu for SQL queries

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
