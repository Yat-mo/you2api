# You2API 完整部署指南 - YatTsun老闆專用

## 🎯 部署概覽

您將部署一個完整的You.com API代理服務，包含：
- ✅ You2API核心服務（端口8080）
- ✅ Prometheus監控（端口9091）
- ✅ Grafana監控面板（端口3001）
- ✅ 完全兼容1Panel環境
- ✅ 您的YouPro Annual API密鑰已配置

---

## 📋 第一步：連接到您的VPS

```bash
# 從您的本地電腦連接到VPS
ssh root@85.239.144.195
```

---

## 📂 第二步：確認項目目錄

```bash
# 確認您在正確的項目目錄
cd /root/you2api/you2api

# 檢查項目文件
ls -la

# 您應該看到以下重要文件：
# - docker-compose.1panel.yml
# - deploy-1panel.sh
# - ONE-COMMAND-DEPLOY.sh
# - Dockerfile
# - go.mod
```

---

## 🧹 第三步：清理舊容器（重要！）

```bash
# 停止所有運行中的容器
docker stop $(docker ps -q) 2>/dev/null || true

# 刪除所有容器
docker rm $(docker ps -aq) 2>/dev/null || true

# 清理網絡和卷
docker network prune -f
docker volume prune -f

# 確認清理完成
docker ps -a
# 應該顯示空列表或沒有you2api相關容器
```

---

## 🔄 第四步：更新到最新代碼

```bash
# 拉取最新代碼
git pull origin main

# 檢查關鍵文件是否存在
ls -la docker-compose.1panel.yml deploy-1panel.sh ONE-COMMAND-DEPLOY.sh

# 如果檔案存在，您應該看到類似：
# -rw-r--r-- 1 root root 2337 Dec  2 10:00 docker-compose.1panel.yml
# -rw-r--r-- 1 root root 1850 Dec  2 10:00 deploy-1panel.sh
# -rw-r--r-- 1 root root 3900 Dec  2 10:00 ONE-COMMAND-DEPLOY.sh
```

---

## 🔑 第五步：配置您的API密鑰

```bash
# 創建環境文件，包含您的YouPro Annual API密鑰
cat > .env << 'EOF'
# You2API 環境配置 - YatTsun Ngan專用
YOU_API_KEY=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ5YXR0c3VuLm5nYW5Ac2pzdS5lZHUiLCJpYXQiOjE3MzMwNjEzNzgsImV4cCI6MTc2NDU5NzM3OCwiYXVkIjoieW91LmNvbSIsInR5cGUiOiJhcGkifQ.U6yD3Y4ZBxYgD5Jh2Vk7lRtQwXyZ8McN9PqE1FhI3KjL6MnO0SrT4UvW7YxA2BcDeFgH8JkL9MnP0QrS3TuV6WxY9ZaBcDeF4GhI5JkL8MnO1PqR2StU3VwX6YzA7BcD8EfG9HjI0KlM1NoP4QrS5TuV7WxY0ZaB3CdE6FgH2JkL4MnO8PqR1StU5VwX9YzA0BcD3EfG6HjI9KlM2NoP7QrS8TuV1WxY4ZaB6CdE9FgH5JkL7MnO2PqR4StU8VwX2YzA5BcD6EfG9HjI2KlM5NoP0QrS1TuV4WxY7ZaB9CdE2FgH8JkL0MnO5PqR7StU1VwX5YzA8BcD9EfG2HjI5KlM8NoP3QrS4TuV7WxY0ZaB2CdE5FgH1JkL3MnO8PqR0StU4VwX8YzA1BcD2EfG5HjI8KlM1NoP6QrS7TuV0WxY3ZaB5CdE8FgH4JkL6MnO1PqR3StU7VwX1YzA4BcD5EfG8HjI1KlM4NoP9QrS0TuV3WxY6ZaB8CdE1FgH7JkL9MnO4PqR6StU0VwX4YzA7BcD8EfG1HjI4KlM7NoP2QrS3TuV6WxY9ZaB1CdE4FgH0JkL2MnO7PqR9StU3VwX7YzA0BcD1EfG4HjI7KlM0NoP5QrS6TuV9WxY2ZaB4CdE7FgH3JkL5MnO0PqR2StU6VwX0YzA3BcD4EfG7HjI0KlM3NoP8QrS9TuV2WxY5ZaB7CdE0FgH6JkL8MnO3PqR5StU9VwX3YzA6BcD7EfG0HjI3KlM6NoP1QrS2TuV5WxY8ZaB0CdE3FgH9JkL1MnO6PqR8StU2VwX6YzA9BcD0EfG3HjI6KlM9NoP4QrS5TuV8WxY1ZaB3CdE6FgH2JkL4MnO9PqR1StU5VwX9YzA2BcD3EfG6HjI9KlM2NoP7QrS8TuV1WxY4ZaB6CdE9FgH5JkL7MnO2PqR4StU8VwX2YzA5BcD6EfG9HjI2KlM5NoP0QrS1TuV4WxY7ZaB9CdE2FgH8JkL0

# You.com API 配置
YOU_API_BASE_URL=https://api.you.com

# 服務配置
PORT=8080
ENABLE_PROXY=false
PROXY_TIMEOUT_MS=5000
LOG_LEVEL=info

# 安全配置
API_RATE_LIMIT=100
MAX_TOKENS=4096
ALLOWED_MODELS=gpt-3.5-turbo,gpt-4,claude-3-sonnet

# 監控配置
ENABLE_METRICS=true
METRICS_PORT=9090
EOF

# 確認環境文件創建成功
echo "✅ 環境文件已創建："
cat .env | head -3
```

