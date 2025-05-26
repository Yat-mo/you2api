# 🎛️ You2API + 1Panel 完美部署指南

> **老闆您好！** 專門為您的 1Panel 環境定制的部署方案，讓您輕鬆管理 AI API 服務！

## 🔑 您的專屬配置

- **用戶**: YatTsun Ngan
- **API Key**: `eyJhbGciOiJSUzI1NiIs...` (已安全配置)
- **訂閱**: YouPro Annual (企業級)
- **到期時間**: 2026-05-25

## 🚀 1Panel 一鍵部署（推薦）

### 方法一：使用 1Panel 終端

1. **登錄 1Panel 面板**
   ```
   http://your-vps-ip:1panel-port
   ```

2. **打開終端**
   - 主機 → 終端
   - 或直接 SSH 連接

3. **執行部署命令**
   ```bash
   # 克隆您的專屬倉庫
   git clone https://github.com/Yat-mo/you2api.git
   cd you2api
   
   # 使用包含您 API Key 的部署腳本
   chmod +x deploy-with-key.sh
   ./deploy-with-key.sh
   ```

### 方法二：使用 1Panel Docker Compose

1. **進入容器管理**
   - 容器 → Compose 模板

2. **創建新項目**
   - 項目名稱: `you2api`
   - 工作目錄: `/opt/you2api`

3. **使用我們的配置**
   ```yaml
   version: '3.8'
   
   services:
     you2api:
       build: .
       container_name: you2api
       ports:
         - "8080:8080"
       environment:
         - PORT=8080
         - YOU_API_KEY=xxx
         - YOU_API_BASE_URL=https://api.you.com
         - LOG_LEVEL=info
       restart: unless-stopped
       healthcheck:
         test: ["CMD", "curl", "-f", "http://localhost:8080/v1/models"]
         interval: 30s
         timeout: 10s
         retries: 3
       networks:
         - you2api-network
   
   networks:
     you2api-network:
       driver: bridge
   ```

## 🌐 1Panel 網站配置

### 1. 創建反向代理網站

1. **添加網站**
   - 網站 → 創建網站 → 反向代理
   - 主域名: `your-domain.com`
   - 代理地址: `http://127.0.0.1:8080`

2. **SSL 配置**
   - 啟用 HTTPS
   - 自動申請 Let's Encrypt 證書
   - 強制 HTTPS 重定向

3. **高級配置**
   ```nginx
   # 在 1Panel 網站配置中添加
   location /v1/ {
       proxy_pass http://127.0.0.1:8080;
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
       
       # API 特殊配置
       proxy_read_timeout 300s;
       proxy_send_timeout 300s;
       client_max_body_size 10M;
   }
   ```

### 2. 防火牆配置

1. **在 1Panel 中配置**
   - 主機 → 防火牆 → 添加規則
   - 端口 8080: 允許
   - 端口 80: 允許
   - 端口 443: 允許

## 📊 1Panel 監控集成

### 1. 容器監控

1. **查看容器狀態**
   - 容器 → 容器列表
   - 查看 `you2api` 容器狀態

2. **日誌管理**
   - 容器 → 日誌
   - 實時查看應用日誌

3. **資源監控**
   - 主機 → 監控
   - CPU、內存、網絡使用情況

### 2. 自定義監控

```bash
# 在 1Panel 終端中設置監控腳本
cat > /opt/you2api/monitor.sh << 'EOF'
#!/bin/bash
# You2API 健康檢查腳本

API_URL="http://localhost:8080/v1/models"
LOG_FILE="/var/log/you2api-health.log"

if curl -s "$API_URL" > /dev/null; then
    echo "$(date): API 正常" >> "$LOG_FILE"
    exit 0
else
    echo "$(date): API 異常" >> "$LOG_FILE"
    # 可以在這裡添加重啟邏輯
    exit 1
fi
EOF

chmod +x /opt/you2api/monitor.sh
```

## 🔒 1Panel 安全配置

### 1. 訪問控制

1. **IP 白名單**
   - 網站 → 訪問控制
   - 添加允許的 IP 地址

2. **基礎認證**（可選）
   - 網站 → 訪問控制 → 基礎認證
   - 設置用戶名密碼

### 2. SSL 安全

1. **強制 HTTPS**
   - 網站 → SSL → 強制 HTTPS

2. **HSTS 配置**
   ```nginx
   # 在網站配置中添加
   add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
   ```

## 📈 性能優化

### 1. 1Panel 資源限制

```yaml
# 在 Docker Compose 中添加
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '1.0'
    reservations:
      memory: 512M
      cpus: '0.5'
```

### 2. 緩存配置

1. **Nginx 緩存**（在 1Panel 網站配置中）
   ```nginx
   location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
       expires 1y;
       add_header Cache-Control "public, immutable";
   }
   ```

## 🔄 備份與恢復

### 1. 使用 1Panel 備份功能

1. **創建備份任務**
   - 計劃任務 → 備份
   - 備份目錄: `/opt/you2api`
   - 備份頻率: 每日

2. **數據庫備份**（如果使用）
   - 數據庫 → 備份
   - 自動備份配置

### 2. 手動備份

```bash
# 在 1Panel 終端中執行
tar -czf you2api-backup-$(date +%Y%m%d).tar.gz /opt/you2api
```

## 🧪 API 測試

### 1. 基礎測試

```bash
# 在 1Panel 終端中測試
curl http://localhost:8080/v1/models

# 通過域名測試
curl https://your-domain.com/v1/models
```

### 2. 聊天 API 測試

```bash
curl -X POST https://your-domain.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello from 1Panel!"}],
    "max_tokens": 100
  }'
```

## 🎯 部署完成檢查清單

- [ ] ✅ 1Panel 容器正常運行
- [ ] ✅ 網站反向代理配置完成
- [ ] ✅ SSL 證書自動申請成功
- [ ] ✅ 防火牆規則配置正確
- [ ] ✅ API Key 安全配置
- [ ] ✅ 健康檢查正常
- [ ] ✅ 日誌監控正常
- [ ] ✅ 備份任務設置完成

## 🚨 故障排除

### 1. 容器無法啟動

```bash
# 在 1Panel 終端中檢查
docker logs you2api
docker-compose logs -f
```

### 2. API 無法訪問

1. **檢查容器狀態**
   - 1Panel → 容器 → 查看狀態

2. **檢查網站配置**
   - 1Panel → 網站 → 檢查代理配置

3. **檢查防火牆**
   - 1Panel → 主機 → 防火牆

### 3. SSL 證書問題

1. **重新申請證書**
   - 1Panel → 網站 → SSL → 重新申請

2. **檢查域名解析**
   ```bash
   nslookup your-domain.com
   ```

## 🎉 部署成功！

恭喜老闆！您的 You2API 服務已在 1Panel 中成功部署！

### 📋 重要信息

- **API 地址**: `https://your-domain.com`
- **管理面板**: `http://your-vps-ip:1panel-port`
- **API Key**: 已安全配置
- **監控**: 1Panel 內置監控
- **備份**: 自動備份已設置

### 🔗 快速鏈接

- **API 文檔**: `https://your-domain.com/v1/models`
- **健康檢查**: `https://your-domain.com/health`
- **1Panel 管理**: 容器管理、網站管理、監控面板

---

**感謝老闆選擇我們的企業級解決方案！您的 AI API 服務現在已經完美運行在 1Panel 環境中！** 🚀✨ 
