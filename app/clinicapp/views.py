from django.http import HttpResponse, HttpRequest
from django.shortcuts import render
from .forms import PatientForm
from .models import Patient, Specialist, User
import psycopg as pg
from app.clinic.settings import DB_ARGS
from functions import generate_entity_ID, populate, populate_medicines
from django.db import connection
from django.shortcuts import render, redirect
from pymongo import MongoClient
from django.contrib.auth import authenticate, login
import uuid
import pymongo

mdb_client = MongoClient('mongodb://localhost:27017/')
mdb_db = mdb_client['clinicapp']
mdb_collection = mdb_db['credentials']


def handler404(request, *args, **argv):
    response = render(request, '404.html')
    response.status_code = 404

    return response

def register(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']


        new_user = {
            'id': f'{uuid.uuid4()}',
            'username': f'{username}',
            'password': f'{password}',
        }

        result = ""
        existing_user = mdb_collection.find_one({'username': username})
        if not existing_user:
            result = mdb_collection.insert_one(new_user)
            if result:
                print(f"В MongoDB успешно записался {new_user}/")
            else:
                print("MONGO FAILURE.")
        else:
            print("USER IS HERE ALREADY.")


        # user = User(username=username, password=password)
        # user.save()
        # print(f"В Django успешно записался {user}/")

        return redirect('/login')

    return render(request, 'register.html')


def login(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']

        # Django way
        # user = authenticate(request, username=username, password=password)
        # print(f"{username}, {password}, {user}")

        # MongoDB way
        user = User.objects.get(username=username)
        print(f"User {user} tried to login")

        # if user is not None:
        #     login(request, user)
        #     return redirect(f'/profile/{user.username}')
        # else:
        #     return render(request, 'login.html', {'error': 'Invalid login credentials.'})
        if user is not None and user.password == password:
            request.session['username'] = username
            print(f"Login success for {username}!")
            return redirect(f'/profile/{user.username}')
        else:
            print("Failure.")
            return render(request, 'login.html', {'error': 'Invalid login credentials.'})

    return render(request, 'login.html')


def logout(request: HttpRequest):
    return render(request, "logout.html")

def add_patient(request: HttpRequest):
    patientform = PatientForm()
    if request.method == "POST":
        patientform = PatientForm(request.POST)
        if patientform.is_valid():
            patient = Patient()
            patient.patient_id = generate_entity_ID("P")
            patient.first_name = request.POST.get("first_name")
            patient.second_name = request.POST.get("second_name")
            patient.patronymic = request.POST.get("patronymic")
            patient.home_address = request.POST.get("home_address")
            patient.phone_number = request.POST.get("phone_number")

            with pg.connect(**DB_ARGS) as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        "SELECT * FROM create_patient(%s, %s, %s, %s, %s, %s)",
                        patient.info(),
                    )
                    return HttpResponse("200")

    return render(request, "add_patient.html", {"form": patientform})


# TODO: make function to clear all tables in DB


def populatedb(request: HttpRequest, count: int):
    if request.method == "GET":
        with pg.connect(**DB_ARGS) as conn:
            with conn.cursor() as cur:
                populate(cur, count)
                return HttpResponse("200")

    return render(request, "populatedb.html")


def populatedb_med(request: HttpRequest, count: int):
    if request.method == "GET":
        with pg.connect(**DB_ARGS) as conn:
            with conn.cursor() as cur:
                populate_medicines(cur, count)
                return HttpResponse("200")

    return render(request, "populatedb.html")


def patients(request: HttpRequest):
    return render(request, "patients.html")


def patient(request: HttpRequest, id: str):
    # ID пациента
    return render(request, "patient.html")


def visit(request: HttpRequest, id: str):
    # ID визита
    return render(request, "visit.html")


def profile(request: HttpRequest, id: str):
    profile = "S-490680-442"

    def get_random_specialist():
        with connection.cursor() as cursor:

            cursor.execute('SELECT * FROM main_schema."Specialist" ORDER BY RANDOM() LIMIT 1')
            row = cursor.fetchone()[0]

            cursor.execute('SELECT * FROM main_schema."Specialist" WHERE "specialist_ID" = %s', [row])
            row = cursor.fetchone()
            return row
            # if row:
            #     # Преобразование результата в словарь (если нужно)
            #     columns = [col[0] for col in cursor.description]
            #     specialist_dict = dict(zip(columns, row))
            #     return specialist_dict
            # else:
            #     return None
    profile = get_random_specialist()
    print(profile)

    # ID врача
    return render(request, "profile.html", {'profile': {
        'specialist_id': profile[0],
        'first_name': profile[1],
        'second_name': profile[2],
        'speciality': profile[4],
        'home_address': profile[5],
        'phone_number': profile[6],
    }})
    # return render(request, "profile.html",
    #               {'specialist_id': profile,
    #                'FIO': 'Vasya Pupkin',
    #                'telephone': '+8 800 555 35 55',
    #                'address': 'The Planet Earth',
    #                'speciality': 'DOTER 2',
    # })


def schedule(request: HttpRequest, id: str):
    # ID врача
    return render(request, "schedule.html")

def schedule_r(request: HttpRequest):
    # ID врача
    return render(request, "schedule.html")

def profile_r(request: HttpRequest):
    return render(request, "profile.html")


def base(request: HttpRequest):
    return render(request, "base.html")
