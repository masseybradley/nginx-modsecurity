from django.db import models


class IPAddress(models.Model):
    ip_address = models.CharField(max_length=15)

    def __str__(self):
        return self.ip_address

# Create your models here.
