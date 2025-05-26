# You2API VPS 部署完整指南

## 🚀 快速部署（推薦方案）

### 1. 準備 VPS 環境

```bash
# 更新系統
sudo apt update && sudo apt upgrade -y

# 安裝 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安裝 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 將用戶添加到 docker 組
sudo usermod -aG docker $USER
newgrp docker
```

### 2. 部署服務

```bash
# 創建項目目錄
mkdir -p /opt/you2api
cd /opt/you2api

# 克隆項目
git clone https://github.com/bohesocool/you2api.git .

# 啟動服務
docker-compose up -d
```

### 3. 驗證部署

```bash
# 檢查服務狀態
docker-compose ps

# 查看日誌
docker-compose logs -f you2api

# 測試 API
curl http://localhost:8080/v1/models
```

## 🔧 配置選項

### 環境變量配置

編輯 `docker-compose.yml` 中的環境變量：

```yaml
environment:
  - PORT=8080              # 服務端口
  - ENABLE_PROXY=false     # 是否啟用代理
  - PROXY_URL=             # 代理地址
  - PROXY_TIMEOUT_MS=5000  # 代理超時時間
  - LOG_LEVEL=info         # 日誌級別
```

### 端口配置

- **8080**: You2API 服務端口
- **9090**: Prometheus 監控端口（可選）
- **3000**: Grafana 監控面板端口（可選）

## 🔒 安全配置

### 1. 防火牆設置

```bash
# 安裝 ufw
sudo apt install ufw -y

# 允許 SSH
sudo ufw allow ssh

# 允許 You2API 端口
sudo ufw allow 8080

# 啟用防火牆
sudo ufw enable
```

### 2. Nginx 反向代理（推薦）

```bash
# 安裝 Nginx
sudo apt install nginx -y

# 創建配置文件
sudo tee /etc/nginx/sites-available/you2api << 'EOF'
server {
    listen 80;
    server_name your-domain.com;  # 替換為您的域名

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 啟用站點
sudo ln -s /etc/nginx/sites-available/you2api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3. SSL 證書（可選）

```bash
# 安裝 Certbot
sudo apt install certbot python3-certbot-nginx -y

# 獲取 SSL 證書
sudo certbot --nginx -d your-domain.com
```

## 📊 監控配置

### 啟用完整監控

```bash
# 啟動包含監控的完整服務
docker-compose up -d

# 訪問監控面板
# Prometheus: http://your-server:9090
# Grafana: http://your-server:3000 (admin/admin)
```

## 🔄 服務管理

### 常用命令

```bash
# 啟動服務
docker-compose up -d

# 停止服務
docker-compose down

# 重啟服務
docker-compose restart

# 查看日誌
docker-compose logs -f

# 更新服務
git pull
docker-compose build --no-cache
docker-compose up -d
```

### 自動啟動

```bash
# 創建 systemd 服務
sudo tee /etc/systemd/system/you2api.service << 'EOF'
[Unit]
Description=You2API Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/you2api
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# 啟用自動啟動
sudo systemctl enable you2api.service
sudo systemctl start you2api.service
```

## 🧪 測試 API

### 基本測試

```bash
# 測試服務狀態
curl http://localhost:8080/v1/models

# 測試聊天 API
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-api-key" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ]
  }'
```

## 🚨 故障排除

### 常見問題

1. **端口被占用**
   ```bash
   sudo netstat -tulpn | grep :8080
   sudo kill -9 <PID>
   ```

2. **Docker 權限問題**
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. **服務無法啟動**
   ```bash
   docker-compose logs you2api
   ```

### 日誌查看

```bash
# 實時查看日誌
docker-compose logs -f you2api

# 查看最近 100 行日誌
docker-compose logs --tail=100 you2api
```

## 📈 性能優化

### 1. 資源限制

編輯 `docker-compose.yml` 添加資源限制：

```yaml
services:
  you2api:
    # ... 其他配置
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
```

### 2. 日誌輪轉

```yaml
services:
  you2api:
    # ... 其他配置
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## 🔐 生產環境建議

1. **使用域名和 SSL**
2. **設置防火牆規則**
3. **定期備份配置**
4. **監控服務狀態**
5. **設置日誌輪轉**
6. **使用非 root 用戶運行**

---

## 📞 技術支持

如果遇到任何問題，請檢查：
1. Docker 服務是否正常運行
2. 端口是否被正確映射
3. 防火牆設置是否正確
4. 日誌中是否有錯誤信息 