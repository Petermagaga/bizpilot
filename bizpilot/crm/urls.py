from django.urls import path
from .views import CustomerListCreateView,CustomerRetrieveUpdateDestroyView,TaskCreateView, TaskListView

urlpatterns=[
    path('customers/',CustomerListCreateView.as_view(),name='customer-list-create'),
    path('customers/<int:pk>/',CustomerRetrieveUpdateDestroyView.as_view(),name='customer-detail'),
    path('customers/<int:pk>/tasks/create/',TaskCreateView.as_view(),name='create-task'),
    path('customers/<int:pk>/tasks/',TaskListView.as_view(), name='task-list'),
]