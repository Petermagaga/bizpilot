from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView,TokenRefreshView
from .views import RegisterView, UserMeView

urlpatterns=[
    path('token/',TokenObtainPairView.as_view(),name='token_obtain_pair'),
    path('token/refresh/',TokenRefreshView.as_view(),name='token_refresh'),
    path('register/',RegisterView.as_view(),name='register'),
    path('users/me/',UserMeView.as_view(), name='user-me'),
]