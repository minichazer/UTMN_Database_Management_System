from django.contrib import admin
from django.urls import path
from app.clinicapp import views

urlpatterns = [
    path("admin/", admin.site.urls),
    path("add/add_patient", views.add_patient),
    path("populatedb/<int:count>", views.populatedb),
    path("populatedb_med/<int:count>", views.populatedb_med),
    path("base", views.base),

    path("login/", views.login),
    path("logout/", views.logout),
    path("register/", views.register),

    path("profile/<str:id>", views.profile),
    path("profile/", views.profile_r),
    path("patients/", views.patients),
    path("patient/<str:id>", views.patient),
    path("visit/<str:id>", views.visit),

    path("schedule/<str:id>", views.schedule),
    path("schedule/", views.schedule_r)
]
handler404 = 'app.clinicapp.views.handler404'
