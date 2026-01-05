# CI/CD Setup Guide - Automatic Deployment

## 🚀 How It Works

1. **You push code to GitHub** → Triggers automatic deployment
2. **GitHub Actions** → Connects to your server via SSH
3. **Server** → Pulls latest code, builds Docker image, and deploys
4. **Done!** → No manual steps needed

---

## 📋 Step-by-Step Setup

### Step 1: Push Code to GitHub

On your local machine:

```bash
cd "D:\HR Portal"

# Initialize git (if not done)
git init
git add .
git commit -m "Initial commit - HR Portal Backend"

# Add remote (replace with your GitHub repo URL)
git remote add origin https://github.com/YOUR_USERNAME/hr-portal-backend.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

### Step 2: Initial Server Setup (One-time)

SSH into your server:

```bash
ssh root@97.77.20.150
```

Run these commands:

```bash
# Create project directory
mkdir -p /data/apps/hr-portal-backend
cd /data/apps/hr-portal-backend

# Clone repository (first time only)
git clone https://github.com/YOUR_USERNAME/hr-portal-backend.git .

# Create .env file
JWT_SECRET=$(openssl rand -base64 32)
SESSION_SECRET=$(openssl rand -base64 32)

cat > .env << EOF
# MongoDB Connection
MONGODB_URI=mongodb://localhost:27017/hr_portal
MONGODB_DB_NAME=hr_portal

# Server Configuration
NODE_ENV=production
PORT=3000
API_URL=http://97.77.20.150:3000

# JWT Secret
JWT_SECRET=$JWT_SECRET
JWT_EXPIRE=7d

# Session Secret
SESSION_SECRET=$SESSION_SECRET

# CORS Configuration
CORS_ORIGIN=http://localhost:5173
EOF

# Build and start (first time)
docker-compose up -d --build
```

---

### Step 3: Setup GitHub Secrets

Go to your GitHub repository:
1. **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add these secrets:

#### Required Secrets:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `SERVER_HOST` | `97.77.20.150` | Your server IP |
| `SERVER_USER` | `root` | SSH username |
| `SERVER_SSH_KEY` | `[Your private SSH key]` | Private SSH key for server access |
| `SERVER_PORT` | `22` | SSH port (optional, defaults to 22) |

---

### Step 4: Generate SSH Key for GitHub Actions

On your **local machine** (Windows):

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_actions_deploy

# This creates:
# ~/.ssh/github_actions_deploy (private key - add to GitHub Secrets)
# ~/.ssh/github_actions_deploy.pub (public key - add to server)
```

**Copy public key to server:**

```bash
# On your local machine, copy public key
type %USERPROFILE%\.ssh\github_actions_deploy.pub
```

**On server, add public key:**

```bash
# SSH into server
ssh root@97.77.20.150

# Add public key to authorized_keys
mkdir -p ~/.ssh
echo "PASTE_YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

**Add private key to GitHub Secrets:**

1. On your local machine:
```bash
type %USERPROFILE%\.ssh\github_actions_deploy
```

2. Copy the entire output (starts with `-----BEGIN OPENSSH PRIVATE KEY-----`)
3. Go to GitHub → Your Repo → Settings → Secrets → Actions
4. Click "New repository secret"
5. Name: `SERVER_SSH_KEY`
6. Value: Paste the private key
7. Click "Add secret"

---

### Step 5: Test CI/CD

Make a small change and push:

```bash
# On your local machine
cd "D:\HR Portal\Backend"

# Make a small change (add a comment or update README)
echo "# HR Portal Backend" > README.md

# Commit and push
git add .
git commit -m "Test CI/CD deployment"
git push origin main
```

**Check GitHub Actions:**
1. Go to your GitHub repository
2. Click **Actions** tab
3. You should see "Deploy Backend to Production" running
4. Click on it to see logs

**On server, verify deployment:**

```bash
# SSH into server
ssh root@97.77.20.150

# Check if container restarted
cd /data/apps/hr-portal-backend
docker-compose logs --tail=50
docker ps | grep hr-portal-backend
```

---

## ✅ That's It!

Now every time you push to `main` branch:
1. ✅ Code automatically deploys
2. ✅ Docker image rebuilds
3. ✅ Container restarts
4. ✅ No manual steps needed!

---

## 🔄 Workflow

```
Local Code Changes
    ↓
git push origin main
    ↓
GitHub receives push
    ↓
GitHub Actions triggered
    ↓
SSH to server
    ↓
git pull origin main
    ↓
docker-compose up -d --build
    ↓
✅ Deployed!
```

---

## 🛠️ Troubleshooting

**CI/CD not triggering:**
- Check if workflow file is in `.github/workflows/deploy.yml`
- Check if branch is `main` or `master`
- Check GitHub Actions tab for errors

**SSH connection fails:**
- Verify `SERVER_HOST`, `SERVER_USER`, `SERVER_SSH_KEY` secrets
- Test SSH manually: `ssh -i ~/.ssh/github_actions_deploy root@97.77.20.150`
- Check server firewall allows port 22

**Deployment fails:**
- Check GitHub Actions logs
- SSH to server and check: `docker-compose logs`
- Verify `.env` file exists on server

---

## 📝 Manual Deployment (if needed)

If CI/CD fails, you can manually deploy:

```bash
# On server
cd /data/apps/hr-portal-backend
git pull origin main
docker-compose up -d --build
```

