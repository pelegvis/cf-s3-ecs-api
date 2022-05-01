FROM python:3.8-alpine
USER root
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY . .
EXPOSE 5011
CMD [ "python3", "app.py"]
