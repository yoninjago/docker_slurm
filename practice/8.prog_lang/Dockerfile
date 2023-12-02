FROM python:3.7-slim

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY . /app
WORKDIR /app
RUN groupadd -g 2000 app && useradd -m -u 2001 -g app app
USER app

ENV FLASK_APP=src/app.py
EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
