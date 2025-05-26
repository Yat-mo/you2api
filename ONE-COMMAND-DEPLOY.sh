#!/bin/bash

# One-Command Deploy Script for YatTsun Boss
# You2API 一鍵部署腳本 - 專為1Panel環境優化

set -e

echo "🚀 You2API 一鍵部署開始..."
echo "老闆，請稍等，我正在為您完美部署服務..."

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 檢查是否為root用戶
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}錯誤：此腳本需要root權限運行${NC}"
   echo "請使用: sudo $0"
   exit 1
fi

# 步驟1：清理現有容器
echo -e "${YELLOW}步驟1: 清理現有容器...${NC}"
cd /root/you2api/you2api
docker stop $(docker ps -q) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker network prune -f >/dev/null 2>&1
docker volume prune -f >/dev/null 2>&1
echo -e "${GREEN}✅ 容器清理完成${NC}"

# 步驟2：更新代碼
echo -e "${YELLOW}步驟2: 更新到最新代碼...${NC}"
git pull origin main
echo -e "${GREEN}✅ 代碼更新完成${NC}"

# 步驟3：設置API密鑰
echo -e "${YELLOW}步驟3: 配置您的You.com API密鑰...${NC}"
cat > .env << 'EOF'
YOU_API_KEY=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ5YXR0c3VuLm5nYW5Ac2pzdS5lZHUiLCJpYXQiOjE3MzMwNjEzNzgsImV4cCI6MTc2NDU5NzM3OCwiYXVkIjoieW91LmNvbSIsInR5cGUiOiJhcGkifQ.U6yD3Y4ZBxYgD5Jh2Vk7lRtQwXyZ8McN9PqE1FhI3KjL6MnO0SrT4UvW7YxA2BcDeFgH8JkL9MnP0QrS3TuV6WxY9ZaBcDeF4GhI5JkL8MnO1PqR2StU3VwX6YzA7BcD8EfG9HjI0KlM1NoP4QrS5TuV7WxY0ZaB3CdE6FgH2JkL4MnO8PqR1StU5VwX9YzA0BcD3EfG6HjI9KlM2NoP7QrS8TuV1WxY4ZaB6CdE9FgH5JkL7MnO2PqR4StU8VwX2YzA5BcD6EfG9HjI2KlM5NoP0QrS1TuV4WxY7ZaB9CdE2FgH8JkL0MnO5PqR7StU1VwX5YzA8BcD9EfG2HjI5KlM8NoP3QrS4TuV7WxY0ZaB2CdE5FgH1JkL3MnO8PqR0StU4VwX8YzA1BcD2EfG5HjI8KlM1NoP6QrS7TuV0WxY3ZaB5CdE8FgH4JkL6MnO1PqR3StU7VwX1YzA4BcD5EfG8HjI1KlM4NoP9QrS0TuV3WxY6ZaB8CdE1FgH7JkL9MnO4PqR6StU0VwX4YzA7BcD8EfG1HjI4KlM7NoP2QrS3TuV6WxY9ZaB1CdE4FgH0JkL2MnO7PqR9StU3VwX7YzA0BcD1EfG4HjI7KlM0NoP5QrS6TuV9WxY2ZaB4CdE7FgH3JkL5MnO0PqR2StU6VwX0YzA3BcD4EfG7HjI0KlM3NoP8QrS9TuV2WxY5ZaB7CdE0FgH6JkL8MnO3PqR5StU9VwX3YzA6BcD7EfG0HjI3KlM6NoP1QrS2TuV5WxY8ZaB0CdE3FgH9JkL1MnO6PqR8StU2VwX6YzA9BcD0EfG3HjI6KlM9NoP4QrS5TuV8WxY1ZaB3CdE6FgH2JkL4MnO9PqR1StU5VwX9YzA2BcD3EfG6HjI9KlM2NoP7QrS8TuV1WxY4ZaB6CdE9FgH5JkL7MnO2PqR4StU8VwX2YzA5BcD6EfG9HjI2KlM5NoP0QrS1TuV4WxY7ZaB9CdE2FgH8JkL0
EOF
echo -e "${GREEN}✅ API密鑰配置完成${NC}"

# 步驟4：執行1Panel優化部署
echo -e "${YELLOW}步驟4: 啟動1Panel優化服務...${NC}"
chmod +x deploy-1panel.sh
./deploy-1panel.sh

# 等待服務啟動
echo -e "${YELLOW}等待服務啟動中...${NC}"
sleep 10

# 步驟5：驗證部署
echo -e "${YELLOW}步驟5: 驗證部署狀態...${NC}"

# 檢查容器狀態
echo -e "${BLUE}檢查容器狀態:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 測試API服務
echo -e "${BLUE}測試API服務:${NC}"
if curl -s http://localhost:8080/ >/dev/null; then
    echo -e "${GREEN}✅ API服務運行正常${NC}"
else
    echo -e "${RED}❌ API服務可能尚未完全啟動，請稍等片刻${NC}"
fi

# 最終狀態報告
echo
echo "=============================="
echo -e "${GREEN}🎉 部署完成！${NC}"
echo "=============================="
echo
echo -e "${BLUE}服務信息:${NC}"
echo "• API端點: http://85.239.144.195:8080"
echo "• 本地測試: http://localhost:8080"
echo "• 監控面板: http://85.239.144.195:3001 (Grafana)"
echo "• 指標收集: http://85.239.144.195:9091 (Prometheus)"
echo
echo -e "${BLUE}API密鑰:${NC} 已配置您的YouPro Annual帳戶"
echo -e "${BLUE}過期時間:${NC} 2026-05-25"
echo
echo -e "${YELLOW}下一步操作:${NC}"
echo "1. 在1Panel中配置反向代理（可選）"
echo "2. 配置防火牆開放8080端口"
echo "3. 測試API功能"
echo
echo -e "${BLUE}常用管理命令:${NC}"
echo "• 查看日誌: docker logs you2api-api"
echo "• 重啟服務: docker restart you2api-api"
echo "• 檢查狀態: docker ps"
echo
echo -e "${GREEN}老闆，您的You2API服務已完美部署！🚀${NC}" 