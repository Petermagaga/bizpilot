from rest_framework import generics,permissions
from .models import Customer
from .serializers import CustomerSerializer

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
    
    
    
