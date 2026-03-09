# 🚀 Deployment Guide

Production deployment guide for the AI Calling Agent.

---

## Deployment Options

1. **Cloud VM (AWS, Azure, GCP)**
2. **Docker Swarm**
3. **Kubernetes**
4. **Azure Container Apps**
5. **AWS ECS/Fargate**

---

## Option 1: Cloud VM Deployment (Recommended for Prototypes)

### Requirements

- Ubuntu 20.04 LTS or later
- 8+ CPU cores
- 16GB+ RAM
- 50GB+ disk space
- Public IP address
- Domain name (optional but recommended)

### Step 1: Set Up the Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose -y

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Step 2: Clone and Configure

```bash
# Clone repository
git clone <repository-url>
cd ai-calling-agent

# Create .env file
cp .env.example .env
nano .env  # Add your Twilio credentials

# Set up firewall
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 8000/tcp  # API
sudo ufw enable
```

### Step 3: Deploy

```bash
# Start services
docker compose up -d --build

# Pull AI model
bash ollama_setup.sh

# Check status
docker compose ps
```

### Step 4: Set Up Reverse Proxy (Nginx)

```bash
# Install Nginx
sudo apt install nginx -y

# Create configuration
sudo nano /etc/nginx/sites-available/ai-calling-agent
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /dashboard/ {
        proxy_pass http://localhost:8000/dashboard/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /twilio/ {
        proxy_pass http://localhost:8000/twilio/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/ai-calling-agent /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Step 5: SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo certbot renew --dry-run
```

### Step 6: Configure Twilio

Update your Twilio webhook to:

```
https://your-domain.com/twilio/incoming
```

---

## Option 2: AWS Deployment

### Using AWS EC2

1. **Launch EC2 Instance**
   - AMI: Ubuntu Server 20.04 LTS
   - Instance Type: t3.xlarge (4 vCPU, 16GB RAM)
   - Storage: 50GB GP3
   - Security Group: Open ports 22, 80, 443, 8000

2. **Connect and Deploy**
   ```bash
   ssh -i your-key.pem ubuntu@ec2-xx-xx-xx-xx.compute.amazonaws.com
   # Follow "Cloud VM Deployment" steps above
   ```

### Using AWS ECS (Container Service)

Create `ecs-task-definition.json`:

```json
{
  "family": "ai-calling-agent",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "4096",
  "memory": "16384",
  "containerDefinitions": [
    {
      "name": "api",
      "image": "your-ecr-repo/api:latest",
      "portMappings": [{ "containerPort": 8000 }],
      "environment": [
        { "name": "TWILIO_ACCOUNT_SID", "value": "..." },
        { "name": "TWILIO_AUTH_TOKEN", "value": "..." }
      ]
    }
  ]
}
```

Deploy:

```bash
aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json
aws ecs create-service --cluster your-cluster --service-name ai-calling-agent --task-definition ai-calling-agent
```

---

## Option 3: Azure Deployment

### Using Azure Container Apps

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login

# Create resource group
az group create --name ai-calling-agent-rg --location eastus

# Create container app environment
az containerapp env create \
  --name ai-calling-agent-env \
  --resource-group ai-calling-agent-rg \
  --location eastus

# Deploy API
az containerapp create \
  --name api \
  --resource-group ai-calling-agent-rg \
  --environment ai-calling-agent-env \
  --image your-acr.azurecr.io/api:latest \
  --target-port 8000 \
  --ingress external \
  --env-vars TWILIO_ACCOUNT_SID=xxx TWILIO_AUTH_TOKEN=xxx
```

---

## Option 4: Google Cloud Platform

### Using GCP Compute Engine

```bash
# Create VM instance
gcloud compute instances create ai-calling-agent \
  --machine-type=n1-standard-4 \
  --zone=us-central1-a \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=50GB

# SSH into instance
gcloud compute ssh ai-calling-agent --zone=us-central1-a

# Follow "Cloud VM Deployment" steps
```

---

## Option 5: Kubernetes Deployment

### Create Kubernetes Manifests

**deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ai-calling-agent-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
        - name: api
          image: your-registry/api:latest
          ports:
            - containerPort: 8000
          env:
            - name: TWILIO_ACCOUNT_SID
              valueFrom:
                secretKeyRef:
                  name: twilio-secrets
                  key: account-sid
          resources:
            requests:
              memory: '2Gi'
              cpu: '1'
            limits:
              memory: '4Gi'
              cpu: '2'
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whisper
spec:
  replicas: 1
  selector:
    matchLabels:
      app: whisper
  template:
    metadata:
      labels:
        app: whisper
    spec:
      containers:
        - name: whisper
          image: your-registry/whisper:latest
          ports:
            - containerPort: 5001
          resources:
            requests:
              memory: '2Gi'
              cpu: '1'
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tts
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tts
  template:
    metadata:
      labels:
        app: tts
    spec:
      containers:
        - name: tts
          image: your-registry/tts:latest
          ports:
            - containerPort: 5002
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      containers:
        - name: ollama
          image: ollama/ollama:latest
          ports:
            - containerPort: 11434
          resources:
            requests:
              memory: '8Gi'
              cpu: '2'
```

