from django.urls import path
from .views import CreateCustomerView

urlpatterns=[
    path('customers/',CreateCustomerView.as_view(),name='create-customer'),
]