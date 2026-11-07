# Full-Stack DevOps Assessment Application

A production-ready full-stack "Hello World" application built with a **Django 6.0 REST API** backend and a **React 19 (Vite + TypeScript)** frontend, fully containerized with multi-stage Docker builds, orchestrable via Docker Compose, automated through Jenkins & GitHub Actions CI/CD pipelines, and prepared with Infrastructure-as-Code (Terraform).

---

## Quick Start (Docker Compose)

The easiest way to launch the complete full-stack environment is using Docker Compose:

```bash
# 1. Clone the repository
git clone <repository-url>
cd Full_stack_DevOps_Project

# 2. Build and launch services in detached mode
docker compose up -d --build

# 3. Check service health status
docker compose ps
```

Once running:
- **Frontend Application**: [http://localhost:3000](http://localhost:3000)
- **Django Backend API**: [http://localhost:8000/api/hello/](http://localhost:8000/api/hello/)
- **Backend Health Check**: [http://localhost:8000/api/health/](http://localhost:8000/api/health/)
- **Frontend Health Check**: [http://localhost:3000/healthz](http://localhost:3000/healthz)

To tear down containers:
```bash
docker compose down
```

---

## Local Development (Without Docker)

### Backend (Django)
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python manage.py check
python manage.py test
python manage.py runserver 0.0.0.0:8000
```

### Frontend (React + Vite)
```bash
cd frontend
npm install
npm run build   # Verifies TypeScript & Vite production build
npm run dev     # Runs local development server on port 5173
```

---

## Automated Deployment Script

Run the automated rollout script:
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## CI/CD Pipeline

- **Jenkins**: Enterprise declarative pipeline configured in `Jenkinsfile` featuring 8 automated stages (Checkout, Linting, Django Tests, Frontend Bundling, Docker Image Build, Registry Push, Local Docker Compose Deployment, and Endpoint Health Verification).
- **GitHub Actions**: Automated CI workflow in `.github/workflows/ci.yml` that validates code on every pull request and push to the `main` branch.

---

## Infrastructure as Code (Terraform)

An optional AWS deployment configuration is prepared in the `terraform/` directory:
- Provisions a dedicated VPC, Public Subnet, Internet Gateway, and Route Table.
- Security Group strictly restricts ingress to ports **22 (SSH)**, **80 (HTTP)**, and **443 (HTTPS)**.
- Launches an Ubuntu 24.04 LTS EC2 instance with automated Docker Engine installation via cloud-init User Data.
- Validated via `terraform fmt` and `terraform validate`.

*(Note: Per environment constraints, AWS free tier is suspended; Terraform is prepared for cloud deployment when AWS access is restored without executing `terraform apply`)*.

---

## Detailed DevOps Documentation

For in-depth architectural details, Jenkins configuration, Docker security best practices, and troubleshooting logs, refer to [DEVOPS.md](./DEVOPS.md).
