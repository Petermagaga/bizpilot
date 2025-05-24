from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth.models import User
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated
from rest_framework import serializers


class RegisterView(APIView):
    permission_classes=[AllowAny]

    def post(self,request):
        username=request.data.get('username')
        password=request.data.get('password')


        if User.objects.filter(username=username).exists():
            return Response({'error':'username alreadly exists'},status=400)
        
        user=User.objects.create_user(username=username,password=password)
        refresh=RefreshToken.for_user(user)

        return Response({
            'refresh':str(refresh),
            'access':str(refresh.access_token),
        }, status=status.HTTP_201_CREATED )

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model=User
        fields=['id','username','email','first_name','last_name']

class UserMeView(APIView):
    permission__classes=[IsAuthenticated]

    def get(self, request):
        serializer=UserSerializer(request.user)
        return Response(serializer.data)