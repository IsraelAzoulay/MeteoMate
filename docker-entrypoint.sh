#!/bin/bash

# Ensure the logs directory exists
mkdir -p /app/logs

# Remove existing log file before starting the application in any environment
rm /app/logs/app.log 2>/dev/null || true

# Debugging: List the current directory contents
echo "Current working directory: $(pwd)"
echo "Listing files in current directory: "
ls -al

if [ "$ENVIRONMENT" = 'TEST' ]; then
  # Run tests in the 'tests' directory
  python -m unittest discover -s tests/
elif [ "$ENVIRONMENT" = 'PRODUCTION' ]; then
  # Start the application using Gunicorn in production mode
  cd app
  gunicorn -b :$PORT app:app --timeout 120 -w 4 # Set the timeout to 120 seconds and the number of workers to 4
else
  # Start the Flask development server
  python app/app.py
fi