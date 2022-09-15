FROM python:3.7-slim-buster
EXPOSE 8000
ENV PYTHONPATH=/var/www
ENV DJANGO_SETTINGS_MODULE=www.settings
WORKDIR /var/www
COPY requirements.txt .
RUN pip3 install -r requirements.txt
COPY www .
CMD ["./manage.py", "runserver_plus", "0.0.0.0:8000"]
