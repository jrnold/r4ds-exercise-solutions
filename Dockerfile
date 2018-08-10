FROM rocker/verse:latest

ENV PANDOC_VERSION 2.2.3.2
ENV PANDOC_FILENAME pandoc-${PANDOC_VERSION}-1-amd64.deb

RUN apt-get update && \
  apt-get install -y gnupg curl && \
  curl -sL -o ${PANDOC_VERSION} https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/${PANDOC_FILENAME}

WORKDIR /app
