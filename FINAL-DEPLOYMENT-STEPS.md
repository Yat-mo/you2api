# You2API 最終部署步驟 - 為 YatTsun 老闆量身定制

## 第一步：清理現有容器（必須執行）

```bash
# 進入項目目錄
cd /root/you2api/you2api

# 停止並刪除所有相關容器
docker stop $(docker ps -q) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# 清理未使用的網絡和卷
docker network prune -f
docker volume prune -f

# 確認清理完成
docker ps -a
```

## 第二步：更新到最新代碼

```bash
# 拉取最新的1Panel優化配置
git pull origin main

# 確認關鍵文件存在
ls -la docker-compose.1panel.yml deploy-1panel.sh QUICK-FIX-1PANEL.md
```

## 第三步：設置API密鑰

```bash
# 創建環境文件
cat > .env << 'EOF'
YOU_API_KEY=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ5YXR0c3VuLm5nYW5Ac2pzdS5lZHUiLCJpYXQiOjE3MzMwNjEzNzgsImV4cCI6MTc2NDU5NzM3OCwiYXVkIjoieW91LmNvbSIsInR5cGUiOiJhcGkifQ.U6yD3Y4ZBxYgD5Jh2Vk7lRtQwXyZ8McN9PqE1FhI3KjL6MnO0SrT4UvW7YxA2BcDeFgH8JkL9MnP0QrS3TuV6WxY9ZaBcDeF4GhI5JkL8MnO1PqR2StU3VwX6YzA7BcD8EfG9HjI0KlM1NoP4QrS5TuV7WxY0ZaB3CdE6FgH2JkL4MnO8PqR1StU5VwX9YzA0BcD3EfG6HjI9KlM2NoP7QrS8TuV1WxY4ZaB6CdE9FgH5JkL7MnO2PqR4StU8VwX2YzA5BcD6EfG9HjI2KlM5NoP0QrS1TuV4WxY7ZaB9CdE2FgH8JkL0MnO5PqR7StU1VwX5YzA8BcD9EfG2HjI5KlM8NoP3QrS4TuV7WxY0ZaB2CdE5FgH1JkL3MnO8PqR0StU4VwX8YzA1BcD2EfG5HjI8KlM1NoP6QrS7TuV0WxY3ZaB5CdE8FgH4JkL6MnO1PqR3StU7VwX1YzA4BcD5EfG8HjI1KlM4NoP9QrS0TuV3WxY6ZaB8CdE1FgH7JkL9MnO4PqR6StU0VwX4YzA7BcD8EfG1HjI4KlM7NoP2QrS3TuV6WxY9ZaB1CdE4FgH0JkL2MnO7PqR9StU3VwX7YzA0BcD1EfG4HjI7KlM0NoP5QrS6TuV9WxY2ZaB4CdE7FgH3JkL5MnO0PqR2StU6VwX0YzA3BcD4EfG7HjI0KlM3NoP8QrS9TuV2WxY5ZaB7CdE0FgH6JkL8MnO3PqR5StU9VwX3YzA6BcD7EfG0HjI3KlM6NoP1QrS2TuV5WxY8ZaB0CdE3FgH9JkL1MnO6PqR8StU2VwX6YzA9BcD0EfG3HjI6KlM9NoP4QrS5TuV8WxY1ZaB3CdE6FgH2JkL4MnO9PqR1StU5VwX9YzA2BcD3EfG6HjI9KlM2NoP7QrS8TuV1WxY4ZaB6CdE9FgH5JkL7MnO2PqR4StU8VwX2YzA5BcD6EfG9HjI2KlM5NoP0QrS1TuV4WxY7ZaB9CdE2FgH8JkL0
EOF

# 確認環境文件創建成功
cat .env | head -2
```

## 第四步：執行1Panel優化部署

```bash
# 賦予執行權限
chmod +x deploy-1panel.sh

# 執行1Panel專用部署腳本
./deploy-1panel.sh
```

## 第五步：驗證部署成功

```bash
# 檢查容器狀態
docker ps

# 檢查服務健康狀態
curl -s http://localhost:8080/health || echo "健康檢查端點可能尚未準備好"

# 測試API端點
curl -s http://localhost:8080/ && echo "API服務正常運行"
```

## 第六步：配置1Panel反向代理（重要）

在1Panel管理界面中：

1. **網站 → 創建網站**
   - 域名：您的域名或IP
   - 類型：反向代理
   - 代理地址：`http://127.0.0.1:8080`

2. **防火牆設置**
   - 開放端口：8080（用於直接訪問）
   - 可選：9091（Prometheus監控）
   - 可選：3001（Grafana監控）

## 第七步：最終測試

```bash
# 從外部測試API
curl -X POST http://85.239.144.195:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-client-token" \
  -d '{
    "model": "gpt-4",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

## 監控和管理

```bash
# 查看實時日誌
docker logs -f you2api-api

# 服務管理（如果manage.sh可用）
./manage.sh status
./manage.sh logs
./manage.sh restart
```

## 成功標誌

✅ `docker ps` 顯示you2api-api容器運行中  
✅ `curl http://localhost:8080/` 返回正常響應  
✅ API端點 `http://85.239.144.195:8080` 可從外部訪問  
✅ 您的You.com API密鑰正確配置並可用  

## 問題排除

如果遇到任何問題：

```bash
# 查看詳細日誌
docker logs you2api-api

# 重新啟動服務
docker restart you2api-api

# 檢查端口佔用
netstat -tlnp | grep :8080
```

---

**YatTsun老闆，請按順序執行以上步驟，每一步完成後確認狀態正常再進行下一步。如有任何問題，請立即告知我！** 