import logging

from mozilla_django_oidc import middleware


LOGGER = logging.getLogger(__name__)


class SessionRefresh(middleware.SessionRefresh):
    def process_request(self, request):
        return super().process_request(request)
