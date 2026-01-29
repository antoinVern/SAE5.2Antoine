FROM python:3.9-slim

# Installation de ping et whois
RUN apt-get update && apt-get install -y iputils-ping whois && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]