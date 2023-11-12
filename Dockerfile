# Use a slim version of Python 3.10 as the base image
FROM python:3.10-slim

# Update the system and install ca-certificates. Needed for Heroku.
RUN apt-get update && apt-get install -y ca-certificates

# Set the working directory inside the container
WORKDIR /app

# Adding the directory creation step to ensure the log directory exists
RUN mkdir -p /app/logs

# Copy the application's requirements file.
COPY requirements.txt .

# Upgrade pip and install Python packages
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the rest of the application files to the container
COPY . .

# Environment variables for Flask
ENV FLASK_APP=app/app.py 
ENV FLASK_ENV=development

# Expose port 5000 to the host machine
EXPOSE 5000

# Command that will be executed when the container starts (Needed for the development phase).
# CMD flask run --host=0.0.0.0 --port=${PORT}

# Setting the 'ENTRYPOINT' command to run our custom script when the container starts (Needed for the deployment phase).
ENTRYPOINT ["/app/docker-entrypoint.sh"]