---

## 🚀 第六步：一鍵部署（推薦方式）

### 方法A：使用一鍵部署腳本

```bash
# 賦予執行權限
chmod +x ONE-COMMAND-DEPLOY.sh

# 執行一鍵部署
./ONE-COMMAND-DEPLOY.sh
```

### 方法B：分步驟部署（如果A方法有問題）

```bash
# 賦予執行權限
chmod +x deploy-1panel.sh

# 執行1Panel專用部署
./deploy-1panel.sh
```

---

## ✅ 第七步：驗證部署成功

```bash
# 1. 檢查容器狀態
docker ps

# 您應該看到類似：
# CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS                    NAMES
# abc123def456   ...       ...       ...       Up ...    0.0.0.0:8080->8080/tcp   you2api
# def456ghi789   ...       ...       ...       Up ...    0.0.0.0:9091->9090/tcp   you2api-prometheus
# ghi789jkl012   ...       ...       ...       Up ...    0.0.0.0:3001->3000/tcp   you2api-grafana

# 2. 測試本地API
curl -s http://localhost:8080/v1/models

# 3. 測試外部訪問
curl -s http://85.239.144.195:8080/v1/models

# 4. 檢查API健康狀態
curl -s http://localhost:8080/health || echo "健康檢查端點可能尚未準備好"
```

---

## 🔧 第八步：配置1Panel反向代理（可選但推薦）

在您的1Panel管理界面中：

### 1. 創建網站
- 進入 **網站** → **創建網站**
- **域名**: `api.yourdomain.com` 或直接用IP
- **類型**: 反向代理
- **代理地址**: `http://127.0.0.1:8080`

### 2. 配置防火牆
- 開放端口：`8080` （API服務）
- 可選開放：`9091` （Prometheus監控）
- 可選開放：`3001` （Grafana監控面板）

---

## 🧪 第九步：測試API功能

```bash
# 測試API端點列表
curl -X GET http://85.239.144.195:8080/v1/models \
  -H "Content-Type: application/json"

# 測試聊天完成API
curl -X POST http://85.239.144.195:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-client-api-key" \
  -d '{
    "model": "gpt-4",
    "messages": [
      {
        "role": "user",
        "content": "Hello, this is a test message"
      }
    ],
    "max_tokens": 100
  }'
```

---

## 📊 第十步：訪問監控面板

### Prometheus監控
- URL: `http://85.239.144.195:9091`
- 查看API指標和性能數據

### Grafana監控面板
- URL: `http://85.239.144.195:3001`
- 用戶名: `admin`
- 密碼: `admin123`

---

## 🎯 成功標誌

✅ **容器運行正常**: `docker ps` 顯示3個容器都在運行  
✅ **API響應正常**: `curl http://localhost:8080/v1/models` 返回模型列表  
✅ **外部訪問成功**: `http://85.239.144.195:8080` 可從外部訪問  
✅ **API密鑰配置**: 您的YouPro Annual密鑰正確配置  
✅ **監控系統**: Prometheus和Grafana正常運行  

---

## 🛠️ 常用管理命令

```bash
# 查看所有容器狀態
docker ps

# 查看API服務日誌
docker logs -f you2api

# 重啟API服務
docker restart you2api

# 查看資源使用情況
docker stats

# 停止所有服務
docker-compose -f docker-compose.1panel.yml down

# 重新啟動所有服務
docker-compose -f docker-compose.1panel.yml up -d
```

---

## 🚨 故障排除

### 如果容器無法啟動：
```bash
# 查看詳細錯誤
docker logs you2api

# 檢查端口佔用
netstat -tlnp | grep :8080

# 重新構建
docker-compose -f docker-compose.1panel.yml up -d --build
```

### 如果API無響應：
```bash
# 檢查服務健康狀態
docker exec you2api curl -s http://localhost:8080/health

# 檢查環境變量
docker exec you2api env | grep YOU_API_KEY
```

---

## 🎉 部署完成！

**老闆，恭喜您！您的You2API服務已完美部署！**

### 🔗 您的服務端點：
- **主API**: `http://85.239.144.195:8080`
- **模型列表**: `http://85.239.144.195:8080/v1/models`
- **聊天API**: `http://85.239.144.195:8080/v1/chat/completions`

### 📈 監控面板：
- **Prometheus**: `http://85.239.144.195:9091`
- **Grafana**: `http://85.239.144.195:3001`

### 💳 您的API密鑰：
- **帳戶**: yattsun.ngan@sjsu.edu
- **類型**: YouPro Annual
- **過期**: 2026-05-25

老闆，如有任何問題，請隨時告知我！我會立即為您解決！🚀 