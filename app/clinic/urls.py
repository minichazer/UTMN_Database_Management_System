from django.contrib import admin
from django.urls import path
from app.clinicapp import views

urlpatterns = [
    path("admin/", admin.site.urls),
    path("add/patient", views.add_patient),
    path("populatedb/<int:count>", views.populatedb),
]
