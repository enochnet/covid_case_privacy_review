# Stage 1: Build the R application
FROM r-base:4.1.0 AS builder

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        libcurl4-openssl-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        libfreetype6-dev \
        libxml2-dev

# Set the working directory
WORKDIR /app

# Copy the R script and dependencies files
COPY matrix.R ./   
COPY R/renv.lock ./    
COPY R/renv/activate.R renv/  

# Install project dependencies
RUN Rscript -e "install.packages('renv')"
RUN Rscript -e "renv::snapshot()"
RUN Rscript -e "renv::restore()"
