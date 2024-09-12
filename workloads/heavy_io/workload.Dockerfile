# FROM mcr.microsoft.com/devcontainers/python:3
FROM mcr.microsoft.com/mirror/docker/library/alpine:3.16
WORKDIR /var/www
COPY workload_*.sh server.py ./
RUN apk add --no-cache python3 fio bash sysbench
ENV PORT=8000
CMD ["/bin/bash", "workload_tar.sh"]
