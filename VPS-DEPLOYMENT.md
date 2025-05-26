# 🚀 You2API VPS 部署快速指南

> **老闆您好！** 我為您準備了最完美的 VPS 部署方案，保證讓您的服務穩定運行！

## ⚡ 一鍵部署（推薦）

### 1. 登錄您的 VPS

```bash
ssh root@your-vps-ip
# 或
ssh your-username@your-vps-ip
```

### 2. 下載並運行部署腳本

```bash
# 下載項目
wget https://github.com/bohesocool/you2api/archive/refs/heads/main.zip
unzip main.zip
cd you2api-main

# 或者使用 git 克隆
git clone https://github.com/bohesocool/you2api.git
cd you2api

# 運行一鍵部署腳本
chmod +x deploy.sh
./deploy.sh
```

### 3. 等待部署完成

腳本會自動：
- ✅ 安裝 Docker 和 Docker Compose
- ✅ 配置防火牆
- ✅ 克隆項目代碼
- ✅ 啟動服務
- ✅ 創建系統服務（開機自啟）
- ✅ 顯示訪問信息

## 🎯 部署完成後

### 訪問您的 API

```bash
# 測試 API 是否正常
curl http://your-vps-ip:8080/v1/models

# 測試聊天功能
curl -X POST http://your-vps-ip:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-api-key" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### 服務管理

```bash
# 使用管理腳本
./manage.sh status    # 查看狀態
./manage.sh logs      # 查看日誌
./manage.sh restart   # 重啟服務
./manage.sh monitor   # 監控服務
./manage.sh test      # 測試 API

# 或直接使用 Docker Compose
docker-compose ps              # 查看容器狀態
docker-compose logs -f you2api # 查看實時日誌
docker-compose restart         # 重啟服務
```

## 🔧 配置選項

### 環境變量

編輯 `docker-compose.yml` 修改配置：

```yaml
environment:
  - PORT=8080              # API 端口
  - ENABLE_PROXY=false     # 是否啟用代理
  - PROXY_URL=             # 代理地址
  - PROXY_TIMEOUT_MS=5000  # 代理超時
  - LOG_LEVEL=info         # 日誌級別
```

### 端口說明

- **8080**: You2API 主服務端口
- **9090**: Prometheus 監控（可選）
- **3000**: Grafana 監控面板（可選）

## 🔒 安全建議

### 1. 使用 Nginx 反向代理

```bash
# 安裝 Nginx
sudo apt install nginx -y

# 使用提供的配置文件
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl reload nginx
```

### 2. 配置 SSL 證書

```bash
# 安裝 Certbot
sudo apt install certbot python3-certbot-nginx -y

# 獲取免費 SSL 證書
sudo certbot --nginx -d your-domain.com
```

### 3. 防火牆設置

```bash
# 只允許必要端口
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

## 📊 監控配置

### 啟用完整監控

```bash
# 使用生產環境配置（包含監控）
docker-compose -f docker-compose.prod.yml up -d

# 訪問監控面板
# Prometheus: http://your-vps-ip:9090
# Grafana: http://your-vps-ip:3000 (admin/admin123)
```

## 🚨 故障排除

### 常見問題

1. **服務無法啟動**
   ```bash
   # 查看詳細日誌
   docker-compose logs you2api
   
   # 檢查端口占用
   sudo netstat -tulpn | grep :8080
   ```

2. **API 無法訪問**
   ```bash
   # 檢查防火牆
   sudo ufw status
   
   # 檢查服務狀態
   docker-compose ps
   ```

3. **內存不足**
   ```bash
   # 查看資源使用
   docker stats
   
   # 清理無用資源
   ./manage.sh cleanup
   ```

### 日誌查看

```bash
# 實時查看日誌
./manage.sh logs

# 查看系統日誌
sudo journalctl -u you2api.service -f
```

## 🔄 更新服務

```bash
# 使用管理腳本更新
./manage.sh update

# 或手動更新
git pull
docker-compose build --no-cache
docker-compose up -d
```

## 📈 性能優化

### 1. 調整資源限制

編輯 `docker-compose.prod.yml`：

```yaml
deploy:
  resources:
    limits:
      memory: 1G        # 根據您的 VPS 配置調整
      cpus: '1.0'
    reservations:
      memory: 512M
      cpus: '0.5'
```

### 2. 啟用日誌輪轉

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

## 🎉 部署成功！

恭喜老闆！您的 You2API 服務已經成功部署到 VPS 上了！

### 重要信息

- **API 地址**: `http://your-vps-ip:8080`
- **項目目錄**: `/opt/you2api`
- **管理腳本**: `./manage.sh`
- **配置文件**: `docker-compose.yml`

### 下一步

1. 🔗 配置域名和 SSL 證書
2. 📊 啟用監控面板
3. 🔒 設置訪問控制
4. 📝 定期備份配置

---

## 💬 技術支持

如果遇到任何問題，我隨時為您服務！請提供：

1. 錯誤日誌：`./manage.sh logs`
2. 服務狀態：`./manage.sh status`
3. 系統信息：`uname -a && docker --version`

**感謝老闆的信任！我會繼續為您提供最優質的技術服務！** 🙏 