# MeteoMate 🌦️

MeteoMate is a sleek and simple web application that provides real-time weather information for select cities. It's powered by Flask and Python and utilizes MongoDB for logging requests.

## Features

- **Real-time Weather Data**: Fetches the latest weather data for predefined cities.
- **Responsive UI**: Designed to work seamlessly on both desktop and mobile devices.
- **Logging**: Captures request information in MongoDB for analytics and monitoring purposes.
- **Dockerized**: The application, along with it's unit and integration tests, is containerized using Docker, ensuring consistency across various environments and testing phases.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- **Docker**: Make sure you have [Docker](https://www.docker.com/) installed.

## Getting Started

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/israelazoulay/MeteoMate.git
    cd MeteoMate
    ```

2. **Environment Variables**: Setup the `.env` file based on the provided `.env.example`. Populate the necessary variables like `API_KEY` and `MONGODB_URI`.

3. **Using Makefile**:
    - To build the Docker image:
      ```bash
      make build
      ```
    - To run the application:
      ```bash
      make run
      ```

    For more commands, refer to the `Makefile`.

4. **Access the App**: Once the server is running, you can visit `http://localhost:5000` in your web browser.

## Testing

1. **Unit Tests**: 
    ```bash
    make test
    ```

2. **Integration Tests**: These are located in the `tests` directory.

3. **Virtual Environment**:
    - Setup the virtual environment:
      ```bash
      make venv
      ```
    - Activate the virtual environment:
      ```bash
      source .venv/bin/activate
      ```

## Deployment

### CI/CD Pipelines:

MeteoMate uses multiple CI/CD pipelines:

- **Heroku Deployment**: The project is configured with GitHub Actions for CI/CD. On each push to the `main` branch, the app undergoes a build and test phase, and is manually deployed to Heroku using the `cd.yml` workflow.
View live on Heroku: https://meteomate-30b58b736361.herokuapp.com/
  
- **AWS Deployment with Kubernetes**: MeteoMate is also containerized and ready for deployment on AWS using Kubernetes. The `aws_ci.yml` and `aws_cd.yml` workflows in the `.github/workflows` directory handle the CI/CD for AWS deployments.

### Contributions

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.