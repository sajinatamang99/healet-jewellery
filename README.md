# 💎 Healet Jewellery – Scalable Web Application

Healet Jewellery is a fully responsive, elegant web application designed for showcasing and managing a jewellery brand online. It is developed with a focus on clean UI/UX, automation, scalability, and observability using modern DevOps tools.

---

## 📌 Features

- 🖥️ Modern UI built with HTML, CSS, and Apache server
- ☁️ Infrastructure provisioned with Terraform on AWS
- 📦 Continuous Integration & Delivery via GitHub Actions
- 🔍 Code Quality checks using **SonarCloud**
- 🛡️ Security scanning using **Trivy**
- 📊 Real-time monitoring with **Prometheus + Grafana**
- 🗃️ Managed database with **Amazon RDS (MySQL)**
- 📡 EC2-based deployment (2-tier architecture)

---

## 🧱 Tech Stack

| Layer             | Technology                        |
|------------------|-----------------------------------|
| Frontend         | HTML, CSS                         |
| Backend Hosting  | Apache on EC2                     |
| Infrastructure   | Terraform (IAC)                   |
| CI/CD            | GitHub Actions                    |
| Monitoring       | Prometheus + Node Exporter + Grafana |
| Security         | Trivy (Docker image scanning)     |
| Code Quality     | SonarCloud                        |
| Database         | Amazon RDS (MySQL)                |
| Cloud Platform   | AWS (EC2, RDS, VPC, SGs, etc.)    |

---

## 🧑‍💻 Architecture Overview

- **EC2-1** (Public Subnet 1): Hosts the web application + Node Exporter
- **EC2-2** (Public Subnet 2): Hosts Prometheus + Grafana
- **RDS MySQL** (Private Subnet 1): Stores persistent backend data
- **VPC**: Includes public/private subnets, NAT Gateway, IGW
- **Security Groups**: Configured for secure port access (22, 80, 9100, 9090, 3000)
