# FROM mcr.microsoft.com/devcontainers/python:3
FROM mcr.microsoft.com/mirror/docker/library/alpine:3.16
WORKDIR /var/www
COPY workload_tar.sh .
COPY workload_fio.sh .
# RUN apt update -y && \
#     apt install -y fio && \
RUN apk add --no-cache python3 fio bash && \
    echo 'Hello' > index.txt
ENV PORT=8000

CMD ["/bin/bash", "workload_tar.sh"]
