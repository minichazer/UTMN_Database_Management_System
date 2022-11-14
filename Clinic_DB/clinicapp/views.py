from email.policy import default
from django.http import HttpResponse, HttpRequest
from telnetlib import STATUS
from django.shortcuts import render
from .forms import PatientForm
from .models import Patient, Visit, VisitMedicine, Specialist
import psycopg as pg
from clinic.settings import DB_ARGS
from functions import generate_entity_ID, populate


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

    return render(request, "Patient.html", {"form": patientform})

def populatedb(request: HttpRequest):
    if request.method == "GET":
        with pg.connect(**DB_ARGS) as conn:
                with conn.cursor() as cur:
                    populate(cur, 10)
                    print("ALO")
                    return HttpResponse("200")
    
    return render(request, "Populatedb.html")
