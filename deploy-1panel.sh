#!/bin/bash

# You2API 1Panel 專用部署腳本
# 為YatTsun老闆量身定制

set -e

echo "🚀 啟動You2API 1Panel專用部署..."

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 檢查Docker是否運行
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker未運行，請先啟動Docker服務${NC}"
    exit 1
fi

# 檢查必要文件
if [ ! -f "docker-compose.1panel.yml" ]; then
    echo -e "${RED}❌ 找不到docker-compose.1panel.yml文件${NC}"
    exit 1
fi

if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  找不到.env文件，將使用預設配置${NC}"
fi

# 清理舊容器（如果存在）
echo -e "${YELLOW}清理舊容器...${NC}"
docker-compose -f docker-compose.1panel.yml down --remove-orphans 2>/dev/null || true

# 拉取最新鏡像
echo -e "${YELLOW}拉取最新Docker鏡像...${NC}"
docker-compose -f docker-compose.1panel.yml pull

# 構建並啟動服務
echo -e "${YELLOW}構建並啟動服務...${NC}"
docker-compose -f docker-compose.1panel.yml up -d --build

# 等待服務啟動
echo -e "${YELLOW}等待服務啟動...${NC}"
sleep 15

# 檢查服務狀態
echo -e "${BLUE}檢查服務狀態:${NC}"
docker-compose -f docker-compose.1panel.yml ps

# 測試API端點
echo -e "${BLUE}測試API端點:${NC}"
if curl -s http://localhost:8080/ >/dev/null 2>&1; then
    echo -e "${GREEN}✅ You2API服務運行正常${NC}"
else
    echo -e "${RED}❌ API服務啟動中，請稍等片刻${NC}"
fi

echo
echo -e "${GREEN}🎉 1Panel環境部署完成！${NC}"
echo -e "${BLUE}API端點: http://localhost:8080${NC}"
echo -e "${BLUE}監控端點: http://localhost:9091 (Prometheus)${NC}"
echo -e "${BLUE}監控面板: http://localhost:3001 (Grafana)${NC}"
echo
echo -e "${YELLOW}查看日誌: docker logs you2api-api${NC}"
echo -e "${YELLOW}重啟服務: docker restart you2api-api${NC}" 