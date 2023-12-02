FROM python:3.7-slim

COPY requirements.txt ./
RUN pip install -r requirements.txt

WORKDIR /app
COPY app.py .

RUN groupadd -g 2000 app && useradd -m -u 2001 -g app app
USER app

EXPOSE 8000
ENTRYPOINT ["python", "app.py"]
