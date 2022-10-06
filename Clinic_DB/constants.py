# P - пациент, P - специалист, V - визит
from secret import password

ENTITY_TYPES = ["P", "S", "V"]
DB_ARGS = {
    "dbname": "Clinic_DB",
    "user": "postgres",
    "password": password,
    "host": "localhost",
    "options": "-c search_path=main_schema",
}

R_DATA = {
    "first_names": ["Олежа", "Ванёк", "Петька", "Антошка"],
    "second_names": ["Олежкин", "Ванькин", "Петькин", "Антошкин"],
    "patronymic": ["Амогусович", "Абобусович", "Кринжевич"],
    "speciality": ["терапевт", "стоматолог", "хирург", "офтальмолог", "ортопед"],
    "streets": [
        "Ленина",
        "Республики",
        "Революции",
        "Тихий проезд",
        "Газовиков",
        "Ю-Р.Г. Эрвье",
        "Первомайская",
        "Перекопская",
        "Полевая",
        "Широтная",
        "Мельникайте",
    ],
}