FROM python:3.12-slim

WORKDIR /app
COPY app.py auth.py coffee.py schema.sql ./

CMD ["python", "-u", "app.py"]