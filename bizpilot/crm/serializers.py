from rest_framework import serializers
from .models import Customer,Task

class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = ['id', 'name', 'email', 'phone', 'company', 'notes', 'created_at']
        read_only_fields = ['owner', 'created_at']

class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model=Task
        fields='__all__'
        read_only_fields=['id','created_at','customer']
