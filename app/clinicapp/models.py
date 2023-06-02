from django.db import models
from djongo import models as djongomodels

class User(models.Model):
    username = djongomodels.CharField(max_length=255, unique=True)
    password = djongomodels.CharField(max_length=255)

class Medicine(models.Model):
    medicine_id = models.TextField(
        db_column="medicine_ID"
    )  # Field name made lowercase.
    name = models.TextField()
    cost = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = "Medicine"


class Patient(models.Model):
    def __init__(self):
        self.patient_id = models.TextField(
            db_column="patient_ID"
        )  # Field name made lowercase.
        self.first_name = models.TextField()
        self.second_name = models.TextField()
        self.patronymic = models.TextField(blank=True, null=True)
        self.home_address = models.TextField(blank=True, null=True)
        self.phone_number = models.TextField()

    def info(self):
        return [
            self.patient_id,
            self.first_name,
            self.second_name,
            self.patronymic,
            self.home_address,
            self.phone_number,
        ]

    class Meta:
        managed = False
        db_table = "Patient"


class Specialist(models.Model):
    specialist_id = models.TextField(
        db_column="specialist_ID"
    )  # Field name made lowercase.
    first_name = models.TextField()
    second_name = models.TextField()
    patronymic = models.TextField(blank=True, null=True)
    speciality = models.TextField()
    home_address = models.TextField(blank=True, null=True)
    phone_number = models.TextField()

    class Meta:
        managed = False
        db_table = "Specialist"


class Visit(models.Model):
    patient_id = models.TextField(db_column="patient_ID")  # Field name made lowercase.
    specialist_id = models.TextField(
        db_column="specialist_ID"
    )  # Field name made lowercase.
    is_first = models.BooleanField()
    visit_id = models.TextField(db_column="visit_ID")  # Field name made lowercase.
    date = models.DateField()
    anamnesis = models.TextField(blank=True, null=True)
    diagnosis = models.TextField()
    treatment = models.TextField(blank=True, null=True)
    drugs_cost = models.FloatField(blank=True, null=True)
    services_cost = models.FloatField()

    class Meta:
        managed = False
        db_table = "Visit"


class VisitMedicine(models.Model):
    visit_id = models.TextField(db_column="visit_ID")  # Field name made lowercase.
    medicine_id = models.TextField(
        db_column="medicine_ID"
    )  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = "Visit_Medicine"
