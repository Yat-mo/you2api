#!/bin/bash

# You2API 完全清理腳本
# 徹底清理之前失敗的部署
# 作者：您的專屬程序員

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日誌函數
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "🧹 You2API 完全清理腳本"
echo "=========================="
echo "⚠️  這將徹底清理所有相關的Docker資源"
echo

# 確認清理
read -p "確定要清理所有You2API相關資源嗎？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "清理已取消"
    exit 0
fi

log_info "開始清理You2API相關資源..."

# 1. 停止所有相關容器
log_info "停止所有You2API相關容器..."
docker stop you2api you2api-nginx you2api-prometheus you2api-grafana 2>/dev/null || true
log_success "容器停止完成"

# 2. 刪除所有相關容器
log_info "刪除所有You2API相關容器..."
docker rm you2api you2api-nginx you2api-prometheus you2api-grafana 2>/dev/null || true
log_success "容器刪除完成"

# 3. 停止並刪除Docker Compose服務
log_info "清理Docker Compose服務..."
if [[ -f "docker-compose.yml" ]]; then
    docker-compose down --remove-orphans 2>/dev/null || true
fi
if [[ -f "docker-compose.prod.yml" ]]; then
    docker-compose -f docker-compose.prod.yml down --remove-orphans 2>/dev/null || true
fi
if [[ -f "docker-compose.1panel.yml" ]]; then
    docker-compose -f docker-compose.1panel.yml down --remove-orphans 2>/dev/null || true
fi
log_success "Docker Compose服務清理完成"

# 4. 刪除相關鏡像
log_info "刪除You2API相關鏡像..."
docker rmi you2api-you2api 2>/dev/null || true
docker rmi $(docker images | grep you2api | awk '{print $3}') 2>/dev/null || true
log_success "鏡像清理完成"

# 5. 刪除相關網絡
log_info "刪除You2API相關網絡..."
docker network rm you2api_you2api-network 2>/dev/null || true
docker network rm you2api-network 2>/dev/null || true
log_success "網絡清理完成"

# 6. 刪除相關卷
log_info "刪除You2API相關數據卷..."
docker volume rm you2api_prometheus_data 2>/dev/null || true
docker volume rm you2api_grafana_data 2>/dev/null || true
docker volume rm prometheus_data 2>/dev/null || true
docker volume rm grafana_data 2>/dev/null || true
log_success "數據卷清理完成"

# 7. 清理懸掛的資源
log_info "清理懸掛的Docker資源..."
docker system prune -f 2>/dev/null || true
log_success "懸掛資源清理完成"

# 8. 清理相關進程
log_info "檢查並清理相關進程..."
pkill -f "you2api" 2>/dev/null || true
log_success "進程清理完成"

# 9. 清理防火牆規則（可選）
log_info "清理防火牆規則..."
if command -v ufw &> /dev/null; then
    # 注意：這裡只刪除8080端口，保留80和443給1Panel使用
    ufw delete allow 8080 2>/dev/null || true
    log_success "UFW規則清理完成"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --remove-port=8080/tcp 2>/dev/null || true
    firewall-cmd --reload 2>/dev/null || true
    log_success "Firewalld規則清理完成"
fi

# 10. 顯示清理結果
echo
log_success "🎉 You2API 完全清理完成！"
echo
echo "📋 清理摘要："
echo "   ✅ 停止並刪除所有相關容器"
echo "   ✅ 刪除相關Docker鏡像"
echo "   ✅ 刪除相關Docker網絡"
echo "   ✅ 刪除相關數據卷"
echo "   ✅ 清理懸掛資源"
echo "   ✅ 清理相關進程"
echo "   ✅ 清理防火牆規則"
echo
echo "🚀 現在可以重新部署了："
echo "   1. git pull origin main"
echo "   2. chmod +x deploy-1panel.sh"
echo "   3. ./deploy-1panel.sh"
echo
echo "💡 提示：配置文件(.env)已保留，如需重新配置請手動刪除"
echo

# 11. 驗證清理結果
log_info "驗證清理結果..."
echo
echo "🔍 當前Docker狀態："
echo "容器列表："
docker ps -a | grep -E "(you2api|CONTAINER)" || echo "   無相關容器"
echo
echo "鏡像列表："
docker images | grep -E "(you2api|REPOSITORY)" || echo "   無相關鏡像"
echo
echo "網絡列表："
docker network ls | grep -E "(you2api|NETWORK)" || echo "   無相關網絡"
echo
echo "數據卷列表："
docker volume ls | grep -E "(you2api|prometheus|grafana|DRIVER)" || echo "   無相關數據卷"
echo

log_success "清理驗證完成！系統已準備好重新部署。" 