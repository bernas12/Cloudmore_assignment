# Prometheus and Grafana Setup with Temperature Monitoring

This project sets up a Prometheus and Grafana environment on an Azure virtual machine, and includes a custom script to retrieve the current temperature in Tallinn and store it in Prometheus.

## Prerequisites

- Azure account and AZ CLI
- Terraform installed on your local machine
- SSH key pair
- OpenWeatherMap API key

## Getting Started

1. Clone the repository.

2. Navigate to the project directory.

3. Obtain an API key for the public OpenWeatherMap API.

4. Update the `varibles.tf` file with the default value for each varible.

5. Start the terraform with terraform init.

6. Login to the az CLI.

7. Run a terraform plan and apply to deploy the infrastruture.

8. Open your browser and connect to http:/<Azure_VM_IP>:3000 to connect to the grafana dashboard.