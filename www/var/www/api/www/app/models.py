from dataclasses import dataclass
import json
import requests
from django.db import models


class IPAddress(models.Model):
    """
    Capture IPv4 address, longitude, and latitude of connecting client
    """
    ipv4 = models.CharField(max_length=15, null=False, blank=False)
    longitude = models.CharField(max_length=255, null=False, blank=False)
    latitude = models.CharField(max_length=255, null=False, blank=False)

#    def __init__(self, *args, **kwargs):
#        super(IPAddress, self).__init__(*args, **kwargs)
#        try:
#            r = json.loads(requests.get("https://geolocation-db.com/json/"))
#        except Exception as ex:
#            return ex
#        
#        self.latitude = r["latitude"]
#        self.longitude = r["longitude"]
#        self.ipv4 = r["IPv4"]
#        self.save()
        
    def __str__(self):
        return self.ipv4