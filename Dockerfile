FROM rocker/verse:latest

ENV PROJ_DIR /home/rstudio/r4ds-exercise-solutions
ENV PANDOC_VERSION 2.2.3.2
ENV PANDOC_FILENAME pandoc-${PANDOC_VERSION}-1-amd64.deb
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE 1

# Install pnandoc and nodejs
RUN apt-get update && apt-get install -y \
  gnupg \
  curl

RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - && \
  apt-get install -y nodejs

RUN curl -sL -o ${PANDOC_FILENAME} https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/${PANDOC_FILENAME} && \
  dpkg -i ${PANDOC_FILENAME} && \
  rm ${PANDOC_FILENAME} && \
  rm /usr/local/bin/pandoc /usr/local/bin/pandoc-citeproc

# Install dependencies needed to run code and build package
RUN mkdir ${PROJ_DIR}
WORKDIR ${PROJ_DIR}
COPY DESCRIPTION .
RUN Rscript -e "devtools::install(\"${PROJ_DIR}\", dependencies=TRUE)"
RUN rm DESCRIPTION
