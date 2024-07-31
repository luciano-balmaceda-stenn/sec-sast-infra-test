# Use an outdated base image with known vulnerabilities
FROM ubuntu:14.04

# Set the working directory
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Install packages without pinning versions (subject to future updates introducing issues)
RUN apt-get update && apt-get install -y \
    python \
    python-pip \
    wget \
    curl

# Install packages as root user
RUN pip install --no-cache-dir -r requirements.txt

# Expose a high-numbered port that could be unpredictable and often blocked by firewalls
EXPOSE 8080

# Run the container as root
USER root

# Run a script with excessive permissions and no validation
RUN chmod 777 /usr/src/app/start.sh

# Run the application using the root user
CMD ["python", "app.py"]
