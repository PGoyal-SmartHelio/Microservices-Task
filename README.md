# Microservices-Task

## Overview
This document provides details on testing various services after running the `docker-compose` file. These services include User, Product, Order, and Gateway Services. Each service has its own endpoints for testing purposes.


## Deployment steps 
Below are the steps to be followed to deploy complete application with microservices

1. Create an .env file in the root directory (same as in docker-compose config), referring to .env.sample for available variables.
2. Run below command to validate if the docker config is correct:
`docker-compose config`
3. Run below command to start containerization & running process:
`docker-compose up -d --env-file .env`
4. Once the services are running, use the above endpoints to verify the functionality.

## Basic troubleshooting tips
You can find basic issues with syntax using below commands:
1. For validating Dockerfile:
`docker build --check .`
2. Validating docker compose configurations:
`docker-compose config`

You can get inside a running container to check logs if any issue arises with a particular container
`docker exec -it <your-container-name> sh`

## SCREENSHOTS
Refer to file: ScreenshotsWithGitRepo.docx in root directory

---

## Services and Endpoints to test

### **User Service**
- **Base URL:** `http://localhost:3000`
- **Endpoints:**
  - **List Users:**  
    ```
    curl http://localhost:3000/users
    ```
    Or open in your browser: [http://localhost:3000/users](http://localhost:3000/users)

---

### **Product Service**
- **Base URL:** `http://localhost:3001`
- **Endpoints:**
  - **List Products:**  
    ```
    curl http://localhost:3001/products
    ```
    Or open in your browser: [http://localhost:3001/products](http://localhost:3001/products)

---

### **Order Service**
- **Base URL:** `http://localhost:3002`
- **Endpoints:**
  - **List Orders:**  
    ```
    curl http://localhost:3002/orders
    ```
    Or open in your browser: [http://localhost:3002/orders](http://localhost:3002/orders)

---

### **Gateway Service**
- **Base URL:** `http://localhost:3003/api`
- **Endpoints:**
  - **Users:**  
    ```
    curl http://localhost:3003/api/users
    ```
  - **Products:**  
    ```
    curl http://localhost:3003/api/products
    ```
  - **Orders:**  
    ```
    curl http://localhost:3003/api/orders
    ```
---
