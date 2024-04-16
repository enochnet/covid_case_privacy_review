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
COPY renv.lock ./
COPY renv/activate.R renv/

# Install project dependencies
RUN Rscript -e "install.packages('renv')"
RUN Rscript -e "renv::restore()"

# Tag the built image
RUN docker tag builder r-application:latest

# Stage 2: Run CVE scanning
FROM anchore/grype AS grype

# Copy the built application and project dependencies from Stage 1
COPY --from=builder /app /app

# Run CVE scanning with Grype
RUN grype /app -o json > /app/grype-output.json

# Stage 3: Generate SBOM
FROM anchore/syft AS syft

# Copy the built application and project dependencies from Stage 1
COPY --from=builder /app /app

# Generate SBOM with Syft
RUN syft /app -o json > /app/sbom.json