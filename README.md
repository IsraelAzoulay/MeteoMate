# MeteoMate 🌦️

MeteoMate is a sleek and simple web application that provides real-time weather information for select cities. It's powered by Flask and Python and utilizes MongoDB for logging requests.

## Features

- **Real-time Weather Data**: Fetches the latest weather data for predefined cities.
- **Responsive UI**: Designed to work seamlessly on both desktop and mobile devices.
- **Logging**: Captures request information in MongoDB for analytics and monitoring purposes.
- **Dockerized**: The application, along with it's unit and integration tests, is containerized using Docker, ensuring consistency across various environments and testing phases.
- **Kubernetes orchestration**: Deployed on Kubernetes clusters for scalable and resilient operations.
- **Infrastructure as Code**: Managed using Terraform and Helm for consistent and reproducible infrastructure provisioning.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- **Docker**: Make sure you have [Docker](https://www.docker.com/) installed.
- **Kubernetes**: Access to a Kubernetes cluster for deployment.
- **Terraform**: [Terraform](https://www.terraform.io/) installed for infrastructure management.
- **Helm**: [Helm](https://helm.sh/) installed for managing Kubernetes applications.

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

MeteoMate uses multiple CI/CD pipelines for robust and automated deployment:

- **Heroku Deployment**: Configured with GitHub Actions for CI/CD. On each push to the `main` branch, the app undergoes a build and test phase, and is manually deployed to Heroku using the `cd.yml` workflow.
  - Live on Heroku: https://meteomate-30b58b736361.herokuapp.com/
  
- **AWS Deployment with K8S, Terraform and Helm**: Containerized and deployed on AWS EKS. The `aws_ci.yml` and `aws_cd.yml` workflows in the `.github/workflows` directory handle the CI/CD pipelines for AWS deployments, including steps for scanning secrets, running unit and integration tests, validating and applying Terraform configurations, updating the Kubernetes configuration, building & pushing the Docker image to AWS ECR, and deploying the application using Helm.
  - Live on AWS EKS: https://www.meteomate.online/

### Infrastructure Management:

- **Terraform**: Used for provisioning and managing the AWS infrastructure, including EKS and EC2 instances & more.
- **Helm**: Utilized for deploying and managing the Kubernetes application.
- **AWS CloudWatch**: Integrated for monitoring and logging, providing insights into application performance and health.
- **AWS ACM**: Used for managing SSL/TLS certificates for secure HTTPS connections.
- **AWS ECR**: Docker images are stored and managed in Amazon Elastic Container Registry.

### Upcoming Integrations:

- **Prometheus**: Planned for enhanced monitoring and alerting capabilities, integrating with existing AWS CloudWatch setup.
- **Ansible**: To be used for automated configuration management, complementing the existing Terraform setup for infrastructure provisioning.

### Contributions

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License.
