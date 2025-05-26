#!/bin/bash

# You2API 服務管理腳本
# 作者：您的專屬程序員

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 項目目錄
PROJECT_DIR="/opt/you2api"

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

# 檢查項目目錄
check_project() {
    if [[ ! -d "$PROJECT_DIR" ]]; then
        log_error "項目目錄不存在: $PROJECT_DIR"
        log_info "請先運行部署腳本: ./deploy.sh"
        exit 1
    fi
    cd "$PROJECT_DIR"
}

# 顯示服務狀態
status() {
    log_info "檢查服務狀態..."
    docker-compose ps
    echo
    
    # 檢查 API 是否可用
    if curl -s http://localhost:8080/v1/models > /dev/null 2>&1; then
        log_success "API 服務正常運行"
    else
        log_warning "API 服務可能未正常運行"
    fi
}

# 啟動服務
start() {
    log_info "啟動 You2API 服務..."
    if [[ -f "docker-compose.prod.yml" ]]; then
        docker-compose -f docker-compose.prod.yml up -d
    else
        docker-compose up -d
    fi
    log_success "服務啟動完成"
}

# 停止服務
stop() {
    log_info "停止 You2API 服務..."
    docker-compose down
    log_success "服務已停止"
}

# 重啟服務
restart() {
    log_info "重啟 You2API 服務..."
    docker-compose restart
    log_success "服務重啟完成"
}

# 查看日誌
logs() {
    log_info "顯示服務日誌..."
    docker-compose logs -f you2api
}

# 更新服務
update() {
    log_info "更新 You2API 服務..."
    
    # 備份當前配置
    cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
    
    # 拉取最新代碼
    git pull
    
    # 重新構建並啟動
    if [[ -f "docker-compose.prod.yml" ]]; then
        docker-compose -f docker-compose.prod.yml build --no-cache
        docker-compose -f docker-compose.prod.yml up -d
    else
        docker-compose build --no-cache
        docker-compose up -d
    fi
    
    log_success "服務更新完成"
}

# 清理資源
cleanup() {
    log_warning "這將清理所有 Docker 資源（包括未使用的鏡像、容器等）"
    read -p "確定要繼續嗎？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "清理 Docker 資源..."
        docker system prune -af
        docker volume prune -f
        log_success "清理完成"
    fi
}

# 備份配置
backup() {
    log_info "備份配置文件..."
    BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # 備份重要文件
    cp docker-compose.yml "$BACKUP_DIR/" 2>/dev/null || true
    cp docker-compose.prod.yml "$BACKUP_DIR/" 2>/dev/null || true
    cp nginx.conf "$BACKUP_DIR/" 2>/dev/null || true
    cp prometheus.yml "$BACKUP_DIR/" 2>/dev/null || true
    
    tar -czf "${BACKUP_DIR}.tar.gz" "$BACKUP_DIR"
    rm -rf "$BACKUP_DIR"
    
    log_success "配置已備份到: ${BACKUP_DIR}.tar.gz"
}

# 監控服務
monitor() {
    log_info "監控服務狀態（按 Ctrl+C 退出）..."
    while true; do
        clear
        echo "=== You2API 服務監控 ==="
        echo "時間: $(date)"
        echo
        
        # 服務狀態
        echo "📊 容器狀態:"
        docker-compose ps
        echo
        
        # 資源使用
        echo "💾 資源使用:"
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
        echo
        
        # API 健康檢查
        echo "🔍 API 健康檢查:"
        if curl -s http://localhost:8080/v1/models > /dev/null 2>&1; then
            echo "✅ API 服務正常"
        else
            echo "❌ API 服務異常"
        fi
        
        sleep 5
    done
}

# 測試 API
test_api() {
    log_info "測試 API 功能..."
    
    echo "1. 測試模型列表..."
    if curl -s http://localhost:8080/v1/models | jq . > /dev/null 2>&1; then
        log_success "模型列表 API 正常"
    else
        log_error "模型列表 API 異常"
    fi
    
    echo "2. 測試聊天 API..."
    RESPONSE=$(curl -s -X POST http://localhost:8080/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer test-key" \
        -d '{
            "model": "gpt-3.5-turbo",
            "messages": [{"role": "user", "content": "Hello"}],
            "max_tokens": 10
        }')
    
    if echo "$RESPONSE" | jq . > /dev/null 2>&1; then
        log_success "聊天 API 正常"
    else
        log_error "聊天 API 異常"
        echo "響應: $RESPONSE"
    fi
}

# 顯示幫助
show_help() {
    echo "You2API 服務管理腳本"
    echo
    echo "用法: $0 [命令]"
    echo
    echo "可用命令:"
    echo "  status    - 顯示服務狀態"
    echo "  start     - 啟動服務"
    echo "  stop      - 停止服務"
    echo "  restart   - 重啟服務"
    echo "  logs      - 查看日誌"
    echo "  update    - 更新服務"
    echo "  cleanup   - 清理 Docker 資源"
    echo "  backup    - 備份配置"
    echo "  monitor   - 監控服務"
    echo "  test      - 測試 API"
    echo "  help      - 顯示此幫助"
    echo
}

# 主函數
main() {
    case "${1:-help}" in
        status)
            check_project
            status
            ;;
        start)
            check_project
            start
            ;;
        stop)
            check_project
            stop
            ;;
        restart)
            check_project
            restart
            ;;
        logs)
            check_project
            logs
            ;;
        update)
            check_project
            update
            ;;
        cleanup)
            cleanup
            ;;
        backup)
            check_project
            backup
            ;;
        monitor)
            check_project
            monitor
            ;;
        test)
            check_project
            test_api
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 執行主函數
main "$@" 