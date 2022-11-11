# from django.conf import settings
# from graphene_django import DjangoObjectType
# from clinicapp import models
# import graphene

# class UserType(DjangoObjectType):
#     class Meta:
#         model = settings.AUTH_USER_MODEL

# class PatientType(DjangoObjectType):
#     class Meta:
#         model = models.Patient

# class Specialist(DjangoObjectType):
#     class Meta:
#         model = models.Specialist

# class Visit(DjangoObjectType):
#     class Meta:
#         model = models.Visit

# class VisitMedicine(DjangoObjectType):
#     class Meta:
#         model = models.VisitMedicine

# class Medicine(models.Model):
#     class Meta:
#         model = models.Medicine

# class Query(graphene.ObjectType):
#     all_patients = graphene.List(PatientType)

#     def resolve_all_patient(root, info):
#         return(models.Patient.objects.all())

# schema = graphene.Schema(query=Query)