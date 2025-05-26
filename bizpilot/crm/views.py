from rest_framework import generics,permissions
from .models import Customer,Task
from .serializers import CustomerSerializer,TaskSerializer
from django.shortcuts import get_object_or_404
class CustomerListCreateView(generics.ListCreateAPIView):
    serializer_class=CustomerSerializer
    permission_classes =[permissions.IsAuthenticated]

    def get_queryset(self):
        return Customer.objects.filter(owner=self.request.user)
    
    def perform_create(self,serializer):
        serializer.save(owner=self.request.user)

class CustomerRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class=CustomerSerializer
    permission_classes=[permissions.IsAuthenticated]

    def get_queryset(self):
        return Customer.objects.filter(owner=self.request.user)

class TaskCreateView(generics.CreateAPIView):
    serializer_class=TaskSerializer
    permission_classes=[permissions.IsAuthenticated]

    def perform_create(self, serializer):
        Customer_id=self.kwargs.get('pk')
        customer=get_object_or_404(Customer,id=Customer_id)
        serializer.save(customer=customer)

    
class TaskListView(generics.ListAPIView):
    serializer_class=TaskSerializer
    permission_classes=[permissions.IsAuthenticated]

    def get_queryset(self):
        customer_id=self.kwargs['pk']
        return Task.objects.filter(customer__id=customer_id).order_by('-due_date')
