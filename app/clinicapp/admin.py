from django.contrib import admin

from app.clinicapp.models import Patient, Medicine, Specialist, Visit, VisitMedicine


@admin.register(Patient)
class PatientAdmin(admin.ModelAdmin):
    model = Patient


@admin.register(Medicine)
class MedicineAdmin(admin.ModelAdmin):
    model = Medicine


@admin.register(Specialist)
class SpecialistAdmin(admin.ModelAdmin):
    model = Specialist


@admin.register(Visit)
class VisitAdmin(admin.ModelAdmin):
    model = Visit


@admin.register(VisitMedicine)
class VisitMedicineAdmin(admin.ModelAdmin):
    model = VisitMedicine
