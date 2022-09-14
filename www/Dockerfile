FROM python:3.9-slim

COPY requirements.txt /requirements.txt

RUN pip3 install -r /requirements.txt

COPY var/www/ /var/www/

ENTRYPOINT ["python"]
CMD ["/var/www/manage.py", "runserver_plus", "0.0.0.0:8000"]
