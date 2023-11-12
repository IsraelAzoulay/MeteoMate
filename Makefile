# Makefile for the MeteoMate webapplication

# Variables
VENV_NAME=.venv
PYTHON=${VENV_NAME}/bin/python

# Default make target
all: venv build

# Create a virtual environment
venv:
	test -d $(VENV_NAME) || python3 -m venv $(VENV_NAME)
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -r requirements.txt

# Activate the virtual environment
activate:
	source $(VENV_NAME)/bin/activate

# Build the Docker image
build:
	@echo "Building Docker image..."
	docker build -t weather-app:latest .

# Start the application container
run:
	@echo "Starting the weather-app container..."
	docker run -d -p 5000:5000 -e PORT=5000 --name weather-app-container weather-app:latest

# Stop and remove the application container
stop:
	@echo "Stopping the weather-app container..."
	docker stop weather-app-container
	docker rm weather-app-container 

# Run tests in the container
test:
	@echo "Running tests in the weather-app container..."
	docker exec -e ENVIRONMENT=TEST weather-app-container ./docker-entrypoint.sh

# Use docker-compose to start services
compose-up:
	@echo "Starting services using docker-compose..."
	docker-compose up -d

# Use docker-compose to stop services
compose-down:
	@echo "Stopping services using docker-compose..."
	docker-compose down

# Clean up all the unused Docker images, containers, volumes, etc.
clean:
	@echo "Cleaning up unused Docker resources..."
	docker system prune -a

# Clean virtual environment
clean-venv:
	rm -rf $(VENV_NAME)

.PHONY: all venv activate build run stop test compose-up compose-down clean clean-venv