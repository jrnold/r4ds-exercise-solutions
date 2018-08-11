FROM rocker/verse:latest

ENV PROJ_DIR /home/rstudio/r4ds-exercise-solutions
ENV PANDOC_VERSION 2.2.3.2
ENV PANDOC_FILENAME pandoc-${PANDOC_VERSION}-1-amd64.deb

# Update pandoc
RUN apt-get update
RUN apt-get install -y gnupg curl
RUN curl -sL -o ${PANDOC_FILENAME} https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/${PANDOC_FILENAME}
RUN dpkg -i ${PANDOC_FILENAME}
RUN rm ${PANDOC_FILENAME}
RUN rm /usr/local/bin/pandoc /usr/local/bin/pandoc-citeproc

# Install dependencies needed to run code and build package
RUN mkdir ${PROJ_DIR}
WORKDIR ${PROJ_DIR}
COPY DESCRIPTION .
RUN Rscript -e "devtools::install(\"${PROJ_DIR}\", dependencies=TRUE)"
RUN rm DESCRIPTION
