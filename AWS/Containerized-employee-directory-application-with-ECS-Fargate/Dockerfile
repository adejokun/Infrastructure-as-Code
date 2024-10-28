# FROM ubuntu:14.04
FROM python:3.8

USER root
RUN apt-get update && apt-get install wget
RUN wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/DEV-AWS-MO-GCNv2/FlaskApp.zip
USER root
RUN apt-get update && apt-get install unzip
RUN unzip FlaskApp.zip
WORKDIR /FlaskApp

RUN apt-get update && apt-get install -y python3 python3-pip
RUN pip install --no-cache-dir -r requirements.txt
RUN apt-get install -y stress

USER root
RUN apt-get update && apt-get install pip
RUN pip install flask==3.0.*

ENV PHOTOS_BUCKET=s3-dir-app
ENV AWS_DEFAULT_REGION=us-west-2
ENV DYNAMO_MODE=on
ENV FLASK_APP=application.py

CMD ["flask", "run", "--host", "0.0.0.0", "--port", "80"]






