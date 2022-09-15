from django.db import models


class IPAddress(models.Model):
    ip_address = models.CharField(max_length=15, null=False)

    def __str__(self):
        return self.ip_address
