from django import forms


class PatientForm(forms.Form):
    # line below not used, as the ID generates in views.py
    # patient_id = forms.CharField(initial=uuid.uuid4, widget=forms.TextInput(attrs={"readonly": "readonly"}))

    first_name = forms.CharField()
    second_name = forms.CharField()
    patronymic = forms.CharField()
    home_address = forms.CharField()
    phone_number = forms.CharField()


class SpecialistForm(forms.Form):
    # specialist_id = forms.CharField(initial=uuid.uuid4, widget=forms.TextInput(attrs={"readonly": "readonly"}))

    first_name = forms.CharField()
    second_name = forms.CharField()
    patronymic = forms.CharField()
    speciality = forms.CharField()
    home_address = forms.CharField()
    phone_number = forms.CharField()


class VisitForm(forms.Form):
    # patient_id = forms.CharField(initial=uuid.uuid4, widget=forms.TextInput(attrs={"readonly": "readonly"}))
    # specialist_id = forms.CharField(initial=uuid.uuid4, widget=forms.TextInput(attrs={"readonly": "readonly"}))
    # visit_ID = forms.CharField(initial=uuid.uuid4, widget=forms.TextInput(attrs={"readonly": "readonly"}))
    is_first = forms.CharField()  # true / false
    date = forms.CharField()
    anamnesis = forms.CharField()
    diagnosis = forms.CharField()
    treatment = forms.CharField()
    drugs_cost = forms.CharField()
    service_cost = forms.CharField()
