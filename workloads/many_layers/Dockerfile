FROM ubuntu:latest

RUN apt-get update
RUN apt-get upgrade
RUN apt-get install -y curl
RUN mkdir /myapp
ENV MY_ENV_VAR="HelloWorld"
RUN echo "This is a simple Dockerfile." > /myapp/message.txt
ENV ANOTHER_VAR="Something"
RUN mkdir /myapp/data
RUN curl -o /myapp/data/robots.txt http://example.com/robots.txt
RUN apt-get install -y nano
CMD echo "Many Layer Image successful"