**service.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8000
  selector:
    app: api
---
apiVersion: v1
kind: Service
metadata:
  name: whisper
spec:
  type: ClusterIP
  ports:
    - port: 5001
  selector:
    app: whisper
---
apiVersion: v1
kind: Service
metadata:
  name: tts
spec:
  type: ClusterIP
  ports:
    - port: 5002
  selector:
    app: tts
```

Deploy:

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

---

## Production Checklist

### Security

- [ ] Use environment variables for secrets (never commit .env)
- [ ] Enable SSL/TLS certificates
- [ ] Set up firewall rules
- [ ] Use private networks for internal services
- [ ] Implement rate limiting
- [ ] Add authentication to dashboard
- [ ] Regular security updates
- [ ] Use secrets management (AWS Secrets Manager, Azure Key Vault)

### Monitoring

- [ ] Set up logging (ELK Stack, Loki, CloudWatch)
- [ ] Configure alerts (PagerDuty, Slack)
- [ ] Monitor resource usage
- [ ] Track API response times
- [ ] Monitor call success rates
- [ ] Set up uptime monitoring (UptimeRobot, Pingdom)

### Scaling

- [ ] Load balancer for API (multiple replicas)
- [ ] Separate Whisper instances for parallel processing
- [ ] Redis cluster for high availability
- [ ] Auto-scaling based on CPU/memory
- [ ] CDN for static assets
- [ ] Database for persistent storage

### Backup & Recovery

- [ ] Redis backup strategy
- [ ] Regular database backups
- [ ] Disaster recovery plan
- [ ] Automated backups to S3/Azure Blob
- [ ] Test recovery procedures

### Performance

- [ ] Enable Redis persistence
- [ ] Use Redis Cluster for scale
- [ ] Optimize Docker images (multi-stage builds)
- [ ] Use faster Whisper model (distil-whisper)
- [ ] Cache LLM responses for common queries
- [ ] Implement connection pooling

---

## Environment Variables for Production

```env
# Twilio
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxx
TWILIO_PHONE_NUMBER=+1234567890

# Redis
REDIS_HOST=redis.production.internal
REDIS_PORT=6379
REDIS_PASSWORD=your_secure_password

# Ollama
OLLAMA_HOST=ollama.production.internal:11434
OLLAMA_MODEL=mistral

# Services
WHISPER_URL=http://whisper:5001
TTS_URL=http://tts:5002

# Application
DEBUG=false
LOG_LEVEL=info
MAX_CONCURRENT_CALLS=10

# Security
API_KEY=your_secure_api_key
CORS_ORIGINS=https://your-domain.com
```

---

## Continuous Deployment

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build Docker images
        run: |
          docker compose build

      - name: Push to registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker compose push

      - name: Deploy to server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /opt/ai-calling-agent
            git pull
            docker compose pull
            docker compose up -d --no-build
```

---

## Cost Estimation

### Monthly Costs (Approximate)

**AWS EC2 (t3.xlarge)**

- Instance: ~$120/month
- Storage (50GB): ~$5/month
- Data transfer: ~$10-50/month
- **Total: ~$135-175/month**

**Azure Container Apps**

- Compute: ~$100-150/month
- Storage: ~$5/month
- **Total: ~$105-155/month**

**Google Cloud (n1-standard-4)**

- Instance: ~$140/month
- Storage: ~$5/month
- **Total: ~$145/month**

**Twilio**

- Phone number: $1/month
- Inbound calls: $0.0085/minute
- 1000 minutes: ~$8.50/month

**Additional Services**

- Domain: ~$12/year
- SSL Certificate: Free (Let's Encrypt)
- Monitoring: $0-50/month

---

## Maintenance

### Daily Tasks

- Check system logs
- Monitor call success rate
- Review error logs

### Weekly Tasks

- Review resource usage
- Update Twilio configuration if needed
- Test system with sample calls

### Monthly Tasks

- Security updates
- Backup verification
- Cost optimization review
- Performance tuning

---

## Support & Escalation

### Level 1: Restart Services

```bash
docker compose restart
```

### Level 2: Rebuild Containers

```bash
docker compose down
docker compose up --build -d
```

### Level 3: Full Reset

```bash
docker compose down -v
docker system prune -a
docker compose up --build -d
bash ollama_setup.sh
```

---

**Production deployment requires careful planning and monitoring. Start with a staging environment first!**
