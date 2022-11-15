# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


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
