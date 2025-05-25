from django.db import models
from django.contrib.auth.models import User

class Customer(models.Model):
    owner=models.ForeignKey(User,on_delete=models.CASCADE,related_name='customers')
    name=models.CharField(max_length=100)
    email=models.EmailField()
    phone=models.CharField(max_length=100)
    notes= models.TextField(blank=True)
    created_at=models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name