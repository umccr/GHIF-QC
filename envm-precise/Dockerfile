FROM ubuntu:16.04
LABEL author="Sehrish Kanwal-https://github.com/skanwal"
LABEL doc="Image to run PRECISE GHIF-QC script"

# Setup a base system
RUN apt-get update && \
    apt-get install -y curl wget git unzip tar gzip bzip2 g++ make zlib1g-dev dbus

# Install conda
RUN wget -nv https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /miniconda
ENV PATH /miniconda/bin:$PATH

# Copy environment file for conda and use it for creating conda environment
COPY ./environment.yaml /tmp/environment.yaml
RUN conda config --set channel_priority strict
RUN conda env create -f /tmp/environment.yaml

# Activate the environment and set path
ENV PATH  /miniconda/envs/precise-qc/bin:$PATH
ENV CONDA_PREFIX /miniconda/envs/precise-qc

