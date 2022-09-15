import logging

from django.urls import reverse
from django.contrib.auth.models import Group
from django.db import transaction

from mozilla_django_oidc import auth
from mozilla_django_oidc.utils import absolutify


LOGGER = logging.getLogger(__name__)


class OIDCAuthenticationBackend(auth.OIDCAuthenticationBackend):
    def create_user(self, claims):
        user = super(OIDCAuthenticationBackend, self).create_user(claims)
        user.first_name = claims.get('given_name', '')
        user.last_name = claims.get('family_name', '')
        user.save()

        self.update_groups(user, claims)

        return user

    def update_user(self, user, claims):
        user.first_name = claims.get('given_name', '')
        user.last_name = claims.get('family_name', '')
        user.save()

        self.update_groups(user, claims)

        return user

    def update_groups(self, user, claims):
        with transaction.atomic():
            user.groups.clear()
            for group_claim in claims['groups']:
                group, created = Group.objects.get_or_create(name=group_claim)
                group.user_set.add(user)

        return None

    def get_token(self, payload):
        token_info = super().get_token(payload)
        return token_info

    def get_userinfo(self, access_token, id_token, payload):
        userinfo = super().get_userinfo(access_token, id_token, payload)
        return userinfo
